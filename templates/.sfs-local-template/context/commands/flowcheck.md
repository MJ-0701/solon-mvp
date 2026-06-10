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
- flow 는 진행 중 구조화 이벤트를 emit: `sfs event model_resolved|worker_dispatched|gate_passed|conflict_surfaced|verification_pair <key=value...>`.
  이벤트는 non-collapsing(매 emission 보존) — agent 자가서술이 아니라 이벤트 증거가 판정 근거다.

## 강제력 (hybrid)
- advisory 위반 → 기록 + surface, 차단 없음.
- critical 위반(model-tier / 필수 Gate 누락·순서 / 충돌 미-surface / stop-the-line / pr-review / verifier=implementer) → blocking.
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
- review close 는 `verification_pair` 로 verifier != implementer 를 증명한다.
- verifier context split 은 separate verifier context 로 rule/evidence package 를
  보게 하는 documentation-level recommendation 이다. 권장 패턴이지 새 critical invariant 나
  flowcheck engine 요구사항이 아니다.

## Plan-gate self-check (암묵 가정 → 명시 스펙, plan = quality gate)
코드(Do) 진입 전 plan 이 통과해야 하는 자기점검 4문. **plan 품질이 산출물 품질을 결정한다 — 코드 생성이 싸질수록 잘못된 방향의 비용이 커진다.**
1. `intended-output` — 실제로 만들려는 결과물은? 명시 스펙/AC 로 적혔는가?
2. `implicit-assumptions` — 아직 암묵으로 남은 가정은? 전부 명시로 전환했는가?
3. `edge-cases` — 잊기 쉬운 엣지케이스는? AC/design 입력으로 박았는가?
4. `intent-alignment` — rollout 전 의도일치(설계 의도 == 산출물)를 어떻게 확인하는가?

미전환 암묵 가정 = silent divergence 의 plan-time 근원. 런타임 divergence 잠금은 `fcp-conflict-surfaced`(#3) + model-tier(#4) 이며, plan 체크리스트는 그 중 #3(silent divergence) 부류를 plan 단계에서 선제 차단한다. Gate SSoT: gate-framework Gate 3 plan-validator check 7.

## Nondeveloper safety gates
Published output gets four plain-language checks before close: structure
(the user can find the main path), security (no secret/admin/auth leak),
UX (primary task works visibly), and refactor (no obvious brittle placeholder
debt). Security exposure is critical-blocking; the others need evidence or a
named follow-up/waiver.

## Tool-telemetry health (advisory, non-gating)
sprint 에 `tool_call` 이벤트(보통 MCP 툴 호출마다 1건; `tool`/`outcome`/`latency_ms`)가
있으면 flowcheck 가 read-only 로 집계해 per-tool call·error·error-rate·max-latency 와
**반복 실패 hotspot**(error count ≥2 기준)을 artifact·stdout 에 advisory 로 덧붙인다.
이 hotspot 은 버그리포트 flow 의 drift-warn 신호원 + lessons 입력이다. 계측은 추가만이고
verdict/exit 를 바꾸지 않는다(기존 동작 비파괴). 계약 SSoT: `policies/flow-conformance-postflight.md`.

## Lessons loop
flowcheck 출력은 `.sfs-local/lessons.md` 의 누적 lesson 수와 "이번 작업단위에서
잡힌 실패를 lesson 으로 기록하라"는 의무를 advisory 1줄로 surface 한다(verdict/exit
불변). 실패→회피 규칙 누적 규약은 `policies/lessons-accumulation.md`.

## invariant SSoT
`policies/flow-conformance-postflight.md`.
