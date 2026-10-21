"""Unit and integration tests for Dupery Runtime Probe Spike and Determinism."""

import json
from pathlib import Path
import unittest

from scripts.agent.dupery_runtime_probe import (
    DEFAULT_GAME_DIR,
    DEFAULT_PROBES_DIR,
    DotNetRandom,
    compute_easing_values,
    verify_game_cleanliness,
    verify_seed_determinism,
    verify_spike_artifacts,
)


class TestDuperyRuntimeProbe(unittest.TestCase):
    """Test suite verifying Runtime Probe spike analysis and offline proofs."""

    def setUp(self) -> None:
        self.game_dir = DEFAULT_GAME_DIR
        self.probes_dir = DEFAULT_PROBES_DIR

    def test_dotnet_random_determinism(self) -> None:
        self.assertTrue(verify_seed_determinism(seed=42, count=50))
        self.assertTrue(verify_seed_determinism(seed=9999, count=50))

    def test_easing_curve_endpoints(self) -> None:
        models = compute_easing_values()
        for curve_name in ["ease_in_back", "ease_out_back", "ease_in_sine", "ease_out_sine", "ease_in_out_sine"]:
            self.assertIn(curve_name, models)
            samples = models[curve_name]
            self.assertEqual(len(samples), 5)
            self.assertAlmostEqual(samples[0], 0.0, places=3)
            self.assertAlmostEqual(samples[4], 1.0, places=3)

    def test_game_directory_cleanliness(self) -> None:
        clean = verify_game_cleanliness(self.game_dir)
        self.assertTrue(clean)

    def test_spike_report_and_decision_manifest(self) -> None:
        report_path = self.probes_dir / "runtime_probe_spike_report.md"
        decision_path = self.probes_dir / "runtime_probe_decision.json"
        self.assertTrue(report_path.exists())
        self.assertTrue(decision_path.exists())

        decision = json.loads(decision_path.read_text(encoding="utf-8"))
        self.assertEqual(decision["decision"]["verdict"], "NO-GO")
        self.assertEqual(decision["decision"]["status"], "NO_GO_FALLBACK_TO_OFFLINE_VERIFICATION")
        self.assertTrue(decision["offline_verification"]["determinism_verified"])
        self.assertIn("ease_in_back", decision["offline_verification"]["analytical_easing_curves"])

    def test_verify_spike_artifacts_helper(self) -> None:
        ok = verify_spike_artifacts(self.probes_dir, self.game_dir)
        self.assertTrue(ok)


if __name__ == "__main__":
    unittest.main()
