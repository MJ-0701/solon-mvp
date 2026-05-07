# Windows SFS 래퍼 장애 요약 보고서 (0.6.35 → 0.6.37)

**Language**: 한국어 / [English](../en/windows-wrapper-incident-0.6.37.md)

이 문서는 Windows PC 에서 `$sfs start 이미지 프롬프트 고도화` 를 실행했을 때 드러난
`sfs.cmd` / `sfs.ps1` 래퍼 문제를 다음 세션과 다음 릴리스 검증자가 바로 이해하도록 남긴
요약 보고서입니다.

## 한 줄 결론

Windows 에서는 성공이 확인된 경로, 즉 `sfs.cmd -> sfs.ps1 -> Bash runtime` bridge 로 고정해야
했습니다. raw Git Bash `%*` 직행 경로는 sandbox, 인자 전달, UTF-8 출력에서 실패한 이력이 있으므로
상태 변경 명령의 기본 경로로 쓰지 않습니다.

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

1. `bin/sfs.ps1` 의 catch-all 인자 정의가 일부 `powershell.exe -File ...` 호출 모양에서
   위치 인자를 안정적으로 받지 못했습니다. 그래서 실제 명령이 빠지고 help 경로로 떨어졌습니다.
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

## 적용된 수정

- `sfs.cmd` 는 native read-only dispatch 를 먼저 시도하고, 나머지 명령도 packaged
  `sfs.ps1` bridge 를 거쳐 Bash runtime 으로 내려갑니다.
- `sfs.cmd` 는 mutating command 를 raw Git Bash `%*` 로 보내지 않습니다.
- `sfs.ps1` 은 `Position = 0` catch-all, automatic `$args` fallback, nested array, accidental
  literal `-SfsArgs` 모양을 같은 인자 목록으로 정규화합니다.
- `sfs.ps1` 은 가능한 경우 UTF-8 console/native-command encoding 과 `LANG=C.UTF-8`,
  `LC_CTYPE=C.UTF-8` 을 맞춥니다.
- Windows guard test 는 실제 Windows host 에서 가능하면
  `powershell.exe -File sfs.ps1 context cat kernel` 과 `status` 를 실행해 usage-only 회귀를 잡습니다.
- 0.6.36 에서는 Homebrew installed layout 도 이해하도록 문서 테스트의 `CHANGELOG.md` /
  `RELEASE-NOTES.md` 위치 해석을 보강했습니다.
- 0.6.37 에서는 `sfs.cmd` 가 Scoop self-upgrade 를 직접 실행하지 않습니다. batch wrapper 는
  native read-only 판단 뒤 `sfs.ps1` 로 넘기고, `sfs.ps1` 이 메모리 실행 상태에서
  `scoop update` / `scoop update sfs` / 새 런타임 재호출을 맡습니다.

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
  안 됩니다. Windows self-upgrade 의 소유자는 `sfs.ps1` 입니다.

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

## 검증 증거

- `tests/test-windows-agent-adapter-fallback.sh` 는 `sfs.cmd -> sfs.ps1 -> Bash runtime` bridge 와
  raw Git Bash `%*` 비사용을 고정합니다. 또한 `sfs.cmd` 가 `call scoop update` 를 직접 실행하지
  않고 `sfs.ps1` 이 Scoop self-upgrade 를 소유하는지 확인합니다.
- `tests/test-docs-model-routing.sh` 는 source layout 과 Homebrew installed layout 의 문서 위치를
  함께 검증합니다.
- 0.6.36 릴리스 검증에서는 installed Homebrew runtime 의 Windows wrapper/docs 관련 focused test 와
  `scripts/verify-product-release.sh --version 0.6.36 --no-clean-handoff-check` 가 통과했습니다.
- 0.6.37 은 Windows `sfs.cmd upgrade` self-replacement 오류를 막기 위한 후속 핫픽스입니다.
