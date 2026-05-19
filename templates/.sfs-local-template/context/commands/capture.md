---
id: sfs-command-capture
summary: Record natural-language flow changes before the next command loses context.
load_when: ["capture", "note", "natural language", "decision", "review order", "waiver", "blocker"]
---

# Capture / Note

- Use `sfs capture` when a natural-language turn changes implementation
  direction, acceptance meaning, review order, exception/waiver status,
  blocker state, or evidence that later gates must remember.
- `sfs note "..."` is an alias for `sfs capture --kind note "..."`.
- Prefer specific kinds when the meaning is clear:
  `decision`, `scope-change`, `review-order`, `exception`, `evidence`,
  `blocker`, `waiver`, or `note`.
- Capture before the next SFS command. The point is to move important chat
  state into the sprint workbench, not to summarize it after the flow already
  drifted.
- The command appends a timestamped entry to the sprint `log.md` and records a
  `flow_capture` event in `events.jsonl`.
- If there is no active sprint, pass `--sprint <id>` only when you are
  intentionally writing to that sprint; otherwise start or restore the sprint
  first.
- Do not use capture as a full transcript recorder. Store the smallest
  decision/evidence sentence that a future reviewer needs.
- `sfs capture` enforces a small text budget by default so prompt bodies and
  transcript dumps do not become durable flow state. If the source is bulky,
  store it as an artifact/archive path and capture the accepted conclusion.

Examples:

```sh
sfs capture --kind review-order --gate 6 "Run Codex self-CPO first, then Gemini, then Claude."
sfs capture --kind scope-change "Do not add automatic transcript recording in this sprint."
sfs note "GitHub @codex review passed, but it is external evidence only."
```
