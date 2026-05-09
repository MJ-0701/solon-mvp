---
id: sfs-policy-debugging-and-error-recovery
summary: Stop feature work on failure and fix the root cause with reproducible evidence.
load_when: ["failure", "debug", "error", "test fail", "CI fail", "regression"]
---

# Debugging And Error Recovery

Use this policy when tests fail, builds break, CI fails, runtime behavior is
wrong, or any command returns unexpected output.

Stop-the-line rule:
1. Stop adding features or broadening scope.
2. Preserve the exact evidence: command, exit code, stdout/stderr, log path,
   repro steps, and environment clues.
3. Reproduce the failure or document why it is not yet reproducible.
4. Localize the layer and smallest failing input.
5. Fix the root cause, not a symptom.
6. Add or update a guard so the same failure is caught next time.
7. Resume only after verification passes.

Rules:
- Do not skip a failing test, suppress an error, or continue to the next feature
  while the current slice is broken.
- For bug fixes, prefer a failing regression test or minimal repro before the
  fix. If no automated test is practical, record a precise manual repro.
- If the failure is flaky or environment-dependent, compare environments and add
  bounded diagnostic logging only where it helps. Remove temporary logs after
  the fix unless they are useful permanent observability.
- If a fallback is added, it must be safe, visible in evidence, and not counted
  as final acceptance unless the plan accepted fallback behavior.

Verification:
- Repro or explicit non-repro note exists.
- Root cause is named.
- Guard evidence exists: test, smoke, CI check, lint rule, script, or review
  guardrail.
- The original failing command or smallest equivalent now passes.
