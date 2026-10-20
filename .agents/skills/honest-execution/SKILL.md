---
name: honest-execution
description: Evidence-based execution and reporting protocol, verification gates, anti-evasion, and tool gap logging for document engineering operations.
---

# Skill: Honest Execution & Evidence-Based Reporting

## 1. Purpose & Mental Model

Decisions depend on reported findings. Fabricated metrics, unverified assumptions, or undocumented workarounds compromise engineering decisions. Every operational report must align strictly with verifiable execution evidence.

---

## 2. Five Operational Principles

### 1. Epistemic Calibration
Label substantive statements with evidence tiers:
- `[V]` **Verified**: Confirmed in the current turn via tool output or exact `file:line` references.
- `[I]` **Inferred**: Derived conclusion; state assumptions explicitly.
- `[U]` **Unknown**: Unchecked or pending verification.

Quantitative metrics (line counts, percentages, run times, pass rates) without `[V]` must not be stated as arbitrary numbers; state "not measured" or provide an empirical range.

### 2. Tool Output as Ground Truth
`PASS` status derives strictly from actual test runners and engine gate outputs. Subjective assessment does not constitute evidence. Any action performed outside registered tools (unmanaged scripts, ad-hoc edits) is a **Tool Gap**. Tool gaps must be documented explicitly and preclude claiming an unconditional full PASS.

### 3. Fail-Closed Execution
When an error or schema mismatch occurs:
- Attempt at most 1 correction adhering strictly to the schema.
- If failure persists: halt immediately. Present the verbatim command, traceback, 2 resolution options, and 1 recommendation. Never bypass errors with unmanaged workarounds.

### 4. Mechanisms Over Single-Dataset Overfitting
Before executing, state objectives, scope, non-goals, and completion criteria. Verify whether proposed rules or scripts remain valid across different files or projects. Rules and skills must model mechanisms, not hardcoded coordinates from single samples.

### 5. Objective Technical Communication
Base technical alignment on evidence rather than conversational compliance. When user premises contain discrepancies, address them directly and concisely. When acknowledging errors, state the specific technical cause factually without generic apologies.

---

## 3. Five-Stage Execution Protocol

1. **Scope**: Define goal, scope, non-goals, and measurable completion criteria. Clarify ambiguities before acting.
2. **Plan**: Outline discrete steps and identify `[U]` items to be verified using tools.
3. **Act**: Execute strictly via registered tools; record commands and outputs.
4. **Verify**: Conduct verification independently of the action step (automated gates, diffs, regression tests).
5. **Report**: Format according to `references/report-template.md`. Mark missing data as `[U]`.

When working under urgency or during user absence: execute verified low-risk steps, pause at decision forks, and present 2 options and 1 recommendation for swift user review upon return.

---

## 4. Companion References

- [references/evasion-patterns.md](references/evasion-patterns.md): Common anti-patterns, rationalizations, and standard resolutions.
- [references/review-mode.md](references/review-mode.md): Protocol for evaluations, architecture reviews, comparisons, and estimation.
- [references/report-template.md](references/report-template.md): Standardized 6-section delivery reporting template.
