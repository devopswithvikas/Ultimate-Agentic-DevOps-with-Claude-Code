---
name: terraform_security_patterns
description: Security findings and good practices observed in this project's Terraform infrastructure — last reviewed 2026-03-28
type: project
---

Reviewed terraform/ directory (main.tf, variables.tf, providers.tf, outputs.tf, backend.tf) on 2026-03-28.

**Why:** Security audit for a static website on S3 + CloudFront with OIDC-based CI/CD.

**How to apply:** Use these observations as baseline when re-auditing or comparing future changes.

## Confirmed Good Practices
- S3 website bucket has all four public access block settings enabled (main.tf lines 17-20)
- OAC (not legacy OAI) used to connect CloudFront to S3 (main.tf lines 88-94)
- S3 bucket policy scoped to specific CloudFront distribution ARN via condition (main.tf lines 114-118)
- CloudFront viewer_protocol_policy = "redirect-to-https" (main.tf line 151)
- TLS minimum_protocol_version = "TLSv1.2_2021" with sni-only (main.tf lines 178-179)
- S3 server-side encryption with AES256 on both website bucket and state bucket (main.tf lines 29, 261)
- S3 versioning enabled on both buckets (main.tf lines 38-40, 249-252)
- Backend state bucket uses encrypt = true (backend.tf line 26)
- Default tags applied via default_tags across both provider blocks (providers.tf lines 15-19, 27-31)
- ACM cert uses DNS validation and create_before_destroy (main.tf lines 50-54)
- Backend uses use_lockfile = true (native S3 locking, no DynamoDB needed) (backend.tf line 25)

## Open Findings (as of 2026-03-28)

### CRITICAL
- None

### HIGH
- Hardcoded Route 53 Zone ID (Z00392091BL2HLJRJWDDN) in variables.tf line 28 — leaks AWS account topology
- Hardcoded state bucket name in variables.tf line 34 and backend.tf line 22 — sensitive infrastructure detail committed to VCS
- DynamoDB terraform_locks resource commented out (main.tf lines 266-280) — note: use_lockfile=true in backend mitigates this for the backend itself, but the resource comment may mislead future engineers; low residual risk

### MEDIUM
- No CloudFront response headers policy — missing security headers: Content-Security-Policy, X-Frame-Options, Strict-Transport-Security (HSTS), X-Content-Type-Options, Referrer-Policy (main.tf lines 134-187, no response_headers_policy_id)
- No CloudFront access logging configured (main.tf lines 134-187)
- No S3 access logging on website bucket or state bucket
- Custom 404->200 error response may mask real errors and complicates debugging (main.tf lines 161-166)
- CloudFront WAF (web_acl_id) not attached — no layer-7 protection (main.tf lines 134-187)
- No geo-restriction configured (main.tf lines 169-173) — not a finding for a public site, but worth documenting

### LOW
- S3 encryption uses SSE-S3 (AES256) not SSE-KMS — no customer-managed key rotation or audit trail (main.tf lines 28-30, 259-263)
- No S3 lifecycle policy for expiring old versions — unbounded storage growth and cost (main.tf lines 35-41, 246-252)
- terraform_state bucket public access block and versioning managed via variables.tf reference instead of a full resource block — the underlying bucket is not fully declarative in this repo (main.tf lines 236-263)
- outputs.tf exposes s3_bucket_arn (line 17) — ARN contains account ID; mark sensitive = true to prevent accidental logging
- No explicit aws_s3_bucket_ownership_controls resource — relies on AWS default (BucketOwnerEnforced), which is correct but not declared
