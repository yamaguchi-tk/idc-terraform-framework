# terraform/assignment

AWSアカウントへの権限割当（PermissionSet Assignment）を定義するディレクトリです。

- `<account_id>/<permission_set>_<USER|GROUP>.txt`
  - `<account_id>`: 割当先の AWS アカウントID（12桁）をディレクトリ名にします
  - `<permission_set>`: `variables.tf` の `assignment_target_groups` / `assignment_target_users` に登録した PermissionSet 名
  - `<USER|GROUP>`: ファイル名の末尾で、ユーザーへの割当かグループへの割当かを示します
  - ファイルの中身は、割当対象のユーザー名（ローカルパート）またはグループ名を1行1件で記載します

例: `111111111111/AdministratorAccess_GROUP.txt`

```
engineering
```
