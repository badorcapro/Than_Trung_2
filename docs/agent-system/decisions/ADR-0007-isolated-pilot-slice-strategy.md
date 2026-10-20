# ADR-0007: Isolated Pilot Target Slice Strategy

- **Reference ID**: `ADR-ARCH-007`
- **Status**: `approved`
- **Date**: `2026-10-19`
- **Depends On**: `ARCH-CORE-001`

---

## 1. Context
Phase P1 required testing the complete task execution and verification lifecycle against a real-world software module (`docwright-ai-toolkit`). Executing tests directly on the external directory `D:/Minh/.../pdf_to_docx_converter` risks polluting its working tree and breaks local `git status` scope checks.

## 2. Decision
Extract a small, self-contained contract slice (`fileref.py`, `issues.py`, `envelope.py`) from `docwright-ai-toolkit` into a local directory `pilot/contract/` inside `AI-AGENTS-Template`.

## 3. Consequences
- **Positive**: Fully realistic pilot testing with genuine Pydantic models while maintaining 100% repository isolation and clean Scope Guard execution.
