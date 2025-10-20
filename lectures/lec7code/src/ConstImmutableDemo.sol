// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Constant vs Immutable vs Storage - Gas Comparison Demo
/// @notice Simple demo that shows:
///         - literal (x + 10) ~ constant (x + FEE_CONST)  [both very cheap]
///         - immutable read is a bit costlier than constant/literal
///         - storage read is costlier than immutable
///         - storage write is the most expensive
contract ConstImmutableDemo {
    // compile-time constant (baked into bytecode)
    uint256 public constant FEE_CONST = 10;

    // set-once at deployment time
    uint256 public immutable FEE_IMM;

    // regular storage slot
    uint256 public feeStorage = 10;

    constructor(uint256 imm) {
        FEE_IMM = imm; // e.g., pass 10 at deploy
    }

    /// @notice Baseline using literal 10 (pure, no storage touch)
    function sumWithLiteral(uint256 n) external pure returns (uint256 acc) {
        unchecked {
            for (uint256 i = 0; i < n; i++) {
                acc += i + 10;
            }
        }
    }

    /// @notice Using compile-time constant (pure, same idea as literal)
    function sumWithConstant(uint256 n) external pure returns (uint256 acc) {
        unchecked {
            for (uint256 i = 0; i < n; i++) {
                acc += i + FEE_CONST;
            }
        }
    }

    /// @notice Using immutable (view; stored once at deploy)
    function sumWithImmutable(uint256 n) external view returns (uint256 acc) {
        unchecked {
            uint256 imm = FEE_IMM; // cache to avoid repeated SLOAD-like cost
            for (uint256 i = 0; i < n; i++) {
                acc += i + imm;
            }
        }
    }

    /// @notice Using regular storage (view; reads a storage slot)
    function sumWithStorage(uint256 n) external view returns (uint256 acc) {
        unchecked {
            uint256 fee = feeStorage; // cache to avoid repeated SLOAD
            for (uint256 i = 0; i < n; i++) {
                acc += i + fee;
            }
        }
    }
}
