// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/Auction.sol";

contract AuctionTest is Test {
    Auction auction;
    address seller = address(0xA11CE);
    address alice  = address(0xBEEF);
    address bob    = address(0xCAFE);

    function setUp() public {
        vm.startPrank(seller);
        auction = new Auction(1 hours, 1 hours); // commit 1h, reveal 1h
        vm.stopPrank();

        // provide initial balances
        vm.deal(seller, 0);
        vm.deal(alice,  10 ether);
        vm.deal(bob,    10 ether);
    }

    function testFlowCommitRevealFinalizeWithdraw() public {
        // === Commit phase ===
        bytes32 saltA = bytes32(uint256(123));
        uint256 bidA  = 1 ether;
        bytes32 cA = keccak256(abi.encode(bidA, saltA));

        bytes32 saltB = bytes32(uint256(456));
        uint256 bidB  = 1.5 ether;
        bytes32 cB = keccak256(abi.encode(bidB, saltB));

        // Alice commits with 2 ETH deposit
        vm.prank(alice);
        auction.commit{value: 2 ether}(cA);
        assertEq(auction.deposits(alice), 2 ether);

        // Bob commits with 2 ETH deposit
        vm.prank(bob);
        auction.commit{value: 2 ether}(cB);
        assertEq(auction.deposits(bob), 2 ether);

        // === Move to Reveal phase ===
        vm.warp(block.timestamp + 1 hours + 1);
        auction.advance();

        // Alice reveals 1 ETH
        vm.prank(alice);
        auction.reveal(bidA, saltA);
        assertEq(auction.highestBid(), 1 ether);
        assertEq(auction.highestBidder(), alice);

        // Bob reveals 1.5 ETH (higher)
        vm.prank(bob);
        auction.reveal(bidB, saltB);
        assertEq(auction.highestBid(), 1.5 ether);
        assertEq(auction.highestBidder(), bob);

        // === Move to Finalized ===
        vm.warp(block.timestamp + 1 hours + 1);
        auction.advance();

        uint256 aliceBefore  = alice.balance;
        uint256 bobBefore    = bob.balance;
        uint256 sellerBefore = seller.balance;

        // Seller withdraws 1.5 ETH
        vm.prank(seller);
        auction.withdraw();
        assertEq(seller.balance, sellerBefore + 1.5 ether);

        // Bob (winner) withdraws remaining 0.5 ETH
        vm.prank(bob);
        auction.withdraw();
        assertEq(bob.balance, bobBefore + 0.5 ether);

        // Alice (loser) withdraws full 2 ETH
        vm.prank(alice);
        auction.withdraw();
        assertEq(alice.balance, aliceBefore + 2 ether);

        assertEq(address(auction).balance, 0);
    }

    function testRevealWithBadHashReverts() public {
        bytes32 saltA = bytes32(uint256(123));
        uint256 bidA  = 1 ether;
        bytes32 cA    = keccak256(abi.encode(bidA, saltA));

        vm.prank(alice);
        auction.commit{value: 1 ether}(cA);

        // jump to reveal phase
        vm.warp(block.timestamp + 1 hours + 1);
        auction.advance();

        // reveal with wrong salt should revert
        vm.prank(alice);
        vm.expectRevert(Auction.BadReveal.selector);
        auction.reveal(bidA, bytes32(uint256(999)));
    }
}
