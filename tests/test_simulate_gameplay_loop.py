"""Unit tests for gameplay loop state machine and leads investigation simulator."""

import unittest
from scripts.agent.simulate_gameplay_loop import (
    InvestigationState,
    GameplayLoopSimulator,
    run_verification,
    audit_v3_ledger,
)


class TestSimulateGameplayLoop(unittest.TestCase):
    """Test suite for investigation state machine, clues, and accusation scoring."""

    def test_state_machine_valid_progression(self):
        """Verify normal transition through all stages of investigation."""
        sim = GameplayLoopSimulator("CASE-TEST-01", prime_suspect_id=4)
        self.assertEqual(sim.current_state, InvestigationState.CASE_SELECTION)

        sim.start_investigation()
        self.assertEqual(sim.current_state, InvestigationState.INVESTIGATION)

        sim.discover_lead("ROLE", "Suspect is a Corrupt Officer", 25)
        sim.discover_lead("STAMP", "Stamped with Syndicate insignia", 30)
        self.assertEqual(len(sim.discovered_clues), 2)

        sim.enter_lineup()
        self.assertEqual(sim.current_state, InvestigationState.LINEUP)

        summary = sim.accuse_suspect(4)
        self.assertEqual(sim.current_state, InvestigationState.SUMMARY)
        self.assertTrue(summary["is_correct"])
        self.assertEqual(summary["final_score"], 255)
        self.assertEqual(summary["reputation"], 200)

    def test_state_machine_invalid_transitions(self):
        """Verify state machine rejects out-of-order transitions."""
        sim = GameplayLoopSimulator("CASE-TEST-02", prime_suspect_id=1)

        # Cannot discover leads before starting investigation
        with self.assertRaises(ValueError):
            sim.discover_lead("AGE", "Young", 10)

        # Cannot jump straight to lineup
        with self.assertRaises(ValueError):
            sim.enter_lineup()

        # Cannot accuse without being in lineup
        with self.assertRaises(ValueError):
            sim.accuse_suspect(1)

    def test_false_accusation_penalty(self):
        """Verify incorrect accusation deducts reputation and forfeits bonus."""
        sim = GameplayLoopSimulator("CASE-TEST-03", prime_suspect_id=5)
        sim.start_investigation()
        sim.discover_lead("NAME", "Starts with J", 10)
        sim.enter_lineup()

        summary = sim.accuse_suspect(2)  # Accuse suspect 2 instead of 5
        self.assertFalse(summary["is_correct"])
        self.assertEqual(summary["final_score"], 10)  # Only clue points, no guilt bonus
        self.assertEqual(summary["reputation"], 50)  # Deducted 50 from 100

    def test_run_verification(self):
        """Verify deterministic verification routine."""
        self.assertTrue(run_verification())

    def test_audit_v3_ledger_completion(self):
        """Verify V1, V2, and V3 have reached 100% L3 documented in ledger."""
        audit = audit_v3_ledger()
        self.assertEqual(audit["V1"]["total"], 95)
        self.assertEqual(audit["V1"]["l3"], 95)
        self.assertEqual(audit["V1"]["pending"], 0)

        self.assertEqual(audit["V2"]["total"], 130)
        self.assertEqual(audit["V2"]["l3"], 130)
        self.assertEqual(audit["V2"]["pending"], 0)

        self.assertEqual(audit["V3"]["total"], 94)
        self.assertEqual(audit["V3"]["l3"], 94)
        self.assertEqual(audit["V3"]["pending"], 0)


if __name__ == "__main__":
    unittest.main()
