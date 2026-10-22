"""
DEC-15 Layer 3 Context Projection Engine (scripts/agent/toon_projector.py).
Provides read-only TOON (Token-Oriented Object Notation), JSON Compact, and JSONL
projections from verified Layer 1 JSON artifacts with a Per-Array Heuristic Gate,
Native Primary Key column ordering, and 1-line Provenance Envelope.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
import json
from pathlib import Path
import re
import sys
from typing import Any, Iterable, List, Optional, Sequence, Tuple

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.models import FixableBy, Issue, ResultEnvelope, Severity, compute_raw_sha256

ENCODER_VERSION = "toon_projector/1.0"
PRIMARY_KEY_CANDIDATES: Tuple[str, ...] = (
    "id", "path", "node_path", "symbol_id", "edge_id", "file_id", "rank", "name",
)
_NUMERIC_RE = re.compile(r"^-?(?:0|[1-9]\d*)(?:\.\d+)?(?:e[+-]?\d+)?$", re.IGNORECASE)
_UNQUOTED_KEY_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_.-]*$")
_UNSAFE_STR_CHARS = set(',:"\\\n\r\t[]{}-#')
_TOKEN_SPLIT_RE = re.compile(r"[A-Za-z0-9_]+|[^\sA-Za-z0-9_]")


@dataclass(frozen=True)
class HeuristicConfig:
    """Per-array heuristic thresholds governing TOON tabular eligibility (DEC-15.3)."""
    min_rows: int = 5
    max_columns: int = 8
    max_nesting_depth: int = 4
    max_null_ratio: float = 0.15
    max_free_text_chars: int = 120
    indent: int = 2


def is_json_primitive(value: Any) -> bool:
    """Return True if value is a JSON scalar (None, bool, int, float, str)."""
    return value is None or isinstance(value, (bool, int, float, str))


def escape_toon_string(value: str) -> str:
    """Escape backslashes, quotes, and control characters per TOON spec."""
    return (
        value.replace("\\", "\\\\").replace('"', '\\"')
        .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t")
    )


def is_safe_unquoted_string(value: str) -> bool:
    """Return True if a string can be emitted without quotes in TOON."""
    if not value or value != value.strip() or value in ("true", "false", "null"):
        return False
    if _NUMERIC_RE.match(value):
        return False
    return not any(ch in _UNSAFE_STR_CHARS for ch in value)


def encode_primitive(value: Any) -> str:
    """Encode a JSON scalar into its TOON literal representation."""
    if value is None:
        return "null"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return str(value)
    text = str(value)
    return text if is_safe_unquoted_string(text) else f'"{escape_toon_string(text)}"'


def encode_key(key: str) -> str:
    """Encode an object key or header column name."""
    return key if _UNQUOTED_KEY_RE.match(key) else f'"{escape_toon_string(key)}"'


def order_tabular_headers(keys: Sequence[str]) -> List[str]:
    """Place the first matching Native Primary Key at column 0 (DEC-15.4)."""
    key_list = list(keys)
    for candidate in PRIMARY_KEY_CANDIDATES:
        if candidate in key_list:
            key_list.remove(candidate)
            return [candidate] + key_list
    return key_list


def evaluate_tabular_gate(
    rows: Sequence[Any], config: HeuristicConfig, depth: int = 0
) -> Optional[List[str]]:
    """Evaluate Per-Array Heuristic Gate (DEC-15.3); return ordered headers or None."""
    if len(rows) < config.min_rows or depth > config.max_nesting_depth:
        return None
    if not all(isinstance(r, dict) and len(r) > 0 for r in rows):
        return None
    first_keys = list(rows[0].keys())
    num_cols = len(first_keys)
    if num_cols == 0 or num_cols > config.max_columns:
        return None

    expected_key_set = set(first_keys)
    null_cells = 0
    total_cells = len(rows) * num_cols
    for row in rows:
        if set(row.keys()) != expected_key_set:
            return None
        for col in first_keys:
            val = row[col]
            if not is_json_primitive(val):
                return None
            if val is None or val == "":
                null_cells += 1
            elif isinstance(val, str) and len(val) > config.max_free_text_chars:
                return None

    if total_cells > 0 and (null_cells / total_cells) > config.max_null_ratio:
        return None
    return order_tabular_headers(first_keys)


def _indent_line(depth: int, content: str, indent_size: int) -> str:
    return (" " * (depth * indent_size)) + content


def _encode_array_lines(
    key: Optional[str], items: Sequence[Any], depth: int, config: HeuristicConfig
) -> Iterable[str]:
    prefix = encode_key(key) if key is not None else ""
    if len(items) == 0:
        yield _indent_line(depth, f"{prefix}: []" if prefix else "[]", config.indent)
        return
    if all(is_json_primitive(x) for x in items):
        joined = ",".join(encode_primitive(x) for x in items)
        if len(joined) <= config.max_free_text_chars:
            yield _indent_line(depth, f"{prefix}[{len(items)}]: {joined}", config.indent)
            return

    headers = evaluate_tabular_gate(items, config, depth)
    if headers is not None:
        cols_str = ",".join(encode_key(h) for h in headers)
        yield _indent_line(depth, f"{prefix}[{len(items)}]{{{cols_str}}}:", config.indent)
        for row in items:
            yield _indent_line(depth + 1, ",".join(encode_primitive(row[h]) for h in headers), config.indent)
        return

    yield _indent_line(depth, f"{prefix}[{len(items)}]:", config.indent)
    for item in items:
        if is_json_primitive(item):
            yield _indent_line(depth + 1, f"- {encode_primitive(item)}", config.indent)
        elif isinstance(item, dict) and item:
            entries = list(item.items())
            first_k, first_v = entries[0]
            if is_json_primitive(first_v):
                yield _indent_line(depth + 1, f"- {encode_key(first_k)}: {encode_primitive(first_v)}", config.indent)
            else:
                yield _indent_line(depth + 1, f"- {encode_key(first_k)}:", config.indent)
                yield from _encode_value_lines(first_v, depth + 2, config)
            for rest_k, rest_v in entries[1:]:
                yield from _encode_kv_lines(rest_k, rest_v, depth + 2, config)
        else:
            yield _indent_line(depth + 1, f"- {json.dumps(item, ensure_ascii=False)}", config.indent)


def _encode_kv_lines(key: str, value: Any, depth: int, config: HeuristicConfig) -> Iterable[str]:
    enc_k = encode_key(key)
    if is_json_primitive(value):
        yield _indent_line(depth, f"{enc_k}: {encode_primitive(value)}", config.indent)
    elif isinstance(value, list):
        yield from _encode_array_lines(key, value, depth, config)
    elif isinstance(value, dict):
        if not value:
            yield _indent_line(depth, f"{enc_k}: {{}}", config.indent)
            return
        yield _indent_line(depth, f"{enc_k}:", config.indent)
        for child_k, child_v in value.items():
            yield from _encode_kv_lines(child_k, child_v, depth + 1, config)


def _encode_value_lines(value: Any, depth: int, config: HeuristicConfig) -> Iterable[str]:
    if is_json_primitive(value):
        yield _indent_line(depth, encode_primitive(value), config.indent)
    elif isinstance(value, list):
        yield from _encode_array_lines(None, value, depth, config)
    elif isinstance(value, dict):
        for k, v in value.items():
            yield from _encode_kv_lines(k, v, depth, config)


def encode_toon(value: Any, config: Optional[HeuristicConfig] = None) -> str:
    """Encode an arbitrary JSON-compatible value into TOON format with Per-Array Heuristic Gate."""
    return "\n".join(_encode_value_lines(value, 0, config or HeuristicConfig()))


def select_subtree(data: Any, select_path: Optional[str]) -> Any:
    """Select a nested key path (dotted) or subset of columns (`path:col1,col2`)."""
    if not select_path:
        return data
    path_part, _, cols_part = select_path.partition(":")
    current = data
    for segment in path_part.split("."):
        if not segment:
            continue
        if isinstance(current, dict) and segment in current:
            current = current[segment]
        else:
            raise KeyError(f"Selection path segment '{segment}' not found.")
    if cols_part and isinstance(current, list):
        wanted = [c.strip() for c in cols_part.split(",") if c.strip()]
        current = [{c: r.get(c) for c in wanted if isinstance(r, dict) and c in r} for r in current]
    return current


def count_projected_records(data: Any) -> int:
    """Count primary records in a projected payload."""
    if isinstance(data, list):
        return len(data)
    if isinstance(data, dict):
        total = sum(len(v) for v in data.values() if isinstance(v, list))
        return total if total > 0 else len(data)
    return 1


def format_projection(
    data: Any,
    format_name: str = "toon",
    source_path: Optional[Path] = None,
    workspace_root: Path = ROOT_DIR,
    select_path: Optional[str] = None,
    config: Optional[HeuristicConfig] = None,
) -> str:
    """Format verified Layer 1 data into a Layer 3 projection (toon, json, json_compact, jsonl)."""
    selected = select_subtree(data, select_path)
    fmt = format_name.lower().strip()
    if fmt == "json":
        return json.dumps(selected, indent=2, ensure_ascii=False)
    if fmt == "json_compact":
        return json.dumps(selected, separators=(",", ":"), ensure_ascii=False)
    if fmt == "jsonl":
        if isinstance(selected, list):
            return "\n".join(json.dumps(x, separators=(",", ":"), ensure_ascii=False) for x in selected)
        return json.dumps(selected, separators=(",", ":"), ensure_ascii=False)
    if fmt != "toon":
        raise ValueError(f"Unsupported projection format '{format_name}'.")

    body = encode_toon(selected, config=config)
    if source_path is not None and source_path.exists():
        try:
            rel_src = source_path.resolve().relative_to(workspace_root.resolve()).as_posix()
        except ValueError:
            rel_src = source_path.as_posix()
        raw_hash = compute_raw_sha256(source_path)
        sel_tag = f" | select={select_path}" if select_path else ""
        header = (
            f"# toon_projection: source={rel_src} | sha256_raw_bytes={raw_hash} "
            f"| records={count_projected_records(selected)}{sel_tag} | encoder={ENCODER_VERSION}"
        )
        return f"{header}\n{body}"
    return body


def estimate_tokens(text: str) -> int:
    """Estimate BPE token count for structured data payloads (punctuation + word tokens)."""
    return len(_TOKEN_SPLIT_RE.findall(text))


def verify_toon_projector(workspace_root: Path = ROOT_DIR) -> ResultEnvelope:
    """Run deterministic self-verification and benchmark on project_index.json."""
    issues: List[Issue] = []
    index_path = workspace_root / "docs/agent-system/evidence/godot/project_index.json"
    if not index_path.exists():
        issues.append(Issue(
            code="ERR_TOON_BENCHMARK_SOURCE_MISSING", severity=Severity.ERROR,
            message="project_index.json missing for TOON verification benchmark.",
            location="docs/agent-system/evidence/godot/project_index.json", fixable_by=FixableBy.AI,
        ))
        return ResultEnvelope(success=False, tool="toon_projector", issues=issues)

    raw_data = json.loads(index_path.read_text(encoding="utf-8"))
    tok_json = estimate_tokens(format_projection(raw_data, "json", index_path, workspace_root))
    tok_compact = estimate_tokens(format_projection(raw_data, "json_compact", index_path, workspace_root))
    tok_toon = estimate_tokens(format_projection(raw_data, "toon", index_path, workspace_root))
    tok_god_json = estimate_tokens(format_projection(raw_data, "json", index_path, workspace_root, "god_files_ranked"))
    tok_god_toon = estimate_tokens(format_projection(raw_data, "toon", index_path, workspace_root, "god_files_ranked"))

    if tok_god_toon >= tok_god_json:
        issues.append(Issue(
            code="ERR_TOON_NO_SAVINGS", severity=Severity.ERROR,
            message="TOON projection failed to reduce token count on god_files_ranked.",
            location="scripts/agent/toon_projector.py", fixable_by=FixableBy.AI,
        ))
    return ResultEnvelope(
        success=not any(i.severity == Severity.ERROR for i in issues),
        tool="toon_projector",
        issues=issues,
        data={
            "source": "docs/agent-system/evidence/godot/project_index.json",
            "sha256_raw_bytes": compute_raw_sha256(index_path),
            "full_document_benchmark": {
                "json_pretty_tokens": tok_json,
                "json_compact_tokens": tok_compact,
                "toon_tokens": tok_toon,
                "savings_vs_pretty_pct": round((1.0 - (tok_toon / max(1, tok_json))) * 100.0, 2),
                "savings_vs_compact_pct": round((1.0 - (tok_toon / max(1, tok_compact))) * 100.0, 2),
            },
            "god_files_table_benchmark": {
                "json_pretty_tokens": tok_god_json,
                "toon_tokens": tok_god_toon,
                "savings_vs_pretty_pct": round((1.0 - (tok_god_toon / max(1, tok_god_json))) * 100.0, 2),
            },
        },
    )


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="DEC-15 Layer 3 TOON Context Projector")
    parser.add_argument("--input", type=Path, help="Path to Layer 1 JSON file to project")
    parser.add_argument("--format", default="toon", choices=["toon", "json", "json_compact", "jsonl"])
    parser.add_argument("--select", default=None, help="Optional dotted path and column filter")
    parser.add_argument("--verify", action="store_true", help="Run self-verification and token benchmark")
    args = parser.parse_args(argv)
    if args.verify:
        env = verify_toon_projector(ROOT_DIR)
        print(json.dumps(env.model_dump(mode="json"), indent=2, ensure_ascii=False))
        return env.exit_code
    if not args.input or not args.input.exists():
        print("Error: --input <valid JSON path> or --verify is required.", file=sys.stderr)
        return 2
    data = json.loads(args.input.read_text(encoding="utf-8"))
    print(format_projection(data, args.format, args.input, ROOT_DIR, select_path=args.select))
    return 0


if __name__ == "__main__":
    sys.exit(main())
