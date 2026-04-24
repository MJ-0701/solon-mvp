# phase1-mvp-templates/ — admin panel repo 복사 소스

> **출처**: Solon docset `2026-04-19-sfs-v0.4/phase1-mvp-templates/` (WU-18 에서 신설, 2026-04-24).
> **사용처**: 사용자 (채명정) 가 새 회사 관리자 페이지 repo 를 만들 때 **cp** 해서 W0 를 빠르게 exit.
> **IP 경계**: 모든 파일은 Solon 경로 / repo URL **하드코딩 없음**. `<PROJECT-NAME>` / `<STACK>` 같은 placeholder 만 존재.
> **대응 문서**: `../PHASE1-KICKOFF-CHECKLIST.md §2 W0` (원본 체크리스트) + `../PHASE1-MVP-QUICK-START.md` (사용자 5 분 runbook).

## 포함 파일

```
phase1-mvp-templates/
├── README.md                              # 본 파일 (Solon docset 내부용 메타)
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

- **v0.1-mvp** (2026-04-24, WU-18): 초기 신설.
