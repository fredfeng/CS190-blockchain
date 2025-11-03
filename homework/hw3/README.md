# Homework Assignment 3: AMM Pricing & Band Simulation

- Due: 11:59pm on Wednesday, Nov 12, 2025 (Pacific Time)
  - Late Submission Due: 11:59pm on Wednesday, Nov 19, 2025 (Pacific Time)
- Submit via Gradescope (Course Entry Code: VW3K2R)
- Starter Code: [hw3-starter.zip](./hw3-starter.zip)
  - Foundry is required in order to build, run and test the code if you built on top of the starter code.
- Contact *Hanzhi Liu* on Slack if you have any questions

## Overview and Getting Started

Automated market makers (AMMs) underpin many decentralized exchanges. In this homework you will implement pricing helpers for two classic pool types:

- **Constant Product (CPMM)** — price impact grows with trade size (Uniswap v2 style).
- **Constant Sum (CSMM)** — linear pricing that can be exhausted if one token is drained.

Your task is to complete `src/AMM.sol` by writing pure helper functions that:

1. Compute swap outputs for X→Y trades in both AMMs.
2. Report both spot (instantaneous) and execution (trade-size-aware) prices using 1e18 fixed-point scaling.
3. Express slippage between two prices in signed basis points.
4. Simulate a multi-step sweep across a user-provided trading band.

Before coding, make sure Foundry is ready on your machine (see the “Installation” section of [https://book.getfoundry.sh/getting-started/installation](https://book.getfoundry.sh/getting-started/installation) and the “First steps” walkthrough). Once Foundry is installed:

```bash
forge test
```

Run that command inside this directory to execute the provided public tests.

## Starter Pack Layout

- `foundry.toml` — minimal Foundry configuration.
- `src/AMM.sol` — implement all functions listed below; keep signatures unchanged.
- `test/AMM.t.sol` — Solidity tests that read expected values from JSON fixtures.
- `testdata/hw3_cases.json` — numeric fixtures used by the tests. Do not modify.

## Implementation Checklist

All reserves and trade sizes are expressed in raw token units (integers). All prices are **X-per-Y** values scaled by `1e18`, meaning `2e18` represents “2 units of X per 1 unit of Y”.

### Amount-Out Helpers

- **`cpmmAmountOut(uint256 x, uint256 y, uint256 dx)`**
  - Preserve the constant-product invariant while moving along the curve.
  - Use integer math with flooring when solving for the new reserves.
  - Handle degenerate cases (`x == 0`, `y == 0`, or `dx == 0`) by returning `0` instead of reverting.

- **`csmmAmountOut(uint256 x, uint256 y, uint256 dx)`**
  - Enforce the constant-sum behavior and cap the output by the available Y reserve.
  - Keep swaps no-op when `y == 0` so the simulator can continue safely.

### Spot Prices (Instantaneous Marginal Price)

- **`spotPriceXPerY_CP(uint256 x, uint256 y)`**
  - Base the spot price on current reserves and scale the result to `1e18`.
  - Return `0` when the pool cannot quote a finite price (any reserve is zero).

- **`spotPriceXPerY_CS(uint256 x, uint256 y)`**
  - Report the flat price used by constant-sum pools while liquidity exists.
  - Signify drained pools by returning `0`.

### Execution Prices (Average Price Paid for a Finite Trade)

- **`executionPriceXPerY_CP(uint256 x, uint256 y, uint256 dx)`**
  - Reuse your amount-out helper to avoid diverging logic.
  - Scale the ratio of `dx` to `dy` to `1e18`, guarding against division by zero.

- **`executionPriceXPerY_CS(uint256 x, uint256 y, uint256 dx)`**
  - Mirror the CPMM pattern but with the constant-sum helper.
  - Return `0` after the pool is fully drained.

### Slippage in Basis Points

- **`slippageBps(uint256 pExec1e18, uint256 p01e18)`**
  - Compare execution and spot prices in basis points using only integer math.
  - Provide signed output and treat missing spot references (`p01e18 == 0`) as zero slippage.

## Simulating X→Y Trades Across a Band

**Function:** `simulateXtoYBand(uint256 x, uint256 y, uint256 bandBps, uint256 steps, bool isCPMM)`
  - Conceptually: if you ask, “How do I push the price up by 2% in 5 equal trades, and what happens to my average price and slippage each time?”, this routine walks those five trades in order and returns the exact `dx`, `dy`, execution price, and slippage per slice so you can inspect the full path.

The function returns four arrays of length `steps`:

- `dxs[i]` — the incremental X input at step `i`.
- `dys[i]` — the Y output received at step `i`.
- `pexecs1e18[i]` — execution price for that step (X-per-Y, scaled by `1e18`).
- `slipsBps[i]` — slippage versus the initial spot price in signed basis points.

General expectations:

1. `steps` must be ≥ 1. Allocate arrays of length `steps`.
2. Compute the **initial** spot price once (based on the input `x` and `y`) and use it as the slippage baseline for every step.
3. Mutate local copies of the reserves as you simulate each trade. Do **not** revisit prior reserves.
4. Each step must record the incremental trade only; cumulative totals are implied by summing prefixes.

### CPMM Band (price-linear stepping)

1. Capture the initial spot price and exit early with zero arrays when it is undefined.
2. Increase the target price by `bandBps` basis points overall and split that price interval evenly across `steps`.
3. For each target price:
   - Determine how much X input is required to move from the current reserves to that price while respecting the constant-product.
   - Clamp negative or zero deltas to avoid regressions if you already overshoot.
   - Apply the swap using your helper functions and update the working reserves.
4. Record the incremental `dx`, `dy`, execution price, and slippage for each step before moving to the next one.

### CSMM Band (quantity-linear stepping)

1. Bound the total input by both the band size and the available Y reserve.
2. Split the total band input into `steps` consecutive chunks (account for remainders so the sum matches).
3. Execute each chunk sequentially, updating reserves and tracking outputs after every trade.
4. Expect execution prices to stay flat until the pool is drained; once the reserve hits zero, the helper functions should carry the rest of the logic.

### Edge Cases

- Always return arrays of length `steps` even when all values are zero.
- Flooring is required whenever you divide.

## Submission and Evaluation

- Submit only `src/AMM.sol` on Gradescope.
- Hidden tests will check boundary conditions, rounding, and that the cumulative band simulation reaches the intended targets.
- Point breakdown (100 pts total):
  - 30 pts — CPMM amount-out and spot price.
  - 20 pts — CPMM execution price and slippage.
  - 20 pts — CSMM amount-out and pricing behavior.
  - 30 pts — Band simulator (both CPMM and CSMM modes).

## Local Testing

- Run all provided tests with `forge test -vv`.
- Run a specific test by name: `forge test --match-test test_simulateXtoYBand_case`.
- You may add your own tests under `test/`, but do not modify the provided fixtures or the public tests.

## Hints and Resources

- Reuse shared helper logic to avoid subtle inconsistencies (e.g., call `cpmmAmountOut` from the execution price helper).
- Keep intermediates in `uint256` unless a signed result is required (like slippage).
- Recommended references:
  - Lecture notes on AMMs.
  - Foundry Book: [https://book.getfoundry.sh/](https://book.getfoundry.sh/)
  - Solidity by Example: [https://solidity-by-example.org/](https://solidity-by-example.org/)

## Academic Integrity

Please refer to UCSB's adacemic integrity guidance ([here](https://studentconduct.sa.ucsb.edu/academic-integrity)) if you have any questions.
