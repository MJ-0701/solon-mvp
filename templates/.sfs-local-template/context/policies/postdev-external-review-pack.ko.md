---
id: sfs-policy-postdev-external-review-pack-ko
summary: 개발 완료 후 Claude/Gemini/Codex 외부 리뷰를 SFS gate 대체 없이 증거화한다.
load_when:
  - 개발 완료 리뷰
  - 외부 리뷰
  - Claude Cowork
  - Gemini review
  - Codex review
  - after implementation
language: ko
status: filled-v1
---

# Post-Development External Review Pack

구현 증거가 생긴 뒤에 사용한다. 목적은 reviewer 를 늘리는 것이 아니라, 독립
시야를 증거로 붙이되 review round 수를 PASS 기준으로 오해하지 않게 하는 것이다.

## Contract

- SFS gate 가 우선이다: self-CPO PASS, SFS cross review, 그 다음 외부 evidence.
- 외부 reviewer 는 GitHub `@codex`, Claude Code/Cowork, Gemini, future bridge
  다 가능하지만 이것만으로 SFS PASS 가 되지는 않는다.
- CLI bridge 가 인증되어 있으면 agent 가 직접 실행한다. Claude Cowork 가 UI-only
  또는 host-controlled 이면 compact review capsule 을 만들고
  `manual_host_review_pending` 으로 기록한다. user 에게 맥락 반복을 맡기지 않는다.
- Runtime Token Firewall 을 따른다: goal, AC/ADR, diff/files, tests, open risk
  만 보낸다. full chat, secret, raw env, broad log 는 보내지 않는다.
- 외부 PASS 는 continuation trigger 다. evidence 를 붙이고 다음 unmet SFS step 을
  실행한다. 결정적 finding 은 bounded micro-rework 로 들어간다.

## Preferred Order

1. Local verification + self-CPO PASS.
2. 가능한 독립 executor 로 SFS cross review.
3. Gemini `gemini-3.1-pro-preview`: 전략/보안/추론 폭이 필요한 review.
4. Claude Code/Cowork: 구현 가독성, UX/product fit, handoff review.
5. GitHub `@codex`: PR 위 최종 external PR/code-review evidence.

## PASS Shape

- 각 lane 은 `pass`, `partial`, `fail`, `blocked`, `not_applicable`,
  `manual_host_review_pending` 중 하나로 기록한다.
- Evidence 는 command, host, PR/comment URL, prompt capsule path, waiver 를
  구체적으로 남긴다.
- optional reviewer 부재가 아니라 실제 unresolved risk 만 release blocker 다.
