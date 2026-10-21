#!/usr/bin/env python3
"""Simulation and analytical verification of Dupery easing curves and world visuals."""

from __future__ import annotations

import argparse
import json
import math
import sys
from typing import Any, Dict, List


def ease_in_sine(t: float) -> float:
    """Analytical ease-in sine formula: 1 - cos(t * pi / 2)."""
    if t <= 0.0:
        return 0.0
    if t >= 1.0:
        return 1.0
    return float(1.0 - math.cos(t * math.pi / 2.0))


def ease_out_sine(t: float) -> float:
    """Analytical ease-out sine formula: sin(t * pi / 2)."""
    if t <= 0.0:
        return 0.0
    if t >= 1.0:
        return 1.0
    return float(math.sin(t * math.pi / 2.0))


def ease_in_out_sine(t: float) -> float:
    """Analytical ease-in-out sine formula: (1 - cos(t * pi)) / 2."""
    if t <= 0.0:
        return 0.0
    if t >= 1.0:
        return 1.0
    return float((1.0 - math.cos(t * math.pi)) / 2.0)


def ease_in_elastic(t: float) -> float:
    """Analytical ease-in elastic formula matching CoroutineExtensions."""
    if t <= 0.0:
        return 0.0
    if t >= 1.0:
        return 1.0
    c4 = 2.0 * math.pi / 3.0
    return float(-(2.0 ** (10.0 * t - 10.0)) * math.sin((t * 10.0 - 10.75) * c4))


def ease_out_elastic(t: float) -> float:
    """Analytical ease-out elastic formula matching CoroutineExtensions."""
    if t <= 0.0:
        return 0.0
    if t >= 1.0:
        return 1.0
    c4 = 2.0 * math.pi / 3.0
    return float(2.0 ** (-10.0 * t) * math.sin((t * 10.0 - 0.75) * c4) + 1.0)


def ease_in_back(t: float, c1: float = 1.70158) -> float:
    """Analytical ease-in back formula with overshoot constant c1."""
    if t <= 0.0:
        return 0.0
    if t >= 1.0:
        return 1.0
    return float((c1 + 1.0) * t * t * t - c1 * t * t)


def ease_out_back(t: float, c1: float = 1.70158) -> float:
    """Analytical ease-out back formula with overshoot constant c1."""
    if t <= 0.0:
        return 0.0
    if t >= 1.0:
        return 1.0
    tm = t - 1.0
    return float(1.0 + (c1 + 1.0) * (tm ** 3) + c1 * (tm ** 2))


def ease_in_out_back(t: float, c2: float = 2.5949094) -> float:
    """Analytical ease-in-out back formula with overshoot constant c2."""
    if t <= 0.0:
        return 0.0
    if t >= 1.0:
        return 1.0
    if t < 0.5:
        return float(((2.0 * t) ** 2 * ((c2 + 1.0) * 2.0 * t - c2)) / 2.0)
    tm = 2.0 * t - 2.0
    return float(((tm ** 2) * ((c2 + 1.0) * tm + c2) + 2.0) / 2.0)


def ease_out_bounce(t: float) -> float:
    """Analytical 4-stage bounce decay."""
    if t <= 0.0:
        return 0.0
    if t >= 1.0:
        return 1.0
    n1 = 7.5625
    d1 = 2.75
    if t < 1.0 / d1:
        return float(n1 * t * t)
    if t < 2.0 / d1:
        t_sub = t - (1.5 / d1)
        return float(n1 * t_sub * t_sub + 0.75)
    if t < 2.5 / d1:
        t_sub = t - (2.25 / d1)
        return float(n1 * t_sub * t_sub + 0.9375)
    t_sub = t - (2.625 / d1)
    return float(n1 * t_sub * t_sub + 63.0 / 64.0)


def simulate_jiggle_recovery(
    scale_factor: float = 1.08,
    rot_degrees: float = 6.5,
    duration: float = 0.75,
    fps: int = 60,
) -> List[Dict[str, float]]:
    """Simulate jiggle decay animation using ease-out elastic recovery."""
    frames: List[Dict[str, float]] = []
    total_frames = int(duration * fps)
    for frame_idx in range(total_frames + 1):
        progress = float(frame_idx) / float(total_frames)
        elastic_factor = ease_out_elastic(progress)
        cur_scale = scale_factor + (1.0 - scale_factor) * elastic_factor
        cur_rot = rot_degrees * (1.0 - elastic_factor)
        frames.append({
            "frame": frame_idx,
            "time": round(float(frame_idx) / fps, 4),
            "scale": round(cur_scale, 4),
            "rotation": round(cur_rot, 4),
        })
    return frames


def simulate_casino_light_pattern(
    pattern: str,
    bulb_count: int = 16,
    cycles: int = 4,
) -> List[List[bool]]:
    """Simulate discrete state steps of Casino light patterns."""
    steps: List[List[bool]] = []
    if pattern == "SWAP_HALF":
        for step in range(cycles * 2):
            is_even_phase = (step % 2 == 0)
            states = [((i % 2 == 0) == is_even_phase) for i in range(bulb_count)]
            steps.append(states)
        return steps

    if pattern == "SWAP_FULL":
        for step in range(cycles * 2):
            is_on = (step % 2 == 0)
            steps.append([is_on] * bulb_count)
        return steps

    if pattern == "CIRCLE_2":
        half = bulb_count // 2
        for step in range(cycles * bulb_count):
            offset = step % bulb_count
            states = [False] * bulb_count
            states[offset] = True
            states[(offset + half) % bulb_count] = True
            steps.append(states)
        return steps

    raise ValueError(f"Unsupported pattern: {pattern}")


def simulate_decor_shadow_motion(
    duration: float = 7.0,
    max_angle: float = 1.25,
    fps: int = 60,
) -> List[float]:
    """Simulate ambient light shadow rotation trajectory with ease-in-out sine."""
    frames: List[float] = []
    total_frames = int(duration * fps)
    for f in range(total_frames + 1):
        t = float(f) / float(total_frames)
        weight = ease_in_out_sine(t)
        angle = -max_angle + 2.0 * max_angle * weight
        frames.append(round(angle, 4))
    return frames


def run_verification() -> bool:
    """Execute mathematical assertions on analytical formulas and patterns."""
    curves = [
        ("ease_in_sine", ease_in_sine),
        ("ease_out_sine", ease_out_sine),
        ("ease_in_out_sine", ease_in_out_sine),
        ("ease_in_elastic", ease_in_elastic),
        ("ease_out_elastic", ease_out_elastic),
        ("ease_in_back", ease_in_back),
        ("ease_out_back", ease_out_back),
        ("ease_in_out_back", ease_in_out_back),
        ("ease_out_bounce", ease_out_bounce),
    ]

    for name, fn in curves:
        val_0 = fn(0.0)
        val_1 = fn(1.0)
        if abs(val_0 - 0.0) > 1e-4 or abs(val_1 - 1.0) > 1e-4:
            sys.stderr.write(f"Boundary check failed for {name}: f(0)={val_0}, f(1)={val_1}\n")
            return False

    jiggle = simulate_jiggle_recovery(scale_factor=1.08, rot_degrees=7.0, duration=0.75, fps=60)
    final_frame = jiggle[-1]
    if abs(final_frame["scale"] - 1.0) > 0.01 or abs(final_frame["rotation"] - 0.0) > 0.05:
        sys.stderr.write("Jiggle recovery failed to settle at scale 1.0, rot 0.0\n")
        return False

    lights = simulate_casino_light_pattern("SWAP_HALF", bulb_count=8, cycles=2)
    if len(lights) != 4 or lights[0] != [True, False, True, False, True, False, True, False]:
        sys.stderr.write("Casino lights SWAP_HALF failed sequence test\n")
        return False

    shadow = simulate_decor_shadow_motion(duration=1.0, max_angle=1.0, fps=10)
    if abs(shadow[0] - (-1.0)) > 1e-3 or abs(shadow[-1] - 1.0) > 1e-3:
        sys.stderr.write("Decor shadow motion failed start/end angle test\n")
        return False

    return True


def main() -> int:
    """Entry point for CLI simulation."""
    parser = argparse.ArgumentParser(description="Dupery Easing & World Visuals Simulator")
    parser.add_argument("--verify", action="store_true", help="Run analytical boundary checks")
    parser.add_argument("--stats", action="store_true", help="Print summary of models")
    args = parser.parse_args()

    if args.verify:
        passed = run_verification()
        result = {"success": passed, "tool": "simulate_easing_and_world_visuals"}
        print(json.dumps(result, indent=2))
        return 0 if passed else 1

    if args.stats:
        summary = {
            "easing_curves_modeled": 9,
            "jiggle_recovery_duration_sec": 0.75,
            "casino_lights_patterns": ["SWAP_HALF", "SWAP_FULL", "CIRCLE_2"],
            "decor_shadow_cycle_sec": 7.0,
        }
        print(json.dumps(summary, indent=2))
        return 0

    parser.print_help()
    return 0


if __name__ == "__main__":
    sys.exit(main())
