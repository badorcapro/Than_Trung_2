"""Unit tests for Dupery Gameplay References Analyzer (DEC-26)."""

import unittest
from pathlib import Path

from scripts.agent.analyze_gameplay_references import (
    DEFAULT_GAMEPLAY_DIR,
    EXPECTED_VIDEOS,
    audit_gameplay_directory,
    probe_media_file,
)


class TestAnalyzeGameplayReferences(unittest.TestCase):
    """Test suite verifying gameplay video metrics against DEC-26."""

    def setUp(self) -> None:
        self.gameplay_dir = DEFAULT_GAMEPLAY_DIR

    def test_all_expected_videos_present_and_valid(self) -> None:
        report = audit_gameplay_directory(self.gameplay_dir)
        self.assertTrue(report["all_passed"], f"Audit failed: {report}")
        self.assertEqual(report["total_audited"], len(EXPECTED_VIDEOS))
        self.assertEqual(report["total_expected"], 6)

    def test_probe_media_file_on_menu_settings(self) -> None:
        test_file = self.gameplay_dir / "REF_MENU_GameSettings_1080p_60fps.mkv"
        probe = probe_media_file(test_file)
        self.assertIsNotNone(probe)
        assert probe is not None
        self.assertEqual(probe["width"], 1920)
        self.assertEqual(probe["height"], 1080)
        self.assertEqual(probe["fps"], 60.0)
        self.assertEqual(probe["audio_sample_rate_hz"], 48000)
        self.assertEqual(probe["audio_channels"], 2)


if __name__ == "__main__":
    unittest.main()
