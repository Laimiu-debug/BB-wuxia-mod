#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generates pixel-exact horizontally mirrored (`_L`) OpenGL brush sheets for all
directional Wuxia kinetic sequences (23 sequences = 232 frames) and directional
legacy Qi-aura / signature VFX sprites (`wx_vfx_01..32`, `wx_fx_*`).

Why: Battle Brothers' `Tactical.spawnParticleEffect(_flipX, ...)` does not
reliably flip particle quads horizontally; shipping pre-mirrored `_L` frames in
dedicated `<= 2048x2048` sheets guarantees identical, crisp left/right symmetry
when enemies cast Wuxia skills from right-to-left.
"""

import glob
import os
import re
import struct
import sys
from PIL import Image, ImageOps

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

import compile_wuxia_brushes as cwb

ROOT = os.path.dirname(SCRIPT_DIR)
MOD_ROOT = os.path.join(ROOT, "mod_wuxia")

DIRECTIONAL_KINETIC_SEQS = [
    "wx_kin_sword_slash",
    "wx_kin_dragon_surge",
    "wx_kin_flame_cleave",
    "wx_kin_celestial_beam",
    "wx_kin_blood_arc",
    "wx_kin_spear_drill",
    "wx_kin_whirl_cyclone",
    "wx_kin_claw_rend",
    "wx_kin_whip_lash",
    "wx_kin_shadow_cross",
    "wx_kin_arrow_barrage",
    "wx_kin_qinggong_gust",
    "wx_kin_soul_vortex",
    "wx_kin_fist_flurry",
    "wx_kin_giant_axe",
    "wx_kin_phoenix_spear",
    "wx_kin_bamboo_bind",
    "wx_kin_flying_knives",
    "wx_kin_peacock_fan",
    "wx_kin_tidal_wave",
    "wx_kin_snow_step",
    "wx_kin_sword_rain",
    "wx_kin_moon_crescent",
]

DIRECTIONAL_LEGACY_PREFIXES = ("wx_vfx_",)
DIRECTIONAL_LEGACY_EXACT = {
    "wx_fx_claw_slash",
    "wx_fx_dragon_head",
    "wx_fx_sword_phantom",
    "wx_fx_whip_arc",
    "wx_fx_gold_needle",
}


def read_brush_records(brush_path):
    """Parses a Battle Brothers v17 `.brush` binary written by `compile_wuxia_brushes.py`."""
    with open(brush_path, "rb") as f:
        data = f.read()

    pos = 0
    magic, ver, gfx_len = struct.unpack_from("<IHH", data, pos)
    pos += 8
    assert magic == cwb.BRUSH_MAGIC, f"Invalid brush magic in {brush_path}: {hex(magic)}"
    gfx_rel = data[pos:pos + gfx_len].decode("ascii")
    pos += gfx_len

    aw, ah = struct.unpack_from("<HH", data, pos)
    pos += 4
    pos += 12  # flag12
    count, _zero, _scale = struct.unpack_from("<IHI", data, pos)
    pos += 10

    records = []
    for _ in range(count):
        _hash, sid_len = struct.unpack_from("<QH", data, pos)
        pos += 10
        sid = data[pos:pos + sid_len].decode("ascii")
        pos += sid_len
        _cat, w, h, ox, oy = struct.unpack_from("<QIIhh", data, pos)
        pos += 20
        pos += 25  # mid_prefix25
        avg_rgba = struct.unpack_from("<BBBB", data, pos)
        pos += 4
        pos += 4   # mid_scale4
        n_frames, src_len = struct.unpack_from("<HH", data, pos)
        pos += 4
        assert n_frames == 1, f"Expected 1 frame for {sid}, got {n_frames}"
        src_rel = data[pos:pos + src_len].decode("ascii")
        pos += src_len
        uv_quad = struct.unpack_from("<8f", data, pos)
        pos += 32
        pos += 3   # trailing 3 zero bytes
        records.append({
            "id": sid,
            "w": w,
            "h": h,
            "ox": ox,
            "oy": oy,
            "avg_rgba": avg_rgba,
            "src_rel": src_rel,
            "uv_quad": uv_quad,
        })

    return gfx_rel, (aw, ah), records


def extract_mirrored_entry(atlas_im, atlas_size, rec, new_id):
    aw, ah = atlas_size
    u0, u1, v0, v1, fL, fR, fT, fB = rec["uv_quad"]
    ax0 = int(round(u0 * aw))
    ax1 = int(round(u1 * aw))
    ay0 = int(round(v0 * ah))
    ay1 = int(round(v1 * ah))
    cw = max(1, ax1 - ax0)
    ch = max(1, ay1 - ay0)

    # Undo OpenGL vertical atlas flip to recover upright trimmed sprite
    crop_upright = ImageOps.flip(atlas_im.crop((ax0, ay0, ax0 + cw, ay0 + ch)))

    w, h = rec["w"], rec["h"]
    half_w = w / 2.0
    half_h = h / 2.0
    bx0 = int(round(fL + half_w))
    by0 = int(round(half_h - fB))
    bx0 = max(0, min(w - cw, bx0))
    by0 = max(0, min(h - ch, by0))

    canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    canvas.paste(crop_upright, (bx0, by0))
    mirrored = ImageOps.mirror(canvas)

    return {
        "id": new_id,
        "img": mirrored,
        "ox": -rec["ox"],
        "oy": rec["oy"],
        "src_rel": f"effects\\{new_id}.png",
        "is_effect": True,
    }


def _should_mirror_kinetic(sid):
    m = re.match(r"^(wx_kin_[a-z0-9_]+)_(\d{2})$", sid)
    if not m:
        return None
    seq, idx = m.group(1), m.group(2)
    if seq in DIRECTIONAL_KINETIC_SEQS:
        return f"{seq}_L_{idx}"
    return None


def _should_mirror_legacy(sid):
    if sid.endswith("_L"):
        return None
    if sid in DIRECTIONAL_LEGACY_EXACT:
        return f"{sid}_L"
    if any(sid.startswith(p) for p in DIRECTIONAL_LEGACY_PREFIXES):
        return f"{sid}_L"
    return None


def pack_into_pages(entries, start_page_idx=7, max_dim=2048, pad=2):
    """Packs mirrored entries into as few `<= 2048x2048` brush sheets as possible."""
    # Clean any previous mirrored pages >= start_page_idx
    for idx in range(start_page_idx, 16):
        for rel in (f"brushes/wx_kinetic_{idx}.brush", f"gfx/wx_kinetic_{idx}.png"):
            p = os.path.join(MOD_ROOT, rel)
            if os.path.exists(p):
                os.remove(p)

    # Pre-measure trimmed height/width to partition cleanly into pages <= 2048x2048
    measured = []
    for ent in entries:
        im = ent["img"]
        bbox = im.getchannel("A").point(lambda a: 255 if a > 4 else 0).getbbox()
        if bbox:
            cw, ch = bbox[2] - bbox[0], bbox[3] - bbox[1]
        else:
            cw, ch = 4, 4
        measured.append((ch, cw, ent))
    measured.sort(key=lambda x: (-x[0], x[2]["id"]))

    pages = []
    cur_batch = []
    cx, cy, row_h = pad, pad, 0
    for ch, cw, ent in measured:
        if cx + cw + pad > max_dim:
            cx = pad
            cy += row_h + pad
            row_h = 0
        if cy + ch + pad > max_dim and cur_batch:
            pages.append(cur_batch)
            cur_batch = []
            cx, cy, row_h = pad, pad, 0
        cur_batch.append(ent)
        cx += cw + pad
        if ch > row_h:
            row_h = ch
    if cur_batch:
        pages.append(cur_batch)

    written_pages = []
    for offset, batch in enumerate(pages):
        page_idx = start_page_idx + offset
        at, rc = cwb.shelf_pack_sprites(batch, max_atlas_w=max_dim, pad=pad)
        assert at.size[0] <= max_dim and at.size[1] <= max_dim, (
            f"Mirrored page wx_kinetic_{page_idx} exceeded {max_dim}: {at.size}"
        )
        gfx_rel = f"gfx/wx_kinetic_{page_idx}.png"
        brush_rel = f"brushes/wx_kinetic_{page_idx}.brush"
        at.save(os.path.join(MOD_ROOT, gfx_rel))
        cwb.write_brush_binary(
            os.path.join(MOD_ROOT, brush_rel), gfx_rel, at.size, rc, is_effect_sheet=True
        )
        print(f"Compiled {brush_rel}: {len(rc)} mirrored sprites ({at.size[0]}x{at.size[1]})")
        written_pages.append((page_idx, gfx_rel, len(rc), at.size))

    return written_pages


def build_mirrored_pages():
    entries = []
    seen_ids = set()

    # 1. Mirror all 23 directional kinetic sequences from wx_kinetic_0..6
    for idx in range(7):
        bpath = os.path.join(MOD_ROOT, "brushes", f"wx_kinetic_{idx}.brush")
        if not os.path.exists(bpath):
            continue
        gfx_rel, atlas_size, recs = read_brush_records(bpath)
        atlas_im = Image.open(os.path.join(MOD_ROOT, gfx_rel)).convert("RGBA")
        for rec in recs:
            new_id = _should_mirror_kinetic(rec["id"])
            if new_id and new_id not in seen_ids:
                entries.append(extract_mirrored_entry(atlas_im, atlas_size, rec, new_id))
                seen_ids.add(new_id)

    # 2. Mirror wx_vfx_01..32 and directional wx_fx_* from wx_effects_0..5
    for idx in range(6):
        bpath = os.path.join(MOD_ROOT, "brushes", f"wx_effects_{idx}.brush")
        if not os.path.exists(bpath):
            continue
        gfx_rel, atlas_size, recs = read_brush_records(bpath)
        atlas_im = Image.open(os.path.join(MOD_ROOT, gfx_rel)).convert("RGBA")
        for rec in recs:
            new_id = _should_mirror_legacy(rec["id"])
            if new_id and new_id not in seen_ids:
                entries.append(extract_mirrored_entry(atlas_im, atlas_size, rec, new_id))
                seen_ids.add(new_id)

    pages = pack_into_pages(entries, start_page_idx=7, max_dim=2048, pad=2)
    print(f"TOTAL MIRRORED (_L) VFX SPRITES COMPILED: {len(entries)} across {len(pages)} sheet(s).")
    return pages


if __name__ == "__main__":
    build_mirrored_pages()
