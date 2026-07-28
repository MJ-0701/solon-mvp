---
id: sfs-policy-md-line-budget-ko
summary: 활성 markdown 은 loadable 상태로 유지. 운영 로그, routed context, top-level project doc, 사용자 작성 장문 md 는 파일당 200줄 이하; 초과분은 archive 로, flatten 으로 누르지 않는다.
load_when: ["writing", "readme", "progress", "handoff", "session index", "200줄", "md 청소", "log retention", "운영 로그", "routed context", "policy doc", "wiki", "guide", "report", "학습노트"]
---

# MD 라인 한도 정책

Agent 가 context 에 로드하는 — 또는 사람이 리뷰에서 끝까지 읽어야 하는 —
markdown 에는 명확한 크기 천장이 있다. 천장을 넘는 순간 그 파일은
"로드 가능한 산출물" 이 아니라 "아카이브된 증거" 로 분류해야 한다.

## 임계값

- **warn**: 180줄 (쿠션. 활성 파일은 이 선을 넘기 전 회전해야 함).
- **partial**: 200줄 (크기 위반. harness doctor 가 보고하고, scope 안
  contract test 가 fail).
- **fail**: 250줄 (쿠션을 넘은 위반. 릴리즈 블로커).

임계값은 파일 단위. 600줄짜리 PROGRESS.md 한 개와 200줄짜리 6개는 같은
위반이다 — 해결은 archive 회전이지, 여러 파일로 쪼개는 flatten 이 아니다.

## 적용 범위 (scope)

200줄 천장이 적용되는 대상:

- `templates/.sfs-local-template/context/**/*.md` (routed context / skill /
  policy / kernel doc).
- product distribution 루트 top-level `*.md` (`SFS.md`, `CLAUDE.md`,
  `AGENTS.md`, `GEMINI.md`, `README.md`, `GUIDE.md`, agent adapter doc).
- **운영 로그** — 릴리즈 ledger, session history, scheduled task trace,
  handoff state 를 시간순으로 append/overwrite 하는 파일. 실제 인스턴스:
  `PROGRESS.md`, `HANDOFF-next-session.md`, `NEXT-SESSION-BRIEFING.md`,
  `sessions/_INDEX.md`, sprint 단위 `handoff*.md` stub, learning-log
  월별 index.
- **사용자 작성 장문 md** — agent 가 작업하는 프로젝트 안의 README /
  GUIDE / 학습노트 / 보고서 / retro / postmortem. 천장이 이 파일들의
  loadable 상태를 유지해 준다; 긴 사고는 link 된 child doc 으로.

## 적용 제외 (예외 리스트)

다음은 의도적으로 200줄을 초과하며, 정책 위반이 아니다:

- `CHANGELOG.md`, `RELEASE-NOTES.md` — append-only 릴리즈 로그. 기존
  harness 는 이 두 파일이 *반드시* 200줄을 *넘어야* release-log
  exception 으로 인정되는지 확인한다.
- `QA-REPORT-*.md`, `INTEGRATION-VERIFY-*.md` — 1회용 evidence doc.
  frontmatter check 는 그대로 적용 (LLM 이 shape 를 잡을 수 있도록),
  크기는 무제한.
- `tests/` fixture 및 기타 test data.
- 모든 `archives/`, `.sfs-local/archives/`,
  `docs/solon/<workspace>/<yyyyMMdd>/archive/` 경로 아래의 archived 파일.

## 초과 시 회전 (overflow rotation)

scope 안 파일이 200줄을 넘기면, **archive 회전**으로 해결한다. evidence 를
잃는 강제 압축은 금지:

1. 현재 파일을 날짜 archive 경로에 복사:
   - 운영 로그 (PROGRESS / HANDOFF / sessions/_INDEX / handoff stub) →
     `.sfs-local/archives/operational-log/<yyyyMMdd>/<원본파일명>` 또는
     workspace docset 에서는
     `docs/solon/<workspace>/<yyyyMMdd>/archive/<원본파일명>`.
   - routed context / top-level / 사용자 장문 → 가장 가까운 archive
     패턴; 없으면 `archives/<doc-kind>/<yyyyMMdd>/` 신설.
2. 활성 파일을 **다음만 남기고** 다시 쓴다: 활성 WU, 현재 sprint 포인터,
   미해결 결정, 최근 N 개 session/release row (N 은 작게 — 보통 3~8),
   현재 handoff state.
3. 활성 파일 안에 `history_archive:` (또는 동등 포인터) 를 두어 옛 row 가
   어디로 갔는지 agent 가 안다.
4. 닫힌 scheduled task trace, 보류된 domain lock, 옛 release evidence 도
   archive 로.

실무 기준 `recent N`: PROGRESS.md 는 약 5~8 session row, sessions/_INDEX
는 최근 약 15 ledger row, HANDOFF 는 최근 단일 handoff body, learning-log
index 는 이번 달 + 지난 달.

## ARTIFACT_FITS_IN_HEAD

ceiling 은 서식 취향이 아니라 SFS 의 모든 분해 표면이 공유하는 설계 근거다.
읽는 사람이 머리에 담을 수 없는 산출물은 아무도 리뷰할 수 없는 산출물이라,
루프가 출발점(리뷰 불가 출력)으로 되돌아간다. 같은 근거가 — 재기술이 아니라
by-reference 로 — thin agent entry (어댑터 문서는 포인터만, 본문은 routed
context) 와 capsule 분해 (`sub-agent-capsule-contract.md`) 를 받친다. 표면은
셋, 이유는 하나다. 새 산출물 종류를 추가할 때 물을 것은 "몇 줄까지 되는가"
가 아니라 "한 사람이 담을 수 있는가" 이고, 그 답이 예산을 정한다. 외부검증
(by-reference): 결정론 커널 관련 Claude 블로그(2026-07-21) — 머리에 안 담기는
출력은 작업을 원점으로 되돌린다. 벤더·제품명은 보류.

## 이 정책이 필요한 이유

이 정책이 없을 때 반복되는 두 가지 실패:

- 운영 로그가 조용히 자란다. PROGRESS.md 가 16 release lag (455줄)
  까지 자라야 Cowork 세션이 알아챈 사례, HANDOFF 가 18 release 동안
  stale 인 채로 유지된 사례. routed policy 가 ceiling 을 가지지 않아서
  agent 가 그 파일을 쓸 때 룰을 prompt 안에서 보지 못했다.
- contract test 는 routed context 와 top-level doc 의 ceiling 은 이미
  잠가두지만, 운영 로그와 사용자 장문 md 는 test scope 밖이었다. 0.7.10
  promotion 이 scope 를 정책에 맞춰 넓힌다.

## Harness 강제

- 기존 contract: `tests/test-product-md-frontmatter-line-budget.sh`
  (top-level) + `tests/test-context-md-split-frontmatter.sh` (routed
  context) 가 자기 scope 안 ceiling 을 잠근다.
- 0.7.10 확장: `sfs harness doctor` 에 `md-line-budget-violation`
  detector 추가 — 정책 scope 전체를 walk 하며 path 별 warn/partial 카운트
  보고. contract test 가 없는 프로젝트도 위반을 본다.
- 0.7.10 은 `operational-log-lag` detector 도 추가한다 — sibling 실패인
  제품 `VERSION` 과 PROGRESS.md `last_completed_release.version`
  간 release lag 검출용.

## 관련 정책

- `context-pollution-guard.md` — durable context 를 얇게 유지. 본 정책은
  그 의도를 숫자 ceiling 으로 강제.
- `session-transfer-autopilot.md` — handoff durable artifact 목록에
  본 정책이 다루는 운영 로그가 명시되어, 크기 강제와 handoff 완결성이
  같이 간다.
