// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/RefundAuction.sol";

/// @notice Foundry test to compare gas used before vs after refund.
contract RefundAuctionTest is Test {
    RefundAuction auction;
    address alice = address(0xA11CE);
    address bob   = address(0xB0B);
    address admin = address(this);

    function setUp() public {
        auction = new RefundAuction();
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);

        vm.prank(alice);
        auction.bid{value: 1 ether}();

        vm.prank(bob);
        auction.bid{value: 2 ether}();
    }

    function testEndWithoutCleanupGas() public {
        uint256 gasStart = gasleft();
        auction.endWithoutCleanup();
        uint256 gasUsed = gasStart - gasleft();
        emit log_named_uint("Gas used (no cleanup)", gasUsed);
    }

    function testEndWithCleanupGas() public {
        // Re-deploy new instance so state is same before cleanup test
        RefundAuction a2 = new RefundAuction();
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
        vm.prank(alice);
        a2.bid{value: 1 ether}();
        vm.prank(bob);
        a2.bid{value: 2 ether}();

        uint256 gasStart = gasleft();
        a2.endWithCleanup();
        uint256 gasUsed = gasStart - gasleft();
        emit log_named_uint("Gas used (with cleanup)", gasUsed);
    }
}
