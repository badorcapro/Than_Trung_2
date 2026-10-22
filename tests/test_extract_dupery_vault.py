"""Unit tests for extract_dupery_vault module and manifest integrity."""

from __future__ import annotations

import hashlib
import json
import unittest
from pathlib import Path
from PIL import Image

from scripts.agent.extract_dupery_vault import (
    DEFAULT_MANIFEST,
    compute_bytes_sha256,
    get_image_png_bytes,
    is_valid_asset_file,
    verify_dupery_vault,
)


class TestExtractDuperyVault(unittest.TestCase):
    """Test suite covering vault scanning, hashing, and manifest validation."""

    def test_is_valid_asset_file(self) -> None:
        """Verify asset file filtering excludes binary streams."""
        self.assertTrue(is_valid_asset_file("sharedassets0.assets"))
        self.assertTrue(is_valid_asset_file("level0"))
        self.assertTrue(is_valid_asset_file("resources.assets"))
        self.assertFalse(is_valid_asset_file("sharedassets0.assets.resS"))
        self.assertFalse(is_valid_asset_file("unity default resources.resource"))
        self.assertFalse(is_valid_asset_file("data.bin"))

    def test_compute_bytes_sha256(self) -> None:
        """Verify deterministic SHA-256 hashing."""
        sample = b"dupery vault test payload"
        expected = hashlib.sha256(sample).hexdigest()
        self.assertEqual(compute_bytes_sha256(sample), expected)

    def test_get_image_png_bytes(self) -> None:
        """Verify PIL image serializes to valid PNG bytes."""
        img = Image.new("RGBA", (16, 16), color=(255, 0, 0, 255))
        png_bytes = get_image_png_bytes(img)
        self.assertTrue(png_bytes.startswith(b"\x89PNG\r\n\x1a\n"))

    def test_manifest_verification_and_counts(self) -> None:
        """Verify vault manifest exists, parses, and matches P2 inventory."""
        self.assertTrue(verify_dupery_vault(DEFAULT_MANIFEST))

        with open(DEFAULT_MANIFEST, "r", encoding="utf-8") as f:
            manifest = json.load(f)

        self.assertEqual(manifest["total_sprites"], 879)
        self.assertEqual(manifest["total_fonts"], 10)
        self.assertEqual(manifest["total_textures"], 752)
        self.assertEqual(len(manifest["sprites"]), 879)
        self.assertEqual(len(manifest["fonts"]), 10)
        self.assertEqual(len(manifest["textures"]), 752)

    def test_sprite_entry_structure(self) -> None:
        """Verify sprite entries contain Nine-Slice border and coordinates."""
        with open(DEFAULT_MANIFEST, "r", encoding="utf-8") as f:
            manifest = json.load(f)

        sample_sprite = manifest["sprites"][0]
        self.assertIn("name", sample_sprite)
        self.assertIn("asset_file", sample_sprite)
        self.assertIn("path_id", sample_sprite)
        self.assertIn("rect", sample_sprite)
        self.assertIn("pivot", sample_sprite)
        self.assertIn("border", sample_sprite)
        self.assertIn("pixels_per_unit", sample_sprite)
        self.assertIn("size", sample_sprite)
        self.assertIn("sha256", sample_sprite)

        border = sample_sprite["border"]
        self.assertIn("left", border)
        self.assertIn("bottom", border)
        self.assertIn("right", border)
        self.assertIn("top", border)

    def test_font_entry_structure(self) -> None:
        """Verify font entries contain binary size and cryptographic digest."""
        with open(DEFAULT_MANIFEST, "r", encoding="utf-8") as f:
            manifest = json.load(f)

        sample_font = manifest["fonts"][0]
        self.assertIn("name", sample_font)
        self.assertIn("size_bytes", sample_font)
        self.assertGreater(sample_font["size_bytes"], 0)
        self.assertIn("sha256", sample_font)
        self.assertEqual(len(sample_font["sha256"]), 64)


if __name__ == "__main__":
    unittest.main()
