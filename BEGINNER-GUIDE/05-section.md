---
doc_id: sfs-beginner-guide-ko-5
title: "실제 프로젝트에 적용하기"
visibility: oss-public
doc_type: beginner-guide
language: ko
updated: 2026-05-22
parent: BEGINNER-GUIDE.md
summary: "실제 프로젝트에 적용하기"
load_when: "Read when BEGINNER-GUIDE.md routes to this section."
---
## 실제 프로젝트에 적용하기

테스트가 성공한 뒤 실제 프로젝트 폴더로 이동합니다.

Windows:

```powershell
cd C:\workspace\my-project
git init
sfs.cmd init --layout thin --yes
sfs.cmd status
```

Mac:

```bash
cd ~/workspace/my-project
git init
sfs init --layout thin --yes
sfs status
```

이미 Git 이 있는 프로젝트라면 `git init` 은 다시 해도 보통 안전합니다. 그래도 불안하면
그 줄은 건너뛰고 Windows 는 `sfs.cmd init --layout thin --yes`, Mac/Git Bash 는
`sfs init --layout thin --yes` 부터 실행하세요.

설치 후 프로젝트 폴더에는 이런 파일이 생깁니다.

| 파일/폴더 | 뜻 |
|---|---|
| `SFS.md` | AI 가 읽는 프로젝트 운영 규칙 |
| `.sfs-local/` | git 에 올리지 않는 private 작업 공간 |
| `docs/<workspace>/<yyyyMMdd>/` | 공유할 요약/인계 문서가 생기는 곳 |
| `CLAUDE.md` | Claude 가 Solon 을 찾는 입구 |
| `AGENTS.md` | Codex 가 Solon 을 찾는 입구 |
| `GEMINI.md` | Gemini 가 Solon 을 찾는 입구 |

큰 프로젝트나 기존 문서가 많은 프로젝트에서는 AI 가 Obsidian 용 `llm-wiki/` 지도를 권장할 수
있습니다. 필수는 아니고, 원문 문서를 복사하는 공간도 아닙니다. 나중에 다시 찾기 쉽게
source link 와 읽는 순서를 모아두는 선택지입니다.

---
