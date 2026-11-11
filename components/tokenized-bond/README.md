# tokenized-bond

The lifecycle of a tokenized bond in a regulated market infrastructure: issuance, delivery versus payment, custody and lifecycle events. The bond exists as a hybrid instrument, partly on-chain and partly in a classic register, and can move between both forms.

**Status:** planned · **Target:** January 2027

## Layout

```text
components/tokenized-bond/
├── _infra/             # Stage-3 Terraform (Pub/Sub, Cloud Run worker, Cloud HSM IAM)
├── smart-contracts/    # Solidity (Foundry, ERC-3643)
└── chain-bridge/       # Python chain integration & classic CSD ledger stand-in
```

## Scope

- **Issuance:** bond issued by smart contract (Solidity in `smart-contracts/`) on a testnet, using a permissioned token standard such as ERC-3643.
- **Transfer restrictions:** only whitelisted, KYC-checked investors can hold the bond.
- **Settlement:** delivery versus payment (DvP).
- **Hybrid issuance:** one bond, one ISIN, two forms. Part of the issue is held as tokens, part in a classic holdings ledger that stands in for the central securities depository.
- **Tokenization and detokenization:** holdings move in both directions. Tokenizing locks the classic holding and mints tokens; detokenizing burns tokens and releases the classic holding. The total issued amount stays constant and is checked after every movement.
- **Internal and external networks:** the chain sits behind one interface, so the same flow works on the operator's own ledger and on an external network.
- **Lifecycle events:** coupon payment, redemption at maturity, one corporate action.
- **Operator controls:** freeze and forced transfer, as a regulated FMI operator needs them.
- **Custody:** key management in Cloud KMS / Cloud HSM (provisioned in [`../../fast/stages/2-security`](../../fast/stages/2-security/)).
- **Integration:** Python service (`chain-bridge/`) streaming chain events through Pub/Sub into [`../position-keeping`](../position-keeping/), reconciled against the classic holdings ledger after chain finality.
- **Tests:** contract tests with Foundry.
- **Design note:** how the same solution would look on Google Cloud Universal Ledger.

## Documents

- PRD: to follow in [`../../docs/prd/`](../../docs/prd/)
- Hand-off guide: to follow
