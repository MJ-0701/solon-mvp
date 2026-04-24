# solon-wip — 임시 Claude Code 플러그인 skeleton

> **상태**: WIP (`0.1-wip`). 풀스펙 `solon` 플러그인 (07-plugin-distribution.md 및 §10.4 W13) 완성 전까지의 **임시 참조용**.
> **출처**: Solon docset `2026-04-19-sfs-v0.4/plugin-wip-skeleton/` (WU-18, 2026-04-24).
> **대응 결정**: PHASE1-KICKOFF-CHECKLIST §1.1 "Solon 참조 방식 — 방법 2".
> **IP 경계**: 사용자 개인 머신 전용. 회사 머신에 배포하지 않음. admin panel repo 에 설치하지 않음.

## 역할

- Claude Code 가 `~/.claude/plugins/solon-wip/` 경로를 플러그인으로 인식하도록 하는 최소 manifest (`plugin.json`).
- 실제 skill / command / agent 정의는 비어있음 — **docset 본문을 `docs/` 하위에 mount 또는 symlink** 해서 Claude Code 가 docset 을 읽도록 하는 것이 사용 패턴.

## 사용 패턴 (권장)

```bash
# 1. ~/.claude/plugins/solon-wip/ 로 본 skeleton 이동
mkdir -p ~/.claude/plugins
cp -r /path/to/solon-docset/2026-04-19-sfs-v0.4/plugin-wip-skeleton/ ~/.claude/plugins/solon-wip/

# 2. docset 본문을 docs/ 하위로 symlink (admin panel repo 외부!)
cd ~/.claude/plugins/solon-wip/
ln -s /path/to/solon-docset/2026-04-19-sfs-v0.4 docs

# 3. Claude Code 재시작
# 4. claude 세션에서 "solon-wip 플러그인 인식됐어?" 로 검증
```

## 주의

- 이 플러그인은 **읽기 전용 참조** 목적. skill/command 자동 주입 없음 (풀스펙 W13 구현 후 `solon` 플러그인이 대체).
- 설치 후 `plugin.json` 의 `author.email` 을 사용자 실제 이메일로 치환 권장.
- 회사 머신 (업무용 Mac) 에는 설치 금지. 개인 MacBook 등 IP 경계 안쪽에만.

## 설치 후 제거

`rm -rf ~/.claude/plugins/solon-wip/` 한 줄로 완전 제거. 풀스펙 `solon` 플러그인으로 교체 시 선행 필수.

## 관련 문서

- `INSTALL-GUIDE.md` — 설치 1-liner + 검증 절차
- `../phase1-mvp-templates/` — admin panel repo 용 템플릿 (본 플러그인과 별개)
- `../PHASE1-KICKOFF-CHECKLIST.md §2.2` — 본 방법 2 원본 체크리스트
- `../07-plugin-distribution.md` — 풀스펙 `solon` 플러그인 end-state 설계
