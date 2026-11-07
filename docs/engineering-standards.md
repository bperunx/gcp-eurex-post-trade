# Engineering standards

## Workflow

- Trunk-based development: short-lived branches or direct commits to `main`, feature flags for unfinished work.
- CI runs on every push and pull request; `main` stays green.
- Deployments are blue/green, through Cloud Deploy or traffic splitting on Cloud Run.

## Languages and tests

| Language | Used for | Tests |
| --- | --- | --- |
| Python | Agents, analytics, chain integration | pytest |
| Java | Dataflow pipelines (Apache Beam) | JUnit with Beam `TestPipeline` |
| Go | APIs on Cloud Run | `go test` |
| Rust | Market data ingestion and replay | `cargo test` |
| Solidity | Smart contracts | Foundry |
| Terraform | Infrastructure | `terraform fmt`, `terraform validate` |

APIs have OpenAPI contracts and contract tests.

## Design patterns

- **Event sourcing and CQRS** in the position book: positions are derived from an immutable event log, so any historical state can be rebuilt.
- **Idempotent consumers:** every event carries a unique ID, so replays never double-count.
- **Transactional outbox** where a state change and an event must be published together.

## Documentation per component

- PRD with critical user journeys and success metrics
- Architecture diagram
- Hand-off guide for an engineering team: setup, operations, extension
- README in English
