---
doc_id: sfs-current-product-shape-ko-12
title: "모델 라우팅과 책임 경계"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-22
parent: docs/ko/current-product-shape.md
summary: "모델 라우팅과 책임 경계"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## 모델 라우팅과 책임 경계

역할 분리는 모델 선택에도 적용됩니다. Plan 을 만드는 모델과 코드를 쓰는 worker 는 같은 책임을
지지 않습니다.

| 역할 | 책임 | 기본 모델 흐름 |
|---|---|---|
| Helper-grade intake | 단순 relay, 누락 인자 질문, 낮은 위험의 짧은 요약, 작은 read-only 보조 | Claude 는 Haiku 계열(코딩 금지), Codex 는 `gpt-5.4-mini` |
| Facilitator / question | brainstorm 질문 생성, 선택지 framing, 답변 요약 | Claude 는 Sonnet 4.6 계열, Codex 는 `gpt-5.4` |
| C-Level / review | 의도, architecture, AC, review, escalation | high reasoning. Codex 는 `gpt-5.5`, Claude 는 Opus 계열 |
| Claude worker | 고정된 files_scope 구현 slice | Sonnet 4.6 계열 |
| Codex worker | 고정된 files_scope 구현 slice 중 코드 판단이 남은 일반 작업 | `gpt-5.4` |
| Codex helper | 단순 relay, grep summary, formatting 같은 non-coding helper | `gpt-5.4-mini` |
| Codex coding helper | 좁은 repo-aware code 보조 작업 | `gpt-5.3-codex` |
| Codex mechanical implementation helper | 이미 결정된 무판단 단순 구현 보조 작업 | `gpt-5.3-codex-spark` |

이 라우팅은 기본값입니다. 사용자가 따로 설정하지 않아도 Solon recommended role routing 이
적용됩니다. `current_model` 은 역할 분리를 끄고 현재 선택 모델을 그대로 쓰려는 명시적 opt-out 입니다.
Helper-grade 단순 I/O 는 advisor 검토를 생략할 수 있습니다. 하위모델이 질문/선택지를 설계하거나
답변을 해석하거나 product identity, architecture, gate, AC, files_scope 에 영향을 주면 최상위
advisor 검토가 필수입니다. advisor 는 Claude Opus 4.7, Codex `gpt-5.5` xhigh,
Gemini `gemini-3-pro-auto` 입니다. Gemini 는 모든 role 을 `gemini-3-pro-auto` 로 두며
Flash/2.5 fallback 은 쓰지 않습니다.
advisor 호출은 self-CPO PASS 가 아닙니다. external/cross review 전에 작성자는 self-CPO
mini-check 로 요구사항 → AC → 구현 slice → ADR/decision id 추적, 각 AC 의 file/artifact/evidence
매핑, SEED/placeholder/mock/fallback non-acceptance 를 확인해야 합니다.

Codex 기준 일반 구현 worker 는 `gpt-5.4` 입니다. `gpt-5.3-codex` 는 일반 worker 기본값이 아니라
bounded repo-aware coding helper 입니다. Spark 는 더 좁습니다. scope, files_scope, AC, 정확한 수정
의도가 이미 잠겼고 판단이 필요 없는 file move, import/path rewrite, generated index sync,
deterministic test expectation update 같은 기계적 구현 보조 작업에만 씁니다. 작업이 architecture,
public contract, security, privacy, data-loss, release gate, 또는 반복 실패를 건드리면 worker 를
high reasoning 으로 승격하거나 C-Level 에 다시 넘깁니다. Claude 쪽 코딩 가능한 worker/helper 는
Sonnet 4.6이고, Haiku 는 코딩하지 않습니다. 실질 research 는 가능하면 Gemini 3 Pro auto researcher 로
보냅니다.

Implement 의 실행 모드는 기본적으로 Single Agent 입니다. 사용자가 여러 agent 를 선택할 수는
있지만, 그 경우 plan 은 먼저 독립 lane 으로 나뉘어야 합니다. 각 lane 은 files_scope 가 겹치지
않고 proposed commit message 를 한 문장으로 설명할 수 있어야 합니다. 이 기준을 만족하지 못하면
병렬화하지 않습니다. 병렬 agent 구현은 agent 간 cross review evidence 를 남긴 뒤
`sfs review --gate 6` 를 통과해야 하며, Single Agent 구현도 Gate 6 review 없이 완료로 보지
않습니다.

Gemini, Codex, Claude 같은 named executor review 는 full CPO prompt 를 만들기 전에 auth preflight 를
통과해야 합니다. 새 프로젝트나 새 터미널에서 처음 `sfs review --executor gemini` 를 실행했는데
인증이 없으면 review artifact 를 남기지 않고 멈춥니다. 이때 실제 터미널에서
`sfs auth login --executor gemini` 로 로그인하고 `sfs auth probe --executor gemini` 로 bridge 를
확인한 뒤 같은 review 명령을 다시 실행합니다. 수동 handoff 는 `--prompt-only` 로 분리합니다.

커밋 메시지는 사용자의 native 언어 또는 workspace 언어를 기본값으로 삼습니다. 한국어 사용자의
작업이면 `문서: native 언어 커밋 규칙 추가` 처럼 한국어로 바로 이해되는 메시지를 씁니다.
Solon 작업의 commit grouping 은 host-local `/commit` skill 이 아니라 `sfs commit` 이 담당합니다.
`sfs commit plan` 으로 그룹을 확인하고 `sfs commit apply --group <name>` 으로 선택 그룹을
commit + push 합니다. push 하면 안 되는 SFS release sandbox 나 offline 작업에서만 `--no-push` 를
씁니다.

