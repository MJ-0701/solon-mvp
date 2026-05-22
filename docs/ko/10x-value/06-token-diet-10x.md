---
doc_id: sfs-10x-value-ko-6
title: "Token Diet 10x 루프"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-22
parent: docs/ko/10x-value.md
summary: "Token Diet 10x 루프"
load_when: "Read when docs/ko/10x-value.md routes to this section."
---
## Token Diet 10x 루프

AI agent 를 오래 쓰면 비용보다 먼저 맥락 품질이 흔들립니다. 짧은 답변이 도움이 되는 이유는
단어 수 자체가 아니라, 사용자가 볼 필요 없는 장식을 줄이고 판단에 필요한 trace 를 더 빨리 찾게
하기 때문입니다.

| Token Diet practice | Solon 의미 | 10x 효과 |
|---|---|---|
| Professional compact output | routine status/start/report 를 한 줄 필드로 출력 | 기다리는 시간과 읽는 비용을 줄임 |
| Evidence-preserving floor | warning, decision, evidence, source trace, verification 은 유지 | 짧아져도 review 품질이 무너지지 않음 |
| Raw-text fallback | compact 판단이 애매하면 원문/경로를 다시 확인 | 잘못 요약한 상태로 구현하지 않음 |
| Context Diet | routed context, stable search vocabulary, concept-grained artifact 우선 | 입력 토큰을 broad read 로 태우지 않음 |
| Quiet release verifier | 성공한 install/upgrade smoke 로그는 접고 실패 stdout/stderr 는 replay | 배포 로그는 짧고 실패 원인은 추적 가능 |
| Persona opt-in | Caveman/persona 말투는 기본값이 아님 | 제품 출력 톤을 장난으로 만들지 않음 |

Token Diet 의 성공 조건은 "짧아짐"이 아닙니다. 짧아져도 evidence/risk/raw traceability 가 살아 있어야
성공입니다. 그 조건이 흔들리면 Solon 은 full clarity 로 돌아갑니다.

