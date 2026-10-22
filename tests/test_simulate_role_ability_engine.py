"""Unit tests for role ability engine simulator and trigger pipeline."""

import unittest
from scripts.agent.simulate_role_ability_engine import (
    AbilityTrigger,
    AbilityEngineSimulator,
    run_verification,
    audit_v5a_ledger,
    V5A_CLASSES,
)


class TestSimulateRoleAbilityEngine(unittest.TestCase):
    """Test suite for ability registration, phase triggers, and target redirection."""

    def test_ability_registration_and_trigger(self):
        """Verify normal trigger execution on board enter."""
        engine = AbilityEngineSimulator()
        engine.place_suspect(1, "Hunter", "RevealRight", AbilityTrigger.ON_BOARD_ENTER)
        engine.place_suspect(2, "Cultist", "DarkRitual", AbilityTrigger.ON_PINNED)

        executed = engine.trigger_phase(AbilityTrigger.ON_BOARD_ENTER)
        self.assertEqual(executed, 1)
        self.assertTrue(engine.board[2]["revealed"])
        self.assertFalse(engine.board[1]["revealed"])

    def test_target_redirection_mechanism(self):
        """Verify target redirection changes affected slot direction."""
        engine = AbilityEngineSimulator()
        engine.place_suspect(1, "TargetA", None, AbilityTrigger.ON_ACCUSED)
        engine.place_suspect(2, "Cultist", "DarkRitual", AbilityTrigger.ON_PINNED)
        engine.place_suspect(3, "TargetB", None, AbilityTrigger.ON_ACCUSED)

        # Before redirection, Cultist at 2 would target 3
        # With redirection enabled, Cultist at 2 targets 1
        engine.enable_target_redirection()
        executed = engine.trigger_phase(AbilityTrigger.ON_PINNED)

        self.assertEqual(executed, 1)
        self.assertTrue(engine.board[1]["revealed"])
        self.assertFalse(engine.board[3]["revealed"])

    def test_empty_trigger_phase(self):
        """Verify phase with no matching abilities returns 0 executed."""
        engine = AbilityEngineSimulator()
        engine.place_suspect(1, "Hunter", "RevealRight", AbilityTrigger.ON_BOARD_ENTER)

        executed = engine.trigger_phase(AbilityTrigger.ON_ACCUSED)
        self.assertEqual(executed, 0)

    def test_run_verification(self):
        """Verify deterministic verification script routine."""
        self.assertTrue(run_verification())

    def test_v5a_classes_count(self):
        """Verify exactly 79 classes are declared for V5A."""
        self.assertEqual(len(V5A_CLASSES), 79)

    def test_audit_v5a_ledger_completion(self):
        """Verify V1 through V5A have reached 100% L3 documented in ledger."""
        audit = audit_v5a_ledger()
        self.assertEqual(audit["V1"]["total"], 95)
        self.assertEqual(audit["V1"]["l3"], 95)
        self.assertEqual(audit["V1"]["pending"], 0)

        self.assertEqual(audit["V2"]["total"], 130)
        self.assertEqual(audit["V2"]["l3"], 130)
        self.assertEqual(audit["V2"]["pending"], 0)

        self.assertEqual(audit["V3"]["total"], 94)
        self.assertEqual(audit["V3"]["l3"], 94)
        self.assertEqual(audit["V3"]["pending"], 0)

        self.assertEqual(audit["V4"]["total"], 101)
        self.assertEqual(audit["V4"]["l3"], 101)
        self.assertEqual(audit["V4"]["pending"], 0)

        self.assertEqual(audit["V5A"]["total"], 79)
        self.assertEqual(audit["V5A"]["l3"], 79)
        self.assertEqual(audit["V5A"]["pending"], 0)


if __name__ == "__main__":
    unittest.main()
