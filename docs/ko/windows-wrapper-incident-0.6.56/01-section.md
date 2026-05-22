---
doc_id: sfs-windows-wrapper-incident-0-6-56-ko-1
title: "한 줄 결론"
visibility: oss-public
doc_type: incident-report
language: ko
updated: 2026-05-22
parent: docs/ko/windows-wrapper-incident-0.6.56.md
summary: "한 줄 결론"
load_when: "Read when docs/ko/windows-wrapper-incident-0.6.56.md routes to this section."
---
## 한 줄 결론

Windows PowerShell/cmd 에서는 성공이 확인된 경로, 즉 `sfs.cmd -> sfs.ps1 -> native read-only/Bash runtime`
bridge 로 고정해야 했습니다. Git Bash/WSL 은 기존처럼 `sfs` 를 사용합니다. raw Git Bash `%*` 직행 경로와 batch label forwarding 경로는
sandbox, 인자 전달, UTF-8 출력, Scoop shim 에서 실패한 이력이 있으므로 기본 경로로 쓰지 않습니다.
Scoop self-upgrade 와 native read-only 명령은 교체될 수 있는 `sfs.cmd` batch 가 아니라
`sfs.ps1` 이 소유합니다. 0.6.49 부터 Scoop generated shim 도 그대로 신뢰하지 않고 post-install 이
shims 디렉터리의 `sfs.cmd`, `sfs.ps1`, extensionless `sfs` 를 덮어써 실제 사용자 진입점을 소유합니다.
0.6.50 에서는 hardened `sfs.cmd` shim 도 env bridge 만 믿지 않고 `%*` positional fallback 을 함께
전달합니다. 0.6.52 에서는 그 `%*` 꼬리도 `shift` 전에 `SFS_NATIVE_RAW_ARGS` 로 보존해
PowerShell 쪽 raw-arg fallback 으로 다시 읽습니다. 0.6.53 에서는 batch 가 가진 원본
명령행을 delayed expansion 으로 `SFS_NATIVE_CMDLINE` 에 저장해 child PowerShell 의
`CMDCMDLINE` 이 바뀌어도 원래 `sfs.cmd version` 꼬리를 복구합니다.
0.6.54 에서는 그 saved 변수도 비는 GitHub runner 경로를 위해 parent `cmd.exe`
command-line probe 를 마지막으로 추가했습니다. 이 fallback 은 parent command line 을 공백으로
먼저 자르지 않고 `sfs.cmd` 명령명 뒤의 꼬리부터 추출합니다. wrapper 경로 중간에 공백이 있을 수
있기 때문입니다.
0.6.55 후보에서는 0.6.54 의 parent fallback 까지 둔 상태에서도 최초 설치 직후
`sfs.cmd version` 이 usage-only 로 떨어진 GitHub runner 증거를 기준으로,
`SFS_NATIVE_RAW_ARGS` 꼬리를 `--%` 뒤에 붙이는 실험을 했습니다. 하지만 0.6.55 trace run
`25554923214` 는 batch 가 `version` 을 정상 수집했고, 문제는 `sfs.ps1` 의 여러 helper 가
PowerShell-sensitive `$Args` 파라미터명을 사용해 살아 있는 env bridge 인자를 함수 경계에서
empty/help 로 무너뜨린 데 있음을 보여줬습니다. 0.6.56 은 usable guard 를 `$Items`, native
dispatch/self-upgrade helper 를 `$InvocationArgs` 로 바꾸고, runner 에서
`--SFS_NATIVE_RAW_ARGS` 라는 잘못된 토큰을 만든 `--% %SFS_NATIVE_RAW_ARGS%` 실험을 제거합니다.
또한 `SFS_WINDOWS_ARG_TRACE=1` 진단 모드로 Windows smoke 실패 시 batch `%*`, child PowerShell
`$args`, env/raw/saved/parent source, 최종 선택 source 를 로그에서 바로 볼 수 있게 했습니다.
후속 trace run `25559894888` 에서는 `upgrade -> update` 재실행과 stale env 문제는 해결됐고,
Bash `upgrade.sh` 가 `maybe_prompt_model_profile after` 뒤 후반 훅에서 멈출 수 있음을 확인했습니다.
따라서 0.6.56 기준선은 `SFS_UPGRADE_TRACE=1` 후반 trace 를 더 촘촘히 넣고, `cli-discovery`
전체 훅과 내부 `claude`/`gemini`/`git clone` probe 를 timeout 으로 감싸 unbounded wait 를 금지합니다.
Windows PowerShell/cmd runtime script 는 BOM 없는 UTF-8 파서 오인을
피하도록 ASCII-safe 여야 합니다.

