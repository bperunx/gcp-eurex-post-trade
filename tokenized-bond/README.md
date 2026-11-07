# tokenized-bond

The lifecycle of a tokenized bond in a regulated market infrastructure: issuance, delivery versus payment, custody and lifecycle events, connected to the classic world.

**Status:** planned · **Target:** January 2027

## Scope

- **Issuance:** bond issued by smart contract (Solidity) on a testnet, using a permissioned token standard such as ERC-3643.
- **Transfer restrictions:** only whitelisted, KYC-checked investors can hold the bond.
- **Settlement:** delivery versus payment (DvP).
- **Lifecycle events:** coupon payment, redemption at maturity, one corporate action.
- **Operator controls:** freeze and forced transfer, as a regulated FMI operator needs them.
- **Custody:** key management in Cloud KMS / Cloud HSM.
- **Integration:** Python service streaming chain events through Pub/Sub into `position-keeping`, reconciled against a classic holdings ledger.
- **Tests:** contract tests with Foundry.
- **Design note:** how the same solution would look on Google Cloud Universal Ledger.

## Documents

- PRD: to follow in [`../docs/prd/`](../docs/prd/)
- Hand-off guide: to follow
