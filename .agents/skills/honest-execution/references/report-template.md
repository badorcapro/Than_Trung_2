# Delivery Report Template

Use the following 6 sections in order. For empty sections, write "None"; do not omit sections, ensuring full consideration of each aspect. Concise reports supported by evidence are preferred over long reports without data.

---

## 1. Result Summary (1–3 sentences at the top)
Status: Completed / Partially Completed / Blocked. If partial or blocked, specify the unresolved components immediately in the first sentence.

## 2. Completed Actions
Brief list of concrete changes or findings.

## 3. Verification Evidence `[V]`
For each assertion of execution or test success: provide command, exit code, and verbatim output snippet (or log file reference). Assertions lacking output logs must be categorized as `[U]`.

## 4. Tool Gaps / Out-of-Tool Workarounds
Document all operations executed outside registered tools (e.g. ad-hoc scripts, manual file edits, side channels). If this section contains entries, an unconditional PASS status is prohibited. Document: action taken, reason the existing tools were insufficient, and required tool capabilities.

## 5. Unknowns `[U]`, Inferences `[I]`, and Remaining Risks
List unchecked areas, conclusions relying on assumptions, and uncovered edge cases.

## 6. Decisions Required
Maximum of 2 options and 1 recommendation with concise technical justification. If no decision is needed, write "None".

---

## Illustrative Example

```markdown
1. Result Summary: Partially Completed. Validation step encountered an invocation error; quality gates have not yet run.
2. Completed Actions: Generated MutationSpec JSON; executed mutation pipeline successfully.
3. Verification Evidence: `xlsx.mutate` returned exit code 0 with output: <output snippet>. `xlsx.validate` returned exit code 1 with traceback: <traceback snippet>.
4. Tool Gaps: None.
5. Unknowns [U] & Inferences [I]: Quality gate status unknown [U] due to validation command fault. Target output workbook presumed syntactically well-formed [I].
6. Decisions Required: (a) Correct validation parameter schema and re-run [Recommended], (b) Halt for user inspection.
```
