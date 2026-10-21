"""Unit and integration tests for Dupery Architecture Graph Query CLI (TASK-0021)."""

from __future__ import annotations

import io
import unittest
from contextlib import redirect_stdout
from pathlib import Path
from unittest.mock import patch

from scripts.agent.query_dupery_graph import (
    REPORT_MD,
    generate_architecture_report,
    get_coverage_stats,
    get_fresh_context_recipe,
    inspect_assets,
    inspect_classes,
    inspect_scenes,
    main,
)


class TestQueryDuperyGraph(unittest.TestCase):
    """Test suite verifying unified query CLI and coverage statistics."""

    def test_coverage_stats_exact_metrics(self) -> None:
        """Verifies exact figures from all Layer A evidence artifacts."""
        stats = get_coverage_stats()

        code = stats["code_catalog"]
        self.assertEqual(code["total_classes"], 1532)
        self.assertEqual(code["tier_1_classes"], 1101)
        self.assertEqual(code["tier_2_classes"], 431)
        self.assertEqual(code["with_metadata_token"], 1532)
        self.assertEqual(code["unaccounted"], 0)

        scenes = stats["scenes_hierarchy"]
        self.assertEqual(scenes["total_scenes"], 12)
        self.assertEqual(scenes["total_game_objects"], 5279)
        self.assertEqual(scenes["total_monobehaviours"], 7365)

        vault = stats["visual_vault"]
        self.assertEqual(vault["sprites_count"], 879)
        self.assertEqual(vault["fonts_count"], 10)
        self.assertEqual(vault["textures_count"], 752)

        mat = stats["materials_and_shaders"]
        self.assertEqual(mat["materials_count"], 54)
        self.assertEqual(mat["shaders_count"], 46)
        self.assertEqual(mat["videoclips_count"], 2)
        self.assertEqual(mat["negative_findings_animations"], 0)

        fmod = stats["fmod_audio"]
        self.assertEqual(fmod["banks_count"], 6)
        self.assertEqual(fmod["sound_samples_count"], 155)
        self.assertEqual(fmod["mapped_enums"], 50)
        self.assertEqual(fmod["total_guids"], 62)

        ref = stats["reference_and_probes"]
        self.assertEqual(ref["checklist_categories"], 9)
        self.assertEqual(ref["baseline_videos"], 2)
        self.assertEqual(ref["runtime_probe_verdict"], "NO-GO")
        self.assertTrue(ref["determinism_verified"])

    def test_inspect_classes(self) -> None:
        """Verifies querying C# class metadata, tokens, and dissection cycles."""
        stats = get_coverage_stats()
        from scripts.agent.query_dupery_graph import _load_json, LEDGER_JSON
        ledger = _load_json(LEDGER_JSON)
        matches = inspect_classes("LineupController", ledger)
        self.assertGreaterEqual(len(matches), 1)
        lc = matches[0]
        self.assertEqual(lc["class_name"], "LineupController")
        self.assertEqual(lc["metadata_token"], "0x0200032D")
        self.assertEqual(lc["vong"], "V3")

    def test_inspect_scenes(self) -> None:
        """Verifies scene hierarchy query."""
        from scripts.agent.query_dupery_graph import _load_json, SCENE_SUMMARY_JSON
        summary = _load_json(SCENE_SUMMARY_JSON)
        matches = inspect_scenes("MainMenu", summary)
        self.assertEqual(len(matches), 1)
        sc = matches[0]
        self.assertEqual(sc["scene_name"], "MainMenuScene")
        self.assertEqual(sc["build_index"], 0)
        self.assertEqual(sc["game_objects"], 795)

    def test_inspect_assets(self) -> None:
        """Verifies querying cross-category assets."""
        from scripts.agent.query_dupery_graph import (
            _load_json,
            FMOD_BANKS_JSON,
            MATERIALS_CATALOG_JSON,
            SHADERS_CATALOG_JSON,
            VAULT_MANIFEST_JSON,
        )
        vault = _load_json(VAULT_MANIFEST_JSON)
        mat_cat = _load_json(MATERIALS_CATALOG_JSON)
        sh_cat = _load_json(SHADERS_CATALOG_JSON)
        fmod = _load_json(FMOD_BANKS_JSON)

        matches = inspect_assets("Wobble", vault, mat_cat, sh_cat, fmod)
        self.assertGreaterEqual(len(matches), 2)
        types = {m["type"] for m in matches}
        self.assertIn("Material", types)
        self.assertIn("Shader", types)

    def test_get_fresh_context_recipe(self) -> None:
        """Verifies DEC-19 Fresh Context Recipe assembly."""
        from scripts.agent.query_dupery_graph import _load_json, FMOD_EVENT_MAP_JSON, LEDGER_JSON
        ledger = _load_json(LEDGER_JSON)
        fmod_map = _load_json(FMOD_EVENT_MAP_JSON)

        recipe = get_fresh_context_recipe("Lineup", ledger, fmod_map)
        self.assertIn("Lineup", recipe["primary_class"])
        self.assertTrue(recipe["source_cs_path"].endswith(".cs"))
        self.assertTrue(recipe["metadata_token"].startswith("0x02"))
        self.assertEqual(recipe["golden_reference_checklist"], "REF_LINEUP_EVALUATION_1080P_60FPS")
        self.assertGreaterEqual(len(recipe["fmod_audio_events"]), 1)
        self.assertGreaterEqual(len(recipe["context_files_to_read"]), 2)

    def test_generate_architecture_report(self) -> None:
        """Verifies architecture report generation and markdown content."""
        generate_architecture_report()
        self.assertTrue(REPORT_MD.exists())
        content = REPORT_MD.read_text(encoding="utf-8")
        self.assertIn("# Dupery — Báo Cáo Kiến Trúc Toàn Diện Tầng A", content)
        self.assertIn("1,532 types", content)
        self.assertIn("Unaccounted = 0", content)
        self.assertIn("5,279 GameObjects", content)
        self.assertIn("NO-GO", content)

    def test_cli_subcommands(self) -> None:
        """Verifies CLI execution with various subcommands and format flags."""
        for cmd in [
            ["coverage-stats", "--format", "json"],
            ["coverage-stats", "--format", "toon"],
            ["inspect-class", "Lineup", "--format", "jsonl"],
            ["inspect-scene", "GameScene", "--format", "json"],
            ["inspect-asset", "Casino", "--format", "toon"],
            ["get-recipe", "Case", "--format", "json"],
        ]:
            with patch("sys.argv", ["query_dupery_graph.py"] + cmd):
                buf = io.StringIO()
                with redirect_stdout(buf):
                    ret = main()
                self.assertEqual(ret, 0)
                self.assertGreater(len(buf.getvalue()), 0)


if __name__ == "__main__":
    unittest.main()
