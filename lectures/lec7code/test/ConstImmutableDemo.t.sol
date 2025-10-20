// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ConstImmutableDemo.sol";

contract ConstImmutableDemoTest is Test {
    ConstImmutableDemo demo;

    function setUp() public {
        // Pass 10 for the immutable fee at deploy
        demo = new ConstImmutableDemo(10);
    }

    function testGas_sumWithLiteral() public {
        uint256 gasStart = gasleft();
        demo.sumWithLiteral(200); // loop count: tweak to magnify deltas
        uint256 used = gasStart - gasleft();
        emit log_named_uint("Gas (sumWithLiteral)", used);
    }

    function testGas_sumWithConstant() public {
        uint256 gasStart = gasleft();
        demo.sumWithConstant(200);
        uint256 used = gasStart - gasleft();
        emit log_named_uint("Gas (sumWithConstant)", used);
    }

    function testGas_sumWithImmutable() public {
        uint256 gasStart = gasleft();
        demo.sumWithImmutable(200);
        uint256 used = gasStart - gasleft();
        emit log_named_uint("Gas (sumWithImmutable)", used);
    }

    function testGas_sumWithStorage() public {
        uint256 gasStart = gasleft();
        demo.sumWithStorage(200);
        uint256 used = gasStart - gasleft();
        emit log_named_uint("Gas (sumWithStorage)", used);
    }
}
