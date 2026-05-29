---
id: sfs-policy-search-tooling-ko
summary: Agent 의 code/text 검색은 `rg` (ripgrep) 우선, `grep` 은 `rg` 미설치 host 에서만. AST 기반 도구 (ast-grep) 는 consumer 프로젝트의 opt-in 옵션이며 SFS bash SSoT 에는 들어가지 않는다.
load_when: ["search", "grep", "ripgrep", "rg", "코드 검색", "파일 검색", "ast-grep", "aider", "도구 선택", "퍼포먼스"]
---

# 검색 도구 (Search tooling)

SFS 프로젝트 안에서 code / docs / log / evidence 검색은 기본 `rg` (ripgrep)
로. 평문 `grep` 은 host runtime 에 `rg` 가 없을 때만 사용한다.

## `rg` 를 먼저 쓰는 이유

- ripgrep 은 Claude Code 와 Codex CLI 양쪽 runtime 의 사실상 baseline 이고
  SFS 프로젝트가 실제로 마주치는 모든 디렉토리 크기에서 `grep -r` 보다 빠르다.
- `rg` 는 기본값으로 `.gitignore` / `.ignore` / binary detection 을 존중해서
  agent 가 `node_modules/`, `.sfs-local/archives/`, packaged `tar.gz` fixture,
  컴파일 산출물을 명시 opt-in 없이 스캔하지 않는다.
- 출력이 line-numbered (`-n` 암시) + color-tagged 라 reviewer prompt 로
  replay 될 때 runtime context 가 짧게 유지된다.

agent prompt / policy doc 에 쓸 빠른 reference:

- code / text 검색 → `rg <pattern> <path>` (NOT `grep -rn <pattern> <path>`).
- file name 패턴 → `rg --files | rg <pattern>` 또는 `fd <pattern>`;
  `find . -name '<pattern>'` 은 `fd` / `rg` 가 없을 때만.
- multi-line 패턴 → `rg -U '<pattern>'` (`grep -P` 는 portable 아님).

## opt-in / out-of-scope 항목

다음 도구들은 SFS 의 "퍼포먼스↑ vs 토큰↑" 결정 frame 에 따라 evaluate 됐고
core surface 기준 PASS 로 기록됐다. consumer 프로젝트 안에서는 여전히 가치가
있을 수 있다.

- **ast-grep (`sg`)** — AST 기반 패턴 매칭. SFS source 는 ~85% bash +
  Markdown 이라 ast-grep 이 `rg` 대비 의미 있는 이득 없음. core dependency
  로는 PASS. Java / TypeScript / Python / Rust / Go consumer 프로젝트는
  CI / lint helper 로 install 후 자기 routed context 에서 노출 가능. SFS
  의 bash SSoT 또는 agent 기본 toolbelt 에 ast-grep 을 넣지 않는다.
- **Aider 류 standalone CLI 코딩 loop** — SFS 자체의 brainstorm / plan /
  implement / review (Gate 3/6) + sub-agent council + harness doctor 와 loop
  중복. dual-loop 충돌 회피를 위해 PASS. Agent 는 SFS + 설정된 runtime
  (Claude Code / Codex / Gemini) 만 쓴다.

consumer 프로젝트가 ast-grep 또는 다른 AST 도구를 추가하면 agent 는 그걸
프로젝트-local extension 으로 다룬다: 프로젝트의 wiki / routed context entry
를 존중하되, global SFS toolbelt 에 해당 binary 가 있다고 가정하지 않는다.

## 검출 가능한 signal

- Agent 가 한 줌 이상의 파일이 있는 프로젝트 트리에 `grep -r` 을 emit
  → lens-routing finding 으로 기록 (`rg` 사용 권유).
- Agent 가 SFS core install path 일부로 Aider / ast-grep 을 권장
  → reject; consumer 프로젝트 routed context 로 라우팅.

## 관련 정책

- `context-pollution-guard.md` — 검색 출력 크기 bound. 본 정책은 그 출력을
  덜 노이지하게 만드는 도구 자체를 고른다.
- `ai-work-intake-routing.md` — 검색 / lookup 은 intake 의 일부; 본 baseline
  도구 선택이 그대로 적용.
