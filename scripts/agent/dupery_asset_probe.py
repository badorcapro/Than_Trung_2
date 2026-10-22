"""
Dupery Asset Probe & Topology Extractor (scripts/agent/dupery_asset_probe.py).
Inspects Dupery_Data assets with UnityPy to catalog Scenes, MonoScripts,
ScriptableObjects, and Sprite assets into dupery_asset_topology.json and
exports sample preview images into extracted_assets_preview/.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Any, Dict, List

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.models import FixableBy, Issue, ResultEnvelope, Severity

DEFAULT_DUPERY_DATA = Path(r"D:\Minh\Steam\steamapps\common\Dupery\Dupery_Data")
DEFAULT_OUTPUT_JSON = ROOT_DIR / "docs/agent-system/evidence/dupery/dupery_asset_topology.json"
DEFAULT_PREVIEW_DIR = ROOT_DIR / "docs/agent-system/evidence/dupery/extracted_assets_preview"


def extract_topology(
    data_dir: Path = DEFAULT_DUPERY_DATA,
    output_json: Path = DEFAULT_OUTPUT_JSON,
    preview_dir: Path = DEFAULT_PREVIEW_DIR,
) -> Dict[str, Any]:
    import UnityPy

    scenes: List[Dict[str, Any]] = []
    scripts: List[Dict[str, str]] = []
    named_monobehaviours: List[str] = []
    sprites_catalog: List[Dict[str, Any]] = []

    # 1. Read globalgamemanagers for Scenes
    ggm_path = data_dir / "globalgamemanagers"
    if ggm_path.exists():
        env_ggm = UnityPy.load(str(ggm_path))
        for obj in env_ggm.objects:
            if obj.type.name == "BuildSettings":
                data = obj.read()
                raw_scenes = getattr(data, "scenes", [])
                for idx, sc in enumerate(raw_scenes):
                    scenes.append({
                        "build_index": idx,
                        "path": sc,
                        "name": Path(sc).stem,
                    })

    # 2. Read resources.assets for MonoBehaviours and Sprites
    resources_path = data_dir / "resources.assets"
    preview_saved = 0
    preview_dir.mkdir(parents=True, exist_ok=True)

    if resources_path.exists():
        env_res = UnityPy.load(str(resources_path))
        for obj in env_res.objects:
            t_name = obj.type.name
            if t_name == "MonoBehaviour":
                try:
                    tree = obj.read_typetree(check_read=False)
                    mb_name = tree.get("m_Name")
                    if mb_name and mb_name not in named_monobehaviours:
                        named_monobehaviours.append(mb_name)
                except Exception:
                    pass
            elif t_name == "Sprite":
                try:
                    d = obj.read()
                    sp_name = getattr(d, "m_Name", "") or "unnamed_sprite"
                    sp_info = {
                        "name": sp_name,
                        "width": d.image.width if hasattr(d, "image") else None,
                        "height": d.image.height if hasattr(d, "image") else None,
                    }
                    sprites_catalog.append(sp_info)

                    # Export sample previews for key asset classes
                    target_names = [
                        "quirks_spritesheet_14",
                        "CasinoIconsWhite_2",
                        "NeighbourIcons 1_1",
                    ]
                    if sp_name in target_names and hasattr(d, "image") and preview_saved < 10:
                        save_name = f"{sp_name}.png"
                        d.image.save(str(preview_dir / save_name))
                        preview_saved += 1
                except Exception:
                    pass

    # 3. Read MonoScripts from all available assets
    seen_scripts = set()
    for f in sorted(os.listdir(data_dir)):
        if f.endswith(".assets") or f == "globalgamemanagers":
            fp = data_dir / f
            try:
                env = UnityPy.load(str(fp))
                for obj in env.objects:
                    if obj.type.name == "MonoScript":
                        d = obj.read()
                        cn = getattr(d, "m_ClassName", "")
                        ns = getattr(d, "m_Namespace", "")
                        asm = getattr(d, "m_AssemblyName", "")
                        full = f"{ns}.{cn}" if ns else cn
                        if full and full not in seen_scripts:
                            seen_scripts.add(full)
                            scripts.append({
                                "full_name": full,
                                "class_name": cn,
                                "namespace": ns,
                                "assembly": asm,
                                "source_asset": f,
                            })
            except Exception:
                pass

    topology = {
        "schema_version": "1.0",
        "target_name": "Dupery",
        "data_directory": str(data_dir).replace("\\", "/"),
        "scenes_count": len(scenes),
        "scenes": scenes,
        "named_scriptable_objects_count": len(named_monobehaviours),
        "named_scriptable_objects": sorted(named_monobehaviours),
        "total_monoscripts_count": len(scripts),
        "sample_monoscripts": scripts[:50],
        "sprites_count": len(sprites_catalog),
        "sample_sprites": sprites_catalog[:30],
        "previews_exported": preview_saved,
    }

    output_json.parent.mkdir(parents=True, exist_ok=True)
    output_json.write_text(json.dumps(topology, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return topology


def verify_topology(
    workspace_root: Path = ROOT_DIR,
    output_json: Path = DEFAULT_OUTPUT_JSON,
    preview_dir: Path = DEFAULT_PREVIEW_DIR,
) -> ResultEnvelope:
    issues: list[Issue] = []

    if not output_json.exists():
        issues.append(
            Issue(
                code="ERR_TOPOLOGY_MISSING",
                severity=Severity.ERROR,
                message=f"dupery_asset_topology.json missing at '{output_json.relative_to(workspace_root).as_posix()}'.",
                location=output_json.relative_to(workspace_root).as_posix(),
                fixable_by=FixableBy.AI,
            )
        )
        return ResultEnvelope(success=False, tool="dupery_asset_probe", issues=issues)

    try:
        data = json.loads(output_json.read_text(encoding="utf-8"))
    except Exception as exc:
        issues.append(
            Issue(
                code="ERR_TOPOLOGY_INVALID_JSON",
                severity=Severity.ERROR,
                message=f"dupery_asset_topology.json is invalid JSON: {exc}",
                location=output_json.relative_to(workspace_root).as_posix(),
                fixable_by=FixableBy.AI,
            )
        )
        return ResultEnvelope(success=False, tool="dupery_asset_probe", issues=issues)

    scenes = data.get("scenes", [])
    if len(scenes) < 10:
        issues.append(
            Issue(
                code="ERR_INCOMPLETE_SCENES",
                severity=Severity.ERROR,
                message=f"Observed only {len(scenes)} scenes in topology (expected >= 10).",
                location=output_json.relative_to(workspace_root).as_posix(),
                fixable_by=FixableBy.AI,
            )
        )

    named_sos = data.get("named_scriptable_objects", [])
    if len(named_sos) < 15:
        issues.append(
            Issue(
                code="ERR_INCOMPLETE_SCRIPTABLE_OBJECTS",
                severity=Severity.ERROR,
                message=f"Observed only {len(named_sos)} named ScriptableObjects (expected >= 15).",
                location=output_json.relative_to(workspace_root).as_posix(),
                fixable_by=FixableBy.AI,
            )
        )

    sprites_count = data.get("sprites_count", 0)
    if sprites_count < 100:
        issues.append(
            Issue(
                code="ERR_INCOMPLETE_SPRITES",
                severity=Severity.ERROR,
                message=f"Observed only {sprites_count} sprites (expected >= 100).",
                location=output_json.relative_to(workspace_root).as_posix(),
                fixable_by=FixableBy.AI,
            )
        )

    # Check preview PNGs
    if not preview_dir.exists():
        issues.append(
            Issue(
                code="ERR_PREVIEW_DIR_MISSING",
                severity=Severity.ERROR,
                message=f"Preview directory missing: '{preview_dir.relative_to(workspace_root).as_posix()}'.",
                location=preview_dir.relative_to(workspace_root).as_posix(),
                fixable_by=FixableBy.AI,
            )
        )
    else:
        pngs = list(preview_dir.glob("*.png"))
        if len(pngs) < 3:
            issues.append(
                Issue(
                    code="ERR_INSUFFICIENT_PREVIEWS",
                    severity=Severity.ERROR,
                    message=f"Observed only {len(pngs)} preview PNGs (expected >= 3).",
                    location=preview_dir.relative_to(workspace_root).as_posix(),
                    fixable_by=FixableBy.AI,
                )
            )

    success = not any(i.severity == Severity.ERROR for i in issues)
    return ResultEnvelope(
        success=success,
        tool="dupery_asset_probe",
        issues=issues,
        data={
            "scenes_count": len(scenes),
            "scriptable_objects_count": len(named_sos),
            "sprites_count": sprites_count,
            "previews_verified": len(list(preview_dir.glob("*.png"))) if preview_dir.exists() else 0,
        },
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Dupery Asset Probe & Topology Extractor")
    parser.add_argument("--extract", action="store_true", help="Extract topology and export sample previews")
    parser.add_argument("--verify", action="store_true", help="Run deterministic verification checks")
    args = parser.parse_args()

    if args.extract or (not args.extract and not args.verify):
        extract_topology()
        print("Topology extraction completed.")

    if args.verify:
        envelope = verify_topology()
        print(json.dumps(envelope.model_dump(mode="json"), indent=2))
        sys.exit(envelope.exit_code)


if __name__ == "__main__":
    main()
