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

## Local Windows Smoke

The GitHub Actions workflow builds a local source zip from the checkout,
renders a temporary bucket manifest with a `file:///` URL, and then runs:

```text
scoop bucket add solon <temporary-bucket-path>
scoop install sfs
sfs version
sfs --help
mkdir test-project
cd test-project
git init
sfs init --layout thin --yes
sfs status
sfs agent install all
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
scoop bucket add solon <our-bucket-url>
scoop install sfs
```
