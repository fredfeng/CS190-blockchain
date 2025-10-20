// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

/// @notice Unit tests and fuzz tests for Counter
contract CounterTest is Test {
    Counter internal c;

    function setUp() public {
        // Keep the cap small enough for quick tests but large enough for fuzzing
        c = new Counter(1000);
    }

    /* ============ Unit tests ============ */

    function testIncrement() public {
        c.inc();
        assertEq(c.count(), 1, "count should be 1 after inc()");
    }

    function testDecrementRevertsAtZero() public {
        vm.expectRevert(Counter.Underflow.selector);
        c.dec();
    }

    function testAddExactToCap() public {
        c.add(c.CAP());
        assertEq(c.count(), c.CAP(), "count should reach CAP");
    }

    function testAddRevertsOverCap() public {
        uint256 cap = c.CAP();
        vm.expectRevert(Counter.CapExceeded.selector);
        c.add(cap + 1);
    }

    /* ============ Fuzz tests ============ */

    /// @notice For any x in [0, CAP], adding x from 0 should equal x
    function testFuzz_AddWithinCap(uint256 x) public {
        // bound(value, min, max) is a forge-std helper for fuzz ranges
        x = bound(x, 0, c.CAP());
        c.add(x);
        assertEq(c.count(), x, "count should equal x when starting from 0");
    }

    /// @notice Fuzz inc() until reaching cap: further inc must revert
    function testFuzz_IncRevertsPastCap(uint256 steps) public {
        steps = bound(steps, 0, c.CAP() + 2); // small upper wiggle room
        // bring close to cap
        if (steps < c.CAP()) c.add(steps);
        uint256 remaining = c.CAP() - c.count();

        // consume remaining steps safely
        for (uint256 i = 0; i < remaining; i++) {
            c.inc();
        }
        assertEq(c.count(), c.CAP(), "should be at CAP");

        // one more inc must revert
        vm.expectRevert(Counter.CapExceeded.selector);
        c.inc();
    }
}
