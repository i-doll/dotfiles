# Five's dotfiles

## .chezmoidata.yaml

Each entry under `git.users` represents one identity (personal, work, etc.). chezmoi generates a per-user git config, writes the public key fetched from 1Password to disk, and wires up `includeIf` rules so git picks the right identity per remote.

```yml
git:
  users:
    - id: i-doll                         # GitHub/GitLab username; used in includeIf and config filenames
      name: "Amalthea Skydancer"         # Git commit author name
      email: amalthea@faen.dev           # Git commit author email; also written to allowed_signers
      opAccount: my.1password.com        # 1Password account shorthand (passed to `op read --account`)
      opRef: "op://Thea/id_thea/public key"  # 1Password secret reference for the SSH public key
      sshKey: ~/.ssh/id_thea.pub         # Path where the public key will be written on disk
      orgs:                              # Optional: GitHub orgs/users whose remotes use this identity
        - name: noteban                  # Org/user name; matched in remote URLs via includeIf
          signing:                       # Optional: override signing for this org's repos
            mode: ssh                   # GPG format: "ssh" or "gpg"
            keyid: ~/.ssh/id_thea.pub   # Signing key; omit to inherit the user-level sshKey
```

### Field reference

| Field | Required | Description |
|---|---|---|
| `id` | yes | Your username on the forge (GitHub, GitLab, etc.). Used in `includeIf "hasconfig:remote.*.url:*:<id>/**"` and names the generated file `~/.config/git/config-<id>`. |
| `name` | yes | Full name written to `[user] name` in the generated config. |
| `email` | yes | Email written to `[user] email` and to `~/.ssh/allowed_signers`. |
| `opAccount` | yes | 1Password account identifier passed to `op read --account` and `onepasswordRead`. |
| `opRef` | yes | 1Password secret reference (e.g. `op://Vault/Item/field`) for the SSH public key. |
| `sshKey` | yes | Local path where the fetched public key is written. Also used as `[user] signingkey`. |
| `orgs[].name` | yes (if orgs present) | Org or user name matched against remote URLs. Also names a generated `~/.config/git/config-<name>` when `signing` is set. |
| `orgs[].signing.mode` | yes (if signing present) | GPG format for this org: `ssh` or `gpg`. |
| `orgs[].signing.keyid` | no | Signing key for this org. If omitted, only `[gpg] format` is overridden and the user-level key is inherited. |
