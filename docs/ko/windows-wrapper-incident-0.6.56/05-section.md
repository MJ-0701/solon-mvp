---
doc_id: sfs-windows-wrapper-incident-0-6-56-ko-5
title: "원인"
visibility: oss-public
doc_type: incident-report
language: ko
updated: 2026-05-22
parent: docs/ko/windows-wrapper-incident-0.6.56.md
summary: "원인"
load_when: "Read when docs/ko/windows-wrapper-incident-0.6.56.md routes to this section."
---
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

