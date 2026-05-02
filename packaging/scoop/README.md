# Scoop Packaging

This directory contains the Scoop manifest template for the Solon Product SFS
runtime.

## Manifest Contract

`sfs.json.template` uses release-time placeholders:

- `__VERSION__`: version without the leading `v`, for example `0.5.42-product`.
- `__URL__`: archive URL, usually `https://github.com/MJ-0701/solon-product/archive/refs/tags/v__VERSION__.zip`.
- `__SHA256__`: SHA256 of the exact archive Scoop will download.
- `__EXTRACT_DIR__`: root directory inside the archive, for GitHub source zips usually `solon-product-__VERSION__`.

The manifest exposes `sfs` through `bin\\sfs.cmd`. The command wrapper locates
Git for Windows Bash and delegates to the packaged Bash entrypoint at
`bin/sfs`.

The manifest also runs `bin\\sfs-scoop-post-install.ps1` after install/update.
When `scoop update sfs` is launched from an initialized Solon project, that hook
runs `sfs.cmd upgrade --no-self-upgrade` from the detected project root so the
runtime and project surface move together. The deterministic user-facing command
is still `sfs.cmd update`: it runs `scoop update`, then `scoop update sfs`, then
the project upgrade. Set `SFS_SCOOP_PROJECT_UPGRADE=0` to skip the manifest hook;
`sfs.cmd update` / `sfs.cmd upgrade` set that variable internally while updating
the Scoop runtime, then perform the project upgrade themselves.

In PowerShell/cmd examples, use `sfs.cmd ...` explicitly. Git Bash/WSL users can
use `sfs ...`.

## Local Windows Smoke

The GitHub Actions workflow builds a local source zip from the checkout,
renders a temporary bucket manifest with a `file:///` URL, and then runs:

```text
scoop bucket add solon <temporary-bucket-path>
scoop install sfs
sfs.cmd version
sfs.cmd --help
mkdir test-project
cd test-project
git init
sfs.cmd init --layout thin --yes
sfs.cmd status
sfs.cmd agent install all
scoop update sfs --force
```

The thin-layout assertion is important: project-local `.sfs-local/` must not
receive runtime `scripts/`, `sprint-templates/`, `personas/`, or
`decisions-template/` directories unless the user explicitly chooses vendored
layout.

## Release Bucket Flow

For a real bucket release, render `bucket/sfs.json` in the own Scoop bucket repo
after the GitHub tag exists and the downloadable archive hash is known. The
bucket can then be tested with:

```text
scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs
sfs.cmd version --check
sfs.cmd update
```
