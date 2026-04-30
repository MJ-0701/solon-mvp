---
pattern_id: P-15
title: claude-worktree-gitlink-committed
status: documented
severity: high
first_observed: 2026-05-01
observed_by: Codex cleanup session + 사용자/Claude 교차 분석
resolved_at: 2026-05-01
resolved_by: 사용자 manual commit `78ee0f0` + Codex `.gitignore` edit
resolved_via:
  - "[1] 진단: `.claude/worktrees/pensive-moore-c6f819` 이 단순 잔존 폴더가 아니라 main HEAD 에 `160000` gitlink 로 커밋된 상태임을 `git ls-tree HEAD` 로 확인."
  - "[2] lock 해소: Claude VM 이 잡고 있던 `/Users/mj/agent_architect/.git/index.lock` holder 확인 후 stale lock 파일 제거."
  - "[3] 재발 방지: `.gitignore` 에 `.claude/worktrees/` 추가."
  - "[4] 정리: 사용자 터미널에서 `git rm --cached -r .claude/worktrees/pensive-moore-c6f819` + `.gitignore` commit."
related_wu: null
related_commit: 78ee0f0
related_docs:
  - 2026-04-19-sfs-v0.4/learning-logs/2026-05/P-08-fuse-bypass-cp-a-broken.md
  - 2026-04-19-sfs-v0.4/learning-logs/2026-05/P-09-sandbox-file-clone-isolation.md
  - 2026-04-19-sfs-v0.4/learning-logs/2026-05/P-10-stable-stale-git-lock-recovery.md
  - .gitignore
visibility: raw-internal
applicability:
  - "Claude Code / Cowork / agent runtime 이 repo 내부에 worktree 또는 subagent workspace 를 생성하는 환경"
  - "repo 내부 nested git worktree 가 `160000` gitlink 로 stage/commit 될 가능성이 있는 환경"
  - "`.gitmodules` 없이 gitlink 가 생긴 뒤 clone/checkout/CI 에서 불완전 submodule 처럼 보이는 사고"
reuse_count: 1
related_patterns:
  - P-08-fuse-bypass-cp-a-broken
  - P-09-sandbox-file-clone-isolation
  - P-10-stable-stale-git-lock-recovery
---

# P-15 — Claude worktree gitlink committed

## 1. 문제

Claude Code subagent worktree 경로인 `.claude/worktrees/pensive-moore-c6f819` 가 main HEAD 에 `160000` gitlink 로 커밋되었다. 이 경로는 실제 소스 파일이 아니라 Claude 런타임의 작업 공간인데, root repo 입장에서는 nested git repository 로 인식되어 gitlink 항목이 만들어졌다.

핵심 증상:

- `git ls-tree HEAD .claude/worktrees/pensive-moore-c6f819` 출력이 `160000 commit 398c0dc...` 로 나타남.
- `.gitmodules` 는 없음.
- `git worktree prune --dry-run` 은 비어 있음. 즉 prune 으로 해결되는 "prunable worktree" 가 아니라 이미 main HEAD 에 들어간 commit 사고.
- `git diff c284ef7..HEAD` 에 `.claude/worktrees/pensive-moore-c6f819` 이 추가 파일처럼 잡힘.

이 상태를 방치하면 checkout/clone/CI 사용자에게 "submodule 비슷한 빈 gitlink" 로 보이고, 실제 Claude 로컬 runtime 경로가 repo 역사에 노출된다. 소스 배포물 자체를 깨뜨리진 않지만, repo hygiene 와 협업 신뢰도 관점에서는 high severity 로 본다.

## 2. 발생 조건

1. Claude 또는 Cowork runtime 이 repo 내부 `.claude/worktrees/<id>` 에 subagent worktree 를 생성한다.
2. root `.gitignore` 에 `.claude/worktrees/` 규칙이 없다.
3. 사용자가 `git add -A` 또는 넓은 범위의 add 를 실행한다.
4. Git 이 nested git repo 를 일반 파일 트리 대신 gitlink (`160000`) 로 stage 한다.
5. commit 이 main 에 들어간다.

본 사례에서는 `pensive-moore-c6f819` worktree 자체는 실제 경로가 존재했고 `git worktree prune --dry-run` 으로는 제거되지 않았다. 그래서 "잔존 worktree 정리"가 아니라 "committed gitlink 제거"로 분류해야 했다.

## 3. 진단 절차

```bash
# 1. HEAD 에 gitlink 가 있는지 확인
git ls-tree HEAD .claude/worktrees/pensive-moore-c6f819

# 기대되는 사고 출력 예시:
# 160000 commit <sha> .claude/worktrees/pensive-moore-c6f819

# 2. .gitmodules 없는지 확인
test -f .gitmodules && cat .gitmodules || echo "no .gitmodules"

# 3. 실제 worktree/prune 가능 여부 확인
git worktree list --porcelain
git worktree prune --dry-run --verbose

# 4. lock holder 확인
lsof .git/index.lock
```

판단 기준:

- `160000` + `.gitmodules` 없음 = accidental gitlink.
- `worktree prune --dry-run` 출력 없음 = prune 정리 대상 아님.
- `.git/index.lock` holder 가 있으면 git rm 전에 holder 해소 필요.

## 4. 해결 패턴

### 4.1 재발 방지 ignore

```gitignore
# Claude Desktop / Cowork 세션 부산물
.claude/projects/*/memory/
.claude/projects/*/*.jsonl
.claude/worktrees/
```

### 4.2 index 에서 gitlink 제거

```bash
cd /Users/mj/agent_architect
git rm --cached -r .claude/worktrees/pensive-moore-c6f819
git add .gitignore
git commit -m "fix(git): ignore Claude worktrees and remove accidental gitlink"
```

중요: `git rm --cached` 를 사용해 Git index 에서만 제거한다. 실제 `.claude/worktrees/` runtime directory 를 무조건 삭제하지 않는다. 다른 Claude session 이 같은 VM/runtime 을 쓰고 있을 수 있기 때문이다.

### 4.3 확인

```bash
git status --short --branch
git ls-tree HEAD .claude/worktrees/pensive-moore-c6f819
git check-ignore -v --no-index .claude/worktrees/pensive-moore-c6f819/.git
```

정상 결과:

- `git ls-tree HEAD ...` 출력 없음.
- `git check-ignore` 가 `.gitignore` 의 `.claude/worktrees/` row 를 가리킴.
- push 전이면 `main...origin/main [ahead 1]`.

## 5. 주의점

### 5.1 VM 프로세스 kill 은 최후 수단

본 사례에서 `/Users/mj/agent_architect/.git/index.lock` 은 `com.apple.Virtualization.VirtualMachine` 이 잡고 있었다. 이 프로세스는 "agent_architect 전용 git process" 가 아니라 Claude VM 이므로, 다른 프로젝트 Claude 작업에도 영향을 줄 수 있다.

따라서 권장 순서는 다음이다:

1. 해당 Claude/Cowork 세션에 mutate 중단 요청.
2. 앱/세션 종료로 자연 release 대기.
3. `lsof .git/index.lock` 로 holder 소멸 확인.
4. holder 가 사라진 뒤 남은 0-byte stale lock 만 제거.
5. VM kill 은 사용자에게 "다른 Claude 작업도 끊길 수 있음"을 명시하고 승인받은 경우에만.

### 5.2 prune 과 gitlink 제거를 혼동하지 않는다

`git worktree prune` 은 Git 이 관리하는 worktree metadata 정리용이다. 이미 main tree 에 `160000` gitlink 로 들어간 항목은 prune 이 아니라 `git rm --cached` 로 제거해야 한다.

### 5.3 넓은 `git add -A` 전 ignore 확인

Claude/Cowork runtime 이 repo 내부에 생성하는 경로는 먼저 ignore 되어야 한다. 특히 다음 경로는 source 가 아니라 runtime 부산물이다:

- `.claude/worktrees/`
- `.claude/projects/*/memory/`
- `.claude/projects/*/*.jsonl`
- `.sfs-local/events.jsonl`
- `.sfs-local/tmp/`

## 6. 재사용 체크리스트

- [ ] `git diff --stat` 또는 `git ls-tree` 에 `160000 commit` 이 보이는지 확인.
- [ ] `.gitmodules` 없이 gitlink 가 생겼다면 accidental gitlink 로 분류.
- [ ] runtime directory 를 실제 삭제하기 전, 다른 Claude/Cowork 세션 영향 여부 확인.
- [ ] `.gitignore` 에 runtime worktree 경로 추가.
- [ ] `git rm --cached -r <path>` 로 index 에서만 제거.
- [ ] `git ls-tree HEAD <path>` 출력 없음 + `git check-ignore -v --no-index <path>/.git` 로 ignore 적용 확인.

## 7. 관련 세션 / 커밋

- **발견**: 2026-05-01 Codex cleanup session. Claude 분석은 "prunable worktree 잔존" 으로 보았으나, Codex 확인에서 `main HEAD 160000 gitlink` 로 보정.
- **정리 commit**: `78ee0f0 fix(git): ignore Claude worktrees and remove accidental gitlink`.
- **연결 패턴**:
  - P-08: host `.git` 사고 복구 패턴.
  - P-09: host `.git` mutate 회피를 위한 sandbox 설계.
  - P-10: stale `.git/index.lock` recovery. 본 P-15는 lock 자체보다 runtime worktree gitlink 사고에 초점.
