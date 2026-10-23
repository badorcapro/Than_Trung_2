"""
Unit tests for role-based line budget checker, .gd support, and baseline exemptions
in scripts/agent/check_line_budget.py and scripts/agent/config_models.py (TASK-0033).
"""

from __future__ import annotations

import json
from pathlib import Path
import sys
import tempfile
import unittest

ROOT_DIR = Path(__file__).resolve().parents[1]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.check_line_budget import (
    check_cohesion_notes,
    check_line_budget,
    classify_tier,
    count_loc,
    is_baseline_exempt,
    is_budgeted_file,
    load_project_config,
    main,
    resolve_role,
)
from scripts.agent.config_models import LineBudgetConfig, ProjectConfig, RoleBudget
from scripts.agent.models import Severity


class TestCheckLineBudget(unittest.TestCase):
    """Test suite for line budget engine, .gd extension inclusion, and baseline exemptions."""

    def setUp(self) -> None:
        self.workspace_root = ROOT_DIR
        self.config = load_project_config(self.workspace_root)

    def test_config_models_baseline_exemptions_support(self) -> None:
        """LineBudgetConfig accepts baseline_exemptions and defaults to empty list."""
        raw_budget = {
            "loc_counting": "non_empty_lines",
            "include_extensions": [".gd", ".py"],
            "default_role": "domain_logic",
            "role_map": [],
            "baseline_exemptions": ["legacy/huge_file.gd"],
            "profiles": {
                "software": {
                    "domain_logic": {"warn": 800, "review": 900, "hard": 1000},
                }
            },
            "diff_guard": {
                "max_net_deleted_lines": 150,
                "max_hunk_lines": 200,
                "placeholder_patterns": [r"mock_placeholder_pattern"],
            },
        }
        cfg = LineBudgetConfig.model_validate(raw_budget)
        self.assertEqual(cfg.baseline_exemptions, ["legacy/huge_file.gd"])

        # Default empty list when omitted
        del raw_budget["baseline_exemptions"]
        cfg_default = LineBudgetConfig.model_validate(raw_budget)
        self.assertEqual(cfg_default.baseline_exemptions, [])

    def test_project_config_includes_gd_extension(self) -> None:
        """project-config.json must include '.gd' in line_budget.include_extensions."""
        extensions = [ext.lower() for ext in self.config.line_budget.include_extensions]
        self.assertIn(".gd", extensions)

    def test_project_config_declares_13_baseline_exemptions(self) -> None:
        """project-config.json must declare exactly the 13 legacy Godot God-files."""
        exemptions = self.config.line_budget.baseline_exemptions
        self.assertEqual(len(exemptions), 13)
        expected = [
            "Than_Tham_Nua_Voi_Godot/scripts/tools/SmokeTestRunner.gd",
            "Than_Tham_Nua_Voi_Godot/scripts/presentation/player_facing/PlayerFacingStartController.gd",
            "Than_Tham_Nua_Voi_Godot/scripts/presentation/player_facing/CharacterDetailSheet.gd",
            "Than_Tham_Nua_Voi_Godot/scripts/domain/loot/AuctionCatalog.gd",
            "Than_Tham_Nua_Voi_Godot/scripts/presentation/loot/AuctionScreen.gd",
            "Than_Tham_Nua_Voi_Godot/scripts/presentation/case_gameplay/VSCaseMainController.gd",
            "Than_Tham_Nua_Voi_Godot/scripts/presentation/player_facing/PlayerFacingLootMapView.gd",
            "Than_Tham_Nua_Voi_Godot/scripts/domain/cases/CaseGeneratorPublicSolver.gd",
            "Than_Tham_Nua_Voi_Godot/scripts/application/mvp/MvpIntegratedNextCaseSession.gd",
            "Than_Tham_Nua_Voi_Godot/tests/unit/gd2/Gd2M0AProductionMapTestSuite.gd",
            "Than_Tham_Nua_Voi_Godot/scripts/presentation/case_gameplay/SuspectCardController.gd",
            "Than_Tham_Nua_Voi_Godot/tests/unit/gd3/Gd3M5TestSuite.gd",
            "Than_Tham_Nua_Voi_Godot/scripts/presentation/loot/AuctionEncyclopediaDialog.gd",
        ]
        for exp in expected:
            self.assertIn(exp, exemptions)

    def test_role_resolution_for_godot_codebase(self) -> None:
        """Role resolution must correctly map Godot presentation, test, tools, and domain paths."""
        budget = self.config.line_budget
        self.assertEqual(
            resolve_role("Than_Tham_Nua_Voi_Godot/scripts/presentation/case_gameplay/Card.gd", budget),
            "ui_component",
        )
        self.assertEqual(
            resolve_role("Than_Tham_Nua_Voi_Godot/tests/unit/case_generator/Test.gd", budget),
            "test",
        )
        self.assertEqual(
            resolve_role("Than_Tham_Nua_Voi_Godot/scripts/tools/SmokeTestRunner.gd", budget),
            "test",
        )
        self.assertEqual(
            resolve_role("Than_Tham_Nua_Voi_Godot/scripts/domain/cases/CaseGenerator.gd", budget),
            "domain_logic",
        )
        self.assertEqual(
            resolve_role("scripts/agent/check_line_budget.py", budget),
            "core_engine",
        )

    def test_is_baseline_exempt_matching(self) -> None:
        """is_baseline_exempt normalizes backslashes and matches declared paths."""
        budget = self.config.line_budget
        self.assertTrue(
            is_baseline_exempt("Than_Tham_Nua_Voi_Godot/scripts/tools/SmokeTestRunner.gd", budget)
        )
        # Windows backslash path
        self.assertTrue(
            is_baseline_exempt(r"Than_Tham_Nua_Voi_Godot\scripts\tools\SmokeTestRunner.gd", budget)
        )
        # Non-exempt file
        self.assertFalse(
            is_baseline_exempt("Than_Tham_Nua_Voi_Godot/scripts/domain/cases/CaseGenerator.gd", budget)
        )

    def test_check_line_budget_with_baseline_exempt_file(self) -> None:
        """Baseline exempt files are assigned tier baseline_exempt without hard cap error."""
        target_file = "Than_Tham_Nua_Voi_Godot/scripts/tools/SmokeTestRunner.gd"
        res = check_line_budget(self.workspace_root, explicit_files=[target_file])
        self.assertTrue(res.success)
        self.assertFalse(any(i.severity == Severity.ERROR for i in res.issues))

        exempt_issues = [i for i in res.issues if i.code == "INFO_LBUD_BASELINE_EXEMPT"]
        self.assertEqual(len(exempt_issues), 1)
        self.assertEqual(exempt_issues[0].evidence["tier"], "baseline_exempt")

        report_files = res.data["files"]
        self.assertEqual(len(report_files), 1)
        self.assertEqual(report_files[0]["tier"], "baseline_exempt")

    def test_cohesion_notes_ignores_baseline_exempt_files(self) -> None:
        """check_cohesion_notes should not require cohesion note for baseline_exempt tier."""
        files_report = [
            {"path": "Than_Tham_Nua_Voi_Godot/scripts/tools/SmokeTestRunner.gd", "tier": "baseline_exempt", "loc": 13771},
            {"path": "sample/normal_file.gd", "tier": "ok", "loc": 150},
        ]
        issues = check_cohesion_notes(files_report, "Empty task body with no cohesion notes")
        self.assertEqual(issues, [])

    def test_is_budgeted_file_preserves_diff_guard_protection(self) -> None:
        """is_budgeted_file returns True for .gd files so diff_guard continues guarding them."""
        self.assertTrue(
            is_budgeted_file(
                "Than_Tham_Nua_Voi_Godot/scripts/tools/SmokeTestRunner.gd",
                self.config,
                self.workspace_root,
            )
        )
        self.assertTrue(
            is_budgeted_file(
                "Than_Tham_Nua_Voi_Godot/scripts/domain/cases/CaseGenerator.gd",
                self.config,
                self.workspace_root,
            )
        )

    def test_classify_tier_thresholds(self) -> None:
        """classify_tier strictly enforces warn <= review <= hard."""
        budget = RoleBudget(warn=800, review=900, hard=1000)
        self.assertEqual(classify_tier(500, budget), "ok")
        self.assertEqual(classify_tier(800, budget), "ok")
        self.assertEqual(classify_tier(801, budget), "warn")
        self.assertEqual(classify_tier(900, budget), "warn")
        self.assertEqual(classify_tier(901, budget), "review")
        self.assertEqual(classify_tier(1000, budget), "review")
        self.assertEqual(classify_tier(1001, budget), "hard")

    def test_cli_main_execution(self) -> None:
        """main() CLI smoke test returns exit code 0 on baseline exempt files."""
        exit_code = main([
            "--root", str(self.workspace_root),
            "--files", "Than_Tham_Nua_Voi_Godot/scripts/tools/SmokeTestRunner.gd",
        ])
        self.assertEqual(exit_code, 0)


if __name__ == "__main__":
    unittest.main()
