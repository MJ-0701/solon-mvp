---
doc_id: sfs-product-guide-en-13
title: "12. Periodic Security Audit (audit)"
visibility: oss-public
doc_type: user-guide
language: en
updated: 2026-07-13
parent: docs/en/guide.md
summary: "A defensive static security audit that surfaces your own repo's vulnerability surface from the code — secrets, injection, config, dependencies, hygiene"
load_when: "Read when docs/en/guide.md routes to this section."
---
## 12. Periodic Security Audit (audit)

`sfs audit` statically surfaces the security vulnerability surface of the
operator's **own repository** from the code and organizes it by OWASP family.
The scan, severity model, and secret masking complete deterministically with
zero LLM tokens. The target code is never modified (read-only), and every
result is signal-only — nothing blocks.

### What it finds (5 lenses)

- **secret (A02)** — hardcoded keys / tokens / passwords, committed `.env`,
  private keys. Values are always masked (never printed raw).
- **owasp (A03/A08)** — command/eval execution sinks, SQL string
  concatenation, unsafe deserialization, XSS sinks.
- **config (A05)** — debug on, TLS verification off, wildcard CORS.
- **deps (A06)** — manifest/lockfile presence, loose version pins, plus the
  ecosystem audit command to run yourself (`npm audit` / `pip-audit` … —
  network checks stay manual).
- **hygiene (A09)** — stray debug residue, security-flavored TODO/FIXME, and
  similar project issues.

### Sequence

1. `sfs audit scan --write` — full-lens scan into
   `docs/solon/<domain>/audit/00-audit.md` (severity-sorted table + masked
   evidence + counts).
2. `sfs audit status` — per-severity and waived counts, open-critical list.
3. Record an acceptable finding in `.sfs-local/audit-waivers` as
   `<file:line>|<reason>`; a re-scan reflects it as `waived`. Fixing the code
   makes the finding disappear on the next scan.
4. The three judgment steps (threat model → exploit hypothesis, reasoning only
   → fix) are delegated to the AI as the report's tail points; the full
   contract is in routed context `commands/audit.md`.

### Safety boundary (important)

- **Static threat-model surface only.** `audit` is not an active pen-testing
  tool — it never runs attack payloads against or penetrates a live target.
  Findings carry verify/fix guidance, not weaponized exploit steps.
- **Your own repo only.** The scan target is the current repo you own and are
  authorized for.

### Periodic runs

Manual by default. To automate, the developer explicitly attaches it to the
existing `SCHEDULED_RUN_CONTRACT` (fresh session, file state, four controls)
or adds an audit hook to the `daily` loop — `audit` never starts a scheduler
on its own.
