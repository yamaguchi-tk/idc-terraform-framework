# terraform/membership

[English](README.md) | 日本語

グループとそのメンバーシップを定義するディレクトリです。

- `<groupname>.txt`: ファイル名がグループ名になります。ファイルの中身は、そのグループに所属するユーザー名（`terraform/user/user.txt` のメールアドレスの `@` より前のローカルパート）を1行1件で記載します

例: `engineering.txt`

```
alice
bob
```
