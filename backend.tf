terraform {
  backend "s3" {
    bucket         = "tf-bucket-silicon"
    key            = "my-project/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "lockTable"
  }
}
