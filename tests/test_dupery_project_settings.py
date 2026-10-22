"""
Unit tests for Dupery Project Settings Extractor (TASK-0013).
"""

from __future__ import annotations

import json
from pathlib import Path
import tempfile
import unittest

from scripts.agent.dupery_project_settings import (
    DEFAULT_OUT_DIR,
    TARGET_MANAGERS,
    parse_args,
    verify_project_settings,
)


class TestDuperyProjectSettings(unittest.TestCase):
    """Test suite for project settings extraction and verification."""

    def test_verify_missing_directory(self) -> None:
        """Verify verification fails when output directory does not exist."""
        passed, errors = verify_project_settings(Path("/nonexistent/settings_dir"))
        self.assertFalse(passed)
        self.assertTrue(any("missing" in e.lower() for e in errors))

    def test_verify_missing_manager_file(self) -> None:
        """Verify verification detects missing manager JSON files."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp_root = Path(tmp_dir)
            # Create summary but no managers
            summary = {
                "total_managers_extracted": len(TARGET_MANAGERS),
                "scenes": [{} for _ in range(12)],
            }
            (tmp_root / "project_settings_summary.json").write_text(json.dumps(summary), encoding="utf-8")
            passed, errors = verify_project_settings(tmp_root)
            self.assertFalse(passed)
            self.assertTrue(any("manager json missing" in e.lower() for e in errors))

    def test_verify_real_project_settings(self) -> None:
        """Verify real extracted project settings meet all acceptance criteria."""
        if DEFAULT_OUT_DIR.exists():
            passed, errors = verify_project_settings(DEFAULT_OUT_DIR)
            self.assertTrue(passed, f"Verification failed: {errors}")
            self.assertEqual(len(errors), 0)

            # Check summary contents
            summary_path = DEFAULT_OUT_DIR / "project_settings_summary.json"
            summary = json.loads(summary_path.read_text(encoding="utf-8"))
            self.assertEqual(summary["total_managers_extracted"], 11)
            self.assertEqual(summary["scenes_count"], 12)
            self.assertEqual(summary["display"]["product_name"], "Dupery")
            self.assertEqual(summary["display"]["company_name"], "Gilded Rune Games")
            self.assertEqual(summary["display"]["default_screen_width"], 1920)
            self.assertEqual(summary["display"]["default_screen_height"], 1080)
            self.assertIn("UI_Character", summary["tags_and_layers"]["tags"])
            self.assertIn("Cursor", summary["tags_and_layers"]["sorting_layers"])

    def test_parse_args(self) -> None:
        """Verify argument parser flags."""
        args = parse_args(["--verify", "--stats", "--out-dir", "C:/dummy"])
        self.assertTrue(args.verify)
        self.assertTrue(args.stats)
        self.assertEqual(args.out_dir, Path("C:/dummy"))


if __name__ == "__main__":
    unittest.main()
