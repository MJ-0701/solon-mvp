---
doc_id: sfs-product-readme-7
title: "자주 쓰는 명령"
visibility: oss-public
doc_type: product-intro
language: ko
updated: 2026-07-13
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
| `sfs capture [--kind ...] <text>` | 승인/waiver/결정/외부 evidence 같은 최소 사실만 현재 sprint 기록에 남김 |
| `sfs note <text>` | 짧은 evidence note 를 남기는 capture alias |
| `sfs ingest --source-type <type> --purpose <why>` | wiki 로 컴파일하기 전 Raw source 목적과 스키마를 잠근 intake 초안 생성 |
| `sfs harness doctor` | 긴 자율 작업 전에 하네스 준비 상태 점검 + AI-readiness(Sanity) 4축 채점 + 세션 비용 신호(토큰/캐시 적중률/탐색·편집 비율) — 전부 신호만, 차단 없음 |
| `sfs harness map --write` | agent 역할, artifact, memory, test, release loop 설계도 작성. Sanity 미감사·waiver 없음이면 readiness advisory 한 줄 출력 (지도는 항상 기록) |
| `sfs dig scan\|graph\|capsule\|card\|status` | 인계 문서 없는 코드베이스를 코드에서 역추적 — L0 스캔+ERD·L1 그래프는 LLM 0토큰, 대상 read-only ([가이드](../GUIDE/17-16-undocumented-takeover.md)) |
| `sfs audit scan\|report\|status` | 자기 저장소 정적 보안 감사 — OWASP 계열 취약점 표면(시크릿·injection·설정·의존성·위생), 시크릿 값 마스킹, 방어 전용·신호만 ([가이드](../GUIDE/18-17-security-audit.md)) |
| `sfs team use <solo\|pair\|trio>` | 팀 preset 활성화 (scaffold + runtime binding 작성) |
| `sfs team refresh` | capability 재평가 + binding 재적용 (deprecated fallback 승격 제안 포함) |
| `sfs implement [slice|--stdin]` | 작은 실행 조각 진행 |
| `sfs review [--sprint <id>] [--lens ...]` | 산출물 검토, 닫힌 sprint review 복구 |
| `sfs retro [--draft]` | 회고와 마무리 |
| `sfs commit plan` | 변경 그룹 확인 |
| `sfs commit apply --group <name>` | 선택 그룹을 commit 하고 현재 branch push |
| `sfs upgrade` | 프로젝트의 Solon 파일과 흐름 최신화 |
| `sfs tidy [--apply]` | 끝난 작업의 임시 기록 정리 |
| `sfs tidy --all --wiki-promote [--apply]` | `docs/solon` report/retro 에서 llm-wiki 계승 후보를 먼저 만들고 정리 |

Agent 에게 "배포해줘" 라고 말하면 단순 publish 가 아니라 "배포 프로세스 쭉 진행해줘" 로
해석합니다. 이 흐름은 release readiness check, 관련 테스트, review/검수, release cut,
stable tag, Homebrew/Scoop 배포, 설치 runtime 검증, evidence 보고까지 포함합니다.

`sfs capture` 는 lifecycle 단계가 아니라 evidence primitive 입니다. 기본 흐름에 끼워 넣지 말고
긴 prompt, 전체 대화, bridge/review scratch, command log 는 core docs 에 복사하지 말고
archive/evidence path 만 남기세요.

`sfs ingest` 는 원문을 가져오거나 요약하지 않습니다. 먼저 왜 이 source 를 모으는지와
`article` / `youtube` / `podcast` / `book` / `research` 중 어느 raw schema 인지만 기록합니다.

`sfs tidy --wiki-promote` 는 report/retro 를 지우는 명령이 아닙니다. `llm-wiki/promotion-candidates/`
에 source-linked 후보 노트를 만들고, 실제 TopicHub/glossary/DDD map 승격은 사람이 검토한 뒤 합니다.

---
