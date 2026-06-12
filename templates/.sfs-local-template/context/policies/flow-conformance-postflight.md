---
id: sfs-policy-flow-conformance-postflight
summary: Invariant registry + event contract for flowcheck postflight; defines critical vs advisory and divergence classification.
load_when: ["flowcheck", "flow conformance", "postflight", "invariant", "flow 점검"]
---

# Flow-Conformance Postflight — invariants & event contract

`commands/flowcheck.md` 가 검사하는 invariant 와 그걸 가능케 하는 이벤트 계약 SSoT.

## 이벤트 계약 (events.jsonl, non-collapsing)
flow 는 다음을 emit (`sfs event <type> <key=value...>`; 기존 evidence_capture 와 동급 append):
- `model_resolved` {agent_role, resolved_tier, resolved_model, source: policy|configured|current|user-override, profiles_version}
- `worker_dispatched` {role, model, parallel(true|false), lanes}
- `gate_passed` {gate, order_index, self_cpo: pass|partial|fail}
- `conflict_surfaced` {kind, detail, resolved_by: user|capture, scope}
- `verification_pair` {implementer, verifier, implementer_context, verifier_context, gate}
- (의도 원장) `evidence_capture` kind ∈ {decision, scope-change, user-approval, exception, waiver} (+ `--scope`)
- (텔레메트리, advisory) `tool_call` {tool, outcome: ok|error, latency_ms} — 보통 MCP 툴 호출마다 1건 emit.

`append_flow_event` 는 collapse 하지 않고 매 emission 을 보존하며 active sprint_id 를 항상 stamp 한다.

`tool_call` 은 위 invariant 이벤트와 **같은 non-collapsing 원장 전송로**를 타지만
**FCP invariant 가 아니다** — critical 도 advisory invariant 도 아니고, verdict/exit
에 절대 영향을 주지 않는다. flowcheck 가 read-only 로 집계해 "어떤 툴이 반복 실패·지연"
하는지 health 요약을 내는 계측 신호일 뿐이다 (아래 Tool-telemetry health). high-volume
이라 per-sprint event compaction 으로만 경계되며 MVP 에서는 충분하다.

## EVENT_LOG_RECONSTRUCTION_SSOT

런(작업단위 실행 전체)은 이벤트 로그에서 언제든 재구성 가능해야 하고, resume ·
관측(flowcheck/healthcheck/recall) · 메모리(lessons/핸드오프)는 전부 이 로그에서
**파생**된다 — 파생물이 로그와 어긋나면 **로그가 권위다**. 핸드오프 문서나
PROGRESS 서술이 이벤트 원장과 모순될 때 원장 쪽을 믿고, 모순 자체는 #3 으로
surface 한다 (silent 동기화 금지). 권위 사슬은 active `events.jsonl` +
tidy 가 보존한 raw 발췌(`.sfs-local/archives/events/sprints/<sprint-id>.jsonl`)
까지다 — compaction 은 raw 보존이 선행되어야 한다는 기존 tidy 계약이 이 권위를
지탱한다. 외부 검증 (by-reference): Managed Agents 의 session 리소스 — harness
(brain) 와 실행 샌드박스 (hands) 를 잇는 것은 append-only 이벤트 로그이고 런
상태는 전부 거기서 재구성된다 ("The evolution of agentic surfaces", 2026-06-10).
solon 의 `sfs event` 버스 + session transfer 는 이미 이 형태로 동작한다 — 본
절은 그것의 명문화 + 외부 검증 등재다. (같은 글의 outcomes rubric 자기채점은
flowcheck 의 rubric 형 postflight 자기점검의 외부 검증 — 포인터만, 신규 기능
아님.)

## invariant registry
| id | 기대 | class |
|----|------|-------|
| fcp-model-tier | worker model_resolved.source ∈ policy|configured (현재 host 모델 누수 금지); current/user-override 는 live-scoped override capture 또는 waiver 필요 | critical |
| fcp-conflict-surfaced | user-override 같은 default 이탈마다 `conflict_surfaced` 이벤트 존재 | critical |
| fcp-gate-order | gate_passed order_index 역행 없음·무단 누락 없음 | critical |
| fcp-stop-the-line | self_cpo=fail 인 gate_passed 없음 | critical |
| fcp-pr-reviewed | ship/done 전 SFS review gate_passed(self_cpo=pass) 존재. GitHub PR 승인/`@codex` 단독으로는 불충족 | critical |
| fcp-verifier-implementer | review close 전 `verification_pair` 로 verifier != implementer 증명 | critical |
| fcp-self-cpo | 모든 gate_passed self_cpo=pass (partial 은 warn) | advisory |
| fcp-worker-lane | parallel worker_dispatched 가 lanes 선언 또는 waiver | advisory |

`fcp-pr-reviewed` 는 SFS 내부 review gate 만 권위로 본다 — kernel 의 "GitHub PR/`@codex` review 는
SFS review 와 별개" 계약과 정합(외부 PASS 는 continuation 증거이지 gate PASS 대체 아님).

## 분류 규칙
- covered-by-intent ∧ ¬conflict → 의도(PASS).
- covered-by-local-policy ∧ conflict-with-SFS-default → #3 surface → 사용자 판정(의도면 capture, 버그면 report-bug).
- uncovered → triage → SFS 제품이면 report-bug.
- 모호 → surface(silent 금지).
- override-coverage 는 **live·scoped·user-authorized** capture(`policies/user-override-precedence.md`)일 때만 conformant.
  inherited-but-unconfirmed 또는 expired override 는 critical surface(silent pass 금지).

## 출력
- 판정 artifact(`<sprint>/workbench/flowcheck.md`) + `flow_conformance` 이벤트.
- critical unresolved → nonzero exit(blocking). advisory → warn, exit 0.
- waiver(`sfs capture --kind waiver`)가 invariant id 를 명시하면 해당 critical 을 waived 로 강등.
- (계측) `tool_call` 이 있으면 artifact·stdout 에 advisory **Tool-telemetry health** 요약을 덧붙인다 (verdict/exit 불변).

## Tool-telemetry health (advisory, non-gating)
flowcheck 는 sprint 의 `tool_call` 이벤트를 read-only 로 집계해 per-tool
{call 수, error 수, error-rate, max latency} 를 내고, **반복 실패 hotspot 1개**를
핀포인트한다. hotspot 순위 기준은 **error count(≥2 floor)** 다 — error *rate* 가
아니다. 1/1(100%) 같은 one-off 는 "반복"이 아니므로 제외하고, 동률은 rate desc →
tool 이름 asc 로 결정적 tie-break 한다. 이 hotspot 은 버그리포트 flow 의 drift-warn
신호원이자 `policies/lessons-accumulation.md` 누적 입력이다. 계측은 **추가만**이고
기존 invariant 판정과 exit 코드를 어느 방향으로도 바꾸지 않는다 (비파괴 계약).

## Plan-gate self-check (암묵 가정 → 명시 스펙, plan = quality gate)
silent divergence 의 plan-time 근원 차단. 코드(Do) 진입 전 plan 자기점검 4문 — `intended-output` / `implicit-assumptions` / `edge-cases` / `intent-alignment` (gate-framework Gate 3 plan-validator check 7). 런타임 divergence 잠금은 `fcp-conflict-surfaced`(#3) + model-tier(#4) 이며, plan 체크리스트는 그 중 #3(silent divergence) 부류를 plan 단계에서 선제 차단한다. plan 품질이 산출물 품질을 결정한다 — 코드 생성이 싸질수록 잘못된 방향의 비용이 커진다. (이 self-check 는 plan 게이트 항목이라 flowcheck 런타임 invariant 가 아니라 노출·교차참조 계약이다.)

## Verifier context split pattern (docs-level)
For high-risk or repeated FCP/review rules, prepare a rule-scoped verifier context:
the verifier sees the rule, AC, evidence paths, and known counterexamples, not
the implementer's full authoring context. Use a skeptic persona for
false-positive suppression: the verifier must ask whether a finding is caused
by stale assumptions, self-preferential bias, missing evidence, or an actual
rule breach. Parallel checks may fan out, but close waits at a
fan-out/synthesize barrier where each artifact capsule exists and the lead
synthesizes against source evidence. This is not a new flowcheck critical invariant; it is a documentation-level recommendation for preparing stronger
`verification_pair` evidence. Tool-specific workflow files stay wiki/deferred.

## 비목표
- 제품 데이터/보안 검증은 Gate 6 소관(중복 금지).
- agent 자가서술만으로 PASS 금지 — 이벤트 증거 기반.
