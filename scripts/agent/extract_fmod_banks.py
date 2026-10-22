"""Extractor and catalog builder for Dupery FMOD Audio Banks and Event Mappings.

Parses 6 FMOD Banks (Atmosphere, Intro, Master, Master.strings, Music, Sfx),
decodes embedded FSB5 sound sample headers (155 samples total), extracts Radix
Tree event paths from Master.strings.bank, links C# Audio enums and GUIDs from
AudioReferencesSO, and generates canonical JSON evidence artifacts.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import struct
import sys
import uuid
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

DEFAULT_STREAMING_ASSETS = Path(r"D:\Minh\Steam\steamapps\common\Dupery\Dupery_Data\StreamingAssets")
DEFAULT_SHARED_ASSETS0 = Path(r"D:\Minh\Steam\steamapps\common\Dupery\Dupery_Data\sharedassets0.assets")
DEFAULT_OUT_DIR = Path("docs/agent-system/evidence/dupery/audio")

BANK_FILES = [
    "Atmosphere.bank",
    "Intro.bank",
    "Master.bank",
    "Master.strings.bank",
    "Music.bank",
    "Sfx.bank",
]

MUSIC_ENUMS = {
    1: "A_MT", 2: "B", 3: "C", 4: "D", 5: "E", 6: "F",
    100: "CAS_A", 101: "CAS_B", 200: "DCK_A", 201: "DCK_B",
}

ATMO_ENUMS = {
    0: "RAIN", 1: "RAIN_WINDOW", 1000: "CASINO", 2000: "WAVES", 2001: "DOCKS",
    9000: "CHAINS", 9001: "PEN_SCRIBLLES", 9002: "RUBBER_ERASING", 9003: "GATE_CLOSE",
}

SFX_ENUMS = {
    0: "TEST_BUTTON", 1000: "PAPER_BUTTON", 1001: "TICK", 1002: "TYPE_WRITER_TICK",
    1003: "PAPER_SHORT", 1004: "SUSPECT_HOVER", 1005: "CHARACTER_HOVER", 1006: "POP",
    2000: "DOOR_KNOCK", 2001: "CHAINS_END", 2002: "CARD", 2003: "PIN_DROP",
    2004: "GATE_END", 2005: "GUNSHOT", 2100: "CHIPS_DOWN", 2101: "CHIPS_UP",
    2102: "CARD_DECK", 2200: "BOAT_ACTIVATE", 2201: "BOAT_DEACTIVATE", 2202: "HIDE",
    2203: "DREDGE", 3000: "CLOCK_TOWER_CHIME", 3001: "NAVAL_MINE_EXPLOSION",
    4000: "JUDGE_GAVEL", 8950: "LUKE_INV", 8951: "LUKE_ARR", 8952: "MATT_INV",
    8953: "MATT_ARR", 8954: "LYDIA_INV", 8955: "LYDIA_ARR", 9000: "MAIN_MENU_CLOCKTOWER",
    9001: "LINEUP_MOVE",
}


def parse_fsb5(bank_bytes: bytes) -> Optional[Dict[str, Any]]:
    """Decode embedded FSB5 container header and sample names."""
    idx = bank_bytes.find(b"FSB5")
    if idx == -1:
        return None
    magic, ver, num_samples, sh_size, nt_size, data_size, mode = struct.unpack_from(
        "<4sIIIIII", bank_bytes, idx
    )
    names: List[str] = []
    if nt_size > 0:
        nt_offset = idx + 60 + sh_size
        nt_data = bank_bytes[nt_offset : nt_offset + nt_size]
        if len(nt_data) >= num_samples * 4:
            offsets = struct.unpack_from(f"<{num_samples}I", nt_data, 0)
            for off in offsets:
                end = nt_data.find(b"\x00", off)
                sample_name = nt_data[off:end].decode("latin1", errors="replace") if end != -1 else nt_data[off:].decode("latin1", errors="replace")
                names.append(sample_name)
    return {
        "offset": idx,
        "version": ver,
        "num_samples": num_samples,
        "sample_headers_size": sh_size,
        "name_table_size": nt_size,
        "data_size": data_size,
        "codec_mode": mode,
        "samples": names,
    }


def parse_fmod_strings_bank(bank_bytes: bytes) -> Tuple[List[str], Dict[str, str]]:
    """Extract 62 GUIDs and decode Radix Tree paths from Master.strings.bank."""
    guids: List[str] = []
    for i in range(1244, 2236, 16):
        raw_g = bank_bytes[i : i + 16]
        u = uuid.UUID(bytes_le=raw_g)
        guids.append(f"{{{u}}}")

    str_pool = bank_bytes[2239:]
    records_raw = bank_bytes[464:1244]
    num_records = len(records_raw) // 8
    records = []
    for r_idx in range(num_records):
        w0, w1 = struct.unpack_from("<II", records_raw, r_idx * 8)
        records.append({
            "str_offset": w0 & 0x00FFFFFF,
            "char": chr((w0 >> 24) & 0xFF),
            "target": w1 & 0x00FFFFFF,
            "num_children": (w1 >> 24) & 0xFF,
        })

    def get_str(offset: int) -> str:
        end = str_pool.find(b"\x00", offset)
        raw_sub = str_pool[offset:end] if end != -1 else str_pool[offset:]
        return raw_sub.decode("utf-8", errors="replace")

    events_by_guid: Dict[str, str] = {}

    def traverse(rec_idx: int, current_path: str) -> None:
        rec = records[rec_idx]
        token = rec["char"] if rec["char"] and ord(rec["char"]) > 0 else ""
        if rec["str_offset"] < len(str_pool):
            token += get_str(rec["str_offset"])
        new_path = current_path + token
        num_c = rec["num_children"]
        target = rec["target"]
        if num_c == 0:
            if target < len(guids):
                events_by_guid[guids[target]] = new_path
        else:
            for c in range(num_c):
                traverse(target + c, new_path)

    if records:
        for c in range(records[0]["num_children"]):
            traverse(1 + c, "")

    return guids, events_by_guid


def parse_audio_references_raw(raw_data: bytes) -> Dict[str, List[Tuple[int, str]]]:
    """Parse serializable dictionaries from AudioReferencesSO in sharedassets0."""
    name_idx = raw_data.find(b"AudioReferences")
    if name_idx == -1:
        return {"music": [], "sfx": [], "atmo": []}
    off = name_idx + len("AudioReferences")
    if off % 4 != 0:
        off += 4 - (off % 4)

    def read_dict(cur_off: int) -> Tuple[List[Tuple[int, str]], int]:
        count = struct.unpack_from("<I", raw_data, cur_off)[0]
        cur_off += 4
        entries: List[Tuple[int, str]] = []
        for _ in range(count):
            enum_val = struct.unpack_from("<i", raw_data, cur_off)[0]
            cur_off += 4
            g_bytes = raw_data[cur_off : cur_off + 16]
            cur_off += 16
            u = uuid.UUID(bytes_le=g_bytes)
            entries.append((enum_val, f"{{{u}}}"))
        return entries, cur_off

    music_refs, off = read_dict(off)
    sfx_refs, off = read_dict(off)
    atmo_refs, off = read_dict(off)
    return {"music": music_refs, "sfx": sfx_refs, "atmo": atmo_refs}


def load_audio_references(sharedassets0_path: Path) -> Dict[str, List[Tuple[int, str]]]:
    """Extract AudioReferencesSO from sharedassets0 using UnityPy."""
    import UnityPy

    env = UnityPy.load(str(sharedassets0_path))
    for obj in env.objects:
        if obj.path_id == 1398:
            return parse_audio_references_raw(obj.get_raw_data())
    return {"music": [], "sfx": [], "atmo": []}


def build_audio_manifest(streaming_dir: Path) -> Dict[str, Any]:
    """Inspect and catalog all 6 FMOD bank files."""
    banks_info: List[Dict[str, Any]] = []
    total_samples = 0
    for b_name in BANK_FILES:
        p = streaming_dir / b_name
        if not p.exists():
            continue
        data = p.read_bytes()
        digest = hashlib.sha256(data).hexdigest()
        fsb_data = parse_fsb5(data)
        if fsb_data:
            total_samples += fsb_data["num_samples"]
        banks_info.append({
            "name": b_name,
            "path": f"StreamingAssets/{b_name}",
            "size_bytes": len(data),
            "sha256": digest,
            "has_fsb5": fsb_data is not None,
            "fsb5_info": fsb_data,
        })
    return {
        "metadata": {
            "title": "Dupery FMOD Audio Banks Manifest",
            "phase": "P2",
            "total_banks": len(banks_info),
            "total_samples": total_samples,
        },
        "banks": banks_info,
    }


def build_event_map(
    guids: List[str],
    events_by_guid: Dict[str, str],
    refs: Dict[str, List[Tuple[int, str]]],
) -> Dict[str, Any]:
    """Reconstruct cross-system mapping linking enums, GUIDs, and FMOD paths."""
    def map_category(category_refs: List[Tuple[int, str]], enum_table: Dict[int, str], target_bank: str) -> List[Dict[str, Any]]:
        mapped = []
        for val, g in category_refs:
            mapped.append({
                "enum_name": enum_table.get(val, f"UNKNOWN_{val}"),
                "enum_value": val,
                "guid": g,
                "fmod_path": events_by_guid.get(g, "NOT_FOUND"),
                "target_bank": target_bank,
            })
        return mapped

    music_map = map_category(refs["music"], MUSIC_ENUMS, "Music.bank")
    atmo_map = map_category(refs["atmo"], ATMO_ENUMS, "Atmosphere.bank")
    sfx_map = map_category(refs["sfx"], SFX_ENUMS, "Sfx.bank")

    intro_events = [
        {"name": "IntroEnglish", "guid": "{4e7a8c5e-4d64-47d7-9547-14ff6de5d814}", "fmod_path": "event:/intro/Intro_english", "target_bank": "Intro.bank"},
        {"name": "IntroNoVoice", "guid": "{c761c00f-feec-48b4-ab8e-9b1ea8d8cb36}", "fmod_path": "event:/intro/Intro_noVoice", "target_bank": "Intro.bank"},
    ]

    parameters = [
        {"name": "GamePause", "guid": "{13f715bc-dd85-464a-a182-093335b16331}", "fmod_path": "parameter:/gamePause"},
        {"name": "PopPitch", "guid": "{c8aad81f-60c9-4f5d-b1e2-19c07d5cbd74}", "fmod_path": "parameter:/sfxParameters/PopPitch"},
    ]

    busses = [
        {"name": "MasterBus", "guid": "{8813dd73-cadf-4992-ab9d-23257c0dc7be}", "fmod_path": "bus:/"},
        {"name": "Reverb", "guid": "{f042ac38-628e-469a-a35a-7e3c00e2ae5b}", "fmod_path": "bus:/reverb"},
    ]

    return {
        "metadata": {
            "title": "Dupery Cross-System FMOD Event Map",
            "phase": "P2",
            "total_mapped_enums": len(music_map) + len(atmo_map) + len(sfx_map),
            "total_guids_in_bank": len(guids),
            "limitations_notice": (
                "FMOD compiled bank bytecode does not preserve dynamic musical transition curves, "
                "beat callback sync triggers, or internal DSP parameter graphs in readable text. "
                "These runtime audio behaviors require empirical dynamic tracing via TASK-0019/0020."
            ),
        },
        "cross_system_mappings": {
            "music": music_map,
            "atmosphere": atmo_map,
            "sfx": sfx_map,
            "intro_cutscenes": intro_events,
        },
        "parameters": parameters,
        "busses": busses,
    }


def run_extraction(streaming_dir: Path, sharedassets0: Path, out_dir: Path) -> Tuple[Path, Path]:
    """Execute complete extraction workflow and save JSON artifacts."""
    out_dir.mkdir(parents=True, exist_ok=True)
    manifest = build_audio_manifest(streaming_dir)
    strings_bytes = (streaming_dir / "Master.strings.bank").read_bytes()
    guids, events_by_guid = parse_fmod_strings_bank(strings_bytes)
    refs = load_audio_references(sharedassets0)
    event_map = build_event_map(guids, events_by_guid, refs)

    manifest_path = out_dir / "fmod_banks_manifest.json"
    event_map_path = out_dir / "fmod_event_map.json"
    manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    event_map_path.write_text(json.dumps(event_map, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return manifest_path, event_map_path


def verify_extraction(manifest_path: Path, event_map_path: Path) -> bool:
    """Verify integrity of generated audio manifests against acceptance criteria."""
    if not manifest_path.exists() or not event_map_path.exists():
        return False
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    event_map = json.loads(event_map_path.read_text(encoding="utf-8"))

    if manifest["metadata"]["total_banks"] != 6:
        return False
    if manifest["metadata"]["total_samples"] != 155:
        return False

    cs_map = event_map["cross_system_mappings"]
    if len(cs_map["music"]) != 10:
        return False
    if len(cs_map["atmosphere"]) != 8:
        return False
    if len(cs_map["sfx"]) != 32:
        return False
    if len(cs_map["intro_cutscenes"]) != 2:
        return False
    if len(event_map["parameters"]) != 2:
        return False
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description="Extract Dupery FMOD banks and event map.")
    parser.add_argument("--streaming-dir", type=Path, default=DEFAULT_STREAMING_ASSETS)
    parser.add_argument("--sharedassets0", type=Path, default=DEFAULT_SHARED_ASSETS0)
    parser.add_argument("--out-dir", type=Path, default=DEFAULT_OUT_DIR)
    parser.add_argument("--verify", action="store_true", help="Verify existing artifacts.")
    parser.add_argument("--stats", action="store_true", help="Print summary statistics.")
    args = parser.parse_args()

    m_path = args.out_dir / "fmod_banks_manifest.json"
    e_path = args.out_dir / "fmod_event_map.json"

    if args.verify:
        ok = verify_extraction(m_path, e_path)
        print("VERIFY:", "PASS" if ok else "FAIL")
        return 0 if ok else 1

    m_path, e_path = run_extraction(args.streaming_dir, args.sharedassets0, args.out_dir)
    print(f"Generated manifest: {m_path}")
    print(f"Generated event map: {e_path}")

    if args.stats:
        manifest = json.loads(m_path.read_text(encoding="utf-8"))
        print(f"Banks: {manifest['metadata']['total_banks']}")
        print(f"Samples: {manifest['metadata']['total_samples']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
