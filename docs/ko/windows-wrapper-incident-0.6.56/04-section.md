---
doc_id: sfs-windows-wrapper-incident-0-6-56-ko-4
title: "실제 문제와 오해였던 부분"
visibility: oss-public
doc_type: incident-report
language: ko
updated: 2026-05-22
parent: docs/ko/windows-wrapper-incident-0.6.56.md
summary: "실제 문제와 오해였던 부분"
load_when: "Read when docs/ko/windows-wrapper-incident-0.6.56.md routes to this section."
---
## 실제 문제와 오해였던 부분

`sfs start` 이후 sprint 디렉터리가 비어 있는 것 자체는 버그가 아닙니다. `start` 는 sprint
workspace 와 pointer 를 만들고, `brainstorm`, `plan`, `review`, `retro` 문서는 각 단계에서
필요할 때 생성됩니다.

진짜 문제는 세 가지였습니다.

- 읽기 명령인 `status` / `context cat` 이 인자를 잃고 usage-only 로 퇴행했습니다.
- 상태 변경 명령인 `start` 가 빈 출력과 깨진 한국어 이벤트를 남길 수 있었습니다.
- agent 가 빈 출력/부분 생성 상태를 성공으로 오인할 수 있었습니다.

