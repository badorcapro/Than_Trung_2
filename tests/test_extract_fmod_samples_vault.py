"""Unit tests for FMOD audio samples vault extractor and manifest verification."""

from __future__ import annotations

import json
from pathlib import Path
import unittest

from scripts.agent.extract_fmod_samples_vault import (
    DEFAULT_MANIFEST_PATH,
    DEFAULT_VAULT_AUDIO_DIR,
    sanitize_filename,
    verify_samples_vault,
)


class TestExtractFmodSamplesVault(unittest.TestCase):
    """Test suite for FMOD samples vault extraction and verification."""

    def test_sanitize_filename(self) -> None:
        """Verify filename sanitization handles special characters properly."""
        self.assertEqual(sanitize_filename("Clean_Name"), "Clean_Name")
        self.assertEqual(sanitize_filename("Bad:Name/With*Chars?"), "Bad_Name_With_Chars_")
        self.assertEqual(sanitize_filename("   "), "unnamed_sample")

    def test_manifest_structure_and_counts(self) -> None:
        """Verify manifest contains all 155 samples across 4 banks."""
        self.assertTrue(DEFAULT_MANIFEST_PATH.is_file(), f"Missing manifest: {DEFAULT_MANIFEST_PATH}")
        data = json.loads(DEFAULT_MANIFEST_PATH.read_text(encoding="utf-8"))

        self.assertEqual(data.get("total_samples"), 155)
        self.assertEqual(data.get("total_banks"), 4)

        breakdown = data.get("bank_breakdown", {})
        self.assertEqual(breakdown.get("Atmosphere"), 21)
        self.assertEqual(breakdown.get("Intro"), 2)
        self.assertEqual(breakdown.get("Music"), 79)
        self.assertEqual(breakdown.get("Sfx"), 53)

        self.assertGreater(data.get("total_pcm_bytes", 0), 1_500_000_000)
        self.assertGreater(data.get("total_wav_bytes", 0), 1_500_000_000)
        self.assertGreater(data.get("total_duration_seconds", 0), 8000)

    def test_sample_metadata_fields(self) -> None:
        """Verify all samples possess complete and valid audio metadata."""
        data = json.loads(DEFAULT_MANIFEST_PATH.read_text(encoding="utf-8"))
        samples = data.get("samples", [])
        self.assertEqual(len(samples), 155)

        required_keys = {
            "index", "bank", "sample_name", "filename", "path",
            "channels", "bits_per_sample", "sample_rate_hz",
            "pcm_length_bytes", "wav_size_bytes", "duration_seconds", "sha256"
        }

        for s in samples:
            self.assertTrue(required_keys.issubset(s.keys()))
            self.assertIn(s["bank"], ["Atmosphere", "Intro", "Music", "Sfx"])
            self.assertIn(s["channels"], [1, 2])
            self.assertEqual(s["bits_per_sample"], 16)
            self.assertIn(s["sample_rate_hz"], [44100, 48000])
            self.assertGreater(s["pcm_length_bytes"], 0)
            self.assertGreater(s["wav_size_bytes"], 0)
            self.assertGreater(s["duration_seconds"], 0.0)
            self.assertEqual(len(s["sha256"]), 64)

    def test_verify_helper(self) -> None:
        """Verify verify_samples_vault reports true against real samples on disk."""
        ok = verify_samples_vault(DEFAULT_MANIFEST_PATH)
        self.assertTrue(ok)

    def test_fmod_lessons_document(self) -> None:
        """Verify FMOD architecture lessons document exists and covers core sections."""
        lessons_doc = Path("docs/agent-system/evidence/dupery/audio/fmod_audio_architecture_lessons.md")
        self.assertTrue(lessons_doc.is_file(), f"Missing lessons document: {lessons_doc}")
        content = lessons_doc.read_text(encoding="utf-8")
        self.assertIn("Atmosphere", content)
        self.assertIn("IntroEnglishVO", content)
        self.assertIn("The Ocean's Shadow", content)
        self.assertIn("TASK-0027", content)


if __name__ == "__main__":
    unittest.main()
