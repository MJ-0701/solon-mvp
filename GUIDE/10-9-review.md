---
doc_id: sfs-product-guide-ko-10
title: "9. Review - 산출물이 받아들일 만한지 확인하기"
visibility: oss-public
doc_type: user-guide
language: ko
updated: 2026-05-22
parent: GUIDE.md
summary: "9. Review - 산출물이 받아들일 만한지 확인하기"
load_when: "Read when GUIDE.md routes to this section."
---
## 9. Review - 산출물이 받아들일 만한지 확인하기

```bash
sfs review
```

`review` 는 항상 코드리뷰라는 뜻이 아닙니다. 코드 작업이면 코드리뷰가 맞고, 문서 작업이면 문서
검토, 전략 작업이면 전략 검토, 디자인 작업이면 디자인 검토가 됩니다.

GitHub 의 `@codex` PR/code review 는 외부 코드리뷰 evidence 일 뿐입니다. PR approval,
GitHub check PASS, `@codex` comment 가 있어도 `sfs review`, self-CPO, SFS cross review,
Gate 3/Gate 6 PASS 를 대체하지 않습니다.

외부 리뷰/check PASS 는 continuation trigger 이며, 멈추라는 신호가 아니라 다음 SFS review 단계로
이어가라는 신호입니다.
Codex, Claude, Gemini, 기타 LLM Agent 모두 self-CPO 를 먼저 실행하고, self-CPO PASS 뒤에
정해진 cross-review 순서로 넘어갑니다. 닫힌 sprint 라면 `.sfs-local/current-sprint` 를 손으로
복구하지 말고 `sfs review --sprint <id> --gate <n>` 를 사용합니다.

Solon 은 sprint evidence 와 변경 산출물을 보고 review lens 를 자동으로 고릅니다.

| Lens | 보는 것 |
|---|---|
| `code` | 동작, 테스트, 회귀, 유지보수성 |
| `docs` | 읽는 흐름, 정확성, 오래된 설명, 링크 |
| `source-docs` | 공식 문서/소스/버전 근거가 있는지 |
| `simplify` | 동작을 보존하면서 복잡도와 dead code 를 줄였는지 |
| `security` | auth, secret, PII, 입력 신뢰 경계 |
| `performance` | 측정 근거, baseline, target, 회귀 위험 |
| `api-contract` | public API, schema, error semantics, migration |
| `strategy` | 결정의 질, tradeoff, 실행 가능성 |
| `design` | 사용자 흐름, 일관성, 화면/상호작용 evidence |
| `taxonomy` | 용어, 분류, 이름 경계 |
| `qa` | 검증 범위, 재현성, 남은 위험 |
| `ops` | 배포, rollback, 운영 절차 |
| `management-admin` | 재무 기록, 경리, 세무/회계 질문, 현금 evidence |
| `release` | 버전, changelog, package, 배포 검증 |

대부분은 그냥 `sfs review` 라고 입력하면 됩니다. Solon 의 추론이 틀렸을 때만
`sfs review --lens docs` 처럼 직접 지정합니다.
`strategy-pm` 같은 본부 이름은 alias 로 받지만, 문서나 자동화에는 `strategy` 처럼 공개 lens 이름을 남깁니다.

review 결과가 partial/fail 이어도 모든 경우를 사용자에게 다시 묻지 않습니다. grep 범위 누락,
실측 명령 갱신, AC와 파일/산출물 매핑 누락, evidence 경로 오타, 의미가 바뀌지 않는 문서 일관성
같은 작은 결정론적 finding 은 agent 가 같은 cycle 안에서 patch 하고, 가장 작은 검증을 실행한 뒤,
같은 gate review 를 다시 호출해야 합니다. 사용자 판단이 필요한 경우는 범위, architecture,
public contract, 보안/개인정보/data-loss, 비용/지연/model policy, destructive action, AC 의미 변경처럼
제품 판단이 들어가는 경우입니다.

현재 `sfs review` 는 clean tree 에서도 직전 commit 의 reviewable 산출물을 evidence 로 싣습니다.
그래서 ADR 과 `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/report.md` 를 commit 한 뒤 Gate review 를
돌려도, review agent 가 "본문을 못 봤다"는 이유로 partial 을 내지 않도록 prompt 가 구성됩니다.

---

