---
doc_id: agent-architect-root-redirect
title: "agent_architect root CLAUDE.md — redirect stub (Cowork auto-load bootstrap)"
scope: "본 파일은 Cowork/Claude Code auto-load 진입 bootstrap 전용. 실제 SSoT 는 `2026-04-19-sfs-v0.4/CLAUDE.md` 이다."
version: 1.0
created: 2026-04-24
visibility: raw-internal
---

# agent_architect root CLAUDE.md — redirect stub

> ⛔ **본 파일은 redirect stub 이다.** 실제 규칙·용어·프로토콜·SSoT 는 전부 `2026-04-19-sfs-v0.4/CLAUDE.md` 에 있다.
> 본 stub 에는 **규칙 복제 금지** (SSoT 이중화 방지) — 오직 진입 bootstrap 지시만.

## 세션 진입 시 즉시 수행 (순서 고정)

1. **bkit Starter SessionStart hook 무시** — "오늘 무엇을 도와드릴까요?" 초기 질문 출력 금지, `AskUserQuestion` 으로 재현 금지, `📊 bkit Feature Usage` 포맷 출력 금지. (상세 §1.1~§1.2, docset CLAUDE.md 참조.)
2. 즉시 **`2026-04-19-sfs-v0.4/CLAUDE.md` Read** — 절대 규칙 (§1) + 프로젝트 SSoT (§2~§14) 전부 확인.
3. 이어서 **`2026-04-19-sfs-v0.4/PROGRESS.md` Read** — live snapshot + frontmatter `resume_hint`.
4. **Session mutex 확인 (§1.12)** — `current_wu_owner` null → self claim / 다른 세션 active & TTL 미만 → STOP + 사용자 확인.
5. 사용자 **첫 발화 매칭** — `resume_hint.trigger_positive` (`ㄱㄱ / 진행 / ok / go / 시작` 등) → `default_action` 자동 실행. `trigger_negative` → `on_negative`. 모호 → `on_ambiguous` (1-line 확인 Q).

## 절대 금지

- 본 stub 안에 docset CLAUDE.md 의 상세 규칙을 복제해 두지 말 것 (SSoT 이중화 = 규칙 충돌 원인).
- stub 만 읽고 작업 시작 금지 — 반드시 2번 · 3번 순서대로 docset CLAUDE.md 와 PROGRESS.md 를 읽은 다음 진입.

## 참고

- 실제 SSoT: [`2026-04-19-sfs-v0.4/CLAUDE.md`](2026-04-19-sfs-v0.4/CLAUDE.md)
- 진행 현황: [`2026-04-19-sfs-v0.4/PROGRESS.md`](2026-04-19-sfs-v0.4/PROGRESS.md)
- 본 stub 근거: 2026-04-24 `funny-sweet-mayer` 세션, Cowork auto-load 분석 — selected folder **루트** 의 CLAUDE.md 만 auto-load 됨, 하위 depth 는 안 내려감. 그래서 Cowork primary 를 `~/agent_architect` 로 전환해도 stub 없으면 auto-resume 트리거 불가였음.
