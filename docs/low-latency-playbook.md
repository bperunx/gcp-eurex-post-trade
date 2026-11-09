# Low-latency playbook

Techniques for latency-sensitive trading workloads on Google Cloud, collected from public benchmarks and reference designs. This page decides what the `02_position-keeping` hot path and its latency benchmark use, and in which order.

*As of November 2026. Figures are quoted from the linked sources, not measured here.*

## What public benchmarks show

| Source | Setup | Result |
| --- | --- | --- |
| 28Stone on C3 | Replay instance and test instance, CME equity futures pcap, decode → decide → build SBE order → send, C++ with kernel bypass, CPU pinning and ring buffers | Round trip about 26 µs at P50 on `c3-standard-176`, about the same at 100x replay speed; in-process 0.3 to 2.5 µs |
| Aeron on C3 | Node-to-node messaging with DPDK, 288-byte messages at 100,000 messages per second | 18 µs at P99; C3 halves P50 and P99 against C2 |
| Aeron Cluster | Raft consensus across nodes or zones | Zero message loss on node failure, at a P99 cost in the tens of microseconds |

The takeaway: single-digit microseconds inside the process and tens of microseconds across the network are reachable on general-purpose cloud machines. Sub-microsecond wire-to-wire remains the domain of co-location and FPGAs.

## Techniques by layer

### Machine and placement

| Technique | Why it helps | In this repository |
| --- | --- | --- |
| C3 or C4 machine types on Titanium | Network and storage work is offloaded from the host CPU | Baseline for every benchmark run |
| Compact placement policy | Instances sit physically close, fewer network hops | Step 1 of the benchmark |
| Large shapes or bare metal (`c3-standard-192-metal`) | Whole host, no noisy neighbours, no hypervisor on bare metal | One comparison run |
| Single tenancy and one subnet per market | Pattern of Deutsche Börse's cloud-native engine | Design note |
| Advanced maintenance controls | Maintenance events are announced and can be moved out of trading hours | Design note under DORA |

### Network

| Technique | Why it helps | In this repository |
| --- | --- | --- |
| gVNIC with Tier_1 networking | Higher bandwidth and the newer virtual NIC | Baseline |
| Kernel bypass with DPDK or AF_XDP | Packets skip the kernel network stack | Step 3 of the benchmark, AF_XDP first because it fits Rust and standard drivers |
| Busy polling instead of interrupts | No wake-up delay on packet arrival | Step 2 |
| UDP with a reliable messaging layer (Aeron) | Low-latency transport with ordering and replay | Evaluated against plain UDP and TCP |
| A and B feeds with arbitration | Redundant delivery, first packet wins | Design note, mirrors the dual ULL networks of U4 |

### Operating system

Standard Linux tuning, not specific to Google Cloud:

| Technique | Why it helps |
| --- | --- |
| Core isolation and CPU pinning (`isolcpus`, `nohz_full`, `rcu_nocbs`) | Hot threads are never descheduled or interrupted by the timer tick |
| IRQ affinity away from hot cores | Interrupts do not land on the hot path |
| Simultaneous multithreading off (`--threads-per-core=1`) | No sibling thread competing for the core |
| C-states limited, performance governor | No wake-up latency; Google's U4 guidance also requires C6 off for full NIC performance |
| Huge pages, memory locked and pre-faulted | No page faults or TLB misses on the hot path |
| NUMA alignment of NIC, memory and thread | No cross-socket memory access |

### Application

| Technique | Why it helps | In this repository |
| --- | --- | --- |
| Single-writer, strict FIFO event loop | Determinism and fairness, no locks | Core of the hot path |
| Lock-free ring buffers between threads | Hand-off without contention | Ingest → risk → publish |
| No allocation on the hot path | No allocator or page-fault jitter | Pre-allocated pools in Rust |
| Binary encoding (SBE) with zero-copy decode | No parsing or copying | Message format of the hot path |
| Busy-spin on dedicated cores | No scheduler wake-ups | Configurable, off by default to save cost |
| Journal plus replication instead of a database | Durability without a database round trip | Event log, Spanner updated asynchronously |
| Replicated state machine (Raft) | Zero loss on node or zone failure | Design note; compared against a single node |

### Measurement

- Report P50, P99 and P99.9 as histograms, never averages.
- Correct for coordinated omission.
- Measure in-process time and round trip separately, as 28Stone does.
- Replay at 1x, 10x and 100x to show behaviour under bursts.
- Accurate clocks: PTP where available, otherwise hardware timestamps on one host.

## Benchmark ladder

Each step is one benchmark run, so the gain of every technique is visible on its own:

1. Baseline: C3, kernel sockets, default placement.
2. Compact placement, Tier_1 networking, pinned and isolated cores, busy polling.
3. Kernel bypass with AF_XDP.
4. Bare metal shape.
5. Replicated across three zones, to show the price of zero loss.

## Where the cloud ends

Google's Ultra Low Latency Solution (U4 machine family) shows what a production exchange needs beyond general-purpose cloud: bare metal instances, dedicated ULL networks in A and B pairs, multicast, PTP time, kernel bypass with Onload or DPDK. It is available only to approved exchange operators and their participants and only in `us-south1`, so this repository cannot use it. It serves as the reference for the cloud and co-location boundary note in `02_position-keeping`.

## Sources

- [Benchmarking C3 machine types for trading firms with 28Stone](https://cloud.google.com/blog/products/compute/benchmarking-c3-machine-types-for-trading-firms-with-28stone)
- [28Stone: Benchmarking high-performance trading on Google Cloud](https://28stone.com/news/28stone-benchmarking-high-performance-trading-on-google-cloud/)
- [Google Cloud optimized infrastructure for digital exchanges](https://cloud.google.com/blog/topics/financial-services/google-cloud-optimized-infrastructure-for-digital-exchanges)
- [Lessons from Deutsche Börse Group's cloud-native trading engine](https://cloud.google.com/blog/topics/financial-services/lessons-from-deutsche-borse-groups-cloud-native-trading-engine/)
- [U4 Ultra Low Latency machine family](https://docs.cloud.google.com/ull-solution/participants/u4-machines)
- [Compact placement policies](https://docs.cloud.google.com/compute/docs/instances/use-compact-placement-policies)
