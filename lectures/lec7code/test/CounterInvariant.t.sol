// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "forge-std/StdInvariant.sol";
import {Counter} from "../src/Counter.sol";

/// @notice Invariant: 0 <= count <= CAP, always
/// Foundry's invariant runner will make random sequences of external calls
/// to the target contract and ensure the property holds.
contract CounterInvariant is StdInvariant, Test {
    Counter internal c;

    function setUp() public {
        c = new Counter(1000);
        // Tell the invariant engine to fuzz-call this contract's public/external functions
        targetContract(address(c));
    }

    function invariant_CountWithinBounds() public {
        uint256 v = c.count();
        // >= 0 is always true for uint256; we assert the upper bound explicitly
        assertTrue(v <= c.CAP(), "count must never exceed CAP");
    }
}
