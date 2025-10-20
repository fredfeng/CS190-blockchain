// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/AvoidDynamicArrayDemo.sol";

contract AvoidDynamicArrayDemoTest is Test {
    AvoidDynamicArrayDemo demo;

    // configurable size to magnify differences
    uint256 constant N = 100;

    function setUp() public {
        demo = new AvoidDynamicArrayDemo();
    }

    /* ---------- 1) EXPANSION (push N items) ---------- */

    function testGas_Expansion_Array() public {
        uint256 gasStart = gasleft();
        for (uint256 i = 0; i < N; i++) {
            demo.addArray(i + 1);
        }
        uint256 used = gasStart - gasleft();
        emit log_named_uint("Gas - Expansion: dynamic array push N", used);
    }

    function testGas_Expansion_Mapping() public {
        uint256 gasStart = gasleft();
        for (uint256 i = 0; i < N; i++) {
            demo.addMap(i + 1);
        }
        uint256 used = gasStart - gasleft();
        emit log_named_uint("Gas - Expansion: mapping+counter add N", used);
    }

    /* ---------- 2) MODIFY (update first N items) ---------- */

    function testGas_Modify_Array() public {
        // prepare data
        for (uint256 i = 0; i < N; i++) demo.addArray(i + 1);

        uint256 gasStart = gasleft();
        demo.bumpArray(N);
        uint256 used = gasStart - gasleft();
        emit log_named_uint("Gas - Modify: dynamic array bump N", used);
    }

    function testGas_Modify_Mapping() public {
        // prepare data
        for (uint256 i = 0; i < N; i++) demo.addMap(i + 1);

        uint256 gasStart = gasleft();
        demo.bumpMap(N);
        uint256 used = gasStart - gasleft();
        emit log_named_uint("Gas - Modify: mapping bump N", used);
    }

    /* ---------- 3) READ (sum first N items) ---------- */

    function testGas_Read_Array() public {
        for (uint256 i = 0; i < N; i++) demo.addArray(i + 1);

        uint256 gasStart = gasleft();
        demo.sumArray(N);
        uint256 used = gasStart - gasleft();
        emit log_named_uint("Gas - Read: dynamic array sum N", used);
    }

    function testGas_Read_Mapping() public {
        for (uint256 i = 0; i < N; i++) demo.addMap(i + 1);

        uint256 gasStart = gasleft();
        demo.sumMap(N);
        uint256 used = gasStart - gasleft();
        emit log_named_uint("Gas - Read: mapping sum N", used);
    }

    /* ---------- 4) CLEAR ---------- */

    function testGas_Clear_Array_DeleteElements() public {
        for (uint256 i = 0; i < N; i++) demo.addArray(i + 1);

        uint256 gasStart = gasleft();
        demo.clearArrayByDeletingElements();
        uint256 used = gasStart - gasleft();
        emit log_named_uint("Gas - Clear: array delete elements (O(N))", used);
    }

    function testGas_Clear_Array_LengthOnly() public {
        for (uint256 i = 0; i < N; i++) demo.addArray(i + 1);

        uint256 gasStart = gasleft();
        demo.clearArrayLengthOnly();
        uint256 used = gasStart - gasleft();
        emit log_named_uint("Gas - Clear: array length=0 only (O(1), leaves slots)", used);
    }

    function testGas_Clear_Mapping_ResetCount() public {
        for (uint256 i = 0; i < N; i++) demo.addMap(i + 1);

        uint256 gasStart = gasleft();
        demo.clearMapByResetCount();
        uint256 used = gasStart - gasleft();
        emit log_named_uint("Gas - Clear: mapping mCount=0 (O(1))", used);
    }
}
