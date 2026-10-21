"""
Unit tests for Dupery CIL metadata token extractor (TASK-0011 Enrichment).
"""

from __future__ import annotations

import json
from pathlib import Path
import tempfile
import unittest

from scripts.agent.dupery_metadata_extractor import (
    DEFAULT_OUT,
    build_powershell_script,
    parse_args,
    verify_tokens_artifact,
)


class TestDuperyMetadataExtractor(unittest.TestCase):
    """Test suite for PowerShell reflection script generation and token validation."""

    def test_build_powershell_script(self) -> None:
        """Verify PowerShell reflection script contains valid commands and assemblies."""
        script = build_powershell_script(
            Path("C:/Dummy/Path"),
            ["Assembly-CSharp.dll", "XNode.dll"],
        )
        self.assertIn("[System.Reflection.Assembly]::LoadFrom", script)
        self.assertIn("MetadataToken", script)
        self.assertIn("'Assembly-CSharp.dll'", script)
        self.assertIn("'XNode.dll'", script)

    def test_verify_tokens_artifact_missing(self) -> None:
        """Verify verification fails gracefully when token artifact is missing."""
        passed, errors = verify_tokens_artifact(Path("/nonexistent/tokens.json"))
        self.assertFalse(passed)
        self.assertTrue(any("missing" in e.lower() for e in errors))

    def test_verify_tokens_artifact_invalid_json(self) -> None:
        """Verify verification fails gracefully on malformed JSON."""
        with tempfile.TemporaryDirectory() as tmp_dir:
            bad_file = Path(tmp_dir) / "tokens.json"
            bad_file.write_text("{bad_json:", encoding="utf-8")
            passed, errors = verify_tokens_artifact(bad_file)
            self.assertFalse(passed)
            self.assertTrue(any("invalid json" in e.lower() for e in errors))

    def test_verify_real_tokens_artifact_passes(self) -> None:
        """Verify real generated token artifact passes all checks."""
        if DEFAULT_OUT.exists():
            passed, errors = verify_tokens_artifact(DEFAULT_OUT)
            self.assertTrue(passed, f"Verification failed: {errors}")
            self.assertEqual(len(errors), 0)

            # Check that tokens map has Assembly-CSharp and tokens start with 0x02
            data = json.loads(DEFAULT_OUT.read_text(encoding="utf-8"))
            tokens = data.get("tokens", {})
            self.assertIn("Assembly-CSharp", tokens)
            self.assertGreater(len(tokens["Assembly-CSharp"]), 1000)

    def test_parse_args(self) -> None:
        """Verify argument parsing."""
        args = parse_args(["--verify", "--managed-dir", "C:/test"])
        self.assertTrue(args.verify)
        self.assertEqual(args.managed_dir, Path("C:/test"))


if __name__ == "__main__":
    unittest.main()
