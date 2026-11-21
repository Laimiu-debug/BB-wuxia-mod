#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Full In-Game Art Deployment Pipeline: 武侠百科 (art/) -> 游戏 Mod (mod_wuxia/brushes/, mod_wuxia/gfx/ & .nut configs)

1. Compiles Overhype `0xBAADFAAD` v17 binary `.brush` metadata + OpenGL RGBA sprite atlases (`compile_wuxia_brushes.py`):
   - `mod_wuxia/brushes/wx_effects_0.brush` + `gfx/wx_effects_0.png` (32 Wuxia Active Skill VFX)
   - `mod_wuxia/brushes/wx_beasts_0.brush`  + `gfx/wx_beasts_0.png`  (64 Shan Hai Bosses + 11 Wild Beasts + 18 Enemy Busts)
   - `mod_wuxia/brushes/wx_world_0.brush`   + `gfx/wx_world_0.png`   (64 Shan Hai World Map Lairs)
   - `mod_wuxia/brushes/wx_busts_0.brush`   + `gfx/wx_busts_0.png`   (Modular 104×142 Character Busts: Faces, Boolean Hairs, Beards, Scars, Hats, Armors)
2. Copies all loose UI icons (`gfx/skills/*.png` + `*_sw.png`, `gfx/ui/perks/*.png`, `gfx/ui/items/**/*.png`, `gfx/ui/icons/*.png`) into `mod_wuxia/gfx/`.
3. Binds Squirrel `.nut` configurations across Active Skills, Status Effects, Manuals, Shan Hai Bosses/Cores/Lairs/Gear, Relics, Fist Weapons & Consumables.
"""

import argparse
import glob
import json
import os
import re
import shutil
from compile_wuxia_brushes import compile_all

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MANIFEST_PATH = os.path.join(ROOT, "art", "manifest.json")
WIKI_HTML_PATH = os.path.join(ROOT, "山海武侠.html")
MOD_ROOT = os.path.join(ROOT, "mod_wuxia")


def refresh_wiki_embedded_manifest(manifest):
    if not os.path.exists(WIKI_HTML_PATH):
        return False
    txt = open(WIKI_HTML_PATH, "r", encoding="utf-8").read()
    tag_re = re.compile(r'(<script type="application/json" id="art-data">\n)([\s\S]*?)(\n</script>)')
    if not tag_re.search(txt):
        return False
    payload = json.dumps(manifest, ensure_ascii=False, separators=(",", ":"))
    new_txt = tag_re.sub(lambda m: m.group(1) + payload + m.group(3), txt, count=1)
    with open(WIKI_HTML_PATH, "w", encoding="utf-8") as f:
        f.write(new_txt)
    return True


def replace_in_file(rel_path, pattern, repl, dry_run=False):
    abs_p = os.path.join(MOD_ROOT, rel_path)
    if not os.path.exists(abs_p):
        return False
    orig = open(abs_p, "r", encoding="utf-8").read()
    updated = re.sub(pattern, repl, orig)
    if updated == orig:
        return False
    if not dry_run:
        with open(abs_p, "w", encoding="utf-8") as f:
            f.write(updated)
    return True


def ensure_book_and_page_dynamic_icons(dry_run=False):
    manual_item_p = os.path.join(MOD_ROOT, "scripts/items/misc/wx_manual_item.nut")
    if os.path.exists(manual_item_p):
        txt = open(manual_item_p, "r", encoding="utf-8").read()
        if "wx_book_" not in txt:
            target = "this.m.Value = def.BasePrice;"
            inject = (
                "this.m.Value = def.BasePrice;\n"
                "\t\tlocal bookIcon = \"misc/wx_book_\" + def.Category + \"_\" + def.Quality + \".png\";\n"
                "\t\tthis.m.Icon = bookIcon;"
            )
            if target in txt and not dry_run:
                open(manual_item_p, "w", encoding="utf-8").write(txt.replace(target, inject, 1))

    page_item_p = os.path.join(MOD_ROOT, "scripts/items/misc/wx_page_item.nut")
    if os.path.exists(page_item_p):
        txt = open(page_item_p, "r", encoding="utf-8").read()
        if "wx_page_" not in txt:
            target = "local def = ::Wuxia.Slots.getManualDef(this.m.ManualID);\n\t\tif (def == null) return;"
            inject = target + "\n\t\tthis.m.Icon = \"misc/wx_page_\" + def.Quality + \".png\";"
            if target in txt and not dry_run:
                open(page_item_p, "w", encoding="utf-8").write(txt.replace(target, inject, 1))


def bind_nut_for_asset(asset, dry_run=False):
    aid = asset["id"]
    # 1. Pills in consumables.nut
    if aid.startswith("wx_pill_"):
        item_icon = f"consumables/{aid}.png"
        return replace_in_file(
            "mod_wuxia/config/consumables.nut",
            rf'({aid}\s*=\s*\{{[\s\S]*?Icon\s*=\s*")[^"]+(")',
            rf'\g<1>{item_icon}\2',
            dry_run=dry_run
        )
    # 2. Marrow herb
    if aid == "wx_marrow_herb":
        return replace_in_file(
            "scripts/items/misc/wx_marrow_herb.nut",
            r'(this\.m\.Icon\s*=\s*")[^"]+(")',
            r'\g<1>misc/wx_marrow_herb.png\2',
            dry_run=dry_run
        )
    # 3. Shan Hai Cores (all 64!)
    if aid.startswith("wx_core_"):
        return replace_in_file(
            "mod_wuxia/config/wx_shanhai.nut",
            rf'({aid}\s*=\s*\{{[\s\S]*?CustomIcon\s*=\s*)(?:null|"[^"]*")',
            rf'\g<1>"misc/{aid}.png"',
            dry_run=dry_run
        )
    # 4. Shan Hai Bosses (all 64 -> `CustomBodySprite = "wx_boss_<key>"` in `wx_beasts_0.brush`!)
    if aid.startswith("wx_boss_"):
        key = aid[len("wx_boss_"):]
        return replace_in_file(
            "mod_wuxia/config/wx_shanhai.nut",
            rf'(boss_{key}\s*=\s*\{{[\s\S]*?CustomBodySprite\s*=\s*)(?:null|"[^"]*")',
            rf'\g<1>"{aid}"',
            dry_run=dry_run
        )
    # 5. Shan Hai World Map Lairs (all 64 -> `Brush = "<aid>"` in `wx_world_0.brush`!)
    if aid.startswith("wx_lair_") or (aid.startswith("wx_shanhai_") and asset.get("stage") == "4_beasts"):
        key = aid[len("wx_lair_"):] if aid.startswith("wx_lair_") else aid[len("wx_shanhai_"):]
        return replace_in_file(
            "mod_wuxia/config/wx_encounters.nut",
            rf'(shanhai_{key}\s*=\s*\{{[\s\S]*?Brush\s*=\s*)"[^"]*"',
            rf'\g<1>"{aid}"',
            dry_run=dry_run
        )
    # 6. Shan Hai Blueprints (9 files)
    if aid == "wx_blueprint_shanhai":
        changed = False
        for bp in sorted(glob.glob(os.path.join(MOD_ROOT, "scripts/crafting/blueprints/wx_bp_*.nut"))):
            rel = os.path.relpath(bp, MOD_ROOT)
            if replace_in_file(rel, r'(this\.m\.IconLarge\s*=\s*")[^"]+(")', r'\g<1>misc/wx_blueprint_shanhai.png\2', dry_run):
                changed = True
            if replace_in_file(rel, r'(this\.m\.Icon\s*=\s*")[^"]+(")', r'\g<1>misc/wx_blueprint_shanhai.png\2', dry_run):
                changed = True
        return changed
    # 7. Books & Pages
    if aid.startswith("wx_book_") or aid.startswith("wx_page_"):
        ensure_book_and_page_dynamic_icons(dry_run=dry_run)
        return True
    # 8. Active skills (all 72 files!)
    act_rel = f"scripts/skills/actives/{aid}.nut"
    if os.path.exists(os.path.join(MOD_ROOT, act_rel)):
        c1 = replace_in_file(act_rel, r'(this\.m\.Icon\s*=\s*")[^"]+(")', rf'\g<1>skills/{aid}.png\2', dry_run)
        c2 = replace_in_file(act_rel, r'(this\.m\.IconDisabled\s*=\s*")[^"]+(")', rf'\g<1>skills/{aid}_sw.png\2', dry_run)
        return c1 or c2
    # 9. Status Effects
    eff_rel = f"scripts/skills/effects/{aid}.nut"
    if os.path.exists(os.path.join(MOD_ROOT, eff_rel)):
        return replace_in_file(eff_rel, r'(this\.m\.Icon\s*=\s*")[^"]+(")', rf'\g<1>skills/{aid}.png\2', dry_run)
    # 10. Special Traits
    spec_rel = f"scripts/skills/special/{aid}.nut"
    if os.path.exists(os.path.join(MOD_ROOT, spec_rel)):
        return replace_in_file(spec_rel, r'(this\.m\.Icon\s*=\s*")[^"]+(")', rf'\g<1>ui/perks/{aid}.png\2', dry_run)
    # 11. Shan Hai Unique Manuals
    if aid.startswith("wx_manual_shanhai_"):
        return replace_in_file(
            "mod_wuxia/config/manuals/wx_manuals_shanhai.nut",
            rf'({aid}\s*<-\s*\{{[\s\S]*?Icon\s*=\s*")[^"]+(")',
            rf'\g<1>ui/perks/{aid}.png\2',
            dry_run=dry_run
        )
    # 12. Category & Element Martial Slot Medallions across manual libraries
    perk_map = {
        "wx_perk_neigong_yin": ("mod_wuxia/config/manuals/wx_manuals_neigong.nut", r'(Element\s*=\s*"yin"[\s\S]{0,80}?Icon\s*=\s*")[^"]+(")'),
        "wx_perk_neigong_yang": ("mod_wuxia/config/manuals/wx_manuals_neigong.nut", r'(Element\s*=\s*"yang"[\s\S]{0,80}?Icon\s*=\s*")[^"]+(")'),
        "wx_perk_neigong_harmony": ("mod_wuxia/config/manuals/wx_manuals_neigong.nut", r'(Element\s*=\s*"harmony"[\s\S]{0,80}?Icon\s*=\s*")[^"]+(")'),
        "wx_perk_neigong_evil": ("mod_wuxia/config/manuals/wx_manuals_neigong.nut", r'(Element\s*=\s*"evil"[\s\S]{0,80}?Icon\s*=\s*")[^"]+(")'),
        "wx_perk_qinggong": ("mod_wuxia/config/manuals/wx_manuals_qinggong.nut", r'(Category\s*=\s*"qinggong"[\s\S]{0,90}?Icon\s*=\s*")[^"]+(")'),
        "wx_perk_henglian": ("mod_wuxia/config/manuals/wx_manuals_henglian.nut", r'(perk_40\.png|perk_30\.png|perk_32\.png|perk_06\.png|perk_39\.png)'),
        "wx_perk_tactics": ("mod_wuxia/config/manuals/wx_manuals_henglian.nut", r'(perk_28\.png|perk_19\.png|perk_51\.png)'),
        "wx_perk_waigong_blade": ("mod_wuxia/config/manuals/wx_manuals_sword_saber.nut", r'(Icon\s*=\s*")ui/perks/perk_\d+\.png(")'),
        "wx_perk_waigong_pole_fist": ("mod_wuxia/config/manuals/wx_manuals_pole_fist.nut", r'(Icon\s*=\s*")ui/perks/perk_\d+\.png(")'),
        "wx_perk_waigong_heavy_ranged": ("mod_wuxia/config/manuals/wx_manuals_heavy_odd_ranged.nut", r'(Icon\s*=\s*")ui/perks/perk_\d+\.png(")'),
    }
    if aid in perk_map:
        rel_f, pat = perk_map[aid]
        if aid in ("wx_perk_henglian", "wx_perk_tactics"):
            return replace_in_file(rel_f, rf'ui/perks/{pat}', f"ui/perks/{aid}.png", dry_run=dry_run)
        return replace_in_file(rel_f, pat, rf'\g<1>ui/perks/{aid}.png\2', dry_run=dry_run)
    # 13. Historical & Shan Hai Relic Weapons (39 items)
    if aid.startswith("wx_relic_"):
        c1 = replace_in_file("mod_wuxia/config/wx_relic_weapons.nut",
                             rf'({aid}\s*=\s*\{{[\s\S]*?CustomIcon\s*=\s*)(?:null|"[^"]*")',
                             rf'\g<1>"weapons/named/{aid}_70x70.png"', dry_run=dry_run)
        c2 = replace_in_file("mod_wuxia/config/wx_relic_weapons.nut",
                             rf'({aid}\s*=\s*\{{[\s\S]*?CustomIconLarge\s*=\s*)(?:null|"[^"]*")',
                             rf'\g<1>"weapons/named/{aid}.png"', dry_run=dry_run)
        return c1 or c2
    # 14. Fist Gauntlet progression line (3 items)
    if aid.startswith("wx_fist_") and aid in ("wx_fist_wraps", "wx_fist_iron_knuckles", "wx_fist_xuantie"):
        rel_w = f"scripts/items/weapons/{aid}.nut"
        c1 = replace_in_file(rel_w, r'(this\.m\.Icon\s*=\s*")[^"]*(")', rf'\g<1>weapons/melee/{aid}_70x70.png\2', dry_run=dry_run)
        c2 = replace_in_file(rel_w, r'(this\.m\.IconLarge\s*=\s*")[^"]*(")', rf'\g<1>weapons/melee/{aid}.png\2', dry_run=dry_run)
        return c1 or c2
    # 15. Shan Hai Red Armors, Helmets & Talismans (8 items)
    if aid.startswith("wx_armor_"):
        c1 = replace_in_file("mod_wuxia/config/wx_shanhai.nut",
                             rf'({aid}\s*=\s*\{{[\s\S]*?CustomIcon\s*=\s*)(?:null|"[^"]*")',
                             rf'\g<1>"armor/{aid}_70x70.png"', dry_run=dry_run)
        c2 = replace_in_file("mod_wuxia/config/wx_shanhai.nut",
                             rf'({aid}\s*=\s*\{{[\s\S]*?CustomIconLarge\s*=\s*)(?:null|"[^"]*")',
                             rf'\g<1>"armor/{aid}.png"', dry_run=dry_run)
        return c1 or c2
    if aid.startswith("wx_helm_"):
        return replace_in_file("mod_wuxia/config/wx_shanhai.nut",
                               rf'({aid}\s*=\s*\{{[\s\S]*?CustomIcon\s*=\s*)(?:null|"[^"]*")',
                               rf'\g<1>"helmets/{aid}.png"', dry_run=dry_run)
    if aid.startswith("wx_herb_"):
        return replace_in_file(
            "mod_wuxia/config/consumables.nut",
            rf'({aid}\s*=\s*\{{[\s\S]*?Icon\s*=\s*")[^"]+(")',
            rf'\g<1>misc/{aid}.png\2',
            dry_run=dry_run
        )
    if aid.startswith("wx_shd_") and not aid[-1].isdigit():
        c1 = replace_in_file("mod_wuxia/config/wx_shanhai.nut",
                             rf'({aid}\s*=\s*\{{[\s\S]*?CustomIcon\s*=\s*)(?:null|"[^"]*")',
                             rf'\g<1>"shields/{aid}_70x70.png"', dry_run=dry_run)
        c2 = replace_in_file("mod_wuxia/config/wx_shanhai.nut",
                             rf'({aid}\s*=\s*\{{[\s\S]*?CustomIconLarge\s*=\s*)(?:null|"[^"]*")',
                             rf'\g<1>"shields/{aid}.png"', dry_run=dry_run)
        return c1 or c2
    if aid.startswith("wx_acc_"):
        rel_acc = f"scripts/items/accessory/{aid}.nut"
        c1 = replace_in_file("mod_wuxia/config/wx_shanhai.nut",
                             rf'({aid}\s*=\s*\{{[\s\S]*?CustomIcon\s*=\s*)(?:null|"[^"]*")',
                             rf'\g<1>"accessory/{aid}.png"', dry_run=dry_run)
        c2 = replace_in_file(rel_acc, r'(this\.m\.Icon\s*=\s*")[^"]*(")', rf'\g<1>accessory/{aid}.png\2', dry_run=dry_run)
        return c1 or c2
    return False


def is_loose_ui_target(gt: str) -> bool:
    """Only `gfx/skills/...` and icon-scale `gfx/ui/...` are synced from `previewPath`;
    full-screen `settlements/`, `screens/`, `campfire/`, and `banners/` layers live at native resolution in `mod_wuxia/gfx/`!"""
    if any(gt.startswith(p) for p in ("gfx/ui/settlements/", "gfx/ui/screens/", "gfx/ui/campfire/", "gfx/ui/banners/")):
        return False
    return gt.startswith("gfx/skills/") or gt.startswith("gfx/ui/")


def main():
    parser = argparse.ArgumentParser(description="Sync Wuxia Wiki art assets & compile .brush atlases into mod_wuxia")
    parser.add_argument("--status", action="store_true", help="Print art pipeline status summary")
    parser.add_argument("--dry-run", action="store_true", help="Preview file copies and .nut updates without modifying mod_wuxia")
    parser.add_argument("--apply", action="store_true", help="Compile .brush atlases, copy UI PNGs into mod_wuxia/gfx and bind .nut configs")
    parser.add_argument("--stage", default="", help="Filter by stage (e.g. 1_icons, 2_weapons, 3_characters, 4_beasts, 5_vfx, 6_world, 7_scenes)")
    parser.add_argument("--id", default="", help="Comma-separated list of specific asset IDs to sync")
    args = parser.parse_args()

    manifest = json.load(open(MANIFEST_PATH, "r", encoding="utf-8"))
    assets = manifest["assets"]

    if args.status or (not args.dry_run and not args.apply):
        by_stage = {}
        for a in assets:
            st = by_stage.setdefault(a["stage"], {"total": 0, "wiki_ready": 0, "in_game": 0, "planned": 0})
            st["total"] += 1
            st[a["status"]] = st.get(a["status"], 0) + 1
        print("=== 山海武侠 → 游戏 Mod 美术资产进度总览 ===")
        for sdef in manifest["stages"]:
            sid = sdef["id"]
            c = by_stage.get(sid, {})
            print(f"  [{sid}] {sdef['name']}: 共 {c.get('total',0)} 项 | 百科已创制 {c.get('wiki_ready',0)} | 已实装入游戏 {c.get('in_game',0)} | 待创制 {c.get('planned',0)}")
        return

    if not args.dry_run and not args.stage and not args.id:
        print("=== [BRUSH COMPILER] 正在编译 Battle Brothers 二进制 .brush 与 OpenGL 图集 ===")
        compile_all()

    id_set = set(x.strip() for x in args.id.split(",") if x.strip())
    selected = []
    for a in assets:
        if a["status"] == "planned" or not a.get("previewPath"):
            continue
        if args.stage and a["stage"] != args.stage:
            continue
        if id_set and a["id"] not in id_set:
            continue
        selected.append(a)

    mode = "DRY-RUN" if args.dry_run else "APPLY"
    print(f"=== [{mode}] 准备同步 {len(selected)} 项美术资产至 mod_wuxia ===")
    copied = 0
    bound = 0
    for a in selected:
        gt = a.get("gameTarget", "")
        if is_loose_ui_target(gt):
            src_png = os.path.join(ROOT, a["previewPath"])
            dst_png = os.path.join(MOD_ROOT, gt)
            if os.path.exists(src_png):
                if not args.dry_run:
                    os.makedirs(os.path.dirname(dst_png), exist_ok=True)
                    shutil.copy2(src_png, dst_png)
                copied += 1
            if a.get("swPath"):
                src_sw = os.path.join(ROOT, a["swPath"])
                dst_sw = dst_png[:-4] + "_sw.png"
                if os.path.exists(src_sw):
                    if not args.dry_run:
                        shutil.copy2(src_sw, dst_sw)
                    copied += 1
            if a.get("smallPath"):
                src_sm = os.path.join(ROOT, a["smallPath"])
                dst_sm = dst_png[:-4] + "_70x70.png"
                if os.path.exists(src_sm):
                    if not args.dry_run:
                        shutil.copy2(src_sm, dst_sm)
                    copied += 1
            if a.get("hoverPath"):
                src_hv = os.path.join(ROOT, a["hoverPath"])
                dst_hv = dst_png[:-4] + "_b.png"
                if os.path.exists(src_hv):
                    if not args.dry_run:
                        shutil.copy2(src_hv, dst_hv)
                    copied += 1
        if bind_nut_for_asset(a, dry_run=args.dry_run):
            bound += 1
        if not args.dry_run:
            a["status"] = "in_game"

    if not args.dry_run and selected:
        manifest["summary"]["wiki_ready"] = sum(1 for x in assets if x["status"] == "wiki_ready")
        manifest["summary"]["in_game"] = sum(1 for x in assets if x["status"] == "in_game")
        manifest["summary"]["planned"] = sum(1 for x in assets if x["status"] == "planned")
        with open(MANIFEST_PATH, "w", encoding="utf-8") as f:
            json.dump(manifest, f, ensure_ascii=False, indent=2)
        refresh_wiki_embedded_manifest(manifest)

    print(f"=== [{mode}] 完成：复制 UI PNG 文件 {copied} 个，绑定脚本配置 {bound} 处，4 套二进制 .brush 图集已就绪 ===")


if __name__ == "__main__":
    main()
