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

Windows PowerShell 사용자는 Git for Windows 의 Git Bash 가 필요하다. PowerShell 에서는
`.sfs-local\scripts\sfs.ps1 status` 처럼 wrapper 를 쓰면 되고, wrapper 는 내부에서
Git Bash 를 찾아 `.sfs-local/scripts/sfs-dispatch.sh` 로 넘긴다. WSL 사용자는 WSL shell
안에서 `bash .sfs-local/scripts/sfs-dispatch.sh status` 처럼 직접 실행한다. 순수
PowerShell-only 환경은 아직 지원선 밖이다.

**5초 mental model**:
- **본인이 편집** = `SFS.md`, `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`. 이 4개는 너의 프로젝트 정체성을 담는다.
- **건드리지 마** = `.claude/`, `.gemini/`, `.agents/`, `.sfs-local/scripts/`, `.sfs-local/sprint-templates/`, `.sfs-local/personas/`, `.sfs-local/decisions-template/`. 다음 `upgrade.sh` 실행 시 덮어써진다.
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

## 2. 다음 5분 — 첫 상태 확인 + sprint start

쓰는 LLM CLI 환경에 따라 셋 다 동등하게 작동한다 (paraphrase 금지, 결정성 보장):

| 환경 | 첫 명령 |
|:--|:--|
| Claude Code | `/sfs status` (slash popup) |
| Gemini CLI | `/sfs status` (slash popup) |
| Codex app / Codex CLI | `$sfs status` 또는 `sfs status` |

아래 예시는 Solon 기준 `/sfs` 표기입니다. Claude Code 와 Gemini CLI 에서는 그대로 쓰면 된다.
Codex app/CLI 에서 bare `/sfs` 를 입력했을 때 `커맨드 없음` 또는 `Unrecognized command` 가
뜨면 Solon 이 실행된 것이 아니라 host slash parser 가 메시지를 모델 전에 차단한 것이다.
그 경우 Codex 에서는 `$sfs start ...`, `$sfs plan`, 자연어, direct bash 를 쓴다.

처음 실행하면 다음과 비슷한 1줄 dashboard 가 나온다:

```
sprint - · WU - · gate -:- · ahead 0 · last_event -
```

대시는 "아직 sprint 시작 안 함" 이라는 뜻. 첫 sprint workspace 시작:

```text
/sfs start "todo 앱 v0 — 일정 추가/완료/삭제 + Postgres 저장"
```

이러면:
1. `.sfs-local/sprints/2026-W18-sprint-1/` 같은 디렉토리가 생긴다 (ISO 주차 자동 명명).
2. `brainstorm.md` / `plan.md` / `log.md` / `review.md` / `retro.md` 5개 sprint file 이 복사된다.
3. `events.jsonl` 에 `sprint_start` 이벤트 1줄 append.
4. `.sfs-local/current-sprint` 에 sprint id 저장.

---

## 3. 다음 10분 — brainstorm → plan

먼저 raw 요구사항과 대화 맥락을 `brainstorm.md` 에 남긴다. Claude/Codex/Gemini 같은
AI runtime 에서 `/sfs brainstorm` 으로 실행하면 두 단계가 한 번에 이어진다.

1. bash adapter 가 raw input 을 `§8 Append Log` 에 안전하게 기록한다.
2. Solon CEO 가 그 raw 를 읽고 `§1~§7` 을 채운다. 부족한 정보가 있으면 1~3개 질문을 한다.

```text
/sfs brainstorm "아직 정리 안 된 요구사항, 제약, 아이디어"
```

긴 내용을 붙여넣는 CLI 환경에서는 direct bash 로 stdin 을 써도 된다:

```bash
bash .sfs-local/scripts/sfs-brainstorm.sh --stdin < requirements.txt
```

direct bash 는 raw capture-only 이다. AI 없이 bash 를 직접 실행했다면, 다음에 AI runtime 에서
`/sfs brainstorm` 을 한 번 더 실행해서 기존 `§8 Append Log` 를 CEO refinement 로 정리한다.

그 다음 brainstorm 을 plan 계약으로 바꾼다. AI runtime 에서 `/sfs plan` 은
`plan.md ready` 만 출력하고 끝나는 명령이 아니라, bash adapter 로 G1 파일을 연 뒤
`brainstorm.md` 를 읽어 요구사항/AC/scope 와 CTO/CPO sprint contract 를 채워야 한다:

```text
/sfs plan
```

이러면 `plan.md` 가 열리고 frontmatter 의 `phase: plan`, `last_touched_at` 이 자동 갱신된다.
같은 sprint 의 `brainstorm.md` 에서 Solon CEO 가 채운 영역:

- **목표 (Goal)**: 이번 sprint 끝나고 무엇이 동작해야 하나? 1-2줄.
- **AC (Acceptance Criteria)**: 어떻게 동작하는 게 "끝" 인가? 3-5개 bullet.
- **범위 (In/Out of scope)**: 이번에 할 것 / 안 할 것. "안 할 것" 이 더 중요.
- **Sprint Contract**: CEO plan 을 바탕으로 CTO Generator 가 만들 것과 CPO Evaluator 가 검증할 것.
- **G1 self-check**: plan 자체가 OK 한가? (1줄 verdict)

> 💡 **plan 의 핵심 가치 = "안 할 것" 명시**. AI 가 plan 없이 코드 짜면 over-build 하기 쉽다. plan 에 "X 는 이번 sprint 에 안 한다" 고 적어두면 AI 가 그걸 읽고 안 한다.

---

## 4. 그 다음 — CTO 구현 → CPO review → CTO 확인 → retro

`plan.md §5` 의 계약에 따라 CTO Generator 가 구현한다. Claude 로 구현했다면 CPO review 는
Codex plugin/Codex CLI/Gemini CLI 같은 다른 tool 또는 별도 agent instance 를 쓰는 것을 권장한다.
이게 `/sfs` adaptor 를 만든 배경이다. 같은 명령 표면으로 여러 도구를 연결해서,
Claude 자체검증이 아니라 독립 CPO 검증을 받기 위함이다.

결정 내릴 일이 있을 때마다:

```text
/sfs decision "JWT vs 세션 — 지금은 세션 기반으로 시작 (단일 서버)"
```

→ `.sfs-local/decisions/0001-jwt-vs-session.md` 같은 ADR-style file 자동 생성.
AI runtime 에서는 여기서 끝내지 않고 sprint context 를 읽어 Context / Decision /
Alternatives / Consequences / References 를 바로 채운다.

구현이 끝나갈 때 CPO Evaluator review 를 연다:

```text
/sfs review --gate G4 --executor codex --generator claude --run
```

→ `review.md` 에 CPO persona 기반 review prompt 가 append 된다. `--run` 이 있으면 실제
bridge 실행 결과가 기록되고, `--run` 이 없고 현재 AI runtime 이 선택된 evaluator 일 때만
그 runtime 이 CPO verdict 를 직접 작성한다. CPO verdict 는 `pass` / `partial` / `fail` 로
기록한다. `partial` 또는 `fail` 이면 CTO 가 지정된 항목만 재구현하고 다시 review 를 연다.

`--run` 은 실제 bridge 가 있을 때만 성공한다. `codex` 는 `SFS_REVIEW_CODEX_CMD` 또는
`codex exec --full-auto` 를 사용한다. Claude 내부 Codex plugin 은 shell 에서 직접 호출할 수
없으므로 `SFS_REVIEW_CODEX_PLUGIN_CMD` 같은 bridge 를 설정하거나, `--print-prompt` 로 나온
prompt 를 Claude 에 연결된 Codex plugin 에 넘겨야 한다.

Codex/Claude/Gemini CLI 는 인증 prompt 가 먼저 뜨면 SFS 가 넘긴 review prompt 를 auth 답변으로
소비할 수 있다. 그래서 SFS 는 `.sfs-local/auth.env` 를 자동 로드하고 `/sfs auth` 로
인증 상태를 먼저 확인한다. `.sfs-local/auth.env.example` 을 복사해서 API key 또는
`SFS_CODEX_AUTH_READY=1` / `SFS_CLAUDE_AUTH_READY=1` / `SFS_GEMINI_AUTH_READY=1` 을 넣어라.
real terminal 에서는 `/sfs auth login --executor gemini` 처럼 브라우저/터미널 인증을
명시적으로 끝낼 수 있다. bridge 연결만 확인할 때는 `/sfs auth probe --executor gemini --timeout 20` 가
작은 dummy request/response 만 보낸다. 실제 `.sfs-local/auth.env` 는 gitignore 대상이다.

반대 방향도 비대칭이다. Codex 로 구현한 뒤 Claude 리뷰를 받으려면 Codex 가 Claude plugin 을
부르는 방식이 아니라, 설치된 Claude CLI 를 bridge 로 사용한다:

```text
/sfs review --gate G4 --executor claude --generator codex --run
```

Claude CLI bridge 가 없으면 `--print-prompt` 로 CPO prompt 를 뽑아서 Claude 에 handoff 한다.
`--executor claude-plugin --run` 같은 경로는 지원하지 않는다. Codex 는 Claude plugin host 가 아니다.

sprint 완전히 끝났으면:

```text
/sfs retro --close
```

→ AI runtime 에서는 먼저 `retro.md` 를 KPT/PDCA 로 채우고, 그 다음 close adapter 를 1회
실행해 sprint close + auto-commit 까지 처리한다 (push 는 안 함, 너가 직접).

> ⚠️ `--close` 는 review 한 번이라도 한 sprint 에서만 동작. review 안 했으면 exit 8 + 메시지 출력.

---

## 5. 10 슬래시 명령 cheatsheet

Claude/Gemini 에서는 `/sfs ...` 를 그대로 쓴다. Codex app/CLI 에서는 현재 bare `/sfs` 가
native slash UI 에서 `커맨드 없음` 으로 막힐 수 있으므로 `$sfs ...` Skill mention 이 실사용
1급 경로다. direct bash 는 항상 deterministic fallback 이다.

| 명령 | 한 줄 설명 |
|:--|:--|
| `/sfs status` | 지금 어디까지 왔는지 1줄 |
| `/sfs start <goal>` | 새 sprint workspace 초기화 |
| `/sfs brainstorm [text]` | G0 raw 기록 + Solon CEO 맥락 정리 |
| `/sfs guide` | 처음 쓸 때 필요한 맥락과 다음 명령 확인 |
| `/sfs guide --path` | 이 onboarding guide 경로만 확인 |
| `/sfs guide --print` | 이 guide 본문을 터미널에 출력 |
| `/sfs auth status` | Codex/Claude/Gemini review executor 인증 확인 |
| `/sfs auth probe --executor gemini --timeout 20` | bridge request/response 더미 확인 |
| `/sfs plan` | 현 sprint 의 의도/경계 + G1 요구사항/AC + CTO/CPO 계약 작성 |
| `/sfs review --gate G4 --executor codex --run` | 리뷰할 evidence 가 있을 때 CPO review bridge 실행 + 결과 기록 |
| `/sfs decision <title>` | ADR-style 결정 기록 + AI runtime 에서 ADR 본문 작성 |
| `/sfs retro [--close]` | 회고 작성 / `--close` 는 회고 작성 후 sprint close + auto-commit |
| `/sfs loop` | 큰 작업 자율 진행 (Ralph Loop, 고급) |

Codex 에서는 같은 명령을 `$sfs status`, `$sfs start ...`, `$sfs brainstorm ...` 처럼 입력한다.

각 명령 자체에 `--help` 있음:

```bash
bash .sfs-local/scripts/sfs-status.sh --help
bash .sfs-local/scripts/sfs-guide.sh --help
```

Windows PowerShell 에서는:

```powershell
.\.sfs-local\scripts\sfs.ps1 status
.\.sfs-local\scripts\sfs.ps1 guide --print
```

---

## 6. Multi-vendor — 어디서든 동작

본인이 어떤 LLM CLI 를 쓰든 **같은 bash adapter (`.sfs-local/scripts/sfs-*.sh`)** 가 SSoT. paraphrase 안 하니 결과 동일성 보장.

| LLM CLI | 진입점 |
|:--|:--|
| Claude Code | `.claude/commands/sfs.md` (자동 install) |
| Gemini CLI | `.gemini/commands/sfs.toml` (자동 install) |
| Codex | `.agents/skills/sfs/SKILL.md` (자동 install, project-scoped Skill; `$sfs ...` 권장) |
| Codex CLI bypass (선택, legacy prompt) | `~/.codex/prompts/sfs.md` (manual `cp`, 지원 build 에서 `/prompts:sfs ...`) |

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

`scripts/`, `sprint-templates/`, `personas/`, `decisions-template/`, `.claude/commands/sfs.md`, `.gemini/commands/sfs.toml`, `.agents/skills/sfs/SKILL.md` = 자동 갱신 (배포판 관리 영역).

`.sfs-local/sprints/`, `.sfs-local/decisions/`, `.sfs-local/events.jsonl` = **절대 덮어쓰지 않음**.

### 8.5 `upgrade.sh` 가 "이미 최신" 이라는데 새 명령이 없어

local clone 방식으로 설치했다면 `~/tmp/solon-product` 같은 product clone 이 upgrade 의 배포판
소스다. GitHub 에 새 release 가 있어도 이 clone 이 오래됐으면 낡은 `VERSION` 을 읽고
"이미 최신" 이라고 보일 수 있다.

먼저 product clone 을 최신화한 뒤 프로젝트에서 upgrade 를 다시 실행:

```bash
git -C ~/tmp/solon-product pull --ff-only --tags
cd ~/workspace/my-project
bash ~/tmp/solon-product/upgrade.sh
```

remote one-liner (`curl .../upgrade.sh | bash`) 는 매번 GitHub main 을 새로 clone 하므로 이
local clone freshness 문제를 피한다.

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
