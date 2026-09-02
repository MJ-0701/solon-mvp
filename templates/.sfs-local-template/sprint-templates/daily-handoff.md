---
phase: daily-handoff
date: YYYY-MM-DD
owner: OWNER_NAME
sprint: SPRINT_OR_WU_ID
status: on-track
---

# Daily Handoff

> 본문 내용은 사용자의 native/workspace 언어로 작성한다. 단 frontmatter key
> (`date` / `owner` / `sprint` / `status`) 와 `##` 섹션 제목 6개는 renderer
> 계약이므로 그대로 둔다. status 허용값: on-track | at-risk | blocked | done.
>
> 이 양식은 기본 `sfs retro` close 가 report/retro 증거로부터
> `docs/solon/<workspace>/<yyyyMMdd>/daily-handoff.md` 와 같은 위치의 HTML 을
> 자동 생성할 때의 형태다. 별도 생성 명령을 실행하지 않는다. HTML 은 파생
> 산출물 — 수정은 항상 이 MD 의 human-notes 블록에서. 흐름 문서:
> `context/commands/daily.md` 의 MANAGER_HANDOFF.

## Completed

<!-- 완료 작업. 형식 자유, 한 줄에 하나. 증거를 괄호로 같이 남긴다. -->
- WHAT_WAS_DONE (evidence: TEST_OR_COMMAND_RESULT)

## Decisions

<!-- ADR gate 해당 시에만 (durable decision + 대안 비교가 있었던 작업).
     형식: - <ADR-ID> | <path 또는 URL> | <one-line rationale>
     해당 없으면 bullet 없이 비워둔다 (렌더러가 "gate did not apply" 표기). -->
- ADR-0000 | .sfs-local/decisions/0000-example.md | WHY_THIS_CHOICE_WON

## Validation

<!-- 실행한 검증 명령/체크와 결과. -->
- COMMAND_OR_CHECK: RESULT

## Risks

<!-- 위험/블로커. 형식: - <risk> | owner: <name> | status: open|mitigating|closed -->
- RISK_OR_BLOCKER | owner: OWNER_NAME | status: open

## Next

<!-- 다음 액션. 형식: - <action> | owner: <name> | status: pending|in-progress -->
- NEXT_ACTION | owner: OWNER_NAME | status: pending

## Sources

<!-- 이 보고의 근거 원장: sprint log / report / PR / handoff 경로 또는 URL. -->
- .sfs-local/sprints/SPRINT_ID/log.md
