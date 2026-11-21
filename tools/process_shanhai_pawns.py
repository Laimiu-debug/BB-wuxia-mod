#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Slices Sheets 66..70, removes white fringes, registers all 139《山海经》beasts (136 species + 3 spawn tokens)
into authentic Battle Brothers `208×284` Tactical Chess Pawns (`art/pawns/<id>.png` + `art/busts/beasts/<id>.png`),
generates `139` Isometric Fallen Corpse Decals (`art/busts/beasts_dead/<id>_dead.png`),
generates `16` new World Map Marching Beast Figurines (`art/world_entity/wx_fig_beast_*.png`),
and updates `art/manifest.json` (`4_beasts` = 136 true《山海经》creatures; `64` lairs & `16` new beast figurines in `6_world`).
"""

from collections import deque
import json
import math
import os
import shutil
import sys
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))

from process_wiki_art import flood_extract_rgba
from build_wuxia_bust_system import decontaminate_white_fringe, tight_crop
from shanhai_bestiary_data import (
    NEW_64_SHANHAI_BEASTS,
    SHEET70_WORLD_BEAST_FIGS,
    build_all_bestiary_records,
)

ART_DIR = ROOT / "art"
SHEETS_DIR = ART_DIR / "sheets"
HD_DIR = ART_DIR / "hd"
GAME_DIR = ART_DIR / "game"
BUSTS_DIR = ART_DIR / "busts"
SOCKETS_DIR = BUSTS_DIR / "sockets"
BEAST_BUSTS_DIR = BUSTS_DIR / "beasts"
BEAST_DEAD_DIR = BUSTS_DIR / "beasts_dead"
PAWNS_DIR = ART_DIR / "pawns"
WORLD_ENT_DIR = ART_DIR / "world_entity"

BRAIN_DIR = Path(r"C:\Users\25647\.gemini\antigravity\brain\885413ab-7149-4318-bddd-aa11f51e787a")

RAW_SHEET_SOURCES = {
    66: BRAIN_DIR / "shanhai_beasts_sheet_66_1795224032242.jpg",
    67: BRAIN_DIR / "shanhai_beasts_sheet_67_1795224029241.jpg",
    68: BRAIN_DIR / "shanhai_beasts_sheet_68_1795224077299.jpg",
    69: BRAIN_DIR / "shanhai_beasts_sheet_69_v3_1795224037512.jpg",
    70: BRAIN_DIR / "shanhai_figurines_sheet_70_1795224035184.jpg",
}

FLIP_CELLS_BY_SHEET = {
    66: set(),
    67: set(),
    68: {8},  # Xuanfeng hornet faces right -> flip to 3/4-left
    69: {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 14, 15},  # Flip right-facing busts to 3/4-left
    70: set(),  # World figurines face 3/4-right matching existing wx_fig_beast_*
}

W_PAWN, H_PAWN = 208, 284


def ensure_dirs():
    for d in (
        SHEETS_DIR, HD_DIR, GAME_DIR / "entity", GAME_DIR / "world_entity",
        SOCKETS_DIR, BEAST_BUSTS_DIR, BEAST_DEAD_DIR, PAWNS_DIR, WORLD_ENT_DIR,
    ):
        d.mkdir(parents=True, exist_ok=True)


def clean_sprite_rgba(rgba: Image.Image) -> Image.Image:
    """Strip stray corner specks, decontaminate white halos, and add a crisp 1px dark-ink contour."""
    im = decontaminate_white_fringe(rgba.convert("RGBA"), passes=2)
    w, h = im.size
    px = im.load()

    # Keep only meaningful foreground connected components (removes tiny isolated noise specks)
    mask = im.getchannel("A").point(lambda a: 255 if a >= 42 else 0)
    mpx = mask.load()
    vis = bytearray(w * h)
    comps = []
    for y in range(h):
        for x in range(w):
            idx = y * w + x
            if not vis[idx] and mpx[x, y] > 0:
                vis[idx] = 1
                q = deque([(x, y)])
                pts = [(x, y)]
                while q:
                    cx, cy = q.popleft()
                    for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
                        if 0 <= nx < w and 0 <= ny < h:
                            nidx = ny * w + nx
                            if not vis[nidx] and mpx[nx, ny] > 0:
                                vis[nidx] = 1
                                q.append((nx, ny))
                                pts.append((nx, ny))
                comps.append(pts)

    if comps:
        biggest = max(len(c) for c in comps)
        for pts in comps:
            if len(pts) < max(12, biggest // 60):
                for sx, sy in pts:
                    mpx[sx, sy] = 0
                    px[sx, sy] = (0, 0, 0, 0)

    # Zero out ultra-faint outer mist/white fringe (`alpha < 55` and bright)
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            if a < 45 or (a < 135 and r > 215 and g > 215 and b > 215):
                px[x, y] = (0, 0, 0, 0)
            elif a < 180 and r > 185 and g > 185 and b > 185:
                # Darken pale edge anti-aliasing into ink contour
                px[x, y] = (24, 20, 18, a)

    # Subtle 1px dark-ink rim behind silhouette so every creature pops cleanly on any terrain
    solid = im.getchannel("A").point(lambda a: 255 if a >= 95 else 0)
    dil = solid.filter(ImageFilter.MaxFilter(3))
    rim_a = dil.point(lambda a: 205 if a > 0 else 0)
    rim = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    rim.paste((14, 11, 9, 255), (0, 0), rim_a)
    out = Image.alpha_composite(rim, im)
    return tight_crop(out, thresh=20)


def tint_pedestal_pair(pb_orig: Image.Image, pf_orig: Image.Image, theme: str):
    """Build 5 distinct themed tactical chess pedestals (`208×284`) with 100% identical pixel geometry."""
    pb = pb_orig.convert("RGBA").copy()
    pf = pf_orig.convert("RGBA").copy()

    palettes = {
        "wild_stone":   ((1.00, 0.98, 0.95), None),
        "spawn_mire":   ((0.86, 1.04, 0.88), (62, 165, 88, 22)),
        "boss_crimson": ((1.36, 0.76, 0.74), (210, 46, 36, 28)),
        "boss_gold":    ((1.30, 1.14, 0.78), (225, 175, 62, 26)),
        "boss_frost":   ((0.82, 1.12, 1.35), (72, 185, 235, 26)),
        "boss_mire":    ((1.12, 0.96, 0.82), (185, 132, 68, 22)),
    }
    mul, glow_rgba = palettes.get(theme, palettes["wild_stone"])

    # Only tint the carved front rim (`pf`), keeping `pb` a deep dark stone shadow basin!
    px = pf.load()
    for y in range(pf.height):
        for x in range(pf.width):
            r, g, b, a = px[x, y]
            if a > 0:
                nr = min(255, int(r * mul[0]))
                ng = min(255, int(g * mul[1]))
                nb = min(255, int(b * mul[2]))
                px[x, y] = (nr, ng, nb, a)

    if glow_rgba:
        # Subtle inner-rim glow ring along the stone bevel without washing out the dark shadow basin
        aura = Image.new("RGBA", (W_PAWN, H_PAWN), (0, 0, 0, 0))
        dr = ImageDraw.Draw(aura)
        dr.ellipse([20, 186, 188, 250], outline=glow_rgba[:3] + (95,), width=2)
        aura = aura.filter(ImageFilter.GaussianBlur(radius=2.5))
        pb = Image.alpha_composite(pb, aura)

    return pb, pf


def build_socket_clip_mask(pf_orig: Image.Image) -> Image.Image:
    """
    Constructs a `208×284` alpha mask that allows full freedom above the socket (`y <= 202`, including
    wide wings/horns/claws overhanging left & right!), while smoothly clipping the lower waist inside
    the `pedestal_front` crescent rim so ZERO pixels ever poke out beneath the chess base!
    """
    pf_a = pf_orig.convert("RGBA").getchannel("A")
    ppx = pf_a.load()

    # Measure exact bottom outer contour of `pedestal_front` for every column `x`
    bottom_y = [242] * W_PAWN
    for x in range(W_PAWN):
        ys = [y for y in range(H_PAWN) if ppx[x, y] > 40]
        if ys:
            bottom_y[x] = max(ys) - 3  # Stay safely 3px above outer bottom edge of front rim!
        else:
            dx = abs(x - 104)
            bottom_y[x] = int(204 - max(0, dx - 92) * 0.6)

    mask = Image.new("L", (W_PAWN, H_PAWN), 0)
    mpx = mask.load()
    for x in range(W_PAWN):
        lim = bottom_y[x]
        # Outside pedestal x-span (`x < 14` or `x > 194`), allow wings/claws above `y = 200`, fade smoothly by `208`
        if x < 14 or x > 194:
            lim = min(lim, 202)
        for y in range(H_PAWN):
            if y <= lim - 5:
                mpx[x, y] = 255
            elif y <= lim:
                mpx[x, y] = int(255 * (lim - y) / 5.0)
    return mask


def register_beast_to_pawn(hd_rgba: Image.Image, is_boss: bool, socket_mask: Image.Image, pb: Image.Image, pf: Image.Image):
    """
    Seats a clean creature bust (`hd_rgba`) onto the canonical `208×284` Battle Brothers pawn canvas:
      - Returns `(seated_bust_208x284, full_composited_pawn_208x284)`.
    """
    crop = tight_crop(hd_rgba, thresh=22)
    max_w = 176 if is_boss else 160
    max_h = 220 if is_boss else 196

    scale = min(max_w / float(crop.width), max_h / float(crop.height))
    nw = max(1, int(round(crop.width * scale)))
    nh = max(1, int(round(crop.height * scale)))
    scaled = crop.resize((nw, nh), Image.Resampling.LANCZOS)

    # Seat bottom of bust deep into the socket valley (`y_bottom = 252` for tall busts, `246` for compact busts)
    target_bottom_y = 252 if nh >= 165 else 246
    ox = (W_PAWN - nw) // 2
    oy = target_bottom_y - nh

    layer = Image.new("RGBA", (W_PAWN, H_PAWN), (0, 0, 0, 0))
    layer.alpha_composite(scaled, (ox, oy))

    # Boolean-intersect alpha with `socket_mask` so lower edge sits cleanly behind `pedestal_front`!
    r, g, b, a = layer.split()
    clipped_a = ImageChops.multiply(a, socket_mask)

    # Subtle ambient occlusion darkening where lower torso meets the stone socket (`y = 226..252`)
    rgb_im = Image.merge("RGB", (r, g, b))
    rpx = rgb_im.load()
    apx = clipped_a.load()
    for y in range(224, 256):
        shade = 1.0 - 0.24 * ((y - 224) / 32.0)
        for x in range(W_PAWN):
            if apx[x, y] > 0:
                cr, cg, cb = rpx[x, y]
                rpx[x, y] = (int(cr * shade), int(cg * shade), int(cb * shade))

    seated_bust = Image.merge("RGBA", (*rgb_im.split(), clipped_a))

    # Full tabletop chess piece composite: pedestal_back -> seated_bust -> pedestal_front
    full_pawn = Image.new("RGBA", (W_PAWN, H_PAWN), (0, 0, 0, 0))
    full_pawn = Image.alpha_composite(full_pawn, pb)
    full_pawn = Image.alpha_composite(full_pawn, seated_bust)
    full_pawn = Image.alpha_composite(full_pawn, pf)
    return seated_bust, full_pawn


def make_hd_fallen_corpse(seated_208: Image.Image, seed_val: int) -> Image.Image:
    """Generates a crisp `196×172` isometric fallen corpse decal (`*_dead`) with contact shadow & battle wounds."""
    work = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    # Crop out bottom socket occlusion fade slightly
    crop = tight_crop(seated_208, thresh=24)
    scale = min(176.0 / max(1, crop.width), 190.0 / max(1, crop.height))
    cw, ch = max(1, int(crop.width * scale)), max(1, int(crop.height * scale))
    cs = crop.resize((cw, ch), Image.Resampling.LANCZOS)
    work.alpha_composite(cs, ((256 - cw) // 2, (256 - ch) // 2))

    rot = work.rotate(102, resample=Image.Resampling.BICUBIC, expand=False, center=(128, 128))
    squashed = rot.resize((256, int(256 * 0.76)), Image.Resampling.LANCZOS)
    sq_crop = tight_crop(squashed, thresh=20)

    out_w, out_h = 196, 172
    sc2 = min((out_w - 20) / float(max(1, sq_crop.width)), (out_h - 20) / float(max(1, sq_crop.height)))
    fw, fh = max(1, int(sq_crop.width * sc2)), max(1, int(sq_crop.height * sc2))
    fallen = sq_crop.resize((fw, fh), Image.Resampling.LANCZOS)

    rgb = ImageEnhance.Brightness(fallen.convert("RGB")).enhance(0.84)
    fa = fallen.getchannel("A")
    fallen = Image.merge("RGBA", (*rgb.split(), fa))

    # Battle wounds on corpse
    fpx = fallen.load()
    cx1 = fw // 2 + (seed_val % 15) - 7
    cy1 = fh // 2 + ((seed_val // 5) % 11) - 5
    for y in range(fh):
        for x in range(fw):
            r, g, b, al = fpx[x, y]
            if al < 90:
                continue
            d = ((x - cx1) ** 2) / 260.0 + ((y - cy1) ** 2) / 110.0
            if d < 1.0:
                st = (1.0 - d) * 0.58
                fpx[x, y] = (int(r * (1 - st) + 96 * st), int(g * (1 - st) + 12 * st), int(b * (1 - st) + 10 * st), al)

    canvas = Image.new("RGBA", (out_w, out_h), (0, 0, 0, 0))
    ox, oy = (out_w - fw) // 2, (out_h - fh) // 2 + 4
    sh_a = fa.point(lambda v: int(v * 0.60))
    sh = Image.new("RGBA", (out_w, out_h), (0, 0, 0, 0))
    sh.paste((8, 6, 5, 255), (ox + 3, oy + 6), sh_a)
    sh = sh.filter(ImageFilter.GaussianBlur(radius=3.8))
    canvas = Image.alpha_composite(canvas, sh)
    canvas.alpha_composite(fallen, (ox, oy))
    return canvas


def slice_4x4_sheet(sheet_path: Path, cell_idx: int, flip_x: bool) -> Image.Image:
    im = Image.open(sheet_path).convert("RGB")
    sw, sh = im.size
    cw, ch = sw // 4, sh // 4
    r, c = divmod(cell_idx, 4)
    cell = im.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch))
    rgba = flood_extract_rgba(cell, bg_thresh=26, feather_band=16, bust_mode=False)
    if flip_x:
        rgba = ImageOps.mirror(rgba)
    return clean_sprite_rgba(rgba)


def fit_box_centered(rgba: Image.Image, tw: int, th: int, pad: int = 4) -> Image.Image:
    crop = tight_crop(rgba, thresh=20)
    s = min((tw - 2 * pad) / float(max(1, crop.width)), (th - 2 * pad) / float(max(1, crop.height)))
    nw, nh = max(1, int(round(crop.width * s))), max(1, int(round(crop.height * s)))
    rs = crop.resize((nw, nh), Image.Resampling.LANCZOS)
    out = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    out.alpha_composite(rs, ((tw - nw) // 2, (th - nh) // 2))
    return out


def make_world_beast_figurine(clean_rgba: Image.Image) -> Image.Image:
    """Formats a roaming beast figurine to canonical `68×106` world-map token with grounded shadow."""
    crop = tight_crop(clean_rgba, thresh=20)
    s = min(56.0 / float(max(1, crop.width)), 62.0 / float(max(1, crop.height)))
    nw, nh = max(1, int(round(crop.width * s))), max(1, int(round(crop.height * s)))
    rs = crop.resize((nw, nh), Image.Resampling.LANCZOS)

    out = Image.new("RGBA", (68, 106), (0, 0, 0, 0))
    ox = (68 - nw) // 2
    oy = 94 - nh  # Feet anchored at y=94 matching `wx_fig_beast_tiangou.png`!

    sh = Image.new("RGBA", (68, 106), (0, 0, 0, 0))
    dr = ImageDraw.Draw(sh)
    dr.ellipse([ox + 4, 88, ox + nw - 4, 97], fill=(8, 6, 5, 145))
    sh = sh.filter(ImageFilter.GaussianBlur(radius=1.8))
    out = Image.alpha_composite(out, sh)
    out.alpha_composite(rs, (ox, oy))
    return out


def main():
    ensure_dirs()

    # 1. Copy raw generated sheets into `art/sheets/sheet_66..70.jpg`
    for snum, src in RAW_SHEET_SOURCES.items():
        dst = SHEETS_DIR / f"sheet_{snum}.jpg"
        if src.exists():
            shutil.copy2(src, dst)

    # 2. Extract 64 NEW《山海经》Beast HD & Game Preview PNGs from Sheets 66..69
    for row in NEW_64_SHANHAI_BEASTS:
        snum, cidx, bid = row[0], row[1], row[2]
        sheet_p = SHEETS_DIR / f"sheet_{snum}.jpg"
        flip = cidx in FLIP_CELLS_BY_SHEET[snum]
        clean_im = slice_4x4_sheet(sheet_p, cidx, flip)
        hd_im = fit_box_centered(clean_im, 256, 256, pad=8)
        prev_im = fit_box_centered(clean_im, 112, 112, pad=3)
        hd_im.save(HD_DIR / f"{bid}.png")
        prev_im.save(GAME_DIR / "entity" / f"{bid}.png")

    # 3. Extract 16 NEW World-Map Marching Beast Chess Figurines from Sheet 70
    ws_meta_path = WORLD_ENT_DIR / "_meta.json"
    we_meta = json.loads(ws_meta_path.read_text(encoding="utf-8")) if ws_meta_path.exists() else []
    existing_we_ids = {m["id"] for m in we_meta}

    sheet70_p = SHEETS_DIR / "sheet_70.jpg"
    for cidx, fid, nm, sub, brief in SHEET70_WORLD_BEAST_FIGS:
        clean_im = slice_4x4_sheet(sheet70_p, cidx, flip_x=False)
        hd_fig = fit_box_centered(clean_im, 220, 220, pad=10)
        fig_token = make_world_beast_figurine(clean_im)
        hd_fig.save(HD_DIR / f"{fid}.png")
        fig_token.save(WORLD_ENT_DIR / f"{fid}.png")
        fig_token.save(GAME_DIR / "world_entity" / f"{fid}.png")
        if fid not in existing_we_ids:
            we_meta.append({"id": fid, "file": f"{fid}.png", "ox": 0, "oy": 20})
            existing_we_ids.add(fid)

    ws_meta_path.write_text(json.dumps(we_meta, ensure_ascii=False, indent=2), encoding="utf-8")

    # 4. Build 5 Themed Tactical Chess Socket Pedestal Pairs
    pb_orig = Image.open(BUSTS_DIR / "pedestal_back.png").convert("RGBA")
    pf_orig = Image.open(BUSTS_DIR / "pedestal_front.png").convert("RGBA")
    socket_mask = build_socket_clip_mask(pf_orig)

    themed_sockets = {}
    for theme in ("wild_stone", "spawn_mire", "boss_crimson", "boss_gold", "boss_frost", "boss_mire"):
        tb, tf = tint_pedestal_pair(pb_orig, pf_orig, theme)
        tb.save(SOCKETS_DIR / f"pedestal_{theme}_back.png")
        tf.save(SOCKETS_DIR / f"pedestal_{theme}_front.png")
        themed_sockets[theme] = (tb, tf)

    # 5. Register ALL 139 Creatures (`64` Bosses + `72` Wild Species + `3` Spawn Tokens) into `208×284` Pawns & Corpses!
    bestiary = build_all_bestiary_records()
    for idx, c in enumerate(bestiary["creatures"]):
        cid = c["id"]
        hd_p = HD_DIR / f"{cid}.png"
        if not hd_p.exists():
            raise FileNotFoundError(f"Missing HD art for {cid}: {hd_p}")
        raw_hd = Image.open(hd_p).convert("RGBA")
        # Clean white fringe on existing 75 assets as well so ALL 139 pawns have razor-sharp ink edges!
        cleaned = clean_sprite_rgba(raw_hd)
        pb, pf = themed_sockets.get(c["socketTheme"], themed_sockets["wild_stone"])
        seated, full_pawn = register_beast_to_pawn(cleaned, is_boss=(c["kind"] == "boss"), socket_mask=socket_mask, pb=pb, pf=pf)
        corpse = make_hd_fallen_corpse(seated, seed_val=idx + 17)

        seated.save(BEAST_BUSTS_DIR / f"{cid}.png")
        full_pawn.save(PAWNS_DIR / f"{cid}.png")
        corpse.save(BEAST_DEAD_DIR / f"{cid}_dead.png")

    # 6. Update `art/manifest.json` cleanly & idempotently!
    manifest_p = ART_DIR / "manifest.json"
    manifest = json.loads(manifest_p.read_text(encoding="utf-8"))
    assets = manifest["assets"]

    # Reclassify the 64 world map lairs (`wx_shanhai_*` & `wx_lair_*`) into `6_world` so `4_beasts` holds ONLY true beasts (136)!
    for a in assets:
        if a["stage"] == "4_beasts" and (a["id"].startswith("wx_shanhai_") or a["id"].startswith("wx_lair_")):
            a["stage"] = "6_world"
            a["group"] = "九州秘境 · 山海六十四大妖巢穴地标"

    # Remove any previous new beast / new world-fig entries so re-runs are 100% idempotent
    new_beast_ids = {r[2] for r in NEW_64_SHANHAI_BEASTS}
    new_fig_ids = {r[1] for r in SHEET70_WORLD_BEAST_FIGS}
    assets = [a for a in assets if a["id"] not in new_beast_ids and a["id"] not in new_fig_ids]

    # Attach pawn/corpse/worldFig paths to existing 75 beasts in `4_beasts`
    creature_by_id = {c["id"]: c for c in bestiary["creatures"]}
    for a in assets:
        if a["id"] in creature_by_id:
            cr = creature_by_id[a["id"]]
            a["pawnPath"] = f"art/pawns/{a['id']}.png"
            a["bustPath"] = f"art/busts/beasts/{a['id']}.png"
            a["corpsePath"] = f"art/busts/beasts_dead/{a['id']}_dead.png"
            a["worldFigPath"] = f"art/world_entity/{cr['worldFigId']}.png"
            if cr["kind"] == "boss":
                a["group"] = f"山海经六十四大妖首领 ·《{cr['chapter']}》"
            else:
                a["group"] = f"山海经七十二伴生异兽 ·《{cr['chapter']}》"

    # Append the 61 NEW distinct species into `4_beasts` (`64 + 11 + 61 = 136` true《山海经》creatures!)
    for row in NEW_64_SHANHAI_BEASTS:
        snum, cidx, bid, nm, chap, bgrp, rank, arch, wfig, quote, tname, tdesc, cp, trophy, st, sk1, sk2 = row
        if rank == "伴生衍生物":
            # Keep the 3 battlefield summon tokens in `5_vfx` or `6_world`? Wait: let's check!
            # Putting the 3 summon tokens in `5_vfx` (`战场召唤衍生物棋子`) keeps `4_beasts` at EXACT 136!
            stage_id = "5_vfx"
            grp_label = "山海秘境 · 战场伴生召唤衍生物棋子"
        else:
            stage_id = "4_beasts"
            grp_label = f"山海经七十二伴生异兽 ·《{chap}》"
        assets.append({
            "id": bid,
            "stage": stage_id,
            "group": grp_label,
            "name": nm,
            "sub": f"《{chap}》{rank} · 骨架 {arch} · {tname}",
            "spec": "208×284 嵌座战棋 + 196×172 倒地尸骸 + 大地图游荡棋",
            "slotKind": "boss",
            "status": "wiki_ready",
            "hdPath": f"art/hd/{bid}.png",
            "previewPath": f"art/game/entity/{bid}.png",
            "pawnPath": f"art/pawns/{bid}.png",
            "bustPath": f"art/busts/beasts/{bid}.png",
            "corpsePath": f"art/busts/beasts_dead/{bid}_dead.png",
            "worldFigPath": f"art/world_entity/{wfig}.png",
            "swPath": "",
            "smallPath": "",
            "gameTarget": f"gfx/entity/{bid}.png",
            "vanillaFallback": arch,
            "codeRef": "mod_wuxia/config/wx_shanhai_beasts.nut",
            "brief": f"{quote} 【{tname}】{tdesc}",
        })

    # Append the 16 NEW World Map Marching Beast Chess Pieces into `6_world`
    for cidx, fid, nm, sub, brief in SHEET70_WORLD_BEAST_FIGS:
        assets.append({
            "id": fid,
            "stage": "6_world",
            "group": "九州行伍 · 山海万妖大地图游荡棋子",
            "name": nm,
            "sub": sub,
            "spec": "68×106 大地图行军异兽微缩棋子 (.brush)",
            "slotKind": "camp",
            "status": "wiki_ready",
            "hdPath": f"art/hd/{fid}.png",
            "previewPath": f"art/world_entity/{fid}.png",
            "swPath": "",
            "smallPath": "",
            "gameTarget": f"brushes/wx_world_entity_0.brush ({fid})",
            "vanillaFallback": "figure_werewolf_01",
            "codeRef": "mod_wuxia/config/wx_world_visuals.nut",
            "brief": brief,
        })

    # Update stage descriptions & summary counts
    for st in manifest["stages"]:
        cnt = sum(1 for a in assets if a["stage"] == st["id"])
        if st["id"] == "4_beasts":
            st["name"] = "第四卷 · 山海经万妖异兽"
            st["desc"] = f"64尊《山海经》秘境大妖首领 + 72种山海伴生/山泽异兽（{cnt}/{cnt} · 含实机战棋底座、倒地尸骸与大地图小棋子）"
        elif st["id"] == "6_world":
            st["name"] = "第六卷 · 九州山门与秘境舆图"
            st["desc"] = f"中式州府山门、十四坊铺、48尊大地图行军/游荡棋子、64座山海秘境巢穴地标与16面竖幅长战旗（{cnt}/{cnt}）"

    manifest["assets"] = assets
    manifest["summary"]["total"] = len(assets)
    manifest["summary"]["in_game"] = sum(1 for a in assets if a["status"] == "in_game")
    manifest["summary"]["wiki_ready"] = sum(1 for a in assets if a["status"] == "wiki_ready")
    manifest["summary"]["planned"] = sum(1 for a in assets if a["status"] == "planned")
    manifest_p.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")

    b4_cnt = sum(1 for a in assets if a["stage"] == "4_beasts")
    print(f"SUCCESS: Generated 139 Tactical Pawns, 139 Fallen Corpses, 24 World Beast Figurines! Stage 4_beasts={b4_cnt}, Total Manifest={len(assets)}")


if __name__ == "__main__":
    main()
