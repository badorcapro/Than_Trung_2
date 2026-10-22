"""
Unit tests for Dupery Scene Inspector and Hierarchy Builder (TASK-0014).
"""

from __future__ import annotations

import json
from pathlib import Path
import tempfile
import unittest

from scripts.agent.dupery_scene_inspector import (
    DEFAULT_OUT_DIR,
    filter_custom_properties,
    parse_args,
    verify_scene_artifacts,
)


class TestDuperySceneInspector(unittest.TestCase):
    """Test suite for scene tree hierarchy and inspector verification."""

    def test_filter_custom_properties(self) -> None:
        """Verify default MonoBehaviour header fields are cleanly stripped."""
        raw_tree = {
            "m_GameObject": {"m_FileID": 0, "m_PathID": 10},
            "m_Enabled": 1,
            "m_Script": {"m_FileID": 1, "m_PathID": 20},
            "m_Name": "TestComponent",
            "customSpeed": 42.5,
            "targetColor": {"r": 1.0, "g": 0.0, "b": 0.0, "a": 1.0},
        }
        filtered = filter_custom_properties(raw_tree)
        self.assertEqual(len(filtered), 2)
        self.assertIn("customSpeed", filtered)
        self.assertIn("targetColor", filtered)
        self.assertNotIn("m_GameObject", filtered)
        self.assertNotIn("m_Enabled", filtered)
        self.assertNotIn("m_Script", filtered)
        self.assertNotIn("m_Name", filtered)

    def test_verify_missing_directory(self) -> None:
        """Verify verification fails gracefully when directory is missing."""
        passed, errors = verify_scene_artifacts(Path("/nonexistent/scenes"))
        self.assertFalse(passed)
        self.assertTrue(any("missing" in e.lower() for e in errors))

    def test_verify_missing_scene_file(self) -> None:
        """Verify verification fails when a scene file is missing."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp_root = Path(tmp_dir)
            summary = {
                "scenes": [
                    {"json_artifact": "Scene1.json"},
                    {"json_artifact": "Scene2.json"},
                ]
            }
            (tmp_root / "scene_catalog_summary.json").write_text(json.dumps(summary), encoding="utf-8")
            passed, errors = verify_scene_artifacts(tmp_root)
            self.assertFalse(passed)
            self.assertTrue(any("scene json missing" in e.lower() for e in errors))

    def test_verify_real_scene_artifacts(self) -> None:
        """Verify real extracted 12 scenes meet all acceptance criteria."""
        if DEFAULT_OUT_DIR.exists():
            passed, errors = verify_scene_artifacts(DEFAULT_OUT_DIR)
            self.assertTrue(passed, f"Scene verification failed: {errors}")
            self.assertEqual(len(errors), 0)

            summary_file = DEFAULT_OUT_DIR / "scene_catalog_summary.json"
            summary = json.loads(summary_file.read_text(encoding="utf-8"))
            self.assertEqual(summary["total_scenes_extracted"], 12)
            self.assertGreaterEqual(summary["total_game_objects_all_scenes"], 5000)
            self.assertGreaterEqual(summary["total_monobehaviours_all_scenes"], 7000)

            # Check MainMenuScene details
            main_menu = json.loads((DEFAULT_OUT_DIR / "MainMenuScene.json").read_text(encoding="utf-8"))
            self.assertEqual(main_menu["scene_name"], "MainMenuScene")
            self.assertGreater(len(main_menu["root_game_objects"]), 0)
            root0 = main_menu["root_game_objects"][0]
            self.assertIn("name", root0)
            self.assertIn("transform", root0)
            self.assertIn("children", root0)

    def test_parse_args(self) -> None:
        """Verify argument parser flags."""
        args = parse_args(["--verify", "--stats", "--out-dir", "C:/dummy"])
        self.assertTrue(args.verify)
        self.assertTrue(args.stats)
        self.assertEqual(args.out_dir, Path("C:/dummy"))


if __name__ == "__main__":
    unittest.main()
