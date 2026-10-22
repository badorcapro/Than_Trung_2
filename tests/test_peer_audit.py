"""
Unit tests for Subagent Semantic Peer-Audit Gatekeeper (scripts/agent/check_peer_audit.py).
Tests missing receipt, incomplete context, rejected verdict, stale diff_sha256, and valid PASS.
"""

from __future__ import annotations

import json
from pathlib import Path
import sys
import tempfile
import unittest

ROOT_DIR = Path(__file__).resolve().parents[1]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.check_peer_audit import (
    MANDATORY_AUDIT_CONTEXT_FILES,
    check_peer_audit,
)


def _valid_audit_payload(task_id: str = "TASK-0007B", diff_sha256: str = "a" * 64) -> dict:
    return {
        "task_id": task_id,
        "subagent_conversation_id": "subagent-uuid-12345678",
        "audited_at": "2026-10-21T00:50:00+00:00",
        "diff_sha256": diff_sha256,
        "transcript_reference": "file:///C:/Users/Admin/.gemini/antigravity/brain/5dc69d25/.system_generated/logs/transcript.jsonl",
        "rules_and_docs_loaded": list(MANDATORY_AUDIT_CONTEXT_FILES),
        "decisions_made": [
            "Extracted check_peer_audit.py as a dedicated Single Responsibility module per ADR-0010."
        ],
        "omissions_and_simplifications": [
            "None - verified 100% coverage of acceptance criteria and edge cases."
        ],
        "adr_0010_anti_cheat_check": "Verified < 300 LOC across all modules, 0 semicolons, zero truncated code blocks.",
        "semantic_checks_performed": [
            "Verified GEMINI.md relative link passes check_docs.py.",
            "Verified Dupery binary sizes and hashes match dupery_build_manifest.json.",
        ],
        "findings": [],
        "verdict": "PASS",
    }


class TestPeerAuditGate(unittest.TestCase):
    """Test suite for check_peer_audit.py deterministic enforcement."""

    def test_missing_peer_audit_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            res = check_peer_audit(root, "TASK-0007B", expected_diff_sha256="a" * 64)
            self.assertFalse(res.success)
            self.assertEqual(res.issues[0].code, "ERR_PEER_AUDIT_MISSING")

    def test_valid_peer_audit_passes(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            ev_dir = root / "docs" / "agent-system" / "evidence"
            ev_dir.mkdir(parents=True, exist_ok=True)
            audit_file = ev_dir / "TASK-0007B-peer-audit.json"
            audit_file.write_text(
                json.dumps(_valid_audit_payload("TASK-0007B", "b" * 64), indent=2),
                encoding="utf-8",
            )
            res = check_peer_audit(root, "TASK-0007B", expected_diff_sha256="b" * 64)
            self.assertTrue(res.success, msg=f"Unexpected issues: {res.issues}")
            self.assertEqual(res.data["verdict"], "PASS")

    def test_incomplete_context_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            ev_dir = root / "docs" / "agent-system" / "evidence"
            ev_dir.mkdir(parents=True, exist_ok=True)
            payload = _valid_audit_payload("TASK-0007B", "b" * 64)
            payload["rules_and_docs_loaded"] = ["GEMINI.md"]  # Missing rules & skills
            (ev_dir / "TASK-0007B-peer-audit.json").write_text(
                json.dumps(payload, indent=2), encoding="utf-8"
            )
            res = check_peer_audit(root, "TASK-0007B", expected_diff_sha256="b" * 64)
            self.assertFalse(res.success)
            codes = {i.code for i in res.issues}
            self.assertIn("ERR_PEER_AUDIT_INCOMPLETE_CONTEXT", codes)

    def test_rejected_or_non_empty_findings_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            ev_dir = root / "docs" / "agent-system" / "evidence"
            ev_dir.mkdir(parents=True, exist_ok=True)
            payload = _valid_audit_payload("TASK-0007B", "b" * 64)
            payload["findings"] = ["Residual broken link in GEMINI.md"]
            (ev_dir / "TASK-0007B-peer-audit.json").write_text(
                json.dumps(payload, indent=2), encoding="utf-8"
            )
            res = check_peer_audit(root, "TASK-0007B", expected_diff_sha256="b" * 64)
            self.assertFalse(res.success)
            codes = {i.code for i in res.issues}
            self.assertIn("ERR_PEER_AUDIT_REJECTED", codes)

    def test_stale_diff_sha256_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            ev_dir = root / "docs" / "agent-system" / "evidence"
            ev_dir.mkdir(parents=True, exist_ok=True)
            payload = _valid_audit_payload("TASK-0007B", "a" * 64)
            (ev_dir / "TASK-0007B-peer-audit.json").write_text(
                json.dumps(payload, indent=2), encoding="utf-8"
            )
            res = check_peer_audit(root, "TASK-0007B", expected_diff_sha256="c" * 64)
            self.assertFalse(res.success)
            codes = {i.code for i in res.issues}
            self.assertIn("ERR_PEER_AUDIT_DIFF_STALE", codes)

    def test_invalid_diff_sha256_or_task_id_fails_schema(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            ev_dir = root / "docs" / "agent-system" / "evidence"
            ev_dir.mkdir(parents=True, exist_ok=True)
            payload = _valid_audit_payload("TASK-0007B", "not-a-valid-sha256")
            (ev_dir / "TASK-0007B-peer-audit.json").write_text(
                json.dumps(payload, indent=2), encoding="utf-8"
            )
            res = check_peer_audit(root, "TASK-0007B", expected_diff_sha256="a" * 64)
            self.assertFalse(res.success)
            self.assertEqual(res.issues[0].code, "ERR_PEER_AUDIT_SCHEMA_INVALID")


if __name__ == "__main__":
    unittest.main()
