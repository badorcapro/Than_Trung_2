"""Unit tests for string catenary, Verlet physics, and tool simulation engine."""

from __future__ import annotations

import unittest

from scripts.agent.simulate_string_catenary import (
    Vector2D,
    calculate_magnifying_glass_timings,
    check_pin_string_snap,
    create_verlet_string,
    filter_drawing_stroke_points,
    step_verlet_physics,
    verify_string_catenary_simulation,
)


class TestSimulateStringCatenary(unittest.TestCase):
    """Test suite for StringManager, Verlet physics, and tool simulation."""

    def test_verlet_string_initialization(self) -> None:
        """Verify initial linear interpolation of segments."""
        start = Vector2D(0.0, 100.0)
        end = Vector2D(100.0, 100.0)
        segments = create_verlet_string(start, end, segment_count=11)
        self.assertEqual(len(segments), 11)
        self.assertAlmostEqual(segments[0].current_pos.x, 0.0)
        self.assertAlmostEqual(segments[5].current_pos.x, 50.0)
        self.assertAlmostEqual(segments[10].current_pos.x, 100.0)

    def test_verlet_physics_step_and_sag(self) -> None:
        """Verify Verlet integration causes string to sag under gravity while ends stay fixed."""
        start = Vector2D(0.0, 200.0)
        end = Vector2D(200.0, 200.0)
        seg_len = (200.0 * 1.1) / 19.0
        segments = create_verlet_string(start, end, segment_count=20)

        for _ in range(20):
            step_verlet_physics(segments, start, end, seg_len)

        # Endpoints must remain fixed
        self.assertAlmostEqual(segments[0].current_pos.x, 0.0)
        self.assertAlmostEqual(segments[0].current_pos.y, 200.0)
        self.assertAlmostEqual(segments[-1].current_pos.x, 200.0)
        self.assertAlmostEqual(segments[-1].current_pos.y, 200.0)

        # Midpoint must sag below 200.0
        mid = segments[10].current_pos.y
        self.assertLess(mid, 200.0)

    def test_pin_string_snap_threshold(self) -> None:
        """Verify snap radius logic based on StringManager.cs:57 (50px)."""
        pin = Vector2D(500.0, 500.0)
        # Inside snap
        self.assertTrue(check_pin_string_snap(Vector2D(530.0, 530.0), pin, snap_distance=50.0))
        # Outside snap
        self.assertFalse(check_pin_string_snap(Vector2D(540.0, 540.0), pin, snap_distance=50.0))

    def test_magnifying_glass_timings(self) -> None:
        """Verify 60fps frame counts for magnifying glass animation."""
        timings = calculate_magnifying_glass_timings(60.0)
        self.assertEqual(timings["open_frames"], 30)  # 0.5s * 60
        self.assertEqual(timings["close_frames"], 21)  # 0.35s * 60

    def test_drawing_stroke_filter(self) -> None:
        """Verify stroke filtering reduces redundant close vertices."""
        pts = [
            Vector2D(0.0, 0.0),
            Vector2D(1.0, 1.0),
            Vector2D(2.0, 2.0),
            Vector2D(10.0, 0.0),
            Vector2D(11.0, 0.0),
            Vector2D(20.0, 0.0),
        ]
        filtered = filter_drawing_stroke_points(pts, min_distance=5.0)
        self.assertEqual(len(filtered), 3)
        self.assertEqual(filtered[0], Vector2D(0.0, 0.0))
        self.assertEqual(filtered[1], Vector2D(10.0, 0.0))
        self.assertEqual(filtered[2], Vector2D(20.0, 0.0))

    def test_built_in_verification(self) -> None:
        """Verify built-in verify_string_catenary_simulation returns True."""
        self.assertTrue(verify_string_catenary_simulation())


if __name__ == "__main__":
    unittest.main()
