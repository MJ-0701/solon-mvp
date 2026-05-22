---
doc_id: sfs-windows-wrapper-incident-0-6-56-en-4
title: "What Was A Bug"
visibility: oss-public
doc_type: incident-report
language: en
updated: 2026-05-22
parent: docs/en/windows-wrapper-incident-0.6.56.md
summary: "What Was A Bug"
load_when: "Read when docs/en/windows-wrapper-incident-0.6.56.md routes to this section."
---
## What Was A Bug

An empty sprint directory after `sfs start` is not, by itself, a bug. `start`
creates the sprint workspace and pointer; `brainstorm`, `plan`, `review`, and
`retro` create their step files lazily.

The real bugs were:

- read-only commands lost arguments and degraded to usage-only output
- `start` could leave empty output and corrupted Korean event text
- agent routing could mistake partial state plus exit code 0 for success

