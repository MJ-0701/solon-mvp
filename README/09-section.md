---
doc_id: sfs-product-readme-9
title: "안전 계약"
visibility: oss-public
doc_type: product-intro
language: ko
updated: 2026-05-22
parent: README.md
summary: "안전 계약"
load_when: "Read when README.md routes to this section."
---
## 안전 계약

- Solon 은 사용자 산출물을 조용히 덮어쓰지 않습니다.
- commit/push 는 `sfs commit apply` 또는 명시 승인된 release flow 로 묶어 수행합니다.
  이 push 허용 계약은 Codex, Claude, Gemini 등 모든 LLM Agent 에 동일하게 적용됩니다.
- 공유해야 하는 기록은 `docs/solon/...` 아래에 남깁니다.
- core docs/context 에는 stable rule 과 결론만 남기고 prompt body, transcript, tmp scratch 는 남기지 않습니다.
- 검토는 작성자와 독립된 역할로 분리합니다.
- 최종 제품 판단은 항상 사용자에게 남깁니다.
