"""
Dupery Scene Inspector & Hierarchy Graph Builder (TASK-0014).
Extracts 12 complete scene GameObject hierarchy trees (level0..level11), RectTransforms,
Cameras, Canvases, and filtered custom MonoBehaviour properties into canonical JSON.
"""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import sys
import time
from typing import Any, Dict, List, Optional, Tuple

ROOT_DIR = Path(__file__).resolve().parents[2]
DEFAULT_DUPERY_DATA = Path("D:/Minh/Steam/steamapps/common/Dupery/Dupery_Data")
DEFAULT_MANAGED = DEFAULT_DUPERY_DATA / "Managed"
DEFAULT_SUMMARY_IN = ROOT_DIR / "docs/agent-system/evidence/dupery/project_settings/project_settings_summary.json"
DEFAULT_OUT_DIR = ROOT_DIR / "docs/agent-system/evidence/dupery/scenes"

DEFAULT_MB_FIELDS = {"m_GameObject", "m_Enabled", "m_Script", "m_Name"}


def filter_custom_properties(tree: Dict[str, Any]) -> Dict[str, Any]:
    """Return dictionary with MonoBehaviour default header fields stripped."""
    return {k: v for k, v in tree.items() if k not in DEFAULT_MB_FIELDS}


def extract_node_recursive(
    go_pid: int,
    gos: Dict[int, Dict[str, Any]],
    transforms: Dict[int, Dict[str, Any]],
    children_map: Dict[int, List[int]],
    components_by_go: Dict[int, List[Dict[str, Any]]],
) -> Dict[str, Any]:
    """Recursively build GameObject hierarchy node with components and children."""
    go = gos.get(go_pid, {})
    trans = transforms.get(go_pid, {})
    is_rect = "m_AnchorMin" in trans

    trans_data: Dict[str, Any] = {
        "is_rect_transform": is_rect,
        "local_position": trans.get("m_LocalPosition", {}),
        "local_scale": trans.get("m_LocalScale", {}),
        "local_rotation": trans.get("m_LocalRotation", {}),
    }
    if is_rect:
        trans_data.update({
            "anchor_min": trans.get("m_AnchorMin", {}),
            "anchor_max": trans.get("m_AnchorMax", {}),
            "pivot": trans.get("m_Pivot", {}),
            "size_delta": trans.get("m_SizeDelta", {}),
            "anchored_position": trans.get("m_AnchoredPosition", {}),
        })

    child_pids = children_map.get(go_pid, [])
    children_nodes = [
        extract_node_recursive(c_pid, gos, transforms, children_map, components_by_go)
        for c_pid in child_pids
        if c_pid in gos
    ]

    return {
        "name": go.get("m_Name", "unnamed"),
        "path_id": go_pid,
        "is_active": go.get("m_IsActive", True),
        "layer": go.get("m_Layer", 0),
        "tag": go.get("m_Tag", 0),
        "transform": trans_data,
        "components": components_by_go.get(go_pid, []),
        "children": children_nodes,
    }


def inspect_scene_file(
    env: Any,
    fname: str,
    scene_name: str,
    build_index: int,
) -> Dict[str, Any]:
    """Parse single scene level file and return structured hierarchy and components."""
    gos: Dict[int, Dict[str, Any]] = {}
    transforms: Dict[int, Dict[str, Any]] = {}
    trans_pid_to_go_pid: Dict[int, int] = {}
    go_pid_to_trans_tree: Dict[int, Dict[str, Any]] = {}
    components_by_go: Dict[int, List[Dict[str, Any]]] = {}

    for obj in env.objects:
        if obj.assets_file.name != fname:
            continue
        tname = obj.type.name
        pid = obj.path_id
        if tname == "GameObject":
            tree = obj.read_typetree()
            gos[pid] = tree
        elif tname in ("RectTransform", "Transform"):
            tree = obj.read_typetree()
            transforms[pid] = tree
            go_pid = tree.get("m_GameObject", {}).get("m_PathID", 0)
            if go_pid:
                trans_pid_to_go_pid[pid] = go_pid
                go_pid_to_trans_tree[go_pid] = tree
        elif tname == "Camera":
            tree = obj.read_typetree()
            go_pid = tree.get("m_GameObject", {}).get("m_PathID", 0)
            components_by_go.setdefault(go_pid, []).append({
                "type": "Camera",
                "path_id": pid,
                "orthographic": tree.get("orthographic", True),
                "ortho_size": tree.get("orthographic size", 5.0),
                "clear_flags": tree.get("m_ClearFlags", 1),
                "background_color": tree.get("m_BackGroundColor", {}),
                "culling_mask": tree.get("m_CullingMask", {}),
            })
        elif tname == "Canvas":
            tree = obj.read_typetree()
            go_pid = tree.get("m_GameObject", {}).get("m_PathID", 0)
            components_by_go.setdefault(go_pid, []).append({
                "type": "Canvas",
                "path_id": pid,
                "render_mode": tree.get("m_RenderMode", 0),
                "sorting_order": tree.get("m_SortingOrder", 0),
                "plane_distance": tree.get("m_PlaneDistance", 100.0),
            })
        elif tname == "MonoBehaviour":
            try:
                tree = obj.read_typetree(check_read=True)
                head = obj.parse_monobehaviour_head()
                script = head.m_Script.deref_parse_as_object()
                cname = getattr(script, "m_ClassName", "unknown")
                ns = getattr(script, "m_Namespace", "") or ""
                fullname = f"{ns}.{cname}" if ns else cname
                go_pid = tree.get("m_GameObject", {}).get("m_PathID", 0)
                components_by_go.setdefault(go_pid, []).append({
                    "type": "MonoBehaviour",
                    "path_id": pid,
                    "class_name": fullname,
                    "assembly": getattr(script, "m_AssemblyName", ""),
                    "custom_properties": filter_custom_properties(tree),
                })
            except Exception:
                pass

    # Build parent -> children map
    children_map: Dict[int, List[int]] = {}
    root_go_pids: List[int] = []

    for go_pid, t_tree in go_pid_to_trans_tree.items():
        father_trans_pid = t_tree.get("m_Father", {}).get("m_PathID", 0)
        if father_trans_pid == 0 or father_trans_pid not in trans_pid_to_go_pid:
            root_go_pids.append(go_pid)
        else:
            parent_go_pid = trans_pid_to_go_pid[father_trans_pid]
            children_map.setdefault(parent_go_pid, []).append(go_pid)

    root_nodes = [
        extract_node_recursive(r_pid, gos, go_pid_to_trans_tree, children_map, components_by_go)
        for r_pid in root_go_pids
        if r_pid in gos
    ]

    total_mb_count = sum(
        1 for comps in components_by_go.values() for c in comps if c.get("type") == "MonoBehaviour"
    )

    return {
        "scene_name": scene_name,
        "build_index": build_index,
        "source_file": fname,
        "total_game_objects": len(gos),
        "total_root_objects": len(root_nodes),
        "total_monobehaviours": total_mb_count,
        "root_game_objects": root_nodes,
    }


def run_scene_inspection(
    dupery_data: Path = DEFAULT_DUPERY_DATA,
    managed_dir: Path = DEFAULT_MANAGED,
    summary_in: Path = DEFAULT_SUMMARY_IN,
    out_dir: Path = DEFAULT_OUT_DIR,
) -> Dict[str, Any]:
    """Execute scene inspection across all 12 scenes and write artifacts."""
    import UnityPy
    from UnityPy.helpers.TypeTreeGenerator import TypeTreeGenerator

    if not summary_in.exists():
        raise FileNotFoundError(f"Project settings summary not found: {summary_in}")

    summary_data = json.loads(summary_in.read_text(encoding="utf-8"))
    scenes_meta = summary_data.get("scenes", [])
    if not scenes_meta:
        raise ValueError("No scenes found in project settings summary")

    out_dir.mkdir(parents=True, exist_ok=True)
    ttg = TypeTreeGenerator("2022.3.0f1")
    if managed_dir.exists():
        ttg.load_local_dll_folder(str(managed_dir))

    env = UnityPy.Environment()
    env.typetree_generator = ttg
    ggm_path = dupery_data / "globalgamemanagers.assets"
    if ggm_path.exists():
        env.load_file(str(ggm_path))

    scenes_catalog = []
    t_start = time.time()

    for item in scenes_meta:
        b_idx = item["build_index"]
        fname = item["level_file"]
        s_name = item["scene_name"]
        f_path = dupery_data / fname
        if not f_path.exists():
            continue

        env.load_file(str(f_path))
        scene_doc = inspect_scene_file(env, fname, s_name, b_idx)
        out_file = out_dir / f"{s_name}.json"
        out_file.write_text(json.dumps(scene_doc, indent=2), encoding="utf-8")

        scenes_catalog.append({
            "build_index": b_idx,
            "scene_name": s_name,
            "level_file": fname,
            "scene_path": item.get("scene_path", ""),
            "json_artifact": f"{s_name}.json",
            "total_game_objects": scene_doc["total_game_objects"],
            "total_root_objects": scene_doc["total_root_objects"],
            "total_monobehaviours": scene_doc["total_monobehaviours"],
        })

    summary_doc = {
        "schema_version": "1.0",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "total_scenes_extracted": len(scenes_catalog),
        "total_game_objects_all_scenes": sum(s["total_game_objects"] for s in scenes_catalog),
        "total_monobehaviours_all_scenes": sum(s["total_monobehaviours"] for s in scenes_catalog),
        "duration_seconds": round(time.time() - t_start, 3),
        "scenes": scenes_catalog,
    }

    catalog_path = out_dir / "scene_catalog_summary.json"
    catalog_path.write_text(json.dumps(summary_doc, indent=2), encoding="utf-8")
    return summary_doc


def verify_scene_artifacts(out_dir: Path = DEFAULT_OUT_DIR) -> Tuple[bool, List[str]]:
    """Verify that all 12 scene files and catalog summary exist and are valid."""
    errors: List[str] = []
    if not out_dir.exists():
        return False, [f"Scenes directory missing: {out_dir}"]

    catalog_path = out_dir / "scene_catalog_summary.json"
    if not catalog_path.exists():
        return False, ["scene_catalog_summary.json missing"]

    try:
        catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
        scenes = catalog.get("scenes", [])
        if len(scenes) != 12:
            errors.append(f"Expected 12 scenes in catalog summary, found {len(scenes)}")
    except Exception as exc:
        return False, [f"Invalid scene_catalog_summary.json: {exc}"]

    for item in scenes:
        art_name = item.get("json_artifact", "")
        art_path = out_dir / art_name
        if not art_path.exists():
            errors.append(f"Scene JSON missing: {art_name}")
            continue
        try:
            doc = json.loads(art_path.read_text(encoding="utf-8"))
            if doc.get("total_game_objects", 0) <= 0:
                errors.append(f"Scene has 0 GameObjects: {art_name}")
            if not doc.get("root_game_objects"):
                errors.append(f"Scene has empty root_game_objects: {art_name}")
        except Exception as exc:
            errors.append(f"Invalid JSON in {art_name}: {exc}")

    return len(errors) == 0, errors


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    """Parse CLI arguments."""
    parser = argparse.ArgumentParser(description="Dupery Scene Hierarchy & Inspector Extractor.")
    parser.add_argument("--dupery-data", type=Path, default=DEFAULT_DUPERY_DATA, help="Path to Dupery_Data")
    parser.add_argument("--managed-dir", type=Path, default=DEFAULT_MANAGED, help="Path to Managed directory")
    parser.add_argument("--summary-in", type=Path, default=DEFAULT_SUMMARY_IN, help="Path to project_settings_summary.json")
    parser.add_argument("--out-dir", type=Path, default=DEFAULT_OUT_DIR, help="Path to scenes output directory")
    parser.add_argument("--verify", action="store_true", help="Verify scene JSON artifacts")
    parser.add_argument("--stats", action="store_true", help="Extract and print summary statistics")
    return parser.parse_args(argv)


def main(argv: Optional[List[str]] = None) -> int:
    """CLI entry point."""
    args = parse_args(argv)
    if args.verify:
        passed, errors = verify_scene_artifacts(args.out_dir)
        if passed:
            print("OK: Scene inspection verified. All 12 scenes and catalog summary present and valid.")
            return 0
        print("FAIL: Scene inspection verification failed:", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1

    print(f"Extracting 12 scenes from {args.dupery_data}...")
    summary = run_scene_inspection(args.dupery_data, args.managed_dir, args.summary_in, args.out_dir)
    print(f"Extracted {summary['total_scenes_extracted']} scenes successfully in {summary['duration_seconds']}s.")
    print(f"Total GameObjects across all scenes: {summary['total_game_objects_all_scenes']}")
    print(f"Total MonoBehaviours across all scenes: {summary['total_monobehaviours_all_scenes']}")
    print(f"Output directory: {args.out_dir}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
