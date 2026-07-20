locals {
  merged_targets = concat(local.assignment_target_users, local.assignment_target_groups)

  # assignments_targets の各要素に対して展開処理
  #  {
  #    file_name = "PowerUserAccess_USER.txt"
  #    permission_set_arn = "arn:aws:sso:::permissionSet/..."
  #    principal_type     = "USER"
  #  }
  # のような構造を作る
  flatten_targets = flatten([
    for account in local.assignment_target_aws_accounts : [
      for t in local.merged_targets : {
        file_path          = "${local.assignment_file_path}/${account}/${t.file_name}"
        file_name          = t.file_name
        account            = account
        permission_set_arn = t.permission_set_arn
        principal_type     = t.principal_type
      }
    ]
  ])

  assignment_targets_expanded = [
    for t in local.flatten_targets : {
      file_name           = t.file_name
      account             = t.account
      resourcename_prefix = trimsuffix(t.file_name, ".txt")
      permission_set_arn  = t.permission_set_arn
      principal_type      = t.principal_type

      # TXTファイルが存在すれば読み込み、なければ空リスト
      # 空文字列""の場合はリストから外す
      user_names = [
        for name in(fileexists(t.file_path) ? split("\n", trimspace(file(t.file_path))) : []) :
        name
        if name != ""
      ]
    }
  ]
}


########################################
# assignment_targets_expanded をフラットに合体
########################################
#  例: {
#    "PowerUserAccess_USER.txt-alice" = { user_id="xxx", permission_set_arn="yyy", principal_type="USER" }
#    "PowerUserAccess_USER.txt-bob"   = { user_id="xxx", permission_set_arn="yyy", principal_type="USER" }
#    "AdministratorAccess_USER.txt-charlie" = { ... }
#  }
locals {
  combined_assignment_users = merge([
    # assignment_targets_expanded の各要素 t に対して...
    for t in local.assignment_targets_expanded : {
      # さらに t.user_names の各 user_name に対して...
      for user_name in t.user_names :
      # キーを "<awsaccount_id>_<file_name>_<user_name>"、値をオブジェクトにする
      "${t.account}_${t.resourcename_prefix}_${user_name}" => {
        user_name          = user_name
        account            = t.account
        permission_set_arn = t.permission_set_arn
        principal_type     = t.principal_type
      }
    }
  ]...)
}

########################################
# for_each で一括作成
########################################
#  combined_assignments には「(ファイル名)-(ユーザー名)」がキーになっている
resource "aws_ssoadmin_account_assignment" "this" {
  for_each = local.combined_assignment_users

  instance_arn   = local.instance_arn
  target_id      = each.value.account
  target_type    = "AWS_ACCOUNT"
  principal_id   = each.value.principal_type == "USER" ? aws_identitystore_user.this[each.value.user_name].user_id : aws_identitystore_group.this[each.value.user_name].group_id
  principal_type = each.value.principal_type

  permission_set_arn = each.value.permission_set_arn
}
