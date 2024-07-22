terraform {
  backend "s3" {
    bucket         = "terraform-state-full"       # Replace with your S3 bucket name
    key            = "terraform-Rds/state.tfstate"  # Path to the state file within the bucket
    region         = "us-west-2"                # Replace with your AWS region
    dynamodb_table = "terraform-locks"          # Replace with your DynamoDB table name
    encrypt        = true                       # Enable state file encryption
 }
}