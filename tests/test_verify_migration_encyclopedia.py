"""Unit tests for Dupery Master Architecture Encyclopedia Verifier (TASK-0031)."""

import tempfile
import unittest
from pathlib import Path

from scripts.agent.verify_migration_encyclopedia import (
    DEFAULT_ENCYCLOPEDIA,
    REQUIRED_SECTIONS,
    audit_encyclopedia_document,
)


class TestVerifyMigrationEncyclopedia(unittest.TestCase):
    """Test suite verifying encyclopedia structural integrity and migration invariants."""

    def test_official_encyclopedia_passes_audit(self) -> None:
        passed, errors, stats = audit_encyclopedia_document(DEFAULT_ENCYCLOPEDIA)
        self.assertTrue(passed, f"Encyclopedia audit failed with errors: {errors}")
        self.assertEqual(len(errors), 0)
        self.assertEqual(stats["sections_verified"], len(REQUIRED_SECTIONS))
        self.assertGreaterEqual(stats["lines_count"], 100)

    def test_missing_document_fails_gracefully(self) -> None:
        missing_path = Path("/nonexistent/encyclopedia.md")
        passed, errors, _ = audit_encyclopedia_document(missing_path)
        self.assertFalse(passed)
        self.assertTrue(any("missing" in err.lower() for err in errors))

    def test_incomplete_document_detects_missing_sections(self) -> None:
        with tempfile.NamedTemporaryFile("w", delete=False, encoding="utf-8") as tmp:
            tmp.write("# Minimal Title\nJust some random text\n")
            tmp_path = Path(tmp.name)

        try:
            passed, errors, _ = audit_encyclopedia_document(tmp_path)
            self.assertFalse(passed)
            self.assertTrue(any("Missing required section header" in err for err in errors))
        finally:
            tmp_path.unlink(missing_ok=True)


if __name__ == "__main__":
    unittest.main()
