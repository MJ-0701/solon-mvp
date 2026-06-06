---
doc_id: sfs-current-product-shape-ko
title: "현재 제품 구조와 운영 흐름"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-28
summary: "Thin index for 현재 제품 구조와 운영 흐름"
load_when: "Start here, then load only the child section needed."
split_children:
  - docs/ko/current-product-shape/01-section.md
  - docs/ko/current-product-shape/02-start.md
  - docs/ko/current-product-shape/03-token-diet-compact-i-o.md
  - docs/ko/current-product-shape/04-windows.md
  - docs/ko/current-product-shape/05-brainstorm-3.md
  - docs/ko/current-product-shape/06-hard-mode.md
  - docs/ko/current-product-shape/07-plan-transcript.md
  - docs/ko/current-product-shape/08-capture-evidence-primitive.md
  - docs/ko/current-product-shape/09-implement.md
  - docs/ko/current-product-shape/10-review-artifact-acceptance-review.md
  - docs/ko/current-product-shape/11-section.md
  - docs/ko/current-product-shape/12-section.md
  - docs/ko/current-product-shape/13-design-md-ai.md
  - docs/ko/current-product-shape/14-review-lens.md
  - docs/ko/current-product-shape/15-retro-sprint-close.md
  - docs/ko/current-product-shape/16-section.md
  - docs/ko/current-product-shape/17-token-harness-hygiene.md
  - docs/ko/current-product-shape/18-section.md
  - docs/ko/current-product-shape/19-obsidian-llm-wiki-continuity.md
  - docs/ko/current-product-shape/20-ai-work-intake-routing.md
  - docs/ko/current-product-shape/21-domain-knowledge-assets.md
  - docs/ko/current-product-shape/22-project-harness-map.md
  - docs/ko/current-product-shape/23-host-channels-and-mcp.md
---
# 현재 제품 구조와 운영 흐름


**Language**: 한국어 / [English](../en/current-product-shape.md)

이 문서는 Solon Product 의 현재 운영 모델을 한 번에 이해하기 위한 문서입니다. 버전별
체감 변화는 RELEASE-NOTES, 구현 단위 변경 기록은 CHANGELOG 가 맡습니다. 여기의 핵심은
명령어를 더 많이 외우게 만드는 것이 아니라, 사용자가 AI 시대에도 product owner 로서
생각과 판단의 주도권을 잃지 않게 돕는 흐름을 정리하는 것입니다.

## 문서 지도

이 파일은 기존 경로를 유지하는 얇은 진입점입니다. 상세 본문은 아래 child 문서로 분리되어 있고, 각 child 문서는 독립 frontmatter 를 가집니다.

- [한 줄 요약](./current-product-shape/01-section.md)
- [Start 이후의 인계](./current-product-shape/02-start.md)
- [Token Diet / Compact I/O](./current-product-shape/03-token-diet-compact-i-o.md)
- [Windows 래퍼 안정화](./current-product-shape/04-windows.md)
- [Brainstorm 3단계](./current-product-shape/05-brainstorm-3.md)
- [Hard Mode 의 목적](./current-product-shape/06-hard-mode.md)
- [Plan 은 transcript 가 아니라 계약](./current-product-shape/07-plan-transcript.md)
- [Capture 는 evidence primitive](./current-product-shape/08-capture-evidence-primitive.md)
- [Implement 는 코드만 뜻하지 않는다](./current-product-shape/09-implement.md)
- [Review 는 artifact acceptance review](./current-product-shape/10-review-artifact-acceptance-review.md)
- [얇은 멀티 에이전트 감독](./current-product-shape/11-section.md)
- [모델 라우팅과 책임 경계](./current-product-shape/12-section.md)
- [Design.md 와 AI 슬롭 방지](./current-product-shape/13-design-md-ai.md)
- [본부 / 지식팩 / Review Lens](./current-product-shape/14-review-lens.md)
- [Retro 는 기본적으로 sprint close](./current-product-shape/15-retro-sprint-close.md)
- [문서 구조](./current-product-shape/16-section.md)
- [Token / Harness Hygiene](./current-product-shape/17-token-harness-hygiene.md)
- [언제 어떤 모드를 고르나](./current-product-shape/18-section.md)
- [Obsidian LLM Wiki Continuity](./current-product-shape/19-obsidian-llm-wiki-continuity.md)
- [AI Work Intake Routing](./current-product-shape/20-ai-work-intake-routing.md)
- [도메인 지식 자산](./current-product-shape/21-domain-knowledge-assets.md)
- [Project Harness Map](./current-product-shape/22-project-harness-map.md)
- [탑다운 학습 가이드](./current-product-shape/24-topdown-learning-guide.md)
