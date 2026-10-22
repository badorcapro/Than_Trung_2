---
id: TASK-0007B
title: Fix Audit Defects (GEMINI.md, Dupery Classification) and Enforce Subagent Semantic
  Peer-Audit Gate
domain: software
status: approved
phase: P1
touches_gatekeeper: true
goal: Fix the 2 residual defects discovered during the 6-task adversarial audit (broken
  file:/// link in GEMINI.md and stale binary sizes/hashes in dupery_build_classification.md)
  and implement a mandatory mechanical Subagent Semantic Peer-Audit Gate (check_peer_audit.py
  integrated into run_verify.py) requiring TASK-XXXX-peer-audit.json with verified
  diff_sha256, thought/decision handover, and loaded GEMINI.md/rules/skills before
  any task can transition to verified.
in_scope:
- GEMINI.md
- docs/agent-system/evidence/dupery/dupery_build_classification.md
- docs/agent-system/reference-registry.json
- AGENTS.md
- ARCHITECTURE.md
- .agents/rules/rule_task_contract_and_scope.md
- .agents/skills/verify-task/SKILL.md
- scripts/agent/models.py
- scripts/agent/check_scope.py
- scripts/agent/check_peer_audit.py
- scripts/agent/run_verify.py
- tests/test_peer_audit.py
out_of_scope:
- Than_Tham_Nua_Voi_Godot/**
references:
- ARCH-CORE-001
- RULE-ENGINE-001
- RULE-SCOPE-001
- ADR-ARCH-010
dependencies:
- TASK-0007
assumptions:
- Bookkeeping exemption in check_scope.py applies specifically to docs/agent-system/evidence/TASK-*.json
  so peer-audit and verification receipts do not alter diff_sha256, while domain evidence
  artifacts remain scope-tracked.
acceptance_criteria:
- GEMINI.md line 8 uses a workspace-relative POSIX link and check_docs.py reports
  0 ERR_DOC_BROKEN_LINK errors.
- dupery_build_classification.md matches dupery_build_manifest.json byte-for-byte
  on Dupery.exe size/SHA256, UnityPlayer.dll size, and FMOD bank filenames.
- models.py defines PeerAuditVerdict and PeerAuditReceipt and supports optional uppercase
  letter suffixes in Task IDs (TASK-0007B).
- check_peer_audit.py validates TASK-XXXX-peer-audit.json for mandatory rules/skills/GEMINI.md
  coverage, Primary Agent thought/decision handover, transcript reference, diff_sha256
  freshness, and verdict == PASS.
- run_verify.py invokes check_peer_audit and fails closed if the peer audit receipt
  is missing, stale, or rejected.
- All modified scripts in scripts/agent/ remain strictly below the 300 LOC core_engine
  warning threshold per ADR-0010.
- All unit tests (including tests/test_peer_audit.py) pass with exit code 0.
verification_commands:
- python -m unittest discover -s tests -p "test_*.py"
- python scripts/agent/check_docs.py
- python scripts/agent/validate_registry.py
- python scripts/agent/check_peer_audit.py --task TASK-0007B
stop_conditions:
- Always-on context budget exceeds 15% (3,000 tokens).
- Any modified script in scripts/agent/ exceeds 300 LOC warning threshold.
- Verification command fails after 1 fix attempt.
line_budget_exceptions: []
current_checkpoint: CP-APPROVED
evidence_receipt: docs/agent-system/evidence/TASK-0007B-receipt.json
---

# Task Execution Log & Checkpoints

## Implementation & Decision Log (Handover for Peer Auditor Subagent)
- **decisions_made**:
  1. Extracted `scripts/agent/check_peer_audit.py` as a dedicated Single-Responsibility module per ADR-0010 instead of bloating `scripts/agent/run_verify.py` (which was already at 262 LOC).
  2. Tightened `BOOKKEEPING_EXEMPT_PATTERNS` in `scripts/agent/check_scope.py` from `"docs/agent-system/evidence/*"` to `"docs/agent-system/evidence/TASK-*.json"` so that `TASK-XXXX-peer-audit.json` and `TASK-XXXX-receipt.json` do not change `diff_sha256`, while domain evidence files under `docs/agent-system/evidence/dupery/` and `docs/agent-system/evidence/godot/` are properly tracked in `evaluated_files` and `diff_sha256`.
  3. Updated `_TASK_ID_RE` in `scripts/agent/models.py` to `r"^TASK-[0-9]{4}[A-Z]?$"`, added `@field_validator` for `task_id` and 64-hex `diff_sha256` on `PeerAuditReceipt`, and left `scripts/agent/validate_task.py` (350 LOC) untouched because ASCII sorting (`"TASK-0007.md" < "TASK-0007B.md"`) already resolves `TASK-0007` and `TASK-0007B` deterministically without needing to modify `validate_task.py`.
  4. Remediated step 1696 Tool Gap (`python -c` on `reference-registry.json`) by writing `docs/agent-system/reference-registry.json` via the registered `write_file` tool and refreshing hashes via `python scripts/agent/validate_registry.py --update-hashes`.
- **omissions_and_simplifications**:
  - Initially omitted `@field_validator` for `task_id` and `diff_sha256` on `PeerAuditReceipt` and left stale text referencing `validate_task.py` in `TASK-0007B.md:61`; both defects plus the `reference-registry.json` Tool Gap were caught by Peer-Auditor Subagent `81130a73-e36f-43ce-98d8-e10eb1f4a0e2` and resolved in 1 fix pass.
- **adr_0010_modularization_check**:
  - `check_peer_audit.py` is modularized as an independent gatekeeper (< 165 LOC) and called by `run_verify.py` (< 270 LOC). Zero semicolon packing or code truncation used.

## Checkpoint History
- **CP-0**: Task contract initialized for `TASK-0007B`.