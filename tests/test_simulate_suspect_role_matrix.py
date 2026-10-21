"""Unit tests for suspect role matrix and regional catalog simulator."""

import unittest
from scripts.agent.simulate_suspect_role_matrix import (
    SuspectRoleDefinition,
    RoleCatalogSimulator,
    run_verification,
    audit_v5b_ledger,
    V5B_CLASSES,
)


class TestSimulateSuspectRoleMatrix(unittest.TestCase):
    """Test suite for role catalog registration, regional lookups, and ledger audit."""

    def test_role_registration_and_lookup(self):
        """Verify role registration and regional filtering."""
        catalog = RoleCatalogSimulator()
        catalog.register_role(SuspectRoleDefinition("Absconder", "DOCKS", is_syndicate=True))
        catalog.register_role(SuspectRoleDefinition("HarborMaster", "DOCKS", is_syndicate=False))
        catalog.register_role(SuspectRoleDefinition("BigBlind", "CASINO", is_syndicate=False))

        self.assertEqual(len(catalog.roles), 3)

        docks_roles = catalog.get_by_region("DOCKS")
        self.assertEqual(len(docks_roles), 2)
        role_names = [r.name for r in docks_roles]
        self.assertIn("Absconder", role_names)
        self.assertIn("HarborMaster", role_names)

        casino_roles = catalog.get_by_region("CASINO")
        self.assertEqual(len(casino_roles), 1)
        self.assertEqual(casino_roles[0].name, "BigBlind")

    def test_empty_region_query(self):
        """Verify query on region with no registered roles returns empty list."""
        catalog = RoleCatalogSimulator()
        catalog.register_role(SuspectRoleDefinition("Watchmaker", "CLOCK"))
        self.assertEqual(catalog.get_by_region("CASINO"), [])

    def test_run_verification(self):
        """Verify deterministic verification script routine."""
        self.assertTrue(run_verification())

    def test_v5b_classes_count(self):
        """Verify exactly 185 pending roles are declared for V5B."""
        self.assertEqual(len(V5B_CLASSES), 185)

    def test_audit_v5b_ledger_completion(self):
        """Verify V1 through V5B have reached 100% L3 documented in ledger."""
        audit = audit_v5b_ledger()
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

        self.assertEqual(audit["V5B"]["total"], 185)
        self.assertEqual(audit["V5B"]["l3"], 185)
        self.assertEqual(audit["V5B"]["pending"], 0)

        self.assertEqual(audit["V5_remaining"]["total"], 232)
        self.assertEqual(audit["V5_remaining"]["pending"], 232)


if __name__ == "__main__":
    unittest.main()
