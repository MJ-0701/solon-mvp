---
doc_id: sfs-product-readme-5
title: "새 앱에서 시작하기"
visibility: oss-public
doc_type: product-intro
language: ko
updated: 2026-05-22
parent: README.md
summary: "새 앱에서 시작하기"
load_when: "Read when README.md routes to this section."
---
## 새 앱에서 시작하기

처음 쓰는 사람이 Next.js, Spring, Java, API 같은 말을 알고 있을 필요는 없습니다. 사용자는 그냥 만들고
싶은 것을 말하면 됩니다.

Solon 을 쓰는 AI 는 앱 뼈대가 필요하다고 판단하면 먼저 사용자에게 묻고, 동의 후 프레임워크나 AI 의
native 방식으로 초기 구성을 만든 다음 Solon 흐름으로 돌아옵니다.

```bash
cd my-new-app
sfs init --layout thin --yes
sfs start "첫 작업 목표"
```

Solon 의 강점은 앱을 대신 찍어내는 것이 아니라, 앱을 만든 뒤부터 이어지는 의도 정리, 범위 결정,
실행 기록, 검토, 회고를 프로젝트 안에 남기는 데 있습니다.

처음 제품을 여는 founder 는 "아이디어가 맞나", "MVP 가 충분히 작나", "launch 해도 안전한가",
"scale 전에 무엇을 반복해야 하나"를 같은 흐름으로 묻습니다. Solon 은 chat 에서 판단을 정리하고,
code runtime 에서 구현/검증/배포 evidence 를 남기도록 역할을 나눕니다.

---
