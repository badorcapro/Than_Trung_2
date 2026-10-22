"""FMOD FSB5 Audio Samples Vault Extractor and Manifest Generator.

Extracts all 155 Vorbis-encoded FSB5 audio samples across 4 FMOD Banks
(Atmosphere, Intro, Music, Sfx) into clean uncompressed PCM WAV files
using the native FMOD Low-Level engine (fmod.dll). Generates cryptographic
manifest with SHA-256 digests and technical audio specifications.
"""

from __future__ import annotations

import argparse
import ctypes
import hashlib
import json
import os
import re
import sys
import tempfile
import wave
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

DEFAULT_STREAMING_DIR = Path(r"D:\Minh\Steam\steamapps\common\Dupery\Dupery_Data\StreamingAssets")
DEFAULT_FMOD_DLL = Path(r"D:\Minh\Tool_App\AssetStudio.net472.v0.16.47\x64\fmod.dll")
DEFAULT_VAULT_AUDIO_DIR = Path("docs/agent-system/evidence/dupery/vault/audio")
DEFAULT_SAMPLES_DIR = DEFAULT_VAULT_AUDIO_DIR / "samples"
DEFAULT_MANIFEST_PATH = DEFAULT_VAULT_AUDIO_DIR / "fmod_samples_vault_manifest.json"

TARGET_BANKS = ["Atmosphere.bank", "Intro.bank", "Music.bank", "Sfx.bank"]
TIMEUNIT_PCMBYTES = 4


def sanitize_filename(name: str) -> str:
    """Sanitize sound sample name for Windows filesystem safety."""
    cleaned = re.sub(r'[<>:"/\\|?*]', "_", name).strip()
    return cleaned if cleaned else "unnamed_sample"


class FmodDecoder:
    """Wrapper around native fmod.dll Low-Level API."""

    def __init__(self, dll_path: Path) -> None:
        if not dll_path.is_file():
            raise FileNotFoundError(f"FMOD DLL not found at: {dll_path}")
        self.dll = ctypes.CDLL(str(dll_path))
        self.system = ctypes.c_void_p()
        res = self.dll.FMOD_System_Create(ctypes.byref(self.system), 0x00020200)
        if res != 0:
            raise RuntimeError(f"FMOD_System_Create failed with code {res}")
        res = self.dll.FMOD_System_Init(self.system, 32, 0, None)
        if res != 0:
            raise RuntimeError(f"FMOD_System_Init failed with code {res}")

    def close(self) -> None:
        """Release FMOD system resources."""
        if self.system:
            self.dll.FMOD_System_Release(self.system)
            self.system = ctypes.c_void_p()

    def decode_fsb_to_wavs(
        self,
        bank_path: Path,
        bank_out_dir: Path,
    ) -> List[Dict[str, Any]]:
        """Decode all subsounds in an FSB bank to 16-bit PCM WAV files."""
        bank_bytes = bank_path.read_bytes()
        idx = bank_bytes.find(b"FSB5")
        if idx == -1:
            return []

        bank_out_dir.mkdir(parents=True, exist_ok=True)
        results: List[Dict[str, Any]] = []

        with tempfile.NamedTemporaryFile(suffix=".fsb", delete=False) as tmp:
            tmp.write(bank_bytes[idx:])
            tmp_path = Path(tmp.name)

        sound = ctypes.c_void_p()
        try:
            res = self.dll.FMOD_System_CreateSound(
                self.system,
                str(tmp_path.resolve()).encode("utf-8"),
                0,
                None,
                ctypes.byref(sound),
            )
            if res != 0:
                raise RuntimeError(f"FMOD_System_CreateSound failed on {bank_path.name}: code {res}")

            num_sub = ctypes.c_int()
            self.dll.FMOD_Sound_GetNumSubSounds(sound, ctypes.byref(num_sub))

            for i in range(num_sub.value):
                sample_meta = self._extract_subsound(sound, i, bank_path.stem, bank_out_dir)
                results.append(sample_meta)
        finally:
            if sound:
                self.dll.FMOD_Sound_Release(sound)
            if tmp_path.exists():
                tmp_path.unlink()

        return results

    def _extract_subsound(
        self,
        parent_sound: ctypes.c_void_p,
        index: int,
        bank_name: str,
        out_dir: Path,
    ) -> Dict[str, Any]:
        """Extract a single SubSound into a PCM WAV file."""
        subsound = ctypes.c_void_p()
        self.dll.FMOD_Sound_GetSubSound(parent_sound, index, ctypes.byref(subsound))

        name_buf = ctypes.create_string_buffer(256)
        self.dll.FMOD_Sound_GetName(subsound, name_buf, 256)
        raw_name = name_buf.value.decode("latin1", errors="replace")
        safe_name = sanitize_filename(raw_name)

        type_v, format_v = ctypes.c_int(), ctypes.c_int()
        channels, bits = ctypes.c_int(), ctypes.c_int()
        self.dll.FMOD_Sound_GetFormat(
            subsound,
            ctypes.byref(type_v),
            ctypes.byref(format_v),
            ctypes.byref(channels),
            ctypes.byref(bits),
        )

        len_bytes = ctypes.c_uint()
        self.dll.FMOD_Sound_GetLength(subsound, ctypes.byref(len_bytes), TIMEUNIT_PCMBYTES)

        freq = ctypes.c_float()
        prio = ctypes.c_int()
        self.dll.FMOD_Sound_GetDefaults(subsound, ctypes.byref(freq), ctypes.byref(prio))

        ptr1, ptr2 = ctypes.c_void_p(), ctypes.c_void_p()
        len1, len2 = ctypes.c_uint(), ctypes.c_uint()
        lock_res = self.dll.FMOD_Sound_Lock(
            subsound,
            0,
            len_bytes.value,
            ctypes.byref(ptr1),
            ctypes.byref(ptr2),
            ctypes.byref(len1),
            ctypes.byref(len2),
        )

        if lock_res != 0 or len1.value == 0:
            raise RuntimeError(f"FMOD_Sound_Lock failed for {raw_name}: code {lock_res}")

        pcm_data = ctypes.string_at(ptr1.value, len1.value)
        self.dll.FMOD_Sound_Unlock(subsound, ptr1, ptr2, len1, len2)

        wav_filename = f"{index:02d}_{safe_name}.wav"
        wav_path = out_dir / wav_filename
        with wave.open(str(wav_path), "wb") as wf:
            wf.setnchannels(channels.value)
            wf.setsampwidth(bits.value // 8)
            wf.setframerate(int(freq.value))
            wf.writeframes(pcm_data)

        wav_bytes = wav_path.read_bytes()
        sha256_hash = hashlib.sha256(wav_bytes).hexdigest()
        duration = len_bytes.value / (channels.value * (bits.value // 8) * freq.value) if freq.value > 0 else 0.0

        rel_path = wav_path.as_posix()
        if "docs/agent-system" in rel_path:
            rel_path = rel_path[rel_path.find("docs/agent-system"):]

        return {
            "index": index,
            "bank": bank_name,
            "sample_name": raw_name,
            "filename": wav_filename,
            "path": rel_path,
            "channels": channels.value,
            "bits_per_sample": bits.value,
            "sample_rate_hz": int(freq.value),
            "pcm_length_bytes": len_bytes.value,
            "wav_size_bytes": len(wav_bytes),
            "duration_seconds": round(duration, 3),
            "sha256": sha256_hash,
        }


def build_samples_vault(
    streaming_dir: Path = DEFAULT_STREAMING_DIR,
    out_samples_dir: Path = DEFAULT_SAMPLES_DIR,
    manifest_path: Path = DEFAULT_MANIFEST_PATH,
    fmod_dll: Path = DEFAULT_FMOD_DLL,
) -> Dict[str, Any]:
    """Extract all 155 samples from 4 banks and generate manifest."""
    decoder = FmodDecoder(fmod_dll)
    all_samples: List[Dict[str, Any]] = []
    bank_stats: Dict[str, int] = {}

    try:
        for bank_file in TARGET_BANKS:
            b_path = streaming_dir / bank_file
            if not b_path.is_file():
                continue
            bank_out = out_samples_dir / b_path.stem
            samples = decoder.decode_fsb_to_wavs(b_path, bank_out)
            all_samples.extend(samples)
            bank_stats[b_path.stem] = len(samples)
    finally:
        decoder.close()

    total_pcm = sum(s["pcm_length_bytes"] for s in all_samples)
    total_wav = sum(s["wav_size_bytes"] for s in all_samples)
    total_sec = sum(s["duration_seconds"] for s in all_samples)

    manifest_data = {
        "title": "Dupery FMOD Audio Samples Vault Manifest",
        "provenance": "Extracted via native fmod.dll 2.02 from Dupery StreamingAssets",
        "total_samples": len(all_samples),
        "total_banks": len(bank_stats),
        "bank_breakdown": bank_stats,
        "total_pcm_bytes": total_pcm,
        "total_wav_bytes": total_wav,
        "total_duration_seconds": round(total_sec, 2),
        "samples": all_samples,
    }

    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest_data, indent=2), encoding="utf-8")
    return manifest_data


def verify_samples_vault(
    manifest_path: Path = DEFAULT_MANIFEST_PATH,
    root_dir: Optional[Path] = None,
) -> bool:
    """Verify all samples in manifest exist on disk and match SHA-256."""
    if not manifest_path.is_file():
        return False
    data = json.loads(manifest_path.read_text(encoding="utf-8"))
    samples = data.get("samples", [])
    if len(samples) != 155:
        return False

    base = root_dir if root_dir else Path.cwd()
    for s in samples:
        sp = base / s["path"]
        if not sp.is_file():
            return False
        if sp.stat().st_size != s["wav_size_bytes"]:
            return False
        actual_hash = hashlib.sha256(sp.read_bytes()).hexdigest()
        if actual_hash != s["sha256"]:
            return False
    return True


def format_stats_report(data: Dict[str, Any]) -> str:
    """Format human-readable summary of the audio samples vault."""
    lines = [
        f"=== Dupery FMOD Audio Samples Vault Summary ===",
        f"Total Samples: {data['total_samples']} across {data['total_banks']} banks",
        f"Total PCM Size: {data['total_pcm_bytes'] / (1024 * 1024):.2f} MB",
        f"Total WAV Size: {data['total_wav_bytes'] / (1024 * 1024):.2f} MB",
        f"Total Duration: {data['total_duration_seconds']:.1f} s ({data['total_duration_seconds'] / 60:.1f} min)",
        f"--- Bank Breakdown ---",
    ]
    for b, count in data.get("bank_breakdown", {}).items():
        lines.append(f"  - {b}: {count} samples")
    return "\n".join(lines)


def main() -> int:
    """CLI Entry point for FMOD samples vault extraction and verification."""
    parser = argparse.ArgumentParser(description="Dupery FMOD Audio Samples Vault Tool")
    parser.add_argument("--extract", action="store_true", help="Extract all samples to WAV and create manifest")
    parser.add_argument("--verify", action="store_true", help="Verify integrity of extracted WAVs against manifest")
    parser.add_argument("--stats", action="store_true", help="Print summary statistics of the audio vault")
    args = parser.parse_args()

    if args.extract or (not args.verify and not args.stats):
        print("Extracting FMOD samples to vault...")
        manifest = build_samples_vault()
        print(f"Extraction complete! Cataloged {manifest['total_samples']} samples.")
        print(format_stats_report(manifest))
        return 0

    if args.verify:
        ok = verify_samples_vault()
        if ok:
            print("VERIFY PASS: All 155 samples exist, sizes match, and SHA-256 hashes are verified.")
            return 0
        print("VERIFY FAIL: Missing or corrupted audio samples detected.")
        return 1

    if args.stats:
        if not DEFAULT_MANIFEST_PATH.is_file():
            print(f"Manifest not found: {DEFAULT_MANIFEST_PATH}")
            return 1
        data = json.loads(DEFAULT_MANIFEST_PATH.read_text(encoding="utf-8"))
        print(format_stats_report(data))
        return 0

    return 0


if __name__ == "__main__":
    sys.exit(main())
