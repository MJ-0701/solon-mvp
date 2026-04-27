# phase1-mvp-templates/ — admin panel repo 복사 소스

> **출처**: Solon docset `2026-04-19-sfs-v0.4/phase1-mvp-templates/` (WU-18 에서 신설, 2026-04-24).
> **사용처**: 사용자 (채명정) 가 새 회사 관리자 페이지 repo 를 만들 때 **cp** 해서 W0 를 빠르게 exit.
> **IP 경계**: 모든 파일은 Solon 경로 / repo URL **하드코딩 없음**. `<PROJECT-NAME>` / `<STACK>` 같은 placeholder 만 존재.
> **대응 문서**: `../PHASE1-KICKOFF-CHECKLIST.md §2 W0` (원본 체크리스트) + `../PHASE1-MVP-QUICK-START.md` (사용자 5 분 runbook).

## 포함 파일

```
phase1-mvp-templates/
├── README.md                              # 본 파일 (Solon docset 내부용 메타)
├── setup-w0.sh                            # 🆕 WU-19: W0 §2 실행 자동화 (env 3개 입력)
├── verify-w0.sh                           # 🆕 WU-19: W0 §6 exit 검증 자동화 (setup-w0.sh 산출물 전용)
├── verify-install.sh                      # 🆕 WU-30: install.sh 산출물 검증 (어댑터 4종 + .claude/commands/sfs.md + .sfs-local 구조 + 자동 치환 검증)
├── CLAUDE.md.template                     # → admin panel repo 의 CLAUDE.md 로 cp
├── README.md.template                     # → admin panel repo 의 README.md 로 cp
├── .gitignore.snippet                     # → admin panel repo 의 .gitignore 에 추가 블록 (append)
├── .sfs-local-template/
│   ├── divisions.yaml.template            # → .sfs-local/divisions.yaml
│   ├── events.jsonl                       # → .sfs-local/events.jsonl (빈 파일)
│   ├── sprints/.gitkeep                   # → .sfs-local/sprints/.gitkeep
│   └── decisions/.gitkeep                 # → .sfs-local/decisions/.gitkeep
├── sprint-0-brainstorm.md.template        # → .sfs-local/sprints/2026-W18-sprint-1/brainstorm.md 의 boilerplate
└── PROMPT-FOR-FIRST-SESSION.md            # admin panel repo 첫 Claude 대화 시 복붙 프롬프트
```

## 스크립트 사용 (권장 경로)

### A. setup-w0.sh 경로 (template cp + 3 commit, WU-19 신설)

```bash
# W0 실행 (repo 생성 + templates cp + placeholder 치환 + 3 commit + push)
export PROJECT_NAME="<project-name>"
export SOLON_DOCSET="$HOME/workspace/solon-docset/2026-04-19-sfs-v0.4"
export WORKSPACE="$HOME/workspace"
"$SOLON_DOCSET/phase1-mvp-templates/setup-w0.sh"

# W0 exit 검증 (setup-w0.sh 산출물 전용 — 7 체크)
cd "$WORKSPACE/$PROJECT_NAME"
"$SOLON_DOCSET/phase1-mvp-templates/verify-w0.sh"
```

### B. install.sh 경로 (solon-mvp 어댑터 설치, WU-21 ~ WU-31)

```bash
# install.sh 실행 → 어댑터 (SFS/CLAUDE/AGENTS/GEMINI) + .claude/commands/sfs.md
#                 + .sfs-local/ 스캐폴드 + .gitignore solon-mvp marker block 설치
cd <consumer-repo>/
bash <path-to>/solon-mvp/install.sh

# install.sh 산출물 검증 (verify-w0.sh 와 별도 호출 — 7 체크)
bash "$SOLON_DOCSET/phase1-mvp-templates/verify-install.sh"
```

> ⚠️ **두 검증기 분리 (WU-30, WU22-D9 (b))**: `verify-w0.sh` 는 `setup-w0.sh` 산출물 전용,
> `verify-install.sh` 는 `install.sh` 산출물 전용. 교차 호출 시 false-positive 발생 가능
> (예: install.sh banner / 어댑터의 'Solon' 키워드가 verify-w0.sh check #2/#7 에 over-strict 매치).
> 반드시 산출 경로에 맞는 검증기 사용.

상세: `../PHASE1-MVP-QUICK-START.md §2 + §6` (setup-w0.sh) + `../sprints/WU-30.md` (verify-install.sh 분리 결정).

## 사용 순서 (요약, 상세는 QUICK-START 참조)

1. 사용자 Mac 에서 새 repo `<PROJECT-NAME>` 생성 + clone.
2. 본 디렉토리 전체를 repo 외부 (예: `~/workspace/solon-docset/2026-04-19-sfs-v0.4/phase1-mvp-templates/`) 에 둔 상태로 **파일별로** 복사:
   - `cp CLAUDE.md.template <repo>/CLAUDE.md` — placeholder 치환
   - `cp README.md.template <repo>/README.md` — placeholder 치환
   - `cat .gitignore.snippet >> <repo>/.gitignore`
   - `cp -r .sfs-local-template/ <repo>/.sfs-local/` — divisions.yaml 치환
   - `sprint-0-brainstorm.md.template` / `PROMPT-FOR-FIRST-SESSION.md` 는 참고용, cp 선택.
3. repo 루트에서 `git ls-files | grep -i solon` 실행 → **비어있어야** (IP 경계 검증).
4. 치환 끝내고 3 개 commit (init / CLAUDE.md / divisions.yaml) 완료 → W0 exit.

자세한 결정 체크박스 + 치환 매뉴얼은 `../PHASE1-MVP-QUICK-START.md`.

## IP 경계 검증 규칙 (critical)

- 이 폴더 자체는 Solon docset repo 안에 존재 → 그대로 있으면 개인 IP.
- admin panel repo 쪽에는 **파일 내용만** 이동 (확장자 `.template` 제거 + placeholder 치환). `phase1-mvp-templates/` 폴더 구조를 옮기는 것이 아님.
- 복사 후 admin panel repo 에서 `.template` 확장자 파일이 남으면 안 됨.

## Changelog

- **v0.1-mvp** (2026-04-24, WU-18): 초기 신설 (CLAUDE.md.template + README.md.template + .gitignore.snippet + .sfs-local-template + sprint-0-brainstorm + PROMPT-FOR-FIRST-SESSION + 폴더 README).
- **v0.2-mvp** (2026-04-24, WU-19): executable scripts 추가 — `setup-w0.sh` + `verify-w0.sh`. QUICK-START §2 100줄 복붙 → 스크립트 호출 1 줄로 단축.
- **dev-pending** (2026-04-26, WU-30): 두 검증기 분리 — `verify-w0.sh` check #6 정규식 minimal fix (`[A-Z]{2,}`) + check #7 헤더 주석 (setup-w0.sh 전용 명시) + `verify-install.sh` 신설 (install.sh 산출물 전용, 160 lines, 7 체크). README §스크립트 사용 (권장 경로) 두 경로 (A. setup-w0.sh / B. install.sh) 분리. dev path only (R-D1 §1.13) — `~/workspace/solon-mvp/templates/phase1-mvp-templates/` + `solon-mvp-dist/templates/phase1-mvp-templates/` 동기화는 다음 release cut (예상 0.4.0-mvp) 타이밍.
