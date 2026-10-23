"""Unit tests for detective board and suspect card presentation rebuild (DO-05)."""

from __future__ import annotations

import os
import re
import unittest


class TestDetectiveBoardPresentation(unittest.TestCase):
    """Test suite for SuspectCard, VSCaseMain, and CatenaryYarnLayer presentation."""

    def setUp(self) -> None:
        self.workspace_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.suspect_card_tscn = os.path.join(
            self.workspace_root, "Than_Tham_Nua_Voi_Godot", "scenes", "case_gameplay", "SuspectCard.tscn"
        )
        self.vs_case_main_tscn = os.path.join(
            self.workspace_root, "Than_Tham_Nua_Voi_Godot", "scenes", "case_gameplay", "VSCaseMain.tscn"
        )
        self.suspect_card_script = os.path.join(
            self.workspace_root, "Than_Tham_Nua_Voi_Godot", "scripts", "presentation", "case_gameplay", "SuspectCardController.gd"
        )
        self.vs_case_main_script = os.path.join(
            self.workspace_root, "Than_Tham_Nua_Voi_Godot", "scripts", "presentation", "case_gameplay", "VSCaseMainController.gd"
        )
        self.yarn_layer_script = os.path.join(
            self.workspace_root, "Than_Tham_Nua_Voi_Godot", "scripts", "presentation", "case_gameplay", "CatenaryYarnLayer.gd"
        )
        self.props_dir = os.path.join(
            self.workspace_root, "Than_Tham_Nua_Voi_Godot", "assets", "ui", "dupery_props"
        )
        self.sfx_dir = os.path.join(
            self.workspace_root, "Than_Tham_Nua_Voi_Godot", "assets", "audio", "sfx"
        )

    def test_asset_files_exist(self) -> None:
        """Verify that all copied dupery sprites and audio SFX exist on disk."""
        required_sprites = [
            "board_desk_background.png",
            "card_outer_frame.png",
            "card_shadow.png",
            "door_01.png",
            "door_02.png",
            "door_09.png",
            "pin.png",
            "pin_shadow.png",
            "dead_marker.png",
            "yarn_string.png",
            "location_clocktower.png",
            "location_crimescene.png",
            "stamp_role_suspected.png",
            "function_hand.png",
        ]
        for sprite in required_sprites:
            path = os.path.join(self.props_dir, sprite)
            self.assertTrue(os.path.exists(path), f"Missing required sprite: {sprite}")

        required_sfx = [
            "card_flip.wav",
            "card_slide.wav",
            "pin_pop.wav",
            "gavel_stamp.wav",
            "paper_rustle.wav",
            "typewriter_tick.wav",
        ]
        for sfx in required_sfx:
            path = os.path.join(self.sfx_dir, sfx)
            self.assertTrue(os.path.exists(path), f"Missing required sfx: {sfx}")

    def test_suspect_card_two_visual_states(self) -> None:
        """Verify SuspectCard.tscn contains both ClosedStateRoot and OpenStateRoot."""
        with open(self.suspect_card_tscn, "r", encoding="utf-8") as f:
            content = f.read()

        self.assertIn('node name="ClosedStateRoot"', content)
        self.assertIn('node name="DoorSkin"', content)
        self.assertIn('node name="DoorRoomNumber"', content)
        self.assertIn('node name="SpecialLocationRoot"', content)
        self.assertIn('node name="OpenStateRoot"', content)
        self.assertIn('node name="CardFrame"', content)
        self.assertIn('node name="RoleIcon"', content)
        self.assertIn('node name="PublicRoleLabel"', content)
        self.assertIn('node name="StatementRegion"', content)
        self.assertIn('node name="PublicStatementLabel"', content)
        self.assertIn('node name="PinPeg"', content)
        self.assertIn('node name="PinShadow"', content)
        self.assertIn('node name="DeadMarker"', content)
        self.assertIn('node name="FunctionHandMarker"', content)

    def test_suspect_card_anchors_bounded(self) -> None:
        """Verify no anchor in SuspectCard.tscn exceeds 1.0 (eradicating the 1.42 overflow)."""
        with open(self.suspect_card_tscn, "r", encoding="utf-8") as f:
            lines = f.readlines()

        for idx, line in enumerate(lines):
            match = re.search(r'anchor_right\s*=\s*([0-9\.]+)', line)
            if match:
                val = float(match.group(1))
                self.assertLessEqual(val, 1.0, f"anchor_right exceeds 1.0 at line {idx+1}: {line}")
            match_b = re.search(r'anchor_bottom\s*=\s*([0-9\.]+)', line)
            if match_b:
                val_b = float(match_b.group(1))
                self.assertLessEqual(val_b, 1.0, f"anchor_bottom exceeds 1.0 at line {idx+1}: {line}")

    def test_suspect_card_font_size_tiers_bounded(self) -> None:
        """Verify STATEMENT_FONT_TIERS does not shrink text to 5px micro-text."""
        with open(self.suspect_card_script, "r", encoding="utf-8") as f:
            content = f.read()

        match = re.search(r'const\s+STATEMENT_FONT_TIERS\s*:=\s*\[([0-9,\s]+)\]', content)
        self.assertIsNotNone(match, "STATEMENT_FONT_TIERS constant not found")
        tiers = [int(x.strip()) for x in match.group(1).split(",") if x.strip()]
        self.assertTrue(len(tiers) >= 3, "STATEMENT_FONT_TIERS should have at least 3 tiers")
        min_tier = min(tiers)
        self.assertGreaterEqual(min_tier, 13, f"Minimum statement font tier must be >= 13px, got {min_tier}")

    def test_suspect_card_controller_line_budget(self) -> None:
        """Verify SuspectCardController.gd is under 800 non-empty LOC (ADR-0010 warn cap)."""
        with open(self.suspect_card_script, "r", encoding="utf-8") as f:
            lines = [line.strip() for line in f if line.strip() and not line.strip().startswith("#")]
        loc = len(lines)
        self.assertLess(loc, 800, f"SuspectCardController LOC {loc} must be < 800")

    def test_catenary_yarn_layer_specs(self) -> None:
        """Verify CatenaryYarnLayer.gd implements Verlet physics and interactive API."""
        with open(self.yarn_layer_script, "r", encoding="utf-8") as f:
            content = f.read()

        self.assertIn("class_name CatenaryYarnLayer", content)
        self.assertIn("signal yarn_connected", content)
        self.assertIn("signal yarn_disconnected", content)
        self.assertIn("func register_pin_position", content)
        self.assertIn("func start_dragging_from", content)
        self.assertIn("func update_drag_position", content)
        self.assertIn("func finish_dragging", content)
        self.assertIn("func add_connection", content)
        self.assertIn("func remove_connection", content)
        self.assertIn("func remove_connections_for", content)
        self.assertIn("func _step_verlet", content)
        self.assertIn("DEFAULT_SNAP_DISTANCE", content)

        lines = [line.strip() for line in content.splitlines() if line.strip() and not line.strip().startswith("#")]
        self.assertLess(len(lines), 800)

    def test_vs_case_main_scene_integration(self) -> None:
        """Verify VSCaseMain.tscn wires CatenaryYarnLayer, desk background, and SFX."""
        with open(self.vs_case_main_tscn, "r", encoding="utf-8") as f:
            content = f.read()

        self.assertIn("board_desk_background.png", content)
        self.assertIn('node name="CatenaryYarnLayer"', content)
        self.assertIn('node name="PinAudio"', content)
        self.assertIn('node name="CardFlipAudio"', content)
        self.assertIn('node name="GavelAudio"', content)

    def test_vs_case_main_controller_invariants(self) -> None:
        """Verify VSCaseMainController maintains core structural invariants and smoke compatibility."""
        with open(self.vs_case_main_script, "r", encoding="utf-8") as f:
            content = f.read()

        # Invariant 1: Timed event dispatcher generic evaluation without hardcoded services
        self.assertIn("timed_event_dispatcher.evaluate_all", content)
        self.assertNotIn("SurgeonTimedEventService", content)
        self.assertNotIn("SerialKillerTimedEventService", content)

        # Invariant 2: Settlement order
        self.assertIn("_ensure_settlement_and_truth()", content)
        idx_settle = content.find("settlement_service.settle")
        idx_truth = content.find("truth_reveal_builder.build")
        self.assertGreater(idx_settle, 0)
        self.assertGreater(idx_truth, idx_settle)

        # Invariant 3: Yarn & Audio integration
        self.assertIn("yarn_layer", content)
        self.assertIn("pin_audio", content)
        self.assertIn("card_flip_audio", content)
        self.assertIn("gavel_audio", content)
        self.assertIn("_update_yarn_pin_positions", content)


if __name__ == "__main__":
    unittest.main()
