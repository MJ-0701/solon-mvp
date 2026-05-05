# Solon multi-CLI 마켓플레이스

> Solon SFS 를 Claude Code, Gemini CLI, Codex CLI 에서 같은 방식으로 발견하게 만드는
> slash-command discovery 표면입니다.

## 이 repo 의 역할

설치 표면은 세 개지만 SSoT 는 하나입니다.

| CLI | 연결 방식 | 설치 명령 |
|---|---|---|
| Claude Code | plugin marketplace (`.claude-plugin/marketplace.json` + `plugins/solon/`) | `/plugin marketplace add MJ-0701/solon-product` 후 `/plugin install solon` |
| Gemini CLI | extension (`gemini-extension.json` + `commands/sfs.toml`) | `gemini extensions install --consent --auto-update https://github.com/MJ-0701/solon-product.git` |
| Codex CLI | user-global skill `~/.codex/skills/sfs/SKILL.md` | Homebrew/Scoop 의 `sfs` 설치에 포함. 별도 명령 없음. |

## 왜 세 CLI 를 같이 다루나

Solon 제품의 `sfs` CLI 는 Claude Code, Codex CLI, Gemini CLI 에서 같은 binary 를 씁니다.
프로젝트 작업 기록은 `.sfs-local/` 에 남고 git 으로 이동할 수 있습니다. 이 repo 의
plugin/extension/skill 파일들은 **CLI 쪽 discovery surface** 입니다. 모델이 `/sfs`(Claude),
`sfs <subcommand>`(Gemini), `$sfs`(Codex) 를 같은 global binary 로 routing 하게 만듭니다.

## 실제 설치 진입점

이 repo 를 직접 `git clone` 해서 설치하지 않습니다. macOS 는 Homebrew, Windows 는 Scoop 으로
Solon 제품을 설치합니다. 설치 과정에서 세 CLI discovery 표면이 함께 등록됩니다.

```bash
# macOS
brew install MJ-0701/solon-product/sfs

# Windows
scoop bucket add solon-product https://github.com/MJ-0701/solon-product
scoop install sfs
```

설치 뒤에는 어떤 CLI 에서든 프로젝트 안에서 `/sfs status` 또는 대응되는 `sfs status` 호출을
사용할 수 있습니다.

## 프로젝트 표면은 가볍게 유지

이 repo 는 discovery 표면입니다. 일반 프로젝트 tree 에 `.claude/commands/`,
`.gemini/commands/`, `.agents/skills/sfs/` 를 기본으로 흩뿌리지 않습니다. sprint workbench,
decision, event, `SFS.md`, `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` 는 프로젝트-local 작업 산출물로
남지만, CLI별 mechanism 파일은 기본 설치 표면에 들어가지 않습니다.

연속성 테스트는 간단합니다. Claude Code 에서 프로젝트를 열어 작업 기록을 git 에 남긴 뒤,
같은 프로젝트를 Codex CLI 로 열어도 sprint 상태가 이어집니다. 세 CLI 가 `.sfs-local/` 과 같은
`sfs` binary 를 공유하기 때문입니다.

## 소스

주 repo(binary, install hook, docs): https://github.com/MJ-0701/solon-product

이 repo 는 얇은 discovery 표면이며 Solon 제품 릴리스 버전을 따라갑니다.

## 라이선스

`LICENSE` 참고. 현재 TBD.
