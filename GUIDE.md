# Solon Product — 사용 가이드 (친구 onboarding 30분)

> install.sh 실행한 직후 30분 안에 첫 sprint 를 돌려보는 walk-through.
> 본 가이드는 "왜 이런 file 이 생겼는지", "처음 어디부터 손대야 하는지", "내가 알아야 할 핵심 file 4개", 그리고 "내일도 이걸 쓸 이유" 까지 다룬다.
> SFS 는 이중 의미다. 터미널에서 쓰는 `sfs` / `/sfs` 는 표면적으로 **Sprint Flow System** 이고,
> Solon Product 전체의 SFS 는 **Solo Founder System** 이다.

---

## 0. 설치는 끝났다. 이제 뭐 할 차례?

Homebrew 또는 Scoop 으로 global runtime 을 설치한 뒤 프로젝트 루트에서 Mac/Git Bash 는
`sfs init`, Windows PowerShell/cmd 는 `sfs.cmd init` 을 실행하면 다음이 생긴다.

```bash
brew install MJ-0701/solon-product/sfs
cd ~/workspace/my-project
sfs init
sfs agent install all
```

Windows 는 Git for Windows 설치 후 Scoop 경로를 쓴다. PowerShell 에서 직접
실행할 때는 `sfs.cmd` 를 쓴다:

```powershell
scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs
cd C:\workspace\my-project
git init
sfs.cmd init --layout thin --yes
sfs.cmd status
sfs.cmd agent install all
```

```
my-project/
├── SFS.md                       ← 살아있는 운영 문서 (본인이 편집)
├── CLAUDE.md                    ← Claude Code adapter (본인이 편집)
├── AGENTS.md                    ← Codex adapter (본인이 편집)
├── GEMINI.md                    ← Gemini CLI adapter (본인이 편집)
├── .claude/skills/sfs/SKILL.md  ← Claude Code /sfs Skill (배포판 관리, 건드리지 마)
├── .claude/commands/sfs.md      ← Claude Code 슬래시 (배포판 관리, 건드리지 마)
├── .gemini/commands/sfs.toml    ← Gemini CLI sfs command (배포판 관리, 건드리지 마)
├── .agents/skills/sfs/SKILL.md  ← Codex Skill (배포판 관리, 건드리지 마)
├── .sfs-local/                  ← sprint / decision / event / config 가 쌓이는 곳
└── .gitignore                   ← Solon 마커 블록 자동 추가
```

기본 방향은 global `sfs` runtime + project-local `.sfs-local/` state 다. Windows Scoop
설치본은 PowerShell/cmd 에서 `sfs.cmd`, Git Bash/WSL 에서 `sfs` 를 노출하고, 내부 adapter 는
Git for Windows 의 Git Bash 로 내려간다. vendored layout 을 선택했을 때만
`.sfs-local\scripts\sfs.ps1 status` wrapper 를 fallback 으로 쓴다.
Claude/Gemini/Codex entry point 는 얇은 agent adapter 이므로, 새 agent 를 쓰거나
adapter 를 갱신할 때는 Mac/Git Bash 는 `sfs agent install claude|gemini|codex|all`,
Windows PowerShell/cmd 는 `sfs.cmd agent install claude|gemini|codex|all` 을 다시 실행한다.
기존 adapter 가 커스텀되어 있으면 `.sfs-local/archives/agent-install-backups/` 에 보존된다.
Solon 버전 갱신 후에는 uninstall/reinstall 대신 Mac/Git Bash 는 `sfs upgrade`,
Windows PowerShell/cmd 는 `sfs.cmd upgrade` 를 실행한다.

**5초 mental model**:
- **본인이 편집** = `SFS.md`, `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`. 이 4개는 너의 프로젝트 정체성을 담는다.
- **건드리지 마** = `.claude/`, `.gemini/`, `.agents/`. thin layout 에서는 scripts/templates/personas 는 global runtime 에 있고, project-local override 가 필요할 때만 `.sfs-local/sprint-templates/`, `.sfs-local/personas/`, `.sfs-local/decisions-template/` 에 추가한다.
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

자동으로 좁게 채우고 싶으면 AI runtime 에서는 `/sfs profile`, direct shell 에서는
`sfs profile --apply` 를 실행한다. 이 명령은 허용된 설정/docs 파일만 보고 `SFS.md` 의
`## 프로젝트 개요` 섹션만 수정한다.

> ⚠️ **자주 빠지는 함정**: SFS.md 의 7-step / 7-Gate / 6 Division 본문은 **편집 금지** 가 아니라 **편집해도 되는 운영 약속** 이다. 본인 팀 이 4-Gate 만 운용하기로 했으면 `### Gate 운용` 섹션을 4-Gate 로 줄여도 된다. Solon report 에서는 Gate 1~7 표기를 쓰고, 새 CLI 예시도 `--gate 6` 처럼 1~7 숫자를 쓴다.

---

## 2. 다음 5분 — 첫 상태 확인 + sprint start

쓰는 LLM CLI 환경에 따라 셋 다 동등하게 작동한다 (paraphrase 금지, 결정성 보장):

| 환경 | 첫 명령 |
|:--|:--|
| Claude Code | `/sfs status` (slash popup) |
| Gemini CLI | `sfs status` |
| Codex CLI | `$sfs status` |
| Codex app | `$sfs status` 또는 `/sfs status` 가 host 에서 모델까지 전달되는 경우 |
| Windows PowerShell 직접 실행 | `sfs.cmd status` |

아래 예시는 Claude Code 기준 `/sfs` 표기입니다. Gemini CLI 에서는 slash 없이 `sfs ...` 로,
Codex CLI 에서는 `$sfs ...` 로 입력한다. bare `/sfs` 를 입력했을 때 `커맨드 없음` 또는
`Unrecognized command` 가 뜨면 Solon 이 실행된 것이 아니라 host slash parser 가 메시지를 모델
전에 차단한 것이다. Windows PowerShell 에서 agent 밖 direct shell 로 실행할 때는
`sfs.cmd start ...`, `sfs.cmd plan` 처럼 쓴다.

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
2. `brainstorm.md` / `plan.md` / `implement.md` / `log.md` / `review.md` / `retro.md` 6개 workbench file 이 복사된다. `report.md` 는 완료 시점에 만든다.
3. `events.jsonl` 에 `sprint_start` 이벤트 1줄 append.
4. `.sfs-local/current-sprint` 에 sprint id 저장.

`/sfs start` 는 workspace 생성까지만 담당한다. 그 다음이 항상 `brainstorm` 인 것은 아니다.
새 요구를 처음 탐색하는 sprint 는 `brainstorm → plan` 으로 가고, 직전 sprint 의 plan/ADR 을
이어받아 구현하는 sprint 는 `log.md` 또는 `plan.md` 에 `inherit-from: <prior sprint/ADR>` 와
이번 AC 만 얇게 남긴 뒤 바로 첫 구현 slice 로 들어간다.

이미 오래 진행된 legacy 프로젝트라면 첫 sprint 전에 한 번만 baseline 을 만든다:

```text
/sfs adopt --apply
```

`adopt` 는 두 극단을 모두 전제로 한다. 문서가 너무 많으면 남겨야 할 것만 visible 하게 두고,
기존 sprint/archive 문서 숲은 `.tar.gz` cold archive 와 짧은 manifest 로 접는다. 문서가 하나도
없으면 git/code/test/docs 흔적에서 최소한의 baseline 을 복원한다. 결과적으로
`.sfs-local/sprints/legacy-baseline/` 에는 `report.md` + `retro.md` 만 남고, raw scan evidence 와
이전 sprint/archive 원문은 `.sfs-local/archives/adopt/` 아래에 압축 보존된다.

---

## 3. 다음 10분 — shared understanding → brainstorm → plan

먼저 raw 요구사항과 대화 맥락을 `brainstorm.md` 에 남긴다. Claude/Codex/Gemini 같은
AI runtime 에서 `/sfs brainstorm` 으로 실행하면 두 단계가 한 번에 이어진다.

1. bash adapter 가 raw input 을 `§8 Append Log` 에 안전하게 기록한다.
2. Solon CEO 가 그 raw 를 읽고 `§0~§7` 을 채운다. 부족한 정보가 있으면 1~3개 질문을 한다.

Gate 2 (Brainstorm) 의 목적은 raw 요구를 예쁘게 받아 적는 것이 아니라, plan 으로 넘기기 전에 공유 이해를
만드는 것이다. AI 시대의 기본 guardrail 은 여기서 이미 시작된다: 공유 design concept,
domain language, 작은 feedback loop, public interface/artifact boundary, gray-box 위임 경계.
이 중 plan 에 필요한 항목이 비어 있으면 `/sfs plan` 으로 넘어가지 않고 질문부터 한다.

```text
/sfs brainstorm "아직 정리 안 된 요구사항, 제약, 아이디어"
```

긴 내용을 붙여넣는 CLI 환경에서는 direct CLI 로 stdin 을 써도 된다:

```bash
sfs brainstorm --stdin < requirements.txt
```

direct CLI 는 raw capture-only 이다. AI 없이 직접 실행했다면, 다음에 AI runtime 에서
`/sfs brainstorm` 을 한 번 더 실행해서 기존 `§8 Append Log` 를 CEO refinement 로 정리한다.

그 다음 brainstorm 을 plan 계약으로 바꾼다. AI runtime 에서 `/sfs plan` 은
`plan.md ready` 만 출력하고 끝나는 명령이 아니라, bash adapter 로 Gate 3 (Plan) 파일을 연 뒤
`brainstorm.md` 를 읽어 요구사항/AC/scope 와 CTO/CPO sprint contract 를 채워야 한다. Gate 2 의
blocking question 이 남아 있으면 추측으로 메우지 않고 질문을 유지한다:

```text
/sfs plan
```

이러면 `plan.md` 가 열리고 frontmatter 의 `phase: plan`, `last_touched_at` 이 자동 갱신된다.
같은 sprint 의 `brainstorm.md` 에서 Solon CEO 가 채운 영역:

- **목표 (Goal)**: 이번 sprint 끝나고 무엇이 동작해야 하나? 1-2줄.
- **AC (Acceptance Criteria)**: 어떻게 동작하는 게 "끝" 인가? 3-5개 bullet.
- **범위 (In/Out of scope)**: 이번에 할 것 / 안 할 것. "안 할 것" 이 더 중요.
- **Sprint Contract**: CEO plan 을 바탕으로 CTO Generator 가 만들 것과 CPO Evaluator 가 검증할 것.
- **AI-era fundamentals**: 용어, feedback loop, interface boundary, gray-box 위임 경계.
- **Gate 3 self-check**: plan 자체가 OK 한가? (1줄 verdict)

> 💡 **plan 의 핵심 가치 = "안 할 것" 명시**. AI 가 plan 없이 코드 짜면 over-build 하기 쉽다. plan 에 "X 는 이번 sprint 에 안 한다" 고 적어두면 AI 가 그걸 읽고 안 한다.

> 📌 **문서 생명주기**: 진행 중에는 `brainstorm.md`, `plan.md`, `implement.md`,
> `log.md`, `review.md` 가 노트패드처럼 길어질 수 있다. Sprint 완료 전에는
> `/sfs report` 로 한 장짜리 `report.md` 를 만들고, `/sfs retro --close` 또는
> `/sfs tidy --apply` 가 workbench 문서와 tmp review 산출물을 archive 로 이동한다. 회고/히스토리는 `retro.md` 가 담당한다.
> 기존 sprint 문서를 나중에 정리할 때는 `/sfs tidy --sprint <id-or-ref>` 로 먼저 dry-run 을 보고,
> `/sfs tidy --sprint <id-or-ref> --apply` 를 실행한다. `W18-sprint-1` 같은 고유 suffix 는
> `2026-W18-sprint-1` 로 해석된다. 초기 버전처럼 `report.md` 가 없으면
> 먼저 생성하고, 원문 workbench/tmp 산출물은 삭제하지 않고 `.sfs-local/archives/` 로 이동한다.
> 핵심은 "남겨야 할 것만 남긴다" 이다.

이미 직전 planning sprint 에서 plan/review/ADR 이 통과했다면, 다음 implementation sprint 에서
같은 Gate 2/3 을 다시 두껍게 반복하지 않는다. 그때의 `brainstorm.md`/`plan.md` 는 새 결정을
생산하는 문서가 아니라 인수인계 pointer 다. 예: "inherit-from: 2026-W18-sprint-2/plan.md,
scope: backlog 1~3, AC: compose up / API boot / DB health / manifest schema pass".

반대로 sprint goal 자체가 `repo scaffold`, `dev compose`, `DB schema`, `API boot`, 테스트,
UI 동작, taxonomy 정리, design handoff, QA evidence, infra/runbook 같은 실행 산출물을 말하고
있다면 Gate 3 계약만으로 sprint 를 완료했다고 부르면 안 된다. 그 경우 완료 조건은 실제 artifact
변경, `log.md` evidence, smoke/test/review 결과, Gate 6 (Review), retro 까지다.

### 3.5 `/sfs implement` 로 첫 실행 slice 를 AI-safe 하게 시작하기

Solon 에서 첫 구현은 "스펙을 던지고 코드가 나오길 기다리는 일" 이 아니다.
`/sfs implement` 는 `implement.md` 와 `log.md` 를 열고, AI runtime 이 실제 작업 slice 와
검증 evidence 까지 남기도록 하는 실행 진입점이다. 코드 변경은 중요한 산출물이지만 유일한
산출물은 아니다. taxonomy, design handoff, QA evidence, infra/runbook, decision, docs 도
implementation artifact 다. AI 는 눈앞의 변경에는 빠르지만, 전체 design concept / domain
language / feedback loop 가 약하면 같은 프로젝트를 점점 더 바꾸기 어렵게 만들 수 있다.
그래서 이 절의 guardrail 은 implement 에서 처음 등장하는 규칙이 아니라, Gate 2/3 에서 만든
공유 이해와 계약을 실제 artifact 로 검증하는 규칙이다.

첫 execution sprint 는 아래 순서로 작게 시작한다:

1. **하네스 4원칙 고정**
   - Think Before Execution: 가정/선택지/성공 기준을 짧게 잡고 모호하면 질문한다.
   - Simplicity First: AC 를 증명하는 최소 artifact surface 로 간다.
   - Surgical Changes: 요청 slice 와 직접 연결된 줄만 바꾼다.
   - Goal-Driven Execution: 산출물 + 검증 evidence + review handoff 까지를 완료 기준으로 둔다.
2. **기존 프로젝트 규칙 확인**
   - "이 프로젝트의 폴더 구조, naming, 테스트/리뷰 방식, 상태 관리 방식, artifact 패턴을 요약해줘."
   - 새 구조를 만들기 전에 기존 규칙을 먼저 따른다.
3. **도메인 용어 고정**
   - `plan.md` 에 핵심 명사/행위자/상태/규칙을 적는다.
   - 예: `Course`, `Week`, `Artifact`, `ExamRange`, `GateSession`.
   - AI 에게 "이 용어를 코드, docs, UI label, 테스트, 보고서에서 같은 의미로 써라" 고 지시한다.
4. **피드백 계약 먼저 만들기**
   - 구현 전에 "무엇이 통과하면 끝인가" 를 3~5개로 적는다.
   - 코드면 test-first 를 우선하고, 비코드면 smoke check, design review, taxonomy drift check,
     CLI output check, 수동 inspection 도 가능하다.
5. **Solon division guardrails 분류**
   - strategy-pm, taxonomy, design/frontend, dev/backend, QA, infra 를 always-on / trigger-based / scale-gated 로 짧게 분류한다.
   - Backend Transaction discipline 은 always-on 이다. DB, Spring/JPA, Spring Batch, external API, MQ/event, idempotency, state, consistency path 가 닿으면 Transaction boundary, `REQUIRES_NEW`, JPA first-level cache, Batch chunk TX, outbox/idempotency/order/history, Hikari pool pressure, test depth 를 확인한다.
   - Security / Infra / DevOps 는 sprint/project scope 에서 `light` / `full` / `skip` 만 묻는다. MVP-overkill 은 구현을 막지 말고 `deferred` 또는 `risk-accepted` 로 기록한다.
6. **가장 작은 slice 실행**
   - 한 번에 feature 전체를 만들지 않는다.
   - 하나의 AC 를 증명하는 최소 변경만 한다.
7. **review 에서 artifact 보다 의도를 검증**
   - "파일이 바뀜" 이 아니라 domain intent, project regularity, feedback evidence,
     user-visible behavior 를 본다.

```text
/sfs implement "첫 실행 slice"

AI-safe first slice =
existing pattern + domain term + feedback contract + one small behavior + review action
```

하네스 4원칙과 도메인/피드백 계약은 여기서 거창한 방법론이 아니라 AI 가 프로젝트를
망가뜨리지 않게 하는 안전장치다.

---

## 4. 그 다음 — CPO review → CTO 확인 → retro

`/sfs implement` 로 artifact 와 evidence 가 생긴 뒤 CPO review 를 연다. 기본 계약은 CTO 구현
agent 와 별도 CPO role/agent/instance 가 분리되어야 한다는 것이다. cross-vendor review
(Codex/Claude/Gemini 교차 검증) 는 유용하지만 필수는 아니다. 같은 runtime 또는 같은 도구만
쓰는 사용자도 별도 CPO instance 가 evidence 를 읽고 verdict/findings/required CTO actions 를
남기면 독립 CPO 검증으로 다룬다. 이게 `/sfs` adaptor 를 만든 배경이다. 여러 도구 사용을
강제하는 token-heavy workflow 가 아니라, 어떤 review 경로든 역할 분리와 evidence 를 남기기 위함이다.

결정 내릴 일이 있을 때마다:

```text
/sfs decision "JWT vs 세션 — 지금은 세션 기반으로 시작 (단일 서버)"
```

→ `.sfs-local/decisions/0001-jwt-vs-session.md` 같은 ADR-style file 자동 생성.
AI runtime 에서는 여기서 끝내지 않고 sprint context 를 읽어 Context / Decision /
Alternatives / Consequences / References 를 바로 채운다.

구현이 끝나갈 때 CPO Evaluator review 를 연다. 아래는 cross-vendor 예시이고, 같은 runtime 의
별도 CPO instance 를 쓰는 것도 같은 계약으로 유효하다:

```text
/sfs review --gate 6 --executor codex --generator claude
```

→ 이 명령은 Gate 6 (Review) 를 실행한다. full CPO prompt 는 `.sfs-local/tmp/review-prompts/` 에 저장되고, `review.md` 에는
`prompt_path` 와 크기, 실행 결과 요약만 남는다. 명령 출력에는 verdict/output path
메타데이터만 짧게 표시되고, AI runtime 은 result 원문을 사용자의 언어로 요약해
verdict/findings/required CTO actions 를 Solon report 로 보여준다.
기본 동작은 실제 bridge 실행이고, 수동 handoff 만 필요하면 `--prompt-only` 로 prompt/log 만
만든다. 이미 실행된 리뷰를 다시 보려면 `/sfs review --show-last [--gate 6]` 를 사용한다. Solon report 는 이 gate 를 `Gate 6 (Review)` 로 표시한다.
CPO verdict 는 `pass` / `partial` / `fail` 로 기록한다. `partial` 또는
`fail` 이면 CTO 가 지정된 항목만 재구현하고 다시 review 를 연다.

기본 review 실행은 실제 bridge 가 있을 때만 성공한다. `codex` 는 `SFS_REVIEW_CODEX_CMD` 또는
`codex exec --full-auto --ephemeral --output-last-message <result> -` 를 사용한다. Claude 내부 Codex plugin 은 shell 에서 직접 호출할 수
없으므로 `SFS_REVIEW_CODEX_PLUGIN_CMD` 같은 bridge 를 설정하거나, `--prompt-only` 로 나온
prompt 를 Claude 에 연결된 Codex plugin 에 넘겨야 한다.

Codex/Claude/Gemini CLI 는 인증 prompt 가 먼저 뜨면 SFS 가 넘긴 review prompt 를 auth 답변으로
소비할 수 있다. 그래서 SFS 는 `.sfs-local/auth.env` 를 자동 로드하고, 각 runtime 의 SFS entry
(`/sfs auth`, `sfs auth`, `$sfs auth`) 로 인증 상태를 먼저 확인한다. `.sfs-local/auth.env.example` 을 복사해서 API key 또는
`SFS_CODEX_AUTH_READY=1` / `SFS_CLAUDE_AUTH_READY=1` / `SFS_GEMINI_AUTH_READY=1` 을 넣어라.
direct shell 에서는 `sfs auth login gemini` 또는 `sfs auth login --executor gemini` 처럼 브라우저/터미널 인증을
명시적으로 끝낼 수 있다. bridge 연결만 확인할 때는 `sfs auth probe --executor gemini --timeout 20` 가
작은 dummy request/response 만 보낸다. 실제 `.sfs-local/auth.env` 는 gitignore 대상이다.

Windows Store 로 설치된 Codex 는 `C:\Program Files\WindowsApps\OpenAI.Codex_...\app\resources\codex.exe`
패키지 내부 파일을 직접 실행하면 access denied 가 날 수 있다. `SFS_REVIEW_CODEX_CMD` 를
직접 지정할 때는 그 경로 대신 `codex exec ...` App Execution Alias 또는
`/c/Users/<you>/AppData/Local/Microsoft/WindowsApps/codex.exe` 처럼 실행 가능한 shim 을 사용한다.
CLI 가 없고 앱만 있는 executor 는 자동 review bridge 로 사용할 수 없다. 이 경우
`/sfs review --gate <1..7> --executor <tool> --prompt-only` 로 prompt 파일을 만든 뒤 앱에
수동으로 붙여넣거나, 설치된 다른 CLI executor 를 사용한다.

반대 방향도 비대칭이다. Codex 로 구현한 뒤 Claude 리뷰를 받으려면 Codex 가 Claude plugin 을
부르는 방식이 아니라, 설치된 Claude CLI 를 bridge 로 사용한다:

```text
/sfs review --gate 6 --executor claude --generator codex
```

Claude CLI bridge 가 없으면 `--prompt-only` 로 CPO prompt 를 뽑아서 Claude 에 handoff 한다.
`--executor claude-plugin` 같은 경로는 지원하지 않는다. Codex 는 Claude plugin host 가 아니다.

sprint 완전히 끝났으면 먼저 최종 작업보고서를 만든다:

```text
/sfs report
```

AI runtime 에서는 sprint workbench 문서와 review evidence 를 읽고 `report.md` 를 한 장짜리
완료 보고서로 채운다. 이미 닫힌 과거 sprint 를 정리할 때는 사용자 동의 후 명시적으로 실행한다:

```text
/sfs report --sprint <sprint-id>
# report.md 확인/수정 후
/sfs tidy --sprint <sprint-id-or-ref> --apply
```

현재 sprint close:

```text
/sfs retro --close
```

→ AI runtime 에서는 먼저 `retro.md` 를 KPT/PDCA 로 채우고 `report.md` 를 최종보고서로
정리한 뒤 close adapter 를 1회 실행한다. 이때 workbench 문서와 tmp review 산출물은 archive 로 이동하고,
sprint close + auto-commit 까지 처리된다. 이후 branch push/main 흡수는 AI runtime 이
Git Flow lifecycle 로 처리한다.

> ⚠️ `--close` 는 review 한 번이라도 한 sprint 에서만 동작. review 안 했으면 exit 8 + 메시지 출력.

---

## 5. 주요 SFS 명령 cheatsheet

Claude Code 에서는 `/sfs ...`, Gemini CLI 에서는 `sfs ...`, Codex CLI 에서는 `$sfs ...` 가
공식 호출이다. Codex app 에서는 `$sfs ...` 또는 `/sfs ...` 가 host 에서 모델까지 전달되는 경우를
쓴다. Windows PowerShell direct shell 에서는 `sfs.cmd ...` 를 쓴다. direct bash 는 항상
deterministic fallback 이다.

| 명령 (Claude 표기) | 한 줄 설명 |
|:--|:--|
| `/sfs status` | 지금 어디까지 왔는지 1줄 |
| `/sfs start <goal>` | 새 sprint workspace 초기화 |
| `/sfs brainstorm [text]` | Gate 2 (Brainstorm) raw 기록 + 공유 design concept/domain language/feedback/boundary 정리, 부족하면 질문 |
| `/sfs guide` | 처음 쓸 때 필요한 맥락과 다음 명령 확인 |
| `/sfs guide --path` | 이 onboarding guide 경로만 확인 |
| `/sfs guide --print` | 이 guide 본문을 터미널에 출력 |
| `/sfs profile [--prompt-only|--apply]` | SFS.md 프로젝트 개요만 좁게 감지/보정 |
| `/sfs auth status` | Codex/Claude/Gemini review executor 인증 확인 |
| `/sfs auth login codex` | Codex CLI 인증 bootstrap |
| `/sfs auth probe --executor gemini --timeout 20` | bridge request/response 더미 확인 |
| `/sfs division list` | dev/strategy-pm/qa/design/infra/taxonomy 활성 상태 확인 |
| `/sfs division activate design` | abstract 디자인 본부를 실행 가능한 active 본부로 승격하고 decision/event 기록 |
| `/sfs division activate all` | 현재 abstract 인 모든 본부를 한 번에 active 로 승격 |
| `/sfs adopt [--apply]` | legacy 프로젝트 인수인계 baseline 생성. 문서 과잉은 기존 sprint/archive tree 를 cold archive 로 접고, 문서 0은 report-first baseline 복원 |
| `/sfs plan` | 현 sprint 의 의도/경계 + Gate 3 (Plan) 요구사항/AC + CTO/CPO 계약 작성, Gate 2 질문은 추측으로 덮지 않음 |
| `/sfs implement [work slice]` | plan 기반 작업 slice 실행 + 하네스 4원칙 + 도메인/피드백 계약 + 6-division guardrail ledger + evidence 기록. 코드, taxonomy, design handoff, QA, infra/runbook, decision, docs 모두 artifact 로 취급 |
| `/sfs review --gate 6 --executor codex` | Gate 6 (Review) evidence 가 있을 때 CPO review bridge 실행 + 결과 기록 |
| `/sfs review --show-last` | executor 재실행 없이 마지막 CPO review 결과를 요약/action report 로 확인 |
| `/sfs decision <title>` | ADR-style 결정 기록 + AI runtime 에서 ADR 본문 작성 |
| `/sfs report [--sprint <id>] [--compact]` | 최종 작업보고서 생성 / 동의 후 workbench archive |
| `/sfs tidy [--sprint <id-or-ref>\|--all] [--apply]` | 기존 sprint workbench/tmp 를 archive 로 이동하고 남길 문서만 유지. `W18-sprint-1` 같은 고유 suffix 참조 가능 |
| `/sfs retro [--close]` | 회고 작성 / `--close` 는 회고+보고서 작성 후 archive + sprint close + auto-commit |
| `/sfs commit plan` | close 후 남은 working tree 분류 + Git Flow branch preflight 안내 |
| `/sfs commit apply --group product-code` | 선택 그룹만 local commit. Git Flow-aware Conventional Commit 메시지 자동 생성, `-m` override 가능. 이후 branch push/main 흡수는 AI runtime 이 수행 |
| `/sfs loop` | 큰 작업 자율 진행 (queue-first Ralph Loop, 고급) |
| `/sfs loop enqueue "작업" --size large --target-minutes 90` | queue 에 loop task 등록 |
| `/sfs loop queue` | queue pending/claimed/done/failed/abandoned count + stale claimed 확인 |
| `/sfs loop claim --owner <name>` | pending task 하나를 worker 가 claim |
| `/sfs loop verify <task>` | claimed task 의 `## Verify` command 를 실행하고 done/failed 처리 |
| `/sfs loop complete|fail|retry|abandon <task>` | queue lifecycle 수동 마무리 / 재시도 / 포기 |

Gemini 에서는 같은 명령을 `sfs status`, `sfs start ...`, `sfs brainstorm ...` 처럼 입력한다.
Codex 에서는 `$sfs status`, `$sfs start ...`, `$sfs brainstorm ...` 처럼 입력한다.

각 명령 자체에 `--help` 있음. Windows PowerShell/cmd 에서는 `sfs.cmd` 로 바꿔 입력한다:

```bash
sfs status --help
sfs guide --help
```

vendored layout 의 Windows PowerShell fallback:

```powershell
.\.sfs-local\scripts\sfs.ps1 status
.\.sfs-local\scripts\sfs.ps1 guide --print
```

---

## 6. Multi-vendor — 어디서든 동작

본인이 어떤 LLM CLI 를 쓰든 **같은 `sfs` runtime** 이 SSoT. paraphrase 안 하니 결과 동일성 보장.

| LLM CLI | 진입점 |
|:--|:--|
| Claude Code | `.claude/skills/sfs/SKILL.md` (자동 install, primary) + `.claude/commands/sfs.md` (legacy fallback) |
| Gemini CLI | `.gemini/commands/sfs.toml` (자동 install) |
| Codex | `.agents/skills/sfs/SKILL.md` (자동 install, project-scoped Skill; `$sfs ...` 권장) |
| Codex CLI bypass (선택, legacy prompt) | `~/.codex/prompts/sfs.md` (manual `cp`, 지원 build 에서 `/prompts:sfs ...`) |

`/sfs loop` 의 LLM 호출 부분 (자율 진행 모드) 은 `--executor claude|gemini|codex|<custom>` 로 vendor 선택:

```text
/sfs loop --executor gemini --max-iters 3
```

고급 사용자는 큰 정합성 작업을 queue 에 먼저 넣을 수 있다. queue 는 execution backlog /
실행 대기열이고, sprint scope SSoT 는 여전히 `brainstorm.md` / `plan.md` / decision file 이다.
자율주행용 queue item 은 보통 `medium`(30~60분) 또는 `large`(60~120분) 로 잡고,
`small` 은 standalone overnight item 이 아니라 batch 후보로 둔다. queue 가 비어 있으면
loop 는 기존 `domain_locks` sweep 으로 fallback 한다:

```text
/sfs loop enqueue "README/GUIDE/SFS template wording consistency" --size medium --target-minutes 45
/sfs loop queue
/sfs loop --dry-run --max-iters 1
```

non-live 기본 loop 는 claim 후 `.sfs-local/queue/runs/<task-id>/<timestamp>/PROMPT.md`
를 만들고 executor 는 호출하지 않는다. `SFS_LOOP_LLM_LIVE=1` 일 때 executor 호출,
`SFS_LOOP_VERIFY=1` 일 때 `## Verify` command 실행 후 done/failed lifecycle 처리를 한다.
`retry` 는 attempts 를 1 증가시키며 `max_attempts` 를 넘으면 `abandoned/` 로 이동한다.

### Queue lifecycle (minimal)

- `pending/`: 아직 아무도 잡지 않은 대기 상태. 오직 pending 만 claim 대상.
- `claimed/<owner>/`: worker 가 `claim` 으로 원본 파일을 **mv** 해서 잡은 상태. stale claim 은 `loop queue` 에서 TTL 기반으로 경고된다.
- `done/`: 완료된 작업. `complete` 또는 `verify` 성공 시 이동한다.
- `failed/`: 검증 실패(또는 수동 fail) 상태. `retry` 하면 `pending/` 으로 되돌리고 `attempts += 1` 한다.
- `abandoned/`: 포기/중단 상태. `retry` 가 `max_attempts` 를 넘으면 자동 abandon 되며, 수동 `abandon` 도 동일하게 이동한다.

### Retro-light vs sprint retro

- queue item 에는 짧은 `## Retro-Light` 섹션만 남긴다 (3–7 bullets 정도).
- 내용이 커지면 queue item 에서 확장하지 말고 **정식 sprint retro/report** 로 승격한다.
- 큰 후속 작업은 `## Backlog Seeds` 에 TODO 로 쌓지 말고 `/sfs loop enqueue ...` 로 별도 pending task 로 만든다.
- 순서/의존이 필요하면 frontmatter `depends_on: []` 에 선행 `task_id` 를 적고, `loop queue` 의 blocked 리포트로 확인한다.

---

## 7. FAQ — 자주 묻는 것

### Q1. SFS.md 의 7-step / 7-Gate 본문도 편집해도 돼?

**Yes**. SFS.md 는 이 프로젝트의 SFS 운영 약속이다. 본인 팀이 Gate 5 를 안 쓰기로 했으면 빼도 되고, retrospective 매주 안 하기로 했으면 그렇게 적어두면 된다. 단 **편집 결과는 다음 sprint 부터 적용** — 진행 중인 sprint 의 약속은 지키는 게 좋다.

### Q2. scripts/templates/personas 는 왜 프로젝트에 없어도 돼?

thin layout 에서는 global `sfs` package 가 runtime scripts/templates/personas 를 갖고, 프로젝트는
state/config/custom override 만 갖는다. 팀 만의 template/persona 가 필요하면 `.sfs-local/personas/`
같은 override 경로에 해당 파일만 추가하면 된다. vendored layout 은 기존처럼 프로젝트에 전체 runtime 을 복사한다.

### Q3. `events.jsonl` 은 git 에 올려도 돼?

`.gitignore` 에 자동 추가됨 (PII / 감사 로그 혼입 위험). sprint 산출물 (`sprints/*` + `decisions/*`) 은 commit 권장 — 팀 누적 지식.

### Q4. AI 가 commit 까지 자동으로 해?

`/sfs retro --close` 는 sprint close bookkeeping commit 을 만든다. 코드 본체나 runtime upgrade 처럼 close commit 에 들어가지 않은 변경은 `/sfs commit plan` 으로 그룹과 branch preflight 를 확인한 뒤 `/sfs commit apply --group ...` 로 별도 local commit 한다. 메시지는 Git Flow-aware Conventional Commit 으로 자동 생성된다. 사용자가 작업만 발화하면 AI runtime 이 도메인별 `feature/*` 또는 `hotfix/*` branch 생성/전환, 검증, commit, branch push, main 흡수, origin main push 까지 완료 조건으로 수행한다. destructive git, unrelated dirty set, merge conflict, failing tests, protected branch/remote rejection, auth prompt 에서만 사용자에게 넘긴다.

### Q5. 친구한테 보여주려면?

Closed sprint 는 `.sfs-local/sprints/<sprint-id>/report.md` 를 먼저 보여준다. 세부 히스토리와 학습은 `retro.md`, 장기 결정은 `.sfs-local/decisions/` 를 같이 보면 된다.

---

## 8. 트러블슈팅

### 8.1 `sfs guide/status/upgrade` 가 "project is not initialized" 출력

Homebrew/Scoop 으로 global runtime 은 설치됐지만, 현재 프로젝트에는 아직 Solon 파일을
주입하지 않은 상태입니다. 프로젝트 루트에서 실행합니다.

Windows PowerShell/cmd:

```powershell
sfs.cmd init --layout thin --yes
sfs.cmd status
sfs.cmd guide
```

Mac/Git Bash:

```bash
sfs init --yes
sfs status
sfs guide
```

`brew install` 은 Mac 전체에 CLI 를 설치하고, `scoop install sfs` 는 Windows 에
`sfs.cmd` wrapper 를 설치합니다. Mac/Git Bash 의 `sfs init --yes` 또는 Windows
PowerShell/cmd 의 `sfs.cmd init --layout thin --yes` 는 현재 repo 에 `SFS.md`,
`.sfs-local/`, agent adapter 를 생성합니다. `sfs upgrade` / `sfs.cmd upgrade` 는 이미
init 된 프로젝트를 새 runtime 기준으로 갱신할 때 사용합니다.

agent 모델 설정은 `.sfs-local/model-profiles.yaml` 에 있습니다. 이 파일이 없던 기존
프로젝트는 `sfs upgrade` / `sfs.cmd upgrade` 때 생성됩니다. 이 설정은 "설계/평가 agent 는 강한 모델,
구현 worker 는 표준 모델, 단순 helper 는 가벼운 모델"처럼 역할별 모델 배치를 정하는
용도입니다. 설정을 안 하거나 거부하거나 나중으로 미루면 Solon 은
현재 런타임에서 사용자가 선택한 모델을 그대로 쓰고, C-Level high / worker standard /
helper economy 는 권장값으로만 남깁니다. 이 fallback 상태는 확정 설정이 아니므로 다음
`sfs upgrade` / `sfs.cmd upgrade` 또는 agent/model 설정 질문 때 다시 안내됩니다.

### 8.2 `/sfs start` 가 "sprint id conflict" 출력

같은 ISO 주차 안에 같은 번호 sprint 가 이미 있음. `--force` 로 덮어쓰거나 `--id <new-id>` 로 다른 이름.

### 8.3 `/sfs review --gate` 번호가 헷갈릴 때

새 CLI 예시는 1~7 숫자를 쓴다. review gate 는 Gate 6 이므로 `/sfs review --gate 6` 으로 실행한다.

### 8.4 Solon 버전 올릴 때 매번 지웠다 다시 깔아야 해?

아니. 프로젝트 루트에서 Mac/Git Bash 는 `sfs upgrade`, Windows PowerShell/cmd 는
`sfs.cmd upgrade` 한 번만 실행한다. Homebrew 설치본이면 먼저
`brew update` + `brew upgrade sfs` 를 실행하고, Scoop 설치본이면 `scoop update` +
`scoop update sfs` 를 실행한 뒤 현재 프로젝트 adapter/docs 를 갱신한다.

Windows PowerShell/cmd:

```powershell
cd C:\workspace\my-project
sfs.cmd version --check
sfs.cmd upgrade
```

Mac/Git Bash:

```bash
cd ~/workspace/my-project
sfs version --check
sfs upgrade
```

`sfs upgrade` / `sfs.cmd upgrade` 는 managed adapter/docs 를 백업 후 갱신하고, `.sfs-local/sprints/`,
`.sfs-local/decisions/`, `.sfs-local/events.jsonl`, 프로젝트별 `CLAUDE.md`/`AGENTS.md`/
`GEMINI.md` 는 보존한다. `.sfs-local/model-profiles.yaml` 이 없으면 current-model fallback
설정으로 새로 만들고, 이미 있으면 사용자 설정 보호를 위해 보존한다. fallback 또는 미확정이면
upgrade 가 설정 여부를 다시 묻고, 사용자가 지금 설정하지 않겠다고 하면 fallback 을 유지한다.
`sfs update` 는 하위 호환 alias 로 남아 있지만 새 문서에서는 `sfs upgrade` 를 기준으로 설명한다.

### 8.5 `upgrade.sh` 시 본인이 편집한 file 보존돼?

`SFS.md`, `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.sfs-local/divisions.yaml` = 기본 보존 (본인 편집 가능성 큰 영역).

`scripts/`, `sprint-templates/`, `personas/`, `decisions-template/`, `.claude/skills/sfs/SKILL.md`, `.claude/commands/sfs.md`, `.gemini/commands/sfs.toml`, `.agents/skills/sfs/SKILL.md` = 자동 갱신 (배포판 관리 영역).

`.sfs-local/sprints/`, `.sfs-local/decisions/`, `.sfs-local/events.jsonl` = **절대 덮어쓰지 않음**.

### 8.6 `upgrade.sh` 가 "이미 최신" 이라는데 새 명령이 없어

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

1. `cat .sfs-local/sprints/*/report.md` — 이번 주 결과를 한눈에.
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
