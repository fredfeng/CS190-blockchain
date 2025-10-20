// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/StructPackingDemo.sol";

contract StructPackingDemoTest is Test {
    StructPackingDemo demo;

    function setUp() public {
        demo = new StructPackingDemo();
    }

    function testGas_UnpackedStruct() public {
        uint256 gasStart = gasleft();
        demo.storeBad(1, 111, 222, 3, 4);
        uint256 gasUsed = gasStart - gasleft();
        emit log_named_uint("Gas used (UNPACKED)", gasUsed);
    }

    function testGas_PackedStruct() public {
        uint256 gasStart = gasleft();
        demo.storeGood(1, 111, 222, 3, 4);
        uint256 gasUsed = gasStart - gasleft();
        emit log_named_uint("Gas used (PACKED)", gasUsed);
    }
}
