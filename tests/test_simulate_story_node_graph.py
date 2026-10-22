"""Unit tests for story node graph execution simulator and validator."""

import os
import unittest
from scripts.agent.simulate_story_node_graph import (
    StoryNode,
    StoryGraph,
    parse_story_graph,
    traverse_story_graph,
    validate_story_graph,
    run_verification,
    audit_v2_ledger,
)


class TestSimulateStoryNodeGraph(unittest.TestCase):
    """Test suite for XNode story graph simulation and traversal."""

    def test_parse_and_validate_mock_graph(self):
        """Verify graph parsing and validation of well-formed graph."""
        data = {
            "name": "TestGraph",
            "nodes": [
                {
                    "path_id": 1,
                    "name": "Story Start",
                    "ports": [{"field_name": "exit", "direction": "output", "connections": [{"target_node": 2}]}],
                },
                {
                    "path_id": 2,
                    "name": "Story Dialogue",
                    "ports": [{"field_name": "exit", "direction": "output", "connections": [{"target_node": 3}]}],
                },
                {
                    "path_id": 3,
                    "name": "Story End",
                    "ports": [],
                },
            ],
        }
        graph = parse_story_graph(data)
        self.assertEqual(graph.graph_id, "TestGraph")
        self.assertEqual(len(graph.nodes), 3)

        valid, issues = validate_story_graph(graph)
        self.assertTrue(valid)
        self.assertEqual(len(issues), 0)

        trace = traverse_story_graph(graph)
        self.assertEqual(len(trace), 3)
        self.assertEqual(trace[0]["name"], "Story Start")
        self.assertEqual(trace[1]["name"], "Story Dialogue")
        self.assertEqual(trace[2]["name"], "Story End")

    def test_missing_start_node(self):
        """Verify validation failure when start node is missing."""
        data = {
            "name": "NoStartGraph",
            "nodes": [{"path_id": 10, "name": "Story Dialogue", "ports": []}],
        }
        graph = parse_story_graph(data)
        valid, issues = validate_story_graph(graph)
        self.assertFalse(valid)
        self.assertIn("Missing StoryStartNode", issues)

        with self.assertRaises(ValueError):
            traverse_story_graph(graph)

    def test_cycle_detection(self):
        """Verify cycle detection safeguard stops infinite looping."""
        data = {
            "name": "LoopGraph",
            "nodes": [
                {
                    "path_id": 1,
                    "name": "Story Start",
                    "ports": [{"field_name": "exit", "direction": "output", "connections": [{"target_node": 2}]}],
                },
                {
                    "path_id": 2,
                    "name": "Story Dialogue A",
                    "ports": [{"field_name": "exit", "direction": "output", "connections": [{"target_node": 3}]}],
                },
                {
                    "path_id": 3,
                    "name": "Story Dialogue B",
                    "ports": [{"field_name": "exit", "direction": "output", "connections": [{"target_node": 2}]}],
                },
            ],
        }
        graph = parse_story_graph(data)
        trace = traverse_story_graph(graph)
        self.assertIn("warning", trace[-1])

    def test_run_verification_on_real_graphs(self):
        """Verify real cutscene and tutorial graphs from TASK-0015."""
        self.assertTrue(run_verification())

    def test_audit_v2_ledger(self):
        """Verify ledger status: V1 is 95/95 L3 and V2 is 130/130 L3."""
        audit = audit_v2_ledger()
        self.assertEqual(audit["v1_total"], 95)
        self.assertEqual(audit["v1_l3"], 95)
        self.assertEqual(audit["v2_total"], 130)
        self.assertEqual(audit["v2_l3"], 130)
        self.assertEqual(audit["v2_pending"], 0)


if __name__ == "__main__":
    unittest.main()
