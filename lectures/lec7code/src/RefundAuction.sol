// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title RefundAuction - Demo for Gas Refund via Storage Deletion
contract RefundAuction {
    address public admin;
    address[] public participants;
    mapping(address => uint256) public bids;
    bool public ended;

    constructor() {
        admin = msg.sender;
    }

    function bid() external payable {
        require(!ended, "ended");
        if (bids[msg.sender] == 0) {
            participants.push(msg.sender);
        }
        bids[msg.sender] = msg.value;
    }

    /// @notice End auction without cleanup (no refund)
    function endWithoutCleanup() external {
        require(msg.sender == admin);
        require(!ended);
        ended = true;
        // do nothing: leaves bids nonzero
    }

    /// @notice End auction with cleanup (refund happens)
    function endWithCleanup() external {
        require(msg.sender == admin);
        require(!ended);
        ended = true;
        for (uint256 i = 0; i < participants.length; i++) {
            delete bids[participants[i]]; // nonzero -> zero => refund
        }
    }
}
