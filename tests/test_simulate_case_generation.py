"""Unit tests for procedural case creation simulator and Knuth subtractive PRNG."""

import unittest
from scripts.agent.simulate_case_generation import (
    DotNetRandom,
    get_adjacent_coords,
    simulate_suspect_list,
    simulate_in_play_list,
    simulate_board_positioning,
    generate_full_case,
    run_verification,
)


class TestSimulateCaseGeneration(unittest.TestCase):
    """Test suite for DotNetRandom PRNG and procedural case creation pipeline."""

    def test_dotnet_random_golden_sequences(self):
        """Verify DotNetRandom output exactly matches .NET Mono System.Random."""
        golden_sequences = {
            12345: [6, 7, 77, 51, 79, 82, 16, 73, 26, 50],
            42: [66, 14, 12, 52, 16, 26, 72, 51, 17, 76],
            999999: [51, 14, 5, 27, 49, 49, 15, 34, 55, 0],
        }
        for seed, expected in golden_sequences.items():
            rng = DotNetRandom(seed)
            actual = [rng.next(0, 100) for _ in range(10)]
            self.assertEqual(actual, expected)

    def test_dotnet_random_sample_bounds(self):
        """Verify sample values lie strictly in [0.0, 1.0)."""
        rng = DotNetRandom(777)
        for _ in range(100):
            val = rng.sample()
            self.assertGreaterEqual(val, 0.0)
            self.assertLess(val, 1.0)

    def test_dotnet_random_shuffle(self):
        """Verify deterministic shuffle ordering."""
        items1 = [1, 2, 3, 4, 5, 6, 7, 8]
        items2 = [1, 2, 3, 4, 5, 6, 7, 8]
        DotNetRandom(12345).shuffle(items1)
        DotNetRandom(12345).shuffle(items2)
        self.assertEqual(items1, items2)

    def test_get_adjacent_coords(self):
        """Verify orthogonal adjacent coordinate bounds."""
        adj_corner = get_adjacent_coords((0, 0), width=4, height=4)
        self.assertEqual(set(adj_corner), {(1, 0), (0, 1)})
        adj_center = get_adjacent_coords((1, 1), width=4, height=4)
        self.assertEqual(set(adj_center), {(0, 1), (2, 1), (1, 0), (1, 2)})

    def test_suspect_and_in_play_pipeline(self):
        """Verify suspect and in-play list generation stages."""
        pool = [{"id": f"R{i}", "class": "INNOCENT"} for i in range(10)]
        extras = [{"id": f"E{i}", "class": "NEUTRAL"} for i in range(5)]

        suspects1 = simulate_suspect_list(DotNetRandom(42), pool, target_count=4)
        suspects2 = simulate_suspect_list(DotNetRandom(42), pool, target_count=4)
        self.assertEqual(suspects1, suspects2)
        self.assertEqual(len(suspects1), 4)

        in_play1 = simulate_in_play_list(DotNetRandom(42), suspects1, extras, max_slots=8)
        in_play2 = simulate_in_play_list(DotNetRandom(42), suspects2, extras, max_slots=8)
        self.assertEqual(in_play1, in_play2)
        self.assertEqual(len(in_play1), 8)

    def test_board_positioning_constraint(self):
        """Verify positioning constraint satisfies adjacency."""
        in_play = [
            {"id": "CASANOVA", "class": "INNOCENT"},
            {"id": "ROMANTIC", "class": "INNOCENT"},
        ]
        constraints = [
            {"type": "POSITION_SELF", "role": "CASANOVA", "priority": 50},
            {"type": "POSITION_ADJACENT", "role": "CASANOVA", "other_role": "ROMANTIC", "priority": 30},
        ]
        res = simulate_board_positioning(DotNetRandom(100), width=4, height=4, in_play=in_play, constraints=constraints)
        grid = res["grid"]
        casanova_pos = None
        romantic_pos = None
        for k, v in grid.items():
            if v == "CASANOVA":
                casanova_pos = tuple(map(int, k.split(",")))
            elif v == "ROMANTIC":
                romantic_pos = tuple(map(int, k.split(",")))

        self.assertIsNotNone(casanova_pos)
        self.assertIsNotNone(romantic_pos)
        dist = abs(casanova_pos[0] - romantic_pos[0]) + abs(casanova_pos[1] - romantic_pos[1])
        self.assertEqual(dist, 1)

    def test_full_case_determinism(self):
        """Verify identical seed produces identical full case structure."""
        case_a = generate_full_case(seed=5555, width=4, height=4)
        case_b = generate_full_case(seed=5555, width=4, height=4)
        self.assertEqual(case_a, case_b)

    def test_run_verification(self):
        """Verify end-to-end verification function."""
        self.assertTrue(run_verification())


if __name__ == "__main__":
    unittest.main()
