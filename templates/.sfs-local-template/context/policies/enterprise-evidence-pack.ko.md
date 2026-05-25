---
id: sfs-policy-enterprise-evidence-pack-ko
summary: SFS 산출물과 실제 프로젝트 적용 여부를 검증하는 QA/QC evidence 팩.
language: ko
load_when:
  - QA/QC
  - evidence
  - metrics
  - 실제 프로젝트 적용
  - release confidence
  - wiki evidence
status: filled-v1
parent_doc: enterprise-agent-team-pack.ko.md
content_policy: "acceptance, release, monitoring, durable wiki evidence 때 로드"
---

# Enterprise Evidence Pack

SFS 품질 주장을 측정 가능하게 만든다. 정책/knowledge-pack 변경은 Markdown 이
생겼다고 끝이 아니다. runtime behavior, test, 실제 프로젝트 적용 증거가 있어야
끝난다.

## Evidence 우선순위

1. exact command 와 결과가 있는 test/build/typecheck/lint/smoke
2. integration/browser trace, screenshot, API response, migration dry run
3. static analysis, dependency/security scan, query plan, bundle/profile output
4. AC/file/evidence mapping 이 있는 review artifact
5. owner, reason, follow-up, risk 가 있는 explicit waiver

## Enterprise Metrics

해당 slice 가 영향을 줄 수 있을 때만 추적한다.

- DORA: lead time, deployment frequency, change failure rate, recovery time
- quality: defect escape, flaky test, 반복 finding, critical path coverage
- product: task completion, user-visible latency, accessibility, error rate
- ops: SLO/error-budget risk, rollback, alert/runbook readiness
- harness: user-call count, runnable-step delegation, review loop, context size,
  pack load accuracy

## QA/QC Ledger

SFS harness/product-policy 작업이면 기록한다.

- 관찰된 문제와 root cause
- 변경된 guardrail, command, pack, test
- local verification command 와 PASS/FAIL
- 가능한 경우 실제 SFS 프로젝트 적용 smoke
- residual risk, waiver, next sprint item

## 실제 프로젝트 Smoke

SFS 자체 변경에는 실제 프로젝트 probe 를 선호한다.

- consumer project 에서 `sfs context cat ...` 로 새 pack 이 로드되는지 확인
- `sfs plan` 또는 `sfs review --prompt-only` 가 새 ledger field 를 보여주는지 확인
- 문제를 보였던 프로젝트 slice 를 app code 수정 없이 재평가
- 명시적 필요가 없으면 study-note wiki 는 쓰지 않는다.

## Anti-Paper PASS

아래는 partial 이다.

- router/test/runtime proof 없이 "docs updated" 만 있는 경우
- 같은 generator 의 self-attestation 만 있는 경우
- GitHub/PR PASS 를 SFS Gate 3/6 대체로 쓰는 경우
- performance/security/accessibility 주장이 측정 또는 N/A waiver 없이 있는 경우
