# Solon Product

> AI-native product work 를 위한 Company-as-Code 운영 레이어.
> Solon Product 는 제품 개발에 필요한 역할 분리, 결정 기록, 검증, 회고, 인수인계를
> 프로젝트 안에 설치합니다.

Solon Product 는 Claude Code, Codex, Gemini CLI 같은 LLM agent 와 함께 제품을 만들 때
작업 맥락이 사라지지 않도록 돕는 로컬 운영 시스템입니다. 설치하면 현재 repository 안에
공통 지침, runtime adapter, `/sfs` 명령, sprint 산출물, decision log, review/retro 흐름이
생깁니다.

핵심 약속은 단순합니다.

- AI 는 실행 속도를 높인다.
- Solon 은 역할, 기록, 검증, 인수인계 구조를 고정한다.
- 사용자는 방향과 최종 통과 여부를 결정한다.

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

---

## How It Works

1. 기존 프로젝트에 Solon Product 를 설치합니다.
2. `/sfs start <goal>` 로 sprint workspace 를 만듭니다.
3. `/sfs brainstorm` 으로 raw 요구사항과 대화 맥락을 G0 산출물에 남깁니다.
4. `/sfs plan` 에서 CEO plan 과 CTO/CPO sprint contract 를 남깁니다.
5. CTO Generator 가 구현하고, `/sfs review --gate G4 --executor codex|gemini|claude` 로 CPO Evaluator review 를 남깁니다.
6. `/sfs status` 와 `.sfs-local/events.jsonl` 로 현재 상태를 확인합니다.
7. 필요하면 Codex/Gemini/Claude 가 같은 문서 계약을 읽고 다음 작업을 이어갑니다.

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
| Process | CEO 요구사항/plan → CTO/CPO sprint contract → CTO 구현 → CPO review → CTO rework/final confirm → retro |
| Artifact | `brainstorm.md`, `plan.md`, `review.md`, `retro.md`, ADR-style decision |
| State | `/sfs status`, `.sfs-local/current-sprint`, `.sfs-local/events.jsonl` |
| Safety | signal-only gate, human final filter, no automatic push |

7-step flow 는 full startup artifact chain 의 product-facing projection 입니다. Discovery,
PRD, Taxonomy, UX, Technical Design, Release Readiness 를 없애는 것이 아니라, 작은 팀과
1인 창업자가 매일 운용할 수 있는 형태로 접어 둔 것입니다.

각 작업 단위가 통과할 수 있는 7 개의 검증 지점 (`G-1, G0, G1, G2, G3, G4, G5`) 이 있고,
verdict 는 `pass / partial / fail` 3-enum 입니다 (G3 만 binary `block / unblock`). gate 는
진행을 강제로 막지 않는 signal 입니다.

### 3 C-Level Flow

Solon Product 의 3 C-Level 은 README 의 6 Division + 3 C-Level 모델에서 온다.

| C-Level | Sprint 책임 | 기본 persona |
|---|---|---|
| CEO | 요구사항 정리, scope, plan 승인 | `.sfs-local/personas/ceo.md` |
| CTO Generator | sprint contract 구현, CPO finding 반영 | `.sfs-local/personas/cto-generator.md` |
| CPO Evaluator | 품질검증, verdict, CTO action 제시 | `.sfs-local/personas/cpo-evaluator.md` |

리뷰는 필수이고, 리뷰 도구는 선택 가능하다. Claude 로 구현한 작업은 Codex/Gemini CLI 같은
다른 도구나 별도 agent instance 로 CPO review 를 돌려 self-validation 위험을 낮춘다.

### Adaptor Design Intent

`/sfs` adaptor 의 배경은 단순한 vendor별 명령어 통일이 아니다. 사용자가 Claude 를 주 구현
도구로 쓰더라도, **Claude 가 만든 결과를 Claude 가 그대로 통과시키는 자체검증을 피하기 위해**
Codex plugin, Codex CLI, Gemini CLI, 또는 별도 agent instance 로 CPO review 를 위임할 수 있어야 한다.

따라서 `/sfs review` 의 `--executor` 는 audit metadata 가 아니라 review bridge 의 의도다.
`--run` 을 붙이면 실제 CLI/bridge 를 호출한다. bridge 가 없으면 조용히 성공하지 않고 실패해야 한다.
Claude 내부에 연결된 Codex plugin 은 shell 에서 자동 호출할 수 없으므로, plugin bridge command 를
설정하거나 Claude adaptor 가 printed prompt 를 plugin 으로 넘기는 2-step 이 필요하다.

Bridge 는 대칭이 아니다.

| CTO 구현 host | CPO review target | 지원 방식 |
|---|---|---|
| Claude | Codex | Claude 쪽 Codex plugin/manual bridge 또는 `codex` CLI |
| Claude | Gemini | `gemini` CLI |
| Codex | Claude | `claude` CLI (`--executor claude --run`) 또는 `--print-prompt` 후 Claude handoff |
| Codex | Claude plugin | 지원하지 않음. Codex 는 Claude plugin host 가 아니다 |
| Gemini | Claude/Codex | 각 CLI bridge 또는 prompt handoff |

Headless CLI review 는 인증도 bridge 의 일부다. SFS 는 `.sfs-local/auth.env` 를 있으면 자동
로드한다. 이 파일은 gitignore 대상이며, `.sfs-local/auth.env.example` 을 복사해서
`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`, `SFS_REVIEW_*_CMD` 같은 로컬 값을
넣는다. Codex/Claude/Gemini CLI login cache 를 쓰려면 `SFS_CODEX_AUTH_READY=1`,
`SFS_CLAUDE_AUTH_READY=1`, `SFS_GEMINI_AUTH_READY=1` 중 해당 값을 명시한다.
인증 상태는 `/sfs auth status` 로 확인하고, 필요하면 `/sfs auth login --executor <tool>` 로
브라우저/터미널 인증을 먼저 끝낸다. bridge 자체만 확인할 때는 `/sfs auth probe --executor <tool> --timeout 20` 로
작은 dummy request/response 를 확인한다. `/sfs review --run` 도 실행 전에 인증을 확인하고,
리뷰할 evidence 가 없으면 executor 를 호출하지 않는다.

---

## Quickstart

설치할 프로젝트 루트에서 실행합니다.

```bash
cd ~/workspace/my-project
curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-product/main/install.sh | bash
```

Windows PowerShell 사용자는 **Git for Windows 의 Git Bash** 가 필요합니다. PowerShell 에서는
wrapper 를 사용할 수 있습니다:

```powershell
cd C:\workspace\my-project
iwr -useb https://raw.githubusercontent.com/MJ-0701/solon-product/main/install.ps1 | iex
```

설치 후 Solon 의 public command surface 는 세 런타임 모두 `/sfs` 입니다. Runtime adaptor 는
각 vendor 의 입력면 차이를 흡수해서 같은 bash adapter 로 내려보내야 합니다. 자동 install 된 entry point 는
`.claude/commands/sfs.md` + `.gemini/commands/sfs.toml` + `.agents/skills/sfs/SKILL.md`
입니다.

> 📘 **친구 onboarding 30분 walk-through**: 설치 직후 처음 30분 동안 `SFS.md` placeholder 치환,
> 첫 sprint 시작, plan/review/decision/retro 흐름까지 따라 하는 가이드는 [GUIDE.md](./GUIDE.md)
> 참조. "SFS.md 에 프로젝트 스택 적어도 되는지" 같은 자주 묻는 오해도 거기서 해소.

```text
/sfs status
/sfs guide
/sfs auth status
/sfs start "첫 번째 sprint 목표"
/sfs brainstorm "raw 요구사항과 아직 정리 안 된 맥락"
/sfs plan
/sfs review --gate G4 --executor codex --generator claude --run
/sfs decision "초기 인증 방식은 세션 기반으로 시작한다"
/sfs retro --close
```

Codex desktop app / compatible Codex surfaces 에서 `/sfs ...` 입력이 prompt 본문으로
모델/Skill 까지 도달하면 그 경로가 canonical 1급 경로입니다. 앱 UI 가 별도 command chip 을
표시하지 않아도, 모델이 `/sfs ...` 메시지를 읽을 수 있으면 `.agents/skills/sfs/SKILL.md`
가 즉시 bash adapter 로 dispatch 해야 합니다. Codex CLI 일부 build 에서만 bare `/sfs` 가
native slash parser 에서 모델/Skill 전에 차단될 수 있습니다. 이것은 사용자 호출법 차이가
아니라 Codex CLI adaptor compatibility gap 입니다. `$sfs status`, `$sfs plan`, `sfs status`,
자연어 요청, direct bash 는 그 CLI build 에서만 쓰는 임시 bypass 입니다.

세 환경 모두 같은 `.sfs-local/scripts/sfs-*.sh` bash adapter 를 SSoT 로 호출합니다 — paraphrase
금지, vendor 마다 결과 동일성 보장.

Windows PowerShell 에서 direct adapter 를 호출해야 하면:

```powershell
.\.sfs-local\scripts\sfs.ps1 status
.\.sfs-local\scripts\sfs.ps1 guide
```

이 wrapper 는 Git Bash 를 찾아 `.sfs-local/scripts/sfs-dispatch.sh` 로 넘깁니다.
WSL 사용자는 WSL shell 안에서 `bash .sfs-local/scripts/sfs-dispatch.sh status` 처럼 직접
실행합니다. 순수 PowerShell-only 환경은 아직 지원선 밖입니다.

---

## Product Surface

| 명령 | 역할 |
|---|---|
| `/sfs status` | 현재 sprint, WU, gate, ahead count, last event 를 한 줄로 표시 |
| `/sfs start <goal>` | 새 sprint workspace 초기화 (`--id <sprint-id>` 지원) |
| `/sfs guide [--path|--print]` | 짧은 사용 맥락 브리핑 / guide 경로 / full guide 본문 보기 |
| `/sfs auth status|check|login|probe` | Codex/Claude/Gemini review executor 인증 확인/로그인/더미 요청 (`probe --timeout <seconds>` 지원) |
| `/sfs brainstorm [text|--stdin]` | G0 raw 요구사항/대화 맥락을 `brainstorm.md` 에 기록 |
| `/sfs plan` | 현재 sprint 의 `plan.md` 작성 또는 갱신 |
| `/sfs review --gate <id> [--executor <tool>] [--run]` | CPO Evaluator review prompt 기록. `--run` 은 리뷰할 evidence 가 있을 때만 실제 bridge 호출 (id ∈ G-1..G5) |
| `/sfs decision <title>` | full ADR (decisions/) 또는 sprint-local mini-ADR 자동 분기 |
| `/sfs retro` | 현재 sprint 의 `retro.md` 작성 또는 갱신 |
| `/sfs retro --close` | review 실행 여부 확인 후 sprint close + auto commit (push 는 manual) |
| `/sfs loop [OPTIONS]` | 큰 작업에서 micro-step 단위 반복 실행을 돕는 자율 진행 모드 |

10 명령 모두 동일 bash adapter SSoT 입니다. `/sfs` 가 public API 이고, Skill/prompt/wrapper 는
그 API 를 runtime 별로 전달하는 adaptor surface 입니다.

### `/sfs loop` 자세히

`/sfs loop` 는 자율 진행 (Ralph Loop 패턴) 의 LLM 호출 site 입니다. LLM 이 한 micro-step →
PROGRESS 갱신 → 자기 review gate → 다음 micro-step 을 cap (`--max-iters` default 5) 까지 반복.
multi-vendor executor 1급 지원:

- `--executor claude` → `claude -p --dangerously-skip-permissions`
- `--executor gemini` → `gemini --skip-trust --yolo --output-format text -p "Read stdin and execute the requested task."`
- `--executor codex` → `codex exec --full-auto`
- `--executor "<custom command>"` → 그대로 passthrough

이 convention 은 `/sfs loop` 만 적용되는 게 아니라 Solon-wide invariant — 모든 명령이 어느 1급
CLI 에서든 동등한 deterministic bash adapter SSoT 로 동작합니다.

---

## Runtime Coverage

설치 후 10 명령은 **세 런타임 모두에서 1급 entry point** 로 연결됩니다.

| 런타임 | Entry point (자동 install) | 호출 방법 |
|---|---|---|
| **Claude Code** | `.claude/commands/sfs.md` (Markdown slash) | `/sfs status` |
| **Gemini CLI** | `.gemini/commands/sfs.toml` (TOML slash) | `/sfs status` |
| **Codex desktop app / compatible Codex surfaces** | `.agents/skills/sfs/SKILL.md` (project-scoped Skill, agentskills.io 표준) | `/sfs status` |
| **Codex CLI blocking builds** | same Skill | `$sfs status` / `sfs status` / 자연어 임시 bypass |

Codex desktop app 에서 `/sfs` 가 모델/Skill 에 보이는 경로는 제거하거나 격하하면 안 됩니다.
그 메시지를 읽은 Codex adapter 는 "unrecognized command" 로 답하지 말고 즉시 dispatch 합니다.
Codex CLI/TUI 에서만 bare `/sfs` 가 native slash parser 에 막히면 **runtime adapter compatibility
gap** 으로 분류합니다. Desktop app 과 CLI 둘 다 `/sfs` 를 public surface 로 받아야 Solon parity 가
완료됩니다.
일부 Codex build 에서 user prompt fallback (`/prompts:sfs ...`, `~/.codex/prompts/sfs.md`) 을
쓸 수 있지만, install.sh 는 user `$HOME` 에 자동 cp 하지 않습니다 (사용자 영역 보호).
지원되는 build 에서만 manual cp:

```sh
mkdir -p ~/.codex/prompts
cp <consumer-project>/templates/.codex/prompts/sfs.md ~/.codex/prompts/sfs.md
```

---

## Installation

### Remote One-Liner

```bash
cd ~/workspace/my-project
curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-product/main/install.sh | bash
```

Windows PowerShell:

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

```bash
cd ~/workspace/my-project
bash ~/tmp/solon-product/install.sh --yes
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
| `.claude/commands/sfs.md` | Claude Code `/sfs` slash command |
| `.gemini/commands/sfs.toml` | Gemini CLI `/sfs` slash command |
| `.agents/skills/sfs/SKILL.md` | Codex Skill (project-scoped) |
| `.sfs-local/` | sprint, decision, event, runtime script 를 담는 로컬 운영 디렉토리 |
| `.gitignore` marker block | `.sfs-local/` 운영 파일을 위한 ignore 규칙 |

`templates/` 아래 파일은 consumer 프로젝트에 설치되는 배포 자산입니다.

---

## Safety Contract

- install/upgrade/uninstall 은 consumer 프로젝트에 자동 push 하지 않습니다.
- `/sfs retro --close` 는 사용자가 명시적으로 호출했을 때만 sprint close 와 auto commit 을 수행합니다.
- gate 는 진행을 강제로 막지 않는 signal 입니다.
- 사용자가 만든 `.sfs-local/sprints/`, `.sfs-local/decisions/`, `.sfs-local/events.jsonl` 은 install/upgrade 과정에서 덮어쓰지 않습니다.
- 기존 파일과 충돌하면 `skip`, `backup + overwrite`, `overwrite`, `diff` 중 선택합니다.
- 새 marker 는 `solon-product` 를 사용하지만, install/upgrade/uninstall 은 legacy `solon-mvp` marker 도 인식합니다 (consumer 하위 호환).

---

## Upgrade

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

- `SFS.md`, `.claude/commands/sfs.md`, `.gemini/commands/sfs.toml`, `.agents/skills/sfs/SKILL.md`, runtime scripts 는 배포판 관리 영역으로 갱신 대상입니다.
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
| `GUIDE.md` | 친구 onboarding 30분 walk-through (placeholder 치환 + 첫 sprint + FAQ + 트러블슈팅) |
| `templates/SFS.md.template` | 공통 운영 지침 |
| `templates/CLAUDE.md.template` | Claude Code adapter template |
| `templates/AGENTS.md.template` | Codex adapter template |
| `templates/GEMINI.md.template` | Gemini CLI adapter template |
| `templates/.claude/commands/sfs.md` | Claude Code slash command |
| `templates/.gemini/commands/sfs.toml` | Gemini CLI slash command |
| `templates/.agents/skills/sfs/SKILL.md` | Codex Skill (project-scoped) |
| `templates/.codex/prompts/sfs.md` | Codex custom prompt fallback (optional/legacy) |
| `templates/.sfs-local-template/` | runtime scripts, Windows `sfs.ps1` wrapper, sprint templates, decision templates |
| `CHANGELOG.md` | release history |
| `VERSION` | distribution version |

---

## Release Channel

현재 distribution version 은 `0.5.3-product` 입니다. `-mvp` suffix (0.5.0-mvp 까지) 는 기존 설치본
과의 semver 호환을 위해 유지하지만, 0.5.1+ 부터 repo identity 와 release suffix 는 product
track 기준으로 운영합니다.

릴리스 기록은 [CHANGELOG.md](./CHANGELOG.md) 를 참조하세요.
