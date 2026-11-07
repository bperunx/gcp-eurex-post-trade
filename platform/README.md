# platform

Shared infrastructure, security baseline and CI/CD templates for all components.

**Status:** scaffolded

## Scope

- **Infrastructure as code:** Terraform, default region `europe-west3` (Frankfurt).
- **Security baseline:** least-privilege IAM, organization policies, VPC Service Controls around the data products, customer-managed encryption keys (Cloud KMS, Cloud EKM / HSM), Assured Workloads for EU data residency, audit logs, Access Transparency, Security Command Center.
- **Encryption:** at rest with CMEK, in transit with TLS and mTLS between services.
- **Delivery:** CI on every push, blue/green deployments through Cloud Deploy and traffic splitting on Cloud Run.

## Layout

```
platform/
└── terraform/     # provider setup and shared variables; resources follow per component
```

## Usage

```bash
cd platform/terraform
terraform init -backend=false
terraform validate
```
