"""
Dependency Impact Analyzer (scripts/agent/check_impact.py).
Traverses reverse dependencies in docs/agent-system/reference-registry.json
to identify all downstream documents, modules, and tests affected by a change.
"""

from __future__ import annotations

import argparse
from collections import deque
import json
import sys
from pathlib import Path
from typing import Dict, List, Optional, Set

from pydantic import ValidationError

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.models import (
    FixableBy,
    Issue,
    ReferenceRegistry,
    RegistryEntry,
    ResultEnvelope,
    Severity,
)

DEFAULT_REGISTRY_PATH = Path("docs/agent-system/reference-registry.json")


def check_impact(
    workspace_root: Path,
    target_id_or_path: str,
    registry_rel_path: Path = DEFAULT_REGISTRY_PATH,
) -> ResultEnvelope:
    """Compute direct and transitive downstream dependents for a Reference ID or file path."""
    issues: List[Issue] = []
    reg_path = workspace_root / registry_rel_path

    if not reg_path.exists():
        issues.append(Issue(
            code="ERR_REG_FILE_NOT_FOUND",
            severity=Severity.ERROR,
            message=f"Reference registry missing at '{registry_rel_path.as_posix()}'.",
            location=registry_rel_path.as_posix(),
            fixable_by=FixableBy.AI,
        ))
        return ResultEnvelope(success=False, tool="check_impact", issues=issues)

    try:
        registry = ReferenceRegistry.model_validate(json.loads(reg_path.read_text(encoding="utf-8")))
    except (json.JSONDecodeError, ValidationError) as exc:
        issues.append(Issue(
            code="ERR_REG_SCHEMA_INVALID",
            severity=Severity.ERROR,
            message=f"Registry schema invalid: {exc}",
            location=registry_rel_path.as_posix(),
            fixable_by=FixableBy.AI,
        ))
        return ResultEnvelope(success=False, tool="check_impact", issues=issues)

    by_id: Dict[str, RegistryEntry] = {e.id: e for e in registry.entries}
    norm_query = target_id_or_path.strip().replace("\\", "/")

    seed_id: Optional[str] = None
    if norm_query in by_id:
        seed_id = norm_query
    else:
        for entry in registry.entries:
            if entry.path == norm_query:
                seed_id = entry.id
                break

    if seed_id is None:
        issues.append(Issue(
            code="ERR_IMPACT_TARGET_NOT_FOUND",
            severity=Severity.ERROR,
            message=f"Target '{target_id_or_path}' not found in reference-registry.json (by ID or path).",
            location=target_id_or_path,
            fixable_by=FixableBy.AI,
            suggested_action="Register the target in reference-registry.json before running impact analysis.",
        ))
        return ResultEnvelope(success=False, tool="check_impact", issues=issues)

    # Build reverse adjacency list: upstream_id -> [dependent_ids]
    rev_graph: Dict[str, List[str]] = {e.id: [] for e in registry.entries}
    for entry in registry.entries:
        for upstream in entry.depends_on:
            if upstream in rev_graph:
                rev_graph[upstream].append(entry.id)

    direct_dependents = sorted(rev_graph.get(seed_id, []))
    visited: Set[str] = {seed_id}
    queue: deque[str] = deque([seed_id])
    transitive_ids: List[str] = []

    while queue:
        curr = queue.popleft()
        for nxt in sorted(rev_graph.get(curr, [])):
            if nxt not in visited:
                visited.add(nxt)
                transitive_ids.append(nxt)
                queue.append(nxt)

    impacted_records = [
        {
            "id": dep_id,
            "kind": by_id[dep_id].kind.value,
            "path": by_id[dep_id].path,
            "authority": by_id[dep_id].authority.value,
            "status": by_id[dep_id].status.value,
        }
        for dep_id in transitive_ids
    ]

    return ResultEnvelope(
        success=True,
        tool="check_impact",
        issues=issues,
        data={
            "source_id": seed_id,
            "source_path": by_id[seed_id].path,
            "direct_dependents": direct_dependents,
            "transitive_dependents": transitive_ids,
            "impacted_artifacts": impacted_records,
        },
    )


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Analyze downstream impact of modifying a registered artifact.")
    parser.add_argument("--root", type=Path, default=ROOT_DIR, help="Workspace root directory")
    parser.add_argument("--target", required=True, help="Reference ID (e.g. ARCH-CORE-001) or relative file path")
    parser.add_argument("--registry", type=Path, default=DEFAULT_REGISTRY_PATH, help="Relative path to registry JSON")
    args = parser.parse_args(argv)

    res = check_impact(
        workspace_root=args.root.resolve(),
        target_id_or_path=args.target,
        registry_rel_path=args.registry,
    )
    print(json.dumps(res.model_dump(mode="json"), indent=2, ensure_ascii=False))
    return res.exit_code


if __name__ == "__main__":
    sys.exit(main())
