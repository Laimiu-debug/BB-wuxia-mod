#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Processes Sheets 49..53:
  - Sheets 49..52: 16 x 4-frame hand-painted Wuxia martial arts animation sequences (64 frames total)
  - Sheet 53: 5 new Jianghu Alchemy Pills + 11 distinct Martial Lineage Medallions
  - Fixes `wx_book_*_secret.png`, `wx_page_secret.png`, and `mod_wuxia/gfx/ui/skills/*.png`
  - Audits & updates all 272 manuals (distinct lineage medallion icons + exact GrantSkills Chinese names in Summary)
  - Maps all 72 active skills to their exact 4-frame animation sequence (`WX_AnimID` + `WX_AnimMode` + `wx_ov_*` Overlay)
"""

import glob
import json
import os
import re
import shutil
import sys
from PIL import Image, ImageEnhance, ImageOps

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import build_wuxia_bust_system as bsys

ART_DIR = os.path.join(ROOT, "art")
SHEETS_DIR = os.path.join(ART_DIR, "sheets")
ANIM_DIR = os.path.join(ART_DIR, "anim")
MOD_ROOT = os.path.join(ROOT, "mod_wuxia")
BRAIN_DIR = r"C:\Users\25647\.gemini\antigravity\brain\fa3a61d2-2588-454a-a04d-cca189377964"

RAW_SHEETS = {
    "sheet_49.jpg": "wuxia_slash_vfx_4x4_sheet_final_1795178918695.jpg",
    "sheet_50.jpg": "wuxia_martial_arts_4x4_spritesheet_1795178855051.jpg",
    "sheet_51.jpg": "wuxia_weapon_vfx_4x4_spritesheet_final_1795178946360.jpg",
    "sheet_52.jpg": "wuxia_vfx_4x4_spritesheet_1795178863739.jpg",
    "sheet_53.jpg": "bb_wuxia_alchemy_lineage_4x4_v3_1795178909417.jpg",
}

ANIM_DEFS = [
    # Sheet 49 (Sword & Saber)
    ("wx_anim_01", "sheet_49.jpg", 0, "清风剑气·四帧连斩", "剑法序列动画 01 · 聚芒→挥弧→双剑交斩→余气", "剑尖凝起青白寒星，旋即化作新月剑弧破空交斩，激起凛冽银芒与散逸剑气。", "slash"),
    ("wx_anim_02", "sheet_49.jpg", 1, "天外飞剑·四帧化虹", "剑法序列动画 02 · 剑阵→三剑齐飞→星芒攒刺→剑韵", "半空浮现鎏金八卦剑印，三道青玉剑影破空疾射，于敌身炸开五星贯体剑芒。", "projectile"),
    ("wx_anim_03", "sheet_49.jpg", 2, "燃木烈焰·四帧霸劈", "刀法序列动画 03 · 燃火→烈焰刀弧→崩岩爆炎→浓烟", "刀锋腾起纯阳烈火，重刀由上而下怒劈而出，轰然炸裂地面焦岩与漫天火星。", "heavy_quake"),
    ("wx_anim_04", "sheet_49.jpg", 3, "修罗血海·四帧狂斩", "刀法序列动画 04 · 凝血→双刃撕裂→血莲旋涡→血雾", "凶戾暗红血气凝聚成弯月，狂暴双刃撕开血肉，卷起猩红血莲气旋汲取生机。", "slash"),
    # Sheet 50 (Fist, Palm, Finger & Claw)
    ("wx_anim_05", "sheet_50.jpg", 0, "亢龙有悔·四帧真龙掌", "拳掌序列动画 05 · 掌印聚气→金龙咆哮→撼天掌爆→震环", "掌心金光真气盘旋，一条金墨苍龙穿环呼啸扑出，轰然印出裂地金掌巨震。", "projectile"),
    ("wx_anim_06", "sheet_50.jpg", 1, "玄冥寒毒·四帧冰晶掌", "拳掌序列动画 06 · 寒漩→冰魄掌浪→玄冰刺阵→碎霜", "阴寒冰漩凝结霜符，幽蓝寒冰掌浪破空拍至，将目标冻结于狰狞玄冰尖刺之中。", "slash"),
    ("wx_anim_07", "sheet_50.jpg", 2, "一阳贯日·四帧点穴指", "指法序列动画 07 · 凝阳→金虹指劲→经脉星爆→封穴", "指端汇聚炽盛纯阳金星，一道凝练金红指劲破空洞穿大穴，震亮周天经脉星图。", "projectile"),
    ("wx_anim_08", "sheet_50.jpg", 3, "九阴白骨·四帧碎骨爪", "爪法序列动画 08 · 幽煞→五指爪痕→碎骨紫爆→阴烟", "诡谲紫黑煞气缠绕指尖，五道凌厉爪芒横掠撕裂甲胄，爆开森白碎骨幽光。", "slash"),
    # Sheet 51 (Polearm, Heavy Hammer, Sweep & Bow)
    ("wx_anim_09", "sheet_51.jpg", 0, "寒星盘龙·四帧螺旋刺", "枪棒序列动画 09 · 寒星→盘龙风钻→破甲音爆→旋风", "枪尖一点寒星先至，随后银枪裹挟螺旋白龙风劲贯体而出，炸开破甲音爆。", "slash"),
    ("wx_anim_10", "sheet_51.jpg", 1, "震岳碎甲·四帧裂地锤", "重兵序列动画 10 · 重压→陨星砸落→崩山碎石→尘浪", "沉重气场压得碎石浮空，重锤如天外陨星轰然砸落，掀起崩山裂地乱石气浪。", "heavy_quake"),
    ("wx_anim_11", "sheet_51.jpg", 2, "横扫千军·四帧旋风斩", "群攻序列动画 11 · 起旋→半月狂扫→周身龙卷→风环", "腰马合一带动长兵贴地起旋，瞬间化作三百六十度钢铁赤风龙卷横扫周身群敌。", "sweep"),
    ("wx_anim_12", "sheet_51.jpg", 3, "流星追月·四帧贯日箭", "弓弩序列动画 12 · 满弦翠羽→流光破音障→碎甲星爆→散羽", "满弓凝起翠金风羽，利箭连破两道音障疾射而至，轰然洞穿重甲铁片。", "projectile"),
    # Sheet 52 (Throwing, Thunder Bomb, Qinggong & Neigong)
    ("wx_anim_13", "sheet_52.jpg", 0, "暴雨梨花·四帧千针雨", "暗器序列动画 13 · 机括碧芒→漫天银针毒镖→攒刺毒雾→幽瘴", "唐门青铜机括乍亮，数十枚寒芒银针与碧绿毒镖呈扇面攒射，爆开剧毒紫绿瘴云。", "projectile"),
    ("wx_anim_14", "sheet_52.jpg", 1, "霹雳雷火·四帧轰天爆", "火器序列动画 14 · 引信燃星→火流星抛射→烈焰铁砂爆→硝烟", "黑铁雷火弹引信燃亮，划过赤红火弧轰然炸开漫天烈焰铁砂与滚滚黑硝烟环。", "projectile"),
    ("wx_anim_15", "sheet_52.jpg", 2, "凌波梯云·四帧水墨影", "轻功序列动画 15 · 八卦步纹→竹叶疾风→双生青墨残影→涟漪", "足下踏出太极水墨步纹，身形化作飞竹疾风与两道青墨残影瞬息掠过战阵。", "qinggong"),
    ("wx_anim_16", "sheet_52.jpg", 3, "金钟太极·四帧护体罡", "内功序列动画 16 · 金莲阵启→周天气柱→梵钟金罩→阴阳归元", "脚下金莲八卦阵图亮起，醇厚内息冲天化作护体金钟气罩，继而归于阴阳太极。", "aura"),
]

SHEET53_DEFS = [
    # 5 New Alchemy Pills (`slotKind = item70`, `game/items/consumables/...`)
    (0, "wx_pill_dahuan",   "1_icons", "丹药百工 · 江湖十丹谱系", "九转大还丹", "宗门圣丹 · 灌注 +320 火候", "70×70 行囊灵丹贴图", "item70", "items/consumables/wx_pill_dahuan.png", "mod_wuxia/config/consumables.nut", "朱金锦盒盛装的名门九转金丹，拖入武学槽立即灌注 320 点火候并平复散功虚弱。"),
    (1, "wx_pill_qingxin",  "1_icons", "丹药百工 · 江湖十丹谱系", "清心解毒丹", "避秽灵丸 · 下场免疫奇毒", "70×70 行囊灵丹贴图", "item70", "items/consumables/wx_pill_qingxin.png", "mod_wuxia/config/consumables.nut", "龙泉青瓷瓶所盛碧玉解毒丸，战前服食令下场战斗全程免疫吹箭与虫蝎奇毒。"),
    (2, "wx_pill_hugu",     "1_icons", "丹药百工 · 江湖十丹谱系", "虎骨壮气丸", "壮骨大丸 · 回血+临时内息", "70×70 行囊灵丹贴图", "item70", "items/consumables/wx_pill_hugu.png", "mod_wuxia/config/consumables.nut", "金箔包裹的虎骨赤血大丸，服后补满受损气血并令下场战斗临时 +12 内息上限、+2 回气。"),
    (3, "wx_pill_dingshen", "1_icons", "丹药百工 · 江湖十丹谱系", "明目定神散", "镇魂灵散 · +10定力+夜视", "70×70 行囊灵丹贴图", "item70", "items/consumables/wx_pill_dingshen.png", "mod_wuxia/config/consumables.nut", "青花瓷瓶盛装的清心灵散，战前服食令下场战斗临时 +10 定力并免除夜战视野惩罚。"),
    (4, "wx_pill_huoluo",   "1_icons", "丹药百工 · 江湖十丹谱系", "易筋活络膏", "黑玉药膏 · 双外伤速愈", "70×70 行囊灵丹贴图", "item70", "items/consumables/wx_pill_huoluo.png", "mod_wuxia/config/consumables.nut", "玳瑁黑漆盒盛装的跌打秘膏，一次解除至多 2 处临时外伤并恢复至多 35 点气血。"),
    # 11 Martial Lineage Medallions (`slotKind = icon56`, `game/ui/perks/...`)
    (5,  "wx_emblem_heavy",    "1_icons", "功法圆章 · 十一脉武学宗印", "重兵破甲宗印", "锤斧重兵外功专属圆章", "56×56 功法槽圆章 (+_sw)", "icon56", "ui/perks/wx_emblem_heavy.png",    "mod_wuxia/config/manuals/", "交错战锤与开山巨斧震碎青石的古铜宗印，专配重锤、大斧类刚猛破甲秘籍。"),
    (6,  "wx_emblem_odd",      "1_icons", "功法圆章 · 十一脉武学宗印", "奇门短兵宗印", "短匕软鞭暗器专属圆章", "56×56 功法槽圆章 (+_sw)", "icon56", "ui/perks/wx_emblem_odd.png",      "mod_wuxia/config/manuals/", "双分水刺与九节铁鞭盘绕的玄铁宗印，专配短匕、软鞭连枷与奇门暗器秘籍。"),
    (7,  "wx_emblem_ranged",   "1_icons", "功法圆章 · 十一脉武学宗印", "神射火器宗印", "弓弩神机火器专属圆章", "56×56 功法槽圆章 (+_sw)", "icon56", "ui/perks/wx_emblem_ranged.png",   "mod_wuxia/config/manuals/", "牛角筋弓、破甲箭与神机火铳同辉的鎏金木印，专配弓术、强弩与火器秘籍。"),
    (8,  "wx_emblem_sword",    "1_icons", "功法圆章 · 十一脉武学宗印", "名门剑宗圆印", "正奇诸派剑法专属圆章", "56×56 功法槽圆章 (+_sw)", "icon56", "ui/perks/wx_emblem_sword.png",    "mod_wuxia/config/manuals/", "苍松流云间双剑交辉的青玉剑印，专配天下名门正宗与奇险快剑秘籍。"),
    (9,  "wx_emblem_saber",    "1_icons", "功法圆章 · 十一脉武学宗印", "霸道刀宗圆印", "单双刀法血刃专属圆章", "56×56 功法槽圆章 (+_sw)", "icon56", "ui/perks/wx_emblem_saber.png",    "mod_wuxia/config/manuals/", "赤铁圆盾上烈焰环首大刀怒燃的霸刀宗印，专配沙场战刀与江湖狂刀秘籍。"),
    (10, "wx_emblem_pole",     "1_icons", "功法圆章 · 十一脉武学宗印", "长兵枪棒圆印", "枪矛大戟棍棒专属圆章", "56×56 功法槽圆章 (+_sw)", "icon56", "ui/perks/wx_emblem_pole.png",     "mod_wuxia/config/manuals/", "红缨盘龙银枪与齐眉铁棍交叉的精钢宗印，专配枪矛、长戟与禅门棍杖秘籍。"),
    (11, "wx_emblem_fist",     "1_icons", "功法圆章 · 十一脉武学宗印", "拳掌指爪圆印", "拳掌指爪擒拿专属圆章", "56×56 功法槽圆章 (+_sw)", "icon56", "ui/perks/wx_emblem_fist.png",     "mod_wuxia/config/manuals/", "纯阳金色掌印与玄铁指虎交相辉映的佛武宗印，专配拳、掌、指、爪与擒拿秘籍。"),
    (12, "wx_emblem_neigong",  "1_icons", "功法圆章 · 十一脉武学宗印", "玄门内功心印", "周天内功心法专属圆章", "56×56 功法槽圆章 (+_sw)", "icon56", "ui/perks/wx_emblem_neigong.png",  "mod_wuxia/config/manuals/", "墨玉莲台烘托阴阳双鱼流转的周天心印，专配道佛正邪诸脉内功心法。"),
    (13, "wx_emblem_qinggong", "1_icons", "功法圆章 · 十一脉武学宗印", "轻功身法风印", "提纵步法闪避专属圆章", "56×56 功法槽圆章 (+_sw)", "icon56", "ui/perks/wx_emblem_qinggong.png", "mod_wuxia/config/manuals/", "碧玉风涛间玄燕掠空的轻灵风印，专配水上漂、凌波与提纵轻功秘籍。"),
    (14, "wx_emblem_henglian", "1_icons", "功法圆章 · 十一脉武学宗印", "横练硬功钟印", "重甲护体硬功专属圆章", "56×56 功法槽圆章 (+_sw)", "icon56", "ui/perks/wx_emblem_henglian.png", "mod_wuxia/config/manuals/", "铆钉铜环内古寺梵钟镇压崇山的硬功宗印，专配金钟、铁布衫与气血横练秘籍。"),
    (15, "wx_emblem_tactics",  "1_icons", "功法圆章 · 十一脉武学宗印", "统帅奇策虎印", "军心号令杂学专属圆章", "56×56 功法槽圆章 (+_sw)", "icon56", "ui/perks/wx_emblem_tactics.png",  "mod_wuxia/config/manuals/", "鎏金虎符与猎猎红帅旗并立的兵家宗印，专配聚义号令、盾阵与江湖奇门杂学。"),
]


def make_sw_disabled(im_56: Image.Image) -> Image.Image:
    g = ImageOps.grayscale(im_56.convert("RGB"))
    g = ImageEnhance.Brightness(g).enhance(0.62)
    g = ImageEnhance.Contrast(g).enhance(0.88)
    r, gg, b = g.convert("RGB").split()
    return Image.merge("RGBA", (r, gg, b, im_56.getchannel("A")))


def fit_box(rgba: Image.Image, w: int, h: int, pad: int = 4) -> Image.Image:
    tc = bsys.decontaminate_white_fringe(bsys.tight_crop(rgba), passes=1)
    mw, mh = max(1, w - 2 * pad), max(1, h - 2 * pad)
    s = min(mw / float(tc.width), mh / float(tc.height))
    nw, nh = max(1, int(round(tc.width * s))), max(1, int(round(tc.height * s)))
    im = tc.resize((nw, nh), Image.Resampling.LANCZOS)
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out.alpha_composite(im, ((w - nw) // 2, (h - nh) // 2))
    return out


def map_skill_to_anim(skill_id: str):
    """Maps every one of the 72 active skills (`wx_*`) to `(anim_id, anim_mode)`!"""
    s = skill_id.lower()
    if "feixian" in s or "tianwai" in s or "liuxing_jian" in s or "yuenv" in s:
        return ("wx_anim_02", "projectile")
    if "sword" in s:
        if "zhongjian" in s:
            return ("wx_anim_10", "heavy_quake")
        if "taiji" in s or "counter" in s:
            return ("wx_anim_16", "aura")
        return ("wx_anim_01", "slash")
    if "saber" in s:
        if "ranmu" in s or "flame" in s or "kuangdao" in s or "duanyue" in s:
            return ("wx_anim_03", "heavy_quake")
        if "whirl" in s or "hengsao" in s:
            return ("wx_anim_11", "sweep")
        return ("wx_anim_04", "slash")
    if "fist" in s or "acupoint" in s:
        if "yiyang" in s or "acupoint" in s or "fuxue" in s or "tan" in s:
            return ("wx_anim_07", "projectile")
        if "xuanming" in s or "hanbing" in s or "frost" in s:
            return ("wx_anim_06", "slash")
        if "jiuyin" in s or "claw" in s or "zhua" in s or "grapple" in s or "disarm" in s:
            return ("wx_anim_08", "slash")
        return ("wx_anim_05", "projectile")
    if "spear" in s or "pole" in s or "staff" in s:
        if "sweep" in s or "fengjuan" in s or "hengsao" in s or "whirl" in s:
            return ("wx_anim_11", "sweep")
        return ("wx_anim_09", "slash")
    if "hammer" in s:
        return ("wx_anim_10", "heavy_quake")
    if "axe" in s:
        if "whirl" in s:
            return ("wx_anim_11", "sweep")
        return ("wx_anim_10", "heavy_quake")
    if "flail" in s:
        return ("wx_anim_11", "sweep")
    if "dagger" in s:
        if "fuxue" in s:
            return ("wx_anim_07", "projectile")
        return ("wx_anim_08", "slash")
    if "bow" in s or "crossbow" in s:
        return ("wx_anim_12", "projectile")
    if "firearm" in s or "pilidan" in s or "thunder" in s or "chong" in s:
        return ("wx_anim_14", "projectile")
    if "throw" in s or "poison" in s or "wudu" in s or "smoke" in s:
        return ("wx_anim_13", "projectile")
    if "qinggong" in s or "step" in s or "zongyue" in s or "lingbo" in s or "feiyan" in s:
        return ("wx_anim_15", "qinggong")
    if "blood" in s or "xixing" in s or "guiyuan" in s:
        return ("wx_anim_04", "aura")
    return ("wx_anim_16", "aura")


def main():
    os.makedirs(SHEETS_DIR, exist_ok=True)
    os.makedirs(ANIM_DIR, exist_ok=True)
    os.makedirs(os.path.join(ART_DIR, "hd"), exist_ok=True)
    os.makedirs(os.path.join(ART_DIR, "game", "effects"), exist_ok=True)
    os.makedirs(os.path.join(ART_DIR, "game", "items", "consumables"), exist_ok=True)
    os.makedirs(os.path.join(ART_DIR, "game", "ui", "perks"), exist_ok=True)

    for dst_name, raw_name in RAW_SHEETS.items():
        src_p = os.path.join(BRAIN_DIR, raw_name)
        dst_p = os.path.join(SHEETS_DIR, dst_name)
        if os.path.exists(src_p):
            shutil.copy2(src_p, dst_p)
        if not os.path.exists(dst_p):
            raise FileNotFoundError(f"Missing {dst_p}")

    # 1. Extract 16 x 4-frame animation sequences (`64` PNG frames + 16 4-frame strip previews)
    new_manifest_assets = []
    for anim_id, sheet_fn, row_idx, nm, sub, brf, mode in ANIM_DEFS:
        sh = Image.open(os.path.join(SHEETS_DIR, sheet_fn))
        cw, ch = sh.width // 4, sh.height // 4
        frame_rels = []
        frame_imgs_160 = []
        for col_idx in range(4):
            cell = sh.crop((col_idx * cw, row_idx * ch, (col_idx + 1) * cw, (row_idx + 1) * ch))
            rgba = bsys.flood_white_bg(cell, bg_thresh=32, feather=22)
            f_256 = fit_box(rgba, 256, 256, pad=10)
            f_rel = f"art/anim/{anim_id}_f{col_idx + 1}.png"
            f_256.save(os.path.join(ROOT, f_rel))
            frame_rels.append(f_rel)
            frame_imgs_160.append(fit_box(rgba, 124, 124, pad=4))

        # Build a clean 2x2 / 4-in-1 composite preview card (`256x256` HD & `128x128` preview) showing the 4 progression frames!
        hd_comp = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
        for fi, fim in enumerate(frame_imgs_160):
            rr, cc = divmod(fi, 2)
            hd_comp.alpha_composite(fim, (cc * 128 + 2, rr * 128 + 2))
        hd_rel = f"art/hd/{anim_id}.png"
        prev_rel = f"art/game/effects/{anim_id}.png"
        hd_comp.save(os.path.join(ROOT, hd_rel))
        hd_comp.resize((128, 128), Image.Resampling.LANCZOS).save(os.path.join(ROOT, prev_rel))

        new_manifest_assets.append({
            "id": anim_id,
            "stage": "5_vfx",
            "group": "武学招式 · 四帧连续序列动画（16套·64帧）",
            "name": nm,
            "sub": sub,
            "spec": "4×136×136 实机四阶段序列帧 (.brush)",
            "slotKind": "boss",
            "status": "in_game",
            "hdPath": hd_rel,
            "previewPath": prev_rel,
            "swPath": "",
            "smallPath": "",
            "animFrames": frame_rels,
            "animMode": mode,
            "gameTarget": f"brushes/wx_effects_0.brush#{anim_id}_f1..f4",
            "vanillaFallback": "effect_slash_01",
            "codeRef": "mod_wuxia/mod_wuxia/systems/wx_vfx_system.nut",
            "brief": brf,
        })

    # 2. Extract Sheet 53 (5 New Pills + 11 Martial Lineage Medallions)
    sh53 = Image.open(os.path.join(SHEETS_DIR, "sheet_53.jpg"))
    cw53, ch53 = sh53.width // 4, sh53.height // 4
    for (cidx, aid, stage, grp, nm, sub, spec, skind, game_rel, cref, brf) in SHEET53_DEFS:
        r, c = divmod(cidx, 4)
        rgba = bsys.flood_white_bg(sh53.crop((c * cw53, r * ch53, (c + 1) * cw53, (r + 1) * ch53)), bg_thresh=30, feather=20)
        hd_rel = f"art/hd/{aid}.png"
        fit_box(rgba, 256, 256, pad=14).save(os.path.join(ROOT, hd_rel))
        g_abs = os.path.join(ART_DIR, "game", game_rel)
        os.makedirs(os.path.dirname(g_abs), exist_ok=True)
        sw_rel = ""
        if skind == "item70":
            im70 = fit_box(rgba, 70, 70, pad=3)
            im70.save(g_abs)
            # Also copy directly into `mod_wuxia/gfx/ui/items/consumables/`
            mod_dst = os.path.join(MOD_ROOT, "gfx", "ui", game_rel)
            os.makedirs(os.path.dirname(mod_dst), exist_ok=True)
            im70.save(mod_dst)
        else:
            im56 = fit_box(rgba, 56, 56, pad=2)
            im56.save(g_abs)
            im_sw = make_sw_disabled(im56)
            sw_game_rel = game_rel.replace(".png", "_sw.png")
            sw_abs = os.path.join(ART_DIR, "game", sw_game_rel)
            im_sw.save(sw_abs)
            sw_rel = f"art/game/{sw_game_rel}"
            # Copy both normal and `_sw` into `mod_wuxia/gfx/ui/perks/`
            mod_dst = os.path.join(MOD_ROOT, "gfx", game_rel)
            os.makedirs(os.path.dirname(mod_dst), exist_ok=True)
            im56.save(mod_dst)
            im_sw.save(mod_dst.replace(".png", "_sw.png"))

        new_manifest_assets.append({
            "id": aid,
            "stage": stage,
            "group": grp,
            "name": nm,
            "sub": sub,
            "spec": spec,
            "slotKind": skind,
            "status": "in_game",
            "hdPath": hd_rel,
            "previewPath": f"art/game/{game_rel}",
            "swPath": sw_rel,
            "smallPath": "",
            "gameTarget": f"gfx/ui/{game_rel}" if skind == "item70" else f"gfx/{game_rel}",
            "vanillaFallback": "consumables/potion_01.png" if skind == "item70" else "ui/perks/perk_01.png",
            "codeRef": cref,
            "brief": brf,
        })

    # 3. Fix `wx_book_*_secret.png`, `wx_page_secret.png` & copy all skills/status icons into `mod_wuxia/gfx/ui/skills/`
    for base_dir in [os.path.join(ART_DIR, "game", "items", "misc"), os.path.join(MOD_ROOT, "gfx", "ui", "items", "misc")]:
        if os.path.exists(base_dir):
            for fn in os.listdir(base_dir):
                if "_supreme.png" in fn:
                    sec_fn = fn.replace("_supreme.png", "_secret.png")
                    shutil.copy2(os.path.join(base_dir, fn), os.path.join(base_dir, sec_fn))

    ui_skills_dir = os.path.join(MOD_ROOT, "gfx", "ui", "skills")
    os.makedirs(ui_skills_dir, exist_ok=True)
    for src_skill_dir in [os.path.join(MOD_ROOT, "gfx", "skills"), os.path.join(ART_DIR, "game", "skills")]:
        if os.path.exists(src_skill_dir):
            for fn in os.listdir(src_skill_dir):
                if fn.endswith(".png"):
                    shutil.copy2(os.path.join(src_skill_dir, fn), os.path.join(ui_skills_dir, fn))

    # 4. Build exact map of `actives.wx_*` -> real Chinese skill `Name` from `mod_wuxia/scripts/skills/actives/*.nut`
    skill_cn_names = {}
    skill_anim_meta = {}
    for p in sorted(glob.glob(os.path.join(MOD_ROOT, "scripts", "skills", "actives", "*.nut"))):
        bn = os.path.splitext(os.path.basename(p))[0]
        if bn == "wx_move_base":
            continue
        txt = open(p, "r", encoding="utf-8").read()
        m_id = re.search(r'this\.m\.ID\s*=\s*"([^"]+)"', txt)
        m_nm = re.search(r'this\.m\.Name\s*=\s*"([^"]+)"', txt)
        if m_id and m_nm:
            full_id = m_id.group(1)  # e.g. actives.wx_sword_zhongjian
            short_id = full_id.replace("actives.", "")
            skill_cn_names[full_id] = m_nm.group(1)
            anim_id, anim_mode = map_skill_to_anim(short_id)
            skill_anim_meta[short_id] = (anim_id, anim_mode)

            # Inject `WX_AnimID`, `WX_AnimMode`, and custom `Overlay = "wx_ov_<short_id>"` into every active skill!
            new_txt = re.sub(r'this\.m\.Overlay\s*=\s*"[^"]+"\s*;', f'this.m.Overlay = "wx_ov_{short_id}";', txt)
            if "WX_AnimID" not in new_txt:
                new_txt = re.sub(
                    r'(this\.m\.WX_VfxBrush\s*<-\s*"[^"]+"\s*;)',
                    rf'\1\n\t\tthis.m.WX_AnimID <- "{anim_id}";\n\t\tthis.m.WX_AnimMode <- "{anim_mode}";',
                    new_txt,
                )
                if "WX_AnimID" not in new_txt:
                    new_txt = re.sub(
                        r'(WX_VfxBrush\s*=\s*"[^"]+")',
                        rf'\1, WX_AnimID = "{anim_id}", WX_AnimMode = "{anim_mode}"',
                        new_txt,
                    )
            if new_txt != txt:
                with open(p, "w", encoding="utf-8", newline="\n") as f:
                    f.write(new_txt)

    # 5. Update all Manual config `.nut` files:
    #    (a) Assign distinct 11-lineage medallion `Icon = "ui/perks/wx_emblem_*.png"` (preserve Shan Hai bespoke icons!)
    #    (b) Fix any `Summary` where `习得「...」` had a stale placeholder skill name that didn't match `GrantSkills`!
    manual_files = [
        os.path.join(MOD_ROOT, "mod_wuxia", "config", "manuals.nut"),
        os.path.join(MOD_ROOT, "mod_wuxia", "config", "wx_m4_manuals.nut"),
    ] + sorted(glob.glob(os.path.join(MOD_ROOT, "mod_wuxia", "config", "manuals", "*.nut")))

    fixed_summaries = 0
    updated_icons = 0

    def choose_emblem(cat, wtypes_str, block_text):
        if "wx_manual_shanhai_" in block_text:
            return None
        if cat == "neigong":
            return "ui/perks/wx_emblem_neigong.png"
        if cat == "qinggong":
            return "ui/perks/wx_emblem_qinggong.png"
        if cat == "henglian":
            if any(k in block_text for k in ("CommandAuraPct", "RallyBonus", "EmptyOffhandPen", "FastAdaptBonus", "SurroundHitBonus", "UnderdogGuard", "ShieldDefBonus", "LoneWolfBonus")):
                return "ui/perks/wx_emblem_tactics.png"
            return "ui/perks/wx_emblem_henglian.png"
        # waigong by WeaponTypes
        if '"Sword"' in wtypes_str and '"Cleaver"' not in wtypes_str:
            return "ui/perks/wx_emblem_sword.png"
        if '"Cleaver"' in wtypes_str or '"Saber"' in wtypes_str:
            return "ui/perks/wx_emblem_saber.png"
        if '"Spear"' in wtypes_str or '"Polearm"' in wtypes_str or '"Staff"' in wtypes_str:
            return "ui/perks/wx_emblem_pole.png"
        if '"Fist"' in wtypes_str:
            return "ui/perks/wx_emblem_fist.png"
        if '"Hammer"' in wtypes_str or '"Axe"' in wtypes_str:
            return "ui/perks/wx_emblem_heavy.png"
        if '"Dagger"' in wtypes_str or '"Flail"' in wtypes_str or '"Throwing"' in wtypes_str:
            return "ui/perks/wx_emblem_odd.png"
        if '"Bow"' in wtypes_str or '"Crossbow"' in wtypes_str or '"Firearm"' in wtypes_str:
            return "ui/perks/wx_emblem_ranged.png"
        return "ui/perks/wx_emblem_tactics.png"

    for mf in manual_files:
        if not os.path.exists(mf):
            continue
        content = open(mf, "r", encoding="utf-8").read()
        # Process manual blocks
        parts = re.split(r'(?=::Wuxia\.Config\.Manuals\.[A-Za-z0-9_]+\s*<-|\bwx_manual_[A-Za-z0-9_]+\s*=\s*\{)', content)
        out_parts = []
        for blk in parts:
            m_cat = re.search(r'Category\s*=\s*"([^"]+)"', blk)
            m_wt = re.search(r'WeaponTypes\s*=\s*\[([^\]]*)\]', blk)
            if m_cat:
                emb = choose_emblem(m_cat.group(1), m_wt.group(1) if m_wt else "", blk)
                if emb:
                    blk2 = re.sub(r'Icon\s*=\s*"ui/perks/[^"]+"', f'Icon = "{emb}"', blk, count=1)
                    if blk2 != blk:
                        updated_icons += 1
                        blk = blk2
                # Check each level line for `GrantSkills = [...]` vs `习得「...」` in `Summary = "..."`
                def fix_level_line(m):
                    nonlocal fixed_summaries
                    line = m.group(0)
                    g_list = re.findall(r'"(actives\.[A-Za-z0-9_]+)"', m.group(1))
                    if not g_list:
                        return line
                    real_names = [skill_cn_names[g] for g in g_list if g in skill_cn_names]
                    if not real_names:
                        return line
                    # If Summary contains `习得「X」` where X is not in real_names, replace with exact granted skill name(s)!
                    def repl_xide(sm):
                        nonlocal fixed_summaries
                        old_inner = sm.group(1)
                        if all(rn not in old_inner for rn in real_names):
                            fixed_summaries += 1
                            return "习得" + "、".join(f"「{rn}」" for rn in real_names)
                        return sm.group(0)
                    return re.sub(r'习得「([^」]+)」', repl_xide, line)

                blk = re.sub(r'\{\s*ExpNeeded[^\n]*GrantSkills\s*=\s*\[([^\]]*)\][^\n]*\}', fix_level_line, blk)
            out_parts.append(blk)
        new_content = "".join(out_parts)
        if new_content != content:
            with open(mf, "w", encoding="utf-8", newline="\n") as f:
                f.write(new_content)

    # 6. Update `art/manifest.json` (attach `animId` & `animMode` to all 72 active skills + add 32 new assets!)
    manifest_path = os.path.join(ART_DIR, "manifest.json")
    manifest = json.load(open(manifest_path, "r", encoding="utf-8"))
    new_ids = {a["id"] for a in new_manifest_assets}
    kept_assets = [a for a in manifest["assets"] if a["id"] not in new_ids]

    for a in kept_assets:
        if a["id"] in skill_anim_meta:
            anim_id, anim_mode = skill_anim_meta[a["id"]]
            a["animId"] = anim_id
            a["animMode"] = anim_mode

    kept_assets.extend(new_manifest_assets)
    manifest["version"] = "0.8.0-true-anim-and-ui-787"
    manifest["assets"] = kept_assets
    manifest["summary"]["total"] = len(kept_assets)
    manifest["summary"]["in_game"] = sum(1 for x in kept_assets if x["status"] == "in_game")
    manifest["summary"]["wiki_ready"] = sum(1 for x in kept_assets if x["status"] == "wiki_ready")
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)

    print(f"SUCCESS: Extracted 64 animation frames + 16 pills/emblems! Total assets = {len(kept_assets)}, updated manual icons = {updated_icons}, fixed summaries = {fixed_summaries}")


if __name__ == "__main__":
    main()
