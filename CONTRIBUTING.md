# Contributing

English | [日本語](CONTRIBUTING.ja.md)

Thanks for your interest in contributing to idc-terraform-framework!

## Reporting issues

Use [GitHub Issues](https://github.com/yamaguchi-tk/idc-terraform-framework/issues) for bugs,
questions, or feature requests. Please include your Terraform version and a minimal
reproduction where possible.

## Submitting changes

1. Fork the repository and create a branch from `main`.
2. Make your change.
3. Validate it locally:
   ```sh
   cd terraform/root
   terraform init -backend=false
   terraform validate
   terraform fmt -check -recursive
   ```
4. Open a pull request against `main`. Please describe what changed and why.

## Code style

- Follow the existing `terraform fmt` formatting.
- This project keeps comments and documentation bilingual (Japanese followed by English, or
  vice versa) — see any existing `.tf` file for the convention. New comments should follow
  the same pattern.
- Follow the file-list format documented in `terraform/user/README.md`,
  `terraform/membership/README.md`, and `terraform/assignment/README.md`.
- Keep `README.md`/`README.ja.md` and `docs/architecture.md`/`docs/architecture.ja.md` in
  sync when your change affects usage or structure.

## License

By contributing, you agree that your contributions will be licensed under the
[Apache License 2.0](LICENSE).
