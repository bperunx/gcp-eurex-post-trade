# ADR 0001: One repository for all components

**Status:** accepted · **Date:** 2026-11-07

## Context

The platform has four components (data foundation, position keeping, tokenized bond, market surveillance) plus shared infrastructure. All components consume the same reference data, market data streams and API contracts, and share Terraform, the security baseline and CI.

## Decision

Keep all components in one repository, with one top-level folder per component and a shared `platform/` folder.

## Consequences

- Shared contracts and infrastructure change in one commit, so components cannot drift apart.
- One CI pipeline and one set of engineering standards apply to everything.
- Readers find the whole platform behind one link.
- CI must stay fast as the repository grows: jobs run per component based on changed paths.
