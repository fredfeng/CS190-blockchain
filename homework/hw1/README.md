# Homework Assignment 1

- Due: 11:59pm on Monday, April 22, 2024 (Pacific Time)
  - Late Submission Due: 11:59pm on Monday, Apr 29, 2024 (Pacific Time)

- Submit via Gradescope (Course Entry Code: 3PEP34)
- Starter Code: [hw1-starter.zip](./hw1-starter.zip)
  - Note: You need Python 3 installed if you'd like to run the starter code locally.
- Contact *Yanju Chen* on slack if you have any questions.

## Overview and Instructions

You will be implementing a Python function that generates a Merkle proof in this project. You can find the starter code at the top section of this page. 

You will be completing the missing part of a function called `generate_merkle_proof(nodes, pos)` in `prover.py`. In particular, given `nodes` that represents a list of data and `pos` which indicates the position of the data that you want to generate a Merkle proof of, the `generate_merkle_proof(nodes, pos)` function produces a list of hashes of the nodes of corresponding Merkle tree of `nodes`. Such a list of hashes is the Merkle proof of the target data `nodes[pos]`.

You can find three Python modules in the starter code:

- `prover.py`: This is the module that the prover will utilize to generate a Merkle proof. It contains the function `generate_merkle_proof(nodes, pos)` that you will be implementing.
- `verifier.py`: This is the module that the verifier will utilize to verify the correctness of a given Merkle proof. There are two major functions:
  - `compute_merkle_root(proof, pos, data)`: This function computes the *Merkle root hash*, which is used for checking whether a prover's Merkle proof matches with the real one.
  - `verify(fpt, pos)`: This function loads in a public dataset (see below for details) and verify the correctness of the `generate_merkle_proof` function from `prover.py`, where `fpt` is a path pointing to the dataset, and `pos` corresponds to the target data for generation of Merkle proof.
- `utils.py`: This module contains utility functions that you may find helpful during implementation and debugging.

## Datasets, Submission and Evaluation

**Datasets.** The full evaluation is performed on top of 5 datasets, where 2 of them are public datasets that you can try out and debug locally, and 3 of them are private (hold-out) datasets that are available to Gradescope's autograder only.

You can find the 2 public datasets in the starter code:

- `data0.txt`: This dataset contains 1000 data points, their Merkle proof (a list of hashes) and the Merkle root hash. The data follows the pattern "data item i" where "data item" is the common prefix and i is the position of data in the list.
- `data1.txt`: This dataset is similar to `data0.txt`, except that it uses a different prefix "new data" and contains a much smaller number of nodes (10).

The dataset file has the following format:

```
Merkle root hash
string of 1st data | list of node hashes separated by comma (,)
string of 2nd data | ...
...
```

Actually, you don't have to manipulate the dataset unless you want to do some debugging. The starter code has done everything else for you including the wrapper code for evaluation on the datasets. When you are done with implementation, just issue the following command to invoke the local testing from the verifier:

```bash
python ./verifier.py <path-to-dataset> <pos>
```

For example, if you want to test out your implementation for node at position 20 on the dataset `data0.txt`, you can simply do:

```bash
python ./verifier.py ./data0.txt 20
```

If it throws an exception (e.g., `AssertionError: Verification failed`) then there's something wrong in the prover implementation that you should consider fixing; otherwise, you are likely good to go and submit your implementation.

**Submission and Evaluation.** You will be sumitting only the `prover.py` file via Gradescope.

There are in total 16 test cases, where 6 of them are from public datasets (`data0.txt` and `data1.txt`), and  10 of them are from private datasets. Each test case is worth 1pt. The maximum points you can get is 20 pts, since you will get extra 4 pts if you submit your solution in time.

Note that:

- The extra 4 pts won't be awarded if you only submit an empty solution; so please do try your best to understand the problem and write down the solution.
- Please do NOT use external libraries that performs part of or entire computation of Merkle proof in your implementation; instead, you can use utility functions provided in the `utils.py` module. The homework is carefully designed in such a way that the shortest solution can be done less than 20 lines of code, and there's no fancy or complicated algorithms required. Submissions that contain use of such external libraries may be disqualified for all points.
- There's a grace period of 1 hour after the regular deadline. Note that the grace period is intended for you to wrap up and save your unfinished work for submission at the last minute, and if you could not catch that, your subsequent submissions will be marked as late submissions.
- The points you get will be converted to percentage when computing score of this homework towards your final grade. For example, if you get 20/20 pts, you get 100% of the homework score, and if you get 10/20 pts, you'll get 50% of the homework score, etc..
- Points earned from late submission will be discounted by 50%. Late submission is due 1 week after the regular deadline. Subsequent submissions after the late submission deadline will receive 0 point. There's no grace period of late submission deadline.

## Hints and Useful Resources

- ⭐️ If you have no idea about where to get started for the implementation, the `compute_merkle_root(proof, pos, data)` in `verifier.py` can be a perfect reference for the overall logic about how to traverse the tree and compute the hash.

- You may find the slides of Lecture 3 useful.
- Additionally, you may check out another practical blog about Merkle tree: [https://decentralizedthoughts.github.io/2020-12-22-what-is-a-merkle-tree/](https://decentralizedthoughts.github.io/2020-12-22-what-is-a-merkle-tree/)

## Academic Integrity

Please refer to UCSB's adacemic integrity guidance ([here](https://studentconduct.sa.ucsb.edu/academic-integrity)) if you have any questions.