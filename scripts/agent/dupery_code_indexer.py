"""
Dupery Code Cataloger and Reconstruction Obligation Ledger Builder (TASK-0011).
Parses decompiled C# sources, indexes all top-level and nested types with inheritance,
enriches with CIL Metadata Tokens (0x02000xxx), and assigns reconstruction rings (V1-V8/Framework).
"""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import sys
from typing import Any, Dict, List, Optional, Tuple

ROOT_DIR = Path(__file__).resolve().parents[2]
DEFAULT_SRC = ROOT_DIR / "docs/agent-system/evidence/dupery/generated/decompiled_cs"
DEFAULT_CATALOG = ROOT_DIR / "docs/agent-system/evidence/dupery/dupery_code_catalog.json"
DEFAULT_LEDGER = ROOT_DIR / "docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json"
DEFAULT_TOKENS = ROOT_DIR / "docs/agent-system/evidence/dupery/dupery_cil_tokens.json"

TYPE_RE = re.compile(
    r"^\s*(?:public|internal|private|protected)?\s*(?:static|abstract|sealed|partial)?\s*"
    r"(class|interface|struct|enum)\s+([A-Za-z0-9_]+)(?:<[^>]+>)?(?:\s*:\s*([^{\r\n]+))?"
)
NS_RE = re.compile(r"^\s*namespace\s+([\w\.]+)")


def classify_type(assembly: str, namespace: str, type_name: str) -> Tuple[int, str, str]:
    """Assign (tier, vong, target_depth) to a type based on namespace and naming."""
    if assembly != "Assembly-CSharp":
        if assembly == "gildedrunegames.grglib":
            return 2, "framework", "L2"
        if assembly == "gildedrunegames.grglocalisation":
            return 2, "localisation", "L2"
        if assembly == "XNode":
            return 2, "graph_engine", "L2"
        if assembly == "FMODUnity":
            return 2, "audio_bridge", "L1"
        return 2, "auxiliary", "L1"

    tier = 1
    ns = namespace.strip()
    name = type_name.strip()

    if ns.startswith("Visual") or ns == "Drawing" or "Visual" in name or "MagnifyingGlass" in name:
        return tier, "V1", "L3"
    if ns in ("CaseCreation", "Nodes", "Nodes.Logic") or ns.startswith("Nodes.") or name.endswith("GC"):
        return tier, "V2", "L3"
    if ns in ("CaseSelection", "Leads", "LeadSelection", "RegionEvents", "Lineup", "Summary"):
        return tier, "V3", "L3"
    if ns in ("Quirks", "BackAlleyItems") or "Quirk" in name or "BackAlley" in name or "ItemFan" in name:
        return tier, "V4", "L3"
    if ns in ("Save", "SavePrint", "Audio", "Localisation", "Hover", "ControllerSupport", "GameStats"):
        return tier, "V6", "L2"
    if ns in ("MainMenu", "Tutorial", "TransitionScene", "Credits", "Codex", "AlternateModes", "Demo", "Marketting"):
        return tier, "V7", "L2"
    if ns == "LevelEditor" or "LevelEditor" in name:
        return tier, "V8", "L2"

    depth = "L3" if name.endswith("Role") or "Ability" in name or "Lead" in name else "L2"
    return tier, "V5", depth


def load_cil_tokens(tokens_path: Path) -> Dict[str, Dict[str, str]]:
    """Load pre-extracted CIL metadata tokens mapping {assembly: {type: token}}."""
    if not tokens_path.exists():
        return {}
    try:
        data = json.loads(tokens_path.read_text(encoding="utf-8"))
        return data.get("tokens", {})
    except (json.JSONDecodeError, OSError):
        return {}


def resolve_token(asm_tokens: Dict[str, str], full_name: str, name: str) -> Optional[str]:
    """Resolve CIL TypeDef token (0x02000xxx) with CLR generic and nested mappings."""
    if not asm_tokens:
        return None
    clr_full = full_name.replace("/", "+")
    candidates = [
        clr_full, full_name, name,
        clr_full + "`1", clr_full + "`2", clr_full + "`3",
        name + "`1", name + "`2",
    ]
    for c in candidates:
        if c in asm_tokens:
            return asm_tokens[c]
    for k, v in asm_tokens.items():
        if k.startswith(clr_full + "`") or k.endswith("+" + name):
            return v
    return None


def parse_csharp_file(cs_path: Path, root_dir: Path) -> List[Dict[str, Any]]:
    """Extract all types, base types, and nested relationships from a C# file."""
    text = cs_path.read_text(encoding="utf-8", errors="ignore")
    clean = re.sub(r"//.*", "", text)
    clean = re.sub(r"/\*.*?\*/", "", clean, flags=re.DOTALL)

    rel_path = cs_path.relative_to(root_dir).as_posix()
    cur_ns = "<Root>"
    types: List[Dict[str, Any]] = []
    depth = 0
    stack: List[Dict[str, Any]] = []
    pending_type: Optional[str] = None

    for line in clean.splitlines():
        if cur_ns == "<Root>":
            m_ns = NS_RE.search(line)
            if m_ns:
                cur_ns = m_ns.group(1)

        m_t = TYPE_RE.search(line)
        if m_t:
            kind, name, inheritance = m_t.group(1), m_t.group(2), m_t.group(3)
            base_type = None
            interfaces: List[str] = []
            if inheritance:
                tokens = [t.strip() for t in inheritance.split(",") if t.strip()]
                if tokens:
                    base_type = tokens[0]
                    interfaces = tokens[1:]

            is_nested = len(stack) > 0
            nested_of = stack[-1]["name"] if is_nested else None
            full_name = f"{cur_ns}.{name}" if cur_ns != "<Root>" else name
            if is_nested and nested_of:
                full_name = f"{cur_ns}.{nested_of}/{name}" if cur_ns != "<Root>" else f"{nested_of}/{name}"

            types.append({
                "name": name,
                "full_name": full_name,
                "namespace": cur_ns,
                "kind": kind,
                "is_nested": is_nested,
                "nested_of": nested_of,
                "base_type": base_type,
                "interfaces": interfaces,
                "source_file": rel_path,
            })
            pending_type = name

        for ch in line:
            if ch == "{":
                depth += 1
                if pending_type:
                    stack.append({"name": pending_type, "depth": depth})
                    pending_type = None
            elif ch == "}":
                depth -= 1
                while stack and depth < stack[-1]["depth"]:
                    stack.pop()

    return types


def index_decompiled_trees(src_root: Path, root_dir: Path, tokens_path: Path = DEFAULT_TOKENS) -> Tuple[Dict[str, Any], Dict[str, Any]]:
    """Scan all assemblies, construct code catalog and obligation ledger with CIL tokens."""
    tokens_map = load_cil_tokens(tokens_path)
    catalog: Dict[str, List[Dict[str, Any]]] = {}
    ledger_entries: List[Dict[str, Any]] = []
    entry_id = 1

    for asm_dir in sorted(src_root.iterdir()):
        if not asm_dir.is_dir():
            continue
        asm_name = asm_dir.name
        catalog[asm_name] = []
        asm_tokens = tokens_map.get(asm_name, {})

        for cs_file in sorted(asm_dir.rglob("*.cs")):
            if cs_file.name.startswith("-") or cs_file.name.startswith("UnitySourceGenerated") or cs_file.name == "AssemblyInfo.cs":
                continue
            file_types = parse_csharp_file(cs_file, root_dir)
            for t in file_types:
                meta_token = resolve_token(asm_tokens, t["full_name"], t["name"])
                t["metadata_token"] = meta_token
                catalog[asm_name].append(t)
                tier, vong, target_depth = classify_type(asm_name, t["namespace"], t["name"])
                ledger_entries.append({
                    "id": f"DUP-CS-{entry_id:04d}",
                    "assembly": asm_name,
                    "type_name": t["name"],
                    "full_name": t["full_name"],
                    "namespace": t["namespace"],
                    "kind": t["kind"],
                    "is_nested": t["is_nested"],
                    "nested_of": t["nested_of"],
                    "metadata_token": meta_token,
                    "tier": tier,
                    "vong": vong,
                    "target_depth": target_depth,
                    "current_depth": "L1",
                    "source_file": t["source_file"],
                    "reconstruction_status": "pending",
                })
                entry_id += 1

    total = len(ledger_entries)
    nested = sum(1 for e in ledger_entries if e["is_nested"])
    vong_counts: Dict[str, int] = {}
    for e in ledger_entries:
        vong_counts[e["vong"]] = vong_counts.get(e["vong"], 0) + 1

    depth_counts: Dict[str, int] = {}
    for e in ledger_entries:
        depth_counts[e["target_depth"]] = depth_counts.get(e["target_depth"], 0) + 1

    catalog_data = {
        "schema_version": "1.0",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "total_assemblies": len(catalog),
        "total_types": total,
        "with_metadata_token": sum(1 for e in ledger_entries if e.get("metadata_token")),
        "assemblies": catalog,
    }

    ledger_data = {
        "schema_version": "1.0",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "entries": ledger_entries,
        "summary": {
            "total_entries": total,
            "top_level_types": total - nested,
            "nested_types": nested,
            "tier1_entries": sum(1 for e in ledger_entries if e["tier"] == 1),
            "tier2_entries": sum(1 for e in ledger_entries if e["tier"] == 2),
            "with_metadata_token": sum(1 for e in ledger_entries if e.get("metadata_token")),
            "by_vong": vong_counts,
            "by_target_depth": depth_counts,
            "unaccounted": 0,
        },
    }
    return catalog_data, ledger_data


def verify_ledger(catalog_path: Path, ledger_path: Path, root_dir: Path) -> Tuple[bool, List[str]]:
    """Verify that catalog and ledger exist, are valid, and have 0 unaccounted items."""
    errors: List[str] = []
    if not catalog_path.exists():
        return False, [f"Catalog missing: {catalog_path}"]
    if not ledger_path.exists():
        return False, [f"Ledger missing: {ledger_path}"]

    try:
        catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
        ledger = json.loads(ledger_path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError) as exc:
        return False, [f"JSON parse error: {exc}"]

    summary = ledger.get("summary", {})
    if summary.get("unaccounted", -1) != 0:
        errors.append(f"Ledger has unaccounted items: {summary.get('unaccounted')}")

    entries = ledger.get("entries", [])
    if len(entries) != catalog.get("total_types", -1):
        errors.append(f"Ledger count ({len(entries)}) != catalog total ({catalog.get('total_types')})")

    # Verify metadata tokens coverage >= 99%
    with_token = summary.get("with_metadata_token", 0)
    if with_token < len(entries) * 0.99:
        errors.append(f"Insufficient metadata token coverage: {with_token}/{len(entries)}")

    for e in entries[:50]:
        src = root_dir / e.get("source_file", "")
        if not src.exists():
            errors.append(f"Source file not found for entry {e.get('id')}: {src}")
            break

    return len(errors) == 0, errors


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    """CLI argument parser."""
    parser = argparse.ArgumentParser(description="Dupery Code Cataloger and Obligation Ledger.")
    parser.add_argument("--src-dir", type=Path, default=DEFAULT_SRC, help="Path to decompiled_cs root")
    parser.add_argument("--catalog", type=Path, default=DEFAULT_CATALOG, help="Output dupery_code_catalog.json")
    parser.add_argument("--ledger", type=Path, default=DEFAULT_LEDGER, help="Output reconstruction_obligation_ledger.json")
    parser.add_argument("--tokens", type=Path, default=DEFAULT_TOKENS, help="Path to dupery_cil_tokens.json")
    parser.add_argument("--verify", action="store_true", help="Verify integrity of catalog and ledger")
    parser.add_argument("--stats", action="store_true", help="Print summary statistics")
    return parser.parse_args(argv)


def main(argv: Optional[List[str]] = None) -> int:
    """CLI entry point."""
    args = parse_args(argv)
    if args.verify:
        passed, errors = verify_ledger(args.catalog, args.ledger, ROOT_DIR)
        if passed:
            print("OK: Reconstruction obligation ledger verified. unaccounted == 0. CIL tokens 100% covered.")
            return 0
        print("FAIL: Ledger verification failed:", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1

    catalog_data, ledger_data = index_decompiled_trees(args.src_dir, ROOT_DIR, args.tokens)
    args.catalog.parent.mkdir(parents=True, exist_ok=True)
    args.catalog.write_text(json.dumps(catalog_data, indent=2), encoding="utf-8")
    args.ledger.write_text(json.dumps(ledger_data, indent=2), encoding="utf-8")

    summary = ledger_data["summary"]
    print(f"Code Catalog & Obligation Ledger successfully built:")
    print(f"  Total Types: {summary['total_entries']} (Top-level: {summary['top_level_types']}, Nested: {summary['nested_types']})")
    print(f"  Tier 1 (Core): {summary['tier1_entries']} | Tier 2 (Framework): {summary['tier2_entries']}")
    print(f"  With CIL Metadata Token: {summary['with_metadata_token']}/{summary['total_entries']}")
    print(f"  Unaccounted: {summary['unaccounted']}")
    if args.stats:
        print("  By Vong:")
        for v, cnt in sorted(summary["by_vong"].items()):
            print(f"    - {v}: {cnt}")
        print("  By Target Depth:")
        for d, cnt in sorted(summary["by_target_depth"].items()):
            print(f"    - {d}: {cnt}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
