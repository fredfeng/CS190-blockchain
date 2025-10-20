// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Struct Packing Gas Optimization Demo (Corrected)
/// @notice Shows a clear slot-count difference between "unpacked" and "packed" layouts.
contract StructPackingDemo {
    // Unpacked: small fields are separated by 256-bit fields -> cannot pack together.
    // Layout (by slots):
    //   slot0: a (uint256)
    //   slot1: x (uint64)   <-- only 8 bytes used; rest wasted because next field is 256-bit
    //   slot2: b (uint256)
    //   slot3: y (uint64)   <-- again cannot share with previous 256-bit
    struct UserBad {
        uint256 a;
        uint64  x;
        uint256 b;
        uint64  y;
    }

    // Packed: group 256-bit fields first; then pack small fields together.
    // Layout (by slots):
    //   slot0: a (uint256)
    //   slot1: b (uint256)
    //   slot2: x (uint64) | y (uint64)  (two small fields share one slot)
    struct UserGood {
        uint256 a;
        uint256 b;
        uint64  x;
        uint64  y;
    }

    mapping(uint256 => UserBad)  public badUsers;
    mapping(uint256 => UserGood) public goodUsers;

    // Write one element for each mapping (one struct assignment = multiple SSTOREs)
    function storeBad(uint256 i, uint256 A, uint256 B, uint64 X, uint64 Y) external {
        badUsers[i] = UserBad({a: A, x: X, b: B, y: Y});
    }

    function storeGood(uint256 i, uint256 A, uint256 B, uint64 X, uint64 Y) external {
        goodUsers[i] = UserGood({a: A, b: B, x: X, y: Y});
    }
}
