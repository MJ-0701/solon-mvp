# Windows Codex Handoff - SFS 0.6.56

작성 시각: 2026-05-08 KST

## 바로 이어받는 발화명령어

Windows Codex 앱에서 이 repo/branch 를 연 뒤 아래처럼 말하면 됩니다.

```text
SFS 0.6.56 Windows sfs.cmd self-upgrade trace 이어서 봐줘. HANDOFF-windows-codex-0.6.56.md 읽고, GitHub Actions run 25559894888 로그에서 sfs.cmd upgrade live trace 마지막 줄부터 원인 고쳐줘. 개발 중에는 SFS_WINDOWS_ARG_TRACE=1 / SFS_UPGRADE_TRACE=1 로그를 켜고, 통과하면 운영 기본 로그는 조용하게 유지해.
```

짧은 alias:

```text
윈도우 sfs.cmd update 재실행 버그 이어서
```

## 현재 branch

- Repo: `MJ-0701/solon-product`
- Branch: `codex/windows-wrapper-trace-0-6-56`
- Latest trace commit: `22d7d4d` (`수정: Windows update 재실행 env 정규화`)
- Current Windows workflow run: `25559894888`
- Job id: `75028412888`

## 지금까지 확정한 원인

1. `sfs.cmd upgrade` 는 사용자-facing spelling 이지만, self-upgrade 뒤 재실행은 canonical `update` 로 들어가야 합니다.
2. 이전 trace 에서 `PS_RELOAD_ARGS=update` 까지는 갔지만, 부모 process 에 남아 있던 `SFS_NATIVE_ARG_1=upgrade` 가 다시 우선 선택되어 Bash runtime 으로 `upgrade` 가 들어갔습니다.
3. PowerShell one-token array 가 scalar 로 무너져 `PS_AUTOMATIC_ARGS=[u|p|d|a|t|e]` 처럼 보이는 증상도 같이 있었습니다.
4. 그래서 `bin/sfs.ps1` 은 이제 `$reloadArgs = [string[]] @(Normalize-SfsScoopReloadArgs ...)` 로 고정하고, `Set-SfsNativeArgEnv $reloadArgs` 로 stale `SFS_NATIVE_ARG_*`, raw args, saved cmdline 을 canonical `update` 로 다시 씁니다.
5. `upgrade.sh` 는 `SFS_UPGRADE_TRACE=1` 일 때만 phase trace 를 출력합니다. 운영 기본값은 조용합니다.

## 이미 통과한 Mac 로컬 검증

```bash
cd /Users/mj/agent_architect/2026-04-19-sfs-v0.4/solon-mvp-dist
bash tests/test-windows-agent-adapter-fallback.sh
bash tests/test-windows-wrapper-incident-report.sh
bash tests/test-agent-behavior-guardrails.sh
bash -n bin/sfs
bash -n upgrade.sh
bash tests/run-all.sh
```

결과: `tests/run-all.sh` PASS 48 / FAIL 0.

## Windows 에서 바로 볼 로그

job 이 끝난 뒤:

```powershell
gh run view 25559894888 --repo MJ-0701/solon-product --job 75028412888 --log
```

먼저 찾을 문자열:

```text
sfs.cmd upgrade live trace
SFS_ARGTRACE_PS_RELOAD_ARGS
SFS_ARGTRACE_PS_ENV_ARGS
SFS_ARGTRACE_PS_SELECTED_SOURCE
SFS_ARGTRACE_PS_BASH_ARGS
[sfs-upgrade-trace]
```

정상 기대값:

```text
SFS_ARGTRACE_PS_RELOAD_ARGS=[update]
SFS_ARGTRACE_PS_ENV_ARGS=[update]
SFS_ARGTRACE_PS_SELECTED_SOURCE=env
SFS_ARGTRACE_PS_BASH_ARGS=[update]
```

`PS_ENV_ARGS=upgrade`, `PS_BASH_ARGS=upgrade`, `[u|p|d|a|t|e]`, 또는 `업그레이드 진행?` 이후 phase trace 가 끊기면 그 줄이 다음 원인입니다.

## 변경 파일 핵심

- `bin/sfs.ps1`: `upgrade -> update` canonical reload, stale env rewrite, one-token array 보존.
- `upgrade.sh`: CI 에서 `/dev/tty` 재연결 금지, `SFS_UPGRADE_TRACE=1` phase trace.
- `.github/workflows/windows-scoop-smoke.yml`: `SFS_WINDOWS_ARG_TRACE=1` + `SFS_UPGRADE_TRACE=1`, `Tee-Object` live stream.
- `tests/test-windows-agent-adapter-fallback.sh`: stale env rewrite와 trace 계약 회귀 방지.
- `docs/*/windows-wrapper-incident-0.6.56.md`: P25 까지 원인 기록.

## 추가 제품 품질 수정

- 결정 질문은 `Q1 / 추천 A` 만 보여주면 안 됩니다. 모든 선택지의 뜻과 결과를 보여주고 추천은 default 로만 표시합니다.
- 선택지가 너무 많으면 숨기지 말고 하나씩 순차 질문합니다.
- `.sfs-local/events.jsonl`, `cache/`, `tmp/`, `archives/`, `queue/runs/`, `migrate-tx/` 는 private/disposable 입니다. 공유 결론은 `docs/solon/` 또는 sprint `report.md` 로 남깁니다.

## 다음 액션

1. `25559894888` 완료 로그를 열고 `sfs.cmd upgrade live trace` group 을 확인합니다.
2. 위 정상 기대값과 다르면 마지막 trace 줄 기준으로 `bin/sfs.ps1` 또는 `upgrade.sh` 를 고칩니다.
3. 다시 commit/push 후 `windows-scoop-smoke.yml` 를 같은 branch 로 재실행합니다.
4. Windows smoke 가 PASS 하면 dev repo 에 동기화하고 0.6.56 stable release, Homebrew tap, Scoop bucket 을 배포합니다.
