---
id: sfs-policy-enterprise-evidence-pack
summary: Enterprise QA/QC evidence taxonomy for SFS artifacts and project-applied validation.
load_when:
  - QA/QC
  - evidence
  - metrics
  - applied project
  - release confidence
  - wiki evidence
status: filled-v1
parent_doc: enterprise-agent-team-pack.md
content_policy: "load when acceptance, release, monitoring, or durable wiki evidence is in scope"
---

# Enterprise Evidence Pack

Use this pack to keep SFS quality claims measurable. A policy or knowledge-pack
change is not done when the Markdown exists; it is done when runtime behavior,
tests, and project-applied evidence show it works.

## Evidence Hierarchy

Prefer evidence in this order:

1. automated test/build/typecheck/lint/smoke with exact command and result;
2. integration or browser trace, screenshot, API response, migration dry run;
3. static analysis, dependency/security scan, query plan, bundle/profile output;
4. review artifact with AC/file/evidence mapping;
5. explicit waiver with owner, reason, follow-up, and risk.

## Enterprise Metrics

Track only when the slice can reasonably affect them:

- DORA: lead time, deployment frequency, change failure rate, recovery time;
- quality: defect escape, flaky test count, repeated finding count, coverage of
  critical paths;
- product: task completion, user-visible latency, accessibility, error rate;
- operations: SLO/error-budget risk, rollback path, alert/runbook readiness;
- harness: user-call count, runnable-step delegation count, review loop count,
  context size, pack load accuracy.

## QA/QC Ledger

For harness/product-policy work, record:

- problem observed and root cause;
- changed guardrail, command, pack, or test;
- local verification commands and PASS/FAIL;
- project-applied smoke against a real SFS project when practical;
- residual risk, waiver, or next sprint item.

## Applied Project Smoke

When changing SFS itself, prefer one real-project probe:

- `sfs context cat ...` loads the new pack from a consumer project;
- `sfs plan` or `sfs review --prompt-only` shows the new ledger fields;
- a known problematic project slice is re-evaluated without editing app code;
- no study/project wiki is written unless that project explicitly needs handoff.

## Anti-Paper PASS

Return partial when evidence is only:

- "updated docs" with no router/test/runtime proof;
- self-attestation by the same generator without self-CPO ledger;
- a GitHub/PR PASS used as SFS Gate 3 or Gate 6 replacement;
- performance, security, or accessibility claims without a measurement or
  explicit N/A waiver.
