"""Unit tests for quirks modifier pipeline, backalley items, and fan layout."""

import unittest
from scripts.agent.simulate_quirks_and_items import (
    QuirkModifier,
    BackAlleyItem,
    InvestigationContext,
    calculate_fan_layout,
    run_verification,
    audit_v4_ledger,
)


class TestSimulateQuirksAndItems(unittest.TestCase):
    """Test suite for quirks modifiers, inventory tools, and fan card positions."""

    def test_quirk_modifier_stacking(self):
        """Verify multiplicative and additive modifier stacking."""
        ctx = InvestigationContext()
        ctx.add_quirk(QuirkModifier("Q01", "GamblersFallacy", "REPUTATION_MULT", 1.5))
        ctx.add_quirk(QuirkModifier("Q02", "RiskReward", "REPUTATION_MULT", 2.0))
        ctx.add_quirk(QuirkModifier("Q03", "ExtraYarn", "EXTRA_YARN", 4.0))

        self.assertAlmostEqual(ctx.reputation_multiplier, 3.0)
        self.assertEqual(ctx.bonus_yarn, 4)

    def test_item_usage_and_consumption(self):
        """Verify item activation effects and inventory removal."""
        ctx = InvestigationContext()
        locket = BackAlleyItem("I01", "FamilialLocket", "REPUTATION_SHIELD", single_use=True)
        yarn = BackAlleyItem("I02", "BundleOfString", "ADD_YARN", single_use=True)
        ctx.inventory.extend([locket, yarn])

        self.assertTrue(ctx.use_item("I01"))
        self.assertTrue(ctx.reputation_shield)
        self.assertEqual(len(ctx.inventory), 1)

        self.assertTrue(ctx.use_item("I02"))
        self.assertEqual(ctx.bonus_yarn, 3)
        self.assertEqual(len(ctx.inventory), 0)

        # Attempt to use non-existent or consumed item
        self.assertFalse(ctx.use_item("I01"))

    def test_fan_layout_symmetry(self):
        """Verify card positions in arc fan have bilateral symmetry."""
        fan = calculate_fan_layout(7, radius=600.0, step_deg=5.0)
        self.assertEqual(len(fan), 7)

        # Middle card (index 3) is vertical and at apex
        self.assertEqual(fan[3]["x"], 0.0)
        self.assertEqual(fan[3]["rotation_deg"], 0.0)

        # Bilateral symmetry
        for i in range(3):
            mirror_idx = 6 - i
            self.assertAlmostEqual(fan[i]["x"], -fan[mirror_idx]["x"], places=2)
            self.assertAlmostEqual(fan[i]["rotation_deg"], -fan[mirror_idx]["rotation_deg"], places=2)

    def test_empty_fan_layout(self):
        """Verify empty fan returns empty list."""
        self.assertEqual(calculate_fan_layout(0), [])

    def test_run_verification(self):
        """Verify deterministic verification script routine."""
        self.assertTrue(run_verification())

    def test_audit_v4_ledger_completion(self):
        """Verify V1 through V4 have reached 100% L3 documented in ledger."""
        audit = audit_v4_ledger()
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


if __name__ == "__main__":
    unittest.main()
