"""Detective Board Layout and Snap Grid Mathematical Simulation Engine.

Simulates the exact geometric layout, slot true coordinates, pin offsets,
snap radius logic, and classification ratio calculations extracted from
decompiled Dupery C# classes: BoardVisualManager, PinsController, DragPin,
and VisualClassificationRatioGC.
"""

from __future__ import annotations

import argparse
import math
import sys
from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple


@dataclass(frozen=True)
class Vector2D:
    """2D Vector with arithmetic operations."""
    x: float
    y: float

    def __add__(self, other: Vector2D) -> Vector2D:
        return Vector2D(self.x + other.x, self.y + other.y)

    def __sub__(self, other: Vector2D) -> Vector2D:
        return Vector2D(self.x - other.x, self.y - other.y)

    def __mul__(self, scalar: float) -> Vector2D:
        return Vector2D(self.x * scalar, self.y * scalar)

    def distance_to(self, other: Vector2D) -> float:
        return math.hypot(self.x - other.x, self.y - other.y)


DEFAULT_CELL_SIZE = Vector2D(-600.0, -600.0)
DEFAULT_GRID_CENTER = Vector2D(25.0, 87.5)
DEFAULT_PIN_DRAG_OFFSET = Vector2D(0.0, 20.0)
DEFAULT_PIN_OFFSET = Vector2D(-0.25, 0.35)
DEFAULT_SNAP_RADIUS = 120.0  # Screen pixels in UI space


def compute_board_scale(board_width: int, board_height: int) -> float:
    """Calculate board scale based on maximum dimension (BoardVisualManager.cs:174-176)."""
    max_dim = max(board_width, board_height)
    if max_dim == 4:
        return 1.0
    if max_dim < 4:
        return 1.15
    return 0.85


def compute_grid_start_position(
    board_width: int,
    board_height: int,
    cell_size: Vector2D = DEFAULT_CELL_SIZE,
    grid_center: Vector2D = DEFAULT_GRID_CENTER,
) -> Vector2D:
    """Calculate top-left grid start position (BoardVisualManager.cs:178)."""
    offset_x = float(board_width - 1) / 2.0 * cell_size.x
    offset_y = float(board_height - 1) / 2.0 * cell_size.y
    return grid_center - Vector2D(offset_x, offset_y)


def compute_slot_true_position(
    grid_x: int,
    grid_y: int,
    grid_start_pos: Vector2D,
    cell_size: Vector2D = DEFAULT_CELL_SIZE,
) -> Vector2D:
    """Calculate exact slot local coordinates on board (BoardVisualManager.cs:97-100)."""
    return grid_start_pos + Vector2D(cell_size.x * grid_x, cell_size.y * grid_y)


def generate_board_slots(
    board_width: int,
    board_height: int,
    cell_size: Vector2D = DEFAULT_CELL_SIZE,
    grid_center: Vector2D = DEFAULT_GRID_CENTER,
) -> Dict[Tuple[int, int], Vector2D]:
    """Generate all slot coordinates for given board dimensions."""
    start_pos = compute_grid_start_position(board_width, board_height, cell_size, grid_center)
    slots: Dict[Tuple[int, int], Vector2D] = {}
    for x in range(board_width):
        for y in range(board_height):
            slots[(x, y)] = compute_slot_true_position(x, y, start_pos, cell_size)
    return slots


def find_nearest_slot(
    pin_position: Vector2D,
    slots: Dict[Tuple[int, int], Vector2D],
    snap_radius: float = DEFAULT_SNAP_RADIUS,
) -> Optional[Tuple[Tuple[int, int], float]]:
    """Determine closest slot within snap radius if any (DragPin snap logic)."""
    closest_slot: Optional[Tuple[int, int]] = None
    min_dist = float("inf")

    for coord, slot_pos in slots.items():
        dist = pin_position.distance_to(slot_pos)
        if dist < min_dist:
            min_dist = dist
            closest_slot = coord

    if closest_slot is not None and min_dist <= snap_radius:
        return (closest_slot, round(min_dist, 2))
    return None


def calculate_pin_drop_timing(fps: float = 60.0) -> Dict[str, float]:
    """Calculate exact 60fps frame timing for pin drop tween (DragPin.cs:123-128)."""
    duration_sec = 0.4
    sound_delay_sec = 0.3
    return {
        "duration_sec": duration_sec,
        "total_frames": round(duration_sec * fps),
        "sound_trigger_sec": sound_delay_sec,
        "sound_trigger_frame": round(sound_delay_sec * fps),
        "easing_function": "TRANS_BACK, EASE_IN",
    }


def calculate_visual_classification_extra(
    target_classification: str,
    roles_in_play: List[Tuple[str, str]],
) -> int:
    """Replicate countRequiredExtra logic from VisualClassificationRatioGC.cs:53-73.

    roles_in_play: list of (true_classification, visual_classification).
    """
    count_true = 0
    count_visual = 0
    for true_cls, visual_cls in roles_in_play:
        if true_cls != visual_cls:
            if true_cls == target_classification:
                count_true += 1
            if visual_cls == target_classification:
                count_visual += 1
    return count_visual - count_true


def verify_board_simulation() -> bool:
    """Run deterministic self-test of all geometric and ratio formulas."""
    scale_3x3 = compute_board_scale(3, 3)
    scale_4x4 = compute_board_scale(4, 4)
    scale_5x5 = compute_board_scale(5, 5)
    if scale_3x3 != 1.15 or scale_4x4 != 1.0 or scale_5x5 != 0.85:
        return False

    slots_4x4 = generate_board_slots(4, 4)
    if len(slots_4x4) != 16:
        return False

    start_pos = compute_grid_start_position(4, 4)
    expected_origin = DEFAULT_GRID_CENTER - Vector2D(1.5 * -600.0, 1.5 * -600.0)
    if start_pos.x != expected_origin.x or start_pos.y != expected_origin.y:
        return False

    slot_0_0 = slots_4x4[(0, 0)]
    near_pin = slot_0_0 + Vector2D(25.0, 25.0)
    snap_res = find_nearest_slot(near_pin, slots_4x4, snap_radius=100.0)
    if snap_res is None or snap_res[0] != (0, 0):
        return False

    far_pin = slot_0_0 + Vector2D(300.0, 300.0)
    far_snap = find_nearest_slot(far_pin, slots_4x4, snap_radius=100.0)
    if far_snap is not None:
        return False

    timing = calculate_pin_drop_timing(60.0)
    if timing["total_frames"] != 24 or timing["sound_trigger_frame"] != 18:
        return False

    roles = [("MURDERER", "INNOCENT"), ("INNOCENT", "MURDERER"), ("INNOCENT", "INNOCENT")]
    extra_murderer = calculate_visual_classification_extra("MURDERER", roles)
    if extra_murderer != 0:
        return False

    roles_skewed = [("MURDERER", "INNOCENT"), ("ACCOMPLICE", "MURDERER")]
    extra_m2 = calculate_visual_classification_extra("MURDERER", roles_skewed)
    if extra_m2 != 0:
        return False

    roles_guilty_visual = [("INNOCENT", "MURDERER")]
    extra_m3 = calculate_visual_classification_extra("MURDERER", roles_guilty_visual)
    if extra_m3 != 1:
        return False

    return True


def main() -> int:
    """CLI Entry point for board simulation."""
    parser = argparse.ArgumentParser(description="Dupery Detective Board Layout Simulator")
    parser.add_argument("--verify", action="store_true", help="Run deterministic mathematical validation")
    parser.add_argument("--demo", action="store_true", help="Print sample 4x4 board coordinates")
    args = parser.parse_args()

    if args.verify or (not args.demo):
        ok = verify_board_simulation()
        if ok:
            print("SIMULATION PASS: All geometric, snap grid, and ratio calculations verified.")
            return 0
        print("SIMULATION FAIL: Calculation divergence detected.")
        return 1

    if args.demo:
        slots = generate_board_slots(4, 4)
        print("=== 4x4 Board Slots Layout ===")
        for (x, y), pos in sorted(slots.items()):
            print(f"Slot ({x}, {y}): x={pos.x:8.1f}, y={pos.y:8.1f}")
        return 0

    return 0


if __name__ == "__main__":
    sys.exit(main())
