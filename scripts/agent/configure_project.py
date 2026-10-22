"""
Workspace customization and project-config initialization CLI (scripts/agent/configure_project.py).
Provides deterministic programmatic and interactive configuration of docs/agent-system/project-config.json.
Governed by ADR-ARCH-010 and ADR-ARCH-011.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys
from typing import Any, Dict, List, Optional

from scripts.agent.config_models import (
    DiffGuardConfig,
    LineBudgetConfig,
    ProjectConfig,
    RoleBudget,
    RoleMapEntry,
)
from scripts.agent.models import FixableBy, Issue, ResultEnvelope, Severity

DEFAULT_CONFIG_REL_PATH = Path("docs/agent-system/project-config.json")

DEFAULT_EXTENSIONS = [
    ".py", ".sv", ".v", ".vhd", ".ts", ".tsx", ".js", ".jsx", ".java", ".go",
    ".rs", ".c", ".cc", ".cpp", ".h", ".hpp", ".cs", ".kt", ".swift"
]

DEFAULT_ROLE_MAP: List[Dict[str, str]] = [
    {"glob": "scripts/agent/**", "role": "core_engine"},
    {"glob": "tests/**", "role": "test"},
    {"glob": "pilot/rtl/**", "role": "rtl"},
    {"glob": "generated/**", "role": "generated"},
    {"glob": "**/generated/**", "role": "generated"},
    {"glob": "vendor/**", "role": "generated"},
    {"glob": "**/vendor/**", "role": "generated"},
]

DEFAULT_PROFILES: Dict[str, Dict[str, Dict[str, Any]]] = {
    "software": {
        "core_engine": {"warn": 300, "review": 350, "hard": 400},
        "domain_logic": {"warn": 400, "review": 500, "hard": 800},
        "ui_component": {"warn": 300, "review": 400, "hard": 600},
        "test": {"warn": 500, "review": 800, "hard": 1200},
        "rtl": {"warn": 400, "review": 500, "hard": 800},
        "testbench": {"warn": 500, "review": 800, "hard": 1200},
        "generated": {"exempt": True},
    },
    "semiconductor-hardware": {
        "core_engine": {"warn": 300, "review": 350, "hard": 400},
        "domain_logic": {"warn": 400, "review": 500, "hard": 800},
        "ui_component": {"warn": 300, "review": 400, "hard": 600},
        "test": {"warn": 500, "review": 800, "hard": 1200},
        "rtl": {"warn": 400, "review": 600, "hard": 1000},
        "testbench": {"warn": 600, "review": 900, "hard": 1500},
        "generated": {"exempt": True},
    },
}

DEFAULT_DIFF_GUARD = {
    "max_net_deleted_lines": 150,
    "max_hunk_lines": 200,
    "placeholder_patterns": [
        "(?i)rest of (the )?(code|file|function|class)\\b.{0,30}(unchanged|same|remains)",
        "(?i)(existing|previous|remaining) code (here|unchanged|remains)",
        "(?i)\\.\\.\\.\\s*(rest|remaining|existing)\\b",
    ],
}


def build_default_project_config(
    active_profile: str = "software",
    workflow_mode: str = "milestone",
) -> ProjectConfig:
    """Build a valid default ProjectConfig instance."""
    if active_profile not in DEFAULT_PROFILES:
        raise ValueError(
            f"Unknown profile '{active_profile}'. Available: {sorted(DEFAULT_PROFILES.keys())}"
        )
    if workflow_mode not in ("milestone", "single_task"):
        raise ValueError(f"Unknown workflow_mode '{workflow_mode}'. Must be 'milestone' or 'single_task'.")

    profiles_data: Dict[str, Dict[str, RoleBudget]] = {}
    for prof_name, roles_dict in DEFAULT_PROFILES.items():
        profiles_data[prof_name] = {
            rname: RoleBudget.model_validate(rdata)
            for rname, rdata in roles_dict.items()
        }

    role_map_entries = [
        RoleMapEntry(glob=item["glob"], role=item["role"])
        for item in DEFAULT_ROLE_MAP
    ]

    budget_config = LineBudgetConfig(
        loc_counting="non_empty_lines",
        include_extensions=list(DEFAULT_EXTENSIONS),
        default_role="domain_logic",
        role_map=role_map_entries,
        profiles=profiles_data,
        diff_guard=DiffGuardConfig.model_validate(DEFAULT_DIFF_GUARD),
    )

    return ProjectConfig(
        schema_version="1.0",
        workflow_mode=workflow_mode,  # type: ignore[arg-type]
        active_profile=active_profile,
        line_budget=budget_config,
    )


def configure_project(
    workspace_root: Path,
    mode: Optional[str] = None,
    profile: Optional[str] = None,
    init: bool = False,
    force: bool = False,
    config_rel_path: Path = DEFAULT_CONFIG_REL_PATH,
) -> ResultEnvelope:
    """Configure or initialize docs/agent-system/project-config.json deterministically."""
    target_path = workspace_root / config_rel_path
    issues: List[Issue] = []

    # Handle --init
    if init:
        if target_path.exists() and not force:
            issues.append(Issue(
                code="ERR_CONF_ALREADY_EXISTS",
                severity=Severity.ERROR,
                message=f"Configuration file '{config_rel_path.as_posix()}' already exists. Use --force to overwrite.",
                location=config_rel_path.as_posix(),
                fixable_by=FixableBy.HUMAN,
                suggested_action="Omit --init or specify --force to re-initialize.",
            ))
            return ResultEnvelope(success=False, tool="configure_project", issues=issues)

        sel_profile = profile or "software"
        sel_mode = mode or "milestone"
        try:
            cfg = build_default_project_config(active_profile=sel_profile, workflow_mode=sel_mode)
        except Exception as exc:
            issues.append(Issue(
                code="ERR_CONF_BUILD_FAILED",
                severity=Severity.ERROR,
                message=f"Failed to build default project configuration: {exc}",
                location=config_rel_path.as_posix(),
                fixable_by=FixableBy.AI,
            ))
            return ResultEnvelope(success=False, tool="configure_project", issues=issues)

        target_path.parent.mkdir(parents=True, exist_ok=True)
        target_path.write_text(
            json.dumps(cfg.model_dump(mode="json"), indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )
        return ResultEnvelope(
            success=True,
            tool="configure_project",
            issues=issues,
            data={"action": "initialized", "config": cfg.model_dump(mode="json")},
        )

    # If modifying existing config
    if not target_path.exists():
        issues.append(Issue(
            code="ERR_CONF_FILE_NOT_FOUND",
            severity=Severity.ERROR,
            message=f"Project config file not found at '{config_rel_path.as_posix()}'. Run with --init to create one.",
            location=config_rel_path.as_posix(),
            fixable_by=FixableBy.SCRIPT,
            suggested_action="Run 'python scripts/agent/configure_project.py --init'.",
        ))
        return ResultEnvelope(success=False, tool="configure_project", issues=issues)

    try:
        raw_data = json.loads(target_path.read_text(encoding="utf-8"))
        cfg = ProjectConfig.model_validate(raw_data)
    except Exception as exc:
        issues.append(Issue(
            code="ERR_CONF_PARSE_FAILED",
            severity=Severity.ERROR,
            message=f"Existing project-config.json is invalid: {exc}",
            location=config_rel_path.as_posix(),
            fixable_by=FixableBy.HUMAN,
        ))
        return ResultEnvelope(success=False, tool="configure_project", issues=issues)

    mutated = False
    if mode is not None:
        if mode not in ("milestone", "single_task"):
            issues.append(Issue(
                code="ERR_CONF_INVALID_MODE",
                severity=Severity.ERROR,
                message=f"Invalid workflow mode '{mode}'. Must be 'milestone' or 'single_task'.",
                location=config_rel_path.as_posix(),
                fixable_by=FixableBy.HUMAN,
            ))
            return ResultEnvelope(success=False, tool="configure_project", issues=issues)
        raw_data["workflow_mode"] = mode
        mutated = True

    if profile is not None:
        if profile not in raw_data.get("line_budget", {}).get("profiles", {}):
            available = sorted(raw_data.get("line_budget", {}).get("profiles", {}).keys())
            issues.append(Issue(
                code="ERR_CONF_INVALID_PROFILE",
                severity=Severity.ERROR,
                message=f"Profile '{profile}' not defined in line_budget.profiles. Available: {available}",
                location=config_rel_path.as_posix(),
                fixable_by=FixableBy.HUMAN,
            ))
            return ResultEnvelope(success=False, tool="configure_project", issues=issues)
        raw_data["active_profile"] = profile
        mutated = True

    if mutated:
        try:
            validated = ProjectConfig.model_validate(raw_data)
        except Exception as exc:
            issues.append(Issue(
                code="ERR_CONF_VALIDATION_FAILED",
                severity=Severity.ERROR,
                message=f"Validation failed after mutation: {exc}",
                location=config_rel_path.as_posix(),
                fixable_by=FixableBy.AI,
            ))
            return ResultEnvelope(success=False, tool="configure_project", issues=issues)

        target_path.write_text(
            json.dumps(validated.model_dump(mode="json"), indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )
        return ResultEnvelope(
            success=True,
            tool="configure_project",
            issues=issues,
            data={"action": "updated", "config": validated.model_dump(mode="json")},
        )

    # No changes requested; return current config
    return ResultEnvelope(
        success=True,
        tool="configure_project",
        issues=issues,
        data={"action": "inspected", "config": cfg.model_dump(mode="json")},
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Configure or initialize docs/agent-system/project-config.json."
    )
    parser.add_argument("--root", type=str, default=".", help="Workspace root path")
    parser.add_argument("--init", action="store_true", help="Initialize starter project-config.json")
    parser.add_argument("--force", action="store_true", help="Force overwrite when initializing")
    parser.add_argument("--mode", type=str, choices=["milestone", "single_task"], help="Set workflow mode")
    parser.add_argument("--profile", type=str, help="Set active domain profile")
    parser.add_argument("--show", action="store_true", help="Print current configuration as formatted JSON")
    parser.add_argument("--json", action="store_true", help="Output machine-readable ResultEnvelope JSON")

    args = parser.parse_args()
    root = Path(args.root).resolve()

    if not args.init and args.mode is None and args.profile is None and not args.show:
        # If no arguments provided in interactive terminal, show help or inspect
        if sys.stdin.isatty():
            print("[INFO] No mutation flags provided. Displaying current project configuration:")
            args.show = True
        else:
            args.show = True

    res = configure_project(
        workspace_root=root,
        mode=args.mode,
        profile=args.profile,
        init=args.init,
        force=args.force,
    )

    if args.json:
        print(json.dumps(res.model_dump(mode="json"), indent=2, ensure_ascii=False))
    elif args.show or res.success:
        cfg_data = res.data.get("config", {}) if res.data else {}
        print(json.dumps(cfg_data, indent=2, ensure_ascii=False))
    else:
        for issue in res.issues:
            print(f"[{issue.severity.value.upper()}] {issue.code}: {issue.message}", file=sys.stderr)

    sys.exit(0 if res.success else 2)


if __name__ == "__main__":
    main()
