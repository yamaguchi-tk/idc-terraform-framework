# idc-terraform-framework

[English](README.md) | 日本語

AWS Identity Center (旧 AWS SSO) のユーザー・グループ・権限割当を、テキストファイルで宣言する
list-driven な構成で管理するための Terraform フレームワークです。

テキストファイルを追加・編集するだけで、Identity Center 上のユーザー作成・グループ作成・
グループメンバーシップ・アカウントへの権限割当が Terraform の `for_each` によって自動的に
展開されます。

サンプル（架空データによる動作例）は [idc-terraform-example](https://github.com/yamaguchi-tk/idc-terraform-example)
を参照してください。

## 前提条件

本リポジトリが管理するのは AWS Identity Center の Identity Store（ユーザー・グループ）と
権限割当のみです。外部の Identity Provider (IdP) が別途構築済みであり、その IdP からの SSO で
ユーザー認証を行うことを前提としています。IdP自体の構築や Identity Center との連携設定
（SAML/SCIM 設定等）は本リポジトリのスコープ外です。

- AWS IAM Identity Center 自体が組織で有効化済みであることも前提です。本リポジトリは
  有効化そのものは行いません。
- 本フレームワークは Terraform (`aws_identitystore_user`) で Identity Store のユーザーを
  直接作成します。IdP側からIdentity Centerへの自動プロビジョニング（SCIM）は有効にしないで
  ください。SCIM自動プロビジョニングとTerraform管理のユーザーは競合し、`terraform apply`が
  失敗する原因になります。ユーザー管理は本フレームワーク経由で行ってください。

## Directory layout

詳細は [docs/architecture.md](docs/architecture.md) を参照してください。

```
terraform/
├── user/                # user.txt: Identity Store に作成するユーザーのメールアドレス一覧
├── membership/           # <groupname>.txt: グループとそのメンバー一覧
├── assignment/            # <account_id>/<permission_set>_<USER|GROUP>.txt: 権限割当一覧
└── root/                # 上記テキストファイルを展開するTerraformエンジン
    ├── terraform.tf
    ├── variables.tf
    ├── users.tf
    ├── groups.tf
    ├── memberships.tf
    ├── assignments.tf
    └── permissionsets.tf   # AWS管理ポリシーの定義例（AdministratorAccess等）
```

## Usage

本フレームワークは、実行のたびに変数で指定する方式ではなく、forkしてコードを直接編集する
運用を想定しています。`identity_store_id` は `data "aws_ssoadmin_instances"` から plan 時に
自動導出されるため、手動での入力は不要です。`aws_region` は `terraform/root/variables.tf` の
`locals` に静的な値（デフォルト: `ap-northeast-1`）として定義しているため、別リージョンを
利用する場合は fork したコード上で直接書き換えてください。

1. `terraform/root/terraform.tf` の `backend "s3" {}` は空にしてあるため、
   `terraform init -backend-config="bucket=<your-bucket>" -backend-config="key=<your-key>" -backend-config="region=<your-region>"`
   のように利用者の環境に合わせて指定する
2. `terraform/user/user.txt` にユーザーのメールアドレスを追加する
3. `terraform/membership/<groupname>.txt` にグループとそのメンバーを追加する
4. `terraform/assignment/<account_id>/<permission_set>_<USER|GROUP>.txt` に権限割当を追加する
5. `permissionsets.tf` にはAWS管理ポリシーの定義例（AdministratorAccess / PowerUserAccess /
   ReadOnlyAccess）のみを含めています。他のPermissionSetが必要な場合は同様のパターンで追加し、
   `variables.tf` の `assignment_target_groups` / `assignment_target_users` にも対応する
   `file_name` / `permission_set_arn` / `principal_type`（`"GROUP"` または `"USER"`）のマッピングを追加してください

```sh
cd terraform/root
terraform init -backend-config=...
terraform plan
terraform apply
```

## CI/CD について

本リポジトリは CI/CD 設定（GitHub Actions 等）を含みません。実運用では
`terraform plan`/`apply` をPRベースで自動実行するパイプラインを別途用意することを推奨します。

## License

Copyright 2026 yamaguchi-tk

Licensed under the [Apache License 2.0](LICENSE).
