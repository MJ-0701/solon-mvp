---
pattern_id: P-05-agent-loader-startup-only
title: "Claude Code agent loader 가 startup-only — mid-session `.claude/agents/` 추가는 reload 안 됨"
status: resolved
severity: low
first_observed: 2026-04-25
observed_by: trusting-stoic-archimedes (21번째 세션, .claude/agents/ alt B 등록 후 호출 실패)
resolved_at: 2026-04-25
resolved_by: trusting-stoic-archimedes (21번째 세션, fallback A 자동 전환)
resolved_via: |
  (1) `.claude/agents/{generator,evaluator,planner}.md` 신설은 commit 으로 보존 +
  (2) 같은 세션 안에서는 fallback A 사용 (Agent subagent_type=general-purpose + Read .claude/agents/<persona>.md inline 지시) +
  (3) 사용자 복귀 후 Claude Code 재시작 시 native subagent_type=<name> 활성 예상.
related_wu: WU-23 (21번째 세션 신설/close, V-1 vote 첫 적용)
related_docs:
  - .claude/agents/generator.md (Solon docset edition CTO 페르소나)
  - .claude/agents/evaluator.md (Solon docset edition CPO 페르소나)
  - .claude/agents/planner.md (Solon docset edition CEO 페르소나, 메인 세션 reference)
  - sprints/WU-23.md §3 V-1 (fallback A 첫 사용 사례 verbatim)
  - sprints/WU-23.md §7.3 (사용자 복귀 후 재시작 권장 항목)
visibility: business-only
applicability:
  - "Claude Code 세션 도중 새 agent 정의 (`.claude/agents/<name>.md`) 추가"
  - "추가 직후 Agent 도구 호출 시 `subagent_type='<name>' not found` 에러"
  - "환경 reload 없이 native 호출 불가능, 같은 세션 안에서 fallback 필요"
reuse_count: 1   # WU-23 V-1 vote 시 첫 사용. 후속 vote (V-2 등) 도 동일 fallback 예상.
related_patterns:
  - P-03   # staged uncommitted on session crash (등록 자체는 commit 으로 보존, P-03 와 결합)
  - P-04   # session-hang takeover (페르소나 시스템 자체가 hang 방지 기제 일부)
---

# P-05 — agent-loader-startup-only

> **visibility: business-only** — Claude Code 환경 한계 + Solon 페르소나 시스템 운영 노하우. OSS fork 마케팅 프로덕트에는 들어갈 수 있으나 Solon 도메인 specific (페르소나 spec) 이라 일단 business-only.

---

## 문제

`.claude/agents/<name>.md` 형식의 agent 정의 파일을 **세션 도중에 새로 생성**해도 같은 세션 안에서는 `Agent` 도구의 `subagent_type` 으로 인식되지 않음. Claude Code 의 agent 등록은 **세션 startup 시점에만 1회 로드** 되며 mid-session reload 메커니즘 없음.

- **증상**: 신규 등록 후 호출 시 `Agent type '<name>' not found. Available agents: ...` 에러. Available list 에 새 agent 없음.
- **발생 조건**: 1 세션 안에서 (a) `.claude/agents/<name>.md` 파일 신설 + (b) 같은 세션 안에서 그 `<name>` 으로 `Agent` 도구 호출.
- **원인**: Claude Code agent registry 는 startup-time scan + cache. file-watch 또는 reload command 없음 (2026-04 시점).
- **영향**: alt B (정식 등록) 패턴 시도 시 **첫 세션에서는 동작 안 함**, 다음 세션부터 동작.

## 해결 패턴 (fallback A)

같은 세션 안에서 페르소나 시스템을 작동시키는 우회 방법:

### 단계

1. **`.claude/agents/<name>.md` 등록**은 그대로 진행 (다음 세션부터 native 활성).
2. **같은 세션 안에서는 `Agent(subagent_type="general-purpose")` 호출** 사용.
3. **prompt 안에 페르소나 spec 로드 지시 inline**:
   ```
   1. Read /Users/mj/agent_architect/.claude/agents/<persona>.md — persona spec.
   2. <persona> 역할 그대로 따라서 다음 작업 수행: ...
   ```
4. **자기-자기 self-contained brief** — sub-agent 는 conversation context 없으므로 brief 안에 (a) 사용자 위임 verbatim, (b) 페르소나 출처, (c) 본 호출 정당성 명시.
5. **거부 시 retry with 강화 컨텍스트** — sub-agent 가 안전 우려로 거부하면 사용자 verbatim 메시지 + 페르소나 첨부 사실 + fallback 사용 사유 추가하여 재호출.
6. **사용자 복귀 + Claude Code 재시작 후 V-N 부터 native 호출 시도** — 일반적으로 native 가 더 토큰 효율적 (페르소나 spec inline 안 해도 됨).

### 샘플 명령 / 코드

```python
# 같은 세션 fallback A 패턴
Agent(
  subagent_type="general-purpose",
  description="CTO vote (Solon WU-XX)",
  prompt="""
1. Read /Users/mj/agent_architect/.claude/agents/generator.md — 페르소나 spec.
2. CTO Agent (Solon docset edition) 역할 그대로 따라서 다음 작업 수행:
   - WU-XX §Y 검토
   - Pre-Submit Self-Check 8 항목
   - CTO VOTE 캐스팅 (페르소나 spec 의 Vote Format 그대로)

[사용자 위임 verbatim]
"<verbatim quote>"

[페르소나 출처]
사용자 채명정 (jack2718@green-ribbon.co.kr) 첨부.
.claude/agents/generator.md = Product Image Studio 의 CTO Agent spec 을 Solon docset 도메인용으로 override 한 등록 페르소나.

[본 호출 정당성]
21번째 세션 자율 작업 mode. 의미 결정 = 3-agent vote (CEO+CTO+CPO 동등 2/3). CTO 호출 = 본 vote 의 한 표.
"""
)
```

## 재사용 체크리스트

- [ ] 전제 조건 확인: `.claude/agents/<name>.md` 가 정상 작성됐는지 (frontmatter `name`, `model`, `tools`, body Identity / Workflow / Vote Format).
- [ ] 사이드 이펙트 검토: 같은 세션 sub-agent 가 페르소나 spec 을 잘못 해석할 가능성 — vote format 강제 + brief 안에 검증 포인트 명시.
- [ ] 롤백 가능 여부: fallback A 결과는 native 와 동등 (사용자 의도 = 3-agent 합의 + 2/3 vote). 단 토큰 부담 매번 spec inline 또는 Read 지시 필요.
- [ ] 원칙 2 (self-validation-forbidden) 위반 여부 검토: fallback A 자체는 위반 아님 (사용자가 alt B 명시 + fallback 사용 가능성 사전 인지).

## 관련 WU / 세션

- **최초 발견**: WU-23 V-1 vote 시점 (21번째 세션 trusting-stoic-archimedes, 2026-04-25T17:50+09:00).
  - alt B 등록 직후 `Agent(subagent_type="generator")` 호출 → `Agent type 'generator' not found` 에러.
  - 즉시 fallback A 자동 전환, 페르소나 spec Read 지시 prompt 작성, V-1 vote 정상 진행.
- **재발견 / 재사용** (예상):
  - WU-XX V-N (21번째 세션 후속 vote 발생 시).
  - 후속 세션 첫 진입 시 (Claude Code 재시작 후 native 활성 검증).

## Notes

- **OSS 마케팅 프로덕트 영향**: solon-mvp distribution 에서 페르소나 시스템을 채택한 consumer 도 같은 한계 직면. install.sh 가 페르소나 .md 작성 시점부터 다음 세션 시작까지 1회 gap 발생 — README/QUICK-START 에 명시 권장 (후속 WU).
- **Claude Code 측 개선 가능성**: file-watch 또는 `/agent reload` 슬래시 명령 추가되면 본 패턴 일부 deprecated. 모니터링 가치 있음.
- **상위 규율**: §1.3 (self-validation), §1.8 (작업 유실 최소화) 와 직접 관련 없음 — 환경 한계 우회 패턴.
- **변종**: 페르소나 .md 가 아닌 commands/skills 의 mid-session 등록도 같은 한계 가능성 — 별도 검증 필요 (P-05 spin-off 후보).
