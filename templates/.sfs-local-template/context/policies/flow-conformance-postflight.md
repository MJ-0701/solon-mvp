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

`append_flow_event` 는 collapse 하지 않고 매 emission 을 보존하며 active sprint_id 를 항상 stamp 한다.

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

## Plan-gate self-check (암묵 가정 → 명시 스펙, plan = quality gate)
silent divergence 의 plan-time 근원 차단. 코드(Do) 진입 전 plan 자기점검 4문 — `intended-output` / `implicit-assumptions` / `edge-cases` / `intent-alignment` (gate-framework Gate 3 plan-validator check 7). 런타임 divergence 잠금은 `fcp-conflict-surfaced`(#3) + model-tier(#4) 이며, plan 체크리스트는 그 중 #3(silent divergence) 부류를 plan 단계에서 선제 차단한다. plan 품질이 산출물 품질을 결정한다 — 코드 생성이 싸질수록 잘못된 방향의 비용이 커진다. (이 self-check 는 plan 게이트 항목이라 flowcheck 런타임 invariant 가 아니라 노출·교차참조 계약이다.)

## 비목표
- 제품 데이터/보안 검증은 Gate 6 소관(중복 금지).
- agent 자가서술만으로 PASS 금지 — 이벤트 증거 기반.
