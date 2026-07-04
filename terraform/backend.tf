#terraform {
#  backend "s3" {
#    bucket         = "sakshi-victoriametrics-tfstate-bucket"
#    key            = "prod/victoria-metrics/terraform.tfstate"
#    region         = "ap-south-1"
#    dynamodb_table = "sakshi-victoriametrics-tfstate-locks"
#    encrypt        = true
#  }
#}

# This resource is used by the Terraform backend for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "victoriametrics-tfstate-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "VictoriaMetrics Terraform State Locks Table"
    Environment = var.environment
  }
}