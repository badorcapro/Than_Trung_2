"""
Unit and Integration Tests for Modular Godot Static Graph Parser (tests/test_godot_parser.py).
"""

from __future__ import annotations

import json
from pathlib import Path
import tempfile
import unittest

from scripts.agent.gdscript_parser import parse_gd_file
from scripts.agent.godot_parser import verify_godot_parser
from scripts.agent.toon_projector import format_projection
from scripts.agent.tscn_parser import parse_tscn_file


class TestGodotParser(unittest.TestCase):
    """Verify Modular Static Graph Parser for .tscn scenes and .gd scripts."""

    def test_parse_tscn_extracts_nodes_connections_and_deps(self) -> None:
        sample_tscn = (
            '[gd_scene load_steps=2 format=3 uid="uid://test1234"]\n\n'
            '[ext_resource type="Script" path="res://scripts/TestScript.gd" id="1"]\n\n'
            '[node name="Root" type="Control"]\n'
            'script = ExtResource("1")\n\n'
            '[node name="ChildButton" type="Button" parent="Root"]\n\n'
            '[connection signal="pressed" from="Root/ChildButton" to="." method="_on_button_pressed"]\n'
        )
        with tempfile.TemporaryDirectory() as tmp:
            godot_root = Path(tmp)
            scene_path = godot_root / "scenes/TestScene.tscn"
            scene_path.parent.mkdir(parents=True, exist_ok=True)
            scene_path.write_text(sample_tscn, encoding="utf-8")

            s_entry, nodes, conns, deps = parse_tscn_file(scene_path, godot_root)
            self.assertEqual(s_entry["path"], "scenes/TestScene.tscn")
            self.assertEqual(s_entry["root_name"], "Root")
            self.assertEqual(s_entry["root_type"], "Control")
            self.assertEqual(s_entry["script_path"], "scripts/TestScript.gd")
            self.assertEqual(len(nodes), 2)
            self.assertEqual(len(conns), 1)
            self.assertEqual(conns[0]["kind"], "static_ui")
            self.assertEqual(conns[0]["signal"], "pressed")
            self.assertEqual(conns[0]["method"], "_on_button_pressed")
            self.assertEqual(len(deps), 1)

    def test_multiline_functions_and_dynamic_connect(self) -> None:
        sample_gd = (
            'class_name CustomCase\n'
            'extends RefCounted\n\n'
            'signal case_solved(suspect_id: String, score: int)\n\n'
            'const Helper = preload("res://scripts/Helper.gd")\n\n'
            'func generate_complex_case(\n'
            '    case_id: String,\n'
            '    difficulty: int = 1,\n'
            '    rules: Array = []\n'
            ') -> Dictionary:\n'
            '    button.pressed.connect(_on_custom_pressed)\n'
            '    return {}\n'
        )
        with tempfile.TemporaryDirectory() as tmp:
            godot_root = Path(tmp)
            script_path = godot_root / "scripts/domain/CustomCase.gd"
            script_path.parent.mkdir(parents=True, exist_ok=True)
            script_path.write_text(sample_gd, encoding="utf-8")

            sc_entry, methods, signals, dynamic_conns, deps = parse_gd_file(script_path, godot_root)
            self.assertEqual(sc_entry["class_name"], "CustomCase")
            self.assertEqual(sc_entry["extends"], "RefCounted")
            self.assertEqual(sc_entry["layer"], "domain")
            self.assertEqual(len(signals), 1)
            self.assertEqual(signals[0]["name"], "case_solved")

            # Verify multiline function parsed successfully
            self.assertEqual(len(methods), 1)
            self.assertEqual(methods[0]["name"], "generate_complex_case")
            self.assertEqual(methods[0]["return_type"], "Dictionary")
            self.assertEqual(methods[0]["param_count"], 3)
            self.assertEqual(methods[0]["params"], ["case_id", "difficulty", "rules"])

            # Verify dynamic .connect() parsed successfully
            self.assertEqual(len(dynamic_conns), 1)
            self.assertEqual(dynamic_conns[0]["kind"], "dynamic_code")
            self.assertEqual(dynamic_conns[0]["signal"], "pressed")
            self.assertEqual(dynamic_conns[0]["from_node"], "button")
            self.assertEqual(dynamic_conns[0]["method"], "_on_custom_pressed")

    def test_verify_real_godot_modular_artifacts(self) -> None:
        res = verify_godot_parser()
        self.assertTrue(res.success, f"verify_godot_parser failed: {res.issues}")
        self.assertEqual(res.data["total_scenes"], 21)
        self.assertGreaterEqual(res.data["total_nodes"], 1000)
        self.assertEqual(res.data["total_static_ui_connections"], 204)
        self.assertGreaterEqual(res.data["total_dynamic_code_connections"], 150)
        self.assertEqual(res.data["total_scripts"], 293)
        self.assertGreaterEqual(res.data["total_methods"], 4000)

    def test_scene_graph_toon_projection(self) -> None:
        scene_json = Path(__file__).resolve().parents[1] / "docs/agent-system/evidence/godot/scene_graph.json"
        raw_data = json.loads(scene_json.read_text(encoding="utf-8"))
        toon_out = format_projection(
            raw_data,
            "toon",
            source_path=scene_json,
            select_path="scenes:path,root_name,root_type,node_count,connection_count",
        )
        self.assertIn("[21]{path,root_name,root_type,node_count,connection_count}:", toon_out)
        self.assertIn("scenes/boot/Boot.tscn,Boot,Control,15,0", toon_out)


if __name__ == "__main__":
    unittest.main()
