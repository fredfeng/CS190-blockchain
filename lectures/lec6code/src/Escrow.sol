// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Minimal, deployable Escrow using pull-over-push payouts
/// @notice Demonstrates the Escrow design pattern with single outcome and safe withdrawal
contract Escrow {
    enum State { Funded, Resolved }

    // Immutable parties and parameters
    address public immutable payer;
    address public immutable payee;
    address public immutable arbiter;
    uint256 public immutable amount;
    uint256 public immutable deadline;
    State public s;

    // Internal accounting ledger
    mapping(address => uint256) public credit;

    // Custom errors for clarity and gas efficiency
    error NotPayer();
    error NotArbiter();
    error BadState();
    error NothingToWithdraw();

    // Events for off-chain tracking
    event Released(address indexed to, uint256 amount);
    event Refunded(address indexed to, uint256 amount);
    event Resolved(address indexed winner, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);

    bool internal locked;
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    /// @notice Initializes the escrow with payer, payee, arbiter and a funding amount
    /// @dev The constructor receives the funds and sets the initial state to Funded
    constructor(address _payer, address _payee, address _arbiter, uint256 _deadline) payable {
        require(_payer != address(0) && _payee != address(0) && _arbiter != address(0), "zero address");
        require(msg.value > 0, "no funds provided");
        require(_deadline > block.timestamp, "deadline already passed");
        payer = _payer;
        payee = _payee;
        arbiter = _arbiter;
        amount = msg.value;
        deadline = _deadline;
        s = State.Funded;
    }

    modifier onlyPayer() {
        if (msg.sender != payer) revert NotPayer();
        _;
    }
    modifier onlyArbiter() {
        if (msg.sender != arbiter) revert NotArbiter();
        _;
    }

    /// @notice Called by the payer before the deadline to release funds to the payee
    /// @dev Applies the "effects first" rule to avoid reentrancy
    function release() external onlyPayer {
        if (!(s == State.Funded && block.timestamp < deadline)) revert BadState();
        s = State.Resolved;                     // Effects first
        credit[payee] += amount;                // Single outcome: credit payee
        emit Released(payee, amount);
    }

    /// @notice Called by the payer after the deadline to refund themselves
    function refund() external onlyPayer {
        if (!(s == State.Funded && block.timestamp >= deadline)) revert BadState();
        s = State.Resolved;
        credit[payer] += amount;
        emit Refunded(payer, amount);
    }

    /// @notice Called by the arbiter to resolve a dispute in favor of either side
    /// @param toPayee If true, payee receives funds; otherwise payer is refunded
    function resolve(bool toPayee) external onlyArbiter {
        if (s != State.Funded) revert BadState();
        s = State.Resolved;
        address winner = toPayee ? payee : payer;
        credit[winner] += amount;
        emit Resolved(winner, amount);
    }

    /// @notice Unified withdrawal entry point (Pull over Push pattern)
    /// @dev Follows Checks–Effects–Interactions order for safety
    // function withdraw() external noReentrant {
    function withdraw() external {
        uint256 due = credit[msg.sender];
        if (due == 0) revert NothingToWithdraw();
        credit[msg.sender] = 0;                // Effects before interaction
        (bool ok, ) = msg.sender.call{value: due}("");
        // credit[msg.sender] = 0;                // Move the effects here to trigger reentrancy
        require(ok, "transfer failed");
        emit Withdrawn(msg.sender, due);
    }
}
