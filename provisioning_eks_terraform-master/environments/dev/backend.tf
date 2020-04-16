# This assumes that the state/main.tf has been created in order to provision the required
# resources on AWS (S3 Bucket and DynamoDB table)
terraform {
    backend "s3" {
        encrypt         = true
        bucket          = "terraform-state-dinner-devops-eks"
        key             = "dev"
        dynamodb_table  = "terraform-lock-dev"
        
        # Not ideal - we can't use vars when initialising the backend
        region          = "eu-west-2"
        profile         = "terraform"
  }
}