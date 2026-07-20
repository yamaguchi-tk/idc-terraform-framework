variable "aws_region" {
  description = "AWS Identity Center を管理する AWS リージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "identity_store_id" {
  description = "AWS Identity Center の Identity Store ID (d-で始まるID)"
  type        = string
}

data "aws_ssoadmin_instances" "instance" {}

locals {
  instance_arn = tolist(data.aws_ssoadmin_instances.instance.arns)[0]

  assignment_file_path = "../assignment"
  # assignment配下のフォルダ(AWSアカウントID)を列挙
  assignment_target_aws_accounts = distinct([
    for file in fileset(local.assignment_file_path, "*/*.txt") : dirname(file)
  ])

  membership_file_path = "../membership"
}

locals {
  # assignment_targets の定義
  # 利用するPermissionSetを増やす場合は、file_name / permission_set_arn / principal_type（"GROUP" または "USER"）のマッピングを追加する
  assignment_target_groups = [
    {
      file_name          = "AdministratorAccess_GROUP.txt"
      permission_set_arn = aws_ssoadmin_permission_set.AdministratorAccess.arn
      principal_type     = "GROUP"
    },
    {
      file_name          = "PowerUserAccess_GROUP.txt"
      permission_set_arn = aws_ssoadmin_permission_set.PowerUserAccess.arn
      principal_type     = "GROUP"
    },
    {
      file_name          = "ReadOnlyAccess_GROUP.txt"
      permission_set_arn = aws_ssoadmin_permission_set.ReadOnlyAccess.arn
      principal_type     = "GROUP"
    },
  ]

  assignment_target_users = [
    {
      file_name          = "AdministratorAccess_USER.txt"
      permission_set_arn = aws_ssoadmin_permission_set.AdministratorAccess.arn
      principal_type     = "USER"
    },
    {
      file_name          = "PowerUserAccess_USER.txt"
      permission_set_arn = aws_ssoadmin_permission_set.PowerUserAccess.arn
      principal_type     = "USER"
    },
    {
      file_name          = "ReadOnlyAccess_USER.txt"
      permission_set_arn = aws_ssoadmin_permission_set.ReadOnlyAccess.arn
      principal_type     = "USER"
    },
  ]
}
