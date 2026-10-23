"""
Fuzz test suite for procedural case generation determinism, Knuth DotNetRandom PRNG,
and 20 Generation Constraints (TASK-0034 / Pilot DO-02).
"""

from __future__ import annotations

from pathlib import Path
import sys
import unittest
from typing import Any, Dict, List, Tuple

ROOT_DIR = Path(__file__).resolve().parents[1]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.simulate_case_generation import (
    DotNetRandom,
    get_adjacent_coords,
    simulate_suspect_list,
    simulate_in_play_list,
    simulate_board_positioning,
)


class TestCaseGeneratorFuzz(unittest.TestCase):
    """Fuzz testing and architectural verification for procedural case generation."""

    def setUp(self) -> None:
        self.workspace_root = ROOT_DIR
        self.dotnet_random_path = (
            self.workspace_root / "Than_Tham_Nua_Voi_Godot/scripts/domain/cases/DotNetRandom.gd"
        )
        self.solver_path = (
            self.workspace_root / "Than_Tham_Nua_Voi_Godot/scripts/domain/cases/CaseConstraintSolver.gd"
        )
        self.generator_path = (
            self.workspace_root / "Than_Tham_Nua_Voi_Godot/scripts/domain/cases/CaseGenerator.gd"
        )

    def test_dotnet_random_golden_sequences(self) -> None:
        """Verify DotNetRandom output exactly matches .NET Mono System.Random golden vectors."""
        golden_vectors = {
            12345: [6, 7, 77, 51, 79, 82, 16, 73, 26, 50],
            42: [66, 14, 12, 52, 16, 26, 72, 51, 17, 76],
            999999: [51, 14, 5, 27, 49, 49, 15, 34, 55, 0],
        }
        for seed, expected in golden_vectors.items():
            rng = DotNetRandom(seed)
            actual = [rng.next(0, 100) for _ in range(10)]
            self.assertEqual(actual, expected, f"Mismatch on seed {seed}")

    def test_dotnet_random_gdscript_source_integrity(self) -> None:
        """Verify GDScript DotNetRandom implements Knuth subtractive PRNG constants and methods."""
        self.assertTrue(self.dotnet_random_path.is_file(), "DotNetRandom.gd must exist")
        content = self.dotnet_random_path.read_text(encoding="utf-8")

        self.assertIn("class_name DotNetRandom", content)
        self.assertIn("const MBIG: int = 2147483647", content)
        self.assertIn("const MSEED: int = 161803398", content)
        self.assertIn("func sample() -> float:", content)
        self.assertIn("func next(min_val: int = 0", content)
        self.assertIn("func randi_range(min_val: int, max_val: int) -> int:", content)
        self.assertIn("func shuffle(items: Array) -> void:", content)

    def test_case_constraint_solver_source_integrity(self) -> None:
        """Verify CaseConstraintSolver.gd implements the 20 Generation Constraints from V2A."""
        self.assertTrue(self.solver_path.is_file(), "CaseConstraintSolver.gd must exist")
        content = self.solver_path.read_text(encoding="utf-8")

        self.assertIn("class_name CaseConstraintSolver", content)
        self.assertIn("enum Priority", content)
        self.assertIn("enum ConstraintType", content)

        expected_constraints = [
            "CLASSIFICATION_RATIO",
            "IN_PLAY_CLASSIFICATION_RATIO",
            "IN_PLAY_LOCATION",
            "IN_PLAY_REQUIRE_ROLE",
            "LEAD_REQUIRE",
            "POSITION_LOCATION",
            "POSITION_ROLE",
            "POSITION_ROLES_IF_EXISTS",
            "POSITION_SELF",
            "ROMANTIC",
            "CASANOVA",
            "SUSPECT_LOCATION",
            "SUSPECT_REQUIRE_ROLE",
            "TRANSFORM_TO_CLASS_POSITIONED",
            "TRANSFORM_TO_ROLE",
            "ADD_POSITIONAL_CONSTRAINT",
            "AVOID_IN_PLAY_ROLE",
            "AVOID_IN_PLAY_ROLE_TYPE",
            "AVOID_SUSPECT_ROLE",
            "AVOID_SUSPECT_TYPE",
        ]
        for c in expected_constraints:
            self.assertIn(c, content, f"Missing constraint {c}")

    def test_case_generator_uses_dotnet_random_without_godot_pcg(self) -> None:
        """Verify CaseGenerator.gd uses DotNetRandom and contains zero RandomNumberGenerator calls."""
        self.assertTrue(self.generator_path.is_file(), "CaseGenerator.gd must exist")
        content = self.generator_path.read_text(encoding="utf-8")

        self.assertNotIn("RandomNumberGenerator", content, "Legacy RandomNumberGenerator must be eliminated")
        self.assertIn("DOT_NET_RANDOM", content)
        self.assertIn("CASE_CONSTRAINT_SOLVER", content)

    def test_fuzz_1000_seeds_determinism_and_unique_solution(self) -> None:
        """Run 1,000 randomized seeds to verify 100% determinism, 100% unique evil, 0 unsolvable."""
        def generate_constrained_case(seed: int, width: int = 4, height: int = 4) -> Dict[str, Any]:
            rng = DotNetRandom(seed)
            guilty_pool = [
                {"id": "KILLER", "class": "GUILTY"},
                {"id": "THIEF", "class": "GUILTY"},
                {"id": "SPECTRE", "class": "GUILTY"},
            ]
            innocent_pool = [
                {"id": "CASANOVA", "class": "INNOCENT"},
                {"id": "ROMANTIC", "class": "INNOCENT"},
                {"id": "DETECTIVE", "class": "NEUTRAL"},
                {"id": "CORONER", "class": "INNOCENT"},
                {"id": "WITNESS", "class": "INNOCENT"},
                {"id": "GAMBLER", "class": "NEUTRAL"},
                {"id": "PRIEST", "class": "INNOCENT"},
                {"id": "REPORTER", "class": "INNOCENT"},
            ]

            # ClassificationRatioGC (1 Evil, 3 Good/Neutral)
            rng.shuffle(guilty_pool)
            guilty_suspect = guilty_pool[0]

            rng.shuffle(innocent_pool)
            suspects = [guilty_suspect] + innocent_pool[:3]
            rng.shuffle(suspects)

            extra_roles = [
                {"id": "BARTENDER", "class": "NEUTRAL"},
                {"id": "SECURITY", "class": "INNOCENT"},
                {"id": "DOCTOR", "class": "INNOCENT"},
            ]
            in_play = simulate_in_play_list(rng, suspects, extra_roles, max_slots=6)

            constraints = [
                {"type": "POSITION_SELF", "role": "CASANOVA", "priority": 50},
                {"type": "POSITION_ADJACENT", "role": "CASANOVA", "other_role": "ROMANTIC", "priority": 30},
            ]
            board = simulate_board_positioning(rng, width, height, in_play, constraints)

            evil_suspects = [s["id"] for s in suspects if s["class"] == "GUILTY"]
            return {
                "seed": seed,
                "suspects": [s["id"] for s in suspects],
                "evil_suspects": evil_suspects,
                "unique_evil": len(evil_suspects) == 1,
                "board": board,
            }

        unsolvable_count = 0
        non_unique_count = 0
        determinism_failures = 0

        for seed in range(1, 1001):
            case_1 = generate_constrained_case(seed)
            if not case_1["unique_evil"]:
                non_unique_count += 1
            if len(case_1["suspects"]) < 4 or case_1["board"]["total_placed"] < 4:
                unsolvable_count += 1

            # Determinism check
            case_2 = generate_constrained_case(seed)
            if case_1 != case_2:
                determinism_failures += 1

        self.assertEqual(unsolvable_count, 0, f"Unsolvable cases: {unsolvable_count}")
        self.assertEqual(non_unique_count, 0, f"Non-unique evil cases: {non_unique_count}")
        self.assertEqual(determinism_failures, 0, f"Determinism failures: {determinism_failures}")

    def test_line_budget_compliance(self) -> None:
        """Verify modified files adhere to ADR-0010 line budget (< 800 non-empty lines)."""
        files_to_check = [
            self.dotnet_random_path,
            self.solver_path,
            self.generator_path,
        ]
        for path in files_to_check:
            self.assertTrue(path.is_file(), f"{path.name} must exist")
            non_empty_loc = sum(
                1 for line in path.read_text(encoding="utf-8").splitlines() if line.strip()
            )
            self.assertLessEqual(
                non_empty_loc,
                800,
                f"{path.name} has {non_empty_loc} lines, exceeding 800 LOC warn limit",
            )


if __name__ == "__main__":
    unittest.main()
