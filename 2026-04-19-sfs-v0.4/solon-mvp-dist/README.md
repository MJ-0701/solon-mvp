# Solon Product

> AI-native solo founder 를 위한 **Solo Founder System (SFS)**.
> Solon Product 는 제품 개발에 필요한 역할 분리, 결정 기록, 검증, 회고, 인수인계를
> 프로젝트 안에 설치합니다.

SFS 는 의도적으로 이중 의미를 가집니다. 터미널에서 매일 치는 `sfs` / `/sfs` 의 표면 의미는
**Sprint Flow System** 입니다. 사용자가 생각을 `start → brainstorm → plan → implement →
review → report → retro` 흐름으로 통과시키는 로컬 실행 시스템이라는 뜻입니다. 동시에 Solon
Product 전체의 SFS 는 **Solo Founder System** 입니다. 혼자 제품을 만드는 founder 가 여러 AI
agent 를 팀처럼 쓰기 위해, 프로젝트 안에 sprint flow, role boundary, decision log,
review/retro loop 를 고정하는 운영 시스템입니다.

Solon Product 는 Claude Code, Codex, Gemini CLI 같은 LLM agent 와 함께 제품을 만들 때
작업 맥락이 사라지지 않도록 돕는 로컬 운영 시스템입니다. 설치하면 현재 repository 안에
공통 지침, runtime adapter, `/sfs` 명령, sprint 산출물, decision log, review/retro 흐름이
생깁니다.

핵심 약속은 단순합니다.

- AI 는 실행 속도를 높인다.
- Solon 은 역할, 기록, 검증, 인수인계 구조를 고정한다.
- 사용자는 방향과 최종 통과 여부를 결정한다.

개발, 터미널, CLI 환경에 아직 익숙하지 않다면 먼저
[BEGINNER-GUIDE.md](./BEGINNER-GUIDE.md) 를 보세요. PowerShell/Terminal 을 처음 쓰는
사람 기준으로 설치부터 첫 `sfs.cmd status`(Windows) 또는 `sfs status`(Mac/Git Bash)
까지 안내합니다.

---

## Installation

Solon 은 먼저 global runtime 을 설치하고, 각 프로젝트 루트에서 Windows PowerShell/cmd 는
`sfs.cmd init`, Mac/Git Bash 는 `sfs init` 으로 프로젝트 파일을 생성합니다. Windows 는
Scoop, Mac 은 Homebrew 가 권장 경로입니다.
설치 용어가 낯설면 [Beginner Guide](./BEGINNER-GUIDE.md) 의 순서대로 진행하세요.

### Windows (Scoop)

Windows 에서 가장 따라가기 쉬운 설치 경로입니다. PowerShell 을 열고 아래 순서대로 실행합니다.

```powershell
# 1) Git Bash 설치: Solon 내부 bash adapter 실행에 필요합니다.
winget install --id Git.Git -e --source winget

# 2) Scoop 설치: 이미 설치되어 있으면 건너뛰세요.
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

# 3) Solon SFS 설치
scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs

# 4) 프로젝트 폴더에서 초기화
cd C:\workspace\my-project
git init
sfs.cmd init --layout thin --yes
sfs.cmd status
```

### Mac (Homebrew)

```bash
brew install MJ-0701/solon-product/sfs
cd ~/workspace/my-project
sfs init --layout thin --yes
sfs status
```

### Source Fallback

Homebrew/Scoop 을 쓰지 않는 경우에는 GitHub 의 installer 를 직접 실행할 수 있습니다.

```bash
cd ~/workspace/my-project
curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-product/main/install.sh | bash
```

Windows PowerShell:

```powershell
cd C:\workspace\my-project
iwr -useb https://raw.githubusercontent.com/MJ-0701/solon-product/main/install.ps1 | iex
```

### Upgrade

업데이트는 재설치가 아니라 프로젝트 루트에서 한 번만 실행합니다.

Windows PowerShell/cmd:

```powershell
sfs.cmd upgrade
```

Mac/Git Bash:

```bash
sfs upgrade
```

Scoop 설치본은 `sfs.cmd upgrade` 실행 시 먼저 `scoop update` + `scoop update sfs` 로
global runtime 을 최신화합니다. Homebrew 설치본은 Homebrew tap 을 새로고침한 뒤
`MJ-0701/solon-product/sfs` 를 업그레이드합니다. 그 다음 현재 프로젝트의
Solon adapter/docs/context 를 갱신합니다.

---

## Why Solon

AI 로 코드를 빨리 만들 수 있어도 제품 작업에는 반복적으로 같은 문제가 생깁니다.

- 어떤 결정이 왜 내려졌는지 다음 세션에서 다시 추측한다.
- 설계 없이 만든 코드가 다음 sprint 의 부채가 된다.
- 만든 agent 와 검증 agent 가 섞여 자기검증이 발생한다.
- release 직전 secret, auth, data, monitoring, rollback, cost evidence 가 누락된다.
- 여러 도구를 오가며 일할수록 현재 상태와 다음 행동이 흐려진다.

Solon Product 는 이 문제를 프롬프트가 아니라 **운영 구조**로 다룹니다. 작업 단위를
sprint 로 묶고, 계획/결정/review/회고를 파일로 남기며, agent 가 같은 상태를 읽고 이어받을 수
있게 합니다.

Solon 의 10x 가치는 AI 가 코드를 더 많이 쓰게 하는 데 있지 않습니다. 비개발자의 모호한
아이디어를 공유 design concept, domain language, acceptance criteria, test contract,
작은 work unit 으로 바꾸고, 개발자는 그 구조 안에서 DDD/TDD 기반으로 AI 를 안전하게 쓰게
만드는 데 있습니다. 자세한 제품 관점은 [10X-VALUE.md](./10X-VALUE.md) 를 참조하세요.
이 원칙은 implement 단계 전용이 아닙니다. Gate 2 (Brainstorm) 부터 공유 이해와 용어를 맞추고,
Gate 3 (Plan) 에서 검증 가능한 계약과 interface boundary 를 세운 뒤, implement/review/report 가
그 계약을 따라갑니다.

---

## How It Works

1. 기존 프로젝트에 Solon Product 를 설치합니다.
2. 이미 오래 진행된 legacy 프로젝트라면 먼저 `/sfs adopt --apply` 로 git/code/docs 기반 baseline 을 만듭니다. 문서가 너무 많아도, 문서가 하나도 없어도, visible entry 는 `report.md` + `retro.md` 만 남기고 기존 sprint/archive 문서 숲은 cold archive tarball 로 접습니다.
3. `/sfs start <goal>` 로 sprint workspace 를 만듭니다.
4. 새 요구를 탐색하는 planning sprint 라면 `/sfs brainstorm` 으로 raw 요구사항을 Gate 2 (Brainstorm) 산출물에 남기고, Solon CEO 가 문제/제약/옵션/scope seed/plan seed 를 정리합니다. raw 요구사항은 아직 계약이 아닙니다. 공유 design concept, domain language, feedback loop, interface/artifact boundary, gray-box 위임 경계가 비어 있으면 1~3개 blocking question 을 먼저 답합니다.
5. `/sfs plan` 에서 `plan.md ready` handshake 후 `brainstorm.md` 를 읽고 CEO plan 과 CTO/CPO sprint contract 를 남깁니다. 이때 Gate 2 의 공유 이해를 측정 가능한 요구사항, acceptance criteria, test/review contract, 작은 구현 단위로 내립니다. Gate 2 질문이 남아 있으면 추측으로 메우지 않고 plan 을 draft 로 둡니다.
   이미 통과한 plan/ADR 을 이어받는 implementation sprint 라면 Gate 2/3 을 다시 두껍게 돌리지 않습니다. `log.md` 또는 `plan.md` 에 `inherit-from: <prior sprint/ADR>` 와 이번 AC 만 얇게 남긴 뒤 바로 첫 실행 slice 로 들어갑니다.
   sprint goal 이 repo scaffold, dev compose, DB schema, API boot, 테스트, UI 동작, taxonomy 정리, design handoff, QA evidence, infra/runbook 처럼 구체적인 실행 산출물을 말한다면 Gate 3 (Plan) 계약만으로 sprint 완료가 아닙니다. artifact 변경, smoke/test/review evidence, review, retro 까지가 완료 조건입니다.
6. `/sfs implement "<첫 실행 slice>"` 에서 `implement.md` + `log.md` 를 열고, AI runtime 이 실제 작업 slice 와 검증 evidence 를 남깁니다. 코드 변경은 중요한 산출물이지만 유일한 산출물은 아닙니다. taxonomy, design handoff, QA evidence, infra/runbook, decision, docs 도 implementation artifact 입니다. 구현 모드는 공유 design concept, 도메인 용어, 작은 verification loop, 기존 프로젝트 규칙성을 기본 guardrail 로 삼습니다. 코드가 포함될 때 DDD/TDD 와 backend Transaction discipline 이 강하게 적용됩니다. Backend architecture 는 MVP/소규모에서는 clean layered monolith, 초기 MVP 이후 backend 는 단일 DB 여도 CQRS 를 기본값으로 삼고, Hexagonal/MSA 전환은 안내 → 사용자 수용/승인 → incremental refactor 순서로만 진행합니다. Security / Infra / DevOps 는 sprint/project 단위 `light` / `full` / `skip` 질문으로만 확장하며, MVP-overkill 은 `deferred` 또는 `risk-accepted` 로 기록합니다.
7. `/sfs review --gate 6 --executor codex|gemini|claude` 로 Gate 6 (Review) CPO Evaluator review 를 실행하고 verdict 를 남깁니다. 명령 출력은 result path/verdict 메타데이터만 짧게 보여주고, AI runtime 은 원문 result 를 사용자의 언어로 요약해 해야 할 일을 Solon report 로 보여줍니다. 수동 handoff 만 필요하면 `--prompt-only` 를, 기존 리뷰 확인은 `--show-last` 를 사용합니다.
8. `/sfs report` 로 최종 작업보고서 `report.md` 를 만들고, `/sfs retro --close` 또는 `/sfs tidy --apply` 에서 workbench 문서를 archive 로 이동합니다. `brainstorm/plan/implement/log/review` 는 작업 중 화이트보드이고, 완료 후에는 `report.md` + `retro.md` 가 읽는 입구입니다.
9. `/sfs status` 와 `.sfs-local/events.jsonl` 로 현재 상태를 확인합니다.
10. 필요하면 Codex/Gemini/Claude 가 같은 문서 계약을 읽고 다음 작업을 이어갑니다.

```text
Product work = Goal + Role boundary + Artifact + Review signal + Handoff state
```

Solon 은 AI 가 더 많이 결정하게 만드는 도구가 아닙니다. AI 가 더 안정적으로 일하게 만들고,
중요한 판단은 사용자에게 남기는 도구입니다.

---

## Operating Model

| 축 | Solon Product 가 고정하는 것 |
|---|---|
| Role | 6 Division + 3 C-Level 관점의 책임 분리 |
| Process | CEO 요구사항/plan → CTO/CPO sprint contract → `/sfs implement` 실제 구현 → CPO review → CTO rework/final confirm → retro. Planning sprint 는 Gate 2/3 이 두껍고, implementation sprint 는 상위 plan 을 인계받아 Do/Gate 6 이 두껍다 |
| Artifact | active workbench (`brainstorm.md`, `plan.md`, `implement.md`, `log.md`, `review.md`) → closed sprint entry (`report.md`, `retro.md`), ADR-style decision |
| State | `/sfs status`, `.sfs-local/current-sprint`, `.sfs-local/events.jsonl` |
| Safety | signal-only gate, human final filter, no automatic push |

7-step flow 는 full startup artifact chain 의 product-facing projection 입니다. Discovery,
PRD, Taxonomy, UX, Technical Design, Release Readiness 를 없애는 것이 아니라, 작은 팀과
1인 창업자가 매일 운용할 수 있는 형태로 접어 둔 것입니다.

각 작업 단위가 통과할 수 있는 7 개의 검증 지점은 사용자에게 `Gate 1..7` 로 표시합니다:
Gate 1 (Intake), Gate 2 (Brainstorm), Gate 3 (Plan), Gate 4 (Design),
Gate 5 (Handoff), Gate 6 (Review), Gate 7 (Retro).
verdict 는 `pass / partial / fail` 3-enum 입니다 (Gate 5 만 binary `block / unblock`). gate 는
진행을 강제로 막지 않는 signal 입니다.

### 3 C-Level Flow

Solon Product 의 3 C-Level 은 README 의 6 Division + 3 C-Level 모델에서 온다.

| C-Level | Sprint 책임 | 기본 persona |
|---|---|---|
| CEO | 요구사항 정리, scope, plan 승인 | `.sfs-local/personas/ceo.md` |
| CTO Generator | sprint contract 구현, CPO finding 반영 | `.sfs-local/personas/cto-generator.md` |
| CPO Evaluator | 품질검증, verdict, CTO action 제시 | `.sfs-local/personas/cpo-evaluator.md` |

리뷰는 필수이고, 리뷰 도구는 선택 가능하다. 핵심 분리는 CTO 구현 agent 와 CPO reviewer
role/agent/instance 의 분리다. cross-vendor review 는 좋은 선택지지만 필수 조건은 아니다.
Claude-only / Codex-only 사용자는 같은 runtime 또는 같은 도구 안에서도 별도 CPO instance 가
evidence 를 읽고 verdict 와 required CTO actions 를 남기면 유효한 review 로 다룬다.

### Adaptor Design Intent

`/sfs` adaptor 의 배경은 단순한 vendor별 명령어 통일이 아니다. `self-validation-forbidden` 은
"같은 vendor/runtime 금지" 가 아니라, **CTO 구현 agent 가 자기 결과를 그대로 통과시키는
자체검증 금지**다. 사용자가 Claude 를 주 구현 도구로 쓰더라도 Codex plugin, Codex CLI,
Gemini CLI, 또는 같은 runtime 의 별도 CPO agent instance 로 review 를 위임할 수 있어야 한다.
Solon 은 token-hungry multi-tool requirement 가 아니라, cross-vendor 또는 same-runtime CPO
review 중 어떤 경로를 쓰든 역할 분리와 evidence 기록을 명시적으로 남기는 adaptor 다.

따라서 `/sfs review` 의 `--executor` 는 audit metadata 가 아니라 review bridge 의 의도다.
기본 동작은 실제 CLI/bridge 호출이며, bridge 가 없으면 조용히 성공하지 않고 실패해야 한다.
수동 전달만 필요할 때는 `--prompt-only` 로 prompt/log 만 생성한다. 이미 실행된 리뷰를 다시 볼 때는
`/sfs review --show-last [--gate <1..7>]` 로 executor 를 다시 쓰지 않고 마지막 CPO 결과를 요약 레포트로 확인한다.
Claude 내부에 연결된 Codex plugin 은 shell 에서 자동 호출할 수 없으므로, plugin bridge command 를
설정하거나 Claude adaptor 가 printed prompt 를 plugin 으로 넘기는 2-step 이 필요하다.

Bridge 는 대칭이 아니다.

| CTO 구현 host | CPO review target | 지원 방식 |
|---|---|---|
| Claude | Codex | Claude 쪽 Codex plugin/manual bridge 또는 `codex` CLI |
| Claude | Gemini | `gemini` CLI |
| Codex | Claude | `claude` CLI (`--executor claude`) 또는 `--prompt-only` 후 Claude handoff |
| Codex | Claude plugin | 지원하지 않음. Codex 는 Claude plugin host 가 아니다 |
| Gemini | Claude/Codex | 각 CLI bridge 또는 prompt handoff |

Headless CLI review 는 인증도 bridge 의 일부다. SFS 는 `.sfs-local/auth.env` 를 있으면 자동
로드한다. 이 파일은 gitignore 대상이며, `.sfs-local/auth.env.example` 을 복사해서
`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`, `SFS_REVIEW_*_CMD` 같은 로컬 값을
넣는다. Codex/Claude/Gemini CLI login cache 를 쓰려면 `SFS_CODEX_AUTH_READY=1`,
`SFS_CLAUDE_AUTH_READY=1`, `SFS_GEMINI_AUTH_READY=1` 중 해당 값을 명시한다.
인증 상태는 `/sfs auth status` 로 확인하고, 필요하면 `/sfs auth login <tool>`
또는 `/sfs auth login --executor <tool>` 로
브라우저/터미널 인증을 먼저 끝낸다. bridge 자체만 확인할 때는 `/sfs auth probe --executor <tool> --timeout 20` 로
작은 dummy request/response 를 확인한다. `/sfs review` 도 실행 전에 인증을 확인하고,
리뷰할 evidence 가 없으면 executor 를 호출하지 않는다.

Windows Store 로 설치된 Codex 는 `C:\Program Files\WindowsApps\OpenAI.Codex_...\app\resources\codex.exe`
패키지 내부 파일을 직접 실행하면 access denied 가 날 수 있다. `SFS_REVIEW_CODEX_CMD` 를
직접 지정할 때는 그 경로 대신 `codex exec ...` App Execution Alias 또는
`/c/Users/<you>/AppData/Local/Microsoft/WindowsApps/codex.exe` 처럼 실행 가능한 shim 을 사용한다.
CLI 가 없고 앱만 있는 executor 는 자동 review bridge 로 사용할 수 없다. 이 경우
`/sfs review --gate <1..7> --executor <tool> --prompt-only` 로 prompt 파일을 만든 뒤 앱에
수동으로 붙여넣거나, 설치된 다른 CLI executor 를 사용한다.

---

## Quickstart

설치할 프로젝트 루트에서 실행합니다.

### Mac / Git Bash

```bash
brew install MJ-0701/solon-product/sfs
cd ~/workspace/my-project
sfs init --yes
sfs status
sfs guide
sfs agent install all   # Claude + Gemini + Codex entry point 한번에 설치/갱신
```

### Windows PowerShell / cmd (Scoop)

```powershell
scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs
cd C:\workspace\my-project
git init
sfs.cmd init --layout thin --yes
sfs.cmd status
sfs.cmd guide
sfs.cmd agent install all
```

Homebrew/Scoop 은 global `sfs` runtime 만 설치할 뿐이고, 프로젝트 파일은 만들지
않습니다. 각 프로젝트 루트에서 Mac/Git Bash 는 `sfs init --yes`, Windows PowerShell/cmd 는
`sfs.cmd init --layout thin --yes` 를 한 번 실행해야 `SFS.md`, `.sfs-local/`,
Claude/Gemini/Codex adapter 가 생성됩니다. 아직 git repo 가 아니면 `git init` 을 먼저
실행합니다.

초기화 후 agent 모델 설정은 `.sfs-local/model-profiles.yaml` 에 남습니다. Codex 는
`model + reasoning_effort` (예: `gpt-5.5` + `xhigh`/`very_high`), Claude 는 `opus-4.7` / `opus-4.6` / `sonnet` / `haiku`,
Gemini/custom 은 해당 runtime profile 이름으로 agent별 override 할 수 있습니다. 이 설정은
"설계/평가 agent 는 강한 모델, 구현 worker 는 표준 모델, 단순 helper 는 가벼운 모델"처럼
역할별 모델 배치를 정하는 용도입니다. 설정을
건너뛰거나 나중에 하기로 하면 Solon 은 현재 런타임에서 사용자가 선택한 모델을 그대로 쓰고,
다음 `sfs upgrade` 또는 agent/model 설정 질문 때 다시 안내합니다.
Solon 의 C-Level high / worker standard / helper economy 는 권장값이고 hard block 이 아닙니다.

`SFS.md` 상단 프로젝트 개요를 다시 감지하고 싶으면 AI runtime 에서는 `sfs profile` 을,
빠른 shell-only 갱신은 `sfs profile --apply` 를 실행합니다. 이 명령은 adapter 가 허용한
설정/docs 파일만 읽고 `SFS.md` 의 `## 프로젝트 개요` 섹션만 수정합니다.

이후 Solon 런타임과 현재 프로젝트 adapter/docs 를 갱신할 때는 uninstall/reinstall 하지 않습니다.
프로젝트 루트에서 Mac/Git Bash 는 `sfs upgrade`, Windows PowerShell/cmd 는
`sfs.cmd upgrade` 한 번만 실행합니다. Homebrew 설치본이면 내부에서 먼저
`brew update` + `brew upgrade sfs` 를 실행하고, Scoop 설치본이면 `scoop update` +
`scoop update sfs` 를 실행한 뒤 프로젝트 파일을 갱신합니다. `sfs update` 는 하위 호환 alias 로
남아 있지만 문서상 권장 명령은 `sfs upgrade` 입니다:

Windows PowerShell/cmd:

```powershell
cd C:\workspace\my-project
sfs.cmd upgrade
```

Mac/Git Bash:

```bash
cd ~/workspace/my-project
sfs upgrade
```

새 배포가 있는지 확인만 하고 싶을 때는:

Windows PowerShell/cmd:

```powershell
sfs.cmd version
sfs.cmd version --check
```

Mac/Git Bash:

```bash
sfs version
sfs version --check
```

Scoop 설치본도 프로젝트에는 thin layout 을 기본으로 둡니다. 즉 `.sfs-local/` 에 sprint/decision
state 와 config 는 생기지만 runtime `scripts/`, `sprint-templates/`, `personas/` 는 통째로
복사되지 않아야 합니다. 내부 bash adapter 실행에는 Git for Windows 의 Git Bash 가 필요하며,
자동 감지가 안 되면 `SFS_BASH` 에 `bash.exe` 경로를 지정합니다.

`agent install all` 이 기본 권장입니다. Claude/Gemini/Codex 중 일부만 쓰는
프로젝트라면 같은 프로젝트 루트에서 개별 설치할 수 있습니다:

Windows PowerShell/cmd:

```powershell
sfs.cmd agent install claude
sfs.cmd agent install gemini
sfs.cmd agent install codex
```

Mac/Git Bash:

```bash
sfs agent install claude
sfs agent install gemini
sfs agent install codex
```

아직 Homebrew/source package 로 `sfs` 를 노출하지 않았다면 기존 curl installer 를 쓸 수 있습니다.
기본은 vendored layout 이고, global runtime 준비가 끝난 팀은 `--layout thin` 으로 프로젝트를 얇게 둡니다.

```bash
cd ~/workspace/my-project
curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-product/main/install.sh | bash
```

Windows 에서는 Scoop 경로를 우선 사용하세요. 아래 `install.ps1` 는 source fallback 이고,
Scoop/global `sfs.cmd` 를 쓸 수 없는 특수한 상황에서만 사용합니다:

```powershell
cd C:\workspace\my-project
iwr -useb https://raw.githubusercontent.com/MJ-0701/solon-product/main/install.ps1 | iex
```

설치 후 Solon 의 agent command shape 는 runtime 마다 다릅니다. Claude Code 는 `/sfs ...`,
Gemini CLI 는 slash 없이 `sfs ...`, Codex CLI 는 `$sfs ...` Skill mention 을 사용합니다.
Codex CLI 는 unknown leading slash 를 모델 전에 막고
`커맨드 없음` / `Unrecognized command` 를 표시할 수 있으므로, Codex CLI 에서는 `$sfs status`
가 1급 경로입니다. Runtime adaptor 는 각 vendor 의 입력면 차이를
흡수해서 같은 bash adapter 로 내려보내야 합니다. `sfs agent install ...` 은 다음 thin
entry point 를 프로젝트에 설치/갱신합니다:
`.claude/skills/sfs/SKILL.md` + `.claude/commands/sfs.md` +
`.gemini/commands/sfs.toml` + `.agents/skills/sfs/SKILL.md`.
기존 파일이 다르면 `.sfs-local/archives/agent-install-backups/` 에 보존한 뒤 갱신합니다.

> 📘 **친구 onboarding 30분 walk-through**: 설치 직후 처음 30분 동안 `SFS.md` placeholder 치환,
> 첫 sprint 시작, plan/review/decision/retro 흐름까지 따라 하는 가이드는 [GUIDE.md](./GUIDE.md)
> 참조. "SFS.md 에 프로젝트 스택 적어도 되는지" 같은 자주 묻는 오해도 거기서 해소.

```text
# Claude Code
/sfs status
/sfs guide
/sfs auth status
/sfs profile
/sfs start "첫 번째 sprint 목표"
/sfs brainstorm "raw 요구사항과 아직 정리 안 된 맥락"
/sfs plan
/sfs implement "첫 실행 slice"
/sfs review --gate 6 --executor codex --generator claude
/sfs decision "초기 인증 방식은 세션 기반으로 시작한다"
/sfs report
/sfs retro --close

# Gemini CLI
sfs status
sfs guide
sfs auth status
sfs profile
sfs start "첫 번째 sprint 목표"
sfs brainstorm "raw 요구사항과 아직 정리 안 된 맥락"
sfs plan
sfs implement "첫 실행 slice"
sfs review --gate 6 --executor codex --generator gemini
sfs decision "초기 인증 방식은 세션 기반으로 시작한다"
sfs report
sfs retro --close

# Codex CLI
$sfs status
$sfs profile
$sfs start "첫 번째 sprint 목표"
$sfs brainstorm "raw 요구사항과 아직 정리 안 된 맥락"
$sfs plan
$sfs implement "첫 실행 slice"
$sfs report

# Windows PowerShell direct shell
sfs.cmd status
sfs.cmd guide
```

Codex CLI 에서 bare `/sfs` 를 입력했을 때 `커맨드 없음` 또는 `Unrecognized command`
가 보이면 Solon Skill 이 실행된 것이 아닙니다. Host slash parser 가 메시지를 모델 전에
차단한 상태입니다. 이때는 공식 Skill 호출인 `$sfs status`, `$sfs plan` 을 사용합니다.
Windows PowerShell 에서 agent 밖 direct shell 로 실행할 때는 `sfs.cmd status` 를 사용합니다.
`/sfs ...` 텍스트가 실제로 모델/Skill 까지 도달하는 Codex app surface 에서는 Skill 이 즉시
bash adapter 로 dispatch 해야 하지만, 현재 Codex CLI 에서 native slash 등록을 보장하지는
않습니다.

세 환경 모두 같은 `sfs` runtime command 를 SSoT 로 호출합니다. `sfs` 는 packaged bash
adapter 로 내려가며, 프로젝트의 `.sfs-local/` 은 sprint/decision/config/custom override 만
담습니다. vendored layout 을 선택한 경우에만 `.sfs-local/scripts/sfs-*.sh` 가 프로젝트에 복사됩니다.

Windows PowerShell 에서는 global `sfs.cmd` 를 우선 사용합니다.
vendored layout 에서 direct adapter 를 호출해야 하면:

```powershell
.\.sfs-local\scripts\sfs.ps1 status
.\.sfs-local\scripts\sfs.ps1 guide
```

이 wrapper 는 Git Bash 를 찾아 `.sfs-local/scripts/sfs-dispatch.sh` 로 넘깁니다.
순수 PowerShell-only 환경은 아직 지원선 밖입니다.

---

## Product Surface

| 명령 | 역할 |
|---|---|
| `/sfs status` | 현재 sprint, WU, gate, ahead count, last event 를 한 줄로 표시 |
| `/sfs start <goal>` | 새 sprint workspace 초기화 (`--id <sprint-id>` 지원) |
| `/sfs guide [--path|--print]` | 짧은 사용 맥락 브리핑 / guide 경로 / full guide 본문 보기 |
| `/sfs auth status|check|login|probe` | Codex/Claude/Gemini review executor 인증 확인/로그인/더미 요청 (`login codex` positional executor, `probe --timeout <seconds>` 지원) |
| `/sfs profile [--prompt-only|--apply]` | `SFS.md` 프로젝트 개요만 좁게 감지/보정. 기본은 AI용 bounded task, `--apply` 는 shell-only quick apply |
| `/sfs division list` / `/sfs division activate <division|all>` | 본부 활성 상태 확인/승격. abstract 본부를 active/scoped/temporal 로 전환하고 `.sfs-local/divisions.yaml`, decision, events evidence 를 갱신 |
| `/sfs adopt [--id legacy-baseline] [--apply]` | SFS 없이 진행된 legacy 프로젝트를 git/code/docs 기반으로 인계. 문서 과잉 프로젝트는 기존 visible sprint/archive tree 를 cold archive tarball 로 접고 `report.md` + `retro.md` 만 남김. 문서 0 프로젝트는 최소 baseline 을 복원. 기본은 dry-run |
| `/sfs brainstorm [text|--stdin]` | Gate 2 (Brainstorm) raw 요구사항/대화 맥락을 기록하고, AI runtime 에서 공유 design concept, domain language, feedback loop, boundary, gray-box 위임을 정리. 부족하면 1~3개 질문 후 draft 유지 |
| `/sfs plan` | 현재 sprint 의 `plan.md` 작성 또는 갱신 + Gate 3 (Plan) 요구사항/AC/scope + CTO/CPO sprint contract refinement. Gate 2 질문을 추측으로 덮지 않고 측정 가능한 계약으로만 승격 |
| `/sfs implement [work slice|--stdin]` | `implement.md`/`log.md` 를 열고 plan 기반 작업 slice 실행 + evidence 기록. 코드, taxonomy, design handoff, QA, infra/runbook, decision, docs 를 모두 artifact 로 취급하며, 코드가 포함될 때 backend Transaction / `REQUIRES_NEW` guardrail 을 always-on 으로 적용. Backend architecture 는 clean layered monolith → CQRS → Hexagonal 안내/수용 → MSA 안내/승인 ladder 로 기록. Security / Infra / DevOps 는 `light` / `full` / `skip`, 과한 항목은 `deferred` / `risk-accepted` 로 기록 |
| `/sfs review --gate <1..7> [--executor <tool>] [--prompt-only]` / `/sfs review --show-last` | CPO Evaluator review run. stdout 은 verdict/output path 메타데이터만 보여주고, AI runtime 이 result 를 사용자 언어의 요약+action report 로 렌더링. full prompt 는 tmp prompt file에 저장하며 `review.md`에는 compact log/result를 남김 |
| `/sfs decision <title>` | full ADR 생성 후 Context/Decision/Alternatives/Consequences 작성 |
| `/sfs report [--sprint <id>] [--compact]` | 최종 작업보고서 `report.md` 생성/갱신. `--compact` 는 사용자 동의 후 workbench 문서를 archive 로 이동 |
| `/sfs tidy [--sprint <id-or-ref>|--all] [--apply]` | 완료된 sprint workbench/tmp 산출물을 archive 로 이동하고, 없으면 `report.md` 를 생성. `--sprint W18-sprint-1` 같은 고유 suffix 참조 가능. 남겨야 할 문서만 sprint 폴더에 둠. 기본은 dry-run |
| `/sfs retro` | 현재 sprint 의 `retro.md` 작성 또는 갱신 |
| `/sfs retro --close` | AI runtime 에서는 retro + report refinement 후, review 실행 여부 확인 + workbench/tmp archive + sprint close + auto commit. 이후 branch push/main 흡수는 Git Flow lifecycle 로 처리 |
| `/sfs commit [status|plan|apply --group <name>]` | close 후 남은 working tree 를 의미 그룹으로 분리하고 branch preflight 안내 후 선택 그룹만 local commit. 메시지는 Git Flow-aware Conventional Commit 으로 자동 생성 (`-m` override). 이후 branch push/main 흡수는 AI runtime 이 수행 |
| `/sfs loop [OPTIONS]` | queue-first + domain_locks fallback 으로 micro-step 단위 반복 실행을 돕는 자율 진행 모드 |

17 명령 모두 동일 bash adapter SSoT 입니다. `/sfs` 는 Claude Code command shape,
`sfs` 는 Gemini CLI/direct shell command shape, `$sfs` 는 Codex Skill mention 입니다.
Skill/prompt/wrapper 는 이 API 를 runtime 별로 전달하는 adaptor surface 입니다.

### `/sfs loop` 자세히

`/sfs loop` 는 자율 진행 (Ralph Loop 패턴) 의 LLM 호출 site 입니다. 먼저
`.sfs-local/queue/pending/` 의 file-backed task 를 보고, 없으면 기존 `PROGRESS.md`
`domain_locks` 를 fallback 으로 sweep 합니다. LLM 이 한 micro-step → PROGRESS 갱신 →
자기 review gate → 다음 micro-step 을 cap (`--max-iters` default 5) 까지 반복.

Queue MVP:

```text
/sfs loop enqueue "10x docs consistency pass" --size large --target-minutes 90
/sfs loop queue
/sfs loop claim --owner my-worker
/sfs loop verify <task-id-or-path>
/sfs loop complete <task-id-or-path>
/sfs loop fail <task-id-or-path>
/sfs loop retry <task-id-or-path>
/sfs loop abandon <task-id-or-path>
/sfs loop --dry-run --max-iters 1
```

queue 는 execution backlog / 실행 대기열이고, sprint scope 의 SSoT 는 여전히
`brainstorm.md` / `plan.md` / decision file 입니다. 자율주행용 queue item 은
`size: medium|large` 와 `target_minutes: 30~120` 범위가 기본이며, `small` 은 보통
standalone overnight item 이 아니라 batch 후보입니다.

기본 `/sfs loop` 는 non-live 모드에서 task 를 claim 한 뒤
`.sfs-local/queue/runs/<task-id>/<timestamp>/PROMPT.md` 와 `metadata.env` 를 만들고
executor 호출은 하지 않습니다. `SFS_LOOP_LLM_LIVE=1` 일 때만 executor 를 호출합니다.
검증까지 자동으로 닫으려면 task 의 `## Verify` 에 runnable command bullet 을 넣고
`SFS_LOOP_VERIFY=1 /sfs loop ...` 를 사용합니다. 수동 마무리는 `complete` / `fail` /
`retry` / `abandon`, 또는 claimed task 에 대한 `verify` 로 처리합니다. `retry` 는
attempts 를 1 증가시키며 `max_attempts` 를 넘으면 task 를 `abandoned/` 로 이동합니다.
multi-vendor executor 1급 지원:

- `--executor claude` → `claude -p --dangerously-skip-permissions`
- `--executor gemini` → `gemini --skip-trust --yolo --output-format text -p "Read stdin and execute the requested task."`
- `--executor codex` → `codex exec --full-auto --ephemeral --output-last-message <result> -`
- `--executor "<custom command>"` → 그대로 passthrough

이 convention 은 `/sfs loop` 만 적용되는 게 아니라 Solon-wide invariant — 모든 명령이 어느 1급
CLI 에서든 동등한 deterministic bash adapter SSoT 로 동작합니다.

---

## Runtime Coverage

설치 후 17 명령은 **세 런타임 모두에서 1급 entry point** 로 연결됩니다.

| 런타임 | Entry point (자동 install) | 호출 방법 |
|---|---|---|
| **Claude Code** | `.claude/skills/sfs/SKILL.md` (primary Skill) + `.claude/commands/sfs.md` (legacy fallback) | `/sfs status` |
| **Gemini CLI** | `.gemini/commands/sfs.toml` (TOML command) | `sfs status` |
| **Codex CLI** | `.agents/skills/sfs/SKILL.md` (project-scoped Skill) | `$sfs status` |
| **Codex app** | `.agents/skills/sfs/SKILL.md` (project-scoped Skill) | `$sfs status` 또는 `/sfs status` 가 host 에서 모델까지 전달되는 경우 |
| **Windows PowerShell shell** | `bin/sfs.cmd` (Scoop/PATH global wrapper) | `sfs.cmd status` |

Codex CLI 에서 bare `/sfs` 가 native slash parser 에 막히는 것은 Solon 설치 실패가 아니라
host UI 가 Skill 호출 전에 입력을 선점한 것입니다. Codex CLI 의 공식 SFS entry 는 `$sfs` 이며,
Codex native slash registration 은 host 가 공식 extension point 를 제공할 때만 다시 검토합니다.
일부 Codex build 에서 user prompt fallback (`/prompts:sfs ...`, `~/.codex/prompts/sfs.md`) 을
쓸 수 있지만, install.sh 는 user `$HOME` 에 자동 cp 하지 않습니다 (사용자 영역 보호).
지원되는 build 에서만 manual cp:

```sh
mkdir -p ~/.codex/prompts
cp <consumer-project>/templates/.codex/prompts/sfs.md ~/.codex/prompts/sfs.md
```

---

## Manual / Source Install Details

### Remote One-Liner

Mac/Git Bash:

```bash
cd ~/workspace/my-project
curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-product/main/install.sh | bash
```

Windows PowerShell source fallback (Scoop 권장 경로를 쓸 수 없을 때만):

```powershell
cd C:\workspace\my-project
iwr -useb https://raw.githubusercontent.com/MJ-0701/solon-product/main/install.ps1 | iex
```

### Local Clone

```bash
git clone https://github.com/MJ-0701/solon-product ~/tmp/solon-product
cd ~/workspace/my-project
bash ~/tmp/solon-product/install.sh
```

`~/tmp/solon-product` 는 설치/업그레이드에 쓰는 사용자의 로컬 product clone 입니다. 한 번
clone 한 뒤 시간이 지나면 GitHub 보다 뒤처질 수 있으므로, 재설치나 업그레이드 전에는
clone 을 먼저 최신화하세요.

Windows PowerShell:

```powershell
git clone https://github.com/MJ-0701/solon-product $env:TEMP\solon-product
cd C:\workspace\my-project
powershell -ExecutionPolicy Bypass -File $env:TEMP\solon-product\install.ps1
```

### Non-Interactive

Mac/Git Bash:

```bash
cd ~/workspace/my-project
bash ~/tmp/solon-product/install.sh --yes
```

Windows PowerShell source fallback:

```powershell
cd C:\workspace\my-project
powershell -ExecutionPolicy Bypass -File $env:TEMP\solon-product\install.ps1 -Yes
```

`--yes` 는 확인 프롬프트를 승인하지만, 파일 충돌이 있으면 안전한 기본값인 `skip` 을
사용합니다.

---

## Installed Files

| 경로 | 설명 |
|---|---|
| `SFS.md` | 프로젝트가 따르는 Solon 7-step + 7-Gate 공통 지침 |
| `CLAUDE.md` | Claude Code adapter |
| `AGENTS.md` | Codex adapter |
| `GEMINI.md` | Gemini CLI adapter |
| `.claude/skills/sfs/SKILL.md` | Claude Code `/sfs` Skill (primary) |
| `.claude/commands/sfs.md` | Claude Code `/sfs` legacy slash command fallback |
| `.gemini/commands/sfs.toml` | Gemini CLI `sfs ...` command |
| `.agents/skills/sfs/SKILL.md` | Codex Skill (project-scoped) |
| `.sfs-local/` | sprint, decision, event, config, custom override 를 담는 로컬 운영 디렉토리 |
| `.sfs-local/config.yaml` | runtime layout (`thin`/`vendored`) 과 override 경로 |
| `.gitignore` marker block | `.sfs-local/` 운영 파일을 위한 ignore 규칙 |

thin layout 에서는 runtime scripts/templates/personas 는 packaged `sfs` runtime 에 남고,
consumer 프로젝트에는 필요한 state/config/custom override 만 설치됩니다. vendored layout 은
기존처럼 `templates/.sfs-local-template/` 을 프로젝트에 복사합니다.

---

## Safety Contract

- install/upgrade/uninstall 은 consumer 프로젝트에 자동 push 하지 않습니다.
- `/sfs retro --close` 는 사용자가 명시적으로 호출했을 때만 report 기반 workbench/tmp archive, sprint close, auto commit 을 수행합니다.
- `/sfs tidy --apply` 는 기존 workbench 원문과 대상 sprint 의 tmp review 산출물을 `.sfs-local/archives/` 로 이동해 보존하고, sprint/tmp 폴더에는 남겨야 할 것만 둡니다. 기본 실행은 dry-run 입니다. 단일 sprint 는 정확한 ID 또는 고유 suffix 로 지정할 수 있습니다. 예: `--sprint W18-sprint-1` → `2026-W18-sprint-1`.
- gate 는 진행을 강제로 막지 않는 signal 입니다.
- 사용자가 만든 `.sfs-local/sprints/`, `.sfs-local/decisions/`, `.sfs-local/events.jsonl` 은 install/upgrade 과정에서 덮어쓰지 않습니다.
- 기존 파일과 충돌하면 `skip`, `backup + overwrite`, `overwrite`, `diff` 중 선택합니다.
- 새 marker 는 `solon-product` 를 사용하지만, install/upgrade/uninstall 은 legacy `solon-mvp` marker 도 인식합니다 (consumer 하위 호환).

---

## Version Check / Upgrade

일반 사용자는 Mac/Git Bash 에서는 `sfs upgrade`, Windows PowerShell/cmd 에서는
`sfs.cmd upgrade` 를 사용합니다. Homebrew 설치본이면 global runtime 을 먼저 최신화하고,
Scoop 설치본이면 bucket manifest 기준으로 `sfs.cmd` runtime 을 먼저 최신화한 뒤 managed
adapter/docs 를 백업 후 갱신합니다. sprint/decision/event history 와 프로젝트별 지침은 보존합니다.
`.sfs-local/model-profiles.yaml` 이 없던 기존 프로젝트에는 current-model fallback 설정으로 추가하고,
이미 있으면 사용자 agent/model 설정 보호를 위해 보존합니다. fallback 또는 미확정 상태이면
upgrade 시 다시 설정 여부를 묻고, 사용자가 지금 설정하지 않겠다고 하면 fallback 을 유지합니다.

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

Owner 가 새 버전을 배포하면 사용자는 세 경로로 알 수 있습니다.

- `sfs version --check` / `sfs.cmd version --check`: 현재 설치 버전과 GitHub 최신 product tag 를 비교합니다.
- Homebrew: `brew outdated sfs` 또는 `sfs upgrade` 실행 시 tap 의 최신 formula 를 확인합니다.
- Scoop: `scoop status sfs` 또는 `sfs.cmd upgrade` 실행 시 bucket manifest 의 최신 버전을 확인합니다.

자동 background notifier 는 두지 않습니다. SFS 는 사용자가 프로젝트 루트에서 명시적으로
`sfs version --check` / `sfs upgrade` 또는 Windows 의 `sfs.cmd version --check` /
`sfs.cmd upgrade` 를 호출하는 모델입니다.

릴리즈별 변경 내용은 `CHANGELOG.md` 의 해당 버전 섹션에서 확인합니다. 배포 전에는
대상 버전의 release note entry 를 먼저 작성해야 하며, release helper 는 `Added`,
`Changed`, `Fixed` 중심의 명시적 entry 가 없으면 `--apply` 를 막습니다.

Local clone 기반 upgrade 는 먼저 product clone 을 GitHub 최신으로 맞춘 뒤 consumer 프로젝트에서
실행합니다. 이 clone 이 오래되면 upgrade 가 낡은 `VERSION` 을 읽고 "이미 최신" 이라고 잘못
보일 수 있습니다.

```bash
git -C ~/tmp/solon-product pull --ff-only --tags
```

```bash
cd ~/workspace/my-project
bash ~/tmp/solon-product/upgrade.sh
```

Windows PowerShell:

```powershell
cd C:\workspace\my-project
powershell -ExecutionPolicy Bypass -File $env:TEMP\solon-product\upgrade.ps1
```

Upgrade 는 `.sfs-local/VERSION` 과 배포판 `VERSION` 을 비교하고, 파일을 쓰기 전에
dry-run preview 를 보여줍니다.

- `SFS.md`, `.claude/skills/sfs/SKILL.md`, `.claude/commands/sfs.md`, `.gemini/commands/sfs.toml`, `.agents/skills/sfs/SKILL.md` 는 배포판 관리 영역으로 갱신 대상입니다.
- thin layout 에서는 runtime scripts/templates/personas 를 프로젝트에 복사하지 않고 global `sfs` package 를 갱신합니다.
- vendored layout 에서는 runtime scripts/templates/personas 도 project-local 배포판 관리 영역으로 갱신합니다.
- `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.sfs-local/divisions.yaml` 은 프로젝트별 편집 가능성이 커서 기본 보존합니다.
- sprint/decision 산출물과 event log 는 보존합니다.
- legacy `### BEGIN solon-mvp ###` `.gitignore` marker 가 있으면 product marker 로 자동 교체합니다.

---

## Uninstall

```bash
cd ~/workspace/my-project
bash ~/tmp/solon-product/uninstall.sh
```

Windows PowerShell:

```powershell
cd C:\workspace\my-project
powershell -ExecutionPolicy Bypass -File $env:TEMP\solon-product\uninstall.ps1
```

Uninstall 은 대화형으로 실행됩니다.

- 전체 제거
- scaffold 만 제거하고 sprint/decision/event 산출물 보존
- 취소

---

## Repository Map

| 파일/디렉토리 | 역할 |
|---|---|
| `install.sh` | consumer 프로젝트에 Solon Product scaffold 설치 |
| `install.ps1` | Windows PowerShell install wrapper (Git Bash 필요) |
| `upgrade.sh` | 설치된 scaffold 를 새 배포판으로 갱신 |
| `upgrade.ps1` | Windows PowerShell upgrade wrapper (Git Bash 필요) |
| `uninstall.sh` | 설치된 scaffold 제거 |
| `uninstall.ps1` | Windows PowerShell uninstall wrapper (Git Bash 필요) |
| `bin/sfs` | global Bash CLI entrypoint (`sfs init`, `sfs status`, `sfs plan`, `sfs implement` 등) |
| `bin/sfs.cmd` / `bin/sfs.ps1` | Windows global wrappers for Scoop/PATH; locate Git Bash and delegate to `bin/sfs` |
| `BEGINNER-GUIDE.md` | 개발/터미널/CLI 환경이 낯선 사용자를 위한 설치 + 첫 사용 가이드 |
| `GUIDE.md` | 친구 onboarding 30분 walk-through (placeholder 치환 + 첫 sprint + FAQ + 트러블슈팅) |
| `templates/SFS.md.template` | 공통 운영 지침 |
| `templates/CLAUDE.md.template` | Claude Code adapter template |
| `templates/AGENTS.md.template` | Codex adapter template |
| `templates/GEMINI.md.template` | Gemini CLI adapter template |
| `templates/.claude/commands/sfs.md` | Claude Code Skill/legacy slash source |
| `templates/.gemini/commands/sfs.toml` | Gemini CLI `sfs ...` command |
| `templates/.agents/skills/sfs/SKILL.md` | Codex Skill (project-scoped) |
| `templates/.codex/prompts/sfs.md` | Codex custom prompt fallback (optional/legacy) |
| `templates/.sfs-local-template/context/` | short routed context modules loaded only when relevant |
| `templates/.sfs-local-template/` | packaged runtime scripts, Windows `sfs.ps1` vendored fallback, sprint templates, decision templates |
| `packaging/homebrew/sfs.rb.template` | Homebrew tap formula template (`url`/`sha256` fill-in on release cut) |
| `packaging/scoop/sfs.json.template` | Scoop bucket manifest template (`url`/`hash`/`extract_dir` fill-in on release cut) |
| `.github/workflows/windows-scoop-smoke.yml` | Windows Actions smoke for Scoop install + thin project init |
| `CHANGELOG.md` | release history |
| `VERSION` | distribution version |

---

## Release Channel

현재 distribution version 은 `VERSION` 파일과 `sfs version` 출력 기준입니다. `-mvp` suffix
(0.5.0-mvp 까지) 는 기존 설치본과의 semver 호환을 위해 유지하지만, 0.5.1+ 부터 repo
identity 와 release suffix 는 product track 기준으로 운영합니다.

Product release publish 는 Homebrew tap 과 Scoop bucket 을 같은 tag 로 갱신한 뒤 완료로
간주합니다. Release owner 는 GitHub product tag, Homebrew formula URL/sha256, Scoop
manifest URL/hash 가 모두 같은 `v<VERSION>` 을 가리키는지 확인합니다. 완료 전에는 실제
Homebrew tap clone 이 stale 이 아닌지와 `sfs version --check` 가 같은 버전 `up-to-date` 를
출력하는지도 확인합니다.

릴리스 기록은 [CHANGELOG.md](./CHANGELOG.md) 를 참조하세요.

---

## 약어 사전 (Acronym Glossary)

| 약어 | 풀네임 | 이 프로젝트에서의 의미 |
|---|---|---|
| **ADR** | Architecture Decision Record | 중요한 제품/기술 결정을 `Context / Decision / Alternatives / Consequences` 형태로 남기는 기록. SFS 에서는 `/sfs decision` 이 ADR-style decision file 을 만든다. |
| **AC** | Acceptance Criteria | 요구사항이 완료됐다고 볼 수 있는 구체적 검수 조건. `/sfs plan` 에서 구현 slice 와 review 기준으로 내려간다. |
| **API** | Application Programming Interface | 시스템/서비스/모듈 간 호출 계약. 외부 API, OpenAPI, internal API 모두 이 범주로 다룬다. |
| **CEO** | Chief Executive Officer | Solon 의 전략/요구사항/scope 관점 persona. 작은 조직에서 "무엇을 할지"를 정리하는 역할이다. |
| **CLI** | Command Line Interface | 터미널에서 실행하는 명령 인터페이스. 예: `sfs status`, `sfs plan`, `/sfs review`. |
| **Clean Layered Architecture** | Clean layered monolith | presentation/application/domain/infrastructure 같은 책임 경계를 유지하는 단일 배포 구조. SFS 에서는 MVP/소규모 프로젝트의 backend 기본값이다. |
| **CPO** | Chief Product Officer | 제품 가치와 사용자 영향 관점의 evaluator persona. review 에서 verdict 와 CTO action 을 남긴다. |
| **CQRS** | Command Query Responsibility Segregation | 쓰기 command/use case 와 읽기 query/read path 를 분리하는 backend 설계 방식. SFS 에서는 초기 MVP 를 벗어난 backend 의 기본값이며, 단일 DB 여도 적용 가능하다. |
| **CTO** | Chief Technology Officer | 기술 설계/구현 책임 persona. CPO review 결과를 받아 구현 수정과 최종 정리를 담당한다. |
| **DDD** | Domain-Driven Design | 도메인 언어와 모델을 먼저 정렬한 뒤 코드와 문서를 설계하는 방식. SFS 에서는 Gate 2/3 부터 적용되는 cross-phase guardrail 이다. |
| **DoD** | Definition of Done | 완료 정의. 코드 변경, 테스트 evidence, review, report/retro 등 작업별 종료 조건을 뜻한다. |
| **Gate 1..7** | Gate labels | Solon report 의 사용자 표기. Gate 1 (Intake), Gate 2 (Brainstorm), Gate 3 (Plan), Gate 4 (Design), Gate 5 (Handoff), Gate 6 (Review), Gate 7 (Retro). |
| **GUI** | Graphical User Interface | 그래픽 기반 화면 인터페이스. Solon 은 CLI first 이고 GUI 는 optional/product expansion 영역이다. |
| **Hexagonal Architecture** | Ports and Adapters Architecture | 도메인 내부와 외부 adapter 를 분리하는 구조. SFS 에서는 도메인 seam 이 커졌을 때 사용자 수용을 받은 뒤 전환하는 리팩토링 단계다. |
| **JSONL** | JSON Lines | 한 줄에 JSON 객체 하나씩 쌓는 로그 형식. `.sfs-local/events.jsonl` 이 대표 예시다. |
| **L1 / L2 / L3** | Log / Docs / Driver channels | Observability 3채널. L1은 events, L2는 git docs SSoT, L3는 Notion/Obsidian 같은 외부 driver view. |
| **LLM** | Large Language Model | Claude, Codex, Gemini 같은 AI 모델/runtime. SFS 는 여러 LLM runtime 이 같은 문서 계약을 읽도록 맞춘다. |
| **MCP** | Model Context Protocol | Claude/Codex 등에서 외부 도구나 데이터 소스를 연결하는 프로토콜/connector 계층. |
| **MSA** | Microservice Architecture | 독립 배포 가능한 서비스들로 나누는 아키텍처. SFS 에서는 독립 배포/스케일/소유권/장애 격리 필요가 확인되고 사용자가 승인한 뒤에만 전환한다. |
| **MVP** | Minimum Viable Product | 가장 작은 검증 가능한 제품 범위. SFS 에서는 과한 절차를 MVP filter 로 접고 핵심 evidence 만 남긴다. |
| **OSS** | Open Source Software | 공개 가능한 오픈소스 트랙. private/business-only 자산과 구분해 관리한다. |
| **PDCA** | Plan / Do / Check / Act | 계획, 실행, 검증, 회고의 작업 사이클. Solon sprint 안의 기본 흐름이다. |
| **PII** | Personally Identifiable Information | 개인 식별 정보. release readiness 에서 secret/auth/data risk 와 함께 점검한다. |
| **PM** | Product Manager | 요구사항, 우선순위, acceptance criteria 를 정리하는 제품 관리 역할. Solon 에서는 strategy-pm division 으로 표현된다. |
| **PRD** | Product Requirements Document | 제품 요구사항 문서. 사용자의 의도와 scope 를 구현 가능한 계약으로 바꾼 산출물이다. |
| **QA** | Quality Assurance | 품질 검증 역할/본부. 테스트 시나리오, review evidence, release readiness 를 점검한다. |
| **RBAC** | Role-Based Access Control | 역할 기반 권한 모델. 관리자/매니저/뷰어 같은 권한 설계를 말할 때 쓰인다. |
| **S3** | Simple Storage Service | AWS 의 object storage. 문서에서는 L1 event 저장소 예시로 등장한다. |
| **SFS** | Sprint Flow System / Solo Founder System | 터미널 표면의 `sfs` 는 Sprint Flow System, Solon Product 전체의 SFS 는 Solo Founder System 이다. `/sfs` command, sprint flow, decision/review/retro 구조를 포함한다. |
| **SSoT** | Single Source of Truth | 유일 정보원. 규칙이나 상태가 여러 곳에 흩어질 때 최종 기준으로 삼는 원본 문서/파일을 뜻한다. |
| **TDD** | Test-Driven Development | 테스트를 먼저 또는 아주 작은 검증 loop 로 두고 구현하는 방식. SFS 에서는 Gate 3 AC, implement evidence, review 신호를 잇는 feedback-loop guardrail 이다. |
| **UI / UX** | User Interface / User Experience | 화면 구성과 사용자 경험. taxonomy/design/dev 산출물이 함께 맞춰야 하는 영역이다. |
| **WIP** | Work In Progress | 아직 완료되지 않은 진행 중 작업. SFS 는 WIP 를 sprint workbench 문서와 event log 로 남긴다. |
| **WU** | Work Unit | 작업 단위. `/sfs status` 의 WU 는 현재 sprint 안에서 진행 중인 작은 실행 단위를 가리킨다. |

---

## 6개 본부 설명 (Division Glossary)

| 본부 | 주로 보는 것 | 쉽게 말하면 |
|---|---|---|
| **strategy-pm** | 요구사항, scope, 우선순위, AC, sprint plan | "무엇을 왜 만들지"를 정리하는 제품/전략 본부 |
| **taxonomy** | 도메인 용어, 분류 체계, entity/name consistency | 팀과 AI가 같은 단어를 쓰게 만드는 언어/모델 본부 |
| **design** | UX flow, UI 구조, design concept, handoff | 사용자가 보는 경험과 화면 구조를 잡는 디자인 본부 |
| **dev** | 코드 구현, API, DB, transaction, test evidence | 실제로 돌아가는 코드를 만드는 개발 본부 |
| **QA** | acceptance 검증, regression, release confidence | 만든 것이 요구사항대로 동작하는지 확인하는 품질 본부 |
| **infra** | 배포, 보안, 인증/secret, monitoring, rollback, cost | 제품이 안전하게 배포·운영되게 하는 인프라 본부 |
