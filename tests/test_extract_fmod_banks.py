"""Unit and integration tests for Dupery FMOD Banks and Event Map Extractor."""

import json
from pathlib import Path
import unittest

from scripts.agent.extract_fmod_banks import (
    DEFAULT_OUT_DIR,
    DEFAULT_STREAMING_ASSETS,
    parse_fsb5,
    parse_fmod_strings_bank,
    parse_audio_references_raw,
    verify_extraction,
)


class TestExtractFmodBanks(unittest.TestCase):
    """Test suite verifying FMOD banks parsing and cross-system mappings."""

    def setUp(self) -> None:
        self.streaming_dir = DEFAULT_STREAMING_ASSETS
        self.out_dir = DEFAULT_OUT_DIR

    def test_parse_fsb5_header_real_bank(self) -> None:
        intro_bank = self.streaming_dir / "Intro.bank"
        if not intro_bank.exists():
            self.skipTest("Intro.bank not found on disk")
        data = intro_bank.read_bytes()
        fsb = parse_fsb5(data)
        self.assertIsNotNone(fsb)
        assert fsb is not None
        self.assertEqual(fsb["num_samples"], 2)
        self.assertEqual(fsb["codec_mode"], 15)
        self.assertEqual(len(fsb["samples"]), 2)
        self.assertIn("IntroEnglishVO", fsb["samples"])

    def test_parse_fmod_strings_bank(self) -> None:
        strings_bank = self.streaming_dir / "Master.strings.bank"
        if not strings_bank.exists():
            self.skipTest("Master.strings.bank not found on disk")
        data = strings_bank.read_bytes()
        guids, events = parse_fmod_strings_bank(data)
        self.assertEqual(len(guids), 62)
        self.assertGreaterEqual(len(events), 50)
        self.assertIn("{be55ab93-3ba5-4530-b890-2087b710f0d8}", events)
        self.assertEqual(events["{be55ab93-3ba5-4530-b890-2087b710f0d8}"], "event:/mUSIC/a_MainTheme")

    def test_parse_audio_references_empty_fallback(self) -> None:
        empty_res = parse_audio_references_raw(b"invalid_raw_bytes")
        self.assertEqual(empty_res, {"music": [], "sfx": [], "atmo": []})

    def test_banks_manifest_artifact(self) -> None:
        m_path = self.out_dir / "fmod_banks_manifest.json"
        self.assertTrue(m_path.exists())
        manifest = json.loads(m_path.read_text(encoding="utf-8"))
        meta = manifest["metadata"]
        self.assertEqual(meta["total_banks"], 6)
        self.assertEqual(meta["total_samples"], 155)

        sample_counts = {b["name"]: (b["fsb5_info"]["num_samples"] if b["has_fsb5"] else 0) for b in manifest["banks"]}
        self.assertEqual(sample_counts["Atmosphere.bank"], 21)
        self.assertEqual(sample_counts["Intro.bank"], 2)
        self.assertEqual(sample_counts["Music.bank"], 79)
        self.assertEqual(sample_counts["Sfx.bank"], 53)
        self.assertEqual(sample_counts["Master.bank"], 0)
        self.assertEqual(sample_counts["Master.strings.bank"], 0)

    def test_event_map_artifact(self) -> None:
        e_path = self.out_dir / "fmod_event_map.json"
        self.assertTrue(e_path.exists())
        event_map = json.loads(e_path.read_text(encoding="utf-8"))
        meta = event_map["metadata"]
        self.assertEqual(meta["total_mapped_enums"], 50)
        self.assertEqual(meta["total_guids_in_bank"], 62)
        self.assertIn("FMOD compiled bank bytecode does not preserve dynamic musical transition curves", meta["limitations_notice"])

        cs = event_map["cross_system_mappings"]
        self.assertEqual(len(cs["music"]), 10)
        self.assertEqual(len(cs["atmosphere"]), 8)
        self.assertEqual(len(cs["sfx"]), 32)
        self.assertEqual(len(cs["intro_cutscenes"]), 2)
        self.assertEqual(len(event_map["parameters"]), 2)
        self.assertEqual(len(event_map["busses"]), 2)

    def test_verify_extraction_helper(self) -> None:
        m_path = self.out_dir / "fmod_banks_manifest.json"
        e_path = self.out_dir / "fmod_event_map.json"
        self.assertTrue(verify_extraction(m_path, e_path))


if __name__ == "__main__":
    unittest.main()
