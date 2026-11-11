# FAST Landing Zone (`fast/`)

Horizontal Google Cloud landing zone built on [Cloud Foundation Fabric FAST (`v60.0.0`)](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/v60.0.0/fast), tailored for `organizations/149750641473` (`info-org`) and region `europe-west3` (Frankfurt).

## Stages and Deployment Order

| Stage | Path | Responsibility | State Location |
| :--- | :--- | :--- | :--- |
| **0** | [`stages/0-org-setup`](stages/0-org-setup/) | Organization IAM, `europe-west3` location & security Org Policies, Audit Logs (`log-0`), Terraform state buckets & GitHub WIF (`iac-0`), folder hierarchy (`networking`, `security`, `components/prod`) | Dedicated bucket `iac-org-state` |
| **1** | [`stages/1-vpcsc`](stages/1-vpcsc/) | VPC Service Controls perimeter (starts in `spec` dry-run mode) around BigQuery, Bigtable, Spanner, Pub/Sub, KMS, Vertex AI | `iac-stage-state` (`1-vpcsc/`) |
| **2** | [`stages/2-security`](stages/2-security/) | Centralized Cloud KMS CMEK keyring (`prod-ew3-cmek`), Cloud HSM keyring (`prod-ew3-hsm` for `tokenized-bond` `secp256k1` custody), Private CA (`prod-ew3-ca-0` for mTLS) | `iac-stage-state` (`2-security/`) |
| **2** | [`stages/2-networking`](stages/2-networking/) | Shared VPC (`prod-shared-0`) with per-domain subnets, plus dedicated jumbo-frame Low-Latency Shared VPC (`prod-ull-0` with Feed-A, Feed-B, Core subnets) and Restricted Google Access DNS | `iac-stage-state` (`2-networking/`) |
| **2** | [`stages/2-project-factory`](stages/2-project-factory/) | Declarative YAML provisioning for all 5 FMI projects under `components/prod`, Shared VPC attachment, CMEK grants, and isolated per-component Stage-3 Terraform SAs + state folders | `iac-stage-state` (`2-project-factory/`) |

All stages default to their tailored `datasets/fmi/` directory and consume upstream CFF modules pinned to `?ref=v60.0.0`.

## Initial Bootstrap Checklist (Stage 0)

> **Windows note:** Enable Git long paths once before running `terraform init`:
> `git config --global core.longpaths true`

1. **Authenticate `gcloud` and Application Default Credentials:**
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```
2. **Grant initial bootstrap roles to `user:info@perunx.io` on `organizations/149750641473`:**
   ```bash
   for role in \
     roles/billing.admin \
     roles/logging.admin \
     roles/iam.organizationRoleAdmin \
     roles/orgpolicy.policyAdmin \
     roles/resourcemanager.folderAdmin \
     roles/resourcemanager.organizationAdmin \
     roles/resourcemanager.projectCreator \
     roles/resourcemanager.tagAdmin \
     roles/owner; do
     gcloud organizations add-iam-policy-binding 149750641473 \
       --member="user:info@perunx.io" --role="$role" --condition=None
   done
   ```
3. **Import the 6 pre-existing default org policies on first apply:**
   Copy [`stages/0-org-setup/example.tfvars`](stages/0-org-setup/example.tfvars) to `stages/0-org-setup/0-org-setup.auto.tfvars`, run `terraform init && terraform apply`, then link the generated backend/provider from `~/fast-config/fmi-eurex/providers/0-org-setup-providers.tf`, remove `0-org-setup.auto.tfvars`, and run `terraform init -migrate-state`.
4. **Apply downstream stages (`1-vpcsc` → `2-security` & `2-networking` → `2-project-factory`):**
   Use [`stages/fast-links.sh`](stages/fast-links.sh) against `~/fast-config/fmi-eurex` in each stage directory, then `terraform init && terraform apply`.

## Extending to `dev` Later

The hierarchy is structured for `prod` today and ready for `dev` without refactoring:
1. Add `folders/{networking,security,components}/dev/.config.yaml` in `0-org-setup/datasets/fmi/`.
2. Add `dev-sec-core-0.yaml` + `dev-ew3-cmek.yaml` in `2-security/datasets/fmi/`.
3. Add `net-dev-0.yaml` + `vpcs/dev-shared/` in `2-networking/datasets/fmi/`.
4. Add `projects/dev/dev-<component>-0.yaml` in `2-project-factory/datasets/fmi/`.
