# GCP FMI Eurex Platform

A reference platform for **Financial Market Infrastructures (FMIs)** on Google Cloud: scalable real-time position keeping, a low-latency in-memory hot path, the lifecycle of a tokenized and hybrid bond, and explainable market surveillance, built on a [Cloud Foundation Fabric FAST](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/v60.0.0/fast) landing zone and one shared data foundation.

> **Status: in progress.** Independent reference implementation, not affiliated with Google, Eurex or Deutsche Börse. Clearing members and accounts are fictitious, smart contracts run on a testnet only, and nothing here is meant for production use.

## Why this exists

Exchanges, CCPs and CSDs are moving core processes to the cloud while the industry shortens settlement cycles (the EU move to T+1 is planned for October 2027) and starts to tokenize assets. Both push batch-era post-trade processing towards real time.

This repository shows what that can look like on Google Cloud across the whole trade lifecycle, with the regulatory and operational rigor the industry requires: data residency, customer-managed encryption, operational resilience under DORA, and explainable AI.

## Platform & Components

| Layer / Component | What it shows | Key services | Status |
| --- | --- | --- | --- |
| [`fast/`](fast/) | Horizontal GCP landing zone (Stages 0–2): org policies (`europe-west3`), audit logs, WIF CI/CD, VPC-SC, KMS/HSM, Shared & ULL VPCs, YAML project factory | Terraform, CFF FAST `v60.0.0`, VPC-SC, Cloud KMS / HSM, CAS | Configured |
| [`contracts/`](contracts/) | Shared cross-component API and event contracts | OpenAPI, Protobuf, SBE | Scaffolded |
| [`components/data-foundation`](components/data-foundation/) | Reference data golden record, market data products, data sharing without copies, contract-first APIs | Pub/Sub, BigLake, BigQuery, Bigtable, Analytics Hub, Apigee | Planned |
| [`components/position-keeping`](components/position-keeping/) | Scalable real-time positions across tokenized, detokenized and hybrid instruments, intraday risk and margin for futures and options, tokenized collateral, DORA resilience | Pub/Sub, Dataflow, Spanner, BigQuery, Cloud Run | PRD drafted |
| [`components/tokenized-bond`](components/tokenized-bond/) | Issuance, tokenization and detokenization, DvP settlement, custody and lifecycle events of a hybrid bond | Solidity (testnet), Cloud KMS / Cloud HSM, Pub/Sub | Planned |
| [`components/market-surveillance`](components/market-surveillance/) | Spoofing detection on the order book with explainable alerts and an investigation agent | Vertex AI, Gemini, Agent Development Kit, BigQuery | Planned |
| [`components/low-latency`](components/low-latency/) | In-memory hot path with feed handler, pre-trade risk check and order gateway, latency benchmark ladder, cloud and co-location boundary | Rust, C3 / C4, compact placement, kernel bypass, Pub/Sub | Planned |

## Architecture

```mermaid
flowchart LR
    MD["Historical Eurex market data<br/>(licensed, replayed)"] --> ING["Ingestion and replay<br/>(Rust)"]
    ING --> PS[("Pub/Sub")]
    CHAIN["Testnet chain<br/>tokenized bond"] --> INT["Chain integration<br/>(Python)"]
    LEDGER["Classic holdings ledger<br/>(CSD stand-in)"] --> INT
    INT --> PS
    ING --> HOT["low-latency<br/>in-memory risk (Rust, FIFO)"]
    HOT --> PS

    subgraph DF["data-foundation"]
        RD["Reference data<br/>golden record"]
        LH[("BigLake / BigQuery<br/>data products")]
        BT[("Bigtable<br/>tick history")]
    end

    PS --> PK["position-keeping<br/>Dataflow (Java)"]
    PK --> SP[("Spanner<br/>position book")]
    PS --> LH
    PS --> BT
    RD --> PK
    PS --> MS["market-surveillance<br/>Vertex AI + agent (Python)"]
    LH --> MS

    SP --> API["Positions and reference data API<br/>(Go, OpenAPI, Apigee)"]
    RD --> API
    LH --> AH["Analytics Hub<br/>data sharing"]
    API --> CON["Clearing members,<br/>operations, supervisors"]
    AH --> CON
    MS --> CON
```

## Trade lifecycle coverage

| Stage | Where it is shown |
| --- | --- |
| Issuance | `components/tokenized-bond`: issuance via smart contract, investor whitelist |
| Trading | `components/data-foundation`: market data replay; `components/low-latency`: feed handler, pre-trade risk check, order gateway; `components/market-surveillance`: order book surveillance |
| Clearing | `components/position-keeping`: CCP view, margin calls, futures and options margin |
| Settlement | `components/tokenized-bond`: delivery versus payment; `components/position-keeping`: daily cash settlement of variation margin |
| Custody | `components/tokenized-bond`: custody with keys in Cloud KMS / Cloud HSM, coupon and redemption, tokenization and detokenization against the classic register |
| Reference and market data | `components/data-foundation`: golden record (ISIN, LEI, CFI, FIGI), market data products, data sharing |

## Engineering principles

- **Trunk-based development:** short-lived branches, CI on every push, blue/green deployments.
- **Horizontal landing zone, vertical components:** FAST Stages 0–2 isolate organization, security, networking and project provisioning; each component owns its Stage-3 `_infra/` state and application code ([ADR 0003](docs/adr/0003-fast-landing-zone-and-component-layout.md)).
- **Polyglot by purpose:** Python for agents, analytics and integration; Java for Dataflow (Apache Beam); Go for APIs; Rust for market data ingestion and the low-latency hot path; Solidity for smart contracts.
- **Contract-first:** OpenAPI, Protobuf and SBE contracts in [`contracts/`](contracts/) with contract tests, published through Apigee.
- **No database in the hot path:** latency-critical state lives in memory; databases hold the authoritative record and are updated asynchronously.
- **Event-sourced positions:** an immutable event log, idempotent consumers, reproducible historical states.
- **Secure by default:** EU region `europe-west3` (Frankfurt), customer-managed encryption keys, VPC Service Controls, least-privilege IAM.
- **Built to hand over:** every component ships with a PRD, an architecture diagram, Stage-3 `_infra/` and a hand-off guide.

Details: [docs/engineering-standards.md](docs/engineering-standards.md), the [architecture decision records](docs/adr/), the [low-latency playbook](docs/low-latency-playbook.md) and the [industry insights](docs/industry-insights.md) that keep each component close to how exchanges, CCPs and CSDs actually build.

## Regulatory context

The components are designed with these frameworks in mind: DORA, EMIR, CSDR, MiFID II / MiFIR, MAR, the EU AI Act, the EU DLT Pilot Regime, the German eWpG and the CPMI-IOSCO Principles for Financial Market Infrastructures. This is an engineering illustration, not legal or regulatory advice.

## Data

Market data comes from licensed historical Eurex data and is **not** part of this repository. The repository contains fetch and replay scripts and small synthetic samples only.

## Repository layout

```text
gcp-fmi-eurex-platform/
├── fast/                             # GCP landing zone (FAST Stages 0–2: org, vpcsc, security, net, project-factory)
├── contracts/                        # shared OpenAPI, Protobuf and SBE schemas
├── components/
│   ├── data-foundation/              # _infra/, replay-ingestor/ (Rust), data-products/ (SQL/Dataform)
│   ├── position-keeping/             # _infra/, position-pipeline/ (Java), positions-api/ (Go)
│   ├── tokenized-bond/               # _infra/, smart-contracts/ (Solidity), chain-bridge/ (Python)
│   ├── market-surveillance/          # _infra/, spoofing-detector/ (Python), investigation-agent/ (ADK)
│   └── low-latency/                  # _infra/, hot-path/ (Rust workspace)
└── docs/                             # PRDs, architecture decisions, engineering standards, playbooks
```

## Roadmap

- [x] `fast/` landing zone & multi-state component layout: November 2026
- [ ] `components/data-foundation` and `components/position-keeping` MVP: December 2026
- [ ] `components/tokenized-bond`, `components/market-surveillance` and `components/low-latency` MVP: January 2027
- [ ] Data foundation extensions and security hardening: February–March 2027

## License

[Apache License 2.0](LICENSE)

Maintained by [@bperunx](https://github.com/bperunx).
