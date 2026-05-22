---
doc_id: sfs-current-product-shape-en-3
title: "Token Diet / Compact I/O"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-22
parent: docs/en/current-product-shape.md
summary: "Token Diet / Compact I/O"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Token Diet / Compact I/O

Token Diet is not "make every AI answer short." It is a compact I/O contract
for routine status and handoff output: remove decorative filler, keep the
fields needed for judgment and verification.

```bash
SFS_OUTPUT_STYLE=compact sfs status
sfs status --compact
sfs start "first goal" --output-style compact
SFS_OUTPUT_STYLE=compact sfs report
```

Compact `status` keeps `sprint`, `wu`, `gate`, `verdict`, `ahead`, and
`last_event`. Compact `start` keeps the created sprint path, shared-docs path,
lazy step-doc state, recommended brainstorm command, `--simple` / `--hard`
alternatives, and `recommended=normal`. Compact `report` keeps the report path,
archive path, and compact/finalization state.

Destructive/security/privacy/data-loss warnings, user decisions, review
findings, raw-source traceability, and verification evidence stay in full
clarity when shortening would lower quality. Caveman/persona speech is not the
default; SFS defaults to professional compact output. The quality floor is
evidence, risk, and raw traceability first; shorter text comes second. The filefunc benchmark
influenced Context Diet principles such as precise routed context, stable
search vocabulary, raw-text fallback, and verification. It is not a broad one-file-one-function rule.

As of 0.6.85, the release verifier applies the same quality floor to release
checks. Successful internal install/upgrade smoke logs stay quiet; failed
smokes replay captured stdout and stderr with `[verify-product-release]`
prefixes. Release logs get shorter, but release evidence remains traceable.

When the work closes, `report.md` and `retro.md` are generated under
`docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/` rather than inside
`.sfs-local`. For example, order item quantity work belongs under
`order/order-items/quantity-update`. Users normally run `sfs start "<goal>"`;
SFS infers high-confidence domain labels from that natural goal. Use the legacy
`--workspace <english-name>` fallback only while the work is still exploration
without stable domain labels.
The prose defaults to the user's native or workspace language, matching the
native-language commit message rule.

