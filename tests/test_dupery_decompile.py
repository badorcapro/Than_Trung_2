"""
Unit tests for Dupery assembly decompiler and manifest manager (TASK-0010).
"""

from __future__ import annotations

import json
from pathlib import Path
import tempfile
import unittest

from scripts.agent.dupery_decompile import (
    compute_file_sha256,
    get_ilspycmd_version,
    parse_args,
    verify_decompilation,
)


class TestDuperyDecompile(unittest.TestCase):
    """Test suite for decompile script, hashing, and verification logic."""

    def test_compute_file_sha256(self) -> None:
        """Verify sha256 computation matches known digest."""
        with tempfile.NamedTemporaryFile(delete=False) as tmp:
            tmp.write(b"Hello Dupery Decompiler")
            tmp_path = Path(tmp.name)

        try:
            digest = compute_file_sha256(tmp_path)
            self.assertEqual(len(digest), 64)
            # Known sha256 of 'Hello Dupery Decompiler'
            import hashlib
            expected = hashlib.sha256(b"Hello Dupery Decompiler").hexdigest()
            self.assertEqual(digest, expected)
        finally:
            tmp_path.unlink(missing_ok=True)

    def test_get_ilspycmd_version(self) -> None:
        """Verify ilspycmd returns a non-empty version string."""
        ver = get_ilspycmd_version()
        self.assertTrue(len(ver) > 0)
        self.assertNotEqual(ver, "unknown")

    def test_verify_manifest_not_found(self) -> None:
        """Verify verification fails gracefully when manifest is missing."""
        passed, errors = verify_decompilation(
            Path("/nonexistent/manifest.json"),
            Path("/nonexistent/managed"),
        )
        self.assertFalse(passed)
        self.assertTrue(any("not found" in e.lower() for e in errors))

    def test_verify_manifest_invalid_json(self) -> None:
        """Verify verification fails when manifest contains invalid JSON."""
        with tempfile.NamedTemporaryFile("w", delete=False) as tmp:
            tmp.write("invalid json content {{{")
            tmp_path = Path(tmp.name)

        try:
            passed, errors = verify_decompilation(tmp_path, Path("/nonexistent"))
            self.assertFalse(passed)
            self.assertTrue(any("invalid json" in e.lower() for e in errors))
        finally:
            tmp_path.unlink(missing_ok=True)

    def test_verify_manifest_empty_assemblies(self) -> None:
        """Verify verification fails when assemblies dict is empty."""
        with tempfile.NamedTemporaryFile("w", delete=False) as tmp:
            tmp.write(json.dumps({"schema_version": "1.0", "assemblies": {}}))
            tmp_path = Path(tmp.name)

        try:
            passed, errors = verify_decompilation(tmp_path, Path("/nonexistent"))
            self.assertFalse(passed)
            self.assertTrue(any("no assemblies" in e.lower() for e in errors))
        finally:
            tmp_path.unlink(missing_ok=True)

    def test_verify_real_decompilation_passes(self) -> None:
        """Verify real decompilation manifest passes verification if present."""
        from scripts.agent.dupery_decompile import DEFAULT_MANIFEST, DEFAULT_MANAGED_DIR
        if DEFAULT_MANIFEST.exists() and DEFAULT_MANAGED_DIR.exists():
            passed, errors = verify_decompilation(DEFAULT_MANIFEST, DEFAULT_MANAGED_DIR)
            self.assertTrue(passed, f"Real verification failed: {errors}")
            self.assertEqual(len(errors), 0)

    def test_parse_args(self) -> None:
        """Verify CLI argument parser defaults and flags."""
        args = parse_args(["--verify"])
        self.assertTrue(args.verify)
        self.assertIsNone(args.assemblies)

        args_custom = parse_args(["--assemblies", "XNode.dll", "--out-dir", "/tmp/out"])
        self.assertFalse(args_custom.verify)
        self.assertEqual(args_custom.assemblies, ["XNode.dll"])
        self.assertEqual(args_custom.out_dir, Path("/tmp/out"))


if __name__ == "__main__":
    unittest.main()
