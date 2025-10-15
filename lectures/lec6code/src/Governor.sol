// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Governor: snapshot voting + quorum/majority + timelocked, allowlisted execution.
/// @dev A proposal fixes (target, value, callData, window) and later executes exactly that payload.
///      To keep focus on voting mechanics, execution can be a plain ETH transfer (empty callData).
interface IVotes {
    function getPastVotes(address who, uint256 blockNumber) external view returns (uint256);
}

contract Governor {
    // --- admin / ownership ---
    address public owner;
    modifier onlyOwner() { require(msg.sender == owner, "not owner"); _; }

    // --- execution policy ---
    mapping(address => bool) public allowedTarget; // whitelist of allowed call targets
    uint256 public minDelay; // seconds: timelock delay after a successful vote
    uint256 public quorum;   // minimal required "for" votes

    // --- proposal storage ---
    struct Proposal {
        address proposer;
        address target;
        uint256 value;     // ETH to send on execution
        bytes callData;    // empty for pure ETH transfer
        uint256 startBlock;
        uint256 endBlock;
        uint256 forVotes;
        uint256 againstVotes;
        mapping(address => bool) voted;
        bool queued;
        bool executed;
    }
    mapping(bytes32 => Proposal) private _props;
    mapping(bytes32 => uint256) public eta; // earliest execution timestamp per proposal

    // --- events ---
    event ProposalCreated(bytes32 id, address proposer, address target, uint256 value, bytes callData, uint256 startBlock, uint256 endBlock);
    event VoteCast(bytes32 id, address voter, bool support, uint256 weight);
    event Queued(bytes32 id, uint256 eta);
    event Executed(bytes32 id);
    event AllowedTargetSet(address target, bool allowed);
    event QuorumSet(uint256 quorum);
    event MinDelaySet(uint256 minDelay);

    constructor(uint256 _minDelay, uint256 _quorum) {
        owner = msg.sender;
        minDelay = _minDelay;
        quorum = _quorum;
    }

    /// @notice Allow the contract to hold ETH for proposal execution.
    receive() external payable {}

    // ---------- admin setters ----------
    function setAllowedTarget(address target, bool allowed) external onlyOwner {
        allowedTarget[target] = allowed;
        emit AllowedTargetSet(target, allowed);
    }

    function setQuorum(uint256 newQuorum) external onlyOwner {
        quorum = newQuorum;
        emit QuorumSet(newQuorum);
    }

    function setMinDelay(uint256 newDelay) external onlyOwner {
        minDelay = newDelay;
        emit MinDelaySet(newDelay);
    }

    // ---------- proposal lifecycle ----------
    function _id(address target, uint256 value, bytes memory callData, uint256 startBlock, uint256 endBlock)
        internal pure returns (bytes32)
    {
        return keccak256(abi.encode(target, value, callData, startBlock, endBlock));
    }

    /// @notice Create a proposal; voting window is defined in blocks to enable snapshot voting.
    /// @param target Execution target (must be allowlisted).
    /// @param value  ETH value to send at execution.
    /// @param callData Calldata to use; empty for pure ETH transfer.
    /// @param votingDelayBlocks Blocks to wait before voting starts (snapshot at startBlock).
    /// @param votingPeriodBlocks Voting duration in blocks.
    function propose(
        address target,
        uint256 value,
        bytes calldata callData,
        uint256 votingDelayBlocks,
        uint256 votingPeriodBlocks
    ) external returns (bytes32 id) {
        require(allowedTarget[target], "target not allowed");

        uint256 startBlock = block.number + votingDelayBlocks;
        uint256 endBlock = startBlock + votingPeriodBlocks;
        id = _id(target, value, callData, startBlock, endBlock);

        Proposal storage p = _props[id];
        // Uninitialized proposals have all-zero fields; startBlock==0 is our sentinel.
        require(p.startBlock == 0, "exists");

        p.proposer   = msg.sender;
        p.target     = target;
        p.value      = value;
        p.callData   = callData;
        p.startBlock = startBlock;
        p.endBlock   = endBlock;

        emit ProposalCreated(id, msg.sender, target, value, callData, startBlock, endBlock);
    }

    /// @notice Snapshot-based voting: weight is read at startBlock using IVotes.getPastVotes.
    function castVote(bytes32 id, IVotes token, bool support) external {
        Proposal storage p = _require(id);
        require(block.number >= p.startBlock && block.number <= p.endBlock, "not active");
        require(!p.voted[msg.sender], "voted");
        p.voted[msg.sender] = true;

        uint256 w = token.getPastVotes(msg.sender, p.startBlock);
        if (support) p.forVotes += w; else p.againstVotes += w;

        emit VoteCast(id, msg.sender, support, w);
    }

    /// @notice Queue a successful proposal: must win majority and meet quorum; sets eta = now + minDelay.
    function queue(bytes32 id) external {
        Proposal storage p = _require(id);
        require(block.number > p.endBlock, "still voting");
        require(!p.queued, "queued");
        require(p.forVotes > p.againstVotes, "failed");
        require(p.forVotes >= quorum, "no quorum");

        p.queued = true;
        eta[id] = block.timestamp + minDelay;
        emit Queued(id, eta[id]);
    }

    /// @notice Execute after the timelock: calls exactly the recorded payload to an allowlisted target.
    function execute(bytes32 id) external {
        Proposal storage p = _require(id);
        require(p.queued, "not queued");
        require(!p.executed, "executed");
        require(block.timestamp >= eta[id], "too early");
        require(allowedTarget[p.target], "target not allowed");

        p.executed = true;
        (bool ok, ) = p.target.call{value: p.value}(p.callData);
        require(ok, "exec failed");
        emit Executed(id);
    }

    // ---------- lightweight views for clients/tests ----------
    function proposalWindow(bytes32 id) external view returns (uint256 startBlock, uint256 endBlock) {
        Proposal storage p = _require(id);
        return (p.startBlock, p.endBlock);
    }

    function tallies(bytes32 id) external view returns (uint256 forVotes, uint256 againstVotes) {
        Proposal storage p = _require(id);
        return (p.forVotes, p.againstVotes);
    }

    // ---------- internal ----------
    function _require(bytes32 id) internal view returns (Proposal storage p) {
        p = _props[id];
        require(p.startBlock != 0, "unknown");
    }
}
