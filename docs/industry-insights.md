# Industry insights: how real FMIs build

Every component in this repository should trace back to a real, publicly documented pattern, so the demos look like what exchanges, CCPs and CSDs actually run, not like a textbook stack. This page collects those patterns and what they mean for our design. Check it before any new architecture decision.

*As of November 2026.*

## Key finding

The hot path of an exchange contains **no database**. Matching and risk run in memory, event-sourced, with strict first-in-first-out processing. Databases hold the authoritative state and distribute data; they are never in the critical latency path.

## What runs in practice, and what it means for us

| Building block | What runs in practice | Consequence for this repository |
| --- | --- | --- |
| Matching / hot path | T7 (Xetra, Eurex) runs on-premises with co-location. Deutsche Börse's new digital-asset trading engine on Google Cloud uses fault-tolerant in-memory services with strict FIFO processing. | Keep position and margin state in memory, event-sourced; no database round trips in the hot path. |
| Position book / ledger | Legacy: Oracle, DB2, mainframe. New builds: PostgreSQL / AlloyDB, or Spanner where availability and scale demand it. Deutsche Bank runs its new online banking platform on Spanner. | Spanner (PostgreSQL dialect) as system of record. State the trade-off against AlloyDB explicitly: RPO 0, multi-zone, external consistency. |
| Analytics and data distribution | D7 has its analytics layer on BigQuery and Analytics Hub; Deutsche Börse and Google build a joint data mesh. | Use BigQuery and Analytics Hub the same way: data products instead of file feeds. |
| Market access | Global external proxy network load balancer (TCP and WebSocket), network endpoint groups, one GKE cluster per market, Cloud Armor. | Same pattern for API and streaming access of clearing members. |
| Latency in the cloud | Single tenancy, one subnet per market, placement policies. | Compact placement in the latency benchmark; document the limits honestly. |
| Operations | Infrastructure as code with CI/CD; an entire exchange can be stood up automatically; Cloud Trace and Cloud Monitoring across all layers. | Whole environment reproducible from the Terraform pipeline; show request lineage with Cloud Trace. |
| Tick history | Banks often use kdb+; history increasingly moves to BigQuery, ClickHouse or Parquet in object storage. | Bigtable for access by instrument and time range, BigQuery for research; mention kdb+ as the industry reference. |
| Multi-cloud | A7 runs on AWS (S3, EKS, RDS); D7 started with Microsoft and Digital Asset before Google became the preferred partner. | Ground the DORA exit strategy in this real multi-vendor pattern. |

## Storage choices in one line each

- **Spanner:** change several things atomically and consistently (positions, accounts, collateral).
- **Bigtable:** fetch data for one key or key range fast, at very high write throughput (ticks by instrument and time). No joins, single-row atomicity only, row key design decides performance.
- **BigQuery:** compute over all the data (research, reporting, surveillance features).
- **AlloyDB / Cloud SQL:** PostgreSQL with full extension support when global scale is not needed; the realistic MVP choice in many firms.

## Guidelines for all components

- Every architecture decision names its public reference (blog post, press release, case study) in the component README or an ADR.
- Draw the on-premises / cloud boundary realistically: latency-critical trading stays in co-location; the cloud carries digital assets, post-trade, data, simulation and risk.
- Justify trade-offs explicitly (for example, why Spanner instead of AlloyDB) rather than only showing the Google answer.
- Before building a new component, check whether Deutsche Börse, CME or a bank has published a comparable project, and follow its pattern.

## Open question

Hot path for `02_position-keeping`: keep position and margin state in Dataflow (Java, stateful processing), or build an in-memory engine (for example Rust on GKE) following the Deutsche Börse pattern, with Spanner as system of record only?

## Sources

- [Trading in the cloud: lessons from Deutsche Börse Group's cloud-native trading engine](https://cloud.google.com/blog/topics/financial-services/lessons-from-deutsche-borse-groups-cloud-native-trading-engine) (Google Cloud blog, January 2025)
- [Deutsche Börse Group and Google Cloud announce strategic partnership](https://www.deutsche-boerse.com/dbg-en/media/news-stories/press-releases/Deutsche-B-rse-Group-and-Google-Cloud-Announce-Strategic-Partnership-to-Accelerate-Innovation-3405724) (February 2023)
- [D7 with BigQuery and Analytics Hub](https://www.thetradenews.com/deutsche-borse-enters-10-year-partnership-with-google-cloud-to-accelerate-innovation/) (The TRADE)
- [D7 DLT: Clearstream launches tokenized securities platform](https://www.deutsche-boerse.com/dbg-en/media/news-stories/press-releases/D7-DLT-Clearstream-Launches-Tokenized-Securities-Platform-4757912)
- [D7 launch with Digital Asset, Microsoft, R3 and VMware](https://www.clearstream.com/clearstream-en/newsroom/211006-2801334) (2021)
- [Deutsche Börse Trading Roadmap 2025](https://deutsche-boerse.com/resource/blob/4680828/3fba7a1c651365c6785d8fe72c90fd7a/data/Trading%20Roadmap%202025.pdf) (T7 Cloud Simulation moving to GCP)
- [A7 analytics platform on AWS](https://www.hso.co.uk/cloud-migration/aws/case-studies/deutsche-boerse-agility)
- [Deutsche Bank scales its online banking platform with Spanner](https://cloud.google.com/blog/products/databases/deutsche-bank-scales-online-banking-platform-with-spanner)
- [Spanner use cases: financial ledger](https://cloud.google.com/spanner)
