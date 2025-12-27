# Authorization-Governed Vault System

## Overview
This project implements a **secure, multi-contract vault system** for controlled asset withdrawals. It separates responsibilities for fund custody and authorization validation to enforce security and replay protection. The system is fully Dockerized and deployable on a local blockchain for testing and evaluation.

---

## Architecture

The system consists of **two smart contracts**:

1. **AuthorizationManager.sol**
   - Responsible for verifying off-chain generated authorizations.
   - Tracks used authorizations to prevent replay attacks.
   - Does **not** hold or transfer funds.

2. **SecureVault.sol**
   - Holds and transfers ETH (native blockchain currency).
   - Calls `AuthorizationManager` to validate withdrawals before transferring funds.
   - Emits events for deposits and withdrawals.
   - Ensures internal invariants (balance cannot go negative).

**Separation of concerns:**  
- **AuthorizationManager** handles **permission verification**.  
- **SecureVault** handles **fund custody and transfers**.  

---

## Authorization Design

- Off-chain authorizations are signed by a trusted authority.  
- Each authorization is bound to the following parameters:
  - Vault address
  - Blockchain network (chain ID)
  - Recipient address
  - Withdrawal amount
  - Unique authorization ID  

- **Flow:**
  1. Authority signs a unique message off-chain containing the parameters above.
  2. Recipient submits the signed authorization to `SecureVault`.
  3. `SecureVault` calls `verifyAuthorization` in `AuthorizationManager`.
  4. `AuthorizationManager` validates the signature, ensures the authorization has not been used, and marks it as consumed.
  5. If valid, `SecureVault` transfers funds to the recipient.

- Signature verification is **always offloaded** to `AuthorizationManager` and never handled directly by `SecureVault`.

---

## Replay Protection

- Each authorization ID can be used **exactly once**.  
- Attempting to reuse an authorization will revert with `"Authorization already used"`.  
- Ensures that each authorization triggers **exactly one state transition**.

---

## Events

All key state changes are observable via events:

- **Deposit:** emitted when ETH is deposited to the vault.  
- **Withdrawal:** emitted when a valid withdrawal occurs.  
- **AuthorizationConsumed:** emitted when an authorization is consumed.

---

## Deployment Instructions

### Requirements
- Docker & Docker Compose  
- Node.js 18.x  
- Hardhat

### Steps

1. **Build Docker image**
```bash
docker-compose build
```
2. **Start the system**
```bash
docker-compose up
```

3.**Expected logs**
```bash
Starting local Hardhat blockchain...
Compiling contracts...
Deploying contracts...
AuthorizationManager deployed at: <address>
SecureVault deployed at: <address>
Deployment completed successfully
```

- RPC is exposed at http://localhost:8545.

- Contracts are deployed automatically — no manual steps required
## Assumptions & Limitations

- Only local blockchain deployment is supported.  
- Single authority is used for signing authorizations.  
- No frontend is provided; interaction is via scripts or programmatic calls.  
- Only native ETH (or the network’s base currency) is supported.  
- Security assumes off-chain authority’s private key is kept safe.
## Optional Enhancements

- Architecture or interaction diagrams  
- Automated tests for successful and failed withdrawals  
- Integration with off-chain coordination service for authorization management