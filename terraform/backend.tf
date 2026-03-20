# ---------------------------------------------------------------------------
# REMOTE STATE BACKEND — UNCOMMENT AFTER BOOTSTRAPPING
# ---------------------------------------------------------------------------
# HOW TO USE:
#
# Step 1: Keep this block commented out and run:
#           terraform init
#           terraform apply
#         This creates the S3 bucket and DynamoDB table used for state storage.
#
# Step 2: Once those resources exist, uncomment the terraform block below
#         and run:
#           terraform init -migrate-state
#         Terraform will migrate the local state file into the S3 backend.
#
# Step 3: Commit backend.tf (with the block uncommented) to version control.
#         All future runs will use the remote backend automatically.
# ---------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket       = "terraform-state-files-0110"
    key          = "claude-static-website/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
