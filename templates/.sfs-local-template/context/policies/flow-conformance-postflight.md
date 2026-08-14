---
id: sfs-policy-flow-conformance-postflight
summary: Invariant registry + event contract for flowcheck postflight; defines critical vs advisory and divergence classification.
load_when: ["flowcheck", "flow conformance", "postflight", "invariant", "flow 점검", "long run drift", "still on track", "assumption changed", "무인 런 점검"]
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

## MID_RUN_INTENT_RECHECK (in-flight, docs-level)

본 정책의 나머지는 **사후** 표면이다. 장시간·무인 런은 사후만으로 늦다 —
초반에 세운 잘못된 가정 하나가 남은 런 전체에 복리로 쌓이고, 끝나서야 드러난다.
그래서 장시간/무인 WU 는 **스텝 경계마다** 두 가지를 산출물 흔적으로 남긴다:

1. **가정 변화 감지** — 이 런이 의존하는 가정 중 territory 에서 바뀐 것이
   있는가. 있으면 DEVIATIONS_LOG (`policies/unknowns-and-deviations.md`) 로.
2. **원 intent 대조** — 지금 하는 일이 원래 AC/intent 를 여전히 만족하는가.

둘 다 침묵한 채 직진하면 그 자체가 drift finding 이다 (advisory — 명령을
막지 않는다). 시점이 다른 세 표면을 구분해 둔다: 착수 **전** 선언은
`policies/harness-autonomy.md` PRE_WORK_INVARIANT_DECLARATION, **도중** 은
본 절, **사후** 는 본 정책의 invariant registry 와 Gate 6. 무인 런에서는
SCHEDULED_RUN_CONTRACT 1번 (상태는 파일로) 이 그 흔적의 거처다
(`policies/work-delegation-and-startup.md`). 외부검증 (by-reference): 야간
무인 에이전트 운영 인터뷰 관련 Claude 블로그(2026-07-20) — 매 스텝 자기검증
과 원 의도 재검증이 초기 오가정의 복리화를 막는다. 벤더·조직·모델·수치는 보류.

## IRREVERSIBLE_ACTION_INTENT_GATE (행위측, docs-level)

바로 위 MID_RUN_INTENT_RECHECK 는 런 전체를 **스텝 경계마다 스스로** 되짚는다. 본 절은
**개별 비가역 행동 직전 1회**, **실행자가 아닌 검사자**가 그 행동을 원 요청문과 대조한다
— 시점(주기 vs 행동 직전)도 주체(자기점검 vs 분리 검사자)도 달라 두 앵커는 병존한다.
기존 세 층 — 입력측(`policies/credential-hygiene.md` INGRESS_TRUST_CHECKPOINT), 부류측
(같은 파일 NEVER_APPROVE_CLASS), 피로측(`policies/harness-autonomy.md`
APPROVAL_FATIGUE_DECAY) — 은 **허용 부류 안에 있으면서 원 요청과 방향이 다른 행동**을
셋 다 통과시킨다.

- **대상**: 취소가 새 행동을 요구하는 것 — 발송 · 게시 · 제출 · 결제 · 삭제 · 강제 push.
- **입력**: 원 요청문과 AC. 행동이 둘 중 어느 것으로도 설명되지 않으면 불일치이고, 불일치면 진행하지 않고 surface 한다.
- **검사자 분리 필수**: 실행자의 자기신고는 게이트가 아니다. `policies/harness-autonomy.md` 의 verifier != implementer 를 재사용하며 새 검사 기구를 만들지 않는다. 분리 검사자를 못 세우는 런은 그 행동을 자동으로 하지 않는다.
- **행동 직전 1회**: 세션 초입의 승인은 한 시간 뒤 행동의 근거가 아니다.

invariant registry 에 행을 추가하지 않으며 verdict/exit 는 양방향 불변인
documentation-level 계약이다. 신뢰 구역 선행(SHADOW_MODE_TRUST_LADDER)과 세션이 원장에
사는 성질(EVENT_LOG_RECONSTRUCTION_SSOT + DONE_IS_ARTIFACT_ON_DISK)은 기커버라
재기안하지 않는다. 외부 검증 (by-reference): 자동 승인 하에서도 결과가 큰 행동 직전에
별도 검사가 원 요청과 대조해 차단하는 층 (Claude 블로그, 2026-08-12); 브라우저 · 확장
· 사이드 패널 · 제품명 · 플랜명 보류.

## HONEST_UNKNOWNS (docs-level)

진단 산출물 — triage, root-cause 분석, healthcheck/flowcheck 부속 리포트, 장애
분석 — 은 **확신도와 미확인 항목을 명시**한다: 무엇이 검증됐고(증거 경로),
무엇이 추정이며(확신도), 무엇을 아직 안 봤는지(unverified 목록). **"첫
그럴듯한 결론에서 멈춤"**(confident first-plausible answer)은 drift finding
으로 분류한다 — 신뢰를 깨는 안티패턴은 오답 자체가 아니라 오답을 확신으로
포장하는 것이고, "모르는 것은 모른다"고 말하는 진단이 자율성 신뢰의 전제다.
미확인 항목 명명은 unknowns 프리플라이트의 사후 짝이다
(`unknowns-and-deviations.md` known-unknowns). verdict/exit 는 어느 방향으로도
불변 — 새 critical invariant 가 아니라 아래 verifier-context-split 과 같은
documentation-level 계약이다. 외부 검증 (by-reference): frontier-lab 사례
(Claude blog, 2026-07-10) — root cause 를 짚되 모르는 것을 모른다고 말하는
것이 장시간 무인 자율성 신뢰의 근거 중 하나; vendor 디테일 보류.

## RUNTIME_EVIDENCE_COVERAGE (docs-level)

HONEST_UNKNOWNS 는 한 산출물 안에서 모르는 것을 말하게 한다. 그 사후 짝은 **원장 자체의
공백**이다: 증거 계약이 적용되는 런타임 목록과 **known-blind 런타임 목록**을 **함께**
선언한다. 한쪽만 적힌 선언은 선언이 아니다.

- **covered** — `sfs event` 버스를 타 `events.jsonl` 에 남는 런타임: 대화형 세션,
  CLI 세션, 같은 rail 을 타는 무인 스케줄 러너.
- **known-blind** — 안 남거나 부분만 남는 런타임: 제품 밖 호스트 UI 에서만 끝난 작업,
  파일버스만 거친 보조 검토, 외부 오케스트레이터가 자체 실행하고 결과만 넣은 구간.
- 선언되지 않은 런타임의 완료 주장은 **unverified** — 거짓이 아니라 원장이 뒷받침하지 않는다는 뜻이다. 외부 SIGNAL 주입 seam 은 커버리지 티어를 함께 실어야 하고, 티어 없는 유입은 원장 권위를 흐린다 (`policies/external-orchestrator-entry.md`).
- 런타임별 증거는 **run 단위로 합쳐 읽을 수 있어야** 한다 — 신규 계약이 아니라 위 EVENT_LOG_RECONSTRUCTION_SSOT + DONE_IS_ARTIFACT_ON_DISK 의 재확인이다.

verdict/exit 양방향 불변. additive 확장 규율(VERSIONED_EXTENSION_SURFACE)과 접근키 ·
신원(`policies/credential-hygiene.md` AGENT_IDENTITY / GRANT_LIFECYCLE)은 기커버라
재기안하지 않는다. 외부 검증 (by-reference): 세션 1건을 통합 증거 레코드로 반환하면서
**커버리지 제외 목록을 본문에 명시**한 커버리지 확대 공지 (Claude 블로그, 2026-08-11);
제품 · API 명, 규정준수 프로그램명, 클라우드 제공자명, 플랜명 보류.

## REASONING_LOG_AS_AUDIT_ARTIFACT (docs-level, 위험 티어 한정)

solon 은 **무엇을 만들었는지**(plan/report/deviations)는 계약하지만 **왜 그렇게
판단했는지**의 흔적은 리뷰어 재량으로 남겨 둔다. **최상위 위험 티어에 한해** 그
흔적도 산출물로 계약한다 — `harness-autonomy.md` PRE_WORK_INVARIANT_DECLARATION
의 사후 짝이다. 사전 선언은 "무엇을 지킬 것인가"를, 추론 로그는 "가는 길에 무엇을
저울질하고 무엇을 버렸는가"를 남기므로, 리뷰어가 판단을 재구성하지 않고 감사할 수
있다. 위 HONEST_UNKNOWNS 와도 짝이다 — 그쪽은 확신도와 미확인을 말하게 하고,
이쪽은 도달한 판단의 경로를 남긴다.

**전면 적용 아님 — 조건부가 설계다.** 발동 조건은
`work-delegation-and-startup.md` DELEGATION_UNIT_LADDER 의 위험 티어 상단(파괴적
· 마이그레이션급 작업, 장시간 무인 런)이며, 새 티어를 만들지 않고 그 티어링을
그대로 재사용한다. 그 밖에서는 꺼 둔다: 일상 작업의 추론 로그는 아무도 읽지 않을
감사를 위해 반복 토큰 비용을 내는 것이고, 좋은 관행이 의례로 굳는 경로가 그것이다.
로그는 기존 증거 표면(workbench 산출물 또는 capsule `output_paths`)에 실린다 —
새 파일 클래스도, 새 명령도 없다. verdict/exit 불변, signal-only.

샌드박스 선행 실행과 인간 승인 게이트는 Gate 6 · capsule 계약이 이미 커버하므로
재기안하지 않는다. 외부 검증 (by-reference): 공동 개발된 리스크 분석 에이전트
(Claude blog, 2026-08-06) — 추론 과정 로그 자체를 감사 산출물로 삼는다; 회사명 ·
업권 · 자산군 서술 보류.

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
