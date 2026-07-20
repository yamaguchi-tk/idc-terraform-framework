# Architecture

English | [日本語](architecture.ja.md)

## Overview

This repository manages AWS Identity Center (formerly AWS SSO) access permissions with
Terraform. The configuration is list-driven (text-file driven): users, group memberships,
and account permission assignments are declared in text files, and the engine in
`terraform/root/` expands them into Terraform resources.

## Directory layout

- `terraform/assignment/`: places permission assignment lists in a directory per AWS
  account ID. Files follow the `<permission_set>_<USER|GROUP>.txt` format and list user
  names (the local part before `@` of an email address) or group names
- `terraform/membership/`: group membership lists. The file name itself becomes the group
  name, and the file content is user names (the local part before `@`)
- `terraform/user/`: `user.txt` is the list of email addresses used to create users in the
  Identity Store
- `terraform/root/`: the root module holding the Terraform definitions and variables
  (where `terraform init/plan/apply` is run). Includes `terraform.tf`, `assignments.tf`,
  `users.tf`, `groups.tf`, `memberships.tf`, `variables.tf`, and `permissionsets.tf`

## Notes when making changes

- Before adding a membership or an assignment, always add the user to
  `terraform/user/user.txt` first
- Membership and assignment lists use user names (the part before `@`), not full email
  addresses
- Assignment files are registered in `assignment_target_groups` /
  `assignment_target_users` in `terraform/root/variables.tf`. When adding a file for a new
  PermissionSet, add the resource in `permissionsets.tf` and also add the corresponding
  `file_name` / `permission_set_arn` / `principal_type` mapping in `variables.tf`
- Renaming a membership file is equivalent to deleting and re-creating the group. Create
  the new file before deleting the old one
- Adding a new AWS account only requires creating a new directory under
  `terraform/assignment/`. `assignment_target_aws_accounts` in `variables.tf`
  auto-discovers it via `fileset`
- `identity_store_id` is derived automatically as a `locals` value in `variables.tf` from
  `data "aws_ssoadmin_instances"`, so no manual input is required. `aws_region` (default:
  `ap-northeast-1`) is also defined as a static `locals` value in the same file — edit your
  fork directly if you need to change it
- This repository intentionally does not include CI/CD configuration (e.g. GitHub
  Actions). Incorporate `terraform plan`/`apply` into your own pipeline, and scope changes
  to the relevant text files
