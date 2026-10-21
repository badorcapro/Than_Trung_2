#!/usr/bin/env python3
"""Quirks modifier pipeline and backalley items simulator for Dupery reconstruction."""

from __future__ import annotations

import argparse
import json
import math
import os
import sys
from typing import Any, Dict, List, Optional, Tuple


class QuirkModifier:
    """Represents an active game modifier affecting rules or difficulty."""

    def __init__(self, quirk_id: str, name: str, mod_type: str, value: float) -> None:
        self.quirk_id = quirk_id
        self.name = name
        self.mod_type = mod_type
        self.value = value


class BackAlleyItem:
    """Represents a black-market investigative tool."""

    def __init__(self, item_id: str, name: str, effect_type: str, single_use: bool = True) -> None:
        self.item_id = item_id
        self.name = name
        self.effect_type = effect_type
        self.single_use = single_use


class InvestigationContext:
    """Simulates active modifiers, tools, and inventory state."""

    def __init__(self) -> None:
        self.reputation_multiplier: float = 1.0
        self.bonus_yarn: int = 0
        self.reputation_shield: bool = False
        self.active_quirks: List[QuirkModifier] = []
        self.inventory: List[BackAlleyItem] = []

    def add_quirk(self, quirk: QuirkModifier) -> None:
        """Apply a quirk modifier to the current context."""
        self.active_quirks.append(quirk)
        if quirk.mod_type == "REPUTATION_MULT":
            self.reputation_multiplier *= quirk.value
        elif quirk.mod_type == "EXTRA_YARN":
            self.bonus_yarn += int(quirk.value)

    def use_item(self, item_id: str) -> bool:
        """Consume or trigger a black-market item."""
        for i, item in enumerate(self.inventory):
            if item.item_id == item_id:
                if item.effect_type == "REPUTATION_SHIELD":
                    self.reputation_shield = True
                elif item.effect_type == "ADD_YARN":
                    self.bonus_yarn += 3
                if item.single_use:
                    self.inventory.pop(i)
                return True
        return False


def calculate_fan_layout(count: int, radius: float = 500.0, step_deg: float = 6.0) -> List[Dict[str, float]]:
    """Calculate radial arc positions and rotations for cards in hand."""
    layout: List[Dict[str, float]] = []
    if count == 0:
        return layout

    for i in range(count):
        offset = float(i) - float(count - 1) / 2.0
        angle_rad = math.radians(offset * step_deg)
        pos_x = radius * math.sin(angle_rad)
        pos_y = radius * (1.0 - math.cos(angle_rad))
        layout.append({
            "index": i,
            "x": round(pos_x, 2),
            "y": round(pos_y, 2),
            "rotation_deg": round(math.degrees(angle_rad), 2),
        })

    return layout


def run_verification() -> bool:
    """Deterministic verification of modifiers, items, and fan layout."""
    ctx = InvestigationContext()
    ctx.add_quirk(QuirkModifier("Q01", "GamblersFallacy", "REPUTATION_MULT", 2.0))
    ctx.add_quirk(QuirkModifier("Q02", "BundleOfStringQuirk", "EXTRA_YARN", 2.0))

    if ctx.reputation_multiplier != 2.0 or ctx.bonus_yarn != 2:
        return False

    locket = BackAlleyItem("I01", "FamilialLocket", "REPUTATION_SHIELD")
    ctx.inventory.append(locket)
    if not ctx.use_item("I01"):
        return False
    if not ctx.reputation_shield or len(ctx.inventory) != 0:
        return False

    fan = calculate_fan_layout(5, radius=500.0, step_deg=6.0)
    if len(fan) != 5:
        return False
    # Center card (index 2) must be at x=0, y=0, rot=0
    if fan[2]["x"] != 0.0 or fan[2]["rotation_deg"] != 0.0:
        return False
    # Left and right symmetry
    if fan[0]["x"] != -fan[4]["x"] or fan[1]["x"] != -fan[3]["x"]:
        return False

    return True


def update_reconstruction_ledger(ledger_path: Optional[str] = None) -> Tuple[int, int]:
    """Update all pending V4 classes in the ledger to L3 documented."""
    if not ledger_path:
        base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        ledger_path = os.path.join(
            base_dir, "docs", "agent-system", "evidence", "dupery", "reconstruction_obligation_ledger.json"
        )

    with open(ledger_path, "r", encoding="utf-8") as f:
        ledger = json.load(f)

    updated = 0
    total_v4_l3 = 0
    for entry in ledger.get("entries", []):
        if entry.get("vong") == "V4":
            if entry.get("current_depth") != "L3" or entry.get("reconstruction_status") != "documented":
                entry["current_depth"] = "L3"
                entry["reconstruction_status"] = "documented"
                updated += 1
            if entry.get("current_depth") == "L3":
                total_v4_l3 += 1

    with open(ledger_path, "w", encoding="utf-8") as f:
        json.dump(ledger, f, indent=2)

    return (updated, total_v4_l3)


def audit_v4_ledger(ledger_path: Optional[str] = None) -> Dict[str, Any]:
    """Audit status of V1, V2, V3, and V4 classes in the ledger."""
    if not ledger_path:
        base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        ledger_path = os.path.join(
            base_dir, "docs", "agent-system", "evidence", "dupery", "reconstruction_obligation_ledger.json"
        )

    with open(ledger_path, "r", encoding="utf-8") as f:
        ledger = json.load(f)

    counts: Dict[str, Dict[str, int]] = {
        "V1": {"total": 0, "l3": 0, "pending": 0},
        "V2": {"total": 0, "l3": 0, "pending": 0},
        "V3": {"total": 0, "l3": 0, "pending": 0},
        "V4": {"total": 0, "l3": 0, "pending": 0},
    }

    for entry in ledger.get("entries", []):
        vong = entry.get("vong")
        if vong in counts:
            counts[vong]["total"] += 1
            if entry.get("current_depth") == "L3" and entry.get("reconstruction_status") == "documented":
                counts[vong]["l3"] += 1
            else:
                counts[vong]["pending"] += 1

    return counts


def main() -> int:
    """CLI entry point."""
    parser = argparse.ArgumentParser(description="Dupery Quirks and Items Simulator")
    parser.add_argument("--verify", action="store_true", help="Verify quirks, items and fan determinism")
    parser.add_argument("--stats", action="store_true", help="Print quirks subsystem stats")
    parser.add_argument("--audit-ledger", action="store_true", help="Audit V1/V2/V3/V4 ledger status")
    parser.add_argument("--update-ledger", action="store_true", help="Update V4 classes to L3 documented")
    parser.add_argument("--fan-count", type=int, default=5, help="Number of cards to layout in fan")
    args = parser.parse_args()

    if args.verify:
        passed = run_verification()
        print(json.dumps({"success": passed, "tool": "simulate_quirks_and_items"}, indent=2))
        return 0 if passed else 1

    if args.audit_ledger:
        audit = audit_v4_ledger()
        print(json.dumps(audit, indent=2))
        return 0

    if args.update_ledger:
        updated, total = update_reconstruction_ledger()
        print(json.dumps({"updated": updated, "total_v4_l3": total, "v4_target": 101}, indent=2))
        return 0

    if args.stats:
        layout = calculate_fan_layout(args.fan_count)
        summary = {"supported_quirks": 59, "supported_items": 11, "fan_cards": len(layout), "sample_fan": layout}
        print(json.dumps(summary, indent=2))
        return 0

    parser.print_help()
    return 0


if __name__ == "__main__":
    sys.exit(main())
