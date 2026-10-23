#!/usr/bin/env python3
"""Procedural case creation simulator and Knuth subtractive PRNG for Dupery reconstruction."""

from __future__ import annotations

import argparse
import json
import sys
from typing import Any, Dict, List, Optional, Tuple


def _to_int32(x: int) -> int:
    v = x & 0xFFFFFFFF
    if v >= 0x80000000:
        return v - 0x100000000
    return v


class DotNetRandom:
    """Donald E. Knuth's subtractive PRNG matching .NET Mono System.Random."""

    MBIG: int = 2147483647
    MSEED: int = 161803398

    def __init__(self, seed: int) -> None:
        subtraction = 2147483647 if seed == -2147483648 else abs(seed)
        mj = _to_int32(self.MSEED - subtraction)
        self.seed_array: List[int] = [0] * 56
        self.seed_array[55] = mj
        mk = 1
        for i in range(1, 55):
            ii = (21 * i) % 55
            self.seed_array[ii] = mk
            mk = _to_int32(mj - mk)
            if mk < 0:
                mk += self.MBIG
            mj = self.seed_array[ii]

        for _ in range(4):
            for i in range(1, 56):
                idx = 1 + (i + 30) % 55
                self.seed_array[i] = _to_int32(self.seed_array[i] - self.seed_array[idx])
                if self.seed_array[i] < 0:
                    self.seed_array[i] += self.MBIG

        self.inext: int = 0
        self.inextp: int = 21

    def sample(self) -> float:
        """Return next random float in [0.0, 1.0)."""
        loc_inext = self.inext + 1
        loc_inextp = self.inextp + 1
        if loc_inext >= 56:
            loc_inext = 1
        if loc_inextp >= 56:
            loc_inextp = 1
        num = _to_int32(self.seed_array[loc_inext] - self.seed_array[loc_inextp])
        if num == self.MBIG:
            num -= 1
        if num < 0:
            num += self.MBIG
        self.seed_array[loc_inext] = num
        self.inext = loc_inext
        self.inextp = loc_inextp
        s = float(num) / float(self.MBIG)
        return min(max(s, 0.0), 0.999999999999999)

    def next(self, min_val: int = 0, max_val: Optional[int] = None) -> int:
        """Return integer in range [min_val, max_val)."""
        if max_val is None:
            return int(self.sample() * self.MBIG)
        diff = max_val - min_val
        return int(self.sample() * diff) + min_val

    def shuffle(self, items: List[Any]) -> None:
        """In-place Fisher-Yates shuffle using subtractive generator."""
        n = len(items)
        for i in range(n - 1, 0, -1):
            j = self.next(0, i + 1)
            items[i], items[j] = items[j], items[i]


def get_adjacent_coords(pos: Tuple[int, int], width: int, height: int) -> List[Tuple[int, int]]:
    """Return adjacent orthogonal coordinates within grid bounds."""
    x, y = pos
    candidates = [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
    return [(cx, cy) for cx, cy in candidates if 0 <= cx < width and 0 <= cy < height]


def simulate_suspect_list(
    rng: DotNetRandom,
    role_pool: List[Dict[str, Any]],
    target_count: int = 4,
) -> List[Dict[str, Any]]:
    """Stage 1: Select suspects according to classification ratio."""
    pool = list(role_pool)
    rng.shuffle(pool)
    return pool[:target_count]


def simulate_in_play_list(
    rng: DotNetRandom,
    suspects: List[Dict[str, Any]],
    extra_roles: List[Dict[str, Any]],
    max_slots: int = 12,
) -> List[Dict[str, Any]]:
    """Stage 2: Expand suspects into full in-play board occupants."""
    in_play = list(suspects)
    available_extras = [r for r in extra_roles if r["id"] not in {s["id"] for s in in_play}]
    rng.shuffle(available_extras)
    needed = max_slots - len(in_play)
    if needed > 0:
        in_play.extend(available_extras[:needed])
    return in_play


def simulate_board_positioning(
    rng: DotNetRandom,
    width: int,
    height: int,
    in_play: List[Dict[str, Any]],
    constraints: List[Dict[str, Any]],
) -> Dict[str, Any]:
    """Stage 3: Place in-play entities onto board grid satisfying constraints."""
    grid: Dict[Tuple[int, int], str] = {}
    available_cells = [(x, y) for x in range(width) for y in range(height)]
    rng.shuffle(available_cells)

    sorted_constraints = sorted(
        constraints,
        key=lambda c: c.get("priority", 0),
        reverse=True,
    )

    placed_roles: Dict[str, Tuple[int, int]] = {}
    for c in sorted_constraints:
        c_type = c.get("type")
        target_role = c.get("role")
        if c_type == "POSITION_SELF" and available_cells:
            cell = available_cells.pop()
            grid[cell] = target_role
            placed_roles[target_role] = cell
        elif c_type == "POSITION_ADJACENT" and target_role in placed_roles:
            anchor_pos = placed_roles[target_role]
            adjacent = get_adjacent_coords(anchor_pos, width, height)
            valid_empty = [p for p in adjacent if p in available_cells]
            if valid_empty:
                other_role = c.get("other_role")
                cell = valid_empty[0]
                available_cells.remove(cell)
                grid[cell] = other_role
                placed_roles[other_role] = cell

    unplaced = [r for r in in_play if r["id"] not in placed_roles]
    for r in unplaced:
        if available_cells:
            cell = available_cells.pop()
            grid[cell] = r["id"]
            placed_roles[r["id"]] = cell

    grid_serialized = {f"{k[0]},{k[1]}": v for k, v in grid.items()}
    return {
        "board_size": [width, height],
        "total_placed": len(grid),
        "grid": grid_serialized,
    }


def generate_full_case(seed: int, width: int = 4, height: int = 4) -> Dict[str, Any]:
    """Execute complete 3-stage procedural case generation pipeline."""
    rng = DotNetRandom(seed)
    mock_pool = [
        {"id": "CASANOVA", "class": "INNOCENT"},
        {"id": "ROMANTIC", "class": "INNOCENT"},
        {"id": "KILLER", "class": "GUILTY"},
        {"id": "ACCOMPLICE", "class": "COMPLICIT"},
        {"id": "DETECTIVE", "class": "NEUTRAL"},
        {"id": "CORONER", "class": "INNOCENT"},
        {"id": "WITNESS", "class": "INNOCENT"},
        {"id": "GAMBLER", "class": "NEUTRAL"},
    ]
    mock_extras = [
        {"id": "BARTENDER", "class": "NEUTRAL"},
        {"id": "SECURITY", "class": "INNOCENT"},
        {"id": "THIEF", "class": "GUILTY"},
        {"id": "DOCTOR", "class": "INNOCENT"},
    ]

    suspects = simulate_suspect_list(rng, mock_pool, target_count=4)
    in_play = simulate_in_play_list(rng, suspects, mock_extras, max_slots=8)

    constraints = [
        {"type": "POSITION_SELF", "role": "CASANOVA", "priority": 50},
        {"type": "POSITION_ADJACENT", "role": "CASANOVA", "other_role": "ROMANTIC", "priority": 30},
    ]

    board = simulate_board_positioning(rng, width, height, in_play, constraints)
    return {
        "seed": seed,
        "suspect_count": len(suspects),
        "in_play_count": len(in_play),
        "board": board,
    }


def run_verification() -> bool:
    """Verify DotNetRandom against canonical .NET Mono sequences."""
    golden_sequences = {
        12345: [6, 7, 77, 51, 79, 82, 16, 73, 26, 50],
        42: [66, 14, 12, 52, 16, 26, 72, 51, 17, 76],
        999999: [51, 14, 5, 27, 49, 49, 15, 34, 55, 0],
    }

    for seed, expected in golden_sequences.items():
        rng = DotNetRandom(seed)
        actual = [rng.next(0, 100) for _ in range(10)]
        if actual != expected:
            sys.stderr.write(f"DotNetRandom mismatch for seed {seed}: {actual} != {expected}\n")
            return False

    case1 = generate_full_case(seed=12345, width=4, height=4)
    case2 = generate_full_case(seed=12345, width=4, height=4)
    if json.dumps(case1, sort_keys=True) != json.dumps(case2, sort_keys=True):
        sys.stderr.write("Determinism failure: Same seed produced distinct cases\n")
        return False

    return True


def main() -> int:
    """CLI entry point."""
    parser = argparse.ArgumentParser(description="Dupery Case Creation Simulator")
    parser.add_argument("--verify", action="store_true", help="Run seed determinism verification")
    parser.add_argument("--seed", type=int, default=12345, help="Case generation seed")
    parser.add_argument("--stats", action="store_true", help="Print simulation stats")
    args = parser.parse_args()

    if args.verify:
        passed = run_verification()
        print(json.dumps({"success": passed, "tool": "simulate_case_generation"}, indent=2))
        return 0 if passed else 1

    if args.stats:
        result = generate_full_case(args.seed)
        print(json.dumps(result, indent=2))
        return 0

    parser.print_help()
    return 0


if __name__ == "__main__":
    sys.exit(main())
