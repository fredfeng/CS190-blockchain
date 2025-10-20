// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Small Integer Packing & bool-vs-uint8 Gas Demo
/// @notice One contract to demo:
///         (A) Use smallest integer types (struct packing)
///         (B) Replace bool with uint8 (lower-level ops without extra masking)
contract SmallIntAndBoolDemo {
    /* =========================================================
       (A) Smallest integer types / struct packing
       ---------------------------------------------------------
       BigNums uses 3 storage slots per element (3x SSTORE).
       SmallPacked fits into 1 slot per element (1x SSTORE).
    ========================================================== */
    struct BigNums {
        uint256 a; // slot i
        uint256 b; // slot i+1
        uint256 c; // slot i+2
    }

    struct SmallPacked {
        // 128 + 64 + 64 = 256 bits -> tightly fits into ONE 32-byte slot
        uint128 a;
        uint64  b;
        uint64  c;
    }

    mapping(uint256 => BigNums)     public bigMap;
    mapping(uint256 => SmallPacked) public smallMap;

    /// @dev Write N elements into bigMap (3 SSTOREs per element).
    function writeBig(uint256 n) external {
        for (uint256 i = 0; i < n; i++) {
            bigMap[i] = BigNums({a: uint256(1), b: uint256(2), c: uint256(3)});
        }
    }

    /// @dev Write N elements into smallMap (1 SSTORE per element).
    function writeSmallPacked(uint256 n) external {
        for (uint256 i = 0; i < n; i++) {
            smallMap[i] = SmallPacked({a: uint128(1), b: uint64(2), c: uint64(3)});
        }
    }

    /* =========================================================
       (B) bool vs uint8 in a packed struct
       ---------------------------------------------------------
       Both structs below are arranged to fit in ONE slot.
       - FlagsBool uses 2 bools: compiler adds masking/validation.
       - FlagsU8  uses 2 uint8: fewer ops when toggling.
    ========================================================== */
    struct FlagsBool {
        uint128 a; // 16 bytes
        bool    f1; // 1 byte
        bool    f2; // 1 byte
        uint64  b;  // 8 bytes
        // total <= 26 bytes -> packed into 1 slot
    }

    struct FlagsU8 {
        uint128 a;  // 16 bytes
        uint8   f1; // 1 byte
        uint8   f2; // 1 byte
        uint64  b;  // 8 bytes
        // total <= 26 bytes -> packed into 1 slot
    }

    mapping(uint256 => FlagsBool) public boolMap;
    mapping(uint256 => FlagsU8)   public u8Map;

    /// @dev Seed N elements for the bool-based struct.
    function seedBool(uint256 n) external {
        for (uint256 i = 0; i < n; i++) {
            boolMap[i] = FlagsBool({a: 1, f1: true, f2: false, b: 7});
        }
    }

    /// @dev Seed N elements for the uint8-based struct.
    function seedU8(uint256 n) external {
        for (uint256 i = 0; i < n; i++) {
            u8Map[i] = FlagsU8({a: 1, f1: 1, f2: 0, b: 7});
        }
    }

    /// @dev Toggle the two bool flags for the first N entries.
    ///      bool loads/stores often include extra masking/validation ops.
    function flipBool(uint256 n) external {
        for (uint256 i = 0; i < n; i++) {
            FlagsBool memory tmp = boolMap[i]; // read packed slot once
            tmp.f1 = !tmp.f1;
            tmp.f2 = !tmp.f2;
            boolMap[i] = tmp; // write packed slot once
        }
    }

    /// @dev Toggle the two uint8 flags (xor 1) for the first N entries.
    ///      Avoids bool-specific masking overhead.
    function flipU8(uint256 n) external {
        for (uint256 i = 0; i < n; i++) {
            FlagsU8 memory tmp = u8Map[i]; // read packed slot once
            tmp.f1 ^= 1;
            tmp.f2 ^= 1;
            u8Map[i] = tmp; // write packed slot once
        }
    }
}
