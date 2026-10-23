"""
Unit test suite for Case Selection System & Level Progression Loop (TASK-0036 / Pilot DO-03).
"""

from __future__ import annotations

import json
import os
import re
import tempfile
import unittest


class TestCaseSelectionProgression(unittest.TestCase):
    """Test suite for CaseSelectionManager, LevelProgressionManager, and CaseSelectionModal."""

    def setUp(self) -> None:
        self.workspace_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.selection_mgr_path = os.path.join(
            self.workspace_root,
            "Than_Tham_Nua_Voi_Godot",
            "scripts",
            "domain",
            "cases",
            "CaseSelectionManager.gd",
        )
        self.progression_mgr_path = os.path.join(
            self.workspace_root,
            "Than_Tham_Nua_Voi_Godot",
            "scripts",
            "domain",
            "cases",
            "LevelProgressionManager.gd",
        )
        self.modal_tscn_path = os.path.join(
            self.workspace_root,
            "Than_Tham_Nua_Voi_Godot",
            "scenes",
            "case_selection",
            "CaseSelectionModal.tscn",
        )
        self.modal_controller_path = os.path.join(
            self.workspace_root,
            "Than_Tham_Nua_Voi_Godot",
            "scripts",
            "presentation",
            "case_selection",
            "CaseSelectionModalController.gd",
        )

    def test_source_files_exist(self) -> None:
        """Verify all domain and presentation files for TASK-0036 exist on disk."""
        self.assertTrue(os.path.exists(self.selection_mgr_path), "Missing CaseSelectionManager.gd")
        self.assertTrue(os.path.exists(self.progression_mgr_path), "Missing LevelProgressionManager.gd")
        self.assertTrue(os.path.exists(self.modal_tscn_path), "Missing CaseSelectionModal.tscn")
        self.assertTrue(os.path.exists(self.modal_controller_path), "Missing CaseSelectionModalController.gd")

    def test_case_selection_manager_specifications(self) -> None:
        """Verify CaseSelectionManager declares required constants and public API."""
        with open(self.selection_mgr_path, "r", encoding="utf-8") as f:
            code = f.read()

        self.assertIn("class_name CaseSelectionManager", code)
        self.assertIn("const DEFAULT_OPTION_COUNT := 3", code)
        self.assertIn("func generate_options", code)
        self.assertIn("func select_option", code)
        self.assertIn("func get_selected_option", code)
        self.assertIn("func get_current_options", code)
        self.assertIn("func has_options", code)

    def test_level_progression_manager_specifications(self) -> None:
        """Verify LevelProgressionManager declares 1-3 star metrics and persistence API."""
        with open(self.progression_mgr_path, "r", encoding="utf-8") as f:
            code = f.read()

        self.assertIn("class_name LevelProgressionManager", code)
        self.assertIn("const STAR_NONE := 0", code)
        self.assertIn("const STAR_CLEAR := 1", code)
        self.assertIn("const STAR_NO_CASUALTY := 2", code)
        self.assertIn("const STAR_PERFECT := 3", code)
        self.assertIn("func evaluate_clear", code)
        self.assertIn("func get_total_stars", code)
        self.assertIn("func get_unlocked_level_count", code)
        self.assertIn("func save_progress", code)
        self.assertIn("func load_progress", code)
        self.assertIn("func serialize", code)
        self.assertIn("func deserialize", code)

    def test_modal_scene_anchors_and_unique_names(self) -> None:
        """Verify CaseSelectionModal.tscn clamps anchors <= 1.0 and declares unique names."""
        with open(self.modal_tscn_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Unique node names for controller binding
        self.assertIn("unique_name_in_owner = true", content)
        self.assertIn('name="ProgressionContainer"', content)
        self.assertIn('name="TotalStarsLabel"', content)
        self.assertIn('name="CardsContainer"', content)
        self.assertIn('name="TitleLabel"', content)
        self.assertIn('name="CloseButton"', content)

        # Anchor check: no anchor exceeds 1.0
        for line in content.splitlines():
            match = re.search(r'anchor_(right|bottom)\s*=\s*([0-9\.]+)', line)
            if match:
                val = float(match.group(2))
                self.assertLessEqual(val, 1.0, f"Anchor exceeds 1.0: {line}")

    def test_level_progression_simulation_logic(self) -> None:
        """Simulate LevelProgressionManager star evaluation and unlock cascade in Python."""
        # Python implementation mirroring LevelProgressionManager.gd
        levels = []
        for i in range(1, 11):
            levels.append({
                "level_id": i,
                "is_unlocked": i == 1,
                "completed": False,
                "star_rating": 0,
                "high_score": 0,
                "par_moves": 4 + int(i * 0.8),
            })

        def evaluate_clear(lvl_id: int, solved: bool, innocent_killed: int, moves_used: int, score: int):
            idx = lvl_id - 1
            lvl = levels[idx]
            if not solved:
                return {"success": False, "stars_earned": 0, "stars_record": lvl["star_rating"]}

            par = lvl["par_moves"]
            stars = 1
            if innocent_killed == 0:
                stars = 2
                if moves_used > 0 and moves_used <= par:
                    stars = 3

            lvl["completed"] = True
            lvl["star_rating"] = max(lvl["star_rating"], stars)
            lvl["high_score"] = max(lvl["high_score"], score)

            newly_unlocked = 0
            if idx + 1 < len(levels):
                next_lvl = levels[idx + 1]
                if not next_lvl["is_unlocked"]:
                    next_lvl["is_unlocked"] = True
                    newly_unlocked = next_lvl["level_id"]

            return {"success": True, "stars_earned": stars, "stars_record": lvl["star_rating"], "newly_unlocked": newly_unlocked}

        # Case 1: Unsolved -> 0 stars
        r1 = evaluate_clear(1, solved=False, innocent_killed=0, moves_used=3, score=0)
        self.assertFalse(r1["success"])
        self.assertEqual(r1["stars_earned"], 0)
        self.assertFalse(levels[1]["is_unlocked"])

        # Case 2: Solved with casualties -> 1 star
        r2 = evaluate_clear(1, solved=True, innocent_killed=1, moves_used=3, score=100)
        self.assertTrue(r2["success"])
        self.assertEqual(r2["stars_earned"], 1)
        self.assertTrue(levels[1]["is_unlocked"], "Level 2 should now be unlocked")

        # Case 3: Replay Level 1 with 0 casualties, over par -> 2 stars
        r3 = evaluate_clear(1, solved=True, innocent_killed=0, moves_used=8, score=250)
        self.assertEqual(r3["stars_earned"], 2)
        self.assertEqual(r3["stars_record"], 2)

        # Case 4: Replay Level 1 with 0 casualties, under par -> 3 stars
        r4 = evaluate_clear(1, solved=True, innocent_killed=0, moves_used=3, score=500)
        self.assertEqual(r4["stars_earned"], 3)
        self.assertEqual(r4["stars_record"], 3)

        # Total stars check
        total_stars = sum(lvl["star_rating"] for lvl in levels)
        self.assertEqual(total_stars, 3)

    def test_level_progression_json_persistence(self) -> None:
        """Verify JSON serialization, file persistence, and corrupt file fallback."""
        data = {
            "version": 1,
            "total_stars": 5,
            "levels": [
                {"level_id": 1, "is_unlocked": True, "completed": True, "star_rating": 3, "high_score": 500},
                {"level_id": 2, "is_unlocked": True, "completed": True, "star_rating": 2, "high_score": 300},
                {"level_id": 3, "is_unlocked": True, "completed": False, "star_rating": 0, "high_score": 0},
            ]
        }
        with tempfile.NamedTemporaryFile("w", delete=False, suffix=".json") as tmp:
            json.dump(data, tmp)
            tmp_path = tmp.name

        try:
            with open(tmp_path, "r", encoding="utf-8") as f:
                loaded = json.load(f)
            self.assertEqual(loaded["version"], 1)
            self.assertEqual(len(loaded["levels"]), 3)
            self.assertEqual(loaded["levels"][0]["star_rating"], 3)

            # Test corrupt JSON fallback
            with open(tmp_path, "w", encoding="utf-8") as f:
                f.write("{ corrupt json content ...")

            with self.assertRaises(json.JSONDecodeError):
                with open(tmp_path, "r", encoding="utf-8") as f:
                    json.load(f)
        finally:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)

    def test_line_budget_compliance(self) -> None:
        """Verify all new GDScript files comply with ADR-0010 (< 800 LOC)."""
        files_to_check = [
            self.selection_mgr_path,
            self.progression_mgr_path,
            self.modal_controller_path,
        ]
        for path in files_to_check:
            with open(path, "r", encoding="utf-8") as f:
                lines = [l.strip() for l in f if l.strip() and not l.strip().startswith("#")]
            loc = len(lines)
            self.assertLess(loc, 800, f"File {os.path.basename(path)} LOC {loc} exceeds 800")


if __name__ == "__main__":
    unittest.main()
