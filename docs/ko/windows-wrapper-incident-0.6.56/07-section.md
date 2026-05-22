---
doc_id: sfs-windows-wrapper-incident-0-6-56-ko-7
title: "발견된 문제점"
visibility: oss-public
doc_type: incident-report
language: ko
updated: 2026-05-22
parent: docs/ko/windows-wrapper-incident-0.6.56.md
summary: "발견된 문제점"
load_when: "Read when docs/ko/windows-wrapper-incident-0.6.56.md routes to this section."
---
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

