---
doc_id: solon-product-policy-session-transfer-autopilot
title: "Session transfer autopilot — Continuation Guard 가 걸렸을 때의 규약"
visibility: oss-public
doc_type: maintenance-policy
language: ko
updated: 2026-05-29
summary: "Don't ask whether to /clear or open a new session. Drop a durable handoff first (with the full sync surface enumeration), then invoke whatever host-native transfer control exists."
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

## Durable handoff artifact — mandatory sync surface

(2) 의 "durable handoff / report" 는 단순 메모가 아니다. 다음 표면을 **모두**
실제 상태와 일치시켜야 한다. 누락 1건은 다음 세션 인계가 stale 상태로
시작한다는 뜻이며, 0.6.141 → 0.7.9 ledger lag (16 release) 가 그 결과다.

필수 sync surface (release-bearing project 기준):

1. **product VERSION** — `solon-mvp-dist/VERSION` 의 현재 값.
2. **CHANGELOG headline** — 가장 최근 release section (`## [X.Y.Z]`) 의
   첫 `> **요약 줄**` 또는 동등 줄.
3. **PROGRESS.md `last_completed_release`** — `version` / `source_main` /
   `evidence_closure` / `product_commit` / `product_tag` 가 위 (1)(2) 와
   일치하는지.
4. **PROGRESS.md `recent_session_owner_history`** — 마지막 release 이후
   세션이 모두 행으로 들어가 있는지. `released_at` 가 시간순으로 정렬
   돼 있는지.
5. **PROGRESS.md `resume_hint.default_action`** — 옛 release 의
   follow-up 을 가리키고 있지는 않은지 (예: 0.7.9 시점에 0.6.114
   monitor stall guard 를 default 로 가리키고 있으면 stale).
6. **HANDOFF-next-session.md** — 한 단락 stub 으로 (a) 현재 main
   sha/branch, (b) active WU (없으면 명시), (c) 다음 한 step 의 mode
   (C-Cowork / D-Code) 와 trigger 발화를 포함.
7. **sessions/_INDEX.md** — 마지막 release 이후 모든 session codename
   행 prepend (역시간순). `updated:` frontmatter 날짜도 갱신.
8. **200-line policy 준수 상태** — 위 (3)(6)(7) 파일 각각이
   `templates/.sfs-local-template/context/policies/md-line-budget.md`
   의 warn(180) / partial(200) / fail(250) 안에 있는지. 넘었다면
   archive 회전 후 위 sync 적용.

생략 가능 표면 (project-specific, 없으면 skip):

- `NEXT-SESSION-BRIEFING.md` (legacy briefing doc; 0.7.x 이후 신규
  프로젝트에선 안 만든다).
- 학습-log per-month index (변경 없으면 skip).
- domain_locks_summary (활성 lock 변동 없으면 skip).

handoff 작성자는 위 1~8 을 명시적으로 PASS / mismatch / N/A 로 마크해야
하고, mismatch 1건이라도 있으면 `sfs handoff verify` (0.7.10+) 가 fail.

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
