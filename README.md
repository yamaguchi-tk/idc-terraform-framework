# idc-terraform-framework

English | [日本語](README.ja.md)

A Terraform framework for managing AWS Identity Center (formerly AWS SSO) users, groups,
and permission assignments in a list-driven configuration, declared through plain text files.

Just add or edit text files, and user creation, group creation, group membership, and
account permission assignments in Identity Center are automatically expanded via
Terraform's `for_each`.

For a working sample with fictional data, see
[idc-terraform-example](https://github.com/yamaguchi-tk/idc-terraform-example).

## Prerequisites

This repository manages only the Identity Store (users and groups) and permission
assignments of AWS Identity Center. It assumes an external Identity Provider (IdP) is
already set up separately, and that users authenticate via SSO federated from that IdP.
Setting up the IdP itself or its federation with Identity Center (e.g. SAML/SCIM
configuration) is out of scope for this repository.

- AWS IAM Identity Center itself must already be enabled for your organization. This
  repository does not enable it.
- This framework provisions Identity Store users directly via Terraform
  (`aws_identitystore_user`). Do not enable automatic (SCIM) provisioning from your IdP
  into Identity Center — SCIM auto-provisioning and Terraform-managed users conflict and
  can cause `terraform apply` to fail. Manage users manually via this framework instead.

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

This framework is designed to be forked and edited directly, rather than configured
through variables at every run. `identity_store_id` is derived automatically at plan time
from `data "aws_ssoadmin_instances"`, so no manual input is needed. `aws_region` is a plain
`locals` value (default: `ap-northeast-1`) in `terraform/root/variables.tf` — edit it
directly in your fork if you use a different region.

1. `backend "s3" {}` in `terraform/root/terraform.tf` is left empty, so specify it for your
   environment, e.g.
   `terraform init -backend-config="bucket=<your-bucket>" -backend-config="key=<your-key>" -backend-config="region=<your-region>"`
2. Add user email addresses to `terraform/user/user.txt`
3. Add a group and its members to `terraform/membership/<groupname>.txt`
4. Add a permission assignment to `terraform/assignment/<account_id>/<permission_set>_<USER|GROUP>.txt`
5. `permissionsets.tf` only includes example definitions for AWS managed policies
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
