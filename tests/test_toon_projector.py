"""
Unit and Integration Tests for DEC-15 TOON Context Projector & Canonical JSON Layer
(tests/test_toon_projector.py).
"""

from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from scripts.agent.models import (
    compute_file_sha256,
    compute_raw_sha256,
    write_canonical_json,
)
from scripts.agent.toon_projector import (
    HeuristicConfig,
    encode_toon,
    evaluate_tabular_gate,
    format_projection,
    verify_toon_projector,
)


class TestDec15ToonProjector(unittest.TestCase):
    """Verify DEC-15.1 (Canonical JSON), DEC-15.3 (Per-Array Gate), and DEC-15.4 (Native PK & Provenance)."""

    def test_canonical_json_and_raw_sha256_lf_determinism(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "sample.json"
            payload = {"b": 1, "a": ["x", "y"]}
            raw_digest = write_canonical_json(target, payload)
            raw_bytes = target.read_bytes()
            self.assertNotIn(b"\r\n", raw_bytes)
            self.assertTrue(raw_bytes.endswith(b"\n"))
            self.assertEqual(raw_digest, compute_raw_sha256(target))
            self.assertEqual(raw_digest, compute_file_sha256(target))

    def test_tabular_gate_places_native_primary_key_first(self) -> None:
        rows = [
            {"layer": "domain", "loc": 100 + i, "path": f"scripts/file_{i}.gd"}
            for i in range(6)
        ]
        headers = evaluate_tabular_gate(rows, HeuristicConfig(min_rows=5))
        self.assertEqual(headers, ["path", "layer", "loc"])
        toon_text = encode_toon({"scripts": rows}, HeuristicConfig(min_rows=5))
        self.assertIn("scripts[6]{path,layer,loc}:", toon_text)
        self.assertIn("  scripts/file_0.gd,domain,100", toon_text)

    def test_per_array_heuristic_fallback_preserves_valid_sibling_table(self) -> None:
        doc = {
            "valid_table": [
                {"name": f"Node{i}", "id": f"N-{i}", "count": i}
                for i in range(5)
            ],
            "sparse_table": [
                {"id": f"S-{i}", "opt_a": None, "opt_b": None}
                for i in range(5)
            ],
            "verbose_table": [
                {"id": f"V-{i}", "body": "x" * 150}
                for i in range(5)
            ],
        }
        toon_out = encode_toon(doc, HeuristicConfig(min_rows=5, max_null_ratio=0.15, max_free_text_chars=120))
        # Valid sibling table MUST be tabular with id at column 0
        self.assertIn("valid_table[5]{id,name,count}:", toon_out)
        # Sparse and verbose tables MUST fallback to list items without breaking valid_table
        self.assertIn("sparse_table[5]:", toon_out)
        self.assertNotIn("sparse_table[5]{", toon_out)
        self.assertIn("verbose_table[5]:", toon_out)
        self.assertNotIn("verbose_table[5]{", toon_out)

    def test_provenance_header_and_real_godot_index_benchmark(self) -> None:
        res = verify_toon_projector()
        self.assertTrue(res.success, f"verify_toon_projector failed: {res.issues}")
        full_bench = res.data["full_document_benchmark"]
        self.assertGreater(full_bench["savings_vs_pretty_pct"], 50.0)
        god_bench = res.data["god_files_table_benchmark"]
        self.assertGreater(god_bench["savings_vs_pretty_pct"], 45.0)

        with tempfile.TemporaryDirectory() as tmp:
            src = Path(tmp) / "artifact.json"
            data = {"items": [{"id": f"ID-{i}", "val": i} for i in range(5)]}
            digest = write_canonical_json(src, data)
            projected = format_projection(data, "toon", source_path=src, workspace_root=Path(tmp))
            first_line = projected.splitlines()[0]
            self.assertIn("source=artifact.json", first_line)
            self.assertIn(f"sha256_raw_bytes={digest}", first_line)
            self.assertIn("records=5", first_line)


if __name__ == "__main__":
    unittest.main()
