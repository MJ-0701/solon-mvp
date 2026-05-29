"""Smoke contracts for the mcp-tool-zero scaffold.

Static + import-light checks a consumer can run right after scaffolding,
before wiring the real <DOMAIN> operation.
"""

import pathlib

import yaml

HERE = pathlib.Path(__file__).resolve().parent.parent
PRESET = HERE / "solon-safe-permissions.yaml"
SERVER = HERE / "server.py"


def test_server_declares_single_narrow_tool():
    src = SERVER.read_text(encoding="utf-8")
    # exactly one @mcp.tool() decorator — no sprawling tool surface.
    assert src.count("@mcp.tool()") == 1
    assert "FastMCP(" in src
    assert "def domain_tool(" in src


def test_tool_input_is_typed_and_bounded():
    src = SERVER.read_text(encoding="utf-8")
    assert "target: str" in src
    assert "max_items: int" in src
    # output-bounded so a sub-agent capsule token_budget holds.
    assert "max_items must be positive" in src


def test_permission_preset_parses_and_denies_auto_push():
    preset = yaml.safe_load(PRESET.read_text(encoding="utf-8"))
    denied = preset["tools"]["denied"]
    assert any(rule.startswith("bash:git push") for rule in denied)
    assert any("rm -rf" in rule for rule in denied)
    assert preset["workflow"]["mainline_first"] is True
    assert preset["workflow"]["require_gate_6"] is True


def test_no_secrets_committed():
    # markers built from fragments so this scanner does not flag its own source.
    for marker in ("sk-" + "ant-", "sk-" + "proj-", "ghp" + "_", "AIza" + "Sy"):
        for path in HERE.rglob("*"):
            if path.is_file() and path.suffix in (".py", ".yaml", ".toml", ".md"):
                assert marker not in path.read_text(encoding="utf-8"), f"secret {marker} in {path}"
