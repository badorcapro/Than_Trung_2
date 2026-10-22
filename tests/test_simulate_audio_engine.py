#!/usr/bin/env python3
"""Unit tests for Interactive Audio Engine Simulator (TASK-0027A)."""

import unittest

from scripts.agent.simulate_audio_engine import (
    AudioBusType,
    AudioEngineManager,
    run_verification,
)


class TestSimulateAudioEngine(unittest.TestCase):
    """Test suite for AudioEngineManager, buses, stem mixer, and snapshot states."""

    def setUp(self) -> None:
        self.engine = AudioEngineManager()

    def test_audio_server_bus_hierarchy(self) -> None:
        """Verify bus hierarchy, initial volume, and parent routing."""
        self.assertEqual(self.engine.master_bus.name, AudioBusType.MASTER)
        self.assertEqual(self.engine.master_bus.volume_db, 0.0)
        self.assertIsNone(self.engine.master_bus.parent)

        self.assertEqual(self.engine.music_bus.volume_db, -6.0)
        self.assertEqual(self.engine.music_bus.parent, self.engine.master_bus)

        self.assertEqual(self.engine.atmo_bus.volume_db, -8.0)
        self.assertEqual(self.engine.sfx_bus.volume_db, 0.0)
        self.assertEqual(self.engine.reverb_bus.volume_db, -12.0)

    def test_interactive_music_stem_mixing(self) -> None:
        """Verify stem activation and volume boundaries (-80 dB to 0 dB)."""
        self.assertEqual(self.engine.music.stems["Drums"], -80.0)
        self.engine.music.set_stem_volume("Drums", 0.0)
        self.assertEqual(self.engine.music.stems["Drums"], 0.0)

        self.engine.music.set_stem_volume("Piano", 10.0)  # Clamped to 0.0
        self.assertEqual(self.engine.music.stems["Piano"], 0.0)

        self.engine.music.set_stem_volume("Bass", -100.0)  # Clamped to -80.0
        self.assertEqual(self.engine.music.stems["Bass"], -80.0)

    def test_saxophone_solo_improvisation(self) -> None:
        """Verify saxophone solo improvisation selection and pool size."""
        self.assertEqual(len(self.engine.music.SAX_SOLOS), 16)
        solo = self.engine.music.trigger_sax_solo(seed=123)
        self.assertIn(solo, self.engine.music.SAX_SOLOS)
        self.assertEqual(self.engine.music.active_solo, solo)

    def test_atmo_soundscape_layers(self) -> None:
        """Verify multi-layered ambient loop registration and removal."""
        self.assertEqual(len(self.engine.atmo.active_layers), 0)
        self.engine.atmo.play_atmo("soft-rain-ambient", -4.0)
        self.engine.atmo.play_atmo("ocean-waves", -6.0)
        self.assertEqual(len(self.engine.atmo.active_layers), 2)
        self.assertEqual(self.engine.atmo.active_layers["soft-rain-ambient"], -4.0)

        self.engine.atmo.stop_atmo("soft-rain-ambient")
        self.assertEqual(len(self.engine.atmo.active_layers), 1)
        self.assertNotIn("soft-rain-ambient", self.engine.atmo.active_layers)

    def test_sfx_pitch_randomization_and_debounce(self) -> None:
        """Verify SFX pitch modulation and time-based debouncing."""
        played_1 = self.engine.sfx.play_sfx("CardFlip", current_time_ms=0.0, seed=42)
        self.assertTrue(played_1)

        played_2 = self.engine.sfx.play_sfx("CardFlip", current_time_ms=15.0, seed=43)  # < 30ms window
        self.assertFalse(played_2)

        played_3 = self.engine.sfx.play_sfx("CardFlip", current_time_ms=35.0, seed=44)  # >= 30ms window
        self.assertTrue(played_3)
        self.assertEqual(len(self.engine.sfx.played_history), 2)

    def test_game_pause_snapshot_lpf(self) -> None:
        """Verify GAME_PAUSE lowpass filter activation and volume ducking."""
        self.assertFalse(self.engine.is_paused)
        self.assertTrue(self.engine.music_bus.lowpass_bypass)

        self.engine.set_pause(True)
        self.assertTrue(self.engine.is_paused)
        self.assertFalse(self.engine.music_bus.lowpass_bypass)
        self.assertEqual(self.engine.music_bus.lowpass_cutoff_hz, 600.0)
        self.assertEqual(self.engine.music_bus.volume_db, -10.0)

        self.engine.set_pause(False)
        self.assertFalse(self.engine.is_paused)
        self.assertTrue(self.engine.music_bus.lowpass_bypass)
        self.assertEqual(self.engine.music_bus.lowpass_cutoff_hz, 20000.0)
        self.assertEqual(self.engine.music_bus.volume_db, -6.0)

    def test_cli_verification_output(self) -> None:
        """Verify self-verification payload integrity."""
        res = run_verification()
        self.assertTrue(res["success"])
        self.assertEqual(res["tool"], "simulate_audio_engine")
        self.assertEqual(len(res["verified_features"]), 6)


if __name__ == "__main__":
    unittest.main()
