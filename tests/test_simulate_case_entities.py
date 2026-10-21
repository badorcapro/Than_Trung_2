"""Unit tests for case entities, location data, and hazard mitigation simulator."""

import unittest
from scripts.agent.simulate_case_entities import (
    HazardType,
    CaseSnapshot,
    CaseEntityManager,
    run_verification,
    audit_v5c_ledger,
)


class TestSimulateCaseEntities(unittest.TestCase):
    """Test suite for case lifecycle, hazard defusal, and ledger completion."""

    def test_case_lifecycle_and_hazards(self):
        """Verify hazard spawning, defusing, and resolution reward."""
        manager = CaseEntityManager("CASE-TEST-V5C", base_reward=250)
        self.assertEqual(len(manager.active_hazards), 0)

        manager.spawn_hazard(HazardType.BOMB)
        manager.spawn_hazard(HazardType.BREACH_OF_TRUST)
        self.assertEqual(len(manager.active_hazards), 2)

        snapshot = manager.create_snapshot()
        self.assertEqual(snapshot.case_id, "CASE-TEST-V5C")
        self.assertIn("BOMB", snapshot.hazards)
        self.assertIn("BREACH_OF_TRUST", snapshot.hazards)

        # Defuse bomb hazard
        self.assertTrue(manager.defuse_hazard(HazardType.BOMB))
        self.assertEqual(len(manager.active_hazards), 1)

        # Cannot defuse hazard not present
        self.assertFalse(manager.defuse_hazard(HazardType.BLOOD_TRACE))

        # Resolve case: 1 hazard remains -> 250 - 30 = 220
        outcome = manager.resolve_case(solved=True)
        self.assertTrue(outcome["solved"])
        self.assertEqual(outcome["final_reward"], 220)
        self.assertEqual(outcome["hazards_remaining"], 1)

    def test_failed_case_zero_reward(self):
        """Verify unsolved case yields zero reward."""
        manager = CaseEntityManager("CASE-FAIL", base_reward=100)
        outcome = manager.resolve_case(solved=False)
        self.assertFalse(outcome["solved"])
        self.assertEqual(outcome["final_reward"], 0)

    def test_run_verification(self):
        """Verify deterministic verification script routine."""
        self.assertTrue(run_verification())

    def test_audit_v5c_ledger_completion(self):
        """Verify V1 through V5 have all reached 100% L3 documented in ledger."""
        audit = audit_v5c_ledger()
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

        self.assertEqual(audit["V5"]["total"], 496)
        self.assertEqual(audit["V5"]["l3"], 496)
        self.assertEqual(audit["V5"]["pending"], 0)


if __name__ == "__main__":
    unittest.main()
