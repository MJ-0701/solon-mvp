---
doc_id: sfs-current-product-shape-ko-3
title: "Token Diet / Compact I/O"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-22
parent: docs/ko/current-product-shape.md
summary: "Token Diet / Compact I/O"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## Token Diet / Compact I/O

Token Diet 는 AI 응답을 무조건 짧게 만드는 모드가 아닙니다. routine 상태/인계 출력에서
불필요한 장식을 줄이되, 판단과 검증에 필요한 필드는 남기는 compact I/O 계약입니다.

```bash
SFS_OUTPUT_STYLE=compact sfs status
sfs status --compact
sfs start "첫 작업 목표" --output-style compact
SFS_OUTPUT_STYLE=compact sfs report
```

compact `status` 는 `sprint`, `wu`, `gate`, `verdict`, `ahead`, `last_event` 를 보존합니다.
compact `start` 는 생성된 sprint path, shared docs path, lazy step-doc 상태, 권장 brainstorm 명령,
`--simple` / `--hard` 대안, `recommended=normal` 을 보존합니다. compact `report` 는 report path,
archive path, compact/finalization 상태를 보존합니다.

반대로 destructive/security/privacy/data-loss warning, 사용자 decision, review finding,
raw-source traceability, verification evidence 는 줄이면 품질이 낮아질 수 있으므로 full clarity 를
유지합니다. Caveman/persona 말투는 기본값이 아니며, SFS 기본값은 professional compact output 입니다.
품질 기준은 evidence/risk/raw traceability 먼저, 짧아짐은 그 다음입니다.
filefunc 에서 흡수한 것은 one-file-one-function 규칙이 아니라 precise routed context, stable search
vocabulary, raw-text fallback, verification 같은 Context Diet 원칙입니다.

0.6.85 release verifier 는 이 quality floor 를 배포 확인에도 적용합니다. 성공한 내부
install/upgrade smoke 로그는 조용히 접고, 실패하면 캡처한 stdout/stderr 를
`[verify-product-release]` prefix 로 다시 보여줍니다. 배포 로그는 짧아져도 실패 원문과
증거 경로는 사라지지 않습니다.

작업을 닫을 때 `report.md` 와 `retro.md` 는 `.sfs-local` 안이 아니라
`docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/` 아래에 생성됩니다. 예를 들어 주문 도메인의
주문상품 수량 변경은 `order/order-items/quantity-update` 처럼 도메인 → 서브도메인 → 기능 순서로
둡니다. 일반 사용자는 `sfs start "<goal>"` 처럼 자연어 목표만 주면 되고, SFS 가 높은 확신의
도메인 신호를 자동 추론합니다. 목표가 아직 도메인으로 분류되지 않는 탐색 작업만
`--workspace <english-name>` 으로 legacy fallback 폴더를 고정합니다. 본문 언어는
커밋 메시지와 같이 사용자의 native/workspace 언어를 기본값으로 둡니다.

