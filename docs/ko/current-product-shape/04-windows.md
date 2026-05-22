---
doc_id: sfs-current-product-shape-ko-4
title: "Windows 래퍼 안정화"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-22
parent: docs/ko/current-product-shape.md
summary: "Windows 래퍼 안정화"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## Windows 래퍼 안정화

Windows PowerShell/cmd 의 사용자 진입점은 `sfs.cmd` 로 고정합니다. Git Bash/WSL 에서는
macOS/Linux 처럼 `sfs` 를 씁니다. 현재 Scoop manifest 는 generated shim 이
packaged `bin\sfs.ps1` 을 직접 호출하도록 유지하지만, Scoop 이 생성한 `sfs.cmd` / `sfs.ps1`
shim 이 인자를 버리는 경로가 확인되어 post-install hook 이 shims 디렉터리의 `sfs.cmd`,
`sfs.ps1`, extensionless `sfs` 를 deterministic wrapper 로 덮어씁니다. PowerShell/cmd smoke 와
사용자 안내는 인자 전달이 확인된 `sfs.cmd` 경로만 통과 조건으로 봅니다. packaged `sfs.cmd` 는
직접 실행/호환용 thin PowerShell trampoline 으로 유지하고, `SFS_NATIVE_ARGC` /
`SFS_NATIVE_ARG_N` 번호 환경 변수 bridge 로 `sfs.ps1` 에 인자를 넘깁니다. 이 값도 비면
`sfs.ps1` 이 `SFS_NATIVE_RAW_ARGS`, delayed-expansion `SFS_NATIVE_CMDLINE`,
parent `cmd.exe` command line, `CMDCMDLINE` 순서로
fallback 을 읽습니다. command-line parser 는 `&& sfs.cmd --help` 같은 `cmd.exe`
shell-control tail 도 잘라냅니다.
`sfs.ps1` 이 read-only
명령과 `start` 같은 상태 변경 명령을 모두 소유합니다. 상태 변경 명령은
`sfs.cmd -> sfs.ps1 -> Bash runtime` bridge 로 내려갑니다. hardened Scoop `sfs.cmd` shim 은
numbered env bridge 를 먼저 기록하고, `sfs.ps1` 이 그 값이 비어 있을 때 saved raw tail 을
fallback 으로 다시 읽습니다. 이는 generated Scoop shim 아래에서 실패했던 단일 `-File ... %*`
bridge 와 다릅니다. 실패 이력이 있는 raw Git Bash `%*`
직행 경로, batch label forwarding, 단일 `-File ... %*` bridge, `-Command @args`, empty `%1..%n`, generated bare
`sfs` PowerShell shim 경로, generated shim -> packaged `.cmd` 경로, generated `sfs.cmd` shim
경로는 기본값으로 쓰지 않습니다.
`sfs.cmd upgrade` 도 batch 파일이 직접 `scoop update sfs` 를 실행하지 않고 `sfs.ps1` self-upgrade
경로로 넘깁니다. `sfs.ps1` 은 numbered env bridge, raw arg tail, saved cmdline,
parent command line, `CMDCMDLINE`, `$MyInvocation.UnboundArguments` 순서로 인자를 정규화하고, `version`, `status`, `guide`,
`context`, Scoop self-upgrade, Bash fallback 을 모두 처리합니다. 또한 `sfs.cmd` 가 PowerShell 호출 뒤 같은 parsed line 에서 종료하고
Windows runtime `.ps1` / `.cmd` 파일을 ASCII-safe 로 유지해 `context cat` / `start` usage-only
회귀, batch tail fragment, PowerShell 5.1 parser 회귀를 함께 막습니다.

`sfs start` 후 sprint 디렉터리가 비어 있는 것은 정상일 수 있습니다. 단계별 문서는
`brainstorm`, `plan`, `review`, `retro` 에서 필요할 때 생성됩니다. 하지만 명령 출력이 비어 있거나
`sfs.cmd status` / `sfs.cmd context cat kernel` 이 usage 만 출력하면 실패로 봐야 합니다.
자세한 원인과 확인 절차는
[Windows SFS 래퍼 장애 요약 보고서](./windows-wrapper-incident-0.6.56.md) 에 정리되어 있습니다.

