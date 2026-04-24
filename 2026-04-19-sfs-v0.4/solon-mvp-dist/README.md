# Solon MVP

> AI-native 개발을 위한 **7-step flow** (브레인스토밍 → plan → sprint → 구현 → review → commit → 문서화)
> 를 어떤 프로젝트에든 주입하는 경량 스캐폴드. Claude Code 우선 지원.

**버전**: `0.2.0-mvp` · **라이선스**: [TBD — 개인 IP, 외부 배포 신중] · **상태**: MVP (풀스펙 아님)

## 이게 뭐예요

Solon 은 AI 와 함께 개발할 때 사용하는 경량 방법론 (7-step + 4 Gate + 6 본부) 의 **최소 실행 가능
배포판** 입니다. **runtime-neutral 설계** — Claude Code / OpenAI Codex / Google Gemini-CLI 어느
runtime 에서든 동일한 플로우로 작동합니다.

사용자는 개인 / 회사 프로젝트에서 `install.sh` 한 번으로 다음을 얻어요:

| 파일 | 역할 | Layer |
|------|------|:-:|
| `SFS.md` | runtime-agnostic core — 7-step flow / 4 Gate / 산출물 규칙 **단일 출처** | L1 |
| `CLAUDE.md` | Claude Code adapter (thin) — Task tool / MCP / 모델 tier 힌트 | L2 |
| `AGENTS.md` | OpenAI Codex adapter (thin) — repo instructions / natural-language alias | L2 |
| `GEMINI.md` | Gemini-CLI adapter (thin) — project instruction / long context 힌트 | L2 |
| `.claude/commands/sfs.md` | Claude 용 `/sfs` slash command 정의 (subcommand 6종) | L3 |
| `.sfs-local/` | Sprint 산출물 / 결정 로그 / 이벤트 로그 스캐폴드 | L1 |
| `.gitignore` 블록 | 운영 로그 누출 방지 (marker 기반 idempotent) | L3 |

세션 진입 시 **모든 runtime 이 먼저 SFS.md 를 읽고**, 그 다음 본인 adapter 를 읽는 구조.
adapter 는 "thin" 원칙 — SFS 본문 중복 복사 금지.

풀스펙 (6 본부 상세 / divisions.schema / dialog-tree 등) 은 별도 개인 docset 에 있으며,
본 MVP 는 **도구 자체** 만 실제 프로젝트에 이식 가능하게 묶어놓은 것입니다.

## 설치

### 방법 1 — 원격 one-liner (가장 빠름)

```bash
cd ~/workspace/my-project
curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-mvp/main/install.sh | bash
```

### 방법 2 — 로컬 clone 후 실행 (offline / 수정 가능)

```bash
git clone https://github.com/MJ-0701/solon-mvp ~/tmp/solon-mvp
cd ~/workspace/my-project
~/tmp/solon-mvp/install.sh
```

### 방법 3 — 수동 cp (완전 통제)

```bash
git clone https://github.com/MJ-0701/solon-mvp ~/tmp/solon-mvp
cd ~/workspace/my-project
cp ~/tmp/solon-mvp/templates/SFS.md.template        SFS.md
cp ~/tmp/solon-mvp/templates/CLAUDE.md.template     CLAUDE.md
cp ~/tmp/solon-mvp/templates/AGENTS.md.template     AGENTS.md
cp ~/tmp/solon-mvp/templates/GEMINI.md.template     GEMINI.md
mkdir -p .claude/commands
cp ~/tmp/solon-mvp/templates/.claude-template/commands/sfs.md .claude/commands/sfs.md
cp -r ~/tmp/solon-mvp/templates/.sfs-local-template .sfs-local
cat ~/tmp/solon-mvp/templates/.gitignore.snippet >> .gitignore
# placeholder 치환 (<PROJECT-NAME>, <DATE>, <STACK>, ...) 은 에디터에서 수동.
```

## 설치 후 3 단계

1. `SFS.md` + 사용할 runtime adapter (CLAUDE.md / AGENTS.md / GEMINI.md) 에서
   `<PROJECT-NAME>` / `<STACK>` / `<DB>` / `<DEPLOY>` placeholder 치환
2. 본인 runtime 으로 세션 시작:
   - Claude Code:  `cd <project> && claude` → "SFS.md + CLAUDE.md 읽고 /sfs status"
   - Codex CLI:    `cd <project> && codex`  → "SFS.md + AGENTS.md 읽고 sfs status"
   - Gemini CLI:   `cd <project> && gemini` → "SFS.md + GEMINI.md 읽고 sfs status"
3. commit + push

## 주요 기능

| 기능 | 파일 |
|---|---|
| 설치 (대화형 충돌 처리) | [`install.sh`](./install.sh) |
| 업그레이드 (VERSION diff + 파일별 merge) | [`upgrade.sh`](./upgrade.sh) |
| 제거 (산출물 보존 옵션) | [`uninstall.sh`](./uninstall.sh) |
| runtime-agnostic core 템플릿 | [`templates/SFS.md.template`](./templates/SFS.md.template) |
| Claude adapter 템플릿 | [`templates/CLAUDE.md.template`](./templates/CLAUDE.md.template) |
| Codex adapter 템플릿 | [`templates/AGENTS.md.template`](./templates/AGENTS.md.template) |
| Gemini adapter 템플릿 | [`templates/GEMINI.md.template`](./templates/GEMINI.md.template) |
| Claude `/sfs` slash command | [`templates/.claude-template/commands/sfs.md`](./templates/.claude-template/commands/sfs.md) |
| `.sfs-local/` 스캐폴드 | [`templates/.sfs-local-template/`](./templates/.sfs-local-template/) |
| `.gitignore` 블록 (marker 기반) | [`templates/.gitignore.snippet`](./templates/.gitignore.snippet) |

## Idempotency & 충돌 처리

`install.sh` 는 **재실행 가능**합니다. 기존 파일이 있으면 대화형으로 4가지 중 선택:

- `[s] skip` — 기존 유지 (default, 안전)
- `[b] backup + overwrite` — `.bak-YYYYMMDD-HHMMSS` 백업 후 덮어쓰기
- `[o] overwrite` — 즉시 덮어쓰기 (위험)
- `[d] diff` — 차이점 확인 후 재선택

`.sfs-local/sprints/` 와 `.sfs-local/decisions/` 의 **사용자 산출물은 절대 덮어쓰지 않습니다**.

## 업그레이드

```bash
cd ~/workspace/my-project
~/tmp/solon-mvp/upgrade.sh
```

- `.sfs-local/VERSION` 읽어서 현재 / 최신 비교
- 변경 예정 파일 dry-run 프리뷰
- `CLAUDE.md` / `divisions.yaml` 대화형 병합
- `.gitignore` 블록 (marker 기반) 자동 교체

## 제거

```bash
cd ~/workspace/my-project
~/tmp/solon-mvp/uninstall.sh
```

선택지: (a) 전부 제거 / (b) scaffold 만 제거 + 산출물 보존 / (c) 취소.

## 디자인 원칙

- **never-hard-block** (ALT-INV-3) — Gate 는 signal, 진행 자체를 막지 않음
- **기록 > 기억** — sprint 산출물 + decisions + events.jsonl 로 모든 결정 추적
- **consumer 의 git 존중** — 스크립트는 쓰기만 하고 commit/push 는 사용자 몫
- **YAGNI** — 풀스펙 기능 (dialog-tree, 6 본부 runtime 어댑터 등) 은 MVP 에서 제외

## CHANGELOG

[CHANGELOG.md](./CHANGELOG.md) 참조.

## 기여

MVP 단계라 본 repo 는 사용자 개인 사용 전제. PR / issue 는 환영하지만 방법론 자체 확장은
별도 논의 필요.

## 관련 리소스

- Solon 풀스펙 개인 docset — 사용자 프라이빗 자산 (본 MVP 에 경로 기록 없음)
- 7-step flow 개요: `templates/SFS.md.template` 참조 (runtime-agnostic core)
- Runtime adapter 설계 원칙: 사용자 개인 docset `RUNTIME-ABSTRACTION.md` (v0.2-mvp-correction, `rule/mvp-runtime-neutral-core`)
- 후속 (post-MVP) 예약 항목: SDK/plugin 수준 runtime adapter (OpenAI Agents SDK / Gemini SDK), `claude plugin install solon` 네이티브화
