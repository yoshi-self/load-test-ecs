remote_state {
  backend = "s3"
  generate = {
    path = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "terraform-${get_aws_account_id()}"
    key = "load-test-ecs/${path_relative_to_include()}/terraform.tfstate"
    region = "ap-northeast-1"
    encrypt = true
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "ap-northeast-1"
}
EOF
}
