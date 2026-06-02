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
- `llm-wiki/` vault frontmatter when the vault exists.
- `.git/index.lock` presence.
- A small packaged runtime regression subset.

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
