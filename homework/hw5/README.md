# Homework Assignment 5

- Due: 11:59pm on Monday, Dec 15, 2025 (Pacific Time)
  - Late Submission Due: <u>There's no late submission due for this homework.</u>
- Submit via Gradescope (Course Entry Code: VW3K2R)
- Starter Code: [hw5-starter.zip](./hw5-starter.zip)
  - Foundry is required in order to build, run and test the code if you built on top of the starter code.

- Contact *Yanju Chen* on slack if you have any questions.

## Overview and Getting Started

Decentralized apps could be vulnerable; loss of funds due to bugs is not uncommon on blockchains. In this homework assignment, you will be solving a few puzzles to unlock new perspectives by constructing attacks for breaking different DeFi systems. Of course, the cases are heavily simplified, but they should represent several categories of common and exploitable vulnerabilities.

## The Vulnerability Problem Set

There are in total 9 different problems, where in each problem you will be asked to construct an attack contract such that, when called by a Foundry test, breaks the given DiFi setting in a specified way. Based on the difficulty to break the system, each problem has different values of points: the higher the more difficult.

You are free to choose to submit solutions to any one or more of them, with the goal of earning up to 100 pts; i.e., you don't have to solve all of them, but just pick the one(s) that you are most comfortable with. As long as you get a total of more than 100 pts, you then score 100% of this homework.

Each problem comes with a background contract `ProblemX.sol`, a Foundry testing contract `ProblemX.t.sol` and a template for attack contract `AttackerX.sol`. Fill in the attack contract `AttackerX.sol` to start solving the question. Modification of other contracts is prohibited. You can find concrete goal for attack in `test_attack` function of each `ProblemX.t.sol`; you earn the points by achieving the goals defiend in `ProblemX.t.sol`. Call `forge test -vvv` to check for the validity of your attack.

The following is a list of instructions for each problem.

### Problem 1: Game Breaker (15 pts)

Alice, Bob and Charlie are playing a game where they add tokens to a gaming contract. They got so addicted to it that you want to stop them by breaking the gaming contract. Write an attack contract to *completely* stop the gaming contract by preventing anyone from adding tokens or claiming rewards.

### Problem 2: Turn Taking (30 pts)

Alice and you are playing an on-chain game called EtherGame, where both of you take turns depositing 1 or 2 ether into the game, and the first one that deposits the 10th ether of the game's balance can claim all tokens deposited. Now that Alice has made her first move by depositing 2 ether, but you have a sure way to win, show it by completing the attack contract.

### Problem 3: Vote (20 pts)

Alice, Bob and Charlie have different opinions about where go to for the weekend. They found a voting app where you vote using your ETH. Alice wants to go surfing, and Bob wants to go hiking. They both have 55 ETH. Your best friend, Charlie, wants to see the northern lights (aurora) but he only has 10 ETH, and he just sends them all to you. Help Charlie win the voting.

### Problem 4: Throne (20 pts)

There's an EtherQueen app where you can deposit the biggest amount of ETH to be queen, and all that you are wanting now is to be the QUEEN forever. Stop others from claiming the throne after you become the queen.

### Problem 5: Abdication (25 pts)

Following Problem 4, aware of the attack, the EtherQueen app has been updated to prevent attackers from breaking it. Alice and you are competing. While Alice has 10 ETH to claim the throne, you only have 9 ETH. Even though you claimed the throne at the very first, you are forced to abdicate when Alice put all her 10 ETH in. However, you still believe that as long as you were the queen once, you can be the queen twice. Finish the attack to reclaim the throne.

### Problem 6: Auction (25 pts)

There's a new type of bidding app live on blockchain, where bidder can interact with the auction shop and whoever that deposits the most will be the buyer for the auction item. You and Alice are fond of the same item. Even though you'd really like to buy it, you only have 1 ETH to bid as compared to 100 ETH from Alice. It looks like Alice will be the buyer, but perhaps you can still make a change by reading the auction contract carefully.

### Problem 7: Unlock (15 pts)

There's a locker app on blockchain that provides pretty good rewards as long as you deposit some funds for a certain period of time (blockchain timestep) there. However, the wait time is too long. Looking at the contract, you realize something can be done to speed this up. The locker has 1000 ETH. Fill in the attack contract to drain all balance up from the locker.

### Problem 8: Prompt Reward (15 pts)

There's a reward pool that distributes bonus ETH if you deposit certain amount of funds, and interestingly you can get rewarded immediately without waiting. A bad news is that right now you don't have any ETH left after fierce competition for the throne of Ether Queen. You notice that there's a flash loaner that provides sufficient funds, so maybe you can give it a shot, and take out all the rewards.

### Problem 9: Back Door (15 pts)

You friend told you that there's a flash loaner that is making quite some profits: every once in a while it sends the profits to an external account. How you wish the profits can go to your own account! Oh wait, maybe that's not impossible! Fill in the attack contract to collect the profits of the current round. 

## Submission and Evaluation

You will be submitting only the `AttackerX.sol` files (where `X` means the problem id) via Gradescope. You can build upon the provided template in the starter pack, and test locally using Foundry before you submit. The local tests are the same as the ones on gradescope.

Note that, please do NOT include any Foundry utilities/libraries in `AttackerX.sol`; i.e., you are NOT supposed to use the cheatcodes provided by Foundry, NOR codes from outside the current problem scope when constructing the attack contract. For example, you are not supposed to use contracts from `Problem2.sol` when you are working on `Attacker1.sol`. You will receive 0 pt if such utilities/libraries are detected by the autograder or manually. ONLY modify and submit the `AttackerX.sol`. You are free to modify the entire `AttackerX.sol` except for the `pragma solidity xxxxxx` line and the `import` line.

The maximum points you can get is 100 pts, which can be gained from arbitrary number of problems picked by yourself. Note that:

- The points you get will be converted to percentage when computing score of this homework towards your final grade. For example, if you get 100/100 pts, you get 100% of the homework score, and if you get 30/100 pts, you'll get 30% of the homework score, etc.
- There's a grace period of 1 hour after the regular deadline. Note that the grace period is intended for you to wrap up and save your unfinished work for submission at the last minute, and if you could not catch that, your subsequent submissions will be marked as late submissions.
- <u>There's no late submission deadline for this homework.</u> Subsequent submissions after the regular submission deadline will receive 0 point.

## Hints and Useful Resources

- You may find this Solidity language examples useful: [https://solidity-by-example.org/](https://solidity-by-example.org/)
- Foundry itself is a tool that provides powerful testing utilities for Solidity. Check out its documentation here: [https://book.getfoundry.sh/](https://book.getfoundry.sh/)

## Academic Integrity

Please refer to UCSB's adacemic integrity guidance ([here](https://studentconduct.sa.ucsb.edu/academic-integrity)) if you have any questions.