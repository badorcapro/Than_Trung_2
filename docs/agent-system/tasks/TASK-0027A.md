---
id: TASK-0027A
title: Dissect Interactive Audio Engine & FMOD Bridge (283 Classes)
domain: software
status: approved
phase: P2
touches_gatekeeper: false
goal: 'Execute the first sub-task of Cycle V6 (Technical Infrastructure & Interactive
  Audio) by performing deep architectural dissection and Godot 4 reconstruction mapping
  across 283 classes: 14 C# classes in Assembly-CSharp (AudioHandler, AudioMusicPlayer,
  AudioAtmoPlayer, AudioSfxPlayer, AudioCutscenePlayer, AudioBanks, GlobalParams,
  Music, Atmo, Sfx, etc.) and 269 classes in FMOD / FMODUnity / FMOD.Studio bridge.
  1. Author a comprehensive anatomy handbook (V6A_Interactive_Audio_Engine_and_FMOD_Bridge.md)
  analyzing all 14 Audio classes and 269 FMOD classes, mapping FMOD Event GUIDs and
  parameters to Godot 4.6.2 AudioServer bus architecture (Master, Music, Atmosphere,
  SFX, Reverb), Autoload AudioManager.gd, stem-synchronized playback across 4 Noir
  Jazz themes, 16 saxophone solo improvisations, and snapshot parameters (GAME_PAUSE,
  PopPitch). 2. Build an executable deterministic Audio Engine Simulator (scripts/agent/simulate_audio_engine.py)
  modeling bus mixing, stem cross-fading, saxophone solo triggering, and pause snapshot
  ducking under ADR-0010 (< 300 LOC, tier ok). 3. Update reconstruction status of
  14 Audio classes to L3 documented and 269 FMOD audio_bridge classes to L2 documented
  in docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json, maintaining
  unaccounted == 0 and 100% CIL token coverage. 4. Establish empirical verification
  checklist for audio latency, cross-fade curves, and stem synchronization.

  '
in_scope:
- docs/agent-system/tasks/TASK-0027A.md
- docs/agent-system/evidence/dupery/handbook/V6A_Interactive_Audio_Engine_and_FMOD_Bridge.md
- docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json
- scripts/agent/simulate_audio_engine.py
- tests/test_simulate_audio_engine.py
out_of_scope:
- Than_Tham_Nua_Voi_Godot/**
- docs/agent-system/evidence/dupery/vault/audio/samples/**
- docs/agent-system/evidence/dupery/vault/raw/**
references:
- ARCH-CORE-001
- RULE-ENGINE-001
- RULE-SCOPE-001
- ADR-ARCH-010
- PLAN-CHANG-003
dependencies:
- TASK-0010
- TASK-0011
- TASK-0018
- TASK-0021B
- TASK-0021C
- TASK-0026C
assumptions:
- Decompiled C# source trees exist under docs/agent-system/evidence/dupery/generated/decompiled_cs/.
- 155 WAV PCM samples were successfully extracted to vault under TASK-0021C.
acceptance_criteria:
- Handbook docs/agent-system/evidence/dupery/handbook/V6A_Interactive_Audio_Engine_and_FMOD_Bridge.md
  analyzes all 14 Audio classes and 269 FMOD bridge classes.
- Sổ cái reconstruction_obligation_ledger.json updates 14 Audio classes to depth L3
  documented and 269 FMOD classes to depth L2 documented, maintaining unaccounted
  == 0.
- scripts/agent/simulate_audio_engine.py implements 5 buses layout, stem mixing, sax
  solos, and GAME_PAUSE snapshot adhering to ADR-0010 (< 300 LOC, tier ok).
- tests/test_simulate_audio_engine.py validates bus routing, stem volume bounds, debouncing,
  and snapshot state.
- Subagent Peer-Audit passes with verdict PASS.
verification_commands:
- python scripts/agent/simulate_audio_engine.py --verify
- python -m unittest tests/test_simulate_audio_engine.py
- python scripts/agent/validate_registry.py
- python scripts/agent/check_peer_audit.py --task TASK-0027A
stop_conditions:
- Any file exceeds 300 LOC without modularization.
- Git working tree modifies files outside declared in_scope.
- Failure of stem mixing synchronization or audio regression.
line_budget_exceptions: []
current_checkpoint: CP-APPROVED
evidence_receipt: docs/agent-system/evidence/TASK-0027A-receipt.json
---

# TASK-0027A: Dissect Interactive Audio Engine & FMOD Bridge (283 Classes)

## Context & Rationale
TASK-0027A là tiểu nhiệm vụ đầu tiên của Vòng V6 (Hạ tầng kỹ thuật & Âm thanh tương tác), giải quyết dứt điểm phân hệ âm thanh tương tác của tựa game *Dupery*:
1. **14 Classes C# trong Namespace `Audio` (`Assembly-CSharp`)**:
   - `AudioHandler`: Singleton điều phối toàn cục.
   - `AudioMusicPlayer` & `Music`: Trình phát nhạc tương tác đa phân tầng (stem-mixing) 4 bản nhạc Noir Jazz và 16 đoạn saxophone độc tấu.
   - `AudioAtmoPlayer`, `AtmoInstanceData` & `Atmo`: Trình phát đa âm cảnh không gian (mưa, sóng, chuỗi xích, sáp chì).
   - `AudioSfxPlayer`, `AudioSfxQueuer` & `Sfx`: Phản hồi xúc giác UI và debounce queue.
   - `AudioCutscenePlayer`, `AudioBanks`, `GlobalParams`, `AudioHelper`, `AudioReferencesSO`.
2. **269 Classes C# trong `audio_bridge` (FMOD, FMODUnity, FMOD.Studio)**:
   - Thay thế toàn bộ runtime FMOD bằng 5 `AudioServer` buses trong Godot 4.6.2 (`Master`, `Music`, `Atmosphere`, `SFX`, `Reverb`).
   - Kết nối trực tiếp 155 tệp WAV PCM uncompressed đã bung ra từ vault ở TASK-0021C.

## Key Deliverables
1. `docs/agent-system/evidence/dupery/handbook/V6A_Interactive_Audio_Engine_and_FMOD_Bridge.md`: Cẩm nang giải phẫu kiến trúc 283 classes.
2. `scripts/agent/simulate_audio_engine.py`: Module mô phỏng 5 buses, stem layering, sax solos, và snapshot `GAME_PAUSE`.
3. `tests/test_simulate_audio_engine.py`: Bộ 7 unit tests kiểm định toàn diện phân hệ âm thanh.
4. `docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json`: Cập nhật 14 classes Audio sang L3 `documented` và 269 classes FMOD sang L2 `documented`.