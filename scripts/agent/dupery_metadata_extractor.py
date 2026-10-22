"""
CIL Metadata Token Extractor for Dupery Assemblies (TASK-0011 Enrichment).
Extracts TypeDef metadata tokens (0x02000xxx) from .NET assemblies using reflection
to establish immutable coordinates for REA inspection and runtime hooking.
"""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import subprocess
import sys
from typing import Any, Dict, List, Optional, Tuple

ROOT_DIR = Path(__file__).resolve().parents[2]
DEFAULT_MANAGED = Path("D:/Minh/Steam/steamapps/common/Dupery/Dupery_Data/Managed")
DEFAULT_OUT = ROOT_DIR / "docs/agent-system/evidence/dupery/dupery_cil_tokens.json"

TARGET_ASSEMBLIES = [
    "Assembly-CSharp.dll",
    "gildedrunegames.grglib.dll",
    "gildedrunegames.grglocalisation.dll",
    "XNode.dll",
    "FMODUnity.dll",
]


def build_powershell_script(managed_dir: Path, assemblies: List[str]) -> str:
    """Generate PowerShell reflection script to extract TypeDef tokens."""
    norm_managed = managed_dir.as_posix().replace("/", "\\")
    asm_list_str = "@(" + ", ".join(f"'{a}'" for a in assemblies) + ")"
    return f"""
$ErrorActionPreference = 'Stop'
$managed = '{norm_managed}'
$assemblies = {asm_list_str}
$result = [ordered]@{{}}

foreach ($asmName in $assemblies) {{
    $dllPath = Join-Path $managed $asmName
    if (-not (Test-Path $dllPath)) {{ continue }}
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($asmName)
    $asm = [System.Reflection.Assembly]::LoadFrom($dllPath)
    $typesDict = [ordered]@{{}}
    foreach ($t in $asm.GetTypes()) {{
        if ($null -ne $t.FullName) {{
            $tokenHex = '0x{{0:X8}}' -f $t.MetadataToken
            $typesDict[$t.FullName] = $tokenHex
        }}
    }}
    $result[$stem] = $typesDict
}}

$result | ConvertTo-Json -Depth 4
"""


def extract_cil_metadata_tokens(
    managed_dir: Path,
    assemblies: Optional[List[str]] = None,
) -> Dict[str, Dict[str, str]]:
    """Execute reflection script and return {assembly: {full_name: token}}."""
    targets = assemblies or TARGET_ASSEMBLIES
    ps_code = build_powershell_script(managed_dir, targets)

    proc = subprocess.run(
        ["powershell", "-NoProfile", "-NonInteractive", "-Command", ps_code],
        capture_output=True,
        text=True,
        check=False,
    )
    if proc.returncode != 0:
        err = proc.stderr.strip() or f"exited with code {proc.returncode}"
        raise RuntimeError(f"PowerShell reflection extraction failed: {err}")

    raw_json = proc.stdout.strip()
    if not raw_json:
        return {}
    return json.loads(raw_json)


def generate_token_artifact(
    managed_dir: Path,
    out_path: Path,
    assemblies: Optional[List[str]] = None,
) -> Dict[str, Any]:
    """Extract tokens and write canonical JSON artifact."""
    tokens_by_asm = extract_cil_metadata_tokens(managed_dir, assemblies)
    total_types = sum(len(v) for v in tokens_by_asm.values())

    payload = {
        "schema_version": "1.0",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "managed_dir": managed_dir.as_posix(),
        "total_assemblies": len(tokens_by_asm),
        "total_types_with_tokens": total_types,
        "tokens": tokens_by_asm,
    }
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return payload


def verify_tokens_artifact(out_path: Path) -> Tuple[bool, List[str]]:
    """Verify that token artifact exists, is valid JSON, and has valid token formats."""
    errors: List[str] = []
    if not out_path.exists():
        return False, [f"Token artifact missing: {out_path}"]

    try:
        data = json.loads(out_path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError) as exc:
        return False, [f"Invalid JSON in token artifact: {exc}"]

    tokens = data.get("tokens", {})
    if not tokens:
        return False, ["Tokens dictionary is empty"]

    for asm, type_map in tokens.items():
        if not type_map:
            errors.append(f"Assembly '{asm}' has no token entries")
            continue
        for name, token in list(type_map.items())[:10]:
            if not isinstance(token, str) or not token.startswith("0x02"):
                errors.append(f"Invalid TypeDef token format for '{name}' in '{asm}': {token}")
                break

    return len(errors) == 0, errors


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    """Parse CLI arguments."""
    parser = argparse.ArgumentParser(description="Dupery CIL Metadata Token Extractor.")
    parser.add_argument("--managed-dir", type=Path, default=DEFAULT_MANAGED, help="Path to Managed directory")
    parser.add_argument("--out-file", type=Path, default=DEFAULT_OUT, help="Path to output dupery_cil_tokens.json")
    parser.add_argument("--verify", action="store_true", help="Verify token artifact integrity")
    return parser.parse_args(argv)


def main(argv: Optional[List[str]] = None) -> int:
    """CLI entry point."""
    args = parse_args(argv)
    if args.verify:
        passed, errors = verify_tokens_artifact(args.out_file)
        if passed:
            print("OK: CIL Metadata Token artifact verified. All tokens format valid (0x02xxxxxx).")
            return 0
        print("FAIL: Token artifact verification failed:", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1

    print(f"Extracting CIL metadata tokens from {args.managed_dir}...")
    result = generate_token_artifact(args.managed_dir, args.out_file)
    print(f"Extracted {result['total_types_with_tokens']} tokens across {result['total_assemblies']} assemblies.")
    print(f"Artifact written to: {args.out_file}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
