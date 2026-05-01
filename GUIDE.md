# Solon Product — 사용 가이드 (entry-lean)

> `/sfs guide` 가 출력하는 onboarding 요약입니다. entry-time token 비용을 줄이기 위해
> 상세 설명/긴 예시는 `archives/` 로 옮겼습니다.

- Full guide (verbose): [archives/GUIDE.full.md](./archives/GUIDE.full.md)
- Full product docs: [README.full.md](./README.full.md)
- Release history: [CHANGELOG.md](./CHANGELOG.md)

---

## 0) 설치 직후 3분 체크

macOS/Linux (Homebrew 포함):

```bash
brew install MJ-0701/solon-product/sfs
cd ~/workspace/my-project
sfs init --yes
sfs agent install all
```

Windows (Scoop + Git for Windows):

```powershell
scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs
cd C:\workspace\my-project
git init
sfs init --layout thin --yes
sfs agent install all
```

생기는 핵심 구조(요약):

```text
my-project/
├── SFS.md        (본인이 편집: 운영 약속/스택/도메인)
├── CLAUDE.md     (본인이 편집: Claude adapter)
├── AGENTS.md     (본인이 편집: Codex adapter)
├── GEMINI.md     (본인이 편집: Gemini adapter)
└── .sfs-local/   (state/산출물 누적: sprints/ decisions/ events.jsonl)
```

메모:
- thin layout 기본은 global `sfs` runtime + project-local `.sfs-local/` state 입니다.
- adapter 를 다시 깔거나 갱신하려면 `sfs agent install claude|gemini|codex|all` 을 다시 실행합니다.
- 버전 갱신은 uninstall/reinstall 대신 `sfs upgrade` 입니다.

---

## 1) 첫 5분 — `SFS.md` placeholder 치환

`SFS.md` 최상단의 placeholder 를 프로젝트 실정보로 치환합니다.

```markdown
- **이름**: `<PROJECT-NAME>`
- **도메인**: `<DOMAIN>`
- **Stack**: `<STACK>`
- **DB**: `<DB>`
- **배포**: `<DEPLOY>`
```

`<DATE>` / `<SOLON-VERSION>` 은 설치 시 자동 치환되므로 보통 건드리지 않습니다.

---

## 2) 다음 5분 — `status` → `start`

환경별 진입점:

| 환경 | 권장 입력 |
|:--|:--|
| Claude Code | `/sfs status` |
| Gemini CLI | `/sfs status` |
| Codex (app/CLI) | `$sfs status` 또는 `sfs status` |

Codex 에서 bare `/sfs ...` 가 host slash parser 에 막히면(모델/Skill 까지 도달하지 않으면),
`$sfs ...` 또는 `sfs ...` 를 사용합니다.

첫 sprint 시작:

```text
/sfs start "todo 앱 v0 — 일정 추가/완료/삭제 + Postgres 저장"
```

---

## 3) 10분 — `plan` → `implement` → `review`

Solon 은 workbench 문서(작업 중)와 entry 문서(닫힌 후) 를 분리합니다.

- workbench: `brainstorm.md`, `plan.md`, `implement.md`, `log.md`, `review.md`
- entry: `report.md`, `retro.md` (닫힌 sprint 의 읽는 입구)

권장 루프:

```text
/sfs plan
/sfs implement "첫 구현 slice"
/sfs review --gate G4 --executor codex|gemini|claude
```

리뷰 실행이 어려우면 `--prompt-only` 또는 `--show-last` 로 결과/프롬프트만 확인합니다.

---

## 4) 마무리 — `report` / `retro` / `tidy`

```text
/sfs report --compact
/sfs retro --close
```

또는 기존 sprint 를 정리만 할 때:

```text
/sfs tidy --sprint <id-or-ref> --apply
```

원칙:
- verbose evidence/workbench/tmp 는 `.sfs-local/archives/` 로 이동시키고,
- 닫힌 sprint 에는 `report.md` + `retro.md` 만 남깁니다.

---

## 5) 토큰/안전 수칙 (autoload 최소화)

- 필요할 때만 열기: `.sfs-local/events.jsonl`, 오래된 `scheduled_task_log`, 오래된 `review-runs`
- mutex: `sfs loop` 가 Solon `domain_locks` 충돌을 출력하면 즉시 중단하고 lock owner/domain 을 보고
- 긴 히스토리는 archive-first: `.sfs-local/archives/` 를 기본 보관소로 취급

---

## 6) 트러블슈팅 (요약)

- `project is not initialized` → 프로젝트 루트에서 `sfs init --yes`
- executor auth 문제 → `sfs auth status` / `sfs auth login <executor>`
- `sfs upgrade` 는 패키지 업데이트 + 프로젝트 갱신을 분리해서 생각:
  - 패키지(글로벌): Homebrew/Scoop 업데이트
  - 프로젝트(로컬): `sfs upgrade`

---

## 7) 더 깊게 보기

- 상세 onboarding: [archives/GUIDE.full.md](./archives/GUIDE.full.md)
- `/sfs loop`/queue/mutex/아카이브 철학: [README.full.md](./README.full.md)
- 변경 이력/향후 plan: [CHANGELOG.md](./CHANGELOG.md)
