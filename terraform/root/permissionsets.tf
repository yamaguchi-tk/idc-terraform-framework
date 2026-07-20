# 利用するPermissionSetを増やす場合は、下記のパターンに倣って
# aws_ssoadmin_permission_set / aws_ssoadmin_managed_policy_attachment を追加し、
# variables.tf の assignment_target_groups / assignment_target_users にも
# 対応する file_name / permission_set_arn / principal_type（"GROUP" または "USER"）のマッピングを追加すること。

### AdministratorAccess
resource "aws_ssoadmin_permission_set" "AdministratorAccess" {
  name             = "AdministratorAccess"
  instance_arn     = local.instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "AdministratorAccess" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.AdministratorAccess.arn
}

### PowerUserAccess
resource "aws_ssoadmin_permission_set" "PowerUserAccess" {
  name             = "PowerUserAccess"
  instance_arn     = local.instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "PowerUserAccess" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  permission_set_arn = aws_ssoadmin_permission_set.PowerUserAccess.arn
}

### ReadOnlyAccess
resource "aws_ssoadmin_permission_set" "ReadOnlyAccess" {
  name             = "ReadOnlyAccess"
  instance_arn     = local.instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "ReadOnlyAccess" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.ReadOnlyAccess.arn
}
