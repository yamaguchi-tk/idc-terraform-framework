# アーキテクチャ

[English](architecture.md) | 日本語

## 概要

このリポジトリは AWS Identity Center (旧 AWS SSO) のアクセス権限を Terraform で管理します。
構成は list-driven（テキストファイル駆動）で、ユーザー・グループメンバーシップ・アカウントへの
権限割当をテキストファイルで宣言し、`terraform/root/` のエンジンがそれを Terraform リソースとして
展開します。

## ディレクトリ構成

- `terraform/assignment/`: AWSアカウントIDごとのディレクトリに権限割当リストを配置する。
  ファイルは `<permission_set>_<USER|GROUP>.txt` の形式で、ユーザー名（メールアドレスの`@`より
  前の部分）またはグループ名を列挙する
- `terraform/membership/`: グループメンバーシップのリスト。ファイル名がそのままグループ名になり、
  ファイルの中身はユーザー名（メールアドレスの`@`より前の部分）
- `terraform/user/`: `user.txt` は Identity Store にユーザーを作成するためのメールアドレス一覧
- `terraform/root/`: Terraformの定義と変数を置くルートモジュール（`terraform init/plan/apply`を
  実行する場所）。`terraform.tf`, `assignments.tf`, `users.tf`, `groups.tf`, `memberships.tf`,
  `variables.tf`, `permissionsets.tf` を含む

## 変更時の注意

- メンバーシップや権限割当を追加する前に、必ず `terraform/user/user.txt` にユーザーを追加すること
- メンバーシップ・権限割当のリストは、メールアドレス全体ではなくユーザー名（`@`より前の部分）を使う
- 権限割当ファイルは `terraform/root/variables.tf` の `assignment_target_groups` /
  `assignment_target_users` に登録されている。新しい PermissionSet のファイルを追加する場合は、
  `permissionsets.tf` にリソースを追加した上で `variables.tf` にも `file_name` /
  `permission_set_arn` / `principal_type` のマッピングを追加すること
- メンバーシップファイルのリネームは、グループの削除・再作成と等価な操作になる。
  新しいファイルを作成してから古いファイルを削除する順序で行うこと
- 新しいAWSアカウントの追加は `terraform/assignment/` 配下に新しいディレクトリを作るだけでよい。
  `variables.tf` の `assignment_target_aws_accounts` が `fileset` で自動検出する
- `identity_store_id` は `variables.tf` の `locals` で `data "aws_ssoadmin_instances"` から
  自動導出しており、利用者が手動で指定する必要はない。`aws_region`（デフォルト:
  `ap-northeast-1`）も同ファイルの `locals` に静的な値として定義しているため、変更する場合は
  fork したコードを直接書き換える
- 本リポジトリは意図的に CI/CD 設定（GitHub Actions 等）を含まない。`terraform plan`/`apply` は
  利用者自身のパイプラインに組み込み、変更対象を該当テキストファイルに限定すること
