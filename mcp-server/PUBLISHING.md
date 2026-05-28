---
doc_id: solon-mcp-publishing
title: "Publishing the solon-mcp PyPI package"
visibility: oss-public
doc_type: mcp-server-doc
language: en
updated: 2026-05-28
summary: "Step-by-step for cutting a solon-mcp release to PyPI so consumers can `pipx install solon-mcp`. This is a maintainer-side document; consumers do not need to read it."
load_when: "Read when bumping mcp-server/pyproject.toml version, or when wiring up the GitHub Actions publish workflow."
---

# Publishing `solon-mcp` to PyPI

The MCP server bridge ships as a separate Python package, `solon-mcp`, that
lives under `mcp-server/`. The Solon distribution itself (the `sfs` CLI,
templates, etc.) does not depend on it — `solon-mcp` is an optional
bridge so MCP-capable hosts (Claude Desktop, Claude in Chrome, Cursor,
Claude Agent SDK) can call `sfs` over JSON-RPC stdio.

This document is the maintainer-side recipe for publishing. Consumers
should read `mcp-server/README.md` instead.

## Current state (0.7.3)

- The package is **not yet on PyPI**. Users install from source clone:
  `pip install -e ./mcp-server` (from the solon-product repo root).
- `pipx install solon-mcp` is documented in `mcp-server/README.md` as the
  *target shape* once the first PyPI cut lands. It is not a currently
  working command.
- This document, plus the planned GitHub Actions workflow below, is
  what closes that gap.

## When to cut a release

Bump `mcp-server/pyproject.toml` `version = "..."` and publish whenever:

1. A new sfs-flow tool is added to `solon_mcp_server.py` (host visibility
   only updates when the bridge ships).
2. The bash-SSoT forwarding contract changes (e.g. timeout knobs, error
   shape).
3. The Solon distribution itself crosses a minor bump that adds tools
   the bridge wants to expose.

`solon-mcp` follows its own semver track, independent of the main
distribution. Right now they march together (both at 0.7.x), but a small
solon-mcp fix can ship without bumping the main `VERSION`, and vice
versa.

## Manual cut (until GitHub Actions lands)

```bash
cd mcp-server

# 1. Confirm the version you want in pyproject.toml [project].version.
#    Bump if needed and commit.
grep '^version' pyproject.toml

# 2. Clean any prior build artifacts (.gitignore already excludes these
#    but a stale dist/ can confuse twine).
rm -rf build/ dist/ *.egg-info/

# 3. Build the sdist + wheel.
python3 -m pip install --upgrade build twine
python3 -m build

# 4. Smoke check the built artifact loads.
python3 -m twine check dist/*

# 5. Upload to TestPyPI first.
python3 -m twine upload --repository testpypi dist/*

# 6. Smoke install from TestPyPI in a throwaway venv.
python3 -m venv /tmp/solon-mcp-smoke && source /tmp/solon-mcp-smoke/bin/activate
pip install --index-url https://test.pypi.org/simple/ \
            --extra-index-url https://pypi.org/simple/ \
            solon-mcp
solon-mcp --help 2>/dev/null || echo "ready"
deactivate && rm -rf /tmp/solon-mcp-smoke

# 7. Upload to real PyPI.
python3 -m twine upload dist/*

# 8. Tag the cut on git (separate tag namespace from main VERSION).
git tag mcp-server-v$(grep '^version' pyproject.toml | head -1 | sed 's/[^"]*"\([^"]*\)".*/\1/')
git push origin --tags
```

You need a PyPI account with maintainer rights on `solon-mcp`, plus a
`~/.pypirc` or `TWINE_PASSWORD` env. None of those secrets ever land in
the solon-product repo; they live on the maintainer's machine.

## Planned GitHub Actions workflow (future)

`.github/workflows/mcp-server-publish.yml` (not yet shipped) will:

1. Trigger on tag push matching `mcp-server-v*`.
2. Run the smoke pytest under `templates/claude-agent-sdk-zero/tests/` to
   verify the bridge surface is sane.
3. Build sdist + wheel.
4. Upload to PyPI using a stored `PYPI_API_TOKEN` repository secret.

Until that workflow is wired up, follow the manual recipe above.

## What is NOT yet automated

- Version bump in `pyproject.toml` is manual. A future patch could derive
  it from the main `VERSION` file, but they intentionally float
  independently right now.
- Generating the `CHANGELOG.md` entry for solon-mcp is manual. The main
  `CHANGELOG.md` mentions solon-mcp changes in its sections, but
  solon-mcp does not have its own changelog yet.
- Announcement (Twitter / Discord / mailing list) is manual.

## Related artifacts

- [`README.md`](README.md) — consumer-facing install + host registration.
- [`solon_mcp_server.py`](solon_mcp_server.py) — the bridge itself.
- [`pyproject.toml`](pyproject.toml) — package metadata.
- [`../tests/test-mcp-server-contract.sh`](../tests/test-mcp-server-contract.sh)
  — static contract test that locks the tool surface.
