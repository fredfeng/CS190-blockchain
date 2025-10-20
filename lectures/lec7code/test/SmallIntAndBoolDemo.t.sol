// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SmallIntAndBoolDemo.sol";

contract SmallIntAndBoolDemoTest is Test {
    SmallIntAndBoolDemo demo;

    // increase N to magnify deltas on your machine
    uint256 constant N = 100;

    function setUp() public {
        demo = new SmallIntAndBoolDemo();
    }

    /* ------------------- (A) Smallest integer types ------------------- */

    function testGas_WriteBig() public {
        uint256 g0 = gasleft();
        demo.writeBig(N);
        uint256 used = g0 - gasleft();
        emit log_named_uint("Gas - writeBig (uint256,uint256,uint256) xN", used);
    }

    function testGas_WriteSmallPacked() public {
        uint256 g0 = gasleft();
        demo.writeSmallPacked(N);
        uint256 used = g0 - gasleft();
        emit log_named_uint("Gas - writeSmallPacked (uint128,uint64,uint64) xN", used);
    }

    /* ------------------- (B) bool vs uint8 (packed) ------------------- */

    function testGas_FlipBool() public {
        demo.seedBool(N);
        uint256 g0 = gasleft();
        demo.flipBool(N);
        uint256 used = g0 - gasleft();
        emit log_named_uint("Gas - flipBool (toggle 2 bool flags) xN", used);
    }

    function testGas_FlipU8() public {
        demo.seedU8(N);
        uint256 g0 = gasleft();
        demo.flipU8(N);
        uint256 used = g0 - gasleft();
        emit log_named_uint("Gas - flipU8 (toggle 2 uint8 flags) xN", used);
    }
}
