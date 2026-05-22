---
doc_id: sfs-windows-wrapper-incident-0-6-56-ko-6
title: "적용된 수정"
visibility: oss-public
doc_type: incident-report
language: ko
updated: 2026-05-22
parent: docs/ko/windows-wrapper-incident-0.6.56.md
summary: "적용된 수정"
load_when: "Read when docs/ko/windows-wrapper-incident-0.6.56.md routes to this section."
---
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

