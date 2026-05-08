# Solon 제품 릴리스 노트

**언어**: 한국어 / 영어 문서 예정

이 문서는 사용자가 새 버전에서 무엇을 체감하게 되는지 짧게 정리합니다.
세부 구현 기록은 [CHANGELOG.md](./CHANGELOG.md) 에 따로 둡니다.

---

## 0.6.53

이번 버전은 0.6.52 를 실제 GitHub Windows runner 에 올린 뒤 드러난 saved command-line 문제를
고칩니다. 설치 직후 hardened `sfs.cmd` shim 이 `SFS_NATIVE_RAW_ARGS` 까지 갖고 있었는데도
`sfs.cmd version` 이 usage-only 로 떨어졌습니다. 그래서 batch 프로세스가 가진 원본
명령행을 child PowerShell 을 띄우기 전에 delayed expansion 으로 `SFS_NATIVE_CMDLINE` 에 저장합니다.

- 0.6.52 smoke 실패 run: `25545120029`.
- `sfs.cmd` 와 Scoop post-install hardened `sfs.cmd` shim 이 `SFS_NATIVE_CMDLINE=!CMDCMDLINE!` 을 저장해
  따옴표, `&&`, `>` 가 batch `set` 줄을 깨지 않게 합니다.
- `sfs.ps1` 은 raw arg tail 다음, child PowerShell 의 `CMDCMDLINE` fallback 전에 saved cmdline 을 읽습니다.
- saved cmdline 에 `&& sfs.cmd --help >NUL` 같은 tail 이 붙어도 첫 번째 `sfs.cmd` 명령만 인자로 해석합니다.
- release verifier, Windows guardrail test, GitHub Windows smoke 가 saved-cmdline fallback 계약을 회귀로 막습니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.53.md) 는 P20 으로 이
  설치 직후 usage-only 문제까지 기록합니다.

## 0.6.52

이번 버전은 0.6.51 을 실제 GitHub Windows runner 에 올린 뒤 드러난 마지막 arg-tail 문제를
고칩니다. 설치 직후 hardened `sfs.cmd` shim 이 실행됐는데도 `sfs.cmd version` 이 usage-only 로
떨어졌기 때문에, `%1..%n` 수집 루프가 `shift` 하기 전에 원본 `%*` 꼬리를 `SFS_NATIVE_RAW_ARGS`
로 보존하도록 했습니다.

- 0.6.51 smoke 실패 run: `25543802195`.
- `sfs.cmd` 와 Scoop post-install hardened `sfs.cmd` shim 이 `SFS_NATIVE_RAW_ARGS=%*` 를 먼저 저장합니다.
- `sfs.ps1` 은 numbered env bridge 다음, `CMDCMDLINE` fallback 전에 raw arg tail 을 읽고,
  비어 있는 arg 배열은 fallback 을 막지 못하게 처리합니다.
- release verifier 와 Windows guardrail test 가 raw-arg fallback 계약을 회귀로 막습니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.53.md) 는 P19 로 이
  설치 직후 usage-only 문제까지 기록합니다.

## 0.6.51

이번 버전은 0.6.50 을 실제 GitHub Windows runner 에 올린 뒤 드러난 smoke workflow 문제를
고칩니다. 제품 wrapper 수정은 유지하고, 알려진 깨진 `v0.6.49` archive 를 가져오는 Git refspec 에
PowerShell `${brokenVersion}` braces 를 붙여 Windows CI가 복구 검증까지 실제로 진행하게 했습니다.

- 0.6.50 smoke 실패 run: `25542777986`.
- 실패 원인: `$brokenVersion:` 이 PowerShell scoped-variable 문법처럼 해석되어
  `refs/tags/v/tags/v0.6.49` 를 fetch 하려 했습니다.
- Windows smoke 는 이제 `refs/tags/v${brokenVersion}:refs/tags/v${brokenVersion}` 를 사용합니다.
- release verifier 와 Windows guardrail test 가 refspec 과 archive tag brace 계약을 회귀로 막습니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.53.md) 는 P18 로 이
  release-smoke 문제까지 기록합니다.

## 0.6.50

이번 버전은 0.6.49 를 실제 GitHub Windows runner 에 올린 뒤 확인된 잔여 shim 문제를
수정합니다. post-install 이 `sfs.cmd` shim 을 덮어쓴 것은 맞았지만, env-only 전달만으로는
`sfs.cmd version` 인자가 다시 usage 로 떨어졌습니다. 그래서 hardened `sfs.cmd` shim 이
numbered env bridge 와 `%*` positional fallback 을 함께 `sfs.ps1` 에 넘기도록 고정했습니다.

- Windows PowerShell/cmd 의 사용자 경로는 계속 `sfs.cmd ...` 입니다.
- 설치 직후 shim 파일에 `SFS_NATIVE_ARGC` 와 `%*` 가 모두 있는지도 Windows smoke 가 확인합니다.
- Windows smoke 는 실제 `v0.6.49` archive 도 설치해 `sfs.cmd version` usage 회귀를 재현한 뒤,
  `scoop update` 와 `scoop update sfs` 로 현재 runtime 까지 복구되는지 확인합니다.
- `sfs.cmd version`, `sfs.cmd context cat kernel`, `sfs.cmd start ...`, `sfs.cmd upgrade`
  가 env-only shim 전달 실패에 막히지 않도록 두 경로를 동시에 열어 둡니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.53.md) 는 P1-P17
  문제 목록과 0.6.49 GitHub smoke run `25541086874` 실패 근거까지 포함합니다.

## 0.6.49

이번 버전은 0.6.48 을 실제 GitHub Windows runner 에 올린 뒤 확인된 마지막 shim 문제를
수정합니다. `sfs.cmd` 로 경로를 고정해도 Scoop 이 생성한 `sfs.cmd` shim 자체가 `version`
인자를 버릴 수 있었으므로, 설치 후 hook 이 shims 디렉터리의 `sfs.cmd`, `sfs.ps1`,
extensionless `sfs` 를 Solon 이 제어하는 deterministic wrapper 로 덮어씁니다.

- Windows PowerShell/cmd 의 사용자 경로는 계속 `sfs.cmd ...` 입니다.
- `sfs.cmd version`, `sfs.cmd context cat kernel`, `sfs.cmd start ...`, `sfs.cmd upgrade`
  가 generated shim 인자 손실에 막히지 않도록 shim 자체를 post-install 에서 고정합니다.
- Git Bash 에서는 extensionless `sfs` shim 이 packaged `bin/sfs` 를 실행합니다.
- `sfs.ps1` 내부 인자 정규화도 named-array forwarding 으로 보강해 `context cat kernel` 같은
  여러 단어 명령이 내부 함수 호출에서 잘리지 않게 했습니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.53.md) 는 P1-P16
  문제 목록과 0.6.48 GitHub smoke run `25539387684` 실패 근거까지 포함합니다.

## 0.6.48

이번 버전은 0.6.47 을 실제 GitHub Windows runner 에 올린 뒤 확인된 smoke 계약 문제를
정리합니다. bare `sfs` generated shim 은 PowerShell/cmd 에서 여전히 인자를 잃을 수 있으므로,
Windows 의 사용자 실행 경로와 CI 통과 기준을 `sfs.cmd` 로 고정했습니다.

- Windows PowerShell/cmd 검증은 이제 `sfs.cmd version`, `sfs.cmd status`,
  `sfs.cmd context cat ...`, `sfs.cmd start ...`, `sfs.cmd upgrade` 를 직접 확인합니다.
- Git Bash/WSL 에서는 기존처럼 bare `sfs` 를 검증합니다.
- 문서와 Scoop packaging guide 는 Windows 예시를 `sfs.cmd` 기준으로 정리했습니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.53.md) 는 P1-P15
  문제 목록과 0.6.47 GitHub smoke run `25535059980` 실패 근거까지 포함합니다.

## 0.6.47

이번 버전은 0.6.46 을 실제 GitHub Windows runner 에 올린 뒤 확인된 마지막 인자 수신 문제를
좁힙니다. 0.6.46 에서 Scoop manifest target 은 실제로 `sfs.ps1` 로 바뀌었지만,
`ValueFromRemainingArguments` script param 이 `version` 인자를 받지 못해 `sfs version` 이 다시
usage-only 로 떨어졌습니다.

- packaged `sfs.ps1` 에서 param block 을 제거했습니다.
- `sfs.ps1` 은 이제 numbered env bridge 다음에 PowerShell 자동 `$args` 를 읽고, 그 뒤
  `CMDCMDLINE`, `$MyInvocation.UnboundArguments` fallback 을 유지합니다.
- `sfs.cmd` 는 직접 실행/호환용 trampoline 으로 남아 env bridge 와 `%*` fallback 을 계속 제공합니다.
- Windows guardrail 과 release verifier 는 이제 packaged `sfs.ps1` 안의 `ValueFromRemainingArguments` 를
  회귀로 보고 실패시킵니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.53.md) 는 P1-P14
  문제 목록과 0.6.46 GitHub smoke run `25534566676` 실패 근거까지 포함합니다.

## 0.6.46

이번 버전은 0.6.45 를 실제 GitHub Windows runner 에 올린 뒤에도 남아 있던 최초
`sfs version` usage-only 실패를 다시 좁힙니다. 결론은 더 명확해졌습니다. Scoop 이 생성하는
primary shim 은 packaged `bin\sfs.cmd` 를 target 으로 삼으면 안 되고, `bin\sfs.ps1` 을 직접
호출해야 합니다.

- Scoop manifest 는 이제 `bin\sfs.ps1` 을 통해 `sfs` / `sfs.cmd` shim 을 노출합니다.
- `sfs.ps1` 은 Scoop PowerShell shim 의 positional args 를 받으면서도 env bridge, `$args`,
  `CMDCMDLINE`, `$MyInvocation.UnboundArguments` fallback 을 유지합니다.
- packaged `sfs.cmd` 는 직접 실행/호환용 thin trampoline 으로 남고, `%*` 를 보조 fallback 으로
  `sfs.ps1` 에 같이 넘깁니다.
- Windows guardrail 과 release verifier 는 이제 Scoop manifest 가 `bin\sfs.ps1` 을 primary target 으로
  쓰는지 확인하고, generated shim -> packaged `.cmd` 경로를 기본값으로 되돌리면 실패합니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.53.md) 는 P1-P13
  문제 목록과 0.6.45 GitHub smoke run `25533332634` 실패 근거까지 포함합니다.

## 0.6.45

이번 버전은 0.6.44 를 실제 GitHub Windows runner 에 올린 뒤에도 남아 있던 `sfs.cmd`
인자 손실을 한 번 더 좁힙니다. 0.6.44 의 `%1..%n` numbered env bridge 도 Scoop shim 아래에서는
빈 인자로 시작될 수 있었고, `sfs version` 은 또 usage-only 로 떨어졌습니다.

- `sfs.ps1` 은 이제 numbered env bridge, positional param, `$args` 가 모두 비어 있을 때
  Windows 의 원본 `CMDCMDLINE` 명령행을 마지막 fallback 으로 파싱합니다.
- 이 fallback 은 `sfs` / `sfs.cmd` 뒤의 실제 명령 꼬리만 꺼내 같은 SFS 인자 목록으로 정규화합니다.
- Windows guardrail 과 release verifier 는 이제 `CMDCMDLINE` fallback reader 와 command-line
  splitter 를 필수로 확인합니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.53.md) 는 P1-P12
  문제 목록과 `스프린트 생성 테스트` Windows smoke 기준으로 최신화했습니다.

## 0.6.44

이번 버전은 0.6.43 을 실제 GitHub Windows runner 에 올린 뒤에도 남아 있던 `sfs.cmd`
인자 손실을 고칩니다. 0.6.43 의 PowerShell `-Command @args` 경로도 Scoop shim 아래에서는
`sfs version` 을 usage-only 로 떨어뜨렸습니다. 그래서 Windows wrapper 는 이제 PowerShell CLI
argument binding 을 기본 신뢰 경로에서 제거합니다.

- `sfs.cmd` 는 받은 `%1..%n` 인자를 `SFS_NATIVE_ARGC` / `SFS_NATIVE_ARG_N` 번호 환경 변수로 저장한
  뒤, 인자 없이 `sfs.ps1` 을 실행합니다.
- `sfs.ps1` 은 이 numbered env bridge 를 첫 번째 인자 소스로 읽고, 그 다음 positional param,
  `$args`, `$MyInvocation.UnboundArguments` 를 fallback 으로 정규화합니다.
- Windows guardrail 과 release verifier 는 이제 예전 `-File ... %*` bridge 와
  `-Command "& $env:SFS_NATIVE_SCRIPT @args"` bridge 를 모두 실패로 봅니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.53.md) 는 이후 P1-P12
  문제 목록과 `스프린트 생성 테스트` Windows smoke 기준으로 최신화했습니다.

## 0.6.43

이번 버전은 0.6.42 를 실제 GitHub Windows runner 에 올린 뒤에도 남아 있던 마지막 Windows
인자 전달 실패를 고칩니다. 0.6.42 에서 batch label 은 제거됐지만, Scoop shim 아래에서는
`powershell.exe -File sfs.ps1 %*` 경로도 `sfs version` 을 usage-only 로 떨어뜨렸습니다.
이 릴리스의 `-Command @args` 경로도 실제 Windows smoke 에서 실패해 0.6.45 numbered env bridge 로
후속 보강됐습니다.

- `sfs.cmd` 는 이제 `-File` 이 아니라 PowerShell `-Command "& $env:SFS_NATIVE_SCRIPT @args"`
  경로로 `sfs.ps1` 을 호출합니다.
- `sfs.ps1` 은 positional array param 을 첫 번째 인자 소스로 받고, 그 다음 `$args` 와
  `$MyInvocation.UnboundArguments` 를 fallback 으로 정규화합니다.
- Windows guardrail 과 release verifier 는 이제 예전 `-File ... %*` bridge 를 실패로 보고,
  `SFS_NATIVE_SCRIPT @args` 경로를 필수로 확인합니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.53.md) 는 이후 P1-P12
  문제 목록과 `스프린트 생성 테스트` Windows smoke 기준으로 최신화했습니다.

## 0.6.42

이번 버전은 0.6.41 을 실제 GitHub Windows runner 에 올린 뒤 남아 있던 `sfs.cmd` 인자 손실을
마저 제거합니다. 결론은 더 세게 단순해졌습니다. Windows 의 `sfs.cmd` 는 더 이상 batch label 로
판단하거나 전달하지 않고, 곧장 `sfs.ps1` 로 들어가는 얇은 PowerShell trampoline 입니다.

- `sfs.cmd` 안의 `call :...` label dispatch 를 제거했습니다. Scoop shim 아래에서 label forwarding
  자체가 `sfs version` 을 usage-only 로 떨어뜨릴 수 있었기 때문입니다.
- `sfs.ps1` 이 `version`, `status`, `guide`, `context`, Scoop self-upgrade, Bash fallback 을 모두
  소유합니다. Windows PowerShell/cmd 에서도 macOS 의 `sfs` 처럼 명령 인자를 받아야 한다는 목표에
  맞춘 고정 경로입니다.
- Windows guardrail 과 release verifier 가 이제 `sfs.cmd` 안의 batch label, raw Git Bash `%*`,
  `SFS_ORIGINAL_ARGS`, batch-owned `scoop update` 를 모두 실패로 봅니다.
- 현재 0.6.53 기준으로는 0.6.49 이하의 깨진 wrapper 때문에 `sfs.cmd update` 도 usage 만 출력하는
  경우 최초 1회 `scoop update` 후 `scoop update sfs`, 그리고 `sfs.cmd upgrade --no-self-upgrade` 로 복구합니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.53.md) 는 이후
  P10-P12 PowerShell shim 문제까지 포함하는 0.6.45 기준으로 최신화했습니다.

## 0.6.41

이번 버전은 0.6.40 을 실제 GitHub Windows runner 에 올린 뒤 남아 있던 Windows 전용 문제를
고칩니다. 결론은 더 단순해졌습니다. Windows 에서 실행되는 `.ps1` / `.cmd` 는 PowerShell 5.1 의
legacy decoding 을 견디도록 ASCII 로 고정하고, `sfs.cmd` 는 저장해 둔 인자 변수가 아니라 실제
call-label `%*` 를 바로 `sfs.ps1` 에 전달합니다.

- `install-cli-discovery.ps1` 등 Windows PowerShell/cmd 스크립트에서 non-ASCII 문자를 제거했습니다.
  BOM 없는 UTF-8 파일을 Windows PowerShell 5.1 이 ANSI 로 읽으면서 parser error 를 내던 문제를
  막습니다.
- `sfs.cmd` 는 `SFS_ORIGINAL_ARGS` 캐시를 쓰지 않습니다. Scoop shim 경로에서 빈 인자로 떨어져
  `sfs version` 이 usage 만 출력하던 경로를 제거했습니다.
- Windows guardrail 과 release verifier 가 `.ps1` / `.cmd` ASCII-only, direct `%*` forwarding,
  same-line `exit /b !ERRORLEVEL!` 계약을 함께 검사합니다.
- [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.53.md) 는 이후
  P1-P12 문제 목록과 0.6.45 기준 검증 경로로 최신화했습니다.

## 0.6.40

이번 버전은 0.6.39 배포 후 실제 GitHub Windows runner 에서 다시 잡힌 마지막 wrapper 문제를
고칩니다. 목표는 그대로입니다. Windows PowerShell/cmd 에서 `sfs.cmd` 가 macOS 의 `sfs` 처럼
명령 인자를 받고, upgrade 뒤에도 이상한 조각 명령을 실행하지 않아야 합니다.
이 릴리스는 실제 Windows Scoop smoke 에서 PowerShell 5.1 parser / Scoop shim 인자 문제가
추가로 확인되어 0.6.41 로 후속 보강됐습니다.

- `sfs.cmd` 의 same-line 종료 방식을 `exit /b !ERRORLEVEL!` 로 바꿨습니다. 0.6.39 의
  `call exit /b %%ERRORLEVEL%%` 형태는 실제 Windows/Scoop shim 조합에서 안정적이지 않았습니다.
- batch wrapper 는 delayed expansion 을 켜고, `sfs.ps1` 호출 뒤 같은 parsed line 에서 종료합니다.
- Scoop post-install 의 `install-cli-discovery.ps1` 는 Claude filesystem-direct fallback 실패를
  명시적으로 catch 한 뒤 cleanup 하도록 보강했습니다.
- Windows CI 는 계속 이전 로컬 패키지 설치 -> `sfs.cmd upgrade` -> 한국어 `sfs.cmd start` 순서로
  실제 Windows 동작을 검증합니다.

## 0.6.39

이번 버전은 Windows PowerShell/cmd 에서 `sfs.cmd` 가 macOS 의 `sfs` 처럼 실제 명령을 받도록
고칩니다. 0.6.38 설치 후에도 `sfs.cmd context cat ...` 과 `sfs.cmd start ...` 가 usage 만
출력하던 문제를 수정했습니다.
이 릴리스는 실제 Windows Scoop smoke 에서 추가 batch exit/parser 문제가 발견되어 0.6.40 으로
후속 보강됐습니다.

- `sfs.ps1` 이 Windows PowerShell 5.1 의 불안정한 script param catch-all 에 의존하지 않고
  `$args` / `$MyInvocation.UnboundArguments` 로 명령 인자를 직접 정규화합니다.
- `sfs.cmd` 는 self-upgrade 뒤 batch 파일이 교체되어도 다음 줄을 읽지 않도록 PowerShell 호출과
  종료를 같은 parsed line 으로 고정했습니다. `e`, `*` 같은 조각 문자열이 명령처럼 실행되는 잔여
  문제를 막습니다.
- Windows Scoop smoke 가 이제 `sfs.cmd context cat kernel`, `sfs.cmd context cat commands/start.md`,
  `sfs.cmd start --id ci-sprint-test "sprint-create-test"`, 이벤트 goal, `sfs.cmd status` 까지
  검증합니다.
- 같은 Windows smoke 가 로컬 이전 Scoop 패키지에서 현재 패키지로 `sfs.cmd upgrade` 를 실제 실행하고,
  `e`, `*`, `TIVE_READONLY_DONE`, `LF_UPGRADE_DONE` 같은 batch tail-fragment 가 나오지 않는지 확인합니다.
- Windows smoke 가 한국어 goal `스프린트 생성 테스트` 도 `sfs.cmd start` 로 생성하고 이벤트 goal 까지
  확인합니다.
- Windows wrapper 장애 보고서는 이후 0.6.45 최종 기준선으로 최신화했습니다.

## 0.6.38

이번 버전은 0.6.37 Windows Scoop self-upgrade 수정은 그대로 유지하면서, Homebrew 설치본에서 새
incident-report 문서 테스트가 `CHANGELOG.md` / `RELEASE-NOTES.md` 위치를 잘못 보는 문제를 고칩니다.

- Homebrew 설치본에서는 런타임 테스트가 `libexec/tests` 에서 실행되고, 상위 문서는 Cellar 버전
  루트에 있습니다.
- `test-windows-wrapper-incident-report.sh` 가 source layout 과 Homebrew installed layout 둘 다
  이해하도록 고쳤습니다.
- Windows 사용자는 0.6.37 에 들어간 `sfs.cmd upgrade` self-replacement 방지 수정을 그대로
  받습니다.
- Windows wrapper 장애 보고서는 이후 0.6.45 기준 링크와 P1-P12 문제점 정리로 최신화했습니다.

## 0.6.37

이번 버전은 Windows Scoop 설치본에서 `sfs.cmd upgrade` 가 자기 자신을 교체하는 batch 파일 안에서
계속 실행되며 `TIVE_READONLY_DONE`, `LF_UPGRADE_DONE` 같은 조각 문자열을 명령처럼 실행하던
문제를 고칩니다.

- `sfs.cmd` 는 더 이상 `scoop update` / `scoop update sfs` 를 직접 실행하지 않습니다.
- Windows self-upgrade 는 이미 인자를 정규화하고 메모리 실행에 더 안전한 `sfs.ps1` 이 맡습니다.
- `sfs.cmd` 는 native read-only 확인 후 나머지 명령을 PowerShell entrypoint 로 넘기는 얇은 wrapper
  로 돌아갑니다.
- 이번 Windows wrapper 장애 흐름과 발견된 문제점은
  [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.53.md) 에 정리했습니다.

## 0.6.36

이번 버전은 0.6.35 Windows 래퍼 수정 자체는 유지하면서, Homebrew 설치본의 문서 검증 테스트가
`CHANGELOG.md` 위치를 잘못 보는 문제를 고칩니다.

- Homebrew 설치본에서는 `CHANGELOG.md` 가 `libexec` 안이 아니라 Cellar 버전 루트에 있습니다.
- `test-docs-model-routing.sh` 가 source layout 과 Homebrew installed layout 둘 다 이해하도록
  고쳤습니다.
- Windows 사용자는 0.6.35 에 들어간 `sfs.cmd -> sfs.ps1 -> Bash runtime` bridge 수정을 그대로
  받습니다.
- Windows 에서 실제로 관찰된 usage-only, 빈 출력, 한국어 깨짐, Homebrew installed layout 문제는
  [Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.53.md) 에 정리했습니다.

## 0.6.35

이번 버전은 Windows Scoop 설치본에서 `sfs.cmd` 가 다시 usage 만 출력하거나,
`sfs.cmd start "<한국어 목표>"` 후 출력/인코딩이 불안정해지는 문제를 고칩니다.

- `sfs.cmd status`, `sfs.cmd context cat kernel` 같은 읽기 명령이 PowerShell entrypoint 에
  인자를 확실히 넘기도록 다시 고정했습니다.
- `sfs.ps1` 은 `powershell.exe -File ... status`, `... context cat kernel`, `-SfsArgs`
  배열 호출 모양을 모두 같은 인자 목록으로 정규화합니다.
- `sfs.cmd start "<목표>"` 같은 상태 변경 명령도 raw Git Bash 직행 대신 PowerShell bridge 를
  거친 뒤 Bash runtime 으로 내려갑니다. 그래서 Windows 에서는 성공한 쪽, 즉 PowerShell 이
  Unicode-safe 인자 배열을 들고 있는 경로로 고정됩니다.
- PowerShell bridge 는 UTF-8 console/native-command encoding 과 Git Bash UTF-8 locale 을
  기본으로 맞춥니다.
- Windows 테스트는 가능하면 실제 `powershell.exe -File sfs.ps1 context cat kernel` 과
  `status` 호출까지 실행해 usage-only 회귀를 잡습니다.

## 0.6.34

이번 버전은 SFS 모델 라우팅을 사용자가 따로 설정하지 않아도 기본 적용되게 바꿉니다.

- 단순 relay, 누락 인자 질문, 낮은 위험의 짧은 요약은 helper-grade intake 로 처리합니다.
  Codex 기준 기본값은 `gpt-5.4-mini` 입니다.
- brainstorm 질문 생성, 선택지 framing, 답변 요약은 facilitator tier 로 처리합니다.
  Codex 기준 기본값은 `gpt-5.4` 입니다.
- 하위모델 출력이 질문/선택지를 설계하거나 답변을 해석하거나 gate/plan 에 영향을 주면
  최상위 advisor 검토가 필수입니다. Codex advisor 는 `gpt-5.5` xhigh 입니다.
- 이 승격은 자동 content classifier 가 아니라 SFS role label 과 self-CPO/review 규칙으로 강제합니다.
- Helper-grade 단순 I/O 는 advisor 검토를 생략할 수 있습니다.
- advisor 호출은 self-CPO PASS 를 대체하지 않습니다. external/cross review 전에는 요구사항,
  AC, 구현 slice, ADR/decision id, file/artifact/evidence, SEED/placeholder/mock/fallback
  non-acceptance 를 확인한 self-CPO mini-check 를 남겨야 합니다.
- review executor 는 full CPO prompt 전에 작은 bridge probe 를 먼저 실행합니다. Claude/Codex/Gemini
  CLI 가 무출력으로 멈추면 full review 로 들어가지 않고 `/sfs auth probe` 또는
  `SFS_REVIEW_<EXECUTOR>_CMD` 설정을 안내합니다.
- Claude review bridge 기본값은 성공이 확인된 `claude -p "$(cat)"` prompt-argument 경로로 고정했습니다.
  실패가 확인된 `claude -p --dangerously-skip-permissions` stdin 경로는 더 이상 기본값으로 쓰지 않습니다.
- Gemini 는 facilitator/advisor/review 기본값으로 `gemini-3.1-pro-preview`, helper-grade fallback 으로
  `gemini-3-flash-preview` 만 명시합니다. 2.5 fallback 은 쓰지 않습니다.
- 구현 worker 는 그대로 `gpt-5.3-codex`, 기계적 helper 는 `gpt-5.3-codex-spark` 입니다.
- 새 프로젝트와 fallback 상태의 기존 프로젝트는 `solon_recommended` role routing 을 기본값으로 씁니다.

## 0.6.33

이번 버전은 Claude/Codex/Gemini SFS 어댑터가 사용자 언어와 SFS 용어를 섞어 이상한 선택지로
보여 주는 문제를 막는 핫픽스입니다.

- 택소노미를 조직명이 아니라 SFS의 제품 기능 계약으로 명시했습니다.
- `sfs start` 처럼 필수 인자가 빠졌을 때 `Other`, `Type something` 같은 앱 placeholder 를
  선택지처럼 보여 주지 않도록 막았습니다.
- 한국어 사용자가 `sfs start` goal 을 빼먹으면 한 문장 질문으로
  `이번 sprint 목표를 한 줄로 말해 주세요. 예: "docker compose 구조 리디자인"` 를 쓰도록 했습니다.
- 같은 guardrail 이 Claude, Codex, Gemini 어댑터와 SFS kernel 전체에 적용됩니다.

## 0.6.32

이번 버전은 0.6.31 에서도 남아 있던 Windows CMD 인자 전달 문제를 다시 고칩니다.

- `sfs.cmd` 가 원본 인자를 batch subroutine 안이 아니라 파일 최상단에서 먼저 캡처합니다.
- `sfs.cmd status`, `sfs.cmd version --check`, `sfs.cmd context cat ...` 이
  PowerShell native 경로로 넘어갈 때 같은 원본 인자를 사용합니다.
- 0.5.96 시절처럼 ordinary Git Bash command forwarding 은 기존 `%*` 전달 방식을 유지합니다.

## 0.6.31

이번 버전은 0.6.30 의 Windows native read-only 경로에서 생긴 인자 전달 버그를 고칩니다.

- `sfs.cmd status` 가 `status` 인자를 잃고 usage 만 출력하던 문제를 수정했습니다.
- `sfs.cmd version --check` 가 `version --check` 인자를 잃고 usage 만 출력하던 문제를 수정했습니다.
- `sfs.cmd context cat ...` 도 같은 캡처된 인자 전달 경로를 사용합니다.

## 0.6.30

이번 버전은 Windows Codex 앱 또는 Git Bash 안에서 실행한 Codex 가 SFS 읽기 명령까지
Git Bash 로 들어가며 멈추던 문제를 한 번 더 막는 핫픽스입니다.

- `sfs.cmd status`, `sfs.cmd version`, `sfs.cmd context path ...`,
  `sfs.cmd context cat ...` 는 이제 Git Bash 없이 Windows native 로 동작합니다.
- Codex/Claude/Gemini adapter 는 Windows 에서 routed context 를 읽을 때
  `sfs.cmd context cat ...` 를 우선 사용하도록 안내합니다.
- agent runner 가 Git Bash 를 못 띄우면 읽기 명령은 native fallback 으로 처리하고,
  `start` 같은 상태 변경 명령은 사용자가 PowerShell/cmd 에서 직접 실행하도록 안내합니다.
- Windows 가이드에 Codex 앱/Git Bash sandbox 실패 대응 절차를 보강했습니다.

## 0.6.29

이번 버전은 Windows 에서 Claude, Gemini, Codex 의 SFS 명령이 Git Bash 시작 전에
`couldn't create signal pipe, Win32 error 5` 로 막히던 흐름을 고친 핫픽스입니다.

- Windows PowerShell/cmd 에서는 `sfs.cmd --help`, `sfs.cmd guide` 가 Git Bash 없이도 바로 출력됩니다.
- Claude, Gemini, Codex 용 SFS adapter 는 Windows 실행 시 `sfs.cmd ...` 를 우선 사용하도록 안내합니다.
- `sfs start` 같은 상태 변경 명령이 빈 stdout/stderr 로 끝나면 성공으로 보지 않도록 guardrail 을 추가했습니다.
- `start` 성공은 `.sfs-local/current-sprint` 와 sprint 폴더가 실제로 생겼을 때만 인정합니다.
- Windows 사용자 가이드에 agent 실행 sandbox / Git Bash signal-pipe 에러 대응 절차를 추가했습니다.

## 0.6.28

이번 버전은 0.6.27 에 추가한 native 언어 커밋 메시지 테스트가 Homebrew 설치본에서도 그대로
통과하도록 고친 핫픽스입니다.

- Homebrew 설치본은 `README.md` 를 Cellar 루트에 두고 runtime 테스트는 `libexec` 아래에서 실행합니다.
- native 언어 커밋 메시지 테스트가 source layout 과 installed Homebrew layout 둘 다 이해하도록 수정했습니다.
- 사용자-facing 규칙은 0.6.27 과 같습니다. 커밋 메시지는 사용자의 native/workspace 언어가 기본입니다.

## 0.6.27

이번 버전은 agent 가 커밋 메시지를 사용자의 native 언어 또는 workspace 언어로 쓰도록 기본 규칙을
바꿉니다.

- 한국어 사용자에게는 `수정: 로그인 오류 안내 개선` 처럼 한국어 커밋 메시지가 기본입니다.
- 영어 커밋 메시지는 사용자의 native 언어가 영어이거나 repo 가 영어 커밋을 명시적으로 요구할 때만 기본값입니다.
- `sfs implement` 의 병렬 lane commit message 도 같은 규칙을 따릅니다.
- `sfs review` 는 proposed/actual commit message 가 사용자 언어와 맞는지도 확인합니다.
- install/upgrade/uninstall 안내의 예시 커밋 메시지도 한국어 UX에서는 한국어로 보입니다.

## 0.6.26

이번 버전은 디자인본부 시스템에 AI 슬롭 방지용 디자인 시스템 운영 규칙을 추가합니다.

- `design.md` 또는 `docs/solon/design.md` 를 AI 가 읽는 디자인 시스템 계약으로 봅니다.
- 디자인/frontend 구현은 `design.md` 를 먼저 읽고, 구현 후 token drift 를 확인하도록 안내합니다.
- review 는 임의 색상, 임의 type scale, 임의 spacing/radius, 섞인 icon style, generic AI 슬롭 느낌을 finding 으로 볼 수 있습니다.
- 한국어 제품 starter set 으로 원티드 몽타주식 컴포넌트, Coolicons 같은 단일 icon family, Pretendard 같은 Korean-capable font 를 참고하되, 기존 design system 이 있으면 기존 system 을 우선합니다.
- 10x value 문서에 multi-agent implement 와 design-system governance 를 AI 시대의 실행/품질 leverage 로 반영했습니다.

## 0.6.25

이번 버전은 구현 작업량이 클 때 여러 agent 를 병렬로 쓰는 선택지를 추가합니다. 기본값은 그대로
Single Agent 입니다.

- `sfs implement` 출력에서 기본 Single Agent 와 선택형 parallel agent 명령을 함께 안내합니다.
- 병렬 모드는 `sfs implement --agent-mode parallel --agents codex,claude[,gemini] ...` 로 명시적으로 선택합니다.
- 병렬 lane 은 files_scope 가 겹치지 않아야 하고, lane 별 commit message 를 한 문장으로 설명할 수 있어야 합니다.
- 구현이 끝나면 Single Agent 도 `sfs review --gate 6` 가 필수입니다.
- 병렬 agent 로 구현했다면 Gate 6 전에 agent 간 cross review evidence 도 필수입니다.

## 0.6.24

이번 버전은 0.6.23 에 추가한 문서 테스트가 Homebrew 설치본에서도 그대로 통과하도록 고친 핫픽스입니다.

- Homebrew 설치본은 `README.md` 를 Cellar 루트에 두고 runtime 파일은 `libexec` 아래에 둡니다.
- 문서 테스트가 source layout 과 installed Homebrew layout 둘 다 이해하도록 수정했습니다.
- 사용자 문서 내용은 0.6.23 의 모델 라우팅 최신화 그대로 유지됩니다.

## 0.6.23

이번 버전은 0.6.22 의 Codex worker 모델 라우팅을 사용자 문서까지 맞춘 문서 핫픽스입니다.

- README, GUIDE, BEGINNER-GUIDE, 한국어/영어 docs 의 오래된 0.6.17 기준 문구를 현재 기준으로 정리했습니다.
- C-Level/review 는 high reasoning, Claude worker 는 Sonnet 계열, Codex worker 는 `gpt-5.3-codex` 라고 설명합니다.
- `gpt-5.3-codex-spark` 는 일반 구현 worker 가 아니라 scope/files_scope/AC 가 잠긴 helper subtask 용도라고 명시했습니다.
- architecture, public contract, security, privacy, data-loss, release gate, 반복 실패가 있으면 high reasoning 으로 승격한다고 문서화했습니다.

## 0.6.22

이번 버전은 Codex 쪽 구현 worker 모델 기본값을 명확히 나누는 핫픽스입니다.

- C-Level/review 는 계속 high reasoning 모델이 맡습니다.
- Codex 구현 worker 기본값은 `gpt-5.3-codex` 입니다.
- `gpt-5.3-codex-spark` 는 일반 구현 worker 가 아니라 scope/files_scope/AC 가 잠긴 기계적 helper subtask 용도입니다.
- architecture, public contract, security, privacy, data-loss, release gate, 반복 실패 같은 위험이 있으면 worker 도 high reasoning 으로 승격합니다.
- Claude 쪽 worker 기본값은 기존처럼 Sonnet 계열로 유지됩니다.

## 0.6.21

이번 버전은 Gate 3 review 를 많이 돌렸다는 이유로 implement 여부를 묻던 흐름을 막는 핫픽스입니다.

- self review 가 먼저 PASS 해야 합니다.
- self review PASS 이후에 cross review 를 돌립니다.
- cross review 가 partial/fail 이면 plan 을 고친 뒤 다시 self review 부터 시작합니다.
- review round 수, lens 수, advisor 지적 수, “충분히 봄”은 PASS 를 대신할 수 없습니다.
- 최신 Gate 3 review 가 partial/fail 이면 `sfs implement` 는 계속 막힙니다.

## 0.6.20

이번 버전은 같은 Gate review 를 반복할 때 lens 가 `docs` 에서 `design` 처럼 바뀌어 review loop 가 수렴하지 않던 문제를 고친 핫픽스입니다.

- 첫 `sfs review --lens auto` 는 기존처럼 작업 evidence 를 보고 lens 를 고릅니다.
- 같은 sprint/gate 의 다음 auto review 는 이전 lens 를 재사용합니다.
- 의도적으로 lens 를 바꾸려면 `--lens design` 처럼 명시적으로 지정해야 합니다.
- 그래서 "pass 될 때까지" 반복의 의미가 같은 기준 안에서 유지됩니다.

## 0.6.19

이번 버전은 Gate 3 계획이 끝났다고 바로 구현으로 넘어가며 사용자에게 모델 선택을 묻던 흐름을 막는 핫픽스입니다.

- `sfs implement` 는 이제 Gate 3 Plan review PASS 없이는 시작하지 않습니다.
- 정상 흐름은 `sfs plan` 다음 `sfs review --gate 3`, 그 다음 `sfs implement` 입니다.
- C-Level 모델은 설계, 계약, AC, 검토 handoff 를 책임지고, worker/generator 모델이 고정된 구현 slice 를 맡는다는 역할 경계를 명시했습니다.
- 예외적으로 사용자가 plan review 를 건너뛰라고 명시한 경우에만 `--allow-unreviewed-plan` 으로 진행할 수 있고, 그 waiver 는 기록됩니다.
- 앞으로 Action Rail 이 ready plan 에서 바로 구현/모델 선택으로 뛰면 guardrail 테스트가 실패합니다.

## 0.6.18

이번 버전은 UX가 있는 작업에서 Solon 이 "경고/차단"부터 말하지 않고, 사용자가 바로 고칠 수 있는 흐름을 먼저 설계하도록 바꾼 핫픽스입니다.

- 입력값 검증은 먼저 무엇을 어디서 어떻게 고치면 되는지 보여줘야 합니다.
- `[Product]` 같은 미치환 placeholder 는 field 가까이에 표시하고, focus/clear/replace/AI에게 맡기기 같은 회복 경로를 요구합니다.
- "잘못된 입력" 같은 막힌 문구보다 "아직 실제 값으로 바꿔야 할 부분이 있어요" 같은 coaching tone 을 쓰도록 디자인 지식팩을 보강했습니다.
- 서버 4xx 는 비용/보안/데이터 무결성을 지키는 마지막 안전망으로만 다루고, UI 가 같은 field-level 복구 안내로 렌더링할 수 있어야 합니다.
- 앞으로 이 repair-first UX 계약이 빠지면 패키지 테스트가 실패합니다.

## 0.6.17

이번 버전은 review 통과 후 다음 액션 안내가 `sfs report` 를 불필요하게 먼저 권하던 문제를 바로잡은 핫픽스입니다.

- 정상 마무리 경로는 `sfs retro` 하나입니다.
- `retro` 는 이미 `report.md` 를 확인하거나 만들고, `retro.md` 를 정리하고, sprint close 까지 이어갑니다.
- `sfs report` 는 보고서만 미리 보거나 과거 sprint 보고서를 다시 만들 때 쓰는 선택 명령으로 정리했습니다.
- review/tidy context 와 CPO review prompt 에서 `report -> retro` 안내가 다시 나오지 않도록 테스트를 추가했습니다.

## 0.6.16

이번 버전은 Gate 3 같은 계획 보고서에서 결정 질문이 너무 압축되어 보이던 문제를 바로잡은 핫픽스입니다.

- 보고서가 `Q1`, `D1`, `AC-1` 같은 식별자만 앞세워 사용자의 결정을 요구하지 않도록 했습니다.
- 결정이 필요할 때는 무엇을 결정하는지, 왜 지금 필요한지, 권장 기본값이 무엇인지, 각 선택지가 무엇을 바꾸는지 풀어서 설명해야 합니다.
- Gate 3 plan 이 아직 draft 인 경우에도 마지막 질문은 짧은 decision brief 로 남기도록 context 를 보강했습니다.
- Claude, Gemini, Codex adapter template 모두 같은 보고서 명료성 규칙을 갖습니다.
- 앞으로 이 규칙이 빠지면 agent behavior guardrail 테스트가 실패합니다.

## 0.6.15

이번 버전은 릴리스 노트가 stable package 에 누락되던 배포 스크립트 문제를 바로잡은 핫픽스입니다.

- dev 에서는 0.6.13, 0.6.14 릴리스 노트가 최신이었지만 stable tag 와 설치본에는 `RELEASE-NOTES.md` 가 오래된 상태로 남을 수 있었습니다.
- `cut-release.sh` 가 이제 `RELEASE-NOTES.md` 를 stable 제품 저장소로 함께 동기화합니다.
- 앞으로 release cutter allowlist 에서 릴리스 노트가 빠지면 테스트가 실패하도록 막았습니다.

## 0.6.14

이번 버전은 실사용 중 발견된 review lens 이름 불일치를 바로잡은 핫픽스입니다.

- `sfs review --lens strategy-pm` 처럼 본부 이름을 넣어도 이제 `strategy` lens 로 정상 처리됩니다.
- `strategy_pm`, `design/frontend`, `infra`, `finance`, `accounting` 같은 자주 나오는 표현도 공개 lens 이름으로 정규화됩니다.
- `management-admin` 은 재무 기록, 경리, 세무/회계 질문, 현금 evidence 를 보는 review lens 로 직접 사용할 수 있습니다.
- 잘못된 lens 를 넣었을 때 오류 메시지가 alias 예시를 함께 보여줍니다. agent 가 엉뚱한 lens 로 오래 기다리는 일을 줄이기 위한 조치입니다.

## 0.6.13

이번 버전은 Claude, Codex, Gemini 를 팀처럼 쓰는 방식을 Solon 답게 얇게 반영한 릴리스입니다.

- 큰 조사나 마이그레이션 판단이 필요할 때 사용할 수 있는 read-only researcher 역할이 추가됐습니다.
- researcher 는 코드를 직접 고치거나 품질 승인을 하지 않습니다. 넓게 읽고, 필요한 사실과 근거만 작게 남깁니다.
- 모델 프로필에 `research_high` 단계가 추가되어 Gemini 처럼 긴 컨텍스트에 강한 도구를 조사 역할에 더 자연스럽게 배치할 수 있습니다.
- 구현은 여전히 작은 파일 범위와 명확한 작업 단위로 나눕니다. 여러 에이전트를 쓰더라도 프로젝트 표면이 커지지 않도록 했습니다.
- 리뷰는 작성자와 분리된 관점으로 보게 했습니다. 같은 agent 가 만든 코드를 같은 맥락에서 다시 승인하는 흐름은 위험 신호로 다룹니다.
- 도메인 용어가 sprint 를 넘어 오래 살아야 할 때는 `docs/solon/domain-map.md` 같은 짧은 공유 문서로 남기는 방향을 안내합니다.
- 사용자가 굳이 멀티 에이전트 구성을 몰라도 됩니다. 작업이 작으면 기존처럼 `sfs plan`, `sfs implement`, `sfs review` 흐름으로 충분합니다.

## 0.6.12

이번 버전은 AI 가 코딩이나 문서 작업을 할 때 자주 놓치는 안전장치를 SFS 흐름 안에 얇게 넣은 릴리스입니다.

- agent 는 구현 전에 중요한 가정과 선택지를 먼저 드러냅니다. 불명확한 부분이 있으면 추측하지 않고 작은 질문으로 멈춥니다.
- 구현은 최소 유용 단위로 시작합니다. 요청과 직접 관련된 파일과 줄만 조심스럽게 건드립니다.
- 실제 파일, diff, 에러 로그, 테스트 출력을 읽고 판단하도록 kernel 과 command context 를 강화했습니다.
- 완료 전에는 가능한 가장 작은 테스트, 빌드, smoke, review check 를 실행하고 그 결과를 보고하도록 명시했습니다.
- `checklist.md` 와 `context-notes.md` 를 루트에 강제로 만들지 않습니다. 대신 SFS sprint workbench 문서 안에 계획, checklist, context note 를 남기도록 정리했습니다.
- 한국어 응답의 문장 끝 콜론 금지와 Korean-first 프로젝트의 새 source file 역할 헤더 규칙도 kernel 에 들어갔습니다.
- Claude, Codex, Gemini adapter 는 긴 규칙을 복제하지 않고 routed SFS context 를 따르도록 짧게 연결됩니다.
- Mac 에서 `sfs upgrade` 가 본체 업데이트를 못 할 때는 `brew upgrade MJ-0701/solon-product/sfs` 를 먼저 실행하시면 됩니다. 짧은 `brew upgrade sfs` 가 기대대로 동작하지 않는 경우까지 README, GUIDE, BEGINNER-GUIDE 에 보강했습니다.

## 0.6.11

이번 버전은 Solon 전체에 "남겨야 될 것만 남긴다" 원칙을 적용한 정리 릴리스입니다.

- `.sfs-local/` 은 기본 비공개 작업 공간으로 gitignore 됩니다.
- `sfs start` 는 더 이상 빈 절차 문서를 한 번에 만들지 않습니다. 각 단계 명령이 필요한 문서만 생성합니다.
- `sfs adopt --apply` 는 기존 프로젝트를 요약해서 `docs/solon/<id>-adoption-summary.md` 하나를 공유 문서로 남깁니다.
- adopt 의 raw scan, 과거 sprint, archive evidence 는 `.sfs-local/archives/` 에 private cold archive 로 접습니다.
- 이미 0.6.11 인 프로젝트도 `sfs upgrade` 를 다시 실행하면 예전 `legacy-baseline` sprint 와 빈 단계 문서 잔여물을 더 접습니다.
- 새로 생성되는 sprint 문서 템플릿은 설명문을 줄이고 실제로 채워야 할 칸만 남겼습니다.
- 새 설치는 빈 `sprints/`, `decisions/`, `queue/` 디렉터리를 미리 만들지 않습니다.

## 0.6.10

이번 버전은 Solon report 의 보이는 표면을 다시 손봤습니다.

- report 가 긴 bullet dump 처럼 보이지 않도록 title/verdict strip, 상태 패널, action rail, 질문 queue 구조를 명시했습니다.
- Claude, Gemini, Codex adapter template 모두 같은 report-surface 규칙을 갖습니다.
- 내용은 계속 간결하게 유지하지만, 사용자가 지금 봐야 할 판단/다음 행동이 더 먼저 보이도록 했습니다.

## 0.6.9

이번 버전은 "설치됐는데 실제로 바로 쓰려니 막히는" 부분을 닫는 핫픽스입니다.

- `sfs adopt "문서 정리좀 해야될거 같은데."` 처럼 기존 프로젝트를 정리하려는 자연어 brief 를 이제 정상으로 받습니다.
- `adopt` 는 기본 dry-run 입니다. 실제 파일을 만들려면 `sfs adopt --apply "..."` 를 쓰면 됩니다.
- `sfs context path adopt`, `sfs context path start`, `sfs context path sprint`, `sfs context path intake` 같은 agent routing 경로가 정상화됐습니다.
- CLI discovery 진단이 실패를 성공처럼 보이지 않게 정리됐습니다.
- Claude/Gemini/Codex 연결 메타데이터와 한국어 사용자 문서를 0.6.9 기준으로 맞췄습니다.

이미 0.6.8 을 설치했다면 `brew reinstall MJ-0701/solon-product/sfs` 또는 `sfs upgrade` 로 받으면 됩니다.

## 0.6.1

이번 버전은 Solon 이 "필요한 기준만 조용히 꺼내 쓰는" 감각을 더 또렷하게 만드는 작은 패치입니다.

- backend, 전략/PM, QA, 디자인/frontend, infra/DevOps, 경영관리, taxonomy 지식팩이 빈 목록이 아니라 실제 가이드로 채워졌습니다.
- Solo Founder 에게 꼭 필요한 재무, 경리, 세무, 회계, 인보이스, 현금 흐름, 외주/급여 증빙 기준도 경영관리 지식팩에 포함했습니다.
- 사용자는 여전히 `sfs plan`, `sfs review` 처럼 익숙한 명령만 쓰면 됩니다. Solon 이 작업 성격을 보고 필요한 관점만 얇게 읽습니다.
- 작은 문서 수정에는 작은 기준을, 배포나 구조 변경처럼 위험이 큰 작업에는 더 단단한 기준을 적용하는 쪽으로 안내가 정리됐습니다.
- 새로 설치한 프로젝트와 이미 작업 중인 프로젝트가 같은 지식팩을 보도록 active context 와 패키지 템플릿을 맞췄습니다.
- README 는 큰 지도 역할만 유지하고, 버전별 변화는 이 릴리스 노트에서 따로 확인하도록 정리했습니다.

추가로 외워야 하는 명령은 없습니다. 업데이트 후 평소처럼 `sfs status` 로 시작하면 됩니다.

## 0.6.0

이번 버전의 방향은 "프로젝트 안을 덜 어지럽게 만들고, 첫 실행을 더 빨리 성공시키는 것"입니다.

- `brew install` / `scoop install` 한 번이면 Claude Code, Gemini CLI, Codex CLI 에서 모두 Solon 을 찾습니다.
- 새 프로젝트에는 운영에 필요한 얇은 연결 문서와 `.sfs-local/` 기록 공간만 남습니다.
- 앱 뼈대는 Solon 이 특정 프레임워크로 고정하지 않습니다. 사용자가 Next.js/Spring 같은 말을 몰라도, 대화 중 필요해 보이면 AI 가 "초기 프로젝트 구성해드릴까요?"라고 묻고, 동의 시 크기에 맞는 native 구성을 잡은 뒤 Solon 으로 돌아오는 흐름을 권장합니다.
- 설치/업데이트 직후 SFS discovery 를 우선순위 1로 올립니다. 그래서 Solon 작업은 먼저 SFS 로 들어가고, 사용자가 나중에 직접 바꾼 우선순위는 존중합니다.
- 오래 걸리는 작업은 `sfs measure --alive -- <command>` 로 조용히 멈춘 것처럼 보이지 않게 진행 신호를 남길 수 있습니다.
- `review` 는 줄바꿈이나 이름만 바뀐 일을 과하게 문제 삼기보다, 사용자가 실제로 영향을 받는 변화에 더 집중합니다.
- 버전 이름은 이제 보통의 `0.6.0` 형태를 씁니다. 예전 `-product` 표기는 과거 릴리스 기록에만 남습니다.

처음 설치하거나 업데이트하는 방법은 [README.md](./README.md) 와 [GUIDE.md](./GUIDE.md) 에서 확인하세요.
