"""Extractor and vault manifest builder for Dupery Sprites, Textures, and Fonts.

Extracts atlas-cropped Sprites (with rect, pivot, border Nine-Slice, pixelsPerUnit),
multilingual TTF/OTF Font binaries, and Texture2D assets into cryptographic SHA-256
manifest dupery_vault_manifest.json with single-command raw extraction capability.
"""

from __future__ import annotations

import argparse
import hashlib
import io
import json
import os
import sys
import time
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

DEFAULT_DUPERY_DATA = Path(r"D:\Minh\Steam\steamapps\common\Dupery\Dupery_Data")
DEFAULT_VAULT_DIR = Path("docs/agent-system/evidence/dupery/vault")
DEFAULT_MANIFEST = DEFAULT_VAULT_DIR / "dupery_vault_manifest.json"


def is_valid_asset_file(name: str) -> bool:
    """Filter valid asset files, excluding resource streams."""
    if name.endswith(".resS") or name.endswith(".resource"):
        return False
    return name.endswith(".assets") or name.startswith("level")


def compute_bytes_sha256(data: bytes) -> str:
    """Compute hex SHA-256 digest of arbitrary bytes."""
    h = hashlib.sha256()
    h.update(data)
    return h.hexdigest()


def get_image_png_bytes(img: Any) -> bytes:
    """Serialize PIL Image to PNG format bytes in-memory."""
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return buf.getvalue()


def scan_dupery_vault(
    dupery_data: Path = DEFAULT_DUPERY_DATA,
    extract_dir: Optional[Path] = None,
) -> Dict[str, Any]:
    """Scan all assets, compute cryptographic hashes, and optionally dump binaries."""
    import UnityPy

    valid_files = sorted([f for f in os.listdir(dupery_data) if is_valid_asset_file(f)])

    sprites_list: List[Dict[str, Any]] = []
    fonts_list: List[Dict[str, Any]] = []
    textures_list: List[Dict[str, Any]] = []

    if extract_dir:
        (extract_dir / "sprites").mkdir(parents=True, exist_ok=True)
        (extract_dir / "fonts").mkdir(parents=True, exist_ok=True)
        (extract_dir / "textures").mkdir(parents=True, exist_ok=True)

    for fname in valid_files:
        fpath = dupery_data / fname
        env = UnityPy.load(str(fpath))

        for obj in env.objects:
            tname = obj.type.name
            if tname == "Sprite":
                try:
                    sp = obj.read()
                    img = sp.image
                    png_bytes = get_image_png_bytes(img)
                    sha256_hash = compute_bytes_sha256(png_bytes)

                    name = sp.m_Name or f"Sprite_{obj.path_id}"
                    rect = {
                        "x": round(sp.m_Rect.x, 2),
                        "y": round(sp.m_Rect.y, 2),
                        "width": round(sp.m_Rect.width, 2),
                        "height": round(sp.m_Rect.height, 2),
                    }
                    pivot = {"x": round(sp.m_Pivot.x, 3), "y": round(sp.m_Pivot.y, 3)}
                    border = {
                        "left": round(sp.m_Border.x, 2),
                        "bottom": round(sp.m_Border.y, 2),
                        "right": round(sp.m_Border.z, 2),
                        "top": round(sp.m_Border.w, 2),
                    }
                    ppu = getattr(sp, "m_PixelsToUnits", 100.0)

                    sprite_entry = {
                        "name": name,
                        "asset_file": fname,
                        "path_id": obj.path_id,
                        "rect": rect,
                        "pivot": pivot,
                        "border": border,
                        "pixels_per_unit": round(ppu, 2),
                        "size": [img.size[0], img.size[1]],
                        "sha256": sha256_hash,
                    }
                    sprites_list.append(sprite_entry)

                    if extract_dir:
                        out_png = extract_dir / "sprites" / f"{fname}_{obj.path_id}_{name}.png"
                        out_png.write_bytes(png_bytes)
                except Exception:
                    pass

            elif tname == "Font":
                try:
                    f = obj.read()
                    name = f.m_Name or f"Font_{obj.path_id}"
                    raw_data = getattr(f, "m_FontData", None)
                    fdata = bytes(raw_data) if raw_data else b""
                    f_hash = compute_bytes_sha256(fdata) if fdata else ""
                    ext = ".otf" if fdata[:4] == b"OTTO" else ".ttf"

                    font_entry = {
                        "name": name,
                        "asset_file": fname,
                        "path_id": obj.path_id,
                        "size_bytes": len(fdata),
                        "extension": ext,
                        "sha256": f_hash,
                    }
                    fonts_list.append(font_entry)

                    if extract_dir and fdata:
                        out_font = extract_dir / "fonts" / f"{name}{ext}"
                        out_font.write_bytes(fdata)
                except Exception:
                    pass

            elif tname == "Texture2D":
                try:
                    tex = obj.read()
                    name = tex.m_Name or f"Texture_{obj.path_id}"
                    tex_entry = {
                        "name": name,
                        "asset_file": fname,
                        "path_id": obj.path_id,
                        "width": getattr(tex, "m_Width", 0),
                        "height": getattr(tex, "m_Height", 0),
                        "format": str(getattr(tex, "m_TextureFormat", "Unknown")),
                    }
                    textures_list.append(tex_entry)
                except Exception:
                    pass

    return {
        "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "total_sprites": len(sprites_list),
        "total_fonts": len(fonts_list),
        "total_textures": len(textures_list),
        "sprites": sprites_list,
        "fonts": fonts_list,
        "textures": textures_list,
    }


def build_and_save_manifest(
    dupery_data: Path = DEFAULT_DUPERY_DATA,
    manifest_path: Path = DEFAULT_MANIFEST,
    extract_dir: Optional[Path] = None,
) -> Dict[str, Any]:
    """Execute vault scan and persist JSON manifest."""
    t0 = time.time()
    manifest = scan_dupery_vault(dupery_data, extract_dir)
    manifest["duration_sec"] = round(time.time() - t0, 3)

    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)

    return manifest


def verify_dupery_vault(manifest_path: Path = DEFAULT_MANIFEST) -> bool:
    """Verify vault manifest consistency and exact counts."""
    if not manifest_path.exists():
        return False

    with open(manifest_path, "r", encoding="utf-8") as f:
        manifest = json.load(f)

    if manifest.get("total_sprites") != 879:
        return False
    if manifest.get("total_fonts") != 10:
        return False
    if manifest.get("total_textures") != 752:
        return False

    if len(manifest.get("sprites", [])) != 879:
        return False
    if len(manifest.get("fonts", [])) != 10:
        return False
    if len(manifest.get("textures", [])) != 752:
        return False

    for sp in manifest["sprites"][:20]:
        if "rect" not in sp or "border" not in sp or "sha256" not in sp:
            return False

    return True


def main() -> int:
    """CLI endpoint for Dupery asset vault operations."""
    parser = argparse.ArgumentParser(description="Dupery Asset Vault Extractor")
    parser.add_argument("--verify", action="store_true", help="Verify vault manifest integrity")
    parser.add_argument("--stats", action="store_true", help="Print summary statistics")
    parser.add_argument("--extract-all", action="store_true", help="Dump raw binary images and fonts")
    parser.add_argument("--vault-dir", type=str, default="", help="Custom output directory for raw files")
    args = parser.parse_args()

    if args.verify:
        ok = verify_dupery_vault()
        status = "PASSED" if ok else "FAILED"
        print(f"Dupery Vault Verification: {status}")
        return 0 if ok else 1

    extract_path: Optional[Path] = None
    if args.extract_all or args.vault_dir:
        extract_path = Path(args.vault_dir) if args.vault_dir else (DEFAULT_VAULT_DIR / "raw")

    manifest = build_and_save_manifest(extract_dir=extract_path)

    if args.stats:
        summary = {
            "generated_at": manifest["generated_at"],
            "duration_sec": manifest.get("duration_sec", 0.0),
            "total_sprites": manifest["total_sprites"],
            "total_fonts": manifest["total_fonts"],
            "total_textures": manifest["total_textures"],
        }
        print(json.dumps(summary, indent=2))
    else:
        print(f"Vault manifest generated ({manifest['total_sprites']} sprites, {manifest['total_fonts']} fonts, {manifest['total_textures']} textures) in {manifest.get('duration_sec', 0.0)}s.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
