---
id: TASK-0021C
title: Extract FMOD FSB5 Audio Samples to WAV Vault and Document Architecture Lessons
domain: software
status: verified
phase: P2
touches_gatekeeper: true
goal: 'Completely eliminate Trade-off 1 of TASK-0018 per architectural decision DEC-27.1
  by building a dedicated extraction tool (scripts/agent/extract_fmod_samples_vault.py)
  using the official FMOD Low-Level engine (fmod.dll) to decode all 155 FSB5 Vorbis
  sound samples across 4 audio banks (Atmosphere, Intro, Music, Sfx) into standard
  PCM WAV files on disk under docs/agent-system/evidence/dupery/vault/audio/samples/.
  Generate a cryptographic manifest (fmod_samples_vault_manifest.json) recording sample
  rate, channels, bit depth, duration, and SHA-256 hash for every sample. Author a
  comprehensive architectural lessons document (fmod_audio_architecture_lessons.md)
  analyzing Dupery''s FMOD design and establishing the Godot 4 interactive audio reconstruction
  roadmap for TASK-0027.

  '
in_scope:
- .gitignore
- scripts/agent/check_scope.py
- scripts/agent/extract_fmod_samples_vault.py
- tests/test_extract_fmod_samples_vault.py
- docs/agent-system/evidence/dupery/vault/audio/fmod_samples_vault_manifest.json
- docs/agent-system/evidence/dupery/audio/fmod_audio_architecture_lessons.md
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
- TASK-0018
- TASK-0021
assumptions:
- FMOD Banks exist at D:\Minh\Steam\steamapps\common\Dupery\Dupery_Data\StreamingAssets\
- fmod.dll x64 exists at D:\Minh\Tool_App\AssetStudio.net472.v0.16.47\x64\fmod.dll
acceptance_criteria:
- scripts/agent/extract_fmod_samples_vault.py implements deterministic extraction
  of all 155 FSB5 Vorbis audio samples across 4 banks into PCM WAV format.
- Manifest docs/agent-system/evidence/dupery/vault/audio/fmod_samples_vault_manifest.json
  catalogs all 155 samples with SHA-256 digests and technical audio parameters.
- Document docs/agent-system/evidence/dupery/audio/fmod_audio_architecture_lessons.md
  captures reverse engineering findings, FMOD sound architecture, and Godot 4 interactive
  audio reconstruction roadmap.
- All code files adhere to ADR-0010 Line Budget (< 300 LOC, tier ok).
- Unit tests pass 100%.
verification_commands:
- python scripts/agent/extract_fmod_samples_vault.py --verify
- python scripts/agent/extract_fmod_samples_vault.py --stats
- python -m unittest tests/test_extract_fmod_samples_vault.py
- python scripts/agent/check_peer_audit.py --task TASK-0021C
stop_conditions:
- Any file exceeds 300 LOC without modularization.
- Git working tree modifies files outside declared in_scope.
- Audio decoding fails or produces corrupted/zero-byte WAV files.
line_budget_exceptions: []
current_checkpoint: CP-VERIFIED
evidence_receipt: docs/agent-system/evidence/TASK-0021C-receipt.json
---

# TASK-0021C: Extract FMOD FSB5 Audio Samples to WAV Vault and Document Architecture Lessons

## Context & Rationale
During TASK-0018, metadata and Radix Tree string tables for all 6 FMOD Banks were extracted, mapping 50 C# enums to FMOD GUIDs. However, due to line budget constraints (< 300 LOC), an inline Vorbis bitstream decoder was omitted (Trade-off 1).
Per user direction and architectural decision DEC-27.1, this task builds a dedicated extraction engine leveraging the native `fmod.dll` to decompress all 155 sound samples into clean `.wav` files on disk, generates cryptographic manifests, and documents practical lessons learned for audio engineering and Godot 4 interactive audio reconstruction.

## Key Deliverables
1. `scripts/agent/extract_fmod_samples_vault.py`: Dedicated CLI engine supporting `--extract`, `--verify`, and `--stats`.
2. `docs/agent-system/evidence/dupery/vault/audio/fmod_samples_vault_manifest.json`: Full inventory with SHA-256 digests.
3. `docs/agent-system/evidence/dupery/audio/fmod_audio_architecture_lessons.md`: Architectural analysis and Godot 4 roadmap.
4. `tests/test_extract_fmod_samples_vault.py`: Unit tests validating extraction and manifest integrity.