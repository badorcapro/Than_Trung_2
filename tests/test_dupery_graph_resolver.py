"""Unit tests for Deep Scene Node Traversal and Exact Recipe Resolver (TASK-0021B)."""

from __future__ import annotations

import io
import unittest
from contextlib import redirect_stdout
from unittest.mock import patch

from scripts.agent.dupery_graph_resolver import (
    find_class_scene_attachments,
    resolve_deterministic_recipe,
    scan_cs_dependencies,
    search_scene_nodes,
)
from scripts.agent.query_dupery_graph import _load_json, FMOD_EVENT_MAP_JSON, LEDGER_JSON, inspect_classes, main


class TestDuperyGraphResolver(unittest.TestCase):
    """Test suite verifying deep scene node search and deterministic recipe resolution."""

    def test_search_scene_nodes(self) -> None:
        """Verifies recursive search across all 5,279 GameObjects in 12 scenes."""
        results = search_scene_nodes("GameplayButton")
        self.assertGreaterEqual(len(results), 10)
        first = results[0]
        self.assertIn("scene", first)
        self.assertIn("hierarchy_path", first)
        self.assertIn("rect", first)
        self.assertIn("Buttons/GameplayButton", first["hierarchy_path"])

    def test_find_class_scene_attachments(self) -> None:
        """Verifies locating exact GameObject attachment for MonoBehaviour classes."""
        attachments = find_class_scene_attachments("LineupController")
        self.assertEqual(len(attachments), 1)
        att = attachments[0]
        self.assertEqual(att["scene"], "LineupScene")
        self.assertEqual(att["game_object"], "Canvas")
        self.assertEqual(att["path_id"], 3573)

    def test_scan_cs_dependencies(self) -> None:
        """Verifies scanning decompiled .cs file for FMOD calls and ScriptableObjects."""
        deps = scan_cs_dependencies(
            "docs/agent-system/evidence/dupery/generated/decompiled_cs/Assembly-CSharp/Lineup/LineupController.cs"
        )
        audio = set(deps["audio_calls"])
        self.assertIn("Sfx.LINEUP_MOVE", audio)
        self.assertIn("Sfx.GUNSHOT", audio)
        self.assertIn("Music.F", audio)
        self.assertGreater(len(deps["scriptable_objects"]), 0)

    def test_resolve_deterministic_recipe(self) -> None:
        """Verifies deterministic recipe assembly without heuristic guessing."""
        ledger = _load_json(LEDGER_JSON)
        fmod_map = _load_json(FMOD_EVENT_MAP_JSON)
        classes = inspect_classes("LineupController", ledger)
        self.assertGreaterEqual(len(classes), 1)

        recipe = resolve_deterministic_recipe("LineupController", classes[0], fmod_map)
        self.assertEqual(recipe["primary_class"], "LineupController")
        self.assertEqual(len(recipe["exact_scene_attachments"]), 1)
        self.assertEqual(recipe["exact_scene_attachments"][0]["scene"], "LineupScene")

        fmod_names = [e["enum_name"] for e in recipe["exact_fmod_audio_calls"]]
        self.assertIn("LINEUP_MOVE", fmod_names)
        self.assertIn("GUNSHOT", fmod_names)
        self.assertIn("F", fmod_names)

    def test_cli_deep_node_search(self) -> None:
        """Verifies CLI execution with --node parameter."""
        cmd = ["inspect-scene", "--node", "GameplayButton", "--format", "toon"]
        with patch("sys.argv", ["query_dupery_graph.py"] + cmd):
            buf = io.StringIO()
            with redirect_stdout(buf):
                ret = main()
            self.assertEqual(ret, 0)
            self.assertIn("GameplayButton", buf.getvalue())
            self.assertIn("hierarchy_path", buf.getvalue())


if __name__ == "__main__":
    unittest.main()
