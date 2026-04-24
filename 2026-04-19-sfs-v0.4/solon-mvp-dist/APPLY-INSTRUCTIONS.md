# APPLY — 기존 `solon-mvp` repo 를 distribution 구조로 전환

> 이 문서는 **한 번만** 실행되는 가이드. 2026-04-24 WU-20 scope pivot 으로 `solon-mvp` repo 의
> 정체를 consumer-project-template → **SFS distribution** 으로 전환하는 마이그레이션 절차.
>
> 전제: 현재 `/Users/mj/workspace/solon-mvp/` 에는 WU-18/19 의 setup-w0.sh 가 만든
> consumer-template 3 commit (`9d8fb09` / `b83b6bf` / `13b2d98`) 이 있음.

## 배경

- **기존 (잘못된 scope)**: `solon-mvp` = consumer 프로젝트 (CLAUDE.md / README / .sfs-local/ 스캐폴드 포함)
- **신규 (올바른 scope)**: `solon-mvp` = SFS 시스템 MVP 배포 (install.sh / upgrade.sh / uninstall.sh / templates/)

## 체크리스트

### 0) pre-flight

```bash
cd ~/workspace/solon-mvp
git status                      # 미커밋 변경 없어야 함
git log --oneline -5           # 3 commit 확인
```

### 1) Solon docset 쪽 staging 동기화 pull

Claude (Cowork 세션) 가 `/Users/mj/agent_architect/2026-04-19-sfs-v0.4/solon-mvp-dist/` 에
distribution 원본을 준비해뒀음. 네 Mac 에서 Solon docset 쪽 git 을 먼저 pull:

```bash
cd ~/agent_architect            # (또는 Solon docset clone 위치)
git pull origin main             # WU-20 commit 들 받기
ls 2026-04-19-sfs-v0.4/solon-mvp-dist/   # staging 확인
```

### 2) solon-mvp repo 내용 clean slate 전환

```bash
cd ~/workspace/solon-mvp

# 2a. 기존 consumer-template 파일 제거 (git 히스토리는 유지)
rm CLAUDE.md README.md
rm -rf .sfs-local/
# .gitignore 는 유지 — distribution 개발자용 (node_modules 등) 로 재활용 가능
# 단, 아래 distribution .gitignore 로 교체 권장

# 2b. distribution 원본 복사 (숨김 파일 포함 주의: 없는 편)
SOLON_DIST="$HOME/agent_architect/2026-04-19-sfs-v0.4/solon-mvp-dist"
cp -r "$SOLON_DIST"/. .

# 2c. apply-instructions 는 1회용 → repo 에 넣을지 결정
# (권장: 넣지 말고 삭제. Solon docset 의 sprint 기록으로 충분)
rm APPLY-INSTRUCTIONS.md

# 2d. install.sh / upgrade.sh / uninstall.sh 실행권한 부여
chmod +x install.sh upgrade.sh uninstall.sh
```

### 3) .gitignore 교체 (distribution repo 용)

distribution repo 자체는 node_modules 같은 거 필요 없으니 간단히:

```bash
cat > .gitignore <<'EOF'
# solon-mvp distribution repo 용 .gitignore

# OS
.DS_Store
Thumbs.db

# 에디터
.idea/
.vscode/
*.swp

# 테스트 산출물 (있다면)
/tmp/
*.bak-*
EOF
```

### 4) commit + push (의도적 force 필요 없음 — 정상 커밋)

```bash
git add -A
git status                       # 변경 목록 확인
# 예상: 삭제 CLAUDE.md, README.md, .sfs-local/ / 추가 install.sh upgrade.sh uninstall.sh templates/ VERSION CHANGELOG.md etc

git commit -m "feat: pivot to SFS distribution (WU-20)

기존 consumer-template scope (CLAUDE.md / .sfs-local/ 직접 포함) 를 파기하고,
install.sh / upgrade.sh / uninstall.sh + templates/ 기반 배포판으로 재구성.

변경사항:
- 제거: CLAUDE.md, README.md, .sfs-local/  (consumer-template 산출물)
- 추가: install.sh (dual mode + interactive conflict)
- 추가: upgrade.sh (VERSION 기반 대화형)
- 추가: uninstall.sh (산출물 보존 옵션)
- 추가: templates/CLAUDE.md.template (도메인 중립)
- 추가: templates/.sfs-local-template/
- 추가: templates/.gitignore.snippet
- 추가: VERSION (0.1.0-mvp)
- 추가: CHANGELOG.md
- 추가: README.md (distribution 설명)
- 추가: CLAUDE.md (distribution 유지보수 지침)

관련:
- Solon docset WU-20 sprint doc 참조
- Scope pivot 사유: HANDOFF §0 16번째 사용자 지시"

git push origin main
```

### 5) 검증 (install.sh 실제 dry-run, v0.2.0-mvp 기준)

```bash
# 새 consumer 프로젝트 시뮬레이션
mkdir -p /tmp/solon-test-consumer
cd /tmp/solon-test-consumer
git init

# 로컬 설치 (원격 clone 이 아닌 직접 실행)
~/workspace/solon-mvp/install.sh

# 기대 결과 (v0.2.0-mvp):
# - SFS.md 생성 (runtime-agnostic core)
# - CLAUDE.md 생성 (Claude adapter, thin)
# - AGENTS.md 생성 (Codex adapter, thin)
# - GEMINI.md 생성 (Gemini adapter, thin)
# - .claude/commands/sfs.md 생성 (Claude slash command)
# - .sfs-local/ 스캐폴드 생성 (divisions.yaml / events.jsonl / VERSION / sprints / decisions)
# - .gitignore 에 solon-mvp 블록 추가
# - 자동 치환 확인: <DATE>, <SOLON-VERSION> 은 치환됨 / <PROJECT-NAME>, <STACK>, <DB>, <DEPLOY>, <DOMAIN> 은 그대로

# 확인
ls -la
cat .sfs-local/VERSION       # solon_mvp_version: 0.2.0-mvp 확인
ls .claude/commands/         # sfs.md 존재 확인
grep -l '<DATE>' SFS.md CLAUDE.md AGENTS.md GEMINI.md || echo "✓ <DATE> 전부 치환됨"
grep -l '<SOLON-VERSION>' SFS.md CLAUDE.md AGENTS.md GEMINI.md || echo "✓ <SOLON-VERSION> 전부 치환됨"

# 정리
cd ~
rm -rf /tmp/solon-test-consumer
```

### 6) Solon docset 쪽 staging 정리

staging 은 docset 에서 분리. 실 배포 완료 후엔 staging 은 archive 로 남기거나 삭제:

```bash
cd ~/agent_architect

# 선택 A: archive (히스토리 유지, 안전)
git mv 2026-04-19-sfs-v0.4/solon-mvp-dist 2026-04-19-sfs-v0.4/archive/solon-mvp-dist-v0.1.0-mvp
git commit -m "chore: archive solon-mvp-dist staging (v0.1.0-mvp 배포 완료)"

# 선택 B: 삭제 (WU-20 commit 에서 복구 가능)
rm -rf 2026-04-19-sfs-v0.4/solon-mvp-dist
git add -A
git commit -m "chore: remove solon-mvp-dist staging (v0.1.0-mvp 배포 완료)"

git push origin main
```

### 7) 로컬 workspace 배치 권장

`solon-mvp` 를 다른 프로젝트에서 참조할 수 있게 설치 위치 권장:

```bash
# 이미 /Users/mj/workspace/solon-mvp 에 있음 → 이대로 유지
# consumer 프로젝트에서 사용 시:
cd ~/workspace/my-sideproject
~/workspace/solon-mvp/install.sh
```

또는 Claude plugin 스타일 (Phase 2 예약, 아직 미구현):
```bash
# (미구현) mkdir -p ~/.claude/plugins
# (미구현) ln -s ~/workspace/solon-mvp ~/.claude/plugins/solon-mvp
```

## 문제 발생 시

- **rsync / cp 가 숨김 파일 누락**: `cp -r "$SOLON_DIST"/. .` 의 `/.` 이 포인트. `/*` 아님.
- **실행권한 없음**: `chmod +x install.sh upgrade.sh uninstall.sh` 재실행.
- **install.sh 테스트 중 대화형 멈춤**: curl | bash 시뮬레이션 원하면 `echo -e "y\ny\ny" | ./install.sh` 시도.
- **git push 거부 (non-fast-forward)**: `git pull --rebase` 후 재시도. 또는 remote 가 비어있는지 확인.

## 완료 후 사용자 보고

본 APPLY 가이드 실행 완료 후:
1. solon-mvp 최신 commit sha + push 완료 여부
2. 5) 검증 단계 install.sh dry-run 결과 (성공/실패)
3. 문제 있었으면 에러 메시지 원문

그걸 받으면 Claude (다음 세션) 가 WU-20 final 처리:
- PROGRESS.md 최종 업데이트 (WU-20 완료 표시)
- HANDOFF §0 16번째 지시의 verification 완료 표시
- sprints/WU-20.md → status: done
- learning-logs/2026-05/P-01 final write

즉 WU-20 은 "소비자 (사용자) 가 실제 apply 완료 + install.sh dry-run 통과" 까지 끝내야
"done" 으로 전환.
