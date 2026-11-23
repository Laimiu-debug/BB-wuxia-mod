#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
v0.8.8 Brush Visual Overhaul:
1. Aligns modular Wuxia character busts (`wx_busts_0.brush`) to Vanilla Battle Brothers proportions:
   - Body/armor/back/upgrade layers: 1.09x anchored at waist (worldY=-18) on 128x164 (o=(0,35))
   - Head/hair/beard/scar/hat_back/hat_front: uniform 1.21x anchored at neck (worldX=+1, worldY=+21)
     so head width (~50px) and crown/helmet height (~87..92px) match Vanilla 1:1 with zero layer drift.
2. Fixes Shield & Weapon handedness (`wx_weapons_0.brush`):
   - Shields & offhand tools (`shd_*`) mirrored to RIGHT / FRONT (`worldX=[+4..+54]`, matching Vanilla `shield_round_01`).
   - Melee & throwing weapons (`arm_*`) mirrored to LEFT (`worldX=[-54..+2]`, matching Vanilla right-hand carry with zero shield overlap).
   - Aimed ranged weapons (`bow`/`xbow`/`gun`) kept on RIGHT aiming forward-right toward the enemy.
   - Paired fist gauntlets centered cleanly across the chest.
3. Fixes 6 backwards (left-facing) enemy/beast/boss sprites in `wx_beasts_0.brush` + `wx_corpses_0.brush`
   so 100% of `wx_beasts_0.brush` natively faces 3/4-right (facing LEFT toward player when `!isAlliedWithPlayer()`),
   and gently boosts undersized `<104px` enemy/beast busts to match the new Vanilla-aligned player height.
4. Re-applies zero-VRAM `_injured` aliases cleanly and keeps all atlases strictly 32-bit RGBA.
"""

import io
import os
import struct
import sys
from pathlib import Path
from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))

from compile_wuxia_brushes import (
    BRUSH_MAGIC,
    make_fallen_corpse_layer,
    shelf_pack_sprites,
    write_brush_binary,
)
from add_injured_brush_aliases import main as add_injured_aliases

MOD_DIR = ROOT / "mod_wuxia"
BRUSH_DIR = MOD_DIR / "brushes"
GFX_DIR = MOD_DIR / "gfx"

NEW_W, NEW_H = 128, 164
OX, OY = 0, 35

AIMED_RANGED_ARMS = {
    "arm_wx_beast_bow", "arm_wx_wpn_bow_01", "arm_wx_wpn_bow_02", "arm_wx_wpn_bow_03",
    "arm_wx_wpn_xbow_01", "arm_wx_wpn_xbow_02", "arm_wx_wpn_xbow_03",
    "arm_wx_wpn_gun_01", "arm_wx_wpn_gun_02",
    "arm_wx_famed_54", "arm_wx_famed_55", "arm_wx_famed_56", "arm_wx_famed_57", "arm_wx_famed_58",
    "arm_wx_relic_gudiaonu", "arm_wx_relic_huodouchong", "arm_wx_relic_shenbinu",
    "arm_wx_relic_xunleichong", "arm_wx_relic_yingzhaogong", "arm_wx_relic_zhentiangong",
}
FIST_KEYWORDS = ("fist", "qiongqizhao", "longlinzhao", "jingangwan", "luwuzhao")

BACKWARDS_BEAST_IDS = {
    "wx_enemy_emei_sword",
    "wx_char_enemy_yaoren",
    "wx_enemy_wudu_shaman",
    "wx_beast_jiuwei_wild",
    "wx_boss_boshi",
    "wx_boss_zaochi",
}


def load_brush_records(brush_path: Path):
    data = brush_path.read_bytes()
    magic, ver, gl = struct.unpack_from("<IHH", data, 0)
    assert magic == BRUSH_MAGIC, f"Invalid brush magic in {brush_path}"
    gfx_rel = data[8 : 8 + gl].decode("ascii").replace("\\", "/")
    pos = 8 + gl
    aw, ah = struct.unpack_from("<HH", data, pos)
    pos += 16
    cnt, _, _ = struct.unpack_from("<IHI", data, pos)
    pos += 10

    atlas = Image.open(MOD_DIR / gfx_rel).convert("RGBA")
    recs = []
    for _ in range(cnt):
        _, sl = struct.unpack_from("<QH", data, pos)
        pos += 10
        sid = data[pos : pos + sl].decode("ascii")
        pos += sl
        _, w, h, ox, oy = struct.unpack_from("<QIIhh", data, pos)
        pos += 20 + 25 + 4 + 4
        fc, = struct.unpack_from("<H", data, pos)
        pos += 2
        assert fc == 1, f"Expected single frame for {sid}"
        srcl, = struct.unpack_from("<H", data, pos)
        pos += 2
        src_rel = data[pos : pos + srcl].decode("ascii")
        pos += srcl
        u0, u1, v0, v1, fL, fR, fT, fB = struct.unpack_from("<8f", data, pos)
        pos += 35

        ax0, ax1 = int(round(u0 * aw)), int(round(u1 * aw))
        ay0, ay1 = int(round(v0 * ah)), int(round(v1 * ah))
        crop = ImageOps.flip(atlas.crop((ax0, ay0, ax1, ay1)))
        canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        bx0 = int(round(w / 2.0 + fL))
        by0 = int(round(h / 2.0 - fB))
        canvas.paste(crop, (max(0, bx0), max(0, by0)))
        recs.append({
            "id": sid,
            "w": w,
            "h": h,
            "ox": ox,
            "oy": oy,
            "src_rel": src_rel,
            "img": canvas,
            "vis_h": fB - fT,
            "y_bot": fT + oy,
        })
    return gfx_rel, recs


def clean_zero_alpha_rgba(im: Image.Image) -> Image.Image:
    rgba = im.convert("RGBA")
    r, g, b, a = rgba.split()
    nz = a.point(lambda v: 255 if v > 0 else 0)
    zero = Image.new("L", rgba.size, 0)
    return Image.merge("RGBA", (Image.composite(r, zero, nz), Image.composite(g, zero, nz), Image.composite(b, zero, nz), a))


def transform_layer(
    src: Image.Image,
    scale: float,
    pivot_wx: float,
    pivot_wy: float,
    shift_wx: float = 0.0,
    shift_wy: float = 0.0,
    mirror_h: bool = False,
    out_w: int = NEW_W,
    out_h: int = NEW_H,
    oy: int = OY,
) -> Image.Image:
    im = ImageOps.mirror(src) if mirror_h else src
    ow, oh = im.size
    sw = max(1, int(round(ow * scale)))
    sh = max(1, int(round(oh * scale)))
    rs = im.resize((sw, sh), Image.Resampling.LANCZOS)

    px_old = pivot_wx + ow / 2.0
    py_old = oh / 2.0 + oy - pivot_wy

    px_scaled = px_old * scale
    py_scaled = py_old * scale

    px_new = (pivot_wx + shift_wx) + out_w / 2.0
    py_new = out_h / 2.0 + oy - (pivot_wy + shift_wy)

    paste_x = int(round(px_new - px_scaled))
    paste_y = int(round(py_new - py_scaled))

    out = Image.new("RGBA", (out_w, out_h), (0, 0, 0, 0))
    sx0 = max(0, -paste_x)
    sy0 = max(0, -paste_y)
    dx0 = max(0, paste_x)
    dy0 = max(0, paste_y)
    cw = min(sw - sx0, out_w - dx0)
    ch = min(sh - sy0, out_h - dy0)
    if cw > 0 and ch > 0:
        out.alpha_composite(rs.crop((sx0, sy0, sx0 + cw, sy0 + ch)), (dx0, dy0))
    return out


def is_head_group(sid: str) -> bool:
    return sid.startswith((
        "wx_head_", "wx_hair_", "wx_beard_", "wx_scar_",
        "wx_hat_", "wx_helm_", "wx_char_hat_", "wx_beast_helm_",
    ))


def rebuild_busts():
    bp = BRUSH_DIR / "wx_busts_0.brush"
    gfx_rel, recs = load_brush_records(bp)
    base_recs = [r for r in recs if not r["id"].endswith("_injured")]
    if base_recs and base_recs[0]["w"] == NEW_W and base_recs[0]["h"] == NEW_H:
        print(f"[SKIP] wx_busts_0.brush already upgraded to {NEW_W}x{NEW_H}.")
        return

    entries = []
    head_cnt = body_cnt = 0
    for r in base_recs:
        sid = r["id"]
        if is_head_group(sid):
            out_im = transform_layer(r["img"], scale=1.21, pivot_wx=1.0, pivot_wy=21.0, shift_wx=2.0, shift_wy=1.0, mirror_h=False)
            head_cnt += 1
        else:
            out_im = transform_layer(r["img"], scale=1.09, pivot_wx=0.0, pivot_wy=-18.0, shift_wx=0.0, shift_wy=-1.0, mirror_h=False)
            body_cnt += 1
        entries.append({
            "id": sid,
            "img": out_im,
            "ox": OX,
            "oy": OY,
            "src_rel": r["src_rel"],
            "is_effect": False,
        })

    atlas, packed = shelf_pack_sprites(entries, max_atlas_w=2048)
    atlas = clean_zero_alpha_rgba(atlas)
    atlas.save(MOD_DIR / gfx_rel, optimize=True, compress_level=9)
    write_brush_binary(str(bp), gfx_rel, atlas.size, packed, is_effect_sheet=False)
    print(f"[OK] Rebuilt wx_busts_0.brush: {len(packed)} base sprites (head={head_cnt}, body={body_cnt}), atlas={atlas.size}")


def rebuild_weapons():
    bp = BRUSH_DIR / "wx_weapons_0.brush"
    gfx_rel, recs = load_brush_records(bp)
    base_recs = [r for r in recs if not r["id"].endswith("_injured")]
    if base_recs and base_recs[0]["w"] == NEW_W and base_recs[0]["h"] == NEW_H:
        print(f"[SKIP] wx_weapons_0.brush already upgraded to {NEW_W}x{NEW_H}.")
        return

    entries = []
    c_shd = c_rng = c_fist = c_melee = 0
    for r in base_recs:
        sid = r["id"]
        if sid.startswith("shd_"):
            out_im = transform_layer(r["img"], scale=1.08, pivot_wx=0.0, pivot_wy=-18.0, shift_wx=6.0, shift_wy=1.0, mirror_h=True)
            c_shd += 1
        elif sid in AIMED_RANGED_ARMS:
            out_im = transform_layer(r["img"], scale=1.08, pivot_wx=0.0, pivot_wy=-18.0, shift_wx=3.0, shift_wy=2.0, mirror_h=False)
            c_rng += 1
        elif any(k in sid for k in FIST_KEYWORDS):
            out_im = transform_layer(r["img"], scale=1.10, pivot_wx=0.0, pivot_wy=-18.0, shift_wx=-6.0, shift_wy=0.0, mirror_h=False)
            c_fist += 1
        else:
            out_im = transform_layer(r["img"], scale=1.08, pivot_wx=0.0, pivot_wy=-18.0, shift_wx=2.0, shift_wy=2.0, mirror_h=True)
            c_melee += 1
        entries.append({
            "id": sid,
            "img": out_im,
            "ox": OX,
            "oy": OY,
            "src_rel": r["src_rel"],
            "is_effect": False,
        })

    atlas, packed = shelf_pack_sprites(entries, max_atlas_w=2048)
    atlas = clean_zero_alpha_rgba(atlas)
    atlas.save(MOD_DIR / gfx_rel, optimize=True, compress_level=9)
    write_brush_binary(str(bp), gfx_rel, atlas.size, packed, is_effect_sheet=False)
    print(f"[OK] Rebuilt wx_weapons_0.brush: {len(packed)} sprites (shd={c_shd}, melee/throw={c_melee}, aimed_ranged={c_rng}, fist={c_fist}), atlas={atlas.size}")


def rebuild_beasts_and_corpses():
    bp = BRUSH_DIR / "wx_beasts_0.brush"
    gfx_rel, recs = load_brush_records(bp)
    base_recs = [r for r in recs if not r["id"].endswith("_injured")]

    # Idempotency check: check if wx_enemy_emei_sword is already canvas 128x164
    probe = next((r for r in base_recs if r["id"] == "wx_enemy_emei_sword"), None)
    if probe and probe["w"] == NEW_W and probe["h"] == NEW_H:
        print(f"[SKIP] wx_beasts_0.brush already updated for v0.8.8.")
        return

    flipped_imgs_for_corpses = {}
    entries = []
    c_flip = c_boost = 0
    for r in base_recs:
        sid = r["id"]
        im = r["img"]
        w, h, ox, oy = r["w"], r["h"], r["ox"], r["oy"]
        do_flip = sid in BACKWARDS_BEAST_IDS
        if do_flip:
            im = ImageOps.mirror(im)
            c_flip += 1

        # Gently scale undersized non-boss humanoid/beast busts (`w==104, h==142`) to match upgraded 128x164 player height!
        if not sid.startswith(("wx_boss_", "wx_tail_")) and w == 104 and h == 142:
            scale = 1.12 if r["vis_h"] < 104 else 1.06
            im = transform_layer(im, scale=scale, pivot_wx=0.0, pivot_wy=r["y_bot"], shift_wx=0.0, shift_wy=0.0, mirror_h=False, out_w=NEW_W, out_h=NEW_H, oy=oy)
            c_boost += 1
        elif do_flip:
            # Keep boss 156x156 canvas exact, just flipped cleanly!
            pass

        if do_flip:
            flipped_imgs_for_corpses[sid] = im

        entries.append({
            "id": sid,
            "img": im,
            "ox": ox,
            "oy": oy,
            "src_rel": r["src_rel"],
            "is_effect": False,
        })

    atlas, packed = shelf_pack_sprites(entries, max_atlas_w=2048)
    atlas = clean_zero_alpha_rgba(atlas)
    atlas.save(MOD_DIR / gfx_rel, optimize=True, compress_level=9)
    write_brush_binary(str(bp), gfx_rel, atlas.size, packed, is_effect_sheet=False)
    print(f"[OK] Rebuilt wx_beasts_0.brush: {len(packed)} base sprites (flipped={c_flip}, scale_aligned={c_boost}), atlas={atlas.size}")

    # Update the 6 flipped enemies'/beasts'/bosses' fallen corpse decals in wx_corpses_0.brush
    cp = BRUSH_DIR / "wx_corpses_0.brush"
    if cp.exists() and flipped_imgs_for_corpses:
        c_gfx_rel, c_recs = load_brush_records(cp)
        updated_corpses = 0
        c_entries = []
        for idx, cr in enumerate(c_recs):
            cid = cr["id"]
            base_id = cid[:-5] if cid.endswith("_dead") else ""
            if base_id in flipped_imgs_for_corpses:
                new_im = make_fallen_corpse_layer(flipped_imgs_for_corpses[base_id], is_body_base=True, seed_val=idx + 500)
                updated_corpses += 1
            else:
                new_im = cr["img"]
            c_entries.append({
                "id": cid,
                "img": new_im,
                "ox": cr["ox"],
                "oy": cr["oy"],
                "src_rel": cr["src_rel"],
                "is_effect": False,
            })
        c_atlas, c_packed = shelf_pack_sprites(c_entries, max_atlas_w=2048)
        c_atlas = clean_zero_alpha_rgba(c_atlas)
        c_atlas.save(MOD_DIR / c_gfx_rel, optimize=True, compress_level=9)
        write_brush_binary(str(cp), c_gfx_rel, c_atlas.size, c_packed, is_effect_sheet=False)
        print(f"[OK] Updated wx_corpses_0.brush: {updated_corpses} flipped corpses refreshed, total={len(c_packed)}, atlas={c_atlas.size}")


def main():
    rebuild_busts()
    rebuild_weapons()
    rebuild_beasts_and_corpses()
    # Re-add zero-VRAM _injured aliases to all three brushes!
    add_injured_aliases()


if __name__ == "__main__":
    main()
