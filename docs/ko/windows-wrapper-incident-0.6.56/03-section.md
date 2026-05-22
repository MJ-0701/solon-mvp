---
doc_id: sfs-windows-wrapper-incident-0-6-56-ko-3
title: "사용자가 본 증상"
visibility: oss-public
doc_type: incident-report
language: ko
updated: 2026-05-22
parent: docs/ko/windows-wrapper-incident-0.6.56.md
summary: "사용자가 본 증상"
load_when: "Read when docs/ko/windows-wrapper-incident-0.6.56.md routes to this section."
---
## 사용자가 본 증상

- agent sandbox 안에서 `sfs.cmd start "이미지 프롬프트 고도화"` 가 Git Bash 시작 전에
  `fatal error - couldn't create signal pipe, Win32 error 5` 로 실패했습니다.
- sandbox 밖 재시도는 종료 코드 0 이었지만 출력이 비어 있었습니다.
- `.sfs-local/current-sprint` 는 `2026-W19-sprint-1` 을 가리켰고 sprint 디렉터리도 생겼지만,
  사용자가 볼 수 있는 다음 안내가 없었습니다.
- `sfs.cmd status`, `sfs.cmd context cat kernel`, `sfs.cmd context path kernel` 이 실제 상태나
  컨텍스트 대신 generic usage/help 만 출력했습니다.
- `.sfs-local/events.jsonl` 의 `sprint_start` goal 이 한국어 깨짐으로 남았습니다.

