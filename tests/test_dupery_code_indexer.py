"""
Unit tests for Dupery code indexer and obligation ledger builder (TASK-0011).
"""

from __future__ import annotations

import json
from pathlib import Path
import tempfile
import unittest

from scripts.agent.dupery_code_indexer import (
    classify_type,
    parse_args,
    parse_csharp_file,
    verify_ledger,
)


class TestDuperyCodeIndexer(unittest.TestCase):
    """Test suite for type classification, C# parsing, and ledger verification."""

    def test_classify_type_tiers_and_rings(self) -> None:
        """Verify type classification assigns correct tier, vong, and depth."""
        # Tier 1 - Visual -> V1, L3
        tier, vong, depth = classify_type("Assembly-CSharp", "Visual", "CardVisualManager")
        self.assertEqual(tier, 1)
        self.assertEqual(vong, "V1")
        self.assertEqual(depth, "L3")

        # Tier 1 - CaseCreation -> V2, L3
        tier, vong, depth = classify_type("Assembly-CSharp", "CaseCreation", "LeadBoardFactory")
        self.assertEqual(tier, 1)
        self.assertEqual(vong, "V2")
        self.assertEqual(depth, "L3")

        # Tier 1 - Quirks -> V4, L3
        tier, vong, depth = classify_type("Assembly-CSharp", "Quirks", "ParanoidQuirk")
        self.assertEqual(tier, 1)
        self.assertEqual(vong, "V4")
        self.assertEqual(depth, "L3")

        # Tier 1 - Root Role -> V5
        tier, vong, depth = classify_type("Assembly-CSharp", "<Root>", "AssassinRole")
        self.assertEqual(tier, 1)
        self.assertEqual(vong, "V5")
        self.assertEqual(depth, "L3")

        # Tier 2 - Frameworks
        tier, vong, depth = classify_type("gildedrunegames.grglib", "GRGLib", "CoroutineLibrary")
        self.assertEqual(tier, 2)
        self.assertEqual(vong, "framework")

        tier, vong, depth = classify_type("XNode", "XNode", "NodeGraph")
        self.assertEqual(tier, 2)
        self.assertEqual(vong, "graph_engine")

    def test_parse_csharp_file_nested_types(self) -> None:
        """Verify parser correctly extracts top-level and nested types with inheritance."""
        cs_code = """
namespace TestGame.Logic
{
    public class OuterContainer : BaseEntity, IDisposable
    {
        public enum StateType
        {
            Idle,
            Active
        }

        private struct InnerData
        {
            public int Value;
        }
    }
}
"""
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp_root = Path(tmp_dir)
            f_path = tmp_root / "OuterContainer.cs"
            f_path.write_text(cs_code, encoding="utf-8")

            types = parse_csharp_file(f_path, tmp_root)
            self.assertEqual(len(types), 3)

            # Outer class
            outer = types[0]
            self.assertEqual(outer["name"], "OuterContainer")
            self.assertEqual(outer["kind"], "class")
            self.assertFalse(outer["is_nested"])
            self.assertIsNone(outer["nested_of"])
            self.assertEqual(outer["base_type"], "BaseEntity")
            self.assertIn("IDisposable", outer["interfaces"])

            # Inner enum
            inner_enum = types[1]
            self.assertEqual(inner_enum["name"], "StateType")
            self.assertEqual(inner_enum["kind"], "enum")
            self.assertTrue(inner_enum["is_nested"])
            self.assertEqual(inner_enum["nested_of"], "OuterContainer")
            self.assertEqual(inner_enum["full_name"], "TestGame.Logic.OuterContainer/StateType")

            # Inner struct
            inner_struct = types[2]
            self.assertEqual(inner_struct["name"], "InnerData")
            self.assertEqual(inner_struct["kind"], "struct")
            self.assertTrue(inner_struct["is_nested"])
            self.assertEqual(inner_struct["nested_of"], "OuterContainer")

    def test_verify_ledger_missing_files(self) -> None:
        """Verify verification fails when catalog or ledger is missing."""
        passed, errors = verify_ledger(
            Path("/nonexistent/catalog.json"),
            Path("/nonexistent/ledger.json"),
            Path("/nonexistent"),
        )
        self.assertFalse(passed)
        self.assertTrue(any("missing" in e.lower() for e in errors))

    def test_verify_real_ledger_passes(self) -> None:
        """Verify real catalog and ledger pass verification if generated."""
        from scripts.agent.dupery_code_indexer import DEFAULT_CATALOG, DEFAULT_LEDGER, ROOT_DIR
        if DEFAULT_CATALOG.exists() and DEFAULT_LEDGER.exists():
            passed, errors = verify_ledger(DEFAULT_CATALOG, DEFAULT_LEDGER, ROOT_DIR)
            self.assertTrue(passed, f"Real verification failed: {errors}")
            self.assertEqual(len(errors), 0)

    def test_parse_args(self) -> None:
        """Verify argument parser flags."""
        args = parse_args(["--verify", "--stats"])
        self.assertTrue(args.verify)
        self.assertTrue(args.stats)


if __name__ == "__main__":
    unittest.main()
