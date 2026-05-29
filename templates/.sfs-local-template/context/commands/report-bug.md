---
id: sfs-command-report-bug
summary: File an SFS-product bug to the official GitHub Issues channel, then gate fix work on explicit user confirmation.
load_when: ["report-bug", "bug", "버그", "버그리포트", "버그 제보", "issue 등록", "report a bug", "sfs 버그"]
---

# Report Bug (SFS-product)

`sfs report-bug` 는 **SFS 제품 자체** 결함을 공식 채널에 제출하는 보고 primitive 다.
consumer 프로젝트 코드 버그가 아니라 SFS(kernel/commands/policies/CLI/model-profiles/
install·upgrade) 결함일 때만 쓴다. `report`(tidy/retro 산출 보고)와 다른 명령이다.

## 공식 채널
- GitHub Issues `MJ-0701/solon-product`, label `bug`. SFS 제품 버그의 유일한 공식 접수처.
- 메모/로컬 파일/구두 보고로 대체하지 않는다.

## 보고 절차
1. **분류**: SFS 제품 결함인지 consumer 코드 문제인지 먼저 가른다. consumer 문제면 보고 안 함.
2. **환경 수집**: `sfs version`, runtime(claude/codex/gemini), 해당 시 model-profiles version,
   consumer repo **이름만**. private docset 절대경로/파일명/내용 금지.
3. **dedup**: `gh issue list --repo MJ-0701/solon-product --label bug --search "<키워드>"`.
   중복이면 새 이슈 대신 코멘트.
4. **작성**: 템플릿(증상/실제 사례/근본 원인/제안/환경)으로 본문 구성. #3·#4 가 표준 예시.
5. **제출**: `gh issue create --repo MJ-0701/solon-product --label bug --title "[area] 한 줄" --body-file <tmp>`.
   gh 불가 환경(샌드박스 등)에서는 제출을 **dev runtime/host 로 인계** — 본문 manual-paste 떠넘김 금지.
6. **evidence**: consumer sprint 에 `sfs capture --kind evidence "Filed solon-product#<N>: <title>"` + URL 기록.
7. **confirm gate**: 이슈 URL + 1줄 요약을 사용자에게 제시하고 검토·확정 요청. 확정 전 fix 진입 금지.

## confirm gate
사용자 확정("ㄱㄱ/확인/맞아") → fix flow / "보완" → `gh issue edit` / 반려 → `gh issue close`.

## confirm 이후 (fix routing — `policies/bug-report-lifecycle.md` SSoT)
- 기본 = dev-first(R-D1): dev staging 수정 → release-cut sync → stable. ship release 에서 `Fixes #N` close.
- 예외 = critical stable hotfix: stable 발견 critical 만 stable 직접 + 같은 사이클 dev back-port.
- fix = 정규 lifecycle(plan→implement→review→Gate 6) + worker-tiering 기본 + #3 conflict-surface guard.

## 주의
- 이슈 1건 = 결함 1건. 묶음 금지.
- 충돌(project-local 정책 ↔ SFS default) 발견 시 진입 전 surface — silent 금지(#3, `policies/user-override-precedence.md`).
