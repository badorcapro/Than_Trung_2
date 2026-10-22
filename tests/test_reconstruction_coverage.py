"""Unit tests for Dupery Reconstruction Obligation Coverage Evaluator (TASK-0030)."""

import json
import unittest
from pathlib import Path

from scripts.agent.evaluate_reconstruction_coverage import (
    DEFAULT_CATALOG,
    DEFAULT_LEDGER,
    EXPECTED_DEPTH_TARGETS,
    EXPECTED_TOTAL_CLASSES,
    EXPECTED_VONG_DISTRIBUTION,
    evaluate_ledger_coverage,
    load_json_artifact,
)


class TestReconstructionCoverage(unittest.TestCase):
    """Test suite verifying reconstruction obligation ledger invariants and multi-tier coverage."""

    def setUp(self) -> None:
        self.ledger_path = DEFAULT_LEDGER
        self.catalog_path = DEFAULT_CATALOG
        self.ledger = load_json_artifact(self.ledger_path)
        self.catalog = load_json_artifact(self.catalog_path)
        self.entries = self.ledger.get("entries", [])

    def test_ledger_and_catalog_total_count(self) -> None:
        self.assertEqual(len(self.entries), EXPECTED_TOTAL_CLASSES)
        self.assertEqual(self.catalog.get("total_types"), EXPECTED_TOTAL_CLASSES)

    def test_zero_unaccounted_and_zero_pending(self) -> None:
        unaccounted = [e for e in self.entries if e.get("reconstruction_status") != "documented"]
        self.assertEqual(len(unaccounted), 0, f"Found non-documented classes: {unaccounted[:5]}")
        summary = self.ledger.get("summary", {})
        self.assertEqual(summary.get("unaccounted"), 0)

    def test_three_tier_depth_distribution(self) -> None:
        depths = {}
        for e in self.entries:
            d = e.get("current_depth")
            depths[d] = depths.get(d, 0) + 1
        for d_key, exp_count in EXPECTED_DEPTH_TARGETS.items():
            self.assertEqual(
                depths.get(d_key, 0),
                exp_count,
                f"Depth {d_key} mismatch: actual {depths.get(d_key)} != expected {exp_count}",
            )

    def test_vong_distribution_matrix(self) -> None:
        vongs = {}
        for e in self.entries:
            v = e.get("vong")
            vongs[v] = vongs.get(v, 0) + 1
        for v_key, exp_count in EXPECTED_VONG_DISTRIBUTION.items():
            self.assertEqual(
                vongs.get(v_key, 0),
                exp_count,
                f"Vong {v_key} mismatch: actual {vongs.get(v_key)} != expected {exp_count}",
            )

    def test_localisation_activation_registered(self) -> None:
        target = next((e for e in self.entries if e.get("type_name") == "LocalisationActivation"), None)
        self.assertIsNotNone(target)
        assert target is not None
        self.assertEqual(target.get("vong"), "V6")
        self.assertEqual(target.get("current_depth"), "L2")
        self.assertEqual(target.get("reconstruction_status"), "documented")

    def test_evaluate_ledger_coverage_returns_pass(self) -> None:
        report = evaluate_ledger_coverage(self.ledger_path, self.catalog_path)
        self.assertTrue(report["is_coverage_complete"])
        self.assertEqual(report["metrics"]["unaccounted"], 0)
        self.assertEqual(report["metrics"]["documented"], EXPECTED_TOTAL_CLASSES)


if __name__ == "__main__":
    unittest.main()
