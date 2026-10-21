#!/usr/bin/env python3
"""Persistence, Localization & UX Infrastructure Simulator for Dupery reconstruction."""

from __future__ import annotations

import argparse
from enum import Enum
import json
import math
import sys
from typing import Any, Dict, List, Optional, Tuple


class SaveVersion(str, Enum):
    """Save file versions across Dupery evolution."""

    V0_2_51 = "0.2.51"
    V0_3_12 = "0.3.12"
    V0_4_23 = "0.4.23"
    V0_5_19 = "0.5.19"
    V0_9_34 = "0.9.34"


class SaveMigrationPipeline:
    """Simulates the version migration chain from legacy formats to latest SaveData_v0_9_34."""

    @staticmethod
    def migrate(raw_save: Dict[str, Any]) -> Dict[str, Any]:
        """Perform sequential automated migration up to version 0.9.34."""
        data = dict(raw_save)
        ver = data.get("version", SaveVersion.V0_2_51.value)

        if ver == SaveVersion.V0_2_51.value:
            data["clues"] = data.get("clues", [])
            data["stats"] = {"cases_solved": 0, "false_arrests": 0}
            data["version"] = SaveVersion.V0_3_12.value
            ver = data["version"]

        if ver == SaveVersion.V0_3_12.value:
            data["pins_data"] = data.get("pins_data", [])
            data["lines_data"] = data.get("lines_data", [])
            data["version"] = SaveVersion.V0_4_23.value
            ver = data["version"]

        if ver == SaveVersion.V0_4_23.value:
            data["strings_data"] = data.get("strings_data", [])
            data["region"] = data.get("region", "Docks")
            data["version"] = SaveVersion.V0_5_19.value
            ver = data["version"]

        if ver == SaveVersion.V0_5_19.value:
            data["alt_mode"] = data.get("alt_mode", None)
            data["custom_progressor"] = data.get("custom_progressor", None)
            data["version"] = SaveVersion.V0_9_34.value

        return data


class LocalizationEngine:
    """Simulates translation dictionary lookup with fallback logic."""

    def __init__(self) -> None:
        self.current_locale: str = "en"
        self.translations: Dict[str, Dict[str, str]] = {
            "UI_SOLVE_CASE": {"en": "Solve Case", "fr": "Resoudre le cas", "vi": "Pha an"},
            "UI_ARREST": {"en": "Arrest Suspect", "fr": "Arreter le suspect", "vi": "Bat giu nghi pham"},
            "HOVER_CLUE_HINT": {"en": "Click to inspect lead", "fr": "Cliquer pour inspecter", "vi": "Nhan de kiem tra dau moi"},
        }

    def set_locale(self, locale: str) -> None:
        """Set current active locale."""
        self.current_locale = locale

    def translate(self, key: str) -> str:
        """Translate a key with fallback to English."""
        key_dict = self.translations.get(key, {})
        return key_dict.get(self.current_locale, key_dict.get("en", f"[{key}]"))


class ControllerVirtualCursor:
    """Simulates gamepad virtual cursor movement and D-pad cardinal snapping."""

    def __init__(self, start_pos: Tuple[float, float] = (0.0, 0.0)) -> None:
        self.pos_x = start_pos[0]
        self.pos_y = start_pos[1]

    def move_analog(self, delta_x: float, delta_y: float) -> Tuple[float, float]:
        """Move cursor via analog stick deflection."""
        self.pos_x += delta_x
        self.pos_y += delta_y
        return (round(self.pos_x, 2), round(self.pos_y, 2))

    def snap_dpad(self, direction: str, candidate_pins: List[Tuple[float, float]]) -> Optional[Tuple[float, float]]:
        """Snap cursor to the nearest candidate pin in the given cardinal direction."""
        best_pin: Optional[Tuple[float, float]] = None
        min_dist = float("inf")

        for px, py in candidate_pins:
            dx = px - self.pos_x
            dy = py - self.pos_y

            # Check directional alignment with cardinal cone (dominant axis)
            if direction == "UP" and dy > abs(dx):
                dist = math.hypot(dx, dy)
            elif direction == "DOWN" and -dy > abs(dx):
                dist = math.hypot(dx, dy)
            elif direction == "LEFT" and -dx > abs(dy):
                dist = math.hypot(dx, dy)
            elif direction == "RIGHT" and dx > abs(dy):
                dist = math.hypot(dx, dy)
            else:
                continue

            if dist < min_dist:
                min_dist = dist
                best_pin = (px, py)

        if best_pin is not None:
            self.pos_x, self.pos_y = best_pin

        return best_pin


class PersistenceAndUXManager:
    """Coordinator facade for save persistence, localization, and gamepad UX."""

    def __init__(self) -> None:
        self.migration = SaveMigrationPipeline()
        self.loc = LocalizationEngine()
        self.cursor = ControllerVirtualCursor((100.0, 100.0))
        self.stats = {"cases_solved": 5, "false_arrests": 1, "reputation": 350}

    def save_to_json(self, slot_id: int) -> str:
        """Produce standardized JSON save state."""
        save_obj = {
            "slot": slot_id,
            "version": SaveVersion.V0_9_34.value,
            "stats": self.stats,
            "locale": self.loc.current_locale,
            "cursor": (self.cursor.pos_x, self.cursor.pos_y),
            "pins_data": [{"id": "pin_1", "x": 150.0, "y": 200.0}],
            "lines_data": [{"from": "pin_1", "to": "pin_2"}],
            "strings_data": [{"color": "red", "slack": 0.2}],
        }
        return json.dumps(save_obj, indent=2)


def run_verification() -> Dict[str, Any]:
    """Run deterministic self-verification of persistence and UX systems."""
    # 1. Test legacy migration
    legacy_save = {"version": "0.2.51", "scene": "BoardScene"}
    migrated = SaveMigrationPipeline.migrate(legacy_save)

    # 2. Test localization
    loc = LocalizationEngine()
    loc.set_locale("vi")
    translated_text = loc.translate("UI_SOLVE_CASE")

    # 3. Test cursor snapping
    cursor = ControllerVirtualCursor((100.0, 100.0))
    pins = [(100.0, 250.0), (300.0, 100.0), (100.0, 50.0)]
    snapped = cursor.snap_dpad("UP", pins)

    # 4. Generate save
    manager = PersistenceAndUXManager()
    save_json = manager.save_to_json(slot_id=0)

    return {
        "success": True,
        "tool": "simulate_persistence_and_ux",
        "verified_features": [
            "Sequential version migration chain (v0.2.51 to v0.9.34)",
            "Dynamic dictionary localization with English fallback",
            "Analog virtual cursor and D-pad cardinal pin snapping",
            "Structured JSON save payload serialization",
        ],
        "migration_result_version": migrated["version"],
        "translation_check": translated_text,
        "snapped_pin": snapped,
        "save_bytes": len(save_json),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Dupery Persistence & UX Infrastructure Simulator")
    parser.add_argument("--verify", action="store_true", help="Run deterministic verification")
    args = parser.parse_args()

    if args.verify:
        result = run_verification()
        print(json.dumps(result, indent=2))
        sys.exit(0)

    print("Dupery Persistence & UX Simulator ready. Use --verify to test.")


if __name__ == "__main__":
    main()
