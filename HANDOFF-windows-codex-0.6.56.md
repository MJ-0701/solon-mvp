# Windows Codex Handoff - SFS 0.6.56

작성 시각: 2026-05-08 23:35 KST

## 바로 이어받는 발화명령어

Windows Codex 앱에서 `MJ-0701/solon-product` repo 의
`codex/windows-wrapper-trace-0-6-56` branch 를 연 뒤 아래처럼 말하세요.

```text
SFS 0.6.56 Windows sfs.cmd self-upgrade 이어서 고쳐줘. HANDOFF-windows-codex-0.6.56.md 먼저 읽고, run 25560808383/job 75031590402 로그에서 "completion output after" 뒤에 sfs.cmd가 PowerShell로 반환되지 않는 문제를 trace해. 개발 중에는 SFS_WINDOWS_ARG_TRACE=1, SFS_UPGRADE_TRACE=1을 켜고, 원인 확인 후 운영 기본 로그는 조용하게 유지해. 무한 대기/참조순환/stack overflow 가능성은 금지.
```

짧은 alias:

```text
윈도우 sfs.cmd completion output after 반환 안됨 이어서
```

## 현재 branch / run

- Repo: `MJ-0701/solon-product`
- Branch: `codex/windows-wrapper-trace-0-6-56`
- Latest pushed code before this handoff: `2c2de83` (`수정: upgrade discovery 대기 제한`)
- Latest Windows run: `25560808383`
- Job id: `75031590402`
- Result: Mac 쪽에서 5분 이상 같은 step 에 머물러 취소함. 로그는 남아 있음.

## 핵심 결론

`sfs.cmd upgrade` 의 `upgrade -> update` 치환, stale env 제거, one-token array 보존은 이제 정상입니다.

`25560808383` 로그에서 확인된 정상값:

```text
SFS_ARGTRACE_PS_RELOAD_ARGS=[update]
SFS_ARGTRACE_PS_ENV_RAW_ARGS=update
SFS_ARGTRACE_PS_ENV_SAVED_CMDLINE=sfs.cmd update
SFS_ARGTRACE_PS_ENV_ARGS=update
SFS_ARGTRACE_PS_SELECTED_SOURCE=env
SFS_ARGTRACE_PS_FINAL_ARGS=update
SFS_ARGTRACE_PS_BASH_ARGS=[update]
```

`upgrade.sh` 본문도 끝까지 도달했습니다.

```text
[sfs-upgrade-trace] ... cli-discovery hook before timeout=30s
[sfs-upgrade-trace] ... cli-discovery hook start timeout=30s
[sfs-upgrade-trace] ... cli-discovery hook exit rc=0
[sfs-upgrade-trace] ... cli-discovery hook after
[sfs-upgrade-trace] ... completion hint render before
[sfs-upgrade-trace] ... completion hint render after
[sfs-upgrade-trace] ... completion output before
[sfs-upgrade-trace] ... completion output after
```

따라서 현재 남은 문제는 Bash upgrade 본문 내부 loop 가 아니라, `completion output after` 이후
`sfs.cmd`/`sfs.ps1`/PowerShell pipeline 이 호출자에게 반환되지 않는 문제입니다.

가장 의심되는 지점:

- `upgrade.sh` 의 background watchdog/sleep 이 Windows PowerShell pipe handle 을 붙잡는 문제.
- Git Bash child/grandchild process 가 stdout/stderr handle 을 닫지 않아 `& sfs.cmd upgrade 2>&1 | Tee-Object ...` 가 끝나지 않는 문제.
- `bin/sfs.ps1` 의 final Bash bridge가 `& $bash ... @bashArgs` 이후 `$LASTEXITCODE` 까지 못 돌아오는 문제.

Mac 에서 마지막으로 넣은 작은 보강:

- `upgrade.sh` 의 `run_upgrade_command_with_timeout` 이 이제 먼저 POSIX `timeout(1)` 을 사용합니다.
- `timeout(1)` 이 CI 에 없으면 background watchdog 을 만들지 않고 skip/warn 하게 했습니다.
- 이 보강은 아직 Windows run 으로 검증하지 않았습니다. Windows 에서 먼저 이 커밋이 포함됐는지 확인하세요.

## Windows 에서 바로 실행할 명령

```powershell
git fetch origin codex/windows-wrapper-trace-0-6-56
git switch codex/windows-wrapper-trace-0-6-56
git pull --ff-only
gh run view 25560808383 --repo MJ-0701/solon-product --job 75031590402 --log
```

새 smoke 실행:

```powershell
gh workflow run windows-scoop-smoke.yml --repo MJ-0701/solon-product --ref codex/windows-wrapper-trace-0-6-56
gh run watch --repo MJ-0701/solon-product --exit-status
```

로컬 Windows 재현을 할 수 있으면 우선 이 환경변수로 실행:

```powershell
$env:SFS_WINDOWS_ARG_TRACE = "1"
$env:SFS_UPGRADE_TRACE = "1"
$env:SFS_CLI_DISCOVERY_TIMEOUT_SEC = "30"
$env:SFS_DISCOVERY_CMD_TIMEOUT_SEC = "5"
sfs.cmd upgrade
```

반환 여부를 더 좁히려면 `bin/sfs.ps1` 의 final Bash bridge 주변에 임시 trace 를 추가:

```powershell
Write-SfsArgTrace "PS_BEFORE_BASH_BRIDGE" $bashArgs
& $bash (Convert-ToBashPath $sfsSh) @bashArgs
Write-SfsArgTrace "PS_AFTER_BASH_BRIDGE_LASTEXITCODE" $LASTEXITCODE
exit $LASTEXITCODE
```

`PS_AFTER_BASH_BRIDGE_LASTEXITCODE` 가 안 찍히면 PowerShell 이 Git Bash process 반환을 기다리는 중입니다.
찍히는데 workflow 가 안 끝나면 `Tee-Object` pipeline/descendant handle 문제입니다.

## 이미 통과한 Mac 로컬 검증

```bash
cd /Users/mj/agent_architect/2026-04-19-sfs-v0.4/solon-mvp-dist
bash tests/test-windows-agent-adapter-fallback.sh
bash tests/test-windows-wrapper-incident-report.sh
bash tests/test-agent-behavior-guardrails.sh
bash tests/test-cli-discovery-macos.sh
bash tests/test-sfs-upgrade-minimal-residue-migration.sh
bash -n bin/sfs
bash -n upgrade.sh
bash -n scripts/install-cli-discovery.sh
git diff --check
bash tests/run-all.sh
```

결과: `tests/run-all.sh` PASS 48 / FAIL 0.

## 변경 파일 핵심

- `bin/sfs.ps1`: `upgrade -> update` canonical reload, stale env rewrite, one-token array 보존, final Bash args trace.
- `upgrade.sh`: CI `/dev/tty` 재연결 금지, `SFS_UPGRADE_TRACE=1`, 후반 trace, CLI discovery timeout.
- `scripts/install-cli-discovery.sh`: external `claude`/`gemini`/`git clone` probe timeout.
- `.github/workflows/windows-scoop-smoke.yml`: live `Tee-Object`, `SFS_WINDOWS_ARG_TRACE=1`, `SFS_UPGRADE_TRACE=1`.
- `tests/test-windows-agent-adapter-fallback.sh`: Windows wrapper/timeout guardrail.
- `docs/*/windows-wrapper-incident-0.6.56.md`: P26 까지 기록.

## 제품 품질 정책 반영

- 개발/패치 단계에서는 trace 를 켜서 마지막 정상 지점을 남긴다.
- 운영 기본값은 조용해야 한다. trace 는 `SFS_WINDOWS_ARG_TRACE=1`, `SFS_UPGRADE_TRACE=1` 같은 opt-in 으로만 켠다.
- 무한 대기, 재귀 self-upgrade, stale env replay, background watchdog orphan 은 금지한다.
- 결정 질문은 추천만 보여주지 않는다. 모든 선택지의 뜻/결과를 보여주고 추천은 default 로만 표시한다.
- `.sfs-local/events.jsonl`, `cache/`, `tmp/`, `archives/`, `queue/runs/`, `migrate-tx/` 는 disposable/private 이며 공유 결론은 `docs/solon/` 또는 sprint report 로 남긴다.

## 다음 액션

1. Windows 에서 최신 branch 를 pull 한다.
2. `25560808383` 로그의 `completion output after` 이후 반환 문제를 기준으로 `bin/sfs.ps1` final Bash bridge trace 를 추가한다.
3. `PS_AFTER_BASH_BRIDGE_LASTEXITCODE` 가 찍히는지 확인한다.
4. 안 찍히면 Git Bash child/grandchild handle 문제로 보고 `upgrade.sh` background process 를 더 제거하거나 CI 에서는 CLI discovery 를 완전히 skip 한다.
5. 찍히면 PowerShell workflow pipeline 쪽으로 보고 `& sfs.cmd upgrade` 호출을 `Start-Process` 또는 temp log redirection 방식으로 바꿔 descendant pipe hold 를 차단한다.
6. Windows smoke PASS 후 stable release, Homebrew tap, Scoop bucket 배포를 진행한다.
