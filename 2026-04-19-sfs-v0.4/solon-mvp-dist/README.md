# Solon MVP

> **1인 창업가가 회사의 역할 분리·검증·기억·회복을 파일과 agent 로 재현하게 만드는 운영 시스템.**
> Claude Code · Codex · Gemini CLI 어떤 LLM agent 에서도 동일하게 동작하는 "Company-as-Code" 경량 스캐폴드.

**버전**: `0.5.0-mvp` · **라이선스**: 개인 IP — 외부 배포·상업 이용 신중 (정식 라이선스 TBD) · **상태**: MVP — 풀스펙 아님, 도구 자체는 실 운영 중

---

## 친구야, 이게 뭐야?

쉽게 말하면, **혼자 일하는데 회사처럼 일하게 도와주는 도구**야.

너가 1인 창업가 / 사이드 프로젝트 개발자라고 해 보자. AI 와 같이 코드를 쓰면 빨리 만들 수 있긴 한데, 시간 지나면 이런 게 쌓여:

- "내가 왜 이렇게 만들었더라?" — 어제 한 결정 근거가 사라짐
- "이 코드 또 갈아엎어야 되네" — 설계 안 하고 일단 만들었더니 모순 누적
- "AI 가 통과시켰는데 실은 다 망했네" — 만든 사람이 자기검증
- "다음 세션에서 이어서 한다고 했는데 어디까지 했는지 모름" — 맥락 유실

Solon 은 이걸 **회사가 쓰는 방식**으로 풀려는 시도야. 진짜 회사처럼 사람을 쓰는 게 아니라, 회사를 움직이는 더 작은 단위들 — 역할 / 책임 / 의사결정 / 산출물 / 검증 / 회고 / 인수인계 — 을 **파일과 명령으로 고정**해 두는 거지. 그래서 AI 가 일하게 하되, AI 가 방향을 결정하지는 못하게.

자세한 철학은 아래 "왜 만들었나" + "핵심 컨셉" 두 섹션에 있어. 일단 써 보고 싶으면 [친구 시작 가이드](#친구-시작-가이드--5분-vs-30분) 로 바로 가.

---

## 왜 만들었나

### 1인 창업가의 7-역할 병목

MVP 하나를 시장에 내려고 해도 최소한 이 7 역할이 필요해: **CEO · CTO · CPO · PM · Designer · Developer · QA/Infra**. 한 사람이 다 떠안으면 같은 패턴이 반복돼:

- 무엇을 만들지 결정하지 못해 실행이 늦어진다
- 설계 없이 만들다가 나중에 갈아엎는다
- 구현은 됐지만 사용자가 왜 써야 하는지 흐려진다
- 테스트와 배포가 뒤로 밀려 출시 품질이 무너진다
- 세션이 바뀔 때마다 의사결정 근거가 사라진다

Solon 은 이 역할 공백을 **6 Division (본부) + 3 C-Level** 구조의 agent 조직으로 대체하려는 시도야.

### 맥락 유실

agent 작업의 가장 큰 적은 능력 부족이 아니라 **맥락 유실**이야. 세션이 끊기고, 작업 단위가 커지고, commit 이 밀리고, 같은 파일을 여러 worker 가 건드리면 "왜 이 결정을 했는가" 가 사라져. 그러면 다음 agent 는 결과만 보고 다시 추측해.

Solon 은 이 추측을 줄이기 위해 강제하는 게 있어:

- `PROGRESS.md` 라는 살아있는 single-frame snapshot
- WU (Work Unit) 단위 작업 기록
- gate / decision / event 로그
- frontmatter 기반 문서 의존성
- commit 전후 sha backfill
- session retro + learning log

즉 Solon 의 문서는 "설명서" 가 아니라 **작업 기억 장치** 야.

### 자기검증 금지

LLM 은 자기 산출물을 자기가 통과시키기 너무 쉬워. "좋아 보이는 답" 과 "실제로 통과한 결과" 가 섞이면 시스템이 조용히 부패해. Solon 은 이걸 막기 위해 자기검증 금지를 핵심 원칙으로 둬: 만든 agent 와 검증 agent 분리, gate operator 별도, **사람의 최종 필터** 보존, 실패는 learning log 에 남겨 다음 sprint 입력으로.

---

## 핵심 컨셉 (용어 5분 사전)

### Company-as-Code

회사를 다음 4 축으로 정의하고 각 축을 파일·명령으로 재현 가능하게 만드는 것.

```text
Company = Org × Process × Artifact × Observability
```

- **Org**: 누가 어떤 책임을 지는가 (6 Division + 3 C-Level)
- **Process**: 어떤 순서로 생각·실행·검증하는가 (7-step + 4 Gate)
- **Artifact**: 무엇을 남겨야 다음 사람이 이어받는가 (Plan / Review / Decision / Retro)
- **Observability**: 지금 어디까지 왔고 무엇이 막혔는가 (PROGRESS / events / status)

### 7-step Flow

브레인스토밍 → plan → sprint → 구현 → review → commit → 문서화. 본 MVP 가 주입하는 가벼운 projection 이고, 풀스펙 (Discovery / PRD / Taxonomy / UX / Technical Design / Release Readiness) 은 별도 docset 에 있어.

### 7 Gate

각 작업 단위가 통과할 수 있는 7 개의 검증 지점 (`G-1, G0, G1, G2, G3, G4, G5`). **Gate 는 진행을 막지 않는 signal** (never-hard-block 원칙) — 사용자가 통과 여부 결정해. verdict 는 `pass / partial / fail` 3-enum (G3 만 binary `block / unblock`).

### `/sfs` 7 명령 (multi-adaptor 1급)

Claude Code · Codex · Gemini CLI **셋 다 native slash 1급으로 호출** 가능. 셋 모두 동일한 `.sfs-local/scripts/sfs-*.sh` bash adapter 를 SSoT 로 사용 — paraphrase 금지, 결정성 보장.

| 명령 | 무엇을 하나 |
|---|---|
| `/sfs status` | 현재 sprint·WU·gate·ahead·last_event 1줄 dashboard |
| `/sfs start <goal>` | 새 sprint 시작 또는 기존 sprint 이어가기 |
| `/sfs plan` | 현 sprint 의 `plan.md` 작성·갱신 (의도·경계 기록) |
| `/sfs review --gate <id>` | `review.md` 작성·갱신 + gate verdict 기록 (id ∈ G-1..G5) |
| `/sfs decision <title>` | full ADR (decisions/) 또는 mini-ADR (sprint-local) 신설 |
| `/sfs retro --close` | sprint 회고 + sprint close + auto-commit (push 는 manual) |
| `/sfs loop [OPTIONS]` | Ralph Loop + Solon mutex 자율 진행 (multi-vendor LLM executor) |

### 작업 단위 — Sprint / WU / micro-step

```text
Sprint  = 한 묶음의 의도·산출 단위 (plan / review / decision / retro 의 컨테이너)
   ↓
WU      = "1 회 git commit 으로 완결되는 최소 작업 단위" (Work Unit)
   ↓
micro-step = WU 안의 1 회 PROGRESS 갱신 단위 (~5-10 분)
```

가장 작은 단위가 micro-step 인 이유 = 토큰 한계·세션 종료·사고 발생 시 작업 유실 최소화.

### `/sfs loop` 자세히 (큰 작업용)

`/sfs loop` 는 자율 진행 (Ralph Loop 패턴) 의 LLM 호출 site. 사용자가 "큰 작업 = 자율 진행" 결정 시 LLM 이 한 micro-step → PROGRESS 갱신 → 자기 review gate → 다음 micro-step 을 cap (`--max-iters` default 5) 까지 반복. **multi-vendor executor** 1급 지원:

- `--executor claude` → `claude -p --dangerously-skip-permissions`
- `--executor gemini` → `gemini -p --yolo`
- `--executor codex` → `codex exec --full-auto`
- `--executor "<custom command>"` → 그대로 passthrough (자체 LLM CLI 도 OK)

이 convention 은 `/sfs loop` 만 적용되는 게 아니라 **Solon-wide invariant** — Solon 의 모든 명령이 어느 1급 CLI 에서든 동등한 deterministic bash adapter SSoT 로 동작한다.

---

## 친구 시작 가이드 — 5분 vs 30분

### 5 분 quickstart (일단 써 보기)

내 macbook 에 Claude Code · Codex · Gemini CLI 셋 중 하나 깔려 있다고 치자.

```bash
# (1) 자기 프로젝트로 이동
cd ~/workspace/my-project

# (2) 원격 한 줄로 설치
curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-mvp/main/install.sh | bash

# (3) Claude Code 켜고 첫 sprint 시작
/sfs status
/sfs start 첫 번째 목표를 한 문장으로 설명
```

여기까지가 5 분. 이 상태에서 평소처럼 코딩하다가 결정 내릴 때마다 `/sfs decision "..."`, sprint 끝낼 때 `/sfs retro --close` 만 호출해. 나머지는 그냥 평소대로 코드 쓰면 돼.

### 30 분 deep dive (구조 이해하면서 써 보기)

위 5 분 quickstart 후 다음 5 단계를 추천해:

1. `cat SFS.md` — 본 프로젝트가 따라야 할 7-step + 4-Gate 공통 지침
2. `cat CLAUDE.md` (또는 `AGENTS.md` / `GEMINI.md`) — 본인이 쓰는 LLM 의 어댑터
3. `ls .sfs-local/` — sprint 산출물 + 결정 로그 + event 로그가 들어가는 곳
4. `/sfs plan` 한 번 돌려보고 `cat .sfs-local/sprints/<your-sprint>/plan.md` 로 결과 확인
5. 일주일 사용 후 `/sfs retro --close` 돌려서 회고가 어떻게 자동 누적되는지 확인

이 단계 끝나면 본격 사용 OK.

---

## 설치 — 3 가지 방법

### 방법 1 — 원격 one-liner (가장 빠름)

```bash
cd ~/workspace/my-project
curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-mvp/main/install.sh | bash
```

### 방법 2 — 로컬 clone 후 실행 (오프라인·수정 가능)

```bash
git clone https://github.com/MJ-0701/solon-mvp ~/tmp/solon-mvp
cd ~/workspace/my-project
~/tmp/solon-mvp/install.sh
```

### 방법 3 — 수동 cp (완전 통제)

```bash
git clone https://github.com/MJ-0701/solon-mvp ~/tmp/solon-mvp
cd ~/workspace/my-project
cp ~/tmp/solon-mvp/templates/SFS.md.template      SFS.md
cp ~/tmp/solon-mvp/templates/CLAUDE.md.template   CLAUDE.md
cp ~/tmp/solon-mvp/templates/AGENTS.md.template   AGENTS.md
cp ~/tmp/solon-mvp/templates/GEMINI.md.template   GEMINI.md
mkdir -p .claude/commands .gemini/commands .agents/skills/sfs
cp    ~/tmp/solon-mvp/templates/.claude/commands/sfs.md   .claude/commands/sfs.md
cp    ~/tmp/solon-mvp/templates/.gemini/commands/sfs.toml .gemini/commands/sfs.toml
cp    ~/tmp/solon-mvp/templates/.agents/skills/sfs/SKILL.md .agents/skills/sfs/SKILL.md
cp -r ~/tmp/solon-mvp/templates/.sfs-local-template       .sfs-local
cat   ~/tmp/solon-mvp/templates/.gitignore.snippet       >> .gitignore
# placeholder 치환 (<PROJECT-NAME>, <DATE>, <STACK>, …) 은 에디터에서 수동
# (선택) Codex user-scoped slash fallback:
#   mkdir -p ~/.codex/prompts && cp ~/tmp/solon-mvp/templates/.codex/prompts/sfs.md ~/.codex/prompts/sfs.md
```

### 설치 후 3 단계

1. `SFS.md` 의 `<PROJECT-NAME>` / `<STACK>` / `<DB>` / `<DEPLOY>` placeholder 치환
2. 선호 런타임 (Claude Code / Codex / Gemini) 에서 `/sfs status` → `/sfs start <goal>`
3. 평소처럼 작업 + 결정 시 `/sfs decision`, sprint 마감 시 `/sfs retro --close`

---

## 런타임별 호출 (셋 다 native slash 1급)

설치 후 `/sfs` 7 명령은 **세 런타임 모두에서 native 등록**된다. 같은 `.sfs-local/scripts/sfs-*.sh` bash adapter 가 SSoT — vendor 마다 결과 동일성 보장.

| 런타임 | Entry point (자동 install) | 호출 방법 |
|---|---|---|
| **Claude Code** | `.claude/commands/sfs.md` (Markdown slash) | `/sfs status` |
| **Gemini CLI** | `.gemini/commands/sfs.toml` (TOML slash) | `/sfs status` |
| **Codex** | `.agents/skills/sfs/SKILL.md` (project-scoped Skill) | `$sfs status` (explicit) 또는 자연어 (implicit, e.g. "현재 상태") |

### Codex 의 user-scoped slash fallback (선택)

Codex 는 native `/sfs` popup slash 도 별도 user-scoped path 에서 지원한다 (`~/.codex/prompts/sfs.md`). 본 file 은 install.sh 가 자동 install 하지 않음 (user $HOME 영역 보호) — 원하면 manual cp:

```sh
mkdir -p ~/.codex/prompts
cp <consumer-project>/templates/.codex/prompts/sfs.md ~/.codex/prompts/sfs.md
```

설치 후 Codex CLI 에서 `/sfs status` 입력하면 native popup 에 등장.

---

## 주요 산출물 / 파일

| 무엇 | 어디 |
|---|---|
| 설치 (대화형 충돌 처리) | [`install.sh`](./install.sh) |
| 업그레이드 (VERSION diff + 파일별 merge) | [`upgrade.sh`](./upgrade.sh) |
| 제거 (산출물 보존 옵션) | [`uninstall.sh`](./uninstall.sh) |
| 7-step + 4-Gate 공통 지침 | [`templates/SFS.md.template`](./templates/SFS.md.template) |
| Claude Code adapter | [`templates/CLAUDE.md.template`](./templates/CLAUDE.md.template) |
| Codex adapter | [`templates/AGENTS.md.template`](./templates/AGENTS.md.template) |
| Gemini CLI adapter | [`templates/GEMINI.md.template`](./templates/GEMINI.md.template) |
| Claude Code `/sfs` 슬래시 (Markdown) | [`templates/.claude/commands/sfs.md`](./templates/.claude/commands/sfs.md) |
| Gemini CLI `/sfs` 슬래시 (TOML) | [`templates/.gemini/commands/sfs.toml`](./templates/.gemini/commands/sfs.toml) |
| Codex Skill (project-scoped) | [`templates/.agents/skills/sfs/SKILL.md`](./templates/.agents/skills/sfs/SKILL.md) |
| Codex user-scoped slash (optional fallback) | [`templates/.codex/prompts/sfs.md`](./templates/.codex/prompts/sfs.md) |
| `.sfs-local/` scaffold (sprint·decision·event 로그) | [`templates/.sfs-local-template/`](./templates/.sfs-local-template/) |
| `.gitignore` 블록 (marker 기반) | [`templates/.gitignore.snippet`](./templates/.gitignore.snippet) |

---

## Idempotency & 충돌 처리

`install.sh` 는 **재실행 가능** 해. 기존 파일 충돌 시 4 가지 중 선택:

- `[s] skip` — 기존 유지 (default, 안전)
- `[b] backup + overwrite` — `.bak-YYYYMMDD-HHMMSS` 백업 후 덮어쓰기
- `[o] overwrite` — 즉시 덮어쓰기 (위험)
- `[d] diff` — 차이점 보고 재선택

`.sfs-local/sprints/` 와 `.sfs-local/decisions/` 의 **사용자 산출물은 절대 덮어쓰지 않음**.

---

## 업그레이드

```bash
cd ~/workspace/my-project
~/tmp/solon-mvp/upgrade.sh
```

- `.sfs-local/VERSION` 읽어 현재 ↔ 최신 비교
- 변경 예정 파일 dry-run 프리뷰
- `SFS.md` / runtime adapter / `divisions.yaml` 대화형 병합
- `.gitignore` 블록 (marker 기반) 자동 교체

## 제거

```bash
cd ~/workspace/my-project
~/tmp/solon-mvp/uninstall.sh
```

선택지: (a) 전부 제거 / (b) scaffold 만 제거 + 산출물 보존 / (c) 취소.

---

## 디자인 원칙

- **never-hard-block** (ALT-INV-3) — Gate 는 signal, 진행 자체를 막지 않음. 사용자가 통과 결정.
- **기록 > 기억** — sprint 산출물 + decision + events.jsonl 로 모든 결정 추적.
- **consumer 의 git 존중** — 모든 스크립트는 쓰기만, `git add/commit/push` 는 사용자 몫.
- **자기검증 금지** — 만든 agent 와 검증 agent 분리, 사람 최종 필터 보존.
- **YAGNI** — 풀스펙 (dialog-tree, 6 본부 runtime 어댑터 등) 은 MVP 에서 제외, Phase 1+ 확장.
- **minimal cleanup default** — 새 기능보다 기존 정렬 우선. 기능 추가 전 6 가지 질문 통과 (정체성 §6).

### 방향성을 잃는 신호 (사용자 자가진단용)

다음 중 하나라도 반복되면 새 기능보다 시스템 정렬을 먼저 해.

1. 문서가 실행을 돕지 않고 문서 자체를 위한 문서가 된다
2. agent 가 사용자 결정 영역을 대신 확정한다
3. gate 가 품질 검증이 아니라 통과 의례가 된다
4. `/sfs` 명령이 늘어났지만 작업 기억과 회복력이 늘지 않는다
5. 병렬 worker 가 독립적으로 일하지 않고 서로 타이밍을 눈치 본다
6. "빠른 구현" 이라는 명분으로 초기 의도·대안·실패 조건을 생략한다
7. 사용자 최종 필터 없이 자동 통과를 release 로 착각한다

---

## CHANGELOG

[CHANGELOG.md](./CHANGELOG.md) 참조. 0.3.0-mvp 가 첫 public release, 0.5.0-mvp 가 multi-adaptor 1급 정합 + `/sfs loop` 추가 release.

---

## 기여 / 라이선스 / 관련 리소스

본 repo 는 현재 MVP 단계 + 사용자 개인 IP. PR / issue 환영하지만 방법론 자체 (7-step / 4-Gate / 6 Division) 의 확장은 별도 논의 필요. 라이선스는 정식 결정 전 이라 외부 배포·상업 이용은 신중히.

- 풀스펙 Solon docset (6 본부 상세 / divisions.schema / dialog-tree 등) — 사용자 프라이빗 자산
- 7-step + 4-Gate 자세한 의미 — `templates/SFS.md.template`
- Phase 2 예약 — Claude Code plugin 네이티브화 (`claude plugin install solon`), GitHub Action drift 알림 (WU-32+), release tag trigger 자동화 (WU-33)

---

> 한 문장 정체성: **Solon 은 1인 창업가가 회사를 흉내 내는 게 아니라, 회사가 하던 역할 분리·검증·기억·회복을 파일과 agent 로 재현하게 만드는 운영 시스템이다.**
