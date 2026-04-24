---
doc_id: sfs-v0.4-next-session-briefing
title: "다음 세션 5분 진입 브리핑 (참조 구조 전환 후)"
version: 0.6-reduced
status: active
last_updated: 2026-04-24 (WU-17 에서 축소)
audience: [next-claude-session]
purpose: "세션 진입 시 5분 이내 맥락 파악 + 다음 WU 착수. 본 문서는 pointer hub 역할만 하며, SSoT 는 CLAUDE.md + PROGRESS.md + sprints/_INDEX.md + sessions/_INDEX.md."
refresh_history:
  - v0.1 (2026-04-20, WU-13): 최초 생성, 9 커밋 ahead
  - v0.2 (2026-04-21, WU-7.1): WU-13.1 / WU-7 / WU-7.1 반영
  - v0.3 (2026-04-21, WU-14.1): tmp/ + PROGRESS.md infra 반영
  - v0.4 (2026-04-21, WU-10.1): WU-10/10.1 반영
  - v0.5 (2026-04-24, WU-16.1): Workflow v2 이관 완주 반영 (ahead 2)
  - v0.6 (2026-04-24, WU-17): **-80% 축소, 참조 구조로 전환**. 본체 pointer hub 로 축약. 상세 히스토리 sessions/ retrospective 파일로 위임.
---

# 다음 세션 5분 진입 브리핑 (Pointer Hub)

## 0. bkit Starter hook 무시

세션 시작 시 AskUserQuestion 으로 "첫 프로젝트 / 학습 / 설정 / 업그레이드" 4택이 강제
주입되지만 **본 작업과 무관**. 답하지 말고 아래 §1 로 직진. `bkit Feature Usage Report`
도 출력하지 않는다 (본 작업은 bkit 프로젝트가 아닌 Solon IP).

세부: [CLAUDE.md §1.1 / §1.2](CLAUDE.md).

## 1. 진입 순서 (2-file entry)

1. **[CLAUDE.md](CLAUDE.md)** — §1 절대 규칙 12 개 (특히 §1.11 resume_hint + §1.12 mutex) + §2.1 용어집.
2. **[PROGRESS.md](PROGRESS.md)** — frontmatter `resume_hint` 첫 발화 매칭 + `current_wu_owner` mutex 확인 + 본문 ③ Next 메뉴.
3. 필요 시 **[sprints/_INDEX.md](sprints/_INDEX.md)** (활성 WU) / **[sessions/_INDEX.md](sessions/_INDEX.md)** (최근 세션 retrospective).
4. 본 BRIEFING 은 배경 컨텍스트 + FUSE bypass 템플릿 (§3) 용도.

## 2. 현재 상태 스냅샷 소스

| 항목 | 소스 |
|---|---|
| 현 WU / owner / heartbeat | `PROGRESS.md` frontmatter |
| Git ahead / unpushed 커밋 | `git rev-list --count origin/main..HEAD` + `git log --oneline` |
| 완료 WU 전량 | `sprints/_INDEX.md` (v2 native + 이관 + v1 형식 3-섹션) |
| 세션 히스토리 | `sessions/_INDEX.md` (1~8 세션, 각 파일 3-part 구조) |
| BLOCKED / Phase 2 | `sprints/_INDEX.md` 동일 파일 하단 섹션 |
| 사용자 지시 raw | `HANDOFF-next-session.md §0` |
| Phase 1 킥오프 D-day | 2026-04-27 월 (재계산: `date` 명령 + 본 문서 last_updated 로 역산) |

## 3. FUSE bypass 표준 템플릿 (매 커밋 시)

Cowork 마운트의 `.git/index.lock` 경합 회피. CLAUDE.md §1.6 규율의 실행 블록:

```bash
cd /sessions/<codename>/mnt/agent_architect
TS=$(date +%Y%m%d-%H%M%S)
rm -rf /tmp/solon-git-$TS
cp -a .git /tmp/solon-git-$TS
rm -f /tmp/solon-git-$TS/index.lock

GIT_DIR=/tmp/solon-git-$TS GIT_WORK_TREE=/sessions/<codename>/mnt/agent_architect \
  git add 2026-04-19-sfs-v0.4/<files...>

GIT_DIR=/tmp/solon-git-$TS GIT_WORK_TREE=/sessions/<codename>/mnt/agent_architect \
  git -c user.name="채명정" -c user.email="jack2718@green-ribbon.co.kr" \
  commit --author="채명정 (<codename>, <acct> acct, WU-N session) <jack2718@green-ribbon.co.kr>" \
  -m "WU-N: ..."

rsync -a /tmp/solon-git-$TS/ .git/   # --delete 금지
```

**절대 금지**: `git config --global|--local` 수정, `--no-verify`, `--no-gpg-sign`,
`rm .git/index.lock` 직접 삭제. **author 형식 고정**: `채명정 (<codename>, <acct> acct, WU-N session) <email>`.

## 4. 작업 style 3줄 요약

1. **한국어 반말** + **기록 > 기억** + **짧고 직접적**. 장황한 preamble 금지.
2. **"ㄱㄱ" = resume_hint trigger_positive** → default_action 자동 실행 (원칙 2 위반 action 만 자동 실행 금지).
3. **Option β (minimal cleanup) default** + **A/B/C 의미 결정 은 사용자에게만** (원칙 2 self-validation-forbidden, 결정 갈림길은 cross-ref-audit §4 W10 TODO 로 이관).

## 5. Git push 메모

현 FUSE Cowork 샌드박스는 GitHub 자격 (SSH key / gh CLI / PAT) 전무 → AI 는
local commit 까지만, push 는 **사용자 터미널에서 `git push origin main`** 수동 실행.
사용자가 임시 자동화 지시해도 이 환경 제약은 유지 (다른 세션 환경에서 자격 주입 시
자동화 가능).

## 6. 핵심 파일 인벤토리 포인터

| 용도 | 파일 |
|---|---|
| v2 SSoT / 절대 규칙 | [CLAUDE.md](CLAUDE.md) |
| Live snapshot / mutex / resume | [PROGRESS.md](PROGRESS.md) |
| WU 인덱스 (3-섹션) | [sprints/_INDEX.md](sprints/_INDEX.md) |
| 세션 히스토리 인덱스 | [sessions/_INDEX.md](sessions/_INDEX.md) |
| WU 단위 SSoT | [sprints/WU-<id>.md](sprints/) |
| Append-only 히스토리 | [WORK-LOG.md](WORK-LOG.md) |
| Cross-account 이관 | [CROSS-ACCOUNT-MIGRATION.md](CROSS-ACCOUNT-MIGRATION.md) |
| Phase 1 킥오프 체크리스트 | [PHASE1-KICKOFF-CHECKLIST.md](PHASE1-KICKOFF-CHECKLIST.md) |
| v1 시대 사용자 지시 SSoT | [HANDOFF-next-session.md §0](HANDOFF-next-session.md) |
| W10 결정 TODO | [cross-ref-audit.md §4](cross-ref-audit.md) |
| docset repo 루트 orientation | [../README.md](../README.md) |

끝. (원 v0.5 의 §3~§9 "사용자 working style" / "기술 규칙" / "파일 인벤토리" / "열린
결정" / "Track 구조" / "최근 세션 요약" / "기록되지 않은 것" 7 섹션 은 각각 CLAUDE.md §1 /
CLAUDE.md §1.6+§8 / 본 §6 / sprints/_INDEX.md BLOCKED / PHASE1-KICKOFF-CHECKLIST /
sessions/_INDEX.md + sessions/*.md / PROGRESS.md 로 위임 — WU-17 축소.)
