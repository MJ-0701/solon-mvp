---
id: sfs-policy-sub-agent-capsule-contract-ko
summary: kernel·runtime-token-firewall 가 prose 로 참조하는 capsule-only worker/sub-agent 핸드오프의 구조화 필드 계약.
load_when:
  - capsule
  - sub-agent
  - subagent
  - worker handoff
  - tool scope
  - token budget
  - agent capsule
status: filled-v1
parent_doc: policies/runtime-token-firewall.md
content_policy: "lead 가 worker / sub-agent / external executor 로 작업 slice 를 넘길 때, 또는 agent-build review lens 가 핸드오프를 검사할 때 읽는다"
---

# 서브에이전트 Capsule 계약

`runtime-token-firewall.md` 는 capsule-only 핸드오프를 요구하고 `kernel.md` 는
capsule 필드를 prose 로 명시한다. 본 pack 은 그 prose 를 검사 가능한 필드 계약으로
바꿔, worker/sub-agent 핸드오프를 서술이 아니라 검증할 수 있게 한다. 새 lifecycle
command 가 아니라 기존 capsule-only 규칙 뒤의 스키마이며, `agent-build` review lens
가 핸드오프 시 검사한다.

## 필수 필드

lead/C-Level 에이전트가 worker·reviewer·external executor 로 넘기는 capsule 은 다음
필드를 가진다. 하나라도 빠지면 편의가 아니라 핸드오프 finding 이다.

| 필드 | 의미 |
|---|---|
| `goal` | worker 가 달성할 결과 한 문장. |
| `acceptance_criteria` | pass/fail 을 결정하는 테스트 가능 조건. vibe 금지. |
| `files_scope` | worker 가 읽고 편집해도 되는 명시 경로/glob. 그 밖은 금지. |
| `tools_allowed` | 좁은 tool/permission 집합. 나머지는 default-deny. |
| `output_paths` | worker 가 `status` / `result` / `evidence` / touched-file manifest 를 쓰는 위치. |
| `token_budget` | 예상 output-token 상한. 초과는 product finding (firewall §budget). |
| `timeout` | wall-clock 상한. 도달 시 partial 반환 + 부족 artifact 명시. |
| `pii_rules` | worker 가 닿는 user/workspace 데이터의 redaction/persistence 규칙. |

## 핸드오프 규칙

- Capsule-only: lead 의 전체 대화 history·hidden chain·무관 이전 turn 을 절대
  forward 하지 않는다 (`runtime-token-firewall.md` 참조).
- worker 의 생각이 아니라 `output_paths` 의 artifact 를 poll 한다. evidence 부족 시
  worker 는 partial/fail 반환 + 부족 artifact 명시.
- 이 필드를 표현 못 하는 bridge (예: 전체 chat 을 상속하는 forked-context helper)
  는 default executor 가 아니라 manual escape hatch 다.
- 검증자 ≠ 저작자: `acceptance_criteria` 를 검증하는 agent 는 저작 agent 와 동일
  인스턴스여서는 안 된다 (자기평가 편향). "다른 agent" 는 기본적으로 다른
  인스턴스를 뜻하고, 모델 다양성(Codex/Gemini)은 per-capsule 필드가 아니라 Gate 6
  cross-CPO 에서만 요구한다.

## 검증 (agent-build lens)

핸드오프 시 `agent-build` review lens 가 검사한다: 필수 필드 전부 존재,
`files_scope`·`tools_allowed` 가 좁은지 ("do anything" 금지), `token_budget`·
`timeout` 설정, `pii_rules` 가 tool 이 닿는 데이터를 커버, `output_paths` 가 구체적인지,
그리고 검증 agent 가 저작자와 다른 인스턴스인지. 빠지거나 unbounded 한 필드는 pass 가
아니라 fix 동반 finding 이다.
