# Shared Contracts (`contracts/`)

Single source of truth for cross-component API and event schemas ([ADR 0001](../docs/adr/0001-one-repository-for-all-components.md), [ADR 0003](../docs/adr/0003-fast-landing-zone-and-component-layout.md)):

- `openapi/` — OpenAPI specifications for REST APIs (positions, reference data, collateral) published via Apigee.
- `proto/` — Protobuf event schemas for Pub/Sub streams shared across Rust, Java, Go, and Python services.
- `sbe/` — Simple Binary Encoding (SBE) XML schemas for zero-copy decoding in [`components/low-latency`](../components/low-latency/).
