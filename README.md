---
doc_id: sfs-product-readme
title: "Solon 제품"
visibility: oss-public
doc_type: product-intro
language: ko
updated: 2026-07-28
summary: "Thin index for Solon 제품"
load_when: "Start here, then load only the child section needed."
split_children:
  - README/01-solon.md
  - README/02-sfs.md
  - README/03-section.md
  - README/04-section.md
  - README/05-section.md
  - README/06-section.md
  - README/07-section.md
  - README/08-section.md
  - README/09-section.md
---
# Solon 제품


> AI-native solo founder 를 위한 **Solo Founder System (SFS)**.
> Solon 은 AI 의 속도를 제품 운영으로 바꿔 주는 얇은 레일입니다.

**언어**: 한국어 / [영어 문서](./docs/en/index.md)

---

## 해결하는 문제

AI 로 만드는 속도는 이미 빠릅니다. 문제는 속도가 아니라 흐름입니다.

- 대화는 길어지는데 **결정은 어디에도 남지 않습니다**.
- AI 가 많이 바꿨지만 **무엇을 통과 기준으로 볼지** 흐려집니다.
- 구현자가 자기 결과를 스스로 승인하고 **독립 review 가 뒤로 밀립니다**.
- Claude·Codex·Gemini 를 같이 쓰면 각 agent 가 **서로 다른 프로젝트를 보는 것처럼** 움직입니다.
- sprint 가 끝나도 **다음 사람이 이어받을 한 장짜리 맥락이 없습니다**.

Solon 은 앱 뼈대를 대신 만들지 않습니다. 뼈대는 각 프레임워크와 AI 가 만들고, Solon 은 그
다음의 **제품 운영**(의도 정리 · 검증 가능한 계약 · 독립 검토 · 기록 · 인수인계)을 사람이
이해할 수 있는 얇은 레일로 잡습니다. 자세한 배경은 [왜 Solon인가](./README/01-solon.md).

## 제공 기능 (한눈에)

전체 기능표는 [기능 총람](./docs/ko/current-product-shape/29-feature-overview.md)에 축별로
정리돼 있습니다. 요약하면 6개 축입니다.

| 축 | 무엇을 하나 | 대표 표면 |
|---|---|---|
| 7-step 작업 레일 | 흐름을 결정론 rail 이 소유, LLM 은 각 게이트 안에서만 호출. 장시간·무인 런은 런 중 intent 재검증, 구현 착수 전 자기 반증 패스 | `sfs start` / `plan` / `implement` / `review` / `retro` |
| Evidence·기록 | 승인 · 결정 · waiver · 외부 근거를 최소 사실로 고정, 고위험 티어는 추론 로그까지 | `sfs capture` / `note` / `recall` |
| 하네스 엔지니어링 | 준비도 · 성숙도 · 비용 진단, 설계도, 무문서 역추적, 정적 보안 감사, 과제약·중복 지시 감지, 게이트 활동 계측 | `sfs harness doctor` / `dig` / `audit` |
| 컨텍스트·토큰 위생 | routed context, 얇은 어댑터, 위임 캡슐 계약, 지시 배치 판별 (비우회 게이트 vs 서술 advisory), 결과당 비용 프레임 | `sfs context` / `agent doctor` |
| 팀·오케스트레이션 | 팀 preset, 6본부 council, 작업 라우팅/루프, advisor 선택 코칭 바인딩, 단계별 effort 사전 배분 | `sfs team` / `division` / `route` |
| 기억·위키 | 장기 메모리, raw intake, 승격 파이프라인, 파생문서 주석 보존, 보안 finding 클래스 폐루프 | `sfs ingest` / `tidy --wiki-promote` |

명령을 몰라도 됩니다. agent 에게 자연어로 지시하면 위 레일로 해석합니다
(예: "배포해줘" → release readiness → 테스트 → 검수 → cut → tag → 채널 배포 → 설치 검증 → 보고).

---

## 문서 지도

이 파일은 기존 경로를 유지하는 얇은 진입점입니다. 상세 본문은 아래 child 문서로 분리되어 있고, 각 child 문서는 독립 frontmatter 를 가집니다.

- [왜 Solon인가](./README/01-solon.md)
- [SFS란](./README/02-sfs.md)
- [기본 흐름](./README/03-section.md)
- [설치](./README/04-section.md)
- [새 앱에서 시작하기](./README/05-section.md)
- [어디에 기록되나](./README/06-section.md)
- [자주 쓰는 명령](./README/07-section.md)
- [문서 지도](./README/08-section.md)
- [안전 계약](./README/09-section.md)
