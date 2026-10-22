#!/usr/bin/env python3
"""Unit tests for Persistence, Localization & UX Simulator (TASK-0027B)."""

import json
import unittest

from scripts.agent.simulate_persistence_and_ux import (
    ControllerVirtualCursor,
    LocalizationEngine,
    PersistenceAndUXManager,
    SaveMigrationPipeline,
    SaveVersion,
    run_verification,
)


class TestSimulatePersistenceAndUX(unittest.TestCase):
    """Test suite for SaveMigrationPipeline, LocalizationEngine, and ControllerVirtualCursor."""

    def test_save_version_migration_chain(self) -> None:
        """Verify full sequential migration from 0.2.51 to 0.9.34."""
        legacy = {"version": "0.2.51", "scene": "BoardScene"}
        migrated = SaveMigrationPipeline.migrate(legacy)

        self.assertEqual(migrated["version"], SaveVersion.V0_9_34.value)
        self.assertIn("clues", migrated)
        self.assertIn("stats", migrated)
        self.assertIn("pins_data", migrated)
        self.assertIn("lines_data", migrated)
        self.assertIn("strings_data", migrated)
        self.assertEqual(migrated["region"], "Docks")

    def test_save_partial_migration(self) -> None:
        """Verify partial migration starting from version 0.4.23."""
        mid = {"version": "0.4.23", "pins_data": [{"id": "p1"}]}
        migrated = SaveMigrationPipeline.migrate(mid)

        self.assertEqual(migrated["version"], SaveVersion.V0_9_34.value)
        self.assertIn("strings_data", migrated)
        self.assertEqual(migrated["region"], "Docks")
        self.assertEqual(len(migrated["pins_data"]), 1)

    def test_localization_translation_and_fallback(self) -> None:
        """Verify translation lookup and English fallback for missing locale keys."""
        loc = LocalizationEngine()
        self.assertEqual(loc.translate("UI_SOLVE_CASE"), "Solve Case")

        loc.set_locale("fr")
        self.assertEqual(loc.translate("UI_SOLVE_CASE"), "Resoudre le cas")

        loc.set_locale("vi")
        self.assertEqual(loc.translate("UI_ARREST"), "Bat giu nghi pham")

        # Fallback to English when key is missing in Vietnamese
        loc.translations["ONLY_EN"] = {"en": "Only English"}
        self.assertEqual(loc.translate("ONLY_EN"), "Only English")

        # Fallback when key is entirely missing
        self.assertEqual(loc.translate("UNKNOWN_KEY"), "[UNKNOWN_KEY]")

    def test_controller_cursor_analog_move(self) -> None:
        """Verify virtual cursor position update from analog input."""
        cursor = ControllerVirtualCursor((50.0, 50.0))
        new_pos = cursor.move_analog(12.5, -5.2)
        self.assertEqual(new_pos, (62.5, 44.8))
        self.assertEqual((cursor.pos_x, cursor.pos_y), (62.5, 44.8))

    def test_controller_cursor_dpad_snap(self) -> None:
        """Verify D-pad cardinal snapping to candidate pins."""
        cursor = ControllerVirtualCursor((100.0, 100.0))
        pins = [
            (100.0, 200.0),  # Directly UP
            (100.0, 300.0),  # Further UP
            (50.0, 100.0),   # Directly LEFT
            (100.0, 10.0),   # Directly DOWN
        ]

        # Snap UP
        snapped_up = cursor.snap_dpad("UP", pins)
        self.assertEqual(snapped_up, (100.0, 200.0))
        self.assertEqual((cursor.pos_x, cursor.pos_y), (100.0, 200.0))

        # Snap DOWN from (100, 200) -> nearest downward pin is (50, 100) with dist ~111.8
        snapped_down = cursor.snap_dpad("DOWN", pins)
        self.assertEqual(snapped_down, (50.0, 100.0))

    def test_persistence_manager_json_serialization(self) -> None:
        """Verify manager produces well-formed JSON save data."""
        manager = PersistenceAndUXManager()
        save_str = manager.save_to_json(slot_id=1)
        save_data = json.loads(save_str)

        self.assertEqual(save_data["slot"], 1)
        self.assertEqual(save_data["version"], "0.9.34")
        self.assertIn("stats", save_data)
        self.assertIn("pins_data", save_data)

    def test_cli_verification_output(self) -> None:
        """Verify run_verification payload."""
        result = run_verification()
        self.assertTrue(result["success"])
        self.assertEqual(result["tool"], "simulate_persistence_and_ux")
        self.assertEqual(result["migration_result_version"], "0.9.34")
        self.assertEqual(result["translation_check"], "Pha an")


if __name__ == "__main__":
    unittest.main()
