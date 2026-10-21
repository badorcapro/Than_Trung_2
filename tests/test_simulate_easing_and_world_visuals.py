"""Unit tests for Dupery easing curves and world visuals simulation."""

import unittest
from scripts.agent.simulate_easing_and_world_visuals import (
    ease_in_sine,
    ease_out_sine,
    ease_in_out_sine,
    ease_in_elastic,
    ease_out_elastic,
    ease_in_back,
    ease_out_back,
    ease_in_out_back,
    ease_out_bounce,
    simulate_jiggle_recovery,
    simulate_casino_light_pattern,
    simulate_decor_shadow_motion,
    run_verification,
)


class TestSimulateEasingAndWorldVisuals(unittest.TestCase):
    """Test suite for analytical easing equations and visual simulations."""

    def test_easing_sine_curves(self):
        """Verify sine curve boundary and midpoint values."""
        self.assertEqual(ease_in_sine(0.0), 0.0)
        self.assertEqual(ease_in_sine(1.0), 1.0)
        self.assertEqual(ease_out_sine(0.0), 0.0)
        self.assertEqual(ease_out_sine(1.0), 1.0)
        self.assertEqual(ease_in_out_sine(0.0), 0.0)
        self.assertEqual(ease_in_out_sine(1.0), 1.0)
        self.assertAlmostEqual(ease_in_out_sine(0.5), 0.5, places=5)

    def test_easing_elastic_curves(self):
        """Verify elastic curve endpoints."""
        self.assertEqual(ease_in_elastic(0.0), 0.0)
        self.assertEqual(ease_in_elastic(1.0), 1.0)
        self.assertEqual(ease_out_elastic(0.0), 0.0)
        self.assertEqual(ease_out_elastic(1.0), 1.0)
        # Elastic overshoot in ease_out_elastic
        val_mid = ease_out_elastic(0.3)
        self.assertGreater(val_mid, 0.5)

    def test_easing_back_curves(self):
        """Verify back curve endpoints and overshoot characteristics."""
        self.assertEqual(ease_in_back(0.0), 0.0)
        self.assertEqual(ease_in_back(1.0), 1.0)
        self.assertEqual(ease_out_back(0.0), 0.0)
        self.assertEqual(ease_out_back(1.0), 1.0)
        self.assertEqual(ease_in_out_back(0.0), 0.0)
        self.assertEqual(ease_in_out_back(1.0), 1.0)
        # easeInBack dips below 0 near start
        self.assertLess(ease_in_back(0.2), 0.0)
        # easeOutBack rises above 1.0 near end
        self.assertGreater(ease_out_back(0.8), 1.0)

    def test_easing_bounce_curve(self):
        """Verify bounce decay endpoints and bounds."""
        self.assertEqual(ease_out_bounce(0.0), 0.0)
        self.assertEqual(ease_out_bounce(1.0), 1.0)
        for step in range(11):
            val = ease_out_bounce(step / 10.0)
            self.assertGreaterEqual(val, 0.0)
            self.assertLessEqual(val, 1.0)

    def test_jiggle_recovery(self):
        """Verify jiggle animation frame progression and decay."""
        frames = simulate_jiggle_recovery(scale_factor=1.08, rot_degrees=6.0, duration=0.75, fps=60)
        self.assertEqual(len(frames), 46)  # 0.75 * 60 + 1
        self.assertEqual(frames[0]["scale"], 1.08)
        self.assertEqual(frames[0]["rotation"], 6.0)
        self.assertAlmostEqual(frames[-1]["scale"], 1.0, places=2)
        self.assertAlmostEqual(frames[-1]["rotation"], 0.0, places=1)

    def test_casino_light_patterns(self):
        """Verify casino light sequencing patterns."""
        swap_half = simulate_casino_light_pattern("SWAP_HALF", bulb_count=4, cycles=1)
        self.assertEqual(len(swap_half), 2)
        self.assertEqual(swap_half[0], [True, False, True, False])
        self.assertEqual(swap_half[1], [False, True, False, True])

        swap_full = simulate_casino_light_pattern("SWAP_FULL", bulb_count=4, cycles=1)
        self.assertEqual(len(swap_full), 2)
        self.assertEqual(swap_full[0], [True, True, True, True])
        self.assertEqual(swap_full[1], [False, False, False, False])

        circle_2 = simulate_casino_light_pattern("CIRCLE_2", bulb_count=4, cycles=1)
        self.assertEqual(len(circle_2), 4)
        self.assertEqual(circle_2[0], [True, False, True, False])
        self.assertEqual(circle_2[1], [False, True, False, True])

        with self.assertRaises(ValueError):
            simulate_casino_light_pattern("UNKNOWN_PATTERN")

    def test_decor_shadow_motion(self):
        """Verify shadow rotation oscillation trajectory."""
        motion = simulate_decor_shadow_motion(duration=2.0, max_angle=1.0, fps=10)
        self.assertEqual(len(motion), 21)
        self.assertAlmostEqual(motion[0], -1.0, places=3)
        self.assertAlmostEqual(motion[10], 0.0, places=2)
        self.assertAlmostEqual(motion[-1], 1.0, places=3)

    def test_run_verification(self):
        """Verify end-to-end mathematical verification function."""
        self.assertTrue(run_verification())


if __name__ == "__main__":
    unittest.main()
