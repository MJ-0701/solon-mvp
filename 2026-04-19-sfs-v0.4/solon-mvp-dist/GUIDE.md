# Solon Product — 사용 가이드 (친구 onboarding 30분)

> install.sh 실행한 직후 30분 안에 첫 sprint 를 돌려보는 walk-through.
> 본 가이드는 "왜 이런 file 이 생겼는지", "처음 어디부터 손대야 하는지", "내가 알아야 할 핵심 file 4개", 그리고 "내일도 이걸 쓸 이유" 까지 다룬다.

---

## 0. 설치는 끝났다. 이제 뭐 할 차례?

`install.sh` 가 끝나면 너의 프로젝트 루트에 다음이 새로 생겨 있다.

```
my-project/
├── SFS.md                       ← 살아있는 운영 문서 (본인이 편집)
├── CLAUDE.md                    ← Claude Code adapter (본인이 편집)
├── AGENTS.md                    ← Codex adapter (본인이 편집)
├── GEMINI.md                    ← Gemini CLI adapter (본인이 편집)
├── .claude/commands/sfs.md      ← Claude Code 슬래시 (배포판 관리, 건드리지 마)
├── .gemini/commands/sfs.toml    ← Gemini CLI 슬래시 (배포판 관리, 건드리지 마)
├── .agents/skills/sfs/SKILL.md  ← Codex Skill (배포판 관리, 건드리지 마)
├── .sfs-local/                  ← sprint / decision / event 로그가 쌓이는 곳
└── .gitignore                   ← Solon 마커 블록 자동 추가
```

**5초 mental model**:
- **본인이 편집** = `SFS.md`, `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`. 이 4개는 너의 프로젝트 정체성을 담는다.
- **건드리지 마** = `.claude/`, `.gemini/`, `.agents/`, `.sfs-local/scripts/`, `.sfs-local/sprint-templates/`, `.sfs-local/decisions-template/`. 다음 `upgrade.sh` 실행 시 덮어써진다.
- **쌓이는 곳** = `.sfs-local/sprints/`, `.sfs-local/decisions/`, `.sfs-local/events.jsonl`. 너의 작업 기록이 누적된다. 절대 자동 덮어쓰지 않는다.

---

## 1. 첫 5분 — `SFS.md` placeholder 치환 (가장 흔한 오해 1번)

> ❓ **친구가 자주 묻는 것**: "SFS.md 는 운영 지침인데 거기다 프로젝트 스택을 적어도 되나?"
>
> ✅ **답**: 적는 게 맞다. SFS.md 는 **이 프로젝트의 SFS 운영 지침** 이고, 프로젝트별로 stack / 도메인 / 배포 환경이 다르니 그걸 제일 위에 박아두는 게 정합. 다음 cycle 의 너 (또는 AI agent) 가 SFS.md 첫 줄만 읽고 "아 이 프로젝트는 Next.js + Postgres + Vercel 이구나" 바로 파악할 수 있게.

`SFS.md` 를 열면 맨 위에 5개 placeholder 가 보인다:

```markdown
- **이름**: `<PROJECT-NAME>`
- **도메인**: `<DOMAIN>` (프로젝트가 다루는 문제 영역)
- **단계**: MVP (Phase 1), greenfield, 7-step lightweight spike 운용.
- **Stack**: `<STACK>` (주요 런타임 / 언어 / 프레임워크)
- **DB**: `<DB>` (데이터 저장소 / persistence 전략)
- **배포**: `<DEPLOY>` (배포 / 운영 환경)
```

다음처럼 치환:

```markdown
- **이름**: `my-todo-app`
- **도메인**: 개인 할 일 관리 (혼자 쓰는 minimal todo)
- **단계**: MVP (Phase 1), greenfield, 7-step lightweight spike 운용.
- **Stack**: Next.js 15 App Router + TypeScript + Tailwind
- **DB**: Postgres (Neon serverless)
- **배포**: Vercel
```

`<DATE>` 와 `<SOLON-VERSION>` 은 install.sh 가 자동 치환했으므로 건드릴 필요 없음.

> ⚠️ **자주 빠지는 함정**: SFS.md 의 7-step / 7-Gate / 6 Division 본문은 **편집 금지** 가 아니라 **편집해도 되는 운영 약속** 이다. 본인 팀 이 4-Gate 만 운용하기로 했으면 `### Gate 운용` 섹션을 4-Gate 로 줄여도 된다. SFS.md 는 이 프로젝트의 Solon 운영 약속을 적어두는 곳.

---

## 2. 다음 5분 — 첫 `/sfs status` + `/sfs start`

쓰는 LLM CLI 환경에 따라 셋 다 동등하게 작동한다 (paraphrase 금지, 결정성 보장):

| 환경 | 첫 명령 |
|:--|:--|
| Claude Code | `/sfs status` (slash popup) |
| Gemini CLI | `/sfs status` (slash popup) |
| Codex | `$sfs status` (explicit Skill) 또는 자연어로 "현재 sfs 상태 알려줘" |

처음 실행하면 다음과 비슷한 1줄 dashboard 가 나온다:

```
sprint - · WU - · gate -:- · ahead 0 · last_event -
```

대시는 "아직 sprint 시작 안 함" 이라는 뜻. 첫 sprint 시작:

```text
/sfs start "todo 앱 v0 — 일정 추가/완료/삭제 + Postgres 저장"
```

이러면:
1. `.sfs-local/sprints/2026-W18-sprint-1/` 같은 디렉토리가 생긴다 (ISO 주차 자동 명명).
2. `plan.md` / `log.md` / `review.md` / `retro.md` / `decision-light.md` 5개 template 가 복사된다.
3. `events.jsonl` 에 `sprint_start` 이벤트 1줄 append.
4. `.sfs-local/current-sprint` 에 sprint id 저장.

---

## 3. 다음 10분 — `plan.md` 작성 (이게 진짜 알맹이)

```text
/sfs plan
```

이러면 `plan.md` 가 열리고 frontmatter 의 `phase: plan`, `last_touched_at` 이 자동 갱신된다. 본인이 채울 영역:

- **목표 (Goal)**: 이번 sprint 끝나고 무엇이 동작해야 하나? 1-2줄.
- **AC (Acceptance Criteria)**: 어떻게 동작하는 게 "끝" 인가? 3-5개 bullet.
- **범위 (In/Out of scope)**: 이번에 할 것 / 안 할 것. "안 할 것" 이 더 중요.
- **G1 self-check**: plan 자체가 OK 한가? (1줄 verdict)

> 💡 **plan 의 핵심 가치 = "안 할 것" 명시**. AI 가 plan 없이 코드 짜면 over-build 하기 쉽다. plan 에 "X 는 이번 sprint 에 안 한다" 고 적어두면 AI 가 그걸 읽고 안 한다.

---

## 4. 그 다음 — 구현 → review → decision → retro

평소처럼 코드 짠다. 결정 내릴 일이 있을 때마다:

```text
/sfs decision "JWT vs 세션 — 지금은 세션 기반으로 시작 (단일 서버)"
```

→ `.sfs-local/decisions/0001-jwt-vs-session.md` 같은 ADR-style file 자동 생성.

구현이 끝나갈 때:

```text
/sfs review --gate G2
```

→ `review.md` 가 열린다. "G2 (구현 entry) 자기 점검" 영역 채우고 verdict (`pass` / `partial` / `fail`) 기록.

sprint 완전히 끝났으면:

```text
/sfs retro --close
```

→ `retro.md` 작성 + sprint close + auto-commit 까지 한 번에 (push 는 안 함, 너가 직접).

> ⚠️ `--close` 는 review 한 번이라도 한 sprint 에서만 동작. review 안 했으면 exit 8 + 메시지 출력.

---

## 5. 7 슬래시 명령 cheatsheet

| 명령 | 한 줄 설명 |
|:--|:--|
| `/sfs status` | 지금 어디까지 왔는지 1줄 |
| `/sfs start <goal>` | 새 sprint 시작 또는 이어가기 |
| `/sfs plan` | 현 sprint 의 의도/경계 작성 |
| `/sfs review --gate G2` | gate verdict 기록 (G-1 / G0 / G1 / G2 / G3 / G4 / G5) |
| `/sfs decision <title>` | ADR-style 결정 기록 |
| `/sfs retro [--close]` | 회고 작성 / sprint close + auto-commit |
| `/sfs loop` | 큰 작업 자율 진행 (Ralph Loop, 고급) |

각 명령 자체에 `--help` 있음:

```bash
bash .sfs-local/scripts/sfs-status.sh --help
```

---

## 6. Multi-vendor — 어디서든 동작

본인이 어떤 LLM CLI 를 쓰든 **같은 bash adapter (`.sfs-local/scripts/sfs-*.sh`)** 가 SSoT. paraphrase 안 하니 결과 동일성 보장.

| LLM CLI | 진입점 |
|:--|:--|
| Claude Code | `.claude/commands/sfs.md` (자동 install) |
| Gemini CLI | `.gemini/commands/sfs.toml` (자동 install) |
| Codex | `.agents/skills/sfs/SKILL.md` (자동 install, project-scoped Skill) |
| Codex (선택, slash popup) | `~/.codex/prompts/sfs.md` (manual `cp` — 사용자 home 보호) |

`/sfs loop` 의 LLM 호출 부분 (자율 진행 모드) 은 `--executor claude|gemini|codex|<custom>` 로 vendor 선택:

```text
/sfs loop --executor gemini --max-iters 3
```

---

## 7. FAQ — 자주 묻는 것

### Q1. SFS.md 의 7-step / 7-Gate 본문도 편집해도 돼?

**Yes**. SFS.md 는 이 프로젝트의 SFS 운영 약속이다. 본인 팀이 G3 안 쓰기로 했으면 빼도 되고, retrospective 매주 안 하기로 했으면 그렇게 적어두면 된다. 단 **편집 결과는 다음 sprint 부터 적용** — 진행 중인 sprint 의 약속은 지키는 게 좋다.

### Q2. `.sfs-local/scripts/sfs-*.sh` 는 왜 건드리면 안 돼?

배포판 관리 영역이라 다음 `upgrade.sh` 실행 시 덮어써진다. 만약 본인 팀 만의 변형이 필요하면 별도 wrapper (`.sfs-local/scripts/my-sfs-xxx.sh`) 만들어 쓰는 걸 권장.

### Q3. `events.jsonl` 은 git 에 올려도 돼?

`.gitignore` 에 자동 추가됨 (PII / 감사 로그 혼입 위험). sprint 산출물 (`sprints/*` + `decisions/*`) 은 commit 권장 — 팀 누적 지식.

### Q4. AI 가 commit 까지 자동으로 해?

`/sfs retro --close` 만 sprint close + auto-commit 한다. 그 외 명령 (plan, review, decision) 은 file 만 작성하고 commit 은 본인이 한다. **`git push` 는 절대 자동 안 함** — 모든 vendor / Skill / slash 가 동일.

### Q5. 친구한테 보여주려면?

`.sfs-local/sprints/<sprint-id>/plan.md` + `review.md` + `retro.md` 가 본인이 한 일의 evidence. 팀에 공유하거나 이력서/포트폴리오에 link 걸 수 있다.

---

## 8. 트러블슈팅

### 8.1 `/sfs status` 가 "no .sfs-local found" 출력

설치 안 됨. `install.sh` 다시 실행 또는 `.sfs-local/` 디렉토리 존재 확인.

### 8.2 `/sfs start` 가 "sprint id conflict" 출력

같은 ISO 주차 안에 같은 번호 sprint 가 이미 있음. `--force` 로 덮어쓰거나 `--id <new-id>` 로 다른 이름.

### 8.3 `/sfs review --gate G6` 가 "unknown gate" 출력

7-Gate enum (`G-1, G0, G1, G2, G3, G4, G5`) 외 입력 거부. typo 점검.

### 8.4 `upgrade.sh` 시 본인이 편집한 file 보존돼?

`SFS.md`, `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.sfs-local/divisions.yaml` = 기본 보존 (본인 편집 가능성 큰 영역).

`scripts/`, `sprint-templates/`, `decisions-template/`, `.claude/commands/sfs.md`, `.gemini/commands/sfs.toml`, `.agents/skills/sfs/SKILL.md` = 자동 갱신 (배포판 관리 영역).

`.sfs-local/sprints/`, `.sfs-local/decisions/`, `.sfs-local/events.jsonl` = **절대 덮어쓰지 않음**.

---

## 9. 다음 단계 — 1주일 사용 후

1. `cat .sfs-local/sprints/*/plan.md` — 이번 주 의도가 어디로 갔는지 한눈에.
2. `cat .sfs-local/decisions/*.md` — 무슨 결정을 왜 했는지 ADR 쌓임.
3. `tail .sfs-local/events.jsonl` — sprint_start / plan_open / review_open / decision_created / sprint_close event timeline.
4. `/sfs retro --close` 한 번 돌려서 회고가 어떻게 자동 누적되는지 체험.
5. cycle 2~3 누적 후 `taxonomy` (도메인 용어집) / `qa` (테스트 자동화) 같은 추가 division 활성화 검토.

---

## 10. 더 깊게

- 7-step + 7-Gate 의 의미 → `SFS.md` (본인이 customize 한 본문)
- Solon Product 의 design 원칙 → [README.md](./README.md)
- 변경 이력 / 향후 plan → [CHANGELOG.md](./CHANGELOG.md)
- 문제 / 개선 제안 → https://github.com/MJ-0701/solon-product/issues

> 한 문장: **Solon 은 너가 AI 와 코드 짤 때 결정 / 검증 / 회고 / 인수인계 를 잊어버리지 않게 해 주는 운영 레이어** 다. 처음 30분 만 투자하면 그 다음부터는 자동으로 누적된다.
