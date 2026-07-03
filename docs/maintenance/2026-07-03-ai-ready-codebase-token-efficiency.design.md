---
doc_id: ai-ready-codebase-token-efficiency-design
title: "Design — AI-ready codebase readiness + token/cache 효율 진화"
visibility: oss-public
doc_type: design-doc
language: ko
updated: 2026-07-03
summary: "외부 강의 레퍼런스(AI 레디 코드베이스·Graphify·PRIME·소프트웨어 과잉) 4건을 solon 제품에 회수하는 갭 분석. 캐시 프리픽스 규율, signal-only 코스트 게이트, Sanity→Cartography readiness 진단 확장 3건 제안 + 흡수 확인 2건."
load_when: "token-harness 정책 확장, harness doctor/map의 readiness·비용 지표 작업, 캐시/컨텍스트 규율 논의 시."
---

# Design — AI-ready codebase readiness + token/cache 효율 진화

- **status**: draft (design, pre-implementation — sprint 정식화 대기)
- **date**: 2026-07-03
- **target repo**: solon-product (distribution)
- **scope**: `templates/.sfs-local-template/context/policies/token-harness.md` 확장,
  `sfs harness doctor` / `sfs harness map` 지표 확장 제안
- **author**: Cowork 설계 초안 (사용자 검토 → sprint 정식화 대기)
- **근거 출처**: 사용자 idea_wiki 강의 노트 081~084 (인사이트 ID `L081-*`~`L084-*`).
  구체 수치(탐색 토큰 80%, SW:서비스 1:6, 10분 그래프 생성)는 전부 강연자 주장 —
  본 문서에서 사실로 쓰지 않고 측정 가설로만 취급한다.

---

## 1. 배경 / 갭 분석

강의 4건(AI 레디 코드베이스와 토큰 효율성, Graphify 지식 그래프, PRIME 프레임워크,
소프트웨어 과잉 시대 가치 이동)을 기존 solon 정책과 대조했다. 결론: **상당 부분은
이미 있고, 3개 갭이 남는다.**

이미 커버됨 (변경 불필요, 흡수 확인만):

- 컨텍스트 라우팅·얇은 어댑터·tool-surface budget·project-as-prompt·검증 자동화 →
  `policies/token-harness.md` 가 이미 SSoT.
- 착수 전 요구 복창 + 클래리파잉 질문 → `policies/work-delegation-and-startup.md`.
  PRIME 의 Interview 단계(L082-I3)와 동형 — 신규 도입 아니라 기존 정책의 외부 검증.
- eval-first / map-first → `docs/maintenance/methodology-7-step.md` + routed context.

갭 3건:

- **갭 A — 캐시 프리픽스 규율 부재.** token-harness 는 "무엇을 읽나/보내나"는 다루지만
  "어떤 순서로 고정하나"는 다루지 않는다. 프롬프트 캐시는 동일 프리픽스 전제라서
  세션 중간 어댑터 문서·모델 변경이 캐시 전체를 무효화한다는 규율(L081-I7·I8)이 없다.
- **갭 B — 비용 측정·게이트 부재.** `sfs harness doctor` 는 자율 실행 준비도를 보지만
  토큰·캐시 적중률·세션 비용을 지표로 다루지 않는다. 세션/PR 단위 코스트 신호
  (L081-I10)가 없어 "탐색이 토큰 대부분을 먹는다"(L081-I2·I3, 미검증)를 검증할 수단도 없다.
- **갭 C — AI-readiness(Sanity→Cartography) 진단 부재.** `sfs harness map --write` 는
  환경 지도를 기록하지만, 그 전제인 코드베이스 건강성(테스트 커버리지·데드코드·컨벤션
  일관성) 감사와 "Sanity 없이 지도만 그리면 거짓 정보"라는 순서 규율(L081-I4)이 없다.
  Graphify 계열 지식 그래프(L084)는 선택 모듈 후보.

## 2. 제안

### P1 (저위험, 문서만) — token-harness.md 에 "Cache-prefix discipline" 절 추가

- 고정 정보(어댑터 frontmatter·routed context 캡슐)는 앞, 휘발 정보(시각·상태)는 뒤.
- 세션 중간에 루트 어댑터 문서(CLAUDE.md 등)·모델 등급을 바꾸지 않는다 — 모델 선택은
  세션 시작 시 작업 성격으로 정하고 고정(L081-I9). 필요하면 새 세션.
- 장기 세션은 반복 컴팩트보다 종료·새 세션 + 상태 파일 인계(기존 session-transfer 정책과 결합).
- 무거운 탐색·검증은 스코프드 워커로 위임(기존 Runtime Token Firewall 절과 상호 참조).

### P2 (중위험, signal-only) — 코스트 게이트·토큰 지표

- `sfs harness doctor` 에 세션 로그 기반 지표 추가: 세션 토큰량, 캐시 적중률(로그가
  제공하는 런타임에 한해), 탐색성 read 대 편집 비율.
- 세션/PR 단위 임계치 초과 시 **신호만** — ALT-INV-3 (all signal-only, never-hard-block)
  준수. PR 라벨/report 경고로 표면화, 차단 없음.
- 도입 전후 지표로 "탐색 토큰 80%" 가설을 직접 측정 — 검증되면 마케팅 근거, 안 되면 폐기.
- 런타임 의존(세션 로그 포맷)이 커서 어댑터로 추상화: Claude Code 로그 파서 먼저, 나머지는 seam 만.

### P3 (중위험) — AI-readiness 진단: Sanity 감사 + 순서 규율

- `sfs harness doctor` 또는 신규 `sfs harness readiness` 로 Sanity 축 채점:
  테스트 커버리지 신호(에이전트 셀프 검증 가능성, L081-I5), 데드코드/미사용 파일 흔적,
  컨벤션 일관성(동일 패턴 복수 존재 여부), 엔트리 문서 신선도.
- 순서 규율 명문화: readiness 감사 통과(또는 waiver) 후에 `harness map`/카토그래피 산출 권장.
- 지식 그래프(Graphify 계열, L084)는 **외부 도구 포인터**로만 — 본체 흡수 대신
  `obsidian-llm-wiki` 정책과 같은 opt-in 패턴. 그래프 최신성(drift) 관리 비용이 미해결이라
  본체 의존을 만들지 않는다.

### 흡수 확인 (변경 없음)

- **PRIME(L082)**: Interview ≈ 기존 요구 복창+클래리파잉, Example(E)만 검토 — 워커 위임
  캡슐에 "참조 예시(exemplar)" 필드가 이미 있는지 확인, 없으면 P1 과 함께 한 줄 추가 후보.
- **소프트웨어 과잉(L083)**: 제품 포지셔닝 렌즈 — solon 은 '방법론 도구'가 아니라
  '품질 게이트를 통과한 결과'를 파는 프레임(L083-I4·I8). project-identity.md 논의 후보로만
  기록, 본 설계의 구현 범위 아님.

## 3. 비목표

- 본체가 특정 외부 그래프 도구(Graphify 등)에 의존하는 것.
- 코스트 게이트의 hard-block 화 (ALT-INV-3 위반).
- 루트 어댑터 문서에 본 정책 내용을 인라인하는 것 (frontmatter-only 유지,
  `test-agent-entry-doc-hygiene.sh` 준수).

## 4. 회귀 잠금 / 검증 계획

- P1: `md-line-budget` 준수 + 기존 token-harness 절과 중복 서술 금지(교차 참조만).
- P2: 로그 파서는 fixture 기반 단위 테스트, 지표는 신호 전용임을 테스트로 잠금.
- P3: readiness 채점은 결정론 스크립트(bash 호환 배포 원칙) + 채점 루브릭 문서화.
- 릴리스: VERSION semver + CHANGELOG 기록, Gate 6 리뷰 경유 (release-policy.md).

## 5. 다음 단계

1. 사용자 검토 → P1/P2/P3 우선순위 확정 (P1 은 단독 릴리스 가능한 최소 조각).
2. P1 부터 sprint 정식화 (7-step, eval-first: 캐시 무효화 시나리오 체크리스트가 eval).
3. P2·P3 은 Claude Code 세션 로그 포맷 조사 후 어댑터 seam 설계를 별도 문서로.
