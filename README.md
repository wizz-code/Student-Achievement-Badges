# Student Achievement Badges Smart Contract

A digital badge system for recognizing and recording student achievements on the blockchain.

## Features

- Badge type creation and management
- Badge awarding with reasons
- Achievement verification
- Authorized issuer system
- Student badge portfolios

## Contract Functions

### Public Functions

- `authorize-issuer` - Authorize badge issuers (owner only)
- `create-badge-type` - Create new badge type
- `award-badge` - Award badge to student
- `deactivate-badge-type` - Deactivate badge type

### Read-Only Functions

- `get-badge-type` - Get badge type details
- `get-badge-award` - Get specific award details
- `has-badge` - Check if user has specific badge
- `get-user-badge-count` - Get total badges for user
- `is-authorized-issuer` - Check issuer authorization
- `get-badge-type-nonce` - Get current badge type counter
- `get-badge-award-nonce` - Get current award counter

## Usage

Deploy with Clarinet to create verifiable digital achievement system.