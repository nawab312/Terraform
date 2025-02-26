provider "aws" {
  region = "us-west-2"
  assume_role {
    role_arn = "arn:aws:iam::123456789012:role/my-cross-account-role"
    session_name = "TerraformSession"
  }
}
