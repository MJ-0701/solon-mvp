---
doc_id: llm-wiki-bug-reports-root
title: "Bug recurrence memory — root"
doc_type: wiki-root
status: template
tags:
  - llm-wiki
  - bug-reports
  - quality
---

# Bug recurrence memory

One note per recurring failure class, so the same defect is never re-debugged
from zero. This is the project's **quality memory** — the harness looks for this
folder when it reports wiki health.

## When to add a note

Add a note here when a bug:

- has recurred, or is likely to recur, or
- took real effort to root-cause, or
- was caused by a non-obvious interaction worth warning future work about.

## Suggested note shape

```
---
doc_id: bug-<short-slug>
title: "<one-line symptom>"
doc_type: bug-report
tags: [bug-reports, <area>]
---

- **Symptom** — what was observed.
- **Root cause** — the actual mechanism, not the surface error.
- **Fix** — what changed (link the commit/PR if available).
- **Recurrence guard** — the test, lint, or check that now prevents it.
- **Status** — applied / mitigated / open.
```

Keep one bug class per note. Link related bugs to each other and route them from
[../00-llm-retrieval-guide.md](../00-llm-retrieval-guide.md).
