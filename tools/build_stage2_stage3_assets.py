#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Builds:
  1. Stage 2 (`2_weapons`): 126 Registered `208x284` (`104x142` 1x) Paperdoll Handheld Weapon Layers (`art/busts/weapon/`),
     12 Registered Paperdoll Offhand Shield Layers (`art/busts/shield/`),
     4 Shan Hai Red Armor Busts (`art/busts/body/wx_armor_*`) & 2 Shan Hai Red Helmet Busts (`art/busts/hat*/wx_helm_*`).
  2. Stage 3 (`3_characters`): Extracts 32 New 3/4-Right Hand-Painted Jianghu & Folkloric Enemy Busts (`Sheets 54 & 55`).
  3. Renders visual QA board `diag_paperdoll_handheld_and_enemies.jpg` to verify zero face clipping & natural grip!
"""

import json
import os
import shutil
import sys
from PIL import Image, ImageDraw, ImageFilter, ImageOps

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import build_wuxia_bust_system as bsys

ART_DIR = os.path.join(ROOT, "art")
SHEETS_DIR = os.path.join(ART_DIR, "sheets")
BUSTS_DIR = os.path.join(ART_DIR, "busts")
BRAIN_DIR = r"C:\Users\25647\.gemini\antigravity\brain\fa3a61d2-2588-454a-a04d-cca189377964"

RAW_SHEETS = {
    "sheet_54.jpg": "jianghu_imperial_elite_busts_4x4_1795181838408.jpg",
    "sheet_55.jpg": "wuxia_enemy_busts_4x4_1795181832840.jpg",
}

SHEET54_ENEMIES = [
    ("wx_enemy_shaolin_monk",     "少室护寺铜人僧",   "名门劲敌 · 少室禅院", "浑身涂抹金铜药油、肌肉虬结的少室护寺武僧，双拳刚猛无俦且横练反震刀剑。"),
    ("wx_enemy_taihe_elder",      "太和紫霄执剑道长", "名门劲敌 · 太和玄门", "头戴紫金阴阳莲花冠、三绺银髯飘洒的玄门宿老，精擅两仪反击与内家柔云卸劲。"),
    ("wx_enemy_gaibang_elder",    "丐帮九袋护法长老", "名门劲敌 · 天下丐帮", "肩缀九只麻布口袋、腰悬酒葫芦的白发百战老丐，一根竹棒可封尽重甲武士破绽。"),
    ("wx_enemy_emei_sword",       "峨眉玄衣执刺女剑侍","名门劲敌 · 峨眉金顶", "银簪挽髻、神色凛若寒霜的金顶女剑手，剑刺双绝且招招认穴封脉。"),
    ("wx_enemy_tangmen_killer",   "唐门机括毒匣杀手", "奇门劲敌 · 蜀中唐门", "紫黑面巾遮面、肩负青铜暴雨机括匣的暗夜杀手，十步之内毒针雷火齐发。"),
    ("wx_enemy_weiyuan_captain",  "威远虎头重甲总镖头","名门劲敌 · 威远镖局", "披吞山兽首护肩铁铠、方髯虎目的总镖头，横枪守线并振臂稳固全队军心。"),
    ("wx_enemy_youming_assassin", "幽冥鬼面双匕死士", "黑道劲敌 · 幽冥隐杀", "覆惨白碎裂骷髅铁面、背插双分水刺的绝命刺客，专寻受制破绽一击穿心。"),
    ("wx_enemy_yunmeng_viper",    "云梦赤练软鞭妖姬", "奇门劲敌 · 云梦鞭门", "鬓插银蛇发饰、肩盘倒刺铁长鞭的狠辣女高手，绕盾击头并锁喉散气。"),
    ("wx_enemy_garrison_general", "藩镇玄甲长戟都统", "官军劲敌 · 地方藩镇", "顶红缨金龙兜鍪、披玄黑山文重铠的节度使亲卫统制，长戟重阵破甲如泥。"),
    ("wx_enemy_shenji_musketeer", "神机营红夷火铳手", "官军劲敌 · 神机火器营","戴铁笠盔、胸挂黑药竹管与铅子袋的官军火器精兵，近距排铳轰击成片失衡。"),
    ("wx_enemy_liushan_bailiff",  "六扇门朱衣铁索捕头","公门劲敌 · 刑部六扇门","乌纱展角帽配猩红公服、双肩缠绕精钢锁龙链的名捕，善擒拿夺刃与锁足。"),
    ("wx_enemy_dongchang_agent",  "东厂绣春飞鱼缇骑", "公门劲敌 · 皇城番子", "压低黑金竹笠、身着赤紫飞鱼赐服的阴鸷番子，绣春快刀与追魂劲弩兼修。"),
    ("wx_enemy_mobei_centurion",  "漠北苍狼弯刀百夫长","塞外劲敌 · 苍狼骑部", "狼首铁兜鍪衬白狼毛领的草原百战头目，弯刀噬血连斩且骑射追魂。"),
    ("wx_enemy_mingzun_hierophant","西域圣火拜火法王","西域劲敌 · 圣火明尊教","缠赤金火纹高冠、胸佩圣火铜章的西域护教法王，七伤拳劲隔甲摧伤脏腑。"),
    ("wx_enemy_dongting_pirate",  "洞庭连环水寨翻江寇","绿林劲敌 · 江淮水寇", "额束绛红抹额、身披鲨皮铁环水靠的悍匪头领，翻江斩浪刀与毒蛟鞭并用。"),
    ("wx_enemy_liaodong_boss",    "辽东劈山黑熊寨主", "绿林劲敌 · 关东巨寇", "额箍铆钉黑铁带、披黑熊皮与重铁肩甲的劈山盟巨匪，巨斧旋斩碎盾裂颅。"),
]

SHEET55_ENEMIES = [
    ("wx_enemy_wudu_blowgun",     "五毒密林吹箭伏兵", "五毒奇门 · 密林伏兵", "披伪装藤叶斗篷、戴枯木傩面手持细竹吹管的南疆伏兵，暗处吹针见血封喉。"),
    ("wx_enemy_wudu_gushaman",    "五毒银冠花蛛蛊师", "五毒奇门 · 驭虫祭司", "顶苗银百足虫角冠、肩爬巨型鬼面毒蛛的阴森蛊师，弹指散播万蛊毒瘴。"),
    ("wx_enemy_nanman_rattan",    "南疆油藤甲毒标猎手","五毒奇门 · 蛮荒藤卫", "面涂赤血战纹、全身披挂桐油浸渍老藤重甲的密林猎手，轻便耐射且善掷毒梭。"),
    ("wx_enemy_wanxian_patriarch","万仙坛赤发毒魔老祖","五毒奇门 · 魔窟教主", "赤白狂发怒张、满面紫黑毒脉盘踞的五毒老魔，肩伏碧玉巨蝎，浑身剧毒反噬。"),
    ("wx_enemy_heishui_berserker","关外黑水熊首狂战", "关外战帮 · 狂暴猛士", "头顶狰狞黑熊颅骨皮帽、怒吼搏命的北境巨汉，伤势愈重巨斧劈砍愈发狂暴。"),
    ("wx_enemy_steppe_shaman",    "朔漠鹿角骨鼓萨满", "关外战帮 · 战鼓祭司", "戴惨白鹿角兽骨面具、身缀乌鸦黑羽的大漠萨满，擂动人皮骨鼓催发全军狂热。"),
    ("wx_enemy_bronze_yaoren",    "邪派铁枷铜尸药人", "邪派魔窟 · 炼体药人", "被秘药淬成古铜铁皮、颈锁精铁重枷的失心巨汉，痛觉全丧且双拳撼山裂地。"),
    ("wx_enemy_xuesha_juggernaut","血煞魔窟黑铁狂魔", "邪派魔窟 · 血煞总瓢把","全身裹于带刺黑铁恶鬼重铠中的魔道霸主，燃血狂斩连收人命。"),
    ("wx_enemy_tomb_automaton",   "前朝玄宫青铜机关卒","古墓机关 · 守陵兵俑", "遍布绿锈的先秦前朝青铜发条甲士，双目透出幽青机括寒光，不知疲倦与恐惧。"),
    ("wx_enemy_tomb_general",     "前朝镇陵金甲机关将","古墓机关 · 镇墓神将", "通体鎏金兽面吞肩的巨型守陵机关将军，挥动千钧铜戟横扫盗墓闯入者。"),
    ("wx_enemy_mohist_puppet",    "前朝墨家三目连弩俑","古墓机关 · 机括射手", "由百年铁桦木与青铜齿轮咬合驱动的三目测距机关俑，腹藏连弩攒射破甲钢矢。"),
    ("wx_enemy_tomb_swordwraith", "古墓玄棺血影剑魔", "古墓机关 · 千年尸仙", "身披残破前朝玉殓服、双目赤红如血的千年古墓剑尸，身法鬼魅瞬移斩首。"),
    ("wx_enemy_chenzhou_herder",  "湘西辰州摇铃赶尸匠","湘西尸傀 · 驭尸妖道", "头戴垂挂黄纸朱砂符黑竹笠、手持招魂摄魄铜铃的辰州术士，摇铃驱使跳僵围攻。"),
    ("wx_enemy_iron_jiangshi",    "湘西黑符铁甲跳僵", "湘西尸傀 · 铁甲僵尸", "面色青紫僵硬、额贴镇魂黄符的前朝边军铁甲死尸，刀枪难伤且免疫点穴奇毒。"),
    ("wx_enemy_jiuyou_necromancer","九幽白骨冠驭魂妖道","湘西尸傀 · 邪宗长老","枯瘦如骷髅、头顶惨白骨冠身绕碧绿鬼火的九幽妖道，隔空摄魂摧垮生人战意。"),
    ("wx_enemy_crimson_wraith",   "荒冢怨煞红衣厉魄", "湘西尸傀 · 凶煞怨灵", "笼罩于浓墨阴气与残破暗红冥衣中的凄厉怨魂，尖啸穿脑直伤心神定力。"),
]

TWO_HAND_LONG_IDS = {
    "wx_relic_chixiao", "wx_relic_juque", "wx_relic_modao", "wx_relic_tulong",
    "wx_relic_liquan", "wx_relic_hutouqiang", "wx_relic_huaji", "wx_relic_yanyue",
    "wx_relic_goulianqiang", "wx_relic_bawangqiang", "wx_relic_huntiegun", "wx_relic_lvzhuzhang",
    "wx_relic_wengjinchui", "wx_relic_pochengyue", "wx_relic_kaitian_changfu", "wx_relic_xingtianqi",
    "wx_relic_zhuyinjian", "wx_relic_taowudao", "wx_relic_gonggongshuo", "wx_relic_qiangliangge",
    "wx_relic_jiufengji", "wx_relic_kuafuzhang", "wx_relic_kuiguchui", "wx_relic_chiyoufu",
    "wx_wpn_sword_07", "wx_wpn_sword_08", "wx_wpn_saber_06", "wx_wpn_saber_07", "wx_wpn_saber_08",
}


def orient_weapon_upright_right(tc_rgba: Image.Image, aid: str) -> Image.Image:
    """
    Ensures weapon blade/tip points toward UPPER-RIGHT (`~24°` from vertical) for natural 3/4-right carry!
    """
    w, h = tc_rgba.size
    apx = tc_rgba.getchannel("A").load()
    # Compare upper-left vs upper-right alpha mass to see if diagonal leans left
    ul = sum(1 for y in range(h // 2) for x in range(w // 2) if apx[x, y] > 60)
    ur = sum(1 for y in range(h // 2) for x in range(w // 2, w) if apx[x, y] > 60)
    im = ImageOps.mirror(tc_rgba) if (ul > ur * 1.35) else tc_rgba.copy()
    # If weapon was drawn along 45° diagonal (`0.72 <= w/h <= 1.38`), rotate +16° counter-clockwise so it stands more upright!
    ratio = im.width / float(max(1, im.height))
    if 0.68 <= ratio <= 1.42 and not ("fist" in aid or "zhao" in aid or "wan" in aid or "shd" in aid):
        im = im.rotate(16, resample=Image.Resampling.BICUBIC, expand=True)
        im = bsys.tight_crop(im)
    return im


def build_weapon_bust_layer(hd_rgba: Image.Image, aid: str, ped_clip: Image.Image) -> Image.Image:
    W, H = 208, 284
    tc = bsys.decontaminate_white_fringe(bsys.tight_crop(hd_rgba), passes=1)
    im = bsys.bb_grade(orient_weapon_upright_right(tc, aid))

    is_fist = ("fist" in aid or aid in ("wx_relic_qiongqizhao", "wx_relic_longlinzhao", "wx_relic_jingangwan", "wx_relic_luwuzhao"))
    is_ranged = any(k in aid for k in ("_bow_", "_xbow_", "_gun_", "_throw_", "zhentiangong", "shenbinu", "xunleichong", "feidaonang", "yingzhaogong", "gudiaonu", "huodouchong", "tiangoubiao"))
    is_dagger = ("dagger" in aid or aid in ("wx_relic_yuchang", "wx_relic_xufuren", "wx_relic_qinyuanbi"))
    is_long_2h = (
        aid in TWO_HAND_LONG_IDS
        or any(k in aid for k in ("_spear_05", "_spear_06", "_spear_07", "_spear_08", "_pole_", "_staff_", "_hammer_06", "_hammer_07", "_hammer_08", "_axe_06", "_axe_07", "_axe_08"))
    )

    if is_fist:
        max_w, max_h = 90, 84
        cx, cy = 138, 212
    elif is_ranged:
        max_w, max_h = (84, 92) if ("throw" in aid or "feidaonang" in aid or "tiangoubiao" in aid) else (92, 144)
        cx, cy = 160, 174
    elif is_dagger:
        max_w, max_h = 74, 104
        cx, cy = 160, 184
    elif is_long_2h:
        max_w, max_h = 98, 198
        cx, cy = 160, 138
    else:
        max_w, max_h = 88, 142
        cx, cy = 162, 166

    s = min(max_w / float(max(1, im.width)), max_h / float(max(1, im.height)))
    nw, nh = max(1, int(round(im.width * s))), max(1, int(round(im.height * s)))
    im_s = bsys.decontaminate_white_fringe(im.resize((nw, nh), Image.Resampling.LANCZOS), passes=1)

    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    px = max(2, min(W - nw - 2, cx - nw // 2))
    py = max(4, min(258 - nh, cy - nh // 2))
    layer.alpha_composite(im_s, (px, py))

    # Protect the character's core facial features `[92..140, 88..154]` so NO wide weapon guard ever covers an eye or nose!
    face_guard = Image.new("L", (W, H), 0)
    ImageDraw.Draw(face_guard).ellipse([94, 88, 140, 154], fill=255)
    face_guard = face_guard.filter(ImageFilter.GaussianBlur(1.2))
    a_ch = bsys.bool_subtract(layer.getchannel("A"), face_guard)
    a_ch = bsys.bool_intersect(a_ch, ped_clip)
    layer.putalpha(a_ch)

    return bsys.bake_self_drop_shadow(layer, dx=-3, dy=3, blur=2.2, alpha_scale=0.52)


def build_shield_bust_layer(hd_rgba: Image.Image, ped_clip: Image.Image) -> Image.Image:
    W, H = 208, 284
    tc = bsys.decontaminate_white_fringe(bsys.tight_crop(hd_rgba), passes=1)
    im = bsys.bb_grade(tc.rotate(-5, resample=Image.Resampling.BICUBIC, expand=True))
    im = bsys.tight_crop(im)
    max_w, max_h = 88, 108
    s = min(max_w / float(max(1, im.width)), max_h / float(max(1, im.height)))
    nw, nh = max(1, int(round(im.width * s))), max(1, int(round(im.height * s)))
    im_s = bsys.decontaminate_white_fringe(im.resize((nw, nh), Image.Resampling.LANCZOS), passes=1)

    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    # Left forearm/chest (`x=14..102, y=150..256`), strictly below ear/jaw (`y=150`)!
    px = max(6, 56 - nw // 2)
    py = max(148, 204 - nh // 2)
    layer.alpha_composite(im_s, (px, py))
    layer.putalpha(bsys.bool_intersect(layer.getchannel("A"), ped_clip))
    return bsys.bake_self_drop_shadow(layer, dx=3, dy=3, blur=2.4, alpha_scale=0.55)


def make_handheld_pedestal_clip() -> Image.Image:
    m = Image.new("L", (208, 284), 255)
    d = ImageDraw.Draw(m)
    # Trim anything hanging below the iron pedestal base (`y > 264`)
    d.rectangle([0, 264, 208, 284], fill=0)
    return m.filter(ImageFilter.GaussianBlur(0.8))


def main():
    os.makedirs(os.path.join(BUSTS_DIR, "weapon"), exist_ok=True)
    os.makedirs(os.path.join(BUSTS_DIR, "shield"), exist_ok=True)
    os.makedirs(os.path.join(ART_DIR, "game", "entity", "enemies"), exist_ok=True)

    for dst_name, raw_name in RAW_SHEETS.items():
        src_p = os.path.join(BRAIN_DIR, raw_name)
        dst_p = os.path.join(SHEETS_DIR, dst_name)
        if os.path.exists(src_p):
            shutil.copy2(src_p, dst_p)

    _, _, ped_tmask = bsys.make_pedestal_layers()
    ped_clip = make_handheld_pedestal_clip()

    manifest_path = os.path.join(ART_DIR, "manifest.json")
    manifest = json.load(open(manifest_path, "r", encoding="utf-8"))
    new_enemy_ids = {x[0] for x in (SHEET54_ENEMIES + SHEET55_ENEMIES)}
    assets = [a for a in manifest["assets"] if a["id"] not in new_enemy_ids]

    wpn_cnt = shd_cnt = gear_cnt = 0
    for a in assets:
        if a["stage"] != "2_weapons":
            continue
        aid = a["id"]
        if not a.get("hdPath") or not os.path.exists(os.path.join(ROOT, a["hdPath"])):
            continue
        hd_im = Image.open(os.path.join(ROOT, a["hdPath"])).convert("RGBA")

        if aid.startswith("wx_shd_"):
            shd_layer = build_shield_bust_layer(hd_im, ped_clip)
            b_rel = f"art/busts/shield/{aid}.png"
            shd_layer.save(os.path.join(ROOT, b_rel))
            a["pdRole"] = "shield"
            a["bustPath"] = b_rel
            shd_cnt += 1
        elif aid.startswith("wx_armor_"):
            right_im = ImageOps.mirror(hd_im)
            b_rel = f"art/busts/body/{aid}.png"
            bsys.register_torso_bust(right_im, ped_tmask).save(os.path.join(ROOT, b_rel))
            a["pdRole"] = "torso"
            a["bustPath"] = b_rel
            gear_cnt += 1
        elif aid.startswith("wx_helm_"):
            right_im = ImageOps.mirror(hd_im)
            hb, hf, hcomb = bsys.register_hat_boolean(right_im, "wx_hat_30")
            hb_rel = f"art/busts/hat_back/{aid}.png"
            hf_rel = f"art/busts/hat_front/{aid}.png"
            hc_rel = f"art/busts/hat/{aid}.png"
            hb.save(os.path.join(ROOT, hb_rel))
            hf.save(os.path.join(ROOT, hf_rel))
            hcomb.save(os.path.join(ROOT, hc_rel))
            a["pdRole"] = "hat"
            a["bustPath"] = hc_rel
            a["bustBackPath"] = hb_rel
            a["bustFrontPath"] = hf_rel
            gear_cnt += 1
        elif aid.startswith("wx_acc_"):
            continue
        else:
            wpn_layer = build_weapon_bust_layer(hd_im, aid, ped_clip)
            b_rel = f"art/busts/weapon/{aid}.png"
            wpn_layer.save(os.path.join(ROOT, b_rel))
            a["pdRole"] = "weapon"
            a["bustPath"] = b_rel
            wpn_cnt += 1

    # Extract 32 new Jianghu & Low-Magic Folkloric Enemy Busts (`Sheets 54 & 55`)
    new_enemy_assets = []
    for sheet_fn, defs, grp_title in [
        ("sheet_54.jpg", SHEET54_ENEMIES, "江湖敌军 · 正邪宗门与朝廷藩镇精锐（16款）"),
        ("sheet_55.jpg", SHEET55_ENEMIES, "江湖敌军 · 五毒药人与古墓尸傀精锐（16款）"),
    ]:
        sh = Image.open(os.path.join(SHEETS_DIR, sheet_fn))
        cw, ch = sh.width // 4, sh.height // 4
        for idx, (aid, nm, sub, brf) in enumerate(defs):
            r, c = divmod(idx, 4)
            rgba = bsys.flood_white_bg(sh.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch)), bg_thresh=30, feather=20)
            rgba = bsys.bb_grade(rgba)
            hd_rel, g_rel = bsys.save_catalog_pair(rgba, aid, f"entity/enemies/{aid}.png", 128)
            new_enemy_assets.append({
                "id": aid,
                "stage": "3_characters",
                "group": grp_title,
                "name": nm,
                "sub": sub,
                "spec": "104×142 敌军战术半身胸像 (.brush)",
                "slotKind": "boss",
                "status": "in_game",
                "hdPath": hd_rel,
                "previewPath": g_rel,
                "swPath": "",
                "smallPath": "",
                "pdRole": "enemy_bust",
                "gameTarget": f"brushes/wx_beasts_0.brush#{aid}",
                "vanillaFallback": "bust_bandit_leader",
                "codeRef": "mod_wuxia/mod_wuxia/config/wx_encounters.nut",
                "brief": brf,
            })

    # Insert new enemy busts right at the end of `3_characters`
    idx_ins = max(i for i, a in enumerate(assets) if a["stage"] == "3_characters") + 1
    assets[idx_ins:idx_ins] = new_enemy_assets

    manifest["version"] = "0.9.0-paperdoll-armory-and-64-enemies-819"
    manifest["assets"] = assets
    manifest["summary"]["total"] = len(assets)
    manifest["summary"]["in_game"] = sum(1 for x in assets if x["status"] == "in_game")
    manifest["summary"]["wiki_ready"] = sum(1 for x in assets if x["status"] == "wiki_ready")
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)

    # Render Visual QA Board (`4x4` = 8 Paperdoll Heroes holding diverse Weapons+Shields+ShanHai Gear + 8 New Enemy Busts)
    ped_back = Image.open(os.path.join(BUSTS_DIR, "pedestal_back.png"))
    ped_front = Image.open(os.path.join(BUSTS_DIR, "pedestal_front.png"))
    qa = Image.new("RGBA", (8 * 140, 2 * 180), (22, 17, 13, 255))
    sample_loadouts = [
        ("wx_head_18", "wx_hair_09", "wx_beard_09", "wx_body_sect_03", None,          "wx_relic_chengying", "wx_shd_03"),
        ("wx_head_02", "wx_hair_16", "wx_beard_15", "wx_body_hvy_04",  "wx_hat_32",   "wx_relic_bawangqiang", None),
        ("wx_head_25", "wx_hair_13", "wx_beard_18", "wx_armor_zhuyan", "wx_helm_taotie","wx_relic_kaitian_changfu", None),
        ("wx_head_33", "wx_hair_12", None,          "wx_armor_qiongqi",None,          "wx_wpn_sword_05",    "wx_shd_08"),
        ("wx_head_11", "wx_hair_14", "wx_beard_21", "wx_body_sect_01", "wx_hat_09",   "wx_relic_jingangwan", None),
        ("wx_head_19", "wx_hair_24", "wx_beard_23", "wx_body_arm_07",  "wx_hat_27",   "wx_wpn_saber_04",    "wx_shd_06"),
        ("wx_head_31", "wx_hair_11", "wx_beard_13", "wx_body_arm_04",  "wx_hat_03",   "wx_relic_zhentiangong", None),
        ("wx_head_30", "wx_hair_04", "wx_beard_17", "wx_armor_feiyi",  "wx_helm_bashe","wx_relic_wengjinchui", None),
    ]
    for i, (hid, hrid, bdid, tid, htid, wid, sid) in enumerate(sample_loadouts):
        im = Image.new("RGBA", (208, 284), (0, 0, 0, 0))
        im.alpha_composite(ped_back)
        im.alpha_composite(Image.open(os.path.join(BUSTS_DIR, "body", f"{tid}.png")))
        im.alpha_composite(ped_front)
        if htid:
            im.alpha_composite(Image.open(os.path.join(BUSTS_DIR, "hat_back", f"{htid}.png")))
        im.alpha_composite(Image.open(os.path.join(BUSTS_DIR, "head", f"{hid}.png")))
        if bdid:
            im.alpha_composite(Image.open(os.path.join(BUSTS_DIR, "beard", f"{bdid}.png")))
        if not htid:
            im.alpha_composite(Image.open(os.path.join(BUSTS_DIR, "hair", f"{hrid}.png")))
        if htid:
            im.alpha_composite(Image.open(os.path.join(BUSTS_DIR, "hat_front", f"{htid}.png")))
        if sid:
            im.alpha_composite(Image.open(os.path.join(BUSTS_DIR, "shield", f"{sid}.png")))
        if wid:
            im.alpha_composite(Image.open(os.path.join(BUSTS_DIR, "weapon", f"{wid}.png")))
        card = im.resize((130, 174), Image.Resampling.LANCZOS)
        qa.alpha_composite(card, (i * 140 + 5, 3))

    for i, aid in enumerate(["wx_enemy_shaolin_monk", "wx_enemy_emei_sword", "wx_enemy_garrison_general", "wx_enemy_dongchang_agent",
                             "wx_enemy_wudu_gushaman", "wx_enemy_bronze_yaoren", "wx_enemy_tomb_general", "wx_enemy_iron_jiangshi"]):
        eim = Image.open(os.path.join(ROOT, f"art/hd/{aid}.png")).resize((132, 132), Image.Resampling.LANCZOS)
        qa.alpha_composite(eim, (i * 140 + 4, 180 + 24))

    os.makedirs(os.path.join(BRAIN_DIR, "scratch"), exist_ok=True)
    qa.convert("RGB").save(os.path.join(BRAIN_DIR, "scratch", "diag_paperdoll_handheld_and_enemies.jpg"), quality=95)
    print(f"SUCCESS: Built {wpn_cnt} weapon layers, {shd_cnt} shield layers, {gear_cnt} ShanHai gear busts & {len(new_enemy_assets)} enemy busts! Total = {len(assets)}")


if __name__ == "__main__":
    main()
