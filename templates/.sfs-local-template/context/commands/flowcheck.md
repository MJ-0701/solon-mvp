---
id: sfs-command-flowcheck
summary: Postflight self-check that SFS executed per documented flow; classify divergence intended|product-bug and route product bugs to report-bug.
load_when: ["flowcheck", "postflight", "flow conformance", "작업단위 점검", "flow 점검", "self-check"]
---

# Flowcheck (Flow-Conformance Postflight)

작업단위(slice/sprint/gate 묶음) 종료 시 SFS 자신이 문서화된 default 대로 돌았는지 검증.
제품 검증(Gate 6)이 아니라 **방법론 실행 적합성** 검증 — 에러 없이 잘못 실행된 silent divergence 를 잡는다.

## 실행
- 작업단위 close 시 `sfs flowcheck`. `review` 에서 `flow-conformance` lens 로도 호출.
- `scripts/sfs-flowcheck.sh` 가 events.jsonl(flow events + capture 원장)을 읽어 invariant assert.
- flow 는 진행 중 구조화 이벤트를 emit: `sfs event model_resolved|worker_dispatched|gate_passed|conflict_surfaced <key=value...>`.
  이벤트는 non-collapsing(매 emission 보존) — agent 자가서술이 아니라 이벤트 증거가 판정 근거다.

## 강제력 (hybrid)
- advisory 위반 → 기록 + surface, 차단 없음.
- critical 위반(model-tier / 필수 Gate 누락·순서 / 충돌 미-surface / stop-the-line / pr-review) → blocking.
  PASS 또는 `sfs capture --kind waiver "<invariant-id>: <이유>"` 없으면 작업단위 done 불가(nonzero exit).

## 분류
1. 인가 capture 있고 SFS default 와 모순 없음 → 의도. PASS.
2. 로컬 정책이 인가했지만 SFS default 와 모순 → #3 surface → 사용자 판정.
3. 인가 없는 divergence → debugging-and-error-recovery triage → SFS 제품 결함이면 4로.
4. 모호/제품버그 → surface. 제품버그 확정 시 report-bug 본문 prefill → `report-bug` confirm gate.

## 절대 규칙
- 어느 divergence도 silent 통과·silent drop 금지(#3).
- 제품버그 자동 라우팅은 confirm gate 까지만 — 제출은 사용자 확정 후.
- pr-review 불변식은 **SFS review gate**(self_cpo=pass) 기준. GitHub PR 승인/`@codex` 만으로는 충족 안 됨.

## invariant SSoT
`policies/flow-conformance-postflight.md`.
