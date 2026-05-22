---
doc_id: sfs-product-guide-en-9
title: "8. Upgrade"
visibility: oss-public
doc_type: user-guide
language: en
updated: 2026-05-22
parent: docs/en/guide.md
summary: "8. Upgrade"
load_when: "Read when docs/en/guide.md routes to this section."
---
## 8. Upgrade

Do not reinstall a project to update Solon. Run:

```bash
sfs upgrade
sfs version --check
```

On Mac, if the `sfs` command itself is outdated or `sfs upgrade` cannot update
the runtime, run the tap-qualified Homebrew command first:

```bash
brew upgrade MJ-0701/solon-product/sfs
sfs upgrade
sfs version --check
```

Windows:

```powershell
sfs.cmd update
sfs.cmd version --check
```

On Windows, `sfs.cmd update` is the one-shot command. It updates Solon and then
continues into the current project cleanup.

If `sfs.cmd status` or `sfs.cmd context cat kernel` prints generic usage instead
of real output, treat that as a wrapper regression. If `sfs.cmd start "<goal>"`
exits 0 but prints nothing, verify `.sfs-local/current-sprint` and then run
`sfs.cmd status`; empty output alone is not success. The incident summary and
validation commands are in the
[Windows SFS wrapper incident report](./windows-wrapper-incident-0.6.56.md).

