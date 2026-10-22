"""
Unit tests for Godot 4 bookkeeping exemptions (.godot/**, *.import) and .uid sidecars
in scripts/agent/check_scope.py (TASK-0001).
"""

from __future__ import annotations

from pathlib import Path
import sys
import tempfile
import unittest

ROOT_DIR = Path(__file__).resolve().parents[1]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.check_scope import (
    check_scope,
    is_authorized_uid_sidecar,
    matches_any,
    BOOKKEEPING_EXEMPT_PATTERNS,
)


SAMPLE_TASK_MD = """---
id: TASK-0099
title: "Sample Godot Scope Test Task"
domain: software
status: ready
phase: P0
touches_gatekeeper: false
goal: "Verify Godot .godot, .import, and .uid scope handling."
in_scope:
  - "Than_Tham_Nua_Voi_Godot/scripts/domain/cases/CaseGenerator.gd"
  - "Than_Tham_Nua_Voi_Godot/scenes/board/**"
out_of_scope:
  - "Than_Tham_Nua_Voi_Godot/scripts/presentation/**"
references:
  - "ARCH-CORE-001"
dependencies: []
assumptions: []
acceptance_criteria:
  - "Scope check passes for in_scope files and their .uid sidecars."
verification_commands:
  - "python -V"
stop_conditions:
  - "Out of scope modification detected."
line_budget_exceptions: []
current_checkpoint: CP-0
evidence_receipt: null
---

# Log
"""


class TestCheckScopeGodot(unittest.TestCase):
    """Test suite for Godot-specific scope guard rules in check_scope.py."""

    def test_bookkeeping_exempts_godot_cache_and_import_files(self) -> None:
        self.assertTrue(matches_any(".godot/editor/filesystem_cache10", BOOKKEEPING_EXEMPT_PATTERNS))
        self.assertTrue(
            matches_any(
                "Than_Tham_Nua_Voi_Godot/.godot/imported/icon.svg-123.ctex",
                BOOKKEEPING_EXEMPT_PATTERNS,
            )
        )
        self.assertTrue(
            matches_any(
                "Than_Tham_Nua_Voi_Godot/assets/ui/case/imperial/table_desk_bg.png.import",
                BOOKKEEPING_EXEMPT_PATTERNS,
            )
        )
        self.assertTrue(matches_any("icon.png.import", BOOKKEEPING_EXEMPT_PATTERNS))

    def test_uid_sidecar_authorization_helper(self) -> None:
        in_scope = [
            "Than_Tham_Nua_Voi_Godot/scripts/domain/cases/CaseGenerator.gd",
            "Than_Tham_Nua_Voi_Godot/scenes/board/**",
        ]
        out_of_scope = ["Than_Tham_Nua_Voi_Godot/scripts/presentation/**"]

        self.assertTrue(
            is_authorized_uid_sidecar(
                "Than_Tham_Nua_Voi_Godot/scripts/domain/cases/CaseGenerator.gd.uid",
                in_scope,
                out_of_scope,
            )
        )
        self.assertTrue(
            is_authorized_uid_sidecar(
                "Than_Tham_Nua_Voi_Godot/scenes/board/SuspectSlot.tscn.uid",
                in_scope,
                out_of_scope,
            )
        )
        self.assertFalse(
            is_authorized_uid_sidecar(
                "Than_Tham_Nua_Voi_Godot/scripts/domain/loot/AuctionCatalog.gd.uid",
                in_scope,
                out_of_scope,
            )
        )
        self.assertFalse(
            is_authorized_uid_sidecar(
                "Than_Tham_Nua_Voi_Godot/scripts/presentation/SuspectCardController.gd.uid",
                in_scope,
                out_of_scope,
            )
        )

    def test_check_scope_end_to_end_with_godot_files(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            tasks_dir = root / "docs" / "agent-system" / "tasks"
            tasks_dir.mkdir(parents=True, exist_ok=True)
            task_file = tasks_dir / "TASK-0099.md"
            task_file.write_text(SAMPLE_TASK_MD, encoding="utf-8")

            allowed_files = [
                "Than_Tham_Nua_Voi_Godot/scripts/domain/cases/CaseGenerator.gd",
                "Than_Tham_Nua_Voi_Godot/scripts/domain/cases/CaseGenerator.gd.uid",
                "Than_Tham_Nua_Voi_Godot/.godot/uid_cache.bin",
                "Than_Tham_Nua_Voi_Godot/assets/card.png.import",
            ]
            res_ok = check_scope(root, "TASK-0099", explicit_files=allowed_files)
            self.assertTrue(res_ok.success, msg=f"Expected success, got issues: {res_ok.issues}")
            self.assertEqual(res_ok.data["out_of_scope_files"], [])
            self.assertEqual(
                res_ok.data["evaluated_files"],
                [
                    "Than_Tham_Nua_Voi_Godot/scripts/domain/cases/CaseGenerator.gd",
                    "Than_Tham_Nua_Voi_Godot/scripts/domain/cases/CaseGenerator.gd.uid",
                ],
            )

            unlisted_uid = [
                "Than_Tham_Nua_Voi_Godot/scripts/domain/loot/AuctionCatalog.gd.uid",
            ]
            res_violation = check_scope(root, "TASK-0099", explicit_files=unlisted_uid)
            self.assertFalse(res_violation.success)
            self.assertEqual(res_violation.issues[0].code, "ERR_SCOPE_VIOLATION")

            forbidden_uid = [
                "Than_Tham_Nua_Voi_Godot/scripts/presentation/SuspectCardController.gd.uid",
            ]
            res_forbidden = check_scope(root, "TASK-0099", explicit_files=forbidden_uid)
            self.assertFalse(res_forbidden.success)
            self.assertEqual(res_forbidden.issues[0].code, "ERR_SCOPE_FORBIDDEN")


if __name__ == "__main__":
    unittest.main()
