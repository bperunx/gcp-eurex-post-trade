# ADR 0002: EU region and customer-managed keys by default

**Status:** accepted · **Date:** 2026-11-07

## Context

Market infrastructures in the EU expect data to stay in the EU, keys to stay under their control, and outsourcing to cloud providers to meet DORA and supervisory requirements.

## Decision

- All resources run in `europe-west3` (Frankfurt), enforced by an organization policy on resource locations.
- Data at rest is encrypted with customer-managed encryption keys (CMEK) in Cloud KMS; key material for the tokenized bond custody uses Cloud HSM.
- Data in transit uses TLS, and service-to-service traffic uses mTLS.

## Consequences

- Security is part of the first component, not a later hardening step.
- Some managed services or features may be unavailable or more expensive in a single EU region; this is documented per component.
- Key rotation and access to keys are auditable through Cloud Audit Logs.
