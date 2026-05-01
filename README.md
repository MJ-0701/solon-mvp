# Solon Product

> AI-native solo founder 를 위한 **Solo Founder System (SFS)**.
> Solon Product 는 역할 분리, 결정 기록, 검증, 회고, 인수인계를 프로젝트 안에 설치합니다.

SFS 는 **Solo Founder System** 의 약자입니다. 혼자 제품을 만드는 founder 가 여러 AI agent 를
팀처럼 쓰기 위해, 프로젝트 안에 sprint flow, role boundary, decision log, review/retro loop 를
고정하는 로컬 운영 시스템입니다.

## Entry / Resume (token-min)

- 시작: `sfs status` → current sprint `report.md`
- 막혔을 때만 확장: current sprint `retro.md` → 관련 ADR (`.sfs-local/decisions/`)
- 필요할 때만 열기: `.sfs-local/events.jsonl`, 오래된 `scheduled_task_log`, 오래된 `review-runs`
- mutex: `sfs loop` 가 Solon `domain_locks` 충돌을 출력하면 즉시 중단하고 lock owner/domain 을 보고

## Quickstart

프로젝트 루트에서 실행합니다.

### macOS/Linux (Homebrew)

```bash
brew install MJ-0701/solon-product/sfs
cd ~/workspace/my-project
sfs init --yes
sfs agent install all
sfs status
sfs guide
```

### Windows (Scoop + Git Bash)

```powershell
scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs
cd C:\workspace\my-project
git init
sfs init --layout thin --yes
sfs agent install all
sfs status
```

### Curl installer (global runtime 없이)

```bash
cd ~/workspace/my-project
curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-product/main/install.sh | bash
```

## Command surface (최소)

- 상태: `sfs status`
- sprint 시작: `sfs start "<goal>"`
- G0/G1: `sfs brainstorm ...` → `sfs plan`
- 구현: `sfs implement "<slice>"`
- 리뷰: `sfs review --gate G4 --executor codex|gemini|claude`
- 보고/정리: `sfs report` / `sfs tidy --apply` / `sfs retro`

CLI 입력면 차이:
- Claude Code / Gemini CLI: `/sfs ...`
- Codex app/CLI: host slash 가 막힐 수 있으므로 `$sfs ...` 또는 `sfs ...` 를 1급 경로로 사용

## Safety invariants

- `sfs` deterministic bash adapter 출력은 SSoT (verbatim, paraphrase 금지)
- install/upgrade/uninstall 은 consumer 프로젝트에 자동 `git push` 하지 않음
- `retro --close` 는 사용자가 명시적으로 요청했을 때만 실행
- mutex 충돌(도메인 lock) 은 해결 전까지 진행하지 않음

## Docs

- Onboarding 30분: [GUIDE.md](./GUIDE.md)
- Full reference (긴 버전): [README.full.md](./README.full.md)
- Why/가치: [10X-VALUE.md](./10X-VALUE.md)
- 변경 이력: [CHANGELOG.md](./CHANGELOG.md)

