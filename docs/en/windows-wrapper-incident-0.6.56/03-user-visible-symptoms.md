---
doc_id: sfs-windows-wrapper-incident-0-6-56-en-3
title: "User-Visible Symptoms"
visibility: oss-public
doc_type: incident-report
language: en
updated: 2026-05-22
parent: docs/en/windows-wrapper-incident-0.6.56.md
summary: "User-Visible Symptoms"
load_when: "Read when docs/en/windows-wrapper-incident-0.6.56.md routes to this section."
---
## User-Visible Symptoms

- Inside the agent sandbox, `sfs.cmd start "이미지 프롬프트 고도화"` failed before
  Git Bash could start with `fatal error - couldn't create signal pipe, Win32 error 5`.
- Outside the sandbox, the retry exited 0 but printed no output.
- `.sfs-local/current-sprint` pointed at `2026-W19-sprint-1`, and the sprint
  directory existed, but the user did not receive reliable next-step output.
- `sfs.cmd status`, `sfs.cmd context cat kernel`, and `sfs.cmd context path kernel`
  printed generic usage/help instead of real state or context.
- `.sfs-local/events.jsonl` recorded the Korean `sprint_start` goal as mojibake.

