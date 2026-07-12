---
doc_id: sfs-product-guide-ko-17
title: "16. 무문서 코드베이스 인수 (dig)"
visibility: oss-public
doc_type: user-guide
language: ko
updated: 2026-07-13
parent: GUIDE.md
summary: "인계 문서 없는 외주/레거시 코드베이스를 코드에서 역추적하는 순서 — 첫날 30분 체크리스트 포함"
load_when: "Read when GUIDE.md routes to this section."
---
## 16. 무문서 코드베이스 인수 (dig)

인계 문서·기획서·요구사항정의서가 없고 깃 히스토리도 못 믿는 코드베이스를
넘겨받았을 때, `sfs dig` 가 코드에서 프로젝트 개요와 ERD 를 역추적합니다.
방향은 아래→위(코드→증거→합성)이고, L0(스캔·ERD)·L1(그래프·큐)은 LLM 없이
결정론으로 완결됩니다. 대상 코드는 절대 수정하지 않습니다 (read-only).

### 순서 (A→B→C→D→E)

1. **A. `sfs dig scan --write`** — 프레임워크/엔트리포인트/라우트/환경변수
   키/스키마 소스를 탐지하고 **ERD 를 먼저** 뽑습니다 (`erd.md`, mermaid +
   file:line 근거). 실 DB 를 볼 수 있으면 `information_schema` 를 TSV 로
   직접 덤프해 `--live-schema` 로 코드 추정과 diff — 접속 정보와 데이터
   로우는 어디에도 저장되지 않습니다.
2. **B. `sfs dig graph --write`** — import/라우트→서비스→테이블 그래프와
   L2 순회 큐(진입점 BFS, dead-code 후보 후순위)를 만듭니다.
3. **C. fact card** — 큐 항목별로 캡슐 위임해 모듈 카드를 작성합니다.
   근거(file:line) 없는 서술은 `sfs dig card validate` 가 기계적으로
   거부합니다 — 환각은 프롬프트가 아니라 검증기가 막습니다.
4. **D. 합성** — 카드가 쌓이면 기능 지도(feature-map)와 역-기획서
   (reverse-spec, 모든 추론 `#추정` 표기)를 만들고, 확신도 낮은 항목은
   `unknowns.md` — **외주사 질문 리스트** — 로 모읍니다. 인수인계 미팅에
   이것을 들고 갑니다.
5. **E. 확증** — 답을 얻거나 런타임 확인이 되면 카드가 unverified →
   corroborated → verified 로 올라갑니다 (`sfs dig status` 로 커버리지 확인).

### 첫날 30분 체크리스트

- [ ] `git clone` 후 저장소 루트에서 `sfs dig scan --write`
- [ ] `erd.md` 열어 테이블·FK 그림 확인 (DB 접근 가능하면 `--live-schema` diff)
- [ ] `sfs dig graph --write` → `l2-queue.md` 의 L2-GATE 상태 확인
      (Sanity 미비면 `--waive-sanity "<이유>"` 로 기록하고 진행)
- [ ] `00-scan.md` 의 라우트 표 = "이 시스템이 뭘 하는가" 첫 답
- [ ] unknowns 초안: scan/erd-diff 에서 바로 보이는 불일치 3개를 질문으로 적기

자세한 계약(카드 스키마·게이트·경계)은 routed context `commands/dig.md` 에
있습니다. 산출물이 안정되면 `sfs tidy --wiki-promote` 로 위키에 승격합니다.
