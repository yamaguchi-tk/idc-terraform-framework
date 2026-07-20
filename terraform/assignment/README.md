# terraform/assignment

English | [日本語](README.ja.md)

Directory for defining permission assignments (PermissionSet Assignments) to AWS accounts.

- `<account_id>/<permission_set>_<USER|GROUP>.txt`
  - `<account_id>`: the target AWS account ID (12 digits) as the directory name
  - `<permission_set>`: the PermissionSet name registered in `assignment_target_groups` /
    `assignment_target_users` in `variables.tf`
  - `<USER|GROUP>`: the file name suffix indicating whether the assignment is for a user
    or a group
  - Each line lists the user name (local part) or group name to assign

Example: `111111111111/AdministratorAccess_GROUP.txt`

```
engineering
```
