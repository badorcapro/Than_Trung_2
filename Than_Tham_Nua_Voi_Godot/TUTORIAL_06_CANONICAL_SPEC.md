# Tutorial 06 Canonical Spec

Purpose: locked design/spec handoff for Codex before any Tutorial 06 coding.

Read `CODEX_PROJECT_MAP.md` first. This spec is about Tutorial 06 only.

## Identity

Tutorial 06 is the **Barkeep / Poisoner / Drunkard transformation** tutorial.

Do not substitute Tutorial 07 mechanics here:

- Clock Maker
- Clock Tower
- Serial Killer
- periodic timed kills

## Locked Vietnamese Names

| English | Vietnamese |
|---|---|
| Poisoner | Độc Sư |
| Barkeep | Chủ Quán Rượu |
| Drunkard | Kẻ Say Rượu |

## Locked Terms

| Concept | Vietnamese |
|---|---|
| transform | biến đổi |
| taint / tainted | tha hóa / bị tha hóa |
| suspected role | vai trò bị nghi ngờ |
| true role | vai trò thật |
| displayed role | vai trò hiển thị |
| current transformed role | vai trò hiện tại sau biến đổi |

Use `Số hiệu` for Address. Do not use `Địa chỉ` for this gameplay concept.

## Board

```text
slot0 #1 displayed Reporter
slot1 #2 displayed Priest
slot2 #3 displayed Reporter
slot3 empty
slot4 Crime Scene
slot5 #4 Reporter
slot6 #5 Blood Hound
slot7 #6 displayed Mailman
slot8 #7 Therapist
```

## Initial Ratio

- Innocent: 5
- Meddler: 0
- Underling: 2
- Traitor: 0

The ratio is intentionally allowed to become outdated after transformation.

## Reveal / Hidden Truth

- #1 Độc Sư -> pretended Reporter; tainted #2
- #2 Priest, tainted
- #3 Chủ Quán Rượu -> pretended Reporter; transformed #6 into Kẻ Say Rượu
- #4 Reporter
- #5 Blood Hound
- #6 Kẻ Say Rượu, shown earlier as Mailman
- #7 Therapist

Final Evil answer:

- #1 Độc Sư
- #3 Chủ Quán Rượu

## Tutorial Lesson

Tutorial 06 teaches these reusable rules:

- Good roles can lie because of taint.
- Good/Meddler roles can transform.
- The displayed role, true role, and current transformed role are distinct.
- Wrong information does not automatically prove Evil.
- Kẻ Say Rượu lies while remaining a Good-side/Meddler role.
- Độc Sư taints a surrounding Innocent neighbor, lies, and pretends a suspected role.
- Chủ Quán Rượu transforms one Innocent into Kẻ Say Rượu, lies, and pretends a suspected role.

## Role Mechanics To Audit

Độc Sư:

- Underling.
- Taints a random Innocent surrounding neighbor.
- Surrounding means up to 8 tiles, including diagonals.
- Lies and pretends a suspected role.
- If Độc Sư itself is tainted, it does not taint a target.

Chủ Quán Rượu:

- Underling.
- Transforms one Innocent role into Kẻ Say Rượu.
- Lies and pretends a suspected role.
- Never appears if it would create a second Kẻ Say Rượu.
- Can add Kẻ Say Rượu even if Kẻ Say Rượu was not originally suspected.
- Added Kẻ Say Rượu is not considered "suspected".
- Mailman/Partner interactions with Kẻ Say Rượu must respect transformed in-play truth.

Kẻ Say Rượu:

- Meddler.
- Lies and pretends a good not-in-play role.
- Tainted behavior is unchanged.
- Can be created by Chủ Quán Rượu transforming an Innocent.
- If Chủ Quán Rượu is suspected but not in play, Kẻ Say Rượu cannot be in play.

## Deduction Chain

- Three displayed Reporters create ambiguity.
- #5 Blood Hound points North and helps identify #1 as Evil.
- #2 Priest's wrong statement is explained by Độc Sư taint, not Evil alignment.
- #6 displayed Mailman gives false information, but other evidence indicates #6 is not an Underling.
- #3 Chủ Quán Rượu transformed #6 into Kẻ Say Rượu.
- #7 Therapist can then be treated as truthful.
- #7's adjacent-Evil count helps establish #4 true Reporter as Good and therefore #3 as the other Evil.

## First Codex Prompt

Use this before implementation:

```text
TUTORIAL 06 — BARKEEP CONTENT LOCK / FOUNDATION AUDIT ONLY

Read CODEX_PROJECT_MAP.md first.
Read TUTORIAL_06_CANONICAL_SPEC.md next.

Tutorial 06 is Độc Sư / Chủ Quán Rượu / Kẻ Say Rượu transformation. Do not inspect or implement Tutorial 07 Clock Maker / Clock Tower / Serial Killer mechanics except to avoid mixing them into T06.

Goal:
Audit current repo only and report what already exists vs what is missing for Tutorial 06.

Inspect narrowly:
- project.godot autoloads
- FixtureRepository
- CaseRuntimeState
- RoleInformationEvaluationService
- InvestigationService
- CaseSpatialService
- any transform / taint / pretend / current-role services
- role .tres definitions for Reporter, Priest, Blood Hound, Mailman, Therapist, Độc Sư, Chủ Quán Rượu, Kẻ Say Rượu
- SmokeTestRunner

Do not code.
Do not create Tutorial 06 fixture.
Do not run Godot headless.

Report:
1. Whether Độc Sư exists and what is missing.
2. Whether Chủ Quán Rượu exists and what is missing.
3. Whether Kẻ Say Rượu exists and what is missing.
4. Whether taint behavior supports #1 -> #2.
5. Whether transform/current-role behavior supports #3 changing #6 into Kẻ Say Rượu while #6 displays Mailman earlier.
6. Whether ratio can intentionally become outdated after transform.
7. Whether Mailman / Partner / role-reference logic respects transformed current role.
8. Smallest safe implementation sequence for Tutorial 06.
9. Exact files that should be edited first in the next coding pass.

STOP after report.
```

## Stop Rule

Do not implement from this spec until the audit confirms which foundations already exist.
