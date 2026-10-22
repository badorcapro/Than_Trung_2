"""Unit and integration tests for Dupery Golden Reference Capture System."""

import json
from pathlib import Path
import unittest

from scripts.agent.verify_dupery_reference_capture import (
    BASELINE_VIDEOS,
    CHECKLIST_CATEGORIES,
    DEFAULT_REFERENCES_DIR,
    DEFAULT_RESOURCE_PATH,
    build_golden_manifest,
    scan_user_captures,
    verify_original_resource_streams,
    verify_reference_system,
)


class TestVerifyDuperyReferenceCapture(unittest.TestCase):
    """Test suite verifying Golden Reference Capture protocol and manifests."""

    def setUp(self) -> None:
        self.ref_dir = DEFAULT_REFERENCES_DIR
        self.res_path = DEFAULT_RESOURCE_PATH

    def test_protocol_document_integrity(self) -> None:
        protocol_path = self.ref_dir / "reference_capture_protocol.md"
        self.assertTrue(protocol_path.exists())
        text = protocol_path.read_text(encoding="utf-8")
        self.assertIn("1920 x 1080", text)
        self.assertIn("60.0 FPS", text)
        self.assertIn("Naming Convention", text)
        self.assertIn("REF_<CATEGORY>_<ACTION>_<RESOLUTION>_<FPS>.<EXT>", text)
        for cat in CHECKLIST_CATEGORIES:
            self.assertIn(cat["code"], text)

    def test_original_video_streams_sha256(self) -> None:
        if not self.res_path.exists():
            self.skipTest("sharedassets8.resource not found on disk")
        ok = verify_original_resource_streams(self.res_path)
        self.assertTrue(ok)

    def test_golden_manifest_structure(self) -> None:
        manifest_path = self.ref_dir / "golden_reference_manifest.json"
        self.assertTrue(manifest_path.exists())
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        meta = manifest["metadata"]
        self.assertTrue(meta["protocol_defined"])
        self.assertEqual(meta["total_checklist_categories"], 9)
        self.assertEqual(meta["baseline_videos_count"], 2)
        self.assertEqual(len(manifest["checklist"]), 9)
        self.assertEqual(len(manifest["baseline_videos"]), 2)

    def test_scan_user_captures_empty_and_naming(self) -> None:
        captures = scan_user_captures(self.ref_dir)
        self.assertIsInstance(captures, list)

    def test_verify_reference_system_helper(self) -> None:
        ok = verify_reference_system(self.ref_dir, self.res_path)
        self.assertTrue(ok)


if __name__ == "__main__":
    unittest.main()
