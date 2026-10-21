#!/usr/bin/env python3
"""Unit tests for Secondary Screens, Codex & Alternate Modes Simulator (TASK-0028)."""

import unittest

from scripts.agent.simulate_secondary_screens import (
    AlternateModeEngine,
    AlternateModeType,
    CodexFilterEngine,
    SceneRouter,
    SceneType,
    TutorialStateMachine,
    TutorialStep,
    run_verification,
)


class TestSimulateSecondaryScreens(unittest.TestCase):
    """Test suite for SceneRouter, CodexFilterEngine, AlternateModes, and TutorialStateMachine."""

    def test_scene_router_lifecycle(self) -> None:
        """Verify async scene transition lifecycle and overlay states."""
        router = SceneRouter()
        self.assertEqual(router.current_scene, SceneType.MAIN_MENU)
        self.assertFalse(router.is_overlay_active)

        router.request_transition(SceneType.BOARD)
        self.assertTrue(router.is_overlay_active)
        self.assertEqual(router.loading_progress, 0.0)

        # Advance halfway
        is_done = router.tick_loading(0.5)
        self.assertFalse(is_done)
        self.assertEqual(router.loading_progress, 0.5)
        self.assertEqual(router.current_scene, SceneType.MAIN_MENU)

        # Complete loading
        is_done = router.tick_loading(0.5)
        self.assertTrue(is_done)
        self.assertEqual(router.loading_progress, 1.0)
        self.assertEqual(router.current_scene, SceneType.BOARD)
        self.assertFalse(router.is_overlay_active)

    def test_codex_filtering_by_region_and_alignment(self) -> None:
        """Verify codex catalog filtering across multiple criteria."""
        codex = CodexFilterEngine()

        docks = codex.query_roles(region="Docks")
        self.assertEqual(len(docks), 2)

        special = codex.query_roles(alignment="Special")
        self.assertEqual(len(special), 1)
        self.assertEqual(special[0]["name"], "Cultist")

        search = codex.query_roles(search="watch")
        self.assertEqual(len(search), 1)
        self.assertEqual(search[0]["name"], "Watchmaker")

    def test_alternate_modes_all_six_rules(self) -> None:
        """Verify rule modifiers for all 6 alternate challenge game modes."""
        cd = AlternateModeEngine.get_mode_modifiers(AlternateModeType.COUNTDOWN)
        self.assertEqual(cd["timer_sec"], 300)

        surv = AlternateModeEngine.get_mode_modifiers(AlternateModeType.SURVIVAL)
        self.assertEqual(surv["max_strikes"], 1)

        bank = AlternateModeEngine.get_mode_modifiers(AlternateModeType.BANKRUPT_HERO)
        self.assertEqual(bank["starting_cash"], -500)

        hns = AlternateModeEngine.get_mode_modifiers(AlternateModeType.HIDE_AND_SEEK)
        self.assertTrue(hns["cloaked_suspects"])

        spec = AlternateModeEngine.get_mode_modifiers(AlternateModeType.SPECTRES_DREAM)
        self.assertEqual(spec["special_role_rate"], 1.0)

        trait = AlternateModeEngine.get_mode_modifiers(AlternateModeType.TRAITORS_ONLY)
        self.assertTrue(trait["guilty_only"])

    def test_tutorial_state_machine_progression(self) -> None:
        """Verify full progression of the onboarding tutorial steps."""
        tut = TutorialStateMachine()
        self.assertEqual(tut.current_step, TutorialStep.MOVE_CAMERA)
        self.assertFalse(tut.is_finished)

        tut.advance()
        self.assertEqual(tut.current_step, TutorialStep.INSPECT_CARD)

        tut.advance()
        self.assertEqual(tut.current_step, TutorialStep.CONNECT_STRING)

        tut.advance()
        self.assertEqual(tut.current_step, TutorialStep.EXAMINE_LEAD)

        tut.advance()
        self.assertEqual(tut.current_step, TutorialStep.ACCUSE_SUSPECT)

        tut.advance()
        self.assertEqual(tut.current_step, TutorialStep.COMPLETED)
        self.assertTrue(tut.is_finished)

        # Advancing after completion stays at COMPLETED
        tut.advance()
        self.assertEqual(tut.current_step, TutorialStep.COMPLETED)

    def test_cli_verification_output(self) -> None:
        """Verify self-verification payload structure."""
        res = run_verification()
        self.assertTrue(res["success"])
        self.assertEqual(res["tool"], "simulate_secondary_screens")
        self.assertEqual(len(res["verified_features"]), 4)


if __name__ == "__main__":
    unittest.main()
