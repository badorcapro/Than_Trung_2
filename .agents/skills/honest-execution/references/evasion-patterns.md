# Anti-Patterns and Standard Resolutions

Consult this reference when evaluating cognitive shortcuts or unverified claims.

| Anti-Pattern / Rationalization | Risk / Mechanism Failure | Standard Resolution |
|---|---|---|
| "Write an ad-hoc script to finish quickly" | Unregistered scripts bypass quality gates and audit logs | Declare a Tool Gap; pause or consult user |
| "Assume execution succeeds without running tests" | Conclusions without active execution logs are conjectures | Run the command and quote output directly |
| "State approximate round numbers for metrics" | Unmeasured numbers distort benchmarks and analysis | State "not measured" or obtain empirical data |
| "Modify gate thresholds to simulate a pass" | Silencing gates removes safety boundaries | Report the blocked condition for user decision |
| "Hardcode coordinates specific to a sample file" | Single-sample overfitting fails across other files | Model general mechanisms or document limitations |
| "Complete partial tasks and report completion" | Conceals remaining complex work | Highlight incomplete items prominently at the top |
| "Uncritically affirm user premises" | Conversational compliance overlooks technical gaps | Verify technical facts objectively before agreeing |
| "Recursively guess fixes after initial failure" | Multiple unguided changes compound errors | Halt after 1 fix attempt; report traceback and options |
| "Silently work around missing tool capabilities" | Hides toolkit gaps from improvement tracking | Log as a Tool Gap; do not claim unconditional PASS |
| "Describe file contents without inspecting" | Describing unread files introduces inaccuracies | Inspect the file first, or explicitly label as `[U]` |

---

## Pre-Delivery Verification Checklist

Verify prior to submitting deliverables:
- [ ] Are all quoted metrics substantiated by active execution evidence?
- [ ] Are general rules free of coordinates or values hardcoded from a single file?
- [ ] Has the scope or acceptance criteria remained unaltered unless instructed?
- [ ] Has self-grading been avoided (PASS status attributed strictly to tools/tests)?
- [ ] Are opening statements objective and free of unverified praise?
