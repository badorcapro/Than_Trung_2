"""
Anti-Drift Documentation & Workspace Integrity Auditor (Layer 5 Governance Engine).
Audits markdown files for broken local/foreign links, rule and skill frontmatter,
script line budgets (<= 400 lines), and reference registry synchronization.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import List, Optional, Set
from urllib.parse import unquote, urlparse

import yaml

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.models import (
    FixableBy,
    Issue,
    ReferenceRegistry,
    ResultEnvelope,
    Severity,
)

_LINK_RE = re.compile(r"!?\[([^\]]*)\]\(([^)]+)\)")
_REF_ID_DECL_RE = re.compile(r"Reference ID:\s*`?([A-Z]+-[A-Z0-9-]+-[0-9]{3,4})`?", re.IGNORECASE)
_EXCLUDED_SCHEMES = {"http", "https", "mailto", "ftp", "conversation", "chrome", "vscode"}
_MAX_SCRIPT_LINES = 1000
_WARN_SCRIPT_LINES = 800
_VALID_TRIGGERS = {"always_on", "model_decision", "glob"}


def strip_code_blocks(content: str) -> str:
    """Remove fenced code blocks to prevent scanning documentation examples."""
    return re.sub(r"```[\s\S]*?```", "", content)


def check_link_target(
    raw_target: str,
    source_file: Path,
    root_dir: Path,
) -> Optional[str]:
    """Validate link target. Return error reason string if invalid, None if valid."""
    target = raw_target.strip().split("#")[0].split("?")[0].strip()
    if not target or target.startswith("#"):
        return None

    parsed = urlparse(target)
    if parsed.scheme in _EXCLUDED_SCHEMES:
        return None

    if parsed.scheme == "file":
        file_path_str = unquote(parsed.path)
        if re.match(r"^/[a-zA-Z]:", file_path_str):
            file_path_str = file_path_str[1:]
        target_path = Path(file_path_str)
        try:
            target_path.resolve().relative_to(root_dir.resolve())
        except ValueError:
            return f"Foreign path outside workspace: '{raw_target}'"
        if not target_path.exists():
            return f"Target does not exist: '{target_path}'"
        return None

    if Path(target).is_absolute() or re.match(r"^[a-zA-Z]:", target):
        target_path = Path(target)
        try:
            target_path.resolve().relative_to(root_dir.resolve())
        except ValueError:
            return f"Foreign absolute path outside workspace: '{raw_target}'"
    else:
        target_path = (source_file.parent / target).resolve()

    if not target_path.exists():
        return f"Target file does not exist: '{target}'"
    return None


def audit_file_links(file_path: Path, root_dir: Path, issues: List[Issue]) -> None:
    """Audit markdown links and check for broken local links or foreign paths."""
    try:
        content = file_path.read_text(encoding="utf-8")
    except Exception as exc:
        issues.append(
            Issue(
                code="ERR_DOC_READ_FAILED",
                severity=Severity.ERROR,
                message=f"Failed to read file: {exc}",
                location=str(file_path.relative_to(root_dir)).replace("\\", "/"),
            )
        )
        return

    clean_content = strip_code_blocks(content)
    rel_path = str(file_path.relative_to(root_dir)).replace("\\", "/")

    for match in _LINK_RE.finditer(clean_content):
        target = match.group(2)
        err = check_link_target(target, file_path, root_dir)
        if err:
            issues.append(
                Issue(
                    code="ERR_DOC_BROKEN_LINK",
                    severity=Severity.ERROR,
                    message=f"Broken link in markdown: {err}",
                    location=rel_path,
                    fixable_by=FixableBy.AI,
                    suggested_action=f"Update link target '{target}' to a valid workspace relative path.",
                    evidence={"link_target": target, "error": err},
                )
            )


def audit_rule_frontmatter(rule_path: Path, root_dir: Path, issues: List[Issue]) -> None:
    """Verify rule frontmatter conforms to Layer 5 schema."""
    rel_path = str(rule_path.relative_to(root_dir)).replace("\\", "/")
    content = rule_path.read_text(encoding="utf-8")
    parts = content.split("---")
    if len(parts) < 3:
        issues.append(
            Issue(
                code="ERR_DOC_FRONTMATTER",
                severity=Severity.ERROR,
                message="Rule missing YAML frontmatter enclosed in '---'.",
                location=rel_path,
                fixable_by=FixableBy.AI,
            )
        )
        return

    try:
        fm = yaml.safe_load(parts[1]) or {}
    except Exception as exc:
        issues.append(
            Issue(
                code="ERR_DOC_FRONTMATTER",
                severity=Severity.ERROR,
                message=f"Invalid YAML frontmatter: {exc}",
                location=rel_path,
                fixable_by=FixableBy.AI,
            )
        )
        return

    trigger = fm.get("trigger")
    if trigger not in _VALID_TRIGGERS:
        issues.append(
            Issue(
                code="ERR_DOC_FRONTMATTER",
                severity=Severity.ERROR,
                message=f"Rule trigger must be one of {sorted(_VALID_TRIGGERS)}, got '{trigger}'.",
                location=rel_path,
                fixable_by=FixableBy.AI,
            )
        )

    if trigger == "model_decision" and not fm.get("description"):
        issues.append(
            Issue(
                code="ERR_DOC_FRONTMATTER",
                severity=Severity.ERROR,
                message="Rule with 'trigger: model_decision' must provide a non-empty 'description'.",
                location=rel_path,
                fixable_by=FixableBy.AI,
            )
        )
    elif trigger == "glob" and not fm.get("globs"):
        issues.append(
            Issue(
                code="ERR_DOC_FRONTMATTER",
                severity=Severity.ERROR,
                message="Rule with 'trigger: glob' must provide non-empty 'globs' pattern/list.",
                location=rel_path,
                fixable_by=FixableBy.AI,
            )
        )


def audit_script_line_budgets(root_dir: Path, issues: List[Issue]) -> None:
    """Enforce <= 1000 lines hard cap on scripts/agent/*.py (warn: 800)."""
    scripts_dir = root_dir / "scripts" / "agent"
    if not scripts_dir.exists():
        return

    for script_file in sorted(scripts_dir.glob("*.py")):
        rel_path = str(script_file.relative_to(root_dir)).replace("\\", "/")
        lines = script_file.read_text(encoding="utf-8").splitlines()
        line_count = len(lines)

        if line_count > _MAX_SCRIPT_LINES:
            issues.append(
                Issue(
                    code="ERR_DOC_LINE_BUDGET",
                    severity=Severity.ERROR,
                    message=f"Script '{rel_path}' exceeds hard cap of {_MAX_SCRIPT_LINES} lines ({line_count} lines).",
                    location=rel_path,
                    fixable_by=FixableBy.AI,
                    suggested_action=f"Refactor '{rel_path}' into modular helpers to stay under {_MAX_SCRIPT_LINES} lines.",
                    evidence={"line_count": line_count, "limit": _MAX_SCRIPT_LINES},
                )
            )
        elif line_count > _WARN_SCRIPT_LINES:
            issues.append(
                Issue(
                    code="WARN_DOC_LINE_BUDGET",
                    severity=Severity.WARNING,
                    message=f"Script '{rel_path}' exceeds soft target of {_WARN_SCRIPT_LINES} lines ({line_count} lines).",
                    location=rel_path,
                    fixable_by=FixableBy.AI,
                    evidence={"line_count": line_count, "limit": _WARN_SCRIPT_LINES},
                )
            )


def audit_reference_id_declarations(
    file_path: Path,
    root_dir: Path,
    registered_ids: Set[str],
    issues: List[Issue],
) -> None:
    """Check explicit Reference ID declarations against reference-registry.json."""
    content = file_path.read_text(encoding="utf-8")
    rel_path = str(file_path.relative_to(root_dir)).replace("\\", "/")

    for match in _REF_ID_DECL_RE.finditer(content):
        ref_id = match.group(1).strip()
        if ref_id not in registered_ids:
            issues.append(
                Issue(
                    code="ERR_DOC_UNREGISTERED_REF",
                    severity=Severity.ERROR,
                    message=f"Document declares Reference ID '{ref_id}' which is not in reference-registry.json.",
                    location=rel_path,
                    fixable_by=FixableBy.AI,
                    suggested_action=f"Register '{ref_id}' in docs/agent-system/reference-registry.json.",
                    evidence={"declared_ref_id": ref_id},
                )
            )


def run_check_docs(
    root: Optional[Path] = None,
    registry_path: Optional[Path] = None,
    strict: bool = False,
) -> ResultEnvelope:
    """Run complete anti-drift documentation and workspace integrity audit."""
    root_dir = (root or Path.cwd()).resolve()
    reg_file = registry_path or (root_dir / "docs" / "agent-system" / "reference-registry.json")

    issues: List[Issue] = []
    registered_ids: Set[str] = set()

    if reg_file.exists():
        try:
            reg_data = json.loads(reg_file.read_text(encoding="utf-8"))
            registry = ReferenceRegistry.model_validate(reg_data)
            for entry in registry.entries:
                registered_ids.add(entry.id)
                entry_target = root_dir / entry.path
                if not entry_target.exists():
                    issues.append(
                        Issue(
                            code="ERR_DOC_REGISTRY_MISSING",
                            severity=Severity.ERROR,
                            message=f"Registry entry '{entry.id}' points to non-existent path '{entry.path}'.",
                            location=str(reg_file.relative_to(root_dir)).replace("\\", "/"),
                            fixable_by=FixableBy.AI,
                            evidence={"ref_id": entry.id, "path": entry.path},
                        )
                    )
        except Exception as exc:
            issues.append(
                Issue(
                    code="ERR_DOC_REGISTRY_PARSE",
                    severity=Severity.ERROR,
                    message=f"Failed to parse reference registry: {exc}",
                    location=str(reg_file.relative_to(root_dir)).replace("\\", "/"),
                )
            )

    audit_script_line_budgets(root_dir, issues)

    md_files: List[Path] = []
    for pattern in ["*.md", "docs/**/*.md", ".agents/rules/*.md", ".agents/skills/**/*.md"]:
        md_files.extend(root_dir.glob(pattern))

    seen_md: Set[Path] = set()
    for md_file in md_files:
        if md_file in seen_md or not md_file.is_file():
            continue
        seen_md.add(md_file)
        audit_file_links(md_file, root_dir, issues)
        audit_reference_id_declarations(md_file, root_dir, registered_ids, issues)

    rules_dir = root_dir / ".agents" / "rules"
    if rules_dir.exists():
        for rule_file in sorted(rules_dir.glob("*.md")):
            audit_rule_frontmatter(rule_file, root_dir, issues)

    if strict:
        for i, issue in enumerate(issues):
            if issue.severity == Severity.WARNING:
                issues[i] = issue.model_copy(update={"severity": Severity.ERROR})

    success = not any(i.severity == Severity.ERROR for i in issues)
    return ResultEnvelope(
        success=success,
        tool="check_docs",
        issues=issues,
        data={
            "files_audited": len(seen_md),
            "registered_refs_checked": len(registered_ids),
            "strict_mode": strict,
        },
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Audit workspace documentation drift and integrity.")
    parser.add_argument("--root", type=Path, default=None, help="Workspace root directory")
    parser.add_argument("--registry", type=Path, default=None, help="Path to reference-registry.json")
    parser.add_argument("--strict", action="store_true", help="Elevate warnings to errors")
    args = parser.parse_args()

    envelope = run_check_docs(root=args.root, registry_path=args.registry, strict=args.strict)
    print(envelope.model_dump_json(indent=2))
    sys.exit(envelope.exit_code)


if __name__ == "__main__":
    main()
