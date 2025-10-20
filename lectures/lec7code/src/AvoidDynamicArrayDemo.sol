// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Avoid Dynamic Storage Arrays - Operation-by-Operation Gas Demo
/// @notice Compares gas for dynamic storage array vs mapping+counter across:
///         (1) expansion (push), (2) modify, (3) read, (4) clear.
contract AvoidDynamicArrayDemo {
    // Dynamic storage array
    uint256[] public arr;

    // Mapping + counter (no array length writes; O(1) "clear")
    mapping(uint256 => uint256) public map;
    uint256 public mCount;

    /* ---------- 1) EXPANSION ---------- */

    function addArray(uint256 v) external {
        // Writes: arr.length (SSTORE) + arr[newIndex] (SSTORE)
        arr.push(v);
    }

    function addMap(uint256 v) external {
        // Writes: map[mCount] only (1x SSTORE); mCount++ is another SSTORE,
        // but counter is comparable to arr.length write. Net effect: often cheaper than array push.
        map[mCount] = v;
        unchecked { mCount++; }
    }

    /* ---------- 2) MODIFY (update first N items) ---------- */

    function bumpArray(uint256 n) external {
        uint256 len = arr.length;
        if (n > len) n = len;
        for (uint256 i = 0; i < n; i++) {
            arr[i] = arr[i] + 1; // SSTORE nonzero->nonzero
        }
    }

    function bumpMap(uint256 n) external {
        if (n > mCount) n = mCount;
        for (uint256 i = 0; i < n; i++) {
            map[i] = map[i] + 1; // SSTORE nonzero->nonzero
        }
    }

    /* ---------- 3) READ (sum first N items) ---------- */

    function sumArray(uint256 n) external view returns (uint256 s) {
        uint256 len = arr.length;
        if (n > len) n = len;
        for (uint256 i = 0; i < n; i++) {
            s += arr[i]; // SLOAD per element
        }
    }

    function sumMap(uint256 n) external view returns (uint256 s) {
        if (n > mCount) n = mCount;
        for (uint256 i = 0; i < n; i++) {
            s += map[i]; // SLOAD per element
        }
    }

    /* ---------- 4) CLEAR / RESET ---------- */

    /// @notice True clear: zero-out each slot (O(N) SSTORE), then length=0.
    function clearArrayByDeletingElements() external {
        uint256 len = arr.length;
        for (uint256 i = 0; i < len; i++) {
            delete arr[i]; // nonzero -> 0 (refund-capped)
        }
        delete arr; // length = 0
    }

    /// @notice Fast truncate: only set length=0 (does NOT zero element slots).
    function clearArrayLengthOnly() external {
        delete arr; // cheap but leaves old element slots nonzero in storage
    }

    /// @notice O(1) reset for mapping-based structure.
    function clearMapByResetCount() external {
        mCount = 0; // single SSTORE; old slots remain but are ignored
    }
}
