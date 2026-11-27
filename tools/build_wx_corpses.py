#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Rebuilds all fallen tactical corpse decals (`wx_corpses_*.brush` + `gfx/wx_corpses_*.png`)
directly from the live overhauled `128x164` modular character paperdolls (`wx_busts_0.brush`)
and full-resolution enemies/beasts/bosses (`wx_beasts_0.brush`) at true 1:1 Battle Brothers
scale (matching vanilla `entity_5/6/7.brush` corpses — no 0.86x downscale, no 0.80x pancake
squash, and no crushing 156x156 Shan Hai bosses into 104x142).
"""

import os
import sys
from PIL import Image, ImageEnhance, ImageFilter, ImageOps

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

import compile_wuxia_brushes as cwb
import build_wx_mirrored_vfx as mirror_io

ROOT = os.path.dirname(SCRIPT_DIR)
MOD_ROOT = os.path.join(ROOT, "mod_wuxia")

MODULAR_BODY_PREFIXES = (
    "wx_body_",
    "wx_char_cloth",
    "wx_char_robe",
    "wx_char_armor",
    "wx_char_raincape",
    "wx_armor_",
    "wx_beast_armor_",
)


def extract_all_upright(brush_path):
    gfx_rel, atlas_size, recs = mirror_io.read_brush_records(brush_path)
    atlas = Image.open(os.path.join(MOD_ROOT, gfx_rel)).convert("RGBA")
    aw, ah = atlas_size
    out = []
    for r in recs:
        sid = r["id"]
        if sid.endswith("_injured") or sid.endswith("_damaged"):
            continue
        u0, u1, v0, v1, fL, fR, fT, fB = r["uv_quad"]
        ax0, ax1 = int(round(u0 * aw)), int(round(u1 * aw))
        ay0, ay1 = int(round(v0 * ah)), int(round(v1 * ah))
        cw, ch = max(1, ax1 - ax0), max(1, ay1 - ay0)
        crop = ImageOps.flip(atlas.crop((ax0, ay0, ax0 + cw, ay0 + ch)))
        w, h = r["w"], r["h"]
        im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        bx0 = max(0, min(w - cw, int(round(fL + w / 2.0))))
        by0 = max(0, min(h - ch, int(round(h / 2.0 - fB))))
        im.paste(crop, (bx0, by0))
        out.append((sid, im, r["ox"], r["oy"]))
    return out


def make_heroic_corpse_layer(
    im_src: Image.Image,
    scale: float,
    angle_deg: float,
    y_squash: float,
    canvas_w: int,
    canvas_h: int,
    is_body_base: bool,
    seed_val: int,
) -> Image.Image:
    """
    Renders a pixel-registered fallen corpse layer on `(canvas_w, canvas_h)`:
    - Every modular layer (body, surcoat, hat_back, head, scar, beard, hair, hat_front)
      uses the EXACT same scale, pivot, rotation, and canvas offset so multi-layer
      character corpses align 100% identically to the living character.
    - Head points lower-left, broad armored torso fills center/upper-right, matching
      vanilla Battle Brothers corpse scale & orientation.
    """
    sw = max(1, int(round(im_src.width * scale)))
    sh = max(1, int(round(im_src.height * scale)))
    scaled = im_src.resize((sw, sh), Image.Resampling.LANCZOS)

    # Place onto a generous square working canvas centered on bust mid-torso
    work_dim = max(sw, sh, canvas_w, canvas_h) + 64
    work = Image.new("RGBA", (work_dim, work_dim), (0, 0, 0, 0))
    px = (work_dim - sw) // 2
    py = (work_dim - sh) // 2
    work.alpha_composite(scaled, (px, py))

    # Rotate around consistent anatomical torso-neck center so head lands lower-left and torso upper-right
    piv_x = work_dim * 0.5
    piv_y = work_dim * 0.5 + sh * 0.03
    rot = work.rotate(angle_deg, resample=Image.Resampling.BICUBIC, expand=False, center=(piv_x, piv_y))

    sq_h = max(1, int(round(work_dim * y_squash)))
    squashed = rot.resize((work_dim, sq_h), Image.Resampling.LANCZOS)

    layer = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))
    # Constant offset from squashed center to corpse canvas center (100% identical across all modular layers!)
    ox_paste = (canvas_w - work_dim) // 2 + 2
    oy_paste = (canvas_h - sq_h) // 2 + 4
    layer.alpha_composite(squashed, (ox_paste, oy_paste))

    # Crisp fallen lighting (0.90x brightness keeps character armor/face clearly recognizable!)
    rgb = ImageEnhance.Brightness(layer.convert("RGB")).enhance(0.90)
    a = layer.getchannel("A")
    layer = Image.merge("RGBA", (*rgb.split(), a))

    canvas = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))
    if is_body_base:
        # Soft grounded drop shadow beneath the fallen figure
        sh_a = a.point(lambda v: int(v * 0.56))
        sh_im = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))
        sh_im.paste((8, 6, 5, 255), (2, 5), sh_a)
        sh_im = sh_im.filter(ImageFilter.GaussianBlur(radius=3.0))
        canvas = Image.alpha_composite(canvas, sh_im)

        # Subtle dark-crimson battle wound stains on torso (upper-right region, keeping face clean)
        lpx = layer.load()
        cx1 = int(canvas_w * 0.54) + (seed_val % 11) - 5
        cy1 = int(canvas_h * 0.48) + ((seed_val // 7) % 9) - 4
        cx2 = int(canvas_w * 0.64) + ((seed_val // 3) % 9) - 4
        cy2 = int(canvas_h * 0.38) + ((seed_val // 13) % 9) - 4
        for y in range(canvas_h):
            for x in range(canvas_w):
                r, g, b, al = lpx[x, y]
                if al < 80:
                    continue
                d1 = ((x - cx1) ** 2) / 180.0 + ((y - cy1) ** 2) / 72.0
                d2 = ((x - cx2) ** 2) / 120.0 + ((y - cy2) ** 2) / 52.0
                stain = 0.0
                if d1 < 1.0:
                    stain = max(stain, (1.0 - d1) * 0.55)
                if d2 < 1.0:
                    stain = max(stain, (1.0 - d2) * 0.42)
                if stain > 0.02:
                    nr = int(r * (1.0 - stain) + 86 * stain)
                    ng = int(g * (1.0 - stain) + 12 * stain)
                    nb = int(b * (1.0 - stain) + 10 * stain)
                    lpx[x, y] = (nr, ng, nb, al)

    canvas.alpha_composite(layer, (0, 0))
    return canvas


def pack_corpse_pages(entries, max_dim=2048, pad=2):
    for idx in range(8):
        for rel in (f"brushes/wx_corpses_{idx}.brush", f"gfx/wx_corpses_{idx}.png"):
            p = os.path.join(MOD_ROOT, rel)
            if os.path.exists(p):
                os.remove(p)

    measured = []
    for ent in entries:
        im = ent["img"]
        bbox = im.getchannel("A").point(lambda a: 255 if a > 4 else 0).getbbox()
        cw, ch = (bbox[2] - bbox[0], bbox[3] - bbox[1]) if bbox else (4, 4)
        measured.append((ch, cw, ent))
    measured.sort(key=lambda x: (-x[0], x[2]["id"]))

    pages = []
    cur = []
    cx, cy, row_h = pad, pad, 0
    for ch, cw, ent in measured:
        if cx + cw + pad > max_dim:
            cx = pad
            cy += row_h + pad
            row_h = 0
        if cy + ch + pad > max_dim and cur:
            pages.append(cur)
            cur = []
            cx, cy, row_h = pad, pad, 0
        cur.append(ent)
        cx += cw + pad
        if ch > row_h:
            row_h = ch
    if cur:
        pages.append(cur)

    written = []
    for idx, batch in enumerate(pages):
        at, rc = cwb.shelf_pack_sprites(batch, max_atlas_w=max_dim, pad=pad)
        assert at.size[0] <= max_dim and at.size[1] <= max_dim, f"Corpse page {idx} exceeded {max_dim}: {at.size}"
        gfx_rel = f"gfx/wx_corpses_{idx}.png"
        brush_rel = f"brushes/wx_corpses_{idx}.brush"
        at.save(os.path.join(MOD_ROOT, gfx_rel), optimize=True, compress_level=9)
        cwb.write_brush_binary(os.path.join(MOD_ROOT, brush_rel), gfx_rel, at.size, rc, is_effect_sheet=False)
        print(f"Compiled {brush_rel}: {len(rc)} heroic 1:1 corpse decals ({at.size[0]}x{at.size[1]})")
        written.append((idx, gfx_rel, len(rc), at.size))
    return written


def build_all_corpses():
    busts = extract_all_upright(os.path.join(MOD_ROOT, "brushes", "wx_busts_0.brush"))
    beasts = extract_all_upright(os.path.join(MOD_ROOT, "brushes", "wx_beasts_0.brush"))

    entries = []
    seen = set()

    # 1. Modular 128x164 Wuxia character layers -> 1:1 heroic fallen corpses (168x156, ox=6, oy=10)
    for idx, (sid, im, _ox, _oy) in enumerate(busts):
        cid = f"{sid}_dead"
        if cid in seen:
            continue
        seen.add(cid)
        is_b = sid.startswith(MODULAR_BODY_PREFIXES)
        im_dead = make_heroic_corpse_layer(
            im,
            scale=1.06,
            angle_deg=122.0,
            y_squash=0.95,
            canvas_w=168,
            canvas_h=156,
            is_body_base=is_b,
            seed_val=idx,
        )
        entries.append({
            "id": cid,
            "img": im_dead,
            "ox": 6,
            "oy": 10,
            "src_rel": f"entity\\corpses\\{cid}.png",
            "is_effect": False,
        })

    # 2. Custom enemy busts (104x142 -> scaled 1.18x to match modular 128x164), wild beasts, tails & 156x156 Shan Hai Bosses
    for idx, (sid, im, _ox, _oy) in enumerate(beasts):
        cid = f"{sid}_dead"
        if cid in seen:
            continue
        seen.add(cid)
        is_boss = sid.startswith("wx_boss_") or im.width >= 140
        if is_boss:
            im_dead = make_heroic_corpse_layer(
                im,
                scale=1.02,
                angle_deg=114.0,
                y_squash=0.92,
                canvas_w=192,
                canvas_h=178,
                is_body_base=True,
                seed_val=idx + 500,
            )
            ox, oy = 6, 12
        else:
            im_dead = make_heroic_corpse_layer(
                im,
                scale=1.18,
                angle_deg=118.0,
                y_squash=0.94,
                canvas_w=168,
                canvas_h=156,
                is_body_base=True,
                seed_val=idx + 500,
            )
            ox, oy = 6, 10
        entries.append({
            "id": cid,
            "img": im_dead,
            "ox": ox,
            "oy": oy,
            "src_rel": f"entity\\corpses\\{cid}.png",
            "is_effect": False,
        })

    pages = pack_corpse_pages(entries, max_dim=2048, pad=2)
    print(f"TOTAL HEROIC CORPSE DECALS COMPILED: {len(entries)} across {len(pages)} sheet(s).")
    return pages


if __name__ == "__main__":
    build_all_corpses()
