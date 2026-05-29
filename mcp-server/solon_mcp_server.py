#!/usr/bin/env python3
# solon_mcp_server.py
#
# Solon Product — host-agnostic MCP server.
#
# Exposes the `sfs` 7-step flow as MCP tools so any MCP-capable host
# (Claude Desktop, Claude in Chrome, Cursor, Claude Agent SDK, etc.) can
# drive a Solon project without the bash CLI surface in the middle.
#
# Design constraints (kernel.md):
#
#   - bash adapter output is SSoT and must be verbatim.
#     This server shells out to the installed `sfs` binary and forwards
#     stdout verbatim. It does NOT reshape JSON, drop warnings, or rewrite
#     evidence. If it cannot run `sfs`, it surfaces the error verbatim too.
#
#   - The MCP server is an optional bridge, not a runtime dep of Solon.
#     Solon itself stays bash-first. Consumers who do not run an MCP host
#     never see this file. Consumers who do run an MCP host get the same
#     7-step contract as the CLI, just over JSON-RPC stdio.
#
#   - Tool names are 1:1 with `sfs <cmd>` — `sfs status` → `sfs_status`,
#     `sfs harness doctor` → `sfs_harness_doctor`. Aliasing the surface
#     would create a second mental model and divergence pressure.
#
# Tools shipped in this MVP (0.7.0):
#
#   sfs_status, sfs_version, sfs_start, sfs_brainstorm, sfs_plan,
#   sfs_implement, sfs_review, sfs_retro, sfs_decision, sfs_capture,
#   sfs_report, sfs_report_bug, sfs_flowcheck, sfs_harness_doctor
#
# Tools intentionally excluded from MVP:
#
#   sfs_commit       — host already has a git surface; running it via MCP
#                      tool can mask audit context.
#   sfs_loop         — parallel-worker spawn; gating that through MCP
#                      needs a separate UX design (multi-stream output).
#   sfs_tidy         — destructive; needs an explicit confirmation flow
#                      inside the MCP tool surface.
#
# Add later via follow-up patches once UX patterns settle.

from __future__ import annotations

import os
import shutil
import subprocess
from typing import Optional


try:
    from mcp.server.fastmcp import FastMCP
except ImportError as exc:  # pragma: no cover
    raise SystemExit(
        "solon-mcp: missing dependency `mcp`. Install with:\n"
        "    pipx install solon-mcp\n"
        "  or\n"
        "    pip install mcp\n"
    ) from exc


mcp = FastMCP("solon")


SFS_MCP_TIMEOUT_SEC = int(os.environ.get("SOLON_MCP_TIMEOUT_SEC", "300"))


def _run_sfs(args: list[str]) -> str:
    """Run `sfs <args...>` in CWD and return its verbatim stdout (and a
    fenced stderr/rc tail on failure). Never reshapes adapter output.

    Honors $SOLON_MCP_TIMEOUT_SEC (default 300s) so a stuck executor
    cannot wedge the host. The non-zero rc message keeps the same shape
    so downstream tooling can parse it.
    """
    sfs = shutil.which("sfs") or os.environ.get("SOLON_MCP_SFS_PATH") or "sfs"
    try:
        proc = subprocess.run(
            [sfs, *args],
            capture_output=True,
            text=True,
            timeout=SFS_MCP_TIMEOUT_SEC,
            check=False,
        )
    except FileNotFoundError:
        return (
            "solon-mcp: `sfs` binary not found on PATH.\n"
            "Install Solon Product first (Homebrew tap / Scoop bucket / source clone)\n"
            "or set $SOLON_MCP_SFS_PATH to the absolute path of the `sfs` script.\n"
        )
    except subprocess.TimeoutExpired:
        return (
            f"solon-mcp: `sfs {' '.join(args)}` timed out after "
            f"{SFS_MCP_TIMEOUT_SEC}s. Raise $SOLON_MCP_TIMEOUT_SEC for a one-off run.\n"
        )

    out = proc.stdout or ""
    if proc.returncode != 0:
        # SSoT verbatim: append stderr fenced so callers can still see it,
        # but never rewrite stdout itself.
        out += (
            f"\n\n[sfs rc={proc.returncode}]\n"
            f"{proc.stderr or '<empty stderr>'}\n"
        )
    return out


# ─────────────────────────────────────────────────────────────────────
# Read-only entry surface
# ─────────────────────────────────────────────────────────────────────


@mcp.tool()
def sfs_status() -> str:
    """Solon dashboard. Reads .sfs-local/ and prints the current sprint id,
    gate, divisions, recent evidence, and next-step hint. Safe to call
    often; never mutates state."""
    return _run_sfs(["status"])


@mcp.tool()
def sfs_version() -> str:
    """Show the installed `sfs` version and (when reachable) the latest
    release headline from the source repo."""
    return _run_sfs(["version", "--check"])


@mcp.tool()
def sfs_report() -> str:
    """Print the active sprint's report.md (and route docs/solon/ shared
    handoff entries) without launching an editor."""
    return _run_sfs(["report"])


@mcp.tool()
def sfs_report_bug() -> str:
    """File an SFS-PRODUCT bug to the official GitHub Issues channel
    (MJ-0701/solon-product, label `bug`), then gate fix work on explicit
    user confirmation. Prints the official channel + report procedure +
    confirm-gate contract; distinct from `sfs_report` (the sprint report)."""
    return _run_sfs(["report-bug"])


@mcp.tool()
def sfs_flowcheck(sprint: str = "") -> str:
    """Run `sfs flowcheck` — Flow-Conformance Postflight self-check that SFS
    executed per its documented flow. Reads the sprint's non-collapsing flow
    events + capture ledger and asserts the FCP invariants (model-tier,
    conflict-surfaced, gate-order, stop-the-line, pr-reviewed). A critical
    invariant unresolved exits nonzero (blocking). Methodology-conformance,
    not Gate 6 product acceptance."""
    return _run_sfs(["flowcheck", "--sprint", sprint] if sprint else ["flowcheck"])


@mcp.tool()
def sfs_harness_doctor() -> str:
    """Run `sfs harness doctor` — diagnose whether the current project is
    a safe environment for long autonomous or parallel-worker work
    (thin entry docs, routed context, six-division council, evidence
    loops, tests, release/check rails)."""
    return _run_sfs(["harness", "doctor"])


# ─────────────────────────────────────────────────────────────────────
# 7-step flow
# ─────────────────────────────────────────────────────────────────────


@mcp.tool()
def sfs_start(workspace: str) -> str:
    """Start a new sprint. `workspace` is a short english slug used for the
    sprint workspace name and for the `docs/solon/<workspace>/<yyyyMMdd>/`
    shared handoff path."""
    return _run_sfs(["start", workspace])


@mcp.tool()
def sfs_brainstorm(idea: str = "") -> str:
    """Gate 2 — Brainstorm. `idea` is the plain-language seed for the
    brainstorm scaffold. Pass an empty string to open the brainstorm
    surface without seeding."""
    return _run_sfs(["brainstorm", idea] if idea else ["brainstorm"])


@mcp.tool()
def sfs_plan(notes: str = "") -> str:
    """Gate 3 — Plan. `notes` is optional planner guidance. Returns the
    plan.md path and the routed plan template."""
    return _run_sfs(["plan", notes] if notes else ["plan"])


@mcp.tool()
def sfs_implement(notes: str = "") -> str:
    """Gate 4 — Implement. CTO-side adapter that records implement.md and
    log.md evidence as the work progresses. `notes` is optional
    implementer guidance."""
    return _run_sfs(["implement", notes] if notes else ["implement"])


@mcp.tool()
def sfs_review(
    gate: int = 6,
    executor: Optional[str] = None,
    lens: Optional[str] = None,
) -> str:
    """Gate review — CPO evaluator. Defaults to Gate 6 (final review).

    Args:
        gate: 1..7 (1=Intake, 2=Brainstorm, 3=Plan, 4=Design, 5=Handoff,
              6=Review, 7=Retro).
        executor: One of `codex`, `claude`, `gemini`, or a custom command.
              Empty/None lets `sfs review` pick the configured default.
        lens: Review lens (e.g. `auto`, `code`, `docs`, `security`,
              `performance`, `ddd-tdd`, `process-lean`). Empty/None lets
              `sfs review` pick automatically.
    """
    args = ["review", "--gate", str(gate)]
    if executor:
        args += ["--executor", executor]
    if lens:
        args += ["--lens", lens]
    return _run_sfs(args)


@mcp.tool()
def sfs_retro() -> str:
    """Gate 7 — Retro. Closes the current sprint with retro.md and routes
    the closing summary into the sessions index. Safe even when no
    explicit retro evidence was captured (records a retro-light)."""
    return _run_sfs(["retro"])


# ─────────────────────────────────────────────────────────────────────
# Decision + capture
# ─────────────────────────────────────────────────────────────────────


@mcp.tool()
def sfs_decision(title: str) -> str:
    """Record a durable decision in .sfs-local/decisions/. `title` becomes
    the file name slug; the body is the routed decision template, which
    the user fills in afterwards in their editor."""
    return _run_sfs(["decision", title])


@mcp.tool()
def sfs_capture(note: str) -> str:
    """Capture an evidence note attached to the current sprint. Use this
    when the host catches something worth keeping that does not fit the
    7-step gates (incident, anomaly, side-quest finding)."""
    return _run_sfs(["capture", note])


# ─────────────────────────────────────────────────────────────────────
# Entrypoint
# ─────────────────────────────────────────────────────────────────────


def main() -> None:
    """stdio MCP server entrypoint. Compatible with Claude Desktop,
    Claude in Chrome, Cursor, Claude Agent SDK, and any other host that
    speaks MCP over stdio."""
    mcp.run()


if __name__ == "__main__":
    main()
