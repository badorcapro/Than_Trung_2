# PROJECT_MEMORY_CURRENT.md

## Current checkpoint

**Project:** Thần Thám Nửa Vời -- Truyền Kì Kỳ Án Hoàng Cung\
**Engine:** Godot 4.6.2 stable\
**Language:** GDScript\
**Renderer:** GL Compatibility\
**Base resolution:** 1280×720

This file is the current continuity snapshot. Newer decisions in the
active project conversation supersede stale statements in the older
`PROJECT_MEMORY.md`.

### Priority

1.  Newest explicit user decision
2.  Verified runtime contract
3.  Current project canonical rule
4.  Reference/source fact
5.  Old draft/history

### Workflow

-   Chat = design, architecture, review, canonical decisions, narrow
    Work prompts.
-   Work = repository implementation.
-   User priority: **Hiệu Quả \> Credit \> Thời Gian**.
-   Work prompts must be narrow, explicit, and contain a STOP condition.
-   Never ask Work/Codex to run Godot CLI/headless.
-   User runs Godot manually through GUI.
-   If Work usage ends, resume from the current working tree; do not
    restart/revert.
-   Use `CODEX_PROJECT_MAP.md` for repo navigation.
-   Avoid broad refactors and speculative scans.
-   Current visual work style: fix one concrete issue at a time.

------------------------------------------------------------------------

# 1. PASS / ROADMAP STATUS

  -----------------------------------------------------------------------
  Area                                Status
  ----------------------------------- -----------------------------------
  GĐ0 Pre-production                  PASS

  GĐ1 Kỳ Án Vertical Slice            PASS

  PF-M8A Match Setup / Victory        PASS

  PF-M8B Match Completion / Results   PASS

  PF-M9B Equipment Collection /       PASS
  Loadout                             

  PF-M9C Equipment Progression        PASS

  PF-M9D-B Round Map-Loot /           PASS
  Persistent Transfer                 

  PF-M9E-A Perfect Gacha Choice       PASS

  PF-M9E-C Autosave / Continue        PASS

  PF-M9E-D Bag Overflow               PASS by focused Smoke; manual
                                      fixture skipped

  GĐ2-M0A Production Loot Map         PASS

  Production Character Roster V1      PASS

  GĐ2 Production Loot V1              PASS

  Production Consumables V1           PASS (3188/3188 verified)
  -----------------------------------------------------------------------

Confirmed Smoke baseline: **3188/3188 PASS**.
Consumables V1 and PF-M3/PF-M4 transition: **PASS**.

------------------------------------------------------------------------

# 2. CASE / DUPERY CANON

The Case system is a practical homage to Dupery, adapted to the
Vietnamese imperial-court theme.

## Board

Canonical Case board = fixed 3×3 spatial coordinate system, max 9 total
tiles.

``` text
slot0 | slot1 | slot2
slot3 | slot4 | slot5
slot6 | slot7 | slot8
```

Sparse positions remain meaningful. Do not compact.

### Critical numbering rule

**Slot index is NOT suspect number.**

Suspects are numbered `#1, #2, ...` by: - left → right - top → bottom -
only actual Suspect tiles count - empty slots, Crime Scene, and
locations do not count

## Spatial rules

-   N/E/S/W movement.
-   Starting tile is not counted.
-   Manhattan shortest distance.
-   Adjacent = orthogonal neighbour.
-   Surrounding = up to 8 positions including diagonals.
-   Empty/location/Crime Scene tiles are spatial objects, not roles.

## Truth model

Keep separate: - true role - displayed/pretended role - true alignment -
truthful/lying state - taint - transformed/current role - behavior
role - active function - announcement - obscure state

**Pretend != Lie.** - Evil can be truthful. - Good can lie. - Pretenders
may use the behavior/function/ability of the role they pretend when the
mechanic allows it.

True roles do not naturally duplicate. Displayed roles can duplicate
through Pretend/Transform.

## Chỉ Điểm

-   Exactly one suspect.
-   Consumes one turn.
-   Correct = private `{player_id, suspect_id, true_role_id}`; no public
    reveal; player remains active.
-   Wrong = inactive and advance.
-   Correct private knowledge persists.
-   Phán Quyết is the multi-select exact Evil-set submission.
-   No extra reward for identifying Underling vs Traitor.

## Important implemented Case systems

Already real/verified: - Investigation lifecycle - Early Submission -
Final Verdict - POST_REVEAL_FUNCTIONS - Full Reveal - true-role
uniqueness - role/behavior separation - taint - obscure - Thợ May
function - private Chỉ Điểm - Case settlement/reward

Do not rebuild these without auditing the existing implementation.

------------------------------------------------------------------------

# 3. PF-M8 MATCH SYSTEM --- PASS

## PF-M8A

`MvpMatchState.match_rules` owns the MatchRules snapshot.

Modes: - CLASSIC - CUSTOM

Victory: - REACH_COURT_RANK - FIXED_ROUNDS

Classic: - target Nhất phẩm - round_limit 0

Custom: - selected Court Rank - fixed rounds 1/3/5/10

Smoke: **2959/2959 PASS**.

## PF-M8B

Victory is evaluated only after complete Round Settlement.

Ranking: 1. higher Court Rank 2. higher persistent Merit/Công Danh 3.
exact tie

Competition ranking for ties: `1,1,3`.

`completed_round_count` increments exactly once at the idempotent Round
End commit.

`MATCH_COMPLETE` blocks next Case/Round/Loot/gameplay.

Results support: - Chơi Lại - Về Menu Chính

Completed snapshots restore directly to Match Results.

Smoke: **2971/2971 PASS**, human PASS.

------------------------------------------------------------------------

# 4. PF-M9 META-GAME --- PASS

## Equipment Collection / Loadout

PF-M9B PASS. - Relic + Stigmata A/B/C slots - equip/replace/unequip -
replaced items remain owned - player isolation - Gacha rewards appear in
collection - persistence across Rounds - no normal-flow test grant

Smoke: **2981/2981**.

## Equipment Progression

PF-M9C PASS. - Gold/Purple progression - Purple prerequisite + EXP +
same-definition duplicate - cannot consume self - foreign/equipped
duplicate rejected - exact resource consumption on success - no
consumption on failure - equipped instance remains stable

Expected Smoke: **2993/2993**.

## Round Map-Loot / Persistent Transfer

PF-M9D-B PASS. - only CONSUMABLE_ITEM occupies Round Bag - direct
resources bypass Bag - round-bag consumables usable during same Loot
phase - Item Window separates persistent vs round-bag source -
one-item-per-turn allowance is shared - unused bag consumables transfer
exactly once at successful Loot End - next Round transferred items are
persistent and do not occupy Bag - persistent consumable inventory
currently uncapped - finalized Loot is not discarded by Match Complete

Smoke: **3010/3010**.

## Perfect Gacha Choice

PF-M9E-A PASS. - explicit pending choice - cost committed when pending
choice is created - no cancel/refund - explicit reward selection; no
auto first entry - pending blocks Gacha and preparation completion -
reward granted exactly once - pending state persists

Smoke: **3024/3024**.

## Autosave / Continue

PF-M9E-C PASS. - `user://player_facing_autosave.json` - atomic
temp/backup behavior - only safe between-round / completed-match
boundaries - active Round rejected - Continue restores persistent
state - fresh Case options composed exactly once - completed match
restores Results - corrupt/missing save disables Continue - no
mid-Case/Loot/Equipment resume

## Bag Overflow

PF-M9E-D PASS by focused Smoke. - all bag items selectable - no target
preselected - arbitrary replacement - discard incoming - capacity 0 =
discard only - isolation/guards preserved - manual overflow fixture
skipped because current map could not naturally fill enough items
without Remote Inspector

Smoke: **3059/3059**.

------------------------------------------------------------------------

# 5. FIVE CANONICAL HOUSES

  Order   House          ID              Map position
  ------- -------------- --------------- --------------
  1       Nhà họ Hoàng   `house_hoang`   lower-left
  2       Nhà họ Chu     `house_chu`     lower-right
  3       Nhà họ Kim     `house_kim`     left
  4       Nhà họ Huyền   `house_huyen`   top
  5       Nhà họ Lam     `house_lam`     right

The user supplied an Imperial Court reference image. Production map must
follow its macro geography.

Do not redesign the House placement casually.

------------------------------------------------------------------------

# 6. PRODUCTION CHARACTER ROSTER --- PASS

Exactly five production Characters, one per House:

  ID                            Name              House           Speed/Stamina/Bag
  ----------------------------- ----------------- --------------- -------------------
  `character_hoang_linh_lam`    Hoàng Linh Lâm    `house_hoang`   2/2/2
  `character_chu_tue_nguyet`    Chu Tuệ Nguyệt    `house_chu`     2/2/2
  `character_kim_thanh_giai`    Kim Thanh Giai    `house_kim`     2/2/2
  `character_huyen_ca_xuy`      Huyền Ca Xuý      `house_huyen`   2/2/2
  `character_lam_phuong_xuan`   Lam Phương Xuân   `house_lam`     2/2/2

Selection order: **Hoàng → Chu → Kim → Huyền → Lam**

Skills are deferred: - passive skill ID empty - active skill ID empty -
Orb requirement 0

Production: - `test_only_not_canon_locked = false`

Normal setup: - loads `ProductionCharacterRepository` - duplicates
forbidden - Character cards use authoritative Character + House names

TEST A/B/C/D resources remain unchanged for fixture/debug flows.

Loot spawn authority: `origin_house_id → origin_spawn_by_house`

Production roster validator enforces: - exactly five - unique IDs -
canonical Houses - one Character per House - valid names/stats -
non-TEST production status - deferred skills

------------------------------------------------------------------------

# 7. PRODUCTION LOOT MAP --- GĐ2-M0A PASS

Map: `imperial_court_tabletop_v1`

This is a large **tabletop board-game-style node map**, not free 2D
walking.

Total: **77 gameplay nodes**

Extent: - `(300,120)` to `(2900,3460)` - 2600×3340

## House spawns

-   Huyền: `huyen_spawn` `(1600,120)`
-   Kim: `kim_spawn` `(300,420)`
-   Hoàng: `hoang_spawn` `(340,980)`
-   Lam: `lam_spawn` `(2900,420)`
-   Chu: `chu_spawn` `(2860,980)`

Each House: - one spawn - two direct lanes - each lane has 4 private
nodes + spawn = 5 edges to Central Hub

All 10 House lanes meet only at:

`central_hub` `(1600,1500)`

No House gets a graph-distance advantage.

## Middle

From Central Hub: - exactly 3 middle lanes - each = 5 route nodes / 6
edges - all converge at:

`mausoleum_hub` `(1600,2600)`

## Royal / final

From Mausoleum Hub: - exactly **3 final lanes** - each = 5 nodes / 5
edges - all point predominantly south toward the King/royal destination
area - must not flare outward

Current final coordinate pattern:

Left:
`(1400,2780) → (1400,2950) → (1420,3120) → (1440,3290) → (1460,3460)`

Center:
`(1600,2780) → (1600,2950) → (1600,3120) → (1600,3290) → (1600,3460)`

Right:
`(1800,2780) → (1800,2950) → (1780,3120) → (1760,3290) → (1740,3460)`

This corrected an earlier wrong flaring layout.

## Visual priority

Map topology/layout is now about 80% aligned with user intent.

Defer detailed polish: - decorative palace art - final area-name
typography - detailed node art - final visual theme

Current priority is topology and route composition.

------------------------------------------------------------------------

# 8. LOOT CAMERA UX --- IMPLEMENTED

Loot is: **full-screen map/world + minimal HUD**.

## Edge-pan

-   mouse near viewport edge pans
-   diagonal corners work
-   camera does not mutate gameplay

## Zoom

-   `_zoom` float
-   default 1.0
-   max 1.4
-   wheel step 0.1
-   minimum dynamically calculated to fit the whole map within legal
    view/padding
-   Space/auto-focus preserve current zoom
-   F11 geometry refresh recalculates minimum/bounds

## Cursor-centered zoom

Before zoom: 1. get world point under cursor 2. change zoom 3.
recalculate camera center so that world point stays under cursor 4.
clamp to legal camera bounds

Near map edges, clamp may cause slight anchor drift rather than showing
invalid outside-map space.

## Left-drag

-   hold left mouse

-   \<6px = pending, not drag

-   6px = active drag

-   camera: `camera_center -= screen_delta / current_zoom`

-   drag right/down makes map move right/down perceptually

-   edge-pan disabled during active drag

-   release clears drag

-   Space/auto-focus cancels drag cleanly

A previous issue was fixed by changing the transparent full-screen root
`ProductionLootMapPreview` to `MOUSE_FILTER_IGNORE`, allowing
`_unhandled_input()` to receive map drag events. HUD buttons keep
`MOUSE_FILTER_STOP`.

## F11

Fullscreen issue was traced to Godot embedding. After disabling Game
Embed Mode, explicit main-window ID handling works. User manually
confirmed F11 fullscreen works.

Do not revisit F11 unless a concrete integrated gameplay issue appears.

------------------------------------------------------------------------

# 9. PRODUCTION LOOT REWARDS --- PASS

Seven direct-resource production rewards: - Silver Small - Silver
Large - Orb - Gacha Ticket - Equipment EXP Small - Equipment EXP Large -
Exchange Material

All repeatable.

Zone entry order: 1. Silver Small 2. EXP Small 3. Orb 4. Silver Large 5.
EXP Large 6. Exchange 7. Ticket

Weights:

### HOUSE

`30 / 25 / 15 / 10 / 8 / 7 / 5`

### MIDDLE

`18 / 18 / 18 / 14 / 12 / 10 / 10`

### POST_MAUSOLEUM

`10 / 10 / 20 / 16 / 16 / 13 / 15`

Each = 100.

Density: - one deterministic 0..99 roll per eligible node - \<75 creates
a reward snapshot - otherwise no snapshot

Excluded: - House spawns - Central Hub - Mausoleum Hub

END/final nodes use POST_MAUSOLEUM and are eligible.

Seed authority: - persisted `MvpMatchState.case_generation_seed` -
`MvpRoundState.round_number`

Snapshot generated once by `LootRewardService.build_session()` when Loot
starts. Traversal/resolution consumes the snapshot; no rerolls.
Serialization preserves it.

TEST/prototype remains on old M4 reward array +
`SequenceRewardRollSource`.

GĐ2 Production Loot V1: **3154/3154 PASS**.

Qualitative reward priority user stated: **Post-Mausoleum \> middle road
\> House area**, but all remain random and House can still produce good
loot.

------------------------------------------------------------------------

# 10. PRODUCTION CONSUMABLES V1 --- IMPLEMENTED, NOT YET PASS

Three items:

  ----------------------------------------------------------------------------------------------
  ID                                 Effect                  Scope             Target
  ---------------------------------- ----------------------- ----------------- -----------------
  `consumable_hanh_lo_phu`           MOVE_DISTANCE_BONUS +1  THIS_MOVE         SELF

  `consumable_lenh_bai_thong_hanh`   EXTRA_MOVEMENT_ACTION   THIS_ROUND        SELF
                                     +1                                        

  `consumable_ngu_ma_lenh`           SPEED_BONUS +1          THIS_MOVE         SELF
  ----------------------------------------------------------------------------------------------

All: - CONSUMABLE_ITEM - amount 1 - REPEATABLE - production / non-TEST

Rewards: - `prod_consumable_hanh_lo_phu` -
`prod_consumable_lenh_bai_thong_hanh` - `prod_consumable_ngu_ma_lenh`

Production source: `ProductionConsumableRepository.gd`

M4 fixture/prototype consumables remain untouched.

## New 10-entry weights

Order is the 7 direct resources followed by the 3 consumables.

HOUSE: `26 / 22 / 13 / 9 / 7 / 6 / 5 / 6 / 3 / 3`

MIDDLE: `15 / 15 / 15 / 12 / 10 / 9 / 9 / 7 / 4 / 4`

POST_MAUSOLEUM: `8 / 8 / 16 / 13 / 13 / 11 / 13 / 8 / 5 / 5`

All = 100. Density remains 75%.

## Item Window

Persistent and Round Bag both use authoritative:
`ConsumableItemDefinition.display_name`

No production names are synthesized from TEST IDs.

## Ngự Mã Lệnh

Uses existing mechanics: - base Speed 2 - temporary +1 allows next roll
up to 3 - THIS_MOVE expires - following roll returns to max 2

Do not rewrite `LootMovementService` unless a concrete bug is proven.

Reported static assertion delta: +34

Expected Smoke: **3188/3188**

But manual verification is currently blocked by the PF-M4 failure below.

------------------------------------------------------------------------

# 11. PREVIOUS BUG --- PF-M3 / PF-M4 TRANSITION (RESOLVED)

User ran Smoke Test after Consumables V1 and got:
`Invalid access to property or key 'phase' on a base object of type 'Nil'` / 8 failures in `PfM3TestSuite.gd`.

### Root cause found and resolved:
- In `PfM3TestSuite.gd`, line 88 set `players[0].consumable_inventory = [{"item_id": "test_move_plus_1"}]`.
- Under the production map, `MvpIntegratedCaseLootSession` loads `ProductionConsumableRepository.load_all()`, which only recognizes canonical production item IDs (`consumable_hanh_lo_phu`, `consumable_lenh_bai_thong_hanh`, `consumable_ngu_ma_lenh`).
- Calling `flow.use_item("test_move_plus_1")` failed with `ITEM_OR_PLAYER_UNKNOWN`, trapping the loop in `ITEM_WINDOW` and exhausting the guard limit without completing Loot End confirmation.
- Fix: Updated `PfM3TestSuite.gd` line 88 to use `"consumable_hanh_lo_phu"`.
- Status: **RESOLVED & VERIFIED ON GUI (3188/3188 PASS)**.

------------------------------------------------------------------------

# 12. NEXT WORK PROMPT INTENT

When Work usage is available again:

## Goal

Fix only the PF-M4 runtime failure.

## Trace

Follow exactly:

`PF-M4 fixture setup` → movement/reward/overflow setup → Loot End
confirmation request → `begin_loot_end_confirmation()` →
`equipment_session` creation → `LOOT_END_CONFIRMATION`

Find the first failed/incorrect transition.

## Fix

-   repair that authoritative transition or fixture integration
-   preserve Production Consumables V1 semantics
-   preserve Bag lifecycle
-   preserve Loot End transfer
-   preserve Equipment Management behavior
-   add only focused assertions if needed
-   no broad refactor
-   no null-check workaround

## STOP

Stop after: 1. first broken transition is identified; 2. narrow fix is
implemented; 3. focused assertions are updated if needed; 4. static
checks are done.

Then let the user manually run Smoke.

Do not start another GĐ2 feature until PF-M4 is resolved and manually
verified.

Do not run Godot CLI/headless.

------------------------------------------------------------------------

# 13. STALE-TEST LESSONS

Several recent failures were test-side, not runtime bugs.

### Camera focus

Hoàng spawn `(340,980)` could not be exactly centered because legal
camera minimum X was `(780)`. Runtime correctly clamped. Fix: test
computes closest legal camera center.

### PF-M5

Tests initially expected obsolete prototype labels. Then PF-M5 was found
to be querying production node IDs against an M3 fixture. Fix: helper
selects House/central/downstream nodes from the actual fixture by
kinds/tags.

### Drag test

Test started at a camera clamp boundary. Fix: test first moves camera
into legal non-clamped space before asserting inverse drag.

Lesson: Before changing runtime, verify: - correct fixture - correct
node IDs - legal camera bounds - current production vs TEST data source

------------------------------------------------------------------------

# 14. PRODUCTION / TEST BOUNDARY

Production: - `ProductionHouseRepository` -
`ProductionCharacterRepository` - production map
`imperial_court_tabletop_v1` - `ProductionRewardRepository` -
`ProductionConsumableRepository` - deterministic seeded production
rewards

TEST/prototype: - `Gd2FixtureRepository` - TEST Character A/B/C/D - M4
reward arrays - `SequenceRewardRollSource` - fixture maps such as M3/M4

Do not rewrite TEST fixtures to make production behavior pass.

------------------------------------------------------------------------

# 15. OTHER IMPORTANT PROJECT RULES

## Court Rank

Ladder: Cửu phẩm → Bát phẩm → Thất phẩm → Lục phẩm → Ngũ phẩm → Tứ phẩm
→ Tam phẩm → Nhị phẩm → Nhất phẩm.

-   persistent Merit across Rounds
-   Court Rank derived from authoritative thresholds
-   rank-up feedback uses authoritative before/after Merit
-   rank persists
-   no gameplay modifier unless explicitly added later
-   Nhất phẩm has no fake next rank

## Case UI

Current Case UI pass is considered complete. Only reopen for concrete
defects. Final game art/polish is not considered finished.

## Tutorial state

Tutorials 01--08 are reusable-system teaching fixtures. Do not hardcode
tutorial-only behavior if it can become a reusable engine primitive.

Tutorial-specific critical corrections: - Tutorial 5: Vigilante starts
alive; Surgeon may later kill it probabilistically. - Tutorial 7:
Surgeon #1 killed #3 at 12h, not #2. - Tutorial 8: Copycat #3 pretending
Vigilante killed Conman #2; true Vigilante #5 was never used. - Tutorial
4: project-authored hidden fixture is #1 true Tailor, #2 Mobster→Tailor,
#3 Mailman, #4 Priest; do not call that hidden assignment
source-confirmed Dupery fact without evidence.

------------------------------------------------------------------------

# 16. FUTURE GENERATOR MENTAL MODEL

Future Case Generator must: 1. Generate authoritative hidden world: -
board - true roles - alignment - pretend relations - taint -
transforms - obscure - locations - timed events - ability availability -
death/arrest 2. Derive public information. 3. Simulate legal actions. 4.
Validate unique solvability. 5. Reject contradictory, ambiguous,
impossible, or unfair cases.

Never randomize visible clues directly or assume Evil=lying.

------------------------------------------------------------------------

# 17. CURRENT ONE-LINE HANDOFF

> **GĐ2 Production Loot is completed and fully verified PASS (3188/3188): canonical 5 Houses, 5 Characters, 77-node production map, camera UX, reward tables V1, and Consumables V1. The previous PF-M3/PF-M4 blocker was resolved by fixing the consumable item ID in `PfM3TestSuite.gd`. The system baseline is clean and 100% green. Ready for next project milestone.**

------------------------------------------------------------------------

# END
