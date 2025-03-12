# Transparent Public Infrastructure Project Management

A blockchain-based system for transparent management of public infrastructure projects using Clarity smart contracts.

## Overview

This system enables transparent proposal submission, contractor bidding, progress tracking, and payment disbursement for public infrastructure projects. By leveraging blockchain technology, it ensures accountability, reduces corruption risks, and increases public trust in government infrastructure initiatives.

## Features

- **Project Proposal Management**: Submit, review, and approve infrastructure project proposals
- **Contractor Bidding**: Secure submission and evaluation of bids from contractors
- **Progress Tracking**: Monitor project milestones and overall completion
- **Payment Management**: Disburse funds based on verified progress
- **Transparency**: All actions are recorded on the blockchain for public verification
- **Accountability**: Clear tracking of responsibilities and authorizations

## Contracts

The system consists of four main smart contracts:

1. **Project Proposal Contract** (`project-proposal.clar`)
    - Manages submission and approval of infrastructure projects

2. **Contractor Bidding Contract** (`contractor-bidding.clar`)
    - Handles secure submission and evaluation of bids

3. **Progress Tracking Contract** (`progress-tracking.clar`)
    - Monitors project milestones and completion

4. **Payment Release Contract** (`payment-release.clar`)
    - Manages disbursement of funds based on verified progress

## Usage

### For Government Entities

1. **Submit Project Proposals**
   ```clarity
   (contract-call? .project-proposal submit-proposal "City Bridge Renovation" "Renovation of the main bridge connecting downtown to the suburbs" u1000000 u365)
