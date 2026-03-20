# Terraform Template Specification

Generate these files in the `terraform/` directory:

**terraform/main.tf:**
- S3 bucket (private, no public access, block all public ACLs)
- S3 bucket policy granting CloudFront OAC read access
- CloudFront Origin Access Control (OAC) — NOT legacy OAI
- CloudFront distribution with:
  - S3 origin using OAC
  - Default root object: index.html
  - Custom error response: 404 → /index.html (200)
  - Viewer protocol policy: redirect-to-https
  - Price class: PriceClass_200
  - Default cache behavior with CachingOptimized managed policy
  - `aliases = [var.domain_name]`
  - viewer_certificate using ACM cert (sni-only, TLSv1.2_2021) — NOT cloudfront_default_certificate
- ACM certificate for `var.domain_name` (provider must be `aws.us_east_1` — CloudFront requirement)
  - validation_method = "DNS"
  - lifecycle: create_before_destroy = true
- ACM certificate validation resource (waits for cert to be issued)
- Route 53 DNS validation record (`for_each` over domain_validation_options)
- Route 53 A alias record → CloudFront distribution
- Route 53 AAAA alias record → CloudFront distribution (IPv6)
- Existing state bucket config (public access block, versioning, SSE) using `provider = aws.us_east_1` and `var.terraform_state_bucket`
- All resources tagged with `Project` and `Environment` variables

**terraform/variables.tf:**
- Variables for: region, project_name, environment (default "production"), domain_name, route53_zone_id, terraform_state_bucket

**terraform/outputs.tf:**
- Outputs for: cloudfront_distribution_id, cloudfront_domain_name, s3_bucket_name, s3_bucket_arn

**terraform/providers.tf:**
- Default AWS provider with region variable and default_tags
- Aliased provider `aws.us_east_1` (region = "us-east-1") with same default_tags — required for ACM + state bucket in us-east-1
- terraform block with required_version >= 1.5 and AWS provider source (~> 5.0)

**terraform/backend.tf:**
- S3 backend block (commented out with instructions to uncomment after creating state bucket)
- Include comments explaining: first run `terraform init` without backend, create the resources, then uncomment backend and run `terraform init -migrate-state`