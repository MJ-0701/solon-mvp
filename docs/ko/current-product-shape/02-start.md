---
doc_id: sfs-current-product-shape-ko-2
title: "Start 이후의 인계"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-22
parent: docs/ko/current-product-shape.md
summary: "Start 이후의 인계"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## Start 이후의 인계

`sfs start "<goal>"` 는 sprint workspace 를 만들고 끝나는 명령입니다. 다만 새 요구 탐색에는
대부분 brainstorm 이 필요하므로, start 성공 출력은 사용자가 가이드를 읽지 않았어도 다음 선택지를
볼 수 있게 안내합니다.

```text
next: sfs brainstorm --simple "..."  # 빠른 정리
      sfs brainstorm "..."           # 기본값, normal thinking scaffold
      sfs brainstorm --hard "..."    # product owner hard training
```

사용자가 입력하는 명령어는 그대로 `sfs brainstorm` 입니다. Solon 이 지금 작업에 맞는
depth 옵션을 함께 보여드릴 뿐입니다.

