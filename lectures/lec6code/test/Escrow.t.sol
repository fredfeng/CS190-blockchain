// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Escrow.sol";

/// @dev Malicious receiver that tries to reenter withdraw() upon receiving ETH.
/// We allow setting the target after deployment to avoid constructor ordering issues.
contract ReentrantReceiver {
    Escrow public target;
    bool internal reentered;

    function setTarget(Escrow _target) external {
        target = _target;
    }

    receive() external payable {
        if (!reentered && address(target) != address(0)) {
            reentered = true;
            // Low-level call: even if it fails, it won't revert the outer transfer.
            (bool ok, ) = address(target).call(
                abi.encodeWithSelector(Escrow.withdraw.selector)
            );
            // Silence the unused variable warning
            ok;
        }
    }
}

/// To test, issue: forge test --match-contract EscrowTest -vv
contract EscrowTest is Test {
    Escrow esc;
    address payer   = address(0xA1);
    address payee   = address(0xB2);
    address arbiter = address(0xC3);

    uint256 constant AMOUNT = 5 ether;

    function setUp() public {
        vm.deal(payer, 100 ether);
        vm.deal(payee, 10 ether);
        vm.deal(arbiter, 10 ether);

        // Deploy and fund the escrow (payer deploys and funds it)
        vm.prank(payer);
        esc = new Escrow{value: AMOUNT}(payer, payee, arbiter, block.timestamp + 7 days);
    }

    /* ============ BASIC FLOWS ============ */

    function test_ConstructorState() public view {
        assertEq(address(esc).balance, AMOUNT);
        assertEq(uint(esc.s()), uint(Escrow.State.Funded));
        assertEq(esc.amount(), AMOUNT);
        assertEq(esc.payer(), payer);
        assertEq(esc.payee(), payee);
        assertEq(esc.arbiter(), arbiter);
        assertGt(esc.deadline(), block.timestamp);
    }

    function test_Release_BeforeDeadline_PayeeGetsPaid() public {
        // Payer releases before the deadline
        vm.prank(payer);
        esc.release();

        assertEq(uint(esc.s()), uint(Escrow.State.Resolved));
        assertEq(esc.credit(payee), AMOUNT);

        // Payee withdraws successfully
        uint256 balBefore = payee.balance;
        vm.prank(payee);
        esc.withdraw();
        assertEq(payee.balance, balBefore + AMOUNT);
        assertEq(esc.credit(payee), 0);
        assertEq(address(esc).balance, 0);
    }

    function test_Refund_AfterDeadline_PayerGetsRefund() public {
        // Move time past the deadline
        vm.warp(esc.deadline() + 1);
        vm.prank(payer);
        esc.refund();

        assertEq(uint(esc.s()), uint(Escrow.State.Resolved));
        assertEq(esc.credit(payer), AMOUNT);

        uint256 balBefore = payer.balance;
        vm.prank(payer);
        esc.withdraw();
        assertEq(payer.balance, balBefore + AMOUNT);
        assertEq(address(esc).balance, 0);
    }

    function test_ArbiterResolve_ToPayee() public {
        vm.prank(arbiter);
        esc.resolve(true);
        assertEq(esc.credit(payee), AMOUNT);

        // Once resolved, any further resolve should fail
        vm.prank(arbiter);
        vm.expectRevert(Escrow.BadState.selector);
        esc.resolve(false);
    }

    function test_ArbiterResolve_ToPayer() public {
        vm.prank(arbiter);
        esc.resolve(false);
        assertEq(esc.credit(payer), AMOUNT);

        // Payer withdraws successfully
        uint256 balBefore = payer.balance;
        vm.prank(payer);
        esc.withdraw();
        assertEq(payer.balance, balBefore + AMOUNT);
    }

    /* ============ PERMISSIONS & STATE VALIDATION ============ */

    function test_Permissions() public {
        // Non-payer cannot call release or refund
        vm.expectRevert(Escrow.NotPayer.selector);
        esc.release();
        vm.expectRevert(Escrow.NotPayer.selector);
        esc.refund();

        // Non-arbiter cannot call resolve
        vm.expectRevert(Escrow.NotArbiter.selector);
        esc.resolve(true);
    }

    function test_SingleOutcome() public {
        // First, payer releases
        vm.prank(payer);
        esc.release();

        // After finalization, no other terminal calls are allowed
        vm.prank(payer);
        vm.expectRevert(Escrow.BadState.selector);
        esc.release();

        vm.prank(payer);
        vm.expectRevert(Escrow.BadState.selector);
        esc.refund();

        vm.prank(arbiter);
        vm.expectRevert(Escrow.BadState.selector);
        esc.resolve(false);
    }

    function test_Withdraw_Idempotent() public {
        vm.prank(payer);
        esc.release();

        // First withdrawal should succeed
        vm.prank(payee);
        esc.withdraw();

        // Second withdrawal should revert (no balance left)
        vm.prank(payee);
        vm.expectRevert(Escrow.NothingToWithdraw.selector);
        esc.withdraw();
    }

    /* ============ REENTRANCY SAFETY TESTS ============ */

    function test_Reentrancy_PullOverPushAndCEI() public {
        // Deploy attacker first
        ReentrantReceiver attacker = new ReentrantReceiver();

        // Deploy a fresh escrow whose payee is the attacker
        vm.prank(payer);
        Escrow esc2 = new Escrow{value: AMOUNT}(payer, address(attacker), arbiter, block.timestamp + 7 days);

        // Also assume that the escrow contract has its own balance for
        // demonstrating reentrancy attack
        uint256 ESC2_INIT_AMOUNT = 100 ether;
        vm.deal(address(esc2), address(esc2).balance + ESC2_INIT_AMOUNT);

        // Point the attacker to esc2 (so its receive() reenters esc2)
        attacker.setTarget(esc2);

        // Payer releases to payee (= attacker)
        vm.prank(payer);
        esc2.release();
        assertEq(esc2.credit(address(attacker)), AMOUNT);

        // Attacker withdraws; its receive() tries to reenter withdraw()
        uint256 beforeBal = address(attacker).balance;
        vm.prank(address(attacker));
        esc2.withdraw();
        uint256 afterBal = address(attacker).balance;

        // Should only receive funds once, not multiple times
        assertEq(afterBal - beforeBal, AMOUNT);
        assertEq(esc2.credit(address(attacker)), 0);
        assertEq(address(esc2).balance, ESC2_INIT_AMOUNT);
    }

    /* ============ CONSTRUCTOR EDGE CASES ============ */

    function test_Constructor_RevertsOnZeroValue() public {
        vm.prank(payer);
        vm.expectRevert(bytes("no funds provided"));
        new Escrow(payer, payee, arbiter, block.timestamp + 1 days);
    }

    function test_Constructor_RevertsOnPastDeadline() public {
        vm.prank(payer);
        vm.expectRevert(bytes("deadline already passed"));
        new Escrow{value: 1 ether}(payer, payee, arbiter, block.timestamp - 1);
    }

    function test_Constructor_RevertsOnZeroAddr() public {
        vm.prank(payer);
        vm.expectRevert(bytes("zero address"));
        new Escrow{value: 1 ether}(address(0), payee, arbiter, block.timestamp + 1 days);
    }
}
