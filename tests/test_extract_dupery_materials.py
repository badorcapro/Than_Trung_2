"""Unit tests for extract_dupery_materials module and visual artifacts."""

from __future__ import annotations

import json
import unittest
from pathlib import Path

from scripts.agent.extract_dupery_materials import (
    DEFAULT_OUT_DIR,
    is_valid_asset_file,
    verify_materials_and_shaders,
)


class TestExtractDuperyMaterials(unittest.TestCase):
    """Test suite covering Materials, Shaders, VideoClips, and Negative Findings."""

    def test_is_valid_asset_file(self) -> None:
        """Verify asset filtering excludes binary streams."""
        self.assertTrue(is_valid_asset_file("sharedassets0.assets"))
        self.assertTrue(is_valid_asset_file("level0"))
        self.assertFalse(is_valid_asset_file("sharedassets0.assets.resS"))
        self.assertFalse(is_valid_asset_file("unity default resources.resource"))

    def test_verify_materials_and_shaders(self) -> None:
        """Verify all material artifacts pass automated verification."""
        self.assertTrue(verify_materials_and_shaders(DEFAULT_OUT_DIR))

    def test_materials_summary_counts(self) -> None:
        """Verify exact inventory counts in materials_summary.json."""
        summary_path = DEFAULT_OUT_DIR / "materials_summary.json"
        self.assertTrue(summary_path.exists())
        with open(summary_path, "r", encoding="utf-8") as f:
            summary = json.load(f)

        self.assertEqual(summary["total_materials"], 54)
        self.assertEqual(summary["total_shaders"], 46)
        self.assertEqual(summary["total_videoclips"], 2)

        neg = summary["negative_findings"]
        self.assertEqual(neg["AnimationClip"], 0)
        self.assertEqual(neg["Animator"], 0)
        self.assertEqual(neg["AnimatorController"], 0)
        self.assertEqual(neg["ParticleSystem"], 0)

    def test_negative_findings_certificate(self) -> None:
        """Verify formal P2 negative findings certification."""
        neg_path = DEFAULT_OUT_DIR / "negative_findings.json"
        self.assertTrue(neg_path.exists())
        with open(neg_path, "r", encoding="utf-8") as f:
            neg = json.load(f)

        self.assertTrue(neg.get("p2_verified"))
        self.assertIn("recheck_command", neg)
        self.assertIn("CoroutineLibrary", neg.get("architectural_finding", ""))

    def test_videoclips_catalog(self) -> None:
        """Verify both Dupery Intro video clips are cataloged."""
        vids_path = DEFAULT_OUT_DIR / "videoclips_catalog.json"
        self.assertTrue(vids_path.exists())
        with open(vids_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        self.assertEqual(data["total_videoclips"], 2)
        names = [v["name"] for v in data["videoclips"]]
        self.assertIn("Dupery Intro English", names)
        self.assertIn("Dupery Intro Cutscene", names)

    def test_shaders_catalog_source_notes(self) -> None:
        """Verify shaders explicitly document compiled bytecode status."""
        shaders_path = DEFAULT_OUT_DIR / "shaders_catalog.json"
        self.assertTrue(shaders_path.exists())
        with open(shaders_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        self.assertEqual(data["total_shaders"], 46)
        for s in data["shaders"]:
            self.assertEqual(s.get("source_status"), "compiled_gpu_bytecode_only")
            self.assertIn("Original HLSL source code is not preserved", s.get("source_note", ""))

    def test_materials_catalog_properties(self) -> None:
        """Verify materials contain shader references and properties."""
        mats_path = DEFAULT_OUT_DIR / "materials_catalog.json"
        self.assertTrue(mats_path.exists())
        with open(mats_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        self.assertEqual(data["total_materials"], 54)
        has_shader_ref = any(m["shader_name"] != "Unknown" for m in data["materials"])
        self.assertTrue(has_shader_ref)

        key_search = next((m for m in data["materials"] if m["name"] == "KeysearchBackground"), None)
        self.assertIsNotNone(key_search)
        self.assertEqual(key_search["shader_name"], "Shader Graphs/ImageHole")


if __name__ == "__main__":
    unittest.main()
