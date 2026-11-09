# low-latency

A low-latency in-memory hot path for an exchange or clearing house on Google Cloud, with a published latency benchmark and an honest account of where the cloud ends and co-location begins.

**Status:** planned · **Target:** January 2027

## Scope

- **Feed handler:** receives replayed Eurex market data over UDP, decodes the binary messages without copying, and arbitrates between an A and a B feed.
- **In-memory risk service:** event-sourced service in Rust with a single-writer loop and strict first-in-first-out processing. It keeps position and margin state in memory and answers pre-trade risk checks without a database round trip.
- **Order gateway:** accepts orders in a binary encoding (SBE), runs the risk check and returns accept or reject.
- **Journal and hand-over:** every event is journaled and published to Pub/Sub. `02_position-keeping` builds the authoritative position book in Spanner from the same events, asynchronously.
- **Resilience:** a replicated variant across three zones, to show the latency price of zero message loss.
- **Latency benchmark:** the benchmark ladder from the [low-latency playbook](../docs/low-latency-playbook.md), one run per step: baseline, compact placement and core pinning, kernel bypass, bare metal, three zones.
- **Cloud and co-location boundary:** a design note on what belongs in the cloud (risk, post-trade, data, digital assets) and what stays in co-location (order matching of latency-critical markets), with Google's Ultra Low Latency Solution as the reference.

## Success criteria

Targets, to be confirmed or corrected by measurement:

- A pre-trade risk check takes less than 100 microseconds at p99 inside the service, network excluded.
- Round trip between two instances in one zone is published as p50, p99 and p99.9 for every step of the ladder.
- Latency stays stable when the stress day is replayed at 10x and 100x speed.
- No event is lost or reordered when one node or one zone fails in the replicated variant.
- In-memory state and the Spanner position book agree at end of day.

## Out of scope

No matching engine and no trading strategy. The component shows the infrastructure side of latency-sensitive trading, not how to trade.

## Documents

- [Low-latency playbook](../docs/low-latency-playbook.md)
- PRD: to follow in [`../docs/prd/`](../docs/prd/)
- Hand-off guide: to follow
