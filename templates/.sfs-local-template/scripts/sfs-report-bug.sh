#!/usr/bin/env bash
# .sfs-local/scripts/sfs-report-bug.sh
#
# Solon SFS — `sfs report-bug` entry for filing an SFS-PRODUCT defect to the
# official GitHub Issues channel. This is a thin deterministic entry: it prints
# the official channel + the report procedure + the confirm-gate contract. The
# agent (which holds the classification/dedup/wording judgment and the `gh`
# auth) performs the actual issue creation per commands/report-bug.md.
# Distinct from `sfs report` (the tidy/retro sprint report).

set -euo pipefail

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

: "${SFS_EXIT_OK:=0}"

cat <<'EOF'
sfs report-bug — file an SFS-PRODUCT bug to the official channel.

Official channel: GitHub Issues MJ-0701/solon-product, label `bug` (the only
official intake for SFS kernel/commands/policies/CLI/model-profiles/installer
defects). Not for consumer project code bugs.

Procedure (SSoT: commands/report-bug.md, policies/bug-report-lifecycle.md):
  1. classify    SFS-product defect vs consumer code (consumer → do not file here)
  2. environment sfs version, runtime, model-profiles version, consumer repo NAME
                 only — no private docset path/filename/content
  3. dedup       gh issue list --repo MJ-0701/solon-product --label bug --search "<kw>"
  4. write       template: 증상 / 실제 사례 / 근본 원인 / 제안 / 환경
  5. submit      gh issue create --repo MJ-0701/solon-product --label bug \
                   --title "[area] one line" --body-file <tmp>
                 (no gh? hand off to a dev runtime/host — never dump manual-paste)
  6. evidence    sfs capture --kind evidence "Filed solon-product#<N>: <title>" + URL
  7. confirm     present issue URL + 1-line summary; STOP for explicit user
                 confirmation before any fix work begins.

Conflict (project-local policy vs SFS default) must surface before entry — never
silent (policies/user-override-precedence.md). Detection-routed bugs from
`sfs flowcheck` enter the same confirm gate; submission only after user confirms.
EOF

exit "${SFS_EXIT_OK}"
