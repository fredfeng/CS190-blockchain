// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableBank {
    mapping(address => uint256) public balanceOf;

    /// @notice Deposit ETH into sender's balance.
    function deposit() external payable {
        require(msg.value > 0, "no ether");
        balanceOf[msg.sender] += msg.value;
    }

    /// @notice Withdraw entire sender balance — vulnerable ordering.
    function withdraw() external {
        uint256 bal = balanceOf[msg.sender];
        require(bal > 0, "no balance");

        // Vulnerable: external call before state update
        (bool ok, ) = msg.sender.call{value: bal}("");
        require(ok, "send failed");

        // State update happens after the external call — allow reentrancy
        balanceOf[msg.sender] = 0;
    }
}


contract SafeBank {
    mapping(address => uint256) public balanceOf;

    /// @notice Deposit ETH into sender's balance.
    function deposit() external payable {
        require(msg.value > 0, "no ether");
        balanceOf[msg.sender] += msg.value;
    }

    /// @notice Withdraw entire sender balance — safe ordering.
    function withdraw() external {
        uint256 bal = balanceOf[msg.sender];
        require(bal > 0, "no balance");

        // Effect: update state first
        balanceOf[msg.sender] = 0;

        // Interaction: external call after state change
        (bool ok, ) = msg.sender.call{value: bal}("");
        require(ok, "send failed");
    }
}
