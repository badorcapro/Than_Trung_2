# CODEX_PROJECT_MAP.md

Purpose: navigation map for Codex. Read this before broad repo scans.

This file is separate from `PROJECT_MEMORY.md`. It should stay short, practical, and oriented around "where to look first".

## Project Guardrails

- Project: `Than_Tham_Nua_Voi_Godot`
- Engine: Godot **4.6.2 stable**
- Renderer: GL Compatibility
- Language: GDScript
- Runtime repo root last used by user/Codex:
  - `D:\Game Maker\Đổi acc\Than_Tham_Nua_Voi_Godot_Runtime_Clean\Than_Tham_Nua_Voi_Godot`
  - If shell/path rendering drops Vietnamese accents, use the actual local path from the user's machine.
- Do **not** run Godot headless / CLI runtime tests.
- Do **not** investigate Godot headless crashes.
- User validates runtime through Godot GUI.
- Prefer static/source inspection plus narrow Smoke assertions.
- Keep prompts small and checkpointed.
- Do not start broad rewrites when a narrow correction is enough.
- Do not duplicate systems before auditing the authority listed below.

## STOP / Credit Rules

Stop immediately when the scoped goal is satisfied and report:

- files changed
- exact authority touched
- Smoke/static assertions added or updated
- manual GUI verification needed
- remaining known failures, if any

Never continue into the next milestone without explicit user direction. Do not start Tutorial 06 implementation from an audit/content-lock prompt.

## Scene / Entry Points

Look in `project.godot` first for the current main scene and autoload list.

Known entry/navigation authorities to inspect first:

- app flow / navigation: `scripts/autoload` and any `AppFlow` definition referenced by `project.godot`
- debug/test home: scene/controller reached by `AppFlow.go_to_debug_home()`
- Role Codex / Sổ Vai Trò:
  - `scripts/presentation/RoleCodexController.gd`
  - its `.tscn` scene under `scenes/`
- in-Case gameplay / Role Reference popup:
  - `scripts/presentation/case_gameplay/VSCaseMainController.gd`
  - related case gameplay scene under `scenes/`

If entry points are unclear, inspect `project.godot` and scene controller names before using `rg` broadly.

## Autoloads

Authoritative autoload list lives in `project.godot`.

Expected important autoload/service names to verify there before editing:

- `AppFlow`
- `FixtureRepository`
- any case/match/session state service
- any save/progression/economy services

Do not add a new autoload if an existing service can own the behavior.

## Content / Fixture Authorities

Inspect these areas first:

- role definitions / role `.tres` files loaded by `FixtureRepository.load_roles()`
- case/tutorial fixtures loaded by `FixtureRepository`
- Tutorial 01-05 fixture `.tres` / resource paths
- shared enums/resources such as `CaseEnums`, `RoleDefinition`, case definition resources

Rules:

- `RoleDefinition.help_text` stays plain Vietnamese text.
- Do not put BBCode directly into `.tres` role copy.
- Tutorial fixtures are teaching/reference cases, not one-off hardcoded gameplay.
- Public information should be derived from hidden authoritative state.
- True role duplicates are invalid; displayed duplicates via pretend/transform can be valid.

## Tutorial Fixture / Status Snapshot

Current tutorial state:

| Tutorial | Status | Notes |
|---|---:|---|
| Tutorial 01 | implemented | Included in current PASS baseline. |
| Tutorial 02 | implemented | Do not reopen unless a concrete regression appears. |
| Tutorial 03 | implemented | Old relation failure was fixed; do not regress to old 1581/1582 state. |
| Tutorial 04 | implemented | Fixture intent: #1 true Tailor, #2 Mobster pretending Tailor, #3 Mailman, #4 Priest. |
| Tutorial 05 | implemented and closed | Current report says fixture exists at `content/cases/fixtures/tutorial_case_005.tres`; foundations F1-F6 are present. |
| Tutorial 06 | fixture/launcher authored, GUI Smoke pending after I1 | T06 fixture path: `content/cases/fixtures/tutorial_case_006.tres`. Current I1 intent: Poisoner #1 taints #2, Barkeep #3 transforms #6 into Drunkard, ratio remains authored 5/0/2/0, Blood Hound display name is `Ngự Khuyển Quan`, Drunkard is nested under Barkeep in suspect list. |
| Tutorial 07 | implemented and closed | T07-A added generic `BoardLocationDefinition`; T07-B added `ClockTowerDefinition`, `ClockTowerService`, Clock Maker role semantics, and current ringing-state presentation; T07-C added `CaseTimedEventDispatcher`; T07-D added reusable Serial Killer role/timed-event authority. T07-I1 fixture path: `content/cases/fixtures/tutorial_case_007.tres`. T07-I2 adds fixture-authored tutorial dialogue and Full Reveal timed-kill history from structured `runtime.timed_events`; T07-I2R presents that dialogue in a lightweight VN overlay instead of the left info panel. Do not mix into Tutorial 06. |
| Tutorial 08 | fixture/launcher authored, GUI Smoke pending | T08 fixture path: `content/cases/fixtures/tutorial_case_008.tres`. Intent: Conman / `Kẻ Lừa Đảo` is truthful Evil that hides true role on Chỉ Điểm; Copycat / `Kẻ Bắt Chước` borrows displayed Vigilante / `Sư Tử Phán` function and kills #2. Dead Evil remains part of canonical answer. Do not start Tutorial 09. |

Tutorial 04 key contracts:

- slot is not suspect number
- Crime Scene/location tiles are not suspects
- suspect numbers are #1..#N by reading order, suspects only
- public board shows two displayed Tailors
- #1 true Tailor targets #3/#4 and reports same alignment
- #2 Mobster -> Tailor targets #3/#4 and reports different alignment
- private `Chỉ Điểm` on #2 reveals only `Kẻ Côn Đồ`
- Full Reveal shows true role plus pretend role

Do not substitute Tutorial 07 Clock Maker/Serial Killer mechanics into Tutorial 06.

## Developer Human Verification Fixtures

### HV1 — Disguise & Clue Behavior

- Purpose: developer-only authored Case for verifying true role, displayed role, behavior role, truth mode, public investigation information, and Full Reveal truth remain separate.
- Fixture: `content/cases/fixtures/hv1_disguise_clue_behavior.tres`.
- Entry: DebugHome button `HV1 — Disguise & Clue Behavior`; launches the normal `VSCaseMain` runtime path.
- This is not tutorial or production content and must not affect procedural generation/solver behavior.

Human GUI checklist:

1. Before investigation:
   - Confirm the 3×3 board reads: top row `#1, #2, #3`; middle row `#4, Hiện trường, #5`; bottom row `#6, #7, Tháp Đồng Hồ`.
   - Confirm all seven suspect cards begin unrevealed; note that no true-role identity is visible yet.
2. Investigate the four disguised suspects in this order so elapsed time reaches 8h, before the Serial Killer 9h threshold:
   - `#2`: displayed `Tư Tế`; announces `Ta có thật là một Tư Tế tốt không?`; behavior is Priest in LYING mode.
   - `#4`: displayed `Ngự Y`; announces `Ta có 1 người bệnh thuộc Phe Ác.`; behavior is Therapist in TRUTHFUL mode.
   - `#6`: displayed `Dịch Phu`; announces `Nhà Khí Tượng đang ở trong cung, ta chưa từng nghe đến Tư Tế.`; both claims are false, so behavior is Mailman in LYING mode.
   - `#5`: displayed `Thợ Đồng Hồ`; announces `Tháp Đồng Hồ sẽ không reo từ 1h đến 2h.`; the actual tower interval is 8h–9h, so behavior is Clock Maker in LYING mode.
3. Submit the exact Evil set `{#2, #5, #6}` and inspect Full Reveal:
   - `#2`: true `Kẻ Côn Đồ`, displayed/pretended `Tư Tế`, `Phe Ác`, `Thuộc Hạ`.
   - `#4`: true `Kẻ Bắt Chước`, displayed/pretended `Ngự Y`, `Phe Thiện`, `Kẻ Bao Đồng`.
   - `#6`: true `Nhà Phê Bình`, displayed/pretended `Dịch Phu`, `Phe Ác`, `Nghịch Thần`.
   - `#5`: true `Sát Nhân Hàng Loạt`, displayed/pretended `Thợ Đồng Hồ`, `Phe Ác`, `Thuộc Hạ`.
4. Verdict authority:
   - Evil suspects: `{#2, #5, #6}`.
   - Thuộc Hạ: `{#2, #5}`.
   - Nghịch Thần: `{#6}`.

### HV2 — Active Disguise

- Purpose: developer-only authored Case for verifying borrowed Tailor/Vigilante functions, true-owner truth modes, independent one-use state, and Full Reveal identity separation.
- Fixture: `content/cases/fixtures/hv2_active_disguise.tres`.
- Entry: DebugHome button `HV2 — Active Disguise`; launches the normal `VSCaseMain` runtime path.
- This is not tutorial or production content and must not affect procedural generation, solver behavior, or disguise capability.

Human GUI checklist:

Board:

- Top row: `#1 Thợ May`, `#2 Sư Tử Phán`, `#3 Kẻ Bắt Chước -> Sư Tử Phán`.
- Middle row: `#4 Tư Tế`, `Hiện trường`, `#5 Sử Quan`.
- Bottom row: empty, `#6 Kẻ Côn Đồ -> Thợ May`, `#7 Sát Nhân Hàng Loạt -> Sư Tử Phán`.

1. Investigate `#7` first. It displays `Sư Tử Phán`; its borrowed function is LYING and becomes available on the next turn.
2. Investigate `#3`. It displays `Sư Tử Phán`; its borrowed function is TRUTHFUL and becomes available on the next turn.
3. Use `#7`'s Sư Tử Phán function on `#6` (true Evil). Expected visible result: `Số Hiệu 6 bình an vô sự.` The function hand for `#7` becomes consumed; `#3` remains independently available.
4. Use `#3`'s Sư Tử Phán function on `#7` (true Evil). Expected visible result: `Số Hiệu 7 đã bị xử quyết.` This occurs at 8h, so the true Serial Killer is dead before its first 9h timed threshold and cannot interfere with HV2.
5. Investigate `#6`, then use its borrowed Thợ May function on `#4` and `#6`. Their true alignments differ, but LYING inverts the visible result to `4 và 6 cùng phe.`
6. Investigate `#1`, then use its native TRUTHFUL Thợ May function on the same `#4` and `#6`. Expected visible result: `4 và 6 khác phe.` Each owner's one-use state is independent.
7. Submit the exact Evil set `{#6, #7}` and inspect Full Reveal:
   - `#3`: true `Kẻ Bắt Chước` -> displayed `Sư Tử Phán`; `Phe Thiện`, `Kẻ Bao Đồng`.
   - `#6`: true `Kẻ Côn Đồ` -> displayed `Thợ May`; `Phe Ác`, `Thuộc Hạ`.
   - `#7`: true `Sát Nhân Hàng Loạt` -> displayed `Sư Tử Phán`; `Phe Ác`, `Thuộc Hạ`.

### HV3 — Timed Coexistence

- Purpose: developer-only authored Case for verifying that a Serial Killer's borrowed active function and true-role
  9h timed event coexist with independent state and timing.
- Fixture: `content/cases/fixtures/hv3_timed_coexistence.tres`.
- Entry: DebugHome button `HV3 — Timed Coexistence`; launches the normal `VSCaseMain` runtime path.
- This is not tutorial or production content and must not affect procedural generation, solver behavior, or disguise
  capability.

Human GUI checklist:

Board:

- Top row: `#1 Thợ May`, `Hiện trường`, `#2 Sử Quan`.
- Middle row: `#3 Tư Tế`, empty, `#4 Sát Nhân Hàng Loạt -> Thợ May`.
- Bottom row: `#5 Kẻ Bất Lương`, empty, empty.

1. Investigate `#4`. Time advances to 2h. It displays `Thợ May`; its borrowed function uses LYING truth mode and is
   available on the next turn.
2. At 2h, use `#4`'s Thợ May function on `#4` and `#5`. Both are truly Evil, but LYING inverts the visible result to
   `4 và 5 khác phe.` The function hand for `#4` becomes consumed. The active function costs 0h, so the clock remains
   at 2h and the 9h Serial Killer event has not fired.
3. Investigate `#1`, `#3`, then `#2`. The clock advances to 4h, 6h, then 8h.
4. Use `Chỉ Điểm` on `#2`. The accusation is wrong because `#2` is Good, so the acting player leaves Investigation;
   `#2` is not globally arrested. The clock advances to exactly 9h, and `#4`'s Serial Killer event kills `#2`, its only
   orthogonally adjacent Good suspect.
5. Confirm `#4`'s borrowed Thợ May function remains consumed after the 9h event. Reprocessing the same threshold must
   not reroll or reapply the event.
6. Submit the exact Evil set `{#4, #5}` and inspect Full Reveal:
   - `#4`: true `Sát Nhân Hàng Loạt`, displayed/pretended `Thợ May`, `Phe Ác`, `Thuộc Hạ`.
   - `#5`: true `Kẻ Bất Lương`, `Phe Ác`, `Thuộc Hạ`.
   - `#1`, `#2`, and `#3` are Good.

### HV4 — Critic & Mailman

- Purpose: developer-only authored Case for verifying that Critic may display an explicitly listed role that remains
  absent from current true roles, and that Mailman evaluates current-role presence rather than displayed identities.
- Fixture: `content/cases/fixtures/hv4_critic_mailman.tres`.
- Entry: DebugHome button `HV4 — Critic & Mailman`; launches the normal `VSCaseMain` runtime path.
- This is not tutorial or production content and must not affect procedural generation, solver behavior, disguise
  capability, or Critic player-meta ownership.

Human GUI checklist:

Board:

- Top row: `#1 Tư Tế`, `#2 Dịch Phu`, `#3 Nhà Phê Bình -> Ngự Khuyển Quan`.
- Middle row: `#4 Sử Quan`, `Hiện trường`, `#5 Kẻ Bất Lương`.
- Bottom row: empty, empty, empty.

Explicit Suspect List:

- `Tư Tế`, `Dịch Phu`, `Nhà Phê Bình`, `Sử Quan`, `Kẻ Bất Lương`, `Ngự Khuyển Quan`.
- Current true roles are the first five roles above. `Ngự Khuyển Quan` is listed but current-absent.

1. Open `HV4 — Critic & Mailman` from DebugHome and inspect the Suspect List. Confirm `Ngự Khuyển Quan` is listed.
2. Investigate `#3`. Its card displays `Ngự Khuyển Quan`, even though no suspect has current true role
   `Ngự Khuyển Quan`.
3. Investigate `#2`. It displays native `Dịch Phu` and truthfully announces:
   `Tư Tế đang ở trong cung, ta chưa từng nghe đến Ngự Khuyển Quan.`
4. Optionally investigate `#1` to confirm the present side of that Mailman statement is the native `Tư Tế`.
5. Submit the exact Evil set `{#3, #5}` and inspect Full Reveal:
   - `#3`: true `Nhà Phê Bình`, displayed/pretended `Ngự Khuyển Quan`, `Phe Ác`, `Nghịch Thần`.
   - `#5`: true `Kẻ Bất Lương`, `Phe Ác`, `Thuộc Hạ`.
   - No Full Reveal entry has true/current role `Ngự Khuyển Quan`.

### HV5 — Mutation & Visibility

- Purpose: developer-only authored Case for verifying Poisoner taint, Barkeep transformation, Spectre obscure,
  public identity masking, and authoritative Full Reveal truth in one normal runtime Case.
- Fixture: `content/cases/fixtures/hv5_mutation_visibility.tres`.
- Entry: DebugHome button `HV5 — Mutation & Visibility`; launches the normal `VSCaseMain` runtime path.
- This is not tutorial or production content and does not affect procedural generation, solver behavior, or disguise
  capability.

Human GUI checklist:

Board:

- Top row: `#1 Độc Sư -> Sử Quan`, `#2 Tư Tế`, `#3 Chủ Quán Rượu -> Sử Quan`.
- Middle row: `#4 Vong Linh -> Sử Quan`, `Hiện trường`, `#5 Dịch Phu`.
- Bottom row: `#6 Ngự Y`, `#7 Sử Quan`, empty.

1. Open `HV5 — Mutation & Visibility` from DebugHome. The startup relations are deterministic: `#1` Tha Hóa
   adjacent `#2`; `#3` transforms `#5`; `#4` obscures `#6`. The Spectre and Barkeep targets are distinct.
2. Investigate `#2`. Its displayed role remains `Tư Tế`, but runtime taint makes it announce the LYING line:
   `Ta có thật là một Tư Tế tốt không?`
3. Investigate `#5`. It still displays and behaves as `Dịch Phu`, but its current role is hidden Drunkard and it lies:
   `Nhà Toán Học đang ở trong cung, ta chưa từng nghe đến Sử Quan.`
4. Investigate `#6`. Its role name is `?????`, its portrait/group identity is hidden, and every letter in its
   announcement is masked. The digit `1`, spaces, and punctuation remain visible:
   `■■ ■■ 1 ■■■■■ ■■■■ ■■■■■ ■■■ ■■.`
5. Submit the exact Evil set `{#1, #3, #4}` and inspect Full Reveal:
   - `#1`: true `Độc Sư`, displayed `Sử Quan`, `Phe Ác`, `Thuộc Hạ`; relation says it Tha Hóa `#2`.
   - `#2`: current `Tư Tế`, `Phe Thiện`, `Người Vô Tội`, with the `Tha Hóa` flag.
   - `#3`: true `Chủ Quán Rượu`, displayed `Sử Quan`, `Phe Ác`, `Thuộc Hạ`; relation says it transformed `#5`.
   - `#4`: true `Vong Linh`, displayed `Sử Quan`, `Phe Ác`, `Thuộc Hạ`; its card says it hid `#6`.
   - `#5`: original `Dịch Phu`, current `Kẻ Say Rượu`, `Phe Thiện`, `Kẻ Bao Đồng`; prior Dịch Phu statement remains
     available through card-local history.
   - `#6`: true/current `Ngự Y`, `Phe Thiện`, `Người Vô Tội`; its public role/group identity is restored and
     `Xem lời khai cũ` restores the readable announcement `Ta có 1 người bệnh thuộc Phe Ác.`
   - `#7`: true/current `Sử Quan`, `Phe Thiện`, `Người Vô Tội`.
6. Verdict authority: Evil suspects `{#1, #3, #4}`; all three are `Thuộc Hạ`; there is no `Nghịch Thần`.

### HV6 — Resolution & Timed Safety

- Purpose: final developer-only authored Case for verifying wrong-player removal, Scoundrel immunity, Conman privacy,
  kill-not-auto-solve, dead-Evil exact resolution, and one real deterministic Surgeon 12h event.
- Fixture: `content/cases/fixtures/hv6_resolution_timed_safety.tres`.
- Entry: DebugHome button `HV6 — Resolution & Timed Safety`; launches the normal `VSCaseMain` runtime path.
- This is not tutorial or production content. The fixture's dev-only runtime event seed is `1`; normal Cases retain fresh
  runtime event seeds. At 12h the existing Surgeon service fires once and selects `#6 Sử Quan` from the living current
  Innocent pool.

Board:

- Top row: `#1 Bác Sĩ Phẫu Thuật`, `#2 Sư Tử Phán`, `#3 Tư Tế`.
- Middle row: `#4 Kẻ Lừa Đảo -> Tư Tế`, `Hiện trường`, `#5 Kẻ Bất Lương`.
- Bottom row: `#6 Sử Quan`, empty, empty.
- True Evil set: `{#4, #5}`; both are `Thuộc Hạ`; there is no `Nghịch Thần`.

Human GUI checklist — Flow A (reopen HV6 fresh first):

1. Player 1 uses `Chỉ Điểm` on `#5 Kẻ Bất Lương`. Expected: blocked; `#5` is not arrested/revealed and Player 1 gains
   no successful Evil record.
2. Player 2 uses `Chỉ Điểm` on `#4 Kẻ Lừa Đảo`. Expected: correct, while its hidden true role remains private. `#4`
   is not globally arrested/handled; this success belongs only to Player 2.
3. Player 3 performs one ordinary investigation so the turn returns to Player 1. Player 1 retries `#5`. Expected:
   still blocked; Player 2's success did not unlock Player 1's Kẻ Bất Lương check.
4. Player 2 investigates `#2`, then Player 3 investigates `#3`. Player 1 uses `Chỉ Điểm` on `#4`, which remains a
   valid target after Player 2's private success. Player 1 now records one other true Evil personally.
5. Player 2 investigates `#6`, then Player 3 investigates the still-uninvestigated `#4`. Player 1 retries
   `#5`. Expected: succeeds because Player 1's own successful Evil history now contains `#4`; the accumulated exact
   set becomes `{#4, #5}`.

Human GUI checklist — Flow B (reopen HV6 fresh first):

1. Player 1 investigates `#2 Sư Tử Phán`. Its truthful one-use function becomes available on the next turn.
2. Player 2 uses `#2`'s function on `#4`. Expected: `#4` dies through the normal Vigilante kill path. The Case remains
   in progress; death does not arrest, submit, or solve the Evil answer.
3. Advance from 2h to 10h with four normal investigations in this exact turn order: Player 3 investigates `#1`, Player
   1 investigates `#3`, Player 2 investigates `#5`, then Player 3 investigates `#6`.
4. At 10h, Player 1 uses `Chỉ Điểm` on dead `#4`. Expected: correct but incomplete; dead Evil remains a valid required
   answer member, Player 1 records `#4`, and elapsed time reaches 11h.
5. Player 2 uses `Chỉ Điểm` on known-Good `#3`. Expected: wrong result, Player 2 leaves Investigation, and elapsed time
   reaches 12h. The real Surgeon event fires once and kills the deterministic living current Innocent `#6 Sử Quan`.
   Repeated refreshes at 12h must not reroll or kill another suspect.
6. Player 3 uses `Chỉ Điểm` on `#5`. Expected: blocked because Player 3 has no personal prior correct Evil record;
   Player 1's `#4` record does not transfer to Player 3.
7. The turn skips inactive Player 2 and returns to Player 1. Player 1 uses `Chỉ Điểm` on `#5`. Expected: succeeds
   because Player 1 personally recorded `#4`; the accumulated exact set is `{#4, #5}` and the existing resolution flow
   may now complete. Full Reveal still lists `#4 Kẻ Lừa Đảo` and `#5 Kẻ Bất Lương` as the authoritative Evil set.

## Tutorial 07 Integration Notes

Current Tutorial 07 I1 authored layout:

- slot0 #1 Surgeon
- slot1 #2 Therapist
- slot2 #3 Blood Hound / `Ngự Khuyển Quan`
- slot3 #4 Mobster pretending Clock Maker
- slot4 #5 true Clock Maker
- slot5 Clock Tower, ring hour 8
- slot6 Crime Scene
- slot7 #6 Reporter
- slot8 #7 Serial Killer pretending Clock Maker

Runtime path under Smoke coverage:

- investigations advance 0h -> 2h -> 4h -> 6h -> 8h -> 10h -> 12h
- Clock Tower rings at 8h and 9h
- Serial Killer #7 naturally kills adjacent Good #6 when crossing 9h
- Surgeon #1 resolves at 12h without fixed-victim assumptions
- privately identifying #7 via `Chỉ Điểm` does not globally arrest it or suppress its later Serial Killer event
- timed-event dispatch uses canonical victim pools; a just-investigated suspect is not protected from automatic timed kills. Dead unrevealed suspects cannot be investigated; revealed dead suspects show `*Chết...*` instead of prior announced information.
- T07 dialogue is authored on `CaseDefinition.tutorial_dialogue_lines` and rendered in a lightweight VN-style overlay above the case board. The left case-info panel remains ratio/info only. Full Reveal timed-kill history is generated from successful structured timed events; failed Surgeon procs create no victim note.

## Role Reference / Glossary / Codex

Authorities:

- shared formatter: `scripts/presentation/RoleReferenceFormatter.gd`
- shared glossary bank: `scripts/presentation/RoleGlossaryBank.gd`
- Role Codex controller: `scripts/presentation/RoleCodexController.gd`
- Role Codex scene: inspect scene path referenced by the controller / debug menu
- glossary tooltip controller: `scripts/presentation/RoleGlossaryTooltipController.gd`
- glossary tooltip scene:
  - reported preload in Codex: `res://scenes/shared_ui/RoleGlossaryTooltip.tscn`
  - older prompt suggested `scenes/ui/`; trust actual preload/path in source
- in-Case Role Reference hook: `scripts/presentation/case_gameplay/VSCaseMainController.gd`

Current glossary/Codex facts:

- Role Codex and in-Case Role Reference should share formatter, glossary bank, and tooltip implementation.
- Formatter owns semantic styling and glossary metadata.
- Matching should be deterministic longest-match-first.
- No `[font_size]` inline term styling.
- Generic glossary/key terms use normal-weight colored links, not bold.
- Canonical Kill glossary key is `kill`; title `Giết`; definition: `Làm một vai trò chết. Vai trò đã chết không Công Bố Sự Thật, và mọi thông tin chúng từng thông báo sẽ bị mất.`
- `Số hiệu` is the canonical localization for Address. Do not use `Địa chỉ` for this gameplay concept.
- UI metadata line should render `Phe: Thiện` / `Phe: Ác`, not `Phe: Phe Thiện`.

Known current Smoke status before T08:

- **2415 / 2415 PASS**
- Expected after T08 candidate patch: **2481 / 2481 PASS** pending GUI verification.
- Treat older `7 fail / 1614` glossary/content-copy failures as stale unless the user reports a newer regression.

## Smoke

Authority:

- `scripts/tools/SmokeTestRunner.gd`

Rules:

- User runs full Smoke manually in Godot GUI.
- Codex may update narrow static/Smoke assertions.
- Do not add fragile pixel-coordinate checks.
- Do not chase stale copy failures one by one during content editing; sync after content milestone unless user asks.

## Gameplay Domain Authorities

Audit existing files before proposing new architecture.

| Domain | Inspect first |
|---|---|
| Case runtime / board / role reference | `scripts/presentation/case_gameplay/VSCaseMainController.gd`, case scene, case state/controller services |
| Role definitions and loading | `RoleDefinition`, role `.tres`, `FixtureRepository`, role fixture directories |
| Board locations | `scripts/domain/cases/BoardLocationDefinition.gd`, `CrimeSceneDefinition`, `CaseDefinition.location_definitions()`, `CaseDefinitionValidator`, `CaseBoardController` |
| Clock Tower / Clock Maker | `scripts/domain/cases/ClockTowerDefinition.gd`, `ClockTowerService`, `RoleInformationEvaluationService`, `content/locations/clock_tower.tres`, `content/roles/fixtures/clock_maker.tres` |
| Timed events | `scripts/domain/cases/CaseTimedEventDispatcher.gd`, `SurgeonTimedEventService`, `SerialKillerTimedEventService`, `CaseTimedEventRuntimeState`, `VSCaseMainController._commit_action_time_and_timed_events()` |
| Role info evaluation | `RoleInformationEvaluationService`, `CaseSpatialService`, role function/evaluation services |
| Match / Round | existing match state, round state, round-end/match-end services/controllers |
| Loot movement phase | loot movement controller/state/service, loot interactables/reward resources |
| Equipment / Kỷ Vật / Vết Thánh | equipment inventory/progression resources/services |
| Gacha tickets | gacha/equipment reward services and ticket resources |
| Court Rank / Công Danh / Merit | court rank progression service, merit/progression state, match-end evaluator |
| Submission / Reveal | Early Submission, Final Verdict, Full Reveal, `POST_REVEAL_FUNCTIONS` state |

## CASE GENERATOR FOUNDATION

M0 is contract + deterministic seed foundation only. Do not build the full hidden-world generator, solver, uniqueness validation, difficulty scoring, Seed Warehouse, or runtime random-case integration until a later explicit milestone.

- Seed authority: `CaseGenerationRequest.seed` is the canonical integer-style seed. A request must be fully created before generation; the generator must not read system time, UI state, node positions, or global random state as entropy.
- RNG ownership: `CaseGenerator.generate()` owns one local `RandomNumberGenerator` seeded from the request. Generator decisions should flow through that controlled RNG authority.
- Request contract: `CaseGenerationRequest` carries `seed`, `board_columns`, `board_rows`, `board_slot_count`, `generation_profile_id`, `allowed_role_ids`, `required_location_ids`, `required_suspect_count`, and `generator_version`.
- Result / draft boundary: `CaseGenerationResult` carries status/error data, seed/version/profile echo, logical board slots, an M0 deterministic probe slot sequence, draft tile kinds, future hidden-role id slots, and a canonical fingerprint. It must not contain player-facing formatted copy or presentation nodes.
- Board-slot authority: generator output uses logical slot indices only. Slot order is explicit and independent of `Control`, `GridContainer`, scene-node order, or screen coordinates. M0 supports the 3x3 tutorial/easy and 4x4 normal/full contracts.
- Content boundary: generation decisions use stable role ids/content-pool ids, not localized display names.
- Version contract: `generator_version` is part of the request and fingerprint so old saved/debug seeds are tied to the ruleset that produced them. No migration tooling exists yet.
- Failure contract: invalid dimensions, unsupported profile, empty/invalid content pool, invalid version, and future impossible requests should return structured `CaseGenerationResult` failures, not UI errors or silent fallback requests.
- Roadmap: M0 = contract + deterministic seed foundation; M1 = deterministic hidden-world generation; M2 = public information derivation + deterministic solvability evaluation; M3 = rejection/retry composition around solver results; M4A = deterministic Seed Warehouse build/verification; M4B = runtime selection boundary; later = difficulty/profile tuning and production integration.

## CASE GENERATOR M1 — HIDDEN WORLD CONTRACT

M1 generates a deterministic hidden-world draft only. It does not generate public clues, solver/uniqueness proof, difficulty scoring, Seed Warehouse entries, or runtime/UI integration.

- Placement: `CaseGenerator` uses logical board slots from the request, places each required location exactly once, places exactly `required_suspect_count` suspects, and leaves remaining slots empty. Current supported contracts remain 3x3/9 and 4x4/16.
- Suspect numbering: generated suspects are numbered by occupied suspect slots in left-to-right, top-to-bottom logical slot order. Locations and empty slots never receive suspect numbers or increment numbering.
- True-role assignment: generator consumes only `allowed_role_ids`, resolves each through `RoleDefinition`, enforces unique natural true role ids, and derives role group/alignment from role content authority.
- Hidden answer authority: hidden Evil answer ids are generated from true alignment only, sorted/stable, independent of displayed/pretend/future public information.
- Retry/failure: invalid or impossible requests return structured `CaseGenerationResult` failure codes. Candidate drafts use bounded deterministic retry (`CaseGenerator.MAX_GENERATION_ATTEMPTS`) and never loop forever or return partial hidden worlds silently.
- CaseDefinition compatibility: `CaseGenerator.case_definition_from_result()` exports a successful generated candidate into a minimal `CaseDefinition` with reward/test-balance metadata so the existing `CaseDefinitionValidator` remains the structural validation authority. Generator output remains domain data only, not UI nodes.
- Suspect board-slot authoring is not editor-limited to 0..8; slot bounds are owned by `CaseDefinitionValidator` using the case board capacity metadata so generated 4x4 candidates can remain `CaseDefinition`-compatible.
- Fingerprint: canonical generator fingerprint includes request/version, logical slots, location placement, suspect placement/numbering, true role ids, role group/alignment, and hidden Evil answer. It must avoid unordered dictionary iteration and UI/node data.

## CASE GENERATOR M2 — PUBLIC INFORMATION + SOLVABILITY CONTRACT

M2 derives deterministic public clue records from `HiddenCaseDraft` and evaluates candidate solvability from structured public information. It does not add generator rejection/retry, difficulty scoring, Seed Warehouse, or runtime/UI integration.

- Authority: public clues reuse existing domain role-evaluation logic (`RoleInformationEvaluationService` and existing spatial helpers). Do not duplicate role formulas in presentation or generator UI code.
- Boundary: hidden truth and public information remain separate. `GeneratedPublicClue` stores clue payload data, public referenced suspect ids where the mechanic already exposes them, and role ids needed by later solver work; hidden Evil answer remains in `HiddenCaseDraft.hidden_evil_suspect_ids`.
- Spatial context: generator adapts the hidden draft into a minimal transient `CaseDefinition` so spatial roles use logical board slots, never UI coordinates or scene-node order.
- Solver files: `CaseGeneratorPublicSolver.gd`, `CaseGeneratorSolverResult.gd`, `GeneratedPublicCaseView.gd`, `GeneratedPublicSuspectView.gd`, and `GeneratedPublicClue.gd`.
- Solver status meanings: `unsupported` means the current M2 solver cannot evaluate the public role/clue path; `no_solution`/`contradiction` means zero compatible Evil sets; `multiple_solutions` means 2+ compatible Evil sets; `unique_solution` means exactly one compatible Evil set.
- Solver uniqueness target is the canonical Evil suspect set, not every hidden role identity. `CaseGeneratorSolverResult.compare_unique_solution_to_ground_truth()` may compare a derived unique set against hidden truth only after solving.
- Solver input boundary: `GeneratedPublicCaseView` carries public board dimensions, public suspects, structured public clues, and public Evil count. The solver must not read `HiddenCaseDraft`, hidden Evil answers, UI labels, or presentation nodes.
- Supported M2 solver role scope: `tutorial_priest`, `priest`, `reporter`, `therapist`, `weatherman`, `blood_hound`, `mathematician`, `mailman`, `role_meddler_a`, and `tutorial_mobster`. Other roles remain unsupported/excluded until their public mechanics are modeled.
- Initial generated public-information role scope: static/passive clue roles only: Priest/Tư Tế, Reporter/Sử Quan, Therapist/Ngự Y, Weatherman/Nhà Khí Tượng, Blood Hound/Ngự Khuyển Quan, Mathematician/Nhà Toán Học, and Mailman/Dịch Phu. Complex corruption, impersonation, transforms, timed kills, active-function results, death mutation, and borrowed functions remain deferred.
- Solver model: deterministic exhaustive Evil-set enumeration bounded by current 3x3/4x4 suspect counts, then structured clue replay through existing `RoleInformationEvaluationService`; solution sets are sorted/deduplicated by suspect id signature.
- Determinism: public clue fingerprints are ordered by generated suspect/public clue order and are included in the generator fingerprint. Global RNG must not perturb public clue output.
- Pipeline boundary: Candidate Generator → Solver/Solvability → M3 rejection/retry composition → Seed Warehouse/runtime selection. M2 evaluates candidates; it does not guarantee `CaseGenerator.generate()` returns only solvable cases.

## CASE GENERATOR M3 — DETERMINISTIC ACCEPTANCE / RETRY

M3 composes M1 candidate generation with M2 solver results. It finds an acceptable UNIQUE candidate deterministically; it does not persist warehouse seeds and does not select generated cases in production gameplay.

- Files: `CaseGenerationAcceptanceService.gd` owns retry composition and derived seeds; `CaseGenerationAcceptanceResult.gd` stores domain-only acceptance diagnostics.
- Pipeline: Candidate Generator → Solver/Solvability → M3 Deterministic Acceptance/Retry → M4 Seed Warehouse / runtime selection.
- Derived seed policy: attempt `0` uses `CaseGenerationRequest.seed`; later attempts use `positive_mod(root_seed + attempt_index*1000003 + generator_version*9176 + board_columns*101 + board_rows*211 + required_suspect_count*307 + required_location_count*401 + allowed_role_count*503 + profile_component*601, 2147483647)`, where `profile_component` is `19` for tutorial/easy, `31` for normal/full, and `17` fallback. This does not change direct M1 `CaseGenerator.generate()` semantics for callers that provide a seed themselves.
- Default cap: `CaseGenerationAcceptanceService.DEFAULT_MAX_ATTEMPTS = 24`; exhaustion returns a structured failure, not the last bad candidate.
- Acceptance condition: accept only when solver status is `unique_solution` and `CaseGeneratorSolverResult.compare_unique_solution_to_ground_truth()` confirms the unique public solution matches `HiddenCaseDraft.hidden_evil_suspect_ids` after solving.
- Rejection reasons: generation failure, unsupported solver path, no solution/contradiction, multiple solutions/ambiguous, unique ground-truth mismatch, or solver failure.
- Result contract: success flag, accepted candidate, root seed, accepted derived seed, accepted attempt index, attempts performed, accepted solver result, rejected status counts/details, and failure reason.
- Deferred M4+ work: difficulty scoring, Seed Warehouse entries, runtime random-case launch, deception-aware solving beyond current M2 scope, production UI integration, and content-pool expansion.

## CASE GENERATOR M4A — SEED WAREHOUSE BUILD / VERIFY

M4A builds and verifies a deterministic pool of M3-accepted UNIQUE candidates. It does not select cases for gameplay and does not integrate generated cases into runtime UI.

- Files: `CaseSeedWarehouseEntry.gd` stores accepted candidate provenance; `CaseSeedWarehouseBuildResult.gd` stores ordered build output/summary; `CaseSeedWarehouseBuilder.gd` precomputes entries and verifies them by regenerating through M3.
- Pipeline: M1 Candidate Generator → M2 Solver → M3 Acceptance/Retry → M4A Warehouse Build → M4B Runtime Selection.
- Entry fields: schema version, root seed, accepted derived seed, accepted attempt index, board/profile config, allowed role ids, required location ids, suspect count, generator version, stable candidate signature, canonical Evil solution ids, solver signature, and acceptance signature.
- Build fields: ordered entries, requested root seeds, target count, produced count, rejected root count, duplicate-skipped count, failure summary, build signature, schema version, generator version, and profile id.
- Ordering rule: root seeds are traversed in the provided deterministic order; accepted entries are appended in that traversal order and are not sorted afterward.
- Duplicate policy: duplicate accepted structural `candidate_signature` values are skipped after the first occurrence and recorded as `duplicate_signature`.
- Verification path: warehouse entry → reconstruct `CaseGenerationRequest` from stored root/config → rerun M3 → require accepted attempt index, accepted derived seed, candidate signature, and Evil solution set to match.
- Version rule: entry schema version must match `CaseSeedWarehouseEntry.SCHEMA_VERSION`; generator version must match the current generator version. M4A rejects mismatch cleanly and does not attempt migration.
- Serialization shape: entry/build `to_dictionary()` exports only deterministic IDs, integers, signatures, and arrays. No UI/node state or player-facing formatted text is stored.
- Deferred M4B+ work: random/weighted warehouse selection, no-repeat session history, gameplay launch integration, difficulty balancing, persistence files, and production case rotation.

## CASE GENERATOR M4B — SINGLE-ENTRY WAREHOUSE SELECTION

M4B selects one entry from an existing M4A warehouse. It does not generate cases, build/rebuild warehouses, persist files, launch gameplay, or implement 3-option case voting.

- Files: `CaseSeedWarehouseSelector.gd` owns deterministic single-entry selection; `CaseSeedWarehouseSelectionResult.gd` stores domain-only selection diagnostics.
- Pipeline: M1 Candidate Generator → M2 Solver → M3 Acceptance → M4A Warehouse → M4B Single-entry Runtime Selector → later 3-option case selection/voting/gameplay integration.
- Deterministic pick formula: filter eligible entries in existing warehouse order, then start at `positive_mod(selection_seed + generator_version*7919 + board_columns*157 + board_rows*263 + required_suspect_count*383 + required_location_count*467 + allowed_role_count*587 + profile_component*683, eligible_count)`, where profile component matches M3 style (`19` tutorial/easy, `31` normal/full, `17` fallback).
- Entry identity for session no-repeat: `candidate_signature`. The caller passes used candidate signatures; M4B excludes them and does not mutate the warehouse or own long-lived session state.
- Eligibility filters: entry must have compatible schema version, current generator version, and requested board/profile/role/location/suspect-count config. Used entries are excluded before picking.
- Verification/fallback: after computing the deterministic start index, M4B verifies the candidate through M4A `verify_entry()`. If verification fails, it walks eligible entries circularly in stable warehouse order and selects the first valid entry. If none verify, it returns structured failure.
- Selection result fields: success, selected entry, selected warehouse index, selection seed, eligible count, skipped-used count, skipped-invalid count, deterministic start index, selection signature, and failure reason.
- Deferred next work: selecting three distinct case options, voting, no-repeat session persistence, gameplay launch integration, weighted/difficulty selection, and production UI.

## CASE GENERATOR M5A — THREE DISTINCT OPTION COMPOSITION

M5A composes exactly three verified distinct domain case options from an existing M4A warehouse by repeatedly using M4B single-entry selection. It does not display options, collect votes, launch gameplay, persist session usage, rebuild warehouses, or generate new candidates.

- Files: `CaseSeedWarehouseOptionComposer.gd` owns stateless three-option composition; `CaseSeedWarehouseOptionSetResult.gd` stores domain-only option-set diagnostics.
- Pipeline: M1 Candidate Generator → M2 Solver → M3 Acceptance → M4A Warehouse → M4B Single-entry Selector → M5A Three-case Option Composer → M5B Voting / Gameplay Integration.
- Option-seed formula: for option index `i`, use `positive_mod(option_set_seed + i*1000003 + i*i*37 + generator_version*9181 + board_columns*113 + board_rows*223 + required_suspect_count*331 + required_location_count*419 + allowed_role_count*521 + profile_component*631, 2147483647)`, where profile component is `19` tutorial/easy, `31` normal/full, `17` fallback.
- Distinctness rule: options are distinct by `candidate_signature`. Caller-provided session-used signatures are copied into a local exclusion set, and each selected option signature is added only to that local set while composing the current option set.
- Session boundary: M5A never mutates caller `used_candidate_signatures`, never mutates the warehouse, and never records options as permanently used. Later voting/gameplay flow decides which played signature enters session history.
- Verification/fallback: every option is selected through M4B, so schema/version/profile filtering and M4A `verify_entry()` fallback remain authoritative for each entry.
- Failure behavior: if fewer than the requested three compatible verified unused distinct entries are available, M5A returns structured failure with selection diagnostics but does not expose partial option entries/signatures as a usable option set; it never returns duplicate options or silently reduces the option count.
- Option-set result fields: success, option entries, warehouse indices, candidate signatures, selection seeds, requested/produced count, original option-set seed, selection diagnostics, skipped-used/skipped-invalid counts, deterministic option-set signature, and failure reason.
- Deferred next work: voting UI, vote tally/tie-breaks, case launch, session-used persistence policy for the actually played case, progression/difficulty weighting, and production main-game flow.

## CASE GENERATOR M5B — NEXT-CASE VOTING/GAMEPLAY INTEGRATION BOUNDARY

M5B integrates M5A output into the existing `MvpIntegratedNextCaseSession` next-Round Case boundary. It does not add a new voting system, rebuild warehouses, or redesign case-selection UI.

- Existing architecture reused: `MvpIntegratedNextCaseSession` remains the Round continuation authority; `start_next_round(case_id)` remains the static fixture/debug path. Generated case options use the added `compose_next_case_options()` and `start_next_round_from_option()` path.
- M5A invocation point: `compose_next_case_options()` receives a prebuilt M4A warehouse, option-set seed, profile request, roles, and session-used signatures from `MvpMatchState.used_case_candidate_signatures`, then calls `CaseSeedWarehouseOptionComposer.compose_options()`.
- Round option state: the selected three-option set is held on the session as `next_case_option_set` plus resolved `next_case_option_definitions`. Re-reading the state returns the same composed set and does not recompute during the same Round-selection boundary.
- Vote mapping: `start_next_round_from_option(option_index)` resolves the winning index to the corresponding M5A option and launches that Case through the existing `_start_next_round_with_case()` setup path used by the static next-case flow.
- Session-used commit: only the actually selected option's `candidate_signature` is appended to `MvpMatchState.used_case_candidate_signatures` after Round start succeeds. Offered but unselected signatures remain eligible later.
- Failure behavior: failed M5A composition stores diagnostics but does not publish partial option definitions or start a Round.
- Deferred next work: player-facing three-option/voting presentation, vote tally/tie-break UI, production warehouse persistence/loading, difficulty/progression display, and main-game phase integration.

## CASE GENERATOR M5C — PLAYER-FACING THREE-CASE OPTION PRESENTATION

M5C exposes the already-composed M5B three-option state in the existing player-facing next-Case screen. It is presentation + binding only; it does not compose options, tally multiplayer votes, break ties, load production warehouses, rebalance rewards/difficulty, or alter Match/Round gameplay.

- Authoritative scene/controller: `scenes/player_facing/PlayerFacingStart.tscn` and `scripts/presentation/player_facing/PlayerFacingStartController.gd`.
- M5B state dependency: the controller asks the active `MvpIntegratedNextCaseSession` to `prepare_default_next_case_options()` once when the existing Round Summary → Next Case transition is reached, then reads `case_option_presentations()` from that same `case_flow`. UI refreshes never call `compose_next_case_options()` and must not recompute or reshuffle the option set.
- Runtime reachability bridge: `prepare_default_next_case_options()` is session-owned and uses the existing M4A/M5B pipeline to prepare an in-memory default option set for the current player-facing flow. Production warehouse persistence/loading remains deferred.
- Option binding rule: when exactly three stored procedural options are available, `NextCaseOption1/2/3` are shown in M5A/M5B order and call `start_next_round_from_option(0/1/2)`. The chosen option maps to the pre-resolved `next_case_option_definitions[index]` and launches through the existing next-Round setup path.
- Static compatibility: the explicit authored/static `start_next_round(case_id)` API remains available for debug/test callers, but normal player-facing UI must not silently show the old authored fallback when procedural options are unavailable.
- Empty/failure behavior: missing or failed option state hides procedural option buttons and does not expose partial selection controls.
- Deferred next work: multiplayer vote tally, tie-break presentation, production warehouse persistence/loading, difficulty/progression display, and main-game phase integration.

## CASE GENERATOR M5D — PROCEDURAL CASE SOURCE BOOTSTRAP + ROUND-1 OPTION SELECTION

M5D makes the existing M5B/M5C three-option source reachable from normal player-facing runtime. It does not add vote tally, warehouse disk persistence, difficulty weighting, or a new case-selection screen.

- Round 1 boundary: after character lineup confirmation, `PlayerFacingStartController` creates the existing `MvpIntegratedNextCaseSession`, calls `initialize_player_facing_case_options()`, prepares default procedural options once, and moves the setup session to `NEXT_CASE_SELECTION`. No authored/sample Case launches merely because it is Round 1.
- Source bootstrap: `MvpIntegratedNextCaseSession.prepare_default_next_case_options()` uses an in-memory session-owned default Seed Warehouse built through the real generator pipeline (`CaseSeedWarehouseBuilder` / M1-M4A, then M5A/M5B). It is idempotent for the current option-selection boundary and is not rebuilt on UI redraw.
- Production variety follow-up: `PlayerFacingSetupSession.begin_new_game()` stores a positive `MvpMatchState.case_generation_seed` once. The session derives warehouse roots from that seed and option-set seeds from Match seed plus Round number. The warehouse remains cached; only selected candidate signatures enter persistent no-repeat history. Legacy/test Matches with seed `0` retain their old fixed deterministic source. A fixed 24-root production sweep in GUI Smoke records accepted count and distinct signatures, Evil sets, role compositions, placements, and clue combinations.
- Selection contract: all visible Round 1 and later option buttons read the stored M5B option set and launch through `start_next_round_from_option(index)`. Only the selected option's candidate signature is appended to `MvpMatchState.used_case_candidate_signatures`; unselected offered options remain eligible.
- Failure contract: normal player-facing UI hides procedural buttons and does not expose the old `vs_case_001` fallback when three procedural options cannot be prepared. Static authored APIs remain explicit debug/test paths only.
- Deferred next work: multiplayer voting/tie-breaks, production warehouse persistence/loading, case difficulty/progression display, and broader main-game phase integration.

## CASE GENERATOR M5E-R — CANONICAL PRODUCTION POOL WITHOUT MEDDLER

- Production v1 intentionally has no procedural Kẻ Bao Đồng candidate. The default five-suspect request in `MvpIntegratedNextCaseSession._default_next_case_generation_request()` contains only `tutorial_priest`, `reporter`, `therapist`, `weatherman`, `blood_hound`, `mathematician`, `mailman`, and `tutorial_mobster`.
- `CaseGenerator` requires Good and Evil candidates, not every role group; the four-group validator rule applies only to the authored eight-suspect fixture. The solver enumerates Evil sets from public count and supports zero-Meddler worlds, including Weatherman's special no-Meddler clue. M3 acceptance, warehouse build, and M5A selection reuse those authorities unchanged.
- `role_meddler_a` and other placeholder resources remain loaded for explicit fixtures/debug/tests, but are excluded from normal player-facing procedural requests. No fake canonical replacement or special zero-Meddler generation rule is added.
- At the M5E-R boundary, Copycat, Drunkard, and Surgeon were deferred; M6A subsequently adds Copycat while Drunkard and Surgeon remain deferred.

## CASE GENERATOR M6A — PRETEND + TRUTHFULNESS FOUNDATION

- Generated hidden suspects now retain `true_role_id`, `displayed_role_id`, `impersonated_role_id`, and `is_impersonating`, then project those into existing `SuspectDefinition` fields. Runtime `RoleInformationEvaluationService` resolves behavior from displayed role and truthfulness from true role/corruption independently: Copycat and Conman tell the truth, while existing Mobster lying behavior is unchanged.
- `CaseProceduralPretendCapability` is the shared narrow procedural target rule. Static targets remain Priest, Reporter, Therapist, Weatherman, Blood Hound, Mathematician, and Mailman. Slice 4 additionally allows only Copycat to pretend current in-play native Tailor/Vigilante; other pretenders and Milkman support are unchanged. Active targets remain outside automatic clue generation.
- `CaseGenerator` chooses in-play non-self pretend targets deterministically with its local seeded RNG, rejects candidates without a valid target, and evaluates public clues through the displayed behavior. Final CaseDefinitions retain the request's suspected-role pool for the existing Role Reference/list. Generated candidate signatures include pretend-target identity; non-pretend signatures retain their previous shape.
- `GeneratedPublicCaseView` exposes displayed roles, public Evil count, role-pool context, and public clues, without copying true role or hidden claim-truth flags into solver input. `CaseGeneratorPublicSolver` enumerates compatible true-role/pretend hypotheses for worlds of at most nine suspects (including the M2 4x4 fixture) and replays clues through `RoleInformationEvaluationService`; larger pretend worlds return structured unsupported status. It does not read hidden Evil ids. M2 uniqueness remains uniqueness of the Evil suspect set, not exact hidden assignment.
- Normal player-facing default procedural role pool adds canonical `copycat` and `conman` alongside existing roles, including Mobster. Fixture placeholders remain available only to explicit fixture/debug requests. M3 acceptance, M4 warehouse verification, M4B selection, and M5A option composition continue to use their existing authorities.
- Deferred after M6A: procedural activation/solver hypothesis enumeration for Drunkard/Barkeep transformation and Spectre obscure; Surgeon/Serial Killer timed deaths, Clock Maker environment, Critic, and broader active-function pretend generation remain later work. M6B-P1 enables Poisoner taint only.
- M6A runtime regression lock: procedural Mobster (`tutorial_mobster`/`mobster`) requires a deterministic current in-play natural target and keeps its existing lying truth mode. Broad Disguise Slice A expands its procedural clue-only targets to Priest, Reporter, Therapist, Mathematician, Weatherman, Blood Hound, and Mailman; Slice B adds Clock Maker; Slice D1 adds Tailor and Vigilante behind Slice C's shared current-native-witness authority. The shared pretend capability and public solver model that relation, while Scoundrel remains self-displayed with no pretend.
- M6A role-universe regression lock: generated clues use the request's suspected-role pool. Mailman prefers that pool for the absent-role choice; when all listed roles are in play, it extends only with non-placeholder canonical role definitions, never the whole fixture repository. True generated Weatherman requires an actual in-case Meddler plus another Innocent; generated Weatherman-behavior clues must be complete three-address reports. Weather target groups follow current role when runtime transformation state exists, otherwise authored true role; the displayed disguise is not a category authority. The no-Meddler special remains available to explicit unnatural/debug evaluation, not natural procedural output. The M2 4x4 solvability check keeps nine suspects and adds one spare canonical role to its pool; its all-role representative clue checks use the separate nine-role 4x4 fixture.
- The M2/M6A-R nine-suspect 4x4 test pool uses loaded `copycat` as its spare absent canonical role; `priest` is not loaded as a RoleDefinition (the authored tutorial uses `tutorial_priest`).
- Case cards take pre-reveal role color from the displayed role group and Full Reveal color from the revealed current/true group. Obscured public roles do not expose their group through color metadata. `RoleReferenceOverlay` and `PrivateKnowledgeOverlay` sit above card child overlays in the same canvas, with no card geometry or role-name position changes.

## CASE GENERATOR M6B — TAINT / TRANSFORM / OBSCURE FOUNDATION

- `CaseMutationStateSnapshot` is a read-only projection of existing CaseDefinition + CaseRuntimeState authorities. Original/current/displayed/behavior role ids, current group/alignment, truth mode, taint, obscure, and pretend remain separate. Current role comes from `CaseRuntimeState`; displayed/behavior roles retain the existing Tutorial 06 contract (transformed Drunkard can speak as displayed Mailman while lying). Taint leaves role/group intact. Obscure masks public role/group without changing hidden current role.
- `GeneratedPublicSuspectView.from_mutation_state()` projects only public identity and group, never hidden mutation fields. The foundation solver boundary was initially conservative for obscured identity and Barkeep/Drunkard/Spectre pools; P1-P3 add explicit public candidate-world models one mechanic at a time. Unsupported mutation worlds must still return `UNSUPPORTED` instead of a guessed Evil set.
- Full Reveal takes current role group/alignment labels from the current role definition, while retaining the original role separately. The dev Case Audit can read current runtime mutation state after Full Reveal without rerunning generation or solving. Tutorial 03/06 fixture checks cover taint, transform, obscure, public mask, reveal, solver boundaries, and compact audit output. P1-P3 subsequently enable Poisoner, Barkeep/Drunkard, and Spectre through their explicit public candidate-world models.

## CASE GENERATOR M6B-P1 — POISONER PROCEDURAL ENABLEMENT

- Default normal-play pool adds only `poisoner` (Độc Sư). The existing Poisoner rule requires a suspected-role disguise. Generated Poisoner drafts choose a displayed in-play supported role, then use `PoisonerTaintService` to select exactly one occupied 8-neighbor Innocent target; drafts without an eligible target are rejected. `CaseSpatialService` resolves that adjacency from current Case board dimensions, including 4x4. Hidden source/target are retained in the draft fingerprint and exported to generated startup fields; non-Poisoner fingerprints and RNG decisions remain unchanged.
- Generated startup applies the authored target through `PoisonerTaintService.resolve_taint`; authored/tutorial startup retains its existing random-target route. Public clue generation and solver replay use the same taint service and `RoleInformationEvaluationService`. The solver enumerates possible Poisoner role assignments (including suspected-only disguises) and eligible taint targets from public candidate worlds; it never reads the generated hidden target. M3 uniqueness and ground-truth comparison, warehouse verification, and M5 option selection remain the acceptance authorities.
- Lying Blood Hound outcomes in generated Poisoner worlds use the same stable procedural clue mode during generation, solver replay, and runtime; authored/tutorial behavior is untouched. Public role/group remain the displayed identity, while Full Reveal and dev audit use current hidden role/taint state. At the P1 boundary, Barkeep, Drunkard, and Spectre were still absent from the default pool and unsupported by the production solver.

## CASE GENERATOR M6B-P2 — BARKEEP / DRUNKARD PROCEDURAL ENABLEMENT

- Default normal-play pool additionally enables `barkeep` (Chủ Quán Rượu), never top-level `drunkard` or `spectre`. Generated Barkeep drafts deterministically choose one occupied original Innocent and apply `BarkeepTransformationService`; the target keeps its original role, becomes current Drunkard (HIEU_SU), and displays a seeded Good role not currently in play. Displayed role drives its LYING clue without setting pretend state. Drunkard stays nested under Barkeep in the Case Suspect List.
- Generated startup uses existing Barkeep source/target fields and the same transform service as Tutorial 06. The public solver enumerates Barkeep assignments, legal Innocent transform targets, and public displayed Good roles, replaying clues through the existing runtime transform service. It reads no generated hidden target. M3 unique Evil-set acceptance and warehouse/M5 selection remain unchanged. At the P2 boundary, Spectre and standalone Drunkard pools remained `UNSUPPORTED`; P3 enables Spectre only.

## CASE GENERATOR M6B-P3 — SPECTRE / OBSCURE PROCEDURAL ENABLEMENT

- Default normal-play additionally enables `spectre` (Vong Linh), while standalone `drunkard` remains outside the pool. Spectre uses the existing pretend capability to display a supported in-play role; that displayed role is its behavior source and its truth mode remains `LYING`. Generation deterministically selects exactly one other occupied suspect, excludes authored/current Meddlers and the Barkeep transform target, and rejects the draft cleanly when no legal obscure target exists.
- Obscure is public identity hiding only. The target retains original/current role, group, alignment, behavior, truth mode, taint, transform state, and clue semantics. Normal presentation masks the target role name and role-group color while keeping its public clue visible. Full Reveal restores authoritative current role/group and retains the Spectre-to-target relation for dev truth/audit.
- `GeneratedPublicCaseView` exports only the obscured identity flag plus the target's public clue behavior; it does not expose hidden source, target role, pretend choice, or Evil set. `CaseGeneratorPublicSolver` enters the existing pretend-world search for Spectre pools, infers the single obscured slot from public state, enumerates legal Spectre source/role assignments, and validates source/target compatibility before clue replay. Evil-set uniqueness, M3 acceptance, warehouse verification, and M5 selection remain unchanged; no hard hypothesis cap or second solve was added.

## CASE GENERATOR EXPANSION SLICE 1 — KẺ BẤT LƯƠNG

- Normal procedural generation now includes canonical `tutorial_scoundrel` (Kẻ Bất Lương) as a self-displayed Thuộc Hạ/Evil role with no pretend, mutation target, active function, timed event, or public clue payload. `CaseGeneratorPublicSolver` treats it as a supported silent Evil hypothesis; ordinary UNIQUE Evil-set plus ground-truth M3 acceptance remains mandatory.
- `ScoundrelImmunityService` keeps two explicit runtime checks: kill handling reads the target's current role, effective taint, and other Evil suspects' global dead/arrested state; single-suspect accusation reads the acting player's private successful-Evil history. Displayed/pretended identity is never part of either predicate.
- Kẻ Bất Lương Chỉ Điểm immunity is player-private: while another true Evil exists, an untainted Kẻ Bất Lương can be successfully identified only after that same player has already correctly identified another true Evil. A sole Kẻ Bất Lương remains accusible, preserving Tutorial 01 and avoiding an impossible prerequisite. Another player's record and global death state do not unlock it. Chỉ Điểm never sets global `SuspectRuntimeState.is_arrested`; successful progress lives in the player-keyed action/private records. Taint still disables immunity. A blocked Chỉ Điểm consumes the existing action consequence but adds no successful record. Kill immunity remains the separate existing runtime rule; killing Evil still does not remove that suspect from the exact verdict answer.
- Slice 1 added only Scoundrel; native Tailor/Vigilante and Copycat borrowing them are covered by Slices 2–4 below. Clock Maker, Surgeon, Serial Killer, and Critic are enabled by later slices; standalone Drunkard and other active-function impersonations remain deferred.

## CASE GENERATOR EXPANSION SLICE 2 — NATIVE THỢ MAY

- Native `tailor` is enabled in `MvpIntegratedNextCaseSession._default_next_case_generation_request()` and registered in `CaseGeneratorPublicSolver.SUPPORTED_PUBLIC_ROLE_IDS` as a silent Good role. Existing `CaseGenerator` unique-role construction and Case/public projection are reused; Tailor stays outside `CaseProceduralPretendCapability.STATIC_BEHAVIOR_ROLE_IDS`, so no automatic clue or new pretend target is introduced.
- Locked acceptance timeline: optional player-chosen future information must not be required by procedural acceptance. No generated Tailor pair, SAME/DIFFERENT result, or pre-game function record exists. M3 still requires UNIQUE Evil set plus ground-truth match from pre-function evidence; ambiguous Cases retry normally.
- Runtime remains owned by `FunctionAvailabilityService` and `InteractiveFunctionExecutionService`: hidden/unused at initialization, investigation unlocks on the next turn, player chooses two targets, effective truth mode applies, and successful one-use execution creates the public record. Tutorial 04 and the prior runtime Poisoner-taint fix remain unchanged. Copycat -> Tailor is enabled in Slice 4; Mobster borrowing and post-function solver replay remain deferred.
- `tests/unit/case_generator/CaseGeneratorTailorTestSuite.gd` adds 10 Smoke rows for silent generation/solver/acceptance, runtime lifecycle, Mailman role visibility, uniqueness, ambiguous rejection, and production capability boundaries. Expected GUI Smoke: 2743/2743 from the human-confirmed 2733 baseline; GUI verification pending. Existing conservative solver handling of an obscured identity with no public clue behavior is unchanged.

## CASE GENERATOR EXPANSION SLICE 3 — NATIVE SƯ TỬ PHÁN

- Native `vigilante` is a supported silent Good role in `CaseGeneratorPublicSolver.SUPPORTED_PUBLIC_ROLE_IDS` and the default `MvpIntegratedNextCaseSession` production pool. Existing generator construction, true-role uniqueness, 5–8 production suspect range, and 3x3 maximum of three Evil remain unchanged.
- No target, kill/miss outcome, automatic clue, or public function record is generated. Acceptance still requires UNIQUE Evil set plus ground-truth match from pre-function evidence. Runtime owns the hidden/unused -> investigation -> next-turn availability -> player-selected one-use action; the effective-truth-mode fix and `CaseKillService`/Scoundrel immunity are preserved.
- Native Slice 3 did not expand pretend targets; Slice 4 enables Copycat -> Vigilante and later Broad Disguise Slice D1 enables Mobster -> Vigilante behind the shared current-native-witness requirement. Case Audit continues to show role identity only, with no future function data. Existing conservative rejection of obscured identities lacking public clue behavior remains intact.
- `tests/unit/case_generator/CaseGeneratorVigilanteTestSuite.gd` adds 10 Smoke rows. Root seed `112233`, five suspects, and canonical pool Vigilante/Priest/Reporter/Therapist/Scoundrel exercise normal acceptance without a function result; Vigilante/Priest/Conman exercises ambiguous rejection. Runtime handoff, Mailman visibility, uniqueness, and capability boundaries are covered. Tutorial 05, runtime Poisoner-taint, and Scoundrel immunity regressions are reused unchanged. Expected GUI Smoke: 2756/2756 from human-confirmed 2746; GUI verification pending.

## CASE GENERATOR EXPANSION SLICE 4 — COPYCAT BORROWED ACTIVE FUNCTIONS

- `CaseProceduralPretendCapability.COPYCAT_ACTIVE_ROLE_IDS` identifies Tailor/Vigilante as active behaviors requiring a current native witness. Slice 4 first enabled them for Copycat; Broad Disguise Slice C centralized the witness requirement, and Slice D1 later reused it for Mobster without changing Copycat behavior. True Copycat remains HIEU_SU/Good, displayed duplicates are allowed, and true-role uniqueness is unchanged.
- Runtime audit confirms both borrowed functions already use `FunctionAvailabilityService` displayed-role fallback, shared Tailor/Vigilante dispatch, effective owner truth mode, and one-use public records. Runtime code, Tutorial 08, Poisoner rules, and Scoundrel immunity are unchanged. No generated targets/results or future-action evidence enter acceptance; normal UNIQUE Evil-set plus truth-match acceptance/retry remains mandatory.
- `CaseGeneratorCopycatActiveTestSuite.gd` adds 17 Smoke rows across the two active targets and the capability boundary. Deterministic evidence searches roots 112233–112256 using the five canonical roles Copycat/Tailor/Vigilante/Priest/Scoundrel with unchanged acceptance budget, and reports the matching root/accepted seed in each acceptance row. It covers missing/current witnesses, true-role Mailman presence, no pre-game results, borrowed lifecycle/execution/owner taint, determinism, and ambiguous rejection. Native suites retain their tests with only stale Copycat exclusion expectations updated. Expected GUI Smoke: 2773/2773 from confirmed 2756; GUI verification pending.
- Mobster Tailor/Vigilante borrowing is enabled by Broad Disguise Slice D1; Broad Disguise Slice D2 subsequently enables the same displayed active behaviors for Serial Killer while retaining its independent true-role timed event. Post-function solver replay and other new disguise targets remain deferred.

## CASE GENERATOR EXPANSION SLICE 5 — NATIVE THỢ ĐỒNG HỒ

- Continues the interrupted native `clock_maker` pass. The prior runtime audit confirmed fixed Case-owned `ClockTowerDefinition.ring_hour`, automatic investigation information, and effective runtime Poisoner truth mode. Acceptance uses the existing full automatic-investigation public view, not initial visibility, future player-selected functions, or future random outcomes. Runtime death can prevent an investigation; this pass does not promise solvability for every optional gameplay path or add post-kill evidence.
- `CaseGenerator._assign_clock_tower()` reuses a requested tower or allocates one empty logical slot when Clock Maker is listed (including a red herring). No suspect is moved or removed. A mandatory tower with no free slot rejects the draft under the existing retry budget. The 3x3 nine-tile limit, 5–8 requested suspect range, true-role uniqueness, and combined maximum of three Evil are unchanged.
- Hidden draft stores seeded `clock_tower_ring_hour` (1–23), fingerprints it, and projects it to the existing `ClockTowerDefinition` resource. Ringing is at that hour and the next. `GeneratedPublicClue` records `clock_start_hour`, `clock_end_hour`, and the public announcement's ringing/non-ringing claim; runtime wording is unchanged. `GeneratedPublicCaseView` copies only this announcement and the public tower slot, never the hidden ring schedule or hidden answer.
- `CaseGeneratorPublicSolver` supports native Clock Maker through existing identity/alignment constraints and supports explicitly approved Clock Maker disguise hypotheses through the shared pretend capability. It requires a valid unoccupied tower slot and searches legal schedule hypotheses consistent with the announcement and candidate effective truth mode. Other clues replay once after a compatible schedule is found because no other supported clue depends on that schedule. Existing UNIQUE Evil-set plus ground-truth acceptance, retry limits, warehouse, and launch authorities remain unchanged.
- Default `MvpIntegratedNextCaseSession` added `clock_maker` in Slice 5. Broad Disguise Slice B later enables procedural Mobster, Copycat, and Critic Clock Maker behavior; Serial Killer -> Clock Maker remains enabled by Slice 7's dedicated capability. Conman, Poisoner, Barkeep, Spectre, and standalone Drunkard cannot disguise as Clock Maker. Existing Tutorial 07 authored behavior is untouched.
- Dev-only `CaseGenerationAuditSnapshot` retains the accepted hidden ringing hours under HIDDEN TRUTH; the public clue already supplies its announcement under PUBLIC CLUES. No audit re-solve is added.
- `tests/unit/case_generator/CaseGeneratorClockMakerTestSuite.gd` adds 18 Smoke rows; stale deferred-role/status expectations are updated without removing assertions. Human baseline 2773; expected GUI Smoke 2791/2791, not yet run. Fixed root 112233 / five roles Clock Maker, Priest, Reporter, Therapist, Scoundrel exercises normal acceptance. `SLICE5_CLOCK_EVIDENCE` prints the actual accepted seed, suspect count, tower slot, ring hours, public interval, and solver result during GUI Smoke; those runtime values still require human confirmation.

## CASE GENERATOR EXPANSION SLICE 6 — NATIVE BÁC SĨ PHẪU THUẬT

- Native `surgeon` is enabled as a self-displayed HIEU_SU/Good role. Existing unique-role generation is sufficient; no victim, 12h result, timed public record, automatic clue, special location, or pretend target is generated.
- `CaseGeneratorPublicSolver` treats Surgeon as a silent supported hypothesis. Surgeon participates in true-role uniqueness, role/group/alignment hypotheses, the in-play role universe, and Mailman present/absent evaluation, but the solver never advances time or consumes a future timed result. M3 acceptance remains UNIQUE Evil set plus ground-truth match with the existing retry budget.
- The normal player-facing pool adds native Surgeon. Copycat/Mobster -> Surgeon remain disabled; Serial Killer and Critic are enabled by later dedicated slices. Standalone Drunkard remains disabled. Accepted Cases initialize with no Surgeon timed result; `CaseTimedEventDispatcher` and `SurgeonTimedEventService` remain the sole 12h authorities, including the locked current-role-group victim rule.
- `tests/unit/case_generator/CaseGeneratorSurgeonTestSuite.gd` adds 15 Smoke rows for silent generation/solver support, Mailman and uniqueness behavior, ambiguous rejection, normal acceptance, clean runtime handoff, capability boundaries, and Tutorial 05 preservation. `SLICE6_SURGEON_EVIDENCE` prints root seed, accepted derived seed, suspect count, Surgeon id, solver result, and confirms `timed_evidence=false`. Human baseline before Slice 6 is 2792; expected GUI Smoke is 2807/2807 pending confirmation.

## CASE GENERATOR EXPANSION SLICE 7 — NATIVE SERIAL KILLER

- Runtime Serial Killer targets use `CaseMutationStateSnapshot.current_alignment == GOOD`; authored or displayed groups are not target authority. Barkeep-transformed Drunkard remains eligible because its current alignment is Good. Dead targets remain excluded, arrested Good targets retain the existing eligible behavior, and `CaseKillService` remains final kill authority.
- The existing spawn validator now evaluates the post-startup state by initializing a temporary runtime and reusing `BarkeepTransformationService`. Serial Killer requires an orthogonally adjacent suspect whose current group remains `CHINH_NHAN`; a sole authored Innocent transformed to Drunkard no longer satisfies the invariant.
- `CaseProceduralPretendCapability.SERIAL_KILLER_LYING_BEHAVIOR_ROLE_IDS` is the shared capability authority for Serial Killer disguises: Priest, Reporter, Therapist, Weatherman, Blood Hound, Mathematician, Mailman, Clock Maker, Tailor, and Vigilante behavior ids after Broad Disguise Slice D2, intersected with the Case Suspect List. Tailor/Vigilante additionally require the shared current-native witness. Tutorial 07 Clock Maker remains valid; Copycat/Mobster -> Serial Killer remain disabled.
- `CaseGenerator` assigns one listed, in-play supported displayed role, then reuses `SerialKillerTimedEventService.serial_killer_spawn_requirement_met()` after Barkeep startup transformation. Invalid placement retries deterministically; no 9h victim or outcome is generated.
- `CaseGeneratorPublicSolver` enumerates Serial Killer as an Evil pretender, replays the displayed role in LYING mode, and rejects candidate worlds lacking an orthogonally adjacent current `CHINH_NHAN` witness after the public Barkeep transform hypothesis. Timed kills never enter public clues or acceptance evidence. M3 still requires UNIQUE Evil set plus ground-truth match.
- The default normal player-facing procedural pool includes `serial_killer`; Critic is enabled later by Slice 8. `CaseTimedEventDispatcher` remains the sole runtime handoff for 9h events and one-time resolution. Standalone Drunkard remains excluded.

## CASE GENERATOR SLICE 8 PREREQUISITE B — CRITIC LISTED-BUT-ABSENT AUTHORITY

- This prerequisite established the authority before production enablement. Critic's player-facing disguise must be an explicitly listed Case role with supported LYING behavior that is absent from current roles after startup mutations; displayed/pretended occurrences do not count as present.
- `CaseRolePoolService` owns listed/current/absent resolution. Critic validation builds the post-startup runtime through the existing Barkeep transformation service, so an authored role transformed away is absent and Drunkard is present.
- Tutorial 05 now authors its domain Suspect List explicitly, including the listed-but-absent Mathematician disguise. Critic player ownership and its legacy `PlayerCaseState.case_role_id` meta effects remain intentionally unwired.
- `CaseGeneratorSerialKillerTestSuite.gd` adds 17 focused Smoke rows for native generation, scoped disguise behavior, post-startup spawn legality, LYING clue replay including Priest wording, solver structural rejection, ambiguous rejection without future timed evidence, UNIQUE acceptance, clean runtime handoff, stable 9h event resolution, production boundaries, and Tutorial 07 preservation. From the confirmed 2819 baseline, expected GUI Smoke is 2836/2836 pending human validation.

## CASE GENERATOR EXPANSION SLICE 8 — CRITIC PROCEDURAL DEDUCTION

- `CaseProceduralPretendCapability.CRITIC_LYING_BEHAVIOR_ROLE_IDS` explicitly limits Critic to Priest, Reporter, Therapist, Mathematician, Weatherman, Blood Hound, Mailman, and Clock Maker behavior ids after Broad Disguise Slices A/B. It does not broaden Copycat, Serial Killer, or other disguise capabilities.
- `CaseGenerator` selects Critic's fake role only after the bounded per-Case Suspect List exists. The role must be listed, capability-approved, and absent from current roles after startup Barkeep transformation; the displayed occurrence never makes it present. No natural in-play witness is required.
- `CaseGeneratorPublicSolver` uses a dedicated Critic hypothesis: true/current role remains Evil Critic, displayed role supplies LYING clue behavior, and the listed fake role must remain absent from hypothesized current roles after startup transform. Mailman still evaluates current true roles, so the fake remains absent. UNIQUE Evil-set plus ground-truth acceptance is unchanged.
- The default normal player-facing pool includes `critic`; standalone `drunkard` remains excluded. Critic reputation/turn-order meta effects and `PlayerCaseState.case_role_id` ownership remain unwired and are not solver evidence. Tutorial 05 mechanics remain unchanged.
- `CaseGeneratorCriticTestSuite.gd` adds 20 focused Smoke rows covering capability boundaries, generation, listed/current-absent authority, LYING replay, dedicated solver hypotheses, Mailman, acceptance, production boundaries, meta-evidence exclusion, and Tutorial 05 preservation. Human GUI Smoke confirmed this baseline at 2863/2863.

## BROAD DISGUISE SLICE A — CLUE-ONLY TARGETS

- `CaseProceduralPretendCapability` is the single disguise capability authority with explicit procedural and authored-compatible scopes. `can_pretend()` remains a backward-compatible procedural alias; generator and public solver call the procedural scope explicitly, while `CaseDefinitionValidator` uses authored-compatible checks.
- Procedural Mobster targets are Priest, Reporter, Therapist, Mathematician, Weatherman, Blood Hound, Mailman, Clock Maker, Tailor, and Vigilante behavior ids after Broad Disguise Slice D1. Tailor/Vigilante require another current native witness through the shared Slice C authority. Authored-compatible Mobster remains a superset and preserves canonical Tutorial 04 and Tutorial 07 fixtures.
- Procedural Critic additionally permits Weatherman, Blood Hound, and Mailman under its existing listed-and-current-absent contract. Critic still has no natural-role witness requirement.
- Generated and hypothesized Mobster disguises require another current in-play natural witness after startup Barkeep transformation. A transformed-away authored role cannot satisfy that witness. Copycat active-role witness handling remains unchanged; Copycat, Serial Killer, and Critic authored/procedural scopes are otherwise identical.
- No tutorial id special cases, new production roles, active/timed/meta evidence, or acceptance-rule changes were introduced.
- `CaseGeneratorDisguiseSliceATestSuite.gd` adds 13 focused rows. Expected GUI Smoke after Slice A is 2876/2876.

## BROAD DISGUISE SLICE B — CLOCK MAKER COVERAGE

- `CaseProceduralPretendCapability` explicitly permits procedural Mobster, Copycat, and Critic to display Clock Maker. Clock Maker is not added to the generic static-behavior allowlist, so Conman, Poisoner, Barkeep, Spectre, and standalone Drunkard remain excluded. Copycat's active-function target list remains Tailor/Vigilante only.
- Mobster and Copycat retain a native/current Clock Maker witness. Critic retains its dedicated listed-and-current-absent hypothesis and does not gain a natural witness requirement. Displayed Clock Maker never becomes current-role presence.
- Existing `CaseGenerator._assign_clock_tower()` remains the dependency authority: a listed Clock Maker allocates the Clock Tower before public-clue generation and fixes `HiddenCaseDraft.clock_tower_ring_hour`. Existing `RoleInformationEvaluationService` derives truthful or LYING two-hour announcements, and `CaseGeneratorPublicSolver` existentially replays the same fixed-schedule contract without receiving a public raw ring-hour field.
- Generator, solver, UNIQUE plus ground-truth acceptance, red-herring budget, production role pool, and Tutorial 07 data are otherwise unchanged. Focused Clock Maker Smoke adds three fixed-root acceptance rows for Mobster, Copycat, and Critic; expected GUI Smoke is 2879/2879 pending human validation.

## BROAD DISGUISE SLICE C — ACTIVE-ROLE NATIVE-WITNESS SAFETY

- `CaseProceduralPretendCapability.behavior_requires_current_native_witness()` owns the narrow policy: Tailor and Vigilante behavior require a current native witness; every other currently supported behavior gains no new requirement. `procedural_current_native_witness_is_satisfied()` checks a non-self suspect-id/current-role projection and never counts displayed identity.
- `CaseGenerator._procedural_active_witnesses_are_valid()` projects startup current roles from generated true roles plus the Barkeep-to-Drunkard target, then applies the shared authority before public clues. A transformed-away native role, another displayed copy, or the source's own display cannot satisfy it. Dead/arrested state is irrelevant at this pre-runtime structural boundary.
- `CaseGeneratorPublicSolver` uses the same policy and satisfaction authority for completed active-role hypotheses, and the same policy in its partial natural-witness feasibility checks. Future player-selected Tailor/Vigilante results remain excluded from acceptance evidence.
- Copycat Tailor/Vigilante generation, solver acceptance, and borrowed runtime functions are behavior-preserved. Slice D1 later enables the same active targets for Mobster, and Slice D2 later enables them for Serial Killer while retaining its independent timed event. Slice C itself added no capability, production-pool, acceptance, tutorial, or runtime-function change. Existing focused Slice 4 rows were strengthened without increasing Smoke assertion count; human GUI baseline after Slices B/C is 2879/2879.

## BROAD DISGUISE SLICE D1 — MOBSTER ACTIVE-ROLE DISGUISES

- Procedural Mobster may display Tailor or Vigilante only when another suspect currently owns that native role. The shared Slice C authority rejects self-display, displayed-only copies, and a native role transformed away into Drunkard. D1 itself did not grant those targets to another pretender; D2 subsequently grants them only to Serial Killer, while Critic and other unsupported pretenders remain blocked.
- Existing runtime behavior-role fallback already grants the displayed Tailor/Vigilante function to a Mobster. Shared effective truth-mode evaluation keeps the Mobster LYING: Tailor reverses its true-alignment comparison and Vigilante always misses. The one-use lifecycle and public function record remain unchanged.
- Active-function targets and outcomes remain future player choices and are absent from generator public clues and solver acceptance evidence. UNIQUE Evil-set plus ground-truth acceptance remains authoritative; no production role, tutorial, role pool, or acceptance rule changes.
- `CaseGeneratorMobsterActiveTestSuite.gd` adds seven focused rows for capability boundaries, shared witness safety, solver rejection without a current native witness, acceptance for both targets, and borrowed LYING runtime execution. Both Mobster -> Tailor and Mobster -> Vigilante lock the human-confirmed one-attempt evidence root/accepted seed `112236`, with Mobster owner `#1` and a UNIQUE ground-truth-matching solve. GUI Smoke confirmed the discovery baseline at 2886/2886; fixed-root cleanup retains the same expected total.

## BROAD DISGUISE SLICE D2 — SERIAL KILLER ACTIVE-ROLE DISGUISES

- Procedural Serial Killer additionally permits Tailor and Vigilante behavior only. Both use Slice C's shared current-native-witness authority; self-display, displayed-only copies, and transformed-away native roles do not qualify. Mobster, Copycat, Critic, production roles, tutorials, and acceptance semantics are otherwise unchanged.
- Runtime coexistence uses existing independent authorities: `SerialKillerTimedEventService` keys the 9h/18h/27h events from current true Serial Killer identity, while `FunctionAvailabilityService` grants the displayed Tailor/Vigilante function through the suspect's separate `interactive_function` state. LYING Tailor reverses SAME/DIFFERENT and LYING Vigilante misses; neither function lifecycle consumes or suppresses the timed event.
- `CaseGeneratorSerialKillerActiveTestSuite.gd` adds nine focused rows. Both Serial Killer -> Tailor and Serial Killer -> Vigilante lock the human-confirmed one-attempt evidence root/accepted seed `112236`, with Serial Killer owner `#1` and a UNIQUE ground-truth-matching solve. GUI Smoke confirmed the discovery baseline at 2895/2895; fixed-root cleanup retains the same expected total.

## CASE GENERATOR VARIETY FOUNDATION

- `CaseGenerationRequest.allowed_role_ids` remains the canonical production generator universe, not a Case's Suspect List. `CaseGenerator` derives each draft's `suspected_role_ids` from every true/displayed role represented in play plus a seeded, bounded selection of absent roles (up to two for 5–6 suspects, one for 7–8). The final order follows the request's canonical role order, with no duplicates. The list is fixed before public clues, exported to `CaseDefinition` and `GeneratedPublicCaseView`, included in the candidate fingerprint, and used by the public solver for role hypotheses and Mailman replay.
- Positive-seed normal player-facing Matches use `CaseSeedWarehouseBuilder.build_varied_suspect_counts()` over deterministic root seeds. Each root requests `5 + posmod(root_seed, 4)` suspects on the fixed 3x3 board with one Crime Scene; the builder reuses M4A's verified acceptance path per root. A production-only selection request uses suspect count `0` as a mixed-count compatibility wildcard while retaining the other M4B profile/version/role/location checks. M5A still composes three distinct verified entries; legacy zero-seed/static/debug requests retain the fixed-count path. No accepted Case is modified after generation.
- Production 3x3 hidden worlds allow at most three total Evil suspects. This cap counts `TONG_PHAM` (Thuộc Hạ) and `NGHICH_THAN` (Nghịch Thần) together; it is not a separate quota per group. Generator retry enforces the cap before public solving, while explicit solver fixtures remain free to exercise larger Evil-set shapes.
- `CaseProductionVarietyTestSuite` sweeps 64 deterministic roots, records accepted count, candidate/list/layout/Evil-set diversity, suspect-count histogram, role frequency, and first-Evil board-position frequency in Smoke details, and checks list integrity, solver uniqueness, deterministic signatures, and mixed-count three-option selection. Rejected counts remain visible in the histogram rather than silently substituted.
- M6B solver performance observability uses one `M6B_SOLVER_DIAG` begin/end pair per public solve. End records separate role/pretend, Barkeep transform, Spectre obscure/pretend, Poisoner target, replay, clue, and prune counters without affecting solver results or fingerprints. The existing production variety sweep aggregates elapsed time from its already-executed solves into count/total/average/maximum plus the slowest root/accepted seed; it never runs a second solve for timing.
- M6B-PERF-OPT-1 checks all still-unsatisfied natural-role witnesses together after Evil-role assignment and before clue preflight. Distinct required true roles must fit distinct remaining public-consistent Good suspects; this prunes only branches that true-role uniqueness can never complete. `natural_target_set_prunes` exposes the saved branches without hidden generation state, caps, or skipped legal worlds.
- M6B-PERF-OPT-2 checks whether every remaining Good suspect can still receive a distinct legal true role after Evil-role assignment and OPT-1, before clue preflight. Candidate edges come only from public displayed-role/capability rules plus the public Barkeep-transform hypothesis; failure of this complete matching cannot be rescued by later assignments. `remaining_role_set_prunes` measures this branch class.
- M6B-PERF-OPT-3 applies the existing natural-witness set feasibility check after each partial Evil-role assignment while Evil suspects remain unassigned. Supported witness roles are Good, and the current public Barkeep-target hypothesis already defines all transform flexibility, so a failed matching cannot be repaired by later Evil/Spectre/Barkeep/Poisoner choices. `evil_support_set_prunes` records these branches before deeper mutation counters and preflight work.

## GĐ2 Status / PREP-1 State Boundary

- GĐ2-M0A locks the five production Houses and the production Imperial Court tabletop map. The initial production Character roster now supplies canonical ids/names, neutral 2/2/2 Speed/Stamina/Bag values, one representative per House, and forbidden duplicate selection. Character skills remain deliberately deferred. Existing GĐ2 fixture Characters and legacy tiny maps remain `TEST_ONLY` and must not be promoted to canon.
- GĐ2-PREP-1 establishes the ownership boundary only; it does not make the Character/Loot vertical slice production-ready.
- Persistent player authority: `PlayerPhaseState` persistent projection owns identity/selected Character reference, existing currencies/resources, consumable inventory under the current prototype contract, equipment/loadout references, and Gacha state. `Gd2StateSerializer` serializes only this persistent projection.
- Round-local movement authority: `LootMovementSession` / `LootMovementPlayerState` own round id/phase, current node, Speed/Stamina snapshots, remaining movement actions, movement history, and temporary movement effects. `LootRewardSession` owns reward snapshots, pending trace, overflow, and reward history.
- Legacy `PlayerPhaseState` movement/reward fields remain temporarily for test/prototype compatibility but are not persistent or movement authority. Normal reward/item movement reads and mutates `LootMovementPlayerState`; new rounds rebuild that state without clearing persistent resources.
- GĐ2-PREP-3 separates inventory ownership. `PlayerPhaseState.consumable_inventory` remains persistent/shop inventory and does not consume Túi xách capacity. `LootRewardSession.round_loot_states` / `RoundLootInventoryState` own each player's round-local map-loot items and bag-capacity snapshot; `BagOverflowState` remains the pending replace/discard choice, while `reward_history` remains trace/audit only. PF-M9D-B now performs the approved explicit, exactly-once transfer of unused round consumables at each player's successful Loot End confirmation; no implicit transfer occurs elsewhere.
- GĐ2-PREP-2 hardens this boundary: active Loot movement, reward/item effects, player-facing checks, end confirmation, and Prototype B summary projection read `LootMovementPlayerState`. Deliberately stale legacy node/move/effect values do not influence those paths. Retained `PlayerPhaseState` round fields are limited to TEST_ONLY fixture/selection metadata, migration/reset assertions, and the explicit legacy full-snapshot serializer; persistent serialization still excludes them.

## GĐ2-M0A — FIVE HOUSES + PRODUCTION TABLETOP LOOT MAP FOUNDATION

- `HouseDefinition` is the narrow production House authority: `house_id`, exact Vietnamese `display_name`, stable `display_order`, and `spatial_role` only. `ProductionHouseRepository` loads the canonical order: `house_hoang` / Nhà họ Hoàng / CENTER, `house_chu` / Nhà họ Chu / SOUTH, `house_kim` / Nhà họ Kim / WEST, `house_huyen` / Nhà họ Huyền / NORTH, and `house_lam` / Nhà họ Lam / EAST. House bonuses, affinities, skills, equipment rules, and lore are not modeled.
- `imperial_court_tabletop_v1.tres` is production data (`test_only_not_canon_locked = false`): 77 graph-authoritative board spaces over a 2600×3340 authored node span. Physical placement is Huyền north, Kim upper-left, Lam upper-right, Hoàng lower-left, and Chu lower-right; Hoàng's CENTER value remains lore metadata rather than geometric placement.
- Every House spawn branches immediately into two distinct four-node House lanes. All ten lanes take five edges to the single `central_hub` and never merge earlier. The Central Hub branches into three separate five-node Middle lanes, each six edges to `mausoleum_hub`; the Mausoleum Hub then branches into three separate five-edge Final lanes with distinct southern terminal spaces. There are no presentation waypoints in gameplay data.
- Existing node tags carry the production reward zones: `HOUSE`, `MIDDLE`, and `POST_MAUSOLEUM`. They are consumed by the production direct-resource reward tables below without changing graph topology.
- `LootNodeDefinition.display_name` and `world_position` extend the existing graph without changing movement semantics. Production nodes use authored world coordinates; legacy TEST_ONLY maps retain their previous fitted rendering because zero/default coordinates select the compatibility layout.
- `ProductionLootMapPreview.tscn` is the developer-only full-screen board/HUD preview opened from DebugHome as `GĐ2-M0A — Production Imperial Court Board`. It creates five preview markers directly from House origins and uses explicitly TEST_ONLY preview Speed/Stamina values; it does not create production Characters or replace normal Character Selection.
- `PlayerFacingLootMapView` owns presentation-only camera state. Edge pan uses a 42 px threshold at 680 world pixels/second, supports normalized diagonal motion, and clamps against current map extents plus a 160 px visual margin. Left-pointer movement becomes tabletop drag after a 6 px threshold, converts screen delta through current zoom, and suppresses edge pan until release. Mouse-wheel zoom uses a cursor-anchored `0.1` step from a default `1.0` up to `1.4`; its dynamic minimum fits the framed authored map inside the current viewport with 32 px screen margins. Space focuses the active movement player at the current zoom only when no UI control owns keyboard focus and clears any active drag. A changed movement owner uses the same focus path; resolved preview movement refreshes to the next active player while the traversed route remains highlighted.
- The production renderer is region-first rather than graph-first: five tinted House compounds, persistent House titles/seals, thick board-game lanes, palace/court bands, royal shared-route styling, larger spawn spaces, and prominent player markers. Raw node labels are absent normally and are available only with the developer overlay.
- In the production preview, F9 toggles the debug overlay, DEV controls, camera details, and node labels; the default HUD retains only the active House, Roll & Move, Back, and compact hotkey guidance. F11 explicitly targets `DisplayServer.MAIN_WINDOW_ID`, enters `WINDOW_MODE_EXCLUSIVE_FULLSCREEN`, and returns the same main OS window to `WINDOW_MODE_WINDOWED` with captured size/position restored. The preview scene contains no child `Window`/`SubViewport`; one concise `M0A_FULLSCREEN_DIAG` line records local/root/main ids on each F11 request. A deferred presentation-only geometry refresh reclamps the camera against the resized full-rect viewport without mutating movement state.
- The initial production Character contract is implemented as five Characters, exactly one per House, in House display order with duplicate selection forbidden. Names and neutral 2/2/2 stats are production data; skills, passives, portraits, art, and Character-specific balance remain deferred.

## GĐ2 — PRODUCTION CHARACTER ROSTER FOUNDATION

- `ProductionCharacterRepository.gd` is the normal player-facing source of truth for exactly five Characters in canonical House display order: Hoàng Linh Lâm (`house_hoang`), Chu Tuệ Nguyệt (`house_chu`), Kim Thanh Giai (`house_kim`), Huyền Ca Xuý (`house_huyen`), and Lam Phương Xuân (`house_lam`). Japanese source names remain documentation-only and are not runtime fields.
- All five intentionally share the neutral production baseline Speed 2, Stamina 2, and Bag 2. Passive/active skill IDs remain empty, Orb requirement is 0, and no Character or House skill is implied.
- `ProductionCharacterRosterValidator.gd` scopes production-only checks to count, identity, display name, canonical one-per-House membership/order, base-stat validity, and non-TEST status. Legacy A/B/C/D resources remain TEST_ONLY fixtures under `Gd2FixtureRepository`.
- Normal `PlayerFacingSetupSession` loads the production repository, resolves House display names through `ProductionHouseRepository`, and configures the existing Character Selection authority with duplicate selection forbidden. Debug/prototype fixture flows retain their existing duplicate policy where explicitly required.
- Player-facing integrated Loot uses the approved production map and resolves spawn solely through `CharacterDefinition.origin_house_id -> LootMapDefinition.origin_spawn_by_house`. Movement snapshots and round Loot capacity continue to read the Character's authoritative 2/2/2 fields.

## GĐ2 — PRODUCTION DIRECT-RESOURCE REWARD TABLES V1

- `ProductionRewardRepository.gd` loads exactly ten non-TEST, repeatable rewards: the seven direct-resource rewards (Silver 2/5, Orb 1, Gacha Ticket 1, Equipment EXP 3/6, Equipment Exchange Material 1) plus the three production consumable rewards below.
- `RewardZoneTableDefinition.gd` and `WeightedRewardEntry.gd` own the three provisional V1 weighted tables so balance can change without logic edits. Each table totals 100 and uses 75% node density. In table order Silver Small / EXP Small / Orb / Silver Large / EXP Large / Exchange / Ticket / Hành Lộ Phù / Lệnh Bài Thông Hành / Ngự Mã Lệnh, HOUSE weights are `26/22/13/9/7/6/5/6/3/3`; MIDDLE uses `15/15/15/12/10/9/9/7/4/4`; POST_MAUSOLEUM uses `8/8/16/13/13/11/13/8/5/5`.
- `RewardSnapshotService.build_weighted_reward_snapshot()` rolls once when a production Loot session is created. Ordinary HOUSE, MIDDLE, FINAL and END spaces are eligible; House spawns, Central Hub and Mausoleum Hub never receive a snapshot. Empty nodes are represented by the absence of a snapshot and traversal remains safe.
- Normal player-facing production Loot uses `SeededRewardRollSource` with a deterministic seed derived from the persisted Match Case seed and Round number. The resulting node snapshot is serialized by the existing `LootRewardSession`; resuming a Round does not reroll it. TEST_ONLY maps retain the legacy M4 reward array and `SequenceRewardRollSource` path.
- Direct-resource production rewards continue to bypass Bag capacity. Consumable rewards use the existing Round Bag, overflow, use, and exactly-once Loot End transfer authorities. Reward/session history remains trace data rather than inventory authority. `ProductionRewardContentValidator.gd` validates this production content only; fixture validation remains unchanged.

## GĐ2 — PRODUCTION CONSUMABLES V1

- `ProductionConsumableRepository.gd` is the normal player-facing authority for exactly three stable non-TEST item definitions: Hành Lộ Phù (`MOVE_DISTANCE_BONUS +1`, `THIS_MOVE`), Lệnh Bài Thông Hành (`EXTRA_MOVEMENT_ACTION +1`, `THIS_ROUND`), and Ngự Mã Lệnh (`SPEED_BONUS +1`, `THIS_MOVE`). All target SELF. M4 consumables remain fixture-only.
- The production Loot session loads these definitions together with the production map/reward catalog. The Item Window resolves both persistent and current-Round item names from the same loaded `ConsumableItemDefinition.display_name`; it does not derive production names from TEST IDs.
- Existing lifecycle remains authoritative: a consumable reward enters `RoundLootInventoryState.carried_items`, consumes one Bag slot, may be used during the same Loot phase, and transfers exactly once into persistent `consumable_inventory` at successful Loot End if unused. Overflow and next-Round fresh-bag behavior are unchanged.
- Ngự Mã Lệnh exercises the existing movement authority end-to-end: the next roll uses `speed_snapshot + 1`, then the `THIS_MOVE` SPEED_BONUS expires before any later movement. Character base Speed is never mutated.

## PF-M8A — MATCH SETUP & VICTORY RULES

- `scripts/domain/mvp/MatchRules.gd` is the single serializable victory-rule snapshot owned by `MvpMatchState.match_rules`. Classic is a preset (`REACH_COURT_RANK`, `RANK_1` / Nhất phẩm, no round limit), not a separate gameplay path.
- Custom setup supports exactly `REACH_COURT_RANK` and `FIXED_ROUNDS`. Court Rank ids/order/player-facing names come from `CourtRankService`; fixed-round options are owned by `MatchRules` as 1/3/5/10.
- `PlayerFacingSetupSession` owns Match Mode → Match Rules → Player Count setup transitions. Back navigation retains the current rules snapshot, and confirmed rules survive `MvpMatchState` serialization and the existing Character Selection / first-Case bootstrap.
- `PlayerFacingStart.tscn` / `PlayerFacingStartController.gd` provide the player-facing Cổ Điển / Tùy Chỉnh selection, victory selector, rank/round selector, summary, Continue, and Back controls.
- Validation rejects invalid Classic values, unknown Court Ranks, unsupported round limits, and rank/round hybrid configurations. PF-M8A owns setup only; PF-M8B consumes its immutable rules snapshot at the Round Settlement boundary.

## PF-M8B — MATCH COMPLETION & MATCH RESULTS

- `MatchCompletionService` is the victory and final-standing authority. It runs only after the idempotent Round End commit has merged every player's settlement, and it reads the explicit persisted `MvpMatchState.completed_round_count` rather than inferring completion from UI state.
- `REACH_COURT_RANK` compares post-settlement rank indices through `CourtRankService`; `FIXED_ROUNDS` completes at the configured round limit. All players' settled values are ranked before completion, so simultaneous crossings are retained.

- `MatchFinalStanding` is the persisted final-results row: player id/name, final Court Rank id/name, Merit, and competition place. Ordering is higher Court Rank, then higher Merit; exact ties share a place (`1, 1, 3`) and player order only stabilizes display ordering inside a tie.
- A winning commit stores `final_standings`, sets `match_completion_state` and `current_phase` to `MATCH_COMPLETE`, and prevents next-Case composition or next-Round start. A non-winning commit remains `NEXT_CASE_REQUIRED` without a final snapshot.
- `PlayerFacingStart.tscn` / `PlayerFacingStartController.gd` render the stored Match Results after Round Summary. Replay creates a fresh Match Setup; Main Menu drops the active Match session. `PlayerFacingSetupSession.restore_completed_match()` restores directly to Match Results without resuming gameplay or recomputing standings.

## PF-M9B — EQUIPMENT COLLECTION & LOADOUT UI

- `EquipmentManagementService` remains the equip/replace/unequip authority. Explicit slot requests are validated against the owned `EquipmentInstance`; Relic and authored Stigmata A/B/C restrictions are not reimplemented by the UI.
- The existing player-facing Equipment/Gacha phase now lists only the current player's persistent collection, displays the four loadout slots with rarity and progression levels, and supports equip/replace/unequip without removing replaced items from ownership.
- Equipment and Gacha share the same `PlayerPhaseState.equipment_collection`, so newly granted Equipment appears on refresh and the existing Round End merge persists collection/loadout by stable `player_id` into later Rounds.
- The visible test-grant action is removed. Until production acquisition/content is approved, an invisible `PF_M9B_TEST_BOOTSTRAP` seeds empty player-facing collections once from existing TEST_ONLY M5 definitions; it does not equip items and does not run when a collection already exists.
- PF-M9B does not implement Equipment effects, set effects, active skills, compatibility, progression UI, shop/economy, or canonical content replacement.

## PF-M9C — EQUIPMENT PROGRESSION UI

- `EquipmentProgressionService` remains the sole Gold/Purple progression authority. Gold consumes the authored next-level EXP cost; Purple requires the next Gold prerequisite, the authored Purple EXP cost, and one owned unequipped same-definition duplicate.
- The existing player-facing Equipment/Gacha phase shows the selected instance's rarity, Gold/Purple levels and caps, exact next costs, owned EXP material, eligibility state, and valid duplicate choices. Actions route through `MvpIntegratedRoundCompletionSession`, then refresh the same current-player state and management snapshot.
- Equipped targets progress in place without changing their stable instance or loadout slot. Gacha grants refresh through the existing Equipment screen path, and Round End persistence remains the PF-M9B `PlayerPhaseState` to `PlayerMatchState` merge/projection.
- Manual verification uses the invisible TEST_ONLY player-facing bootstrap: empty collections receive one additional `m5_a_relic` duplicate and at least 200 existing Equipment EXP material. No grant, force-level, or reset control is exposed.
- PF-M9C does not implement Equipment effects, set effects, active skills, compatibility, new economy, shop behavior, or canonical content replacement.

## PF-M9D-B — ROUND MAP-LOOT USE + PERSISTENT TRANSFER

- `RoundLootInventoryState` remains the per-player, per-Round Túi xách authority. Its serialized `disposition_finalized` marker and transferred-item snapshot make Loot disposition explicit and exactly-once.
- The Loot Item Window exposes persistent consumables and current-Round map consumables as two labeled sources. `ConsumableItemService` validates and consumes from the selected authority while the existing shared `item_used_this_turn` enforces one item total per turn.
- On each player's successful Loot End confirmation, `LootEndConfirmationService` validates every remaining bag item, transfers it into that player's persistent `consumable_inventory`, clears/finalizes the Round bag, and updates the Equipment projection before that player leaves Loot.
- Used and overflow-rejected/replaced items cannot transfer. New Rounds create a fresh empty Round bag; transferred consumables remain persistent and do not consume new bag capacity. Direct resource rewards and Equipment/Gacha behavior are unchanged.

## PF-M9E-A — PERFECT GACHA CHOICE UI

- `GachaService` remains the Perfect roll/payment, eligibility, and grant authority. A choice-producing roll commits its two-Ticket cost and Perfect-pool hit before authoring `EquipmentManagementSession.pending_choice`; there is no cancellation/refund path after that point.
- The existing player-facing Equipment/Gacha screen renders only the pending choice's eligible Equipment definitions, requires an explicit single selection and confirmation, then calls the existing `claim_choice` path. It no longer resolves the first eligible reward automatically.
- An unresolved choice is serialized in the management snapshot, blocks every Gacha banner and management completion, and remains owned by its originating player. Confirmation grants exactly one persistent Equipment instance, clears pending state, and refreshes the existing collection/loadout/progression controls.
- The invisible player-facing TEST_ONLY content bootstrap guarantees four Gacha Tickets for manual Perfect, Basic, and Rate Up verification; no grant/debug control is exposed. Rates, pity, pools, costs, ownership, progression, and production content remain unchanged.

## PF-M9E-C — SINGLE-SLOT AUTOSAVE + CONTINUE

- `PlayerFacingAutosaveService` owns the single `user://player_facing_autosave.json` slot. It reuses `MvpStateSerializer`, validates the restored Match, rejects active-Round snapshots, and commits a validated temporary file through a backup/rename replacement.
- Player-facing autosave supports only committed `NEXT_CASE_REQUIRED` and `MATCH_COMPLETE` Matches. The Round Summary continuation writes after successful Round End commit and before composing the next three Case options.
- `MvpIntegratedNextCaseSession.restore_player_facing_between_rounds()` restores a cloned persistent Match at `ROUND_START` without replaying Round End, rewards, or Round-1 initialization. It then composes one fresh deterministic three-Case option set from the saved Match seed/history.
- `PlayerFacingSetupSession.restore_completed_match()` remains the completed-Match restore authority. The existing Main Menu `Tiếp tục` button is enabled only for a valid supported autosave.
- Match Setup, Character Selection, composed Case Selection, active Case, Results, Loot, Loot confirmation, Equipment/Gacha, pending Perfect choice, and uncommitted Round Summary remain intentionally non-resumable.

## PF-M9E-D — BAG OVERFLOW CHOICE UI

- `LootRewardSession.overflow` remains the pending-choice authority and `RoundLootInventoryState` remains the current-Round bag authority. The player-facing Loot panel shows the incoming item plus every carried item, requires one explicit replacement target, and routes the selected bag index through the existing `MvpIntegratedCaseLootSession.resolve_overflow_discard()` service boundary.
- `LootRewardService` validates the active pending reward, owning current player, incoming item, and selected index before mutation. Replacing removes exactly the selected carried item and inserts the incoming item once; discarding the incoming item leaves the bag unchanged. Capacity-zero bags offer discard-new only, and stale/repeated/foreign actions are rejected without mutation.
- Unresolved overflow continues to block Loot progression. PF-M9D-B disposition remains authoritative afterward: only items still carried at successful Loot End confirmation transfer to persistent inventory, exactly once.

## Presentation Contract / UI Replacement Boundary

Future visual work may replace `SuspectCard.tscn` and the board scene hierarchy, but must preserve this data/request boundary:

- Gameplay authority: `CaseRuntimeState`, `SuspectRuntimeState`, `PlayerCaseState`, `InvestigationService`, `FunctionAvailabilityService`, `InteractiveFunctionExecutionService`, `SingleSuspectAccusationService`, `CaseSubmissionService`, `FinalVerdictService`, `CaseTruthRevealBuilder`, timed-event/kill/settlement services.
- Presentation-data authority: `SuspectPublicViewData` and `CasePublicPresentationBuilder`. Cards should render from these fields plus public function records, not infer hidden truth from visual text.
- UI/adapters: `VSCaseMainController`, `CaseBoardController`, `SuspectCardController`, and the case `.tscn` scenes. These may route input, show selection/hold feedback, and refresh visuals, but must not decide investigation correctness, function results, verdict correctness, death, settlement, or hidden truth.
- Card input contract: card/board emits suspect/action requests with suspect ids; controller calls domain services. Card widgets must not mutate `CaseRuntimeState`, `SuspectRuntimeState`, or `PlayerCaseState`.
- Full Reveal contract: truth/history comes from `CaseTruthRevealBuilder` and structured runtime history, then flows through `CasePublicPresentationBuilder`; do not preserve or derive truth from currently visible card labels.
- Function/death/verdict contract: function availability/usage, dead state, Chỉ Điểm, early submission, and Final Verdict remain keyed by runtime/service authority. UI selection state is temporary input state only.
- Board layout contract: authored `board_slot`/location data and spatial services own gameplay coordinates. Visual node positions are an adapter detail.
- Current board presentation contract: center board renders compact portrait card skeletons from authored slots; empty slots stay visually quiet, locations use distinct board-object tiles, and gameplay authority remains `board_slot`/domain data with no new generic 3x3 assumption introduced by this UI pass.
- Reveal Presentation Contract: Full Reveal switches cards to true-role identity/color; ordinary non-impersonators default to an empty statement, roles with no reveal info stay identity-only, impersonators default to `Ta giả danh ...`, dead suspects default to `*Chết...*`, old public statements live behind a per-card history toggle, and structured truth/history stays internal without dumping debug/explanatory text such as `Lời khai đúng`, `Sự thật:`, alignment, `Giả danh:`, or fixture truth notes.
- Universal Dead Marker Contract: every dead suspect card uses the same persistent `res://assets/ui/case/dead_marker_universal.png` seal marker, regardless of execution, active kill, Surgeon, Serial Killer, or other supported death source. The marker is presentation-only and must not encode cause-of-death; cause details remain only in structured reveal/history/public text where already supported. DeadMarker `TextureRect` geometry must remain tight, not oversized: current 3x3 uses a tight 60x60 rect centered at `(116.5, 52.5)`, and compact 4x4 uses `L=60 T=1 R=120 B=61`.
- Reveal history toggles must be layout-stable: `RevealHistoryButton` is a small clickable overlay under non-Container `CardPresentationRoot`, outside `CardContent` sizing; switching to `Xem lời khai cũ` cannot move card content or reflow the Case Board. Full Reveal previous-public-statement authority is the latest meaningful player-facing card statement before Reveal, including active-function results; structured presentation/runtime data is authoritative, not UI label text. Tutorial 06 #6 Dịch Phu history authority is structured (`CaseTruthReveal` original/displayed role data), not a default-card text dump.
- Suspect Card Readability Contract: statement text does not use internal card scrolling. Current 3x3/easy/tutorial board presentation uses a larger readable card variant with bounded auto-fit font tiers and a readable minimum size; short statements render larger than long statements. Future 4x4/full-case presentation should use a separate compact card variant while preserving the same content semantics. Card footprint and Case Board geometry remain stable across normal statement, empty reveal default, history statement, function result, and dead state.
- Active Function Marker Contract: suspect cards show a small top-left overlay hand marker for active functions only, protruding slightly outside the card without changing card footprint. `FunctionHandMarker` is a `TextureRect` overlay sibling of `CardVisual` under `CardPresentationRoot`, outside Container-managed card content; AVAILABLE uses `res://assets/ui/case/function_hand_available.png`, CONSUMED uses `res://assets/ui/case/function_hand_consumed.png`, and no active function hides the marker. Function status prose such as `Chức năng: Khả dụng` / `Chức năng: Đã dùng hết` and redundant green function-state card framing must not be rendered on player-facing cards; public result text remains visible in the reserved card result area.
- Suspect Card Visual Transform Contract: the `SuspectCard` layout root remains fixed as the board footprint authority; `CardPresentationRoot` owns presentation-only transforms for the card body, active-function hand marker, and universal dead marker together. Relation emphasis scales/dims that shared presentation group, direct pointer hover adds a subtle temporary upward lift, and none of these transforms may resize GridContainer cells or reflow the board.
- Suspect Card Skin Spike: approved source skins stay at `res://assets/ui/case/suspect_card_skin_green_3x3.png` and `res://assets/ui/case/suspect_card_skin_green_4x4.png`; runtime cards use trimmed visible-bounds assets `res://assets/ui/case/suspect_card_skin_green_3x3_runtime.png` and `res://assets/ui/case/suspect_card_skin_green_4x4_runtime.png` under the fixed `CardPresentationRoot`. Card skin TextureRects cover-fill a small visual overscan rect, not the layout root, so transparent source padding and aspect-ratio crop do not shrink or clip the painted frame. Current overscan: 3x3 `L=-3 T=-10 R=3 B=10`; 4x4 `L=-2 T=-11 R=2 B=11`. The top-left role/icon area is a non-drawing `IconSlotRoot` with transparent `RoleIcon` and `UnknownIconLabel`; no `ColorRect`, panel, stylebox, or controller color painter may draw a legacy portrait background over the skin plaque. Gameplay data/markers/history/hover contracts remain unchanged.
- 4×4 presentation spike: DebugHome has `DEV — Sample 4×4 Case Board`, which launches a synthetic visual-only `sample_case_4x4_visual` through `VSCaseMain`. It uses case metadata `board_columns=4` / `board_slot_count=16`, compact card profile `126×143`, and the 4x4 green skin; it is not generator/runtime random-case integration.
- 4×4 board spacing: compact 4x4 board view hides the board title/footer help text and the dev back row inside the fixed case shell, tightens shell margins/panel widths only in compact mode, and uses wider grid gaps so compact cards have visible breathing room; 3x3 keeps the normal shell/title/footer/dev row. Grid gaps account for card-skin overscan: 3x3 `h=14/v=26`, 4x4 `h=16/v=28`. Compact card profile has separate human-tuned values from 3x3: `TopRow.y=64`, `IconSlotRoot=48x42`, `RoleIcon` anchors `0,0,1.375,0.85`, `SuspectNumber.min=40x0`, centered compact role/name/body text, and `PublicStatementLabel.min=102x38`.
- Suspect card typography spike: suspect numbers and icon placeholders use explicit `res://assets/fonts/TimesNewRoman.ttf`; role names use `res://assets/fonts/NotoSerif-SemiBold.ttf`; card statement/function-result body text uses `res://assets/fonts/NotoSerif-Regular.ttf`; other case body/help text may still use `res://assets/fonts/Arial.ttf`. Do not return suspect cards to `SystemFont` fallback stacks. Footprints remain 168×190 for 3×3 and 126×143 for 4×4; bounded statement auto-fit remains authoritative. Current human-runtime-approved 3x3 text layout is `TopRow.custom_minimum_size.y = 95` and `CardContent` separation `-8`; compact 4x4 keeps its separate compact profile.
- Hover Relation Emphasis Contract: case-board hover emphasis is presentation-only, directional `SOURCE -> PUBLIC REFERENCED CANDIDATES`, and uses structured `SuspectPublicViewData.public_relation_suspect_ids`, not visible-text parsing. A visible Therapist/Ngự Y count enables hover even when its candidate list is empty: count zero leaves the source HOVERED and makes every other suspect UNRELATED; a positive count makes every occupied orthogonal N/E/S/W suspect RELATED and all other suspects UNRELATED, without filtering by hidden alignment. Empty slots and location/Crime Scene tiles remain spatial positions for clue calculation but stay visually neutral, with no relation markers. Never add reverse edges automatically and never narrow candidates with hidden truth. Supported sources: public function target ids (Tailor/Vigilante/etc.), Weatherman structured suspect lists, Therapist orthogonal suspect candidates, Reporter public announced Manhattan-distance candidate set, Blood Hound public directional same-row/column ray candidates, Full Reveal Spectre obscure targets, and successful timed-kill victims such as Surgeon only when publicly revealed. Blood Hound bark/sniff create no relation set for now. Hover transforms use the suspect-card presentation group so GridContainer/card footprint, authored board slots, horizontal scroll, reveal/history, and gameplay authority do not change.
- Therapist true Evil count and relation neighborhood use `CaseSpatialService` with the current Case board columns/slot count; 3x3 defaults remain unchanged. A dev-only post-Full-Reveal `Xem suy luận AI` button replays public clues through `CaseGeneratorPublicSolver`, reporting candidate Evil sets and per-clue elimination; it is separate from Results acknowledgment and reports unsupported input rather than inferring from hidden answer ids.
- The DEV solver panel groups its deterministic public-only replay into Vietnamese conclusion, initial Evil-set hypotheses, per-clue eliminations (with rule-based numeric explanations where justified), and final conclusion. Unsupported clues are reported explicitly rather than treated as contradictions.
- Generator Audit / Case Audit (DEV): `CaseGenerationAuditSnapshot.gd` copies the selected warehouse entry's accepted M3 candidate, retained public view, and accepted solver result into `CaseDefinition` runtime metadata when M5B resolves the option. `CaseGeneratorPublicSolver` passively records the exact raw combinatorial Evil-set count plus deduplicated Evil sets observed after the optimized pipeline's early public-structure/fixed-clue pruning and at each existing clue-replay checkpoint; these observed stages are not presented as reconstructed structural-only or authored-prefix totals. The snapshots do not affect solver status, acceptance, performance pruning, or fingerprints. After Full Reveal in debug builds, the existing case inspection overlay reads the snapshot for procedural Cases under `Kiểm tra Case`, showing seed/attempt, board and Suspect List, hidden true/displayed/behavior roles, public clues, solver reductions, and acceptance comparison. Authored Cases retain the existing public-only replay inspection. The audit never regenerates or resolves a Case on panel open, and the overlay is hidden from ordinary player-facing play.
- CASE UI/UX FOUNDATION FREEZE: case help/instruction text belongs in a dedicated center-column footer below the board and must not overlap board/cards. `CaseBoardController.populate()` is presentation-size-aware: current 3x3 uses the larger readable `BOARD_TILE_SIZE`, future 4x4 can request 4 columns/16 slots and receives the compact presentation profile. Gameplay/domain authority remains independent of visual grid columns; authored `board_slot` order, hover/reveal/history/marker contracts, and no-reflow behavior are locked. Ready for Case Generator work after GUI Smoke passes.
- Dev tutorial testing supports an in-game `← Quay lại` button on `VSCaseMain` that routes through `AppFlow.go_to_debug_home()` so testers can return to DebugHome without restarting the project.
- Current Case shell is fixed at the 16:9 gameplay viewport and has no whole-page `ScrollContainer`. The left panel order is time/current turn, Case info, player reputation, then a bottom action area. Existing action controls keep their state-driven visibility there. The center board stays fixed. The right Thân Phận list alone owns an automatic vertical `ScrollContainer`, so no scrollbar appears when its content fits.
- Current right suspect list contract: flat notebook-style scroll rows with bullet + role icon placeholder + role name; preserve canonical group/authored order, and keep nested roles attached/indented under their parent.

Important architecture facts:

- Match state and Round-local state already exist as separate concerns.
- Round results commit back into persistent Match state.
- New Round rebuilds Round-local state without wiping persistent player progression.
- Court rank and Merit persist across Rounds.
- Match End belongs at the proper Round-End boundary, not arbitrary Case settlement logic.
- Do not rebuild a second Match/Round architecture without first auditing the existing one.

## Want To Change X? Start Here

| Want to change... | Look here first |
|---|---|
| Role copy text | role `.tres` loaded by `FixtureRepository`; keep `help_text` plain |
| Role Reference formatting | `scripts/presentation/RoleReferenceFormatter.gd` |
| glossary tooltip terms | `scripts/presentation/RoleGlossaryBank.gd` |
| tooltip display/position/size | `scripts/presentation/RoleGlossaryTooltipController.gd` and tooltip `.tscn` |
| Role Codex metadata/display | `scripts/presentation/RoleCodexController.gd` |
| in-Case Role Reference popup | `scripts/presentation/case_gameplay/VSCaseMainController.gd` |
| Tutorial fixture data | tutorial/case fixture resources loaded by `FixtureRepository` |
| suspect numbering / board placement | case board/spatial services plus Tutorial fixture |
| Tailor / Mobster pretend behavior | role information evaluation services, function lifecycle, Tutorial 04 fixture |
| Mailman / Dịch Phu true-role logic | role information evaluation services and role function rules |
| Priest self-confirm | role definition + uniqueness/self-confirm validator |
| true-role duplicate validation | case validation service / `TRUE_ROLE_DUPLICATE` handling |
| Smoke assertion text | `scripts/tools/SmokeTestRunner.gd` |
| Match/Round continuation | match state, round state, round-end commit service |
| Match End / Court Rank | court rank/progression/match-end evaluator |
| Loot movement | loot movement phase controller/state/service |
| Equipment/Gacha | equipment inventory/progression and gacha reward services |

## Tutorial 06 Integration Notes

Current Tutorial 06 I1 authored layout:

- slot0 #1 displayed Reporter, true Poisoner
- slot1 #2 displayed Priest, runtime-tainted by #1
- slot2 #3 displayed Reporter, true Barkeep
- slot3 empty
- slot4 Crime Scene
- slot5 #4 Reporter
- slot6 #5 Ngự Khuyển Quan
- slot7 #6 displayed Mailman, runtime-transformed to Drunkard by #3
- slot8 #7 Therapist

Top-level suspect-role pool is authored separately from board suspects:

- Reporter, Therapist, Blood Hound, Priest, Mailman, Mathematician, Barkeep, Poisoner
- Drunkard is nested beneath Barkeep in the UI/reference path and is not a top-level suspected role.
- initial ratio: Innocent 5, Meddler 0, Underling 2, Traitor 0
- reveal:
  - #1 Độc Sư -> pretended Reporter; tainted #2
  - #2 Priest, tainted
  - #3 Chủ Quán Rượu -> pretended Reporter; transformed #6 into Kẻ Say Rượu
  - #4 Reporter
  - #5 Blood Hound
  - #6 Kẻ Say Rượu, shown earlier as Mailman
  - #7 Therapist
- final Evil answer: #1 Độc Sư and #3 Chủ Quán Rượu
- locked Vietnamese names: Poisoner = Độc Sư, Barkeep = Chủ Quán Rượu, Drunkard = Kẻ Say Rượu
- whether Độc Sư/Chủ Quán Rượu "suspected role" means the case role-list pool, not right-click UI suspicion, unless design changes

Tutorial 06 lesson/foundation:

- Good can lie due to taint.
- Good/Meddler can transform.
- Ratio can become outdated after transform.
- Wrong information does not prove Evil.
- Displayed role / true role / transformed current role are distinct.
- Kẻ Say Rượu lies while remaining a Good-side/Meddler role.
- Chủ Quán Rượu transforms one Innocent into Kẻ Say Rượu, lies, and pretends a suspected role.
- Độc Sư taints a surrounding Innocent neighbor, lies, and pretends a suspected role.

Clock Maker / Clock Tower / Serial Killer belong to Tutorial 07, not Tutorial 06.

## Update Policy

Update this file after milestone-level changes only:

- Tutorial foundation PASS
- new authoritative service/path added
- Match/Round/Loot/Equipment/Gacha/CourtRank contract changes
- Smoke baseline materially changes
- current milestone changes

Do not update this file for every copy edit.
Do not duplicate long design history from `PROJECT_MEMORY.md`.
When facts become stale, replace them instead of appending contradictory history.
