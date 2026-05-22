---
doc_id: sfs-windows-wrapper-incident-0-6-56-ko-9
title: "검증 증거"
visibility: oss-public
doc_type: incident-report
language: ko
updated: 2026-05-22
parent: docs/ko/windows-wrapper-incident-0.6.56.md
summary: "검증 증거"
load_when: "Read when docs/ko/windows-wrapper-incident-0.6.56.md routes to this section."
---
## 검증 증거

- `tests/test-windows-agent-adapter-fallback.sh` 는 Scoop manifest 가 `bin\sfs.ps1` 을 primary shim target 으로
  쓰는지, packaged `sfs.cmd` 가 call-label dispatch 없는 compatibility trampoline 인지, raw Git Bash `%*`
  를 쓰지 않는지 고정합니다. 또한 `sfs.cmd` 가 `call :...` 또는 `call scoop update` 를 직접 실행하지 않고
  `sfs.ps1` 이 native read-only 와 Scoop self-upgrade 를 소유하는지 확인합니다.
- Windows Scoop smoke 는 로컬 이전 패키지를 먼저 설치하고, 같은 로컬 bucket 에 현재 패키지를
  발행한 뒤 `sfs.cmd upgrade` 자체로 self-upgrade 를 실행합니다. 출력에서 `TIVE_READONLY_DONE`,
  `LF_UPGRADE_DONE`, `e`, `*` tail fragment 가 나오면 실패합니다.
- 같은 Windows smoke 는 실제 `v0.6.49` archive 를 설치해 `sfs.cmd version` usage-only 회귀를
  재현한 뒤, `scoop update` + `scoop update sfs` 직접 실행으로 현재 runtime 까지 복구되는지도 확인합니다.
- 같은 Windows smoke 는 `sfs.cmd start --id ci-korean-sprint-test --force "스프린트 생성 테스트"` 를
  실행하고 `.sfs-local/current-sprint` 와 `events.jsonl` 의 한국어 goal 을 확인합니다.
- 같은 Windows smoke 는 env/raw args 를 비운 saved-cmdline fallback 도 강제로 실행해
  `cmd.exe /d /c "sfs.cmd ... && sfs.cmd --help >NUL"` 명령행에서 `version`,
  `context cat kernel`, `start` 가 복구되는지 확인합니다.
- 같은 Windows smoke 는 임시 `sfs.cmd` probe wrapper 로 env/raw/saved command-line source 를
  모두 비운 뒤, parent `cmd.exe` command-line fallback 만으로 `version`, `context cat kernel`,
  `start` 가 복구되는지도 확인합니다.
- Windows smoke 는 설치 직후와 direct Scoop recovery 후 hardened `sfs.cmd` shim 이
  `SFS_NATIVE_RAW_ARGS` 를 보존하되 `--% %SFS_NATIVE_RAW_ARGS%` dispatch 를 쓰지 않는지도 확인합니다.
- Windows smoke 는 `SFS_WINDOWS_ARG_TRACE=1` 로 `SFS_ARGTRACE_CMD_ARGC`,
  `SFS_ARGTRACE_PS_SELECTED_SOURCE=env`, `SFS_ARGTRACE_PS_FINAL_ARGS=.*version` 을 확인한 뒤에야
  `sfs.cmd version` 을 통과로 봅니다.
- `tests/test-windows-wrapper-incident-report.sh` 는 이 보고서의 P1-P24 문제 요약, 0.6.56 문서 링크,
  Homebrew installed layout fallback 을 검증합니다.
- `tests/test-docs-model-routing.sh` 는 source layout 과 Homebrew installed layout 의 문서 위치를
  함께 검증합니다.
- 0.6.56 은 Windows `sfs.cmd upgrade` self-replacement 수정, 설치본 incident-report 테스트
  layout 보강, batch same-line exit, ASCII-only Windows script, `SFS_ORIGINAL_ARGS` 제거,
  call-label dispatch 제거, 단일 `-File ... %*` / `-Command @args` / empty `%1..%n` 실패 학습,
  numbered env arg bridge, `CMDCMDLINE` fallback, Scoop primary `bin\sfs.ps1` shim target,
  script param 제거, automatic `$args` primary path, Windows PowerShell/cmd `sfs.cmd` 계약 고정,
  generated `sfs.cmd` shim 실패 학습, post-install deterministic shim overwrite,
  delayed-expansion saved-cmdline bridge, parent `cmd.exe` command-line fallback,
  shell-control tail trimming, usable-args `$Items` root-cause fix,
  hardened shim env+positional dual forwarding, PowerShell tag-refspec braces smoke fix,
  shift-before-raw-arg-capture fix 까지
  포함한 최종 후속 기준선입니다.
