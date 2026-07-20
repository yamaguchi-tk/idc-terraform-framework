locals {
  # memberships_targets の各要素に対して展開処理
  #  {
  #    file_name = "engineering.txt"
  #    group_id  = "..."
  #  }
  # のような構造を作る
  #
  # Expand each element of memberships_targets into a structure like:
  #  {
  #    file_name = "engineering.txt"
  #    group_id  = "..."
  #  }
  memberships_targets_expanded = [
    for t in local.memberships_targets : {
      file_name           = t.file_name
      resourcename_prefix = trimsuffix(t.file_name, ".txt")
      group_name          = trimsuffix(t.file_name, ".txt")

      file_path = "${local.membership_file_path}/${t.file_name}"

      # TXTファイルが存在すれば読み込み、なければ空リスト
      # 空文字列""の場合はリストから外す
      # Read the .txt file if it exists, otherwise empty list. Empty string "" entries are excluded.
      user_names = [
        for name in(fileexists("${local.membership_file_path}/${t.file_name}") ? split("\n", trimspace(file("${local.membership_file_path}/${t.file_name}"))) : []) :
        name
        if name != ""
      ]
    }
  ]
}

########################
# memberships_targets_expanded をフラットに合体
# Flatten and merge memberships_targets_expanded
########################
#  例: {
#    "engineering-alice" = { group_name="engineering", user_name="alice" }
#    "engineering-bob"   = { group_name="engineering", user_name="bob" }
#  }
#  e.g.: {
#    "engineering-alice" = { group_name="engineering", user_name="alice" }
#    "engineering-bob"   = { group_name="engineering", user_name="bob" }
#  }
locals {
  combined_memberships = merge([
    # memberships_targets_expanded の各要素 t に対して...
    # For each element t in memberships_targets_expanded...
    for t in local.memberships_targets_expanded : {
      # さらに t.user_names の各 user_name について...
      # ...and for each user_name in t.user_names
      for user_name in t.user_names :
      # キーを "<file_name>_<user_name>"、値をオブジェクトにする
      # Build a key of "<file_name>_<user_name>" mapped to the object value
      "${t.resourcename_prefix}_${user_name}" => {
        group_name = t.group_name
        user_name  = user_name
      }
    }
  ]...)
}

########################
# for_each で一括作成
# Create in bulk with for_each
########################
#  combined_memberships には「(ファイル名)_(ユーザー名)」がキーになっている
#  combined_memberships is keyed by "(file_name)_(user_name)"
resource "aws_identitystore_group_membership" "this" {
  for_each = local.combined_memberships

  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.this[each.value.group_name].group_id
  member_id         = aws_identitystore_user.this[each.value.user_name].user_id
}
