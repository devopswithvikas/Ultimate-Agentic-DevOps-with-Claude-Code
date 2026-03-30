---
name: Infrastructure Cost Optimization Review
description: Comprehensive analysis of AWS Terraform resources with estimated cost savings
type: project
---

## Infrastructure Overview
- **Project**: Static portfolio website (HTML/CSS only)
- **Region**: us-east-2 (primary), us-east-1 (ACM, Route53)
- **Architecture**: S3 + CloudFront + Route53 + ACM
- **Deployment**: Terraform-managed with S3 remote backend

## Cost Optimization Findings (2026-03-24)

### Priority 1: CloudFront Price Class (HIGH - $30-50/month savings)
- **Current**: PriceClass_200 (200+ edge locations)
- **Recommended**: PriceClass_100 (100 edge locations, most cost-efficient)
- **Rationale**: Portfolio site doesn't require ultra-edge coverage; PriceClass_100 covers primary traffic regions (North America, Europe, Asia Pacific)
- **Action**: Change main.tf line 138 `price_class = "PriceClass_100"`

### Priority 2: S3 Website Versioning (MEDIUM - $5-15/month savings)
- **Current**: Versioning enabled on website bucket
- **Recommended**: Suspend versioning (set status to "Suspended")
- **Rationale**: CI/CD overwrites files completely; no need for version history. Versioning stores all historical versions, charging storage for each.
- **Action**: Change main.tf line 39 `status = "Suspended"` or disable entirely

### Priority 3: S3 Terraform State Lifecycle (MEDIUM - $5-10/month savings)
- **Current**: Unlimited state file versions in Standard storage
- **Recommended**: Add lifecycle rule to expire non-current versions after 30 days, transition to Intelligent-Tiering
- **Rationale**: Old state versions are rarely used; Intelligent-Tiering auto-optimizes storage class
- **Action**: Add lifecycle policy to Terraform state bucket configuration

### Priority 4: Route53 Hosted Zone (LOW - $0.50/month)
- **Current**: $0.50/month for Route53 hosted zone
- **Recommended**: Keep as-is for Terraform integration (trade-off worth it)
- **Action**: No action required

### Verified As Cost-Optimized
- ✅ ACM Certificate (free)
- ✅ CloudFront CachingOptimized policy (appropriate TTL)
- ✅ S3 Encryption using AES256 (no premium cost)
- ✅ CloudFront compression enabled (reduces data transfer)
- ✅ No cross-region replication
- ✅ DynamoDB state locking commented out (avoids unnecessary $1.25/month)

## Total Estimated Savings
- Monthly: $40-75
- Annual: $480-900

## Configuration Details
- Domain: cloudempowered.online
- State bucket: terraform-state-files-0110 (us-east-1)
- Website bucket: cloudempowered.online (us-east-2)
- Environment: production
