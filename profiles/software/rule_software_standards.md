---
trigger: glob
globs: **/*.py, **/*.ts, **/*.tsx, **/*.js, **/*.go, **/*.rs
description: Software engineering code quality, strict typing, modular line limits, and deterministic unit testing invariants. Tiêu chuẩn kỹ thuật phần mềm, kiểu dữ liệu chặt chẽ, giới hạn 400 dòng/file, kiểm thử tự động.
---

# Rule: Software Engineering Domain Standards

> **Scope**: Activated via `glob` when viewing or editing software source/test files.

---

## 1. Code Quality & Modularity Invariants

1. **Line Limits & Single Responsibility**:
   - Target $\le 300$ lines/file; hard cap **400 lines/file**.
   - Never strip type annotations, docstrings, or error handlers to game line limits; split into logical submodules instead.
2. **Type Safety & Data Contracts**:
   - Enforce explicit type annotations on all public functions and methods.
   - Validate external inputs/outputs via schema models (`pydantic` / `zod` / typed structs) with `extra="forbid"`.
3. **Guard Clauses & Explicit Errors**:
   - Prefer early returns (guard clauses) over deeply nested conditionals.
   - Never swallow exceptions silently (`except Exception: pass` is forbidden).
4. **Deterministic Testing**:
   - Every behavioral change or bugfix requires a deterministic automated unit test that runs offline without external network calls.
