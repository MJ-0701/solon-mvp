---
doc_id: sfs-product-guide-ko-11
title: "10. Retro - sprint 마무리"
visibility: oss-public
doc_type: user-guide
language: ko
updated: 2026-05-22
parent: GUIDE.md
summary: "10. Retro - sprint 마무리"
load_when: "Read when GUIDE.md routes to this section."
---
## 10. Retro - sprint 마무리

```bash
sfs retro
```

`retro` 는 sprint 를 마무리하는 명령입니다. 한 번 실행하면 다음을 함께 처리합니다.

- `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/retro.md` 를 회고로 정리
- `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/report.md` 가 없으면 만들거나 최신 내용으로 정리
- 길어진 임시 기록을 private archive 로 접어 다음 사람이 볼 표면을 정리
- sprint 상태를 close
- local close commit 생성

일반 사용자는 도메인 플래그를 직접 줄 필요가 없습니다. 예를 들어
`sfs start "주문상품 수량 수정"` 처럼 자연어 목표만 주면 SFS 가 높은 확신의 도메인 신호를 추론해
인계 문서를 `docs/solon/order/order-items/quantity-update/<yyyyMMdd>/` 아래에 남깁니다.
`--domain`, `--subdomain`, `--feature` 는 추론이 틀렸을 때의 override 용도입니다. 도메인이 아직
불명확한 탐색 작업만 `--workspace <english-name>` fallback 을 씁니다.
`report.md` 와 `retro.md` 본문은 커밋 메시지 규칙과 같이
사용자의 native/workspace 언어로 작성해도 됩니다.

그래서 일반적인 흐름은 `sfs review -> sfs retro` 두 단계로 끝납니다. 보고서만 먼저
보고 싶거나 sprint 를 닫지 않고 회고 초안만 열고 싶을 때 쓰는 옵션은 §11 에
정리되어 있습니다.

보고서가 사용자 결정을 요구할 때는 `Q1` 같은 번호만 던지지 않습니다. 무엇을 결정해야 하는지,
왜 지금 필요한지, 권장 기본값과 각 선택지의 결과를 짧게 풀어 설명해야 합니다. 확정도
`A/A/A/C/C 확정` 같은 내부 option bundle 이 아니라 `권장안 그대로 확정` 같은 자연어를 씁니다.

---

