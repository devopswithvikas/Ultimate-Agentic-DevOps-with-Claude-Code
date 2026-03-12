# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Static HTML/CSS portfolio website. Single-page site with all sections: About, Services, Courses, Books, Community, and Contact. Will be deployed to AWS using the S3 and Cloudfront, provisioned with Terraform and CI/CD using the Github Actions. 

## Development

There is no build process, package manager, or test suite. To preview locally, serve the files with any static file server:

```bash
# Python (simplest option)
python3 -m http.server 8080

# Nginx (production deployment target)
sudo cp -r . /var/www/html/
sudo systemctl restart nginx
```

## Architecture

### Application (Static Site)
- **index.html**: Single-page portfolio including Sections for About, Services, Courses, Books, Community, and Contact.

- **style.css**: Mobile-first responsive design (~1145 lines) with breakpoints at 900px, 768px, and 600px.

- **privacy.html / terms.html**: Standalone legal pages using inline styles for minimal dependencies.

- **images/**: Directory for static assets (logo, profile, course thumbnails, hero background).

- **Tech Stack**: Pure HTML5 + CSS3, No JavaScript, no build steps—optimized for speed and simplicity.

### Infrastructure ('terraform/')
The infrastructure is fully automated to ensure consistency and eliminate manual configuration.

- **Storage**: AWS S3 bucket configured for private access.

- **Security**: Origin Access Control (OAC) ensures the S3 bucket is only accessible via CloudFront.

- **Content Delivery**: CloudFront distribution used as a Global CDN with S3 as the origin.

- **State Management**: Terraform state is stored in an S3 backend with DynamoDB for state locking.

- **Governance**: All resources are strictly tagged with 'Project' and 'Environment'.

### CI/CD ('.github/workflows/')
A keyless, automated pipeline for continuous delivery.

- **Trigger**: Automatic execution on every push to the main branch.

- **Authentication**: Uses GitHub OIDC provider and IAM roles to eliminate the need for long-lived AWS Access Keys.

- **Deployment**:

Syncs updated site files to S3.

Invalidates the CloudFront cache to ensure immediate global updates.

### MCP Servers ('.mcp.json')
Two MCP servers are configured for Claude Code:

- **aws** ('awslabs/aws-api-mcp-server'): Direct AWS API access for querying and managing resources.

- **terraform** (hashicorp/terraform-mcp-server): Terraform operations via Docker, workspace mounted at /workspace.

- **Secrets Management**: AWS credentials and region are configured in '.claude/settings.local.json' (gitignored), not in '.mcp.json'. This keeps secrets out of version control and provides a single source of truth for all tools.

### Custom Agents ('.claude/agents/')
This project has 4 specialized subagents. Use them by name when delegating tasks:

- **tf-writer**: Generates Terraform code (has Write access + project memory)

- **security-auditor**: Audits TF for security issues (Read-only, Sonnet)

- **cost-optimizer**: Reviews infra cost (Read-only, Haiku)

- **drift-detector**: Detects state drift (Bash, Haiku)

## Skills ('.claude/skills/')
- **Task Delegation**: All infrastructure and deployment tasks are handled via skills. Do not write Terraform or CI/CD code manually — use the appropriate skill.

- **Action Skills**: Configured with 'disable-model-invocation: true' (manual only).

- **Project Scope Skill**: Configured with 'user-invocable: false' (auto-loaded by Claude as background knowledge).

```
/scaffold-terraform [region] [name] – Generate all Terraform files (uses tf-writer agent)

/scaffold-cicd [aws-account-id] – Generate GitHub Actions + OIDC IAM role

/tf-plan – Run terraform plan + risk analysis

/tf-apply – Run terraform apply + verify

/deploy – Sync S3 + invalidate CloudFront

/infra-status – Health dashboard of all resources

/infra-audit – Parallel security + cost + drift audit (forked context)

/setup-gh-actions [create|validate] – Create or validate CI workflow

/tf-destroy – Safe destroy with confirmation

project-scope – Background knowledge: AWS service constraints (auto-loaded, user-invocable: false)

/commit – Auto-generate commit message (built-in)

/compact – Compress long conversation context (built-in)
```

## Safety Layers
1. **UserPromptSubmit hook** – catches destructive intent ("delete all", "nuke", "wipe") before Claude starts.

2. **PreToolUse hook** – blocks dangerous commands (terraform destroy, aws s3 rm) at execution time.

3. **Permissions** – auto-allows safe reads, blocks IAM and rm -rf.

4. **PostToolUse hook** – logs all terraform apply executions to '.claude/deploy.log'.

## DMI Deployment Requirement

Students must add ownership proof to the footer before submission. The format is:

```
Deployed by: DMI Cohort 2 | [Name] | Group [N] | Week 1 | [Date]
```

This line goes in the footer section of `index.html`.

## Key Conventions

- **No JavaScript**: Keep the site pure HTML/CSS. Do not introduce any JS, even for minor interactions.
- **Images**: Place all static assets in the `images/` directory. Optimize before adding to keep total size reasonable.
- **CSS styling**: CSS uses mobile first approach. Breakpoints at 900px, 768px, and 600px.
- **Terraform files**: Uses 'terraform/' directory with standard layout (main.tf, variables.tf, outputs.tf).
- **GitHub Actions**: Uses OIDC - no stored AWS access keys.
- **All infrastructure changes**: Goes through Terraform - never modify AWS resources manually.
- **Site content changes**: Deploy automatically via GitHub Actions on push to main.

## Standard commands
```bash
# Local preview (Linux users may substitute 'xdg-open')
open index.html

# Manual S3 sync (CI does this automatically)
aws s3 sync . s3://$BUCKET_NAME --exclude "terraform/*" --exclude ".git/*" --exclude ".github/*" --exclude "*.md" --exclude ".claude/*"

# Terraform
cd terraform && terraform init
cd terraform && terraform plan
cd terraform && terraform apply
```
