# ADR-0002: Verification Runtime & Schema Dependencies

- **Reference ID**: `ADR-ARCH-002`
- **Status**: `approved`
- **Date**: `2026-10-19`
- **Depends On**: `ARCH-CORE-001`

---

## 1. Context
Verification scripts must perform strict schema validation over Reference Registry, Task Contracts, and Evidence Receipts. We considered pure standard library Python vs dedicated schema libraries (Pydantic / jsonschema).

## 2. Decision
Use Python 3 with dedicated schema libraries specified via `requirements.txt`:
- `pydantic>=2.0.0` for structured contracts, strict model validation (`extra="forbid"`), and JSON serialization.
- `PyYAML>=6.0` for parsing Task Contract YAML frontmatter.
- `jsonschema>=4.0.0` for cross-language schema compatibility.

## 3. Consequences
- **Positive**: Compile-time/import-time schema guarantees, clear error diagnostics for AI, eliminate custom brittle ad-hoc parsers.
- **Negative**: Requires `pip install -r requirements.txt` on a clean machine (verified pre-installed in local environment).
