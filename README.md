# Five's dotfiles

## .chezmoidata.yaml

This file is gitignored — it's the place for values that shouldn't land in public history (employer names, customer org slugs, internal hostnames, etc.).

### `git.users`

Each entry under `git.users` represents one identity (personal, work, etc.). chezmoi generates a per-user git config, writes the public key fetched from 1Password to disk, adds a `Host github-<id>` alias in `~/.ssh/config` pinned to that key, and installs `url.*.insteadOf` rewrites so any tool (git, uv, cargo, etc.) transparently routes that user's personal repos and orgs through the right SSH identity. `includeIf` rules layer email/signing overrides on top for manual clones.

```yml
git:
  users:
    - id: i-doll                              # GitHub/GitLab username; used in includeIf and config filenames
      name: "Amalthea Skydancer"              # Git commit author name
      email: amalthea@faen.dev                # Git commit author email; also written to allowed_signers
      opAccount: my.1password.com             # 1Password account shorthand (passed to `op read --account`)
      opRef: "op://Thea/id_thea/public key"   # 1Password secret reference for the SSH public key
      sshKey: ~/.ssh/id_thea.pub              # Path where the public key will be written on disk
      orgs:                                   # Optional: GitHub orgs/users whose remotes use this identity
        - name: noteban                       # Org/user name; matched in remote URLs via includeIf
          signing:                            # Optional: override signing for this org's repos
            mode: ssh                         # GPG format: "ssh" or "openpgp"
            keyid: ~/.ssh/id_thea.pub         # Signing key; omit to inherit the user-level sshKey
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

### `finicky.work`

Drives `~/.finicky.ts` so the tracked template stays free of employer and customer names. Anything under `finicky.work` routes the matching URL to the `work` browser profile; everything else falls through to `personal`.

```yml
finicky:
  work:
    openers:                        # macOS apps whose links always open in work
      - Microsoft Outlook
      - Slack
    hosts:                          # URL hostnames that always open in work
      - jira.example.internal
    githubPaths:                    # path fragments on *.github.com that open in work
      - AcmeCorp
      - acme-internal-tools
```

| Field | Required | Description |
|---|---|---|
| `openers` | no | List of opener app names (as reported by Finicky's `opener.name`). Links opened by any of these apps go to the work profile. |
| `hosts` | no | Exact-match URL hosts (not suffix — use the full hostname). |
| `githubPaths` | no | Substrings matched against the URL path on any `*.github.com` host. Typically GitHub org or user slugs. |

All three fields default to empty lists, so omitting `finicky` entirely is fine on machines where you don't need work routing.
