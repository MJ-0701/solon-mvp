---
doc_id: sfs-current-product-shape-ko-10
title: "Review 는 artifact acceptance review"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-25
parent: docs/ko/current-product-shape.md
summary: "Review 는 artifact acceptance review"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## Review 는 artifact acceptance review

`sfs review` 는 코드리뷰 하나가 아닙니다. 같은 명령어를 유지하되 Solon 이 sprint evidence 와
변경 artifact 를 보고 lens 를 자동 추론합니다.

GitHub 의 `@codex` PR/code review 는 외부 코드리뷰 evidence 일 뿐입니다. PR approval,
GitHub check PASS, `@codex` comment 가 있어도 `sfs review`, self-CPO, SFS cross review,
Gate 3/Gate 6 PASS 를 대체하지 않습니다.

외부 리뷰/check PASS 는 continuation trigger 이며 stopping point 가 아닙니다. Codex, Claude,
Gemini, 기타 LLM Agent 는 PASS 라고 말하고 끝내지 않고 다음 미충족 SFS review 명령을 이어갑니다:
self-CPO 먼저, self-CPO PASS 뒤에 설정된 cross-review 순서입니다.

Session Continuation Guard 는 긴 host 대화 자체를 다룹니다. `sfs upgrade` 가 최신이어도 이미 열린
Claude/Codex/Gemini conversation history 는 그대로 남아 token meter 를 태웁니다. 새 WU/sprint 의
첫 구현·review 전에 30% 이상, 새 gate/loop/cross-review 전 50% 이상, 또는 같은 chat 이 여러
WU/sprint·반복 wakeup 을 지나면 agent 는 `report.md`, `review.md`, capture id,
commit/branch/status, 정확한 next prompt 를 담은 durable transfer capsule 을 먼저 남깁니다.
그 다음 host 가 transfer/new-session/archive/clear+resume 제어를 지원하면 직접 호출해 fresh
session 에서 즉시 이어갑니다. 이 전환은 사용자에게 같은 세션/새 세션 선택을 묻는 질문이 아니라
autopilot 입니다. resume 없는 bare clear 는 금지이고, host 전환+재개 제어가 없으면 다음 세션용
정확한 prompt/command 만 남기고 멈춥니다. 사용자에게 `/clear` 입력을 요구하는 것은 SFS next
action 이 아니라 host capability gap 입니다.

| Lens | 주로 보는 것 |
|---|---|
| `code` | correctness, tests, regressions, maintainability |
| `docs` | reader flow, accuracy, stale claims, missing links |
| `source-docs` | official docs/source/version evidence |
| `simplify` | behavior-preserving simplification, dead-code removal |
| `security` | auth, secrets, PII, untrusted input boundaries |
| `performance` | baseline, target metric, measured regression risk |
| `api-contract` | public interface, schema, errors, compatibility |
| `strategy` | decision quality, tradeoffs, feasibility, next action |
| `design` | user flow, consistency, visual/interaction evidence |
| `taxonomy` | terms, categories, naming boundaries |
| `qa` | coverage, smoke evidence, reproduction, residual risk |
| `ops` | runbook, deployment, rollback, observability |
| `management-admin` | finance records, bookkeeping, tax/accounting questions, cash evidence |
| `release` | version, changelog, package channel, verification |

사용자는 계속 `sfs review` 라고만 말씀하시면 됩니다. 새 agent-skills류 판단 기준도 새 명령어가
아니라 기존 review lens 로 흡수됩니다. `--lens` 는 Solon 의 추론이 틀렸을 때만 쓰는 override
입니다.

review loop 는 작은 결정론적 finding 을 사용자에게 다시 넘기지 않고 같은 cycle 안에서 닫아야 합니다.
grep 범위 누락, 실측 evidence 갱신, AC와 파일/산출물 매핑 누락, evidence path 오타, 의미가
바뀌지 않는 문서 일관성 문제라면 agent 가 patch 하고 가장 작은 검증을 실행한 뒤 같은 gate review 를
다시 호출합니다. 사용자에게 묻는 경우는 범위, architecture, public contract, 보안/개인정보/data-loss,
비용/지연/model policy, destructive action, AC 의미 변경처럼 제품 판단이 필요한 경우입니다.

현재 `sfs review` 는 commit-aware 입니다. working tree 가 clean 이어도 직전 commit 의
reviewable 파일, 현재 공유 handoff 문서, 작은 ADR/report 본문을 bounded evidence 안에 포함하므로
commit 후 evidence prompt 가 비어서 partial 이 나는 상황을 막습니다.

이미 닫힌 sprint 의 review 를 다시 이어가야 할 때는 `.sfs-local/current-sprint` 를 손으로 복구하지
않고 `sfs review --sprint <id> --gate <n>` 를 사용합니다. SFS 는 최신 cold archive 를 workbench 로
복원하되, 이미 visible workbench 문서가 있으면 그것을 덮어쓰지 않습니다.
