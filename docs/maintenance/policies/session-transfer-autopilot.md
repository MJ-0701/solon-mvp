---
doc_id: solon-product-policy-session-transfer-autopilot
title: "Session transfer autopilot — Continuation Guard 가 걸렸을 때의 규약"
visibility: oss-public
doc_type: maintenance-policy
language: ko
updated: 2026-05-28
summary: "Don't ask whether to /clear or open a new session. Drop a durable handoff first, then invoke whatever host-native transfer control exists."
load_when: "Read when Session Continuation Guard fires, or when implementing a new agent runtime that needs to handle session boundaries."
---

# Session transfer autopilot

본 문서는 0.7.2 이전 CLAUDE.md § 배포 원칙 6 의 풀-문장 형태를 떼어내 분리한
maintenance policy doc 이다. release-policy.md 가 본 문서를 cross-link 로
참조한다.

## 규약

Session Continuation Guard 가 걸리면:

1. **같은 세션 / 새 세션 선택을 사용자에게 묻지 않는다**. `/clear` 를 입력
   하라고 묻지도 않는다.
2. **먼저 durable handoff / report 를 남긴다**. 다음 5개 정보 포함:
   - current branch
   - current commit (`HEAD` SHA)
   - working tree status (`git status -sb`)
   - 진행 중인 작업의 evidence path (sprint dir, decision file, ...)
   - exact next-session prompt (사용자가 새 세션에서 그대로 paste 할 수
     있는 한 줄)
3. **host-native transfer / new-session / archive / clear+resume 제어가
   있으면 직접 호출**해 새 세션에서 즉시 이어간다.
4. **resume 없는 bare clear 는 금지**. 사용자가 이어갈 수 있는 다리를
   먼저 만들고 끊는다.
5. host 제어가 없으면 (5) 의 exact next-session prompt 만 남기고 멈춘다.

## 왜 이 규약이 있나

이전 세션에서 `/clear` 를 묻는 데 시간이 흘러가고, 사용자가 응답하지 않은
사이 컨텍스트가 잘려서 작업 흐름이 끊긴 적이 있었다. continuation guard 가
이미 "지금 컨텍스트가 위험" 이라고 알려주는데, 그 시점에 사용자에게 다시
물어보는 건 신호를 한 번 더 잃는 행동이다. 즉시 durable artifact 를 남기고
host-native 제어로 넘기는 게 사용자 경험에도 일관성 면에서도 더 안전하다.

## host 제어가 없을 때의 fallback

다음 메시지를 사용자에게 정확히 보여준다:

```
Session Continuation Guard hit. Drop your current session and open a new
one. In the new session, paste:

    <exact next-session prompt>

Handoff written to:
    <durable handoff path>
```

해당 fallback 메시지 자체는 agent 행동의 일부이므로 CLAUDE.md / SFS.md /
agent adapter docs 의 do-not-inline 룰에 위배되지 않는다 — 본 정책 문서가
canonical text 이고, agent 는 link 만 본다.
