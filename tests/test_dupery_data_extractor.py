"""Unit tests for dupery_xnode_parser and dupery_data_extractor."""

from __future__ import annotations

import json
import struct
import unittest
from pathlib import Path

from scripts.agent.dupery_data_extractor import (
    DEFAULT_DATA_DIR,
    clean_properties,
    verify_data_artifacts,
)
from scripts.agent.dupery_xnode_parser import XNodeBinaryReader, parse_xnode_binary


class TestDuperyDataExtractor(unittest.TestCase):
    """Test suite covering XNode binary parsing and data extraction artifacts."""

    def test_binary_reader_primitives(self) -> None:
        """Test XNodeBinaryReader on primitive binary datatypes."""
        data = struct.pack("<iiqfI4s", 42, -99, 1234567890123, 3.14, 4, b"test")
        reader = XNodeBinaryReader(data)
        self.assertEqual(reader.read_int(), 42)
        self.assertEqual(reader.read_int(), -99)
        self.assertEqual(reader.read_long(), 1234567890123)
        self.assertAlmostEqual(reader.read_float(), 3.14, places=2)
        self.assertEqual(reader.read_string(), "test")

    def test_clean_properties_filters_defaults(self) -> None:
        """Verify default MonoBehaviour metadata fields are filtered out."""
        raw = {
            "m_GameObject": {"m_FileID": 0, "m_PathID": 1},
            "m_Enabled": 1,
            "m_Script": {"m_FileID": 0, "m_PathID": 2},
            "m_Name": "TestName",
            "custom_property": 42,
            "speed": 10.5,
        }
        cleaned = clean_properties(raw)
        self.assertNotIn("m_GameObject", cleaned)
        self.assertNotIn("m_Enabled", cleaned)
        self.assertNotIn("m_Script", cleaned)
        self.assertNotIn("m_Name", cleaned)
        self.assertEqual(cleaned["custom_property"], 42)
        self.assertEqual(cleaned["speed"], 10.5)

    def test_parse_xnode_binary_short_buffer(self) -> None:
        """Verify parse_xnode_binary handles short or malformed data gracefully."""
        self.assertIsNone(parse_xnode_binary(b"too_short"))

    def test_data_artifacts_verification(self) -> None:
        """Verify generated artifacts via verify_data_artifacts()."""
        self.assertTrue(verify_data_artifacts(DEFAULT_DATA_DIR))

    def test_summary_metrics(self) -> None:
        """Verify exact metrics in data_catalog_summary.json."""
        summary_path = DEFAULT_DATA_DIR / "data_catalog_summary.json"
        self.assertTrue(summary_path.exists())
        with open(summary_path, "r", encoding="utf-8") as f:
            summary = json.load(f)

        self.assertEqual(summary["localisation"]["total_keys"], 1908)
        self.assertEqual(summary["localisation"]["total_languages"], 10)
        self.assertEqual(summary["xnode_graphs"]["story_graphs_count"], 18)
        self.assertEqual(summary["xnode_graphs"]["role_sets_count"], 68)
        self.assertEqual(summary["xnode_graphs"]["of_tutorial_6_nodes"], 53)

        cutscenes = summary["xnode_graphs"]["cutscenes"]
        self.assertIn("CasinoIntro", cutscenes)
        self.assertIn("DocksIntro", cutscenes)
        self.assertIn("SyndicateIntro", cutscenes)
        self.assertIn("TemplateTransition", cutscenes)

    def test_story_graph_connections(self) -> None:
        """Verify port connections in Of_Tutorial_6 graph."""
        graph_path = DEFAULT_DATA_DIR / "graphs" / "story_graphs" / "Of_Tutorial_6.json"
        self.assertTrue(graph_path.exists())
        with open(graph_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        self.assertEqual(data["node_count"], 53)
        self.assertEqual(len(data["nodes"]), 53)

        # Check that nodes contain valid coordinates and port connections
        has_connections = False
        for node in data["nodes"]:
            self.assertIn("position", node)
            self.assertEqual(len(node["position"]), 2)
            for port in node.get("ports", []):
                if port.get("connections"):
                    has_connections = True
                    break
        self.assertTrue(has_connections)


if __name__ == "__main__":
    unittest.main()
