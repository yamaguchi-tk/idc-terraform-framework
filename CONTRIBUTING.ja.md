# Contributing

[English](CONTRIBUTING.md) | 日本語

idc-terraform-framework への貢献に興味を持っていただきありがとうございます。

## バグ報告・質問

バグ報告・質問・機能要望は [GitHub Issues](https://github.com/yamaguchi-tk/idc-terraform-framework/issues)
をご利用ください。可能であれば、利用している Terraform のバージョンと最小限の再現手順を
記載してください。

## 変更の提出

1. リポジトリを fork し、`main` からブランチを作成する
2. 変更を加える
3. ローカルで検証する
   ```sh
   cd terraform/root
   terraform init -backend=false
   terraform validate
   terraform fmt -check -recursive
   ```
4. `main` に対してプルリクエストを作成する。変更内容とその理由を記載してください

## コードスタイル

- 既存の `terraform fmt` によるフォーマットに従ってください
- 本プロジェクトはコメント・ドキュメントを日英併記としています（既存の `.tf` ファイルを
  参照してください）。新規コメントも同様の形式にしてください
- `terraform/user/README.md`、`terraform/membership/README.md`、
  `terraform/assignment/README.md` に記載のファイル形式に従ってください
- 利用方法や構成に影響する変更を行った場合は、`README.md`/`README.ja.md` および
  `docs/architecture.md`/`docs/architecture.ja.md` の内容も合わせて更新してください

## ライセンス

貢献していただいた内容は [Apache License 2.0](LICENSE) の下でライセンスされることに
同意したものとみなされます。
