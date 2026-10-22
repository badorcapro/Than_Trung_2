"""Unit tests for detective board layout and snap grid simulation engine."""

from __future__ import annotations

import unittest

from scripts.agent.simulate_board_layout import (
    DEFAULT_CELL_SIZE,
    DEFAULT_GRID_CENTER,
    Vector2D,
    calculate_pin_drop_timing,
    calculate_visual_classification_extra,
    compute_board_scale,
    compute_grid_start_position,
    compute_slot_true_position,
    find_nearest_slot,
    generate_board_slots,
    verify_board_simulation,
)


class TestSimulateBoardLayout(unittest.TestCase):
    """Test suite for BoardVisualManager and DragPin mathematical simulation."""

    def test_board_scale_factors(self) -> None:
        """Verify scale rules based on BoardVisualManager.cs:174-176."""
        self.assertEqual(compute_board_scale(2, 2), 1.15)
        self.assertEqual(compute_board_scale(3, 3), 1.15)
        self.assertEqual(compute_board_scale(4, 4), 1.0)
        self.assertEqual(compute_board_scale(5, 5), 0.85)
        self.assertEqual(compute_board_scale(3, 4), 1.0)
        self.assertEqual(compute_board_scale(2, 5), 0.85)

    def test_grid_start_position(self) -> None:
        """Verify grid start position offset calculation."""
        start_4x4 = compute_grid_start_position(4, 4)
        expected_x = DEFAULT_GRID_CENTER.x - (1.5 * DEFAULT_CELL_SIZE.x)
        expected_y = DEFAULT_GRID_CENTER.y - (1.5 * DEFAULT_CELL_SIZE.y)
        self.assertAlmostEqual(start_4x4.x, expected_x)
        self.assertAlmostEqual(start_4x4.y, expected_y)

    def test_slot_coordinates_and_grid_count(self) -> None:
        """Verify slot generation count and progression."""
        slots_3x3 = generate_board_slots(3, 3)
        self.assertEqual(len(slots_3x3), 9)

        slots_4x4 = generate_board_slots(4, 4)
        self.assertEqual(len(slots_4x4), 16)

        slot_0_0 = slots_4x4[(0, 0)]
        slot_1_0 = slots_4x4[(1, 0)]
        self.assertAlmostEqual(slot_1_0.x - slot_0_0.x, DEFAULT_CELL_SIZE.x)
        self.assertAlmostEqual(slot_1_0.y, slot_0_0.y)

    def test_nearest_slot_snap(self) -> None:
        """Verify DragPin snap radius behavior."""
        slots = generate_board_slots(4, 4)
        target_slot = slots[(2, 2)]

        near_pos = target_slot + Vector2D(30.0, -40.0)
        res = find_nearest_slot(near_pos, slots, snap_radius=100.0)
        self.assertIsNotNone(res)
        self.assertEqual(res[0], (2, 2))
        self.assertAlmostEqual(res[1], 50.0)

        far_pos = target_slot + Vector2D(150.0, 150.0)
        res_far = find_nearest_slot(far_pos, slots, snap_radius=100.0)
        self.assertIsNone(res_far)

    def test_pin_drop_60fps_timing(self) -> None:
        """Verify pin drop tween frames and audio synchronization."""
        timing_60 = calculate_pin_drop_timing(60.0)
        self.assertEqual(timing_60["duration_sec"], 0.4)
        self.assertEqual(timing_60["total_frames"], 24)
        self.assertEqual(timing_60["sound_trigger_sec"], 0.3)
        self.assertEqual(timing_60["sound_trigger_frame"], 18)

    def test_visual_classification_ratio(self) -> None:
        """Verify ratio adjustment logic from VisualClassificationRatioGC."""
        roles = [
            ("MURDERER", "INNOCENT"),
            ("INNOCENT", "MURDERER"),
            ("INNOCENT", "INNOCENT"),
        ]
        self.assertEqual(calculate_visual_classification_extra("MURDERER", roles), 0)

        roles_disguised_killer = [("MURDERER", "INNOCENT")]
        self.assertEqual(calculate_visual_classification_extra("MURDERER", roles_disguised_killer), -1)

        roles_framed_innocent = [("INNOCENT", "MURDERER")]
        self.assertEqual(calculate_visual_classification_extra("MURDERER", roles_framed_innocent), 1)

    def test_full_verification_routine(self) -> None:
        """Verify the built-in verify_board_simulation function returns True."""
        self.assertTrue(verify_board_simulation())


if __name__ == "__main__":
    unittest.main()
