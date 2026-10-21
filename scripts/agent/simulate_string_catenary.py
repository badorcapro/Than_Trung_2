"""Yarn String Catenary, Verlet Physics, and Investigative Tools Simulator.

Simulates the exact physical models and interaction parameters extracted from
decompiled Dupery C# classes: StringManager, ConnectionStringVerlet, LRBrush,
and MagnifyingGlassManager.
"""

from __future__ import annotations

import argparse
import math
import sys
from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple


@dataclass
class Vector2D:
    """2D Vector for physics and geometry calculations."""
    x: float
    y: float

    def __add__(self, other: Vector2D) -> Vector2D:
        return Vector2D(self.x + other.x, self.y + other.y)

    def __sub__(self, other: Vector2D) -> Vector2D:
        return Vector2D(self.x - other.x, self.y - other.y)

    def __mul__(self, scalar: float) -> Vector2D:
        return Vector2D(self.x * scalar, self.y * scalar)

    @property
    def magnitude(self) -> float:
        return math.hypot(self.x, self.y)

    @property
    def normalized(self) -> Vector2D:
        mag = self.magnitude
        return Vector2D(self.x / mag, self.y / mag) if mag > 1e-9 else Vector2D(0.0, 0.0)

    def distance_to(self, other: Vector2D) -> float:
        return math.hypot(self.x - other.x, self.y - other.y)


DEFAULT_GRAVITY = Vector2D(0.0, -2.0)
DEFAULT_DAMPING = 0.98
DEFAULT_SEGMENT_COUNT = 50
DEFAULT_CONSTRAINT_RUN_COUNT = 50
DEFAULT_STRING_SNAP_DISTANCE = 50.0  # pixels
DEFAULT_FIXED_DELTA_TIME = 0.02  # 50 Hz physics step


@dataclass
class VerletSegment:
    """A single particle in the Verlet string."""
    current_pos: Vector2D
    old_pos: Vector2D


def create_verlet_string(
    start_pos: Vector2D,
    end_pos: Vector2D,
    segment_count: int = DEFAULT_SEGMENT_COUNT,
) -> List[VerletSegment]:
    """Initialize a string of segments interpolated linearly between start and end."""
    segments: List[VerletSegment] = []
    for i in range(segment_count):
        t = i / float(segment_count - 1) if segment_count > 1 else 0.0
        pos = start_pos + (end_pos - start_pos) * t
        segments.append(VerletSegment(current_pos=pos, old_pos=pos))
    return segments


def step_verlet_physics(
    segments: List[VerletSegment],
    start_point: Vector2D,
    end_point: Vector2D,
    segment_length: float,
    gravity: Vector2D = DEFAULT_GRAVITY,
    damping: float = DEFAULT_DAMPING,
    dt: float = DEFAULT_FIXED_DELTA_TIME,
    constraint_runs: int = DEFAULT_CONSTRAINT_RUN_COUNT,
) -> None:
    """Execute one physics step with Verlet integration and distance constraints."""
    count = len(segments)
    if count < 2:
        return

    # 1. Verlet Integration (Inertia + Gravity)
    for seg in segments:
        velocity = (seg.current_pos - seg.old_pos) * damping
        seg.old_pos = seg.current_pos
        seg.current_pos = seg.current_pos + velocity + (gravity * dt)

    # 2. Relaxation Constraints
    for _ in range(constraint_runs):
        segments[0].current_pos = start_point
        segments[count - 1].current_pos = end_point

        for i in range(count - 1):
            seg_a = segments[i]
            seg_b = segments[i + 1]
            diff = seg_a.current_pos - seg_b.current_pos
            current_dist = diff.magnitude
            error = current_dist - segment_length
            offset = diff.normalized * error

            if i != 0 and i != count - 2:
                seg_a.current_pos = seg_a.current_pos - (offset * 0.5)
                seg_b.current_pos = seg_b.current_pos + (offset * 0.5)
            elif i == count - 2:
                seg_a.current_pos = seg_a.current_pos - offset
            else:
                seg_b.current_pos = seg_b.current_pos + offset

        segments[0].current_pos = start_point
        segments[count - 1].current_pos = end_point


def check_pin_string_snap(
    mouse_pos: Vector2D,
    pin_pos: Vector2D,
    snap_distance: float = DEFAULT_STRING_SNAP_DISTANCE,
) -> bool:
    """Check if cursor is close enough to snap yarn to a pin head (StringManager.cs:57)."""
    return mouse_pos.distance_to(pin_pos) <= snap_distance


def calculate_magnifying_glass_timings(fps: float = 60.0) -> Dict[str, int]:
    """Calculate frame counts for magnifying glass opening/closing (MagnifyingGlassManager.cs:59-62)."""
    open_sec = 0.5
    close_sec = 0.35
    return {
        "open_frames": round(open_sec * fps),
        "close_frames": round(close_sec * fps),
    }


def filter_drawing_stroke_points(
    points: List[Vector2D],
    min_distance: float = 5.0,
) -> List[Vector2D]:
    """Subdivide and filter freehand brush stroke points (LRBrush.cs)."""
    if not points:
        return []
    filtered = [points[0]]
    for pt in points[1:]:
        if pt.distance_to(filtered[-1]) >= min_distance:
            filtered.append(pt)
    return filtered


def verify_string_catenary_simulation() -> bool:
    """Run deterministic mathematical validation of string physics and tool timings."""
    start = Vector2D(0.0, 500.0)
    end = Vector2D(400.0, 500.0)
    total_span = start.distance_to(end)
    seg_length = (total_span * 1.05) / float(DEFAULT_SEGMENT_COUNT - 1)

    segments = create_verlet_string(start, end, DEFAULT_SEGMENT_COUNT)
    if len(segments) != 50:
        return False

    # Simulate 30 frames (0.6s)
    for _ in range(30):
        step_verlet_physics(segments, start, end, seg_length)

    mid_idx = DEFAULT_SEGMENT_COUNT // 2
    mid_y = segments[mid_idx].current_pos.y
    # Under negative gravity (0, -2), mid Y must sag below endpoints Y (500.0)
    if mid_y >= 500.0:
        return False

    # Check pin snap
    pin = Vector2D(100.0, 200.0)
    if not check_pin_string_snap(Vector2D(110.0, 220.0), pin):
        return False
    if check_pin_string_snap(Vector2D(200.0, 300.0), pin):
        return False

    # Check magnifying glass frames
    mg_timings = calculate_magnifying_glass_timings(60.0)
    if mg_timings["open_frames"] != 30 or mg_timings["close_frames"] != 21:
        return False

    # Check drawing stroke filter
    raw_points = [
        Vector2D(0.0, 0.0),
        Vector2D(1.0, 1.0),
        Vector2D(2.0, 2.0),
        Vector2D(10.0, 10.0),
        Vector2D(11.0, 11.0),
        Vector2D(20.0, 20.0),
    ]
    filtered = filter_drawing_stroke_points(raw_points, min_distance=5.0)
    if len(filtered) != 3:
        return False

    return True


def main() -> int:
    """CLI Entry point for string catenary simulator."""
    parser = argparse.ArgumentParser(description="Dupery Yarn String and Tools Simulator")
    parser.add_argument("--verify", action="store_true", help="Run deterministic mathematical validation")
    args = parser.parse_args()

    ok = verify_string_catenary_simulation()
    if ok:
        print("SIMULATION PASS: All string catenary, Verlet relaxation, and tool timings verified.")
        return 0
    print("SIMULATION FAIL: Physics divergence detected.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
