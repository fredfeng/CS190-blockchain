// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Capped Counter
/// @notice A simple counter with a maximum cap to illustrate unit, fuzz, and invariant tests.
contract Counter {
    uint256 public count;
    uint256 public immutable CAP;

    error Underflow();
    error CapExceeded();

    constructor(uint256 _cap) {
        require(_cap > 0, "cap must be > 0");
        CAP = _cap;
    }

    /// @notice increase by 1, revert if exceeds CAP
    function inc() external {
        uint256 newVal = count + 1;
        if (newVal > CAP) revert CapExceeded();
        count = newVal;
    }

    /// @notice decrease by 1, revert if already 0
    function dec() external {
        if (count == 0) revert Underflow();
        unchecked {
            count = count - 1;
        }
    }

    /// @notice add x, revert if exceeds CAP
    function add(uint256 x) external {
        uint256 newVal = count + x;
        if (newVal > CAP) revert CapExceeded();
        count = newVal;
    }
}
