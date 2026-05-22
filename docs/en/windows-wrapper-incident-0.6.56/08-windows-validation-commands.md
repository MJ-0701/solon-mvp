---
doc_id: sfs-windows-wrapper-incident-0-6-56-en-8
title: "Windows Validation Commands"
visibility: oss-public
doc_type: incident-report
language: en
updated: 2026-05-22
parent: docs/en/windows-wrapper-incident-0.6.56.md
summary: "Windows Validation Commands"
load_when: "Read when docs/en/windows-wrapper-incident-0.6.56.md routes to this section."
---
## Windows Validation Commands

These commands should not fall back to generic usage:

```powershell
sfs.cmd version --check
sfs.cmd status
sfs.cmd context cat kernel
sfs.cmd start "이미지 프롬프트 고도화"
sfs.cmd status
```

An empty sprint directory after `start` is acceptable until the next step creates
files. Empty command output, usage-only `status`, or usage-only `context cat` is
not acceptable; run `sfs.cmd update` and re-check.
If an already-installed 0.6.49-or-older wrapper makes `sfs.cmd update` itself
fall through to usage, run `scoop update` and then `scoop update sfs` directly
in PowerShell once, then run `sfs.cmd upgrade --no-self-upgrade` from the
project folder.

