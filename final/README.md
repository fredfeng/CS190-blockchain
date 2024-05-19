# CS190 Blockchain: Final Project Guide

- Send a message to the course slack channel if you have any questions.

## Table of Contents

- [Overview](#overview)

- [Proposal Tracks](#proposal-tracks)

- [Proposal](#proposal)

- [Poster](#poster)

- [Final Report](#final-report)

- [Submission and Evaluation](#submission-and-evaluation)

- [Important Dates](#important-dates)

- [Academic Integrity](#academic-integrity)

## Overview

[[back to top]](#cs190-blockchain-final-project-guide)

You will be working with your teammates to build a real-world blockchain application using Solidity and Foundry; but don't worry, as a final project for this coure, you don't need to actually deploy it on any blockchains for now, but just demonstrate it using Foundry.

Each team will have 3-4 team members and will have to decide on one of the five tracks that you want to build an application for. Each track has a dedicated topic and its own functional requirements for the application you build. Check the "Proposal Tracks" for more details.

Note that the final project is not only about coding and getting the application implemented, other parts of blockchain software engineering are also important and will be contributing to the project evaluation. For example:

- Proposal: A clear project proposal is import to collaboration between team members;

- Documentation: A proper documentation will greatly improve the maintainability of the application you develop;
- Functional Tests: A comprehensive suite of functional testing cases will ensure the alignment with the specification.
- Penetration Tests: A set of well-designed penetration tests is crucial to the security of blockchain applications.
- Poster and Report: A demo and presentation is the best introduction to the community about your application design.

So the final project will be evaluated according to the above spirits. Check the "Evaluation" section for more details.

## Proposal Tracks

[[back to top]](#cs190-blockchain-final-project-guide)

> Don't worry, fine-grain specification is provided to help you sort out what to build but not to restrict what and how you should implement. We won't check the exact matching of your application artifact with the specification, but would rather focus more on whether some basic functionalities are realized or severely broken.

You team will need to ***choose one*** of the following five tracks to build your application for. Each track has its own functional requirements for the application. We've carefully designed the specification to make sure of an equal distribution of workloads among all tracks; so just pick the one that your team is most comfortable with.

### Track 1: Blockchain Marketplace

In this track, you will be building an online platform for buying and selling new or used items, in particular, powered by blockchain techniques. Similar to Facebook Marketplace, the blockchain marketplace will have the following main functionalities:

- A user can register as both buyer and seller and trade using ETH; or alternatively, the system needs some form of account management.
- A user can add one or more items for sell, with an expected price range.
- A user can view all items for sell and their expected prices; she can also buy and own items she likes, given sufficient ETH balance to pay.
- Items purchased by a buyer can be put on sell again.
- Within the same block, if one or more buyers pay for the same item, the one who pays more will eventually own it.

### Track 2: Blockchain Mailing System

In this track, you will be building a blockchain email system that allows users to send messages to each others. As blockchain transactions are public, and messages ought to be encrypted during transmission if they are private. To simplify the problem and have you focus on the business logic part, we assume the messages are automatically encrypted in a user-transparent way so you don't need to worry about that. Similar to traditional email systems like GMail, the blockchain mailing system will have the following main functionalities:

- A user can register customized account names and use her blockchain address to log in to the mailing system; or alternatively, the system needs some form of account management.
- A user can maintain (e.g., view/add/delete/update/...) a list of contacts with their mailing addresses via the system.
- A user can compose a message and send it to another mailing address, immediately or scheduled (on certain block.timestamp). The user can retract an email if the retraction action and the send action are within the same block.
- A user can check for and read new mails.
- A user can mark an email as read/unread/deleted/etc.. Deleted emails will be permanantly erased within certain amount of blocks.

### Track 3: Blockchain Meeting Scheduler

In this track, you will be building a blockchain meeting scheduling system that allows users to find time to meet with each others. To simplify the problem, block timestamp will be used for candidate time slots instead of real-world data and time. Similar to scheduling systems like Doodle, the blockchain meeting scheduler will have the following main functionalities:

- A user can register customized account names and log in using her blockchain address; or alternatively, the system needs some form of account management.
- A user can set her availability for the future block timestamp.
- A user can enable/disable different pre-set meeting types, e.g., 30-block meeting, 60-block meeting, etc.
- A user can book/cancel a meeting with another user for a given meeting type if it's enabled.
- Within the same block, if one or more users book conflicting blocks from the same user, the one that books earlier in real-world time will get the meeting confirmed.

### Track 4: Blockchain Q&A System

In this track, you will be building a blockchain Q&A system that allows users to post questions and reward the answers from other users with ETH. Similar to Quora, the blockchain Q&A system will have the following main functionalities:

- A user can register customized account names and use her blockchain address to log in to the Q&A system; or alternatively, the system needs some form of account management.
- A user can post a question with a preset reward in ETH and expired time. All other users can view the question and its reward.
- Both questions and answers, once published, cannot be modified.
- A user can answer an existing question or endorse it only once.
- A user can release the preset reward of a question to the user that gives the best answer and close it, or choose not to reward anyone but close the question.
- When a question is expired, the preset reward will be automatically awarded to the user of the most endorsed answer. If there are more than one most endorsed answers, reward will be splitted evenly.

### Track 5: Blockchain Survey System

In this track, you will be building a blockchain survey system that collects user responses anonymously. To simplify the problem, we restrict each survey to a single choice question with integer values for each option. Similar to platforms like SurveyMonkey, the blockchain survey system will have the following main functionalities:

- A user can register customized account names and use her blockchain address to log in to the survey system; or alternatively, the system needs some form of account management. Registration is only for starting a new survey, but to participate a survey, one doesn't need to register.
- A registered user can create a new survey, which consists of a problem description and several numerical options. The survey should has an expiry block timestamp and maximum number of data points accepted.
- One can view any active survey and its available options via its ID and participate in it by submitting her choice (only once for each ID).
- A survey owner can close the survey or wait for it to close after the expiry block timestamp or when it reaches the maximum accepted data points. When a survey is closed, certain reward in ETH will be sent to the users participating in it.
- On a survey expiry block, the survey will always close after receiving all incoming data points in the same block (last minute submission).

## Proposal

[[back to top]](#cs190-blockchain-final-project-guide)

Each team will be submitting a proposal (2 pages) discussing some of your application development plan, including:

- What's the name of your team? Who are the team members?
- Which track did you pick?
- What's the name of the application that you plan to build?
- A brief introduction and overview of the system.
- Draw a figure with detailed description (in text) about the overall framework or workflow of your application, which should include (but not restricted to): key components/classes and data structures, inputs/outputs.
- A brief discussion about potential security issues and your key designs to prevent them.
- The application development timeline and distribution of work between team members.
- Any other discussions that you think make your application different than others'.

## Poster

[[back to top]](#cs190-blockchain-final-project-guide)

Each team will be submitting a poster in PDF format, together with a presentation that introduces your project.

Check out a LaTeX template for the poster [here](./poster/); alternatively, you can use any other tool (e.g., PowerPoint, PhotoShop, etc.) to make your own poster, as long as it contains the following elements:

- Basic information of your project, including project name, team name, team members, etc.
- A figure about the overall framework or workflow of your project.
- Challenges that you've encountered (if you have done a lot of implementation) or you expect (if you haven't completed the implementation), together with the solutions that your team proposed to address the challenges.
- Potential security issues that you've addressed or anticipated, and the solutions that your team proposed.
- Any other discussions that you think would make your project solution different than others'.

For the poster session, your team will be given time to briefly present your work (use the poster wisely), followed by simple Q&A from the course staff and the audience. Make sure you are prepared for potential questions.

## Final Report

[[back to top]](#cs190-blockchain-final-project-guide)

Each team will be submitting a final report (8 pages; PDF) discussing details of the application your team has built. It's a detailed version of introduction and explanation to the bullet points you've brought up in the proposal. In particular, in the final report, you shall talk about:

- Basic information of your team and project, including project name, team name, team members, etc.
  - Please put your artifact in a publicly available github repo and include the link in your final report.
- The *actual* timeline of your team's project building activity.
- An introduction and overview of the system you built.
- A figure with detailed description (in text) about the overall framework or workflow of your application, which should include (but not restricted to): key components/classes and data structures, inputs/outputs.
- For each specification bullet point in the track you picked: How did you impelement it? What are the main challenges and considerations when designing the internal data structures and algorithms in order to fulfill the specification? What are the potential security concerns that needs attention for this specification? And how did you manage to address those security concerns?
- Any other discussions that you think would make your project solution different than others'.

## Submission and Evaluation

[[back to top]](#cs190-blockchain-final-project-guide)

Please submit all materials via gradescope, including written reports/documentations and application artifacts.

Here's the evaluation breakdown (100%):

- Proposal (10%)
  - Please check the "Proposal" section and gradescope for detailed requirements and breakdown.
  - Please do a group submission on gradescope; don't forget to include your teammates when you submit.
  - Late submissions (due 1 week after regular deadline) will have 75% deduction in points, and subsequent submissions after late submission deadline will receive 0 point. Though we generally have a 1-hour grace period for regular deadline, but please do coordinate with your teammates to make the submission on time.
  
- Poster (10%)
  - Poster (PDF) Submission (5%)
    - Please check the "Poster" section and gradescope for detailed requirements.
    - Please do a group submission on gradescope; don't forget to include your teammates when you submit.

  - Presentation at the Poster Session (5%)

- Final Report (20%)
  - Please check the "Final Report" section and gradescope for detailed requirements.
  - Please do a group submission on gradescope; don't forget to include your teammates when you submit.

- Application Artifact (60%)
  - Please put your artifact in a publicly available github repo and include the link in your final report.
  - Documentation (10%)
    - At least the following needs to be documentd:
      - APIs of the application: what they do, how they are called, what they return, and any special and security notes
      - How to set up the environment and initialize the application
      - What kinds of components there are, and what they do
      - What kinds of roles users can play, and what they can do
    - Markdown is recommended; README.md or DOCS.md is preferred.
    - Here's an example of the contents that your documentation shoudl *try* to include: [pandas documentation](Please put your artifact in a publicly available github repo and include the link in your final report.).
  - Functional Test Cases (20%)
    - You need to write *sufficient amount* of tests (at least 10) by yourself in Foundry and include them in your application artifact.
    - Tests should be explicitly addressing the specification bullet points found the in the "Proposal Tracks" section. One specification may correspond to multiple test cases.
    - A test should come with comments explaining its usage and purpose, specification that it's testing against, and the expected result.
  - Penetration Test Cases (10%)
    - You need to write *sufficient amount* of tests (at least 10) by yourself in Foundry and include them in your application artifact.
    - Tests should be directly related to some security concerns/attacks, not regular functional tests. If you are not sure what security issues that you should check, revisit [HW3](../homework/hw3/).
    - A test should come with comments explaining its usage and purpose, security issues that it's testing against, and the expected result, as well as potential damage if the test fails.
  - Holdout Functional Evaluation (10%)
    - A private holdout functional evaluation is run manually after sumission due to test for any violation of the specification of the track. You don't need to write them.
  - Holdout Security Evaluation (10%)
    - A private holdout security evaluation is run manually after submission due to test for any security breaches of the applications. We will test for some of the most common DeFi vulnerabilities (e.g., reentrancy, selfdestruct, etc.) on the submitted application artifact. You don't need to write them.


## Important Dates

[[back to top]](#cs190-blockchain-final-project-guide)

- Proposal Due: 11:59pm on Monday, May 20, 2024 (Pacific Time)
- Poster Due: 11:59pm on Wednesday, May 29, 2024 (Pacific Time)
- Poster Session: Regular Class Time on Monday, June 3 (Pacific Time)
  - Join on https://www.gather.town/, details to follow.

- Final Report Due: 11:59pm on Wednesday, June 5, 2024 (Pacific Time)

## Academic Integrity

[[back to top]](#cs190-blockchain-final-project-guide)

Please refer to UCSB's adacemic integrity guidance ([here](https://studentconduct.sa.ucsb.edu/academic-integrity)) if you have any questions.