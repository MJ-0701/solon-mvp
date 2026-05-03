---
pattern_id: P-16-multi-cli-plugin-umbrella
title: "단일 brew/scoop install 액션이 Claude Code + Gemini CLI + Codex CLI 슬래시 명령을 한꺼번에 등록하는 multi-CLI plugin umbrella 패턴"
captured_from: 0.5.96-product hotfix (session: determined-focused-galileo, date: 2026-05-03)
visibility: oss-public
applicability:
  - "여러 AI CLI (Claude Code / Gemini CLI / Codex CLI) 가 같은 sfs binary 를 공유할 때 모든 CLI 에서 슬래시/skill 명령이 동작해야 하는 경우"
  - "프로젝트 트리에 plugin/extension/skill 파일을 두지 않으면서도 어느 프로젝트에서든 슬래시 명령이 동작해야 하는 경우 (zero-file-in-project)"
  - "user 가 cli 마다 별도 install 액션 (3 회) 을 치는 마찰을 받아들이지 않을 때 — 단일 entry (brew install / scoop install) 가 3 CLI 모두를 cover"
reuse_count: 0
related_patterns:
  - P-07-release-tooling-phased
  - P-08-fuse-bypass-cp-a-broken
---

# P-16-multi-cli-plugin-umbrella — 단일 brew/scoop install 이 3 CLI 슬래시를 한꺼번에 등록

> **visibility**: oss-public. solon-product 자체 + cc-thingz prior art 모두 공개 패턴.

---

## 문제

증상: solo founder 가 같은 프로젝트에서 Claude Code / Codex CLI / Gemini CLI 를
번갈아 쓰면서 모든 CLI 에서 같은 `sfs <command>` 슬래시 명령을 쓰고 싶다. 단:

- 프로젝트 트리에는 plugin/extension/skill 파일 (`.claude/commands/sfs.md`,
  `.gemini/commands/sfs.toml`, `.agents/skills/sfs/SKILL.md`) 이 들어가지
  않아야 한다 (multi-CLI 전환 시 git 충돌 + project surface clutter 회피).
- user-curated config 파일 위치 (`~/.claude/commands/sfs.md` 같은
  사용자 직접 편집 경로) 에도 들어가지 않아야 한다.
- user-visible install 액션은 단 한 번 (`brew install` / `scoop install`)
  이어야 한다 — 3 CLI 마다 별도 `claude /plugin marketplace add` 또는
  `gemini extensions install` 을 따로 치지 않는다.

발생 조건: 0.5.89-product 의 thin-surface migration 이 project-local
adapter 를 archive 로 이관한 뒤 그 자리를 "global discovery surface" 로
대체하지 않으면 `/sfs` 가 어느 프로젝트에서도 인식 안 됨 (regression).

원인: Claude Code 의 `autoInstallEnabledPlugins` feature 는 미구현
(Anthropic issue #28310, #23737, #32606). settings.json 만 박아둬도
자동 install 안 됨. 또한 3 CLI 가 각자 다른 mechanism (Claude marketplace
plugin / Gemini extension / Codex skill) 을 쓰고 user-side install 명령도
다르다.

영향: regression 발생 후 user 가 every project 에서 `/sfs` 안 됨 →
0.5.89 thin-migration 자체를 후퇴할 위험.

---

## 해결 패턴

### 핵심 아이디어

3 CLI 모두에서 동작하는 단일 외부 git repo (`<owner>/<umbrella>`) 를
만들고 그 repo 안에 3 개의 manifest 를 공존시킨다. 그 다음
brew/scoop 의 post_install hook 이 3 개의 install 명령을 idempotent +
graceful 하게 호출한다.

### 단계

1. **외부 단일 repo 만들기** (`MJ-0701/solon` 형식, `cc-thingz` prior art):
   ```
   <owner>/<umbrella>/
   ├── .claude-plugin/marketplace.json     ← Claude Code 가 읽음
   ├── plugins/<plugin-name>/
   │   ├── .claude-plugin/plugin.json
   │   └── commands/<verb>.md              ← 슬래시 명령 정의
   ├── gemini-extension.json               ← Gemini CLI 가 읽음
   └── commands/<verb>.toml                ← Gemini 명령 정의
   ```
   Codex 는 marketplace 가 없으므로 별도 — brew/scoop bundle 안
   `templates/codex-skill/SKILL.md` 를 두고 hook 이 user-global 위치로 cp.

2. **Install hook 작성** (sh + ps1 mirror, idempotent + graceful):
   - Step 1: `claude plugin marketplace add <owner>/<umbrella>` 시도
     (A-1). 실패 시 git clone repo to `~/.claude/plugins/<plugin>/` +
     `~/.claude/settings.json` 에 `extraKnownMarketplaces` +
     `enabledPlugins` merge (A-2 fallback).
   - Step 2: `gemini extensions install --consent --auto-update
     <git-url>`. 이미 설치된 경우 skip.
   - Step 3: `cp <bundle>/codex-skill/SKILL.md
     ~/.codex/skills/sfs/SKILL.md`. Codex 는 그 경로 자동 탐색.
   - 모든 step 의 실패는 warning 으로 stderr 출력 후 exit 0 (parent
     install 자체는 성공).

3. **brew formula 의 `post_install do … end` + scoop manifest 의
   `installer.script` PowerShell 가 hook 호출**. 환경 변수
   `SFS_SKIP_CLI_DISCOVERY=1` 로 hook skip 가능 (CI / bottle build).

4. **Idempotency 보장**:
   - `claude plugin marketplace add` 두 번째 → no-op
   - `gemini extensions list | grep <name>` 으로 이미 있으면 skip
   - `cp` 은 항상 멱등

5. **`<binary> doctor` subcommand 로 verifiable**: 3 CLI discovery 상태를
   ✅/⚠️/❌ + recovery cmd 로 출력.

### 샘플 명령

```bash
brew install <owner>/<product>/<binary>      # 한 줄로 3 CLI 등록
<binary> doctor                                # 3-line ✅ 검증
```

```bash
scoop bucket add <owner> <bucket-url>
scoop install <binary>
<binary>.cmd doctor
```

### 트레이드 오프

- 외부 repo 1 개 추가 유지 비용 (cc-thingz 가 동일 채택 — 검증된 cost)
- Claude Code 의 CLI subcommand 안정성이 버전마다 다름 → A-1/A-2
  two-tier 로 회피
- Windows 측은 PS1 hook 이 PowerShell-native JSON merge (jq 의존 없이)
  로 처리

## 재사용 체크리스트

- [ ] 외부 단일 repo 가 oss-public OK 인지 확인 (마켓플레이스 등록 시
      모든 user 가 fetch).
- [ ] Plugin/extension 안 슬래시 verb 가 binary 이름과 일치 — user
      muscle memory 보존 (`/sfs`, `sfs <cmd>`, `$sfs`).
- [ ] hook 이 graceful — Claude/Gemini/Codex 어느 한 CLI 가 미설치/error
      여도 brew/scoop install 자체는 success.
- [ ] Windows 측 path 가 macOS 와 동시 land — phase-2 미루지 않음
      (Solon 의 first-class Windows support 차별점).
- [ ] doctor subcommand 로 3-CLI 상태 verifiable + recovery cmd 표기.
- [ ] 원칙 2 (self-validation-forbidden) 위반 여부 검토 — A-1/A-2 분기
      로직 같은 의미 결정은 user-machine probe 결과 확인 후 commit.

## 관련 WU / 세션

- **최초 발견**: 0.5.96-product hotfix (commits 78aeeb2..2f8462d ·
  session: determined-focused-galileo · 2026-05-03)
- **prior art 참조**:
  - `popup-studio-ai/bkit-claude-code` + `popup-studio-ai/bkit-gemini`
    (split-repo 패턴, mac-only)
  - `alexei-led/cc-thingz` (single-repo 패턴 — 채택, multi-CLI 가능)
- **재발견 / 재사용**: TBD (0.5.97-product 의 dashboard surface 가 같은
  외부 repo 에 추가 mechanism 을 얹을 가능성).

## Notes

OSS 공개 시 주의 사항: 외부 단일 repo 의 visibility 는 oss-public 이지만
hook script 내부 logic 에 user-internal 식별자가 들어가지 않도록
(SOLON_REPO 같은 env override 로 분리). brew formula / scoop manifest 도
`MJ-0701` 같은 owner 가 hard-coded 라 fork 시 변경 필요.

cf) Anthropic issue #28310 (autoInstallEnabledPlugins) 가 구현되면 본
패턴은 더 단순화 가능 — settings.json 만 작성하면 자동 install 됨. 그
때까지는 두-tier (A-1/A-2) 가 가장 안정.
