summary: release readiness note

This release-readiness note intentionally uses the fuller style that existed
before Token Diet. It repeats context for clarity: the source tree needs a clean
diff check, focused Token Diet fixture tests, the full test runner, frontmatter
parsing, and version freshness confirmation before anyone should describe the
slice as implemented. The release notes also need to say that no product runtime
release has happened, that the installed Homebrew runtime may still report the
previous version, and that future compact output behavior remains gated behind
fixtures that preserve warnings and evidence.

source: release checklist and `PROGRESS.md`
verification: `git diff --check`, frontmatter parse, `tests/run-all.sh`
status: source-ready only after checks pass
risk: channel release would be false until Homebrew and Scoop are cut
next: keep this as source evidence, not a product release claim
