---
id: sfs-command-healthcheck
summary: Read-only SFS runtime and project drift checker.
load_when: ["healthcheck", "health check", "헬스체크", "drift", "진단"]
---

# Healthcheck

`sfs healthcheck [--all|--project <dir>...]` is a read-only product/runtime
diagnostic. It is part of the packaged runtime, so thin-layout consumers receive
new checks through `brew upgrade` or `scoop update sfs` without per-project
template work.

## Checks

- Runtime dispatch for boosted commands: `adopt`, `ingest`, `flowcheck`,
  `report-bug`, `retro --help`, and `healthcheck`.
- Routed context availability for `review-lens-routing`, `obsidian-llm-wiki`,
  `bug-report-lifecycle`, `flowcheck`, `report-bug`, and `healthcheck`.
- Project version drift between `.sfs-local/VERSION` and packaged `VERSION`.
- `sfs-status` compact parse and `.sfs-local/divisions.yaml` parse.
- Evidence-at-risk handoff guard (advisory `WARN`, never a failure).
- `llm-wiki/` vault frontmatter when the vault exists.
- `.git/index.lock` presence.
- A small packaged runtime regression subset.

## Evidence-at-risk Handoff Guard

`open sprint + passed review + uncommitted tree` is the handoff-loss scenario:
a full sprint can pass review while the working tree stays uncommitted and the
sprint never closes, so a working-tree accident would lose all evidence. The
guard is one read-only predicate shared by three surfaces:

- `sfs status` appends an `evidence-at-risk` flag to its one-line dashboard.
- `sfs <command>` dispatch prints an escalating stderr notice (gentle, firm,
  then `URGENT` as more steps pass without a commit/close). Advisory only — it
  never blocks the command.
- `sfs healthcheck` emits a `WARN` line (read-only; exit code unchanged).

It flags only when a `review_run` PASS exists for the open sprint and the tree
has at least `SFS_EVIDENCE_AT_RISK_MIN_UNCOMMITTED` (default 3) uncommitted
changes (untracked included). Clear it by committing or running
`sfs retro --close`.

## Exit Codes

- `0` — all checked targets are green.
- `1` — one or more issues were found.
- `2` — usage error or unrecoverable runtime error.

## Report-Bug Draft

When issues are found, healthcheck prints a `report-bug DRAFT` only. It must not
call `gh`, create an issue, write project files, append SFS events, or bypass the
`sfs report-bug` confirm gate. The user or agent reviews the draft, dedups if it
is an SFS product defect, then submits through the normal report-bug flow.

## Flowcheck Note

Healthcheck treats `flowcheck: no current sprint` as a normal non-error for this
diagnostic. It verifies flowcheck dispatch/context, not sprint conformance, so a
project without an active sprint does not fail only because flowcheck itself
would need `--sprint`.
