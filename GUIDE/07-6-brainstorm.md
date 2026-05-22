---
doc_id: sfs-product-guide-ko-7
title: "6. Brainstorm - 생각 정리 단계"
visibility: oss-public
doc_type: user-guide
language: ko
updated: 2026-05-22
parent: GUIDE.md
summary: "6. Brainstorm - 생각 정리 단계"
load_when: "Read when GUIDE.md routes to this section."
---
## 6. Brainstorm - 생각 정리 단계

`brainstorm` 은 요구사항을 받아 적는 명령이 아닙니다. plan 으로 넘어가기 전에 사용자의 의도,
우선순위, 포기할 것, 성공 기준을 드러내는 단계입니다.

| Mode | 언제 쓰나 | 결과 |
|---|---|---|
| `--simple` | 이미 답이 거의 정해졌을 때 | 요구사항을 짧게 정리하고 plan seed 로 넘김 |
| 기본 `normal` | 대부분의 새 작업 | 2~5개의 핵심 질문으로 빠진 결정을 확인 |
| `--hard` | 의도, 경계, 용어, 검증 방식이 흐릿할 때 | 사용자가 product owner 로 깊게 생각할 때까지 계속 캐묻기 |

예시는 아래와 같습니다.

```bash
sfs brainstorm "사용자가 결제 실패 이유를 더 빨리 파악하게 하고 싶다"
```

긴 내용을 파일로 정리해 두셨다면 아래처럼 입력하시면 됩니다.

```bash
sfs brainstorm --stdin < requirements.txt
```

`--hard` 는 일부러 빠른 실행을 늦춥니다. AI 가 바로 달려가서 완성물을 만드는 대신,
사용자가 제품의 주인으로 판단해야 하는 질문을 계속 꺼냅니다. 이 모드는 AI 도움을 줄이는 기능이
아니라, AI 시대에 생각하는 근육을 잃지 않게 하는 훈련 모드입니다.

---

