# INSTALL-GUIDE — solon-wip 플러그인 사용자 Mac 설치

> **대상**: 사용자 (채명정) 가 개인 MacBook 에서 방법 2 선택 시.
> **시간**: 2~3 분.

## 1 단계 — 사전 확인

```bash
# Solon docset 이 사용자 홈 어딘가에 clone 되어 있는지 확인
ls ~/workspace/solon-docset/2026-04-19-sfs-v0.4/README.md
# 또는 실제 경로 (예: ~/agent_architect/2026-04-19-sfs-v0.4/)
```

경로 없으면 먼저 clone:

```bash
mkdir -p ~/workspace
cd ~/workspace
git clone git@github.com:MJ-0701/solon.git solon-docset
# 또는 HTTPS: git clone https://github.com/MJ-0701/solon.git solon-docset
```

## 2 단계 — 플러그인 설치

```bash
# Solon docset 의 plugin-wip-skeleton 을 개인 Claude 플러그인 디렉토리로 복사
mkdir -p ~/.claude/plugins
cp -r ~/workspace/solon-docset/2026-04-19-sfs-v0.4/plugin-wip-skeleton \
      ~/.claude/plugins/solon-wip

# docset 본문을 플러그인 내부로 symlink
ln -s ~/workspace/solon-docset/2026-04-19-sfs-v0.4 \
      ~/.claude/plugins/solon-wip/docs
```

## 3 단계 — plugin.json 개인화 (선택)

```bash
# author.email 을 실제 이메일로 치환
sed -i '' 's/jack2718@example.com/YOUR_REAL_EMAIL@domain/' \
  ~/.claude/plugins/solon-wip/plugin.json
```

(macOS `sed -i ''` 형식. Linux 는 `sed -i`)

## 4 단계 — Claude Code 재시작 + 검증

```bash
# 기존 claude 세션 종료
# 새 세션 열고 아래 확인

ls ~/.claude/plugins/solon-wip/
# → plugin.json / README.md / INSTALL-GUIDE.md / docs (symlink) 보여야 함

ls ~/.claude/plugins/solon-wip/docs/
# → Solon docset 본문 (00-intro.md ~ 10-phase1-implementation.md 등) 보여야 함
```

Claude 에게 확인 질문:

> "solon-wip 플러그인 인식됐어? `~/.claude/plugins/solon-wip/docs/CLAUDE.md` 읽어봐."

Claude 가 Solon docset 의 CLAUDE.md 내용을 되풀이해 주면 정상.

## 5 단계 — admin panel repo 에서 사용

admin panel repo 에서 Claude 세션 시작 시 (repo 의 CLAUDE.md 에는 Solon 경로를 기록하지 않으므로) 대화에서 지칭:

> "내 개인 플러그인 solon-wip 의 docs/05-gate-framework 참고해서..."

Claude 가 플러그인 경로의 docs/ 를 Read 하여 참조. admin panel repo 에는 어떤 Solon 관련 파일도 유입되지 않음 (IP 경계).

## 제거

```bash
rm -rf ~/.claude/plugins/solon-wip
```

풀스펙 `solon` 플러그인 완성 시점에 교체.

## 트러블슈팅

| 증상 | 원인 | 해결 |
|---|---|---|
| Claude 가 플러그인 인식 안 함 | `plugin.json` JSON 문법 오류 | `jq . plugin.json` 로 파싱 확인 |
| `docs/` symlink 이 broken | 원본 docset 경로가 이동됨 | `ln -sfn <새 경로> ~/.claude/plugins/solon-wip/docs` |
| `~/.claude/plugins/` 자체가 없음 | Claude Code 신규 설치 | Claude Code 를 1 회 실행한 뒤 다시 설치 |
