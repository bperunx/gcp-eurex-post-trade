# position-keeping

Real-time position keeping and intraday risk for a clearing house, including tokenized collateral and operational resilience under DORA.

**Status:** PRD drafted · **Target:** December 2026

## Scope

- **Streaming core:** Pub/Sub → Dataflow (Java, Apache Beam) → Spanner as the authoritative position book, analytics in BigQuery.
- **Clearing view:** CCP as central counterparty, fictitious clearing members and client accounts, margin calls, daily cash settlement of variation margin.
- **Risk and margin:** intraday risk for futures and options, scenario-based margin, offsets between futures and options, option expiry.
- **Tokenized collateral:** tokenized securities posted as margin collateral, with fast top-ups when margin runs short.
- **Replay and reproducibility:** full replay of a stress day without lost or duplicated events, exact reconstruction of any historical position, end-of-day reconciliation against an independent batch run, cost per trading day.
- **DORA:** multi-zone operation in Frankfurt, zone failure injected during replay, automated incident classification with a draft report, documented exit strategy.
- **Positions API:** Go service on Cloud Run, implementing the contract from `data-foundation`.
- **Latency benchmark:** market data fan-out in the cloud measured with compact placement, with results and limits documented.

## Success criteria

- Positions and risk are current within seconds of a trade, also under load peaks.
- A stress day replays completely, with no lost or double-counted events.
- Every historical position state is exactly reproducible.
- End-of-day positions match an independent batch calculation.
- Cost per trading day is transparent.

## Documents

- PRD: to follow in [`../docs/prd/`](../docs/prd/)
- Hand-off guide: to follow
