#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Wave 70..86 — 100% 1-to-1 Bespoke Manual Medallion Icon Pipeline (265 New + 11 Existing = 276/276 Manuals):
  1. Slices 17 hand-painted Battle Brothers x Ming Wuxia medallion sprite sheets (16 x 4x4 + 1 x 3x3 = 265)
     using per-cell foreground connected-component circle detection (immune to minor outer-margin variance)
     and 4x super-sampled anti-aliased circular masking with crisp 1px dark contour.
  2. Outputs 265 `56x56` RGBA `.png` + 265 `56x56` disabled grayscale `_sw.png` into `mod_wuxia/gfx/ui/perks/`.
  3. Updates all 265 manual `Icon` fields across `mod_wuxia/mod_wuxia/config/manuals*.nut` so all 276/276
     manuals in `::Wuxia.Config.Manuals` have 1-to-1 unique icons (`ui/perks/<id>.png`).
  4. Syncs `山海武侠.html` (`wx-bundle`): embeds all 265 `48x48` RGBA WebP data URIs, adds the missing
     276th manual `wx_manual_yaqi_zhenzhen` (`牙旗镇阵枪`) with full sect/skill cross-links, garbage-collects
     orphaned generic manual icon keys, and updates summary stats (`276` manuals, `276` unique manual icons).
"""

import base64
from collections import Counter, deque
import io
import json
import re
from pathlib import Path
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parent.parent
MOD_ROOT = ROOT / "mod_wuxia"
PERKS_DIR = MOD_ROOT / "gfx" / "ui" / "perks"
WIKI_PATH = ROOT / "山海武侠.html"

BRAIN_DIR = Path(r"C:\Users\25647\.gemini\antigravity\brain\bb87a7c5-4986-42c6-969d-189d212a5c75")
SPEC_PATH = BRAIN_DIR / "scratch" / "sheets_70_86_spec.json"

SHEET_FILES = {
    70: BRAIN_DIR / "wx_manuals_sheet_70_v3_1795406932156.jpg",
    71: BRAIN_DIR / "wx_manuals_sheet_71_1795406885739.jpg",
    72: BRAIN_DIR / "wx_manuals_sheet_72_1795406866694.jpg",
    73: BRAIN_DIR / "wx_manuals_sheet_73_1795406894866.jpg",
    74: BRAIN_DIR / "wx_manuals_sheet_74_1795406866678.jpg",
    75: BRAIN_DIR / "wx_manuals_sheet_75_1795406864726.jpg",
    76: BRAIN_DIR / "wx_manuals_sheet_76_final_1795407043342.jpg",
    77: BRAIN_DIR / "wx_manuals_sheet_77_1795406991834.jpg",
    78: BRAIN_DIR / "wx_manuals_sheet_78_1795407047100.jpg",
    79: BRAIN_DIR / "wx_manuals_sheet_79_1795406993280.jpg",
    80: BRAIN_DIR / "wx_manuals_sheet_80_v2_1795407029171.jpg",
    81: BRAIN_DIR / "wx_manuals_sheet_81_1795407026793.jpg",
    82: BRAIN_DIR / "wx_manuals_sheet_82_1795407146278.jpg",
    83: BRAIN_DIR / "wx_manuals_sheet_83_v3_1795407184053.jpg",
    84: BRAIN_DIR / "wx_manuals_sheet_84_1795407182147.jpg",
    85: BRAIN_DIR / "wx_manuals_sheet_85_1795407188760.jpg",
    86: BRAIN_DIR / "wx_manuals_sheet_86_1795407131136.jpg",
}


def detect_medallion_circle(cell_rgb: Image.Image) -> tuple[float, float, float]:
    """
    Finds the exact largest non-white foreground component inside `cell_rgb`
    and returns `(cx, cy, radius)` in cell coordinates.
    """
    w, h = cell_rgb.size
    px = cell_rgb.load()
    fg = bytearray(w * h)
    for y in range(h):
        row = y * w
        for x in range(w):
            r, g, b = px[x, y]
            # Foreground if darker than pure white paper or noticeably chromatic
            if min(r, g, b) < 236 or (max(r, g, b) - min(r, g, b)) > 16:
                fg[row + x] = 1

    vis = bytearray(w * h)
    best_bbox = None
    best_area = 0
    for y in range(h):
        row = y * w
        for x in range(w):
            idx = row + x
            if fg[idx] and not vis[idx]:
                vis[idx] = 1
                q = deque([(x, y)])
                cnt = 0
                x0 = x1 = x
                y0 = y1 = y
                while q:
                    cx, cy = q.popleft()
                    cnt += 1
                    if cx < x0:
                        x0 = cx
                    if cx > x1:
                        x1 = cx
                    if cy < y0:
                        y0 = cy
                    if cy > y1:
                        y1 = cy
                    for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
                        if 0 <= nx < w and 0 <= ny < h:
                            nidx = ny * w + nx
                            if fg[nidx] and not vis[nidx]:
                                vis[nidx] = 1
                                q.append((nx, ny))
                if cnt > best_area:
                    best_area = cnt
                    best_bbox = (x0, y0, x1 + 1, y1 + 1)

    if not best_bbox:
        raise RuntimeError("Empty cell — no medallion detected!")

    bx0, by0, bx1, by1 = best_bbox
    bw = bx1 - bx0
    bh = by1 - by0
    ratio = bw / float(max(1, bh))
    if not (0.88 <= ratio <= 1.14) or bw < w * 0.65:
        raise RuntimeError(f"Abnormal medallion bbox={best_bbox} in {w}x{h} cell (ratio={ratio:.3f})")

    cx = (bx0 + bx1) / 2.0
    cy = (by0 + by1) / 2.0
    # Slightly inset radius by 0.8px to shave off white JPEG anti-alias fringe along outer rim
    rad = (min(bw, bh) / 2.0) - 0.8
    return cx, cy, rad


def extract_circular_rgba(cell_rgb: Image.Image, cx: float, cy: float, rad: float) -> Image.Image:
    """
    Crops a crisp square around `(cx, cy)` with radius `rad` and applies a 4x super-sampled
    circular alpha mask so 100% of exterior pixels are pure `RGBA(0, 0, 0, 0)`.
    """
    half = int(round(rad))
    diam = half * 2
    x0 = int(round(cx)) - half
    y0 = int(round(cy)) - half

    patch = Image.new("RGB", (diam, diam), (255, 255, 255))
    src_x0 = max(0, x0)
    src_y0 = max(0, y0)
    src_x1 = min(cell_rgb.width, x0 + diam)
    src_y1 = min(cell_rgb.height, y0 + diam)
    sub = cell_rgb.crop((src_x0, src_y0, src_x1, src_y1))
    patch.paste(sub, (src_x0 - x0, src_y0 - y0))

    # 4x super-sampled circular mask
    ss = diam * 4
    mask_ss = Image.new("L", (ss, ss), 0)
    md = ImageDraw.Draw(mask_ss)
    md.ellipse([2, 2, ss - 3, ss - 3], fill=255)
    mask = mask_ss.resize((diam, diam), Image.Resampling.LANCZOS)

    rgba = patch.convert("RGBA")
    rgba.putalpha(mask)
    return rgba


def render_medallion_size(hd_circle: Image.Image, target_sz: int, pad: int = 2) -> Image.Image:
    """
    Renders `hd_circle` into `(target_sz, target_sz)` with `pad`px margin (so `56x56` has
    `52x52` circle at `(2,2)..(54,54)`, matching `wx_manual_shanhai_zhuyan.png`) plus
    a crisp 1px dark ink outer rim contour for clean separation on dark & parchment UIs.
    """
    inner = target_sz - 2 * pad
    scaled = hd_circle.resize((inner, inner), Image.Resampling.LANCZOS)
    rgb = scaled.convert("RGB").filter(ImageFilter.UnsharpMask(radius=0.55, percent=78, threshold=2))
    alpha = scaled.getchannel("A")
    fg = Image.merge("RGBA", (*rgb.split(), alpha))

    # Subtle 4x super-sampled dark ink outer ring so rim edge never looks raw
    ss = target_sz * 4
    ring_ss = Image.new("RGBA", (ss, ss), (0, 0, 0, 0))
    rd = ImageDraw.Draw(ring_ss)
    p4 = pad * 4
    rd.ellipse([p4 - 3, p4 - 3, ss - p4 + 2, ss - p4 + 2], fill=(12, 9, 7, 225))
    canvas = ring_ss.resize((target_sz, target_sz), Image.Resampling.LANCZOS)
    canvas.alpha_composite(fg, (pad, pad))

    # Guarantee 4 outer corner pixels & 1px border outside ring are strictly alpha=0
    cpx = canvas.load()
    for y in range(target_sz):
        for x in range(target_sz):
            if cpx[x, y][3] < 14:
                cpx[x, y] = (0, 0, 0, 0)
    return canvas


def make_sw_disabled(im_56: Image.Image) -> Image.Image:
    g = ImageOps.grayscale(im_56.convert("RGB"))
    g = ImageEnhance.Brightness(g).enhance(0.68)
    g = ImageEnhance.Contrast(g).enhance(0.90)
    r, gg, b = g.convert("RGB").split()
    return Image.merge("RGBA", (r, gg, b, im_56.getchannel("A")))


def encode_webp_data_uri(im_48: Image.Image) -> str:
    buf = io.BytesIO()
    im_48.save(buf, format="WEBP", quality=86, method=6)
    b64 = base64.b64encode(buf.getvalue()).decode("ascii")
    return f"data:image/webp;base64,{b64}"


def update_nut_manual_icons(manual_ids: set[str]) -> int:
    nut_files = [
        MOD_ROOT / "mod_wuxia" / "config" / "manuals.nut",
        MOD_ROOT / "mod_wuxia" / "config" / "wx_m4_manuals.nut",
    ] + sorted((MOD_ROOT / "mod_wuxia" / "config" / "manuals").glob("*.nut"))

    updated_count = 0
    seen_all = set()

    def repl_block(m: re.Match) -> str:
        nonlocal updated_count
        mid = m.group(1)
        block = m.group(0)
        seen_all.add(mid)
        if mid not in manual_ids:
            return block
        target_icon = f"ui/perks/{mid}.png"
        new_block, n = re.subn(r'(Icon\s*=\s*")[^"]+(")', rf'\g<1>{target_icon}\2', block, count=1)
        if n != 1:
            raise RuntimeError(f"Failed to update Icon for {mid}")
        updated_count += 1
        return new_block

    for nf in nut_files:
        txt = nf.read_text(encoding="utf-8")
        new_txt = re.sub(r'(wx_manual_[a-z0-9_]+)\s*(?:=|<-)\s*\{.*?\n\t?\}', repl_block, txt, flags=re.S)
        if new_txt != txt:
            nf.write_text(new_txt, encoding="utf-8")

    return updated_count


def build_yaqi_zhenzhen_wiki_entry(bundle: dict, icon_key: str) -> dict:
    """Builds the exact `DB.manuals` entry for `wx_manual_yaqi_zhenzhen` (`牙旗镇阵枪`)."""
    sects_nut = (MOD_ROOT / "mod_wuxia" / "config" / "sects.nut").read_text(encoding="utf-8")
    sect_name_by_id = {s["id"]: s["name"] for s in bundle["sects"]["list"]}
    yaqi_sects = []
    for sm in re.finditer(r'ID\s*=\s*"([^"]+)".*?ShopManuals\s*=\s*\[(.*?)\]', sects_nut, re.S):
        sid, shop_body = sm.group(1), sm.group(2)
        ym = re.search(r'ManualID\s*=\s*"wx_manual_yaqi_zhenzhen"\s*,\s*MinRel\s*=\s*(\d+)\s*,\s*Price\s*=\s*(\d+)', shop_body)
        if ym:
            yaqi_sects.append({
                "sectId": sid,
                "sectName": sect_name_by_id.get(sid, sid),
                "minRel": int(ym.group(1)),
                "price": int(ym.group(2)),
            })

    skill_name_by_id = {sk["id"]: sk["name"] for sk in bundle["skills"]}

    def mk_skills(sids):
        return [{"id": s, "name": skill_name_by_id.get(s, s)} for s in sids]

    return {
        "id": "wx_manual_yaqi_zhenzhen",
        "name": "牙旗镇阵枪",
        "category": "waigong",
        "quality": "sect",
        "element": None,
        "weapons": ["Polearm", "Spear"],
        "desc": "藩镇掌旗官与总镖头手擎大纛压阵的枪戟法门：借长杆矛尖控距拒敌、震退贴身刺客，大旗翻卷间稳固四邻军阵并壮大号令声威。",
        "price": 2200,
        "fragments": 3,
        "allowFragLearn": True,
        "reqs": {"MeleeSkill": 62, "Bravery": 52},
        "levels": [
            {
                "tier": 1,
                "exp": 0,
                "stats": {"MeleeSkill": 2, "Bravery": 4},
                "flags": {"FormationBondDef": 2},
                "skills": mk_skills(["actives.wx_spear_guard"]),
                "summary": "武艺 +2，定力 +4；习得「威远守线刺」；邻接同袍结阵守御定力 +2。",
            },
            {
                "tier": 2,
                "exp": 160,
                "stats": {"MeleeSkill": 4, "MeleeDefense": 2, "Bravery": 7},
                "flags": {"FormationBondDef": 3, "ZoCBonusHit": 10},
                "skills": mk_skills(["actives.wx_spear_guard", "actives.wx_spear_thrust2"]),
                "summary": "武艺 +4，招架 +2，定力 +7；习得「百鸟朝凤刺」（贴身震退自保）；拦截命中 +10，邻接结阵守御定力 +3。",
            },
            {
                "tier": 3,
                "exp": 360,
                "stats": {"MeleeSkill": 5, "MeleeDefense": 3, "Bravery": 10},
                "flags": {"FormationBondDef": 4, "ZoCBonusHit": 15, "RallyBonus": 10},
                "skills": mk_skills(["actives.wx_spear_guard", "actives.wx_spear_thrust2", "actives.wx_pole_sweep"]),
                "summary": "武艺 +5，招架 +3，定力 +10；习得「横扫千军」；拦截命中 +15，邻接结阵守御定力 +4，聚义号令检定 +10。",
            },
        ],
        "sects": yaqi_sects,
        "fighters": [],
        "hasPermAP": False,
        "hasWash": False,
        "icon": icon_key,
    }


def collect_all_referenced_icons(obj, out: set[str]):
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k == "icons":
                continue
            if k == "icon" and isinstance(v, str) and v:
                out.add(v)
            else:
                collect_all_referenced_icons(v, out)
    elif isinstance(obj, list):
        for item in obj:
            collect_all_referenced_icons(item, out)


def sync_wiki_html(webp_uris: dict[str, str]):
    html = WIKI_PATH.read_text(encoding="utf-8")
    m = re.search(r'(<script[^>]*id="wx-bundle"[^>]*>)(.*?)(</script>)', html, re.S)
    if not m:
        raise RuntimeError("Could not find <script id='wx-bundle'> in 山海武侠.html")

    bundle = json.loads(m.group(2))
    icons = bundle["icons"]

    # Determine next numeric icon key `i<N>`
    max_idx = max(int(k[1:]) for k in icons.keys() if k.startswith("i") and k[1:].isdigit())
    new_icon_key_by_manual = {}
    for mid, uri in webp_uris.items():
        max_idx += 1
        ik = f"i{max_idx}"
        icons[ik] = uri
        new_icon_key_by_manual[mid] = ik

    # Update all existing manuals in bundle
    existing_ids = set()
    for man in bundle["manuals"]:
        existing_ids.add(man["id"])
        if man["id"] in new_icon_key_by_manual:
            man["icon"] = new_icon_key_by_manual[man["id"]]

    # Inject `wx_manual_yaqi_zhenzhen` if missing
    if "wx_manual_yaqi_zhenzhen" not in existing_ids:
        yaqi_entry = build_yaqi_zhenzhen_wiki_entry(bundle, new_icon_key_by_manual["wx_manual_yaqi_zhenzhen"])
        bundle["manuals"].append(yaqi_entry)

        # Cross-link sects that sell it
        for s_ref in yaqi_entry["sects"]:
            for sect_obj in bundle["sects"]["list"]:
                if sect_obj["id"] == s_ref["sectId"]:
                    if not any(x.get("id") == "wx_manual_yaqi_zhenzhen" for x in sect_obj.get("manuals", [])):
                        sect_obj["manuals"].append({
                            "id": "wx_manual_yaqi_zhenzhen",
                            "name": "牙旗镇阵枪",
                            "quality": "sect",
                            "minRel": s_ref["minRel"],
                            "price": s_ref["price"],
                        })

        # Cross-link skills unlocked by it
        unlock_tiers = {
            "actives.wx_spear_guard": 1,
            "actives.wx_spear_thrust2": 2,
            "actives.wx_pole_sweep": 3,
        }
        for sk in bundle["skills"]:
            if sk["id"] in unlock_tiers:
                if not any(x.get("id") == "wx_manual_yaqi_zhenzhen" for x in sk.get("manuals", [])):
                    sk["manuals"].append({
                        "id": "wx_manual_yaqi_zhenzhen",
                        "name": "牙旗镇阵枪",
                        "tier": unlock_tiers[sk["id"]],
                    })

    # Garbage-collect unreferenced icon keys so bundle stays lean
    used_icons = set()
    collect_all_referenced_icons(bundle, used_icons)
    orphaned = [k for k in list(icons.keys()) if k not in used_icons]
    for k in orphaned:
        del icons[k]

    bundle["stats"]["manuals"] = len(bundle["manuals"])
    bundle["stats"]["icons"] = len(bundle["icons"])

    # Verify 100% 1-to-1 unique manual icons in wiki bundle!
    m_icons = [man["icon"] for man in bundle["manuals"]]
    assert len(m_icons) == len(set(m_icons)) == 276, f"Expected 276 unique manual icons, got {len(set(m_icons))}/{len(m_icons)}"

    new_bundle_str = json.dumps(bundle, ensure_ascii=False, separators=(",", ":"))
    new_html = html[: m.start(2)] + new_bundle_str + html[m.end(2) :]
    # Also make the manual filter label dynamic `${DB.manuals.length}` instead of hardcoded `(275)`
    new_html = new_html.replace("全部武学类别 (275)", "全部武学类别 (${DB.manuals.length})")
    WIKI_PATH.write_text(new_html, encoding="utf-8")
    print(f"Synced 山海武侠.html: {len(bundle['manuals'])} manuals (100% 1-to-1 icons), removed {len(orphaned)} orphaned generic icon keys, total icons={len(bundle['icons'])}")


def main():
    PERKS_DIR.mkdir(parents=True, exist_ok=True)
    sheets = json.loads(SPEC_PATH.read_text(encoding="utf-8"))

    webp_uris = {}
    sample_56 = []

    for sh in sheets:
        sno = sh["sheet_no"]
        cols, rows = sh["cols"], sh["rows"]
        img_p = SHEET_FILES[sno]
        if not img_p.exists():
            raise FileNotFoundError(f"Missing sheet #{sno}: {img_p}")
        sheet_im = Image.open(img_p).convert("RGB")
        sw_w, sh_h = sheet_im.size

        for cell_info in sh["cells"]:
            ci = cell_info["cell"]
            mid = cell_info["id"]
            r = ci // cols
            c = ci % cols
            x0 = (c * sw_w) // cols
            y0 = (r * sh_h) // rows
            x1 = ((c + 1) * sw_w) // cols
            y1 = ((r + 1) * sh_h) // rows
            cell_rgb = sheet_im.crop((x0, y0, x1, y1))

            cx, cy, rad = detect_medallion_circle(cell_rgb)
            hd_circle = extract_circular_rgba(cell_rgb, cx, cy, rad)
            im56 = render_medallion_size(hd_circle, 56, pad=2)
            sw56 = make_sw_disabled(im56)
            im48 = render_medallion_size(hd_circle, 48, pad=2)

            im56_q = im56.quantize(colors=256, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.FLOYDSTEINBERG)
            sw56_q = sw56.quantize(colors=256, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.FLOYDSTEINBERG)
            im56_q.save(PERKS_DIR / f"{mid}.png", format="PNG", optimize=True, compress_level=9)
            sw56_q.save(PERKS_DIR / f"{mid}_sw.png", format="PNG", optimize=True, compress_level=9)
            webp_uris[mid] = encode_webp_data_uri(im48)

            if len(sample_56) < 32 and ci in (0, 7):
                sample_56.append((mid, im56, sw56))

        print(f"Sliced Sheet #{sno} ({cols}x{rows}): {len(sh['cells'])} icons OK")

    assert len(webp_uris) == 265, f"Expected 265 sliced icons, got {len(webp_uris)}"

    # Render a dark+light checker verification strip of 56x56 + _sw icons alongside existing wx_manual_shanhai_zhuyan.png
    cols_p = 8
    rows_p = 4
    preview = Image.new("RGBA", (cols_p * 124 + 12, rows_p * 68 + 12), (26, 20, 16, 255))
    ref_im = Image.open(PERKS_DIR / "wx_manual_shanhai_zhuyan.png").convert("RGBA")
    ref_sw = Image.open(PERKS_DIR / "wx_manual_shanhai_zhuyan_sw.png").convert("RGBA")
    items_to_show = [("ref", ref_im, ref_sw)] + sample_56[:31]
    for idx, (_, im56, sw56) in enumerate(items_to_show):
        rr = idx // cols_p
        cc = idx % cols_p
        px_x = 8 + cc * 124
        px_y = 8 + rr * 68
        preview.alpha_composite(im56, (px_x, px_y))
        preview.alpha_composite(sw56, (px_x + 60, px_y))
    preview_path = BRAIN_DIR / "scratch" / "preview_56x56_samples.png"
    preview.save(preview_path)
    print(f"Saved 56x56 + _sw QA contact sheet to {preview_path}")

    # Bind .nut configs
    updated_nuts = update_nut_manual_icons(set(webp_uris.keys()))
    print(f"Updated Icon paths in .nut configs for {updated_nuts} manuals")

    # Sync 山海武侠.html
    sync_wiki_html(webp_uris)


if __name__ == "__main__":
    main()
