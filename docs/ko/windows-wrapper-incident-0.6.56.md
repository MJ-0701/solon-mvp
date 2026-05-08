# Windows SFS 래퍼 장애 요약 보고서 (0.6.35 -> 0.6.56)

**Language**: 한국어 / [English](../en/windows-wrapper-incident-0.6.56.md)

이 문서는 Windows PC 에서 `$sfs start 이미지 프롬프트 고도화` 와 `sfs.cmd upgrade` 를 실행했을 때
드러난 `sfs.cmd` / `sfs.ps1` 래퍼 문제를 다음 세션과 다음 릴리스 검증자가 바로 이해하도록 남긴
요약 보고서입니다. 최종 기준선은 0.6.56 입니다.

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
Windows PowerShell/cmd runtime script 는 BOM 없는 UTF-8 파서 오인을
피하도록 ASCII-safe 여야 합니다.

## 최종 문제점 정리

| # | 문제 | 관찰된 증상 | 최종 조치 |
|---|---|---|---|
| P1 | Windows agent sandbox 가 Git Bash 생성을 막음 | `couldn't create signal pipe, Win32 error 5` | read-only recovery 는 `sfs.cmd status/version/context` native PowerShell 경로로 처리 |
| P2 | PowerShell `-File` 호출에서 script param 인자 손실 | `sfs.cmd status`, `sfs.cmd context cat kernel`, `sfs.cmd start ...` 이 usage 만 출력 | `sfs.ps1` 이 단일 인자 소스에 의존하지 않고 env bridge, positional args, `$args`, `$MyInvocation.UnboundArguments`, literal `-SfsArgs`, `--%` 를 정규화 |
| P3 | mutating command 가 raw Git Bash `%*` 로 새어 나감 | `start` 후 빈 출력, 한국어 goal mojibake 가능 | `sfs.cmd -> sfs.ps1 -> Bash runtime` bridge 로 고정 |
| P4 | partial success 를 성공으로 오인 | 종료 코드 0 이지만 다음 안내 없음, sprint pointer 만 생성 | empty output 은 성공 아님. `current-sprint`, sprint dir, `sfs.cmd status` 확인 |
| P5 | replaceable batch 가 self-upgrade 이후 계속 읽힘 | `TIVE_READONLY_DONE`, `LF_UPGRADE_DONE`, `e`, `*` 이 명령처럼 실행 | `sfs.cmd` 에서 Scoop update 제거, `sfs.ps1` 이 self-upgrade/reload 소유, batch 는 PowerShell 호출과 종료를 같은 parsed line 으로 고정 |
| P6 | 설치본 문서 layout 이 source 와 다름 | Homebrew installed test 가 `CHANGELOG.md` / `RELEASE-NOTES.md` 를 못 찾음 | tests 가 `libexec` 와 Cellar version root 둘 다 해석 |
| P7 | BOM 없는 UTF-8 PowerShell script 를 Windows PowerShell 5.1 이 legacy code page 로 파싱 | `install-cli-discovery.ps1` parser error: `Try statement is missing its Catch or Finally block` | Windows `.ps1` / `.cmd` runtime files 를 ASCII-only 로 고정하고 release guard 추가 |
| P8 | batch 가 `%*` 를 저장한 `SFS_ORIGINAL_ARGS` 를 PowerShell 로 전달 | Scoop shim 경로에서 `sfs version` 이 빈 인자로 떨어져 usage 만 출력 | call-label `%*` 를 `sfs.ps1` 에 직접 전달 |
| P9 | batch label forwarding 자체가 Scoop shim 에서 여전히 불안정 | 0.6.41 GitHub Windows Scoop smoke 에서 post-install 은 통과했지만 `sfs version` 이 다시 usage 로 떨어짐 | `sfs.cmd` 를 label 없는 thin PowerShell trampoline 으로 축소하고 native/read-only/upgrade 소유권을 `sfs.ps1` 로 이동 |
| P10 | `powershell.exe -File sfs.ps1 %*` 도 Scoop shim 아래에서 인자를 잃음 | 0.6.42 GitHub Windows Scoop smoke 에서 label 없는 `sfs.cmd` 였는데도 `sfs version` 이 usage 로 떨어짐 | 0.6.43 에서 `-Command "& $env:SFS_NATIVE_SCRIPT @args"` 를 시도했지만 실제 Windows smoke 에서 다시 실패해 P11 로 supersede |
| P11 | PowerShell `-Command @args` 도 Scoop shim 아래에서 인자를 전달하지 못함 | 0.6.43 GitHub Windows Scoop smoke run `25532139459` 에서 `sfs version` 이 또 usage-only 로 실패 | `sfs.cmd` 가 `%1..%n` 을 `SFS_NATIVE_ARGC` / `SFS_NATIVE_ARG_N` 환경 변수 배열로 저장하고, `sfs.ps1` 이 이 env bridge 를 첫 번째 인자 소스로 읽음 |
| P12 | `%1..%n` numbered env bridge 도 Scoop shim 아래에서 빈 인자로 시작될 수 있음 | 0.6.44 GitHub Windows Scoop smoke run `25532838102` 에서 `sfs version` 이 또 usage-only 로 실패 | env/param/`$args` 가 모두 비면 `sfs.ps1` 이 Windows `CMDCMDLINE` 원본 명령행에서 `sfs` / `sfs.cmd` 뒤의 명령 꼬리를 복구 |
| P13 | generated Scoop shim 이 packaged `bin\sfs.cmd` 를 target 으로 삼으면 원래 인자 꼬리를 끝까지 잃을 수 있음 | 0.6.45 GitHub Windows Scoop smoke run `25533332634` 에서 `CMDCMDLINE` fallback 이후에도 최초 `sfs version` 이 usage-only 로 실패 | Scoop manifest 의 primary shim target 을 `bin\sfs.ps1` 로 고정. packaged `sfs.cmd` 는 직접 실행/호환용 trampoline 으로 유지 |
| P14 | `ValueFromRemainingArguments` script param 이 generated Scoop PowerShell shim 에서도 인자를 못 받을 수 있음 | 0.6.46 GitHub Windows Scoop smoke run `25534566676` 에서 `Get-Command sfs` 는 `sfs.ps1` 로 바뀌었지만 `sfs version` 은 여전히 usage-only 로 실패 | packaged `sfs.ps1` 의 param block 을 제거하고 PowerShell 자동 `$args` 를 primary shim argument source 로 사용 |
| P15 | bare `sfs` generated shim 은 Windows PowerShell/cmd 계약으로 둘 수 없음 | 0.6.47 GitHub Windows Scoop smoke run `25535059980` 에서 `Get-Command sfs` 는 `sfs.ps1` 를 가리켰지만 `sfs version` 이 usage-only 로 실패 | Windows PowerShell/cmd smoke 와 사용자 안내를 `sfs.cmd` 로 고정. Git Bash/WSL smoke 만 bare `sfs` 를 검증 |
| P16 | generated `sfs.cmd` shim 도 `bin\sfs.ps1` target 으로 인자를 전달하지 못할 수 있음 | 0.6.48 GitHub Windows Scoop smoke run `25539387684` 에서 `sfs.cmd version` 이 여전히 generic usage 를 출력 | post-install hook 이 shims 디렉터리의 `sfs.cmd`, `sfs.ps1`, extensionless `sfs` 를 deterministic wrapper 로 덮어써 사용자 경로를 직접 소유 |
| P17 | hardened `sfs.cmd` shim 의 env-only 전달도 GitHub runner 에서 인자를 못 살릴 수 있음 | 0.6.49 GitHub Windows Scoop smoke run `25541086874` 에서 post-install hardening 은 실행됐지만 `sfs.cmd version` 이 다시 generic usage 를 출력 | hardened `sfs.cmd` shim 이 numbered env bridge 와 `%*` positional fallback 을 동시에 `sfs.ps1` 에 전달 |
| P18 | Git refspec 문자열의 `$brokenVersion:` 를 PowerShell 이 scoped-variable 문법처럼 해석할 수 있음 | 0.6.50 GitHub Windows Scoop smoke run `25542777986` 이 설치 전 `refs/tags/v/tags/v0.6.49` 를 fetch 하려다 실패 | tag fetch/archive ref 에 `${brokenVersion}` braces 를 사용 |
| P19 | `shift` 로 인자를 수집한 뒤 `%*` positional fallback 이 비어질 수 있음 | 0.6.51 GitHub Windows Scoop smoke run `25543802195` 에서 설치 직후 hardened `sfs.cmd version` 이 다시 usage-only 로 실패 | `sfs.cmd` 가 원본 `%*` 를 `SFS_NATIVE_RAW_ARGS` 로 shift 전에 저장하고, `sfs.ps1` 이 raw arg fallback 을 env bridge 다음에 읽으며 비어 있는 resolved arg 배열은 unusable 로 처리 |
| P20 | child PowerShell 의 `CMDCMDLINE` 은 wrapper 호출 원문이 아니라 `powershell.exe -File ...` 로 바뀔 수 있음 | 0.6.52 GitHub Windows Scoop smoke run `25545120029` 에서 shim 이 `SFS_NATIVE_RAW_ARGS` 를 갖고도 `sfs.cmd version` 이 다시 usage-only 로 실패 | `sfs.cmd` 가 delayed-expansion dispatch block 안에서 `!CMDCMDLINE!` 을 `SFS_NATIVE_CMDLINE` 으로 저장하고, `sfs.ps1` 이 raw arg fallback 다음에 이 saved cmdline 을 파싱하며 `cmd.exe` shell-control tail 을 자름 |
| P21 | delayed expansion 도 GitHub runner 에서 wrapper 명령행을 복구하지 못할 수 있음 | 0.6.53 GitHub Windows Scoop smoke run `25546859759` 에서 최초 `sfs.cmd version` 이 여전히 usage-only 로 실패 | env/raw/saved command line 이 모두 비면 `sfs.ps1` 이 `Win32_Process` 로 parent `cmd.exe` command line 을 조회하고, 공백 split 전에 `sfs.cmd` 명령명 뒤의 꼬리를 추출해 child `CMDCMDLINE` 전에 파싱 |
| P22 | fallback source 를 여러 개 둬도 child PowerShell 이 실제 argv 없이 시작될 수 있음 | 0.6.54 GitHub Windows Scoop smoke run `25548381094` 에서 post-install hardening 은 보였지만 최초 `sfs.cmd version` 이 다시 usage-only 로 실패 | 0.6.55 후보에서 `--% %SFS_NATIVE_RAW_ARGS%` 실험을 추가했지만 P23 trace 에서 supersede |
| P23 | PowerShell-sensitive `$Args` 파라미터명이 살아 있는 env bridge 를 함수 경계에서 empty/help 로 무너뜨림 | 0.6.55 trace run `25554923214` 에서 `CMD_FIRST=version`, `PS_ENV_ARGS=version` 이 보였지만 처음에는 `PS_SELECTED_SOURCE=empty`, 이후에는 `PS_SELECTED_SOURCE=env`, `PS_FINAL_ARGS=version` 뒤에도 native dispatch 가 usage 를 출력 | usable guard 는 `$Items`, native dispatch/self-upgrade helper 는 `$InvocationArgs` 로 변경하고, `--% %SFS_NATIVE_RAW_ARGS%` dispatch 제거. Windows smoke 는 `SFS_ARGTRACE_PS_SELECTED_SOURCE=env` 와 `SFS_ARGTRACE_PS_FINAL_ARGS=.*version` 을 요구 |
| P24 | Windows CI self-upgrade smoke 가 실제 runtime 버그가 아니라 interactive upgrade prompt 에서 멈출 수 있고, live trace 도 assignment 에 잡혀 보이지 않을 수 있음 | 0.6.56 trace run `25557503623` 이 `Smoke thin project in PowerShell` 에서 진행되지 않았고, `Tee-Object` pipeline 이 `$upgradeLines =` assignment 에 잡혀 `SFS_ARGTRACE_*` 가 Actions 로그에 즉시 나오지 않았습니다. 다음 trace 에서는 `sfs.cmd upgrade --yes` 가 Bash runtime 까지 전달되어 `unknown arg: --yes` 를 만든 것도 확인했습니다 | CI 에서는 `/dev/tty` 재연결을 금지하고, smoke 는 사용자-facing `sfs.cmd upgrade` 를 그대로 검증. `Tee-Object` 는 assignment 없이 직접 stream 하고, self-upgrade reload 는 Scoop `current\bin\sfs.ps1` 로 재해석하며 `upgrade` 를 canonical `update` 로 치환하고 `PS_RELOAD_SCRIPT` 를 trace |

## 사용자가 본 증상

- agent sandbox 안에서 `sfs.cmd start "이미지 프롬프트 고도화"` 가 Git Bash 시작 전에
  `fatal error - couldn't create signal pipe, Win32 error 5` 로 실패했습니다.
- sandbox 밖 재시도는 종료 코드 0 이었지만 출력이 비어 있었습니다.
- `.sfs-local/current-sprint` 는 `2026-W19-sprint-1` 을 가리켰고 sprint 디렉터리도 생겼지만,
  사용자가 볼 수 있는 다음 안내가 없었습니다.
- `sfs.cmd status`, `sfs.cmd context cat kernel`, `sfs.cmd context path kernel` 이 실제 상태나
  컨텍스트 대신 generic usage/help 만 출력했습니다.
- `.sfs-local/events.jsonl` 의 `sprint_start` goal 이 한국어 깨짐으로 남았습니다.

## 실제 문제와 오해였던 부분

`sfs start` 이후 sprint 디렉터리가 비어 있는 것 자체는 버그가 아닙니다. `start` 는 sprint
workspace 와 pointer 를 만들고, `brainstorm`, `plan`, `review`, `retro` 문서는 각 단계에서
필요할 때 생성됩니다.

진짜 문제는 세 가지였습니다.

- 읽기 명령인 `status` / `context cat` 이 인자를 잃고 usage-only 로 퇴행했습니다.
- 상태 변경 명령인 `start` 가 빈 출력과 깨진 한국어 이벤트를 남길 수 있었습니다.
- agent 가 빈 출력/부분 생성 상태를 성공으로 오인할 수 있었습니다.

## 원인

1. `bin/sfs.ps1` 의 `ValueFromRemainingArguments` script param 이 실제 Windows PowerShell 5.1
   `powershell.exe -File ...` 호출 모양에서 위치 인자를 안정적으로 받지 못했습니다. 그래서 실제
   명령이 빠지고 help 경로로 떨어졌습니다.
2. `bin/sfs.cmd` 가 mutating command 를 raw Git Bash `%*` 로 직접 넘기는 경로를 유지하고
   있었습니다. 이 경로는 Windows host 의 인자 quoting 과 Unicode 전달에 취약했습니다.
3. Windows agent sandbox 는 Git Bash 프로세스 생성 자체를 막을 수 있습니다. 따라서 `status`,
   `version`, `context cat/path` 같은 read-only recovery 명령은 Git Bash 없이 PowerShell native
   경로로 먼저 처리되어야 합니다.
4. 후속 검증 중 Homebrew 설치본에서는 `CHANGELOG.md` 가 `libexec/` 안이 아니라 Cellar 버전 루트에
   있다는 별도 문서 테스트 layout 문제도 발견됐습니다.
5. 0.6.36 Scoop 설치본에서 `sfs.cmd upgrade` 를 PowerShell/cmd 로 실행하면, `scoop update sfs` 가
   현재 실행 중인 `current\bin\sfs.cmd` 를 교체한 뒤 같은 batch 파일이 계속 실행되며 command
   offset 이 어긋날 수 있었습니다. 그 결과 `SFS_NATIVE_READONLY_DONE`,
   `SFS_SELF_UPGRADE_DONE` 같은 플래그 이름의 꼬리(`TIVE_READONLY_DONE`, `LF_UPGRADE_DONE`)가
   명령처럼 실행됐습니다.
6. 0.6.38 에서도 0.6.36 에서 0.6.38 로 올라오는 실행 주체는 여전히 old `sfs.cmd` 였기 때문에,
   설치 성공 뒤 `e`, `*` 같은 더 짧은 tail fragment 가 1회 더 나타날 수 있었습니다. 이는
   `sfs.ps1` 로 self-upgrade 소유권을 옮기는 것만으로는 부족하고, batch 가 PowerShell 호출 뒤
   다음 줄을 읽지 않도록 같은 parsed line 에서 종료해야 한다는 신호였습니다.
7. 0.6.40 의 `install-cli-discovery.ps1` 는 논리상 `catch` 를 갖고 있었지만, 파일이 BOM 없는
   UTF-8 이고 문자열에 non-ASCII dash/arrow 가 있어 Windows PowerShell 5.1 / Scoop post-install
   경로에서 legacy code page 로 깨져 parser 가 따옴표/블록을 잘못 읽을 수 있었습니다.
8. `sfs.cmd` 가 top-level `%*` 를 `SFS_ORIGINAL_ARGS` 로 캐시해 다시 전달하는 방식은 실제 Scoop
   shim 호출에서 비어 보일 수 있었습니다. `sfs.cmd` 의 call-label 이 받은 `%*` 를 직접 넘기는 쪽이
   실제 Windows 경로와 맞습니다.
9. 0.6.41 에서 parser 문제와 `SFS_ORIGINAL_ARGS` 문제를 제거한 뒤에도 GitHub Windows Scoop smoke 는
   `sfs version` usage-only 로 실패했습니다. 이로써 batch label forwarding 자체가 Scoop shim
   아래에서 충분히 안정적이지 않다는 결론이 났습니다.
10. 0.6.42 에서 batch label 을 제거했는데도 GitHub Windows Scoop smoke 는 다시 `sfs version`
    usage-only 로 실패했습니다. 남은 경로는 `powershell.exe -File sfs.ps1 %*` 였으므로, 0.6.43 에서
    PowerShell `-Command` 의 `@args` 전달을 시도했습니다.
11. 0.6.43 의 `-Command @args` bridge 도 GitHub Windows Scoop smoke run `25532139459` 에서
    다시 usage-only 로 실패했습니다. 따라서 Windows/Scoop path 에서는 PowerShell CLI argument
    binding 자체를 신뢰하지 않고, batch 가 numbered env arg bridge 를 만들고 `sfs.ps1` 이 이를
    직접 읽는 방식으로 고정해야 합니다.
12. 0.6.44 의 numbered env arg bridge 도 GitHub Windows Scoop smoke run `25532838102` 에서
    다시 usage-only 로 실패했습니다. 이는 generated Scoop shim 아래에서 target `sfs.cmd` 의 `%1..%n`
    자체가 비어 시작될 수 있다는 신호입니다. 마지막 Windows-native fallback 은 `CMDCMDLINE` 에 남은
    원본 명령행에서 `sfs` / `sfs.cmd` 뒤의 tail 을 복구하는 것입니다.
13. 0.6.45 의 `CMDCMDLINE` fallback 도 GitHub Windows Scoop smoke run `25533332634` 에서
    최초 `sfs version` 단계의 usage-only 실패를 막지 못했습니다. 이는 Scoop generated shim 이
    packaged `bin\sfs.cmd` 를 target 으로 삼는 구조 자체가 인자를 잃는 경로였다는 증거입니다.
    따라서 Scoop primary shim target 은 PowerShell script 인 `bin\sfs.ps1` 이어야 합니다.
14. 0.6.46 의 Scoop `bin\sfs.ps1` primary target 은 GitHub Windows Scoop smoke run `25534566676`
    에서 실제로 적용됐습니다. `Get-Command sfs` 가 `ExternalScript ...\sfs.ps1` 를 가리켰지만,
    `ValueFromRemainingArguments` param 이 여전히 인자를 받지 못해 `sfs version` 이 usage-only 로
    실패했습니다. 따라서 packaged `sfs.ps1` 은 param block 없이 PowerShell 자동 `$args` 를 읽어야 합니다.
15. 0.6.47 의 param-block 제거 뒤에도 GitHub Windows Scoop smoke run `25535059980` 에서 bare
    `sfs version` 은 usage-only 로 실패했습니다. 이 경로는 사용자가 PowerShell/cmd 에서 실제로
    입력해야 하는 `sfs.cmd ...` 계약과 다릅니다. 따라서 Windows PowerShell/cmd 의 pass 조건은
    `sfs.cmd version`, `sfs.cmd status`, `sfs.cmd context cat ...`, `sfs.cmd start ...`,
    `sfs.cmd upgrade` 로 고정하고, bare `sfs` 는 Git Bash/WSL 경로에서만 검증합니다.
16. 0.6.48 의 `sfs.cmd` 고정 뒤에도 GitHub Windows Scoop smoke run `25539387684` 에서
    `Get-Command sfs.cmd` 는 `...\scoop\shims\sfs.cmd` 를 가리켰고, `sfs.cmd version` 이 다시
    generic usage 로 떨어졌습니다. 이는 Scoop generated `sfs.cmd` shim 이 `bin\sfs.ps1` 을 target
    으로 삼는 경우에도 인자 꼬리를 버릴 수 있다는 증거입니다. 따라서 post-install hook 이
    generated shim 을 그대로 믿지 않고 shims 디렉터리의 `sfs.cmd`, `sfs.ps1`, extensionless `sfs` 를
    Solon 이 소유한 deterministic wrapper 로 덮어써야 합니다.
17. 0.6.49 의 post-install shim hardening 뒤에도 GitHub Windows Scoop smoke run `25541086874` 에서
    `Scoop shims hardened` 로그는 찍혔지만 `sfs.cmd version` 이 usage 로 떨어졌습니다. 이는 hardened
    `sfs.cmd` shim 의 numbered env bridge 만으로는 GitHub runner 의 `sfs.cmd` 호출 인자를 끝까지
    살리지 못할 수 있다는 증거입니다. 따라서 hardened shim 은 env bridge 와 `%*` positional fallback 을
    동시에 전달해야 합니다.
18. 0.6.50 Windows smoke run `25542777986` 은 설치 전에 실패했습니다. Git fetch refspec 안의
    `$brokenVersion:` 를 PowerShell 이 scoped-variable 문법처럼 해석해
    `refs/tags/v/tags/v0.6.49` 를 fetch 하려 했기 때문입니다. 변수 바로 뒤에 `:` 가 오면
    `${brokenVersion}` 처럼 braces 를 써야 합니다.
19. 0.6.51 Windows smoke run `25543802195` 는 설치 직후 실패했습니다. post-install 이 hardened
    `sfs.cmd` shim 을 썼고 shim text 에 `SFS_NATIVE_ARGC` 와 `%*` 도 있었지만, 인자 수집 루프가
    `shift` 로 `%1..%n` 을 모두 소비한 뒤 PowerShell 을 호출하면서 `sfs.cmd version` 이 다시
    usage-only 로 떨어졌습니다. 따라서 `%*` 꼬리는 수집 루프 전에 별도 env 값으로 보존해야 합니다.

## 적용된 수정

- `sfs.cmd` 는 call-label dispatch 없는 thin PowerShell trampoline 입니다. 받은 인자를 numbered env bridge 로
  저장한 뒤 packaged `sfs.ps1` 을 호출하고 같은 parsed line 에서 종료합니다.
- native read-only dispatch 는 `sfs.ps1` 이 먼저 처리하고, 나머지 명령도 같은 `sfs.ps1` bridge 를
  거쳐 Bash runtime 으로 내려갑니다.
- `sfs.cmd` 는 mutating command 를 raw Git Bash `%*` 로 보내지 않습니다.
- `sfs.ps1` 은 script param 에 의존하지 않습니다. numbered env bridge, PowerShell 자동
  `$args`, `CMDCMDLINE`, `$MyInvocation.UnboundArguments`, nested array, accidental
  literal `-SfsArgs`, `--%` 모양을 같은 인자 목록으로 정규화합니다.
- `sfs.ps1` 은 가능한 경우 UTF-8 console/native-command encoding 과 `LANG=C.UTF-8`,
  `LC_CTYPE=C.UTF-8` 을 맞춥니다.
- Windows guard test 는 실제 Windows host 에서 가능하면
  `powershell.exe -File sfs.ps1 context cat kernel` 과 `status` 를 실행해 usage-only 회귀를 잡습니다.
- 0.6.36 에서는 Homebrew installed layout 도 이해하도록 문서 테스트의 `CHANGELOG.md` /
  `RELEASE-NOTES.md` 위치 해석을 보강했습니다.
- 0.6.37 에서는 `sfs.cmd` 가 Scoop self-upgrade 를 직접 실행하지 않습니다. batch wrapper 는
  native read-only 판단 뒤 `sfs.ps1` 로 넘기고, `sfs.ps1` 이 메모리 실행 상태에서
  `scoop update` / `scoop update sfs` / 새 런타임 재호출을 맡습니다.
- 0.6.38 에서는 새 `test-windows-wrapper-incident-report.sh` 도 Homebrew installed layout 을
  이해하도록 보강해 설치본 검증에서 같은 layout 오인을 반복하지 않게 했습니다.
- 0.6.40 에서는 `sfs.cmd` 의 non-native PowerShell dispatch 를
  `call :powershell_dispatch %* & exit /b !ERRORLEVEL!` 로 고정하고, 실제
  `powershell.exe -File sfs.ps1 ...` 호출도 같은 parsed line 에서 `exit /b !ERRORLEVEL!` 하도록 바꿨습니다.
  따라서 self-upgrade 중 batch 파일이 교체되어도 PowerShell 반환 뒤 새 파일의 임의 줄을 다시
  읽지 않습니다.
- 0.6.41 에서는 Windows runtime `.ps1` / `.cmd` 파일을 ASCII-only 로 고정해 Windows PowerShell
  5.1 의 BOM-less UTF-8 파서 오인을 막았습니다. 또한 `sfs.cmd` 는 `SFS_ORIGINAL_ARGS` 를 쓰지 않고
  call-label `%*` 를 `sfs.ps1` 에 직접 전달합니다.
- 0.6.42 에서는 0.6.41 GitHub Windows Scoop smoke 의 usage-only 잔여 실패를 근거로 `sfs.cmd`
  안의 batch label dispatch 를 제거했습니다. `sfs.cmd` 는 PowerShell trampoline 만 맡고,
  `sfs.ps1` 이 `version`, `status`, `guide`, `context`, Scoop self-upgrade, Bash fallback 을 모두
  소유합니다.
- 0.6.43 에서는 0.6.42 GitHub Windows Scoop smoke 의 추가 실패를 근거로 `sfs.cmd` 의 PowerShell
  호출을 `-File` 에서 `-Command "& $env:SFS_NATIVE_SCRIPT @args"` 로 바꿨습니다. 이 경로는 실제
  0.6.43 Windows smoke 에서 다시 usage-only 로 실패했으므로 0.6.45 에서 supersede 했습니다.
- 0.6.44 에서는 PowerShell CLI argument binding 에 의존하지 않습니다. `sfs.cmd` 는 `%1..%n` 을
  `SFS_NATIVE_ARGC` / `SFS_NATIVE_ARG_N` 환경 변수 배열로 저장한 뒤 인자 없이
  `powershell.exe -File "%SFS_NATIVE_SCRIPT%"` 를 호출합니다. `sfs.ps1` 은 이 env bridge 를 가장
  먼저 읽고, 그 다음 positional param, `$args`, `$MyInvocation.UnboundArguments` 를 fallback 으로
  정규화합니다.
- 0.6.45 에서는 0.6.44 Windows smoke 의 추가 실패를 근거로 `CMDCMDLINE` fallback 을 더했습니다.
  env bridge, positional param, `$args` 가 모두 비면 `sfs.ps1` 이 원본 Windows command line 을
  파싱해 `sfs` / `sfs.cmd` 뒤의 명령 꼬리를 복구합니다.
- 0.6.46 에서는 0.6.45 Windows smoke 의 추가 실패를 근거로 Scoop manifest 의 primary `bin`
  target 을 `bin\sfs.cmd` 에서 `bin\sfs.ps1` 로 바꿨습니다. Scoop generated PowerShell shim 이
  `sfs.ps1` 을 직접 호출합니다. 이 경로는 0.6.46 Windows smoke 에서 적용됐지만 script param
  binding 이 다시 실패해 0.6.47 에서 supersede 했습니다.
- 0.6.47 에서는 packaged `sfs.ps1` 의 param block 을 제거했습니다. `sfs.ps1` 은 numbered env bridge,
  PowerShell 자동 `$args`, `CMDCMDLINE`, `$MyInvocation.UnboundArguments` 를 같은 인자 목록으로
  정규화합니다.
- 0.6.48 에서는 Windows PowerShell/cmd 의 smoke 와 사용자 안내를 `sfs.cmd` 로 고정했습니다.
  bare `sfs` generated shim 은 Windows PowerShell/cmd 계약이 아니라 Git Bash/WSL 계약으로만 봅니다.
- 0.6.49 에서는 Scoop post-install hook 이 shims 디렉터리의 `sfs.cmd`, `sfs.ps1`, extensionless
  `sfs` 를 deterministic wrapper 로 덮어씁니다. `sfs.cmd` shim 은 `%1..%n` 을 numbered env bridge
  로 저장하고 packaged `sfs.ps1` 을 같은 parsed line 에서 호출/종료합니다. `sfs.ps1` shim 은
  PowerShell `$args` 를 target 에 넘기고, extensionless `sfs` shim 은 Git Bash 에서 packaged
  `bin/sfs` 를 실행합니다.
- 0.6.50 에서는 hardened `sfs.cmd` shim 이 numbered env bridge 를 유지하면서도
  `powershell.exe -File "%SFS_NATIVE_SCRIPT%" %*` 로 positional fallback 을 같이 넘깁니다. 같은
  Windows smoke 는 설치 직후 shim 파일에 `SFS_NATIVE_ARGC` 와 `%*` 가 모두 있는지도 확인합니다.
- 0.6.51 에서는 알려진 깨진 패키지를 가져오는 tag refspec 을
  `refs/tags/v${brokenVersion}:refs/tags/v${brokenVersion}` 로 감싸 PowerShell 이 Git 에 전달하기
  전에 문자열을 바꾸지 못하게 했습니다.
- 0.6.52 에서는 `sfs.cmd` 와 post-install hardened `sfs.cmd` shim 이 `shift` 전에 원본 `%*` 를
  `SFS_NATIVE_RAW_ARGS` 로 저장합니다. `sfs.ps1` 은 numbered env bridge 다음에 이 raw arg tail 을
  읽고, 비어 있는 resolved arg 배열은 unusable 로 취급해 `CMDCMDLINE` 으로도 내려갈 수 있게 합니다.
- 0.6.53 에서는 `sfs.cmd` 와 post-install hardened `sfs.cmd` shim 이 PowerShell 실행 전
  delayed expansion 으로 원본 명령행을 `SFS_NATIVE_CMDLINE` 에 저장합니다. `sfs.ps1` 은 raw
  arg tail 다음에 이 saved cmdline 을 읽고, `&& sfs.cmd --help` 같은 `cmd.exe`
  shell-control tail 을 자른 뒤, 그래도 비면 child PowerShell 의 `CMDCMDLINE` fallback 으로 내려갑니다.
- 0.6.54 에서는 0.6.53 GitHub runner 가 여전히 usage-only 를 낸 것을 근거로 parent-process
  command-line fallback 을 추가합니다. env/raw/saved command-line source 가 모두 비면
  `sfs.ps1` 이 parent `cmd.exe` 의 `Win32_Process.CommandLine` 을 읽어 원래 `sfs.cmd ...`
  꼬리를 공백 split 전에 추출합니다. 그래서 wrapper 경로 중간에 공백이 있어도 가짜 인자로
  쪼개지지 않습니다. 그래도 비면 child PowerShell 의 `CMDCMDLINE` fallback 으로 내려갑니다.
- 0.6.55 후보에서는 0.6.54 GitHub runner 가 여전히 usage-only 를 낸 것을 근거로 `sfs.cmd` 의
  PowerShell 호출 자체에도 saved raw tail 을 직접 싣는 실험을 했습니다. trace run `25554923214`
  에서 이 경로는 `--SFS_NATIVE_RAW_ARGS` 라는 잘못된 토큰을 만들었고, 동시에 numbered env bridge
  에는 `version` 이 살아 있음을 보여줘 0.6.56 의 P23 root-cause fix 로 supersede 됐습니다.
- 0.6.56 에서는 `Test-SfsUsableArgs([string[]] $Args)` 를
  `Test-SfsUsableArgs([string[]] $Items)` 로, native dispatch/self-upgrade helper 의 `$Args`
  파라미터를 `$InvocationArgs` 로 바꿔 살아 있는 env bridge 를 정상 command 로 끝까지
  인정합니다. Windows smoke 는 `SFS_ARGTRACE_PS_SELECTED_SOURCE=env` 와
  `SFS_ARGTRACE_PS_FINAL_ARGS=.*version` 을 요구합니다.

## 발견된 문제점

- 실패한 경로와 성공한 경로가 명확하면 Windows wrapper 는 성공한 경로로 고정해야 합니다.
  `sfs.cmd` 의 mutating command 기본값은 PowerShell bridge 입니다.
- 종료 코드 0 과 빈 출력만으로 adapter 성공을 판정하면 안 됩니다. `start` 후에는
  `.sfs-local/current-sprint`, sprint 디렉터리, `sfs.cmd status` 를 함께 확인해야 합니다.
- `context cat` 이 usage 를 출력하는 것은 도움말이 아니라 회귀 신호입니다.
- 한국어 goal 이 events 에 깨져 남으면 UTF-8 bridge 또는 raw Bash 경로 누출을 의심해야 합니다.
- 패키지 설치본은 source layout 과 다를 수 있습니다. Homebrew 는 runtime 을 `libexec/` 에 두고,
  일부 문서는 Cellar 버전 루트에 둘 수 있습니다.
- Scoop self-upgrade 는 실행 중인 batch 파일을 교체할 수 있으므로 `sfs.cmd` 가 직접 소유하면
  안 됩니다. Windows self-upgrade 의 소유자는 `sfs.ps1` 입니다. 또한 `sfs.cmd` 가 `sfs.ps1`
  호출 뒤 다음 batch 줄을 읽는 구조도 허용하지 않습니다.
- Windows PowerShell 5.1 이 읽는 BOM-less script 에 non-ASCII 문자를 넣으면 주석/문자열이어도
  parser failure 로 이어질 수 있습니다. runtime `.ps1` / `.cmd` 는 ASCII-only 로 유지합니다.
- PowerShell CLI argv forwarding 은 Windows/Scoop shim 아래에서 반복 실패했습니다. 단일 `%*` 캐시는
  금지하고, `--% %SFS_NATIVE_RAW_ARGS%` 실험도 runner 에서 잘못된 토큰을 만들었으므로 금지합니다.
  기본 계약은 numbered env arg bridge (`SFS_NATIVE_ARGC`, `SFS_NATIVE_ARG_N`) 를 `sfs.ps1` 이
  즉시 읽고, 비어 있을 때만 raw/saved/parent fallback 으로 내려가는 것입니다.
- generated Scoop shim 아래에서는 target batch 의 `%1..%n` 자체가 비어 있을 수 있습니다. 이때는
  `CMDCMDLINE` 원본 명령행 fallback 이 마지막 Windows-native recovery source 입니다.
- 0.6.45 실패로 `CMDCMDLINE` 조차 target batch 안에서는 충분하지 않다는 점이 확인됐습니다.
  Scoop 설치본의 primary shim 은 generated shim -> packaged `.cmd` 가 아니라 generated shim ->
  packaged `.ps1` 경로로 고정해야 합니다.
- 0.6.46 실패로 `ValueFromRemainingArguments` script param 도 generated Scoop PowerShell shim 아래에서
  충분하지 않다는 점이 확인됐습니다. packaged `sfs.ps1` 은 param block 없이 자동 `$args` 를 읽어야 합니다.
- 0.6.47 실패로 bare `sfs` generated shim 자체를 Windows PowerShell/cmd 계약으로 삼으면 안 된다는
  점이 확인됐습니다. 사용자가 실제로 실행할 Windows entrypoint 는 `sfs.cmd` 입니다.
- 0.6.48 실패로 generated `sfs.cmd` shim 자체도 Windows PowerShell/cmd 계약으로 삼으면 안 된다는
  점이 확인됐습니다. pass 조건은 이름만 `sfs.cmd` 인 generated shim 이 아니라, post-install 이
  덮어쓴 deterministic `sfs.cmd` wrapper 입니다.
- 0.6.49 실패로 post-install 이 소유한 shim 이라도 env-only 전달은 충분하지 않다는 점이 확인됐습니다.
  Windows PowerShell/cmd 경로는 env bridge 와 positional fallback 을 함께 사용해야 합니다.
- PowerShell 문자열 안에서 변수 바로 뒤에 `:` 가 오면 braces 가 필요합니다. 그렇지 않으면 release
  smoke 가 실제 runtime 동작을 검증하기 전에 refspec 단계에서 실패할 수 있습니다.
- batch `shift` 뒤의 `%*` positional fallback 은 Windows runner 에서 충분히 믿을 수 없습니다.
  원본 arg tail 은 shift 전에 별도 env 값으로 고정해야 합니다.

## Windows 확인 명령

Windows PowerShell/cmd 에서는 아래 명령이 usage-only 로 떨어지면 안 됩니다.

```powershell
sfs.cmd version --check
sfs.cmd status
sfs.cmd context cat kernel
sfs.cmd start "이미지 프롬프트 고도화"
sfs.cmd status
```

`start` 이후 sprint 디렉터리가 비어 있어도 그 자체로 실패는 아닙니다. 하지만 출력이 비어 있거나
`status` / `context cat` 이 usage 만 출력하면 실패로 보고 `sfs.cmd update` 후 다시 확인합니다.
이미 설치된 0.6.49 이하 wrapper 때문에 `sfs.cmd update` 자체가 usage 만 출력하면, 최초 1회는
PowerShell 에서 `scoop update` 후 `scoop update sfs` 를 직접 실행한 뒤 프로젝트 폴더에서
`sfs.cmd upgrade --no-self-upgrade` 를 실행합니다.

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
