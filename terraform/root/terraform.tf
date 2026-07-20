provider "aws" {
  region = local.aws_region
}

terraform {
  required_version = ">=1.8.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.55.0"
    }
  }

  # state の保存先は利用者ごとに異なるため、backend の設定は空にしている。
  # `terraform init -backend-config="bucket=<your-bucket>" -backend-config="key=<your-key>" -backend-config="region=<your-region>"`
  # のように -backend-config で指定するか、backend.hcl 等を用意して init 時に渡すこと。
  #
  # The backend configuration is left empty because the state storage location differs per user.
  # Pass it via -backend-config, e.g.
  # `terraform init -backend-config="bucket=<your-bucket>" -backend-config="key=<your-key>" -backend-config="region=<your-region>"`,
  # or prepare a backend.hcl file and pass it to `terraform init`.
  backend "s3" {}
}
