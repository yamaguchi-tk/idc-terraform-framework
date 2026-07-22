# idc-terraform-framework

[![License](https://img.shields.io/github/license/yamaguchi-tk/idc-terraform-framework)](LICENSE)
[![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.8.4-623CE4)](terraform/root/terraform.tf)

English | [日本語](README.ja.md)

A Terraform framework for managing AWS Identity Center (formerly AWS SSO) users, groups,
and permission assignments in a list-driven configuration, declared through plain text files.

Just add or edit text files, and user creation, group creation, group membership, and
account permission assignments in Identity Center are automatically expanded via
Terraform's `for_each`.

For a working sample with fictional data, see
[idc-terraform-example](https://github.com/yamaguchi-tk/idc-terraform-example).

## Quick Start

Try it locally, no AWS account or credentials required:

```sh
git clone https://github.com/yamaguchi-tk/idc-terraform-framework.git
cd idc-terraform-framework/terraform/root
terraform init -backend=false
terraform validate
```

To manage a real AWS Identity Center, fork this repository and follow
[Prerequisites](#prerequisites) and [Usage](#usage) below.

## Why this exists

AWS Identity Center has a few common ways to manage users, groups, and permission
assignments, each with a different tradeoff:

| Approach | Change history | PR-reviewable diff | HCL knowledge needed for routine changes | Setup effort |
| --- | --- | --- | --- | --- |
| AWS Console (manual) | No | No | No | None |
| Hand-written Terraform `resource` blocks | Yes | Noisy (a full resource block per change) | Yes | Low |
| SCIM auto-provisioning from an IdP | Partial (IdP-side only) | Depends on the IdP | No | Medium |
| This framework (list-driven) | Yes | Minimal (one line per change) | No | Low |

This framework's approach: declare only the "list" — an email address, a group and its
members, or a permission assignment — as a line in a plain text file. Terraform expands
these into `aws_identitystore_user`/`aws_identitystore_group`/`aws_ssoadmin_account_assignment`
resources automatically via `for_each`. The result is that a routine change (adding one
user, adding one group member) is a one-line diff in a `.txt` file, reviewable in a PR by
someone who has never touched Terraform.

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
- `terraform plan`/`apply` must be run with AWS credentials that have `sso:*` and
  `identitystore:*` permissions against the AWS account where the Identity Center instance
  resides (the management account, or the delegated administrator account if delegated
  administration is enabled).

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

Before configuring a backend, you can validate your fork locally:

```sh
cd terraform/root
terraform init -backend=false
terraform validate
terraform fmt -check -recursive
```

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

## Contributing

Bug reports, questions, and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Copyright 2026 yamaguchi-tk

Licensed under the [Apache License 2.0](LICENSE).
