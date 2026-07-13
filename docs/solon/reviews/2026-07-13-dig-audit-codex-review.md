---
doc_id: dig-audit-codex-review
title: "Codex review — sfs dig + sfs audit (gpt-5.5 xhigh)"
doc_type: review-evidence
language: ko
updated: 2026-07-13
summary: "Codex 독립 리뷰 원문 — dig/audit 유효 결함 11건 triage. 0.10.1 에서 반영."
load_when: "Read when tracing the dig/audit review findings and their fixes."
---

# Codex review — sfs dig + sfs audit (gpt-5.5 xhigh, read-only)

요청 모델 gpt-5.6 은 Codex ChatGPT 계정 미지원(400) → config 기본이자 문서상 최상위 CPO 티어 gpt-5.5 xhigh 로 대체.

No Critical findings. I could not run write-mode tests because this sandbox is read-only even for `/tmp`, so this is a static, line-grounded review.

**Ranked Findings**

1. **High — [scripts/sfs-audit.sh:56](/Users/mj/tmp/solon-product/scripts/sfs-audit.sh:56), [scripts/sfs-dig.sh:55](/Users/mj/tmp/solon-product/scripts/sfs-dig.sh:55)**  
   `--domain` is used raw, so `--domain ../../src` writes artifacts outside `docs/solon/<domain>/...`.  
   Scenario: `sfs audit scan --write --domain ../../src` writes under `src/audit/`, modifying the scanned repo’s source tree.  
   Fix: slug/reject explicit domains containing `/`, `..`, absolute paths, or empty resolved slugs; assert resolved output path stays under `docs/solon/`.

2. **High — [scripts/sfs-dig.sh:686](/Users/mj/tmp/solon-product/scripts/sfs-dig.sh:686)**  
   `sfs dig capsule --target` bypasses the L2 queue and accepts arbitrary paths.  
   Scenario: after a READY queue, `sfs dig capsule --target ../../.ssh/id_rsa --write` emits a capsule whose `files_scope` authorizes reading outside the repo.  
   Fix: require `--target` to match an open queue item and normalized `src_files`; reject absolute paths and `..`; reject `--next` plus `--target`.

3. **High — [scripts/sfs-audit.sh:91](/Users/mj/tmp/solon-product/scripts/sfs-audit.sh:91)**  
   `is_test_path` treats any path containing `test` or `spec` as test code, causing production false negatives.  
   Scenario: `src/contest/auth.js` with `eval(req.body.x)` or a hardcoded password is skipped because `contest` matches `*test*`.  
   Fix: match path components/suffixes only, e.g. `*/test/*`, `*/tests/*`, `*.test.*`, `*.spec.*`, not arbitrary substrings.

4. **Medium — [scripts/sfs-audit.sh:366](/Users/mj/tmp/solon-product/scripts/sfs-audit.sh:366)**  
   `audit scan --write` always writes `.sfs-local/audit-findings.tsv`, violating the stated “writes only under docs/solon/<domain>/audit/” invariant.  
   Scenario: even a normal `sfs audit scan --write` mutates `.sfs-local` in the scanned repo.  
   Fix: store the TSV under `docs/solon/<domain>/audit/` or explicitly revise the invariant/contract and tests.

5. **Medium — [scripts/sfs-dig.sh:198](/Users/mj/tmp/solon-product/scripts/sfs-dig.sh:198)**  
   SQL ERD parsing relies on `IGNORECASE=1`, which is not portable in BSD awk, so lowercase SQL is missed on macOS.  
   Scenario: `create table users (...)` produces no TABLE rows on BSD awk; inline `org_id integer references orgs(id)` also yields no FK.  
   Fix: use `tolower($0)` for matching and add inline `REFERENCES` parsing; add lowercase and inline-FK fixtures.

6. **Medium — [scripts/sfs-dig.sh:239](/Users/mj/tmp/solon-product/scripts/sfs-dig.sh:239)**  
   Prisma relation parsing emits false FKs for inverse relations without `fields:`.  
   Scenario: `posts Post[] @relation("UserPosts")` emits `FK User <empty> Post`, inventing a relationship column.  
   Fix: only emit FK when `fields:` is present; parse comma-separated field lists; ignore inverse array-only relations.

7. **Medium — [scripts/sfs-dig.sh:751](/Users/mj/tmp/solon-product/scripts/sfs-dig.sh:751), [scripts/sfs-dig.sh:764](/Users/mj/tmp/solon-product/scripts/sfs-dig.sh:764)**  
   The card validator only requires one citation in `## Evidence`, and any runtime bullet upgrades to `verified`.  
   Scenario: unsupported claims in `## Purpose` pass if `## Evidence` contains unrelated `src/a.js:1`; `## Runtime evidence\n- manually checked` becomes verified.  
   Fix: require section-level citations or claim/evidence IDs, and require runtime evidence to cite a command/result artifact or structured verifiable record.

8. **Medium — [scripts/sfs-dig.sh:352](/Users/mj/tmp/solon-product/scripts/sfs-dig.sh:352), [scripts/sfs-dig.sh:523](/Users/mj/tmp/solon-product/scripts/sfs-dig.sh:523)**  
   ERD/JPA file lists are expanded unquoted, breaking filenames with spaces.  
   Scenario: `db/migration/V1 init.sql` is split into two awk arguments, so ERD extraction fails.  
   Fix: pass files via newline-safe loops or NUL-safe `find -print0`; avoid `${sql_files}` word splitting.

9. **Medium — [scripts/sfs-dig.sh:134](/Users/mj/tmp/solon-product/scripts/sfs-dig.sh:134), [scripts/sfs-dig.sh:140](/Users/mj/tmp/solon-product/scripts/sfs-dig.sh:140), [scripts/sfs-dig.sh:175](/Users/mj/tmp/solon-product/scripts/sfs-dig.sh:175)**  
   `grep -E` patterns use non-portable `\b`/`\s`, contrary to the BSD-ERE invariant.  
   Scenario: on stricter BSD grep, Express routes, Django routes, Python defs, or runtime bullets can be missed.  
   Fix: replace with `[[:space:]]` and explicit word-boundary alternatives like `(^|[^[:alnum:]_])`.

10. **Medium — [scripts/sfs-audit.sh:122](/Users/mj/tmp/solon-product/scripts/sfs-audit.sh:122), [scripts/sfs-audit.sh:125](/Users/mj/tmp/solon-product/scripts/sfs-audit.sh:125)**  
   Secret detection misses common current token formats.  
   Scenario: AWS temporary keys starting `ASIA...` and GitHub fine-grained `github_pat_...` tokens are not flagged despite the “AWS/GitHub tokens” contract.  
   Fix: add explicit ERE-safe patterns and fixture tests for current AWS/GitHub token families.

11. **Low — [tests/test-audit-scan.sh:47](/Users/mj/tmp/solon-product/tests/test-audit-scan.sh:47), [tests/test-dig-capsule.sh:46](/Users/mj/tmp/solon-product/tests/test-dig-capsule.sh:46)**  
   The headline tests assert happy-path presence but miss the main invariant regressions above.  
   Scenario: raw secret leakage in TSV/status, `--target` outside queue, domain traversal, lowercase SQL, inverse Prisma relations, and filenames with spaces would all slip through.  
   Fix: add negative tests for every invariant, not just fixture success strings.

**Invariants Verified**

- Dispatcher cases for `dig` and `audit` are present in `bin/sfs`.
- I found no scanner-side LLM or network invocation in the two scripts.
- For currently matched secret patterns, findings call `redact()` before artifact emission.
- Audit findings are signal-only by exit code; critical findings affect status text, not scan failure.