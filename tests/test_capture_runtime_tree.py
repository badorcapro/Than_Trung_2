"""
Unit tests for Godot 4 Runtime Tree Capture & Static Correlation Engine (scripts/agent/capture_runtime_tree.py).
"""

from __future__ import annotations

import json
from pathlib import Path
import sys
import tempfile
import unittest

ROOT_DIR = Path(__file__).resolve().parents[1]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.capture_runtime_tree import (
    correlate_nodes,
    flatten_runtime_nodes,
    run_pipeline,
)


class TestCaptureRuntimeTree(unittest.TestCase):
    """Test suite for capture_runtime_tree.py."""

    def test_flatten_runtime_nodes(self) -> None:
        mock_tree = {
            "name": "root",
            "class_name": "Window",
            "node_path": "/root",
            "groups": [],
            "children_count": 2,
            "children": [
                {
                    "name": "AppVersion",
                    "class_name": "Node",
                    "node_path": "/root/AppVersion",
                    "groups": ["autoload"],
                    "children": [],
                },
                {
                    "name": "Boot",
                    "class_name": "Control",
                    "node_path": "/root/Boot",
                    "groups": [],
                    "children": [
                        {
                            "name": "Background",
                            "class_name": "ColorRect",
                            "node_path": "/root/Boot/Background",
                            "groups": [],
                            "children": [],
                        }
                    ],
                },
            ],
        }
        flat = flatten_runtime_nodes(mock_tree)
        self.assertEqual(len(flat), 4)
        paths = [n["node_path"] for n in flat]
        self.assertIn("/root", paths)
        self.assertIn("/root/AppVersion", paths)
        self.assertIn("/root/Boot", paths)
        self.assertIn("/root/Boot/Background", paths)

    def test_correlate_nodes_categorization(self) -> None:
        flat_nodes = [
            {"name": "root", "class_name": "Window", "node_path": "/root", "script_path": "", "groups": []},
            {"name": "AppVersion", "class_name": "Node", "node_path": "/root/AppVersion", "script_path": "res://autoload/AppVersion.gd", "groups": []},
            {"name": "Background", "class_name": "ColorRect", "node_path": "/root/Boot/Background", "script_path": "", "groups": []},
            {"name": "DynamicVfx", "class_name": "GPUParticles2D", "node_path": "/root/Boot/DynamicVfx", "script_path": "", "groups": []},
        ]
        autoloads = [{"name": "AppVersion", "script_path": "res://autoload/AppVersion.gd"}]
        mock_static_graph = {
            "scenes": [{"path": "scenes/boot/Boot.tscn"}],
            "nodes": [
                {"name": "Background", "type": "ColorRect", "scene_path": "scenes/boot/Boot.tscn"},
            ],
        }

        res = correlate_nodes(flat_nodes, autoloads, mock_static_graph)
        summary = res["summary"]
        self.assertEqual(summary["total_runtime_nodes"], 4)
        self.assertEqual(summary["autoload_singletons_count"], 1)
        self.assertEqual(summary["static_declared_nodes_count"], 1)
        self.assertEqual(summary["dynamic_runtime_only_count"], 2)
        self.assertEqual(summary["correlation_confidence_pct"], 50.0)

        by_name = {n["name"]: n["category"] for n in res["correlated_nodes"]}
        self.assertEqual(by_name["AppVersion"], "autoload_singleton")
        self.assertEqual(by_name["Background"], "static_declared_node")
        self.assertEqual(by_name["DynamicVfx"], "dynamic_runtime_only")

    def test_run_pipeline_end_to_end(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            ev_dir = root / "docs/agent-system/evidence/godot"
            ev_dir.mkdir(parents=True, exist_ok=True)

            mock_runtime = {
                "timestamp": "2026-10-21T01:00:00Z",
                "engine_version": {"string": "4.6.2-stable"},
                "autoload_singletons": [{"name": "AppVersion"}],
                "root_node": {
                    "name": "root",
                    "class_name": "Window",
                    "node_path": "/root",
                    "children": [
                        {"name": "AppVersion", "class_name": "Node", "node_path": "/root/AppVersion", "children": []},
                        {"name": "Background", "class_name": "ColorRect", "node_path": "/root/Background", "children": []},
                    ],
                },
            }
            (ev_dir / "runtime_scene_tree.json").write_text(json.dumps(mock_runtime), encoding="utf-8")

            mock_static = {
                "scenes": [{"path": "scenes/boot/Boot.tscn"}],
                "nodes": [{"name": "Background", "type": "ColorRect", "scene_path": "scenes/boot/Boot.tscn"}]
            }
            (ev_dir / "scene_graph.json").write_text(json.dumps(mock_static), encoding="utf-8")

            res = run_pipeline(workspace_root=root, force_capture=False)
            self.assertTrue(res.success)
            self.assertTrue((ev_dir / "runtime_static_correlation.json").exists())
            self.assertEqual(res.data["summary"]["total_runtime_nodes"], 3)


if __name__ == "__main__":
    unittest.main()
