#!/usr/bin/env bash
# Windows ps1 -> bash 브리지: POSIX PATH 를 선행시킨 뒤 실제 entrypoint 로 exec 한다.
#
# 0.8.65 (pwsh arg-passing fix): the 0.8.54-0.8.55 bridge inlined this prelude
# on the ps1 command line as `bash -c '<prelude>' "sfs" <script> <args>`.
# Windows PowerShell 5.1 (Legacy raw argument passing) delivered that byte
# sequence in the real-Windows-verified form, but pwsh 7.3+ on the CI runner
# (PSNativeCommandArgumentPassing=Windows, which applies Standard escaping to
# bash.exe) collides with the MSYS2 command-line re-parse: the quoted prelude
# swallowed the script path + args, `exec bash "$@"` ran with an empty $@, and
# the bridge silently no-opped with rc 0 (scoop-smoke red since 0.8.54, hard
# evidence: run 28742085408 — PS_BASH_ARGS intact, bridge rc 0, no .sfs-local).
# Shipping the prelude as this FILE removes every embedded quote and space-
# sensitive token from the ps1 native command line — both PowerShell editions
# pass plain path/word arguments identically, so there is nothing left to
# re-parse differently.
#
# Contract (unchanged from 0.8.54/0.8.55, see test-windows-bash-bridge-path.sh):
# - /usr/bin:/bin PREPENDED ahead of $PATH (POSIX mktemp/dirname/timeout must
#   beat C:\Windows\System32\timeout.exe); parent $env:PATH never mutated.
# - mktemp probe is warn-only — never a hard fail on a working install.
# - exec bash "$@" preserves the original entrypoint path + args ($@ = script
#   followed by the forwarded sfs args). Non-login, non-interactive: no user
#   profile sourcing.
export PATH=/usr/bin:/bin:"$PATH"
command -v mktemp >/dev/null 2>&1 || printf "sfs: POSIX utilities (mktemp/dirname/timeout) not found even after adding /usr/bin:/bin to PATH; your Git for Windows install may be incomplete - reinstall Git for Windows or set SFS_BASH to a complete bash.exe.\n" >&2
exec bash "$@"
