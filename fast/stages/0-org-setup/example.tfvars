# Copy to 0-org-setup.auto.tfvars ONLY for the very first `terraform apply`
# on organization 149750641473 so pre-existing default org policies are imported
# instead of failing with 409 Conflict. Remove after the first apply succeeds.

org_policies_imports = [
  "compute.restrictProtocolForwardingCreationForTypes",
  "compute.setNewProjectDefaultToZonalDNSOnly",
  "iam.automaticIamGrantsForDefaultServiceAccounts",
  "iam.disableServiceAccountKeyCreation",
  "iam.disableServiceAccountKeyUpload",
  "storage.uniformBucketLevelAccess",
]
