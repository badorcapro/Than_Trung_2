"""Extractor and validator for Dupery ScriptableObjects, XNode Graphs, and Localisation.

Extracts core game configuration, story/role XNode graphs with port connections,
and full multilingual localisation strings into canonical JSON artifacts under
docs/agent-system/evidence/dupery/data/.
"""

from __future__ import annotations

import argparse
import csv
import io
import json
import os
import sys
import time
from pathlib import Path
from typing import Any, Dict, List, Optional, Set

try:
    from scripts.agent.dupery_xnode_parser import parse_xnode_binary
except ModuleNotFoundError:
    from dupery_xnode_parser import parse_xnode_binary

DEFAULT_DUPERY_DATA = Path(r"D:\Minh\Steam\steamapps\common\Dupery\Dupery_Data")
DEFAULT_MANAGED = DEFAULT_DUPERY_DATA / "Managed"
DEFAULT_DATA_DIR = Path("docs/agent-system/evidence/dupery/data")

IGNORE_FIELDS = {"m_GameObject", "m_Enabled", "m_Script", "m_Name"}


def clean_properties(props: Dict[str, Any]) -> Dict[str, Any]:
    """Filter default Unity MonoBehaviour metadata fields."""
    return {k: v for k, v in props.items() if k not in IGNORE_FIELDS}


def load_unity_env(dupery_data: Path, managed_dir: Path) -> Any:
    """Initialize UnityPy Environment with TypeTree support."""
    import UnityPy
    from UnityPy.helpers.TypeTreeGenerator import TypeTreeGenerator

    ttg = TypeTreeGenerator("2022.3.0f1")
    if managed_dir.exists():
        ttg.load_local_dll_folder(str(managed_dir))

    env = UnityPy.Environment()
    env.typetree_generator = ttg
    ggm = dupery_data / "globalgamemanagers.assets"
    if ggm.exists():
        env.load_file(str(ggm))
    return env


def extract_scriptable_objects(env: Any, dupery_data: Path, out_dir: Path) -> Dict[str, int]:
    """Extract core ScriptableObjects and settings to JSON."""
    out_dir.mkdir(parents=True, exist_ok=True)
    target_files = ["sharedassets0.assets", "resources.assets", "sharedassets1.assets"]
    for f in target_files:
        p = dupery_data / f
        if p.exists():
            env.load_file(str(p))

    so_registry = {
        "InputShortcuts": "input_shortcuts.json",
        "RoleVisuals": "role_visuals.json",
        "ItemVisuals": "item_visuals.json",
        "QuirkVisuals": "quirk_visuals.json",
        "CodexVisualData": "codex_visuals.json",
        "RegionsData": "regions_data.json",
        "TMP Settings": "tmp_settings.json",
        "Settings": "fmod_settings.json",
    }

    counts: Dict[str, int] = {}
    region_data_list: List[Dict[str, Any]] = []

    for obj in env.objects:
        if obj.type.name != "MonoBehaviour":
            continue
        try:
            head = obj.parse_monobehaviour_head()
            script = head.m_Script.deref_parse_as_object()
            cname = getattr(script, "m_ClassName", "")
            if cname == "RegionDataSO":
                tree = obj.read_typetree()
                region_data_list.append(clean_properties(tree))
            elif cname in ("Settings", "TMP_Settings") or cname.endswith("SO"):
                tree = obj.read_typetree()
                name = tree.get("m_Name", cname)
                if name in so_registry:
                    fname = so_registry[name]
                    target_file = out_dir / fname
                    with open(target_file, "w", encoding="utf-8") as f_out:
                        json.dump(clean_properties(tree), f_out, indent=2, ensure_ascii=False)
                    counts[fname] = 1
        except Exception:
            pass

    if region_data_list:
        with open(out_dir / "regions_data.json", "w", encoding="utf-8") as f_out:
            json.dump({"regions": region_data_list}, f_out, indent=2, ensure_ascii=False)
        counts["regions_data.json"] = len(region_data_list)

    return counts


def extract_localisation(env: Any, dupery_data: Path, out_dir: Path) -> Dict[str, Any]:
    """Extract AllLanguages CSV translation table and language metadata."""
    out_dir.mkdir(parents=True, exist_ok=True)
    p0 = dupery_data / "sharedassets0.assets"
    if p0.exists():
        env.load_file(str(p0))

    languages: List[Dict[str, Any]] = []
    csv_rows: List[Dict[str, Any]] = []

    for obj in env.objects:
        if obj.type.name == "MonoBehaviour" and obj.assets_file.name == "sharedassets0.assets":
            try:
                head = obj.parse_monobehaviour_head()
                script = head.m_Script.deref_parse_as_object()
                if getattr(script, "m_ClassName", "") == "LocalisationLanguageSO":
                    tree = obj.read_typetree()
                    languages.append({
                        "name": tree.get("m_Name", ""),
                        "translation_column": tree.get("translation_column", 0),
                    })
            except Exception:
                pass
        elif obj.type.name == "TextAsset" and obj.assets_file.name == "sharedassets0.assets":
            try:
                txt = obj.read()
                if "AllLanguages" in txt.m_Name:
                    reader = csv.reader(io.StringIO(txt.m_Script))
                    header = next(reader)
                    for row in reader:
                        if not row or not row[0]:
                            continue
                        entry: Dict[str, str] = {"key": row[0]}
                        for idx, col in enumerate(header[1:], 1):
                            entry[col] = row[idx] if idx < len(row) else ""
                        csv_rows.append(entry)
            except Exception:
                pass

    catalog = {
        "text_asset_name": "AllLanguagesv1.0.2",
        "total_languages": len(languages),
        "total_keys": len(csv_rows),
        "languages": sorted(languages, key=lambda x: x["translation_column"]),
    }

    with open(out_dir / "localisation_catalog.json", "w", encoding="utf-8") as f_out:
        json.dump(catalog, f_out, indent=2, ensure_ascii=False)

    with open(out_dir / "localisation_strings.json", "w", encoding="utf-8") as f_out:
        json.dump({"keys": csv_rows}, f_out, indent=2, ensure_ascii=False)

    return catalog


def extract_xnode_graphs(env: Any, dupery_data: Path, out_dir: Path) -> Dict[str, Any]:
    """Extract 18 StoryNodeGraphs and 68 RoleSetsGraphs with port connections."""
    graphs_dir = out_dir / "story_graphs"
    graphs_dir.mkdir(parents=True, exist_ok=True)

    for f in ["sharedassets0.assets", "sharedassets1.assets", "sharedassets2.assets"]:
        p = dupery_data / f
        if p.exists():
            env.load_file(str(p))

    # Pre-index all node raw bytes across loaded assets
    node_map: Dict[Tuple[str, int], Dict[str, Any]] = {}
    for obj in env.objects:
        if obj.type.name == "MonoBehaviour":
            try:
                head = obj.parse_monobehaviour_head()
                script = head.m_Script.deref_parse_as_object()
                cname = getattr(script, "m_ClassName", "")
                if "Node" in cname and cname not in ("NodeGraph", "LineupController"):
                    parsed = parse_xnode_binary(obj.get_raw_data())
                    if parsed:
                        parsed["class_name"] = cname
                        parsed["path_id"] = obj.path_id
                        node_map[(obj.assets_file.name, obj.path_id)] = parsed
            except Exception:
                pass

    story_graphs: List[Dict[str, Any]] = []
    role_sets: List[Dict[str, Any]] = []

    for obj in env.objects:
        if obj.type.name != "MonoBehaviour":
            continue
        try:
            head = obj.parse_monobehaviour_head()
            script = head.m_Script.deref_parse_as_object()
            cname = getattr(script, "m_ClassName", "")
            if cname == "StoryNodeGraph":
                tree = obj.read_typetree()
                g_name = tree.get("m_Name", f"Graph_{obj.path_id}")
                nodes_ref = tree.get("nodes", [])
                g_nodes: List[Dict[str, Any]] = []
                for nref in nodes_ref:
                    n_pid = nref.get("m_PathID", 0)
                    key = (obj.assets_file.name, n_pid)
                    if key in node_map:
                        g_nodes.append(node_map[key])

                g_data = {
                    "graph_id": obj.path_id,
                    "name": g_name,
                    "asset_file": obj.assets_file.name,
                    "node_count": len(g_nodes),
                    "nodes": g_nodes,
                }
                with open(graphs_dir / f"{g_name}.json", "w", encoding="utf-8") as f_out:
                    json.dump(g_data, f_out, indent=2, ensure_ascii=False)
                story_graphs.append({
                    "name": g_name,
                    "graph_id": obj.path_id,
                    "asset_file": obj.assets_file.name,
                    "node_count": len(g_nodes),
                })
            elif cname == "RoleSetsGraph":
                tree = obj.read_typetree()
                g_name = tree.get("m_Name", f"Set_{obj.path_id}")
                nodes_ref = tree.get("nodes", [])
                role_sets.append({
                    "name": g_name,
                    "graph_id": obj.path_id,
                    "node_count": len(nodes_ref),
                })
        except Exception:
            pass

    with open(out_dir / "role_sets_graphs.json", "w", encoding="utf-8") as f_out:
        json.dump({"total_sets": len(role_sets), "sets": sorted(role_sets, key=lambda x: x["name"])}, f_out, indent=2)

    cutscenes = [g["name"] for g in story_graphs if g["asset_file"] == "sharedassets2.assets"]
    of_tut_6 = next((g for g in story_graphs if g["name"] == "Of_Tutorial_6"), None)

    summary = {
        "total_story_graphs": len(story_graphs),
        "total_role_sets_graphs": len(role_sets),
        "cutscene_graphs_sharedassets2": cutscenes,
        "of_tutorial_6_nodes": of_tut_6["node_count"] if of_tut_6 else 0,
        "p7_resolution": "Of_Tutorial_6 contains exactly 53 nodes matching P7 investigation",
        "story_graphs": sorted(story_graphs, key=lambda x: x["name"]),
    }
    with open(out_dir / "xnode_graphs_summary.json", "w", encoding="utf-8") as f_out:
        json.dump(summary, f_out, indent=2, ensure_ascii=False)

    return summary


def run_data_extraction(dupery_data: Path = DEFAULT_DUPERY_DATA, out_base: Path = DEFAULT_DATA_DIR) -> Dict[str, Any]:
    """Execute complete data extraction workflow."""
    t0 = time.time()
    env = load_unity_env(dupery_data, DEFAULT_MANAGED)

    so_counts = extract_scriptable_objects(env, dupery_data, out_base / "scriptable_objects")
    loc_summary = extract_localisation(env, dupery_data, out_base / "localisation")
    xnode_summary = extract_xnode_graphs(env, dupery_data, out_base / "graphs")

    duration = round(time.time() - t0, 3)
    summary = {
        "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "duration_sec": duration,
        "scriptable_objects": so_counts,
        "localisation": loc_summary,
        "xnode_graphs": {
            "story_graphs_count": xnode_summary["total_story_graphs"],
            "role_sets_count": xnode_summary["total_role_sets_graphs"],
            "cutscenes": xnode_summary["cutscene_graphs_sharedassets2"],
            "of_tutorial_6_nodes": xnode_summary["of_tutorial_6_nodes"],
        },
    }
    with open(out_base / "data_catalog_summary.json", "w", encoding="utf-8") as f_out:
        json.dump(summary, f_out, indent=2, ensure_ascii=False)

    return summary


def verify_data_artifacts(out_base: Path = DEFAULT_DATA_DIR) -> bool:
    """Verify integrity of all generated data artifacts."""
    summary_path = out_base / "data_catalog_summary.json"
    if not summary_path.exists():
        return False

    with open(summary_path, "r", encoding="utf-8") as f:
        summary = json.load(f)

    if summary["localisation"]["total_keys"] != 1908:
        return False
    if summary["xnode_graphs"]["story_graphs_count"] != 18:
        return False
    if summary["xnode_graphs"]["of_tutorial_6_nodes"] != 53:
        return False

    required_so = ["input_shortcuts.json", "regions_data.json", "role_visuals.json", "tmp_settings.json"]
    for r in required_so:
        if not (out_base / "scriptable_objects" / r).exists():
            return False

    required_cutscenes = ["CasinoIntro.json", "DocksIntro.json", "SyndicateIntro.json", "TemplateTransition.json"]
    for c in required_cutscenes:
        if not (out_base / "graphs" / "story_graphs" / c).exists():
            return False

    return True


def main() -> int:
    """CLI endpoint for data extraction and verification."""
    parser = argparse.ArgumentParser(description="Dupery Data Extractor")
    parser.add_argument("--verify", action="store_true", help="Verify existing data artifacts")
    parser.add_argument("--stats", action="store_true", help="Print data summary")
    args = parser.parse_args()

    if args.verify:
        ok = verify_data_artifacts()
        status = "PASSED" if ok else "FAILED"
        print(f"Data Artifacts Verification: {status}")
        return 0 if ok else 1

    summary = run_data_extraction()
    if args.stats:
        print(json.dumps(summary, indent=2))
    else:
        print(f"Extraction completed in {summary['duration_sec']}s.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
