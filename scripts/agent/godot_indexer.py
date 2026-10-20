"""
Godot Project Indexer & Layer A Catalog Extractor (scripts/agent/godot_indexer.py).
Scans Than_Tham_Nua_Voi_Godot/ to inventory all files, categorize by architecture layer,
compute SHA-256 digests, analyze GDScript LOC, and rank God-files into project_index.json.
Supports DEC-15 Layer 3 TOON/JSONL/JSON Compact context projections.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any, Dict, List

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.models import (
    FixableBy,
    Issue,
    ResultEnvelope,
    Severity,
    compute_raw_sha256,
    write_canonical_json,
)
from scripts.agent.toon_projector import format_projection

DEFAULT_GODOT_ROOT = ROOT_DIR / "Than_Tham_Nua_Voi_Godot"
DEFAULT_OUTPUT_JSON = ROOT_DIR / "docs/agent-system/evidence/godot/project_index.json"

_CLASS_NAME_RE = re.compile(r"^\s*class_name\s+([A-Za-z0-9_]+)")
_EXTENDS_RE = re.compile(r"^\s*extends\s+([A-Za-z0-9_.]+)")

_LAYER_PREFIXES = (
    ("scripts/domain/", "domain"),
    ("scripts/application/", "application"),
    ("scripts/infrastructure/", "infrastructure"),
    ("scripts/presentation/", "presentation"),
    ("scripts/tools/", "tools"),
    ("scenes/", "scenes"),
    ("assets/", "assets"),
)

_CATEGORY_MAP = {
    ".gd": "gdscript",
    ".tscn": "scene",
    ".tres": "resource",
    ".import": "import_meta",
    ".uid": "uid_meta",
    ".png": "texture",
    ".jpg": "texture",
    ".jpeg": "texture",
    ".svg": "texture",
    ".webp": "texture",
    ".wav": "audio",
    ".ogg": "audio",
    ".mp3": "audio",
    ".ttf": "font",
    ".otf": "font",
    ".woff": "font",
    ".woff2": "font",
    ".json": "data",
    ".csv": "data",
    ".txt": "data",
    ".cfg": "data",
}


def classify_layer(rel_path: str) -> str:
    norm = rel_path.replace("\\", "/").lower()
    for prefix, layer in _LAYER_PREFIXES:
        if norm.startswith(prefix):
            return layer
    return "root" if "/" not in norm else "other"


def classify_category(ext: str) -> str:
    return _CATEGORY_MAP.get(ext.lower(), "other")


def hash_file_sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(256 * 1024):
            h.update(chunk)
    return h.hexdigest()


def analyze_gdscript(path: Path) -> Dict[str, Any]:
    text = path.read_text(encoding="utf-8", errors="ignore")
    lines = text.splitlines()
    blank_lines = 0
    comment_lines = 0
    code_lines = 0
    class_name = None
    extends_name = None

    for line in lines:
        s = line.strip()
        if not s:
            blank_lines += 1
        elif s.startswith("#"):
            comment_lines += 1
        else:
            code_lines += 1
            if class_name is None and (m_cn := _CLASS_NAME_RE.match(line)):
                class_name = m_cn.group(1)
            if extends_name is None and (m_ex := _EXTENDS_RE.match(line)):
                extends_name = m_ex.group(1)

    return {
        "total_lines": len(lines),
        "code_lines": code_lines,
        "comment_lines": comment_lines,
        "blank_lines": blank_lines,
        "class_name": class_name,
        "extends": extends_name,
    }


def index_godot_project(
    godot_root: Path = DEFAULT_GODOT_ROOT,
    output_json: Path = DEFAULT_OUTPUT_JSON,
) -> Dict[str, Any]:
    if not godot_root.exists():
        raise FileNotFoundError(f"Godot root not found: {godot_root}")

    files_list: List[Dict[str, Any]] = []
    gdscript_files_list: List[Dict[str, Any]] = []
    files_by_category: Dict[str, int] = {}
    files_by_layer: Dict[str, int] = {}
    files_by_extension: Dict[str, int] = {}

    gd_total_lines = 0
    gd_code_lines = 0
    gd_comment_lines = 0
    gd_blank_lines = 0
    gd_loc_by_layer: Dict[str, int] = {}
    god_files_candidates: List[Dict[str, Any]] = []

    for p in sorted(godot_root.rglob("*")):
        if not p.is_file() or ".godot" in p.parts:
            continue

        rel_path = p.relative_to(godot_root).as_posix()
        ext = p.suffix.lower() or "no_ext"
        category = classify_category(ext)
        layer = classify_layer(rel_path)

        files_by_category[category] = files_by_category.get(category, 0) + 1
        files_by_layer[layer] = files_by_layer.get(layer, 0) + 1
        files_by_extension[ext] = files_by_extension.get(ext, 0) + 1

        files_list.append({
            "path": rel_path,
            "extension": ext,
            "category": category,
            "layer": layer,
            "size_bytes": p.stat().st_size,
            "sha256": hash_file_sha256(p),
        })

        if category == "gdscript":
            gd_info = analyze_gdscript(p)
            loc = gd_info["total_lines"]
            gd_total_lines += loc
            gd_code_lines += gd_info["code_lines"]
            gd_comment_lines += gd_info["comment_lines"]
            gd_blank_lines += gd_info["blank_lines"]
            gd_loc_by_layer[layer] = gd_loc_by_layer.get(layer, 0) + loc

            gdscript_files_list.append({
                "path": rel_path,
                "layer": layer,
                "extends": gd_info["extends"] or "Object",
                "total_lines": loc,
                "code_lines": gd_info["code_lines"],
                "comment_lines": gd_info["comment_lines"],
                "blank_lines": gd_info["blank_lines"],
            })

            if loc >= 1000:
                god_files_candidates.append({
                    "path": rel_path,
                    "rank": 0,
                    "layer": layer,
                    "extends": gd_info["extends"] or "Object",
                    "total_lines": loc,
                    "code_lines": gd_info["code_lines"],
                    "comment_lines": gd_info["comment_lines"],
                    "blank_lines": gd_info["blank_lines"],
                })

    god_files_candidates.sort(key=lambda x: x["total_lines"], reverse=True)
    for rank, gf in enumerate(god_files_candidates, 1):
        gf["rank"] = rank

    summary = {
        "schema_version": "1.1",
        "project_name": "Than_Tham_Nua_Voi_Godot",
        "godot_version": "4.6.2-stable",
        "renderer": "GL Compatibility",
        "root_directory": str(godot_root.relative_to(ROOT_DIR)).replace("\\", "/"),
        "total_files_indexed": len(files_list),
        "files_by_category": files_by_category,
        "files_by_layer": files_by_layer,
        "files_by_extension": files_by_extension,
        "gdscript_metrics": {
            "total_scripts": files_by_category.get("gdscript", 0),
            "total_lines": gd_total_lines,
            "code_lines": gd_code_lines,
            "comment_lines": gd_comment_lines,
            "blank_lines": gd_blank_lines,
            "loc_by_layer": gd_loc_by_layer,
        },
        "god_files_count": len(god_files_candidates),
        "god_files_threshold_loc": 1000,
        "god_files_ranked": god_files_candidates,
        "gdscript_files": gdscript_files_list,
        "files": files_list,
    }

    write_canonical_json(output_json, summary)
    return summary


def verify_godot_index(
    workspace_root: Path = ROOT_DIR,
    output_json: Path = DEFAULT_OUTPUT_JSON,
) -> ResultEnvelope:
    issues: list[Issue] = []
    rel_out = output_json.relative_to(workspace_root).as_posix()
    if not output_json.exists():
        issues.append(Issue(
            code="ERR_INDEX_MISSING", severity=Severity.ERROR,
            message=f"project_index.json not found at '{rel_out}'.",
            location=rel_out, fixable_by=FixableBy.AI,
        ))
        return ResultEnvelope(success=False, tool="godot_indexer", issues=issues)

    try:
        data = json.loads(output_json.read_text(encoding="utf-8"))
    except Exception as exc:
        issues.append(Issue(
            code="ERR_INDEX_INVALID_JSON", severity=Severity.ERROR,
            message=f"project_index.json is invalid JSON: {exc}",
            location=rel_out, fixable_by=FixableBy.AI,
        ))
        return ResultEnvelope(success=False, tool="godot_indexer", issues=issues)

    total_files = data.get("total_files_indexed", 0)
    if total_files < 1500:
        issues.append(Issue(
            code="ERR_INDEX_TOO_FEW_FILES", severity=Severity.ERROR,
            message=f"Expected >= 1,500 indexed files, observed {total_files}.",
            location=rel_out, fixable_by=FixableBy.AI,
        ))

    gd_scripts = data.get("gdscript_metrics", {}).get("total_scripts", 0)
    if gd_scripts < 250:
        issues.append(Issue(
            code="ERR_INDEX_TOO_FEW_SCRIPTS", severity=Severity.ERROR,
            message=f"Expected >= 250 GDScript files, observed {gd_scripts}.",
            location=rel_out, fixable_by=FixableBy.AI,
        ))

    god_files = data.get("god_files_ranked", [])
    if len(god_files) < 5:
        issues.append(Issue(
            code="ERR_INDEX_TOO_FEW_GOD_FILES", severity=Severity.ERROR,
            message=f"Expected >= 5 God-files (> 1,000 LOC), observed {len(god_files)}.",
            location=rel_out, fixable_by=FixableBy.AI,
        ))

    return ResultEnvelope(
        success=not any(i.severity == Severity.ERROR for i in issues),
        tool="godot_indexer",
        issues=issues,
        data={
            "total_files_indexed": total_files,
            "gdscript_files": gd_scripts,
            "total_gdscript_loc": data.get("gdscript_metrics", {}).get("total_lines", 0),
            "god_files_count": len(god_files),
            "sha256_raw_bytes": compute_raw_sha256(output_json),
        },
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Godot Project Indexer & Layer A Catalog Extractor")
    parser.add_argument("--index", action="store_true", help="Run indexing and export project_index.json")
    parser.add_argument("--verify", action="store_true", help="Verify project_index.json compliance")
    parser.add_argument("--format", default=None, choices=["toon", "json", "json_compact", "jsonl"])
    parser.add_argument("--select", default=None, help="Optional subtree/column selector when projecting")
    args = parser.parse_args()

    if args.index or (not args.index and not args.verify and not args.format):
        data = index_godot_project()
        if not args.format:
            print(
                f"Indexing completed: {data['total_files_indexed']} files, "
                f"{data['gdscript_metrics']['total_scripts']} GDScripts, "
                f"{data['god_files_count']} God-files."
            )

    if args.format:
        if not DEFAULT_OUTPUT_JSON.exists():
            index_godot_project()
        raw_data = json.loads(DEFAULT_OUTPUT_JSON.read_text(encoding="utf-8"))
        print(format_projection(raw_data, args.format, DEFAULT_OUTPUT_JSON, ROOT_DIR, args.select))

    if args.verify:
        envelope = verify_godot_index()
        print(json.dumps(envelope.model_dump(mode="json"), indent=2))
        sys.exit(envelope.exit_code)


if __name__ == "__main__":
    main()
