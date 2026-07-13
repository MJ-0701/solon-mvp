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

---

## Round 2 재리뷰 (gpt-5.5 xhigh — gpt-5.6-sol 은 Codex CLI 0.142.0 미지원, npm latest 도 동일이라 앱 전용)

Round-1 픽스 intact 확인 + 신규 7건(전부 실물). 0.10.1 에서 반영.

**Ranked Findings**

1. **High** — [scripts/sfs-audit.sh](/Users/mj/tmp/solon-product/scripts/sfs-audit.sh:176): unsafe `yaml.load(..., Loader=yaml.Loader)` is treated as safe.  
Failure: `yaml.load(data, Loader=yaml.Loader)` produces no A08 finding because any `Loader=` exempts it.  
Fix: exempt only `SafeLoader` or `safe_load`; flag `yaml.Loader`, `FullLoader`, and unknown loaders.

2. **High** — [scripts/sfs-audit.sh](/Users/mj/tmp/solon-product/scripts/sfs-audit.sh:140): unquoted hardcoded secrets are candidate-scanned but never emitted.  
Failure: `db.password=s3cr3t-admin-pw-2024` in `.properties` enters the grep candidate set, but the value regex requires quotes, so no finding.  
Fix: parse both quoted and unquoted assignment values, then redact before adding the finding.

3. **Medium** — [scripts/sfs-dig.sh](/Users/mj/tmp/solon-product/scripts/sfs-dig.sh:226): SQL ERD still misclassifies table constraints.  
Failure: `CONSTRAINT fk ... FOREIGN KEY ... REFERENCES ...` becomes `IDX`, not `FK`; bare `CHECK (...)` becomes a bogus column named `CHECK`.  
Fix: scan constraint lines for `foreign key ... references` before generic IDX handling, and explicitly skip/render `CHECK` as a constraint, not a column.

4. **Medium** — [scripts/sfs-dig.sh](/Users/mj/tmp/solon-product/scripts/sfs-dig.sh:722): capsule `--target` queue matching interpolates the path as ERE.  
Failure: queued `src/routes/[id].js` is rejected; target `src/routes/..js` can false-match another queued path because `.`/`[]` are regex metachars.  
Fix: parse queue item text and compare with fixed-string equality, or use `grep -F` after separating the prefix.

5. **Medium** — [scripts/sfs-audit.sh](/Users/mj/tmp/solon-product/scripts/sfs-audit.sh:128): raw token secret rules bypass `is_test_path`.  
Failure: `auth_test.go` or `UserTest.java` containing fixture AWS/GitHub tokens is reported critical despite the test/suffix exclusion contract.  
Fix: skip `is_test_path "$f"` at the top of `scan_secret`, or apply it consistently to every secret sub-rule.

6. **Low** — [scripts/sfs-audit.sh](/Users/mj/tmp/solon-product/scripts/sfs-audit.sh:234): loose dependency findings are lost in a pipeline subshell.  
Failure: `package.json` with `"express": "*"` or `"cors": "latest"` never adds the intended A06 low finding.  
Fix: feed the loop with a here-doc/here-string or accumulate outside the pipeline.

7. **Low** — [scripts/sfs-audit.sh](/Users/mj/tmp/solon-product/scripts/sfs-audit.sh:172): SQL concat detection misses common single-quoted JS/TS queries.  
Failure: `db.query('SELECT ... ' + id)` is missed unless the variable name happens to match `req|param|input|user`.  
Fix: include single quotes/backticks in the SQL concat pattern and keep the guidance wording as “verify taint” to control noise.

**Verification**

`bash -n` passed for `scripts/sfs-dig.sh`, `scripts/sfs-audit.sh`, and `bin/sfs`. I could not run the shell test suite because this sandbox cannot create `mktemp` directories (`Operation not permitted`).

**Invariants Verified**

- No edits made.
- `bin/sfs` dispatches `dig` and `audit` to the scoped scripts.
- No LLM/network/exploit-tool invocation found in the two scanner scripts.
- `--domain` is slugged to `[a-z0-9-]`, blocking traversal writes.
- `audit` writes reports and `findings.tsv` under `docs/solon/<domain>/audit/`.
- Detected token evidence paths use redaction, not full raw secret values.
- Findings remain signal-only; scanner findings do not change exit status.