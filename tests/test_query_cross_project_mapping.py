"""Unit tests for Cross-Project Mapping and Live Recipe Query Tool (TASK-0032)."""

import unittest
from pathlib import Path

from scripts.agent.query_cross_project_mapping import (
    DEFAULT_MAPPING,
    format_recipe_card,
    load_mapping_artifact,
    search_mappings,
    verify_mapping_integrity,
)


class TestQueryCrossProjectMapping(unittest.TestCase):
    """Test suite verifying cross-project subgraph mapping and query CLI."""

    def setUp(self) -> None:
        self.mapping_path = DEFAULT_MAPPING
        self.data = load_mapping_artifact(self.mapping_path)

    def test_official_mapping_passes_verification(self) -> None:
        passed, errors, stats = verify_mapping_integrity(self.data)
        self.assertTrue(passed, f"Mapping verification failed: {errors}")
        self.assertEqual(len(errors), 0)
        self.assertEqual(stats["total_mappings"], 12)
        self.assertEqual(stats["verified_handbooks"], 12)
        self.assertEqual(stats["verified_videos"], 12)

    def test_search_by_vong_filter(self) -> None:
        results = search_mappings(self.data, vong="V1")
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]["id"], "MAP-V1-BOARD")

    def test_search_by_keyword_filter(self) -> None:
        results = search_mappings(self.data, keyword="Catenary")
        self.assertGreaterEqual(len(results), 1)
        self.assertEqual(results[0]["id"], "MAP-V1-BOARD")

    def test_format_recipe_card_contains_provenance(self) -> None:
        results = search_mappings(self.data, map_id="MAP-V2-CASEGEN")
        self.assertEqual(len(results), 1)
        card = format_recipe_card(results[0])
        self.assertIn("RECIPE [MAP-V2-CASEGEN]", card)
        self.assertIn("Godot Target:", card)
        self.assertIn("Golden Video:", card)
        self.assertIn("Live Lookup:", card)


if __name__ == "__main__":
    unittest.main()
