# ADR-0003: Task Contract Format & Anti-Split-Brain State Hierarchy

- **Reference ID**: `ADR-ARCH-003`
- **Status**: `approved`
- **Date**: `2026-10-19`
- **Depends On**: `ARCH-CORE-001`

---

## 1. Context
Multi-turn AI sessions and `/compact` events cause state divergence if task state is tracked redundantly across chat memory, markdown files, and JSON state pointers.

## 2. Decision
Establish a strict 3-tier State Hierarchy:
1. **Contract SSOT**: `docs/agent-system/tasks/TASK-XXXX.md` containing YAML frontmatter (strictly validated by Pydantic) and Markdown checkpoint notes.
2. **Derived Index**: `docs/agent-system/state/active-task.json` (micro-pointer containing `active_task_id`, `status`, `contract_sha256`) generated exclusively by `validate_task.py --sync-state`. The LLM is strictly prohibited from editing this file by hand.
3. **Turn Memory**: `.agent_scratchpad.md` tracks intra-step micro-actions and references the active `TASK-XXXX` ID.

## 3. Consequences
- **Positive**: Resuming from a compacted session requires loading only 9 lines (~40 tokens) from `active-task.json`, eliminating split-brain desynchronization.
