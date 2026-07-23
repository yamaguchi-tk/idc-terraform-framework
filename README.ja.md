# idc-terraform-framework

[![License](https://img.shields.io/github/license/yamaguchi-tk/idc-terraform-framework)](LICENSE)
[![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.8.4-623CE4)](terraform/root/terraform.tf)

[English](README.md) | 日本語

AWS Identity Center (旧 AWS SSO) のユーザー・グループ・権限割当を、テキストファイルで宣言する
list-driven な構成で管理するための Terraform フレームワークです。

テキストファイルを追加・編集するだけで、Identity Center 上のユーザー作成・グループ作成・
グループメンバーシップ・アカウントへの権限割当が Terraform の `for_each` によって自動的に
展開されます。

サンプル（架空データによる動作例）は [idc-terraform-example](https://github.com/yamaguchi-tk/idc-terraform-example)
を参照してください。

## ユースケース

典型的な想定シーンは、外部IdP（Google Workspace、Okta、Entra ID等）からSSOをAWS Identity
Centerに連携済みで、ユーザーはSSO経由でAWSコンソール/CLIに**認証（authentication）**する、
という構成です。本フレームワークはIdentity Center側の**認可（authorization）**、つまり
「どんなグループが存在し、誰が所属し、どのAWSアカウントでどの権限セットが割り当てられるか」
を管理します。これらの決定はプレーンテキストで宣言するため、変更（例:「Aliceを
`platform-team` グループに追加」）は1行の差分となり、Terraformを知らないレビュアーでもPRで
承認でき、git上に変更履歴が残ります。

## Quick Start

AWSアカウントや認証情報なしで、ローカルで試すことができます。

```sh
git clone https://github.com/yamaguchi-tk/idc-terraform-framework.git
cd idc-terraform-framework/terraform/root
terraform init -backend=false
terraform validate
```

実際の AWS Identity Center を管理する場合は、本リポジトリを fork した上で
[前提条件](#前提条件) と [Usage](#usage) を参照してください。

## なぜこの構成なのか

AWS Identity Center のユーザー・グループ・権限割当の管理には、いくつかの一般的な方法があり、
それぞれトレードオフがあります。

| 方法 | 変更履歴 | PRでレビュー可能な差分 | 日常的な変更にHCLの知識が必要か | 導入コスト |
| --- | --- | --- | --- | --- |
| AWSコンソール（手動） | なし | 不可 | 不要 | なし |
| Terraformの `resource` ブロックを手書き | あり | ノイジー（変更のたびにresourceブロック全体） | 必要 | 低い |
| IdPからのSCIM自動プロビジョニング | 一部（IdP側のみ） | IdPに依存 | 不要 | 中程度 |
| 本フレームワーク（list-driven） | あり | 最小限（変更ごとに1行） | 不要 | 低い |

本フレームワークのアプローチは、メールアドレス・グループとそのメンバー・権限割当という「リスト」
だけをプレーンテキストファイルの1行として宣言することです。Terraformがこれを `for_each` で
`aws_identitystore_user` / `aws_identitystore_group` / `aws_ssoadmin_account_assignment` などの
リソースに自動展開します。結果として、日常的な変更（ユーザー1人の追加、グループメンバー1人の
追加）は `.txt` ファイルの1行差分となり、Terraformを触ったことがない人でもPRでレビューできます。

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
- `terraform plan`/`apply` は、Identity Center インスタンスが存在する AWS アカウント
  （管理アカウント、または委任管理者を有効化している場合はその委任管理アカウント）に対して
  `sso:*` / `identitystore:*` 権限を持つ AWS 認証情報で実行してください。

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

backend を設定する前に、fork した内容をローカルで検証できます。

```sh
cd terraform/root
terraform init -backend=false
terraform validate
terraform fmt -check -recursive
```

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

## Contributing

バグ報告・質問・プルリクエストを歓迎します。[CONTRIBUTING.md](CONTRIBUTING.md)（英語）を参照してください。

## License

Copyright 2026 yamaguchi-tk

Licensed under the [Apache License 2.0](LICENSE).
