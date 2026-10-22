"""
Verification Script for TASK-0003 (Phase 2 Prep).
Validates presence and schema of Dupery build/toolchain manifests,
availability of CLI tools (ilspycmd, UnityPy, pefile), and Probe 1 extraction facts.
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.models import FixableBy, Issue, ResultEnvelope, Severity


def verify_p2_prep(workspace_root: Path) -> ResultEnvelope:
    issues: list[Issue] = []

    # 1. Verify ilspycmd CLI
    ilspycmd_path = shutil.which("ilspycmd")
    if not ilspycmd_path:
        issues.append(
            Issue(
                code="ERR_TOOL_ILSPYCMD_MISSING",
                severity=Severity.ERROR,
                message="ilspycmd CLI tool is not found on PATH.",
                location="ilspycmd",
                fixable_by=FixableBy.HUMAN,
                suggested_action="Run 'dotnet tool install -g ilspycmd --version 9.0.0.7889'.",
            )
        )
    else:
        try:
            res = subprocess.run(
                ["ilspycmd", "--version"],
                capture_output=True,
                text=True,
                check=False,
            )
            if res.returncode != 0:
                issues.append(
                    Issue(
                        code="ERR_TOOL_ILSPYCMD_FAIL",
                        severity=Severity.ERROR,
                        message=f"ilspycmd --version returned exit code {res.returncode}.",
                        location="ilspycmd",
                        fixable_by=FixableBy.HUMAN,
                    )
                )
        except Exception as exc:
            issues.append(
                Issue(
                    code="ERR_TOOL_ILSPYCMD_EXEC",
                    severity=Severity.ERROR,
                    message=f"Failed to execute ilspycmd: {exc}",
                    location="ilspycmd",
                    fixable_by=FixableBy.HUMAN,
                )
            )

    # 2. Verify Python UnityPy & pefile
    try:
        import UnityPy  # noqa: F401
    except ImportError as exc:
        issues.append(
            Issue(
                code="ERR_PKG_UNITYPY_MISSING",
                severity=Severity.ERROR,
                message=f"UnityPy Python package is not importable: {exc}",
                location="UnityPy",
                fixable_by=FixableBy.AI,
                suggested_action="Run 'python -m pip install UnityPy'.",
            )
        )

    try:
        import pefile  # noqa: F401
    except ImportError as exc:
        issues.append(
            Issue(
                code="ERR_PKG_PEFILE_MISSING",
                severity=Severity.ERROR,
                message=f"pefile Python package is not importable: {exc}",
                location="pefile",
                fixable_by=FixableBy.AI,
                suggested_action="Run 'python -m pip install pefile'.",
            )
        )

    # 3. Verify Manifest and Probe files
    evidence_dir = workspace_root / "docs/agent-system/evidence/dupery"
    build_manifest = evidence_dir / "dupery_build_manifest.json"
    toolchain_manifest = evidence_dir / "dupery_toolchain_manifest.json"
    build_classification = evidence_dir / "dupery_build_classification.md"
    probe1_file = evidence_dir / "probes/probe1_lineup_controller.json"

    for file_path in [build_manifest, toolchain_manifest, build_classification, probe1_file]:
        if not file_path.exists():
            issues.append(
                Issue(
                    code="ERR_FILE_MISSING",
                    severity=Severity.ERROR,
                    message=f"Required evidence file missing: '{file_path.relative_to(workspace_root).as_posix()}'",
                    location=file_path.relative_to(workspace_root).as_posix(),
                    fixable_by=FixableBy.AI,
                )
            )

    # 4. Verify Content & Schema
    if build_manifest.exists():
        try:
            bm_data = json.loads(build_manifest.read_text(encoding="utf-8"))
            if len(bm_data.get("managed_assemblies", [])) < 50:
                issues.append(
                    Issue(
                        code="ERR_BUILD_MANIFEST_INCOMPLETE",
                        severity=Severity.ERROR,
                        message="dupery_build_manifest.json contains fewer than 50 managed assemblies.",
                        location=build_manifest.relative_to(workspace_root).as_posix(),
                        fixable_by=FixableBy.AI,
                    )
                )
        except Exception as exc:
            issues.append(
                Issue(
                    code="ERR_BUILD_MANIFEST_INVALID",
                    severity=Severity.ERROR,
                    message=f"dupery_build_manifest.json is not valid JSON: {exc}",
                    location=build_manifest.relative_to(workspace_root).as_posix(),
                    fixable_by=FixableBy.AI,
                )
            )

    if probe1_file.exists():
        try:
            p1_data = json.loads(probe1_file.read_text(encoding="utf-8"))
            result = p1_data.get("result", {})
            types = [t.get("full_name") for t in result.get("types", [])]
            if "Lineup.LineupController" not in types:
                issues.append(
                    Issue(
                        code="ERR_PROBE1_MISSING_TYPE",
                        severity=Severity.ERROR,
                        message="probe1_lineup_controller.json does not contain Lineup.LineupController.",
                        location=probe1_file.relative_to(workspace_root).as_posix(),
                        fixable_by=FixableBy.AI,
                    )
                )
            if len(result.get("methods", [])) < 15:
                issues.append(
                    Issue(
                        code="ERR_PROBE1_INCOMPLETE_METHODS",
                        severity=Severity.ERROR,
                        message=f"probe1_lineup_controller.json has only {len(result.get('methods', []))} methods (expected >= 15).",
                        location=probe1_file.relative_to(workspace_root).as_posix(),
                        fixable_by=FixableBy.AI,
                    )
                )
        except Exception as exc:
            issues.append(
                Issue(
                    code="ERR_PROBE1_INVALID",
                    severity=Severity.ERROR,
                    message=f"probe1_lineup_controller.json is not valid JSON: {exc}",
                    location=probe1_file.relative_to(workspace_root).as_posix(),
                    fixable_by=FixableBy.AI,
                )
            )

    success = not any(i.severity == Severity.ERROR for i in issues)
    return ResultEnvelope(
        success=success,
        tool="verify_dupery_p2_prep",
        issues=issues,
        data={
            "ilspycmd_available": bool(ilspycmd_path),
            "manifests_verified": True if success else False,
            "probe1_verified": True if success else False,
        },
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Verify Dupery P2-Prep Toolchain & Artifacts")
    parser.add_argument("--task", default="TASK-0003", help="Task ID being verified")
    args = parser.parse_args()

    envelope = verify_p2_prep(ROOT_DIR)
    print(json.dumps(envelope.model_dump(mode="json"), indent=2))
    sys.exit(envelope.exit_code)


if __name__ == "__main__":
    main()
