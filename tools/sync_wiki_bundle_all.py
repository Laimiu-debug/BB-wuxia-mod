#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Master Encyclopedia Synchronizer (`山海武侠.html`) for Topics 1, 2 & 3:
1. Topic 3: Translates all 18 English `*_item` beast trophy script code names in `DB.equipment[*].recipe.ingredients`
   into their exact Chinese Wuxia names (`【异兽奇材】...`) and attaches exact in-game drop source notes (`recipe.source`).
2. Topic 2: Refreshes `DB.icons` 48x48 WebP thumbnails for all 59 `wx_relic_*` weapons and 12 `wx_beast_*` gear items
   from the freshly cleaned `mod_wuxia/gfx/ui/items/` PNGs (zero grey/black pockets, zero pink ovals).
3. Topic 1: Syncs all 171 playable `actives.wx_*` skills (`75 -> 171`, including 48x48 WebP icons & `manuals` lists)
   and updates all 276 `DB.manuals[*].levels` (`skills` + `summary`) + HTML hero/tab counters (`75 -> 171`).
"""

import base64
import io
import json
import re
import sys
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))

from wuxia_96_new_skills_data import NEW_96_SKILLS

MOD_DIR = ROOT / "mod_wuxia"
WIKI_PATH = ROOT / "山海武侠.html"

# Complete mapping of vanilla beast trophy script stems -> (Chinese Wuxia Name, In-Game Drop Sources)
TROPHY_ITEM_ZH = {
    "unhold_bones_item":      ("朱厌千钧铁骨", "讨伐刑天/蚩尤/夸父/共工/强良等山海秘境首领保底伴生掉落，或猎杀大地图巡游「小次山朱厌巨猿群」及城镇讨伐巨猿悬赏获得"),
    "ghoul_horn_item":        ("狍鸮弯钩凶角", "讨伐饕餮/狍鸮王/窫窳/凿齿秘境首领保底伴生掉落，或清剿野外「北山狍鸮兽群」及除凶悬赏获得"),
    "lindwurm_scales_item":   ("肥遗赤黑重鳞", "讨伐应龙/肥遗/九婴/冰夷秘境首领保底伴生掉落，或猎杀大泽巡游「太华肥遗毒蛟」及斩蛟悬赏获得"),
    "serpent_skin_item":      ("苍梧巴蛇青鳞皮", "讨伐巴蛇/鸣蛇/虎蛟/化蛇秘境首领保底伴生掉落，或猎杀沙海山林「苍梧巴蛇毒虺群」及斩蟒悬赏获得"),
    "unhold_hide_item":       ("朱厌白首厚革", "讨伐朱厌/陆吾/夔牛/玄龟/无支祁秘境首领保底伴生掉落，或猎杀「朱厌巨猿群」及搜山悬赏获得"),
    "glowing_resin_item":     ("建木琥珀灵脂", "讨伐句芒/白泽秘境首领保底伴生掉落，或猎杀深林「都广建木树精」及伐祟木魅悬赏获得"),
    "hyena_fur_item":         ("西山蛊雕斑革", "讨伐穷奇/蛊雕王/狰/诸犍秘境首领保底伴生掉落，或猎杀荒漠「蛊雕文豹群」及绿洲肃凶悬赏获得"),
    "poison_gland_item":      ("异兽五毒腺囊", "讨伐钦原/蜚/奢比尸秘境首领保底伴生掉落，或清剿密林「毒谷赤蛛群」及除害毒蛛悬赏获得"),
    "spider_silk_item":       ("鬼面赤蛛天韧丝", "讨伐猼訑/猩猩秘境首领保底伴生掉落，或清剿密林「毒谷赤蛛群」及除害毒蛛悬赏获得"),
    "witch_hair_item":        ("青丘妖魅惑心发", "讨伐九尾狐/女丑/武罗秘境首领保底伴生掉落，或破除「青丘妖狐群」及诛灭迷魂妖姬悬赏获得"),
    "lindwurm_bones_item":    ("肥遗毒蛟龙脊骨", "讨伐烛九阴/相柳秘境首领保底伴生掉落，或猎杀「太华肥遗毒蛟」及斩蛟悬赏获得"),
    "unhold_heart_item":      ("朱厌心头赤血核", "讨伐浑敦/檮杌/开明兽秘境首领保底伴生掉落，或猎杀「朱厌巨猿群」及搜山悬赏获得"),
    "ghoul_teeth_item":       ("狍鸮裂骨虎齿", "讨伐诸怀/当康秘境首领保底伴生掉落，或清剿野外「北山狍鸮兽群」获得"),
    "werewolf_pelt_item":     ("阴山天狗苍裘", "讨伐天狗王/驳/孟极/驺吾秘境首领保底伴生掉落，或清剿「阴山天狗群」及搜山悬赏获得"),
    "glistening_scales_item": ("巴蛇微光逆鳞", "讨伐飞廉/夫诸秘境首领保底伴生掉落，或猎杀「苍梧巴蛇毒虺群」及沙海斩蟒悬赏获得"),
    "third_eye_item":         ("讹兽梦魇诡眼", "讨伐帝江/乘黄秘境首领保底伴生掉落，或清剿「幽谷讹兽群」及夜巡捉鬼悬赏获得"),
    "petrified_scream_item":  ("荒冢凝魄寒晶", "讨伐精卫/举父秘境首领保底伴生掉落，或清剿「幽谷讹兽群」及夜巡捉鬼悬赏获得"),
    "vampire_dust_item":      ("幽冥剑魔灵烬", "讨伐毕方/金乌/九凤/祸斗秘境首领保底伴生掉落，或攻破前朝玄宫古墓斩杀「血影剑魔」获得"),
    "ghoul_brain_item":       ("狍鸮颅内髓珠", "清剿野外大中型「北山狍鸮兽群」常规掉落获得"),
}

VANILLA_SKILL_NAMES = {
    "actives.footwork":    "滑步脱身",
    "actives.rotation":    "换位护友",
    "actives.indomitable": "沉岳硬抗",
    "actives.recover":     "吐纳回气",
    "perk.brawny":         "披甲行气",
    "perk.steel_brow":     "铜头铁额",
    "perk.fearsome":       "凶威摄魂",
    "perk.nine_lives":     "九死护脉",
}


def encode_webp_48(png_path: Path) -> str:
    im = Image.open(png_path).convert("RGBA")
    bbox = im.getchannel("A").point(lambda a: 255 if a > 12 else 0).getbbox()
    if bbox:
        im = im.crop(bbox)
    s = min(44.0 / max(1, im.width), 44.0 / max(1, im.height))
    nw, nh = max(1, int(round(im.width * s))), max(1, int(round(im.height * s)))
    rs = im.resize((nw, nh), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    canvas.alpha_composite(rs, ((48 - nw) // 2, (48 - nh) // 2))
    buf = io.BytesIO()
    canvas.save(buf, format="WEBP", lossless=True, method=6)
    return "data:image/webp;base64," + base64.b64encode(buf.getvalue()).decode("ascii")


def encode_skill_webp_48(png_path: Path) -> str:
    im = Image.open(png_path).convert("RGBA").resize((48, 48), Image.Resampling.LANCZOS)
    buf = io.BytesIO()
    im.save(buf, format="WEBP", quality=92, method=6)
    return "data:image/webp;base64," + base64.b64encode(buf.getvalue()).decode("ascii")


def parse_live_manuals(skill_names: dict[str, str]) -> dict[str, list[dict]]:
    manual_files = [
        MOD_DIR / "mod_wuxia/config/manuals.nut",
        MOD_DIR / "mod_wuxia/config/wx_m4_manuals.nut",
    ] + sorted((MOD_DIR / "mod_wuxia/config/manuals").glob("*.nut"))

    out = {}
    for mf in manual_files:
        src = mf.read_text(encoding="utf-8")
        hdrs = list(re.finditer(r"(?<![A-Za-z0-9_])(wx_manual_\w+)\s*(?:<-|=)\s*\{", src))
        for i, hm in enumerate(hdrs):
            st = hm.start()
            end = hdrs[i + 1].start() if i + 1 < len(hdrs) else len(src)
            body = src[st:end]
            mid = hm.group(1)
            gs_lists = re.findall(r"GrantSkills\s*=\s*\[([^\]]*)\]", body)
            sums = re.findall(r'Summary\s*=\s*"([^"]*)"', body)
            assert len(gs_lists) == 3 and len(sums) == 3, f"Unexpected level count on {mid}"
            tiers = []
            for ti in range(3):
                sk_ids = re.findall(r'"([^"]+)"', gs_lists[ti])
                sk_objs = [
                    {"id": sid, "name": skill_names.get(sid, VANILLA_SKILL_NAMES.get(sid, sid))}
                    for sid in sk_ids
                ]
                tiers.append({"skills": sk_objs, "summary": sums[ti]})
            out[mid] = tiers
    return out


def collect_referenced_icons(obj, out: set[str]):
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k == "icons":
                continue
            if k == "icon" and isinstance(v, str) and v:
                out.add(v)
            else:
                collect_referenced_icons(v, out)
    elif isinstance(obj, list):
        for item in obj:
            collect_referenced_icons(item, out)


def main():
    html = WIKI_PATH.read_text(encoding="utf-8")
    m = re.search(r'(<script[^>]*id="wx-bundle"[^>]*>)(.*?)(</script>)', html, re.S)
    assert m, "Could not locate wx-bundle in 山海武侠.html"
    bundle = json.loads(m.group(2))
    icons = bundle["icons"]
    max_idx = max(int(k[1:]) for k in icons.keys() if k.startswith("i") and k[1:].isdigit())

    def alloc_icon(uri: str) -> str:
        nonlocal max_idx
        max_idx += 1
        ik = f"i{max_idx}"
        icons[ik] = uri
        return ik

    # 1. Topic 3 Fix: Replace all English `*_item` ingredient code names & add clear acquisition `source`!
    fixed_recipes = 0
    for eq in bundle["equipment"]:
        rec = eq.get("recipe")
        if not rec or "ingredients" not in rec:
            continue
        new_ings = []
        src_notes = []
        has_sh_core = False
        has_herb = False
        for ing in rec["ingredients"]:
            if "【山海内丹】" in ing:
                has_sh_core = True
            if "【本草灵药】" in ing or "草" in ing or "芝" in ing or "果" in ing or "枝" in ing or "叶" in ing or "晶" in ing:
                if not ing.startswith("【山海内丹】"):
                    has_herb = True
            m_it = re.match(r"^([a-z0-9_]+_item)\s*(×\d+)?$", ing.strip())
            if m_it:
                stem = m_it.group(1)
                qty = m_it.group(2) or "×1"
                assert stem in TROPHY_ITEM_ZH, f"Unmapped *_item in recipe: {stem}"
                zh_nm, drop_hint = TROPHY_ITEM_ZH[stem]
                new_ings.append(f"【异兽奇材】{zh_nm} {qty}")
                src_notes.append(drop_hint)
                fixed_recipes += 1
            else:
                new_ings.append(ing)
        rec["ingredients"] = new_ings
        if src_notes:
            rec["source"] = "；".join(dict.fromkeys(src_notes))
        elif has_sh_core and has_herb:
            rec["source"] = "对应《山海经》秘境首领 100% 必掉专属内丹，秘境宝箱及 44 大门派山门「本门药庐」可直购或采获所需灵草"

    # Verify zero English `*_item` remain in equipment recipes!
    leftover = [
        (eq["id"], ing)
        for eq in bundle["equipment"]
        if eq.get("recipe")
        for ing in eq["recipe"].get("ingredients", [])
        if "_item" in ing
    ]
    assert not leftover, f"Leftover *_item in equipment recipes: {leftover}"
    print(f"1) Fixed {fixed_recipes} English `*_item` recipe ingredients in 山海武侠.html (0 remaining)!")

    # 2. Topic 2 Sync: Refresh weapon icons in `DB.icons` for all cleaned `wx_relic_*` & `wx_beast_*` weapons!
    refreshed_eq_icons = 0
    wpn_ui = MOD_DIR / "gfx/ui/items/weapons"
    for eq in bundle["equipment"]:
        eid = eq["id"]
        cand = None
        if eid.startswith("wx_relic_"):
            cand = wpn_ui / "named" / f"{eid}.png"
        elif eid == "wx_beast_bow":
            cand = wpn_ui / "ranged" / "wx_beast_bow.png"
        elif eid.startswith("wx_beast_") and (wpn_ui / "melee" / f"{eid}.png").exists():
            cand = wpn_ui / "melee" / f"{eid}.png"
        if cand is not None and cand.exists() and eq.get("icon"):
            icons[eq["icon"]] = encode_webp_48(cand)
            refreshed_eq_icons += 1
    print(f"2) Refreshed {refreshed_eq_icons} cleaned weapon thumbnails in 山海武侠.html!")

    # 3. Topic 1 Sync: Sync all 171 Active Skills & 276 Manual tier skills/summaries!
    existing_sk_by_id = {sk["id"]: sk for sk in bundle["skills"]}

    # Build skill metadata map for all 171 skills
    all_sk_names: dict[str, str] = {sk["id"]: sk["name"] for sk in bundle["skills"]}
    for spec in NEW_96_SKILLS:
        sid = spec[0]
        full_id = f"actives.{sid}"
        all_sk_names[full_id] = spec[1]
        icon_png = MOD_DIR / "gfx/ui/skills" / f"{sid}.png"
        ik = existing_sk_by_id[full_id]["icon"] if full_id in existing_sk_by_id else alloc_icon(encode_skill_webp_48(icon_png))
        if full_id in existing_sk_by_id:
            icons[ik] = encode_skill_webp_48(icon_png)

        weapons_list = json.loads(spec[8]) if spec[8] else []
        d_mult = float(spec[9]) if float(spec[9]) > 0 else None
        cd_val = 3 if "冷却 3 回合" in spec[2] else (2 if "冷却 2 回合" in spec[2] else 0)
        prev_choreo = existing_sk_by_id[full_id].get("choreo") if full_id in existing_sk_by_id else None
        existing_sk_by_id[full_id] = {
            "id": full_id,
            "key": sid,
            "name": spec[1],
            "desc": spec[2],
            "ap": spec[4],
            "qi": spec[5],
            "minRange": spec[6],
            "maxRange": spec[7],
            "directMult": d_mult,
            "cooldown": cd_val,
            "weapons": weapons_list,
            "icon": ik,
            "manuals": [],
            **({"choreo": prev_choreo} if prev_choreo else {}),
        }

    # Clear & rebuild `manuals` reverse-index across ALL 171 skills from live manual `.nut` configs!
    for sk_obj in existing_sk_by_id.values():
        sk_obj["manuals"] = []

    live_manuals = parse_live_manuals(all_sk_names)
    assert len(live_manuals) == 276, f"Expected 276 live manuals, got {len(live_manuals)}"

    for man in bundle["manuals"]:
        mid = man["id"]
        m_name = man["name"]
        tiers = live_manuals[mid]
        first_unlock_tier: dict[str, int] = {}
        for ti in range(3):
            man["levels"][ti]["skills"] = tiers[ti]["skills"]
            man["levels"][ti]["summary"] = tiers[ti]["summary"]
            for s_entry in tiers[ti]["skills"]:
                sid = s_entry["id"]
                if sid.startswith("actives.wx_") and sid not in first_unlock_tier:
                    first_unlock_tier[sid] = ti + 1
        for sid, u_tier in first_unlock_tier.items():
            existing_sk_by_id[sid]["manuals"].append({
                "id": mid,
                "name": m_name,
                "tier": u_tier,
            })

    bundle["skills"] = sorted(existing_sk_by_id.values(), key=lambda x: x["id"])
    assert len(bundle["skills"]) == 171, f"Expected 171 skills in wiki bundle, got {len(bundle['skills'])}"

    # Garbage-collect orphaned icon keys
    used_icons: set[str] = set()
    collect_referenced_icons(bundle, used_icons)
    for k in [k for k in list(icons.keys()) if k not in used_icons]:
        del icons[k]

    bundle["stats"]["skills"] = len(bundle["skills"])
    bundle["stats"]["icons"] = len(bundle["icons"])

    new_bundle_str = json.dumps(bundle, ensure_ascii=False, separators=(",", ":"))
    new_html = html[: m.start(2)] + new_bundle_str + html[m.end(2) :]

    # Update hardcoded `75` skill labels + add `eq.recipe.source` display in modal
    new_html = new_html.replace("<b>75式主动绝技</b>", "<b>171式主动绝技</b>")
    new_html = new_html.replace("主动武学招式 (75)", "主动武学招式 (171)")
    old_rec_line = "<p><strong>所需奇材：</strong>${esc(eq.recipe.ingredients.join(' ＋ '))}</p>"
    new_rec_line = (
        "<p><strong>所需奇材：</strong>${esc(eq.recipe.ingredients.join(' ＋ '))}</p>\n"
        "            ${eq.recipe.source ? `<p><strong>奇材出处：</strong>${esc(eq.recipe.source)}</p>` : ''}"
    )
    if "${eq.recipe.source" not in new_html and old_rec_line in new_html:
        new_html = new_html.replace(old_rec_line, new_rec_line, 1)

    WIKI_PATH.write_text(new_html, encoding="utf-8")
    print(f"3) Synced 山海武侠.html: {len(bundle['skills'])} active skills, {len(bundle['manuals'])} manuals, {len(bundle['icons'])} icons!")


if __name__ == "__main__":
    main()
