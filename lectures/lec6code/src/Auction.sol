// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Minimal Commit-Reveal Auction (State Machine + Withdraw Pattern)
/// @notice Educational minimal version: three phases, time-based transitions, single withdrawal point
contract Auction {
    enum Phase { Commit, Reveal, Finalized }

    address public immutable seller;
    Phase   public phase;

    uint64 public immutable commitDeadline;
    uint64 public immutable revealDeadline;

    // commit = keccak256(abi.encode(bid, salt))
    mapping(address => bytes32) public commitments;
    mapping(address => uint256) public deposits;

    address public highestBidder;
    uint256 public highestBid;

    bool public sellerClaimed;

    error WrongPhase(Phase expected, Phase actual);
    error AlreadyCommitted();
    error NoCommitment();
    error BadReveal();
    error TooLate();
    error NothingToWithdraw();
    error SellerOnly();

    modifier inPhase(Phase expected) {
        _advance(); // automatically advance based on time
        if (phase != expected) revert WrongPhase(expected, phase);
        _;
    }

    constructor(uint64 commitDuration, uint64 revealDuration) {
        seller = msg.sender;
        commitDeadline = uint64(block.timestamp) + commitDuration;
        revealDeadline = commitDeadline + revealDuration;
        phase = Phase.Commit;
    }

    /// @notice Anyone can call this to advance the phase according to current time
    function advance() external {
        _advance();
    }

    function _advance() internal {
        if (phase == Phase.Commit && block.timestamp >= commitDeadline) {
            phase = Phase.Reveal;
        }
        if (phase == Phase.Reveal && block.timestamp >= revealDeadline) {
            phase = Phase.Finalized;
        }
    }

    /// @notice Commit a bid hash and lock some deposit
    function commit(bytes32 commitment) external payable inPhase(Phase.Commit) {
        if (commitments[msg.sender] != 0) revert AlreadyCommitted();
        if (msg.value == 0) revert TooLate(); // reuse error name for minimal code

        commitments[msg.sender] = commitment;
        deposits[msg.sender] += msg.value;
    }

    /// @notice Reveal the real bid and salt; deposit must cover the bid
    function reveal(uint256 bid, bytes32 salt) external inPhase(Phase.Reveal) {
        bytes32 c = commitments[msg.sender];
        if (c == 0) revert NoCommitment();
        if (keccak256(abi.encode(bid, salt)) != c) revert BadReveal();
        if (deposits[msg.sender] < bid) revert BadReveal(); // deposit not enough

        // record highest bid
        if (bid > highestBid) {
            highestBid = bid;
            highestBidder = msg.sender;
        }

        // prevent reusing the same commitment
        commitments[msg.sender] = 0;
    }

    /// @notice Unified withdraw entry:
    ///  - Seller withdraws the winning bid
    ///  - Winner withdraws remaining deposit (deposit - highestBid)
    ///  - Losers withdraw full deposit
    function withdraw() external {
        _advance();
        if (phase != Phase.Finalized) revert WrongPhase(Phase.Finalized, phase);

        if (msg.sender == seller) {
            if (sellerClaimed || highestBid == 0) revert NothingToWithdraw();
            sellerClaimed = true;
            (bool ok, ) = seller.call{value: highestBid}("");
            require(ok, "seller transfer failed");
            return;
        }

        uint256 amount = deposits[msg.sender];
        if (amount == 0) revert NothingToWithdraw();

        if (msg.sender == highestBidder) {
            amount -= highestBid;
            highestBid = 0; // ensure winner pays only once
        }

        deposits[msg.sender] = 0;
        (bool ok2, ) = msg.sender.call{value: amount}("");
        require(ok2, "bidder transfer failed");
    }

    /// @notice Utility: compute commitment hash for (bid, salt)
    function commitmentOf(uint256 bid, bytes32 salt) external pure returns (bytes32) {
        return keccak256(abi.encode(bid, salt));
    }
}
