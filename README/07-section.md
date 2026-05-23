---
doc_id: sfs-product-readme-7
title: "자주 쓰는 명령"
visibility: oss-public
doc_type: product-intro
language: ko
updated: 2026-05-23
parent: README.md
summary: "자주 쓰는 명령"
load_when: "Read when README.md routes to this section."
---
## 자주 쓰는 명령

| 명령 | 용도 |
|---|---|
| `sfs status` | 현재 sprint 상태 확인 |
| `sfs guide` | 설치된 프로젝트에서 짧은 터미널 가이드 보기 |
| `sfs start <goal>` | 새 작업 묶음 시작 |
| `sfs brainstorm [--simple|--hard] [text|--stdin]` | 만들기 전에 의도와 기준 정리 |
| `sfs plan` | 목표/범위/완료 기준 계약 작성 |
| `sfs capture [--kind ...] <text>` | 자연어로 바뀐 결정/리뷰순서/예외를 현재 sprint 기록에 남김 |
| `sfs note <text>` | 짧은 자연어 flow note 를 남기는 capture alias |
| `sfs implement [slice|--stdin]` | 작은 실행 조각 진행 |
| `sfs review [--sprint <id>] [--lens ...]` | 산출물 검토, 닫힌 sprint review 복구 |
| `sfs retro [--draft]` | 회고와 마무리 |
| `sfs commit plan` | 변경 그룹 확인 |
| `sfs commit apply --group <name>` | 선택 그룹을 commit 하고 현재 branch push |
| `sfs upgrade` | 프로젝트의 Solon 파일과 흐름 최신화 |
| `sfs tidy [--apply]` | 끝난 작업의 임시 기록 정리 |

Agent 에게 "배포해줘" 라고 말하면 단순 publish 가 아니라 "배포 프로세스 쭉 진행해줘" 로
해석합니다. 이 흐름은 release readiness check, 관련 테스트, review/검수, release cut,
stable tag, Homebrew/Scoop 배포, 설치 runtime 검증, evidence 보고까지 포함합니다.

`sfs capture` 는 짧은 checkpoint 전용입니다. 긴 prompt, 전체 대화, bridge/review scratch,
command log 는 core docs 에 복사하지 말고 archive/evidence path 만 남기세요.

---
