# terraform/membership

English | [日本語](README.ja.md)

Directory for defining groups and their memberships.

- `<groupname>.txt`: the file name becomes the group name. Each line lists a user name
  belonging to that group (the local part before `@` of an email address in
  `terraform/user/user.txt`)

Example: `engineering.txt`

```
alice
bob
```
