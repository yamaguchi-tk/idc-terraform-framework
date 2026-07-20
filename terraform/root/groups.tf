########################################
# Groups
########################################
locals {
  # membershipディレクトリのtxtファイル名からグループ名を自動抽出
  groups = [
    for file in fileset(local.membership_file_path, "*.txt") :
    trimsuffix(file, ".txt")
  ]

  group_map = {
    for group in local.groups :
    group => {
      group_name = group
    }
  }

  memberships_targets = [
    for group in local.groups : {
      file_name = "${group}.txt"
    }
  ]
}

resource "aws_identitystore_group" "this" {
  for_each = local.group_map

  display_name      = each.value.group_name
  identity_store_id = var.identity_store_id
}
