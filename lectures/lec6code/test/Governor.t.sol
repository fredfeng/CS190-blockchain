// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Governor.sol";

// Minimal IVotes mock for snapshot voting in tests.
contract MockVotes is IVotes {
    // blockNumber => voter => weight
    mapping(uint256 => mapping(address => uint256)) internal w;

    function setPastVotes(address who, uint256 blockNumber, uint256 weight) external {
        w[blockNumber][who] = weight;
    }

    function getPastVotes(address who, uint256 blockNumber) external view returns (uint256) {
        return w[blockNumber][who];
    }
}

contract GovernorTest is Test {
    Governor gov;
    MockVotes votes;

    address A = address(0xA11CE);
    address B = address(0xB0B);
    address payable Payee = payable(address(0xCAFE));

    function setUp() public {
        gov = new Governor(/*minDelay=*/ 2 days, /*quorum=*/ 100);
        votes = new MockVotes();

        // Whitelist the payee as a valid execution target.
        gov.setAllowedTarget(Payee, true);

        // Fund the governor contract so it can transfer ETH on execution.
        vm.deal(address(gov), 10 ether);
    }

    function test_EndToEnd_SendEth_AfterGovernance() public {
        // Proposal: send 1 ether to Payee (empty calldata = plain transfer)
        uint256 value = 1 ether;
        bytes memory data = "";

        // Create proposal with a short window for testing
        uint256 delayBlocks = 2;
        uint256 periodBlocks = 8;
        bytes32 id = gov.propose(Payee, value, data, delayBlocks, periodBlocks);

        (uint256 startBlock, uint256 endBlock) = gov.proposalWindow(id);

        // Program snapshot weights at startBlock
        votes.setPastVotes(A, startBlock, 80);
        votes.setPastVotes(B, startBlock, 40);

        // Move chain to voting start
        vm.roll(startBlock);

        // Cast votes (total for = 120 >= quorum 100)
        vm.prank(A); gov.castVote(id, IVotes(address(votes)), true);
        vm.prank(B); gov.castVote(id, IVotes(address(votes)), true);

        // Close the voting period
        vm.roll(endBlock + 1);

        // Queue -> eta = now + 2 days
        uint256 t0 = block.timestamp;
        gov.queue(id);
        uint256 eta = gov.eta(id);
        assertEq(eta, t0 + 2 days);

        // Too early should revert
        vm.expectRevert(bytes("too early"));
        gov.execute(id);

        // Execute at eta
        uint256 balBefore = Payee.balance;
        vm.warp(eta);
        gov.execute(id);
        assertEq(Payee.balance, balBefore + 1 ether);
    }

    function test_Revert_NoQuorum() public {
        // Only 60 for-votes < quorum 100
        bytes32 id = gov.propose(Payee, 0.5 ether, "", 0, 5);
        (uint256 startBlock, uint256 endBlock) = gov.proposalWindow(id);

        votes.setPastVotes(A, startBlock, 60);
        vm.roll(startBlock);
        vm.prank(A); gov.castVote(id, IVotes(address(votes)), true);
        vm.roll(endBlock + 1);

        vm.expectRevert(bytes("no quorum"));
        gov.queue(id);
    }

    function test_Revert_AgainstWins() public {
        // Against > For => cannot queue
        bytes32 id = gov.propose(Payee, 0.2 ether, "", 0, 5);
        (uint256 startBlock, uint256 endBlock) = gov.proposalWindow(id);

        votes.setPastVotes(A, startBlock, 40); // for
        votes.setPastVotes(B, startBlock, 80); // against

        vm.roll(startBlock);
        vm.prank(A); gov.castVote(id, IVotes(address(votes)), true);
        vm.prank(B); gov.castVote(id, IVotes(address(votes)), false);
        vm.roll(endBlock + 1);

        vm.expectRevert(bytes("failed"));
        gov.queue(id);
    }
}
