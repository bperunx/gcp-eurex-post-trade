# data-foundation

The shared data layer under all other components: reference data, market data products, data sharing and API contracts.

**Status:** planned · **Target:** December 2026

## Layout

```text
components/data-foundation/
├── _infra/             # Stage-3 Terraform (isolated state from 2-project-factory)
├── replay-ingestor/    # Rust market data ingestion and replay service
└── data-products/      # BigQuery / BigLake SQL, Dataform, golden record schemas
```

Cross-component OpenAPI, Protobuf and SBE schemas live in [`../../contracts/`](../../contracts/).

## Scope

- **Market data ingestion and replay:** historical Eurex trades and order book data, replayed into Pub/Sub at configurable speed. Ingestion adapter in Rust (`replay-ingestor/`).
- **Reference data golden record:** one authoritative source for instruments (futures, options, bonds, tokens), trading calendars and parties, including settlement instructions. Identifiers: ISIN, LEI, CFI, FIGI.
- **Tick history:** Bigtable with a row-key design for time-range scans per instrument.
- **Data products:** market data, reference data and events as owned data products in BigLake and BigQuery, modelled as Data Vault, with a star-schema mart for reporting (`data-products/`).
- **Data sharing:** distribution to consumers through Analytics Hub, without copying files.
- **APIs:** OpenAPI contracts in [`../../contracts/openapi/`](../../contracts/openapi/) with contract tests for positions, reference data and collateral, published through Apigee.

## Planned instruments

Euro Stoxx 50, DAX and Euro-Bund futures, DAX options, and one volatile trading day as a stress scenario. Final selection pending.

## Data licensing

Raw market data is licensed and stays out of this repository. Only fetch scripts and synthetic samples are committed.

## Documents

- PRD: to follow in [`../../docs/prd/`](../../docs/prd/)
- Hand-off guide: to follow
