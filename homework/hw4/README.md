
# Homework Assignment 4: MEV Sandwich Attack Simulator

- Out: 11:59am on Monday, Nov 19, 2025 (Pacific Time)
- Due: 11:59pm on Monday, Dec 1, 2025 (Pacific Time)
  - Late Submission Due: 11:59pm on Monday, Dec 8, 2025 (Pacific Time)
- Submit via Gradescope (Course Entry Code: VW3K2R)
- Starter Code: [hw4-starter.zip](./hw4-starter.zip)
- Contact *Hanzhi Liu* on Slack if you have any questions

## Overview and Getting Started

You will build a minimal **MEV sandwich bot** that interacts with a constant-product AMM on a local Foundry chain. Your code will approve tokens, call the AMM, and reason about a three-transaction sequence:

1. Attacker front-runs (X->Y).
2. Victim trades (X->Y).
3. Attacker back-runs (Y->X).

Actors and balances (what tests do for you):
- Deploy: attacker EOA deploys `SandwichBot` and is `owner`.
- Pool: tests mint `TokenX`/`TokenY`, seed the AMM with 1000/1000.
- Bot funds: tests transfer `TokenX` to the bot contract. There is no deposit logic; the bot just spends what it already holds.
- Victim: a separate EOA that trades `TokenX` into the AMM.
- Calls: only `owner` can call `frontRun` and `backRun`. `computeFrontRunAmount` takes the victim’s slippage (bps) as an argument.

Set up Foundry (https://book.getfoundry.sh/getting-started/installation) before coding. Then run public tests from this directory:

```bash
forge test
```

If `forge-std/Test.sol` is missing, install deps once with:

```bash
forge install foundry-rs/forge-std
```

## Starter Pack Layout

- `foundry.toml` - Foundry config (Solidity 0.8.20; `contracts/` as the source tree).
- `contracts/SimpleAMM.sol` - Uniswap v2-style CPMM with a 30 bps fee and helpers for swaps and reserves.
- `contracts/TestTokens.sol` - Two ERC-20 tokens (`TokenX`, `TokenY`) used by tests.
- `contracts/IERC20.sol` - Minimal ERC-20 interface.
- `contracts/SandwichBot.sol` - The only file you modify; contains three TODOs.
- `test/SandwichBot.t.sol` - Public Foundry test skeleton (hidden tests add more scenarios).

## Implementation Checklist (`contracts/SandwichBot.sol`)

All swaps use `SimpleAMM`'s 0.3% fee on the input side. Do not rename functions or change their visibility/arguments. You may add private/internal helpers.

- **State & ownership**
  - `tokenX`, `tokenY` are set in the constructor; `owner` is the deployer.
  - Use the provided `onlyOwner` modifier on external functions.

- **`computeFrontRunAmount(uint256 dxVictim, uint24 victimSlippageBps, uint112 reserveX, uint112 reserveY)`**
  - Return a non-negative X input for the attacker's front-run (0 allowed).
  - Derive the maximum front-run size from the victim slippage constraint (solve the quadratic on pre-front-run reserves), convert the fee-adjusted input back to gross `dxFront`, and require profit > 0. Otherwise return `0`.

- **`frontRun(SimpleAMM amm, uint256 dxFront)`**
  - Spend the bot contract’s existing `tokenX` balance (tests pre-fund the contract), approve the AMM for `dxFront`, and call `swapXForY(dxFront, address(this))`.
  - Owner-only. Should not revert for `dxFront = 0`.

- **`backRun(SimpleAMM amm)`**
  - Use the bot's entire Y balance: approve the AMM, then call `swapYForX(yBal, address(this))`.
  - Owner-only, and should handle the zero-balance case.

## Submission and Evaluation

- Submit only `contracts/SandwichBot.sol` to Gradescope.
- Keep contract names, function names, and signatures unchanged.
- Do not edit `SimpleAMM.sol`, `TestTokens.sol`, or the public portions of `test/SandwichBot.t.sol`.

## Local Testing

```bash
forge test -vv
forge test --match-test testFrontAndBackRunProfitableAndPaysOwner
```

Your code must compile with `forge build` without errors.

Tests fund the bot contract with `TokenX`; your code should not try to pull funds from elsewhere. `frontRun` spends the bot’s own balance.

## Resources

- Foundry book: https://book.getfoundry.sh/

## Academic Integrity

Please refer to UCSB's academic integrity guidance (https://studentconduct.sa.ucsb.edu/academic-integrity).
