#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Pure-Python Byte-Exact Overhype `.brush` + OpenGL RGBA Sprite Sheet Compiler (`0xBAADFAAD` v17).
Compiles all standalone Wuxia art assets into directly callable in-game Battle Brothers resources:
  1. `mod_wuxia/brushes/wx_effects_0.brush` + `mod_wuxia/gfx/wx_effects_0.png`
     -> 32 Wuxia Active Skill Combat VFX (`wx_vfx_01..32`)
  2. `mod_wuxia/brushes/wx_beasts_0.brush` + `mod_wuxia/gfx/wx_beasts_0.png`
     -> 64 Shan Hai Jing Apex Bosses (`wx_boss_*`) + 11 Wild Beasts (`wx_beast_*`) + 18 Enemy Busts (`wx_enemy_*`)
  3. `mod_wuxia/brushes/wx_world_0.brush` + `mod_wuxia/gfx/wx_world_0.png`
     -> 64 Shan Hai World Map Lairs (`wx_lair_*`)
  4. `mod_wuxia/brushes/wx_busts_0.brush` + `mod_wuxia/gfx/wx_busts_0.png`
     -> Modular 104×142 Character Busts (`wx_head_01..48`, `wx_hair_01..24`, `wx_hair_tucked_01..24`,
        `wx_beard_01..24`, `wx_scar_01..12`, `wx_hat_back_01..32`, `wx_hat_front_01..32`, `wx_body_*`)
"""

import glob
import json
import math
import os
import struct
from PIL import Image, ImageEnhance, ImageFilter, ImageOps

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART_DIR = os.path.join(ROOT, "art")
MOD_ROOT = os.path.join(ROOT, "mod_wuxia")

BRUSH_MAGIC = 0xBAADFAAD
BRUSH_VERSION = 0x0011
EMPTY_CAT_HASH = 0xBF795EF4D3FE85C5


def sdbm64(s: str) -> int:
    h = 0
    for ch in s:
        h = (h * 65599 + ord(ch)) & 0xFFFFFFFFFFFFFFFF
    return h


def compute_avg_rgba(crop_rgba: Image.Image):
    px = crop_rgba.load()
    w, h = crop_rgba.size
    rs = gs = bs = cnt = 0
    step = max(1, min(w, h) // 16)
    for y in range(0, h, step):
        for x in range(0, w, step):
            r, g, b, a = px[x, y]
            if a > 64:
                rs += r
                gs += g
                bs += b
                cnt += 1
    if cnt == 0:
        return (128, 128, 128, 255)
    return (rs // cnt, gs // cnt, bs // cnt, 255)


def shelf_pack_sprites(entries, max_atlas_w=2048, pad=2):
    """
    entries: list of dicts `{id, img, ox, oy, src_rel, is_effect}`
      where `img` is already scaled to exact game logical canvas `(W, H)`.
    Returns `(atlas_rgba, packed_records)`.
    """
    trimmed = []
    for ent in entries:
        im = ent["img"].convert("RGBA")
        w, h = im.size
        bbox = im.getchannel("A").point(lambda a: 255 if a > 4 else 0).getbbox()
        if not bbox:
            bx0, by0, bx1, by1 = w // 2 - 2, h // 2 - 2, w // 2 + 2, h // 2 + 2
        else:
            bx0, by0, bx1, by1 = bbox
        crop = im.crop((bx0, by0, bx1, by1))
        cw, ch = crop.size
        trimmed.append({
            **ent,
            "w": w,
            "h": h,
            "bx0": bx0,
            "by0": by0,
            "bx1": bx1,
            "by1": by1,
            "cw": cw,
            "ch": ch,
            "crop": crop,
        })

    # Sort by height descending for tight shelf packing, then restore deterministic ID order when writing `.brush`
    order = sorted(range(len(trimmed)), key=lambda i: (-trimmed[i]["ch"], trimmed[i]["id"]))

    def try_pack(aw):
        cx, cy, row_h = pad, pad, 0
        coords = [None] * len(trimmed)
        for idx in order:
            it = trimmed[idx]
            cw, ch = it["cw"], it["ch"]
            if cx + cw + pad > aw:
                cx = pad
                cy += row_h + pad
                row_h = 0
            coords[idx] = (cx, cy)
            cx += cw + pad
            if ch > row_h:
                row_h = ch
        total_h = cy + row_h + pad
        # Next power of two >= max(256, total_h)
        ah = 256
        while ah < total_h:
            ah *= 2
        return ah, coords

    aw = max_atlas_w
    ah, coords = try_pack(aw)
    if ah > 4096 and aw < 4096:
        aw = 4096
        ah, coords = try_pack(aw)

    atlas = Image.new("RGBA", (aw, ah), (0, 0, 0, 0))
    records = []
    for idx, it in enumerate(trimmed):
        ax, ay = coords[idx]
        cw, ch = it["cw"], it["ch"]
        # Battle Brothers OpenGL UVs flip each sprite vertically inside the atlas!
        atlas.paste(ImageOps.flip(it["crop"]), (ax, ay))

        w, h = it["w"], it["h"]
        half_w = w / 2.0
        half_h = h / 2.0
        fL = float(it["bx0"]) - half_w
        fR = float(it["bx1"]) - half_w
        fB = half_h - float(it["by0"])
        fT = half_h - float(it["by1"])

        u0 = ax / float(aw)
        u1 = (ax + cw) / float(aw)
        v0 = ay / float(ah)
        v1 = (ay + ch) / float(ah)

        records.append({
            "id": it["id"],
            "w": w,
            "h": h,
            "ox": it["ox"],
            "oy": it["oy"],
            "avg_rgba": (0, 0, 0, 0) if it.get("is_effect") else compute_avg_rgba(it["crop"]),
            "src_rel": it["src_rel"],
            "uv_quad": (u0, u1, v0, v1, fL, fR, fT, fB),
        })

    return atlas, records


def write_brush_binary(brush_path: str, gfx_rel: str, atlas_size, records, is_effect_sheet=False):
    aw, ah = atlas_size
    gfx_bytes = gfx_rel.encode("ascii")
    buf = bytearray()

    # 1. File Header
    buf += struct.pack("<IHH", BRUSH_MAGIC, BRUSH_VERSION, len(gfx_bytes))
    buf += gfx_bytes
    # 26-byte sheet metadata header (`<HH` aw, ah + 12 flag bytes + `<I` count + `<HI` 0, 1000)
    flag12 = bytes.fromhex("010001010100" + ("0100" if is_effect_sheet else "0000") + "01000000")
    buf += struct.pack("<HH", aw, ah)
    buf += flag12
    buf += struct.pack("<IHI", len(records), 0, 1000)

    # 2. Sprite Records
    mid_prefix25 = bytes.fromhex("00640000000000000000000000030400000000000000000000")
    mid_scale4 = bytes.fromhex("00000040")  # float 2.0

    for rec in records:
        sid = rec["id"]
        sid_b = sid.encode("ascii")
        src_b = rec["src_rel"].encode("ascii")
        r, g, b, a = rec["avg_rgba"]

        buf += struct.pack("<QH", sdbm64(sid), len(sid_b))
        buf += sid_b
        buf += struct.pack("<QIIhh", EMPTY_CAT_HASH, rec["w"], rec["h"], rec["ox"], rec["oy"])
        buf += mid_prefix25
        buf += struct.pack("<BBBB", r, g, b, a)
        buf += mid_scale4
        buf += struct.pack("<HH", 1, len(src_b))  # 1 frame + src length
        buf += src_b
        buf += struct.pack("<8f", *rec["uv_quad"])
        buf += b"\x00\x00\x00"

    os.makedirs(os.path.dirname(brush_path), exist_ok=True)
    with open(brush_path, "wb") as f:
        f.write(buf)


def fit_canvas(rgba: Image.Image, target_w: int, target_h: int, pad: int = 4) -> Image.Image:
    im = rgba.convert("RGBA")
    bbox = im.getchannel("A").point(lambda a: 255 if a > 12 else 0).getbbox()
    if bbox:
        im = im.crop(bbox)
    mw = max(1, target_w - 2 * pad)
    mh = max(1, target_h - 2 * pad)
    s = min(mw / float(im.width), mh / float(im.height))
    nw, nh = max(1, int(round(im.width * s))), max(1, int(round(im.height * s)))
    im_s = im.resize((nw, nh), Image.Resampling.LANCZOS)
    out = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    out.alpha_composite(im_s, ((target_w - nw) // 2, (target_h - nh) // 2))
    return out


def make_world_bust_layer(im_208: Image.Image) -> Image.Image:
    """
    Converts a registered `208x284` paperdoll layer into an exact `68x106` (`ox=0, oy=20`)
    world-map marching figure layer (`wm_<id>`), aligned to vanilla `figure_player_01` (`x=13..57, y=45..94`).
    """
    # Scale `208x284` -> `48x66` so head + shoulders + upper chest fit crisply at world-map zoom
    im_s = im_208.resize((48, 66), Image.Resampling.LANCZOS)
    spx = im_s.load()
    # Smooth curved bust-pedestal cutoff near waist (`y=52..62` in 48x66), matching `figure_player_01`
    for y in range(48, 66):
        for x in range(48):
            r, g, b, a = spx[x, y]
            if a == 0:
                continue
            dx = (x - 23.5) / 22.0
            curve_y = 58.5 - 5.5 * (dx * dx)
            if y > curve_y + 1.5:
                spx[x, y] = (0, 0, 0, 0)
            elif y > curve_y - 1.5:
                fade = max(0.0, min(1.0, (curve_y + 1.5 - y) / 3.0))
                spx[x, y] = (r, g, b, int(a * fade))

    out = Image.new("RGBA", (68, 106), (0, 0, 0, 0))
    # Paste at (10, 36) -> spans y=36..94, matching vanilla `figure_player_01` quad (-39..+12 around h/2=53 -> y=41..92)
    out.alpha_composite(im_s, (10, 36))
    return out


def make_fallen_corpse_layer(im_104: Image.Image, is_body_base: bool = False, seed_val: int = 0) -> Image.Image:
    """
    Transforms any registered `104x142` (`ox=0, oy=35`) tactical bust layer into a pixel-registered
    horizontal fallen corpse decal (`131x125`, `ox=6, oy=10`) matching vanilla `entity_0.brush` corpses:
    head toward lower-left, torso/hem toward upper-right, isometric ground foreshortening (`0.80`),
    grounded shadow, and dark-crimson battle blood on base body/enemy layers.
    """
    if im_104.size != (104, 142):
        im_104 = fit_canvas(im_104, 104, 142, pad=4)

    work = Image.new("RGBA", (164, 164), (0, 0, 0, 0))
    work.alpha_composite(im_104, (30, 11))
    rot = work.rotate(104, resample=Image.Resampling.BICUBIC, expand=False, center=(82, 84))

    # Isometric ground plane squash (vertical 0.80) into 164x132
    sq_h = int(round(164 * 0.80))
    squashed = rot.resize((164, sq_h), Image.Resampling.LANCZOS)

    canvas = Image.new("RGBA", (131, 125), (0, 0, 0, 0))
    # Center squashed (164x131) onto (131x125) with fixed constant offset (-16, -2) for 100% multi-layer registration!
    layer = Image.new("RGBA", (131, 125), (0, 0, 0, 0))
    layer.alpha_composite(squashed, (-16, -2))

    # Slight fallen shadow darkening (0.86x brightness)
    rgb = ImageEnhance.Brightness(layer.convert("RGB")).enhance(0.86)
    a = layer.getchannel("A")
    layer = Image.merge("RGBA", (*rgb.split(), a))

    if is_body_base:
        # Grounded contact shadow beneath the fallen body
        sh_a = a.point(lambda v: int(v * 0.58))
        sh = Image.new("RGBA", (131, 125), (0, 0, 0, 0))
        sh.paste((8, 6, 5, 255), (2, 4), sh_a)
        sh = sh.filter(ImageFilter.GaussianBlur(radius=2.6))
        canvas = Image.alpha_composite(canvas, sh)

        # Subtle dark-crimson battle wounds on torso (masked strictly to opaque pixels)
        lpx = layer.load()
        cx1 = 58 + (seed_val % 11) - 5
        cy1 = 64 + ((seed_val // 7) % 9) - 4
        cx2 = 76 + ((seed_val // 3) % 9) - 4
        cy2 = 52 + ((seed_val // 13) % 9) - 4
        for y in range(125):
            for x in range(131):
                r, g, b, al = lpx[x, y]
                if al < 80:
                    continue
                d1 = ((x - cx1) ** 2) / 140.0 + ((y - cy1) ** 2) / 55.0
                d2 = ((x - cx2) ** 2) / 95.0 + ((y - cy2) ** 2) / 40.0
                stain = 0.0
                if d1 < 1.0:
                    stain = max(stain, (1.0 - d1) * 0.62)
                if d2 < 1.0:
                    stain = max(stain, (1.0 - d2) * 0.48)
                if stain > 0.02:
                    nr = int(r * (1.0 - stain) + 88 * stain)
                    ng = int(g * (1.0 - stain) + 12 * stain)
                    nb = int(b * (1.0 - stain) + 10 * stain)
                    lpx[x, y] = (nr, ng, nb, al)

    canvas.alpha_composite(layer, (0, 0))
    return canvas


def compile_all():
    os.makedirs(os.path.join(MOD_ROOT, "brushes"), exist_ok=True)
    os.makedirs(os.path.join(MOD_ROOT, "gfx"), exist_ok=True)
    manifest = json.load(open(os.path.join(ART_DIR, "manifest.json"), "r", encoding="utf-8"))
    assets = manifest["assets"]

    # 1. Tactical Skill VFX + 64 Multi-Frame Martial Animation Keyframes + 72 Skill Overhead Banners (`wx_effects_0.brush`)
    vfx_entries = []
    for a in assets:
        if a["id"].startswith("wx_vfx_") and a.get("hdPath") and os.path.exists(os.path.join(ROOT, a["hdPath"])):
            src_im = Image.open(os.path.join(ROOT, a["hdPath"])).convert("RGBA")
            vfx_im = fit_canvas(src_im, 136, 136, pad=4)
            vfx_entries.append({
                "id": a["id"],
                "img": vfx_im,
                "ox": 0,
                "oy": 18,
                "src_rel": f"effects\\{a['id']}.png",
                "is_effect": True,
            })
        elif a["id"].startswith("wx_anim_") and a.get("animFrames"):
            for fi, f_rel in enumerate(a["animFrames"]):
                fp = os.path.join(ROOT, f_rel)
                if os.path.exists(fp):
                    fim = fit_canvas(Image.open(fp).convert("RGBA"), 144, 144, pad=4)
                    fid = f"{a['id']}_f{fi + 1}"
                    vfx_entries.append({
                        "id": fid,
                        "img": fim,
                        "ox": 0,
                        "oy": 18,
                        "src_rel": f"effects\\{fid}.png",
                        "is_effect": True,
                    })

    # Also compile 16 bespoke high-clarity Wuxia FX element primitives (`wx_fx_*`) for 72-skill choreography!
    for fp in sorted(glob.glob(os.path.join(ART_DIR, "fx_elements", "wx_fx_*.png"))):
        fid = os.path.splitext(os.path.basename(fp))[0]
        fim = fit_canvas(Image.open(fp).convert("RGBA"), 144, 144, pad=4)
        vfx_entries.append({
            "id": fid,
            "img": fim,
            "ox": 0,
            "oy": 18,
            "src_rel": f"effects\\{fid}.png",
            "is_effect": True,
        })

    # Also compile all 72 custom active skill overhead banners (`wx_ov_<skill>`) so skills never show vanilla `active_01`!
    for p in sorted(glob.glob(os.path.join(MOD_ROOT, "scripts", "skills", "actives", "*.nut"))):
        bn = os.path.splitext(os.path.basename(p))[0]
        if bn == "wx_move_base":
            continue
        icon_p = os.path.join(MOD_ROOT, "gfx", "ui", "skills", f"{bn}.png")
        if os.path.exists(icon_p):
            ov_im = fit_canvas(Image.open(icon_p).convert("RGBA"), 56, 56, pad=2)
            vfx_entries.append({
                "id": f"wx_ov_{bn}",
                "img": ov_im,
                "ox": 0,
                "oy": 0,
                "src_rel": f"skills\\{bn}.png",
                "is_effect": False,
            })

    if vfx_entries:
        # Remove any stale multi-page wx_effects_*.brush / .png before packing fresh <=2048x2048 pages
        for old_p in glob.glob(os.path.join(MOD_ROOT, "brushes", "wx_effects_*.brush")) + glob.glob(os.path.join(MOD_ROOT, "gfx", "wx_effects_*.png")):
            try:
                os.remove(old_p)
            except OSError:
                pass

        # Split cleanly into <=2048x2048 atlas pages so every OpenGL texture stays compact & fast
        page_size = 180
        total_vfx = 0
        for page_idx in range(0, len(vfx_entries), page_size):
            chunk = vfx_entries[page_idx:page_idx + page_size]
            p_num = page_idx // page_size
            atlas, recs = shelf_pack_sprites(chunk, max_atlas_w=2048)
            gfx_rel = f"gfx/wx_effects_{p_num}.png"
            brush_rel = f"brushes/wx_effects_{p_num}.brush"
            atlas.save(os.path.join(MOD_ROOT, gfx_rel))
            write_brush_binary(os.path.join(MOD_ROOT, brush_rel), gfx_rel, atlas.size, recs, is_effect_sheet=True)
            total_vfx += len(recs)
            print(f"Compiled {brush_rel}: {len(recs)} VFX/Anim/Overhead sprites ({atlas.size[0]}x{atlas.size[1]})")
        print(f"Total compiled Wuxia VFX & 72-Skill 4-Frame Action sprites: {total_vfx}")

    # 2. Shan Hai Bosses + Wild Beasts + Jianghu Enemy Busts (`wx_beasts_0.brush` -> `gfx/wx_beasts_0.png`)
    left_facing_enemy_busts = {
        "wx_char_enemy_corpse",
        "wx_char_enemy_yaoren",
        "wx_enemy_bandit_lord",
        "wx_enemy_nomad_khan",
        "wx_enemy_garrison_capt",
        "wx_enemy_shenji_officer",
        "wx_enemy_sword_saint",
        "wx_enemy_hedge_general",
        "wx_enemy_blade_dancer",
        "wx_enemy_wudu_shaman",
        "wx_enemy_wudu_overseer",
        "wx_enemy_barb_chosen",
        "wx_enemy_barb_drummer",
        "wx_enemy_yaoren_lord",
        "wx_enemy_corpse_taoist",
        "wx_enemy_tomb_wraith",
        "wx_enemy_ancient_lord",
        "wx_enemy_blood_vampire",
        "wx_enemy_emei_sword",
    }
    beast_entries = []
    for a in assets:
        aid = a["id"]
        if (aid.startswith("wx_boss_") or aid.startswith("wx_beast_") or aid.startswith("wx_enemy_") or aid.startswith("wx_char_enemy_")) and a.get("hdPath"):
            hp = os.path.join(ROOT, a["hdPath"])
            if os.path.exists(hp):
                src_im = Image.open(hp).convert("RGBA")
                if aid == "wx_boss_jingwei":
                    # Strip dark near-black rectangular border matte around Jingwei's wings
                    jpx = src_im.load()
                    jw, jh = src_im.size
                    from collections import deque
                    q_bg = deque()
                    vis = set()
                    for bx in range(jw):
                        for by in (0, jh - 1):
                            q_bg.append((bx, by))
                    for by in range(jh):
                        for bx in (0, jw - 1):
                            q_bg.append((bx, by))
                    while q_bg:
                        cx_p, cy_p = q_bg.popleft()
                        if (cx_p, cy_p) in vis:
                            continue
                        vis.add((cx_p, cy_p))
                        pr, pg, pb, pa = jpx[cx_p, cy_p]
                        if pa == 0 or (pr < 22 and pg < 26 and pb < 30):
                            jpx[cx_p, cy_p] = (0, 0, 0, 0)
                            for nx_p, ny_p in ((cx_p - 1, cy_p), (cx_p + 1, cy_p), (cx_p, cy_p - 1), (cx_p, cy_p + 1)):
                                if 0 <= nx_p < jw and 0 <= ny_p < jh and (nx_p, ny_p) not in vis:
                                    q_bg.append((nx_p, ny_p))
                # Apex bosses get heroic 156x156 tactical sprites (`oy=30`), standard beasts/enemies 104x142 (`oy=35`)
                is_boss = aid.startswith("wx_boss_")
                tw, th, oy = (156, 156, 30) if is_boss else (104, 142, 35)
                # Flip to face 3/4-right like vanilla Battle Brothers tactical entities!
                im_right = ImageOps.mirror(src_im) if (is_boss or aid.startswith("wx_beast_") or aid in left_facing_enemy_busts) else src_im
                beast_entries.append({
                    "id": aid,
                    "img": fit_canvas(im_right, tw, th, pad=4),
                    "ox": 0,
                    "oy": oy,
                    "src_rel": f"entity\\{aid}.png",
                    "is_effect": False,
                })
    if beast_entries:
        atlas, recs = shelf_pack_sprites(beast_entries, max_atlas_w=2048)
        atlas.save(os.path.join(MOD_ROOT, "gfx/wx_beasts_0.png"))
        write_brush_binary(os.path.join(MOD_ROOT, "brushes/wx_beasts_0.brush"), "gfx/wx_beasts_0.png", atlas.size, recs, is_effect_sheet=False)
        print(f"Compiled wx_beasts_0.brush: {len(recs)} Boss/Beast/Enemy sprites ({atlas.size[0]}x{atlas.size[1]})")

    # 3. Shan Hai World Map Lairs (`wx_world_0.brush` -> `gfx/wx_world_0.png`)
    world_entries = []
    for a in assets:
        aid = a["id"]
        if (aid.startswith("wx_lair_") or (aid.startswith("wx_shanhai_") and a["stage"] in ("4_beasts", "6_world"))) and a.get("hdPath"):
            hp = os.path.join(ROOT, a["hdPath"])
            if os.path.exists(hp):
                src_im = Image.open(hp).convert("RGBA")
                world_entries.append({
                    "id": aid,
                    "img": fit_canvas(src_im, 164, 124, pad=4),
                    "ox": 0,
                    "oy": 0,
                    "src_rel": f"world\\{aid}.png",
                    "is_effect": False,
                })
    if world_entries:
        atlas, recs = shelf_pack_sprites(world_entries, max_atlas_w=2048)
        atlas.save(os.path.join(MOD_ROOT, "gfx/wx_world_0.png"))
        write_brush_binary(os.path.join(MOD_ROOT, "brushes/wx_world_0.brush"), "gfx/wx_world_0.png", atlas.size, recs, is_effect_sheet=False)
        print(f"Compiled wx_world_0.brush: {len(recs)} World Lair sprites ({atlas.size[0]}x{atlas.size[1]})")

    # 4. Modular 104x142 Character Paperdoll Busts (`wx_busts_0.brush` -> `gfx/wx_busts_0.png`)
    bust_entries = []
    bust_folders = [
        ("head", ""),
        ("hair", ""),
        ("hair_tones", ""),
        ("hair_tucked", "_tucked"),
        ("hair_tucked_tones", ""),
        ("beard", ""),
        ("beard_tones", ""),
        ("scar", ""),
        ("back", ""),
        ("hat_back", "_back"),
        ("hat_front", "_front"),
        ("body", ""),
    ]
    for sub, suffix in bust_folders:
        for p in sorted(glob.glob(os.path.join(ART_DIR, "busts", sub, "*.png"))):
            base = os.path.splitext(os.path.basename(p))[0]
            sid = f"{base}{suffix}"
            im_208 = Image.open(p).convert("RGBA")
            # Downsample exact 2x `208x284` registered layer -> canonical vanilla `104x142` (`ox=0, oy=35`)!
            im_104 = im_208.resize((104, 142), Image.Resampling.LANCZOS)
            bust_entries.append({
                "id": sid,
                "img": im_104,
                "ox": 0,
                "oy": 35,
                "src_rel": f"entity\\bodies\\{sid}.png",
                "is_effect": False,
            })
    if bust_entries:
        atlas, recs = shelf_pack_sprites(bust_entries, max_atlas_w=2048)
        atlas.save(os.path.join(MOD_ROOT, "gfx/wx_busts_0.png"))
        write_brush_binary(os.path.join(MOD_ROOT, "brushes/wx_busts_0.brush"), "gfx/wx_busts_0.png", atlas.size, recs, is_effect_sheet=False)
        print(f"Compiled wx_busts_0.brush: {len(recs)} Modular 104x142 Character Bust sprites ({atlas.size[0]}x{atlas.size[1]})")

    # 5. Paperdoll Handheld Weapons (`arm_*`) & Offhand Shields (`shd_*`) (`wx_weapons_0.brush` -> `gfx/wx_weapons_0.png`)
    wpn_entries = []
    for sub, prefix in [("weapon", "arm_"), ("shield", "shd_")]:
        for p in sorted(glob.glob(os.path.join(ART_DIR, "busts", sub, "*.png"))):
            base = os.path.splitext(os.path.basename(p))[0]
            sid = f"{prefix}{base}"
            im_208 = Image.open(p).convert("RGBA")
            im_104 = im_208.resize((104, 142), Image.Resampling.LANCZOS)
            wpn_entries.append({
                "id": sid,
                "img": im_104,
                "ox": 0,
                "oy": 35,
                "src_rel": f"entity\\weapons\\{sid}.png",
                "is_effect": False,
            })
    if wpn_entries:
        atlas, recs = shelf_pack_sprites(wpn_entries, max_atlas_w=2048)
        atlas.save(os.path.join(MOD_ROOT, "gfx/wx_weapons_0.png"))
        write_brush_binary(os.path.join(MOD_ROOT, "brushes/wx_weapons_0.brush"), "gfx/wx_weapons_0.png", atlas.size, recs, is_effect_sheet=False)
        print(f"Compiled wx_weapons_0.brush: {len(recs)} Paperdoll Handheld Weapon & Shield sprites ({atlas.size[0]}x{atlas.size[1]})")

    # 6. Standalone Flying Projectiles & Trajectory Sprites (`wx_projectiles_0.brush` -> `gfx/wx_projectiles_0.png`)
    proj_canvas_map = {
        "wx_proj_feihuangshi":  (56, 80),
        "wx_proj_liuyefeidao":  (42, 96),
        "wx_proj_kongqueling":  (64, 96),
        "wx_proj_huochongdan":  (60, 98),
        "wx_proj_xiujian":      (44, 84),
        "wx_proj_shenjishi":    (48, 92),
        "wx_proj_diaolingjian": (38, 90),
        "wx_proj_liuxingjian":  (50, 98),
        "wx_proj_chuijian":     (36, 86),
        "wx_proj_sangmending":  (48, 90),
        "wx_proj_lihuazhen":    (62, 94),
        "wx_proj_touzhisuo":    (44, 102),
        "wx_proj_xuanfengbiao": (72, 72),
        "wx_proj_jinqianbiao":  (64, 86),
        "wx_proj_feishisuo":    (74, 74),
        "wx_proj_pilileihuo":   (74, 74),
    }
    proj_entries = []
    for p in sorted(glob.glob(os.path.join(ART_DIR, "projectiles", "wx_proj_*.png"))):
        sid = os.path.splitext(os.path.basename(p))[0]
        tw, th = proj_canvas_map.get(sid, (56, 92))
        src_im = Image.open(p).convert("RGBA")
        proj_im = fit_canvas(src_im, tw, th, pad=2)
        proj_entries.append({
            "id": sid,
            "img": proj_im,
            "ox": 0,
            "oy": 0,
            "src_rel": f"effects\\{sid}.png",
            "is_effect": True,
        })
    if proj_entries:
        atlas, recs = shelf_pack_sprites(proj_entries, max_atlas_w=1024)
        atlas.save(os.path.join(MOD_ROOT, "gfx/wx_projectiles_0.png"))
        write_brush_binary(os.path.join(MOD_ROOT, "brushes/wx_projectiles_0.brush"), "gfx/wx_projectiles_0.png", atlas.size, recs, is_effect_sheet=True)
        print(f"Compiled wx_projectiles_0.brush: {len(recs)} Standalone Flying Projectile sprites ({atlas.size[0]}x{atlas.size[1]})")

    # 7. World Map Chinese Settlements, Houses, Sect Gates, Camp & Ships (`wx_settlement_0.brush` -> `gfx/wx_settlement_0.png`)
    ws_meta_p = os.path.join(ART_DIR, "world_settlement", "_meta.json")
    if os.path.exists(ws_meta_p):
        ws_meta = json.load(open(ws_meta_p, "r", encoding="utf-8"))
        ws_entries = []
        for m in ws_meta:
            fp = os.path.join(ART_DIR, "world_settlement", m["file"])
            if os.path.exists(fp):
                ws_entries.append({
                    "id": m["id"],
                    "img": Image.open(fp).convert("RGBA"),
                    "ox": m["ox"],
                    "oy": m["oy"],
                    "src_rel": f"world_settlement\\{m['file']}",
                    "is_effect": False,
                })
        if ws_entries:
            atlas, recs = shelf_pack_sprites(ws_entries, max_atlas_w=2048)
            atlas.save(os.path.join(MOD_ROOT, "gfx/wx_settlement_0.png"))
            write_brush_binary(os.path.join(MOD_ROOT, "brushes/wx_settlement_0.brush"), "gfx/wx_settlement_0.png", atlas.size, recs, is_effect_sheet=False)
            print(f"Compiled wx_settlement_0.brush: {len(recs)} Chinese Settlement & Sect Gate sprites ({atlas.size[0]}x{atlas.size[1]})")

    # 8. World Map Marching Chess Pieces, Caravans, Vertical Party Flags & Modular Player Lead Busts (`wx_world_entity_0.brush`)
    we_meta_p = os.path.join(ART_DIR, "world_entity", "_meta.json")
    if os.path.exists(we_meta_p):
        we_meta = json.load(open(we_meta_p, "r", encoding="utf-8"))
        we_entries = []
        seen_we = set()
        for m in we_meta:
            fp = os.path.join(ART_DIR, "world_entity", m["file"])
            if os.path.exists(fp):
                seen_we.add(m["id"])
                we_entries.append({
                    "id": m["id"],
                    "img": Image.open(fp).convert("RGBA"),
                    "ox": m["ox"],
                    "oy": m["oy"],
                    "src_rel": f"world_entity\\{m['file']}",
                    "is_effect": False,
                })
        # Also pack `wm_<bust>` (`68x106, ox=0, oy=20`) modular world-map layers so `player_party` mirrors the player's actual #1 operated character!
        wm_folders = [
            ("head", ""),
            ("hair", ""),
            ("hair_tones", ""),
            ("hair_tucked", "_tucked"),
            ("hair_tucked_tones", ""),
            ("beard", ""),
            ("beard_tones", ""),
            ("hat_back", "_back"),
            ("hat_front", "_front"),
            ("body", ""),
        ]
        for sub, suffix in wm_folders:
            for p in sorted(glob.glob(os.path.join(ART_DIR, "busts", sub, "*.png"))):
                base = os.path.splitext(os.path.basename(p))[0]
                wm_id = f"wm_{base}{suffix}"
                if wm_id in seen_we:
                    continue
                seen_we.add(wm_id)
                im_208 = Image.open(p).convert("RGBA")
                we_entries.append({
                    "id": wm_id,
                    "img": make_world_bust_layer(im_208),
                    "ox": 0,
                    "oy": 20,
                    "src_rel": f"world_entity\\{wm_id}.png",
                    "is_effect": False,
                })
        if we_entries:
            atlas, recs = shelf_pack_sprites(we_entries, max_atlas_w=2048)
            atlas.save(os.path.join(MOD_ROOT, "gfx/wx_world_entity_0.png"))
            write_brush_binary(os.path.join(MOD_ROOT, "brushes/wx_world_entity_0.brush"), "gfx/wx_world_entity_0.png", atlas.size, recs, is_effect_sheet=False)
            print(f"Compiled wx_world_entity_0.brush: {len(recs)} World Marching Chess Pieces, Modular Lead Busts & Party Banners ({atlas.size[0]}x{atlas.size[1]})")

    # 9. Tactical Battlefield Bannerman Vertical War Standards & Shafts (`wx_banners_0.brush` -> `gfx/wx_banners_0.png`)
    tac_b_dir = os.path.join(ART_DIR, "banners_tactical")
    if os.path.exists(tac_b_dir):
        tb_entries = []
        for fp in sorted(glob.glob(os.path.join(tac_b_dir, "*.png"))):
            sid = os.path.splitext(os.path.basename(fp))[0]
            tb_entries.append({
                "id": sid,
                "img": Image.open(fp).convert("RGBA"),
                "ox": 0,
                "oy": 35,
                "src_rel": f"entity_icons\\{sid}.png",
                "is_effect": False,
            })
        if tb_entries:
            atlas, recs = shelf_pack_sprites(tb_entries, max_atlas_w=2048)
            atlas.save(os.path.join(MOD_ROOT, "gfx/wx_banners_0.png"))
            write_brush_binary(os.path.join(MOD_ROOT, "brushes/wx_banners_0.brush"), "gfx/wx_banners_0.png", atlas.size, recs, is_effect_sheet=False)
            print(f"Compiled wx_banners_0.brush: {len(recs)} Tactical Bannerman War Standards & Shafts ({atlas.size[0]}x{atlas.size[1]})")

    # 10. Tactical Fallen Corpse Decals (`wx_corpses_0.brush` -> `gfx/wx_corpses_0.png`)
    #     Covers all modular character bust layers (`*_dead`) + all custom enemies/beasts/bosses (`*_dead`) at exact vanilla `131x125 (ox=6, oy=10)`!
    corpse_entries = []
    seen_corpses = set()
    for idx, ent in enumerate(bust_entries):
        cid = f"{ent['id']}_dead"
        if cid in seen_corpses:
            continue
        seen_corpses.add(cid)
        is_b = ent["id"].startswith("wx_body_") or ent["id"].startswith("wx_char_")
        corpse_entries.append({
            "id": cid,
            "img": make_fallen_corpse_layer(ent["img"], is_body_base=is_b, seed_val=idx),
            "ox": 6,
            "oy": 10,
            "src_rel": f"entity\\corpses\\{cid}.png",
            "is_effect": False,
        })
    for idx, ent in enumerate(beast_entries):
        cid = f"{ent['id']}_dead"
        if cid in seen_corpses:
            continue
        seen_corpses.add(cid)
        corpse_entries.append({
            "id": cid,
            "img": make_fallen_corpse_layer(ent["img"], is_body_base=True, seed_val=idx + 500),
            "ox": 6,
            "oy": 10,
            "src_rel": f"entity\\corpses\\{cid}.png",
            "is_effect": False,
        })
    if corpse_entries:
        atlas, recs = shelf_pack_sprites(corpse_entries, max_atlas_w=2048)
        atlas.save(os.path.join(MOD_ROOT, "gfx/wx_corpses_0.png"))
        write_brush_binary(os.path.join(MOD_ROOT, "brushes/wx_corpses_0.brush"), "gfx/wx_corpses_0.png", atlas.size, recs, is_effect_sheet=False)
        print(f"Compiled wx_corpses_0.brush: {len(recs)} Fallen Tactical Corpse Decals ({atlas.size[0]}x{atlas.size[1]})")


if __name__ == "__main__":
    compile_all()
