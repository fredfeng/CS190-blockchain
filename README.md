# CS190J Blockchain Technologies and Security

The course covers all aspects of blockchains and cryptocurrencies, including distributed consensus, smart contracts, economics, scalability, security, and applications. We will focus on Bitcoin and Ethereum as case studies.

The workloads include 4 programming assignments plus one final project.

# Office hour
Instructor : Yu Feng (yufeng@UCSBCS)

TA : Yanju Chen (yanju@UCSBCS)

Class: M,Wed, 5:00pm-6:15pm, CHEM 1171

Instructor's office hour: Mon, 9am-10am

TA's office hour: Mon, 4pm-5pm, Zoom, or by Appointment


| Date  | Topic                                         | Slides | Read | Out | Due |
|-------|-----------------------------------------------|--------|------|-----|-----|
| 4/1  | Introduction to blockchain and cryptocurrency                                  |  [lec1](lectures/lecture1.pdf)      |      |     |     |
| 4/3  | Bitcoin                                  |  [lec2](#)      |      |     |     |
| 4/8  | Merkle tree          |  [lec3](#)      |  R1    |     |     |
| 4/10  | Proof of Stake             |  [lec4](#)      |     | [HW1](homework/hw1/hw1.md) |     |
| 4/15  | Ethereum               |  [lec5](#)     |   R2   |     | R1    |
| 4/17 | Solidity                           |  [lec6](#)      |      |   |     |
| 4/22 |  Stablecoins, Oracle, and Lending                           |  [lec7](#)      |      |       |  HW1   |
| 4/24 | Decentralized exchanges                         |  [lec8](#)      |  R3    | [HW2](homework/hw2/hw2.md) |  R2   |
| 4/29 |  Onchain Gaming                        |  [lec9](#)      |  Proposal    |     | |
| 5/1 | DeFi Security    --Yanju      | [lec10](#)        |      |    |  R3   |
| 5/6 | MEV           | [lec11](#)        |      |    | HW2 |
| 5/8 | Zero-knowledge Proofs and zkSnarks   |  [lec12](#)       |      |     |   Proposal (2 pages)  |
| 5/13  |  Optimistic Rollups                      |  [lec13](#)       |  R4    |     |     |
| 5/15  |  ZK Rollups -- Haichen Shen at Scroll  | [lec14](#)        |      | [HW3](homework/hw3/hw3.md) |     |
| 5/20  | Privacy blockchain -- Yanju |   [lec15](#)     |      |     |     |
| 5/22  | ZK Security --Yanju |   [lec16](#)     |      |     |     |
| 5/27 | Memorial Day                       |         |       |     |   R4, Poster (PDF)  |
| 5/29 | TBD                |     [lec17](#)   |      |     | HW3 |
| 6/3 | TBD        |   [lec18](#)      |      |     |    |
| 6/5  | Poster Session for Final Projects                                 |        |      |     |  Final Report (8 pages)  |


# Grading

1. Programming assignments: 30%
    1. 3 programming assignments, 10% each

2. Paper reviews: 20%
    1. 4 papers, 5% each
    
3. Final project: 50%
    1. Team formed by deadline: 5%
    2. 1-page project proposal: 15%
    3. Project presentation: 15%
    4. Final report: 15%


Below is a grading system used by CS190I (No curving).

| Letter | Percentage |
|--------|------------|
| A+     | 95–100%    |
| A      | 90–94%     |
| A-     | 85–89%     |
| B+     | 80–84%     |
| B      | 75–79%     |
| B-     | 70–74%     |
| C+     | 65–69%     |
| C      | 60–64%     |
| F      | <60%       |

Credit: https://en.wikipedia.org/wiki/Academic_grading_in_the_United_States


### Submission
1. Please submit your homework to gradescope: https://www.gradescope.com
2. All paper reviews should be in PDF.


# Homework

1. [Homework1](homework/hw1/hw1.md)
2. [Homework2](homework/hw2/hw2.md)
3. [Homework3](homework/hw3/hw3.md)


# Reading assignments
1. A Lightweight Symbolic Virtual Machine for Solver-Aided Host Languages. Emina Torlak and Rastislav Bodik. PLDI'14.
2. Program synthesis using conflict-driven learning. Yu Feng, Ruben Martins, Osbert Bastani, and Isil Dillig.  PLDI'18. **Distinguished Paper Award** 
3. Scaling symbolic evaluation for automated verification of systems code with Serval. Luke Nelson, James Bornholt, Ronghui Gu, Andrew Baumann, Emina Torlak, and Xi Wang. SOSP'2019. **Best Paper Award**
4. Schkufza et.al. Stochastic Superoptimization. ASPLOS'13


Tips for writing paper [reviews](REVIEW.md).

Tips for writing a project [proposal](PROPOSAL.md).

# References

- Rondon, Patrick M., Ming Kawaguci, and Ranjit Jhala. "Liquid types." PLDI'2008.

- Ali Sinan Köksal, Yewen Pu, Saurabh Srivastava, Rastislav Bodík, Jasmin Fisher, Nir Piterman. Synthesis of biological models from mutation experiments. Principles of Programming Languages (POPL). 2013. ACM DL

- Srivastava, Saurabh, Sumit Gulwani, and Jeffrey S. Foster. From program verification to program synthesis. POPL 2010.

- Jha, Susmit, et al. Oracle-guided component-based program synthesis. ICSE 2010.

- Gulwani, Sumit. Automating string processing in spreadsheets using input-output examples. POPL 2011.

- Phothilimthana, Phitchaya Mangpo, et al. "Scaling up superoptimization." ASPLOS 2016.

- Chandra, Kartik, and Rastislav Bodik. Bonsai: synthesis-based reasoning for type systems. POPL 2017.

- Bornholt, James, et al. Optimizing synthesis with metasketches. POPL 2016.

- Yaghmazadeh, Navid, et al. SQLizer: query synthesis from natural language. OOPSLA 2017. **Distinguished Paper Award**

- Deepcoder: Learning to write programs. Matej, et al. ICLR'16.

- Helgi Sigurbjarnarson, James Bornholt, Emina Torlak, and Xi Wang. Push-Button Verification of File Systems via Crash Refinement. OSDI 2016. **Best Paper Award**

- Shaon Barman, Sarah E. Chasins, Rastislav Bodik, Sumit Gulwani. Ringer: web automation by demonstration. OOPSLA 2016.

- Luke Nelson, Jacob Van Geffen, Emina Torlak, and Xi Wang. Specification and verification in the field: Applying formal methods to BPF just-in-time compilers in the Linux kernel. OSDI 2020.

- Chenming Wu, Haisen Zhao, Chandrakana Nandi, Jeff Lipton, Zachary Tatlock, Adriana Schulz. Carpentry Compiler. SIGGRAPH ASIA 2019.

- Permenev, Anton, et al. Verx: Safety verification of smart contracts. 2020 IEEE Symposium on Security and Privacy 2020.

- Chenglong Wang, Yu Feng, Ras Bodik, Alvin Cheung, Isil Dillig. Visualization by Example. POPL'2020.

- Beckett, Ryan, et al. Network configuration synthesis with abstract topologies. PLDI'2017.

- Dai, Wang-Zhou, et al. Bridging machine learning and logical reasoning by abductive learning. NIPS'2019.


