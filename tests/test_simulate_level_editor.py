#!/usr/bin/env python3
"""Unit tests for Level Editor & Polish Simulator (TASK-0029)."""

import unittest

from scripts.agent.simulate_level_editor import (
    BoardSlot,
    LevelEditorBuilder,
    evaluate_analytical_easing,
    run_verification,
)


class TestSimulateLevelEditor(unittest.TestCase):
    """Test suite for BoardSlot, LevelEditorBuilder, validation constraints, and easing curves."""

    def test_board_slot_placement_and_clearing(self) -> None:
        """Verify slot occupancy, collision prevention, and clearing."""
        slot = BoardSlot("slot_0_0", (0, 0))
        self.assertTrue(slot.is_empty)

        item = {"role": "Barkeep", "alignment": "Innocent"}
        self.assertTrue(slot.place_item(item))
        self.assertFalse(slot.is_empty)

        # Disallow placement when occupied
        self.assertFalse(slot.place_item({"role": "Anglerfish"}))

        cleared = slot.clear()
        self.assertEqual(cleared, item)
        self.assertTrue(slot.is_empty)

    def test_fuel_metering_and_limits(self) -> None:
        """Verify fuel expenditure tracking and budget exhaustion."""
        builder = LevelEditorBuilder(max_fuel=30)
        self.assertEqual(builder.remaining_fuel, 30)

        # Place item costing 20 fuel
        placed_1 = builder.add_suspect("slot_0_0", "Hunter", "Special", fuel_cost=20)
        self.assertTrue(placed_1)
        self.assertEqual(builder.remaining_fuel, 10)

        # Attempt placing item costing 15 fuel (exceeds budget)
        placed_2 = builder.add_suspect("slot_0_1", "Psychic", "Special", fuel_cost=15)
        self.assertFalse(placed_2)
        self.assertEqual(builder.remaining_fuel, 10)

    def test_case_validation_constraints(self) -> None:
        """Verify constraint checks for minimum suspects, guilty, and innocent roles."""
        builder = LevelEditorBuilder()

        # Empty case is invalid
        valid, issues = builder.validate_case()
        self.assertFalse(valid)
        self.assertIn("Case requires at least 3 suspects on the board.", issues)

        # Add 3 innocent suspects (missing guilty)
        builder.add_suspect("slot_0_0", "S1", "Innocent", fuel_cost=5)
        builder.add_suspect("slot_0_1", "S2", "Innocent", fuel_cost=5)
        builder.add_suspect("slot_0_2", "S3", "Innocent", fuel_cost=5)
        valid, issues = builder.validate_case()
        self.assertFalse(valid)
        self.assertIn("Case must have at least 1 guilty suspect.", issues)

        # Replace one with guilty -> becomes valid
        builder.slots["slot_0_2"].clear()
        builder.add_suspect("slot_0_2", "S3_Guilty", "Guilty", fuel_cost=5)
        valid, issues = builder.validate_case()
        self.assertTrue(valid)
        self.assertEqual(len(issues), 0)

    def test_reputation_reward_and_payload_export(self) -> None:
        """Verify reputation point calculation and JSON schema export."""
        builder = LevelEditorBuilder("Casino Heist", "Casino")
        builder.add_suspect("slot_0_0", "Dealer", "Innocent", fuel_cost=10)
        builder.add_suspect("slot_0_1", "Cheater", "Guilty", fuel_cost=15)
        builder.add_location("slot_1_1", "Vault", fuel_cost=10)

        # 100 base + 3 elements * 25 = 175
        self.assertEqual(builder.calculate_reputation_reward(), 175)

        payload = builder.export_case_payload()
        self.assertEqual(payload["title"], "Casino Heist")
        self.assertEqual(payload["region"], "Casino")
        self.assertEqual(len(payload["board_elements"]), 3)

    def test_analytical_easing_evaluations(self) -> None:
        """Verify mathematical precision of easing functions."""
        self.assertEqual(evaluate_analytical_easing(0.0, "SINE"), 0.0)
        self.assertAlmostEqual(evaluate_analytical_easing(0.5, "SINE"), 0.5, places=3)
        self.assertEqual(evaluate_analytical_easing(1.0, "SINE"), 1.0)

        self.assertEqual(evaluate_analytical_easing(0.0, "CUBIC"), 0.0)
        self.assertAlmostEqual(evaluate_analytical_easing(0.5, "CUBIC"), 0.875, places=3)
        self.assertEqual(evaluate_analytical_easing(1.0, "CUBIC"), 1.0)

    def test_cli_verification_output(self) -> None:
        """Verify run_verification payload."""
        res = run_verification()
        self.assertTrue(res["success"])
        self.assertEqual(res["tool"], "simulate_level_editor")
        self.assertTrue(res["is_case_valid"])
        self.assertEqual(len(res["verified_features"]), 5)


if __name__ == "__main__":
    unittest.main()
