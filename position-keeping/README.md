# position-keeping

Scalable real-time position keeping and intraday risk for a clearing house, across tokenized, detokenized and hybrid financial instruments, with a low-latency in-memory hot path and operational resilience under DORA.

**Status:** PRD drafted · **Target:** December 2026

## Scope

- **Low-latency hot path:** in-memory, event-sourced risk service in Rust with strict first-in-first-out processing. It keeps position and margin state in memory and answers pre-trade risk checks without a database round trip. Spanner is updated asynchronously from the same event log.
- **Streaming core:** Pub/Sub → Dataflow (Java, Apache Beam) → Spanner as the authoritative position book, analytics in BigQuery.
- **Clearing view:** CCP as central counterparty, fictitious clearing members and client accounts, margin calls, daily cash settlement of variation margin.
- **Risk and margin:** intraday risk for futures and options, scenario-based margin, offsets between futures and options, option expiry.
- **Tokenized collateral:** tokenized securities posted as margin collateral, with fast top-ups when margin runs short.
- **Hybrid instruments:** one position book for instruments held on-chain, off-chain or both at once. An account's position is the consolidated sum of its tokenized and classic holdings; tokenization and detokenization arrive as paired events (mint and lock, burn and release) and are never counted twice or lost. Chain finality is respected: on-chain movements count only after confirmation and are reversed on a reorg.
- **Replay and reproducibility:** full replay of a stress day without lost or duplicated events, exact reconstruction of any historical position, end-of-day reconciliation against an independent batch run, cost per trading day.
- **DORA:** multi-zone operation in Frankfurt, zone failure injected during replay, automated incident classification with a draft report, documented exit strategy.
- **Positions API:** Go service on Cloud Run, implementing the contract from `data-foundation`.
- **Latency benchmark:** hot path and market data fan-out measured in the cloud with compact placement; p50, p99 and p99.9 published together with the limits.
- **Cloud and co-location boundary:** a short design note on what belongs in the cloud (risk, post-trade, data, digital assets) and what stays in co-location (order matching of latency-critical markets).

## Success criteria

Targets for the MVP, to be confirmed or corrected by measurement:

- **Throughput:** 50,000 events per second sustained and 200,000 per second in bursts, with no backlog after the burst.
- **Size:** 10,000 accounts across 5,000 instruments, including a hot instrument that carries 30 percent of all events.
- **Freshness:** a trade is visible in the Spanner position book within 1 second at p99.
- **Hot path:** a pre-trade risk check takes less than 100 microseconds at p99 inside the service, network excluded.
- **Hybrid instruments:** consolidated positions equal the sum of chain and ledger holdings after every tokenization and detokenization, including under replay.
- A stress day replays completely, with no lost or double-counted events.
- Every historical position state is exactly reproducible.
- End-of-day positions match an independent batch calculation.
- Cost per trading day is transparent.

## Documents

- PRD: to follow in [`../docs/prd/`](../docs/prd/)
- Hand-off guide: to follow
