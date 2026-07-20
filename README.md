# idc-terraform-framework

English | [日本語](README.ja.md)

A Terraform framework for managing AWS Identity Center (formerly AWS SSO) users, groups,
and permission assignments in a list-driven configuration, declared through plain text files.

Just add or edit text files, and user creation, group creation, group membership, and
account permission assignments in Identity Center are automatically expanded via
Terraform's `for_each`.

For a working sample with fictional data, see
[idc-terraform-example](https://github.com/yamaguchi-tk/idc-terraform-example).

## Directory layout

See [docs/architecture.md](docs/architecture.md) for details.

```
terraform/
├── user/                # user.txt: list of email addresses for users to create in Identity Store
├── membership/           # <groupname>.txt: a group and its members
├── assignment/            # <account_id>/<permission_set>_<USER|GROUP>.txt: permission assignments
└── root/                # the Terraform engine that expands the text files above
    ├── terraform.tf
    ├── variables.tf
    ├── users.tf
    ├── groups.tf
    ├── memberships.tf
    ├── assignments.tf
    └── permissionsets.tf   # example definitions of AWS managed policies (AdministratorAccess, etc.)
```

## Usage

1. Set `identity_store_id` (the Identity Store ID, starting with `d-`) in
   `terraform/root/variables.tf` via `-var` or `terraform.tfvars`
2. `backend "s3" {}` in `terraform/root/terraform.tf` is left empty, so specify it for your
   environment, e.g.
   `terraform init -backend-config="bucket=<your-bucket>" -backend-config="key=<your-key>" -backend-config="region=<your-region>"`
3. Add user email addresses to `terraform/user/user.txt`
4. Add a group and its members to `terraform/membership/<groupname>.txt`
5. Add a permission assignment to `terraform/assignment/<account_id>/<permission_set>_<USER|GROUP>.txt`
6. `permissionsets.tf` only includes example definitions for AWS managed policies
   (AdministratorAccess / PowerUserAccess / ReadOnlyAccess). If you need another
   PermissionSet, add it following the same pattern, and also add the corresponding
   `file_name` / `permission_set_arn` / `principal_type` (`"GROUP"` or `"USER"`) mapping to
   `assignment_target_groups` / `assignment_target_users` in `variables.tf`

```sh
cd terraform/root
terraform init -backend-config=...
terraform plan
terraform apply
```

## About CI/CD

This repository does not include CI/CD configuration (e.g. GitHub Actions). For production
use, we recommend setting up a separate pipeline to run `terraform plan`/`apply` automatically
on a PR basis.

## License

Copyright 2026 yamaguchi-tk

Licensed under the [Apache License 2.0](LICENSE).
