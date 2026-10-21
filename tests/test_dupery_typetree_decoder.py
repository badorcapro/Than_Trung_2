"""
Unit tests for Dupery TypeTree Gate and MonoBehaviour Decoder (TASK-0012).
"""

from __future__ import annotations

import json
from pathlib import Path
import tempfile
import unittest

from scripts.agent.dupery_typetree_decoder import (
    DEFAULT_FAILURES,
    DEFAULT_REPORT,
    is_valid_asset_file,
    is_xnode_class,
    parse_args,
    verify_gate_report,
)


class TestDuperyTypeTreeDecoder(unittest.TestCase):
    """Test suite for asset filtering, XNode detection, and gate report verification."""

    def test_is_valid_asset_file(self) -> None:
        """Verify strict asset file filtering logic."""
        self.assertTrue(is_valid_asset_file("level0"))
        self.assertTrue(is_valid_asset_file("level11"))
        self.assertTrue(is_valid_asset_file("sharedassets0.assets"))
        self.assertTrue(is_valid_asset_file("resources.assets"))
        self.assertTrue(is_valid_asset_file("globalgamemanagers.assets"))

        # Strictly rejected raw streaming files
        self.assertFalse(is_valid_asset_file("sharedassets0.assets.resS"))
        self.assertFalse(is_valid_asset_file("sharedassets8.resource"))
        self.assertFalse(is_valid_asset_file("resources.assets.resS"))
        self.assertFalse(is_valid_asset_file("some_other_file.txt"))

    def test_is_xnode_class(self) -> None:
        """Verify identification of XNode classes."""
        self.assertTrue(is_xnode_class("Nodes", "StoryDialogueNode"))
        self.assertTrue(is_xnode_class("Nodes.Logic", "SetsRoleNode"))
        self.assertTrue(is_xnode_class("", "BasicStringNode"))

        # Non-XNode classes
        self.assertFalse(is_xnode_class("UnityEngine.UI", "Image"))
        self.assertFalse(is_xnode_class("Lineup", "LineupController"))
        self.assertFalse(is_xnode_class("Visual", "CasinoBulb"))

    def test_verify_gate_report_missing(self) -> None:
        """Verify verification fails gracefully when report is missing."""
        passed, errors = verify_gate_report(Path("/nonexistent/report.json"), Path("/nonexistent/failures.json"))
        self.assertFalse(passed)
        self.assertTrue(any("missing" in e.lower() for e in errors))

    def test_verify_gate_report_invalid_verdict(self) -> None:
        """Verify verification fails when verdict is not PASS."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp_root = Path(tmp_dir)
            rep_file = tmp_root / "report.json"
            fail_file = tmp_root / "failures.json"

            rep_file.write_text(json.dumps({"gate_verdict": "FAIL"}), encoding="utf-8")
            fail_file.write_text(json.dumps({"failures": []}), encoding="utf-8")

            passed, errors = verify_gate_report(rep_file, fail_file)
            self.assertFalse(passed)
            self.assertTrue(any("verdict" in e.lower() for e in errors))

    def test_verify_real_gate_report(self) -> None:
        """Verify real generated gate report passes all acceptance criteria."""
        if DEFAULT_REPORT.exists() and DEFAULT_FAILURES.exists():
            passed, errors = verify_gate_report(DEFAULT_REPORT, DEFAULT_FAILURES)
            self.assertTrue(passed, f"Gate report verification failed: {errors}")
            self.assertEqual(len(errors), 0)

            # Check report data
            report = json.loads(DEFAULT_REPORT.read_text(encoding="utf-8"))
            self.assertEqual(report["gate_verdict"], "PASS")
            self.assertGreaterEqual(report["scene_levels_success_rate_pct"], 99.0)
            self.assertGreaterEqual(report["total_xnode_instances_cataloged"], 1000)

    def test_parse_args(self) -> None:
        """Verify CLI argument parsing."""
        args = parse_args(["--verify", "--stats"])
        self.assertTrue(args.verify)
        self.assertTrue(args.stats)


if __name__ == "__main__":
    unittest.main()
