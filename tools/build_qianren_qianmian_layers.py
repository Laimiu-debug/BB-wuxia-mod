#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Builds the remaining modular layers for Stage 3 ("千人千面" Full In-Game Integration):
  1. `art/busts/back/wx_back_01..16.png` (208x284 registered paperdoll back/cloak/chest-gear layers)
     + `mod_wuxia/gfx/ui/items/armor_upgrades/wx_back_01..16.png` (70x70 loose item icons)
  2. `art/busts/hat_back/wx_char_hat_*.png` & `art/busts/hat_front/wx_char_hat_*.png` (4 classic hats)
  3. Multi-tone hair & beard variants (`_brown`, `_grey`, `_white`) for `wx_hair_01..24`,
     `wx_hair_01..24_tucked`, and `wx_beard_01..24` so any character can wear black / weathered-brown /
     salt-and-pepper grey / crane-white hair & beard in-game!
  4. Outputs visual QA sheet to verify exact Battle Brothers z-stack alignment!
"""

import glob
import json
import os
import sys
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import build_wuxia_bust_system as bsys

ART_DIR = os.path.join(ROOT, "art")
BUSTS_DIR = os.path.join(ART_DIR, "busts")
MOD_ROOT = os.path.join(ROOT, "mod_wuxia")
W, H = 208, 284


def clear_interior_white_holes(rgba: Image.Image) -> Image.Image:
    """Clears enclosed white studio holes inside closed straps/chains (e.g. abacus chain, map strap)."""
    out = rgba.copy()
    px = out.load()
    w, h = out.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a > 0 and min(r, g, b) >= 228 and (max(r, g, b) - min(r, g, b)) <= 16:
                px[x, y] = (0, 0, 0, 0)
            elif a > 0 and min(r, g, b) >= 205 and (max(r, g, b) - min(r, g, b)) <= 12:
                px[x, y] = (r, g, b, int(a * 0.25))
    return bsys.decontaminate_white_fringe(out, passes=1)


def register_back_bust(raw_hd: Image.Image, aid: str, ped_tmask: Image.Image) -> Image.Image:
    """
    Registers `wx_back_01..16` onto the canonical `208x284` (`104x142` 1x) bust canvas
    for rendering on `armor_upgrade_back` (`z > body`, `z < head`).
    """
    tc = bsys.decontaminate_white_fringe(bsys.tight_crop(raw_hd), passes=1)
    idx = int(aid.split("_")[-1])
    if idx in (4, 5, 7, 15, 16):
        tc = clear_interior_white_holes(tc)

    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))

    # Build neck/face hole & front-of-face guard so nothing protrudes awkwardly past the nose
    front_face_air = Image.new("L", (W, H), 0)
    ImageDraw.Draw(front_face_air).polygon([
        (106, 30), (208, 30), (208, 152), (138, 152), (106, 132)
    ], fill=255)
    front_face_air = front_face_air.filter(ImageFilter.GaussianBlur(1.2))

    if idx in (1, 3, 13):
        # Full shoulder cloaks / wolf pelt / straw rain-cape
        im = ImageOps.mirror(tc)
        tw = 190 if idx != 3 else 192
        th = max(108, min(146, int(round(tw * (im.height / float(max(1, im.width)))))))
        im_s = bsys.decontaminate_white_fringe(bsys.bb_grade(im.resize((tw, th), Image.Resampling.LANCZOS)), passes=1)
        tx = (W - tw) // 2
        ty = 124 if idx == 3 else (132 if idx == 1 else 135)
        layer.alpha_composite(im_s, (tx, ty))
        px = layer.load()
        for y in range(216, 254):
            s = max(0.38, 1.0 - (y - 216) / 52.0)
            for x in range(W):
                r, g, b, a = px[x, y]
                if a > 0:
                    px[x, y] = (int(r * s), int(g * s), int(b * s), a)
        layer.putalpha(bsys.bool_intersect(layer.getchannel("A"), ped_tmask))

    elif idx == 14:
        # Tiger-pelt shoulder cape (`wx_back_14`): align collar cutout (`0.66*w` when mirrored) to chin `x=108`!
        im = ImageOps.mirror(tc)
        mantle = im.crop((0, 0, im.width, int(im.height * 0.78)))
        tw = 204
        th = max(112, min(142, int(round(tw * (mantle.height / float(max(1, mantle.width)))))))
        im_s = bsys.decontaminate_white_fringe(bsys.bb_grade(mantle.resize((tw, th), Image.Resampling.LANCZOS)), passes=1)
        layer.alpha_composite(im_s, (W // 2 - int(tw * 0.63), 128))
        px = layer.load()
        for y in range(214, 254):
            s = max(0.38, 1.0 - (y - 214) / 52.0)
            for x in range(W):
                r, g, b, a = px[x, y]
                if a > 0:
                    px[x, y] = (int(r * s), int(g * s), int(b * s), a)
        layer.putalpha(bsys.bool_intersect(layer.getchannel("A"), ped_tmask))

    elif idx == 2:
        # Black tattered night-crow short cloak (`wx_back_02` has a hood top in `0..0.36*h`: crop mantle shoulders!)
        im = ImageOps.mirror(tc)
        mantle = im.crop((0, int(im.height * 0.31), im.width, im.height))
        tw = 186
        th = max(96, min(124, int(round(tw * (mantle.height / float(max(1, mantle.width)))))))
        im_s = bsys.decontaminate_white_fringe(bsys.bb_grade(mantle.resize((tw, th), Image.Resampling.LANCZOS)), passes=1)
        layer.alpha_composite(im_s, ((W - tw) // 2, 136))
        layer.putalpha(bsys.bool_intersect(layer.getchannel("A"), ped_tmask))

    elif idx in (4, 12):
        # Sword-box (`04`) & Copper-coin sword (`12`): mirror so hilt rises behind LEFT shoulder (`x=22..96, y=54..190`)!
        im = ImageOps.mirror(tc)
        tw = 128 if idx == 4 else 118
        th = max(110, min(148, int(round(tw * (im.height / float(max(1, im.width)))))))
        im_s = bsys.decontaminate_white_fringe(bsys.bb_grade(im.resize((tw, th), Image.Resampling.LANCZOS)), passes=1)
        layer.alpha_composite(im_s, (18, 56 if idx == 4 else 62))
        a = bsys.bool_subtract(layer.getchannel("A"), front_face_air)
        # Subtract lower-right torso stomach area so only upper back sword-box & upper shoulder strap show!
        torso_belly = Image.new("L", (W, H), 0)
        ImageDraw.Draw(torso_belly).ellipse([56, 168, 178, 260], fill=255)
        a = bsys.bool_subtract(a, torso_belly.filter(ImageFilter.GaussianBlur(2.0)))
        upper_keep = Image.new("L", (W, H), 0)
        ImageDraw.Draw(upper_keep).rectangle([0, 0, W, 152], fill=255)
        valid_zone = bsys.bool_union(upper_keep, ped_tmask)
        layer.putalpha(bsys.bool_intersect(a, valid_zone))

    elif idx == 5:
        # Crossed twin sabers on BACK (`05`): keep twin hilts rising behind shoulders (`y <= 156`) + shoulder straps,
        # boolean-subtract front chest torso (`[36..176, 156..265]`) so blades sit BEHIND the back, not on the stomach!
        im = tc.copy()
        tw = 172
        th = max(118, min(154, int(round(tw * (im.height / float(max(1, im.width)))))))
        im_s = bsys.decontaminate_white_fringe(bsys.bb_grade(im.resize((tw, th), Image.Resampling.LANCZOS)), passes=1)
        layer.alpha_composite(im_s, (16, 62))
        hide_front_torso = Image.new("L", (W, H), 0)
        hd = ImageDraw.Draw(hide_front_torso)
        hd.rectangle([144, 0, W, 146], fill=255)
        hd.ellipse([32, 154, 180, 268], fill=255)
        a = bsys.bool_subtract(layer.getchannel("A"), hide_front_torso.filter(ImageFilter.GaussianBlur(1.5)))
        upper_keep = Image.new("L", (W, H), 0)
        ImageDraw.Draw(upper_keep).rectangle([0, 0, W, 160], fill=255)
        layer.putalpha(bsys.bool_intersect(a, bsys.bool_union(upper_keep, ped_tmask)))

    elif idx in (6, 7):
        # Giant red wine gourd (`06`) & Bamboo herb basket (`07`) behind LEFT shoulder
        im = ImageOps.mirror(tc) if idx == 6 else tc.copy()
        tw = 94 if idx == 6 else 96
        th = max(92, min(130, int(round(tw * (im.height / float(max(1, im.width)))))))
        im_s = bsys.decontaminate_white_fringe(bsys.bb_grade(im.resize((tw, th), Image.Resampling.LANCZOS)), passes=1)
        layer.alpha_composite(im_s, (16, 86))
        a = bsys.bool_subtract(layer.getchannel("A"), front_face_air)
        upper_keep = Image.new("L", (W, H), 0)
        ImageDraw.Draw(upper_keep).rectangle([0, 0, W, 152], fill=255)
        layer.putalpha(bsys.bool_intersect(a, bsys.bool_union(upper_keep, ped_tmask)))

    elif idx == 16:
        # Map scroll cylinder (`16`): mirror so cylinder peeks behind LEFT shoulder & leather strap crosses chest!
        im = ImageOps.mirror(tc)
        tw = 108
        th = max(86, min(116, int(round(tw * (im.height / float(max(1, im.width)))))))
        im_s = bsys.decontaminate_white_fringe(bsys.bb_grade(im.resize((tw, th), Image.Resampling.LANCZOS)), passes=1)
        layer.alpha_composite(im_s, (12, 86))
        # Subtract lower front chest `[56..180, 162..260]` so the cylinder sits behind left shoulder!
        belly = Image.new("L", (W, H), 0)
        ImageDraw.Draw(belly).ellipse([58, 162, 182, 260], fill=255)
        a = bsys.bool_subtract(bsys.bool_subtract(layer.getchannel("A"), front_face_air), belly.filter(ImageFilter.GaussianBlur(1.6)))
        upper_keep = Image.new("L", (W, H), 0)
        ImageDraw.Draw(upper_keep).rectangle([0, 0, W, 154], fill=255)
        layer.putalpha(bsys.bool_intersect(a, bsys.bool_union(upper_keep, ped_tmask)))

    elif idx == 8:
        # Escort command pennant (`08`): flagpole behind left shoulder, pennant flutters LEFT!
        im = ImageOps.mirror(tc)
        tw = 104
        th = max(104, min(136, int(round(tw * (im.height / float(max(1, im.width)))))))
        im_s = bsys.decontaminate_white_fringe(bsys.bb_grade(im.resize((tw, th), Image.Resampling.LANCZOS)), passes=1)
        layer.alpha_composite(im_s, (8, 48))
        upper_keep = Image.new("L", (W, H), 0)
        ImageDraw.Draw(upper_keep).rectangle([0, 0, W, 156], fill=255)
        layer.putalpha(bsys.bool_intersect(layer.getchannel("A"), bsys.bool_union(upper_keep, ped_tmask)))

    elif idx == 9:
        # Four war-banners (`节度镇军四面护背大靠旗`): fan grandly behind shoulders (`y=32..172`)!
        im = ImageOps.mirror(tc)
        tw = 162
        th = max(124, min(154, int(round(tw * (im.height / float(max(1, im.width)))))))
        im_s = bsys.decontaminate_white_fringe(bsys.bb_grade(im.resize((tw, th), Image.Resampling.LANCZOS)), passes=1)
        layer.alpha_composite(im_s, (6, 32))
        a = bsys.bool_subtract(layer.getchannel("A"), front_face_air)
        upper_keep = Image.new("L", (W, H), 0)
        ImageDraw.Draw(upper_keep).rectangle([0, 0, W, 160], fill=255)
        layer.putalpha(bsys.bool_intersect(a, bsys.bool_union(upper_keep, ped_tmask)))

    elif idx in (10, 11):
        # Crossed hidden-weapon bandolier (`10`) & Shaolin 108 prayer beads (`11`) across chest
        im = ImageOps.mirror(tc) if idx == 10 else tc.copy()
        tw = 142 if idx == 10 else 138
        th = max(96, min(118, int(round(tw * (im.height / float(max(1, im.width)))))))
        im_s = bsys.decontaminate_white_fringe(bsys.bb_grade(im.resize((tw, th), Image.Resampling.LANCZOS)), passes=1)
        layer.alpha_composite(im_s, ((W - tw) // 2 + 2, 144 if idx == 11 else 148))
        layer.putalpha(bsys.bool_intersect(layer.getchannel("A"), ped_tmask))

    else:
        # `15`: Black-iron abacus on chain at left chest/waist (interior white cleared!)
        im = tc.copy()
        tw = 86
        th = max(70, min(94, int(round(tw * (im.height / float(max(1, im.width)))))))
        im_s = bsys.decontaminate_white_fringe(bsys.bb_grade(im.resize((tw, th), Image.Resampling.LANCZOS)), passes=1)
        layer.alpha_composite(im_s, (34, 158))
        layer.putalpha(bsys.bool_intersect(layer.getchannel("A"), ped_tmask))

    return bsys.bake_self_drop_shadow(layer, dx=0, dy=3, blur=2.4, alpha_scale=0.50)


def fit_icon_70(rgba: Image.Image) -> Image.Image:
    tc = bsys.decontaminate_white_fringe(bsys.tight_crop(rgba), passes=1)
    s = min(62.0 / float(max(1, tc.width)), 62.0 / float(max(1, tc.height)))
    nw, nh = max(1, int(round(tc.width * s))), max(1, int(round(tc.height * s)))
    im = tc.resize((nw, nh), Image.Resampling.LANCZOS)
    out = Image.new("RGBA", (70, 70), (0, 0, 0, 0))
    out.alpha_composite(im, ((70 - nw) // 2, (70 - nh) // 2))
    return out


def tint_bust_hair_layer(layer_rgba: Image.Image, tone: str) -> Image.Image:
    """
    Produces crisp Overhype-palette hair/beard tone variants (`brown`, `grey`, `white`)
    preserving dark drop-shadows & outer ink outlines while recoloring hair strands!
    """
    out = layer_rgba.copy()
    px = out.load()
    w, h = out.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a <= 12:
                continue
            # Keep soft drop-shadow pixels (`a < 180` and very dark) dark!
            lum = 0.299 * r + 0.587 * g + 0.114 * b
            if a < 185 and lum < 26:
                continue
            if lum < 17:
                # Slight lift on pure ink interior only for white/grey so outlines stay crisp dark!
                if tone == "white":
                    px[x, y] = (34, 32, 30, a)
                elif tone == "grey":
                    px[x, y] = (24, 23, 22, a)
                continue
            if tone == "brown":
                nr = min(235, int(lum * 1.24 + 28))
                ng = min(205, int(lum * 0.90 + 14))
                nb = min(175, int(lum * 0.62 + 6))
            elif tone == "grey":
                nl = min(210, int(lum * 1.32 + 46))
                nr, ng, nb = nl, int(nl * 0.99), int(nl * 0.95)
            elif tone == "white":
                nl = min(236, int(lum * 1.48 + 82))
                nr, ng, nb = nl, int(nl * 0.98), int(nl * 0.93)
            else:
                nr, ng, nb = r, g, b
            px[x, y] = (nr, ng, nb, a)
    return out


def main():
    for sub in ("back", "hair_tones", "hair_tucked_tones", "beard_tones"):
        os.makedirs(os.path.join(BUSTS_DIR, sub), exist_ok=True)
    upg_icon_dir = os.path.join(MOD_ROOT, "gfx", "ui", "items", "armor_upgrades")
    os.makedirs(upg_icon_dir, exist_ok=True)
    art_upg_dir = os.path.join(ART_DIR, "game", "ui", "items", "armor_upgrades")
    os.makedirs(art_upg_dir, exist_ok=True)

    ped_back, ped_front, ped_tmask = bsys.make_pedestal_layers()

    # 1. Build all 16 `wx_back_01..16` bust layers + 70x70 armor_upgrade UI icons
    for i in range(1, 17):
        aid = f"wx_back_{i:02d}"
        hd_p = os.path.join(ART_DIR, "hd", f"{aid}.png")
        raw = Image.open(hd_p).convert("RGBA")
        b_layer = register_back_bust(raw, aid, ped_tmask)
        b_layer.save(os.path.join(BUSTS_DIR, "back", f"{aid}.png"))
        ic70 = fit_icon_70(raw)
        ic70.save(os.path.join(upg_icon_dir, f"{aid}.png"))
        ic70.save(os.path.join(art_upg_dir, f"{aid}.png"))

    # 2. Build the 4 classic `wx_char_hat_*` hats into `hat_back` & `hat_front`
    char_hat_templates = {
        "wx_char_hat_bamboo":       "wx_hat_07",
        "wx_char_hat_topknot":      "wx_hat_14",
        "wx_char_hat_taoist":       "wx_hat_09",
        "wx_char_hat_helm_fengchi": "wx_hat_30",
    }
    for ch_id, tpl_id in char_hat_templates.items():
        hd_p = os.path.join(ART_DIR, "hd", f"{ch_id}.png")
        if os.path.exists(hd_p):
            src_im = Image.open(hd_p).convert("RGBA")
            hb, hf, hcomb = bsys.register_hat_boolean(ImageOps.mirror(src_im), tpl_id)
            hb.save(os.path.join(BUSTS_DIR, "hat_back", f"{ch_id}.png"))
            hf.save(os.path.join(BUSTS_DIR, "hat_front", f"{ch_id}.png"))
            hcomb.save(os.path.join(BUSTS_DIR, "hat", f"{ch_id}.png"))

    # 3. Build `_brown`, `_grey`, `_white` tone variants for hairs, tucked hairs & beards
    tone_cnt = 0
    for tone in ("brown", "grey", "white"):
        for i in range(1, 25):
            hid = f"wx_hair_{i:02d}"
            h_im = Image.open(os.path.join(BUSTS_DIR, "hair", f"{hid}.png")).convert("RGBA")
            tint_bust_hair_layer(h_im, tone).save(os.path.join(BUSTS_DIR, "hair_tones", f"{hid}_{tone}.png"))

            ht_im = Image.open(os.path.join(BUSTS_DIR, "hair_tucked", f"{hid}.png")).convert("RGBA")
            tint_bust_hair_layer(ht_im, tone).save(os.path.join(BUSTS_DIR, "hair_tucked_tones", f"{hid}_tucked_{tone}.png"))

            bid = f"wx_beard_{i:02d}"
            b_im = Image.open(os.path.join(BUSTS_DIR, "beard", f"{bid}.png")).convert("RGBA")
            tint_bust_hair_layer(b_im, tone).save(os.path.join(BUSTS_DIR, "beard_tones", f"{bid}_{tone}.png"))
            tone_cnt += 3

    # 4. Update `art/manifest.json` so `wx_back_01..16` record their `bustPath` & `pdRole="back"`
    manifest_path = os.path.join(ART_DIR, "manifest.json")
    manifest = json.load(open(manifest_path, "r", encoding="utf-8"))
    for a in manifest["assets"]:
        aid = a["id"]
        if aid.startswith("wx_back_"):
            a["bustPath"] = f"art/busts/back/{aid}.png"
            a["pdRole"] = "back"
            a["status"] = "in_game"
            a["gameTarget"] = f"brushes/wx_busts_0.brush#{aid}"
            a["codeRef"] = "mod_wuxia/config/wx_appearance.nut"
        elif aid in char_hat_templates:
            a["bustPath"] = f"art/busts/hat/{aid}.png"
            a["bustBackPath"] = f"art/busts/hat_back/{aid}.png"
            a["bustFrontPath"] = f"art/busts/hat_front/{aid}.png"
            a["status"] = "in_game"
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)

    # 5. Render Visual QA Contact Sheet (`8x2` = all 16 `wx_back_01..16` + `hat_back/front` + hair tones!)
    qa = Image.new("RGBA", (8 * 136, 2 * 182), (22, 17, 13, 255))
    demo_specs = [
        ("wx_body_hvy_06",  "wx_back_01", "wx_hat_30", "wx_head_15", "wx_beard_17", "wx_hair_01", "",       "wx_scar_01"),
        ("wx_body_sect_10", "wx_back_02", "wx_hat_08", "wx_head_07", None,          "wx_hair_11", "",       None),
        ("wx_body_arm_06",  "wx_back_03", "wx_hat_19", "wx_head_06", "wx_beard_19", "wx_hair_06", "_brown", "wx_scar_11"),
        ("wx_body_sect_03", "wx_back_04", None,        "wx_head_04", "wx_beard_14", "wx_hair_09", "_white", None),
        ("wx_body_arm_02",  "wx_back_05", "wx_hat_03", "wx_head_24", "wx_beard_10", "wx_hair_16", "",       "wx_scar_03"),
        ("wx_body_sect_05", "wx_back_06", None,        "wx_head_11", "wx_beard_02", "wx_hair_22", "_grey",  None),
        ("wx_body_civ_06",  "wx_back_07", "wx_hat_02", "wx_head_43", None,          "wx_hair_12", "",       None),
        ("wx_body_arm_01",  "wx_back_08", "wx_hat_25", "wx_head_18", "wx_beard_09", "wx_hair_01", "",       None),
        ("wx_body_hvy_02",  "wx_back_09", "wx_hat_27", "wx_head_30", "wx_beard_15", "wx_hair_17", "",       "wx_scar_02"),
        ("wx_body_sect_09", "wx_back_10", "wx_hat_17", "wx_head_20", None,          "wx_hair_11", "_brown", None),
        ("wx_body_sect_01", "wx_back_11", "wx_hat_13", "wx_head_08", "wx_beard_16", None,         "",       "wx_scar_08"),
        ("wx_body_sect_02", "wx_back_12", "wx_hat_09", "wx_head_09", "wx_beard_24", "wx_hair_14", "_white", None),
        ("wx_body_civ_04",  "wx_back_13", "wx_hat_07", "wx_head_23", "wx_beard_20", "wx_hair_05", "_grey",  None),
        ("wx_body_hvy_05",  "wx_back_14", None,        "wx_head_03", "wx_beard_18", "wx_hair_24", "",       "wx_scar_04"),
        ("wx_body_civ_11",  "wx_back_15", "wx_hat_05", "wx_head_28", "wx_beard_11", "wx_hair_07", "_grey",  "wx_scar_09"),
        ("wx_body_sect_16", "wx_back_16", "wx_hat_12", "wx_head_34", None,          "wx_hair_10", "_brown", None),
    ]
    open_crown = {"wx_hat_01", "wx_hat_09", "wx_hat_10", "wx_hat_12", "wx_hat_13", "wx_hat_14", "wx_hat_15", "wx_hat_16", "wx_hat_17", "wx_hat_21", "wx_hat_22"}
    for idx, (tid, bkid, htid, hid, bdid, hrid, tone, scid) in enumerate(demo_specs):
        r, c = divmod(idx, 8)
        im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        im.alpha_composite(ped_back)
        im.alpha_composite(Image.open(os.path.join(BUSTS_DIR, "body", f"{tid}.png")))
        im.alpha_composite(Image.open(os.path.join(BUSTS_DIR, "back", f"{bkid}.png")))
        im.alpha_composite(ped_front)
        if htid:
            im.alpha_composite(Image.open(os.path.join(BUSTS_DIR, "hat_back", f"{htid}.png")))
        im.alpha_composite(Image.open(os.path.join(BUSTS_DIR, "head", f"{hid}.png")))
        if scid:
            im.alpha_composite(Image.open(os.path.join(BUSTS_DIR, "scar", f"{scid}.png")))
        if bdid:
            bp = os.path.join(BUSTS_DIR, "beard_tones" if tone else "beard", f"{bdid}{tone}.png")
            im.alpha_composite(Image.open(bp))
        if hrid:
            tucked = bool(htid and htid not in open_crown)
            if tucked:
                hp = os.path.join(BUSTS_DIR, "hair_tucked_tones" if tone else "hair_tucked", f"{hrid}{'_tucked' + tone if tone else ''}.png")
            else:
                hp = os.path.join(BUSTS_DIR, "hair_tones" if tone else "hair", f"{hrid}{tone}.png")
            im.alpha_composite(Image.open(hp))
        if htid:
            im.alpha_composite(Image.open(os.path.join(BUSTS_DIR, "hat_front", f"{htid}.png")))
        card = im.resize((128, 174), Image.Resampling.LANCZOS)
        qa.alpha_composite(card, (c * 136 + 4, r * 182 + 4))

    qa_out = r"C:\Users\25647\.gemini\antigravity\brain\e42daea8-659d-4828-9640-bca555d0d789\scratch\qa_qianren_qianmian.jpg"
    os.makedirs(os.path.dirname(qa_out), exist_ok=True)
    qa.convert("RGB").save(qa_out, quality=95)
    print(f"SUCCESS: Built 16 wx_back layers, 4 wx_char_hat pairs, {tone_cnt} multi-tone hair/beard layers, and QA sheet!")


if __name__ == "__main__":
    main()
