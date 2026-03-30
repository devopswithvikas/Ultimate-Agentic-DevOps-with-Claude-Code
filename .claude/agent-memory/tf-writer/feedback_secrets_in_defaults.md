---
name: No secrets or IDs in variable defaults
description: Route 53 zone IDs, bucket names, and other environment-specific identifiers must not appear as default values in variables.tf — use partial backend config and tfvars.example instead
type: feedback
---

Never place real AWS resource IDs (Route 53 zone IDs, bucket names, account IDs, etc.) as `default` values in `variables.tf`. These end up committed to version control.

**Why:** These values are environment-specific and sensitive enough to expose infrastructure topology. The project was remediated after hardcoded IDs for `route53_zone_id` and `terraform_state_bucket` were found in defaults.

**How to apply:**
- Variables that require environment-specific values should have no `default` at all, forcing explicit supply.
- Backend config must use a partial config (`backend "s3" {}`) so bucket/key/region are supplied via a gitignored `backend.hcl` file at `terraform init` time.
- Commit only `backend.hcl.example` and `terraform.tfvars.example` as safe templates with placeholder strings like `"YOUR_STATE_BUCKET_NAME"`.
