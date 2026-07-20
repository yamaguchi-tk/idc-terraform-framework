data "aws_ssoadmin_instances" "instance" {}

locals {
  # AWS Identity Center を管理する AWS リージョン。fork して利用する場合はここを書き換える
  # AWS region where AWS Identity Center is managed. Edit this value when you fork this repository.
  aws_region = "ap-northeast-1"

  instance_arn = tolist(data.aws_ssoadmin_instances.instance.arns)[0]
  # Identity Center Instance に対応する Identity Store ID を data source から自動取得
  # Identity Store ID corresponding to the Identity Center instance, derived automatically from the data source
  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]

  assignment_file_path = "../assignment"
  # assignment配下のフォルダ(AWSアカウントID)を列挙
  # Enumerate the folders (AWS account IDs) under assignment/
  assignment_target_aws_accounts = distinct([
    for file in fileset(local.assignment_file_path, "*/*.txt") : dirname(file)
  ])

  membership_file_path = "../membership"
}

locals {
  # assignment_targets の定義
  # 利用するPermissionSetを増やす場合は、file_name / permission_set_arn / principal_type（"GROUP" または "USER"）のマッピングを追加する
  # Definition of assignment_targets.
  # To add a PermissionSet to use, add a mapping of file_name / permission_set_arn / principal_type ("GROUP" or "USER").
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
