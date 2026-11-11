# ADR 0003: Cloud Foundation Fabric FAST landing zone and component layout

**Status:** accepted · **Date:** 2026-11-11 · **Refines:** [ADR 0001](0001-one-repository-for-all-components.md)

## Context

The initial repository layout placed a single Terraform root (`00_platform/terraform`) alongside numbered domain folders (`01_data-foundation` through `05_low-latency`). In a regulated financial market infrastructure (DORA, least privilege, customer-managed encryption, VPC Service Controls), organization setup, perimeter security, centralized KMS/HSM keys, shared networking and project creation follow **horizontal** security boundaries rather than vertical application boundaries, and cannot share one monolithic Terraform state or service account.

## Decision

Adopt [Google Cloud Foundation Fabric FAST (`v60.0.0`)](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/v60.0.0/fast) for the horizontal landing zone while keeping all vertical business components and shared schemas in this monorepo:

1. **`fast/stages/` (Stages 0–2, horizontal landing zone):**
   - `0-org-setup`: organization IAM, `europe-west3` location & baseline org policies, centralized audit log sinks, state buckets, Workload Identity Federation for GitHub Actions, and folder hierarchy (`networking`, `security`, `components/prod`, extensible to `dev`).
   - `1-vpcsc`: VPC Service Controls perimeter protecting regulated data and AI services.
   - `2-security`: centralized Cloud KMS CMEK keys, Cloud HSM custody keys (`secp256k1`), and Private CA for mTLS ([ADR 0002](0002-eu-region-and-customer-managed-keys.md)).
   - `2-networking`: Shared VPC for standard components plus a dedicated jumbo-frame Low-Latency Shared VPC for the hot path.
   - `2-project-factory`: YAML-based provisioning of one GCP project per component under `projects/prod/` (extensible to `projects/dev/`), automatically generating per-component read/write and read-only Terraform service accounts, isolated GCS state folders, `*-providers.tf` and `*.auto.tfvars.json` contracts.
2. **`contracts/` (shared cross-component schemas):** OpenAPI, Protobuf and SBE definitions consumed across components without cross-importing service code.
3. **`components/<domain>/` (vertical business components):** unnumbered domain folders (`data-foundation`, `position-keeping`, `tokenized-bond`, `market-surveillance`, `low-latency`), each containing:
   - `_infra/`: Stage-3 Terraform root module with its own isolated state file, consuming the project contract from `2-project-factory` (with `data-foundation/_infra` deployed first and exporting shared topic/dataset IDs to downstream components).
   - Dedicated subdirectories per deployable application / language toolchain root (`Cargo.toml`, `pom.xml`, `go.mod`, `pyproject.toml`, `foundry.toml`).
4. **Module sourcing:** upstream Cloud Foundation Fabric modules are referenced by pinned Git tag (`?ref=v60.0.0&depth=1`) rather than vendored into the repository.

## Consequences

- Blast radius and IAM permissions are strictly isolated across **10 separate Terraform state files** (5 FAST stages + 5 component `_infra` roots in `prod`).
- Adding a `dev` environment later requires only adding `dev` YAML files to the FAST datasets without restructuring code or Terraform modules.
- Each component in `components/<domain>/` remains self-contained for team hand-off (`_infra/` + application services + README).
