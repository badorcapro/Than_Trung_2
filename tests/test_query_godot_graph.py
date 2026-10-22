"""
Unit tests for Godot Graph Query CLI & Architecture Report Generator (scripts/agent/query_godot_graph.py).
"""

from __future__ import annotations

import contextlib
import io
import json
from pathlib import Path
import sys
import unittest

ROOT_DIR = Path(__file__).resolve().parents[1]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.query_godot_graph import (
    find_nodes,
    find_scripts,
    get_god_files,
    main,
    output_results,
    trace_connections,
)


class TestQueryGodotGraph(unittest.TestCase):
    """Test suite for query_godot_graph.py query engine and CLI."""

    def setUp(self) -> None:
        self.mock_scene_graph = {
            "nodes": [
                {
                    "name": "PlayerButton",
                    "node_path": "Menu/PlayerButton",
                    "type": "Button",
                    "scene_path": "scenes/boot/DebugHome.tscn",
                    "script_path": "",
                },
                {
                    "name": "Background",
                    "node_path": "Root/Background",
                    "type": "ColorRect",
                    "scene_path": "scenes/boot/Boot.tscn",
                    "script_path": "",
                },
            ],
            "connections": [
                {
                    "kind": "static_ui",
                    "signal": "pressed",
                    "from_node": "Menu/PlayerButton",
                    "to_node": ".",
                    "method": "_on_button_pressed",
                    "scene_path": "scenes/boot/DebugHome.tscn",
                },
                {
                    "kind": "dynamic_code",
                    "signal": "case_selected",
                    "from_node": "CaseManager",
                    "to_node": "UI",
                    "method": "load_case",
                    "scene_path": "scenes/main/Game.tscn",
                },
            ],
        }

        self.mock_code_symbols = {
            "scripts": [
                {
                    "path": "autoload/AppFlow.gd",
                    "extends": "Node",
                    "method_count": 2,
                    "signal_count": 0,
                },
                {
                    "path": "scripts/domain/CaseGenerator.gd",
                    "extends": "RefCounted",
                    "method_count": 10,
                    "signal_count": 1,
                },
            ],
            "methods": [
                {
                    "script_path": "autoload/AppFlow.gd",
                    "name": "go_to_debug_home",
                },
                {
                    "script_path": "scripts/domain/CaseGenerator.gd",
                    "name": "solve_case",
                },
            ],
        }

        self.mock_project_index = {
            "gdscript_files": [
                {"path": "scripts/A.gd", "total_lines": 1200, "layer": "domain", "extends": "Node"},
                {"path": "scripts/B.gd", "total_lines": 300, "layer": "presentation", "extends": "Control"},
                {"path": "scripts/C.gd", "total_lines": 600, "layer": "tools", "extends": "RefCounted"},
            ]
        }

    def test_find_nodes_by_name_and_path(self) -> None:
        matches = find_nodes("Player", self.mock_scene_graph)
        self.assertEqual(len(matches), 1)
        self.assertEqual(matches[0]["node_name"], "PlayerButton")
        self.assertEqual(matches[0]["type"], "Button")

        path_matches = find_nodes("Root/", self.mock_scene_graph)
        self.assertEqual(len(path_matches), 1)
        self.assertEqual(path_matches[0]["node_name"], "Background")

        none_matches = find_nodes("NonExistent", self.mock_scene_graph)
        self.assertEqual(len(none_matches), 0)

    def test_find_scripts_by_path_and_method(self) -> None:
        path_matches = find_scripts("AppFlow", self.mock_code_symbols)
        self.assertEqual(len(path_matches), 1)
        self.assertEqual(path_matches[0]["script_path"], "autoload/AppFlow.gd")
        self.assertEqual(path_matches[0]["base_class"], "Node")

        method_matches = find_scripts("solve_case", self.mock_code_symbols)
        self.assertEqual(len(method_matches), 1)
        self.assertEqual(method_matches[0]["script_path"], "scripts/domain/CaseGenerator.gd")
        self.assertIn("solve_case", method_matches[0]["matched_methods"])

    def test_trace_connections(self) -> None:
        conn_pressed = trace_connections("pressed", self.mock_scene_graph)
        self.assertEqual(len(conn_pressed), 1)
        self.assertEqual(conn_pressed[0]["signal_name"], "pressed")
        self.assertEqual(conn_pressed[0]["target_method"], "_on_button_pressed")

        conn_dyn = trace_connections("case_selected", self.mock_scene_graph)
        self.assertEqual(len(conn_dyn), 1)
        self.assertEqual(conn_dyn[0]["connection_type"], "dynamic_code")

    def test_get_god_files(self) -> None:
        gods = get_god_files(500, self.mock_project_index)
        self.assertEqual(len(gods), 2)
        self.assertEqual(gods[0]["path"], "scripts/A.gd")
        self.assertEqual(gods[0]["total_lines"], 1200)
        self.assertEqual(gods[1]["path"], "scripts/C.gd")
        self.assertEqual(gods[1]["total_lines"], 600)

    def test_output_results_formats(self) -> None:
        sample_data = [{"id": 1, "name": "NodeA"}]

        # Test JSON format
        f_json = io.StringIO()
        with contextlib.redirect_stdout(f_json):
            output_results(sample_data, "json")
        out_json = f_json.getvalue()
        self.assertIn('"name": "NodeA"', out_json)

        # Test JSONL format
        f_jsonl = io.StringIO()
        with contextlib.redirect_stdout(f_jsonl):
            output_results(sample_data, "jsonl")
        out_jsonl = f_jsonl.getvalue()
        self.assertTrue(out_jsonl.startswith('{"id": 1'))

        # Test TOON format
        f_toon = io.StringIO()
        with contextlib.redirect_stdout(f_toon):
            output_results(sample_data, "toon")
        out_toon = f_toon.getvalue()
        self.assertIn("NodeA", out_toon)

    def test_cli_subcommands_execution(self) -> None:
        f_out = io.StringIO()
        with contextlib.redirect_stdout(f_out):
            ret_stats = main(["stats"])
            self.assertEqual(ret_stats, 0)

            ret_node = main(["find-node", "Boot"])
            self.assertEqual(ret_node, 0)

            ret_god = main(["check-god-files", "--threshold", "1000"])
            self.assertEqual(ret_god, 0)


if __name__ == "__main__":
    unittest.main()
