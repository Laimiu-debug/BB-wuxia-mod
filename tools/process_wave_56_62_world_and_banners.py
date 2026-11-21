#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Processes Wave 56..63 (Row 4 — 大地图城镇、山门、行军棋子与战团竖幅长战旗):
  - Sheet 56: 16 Isometric World Map Chinese Settlements, Garrisons, Villages & Sect Mountain Gates
  - Sheet 57: 16 Town Interior Hilltop Halls (`BackgroundCenter`) & Stepped Flanking Houses (`BackgroundLeft/Right`)
  - Sheet 58: 14 Clickable Chinese Town Shop Buildings + World Camp Tent + Chinese Junk Warship
  - Sheet 59: 16 World Map Marching Chess Pieces Part I (Player Tiers, Caravans, Sect Patrols, Imperial Armies)
  - Sheet 60: 16 World Map Marching Chess Pieces Part II (Outlaws, Cults, Undead & Shan Hai Jing Roaming Beasts)
  - Sheet 61: 16 Ming/Song Chinese Vertical Long War Standards (`banner_51..62` + 4 World Faction Standards)
  - Sheet 62 & 63: 8 Panoramic Song/Ming Town Interior Landscape Backdrops (`wx_bg_*.jpg` + `_night.jpg`, 1024x588)

Generates:
  1. Staging PNGs under `art/world_settlement/`, `art/world_entity/`, `art/banners_tactical/` for `compile_wuxia_brushes.py`
  2. Loose Town Interior UI layers under `mod_wuxia/gfx/ui/settlements/` & `mod_wuxia/gfx/ui/settlement_sprites/`
     (including Day, Night, Snow, Snow+Night, Closed, and `_b.png` / `_night_b.png` hover rim highlights!)
  3. Loose Company & Faction Banners under `mod_wuxia/gfx/ui/banners/` (`250x401` + `85x148` small) &
     inventory polearm icons under `mod_wuxia/gfx/ui/items/weapons/banner/` (`70x140` + `70x70`)
  4. Stage `6_world` in `art/manifest.json` (`819 -> 921` total in-game Wuxia assets!)
"""

import json
import math
import os
import shutil
import sys
from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter, ImageOps

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import build_wuxia_bust_system as bsys

ART_DIR = os.path.join(ROOT, "art")
SHEETS_DIR = os.path.join(ART_DIR, "sheets")
HD_DIR = os.path.join(ART_DIR, "hd")
GAME_DIR = os.path.join(ART_DIR, "game")
MOD_ROOT = os.path.join(ROOT, "mod_wuxia")
BRAIN_DIR = r"C:\Users\25647\.gemini\antigravity\brain\1a68c4ec-481a-4fb9-96f7-dcbd620cf429"

RAW_SHEETS = {
    "sheet_56.jpg": "wuxia_settlements_4x4_final_1795186645778.jpg",
    "sheet_57.jpg": "wuxia_town_buildings_4x4_1795186609847.jpg",
    "sheet_58.jpg": "wuxia_town_buildings_sheet_1795186612109.jpg",
    "sheet_59.jpg": "wuxia_overworld_figurines_4x4_1795186618069.jpg",
    "sheet_60.jpg": "wuxia_overworld_figurines_4x4_1795186612641.jpg",
    "sheet_61.jpg": "wuxia_banners_4x4_sheet_v2_1795186662213.jpg",
    "sheet_62.jpg": "wuxia_village_bg_sheet_1_1795186648165.jpg",
    "sheet_63.jpg": "wuxia_village_bg_sheet_2_1795186662405.jpg",
}

# (cell_idx, id, w, h, ox, oy, has_undead, name, sub, brief)
SHEET56_WORLD_SETTLEMENTS = [
    (0,  "wx_set_village_01",    244, 171, 0,  5, True,  "中原茅檐青瓦村落", "大地图聚落 · 一阶农庄乡里", "灰瓦祠堂配两座黄泥茅舍与竹篱晒谷场，替换原版欧式茅草屋村落。"),
    (1,  "wx_set_town_02",       241, 208, 0,  5, True,  "州县飞檐县衙市镇", "大地图聚落 · 二阶州县市镇", "青砖石牌坊、重檐县衙正堂与红灯酒肆坊巷，替换原版中型木石城镇。"),
    (2,  "wx_set_prefecture_03", 294, 249, 0,  5, True,  "雄州重檐谯楼大府", "大地图聚落 · 三阶繁华州府", "巍峨包砖雉堞城垣、三滴水钟鼓谯楼与朱瓦府衙，替换原版大型欧式都会。"),
    (3,  "wx_set_outpost_01",    252, 199, 0, 10, True,  "边塞木石烽燧军堡", "大地图军镇 · 一阶边防烽堡", "夯土包石望火墩台燃起狼烟，外围环绕圆木寨栅与拒马尖桩。"),
    (4,  "wx_set_garrison_02",   255, 224, 0, 15, True,  "九边瓮城箭楼军镇", "大地图军镇 · 二阶驻军卫所", "条石包砌瓮城马面与重檐敌台箭楼，千斤铁闸森然守御官道要冲。"),
    (5,  "wx_set_citadel_03",    294, 246, 0, 15, True,  "藩镇节度使雄关帅城", "大地图军镇 · 三阶节镇雄城", "四隅角楼耸立的玄砖重城，正中鎏金鸱吻镇远主楼统摄一方兵马。"),
    (6,  "wx_set_oasis_city_01", 302, 247, 0, 15, False, "西域丝路夯土琉璃雄城", "大地图重镇 · 丝路都护雄州", "敦煌高昌制式黄土重垣与孔雀蓝琉璃歇山顶都护府，彻底替换原版清真寺圆顶。"),
    (7,  "wx_set_sect_mountain", 280, 236, 0, 12, False, "名门正宗云峰石阶山门", "大地图山门 · 险岳剑宗道庭", "百级青石蹬道直通汉白玉三门牌坊与绝壁苍松道宫，尽显名门山门气象。"),
    (8,  "wx_set_sect_monastery",276, 232, 0, 12, False, "古刹禅林红墙钟楼山门", "大地图山门 · 禅宗古刹武院", "赭红院墙合围重檐大雄宝殿、七级石浮屠与晨钟亭，映射名山禅武重镇。"),
    (9,  "wx_set_water_market",  268, 204, 0,  6, False, "江淮水乡廊桥乌篷市镇", "大地图聚落 · 泽国漕运水镇", "粉墙黛瓦临水吊脚楼配单孔石拱风雨廊桥与乌篷渡船，映射水泽江海城镇。"),
    (10, "wx_houses_01",         260, 176, 0, -4, False, "竹篱茅舍农家小院", "聚落外围坊舍 · 农庄民居", "三间黄泥茅顶与灰瓦农舍围成竹篱小院，点缀村落外围地块。"),
    (11, "wx_houses_02",         268, 172, 0, -4, False, "青砖黛瓦四合民居群", "聚落外围坊舍 · 市镇宅院", "四座青砖灰瓦马头墙院落紧凑合围，点缀中型州县外围坊巷。"),
    (12, "wx_houses_03",         282, 180, 0, -4, False, "重檐雕栏酒楼商肆街坊", "聚落外围坊舍 · 州府繁华街市", "雕花木窗重檐商楼高悬红灯笼，拱卫大州府城池外围关厢。"),
    (13, "wx_houses_04",         278, 181, 0, -4, False, "西域胡杨夯土彩篷坊市", "聚落外围坊舍 · 丝路绿洲胡坊", "夯土平顶高墙民居张挂织锦遮阳彩篷，拱卫西域丝路重镇外围。"),
    (14, "wx_att_watchtower",    236, 184, 0,  0, False, "官道青砖烽火哨楼", "聚落附属设施 · 望火戍楼", "高耸青砖收分城台配四角攒尖望亭，替换原版城镇周边木石欧式哨塔。"),
    (15, "wx_att_sect_dojo",     242, 168, 0,  0, False, "城郊演武校场与百草庄", "聚落附属设施 · 团练校场药庐", "木栅演武坪矗立三具木人桩与刀枪架、竹顶药庐，替换原版民兵营与草药林。"),
]

# (cell_idx, id, role, bbox_box, name, sub, brief)
SHEET57_TOWN_UI_ARCH = [
    (0,  "wx_ui_center_village",    "center", (155, 42, 705, 345), "村社青瓦宗祠与木牌楼", "城镇内景主殿 · 一阶村落", "沧桑木牌坊与古松掩映下的青瓦村社宗祠，坐镇小村坡顶正中。"),
    (1,  "wx_ui_center_town",       "center", (135, 22, 725, 345), "州县石狮仪门与谯鼓楼", "城镇内景主殿 · 二阶市镇", "一对威严石狮镇守县衙大门，右侧高架更鼓楼俯瞰全镇坊市。"),
    (2,  "wx_ui_center_prefecture", "center", (135,  6, 735, 332), "重檐三滴水州府宣政殿", "城镇内景主殿 · 三阶大州府", "汉白玉丹陛御道之上耸立三重飞檐巨殿，气吞山河。"),
    (3,  "wx_ui_center_sect",       "center", (145,  6, 730, 342), "名山白玉牌坊与紫霄道宫", "城镇内景主殿 · 名门山门", "三间四柱冲天白玉牌坊后耸立云雾道宫与奇松，赋予险岳城镇武林山门盛景。"),
    (4,  "wx_ui_center_outpost",    "center", (125, 28, 700, 350), "边塞圆木寨门与燃火望楼", "城镇内景主殿 · 一阶军堡", "粗壮原木排栅寨门燃起两尊铁火盆，右侧哨楼戒备森严。"),
    (5,  "wx_ui_center_garrison",   "center", (120, 12, 710, 348), "九边条石瓮城箭楼关门", "城镇内景主殿 · 二阶军镇", "厚重条石城台拱卫券顶关门，城头重檐敌楼旌旗肃穆。"),
    (6,  "wx_ui_center_citadel",    "center", (115,  6, 720, 348), "藩镇双阙铁门镇远帅城", "城镇内景主殿 · 三阶大要塞", "双子重石角楼夹峙铜钉巨门，大帅府重檐正殿高踞城巅。"),
    (7,  "wx_ui_center_oasis",      "center", (120,  6, 725, 352), "丝路黄土重垣琉璃都护府", "城镇内景主殿 · 西域雄城", "雄浑夯土墩台托起孔雀蓝琉璃重檐大殿，尽扫原版清真圆顶违和感。"),
    (8,  "wx_ui_houses_01",         "houses", None,                "坡道茅檐灰瓦农舍群", "城镇两侧坊巷 · 一阶村居", "错落分布在山坡两侧的黄泥草顶与青瓦农舍。"),
    (9,  "wx_ui_houses_02",         "houses", None,                "坡道马头墙青砖宅院群", "城镇两侧坊巷 · 二阶民居", "徽宋风韵马头墙与青砖天井院落层叠依坡而建。"),
    (10, "wx_ui_houses_03",         "houses", None,                "坡道重檐红灯酒楼画舫群", "城镇两侧坊巷 · 三阶商街", "飞檐翘角、悬满红纸灯笼的三层木构酒肆商楼夹道迎客。"),
    (11, "wx_ui_houses_04",         "houses", None,                "坡道西域夯土彩篷胡坊群", "城镇两侧坊巷 · 丝路坊市", "西域胡木挑檐夯土高屋与条纹织物遮阳篷。"),
    (12, "wx_ui_center_monastery",  "center", (135,  8, 725, 345), "红墙古刹大雄殿与七级浮屠", "城镇内景主殿 · 禅林古刹", "赭红宫墙、石塔尖顶与飞檐钟楼交相辉映的佛门武院正殿。"),
    (13, "wx_ui_houses_sect",       "houses", None,                "绝壁奇松飞亭山门精舍", "城镇两侧坊巷 · 山门侧峰", "依奇峰怪石与迎客古松修筑的石阶凉亭与弟子精舍。"),
    (14, "wx_ui_houses_water",      "houses", None,                "粉墙黛瓦临水美人靠楼阁", "城镇两侧坊巷 · 江淮水阁", "白墙黑瓦木栏挑台的水乡楼阁。"),
    (15, "wx_ui_houses_fort",       "houses", None,                "条石雉堞马面军营侧垣", "城镇两侧坊巷 · 军镇侧翼", "严整冷峻的条石女墙与戍卫角楼侧翼。"),
]

# (cell_idx, id, target_w, target_h, mirror_x, name, sub, brief)
SHEET58_BUILDINGS_AND_PROPS = [
    (0,  "wx_bldg_crowd",         186,  98, False, "江湖茶摊招贤聚义处", "城镇交互建筑 · 招募侠客 (building.crowd)", "斗笠剑客、持枪趟子手与脚夫围坐粗木茶桌议事，点击可招募各路江湖豪杰。"),
    (1,  "wx_bldg_marketplace",   460, 210, False, "州县红灯百货绸粮集", "城镇交互建筑 · 坊市杂货 (building.marketplace)", "悬红灯笼的木构市亭摆满彩绸、青花瓷瓮与米粮麻袋，兼售大路货秘籍与灵丹。"),
    (2,  "wx_bldg_tavern",        430, 268, False, "飞檐悬瓠迎客大酒肆", "城镇交互建筑 · 茶楼酒馆 (building.tavern)", "雕花二层木楼高挂红灯与金酒葫芦幌子，坛装烈酒堆满墙根，探听江湖秘闻之所。"),
    (3,  "wx_bldg_temple",        312, 210, False, "古刹青鼎济世药师祠", "城镇交互建筑 · 医馆禅祠 (building.temple)", "重檐禅殿石阶前青铜三足大鼎香烟缭绕，供侠客调理重伤暗疾。"),
    (4,  "wx_bldg_weaponsmith",   310, 224, False, "百炼红炉铁砧铸剑坊", "城镇交互建筑 · 神兵铁匠 (building.weaponsmith)", "炉火熊熊的敞轩锻坊，铁砧旁立满寒光凛冽的刀剑枪戟。"),
    (5,  "wx_bldg_armorsmith",    290, 224, False, "精工山文甲胄藤牌局", "城镇交互建筑 · 甲胄工坊 (building.armorsmith)", "木架陈列绛红山文铁铠、护心铜镜甲与包铁圆藤牌。"),
    (6,  "wx_bldg_fletcher",      362, 196, False, "神臂强弩筋弓机巧坊", "城镇交互建筑 · 弓弩作坊 (building.fletcher)", "陈列牛角筋弓、踏张木弩、竹箭壶与草靶的制弓匠铺。"),
    (7,  "wx_bldg_training_hall", 410, 275, False, "青石木人桩讲武演武馆", "城镇交互建筑 · 演武武馆 (building.training_hall)", "青石天井内设咏春木人桩、练力石锁与长兵器架，供门人切磋精进。"),
    (8,  "wx_bldg_taxidermist",   340, 226, False, "猎妖兽骨八卦炼丹房", "城镇交互建筑 · 百工剥制 (building.taxidermist)", "檐挂巨兽颅角与异兽毛皮，门前青铜八卦丹炉金焰升腾，可炼洗髓丹与山海红装。"),
    (9,  "wx_bldg_alchemist",     354, 237, False, "西域琉璃火器奇珍局", "城镇交互建筑 · 丹药火器 (building.alchemist)", "摆满孔雀蓝药瓮、黄铜药臼与黑铁震天雷弹的西域秘坊。"),
    (10, "wx_bldg_arena",         400, 240, False, "红绸战鼓生死演武擂", "城镇交互建筑 · 生死擂台 (building.arena)", "朱红彩绸高悬的四方青石擂台，三面大鼓助威，供武人搏命扬名。"),
    (11, "wx_bldg_port",          344, 280, False, "木栈漕运硬帆官渡口", "城镇交互建筑 · 江海码头 (building.port)", "延伸入水的木桩栈桥堆满货箱，旁泊硬帆木船供战团乘船远航。"),
    (12, "wx_bldg_barber",        350, 206, False, "铜镜斗笠江湖易容铺", "城镇交互建筑 · 梳篦易容 (building.barber)", "陈设圆铜镜梳妆台与各色发髻、竹笠的精巧铺面。"),
    (13, "wx_bldg_kennel",        400, 215, False, "竹栏石槽塞外猛獒坊", "城镇交互建筑 · 驯犬猎坊 (building.kennel)", "坚固竹木兽栏前两头威猛藏獒昂首守卫。"),
    (14, "wx_camp_01",            214, 156, False, "江湖油布帅帐篝火营", "大地图扎营地标 · 战团营帐", "悬挂堪舆图的油布行军大帐、刀枪木架与跃动篝火，替换原版战团扎营地标。"),
    (15, "wx_ship_junk_01",        92,  94, True,  "江海硬帆三桅福船", "大地图航行舟船 · 漕运海船", "高扬赤褐竹篾硬帆的中式三桅战船，替换原版大地图维京长船。"),
]

# (sheet_fn, cell_idx, id, is_cart, name, sub, brief)
WORLD_FIGURINES = [
    # Sheet 59 (0..15)
    ("sheet_59.jpg", 0,  "wx_fig_player_01",        False, "初涉江湖青笠少侠棋", "大地图行军棋 · 战团初阶形象", "戴青竹斗笠、背负古剑的年轻少侠棋子，代表初入武林的散镖战团。"),
    ("sheet_59.jpg", 1,  "wx_fig_player_02",        False, "名动一方玄甲镖头棋", "大地图行军棋 · 战团中阶形象", "披乌金铆钉皮甲、手持红缨铁枪的沉稳镖头棋子。"),
    ("sheet_59.jpg", 2,  "wx_fig_player_03",        False, "威震九州金冠宗师棋", "大地图行军棋 · 战团高阶形象", "束紫金武冠、披吞兽龙鳞重铠背插双剑的一代武林盟主棋子。"),
    ("sheet_59.jpg", 3,  "wx_fig_mercenary",        False, "草帽披裘捉刀刀客棋", "大地图行军棋 · 江湖受雇佣兵", "压低草帽、身披毛裘手提厚背战刀的江湖同行佣兵团棋子。"),
    ("sheet_59.jpg", 4,  "wx_cart_escort_01",       True,  "威远红绸插旗双骡镖车", "大地图行军棋 · 中原走镖商队", "双骡挽行、满载红绸封箱并斜插黑金三角镖旗的重型木镖车。"),
    ("sheet_59.jpg", 5,  "wx_cart_camel_02",        True,  "西域丝路锦缎双峰驼队", "大地图行军棋 · 塞外丝路商帮", "颈悬铜铃、满驮波斯彩锦与木箱的两匹西域双峰商驼。"),
    ("sheet_59.jpg", 6,  "wx_fig_civilian",         False, "草帽扁担行脚庄户棋", "大地图行军棋 · 乡民行商流民", "头戴竹编草帽、肩挑竹篓扁担往来城乡的百姓行脚棋子。"),
    ("sheet_59.jpg", 7,  "wx_fig_militia",          False, "黑笠号衣巡路团练棋", "大地图行军棋 · 州县团练乡勇", "戴黑漆藤笠、穿红边号衣持长矛巡山的乡勇团练棋子。"),
    ("sheet_59.jpg", 8,  "wx_fig_sect_sword",       False, "名门白玉冠巡山剑客棋", "大地图行军棋 · 正道剑宗弟子", "束白玉道冠、着竹青剑衫背负松纹剑的名门巡山与寻仇剑客棋子。"),
    ("sheet_59.jpg", 9,  "wx_fig_sect_monk",        False, "少室念珠持棍武僧棋", "大地图行军棋 · 禅门护法武僧", "顶烫戒疤、挂大木念珠持熟铜齐眉棍的少室巡山武僧棋子。"),
    ("sheet_59.jpg", 10, "wx_fig_sect_tangmen",     False, "巴蜀紫巾机括暗器手棋", "大地图行军棋 · 唐门幽冥刺客", "紫巾覆面、背负青铜暴雨机括匣指夹寒针的奇门暗杀队棋子。"),
    ("sheet_59.jpg", 11, "wx_fig_sect_gaibang",     False, "丐帮悬瓠打狗竹杖老丐棋", "大地图行军棋 · 天下丐帮弟子", "身披百结麻衣、腰悬朱红酒葫芦手拄绿竹杖的丐帮巡游棋子。"),
    ("sheet_59.jpg", 12, "wx_fig_sect_xuanbing",    False, "昆仑狐裘执剑女侠棋", "大地图行军棋 · 昆仑峨眉剑侍", "银簪束发、披雪白狐裘横持寒霜宝剑的冰雪女侠棋子。"),
    ("sheet_59.jpg", 13, "wx_fig_garrison_foot",    False, "藩镇红缨铁笠步卒棋", "大地图行军棋 · 地方藩镇巡军", "顶红缨铁笠盔、披绛红札甲挽圆盾的官军巡逻步队棋子。"),
    ("sheet_59.jpg", 14, "wx_fig_garrison_general", False, "世家凤翅金甲长戟将棋", "大地图行军棋 · 节度使主力大军", "戴鎏金凤翅兜鍪、披吞兽鱼鳞重铠执方天戟的官军主力统制棋子。"),
    ("sheet_59.jpg", 15, "wx_fig_shenji_army",      False, "边镇红甲三眼火铳官棋", "大地图行军棋 · 神机火器边军", "戴尖顶铁盔、披绯红绵甲手托黄铜三眼火铳的边镇火器军棋子。"),
    # Sheet 60 (0..15)
    ("sheet_60.jpg", 0,  "wx_fig_bandit",           False, "绿林独眼虎皮悍匪棋", "大地图行军棋 · 绿林山寨劫客", "红巾束额、戴黑眼罩穿虎皮坎肩手提豁口砍山刀的山贼棋子。"),
    ("sheet_60.jpg", 1,  "wx_fig_nomad",            False, "塞外狼首皮帽弯刀匪棋", "大地图行军棋 · 塞外沙路马贼", "顶苍狼首皮帽、披熟皮甲挥舞新月弯刀的大漠响马棋子。"),
    ("sheet_60.jpg", 2,  "wx_fig_sect_xuesha",      False, "血煞赤发鬼刃狂魔棋", "大地图行军棋 · 血煞魔宗寻仇队", "赤发如火、披黑铁尖刺护肩执染血阔剑的魔道凶徒棋子。"),
    ("sheet_60.jpg", 3,  "wx_fig_wudu",             False, "南疆木傩面吹箭毒手棋", "大地图行军棋 · 五毒奇门伏兵", "戴彩绘枯木傩面、披青叶伪装蓑衣横吹毒竹管的密林伏兵棋子。"),
    ("sheet_60.jpg", 4,  "wx_fig_yaoren",           False, "邪派断链铁枷铜药人棋", "大地图行军棋 · 炼体药人狂群", "浑身肌肉如浇铸青铜、颈锁沉重断铁链的失心炼体巨汉棋子。"),
    ("sheet_60.jpg", 5,  "wx_fig_northern_warband", False, "关外黑熊颅盔巨斧蛮棋", "大地图行军棋 · 关外铁骑战帮", "顶狰狞黑熊头骨皮盔、怒吼挥动重铁战斧的塞北战帮棋子。"),
    ("sheet_60.jpg", 6,  "wx_fig_tomb_guard",       False, "前朝绿锈幽瞳青铜俑棋", "大地图行军棋 · 古墓守陵机关军", "遍布千年铜绿、双目亮起幽青机括微光的前朝守陵甲士棋子。"),
    ("sheet_60.jpg", 7,  "wx_fig_xiangxi_corpse",   False, "湘西黄符竹笠赶尸道棋", "大地图行军棋 · 湘西尸傀邪宗", "黑竹笠垂挂镇魂黄符、手摇摄魂铜铃驱尸夜行的赶尸术士棋子。"),
    ("sheet_60.jpg", 8,  "wx_fig_beast_tiangou",    False, "山海阴山天狗苍狼棋", "大地图游荡兽群 · 阴山天狗群", "额生白月凶纹、赤目獠牙的阴山天狗异种苍狼群棋子。"),
    ("sheet_60.jpg", 9,  "wx_fig_beast_gudiao",     False, "山海西山独角蛊雕棋", "大地图游荡兽群 · 西山蛊雕群", "顶生利角、钩喙黑鳞羽的西山食人狂禽蛊雕群棋子。"),
    ("sheet_60.jpg", 10, "wx_fig_beast_chizhu",     False, "山海毒谷鬼面赤蛛棋", "大地图游荡兽群 · 五毒巨蛛群", "腹背烙印惨白骷髅鬼面、八足森然的毒谷赤蛛群棋子。"),
    ("sheet_60.jpg", 11, "wx_fig_beast_zhuyan",     False, "山海白首赤臂朱厌猿棋", "大地图游荡兽群 · 小次山朱厌", "白发怒张、双臂赤红如火的《西山经》凶猿朱厌游荡棋子。"),
    ("sheet_60.jpg", 12, "wx_fig_beast_feiyi",      False, "山海太华六足肥遗蛟棋", "大地图游荡兽群 · 太华肥遗毒蛟", "赤黑龙鳞、双翼狰狞紫瞳的太华山旱灾毒蛟肥遗棋子。"),
    ("sheet_60.jpg", 13, "wx_fig_beast_bashe",      False, "山海苍梧青鳞吞鹿巴蛇棋", "大地图游荡兽群 · 苍梧巨蟒群", "盘身昂首、青黑巨鳞寒光闪烁的洞庭苍梧巴蛇游荡棋子。"),
    ("sheet_60.jpg", 14, "wx_fig_beast_yaomei",     False, "山海青丘白发九尾魅棋", "大地图游荡兽群 · 青丘惑心妖魅", "雪发狐耳、幽蓝狐火萦绕的青丘山九尾妖魅棋子。"),
    ("sheet_60.jpg", 15, "wx_fig_beast_jianmu",     False, "山海都广盘根建木精棋", "大地图游荡兽群 · 建木树精群", "枯藤盘角、双目透出琥珀灵脂金光的千年建木树精棋子。"),
]

# (cell_idx, id, is_player_banner, name, sub, brief)
SHEET61_BANNERS = [
    (0,  "banner_51",           True,  "威远金龙护镖竖幅大纛", "战团竖幅长战旗 · 编号 51（含战场旗手大纛）", "玄黑丝绸镶赤金火焰牙边，正中盘绕五爪金龙，龙头横杆红缨矛尖威震官道。"),
    (1,  "banner_52",           True,  "太和双鹤阴阳玄门长幡", "战团竖幅长战旗 · 编号 52（含战场旗手大纛）", "靛青道门竖幅长幡镶银云纹边，双白鹤凌空拱卫太极金印。"),
    (2,  "banner_53",           True,  "少室金莲宝杵护法佛幡", "战团竖幅长战旗 · 编号 53（含战场旗手大纛）", "杏黄镶绛红火焰边竖旗，八叶金莲托起降魔金刚宝杵。"),
    (3,  "banner_54",           True,  "清风寒月双剑名宗剑旗", "战团竖幅长战旗 · 编号 54（含战场旗手大纛）", "竹青竖幅战旗镶银边，两柄寒霜宝剑交错贯透新月。"),
    (4,  "banner_55",           True,  "镇北铁甲白虎啸风帅旗", "战团竖幅长战旗 · 编号 55（含战场旗手大纛）", "暗绛红竖幅镶乌钢甲叶边，猛虎怒啸震慑塞北群寇。"),
    (5,  "banner_56",           True,  "南明烈焰金凰浴火战旗", "战团竖幅长战旗 · 编号 56（含战场旗手大纛）", "朱砂红竖幅镶鎏金火纹，展翼神凰腾焰冲霄。"),
    (6,  "banner_57",           True,  "沧溟惊涛玄武镇海战旗", "战团竖幅长战旗 · 编号 57（含战场旗手大纛）", "深海苍青竖幅配古铜浪纹边，玄龟灵蛇盘结镇守江海。"),
    (7,  "banner_58",           True,  "常羊饕餮干戚破阵凶旗", "战团竖幅长战旗 · 编号 58（含战场旗手大纛）", "焦褐百战残幡烙印黄金饕餮兽面与交错开山巨斧圆盾。"),
    (8,  "banner_59",           True,  "蜀中孔雀翎暴雨奇门旗", "战团竖幅长战旗 · 编号 59（含战场旗手大纛）", "幽紫锦缎竖旗绘翠金孔雀开屏羽扇与交错透甲寒针。"),
    (9,  "banner_60",           True,  "聚义虎头替天号令义旗", "战团竖幅长战旗 · 编号 60（含战场旗手大纛）", "明黄镶赤焰边竖幅帅旗，正中怒目金虎首统御绿林豪杰。"),
    (10, "banner_61",           True,  "幽冥日蚀骨刃隐杀魔旗", "战团竖幅长战旗 · 编号 61（含战场旗手大纛）", "墨黑碎尾长幡高悬猩红血蚀残月与交叉白骨短匕。"),
    (11, "banner_62",           True,  "昆仑冰魄九尾天狐灵旗", "战团竖幅长战旗 · 编号 62（含战场旗手大纛）", "素白冰蓝渐变竖幅银边旗，九尾瑞狐踏霜傲立。"),
    (12, "wx_fbanner_noble_01", False, "藩镇玄紫金蟒长戟官旗", "天下势力竖旗 · 地方藩镇节度使", "玄紫镶金竖幅官军牙旗，金蟒缠绕方天长戟，用于藩镇军团与敌方掌旗官。"),
    (13, "wx_fbanner_noble_02", False, "世家绯红错金麒麟节旗", "天下势力竖旗 · 名门望族世家军", "绯红镶金火焰边大旗，瑞兽金麒麟昂首踏云，用于世家大军与城池旗号。"),
    (14, "wx_fbanner_south_01", False, "西域孔雀蓝烈日圣火旗", "天下势力竖旗 · 西域丝路都护军", "孔雀蓝镶金边竖旗，十二芒金日内燃圣火，用于西域边镇大军与掌旗官。"),
    (15, "wx_fbanner_outlaw_01",False, "绿林血鸦狼首双刀寨旗", "天下势力竖旗 · 绿林山寨与寻仇队", "暗红撕裂竖幅匪旗，铁狼凶首下交错双柄砍山雪刃。"),
]

# (sheet_fn, quad_idx, id, name, sub, brief)
LANDSCAPE_BACKDROPS = [
    ("sheet_62.jpg", 0, "wx_bg_plains",    "中原烟树麦浪远山图", "城镇内景远山天幕 · 平原农庄 (1024×588)", "微风吹拂金绿麦浪，曲水绕过薄雾远山，衬托中原州府与农庄。"),
    ("sheet_62.jpg", 1, "wx_bg_mountains", "名山奇峰云海苍松图", "城镇内景远山天幕 · 险岳山门 (1024×588)", "万仞剑峰刺破浩渺云海，悬崖古松盘曲，衬托名门山门与山城关隘。"),
    ("sheet_62.jpg", 2, "wx_bg_forest",    "巴蜀翠竹幽谷岚雾图", "城镇内景远山天幕 · 密林竹海 (1024×588)", "修竹万竿耸入山岚轻雾，苍翠幽深，衬托巴蜀林镇与隐世门庭。"),
    ("sheet_62.jpg", 3, "wx_bg_swamp",     "江淮烟雨芦荡寒江图", "城镇内景远山天幕 · 水泽湖乡 (1024×588)", "垂柳依依、芦苇迷离的浩淼烟波江泽，衬托江南水乡与云梦泽镇。"),
    ("sheet_63.jpg", 0, "wx_bg_snow",      "关外万里凛雪寒山图", "城镇内景远山天幕 · 朔北雪原 (1024×588)", "朔风卷过苍茫雪野与冰封雪岭，衬托辽东边堡与昆仑雪镇。"),
    ("sheet_63.jpg", 1, "wx_bg_desert",    "西域大漠孤烟胡杨图", "城镇内景远山天幕 · 丝路沙州 (1024×588)", "金色沙丘连绵至昆仑雪线，沧桑胡杨傲立风沙，衬托丝路雄城。"),
    ("sheet_63.jpg", 2, "wx_bg_coast",     "东海惊涛礁岸烟云图", "城镇内景远山天幕 · 滨海港埠 (1024×588)", "危崖礁石俯瞰烟波浩渺的沧溟海湾与远屿，衬托沿海港口重镇。"),
    ("sheet_63.jpg", 3, "wx_bg_steppe",    "塞上秋风黄草高原图", "城镇内景远山天幕 · 塞外草原 (1024×588)", "苍凉辽阔的秋黄草甸、乱石冈峦与万里流云，衬托塞上军镇与马市。"),
]


def remove_stray_specks(rgba: Image.Image, min_pixels: int = 45) -> Image.Image:
    """Removes tiny disconnected edge specks (< min_pixels) left over from neighboring cells."""
    from collections import deque
    out = rgba.copy()
    w, h = out.size
    px = out.load()
    vis = bytearray(w * h)
    for y in range(h):
        for x in range(w):
            idx = y * w + x
            if not vis[idx] and px[x, y][3] > 16:
                vis[idx] = 1
                q = deque([(x, y)])
                comp = [(x, y)]
                while q:
                    cx, cy = q.popleft()
                    for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
                        if 0 <= nx < w and 0 <= ny < h:
                            nidx = ny * w + nx
                            if not vis[nidx] and px[nx, ny][3] > 16:
                                vis[nidx] = 1
                                q.append((nx, ny))
                                comp.append((nx, ny))
                if len(comp) < min_pixels:
                    for cx, cy in comp:
                        px[cx, cy] = (0, 0, 0, 0)
    return out


def fit_box_clean(rgba: Image.Image, tw: int, th: int, pad: int = 4) -> Image.Image:
    cleaned = remove_stray_specks(rgba, min_pixels=42)
    tc = bsys.decontaminate_white_fringe(bsys.tight_crop(cleaned), passes=1)
    tc = bsys.bb_grade(tc)
    mw, mh = max(1, tw - 2 * pad), max(1, th - 2 * pad)
    s = min(mw / float(tc.width), mh / float(tc.height))
    nw, nh = max(1, int(round(tc.width * s))), max(1, int(round(tc.height * s)))
    im_s = tc.resize((nw, nh), Image.Resampling.LANCZOS)
    out = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    out.alpha_composite(im_s, ((tw - nw) // 2, (th - nh) // 2))
    return out


def make_world_night_light_overlay(base_im: Image.Image, undead: bool = False) -> Image.Image:
    """
    Generates an additive-like transparent RGBA glow layer (`_light` / `_undead_lights`)
    so when `settlement.nut` fades in `lighting` (`IgnoreAmbientColor = true`), warm paper lanterns
    and lit windows glow softly without painting an opaque daytime building at midnight!
    """
    w, h = base_im.size
    px = base_im.load()
    glow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    gpx = glow.load()
    for y in range(int(h * 0.16), int(h * 0.86)):
        for x in range(int(w * 0.14), int(w * 0.86)):
            r, g, b, a = px[x, y]
            if a < 180:
                continue
            # Detect warm lantern/fire pixels OR dark interior window openings bordered by timber/stone
            warmness = (r - b) + (g - b) * 0.45
            lum = 0.299 * r + 0.587 * g + 0.114 * b
            is_warm_dot = (r > 155 and warmness > 48)
            is_window_nook = (26 < lum < 66 and (y % 9 in (3, 4)) and (x % 11 in (4, 5, 6)))
            if is_warm_dot or is_window_nook:
                if undead:
                    gpx[x, y] = (72, 245, 195, 225 if is_warm_dot else 165)
                else:
                    gpx[x, y] = (255, 196, 82, 235 if is_warm_dot else 185)

    halo = glow.filter(ImageFilter.GaussianBlur(2.6))
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out.alpha_composite(halo)
    out.alpha_composite(glow)
    # Clip strictly inside building silhouette
    sil = base_im.getchannel("A").filter(ImageFilter.GaussianBlur(1.2))
    out.putalpha(ImageChops.multiply(out.getchannel("A"), sil))
    return out


def make_world_ruins(base_im: Image.Image) -> Image.Image:
    """Charred, desolate war-razed settlement variant (`_ruins`)."""
    im = base_im.copy()
    rgb = im.convert("RGB")
    gray = ImageOps.grayscale(rgb).convert("RGB")
    desat = Image.blend(rgb, gray, 0.72)
    dark = ImageEnhance.Brightness(desat).enhance(0.58)
    # Tint with warm ash-soot brown
    soot = Image.new("RGB", im.size, (62, 50, 40))
    graded = Image.blend(dark, soot, 0.28)
    a = im.getchannel("A").copy()
    # Carve subtle burned roof notches along upper 32% of silhouette
    w, h = im.size
    apx = a.load()
    for y in range(int(h * 0.05), int(h * 0.36)):
        for x in range(w):
            if apx[x, y] > 0 and ((x * 7 + y * 3) % 29 < 4) and ((x // 6) % 3 == 0):
                apx[x, y] = int(apx[x, y] * 0.25)
    out = graded.convert("RGBA")
    out.putalpha(a)
    return out


def make_world_undead(base_im: Image.Image) -> Image.Image:
    """Pale ghostly Yin-shrouded settlement variant (`_undead`)."""
    im = base_im.copy()
    rgb = im.convert("RGB")
    gray = ImageOps.grayscale(rgb).convert("RGB")
    desat = Image.blend(rgb, gray, 0.65)
    dark = ImageEnhance.Brightness(desat).enhance(0.72)
    verdigris = Image.new("RGB", im.size, (58, 86, 82))
    graded = Image.blend(dark, verdigris, 0.26)
    out = graded.convert("RGBA")
    out.putalpha(im.getchannel("A"))
    return out


def make_ui_night_layer(rgba: Image.Image) -> Image.Image:
    """Transforms a Town UI architectural/building RGBA layer into its moonlit + warm-lantern `_night.png`."""
    w, h = rgba.size
    rgb = rgba.convert("RGB")
    # Cool deep midnight blue ambient multiply
    dark = ImageEnhance.Brightness(rgb).enhance(0.46)
    moon_tint = Image.new("RGB", (w, h), (34, 48, 76))
    night_rgb = Image.blend(dark, moon_tint, 0.36)
    out = night_rgb.convert("RGBA")
    out.putalpha(rgba.getchannel("A"))
    # Re-illuminate warm lanterns/furnaces/windows!
    glow = make_world_night_light_overlay(rgba, undead=False)
    out = Image.alpha_composite(out, glow)
    out.putalpha(rgba.getchannel("A"))
    return out


def make_ui_snow_layer(rgba: Image.Image) -> Image.Image:
    """Adds crisp frost/snow accumulation along upward-facing roof slopes (`_snow.png`)."""
    w, h = rgba.size
    out = rgba.copy()
    px = rgba.load()
    snow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    spx = snow.load()
    for y in range(2, int(h * 0.78)):
        for x in range(1, w - 1):
            r, g, b, a = px[x, y]
            if a < 200:
                continue
            # Upward-facing roof tile or top edge
            above_open = px[x, max(0, y - 3)][3] < 90
            lum = 0.299 * r + 0.587 * g + 0.114 * b
            cool_tile = (abs(r - b) < 28 and 55 < lum < 155 and y < h * 0.58)
            if above_open or (cool_tile and (x + y * 2) % 5 != 0):
                alpha_s = 215 if above_open else 105
                spx[x, y] = (232, 239, 246, alpha_s)
    snow_soft = snow.filter(ImageFilter.GaussianBlur(0.9))
    out = Image.alpha_composite(out, snow_soft)
    out.putalpha(rgba.getchannel("A"))
    return out


def make_ui_hover_highlight(rgba: Image.Image) -> Image.Image:
    """Creates Battle Brothers town building mouseover highlight (`_b.png` / `_night_b.png`)."""
    w, h = rgba.size
    a = rgba.getchannel("A")
    dilated = a.filter(ImageFilter.MaxFilter(5))
    rim_mask = ImageChops.subtract(dilated, a).filter(ImageFilter.GaussianBlur(1.0))
    rim = Image.new("RGBA", (w, h), (255, 222, 142, 0))
    rim.putalpha(rim_mask)
    bright_rgb = ImageEnhance.Brightness(rgba.convert("RGB")).enhance(1.18)
    bright_rgba = bright_rgb.convert("RGBA")
    bright_rgba.putalpha(a)
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out.alpha_composite(rim)
    out.alpha_composite(bright_rgba)
    return out


def make_landscape_night_jpg(day_rgb: Image.Image) -> Image.Image:
    """Converts a 1024x588 daytime landscape backdrop into a moody moonlit Wuxia night backdrop (`_night.jpg`)."""
    dark = ImageEnhance.Brightness(day_rgb).enhance(0.40)
    dark = ImageEnhance.Contrast(dark).enhance(1.08)
    night_sky = Image.new("RGB", day_rgb.size, (22, 32, 54))
    blended = Image.blend(dark, night_sky, 0.44)
    # Paint a subtle pale silver moon-glow in upper-right sky so silhouettes read atmospherically
    glow = Image.new("RGBA", day_rgb.size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse([700, -40, 980, 220], fill=(175, 198, 232, 46))
    gd.ellipse([795, 28, 845, 78], fill=(232, 240, 252, 130))
    glow = glow.filter(ImageFilter.GaussianBlur(14.0))
    comp = blended.convert("RGBA")
    comp.alpha_composite(glow)
    return comp.convert("RGB")


def extract_figurine_for_world_base(cell_rgba: Image.Image) -> Image.Image:
    """
    Places a Wuxia chess bust onto the exact `68x106` (`ox=0, oy=20`) Battle Brothers `figure_*` canvas!
    Cleanly trims off the bottom standalone pewter disk (~bottom 17% of tight crop) and curves the
    lower bust rim smoothly at `y=92` so it sits 100% natively inside vanilla `world_base_01..14` (`[12..58, 73..103]`)
    with ZERO double-pedestal!
    """
    tc = bsys.decontaminate_white_fringe(bsys.tight_crop(cell_rgba), passes=1)
    tc = bsys.bb_grade(tc)
    # Trim bottom 17.5% where the standalone grey token disk was painted
    cut_h = max(16, int(round(tc.height * 0.825)))
    bust_only = bsys.tight_crop(tc.crop((0, 0, tc.width, cut_h)))

    # Fit inside `42x48` box centered at `(34, 68)` (`x=[13..55], y=[44..92]`) matching vanilla `figure_player_01` `[17..57, 46..92]`!
    s = min(44.0 / max(1, bust_only.width), 49.0 / max(1, bust_only.height))
    nw, nh = max(1, int(round(bust_only.width * s))), max(1, int(round(bust_only.height * s)))
    im_s = bust_only.resize((nw, nh), Image.Resampling.LANCZOS)

    canvas = Image.new("RGBA", (68, 106), (0, 0, 0, 0))
    px = (68 - nw) // 2
    py = 92 - nh
    canvas.alpha_composite(im_s, (px, py))

    # Smooth elliptical bottom rim mask matching `world_base_01` inner cup
    cup_mask = Image.new("L", (68, 106), 255)
    cd = ImageDraw.Draw(cup_mask)
    cd.rectangle([0, 86, 68, 106], fill=0)
    cd.ellipse([11, 77, 57, 93], fill=255)
    cup_mask = cup_mask.filter(ImageFilter.GaussianBlur(0.6))
    canvas.putalpha(ImageChops.multiply(canvas.getchannel("A"), cup_mask))
    return canvas


def build_banner_outputs(cell_rgba: Image.Image, bid: str, is_player: bool, idx_num: int):
    """
    Produces ALL 5 Battle Brothers war-banner formats from one high-res vertical standard:
      1. `gfx/ui/banners/<bid>.png` (`250x401` RGBA)
      2. `gfx/ui/banners/<bid>s.png` (`85x148` RGBA)
      3. `art/world_entity/<bid>.png` (`56x94, ox=0, oy=28` for `wx_world_entity_0.brush`)
      4. `gfx/ui/items/weapons/banner/<bid>.png` (`70x140`) & `<bid>_70x70.png` (`70x70`)
      5. `art/banners_tactical/<tactical_id>.png` & `<tactical_id>_shaft.png` (`200x300, ox=0, oy=35` for `wx_banners_0.brush`)
    """
    tc = bsys.decontaminate_white_fringe(bsys.tight_crop(cell_rgba), passes=1)
    tc = bsys.bb_grade(tc)

    # 1. UI Full Banner (`250x401`)
    ui_full = fit_box_clean(tc, 250, 401, pad=6)
    ui_dir = os.path.join(MOD_ROOT, "gfx", "ui", "banners")
    os.makedirs(ui_dir, exist_ok=True)
    ui_full.save(os.path.join(ui_dir, f"{bid}.png"))

    # Also mirror preview into `art/game/ui/banners/` for Wiki Art Studio
    wiki_b_dir = os.path.join(GAME_DIR, "ui", "banners")
    os.makedirs(wiki_b_dir, exist_ok=True)
    ui_full.save(os.path.join(wiki_b_dir, f"{bid}.png"))

    # 2. UI Small Banner (`85x148`)
    ui_small = fit_box_clean(tc, 85, 148, pad=2)
    ui_small.save(os.path.join(ui_dir, f"{bid}s.png"))
    ui_small.save(os.path.join(wiki_b_dir, f"{bid}s.png"))

    # 3. World Map Party Flag (`56x94`, `ox=0, oy=28`)
    world_flag = fit_box_clean(tc, 56, 94, pad=2)
    we_dir = os.path.join(ART_DIR, "world_entity")
    os.makedirs(we_dir, exist_ok=True)
    world_flag.save(os.path.join(we_dir, f"{bid}.png"))

    # 4. Inventory Polearm Weapon Icons (`70x140` & `70x70`)
    # Extend a lacquered wooden shaft downward and tilt -22° for crisp inventory polearm silhouette
    pole_canvas = Image.new("RGBA", (260, 520), (0, 0, 0, 0))
    pd = ImageDraw.Draw(pole_canvas)
    # Lacquered crimson-brown hardwood pole with brass ferrule
    pd.rectangle([125, 60, 134, 505], fill=(86, 36, 24, 255), outline=(28, 16, 12, 255))
    pd.rectangle([127, 60, 130, 505], fill=(128, 58, 38, 255))
    pd.rectangle([124, 395, 135, 406], fill=(198, 158, 76, 255), outline=(40, 28, 14, 255))
    pd.polygon([(125, 505), (134, 505), (129, 516)], fill=(156, 162, 170, 255))
    b_top = fit_box_clean(tc, 236, 376, pad=2)
    pole_canvas.alpha_composite(b_top, (12, 8))

    tilted_inv = bsys.tight_crop(pole_canvas.rotate(-22, resample=Image.Resampling.BICUBIC, expand=True))
    inv_140 = fit_box_clean(tilted_inv, 70, 140, pad=3)
    inv_70 = fit_box_clean(tilted_inv, 70, 70, pad=3)
    wpn_b_dir = os.path.join(MOD_ROOT, "gfx", "ui", "items", "weapons", "banner")
    os.makedirs(wpn_b_dir, exist_ok=True)
    inv_140.save(os.path.join(wpn_b_dir, f"{bid}.png"))
    inv_70.save(os.path.join(wpn_b_dir, f"{bid}_70x70.png"))

    # 5. Tactical Battlefield Bannerman Layers (`200x300, ox=0, oy=35`)
    # Vanilla `player_banner_05` sits at `[34..132, 34..180]` (tilted +16° CCW behind character's head/left shoulder),
    # while `player_banner_05_shaft` sits at `[119..143, 120..198]` in front of the character's right hand!
    tac_dir = os.path.join(ART_DIR, "banners_tactical")
    os.makedirs(tac_dir, exist_ok=True)

    tac_rot = bsys.tight_crop(pole_canvas.crop((0, 0, 260, 430)).rotate(16, resample=Image.Resampling.BICUBIC, expand=True))
    s = min(104.0 / max(1, tac_rot.width), 162.0 / max(1, tac_rot.height))
    nw, nh = max(1, int(round(tac_rot.width * s))), max(1, int(round(tac_rot.height * s)))
    tac_s = tac_rot.resize((nw, nh), Image.Resampling.LANCZOS)

    bg_200 = Image.new("RGBA", (200, 300), (0, 0, 0, 0))
    # Position at x=42..146, y=18..180 so crossbar rises proudly behind the Bannerman's head and aligns collinearly with `_shaft`!
    bg_200.alpha_composite(tac_s, (42, 180 - nh))
    sh_a = bg_200.getchannel("A").filter(ImageFilter.GaussianBlur(2.0)).point(lambda v: int(v * 0.45))
    sh_im = Image.new("RGBA", (200, 300), (0, 0, 0, 0))
    sh_im.paste((12, 8, 6, 255), (-2, 3), sh_a)
    bg_200 = Image.alpha_composite(sh_im, bg_200)

    # Foreground grip shaft (`[125..150, 136..206]`, tilted +16° CCW collinear with background pole, clearing beard cleanly!)
    shaft_src = Image.new("RGBA", (80, 180), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shaft_src)
    sd.rectangle([36, 10, 43, 168], fill=(92, 38, 25, 255), outline=(24, 14, 10, 255))
    sd.rectangle([38, 10, 40, 168], fill=(138, 66, 42, 255))
    # Brass grip bands
    sd.rectangle([35, 58, 44, 65], fill=(206, 166, 82, 255), outline=(38, 26, 12, 255))
    sd.rectangle([35, 108, 44, 115], fill=(206, 166, 82, 255), outline=(38, 26, 12, 255))
    sd.polygon([(36, 168), (43, 168), (39, 176)], fill=(158, 164, 172, 255), outline=(28, 28, 30, 255))
    shaft_rot = bsys.tight_crop(shaft_src.rotate(16, resample=Image.Resampling.BICUBIC, expand=True))
    shaft_s = shaft_rot.resize((max(1, int(shaft_rot.width * 0.46)), max(1, int(shaft_rot.height * 0.46))), Image.Resampling.LANCZOS)
    sh_200 = Image.new("RGBA", (200, 300), (0, 0, 0, 0))
    sh_200.alpha_composite(shaft_s, (125, 136))

    if is_player:
        num_str = bid.split("_")[1]
        bg_200.save(os.path.join(tac_dir, f"player_banner_{num_str}.png"))
        sh_200.save(os.path.join(tac_dir, f"player_banner_{num_str}_shaft.png"))
    else:
        f_idx = idx_num - 11  # 1..4
        bg_200.save(os.path.join(tac_dir, f"wx_faction_banner_0{f_idx}.png"))
        if f_idx == 1:
            sh_200.save(os.path.join(tac_dir, "wx_faction_banner_shaft.png"))


def extract_2x2_landscape_quads(sheet_rgb: Image.Image):
    """Slices a 2x2 landscape sheet separated by a white cross gutter, trimming any edge white margins."""
    w, h = sheet_rgb.size
    mx, my = w // 2, h // 2
    raw_quads = [
        sheet_rgb.crop((0, 0, mx, my)),
        sheet_rgb.crop((mx, 0, w, my)),
        sheet_rgb.crop((0, my, w if False else mx, h)),
        sheet_rgb.crop((mx, my, w, h)),
    ]
    cleaned = []
    for q in raw_quads:
        qw, qh = q.size
        px = q.load()
        # Trim pure-ish white gutter rows/cols from edges
        x0, x1, y0, y1 = 0, qw, 0, qh
        while x0 < qw // 4 and sum(min(px[x0, y]) for y in range(qh // 4, 3 * qh // 4)) / max(1, qh // 2) > 244:
            x0 += 1
        while x1 > 3 * qw // 4 and sum(min(px[x1 - 1, y]) for y in range(qh // 4, 3 * qh // 4)) / max(1, qh // 2) > 244:
            x1 -= 1
        while y0 < qh // 4 and sum(min(px[x, y0]) for x in range(qw // 4, 3 * qw // 4)) / max(1, qw // 2) > 244:
            y0 += 1
        while y1 > 3 * qh // 4 and sum(min(px[x, y1 - 1]) for x in range(qw // 4, 3 * qw // 4)) / max(1, qw // 2) > 244:
            y1 -= 1
        sub = q.crop((x0 + 2, y0 + 2, x1 - 2, y1 - 2))
        # Cover-fit to exact `1024x588`
        target_ratio = 1024.0 / 588.0
        cur_ratio = sub.width / float(sub.height)
        if cur_ratio > target_ratio:
            nw = int(round(sub.height * target_ratio))
            ox = (sub.width - nw) // 2
            sub = sub.crop((ox, 0, ox + nw, sub.height))
        else:
            nh = int(round(sub.width / target_ratio))
            oy = (sub.height - nh) // 2
            sub = sub.crop((0, oy, sub.width, oy + nh))
        cleaned.append(sub.resize((1024, 588), Image.Resampling.LANCZOS))
    return cleaned


def main():
    os.makedirs(SHEETS_DIR, exist_ok=True)
    os.makedirs(HD_DIR, exist_ok=True)
    ws_dir = os.path.join(ART_DIR, "world_settlement")
    we_dir = os.path.join(ART_DIR, "world_entity")
    tac_dir = os.path.join(ART_DIR, "banners_tactical")
    os.makedirs(ws_dir, exist_ok=True)
    os.makedirs(we_dir, exist_ok=True)
    os.makedirs(tac_dir, exist_ok=True)

    mod_ui_set_dir = os.path.join(MOD_ROOT, "gfx", "ui", "settlements")
    mod_ui_spr_dir = os.path.join(MOD_ROOT, "gfx", "ui", "settlement_sprites")
    wiki_set_dir = os.path.join(GAME_DIR, "ui", "settlements")
    os.makedirs(mod_ui_set_dir, exist_ok=True)
    os.makedirs(mod_ui_spr_dir, exist_ok=True)
    os.makedirs(wiki_set_dir, exist_ok=True)

    for dst_fn, raw_fn in RAW_SHEETS.items():
        src_p = os.path.join(BRAIN_DIR, raw_fn)
        dst_p = os.path.join(SHEETS_DIR, dst_fn)
        if os.path.exists(src_p):
            shutil.copy2(src_p, dst_p)
        if not os.path.exists(dst_p):
            raise FileNotFoundError(f"Missing art sheet: {dst_p}")

    new_assets = []
    brush_meta_settlement = []
    brush_meta_entity = []

    # =========================================================================
    # 1. Sheet 56: 16 World Map Settlements, Houses & Attached Locations
    # =========================================================================
    sh56 = Image.open(os.path.join(SHEETS_DIR, "sheet_56.jpg"))
    cw, ch = sh56.width // 4, sh56.height // 4
    for (cidx, aid, tw, th, ox, oy, has_undead, nm, sub, brf) in SHEET56_WORLD_SETTLEMENTS:
        r, c = divmod(cidx, 4)
        rgba = bsys.flood_white_bg(sh56.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch)), bg_thresh=30, feather=20)
        hd_im = fit_box_clean(rgba, 256, 256, pad=10)
        hd_rel = f"art/hd/{aid}.png"
        hd_im.save(os.path.join(ROOT, hd_rel))

        prev_rel = f"art/game/ui/settlements/{aid}.png"
        fit_box_clean(rgba, 160, 128, pad=4).save(os.path.join(ROOT, prev_rel))

        if aid.startswith("wx_houses_"):
            # Generate `_01` and `_02` (mirrored architectural variation) + `_light` + `_ruins`
            for v_idx, src_v in ((1, rgba), (2, ImageOps.mirror(rgba))):
                vid = f"{aid}_0{v_idx}"
                base_v = fit_box_clean(src_v, tw, th, pad=4)
                light_v = make_world_night_light_overlay(base_v, undead=False)
                ruins_v = make_world_ruins(base_v)
                for suf, img_v in (("", base_v), ("_light", light_v), ("_ruins", ruins_v)):
                    fn = f"{vid}{suf}.png"
                    img_v.save(os.path.join(ws_dir, fn))
                    brush_meta_settlement.append({"id": f"{vid}{suf}", "file": fn, "w": tw, "h": th, "ox": ox, "oy": oy})
        else:
            base_im = fit_box_clean(rgba, tw, th, pad=4)
            light_im = make_world_night_light_overlay(base_im, undead=False)
            ruins_im = make_world_ruins(base_im)
            variants = [("", base_im), ("_light", light_im), ("_ruins", ruins_im)]
            if has_undead:
                variants.append(("_undead", make_world_undead(base_im)))
                variants.append(("_undead_lights", make_world_night_light_overlay(base_im, undead=True)))
            for suf, img_v in variants:
                fn = f"{aid}{suf}.png"
                img_v.save(os.path.join(ws_dir, fn))
                brush_meta_settlement.append({"id": f"{aid}{suf}", "file": fn, "w": tw, "h": th, "ox": ox, "oy": oy})

            # Also save `ui/settlement_sprites/<aid>.png` (`244x208`) for Settlement UI / Contract icons!
            if aid.startswith("wx_set_"):
                fit_box_clean(rgba, 244, 208, pad=6).save(os.path.join(mod_ui_spr_dir, f"{aid}.png"))

        new_assets.append({
            "id": aid, "stage": "6_world", "group": "九州城池 · 大地图城郭军镇与山门",
            "name": nm, "sub": sub, "spec": f"{tw}×{th} 大地图建筑 (.brush + 夜景/废墟)",
            "slotKind": "boss", "status": "in_game",
            "hdPath": hd_rel, "previewPath": prev_rel, "swPath": "", "smallPath": "",
            "gameTarget": f"brushes/wx_settlement_0.brush#{aid}",
            "vanillaFallback": "world_townhall_01",
            "codeRef": "mod_wuxia/mod_wuxia/systems/wx_world_visuals_system.nut",
            "brief": brf,
        })

    # =========================================================================
    # 2. Sheet 57: 16 Town Interior Screen Hilltop Halls & Flanking Houses (1024x588)
    # =========================================================================
    sh57 = Image.open(os.path.join(SHEETS_DIR, "sheet_57.jpg"))
    cw, ch = sh57.width // 4, sh57.height // 4
    for (cidx, aid, role, bbox_target, nm, sub, brf) in SHEET57_TOWN_UI_ARCH:
        r, c = divmod(cidx, 4)
        rgba = bsys.flood_white_bg(sh57.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch)), bg_thresh=30, feather=20)
        hd_rel = f"art/hd/{aid}.png"
        fit_box_clean(rgba, 256, 256, pad=8).save(os.path.join(ROOT, hd_rel))
        prev_rel = f"art/game/ui/settlements/{aid}.png"
        fit_box_clean(rgba, 180, 136, pad=4).save(os.path.join(ROOT, prev_rel))

        tc = bsys.bb_grade(bsys.decontaminate_white_fringe(bsys.tight_crop(rgba), passes=1))

        if role == "center":
            x0, y0, x1, y1 = bbox_target
            bw, bh = x1 - x0, y1 - y0
            s = min(bw / float(tc.width), bh / float(tc.height))
            nw, nh = max(1, int(round(tc.width * s))), max(1, int(round(tc.height * s)))
            im_s = tc.resize((nw, nh), Image.Resampling.LANCZOS)
            layer = Image.new("RGBA", (1024, 588), (0, 0, 0, 0))
            # Align bottom of hall around y1 (`~342`) so vanilla `ramp_01.png` (`y=240..588`) overlaps its foundation naturally!
            px = x0 + (bw - nw) // 2
            py = y1 - nh
            layer.alpha_composite(im_s, (px, py))

            day_im = layer
            night_im = make_ui_night_layer(day_im)
            snow_im = make_ui_snow_layer(day_im)
            snow_night_im = make_ui_night_layer(snow_im)

            day_im.save(os.path.join(mod_ui_set_dir, f"{aid}.png"))
            night_im.save(os.path.join(mod_ui_set_dir, f"{aid}_night.png"))
            snow_im.save(os.path.join(mod_ui_set_dir, f"{aid}_snow.png"))
            snow_night_im.save(os.path.join(mod_ui_set_dir, f"{aid}_snow_night.png"))
        else:
            # Build BOTH `_left` (`[0..368, 128..472]`) and `_right` (`[652..1024, 136..472]`)
            for side, (x0, y0, x1, y1), src_im in (
                ("left",  (0, 126, 368, 468), tc),
                ("right", (652, 134, 1024, 468), ImageOps.mirror(tc)),
            ):
                bw, bh = x1 - x0, y1 - y0
                s = max(bw / float(src_im.width), min(bw / float(src_im.width), bh / float(src_im.height)))
                s = min(bw / float(src_im.width), bh / float(src_im.height))
                nw, nh = max(1, int(round(src_im.width * s))), max(1, int(round(src_im.height * s)))
                im_s = src_im.resize((nw, nh), Image.Resampling.LANCZOS)
                layer = Image.new("RGBA", (1024, 588), (0, 0, 0, 0))
                px = 0 if side == "left" else (1024 - nw)
                py = y1 - nh
                layer.alpha_composite(im_s, (px, py))

                night_im = make_ui_night_layer(layer)
                snow_im = make_ui_snow_layer(layer)
                snow_night_im = make_ui_night_layer(snow_im)

                base_n = f"{aid}_{side}"
                layer.save(os.path.join(mod_ui_set_dir, f"{base_n}.png"))
                night_im.save(os.path.join(mod_ui_set_dir, f"{base_n}_night.png"))
                snow_im.save(os.path.join(mod_ui_set_dir, f"{base_n}_snow.png"))
                snow_night_im.save(os.path.join(mod_ui_set_dir, f"{base_n}_snow_night.png"))

        new_assets.append({
            "id": aid, "stage": "6_world", "group": "城内盛景 · 衙署山门与两侧坊巷插画",
            "name": nm, "sub": sub, "spec": "1024×588 城镇内景建筑层 (含昼/夜/瑞雪)",
            "slotKind": "boss", "status": "in_game",
            "hdPath": hd_rel, "previewPath": prev_rel, "swPath": "", "smallPath": "",
            "gameTarget": f"gfx/ui/settlements/{aid}.png",
            "vanillaFallback": "ui/settlements/townhall_03.png",
            "codeRef": "mod_wuxia/mod_wuxia/systems/wx_world_visuals_system.nut",
            "brief": brf,
        })

    # =========================================================================
    # 3. Sheet 58: 14 Clickable Town Shop Buildings + Camp Tent + Junk Warship
    # =========================================================================
    sh58 = Image.open(os.path.join(SHEETS_DIR, "sheet_58.jpg"))
    cw, ch = sh58.width // 4, sh58.height // 4
    for (cidx, aid, tw, th, mirror_x, nm, sub, brf) in SHEET58_BUILDINGS_AND_PROPS:
        r, c = divmod(cidx, 4)
        rgba = bsys.flood_white_bg(sh58.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch)), bg_thresh=30, feather=20)
        if mirror_x:
            rgba = ImageOps.mirror(rgba)

        hd_rel = f"art/hd/{aid}.png"
        fit_box_clean(rgba, 256, 256, pad=10).save(os.path.join(ROOT, hd_rel))
        prev_rel = f"art/game/ui/settlements/{aid}.png"
        fit_box_clean(rgba, 176, 132, pad=4).save(os.path.join(ROOT, prev_rel))

        if aid == "wx_camp_01":
            camp_base = fit_box_clean(rgba, tw, th, pad=4)
            camp_fire = make_world_night_light_overlay(camp_base, undead=False)
            camp_base.save(os.path.join(ws_dir, "wx_camp_01.png"))
            camp_fire.save(os.path.join(ws_dir, "wx_camp_01_fire.png"))
            brush_meta_settlement.append({"id": "wx_camp_01", "file": "wx_camp_01.png", "w": tw, "h": th, "ox": 0, "oy": 0})
            brush_meta_settlement.append({"id": "wx_camp_01_fire", "file": "wx_camp_01_fire.png", "w": tw, "h": th, "ox": 0, "oy": 0})
            gt = "brushes/wx_settlement_0.brush#wx_camp_01"
        elif aid == "wx_ship_junk_01":
            ship_im = fit_box_clean(rgba, tw, th, pad=3)
            ship_im.save(os.path.join(ws_dir, "wx_ship_junk_01.png"))
            brush_meta_settlement.append({"id": "wx_ship_junk_01", "file": "wx_ship_junk_01.png", "w": tw, "h": th, "ox": 0, "oy": 0})
            gt = "brushes/wx_settlement_0.brush#wx_ship_junk_01"
        else:
            day_b = fit_box_clean(rgba, tw, th, pad=4)
            day_hi = make_ui_hover_highlight(day_b)
            night_b = make_ui_night_layer(day_b)
            night_hi = make_ui_hover_highlight(night_b)

            day_b.save(os.path.join(mod_ui_set_dir, f"{aid}.png"))
            day_hi.save(os.path.join(mod_ui_set_dir, f"{aid}_b.png"))
            night_b.save(os.path.join(mod_ui_set_dir, f"{aid}_night.png"))
            night_hi.save(os.path.join(mod_ui_set_dir, f"{aid}_night_b.png"))

            if aid == "wx_bldg_arena":
                # Closed arena state (dimmed silk & quiet drums)
                closed_rgb = ImageEnhance.Brightness(day_b.convert("RGB")).enhance(0.68)
                closed_b = closed_rgb.convert("RGBA")
                closed_b.putalpha(day_b.getchannel("A"))
                closed_b.save(os.path.join(mod_ui_set_dir, f"{aid}_closed.png"))
                make_ui_hover_highlight(closed_b).save(os.path.join(mod_ui_set_dir, f"{aid}_closed_b.png"))

            gt = f"gfx/ui/settlements/{aid}.png"

        new_assets.append({
            "id": aid, "stage": "6_world", "group": "城内坊市 · 十四行当店铺与舟营",
            "name": nm, "sub": sub, "spec": f"{tw}×{th} 交互建筑贴图 (含悬停高亮/夜景)",
            "slotKind": "boss", "status": "in_game",
            "hdPath": hd_rel, "previewPath": prev_rel, "swPath": "", "smallPath": "",
            "gameTarget": gt,
            "vanillaFallback": "ui/settlements/building_01.png",
            "codeRef": "mod_wuxia/mod_wuxia/systems/wx_world_visuals_system.nut",
            "brief": brf,
        })

    # =========================================================================
    # 4. Sheets 59 & 60: 32 World Map Marching Chess Pieces (`wx_world_entity_0.brush`)
    # =========================================================================
    open_sheets = {
        "sheet_59.jpg": Image.open(os.path.join(SHEETS_DIR, "sheet_59.jpg")),
        "sheet_60.jpg": Image.open(os.path.join(SHEETS_DIR, "sheet_60.jpg")),
    }
    wiki_we_dir = os.path.join(GAME_DIR, "world_entity")
    os.makedirs(wiki_we_dir, exist_ok=True)

    for (sh_fn, cidx, aid, is_cart, nm, sub, brf) in WORLD_FIGURINES:
        sh = open_sheets[sh_fn]
        cw, ch = sh.width // 4, sh.height // 4
        r, c = divmod(cidx, 4)
        rgba = bsys.flood_white_bg(sh.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch)), bg_thresh=30, feather=20)

        # Save full tabletop chess piece (with its pewter pedestal) as HD & Wiki preview!
        hd_rel = f"art/hd/{aid}.png"
        fit_box_clean(rgba, 256, 256, pad=10).save(os.path.join(ROOT, hd_rel))
        prev_rel = f"art/game/world_entity/{aid}.png"
        fit_box_clean(rgba, 128, 128, pad=4).save(os.path.join(ROOT, prev_rel))

        if is_cart:
            tw, th, ox, oy = 126, 108, 0, 0
            ent_im = fit_box_clean(rgba, tw, th, pad=3)
        else:
            tw, th, ox, oy = 68, 106, 0, 20
            ent_im = extract_figurine_for_world_base(rgba)

        fn = f"{aid}.png"
        ent_im.save(os.path.join(we_dir, fn))
        brush_meta_entity.append({"id": aid, "file": fn, "w": tw, "h": th, "ox": ox, "oy": oy})

        new_assets.append({
            "id": aid, "stage": "6_world", "group": "九州行伍 · 大地图行军小人棋子",
            "name": nm, "sub": sub, "spec": f"{tw}×{th} 大地图行军棋 (.brush)",
            "slotKind": "boss", "status": "in_game",
            "hdPath": hd_rel, "previewPath": prev_rel, "swPath": "", "smallPath": "",
            "gameTarget": f"brushes/wx_world_entity_0.brush#{aid}",
            "vanillaFallback": "figure_player_01",
            "codeRef": "mod_wuxia/mod_wuxia/systems/wx_world_visuals_system.nut",
            "brief": brf,
        })

    # =========================================================================
    # 5. Sheet 61: 16 Chinese Vertical Long War Standards (`banner_51..62` + 4 Faction Standards)
    # =========================================================================
    sh61 = Image.open(os.path.join(SHEETS_DIR, "sheet_61.jpg"))
    cw, ch = sh61.width // 4, sh61.height // 4
    for (cidx, bid, is_player, nm, sub, brf) in SHEET61_BANNERS:
        r, c = divmod(cidx, 4)
        rgba = bsys.flood_white_bg(sh61.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch)), bg_thresh=30, feather=20)
        hd_rel = f"art/hd/{bid}.png"
        fit_box_clean(rgba, 256, 360, pad=8).save(os.path.join(ROOT, hd_rel))

        build_banner_outputs(rgba, bid, is_player, cidx)
        brush_meta_entity.append({"id": bid, "file": f"{bid}.png", "w": 56, "h": 94, "ox": 0, "oy": 28})

        prev_rel = f"art/game/ui/banners/{bid}.png"
        new_assets.append({
            "id": bid, "stage": "6_world", "group": "旌旗招展 · 战团竖幅长战旗与掌旗大纛",
            "name": nm, "sub": sub, "spec": "250×401 竖旗 + 大地图小旗 + 200×300 战场旗手大纛",
            "slotKind": "item140", "status": "in_game",
            "hdPath": hd_rel, "previewPath": prev_rel, "swPath": "", "smallPath": f"art/game/ui/banners/{bid}s.png",
            "gameTarget": f"gfx/ui/banners/{bid}.png",
            "vanillaFallback": "ui/banners/banner_01.png",
            "codeRef": "mod_wuxia/mod_wuxia/systems/wx_world_visuals_system.nut",
            "brief": brf,
        })

    # =========================================================================
    # 6. Sheets 62 & 63: 8 Panoramic Town Interior Landscape Backdrops (`1024x588` JPG)
    # =========================================================================
    quads_62 = extract_2x2_landscape_quads(Image.open(os.path.join(SHEETS_DIR, "sheet_62.jpg")).convert("RGB"))
    quads_63 = extract_2x2_landscape_quads(Image.open(os.path.join(SHEETS_DIR, "sheet_63.jpg")).convert("RGB"))
    quad_map = {"sheet_62.jpg": quads_62, "sheet_63.jpg": quads_63}

    for (sh_fn, qidx, bid, nm, sub, brf) in LANDSCAPE_BACKDROPS:
        day_jpg = quad_map[sh_fn][qidx]
        night_jpg = make_landscape_night_jpg(day_jpg)

        day_jpg.save(os.path.join(mod_ui_set_dir, f"{bid}.jpg"), quality=92)
        night_jpg.save(os.path.join(mod_ui_set_dir, f"{bid}_night.jpg"), quality=92)

        hd_rel = f"art/hd/{bid}.jpg"
        day_jpg.resize((512, 294), Image.Resampling.LANCZOS).save(os.path.join(ROOT, hd_rel), quality=92)
        prev_rel = f"art/game/ui/settlements/{bid}.jpg"
        day_jpg.resize((340, 195), Image.Resampling.LANCZOS).save(os.path.join(ROOT, prev_rel), quality=90)

        new_assets.append({
            "id": bid, "stage": "6_world", "group": "城内盛景 · 八方地域山水天幕背景",
            "name": nm, "sub": sub, "spec": "1024×588 城镇远景天幕 (.jpg 昼/夜双态)",
            "slotKind": "boss", "status": "in_game",
            "hdPath": hd_rel, "previewPath": prev_rel, "swPath": "", "smallPath": "",
            "gameTarget": f"gfx/ui/settlements/{bid}.jpg",
            "vanillaFallback": "ui/settlements/village_bg_01.jpg",
            "codeRef": "mod_wuxia/mod_wuxia/systems/wx_world_visuals_system.nut",
            "brief": brf,
        })

    # Save brush metadata JSONs for `compile_wuxia_brushes.py`
    json.dump(brush_meta_settlement, open(os.path.join(ws_dir, "_meta.json"), "w", encoding="utf-8"), indent=2)
    json.dump(brush_meta_entity, open(os.path.join(we_dir, "_meta.json"), "w", encoding="utf-8"), indent=2)

    # Update `art/manifest.json` idempotently with Stage `6_world`
    manifest_p = os.path.join(ART_DIR, "manifest.json")
    manifest = json.load(open(manifest_p, "r", encoding="utf-8"))
    new_ids = {a["id"] for a in new_assets}
    kept_assets = [a for a in manifest["assets"] if a["id"] not in new_ids]
    kept_assets.extend(new_assets)
    manifest["assets"] = kept_assets
    manifest["version"] = "0.9.5-world-settlements-figurines-banners-921"

    stages = [s for s in manifest["stages"] if s["id"] != "6_world"]
    stages.append({
        "id": "6_world",
        "name": "第六卷 · 九州山门与战团旌旗",
        "desc": f"中式州府/军镇/村落/山门、城镇内景山水与十四坊铺、32尊大地图行军棋子与16面竖幅长战旗（{len(new_assets)}/{len(new_assets)}）"
    })
    manifest["stages"] = stages
    manifest["summary"]["total"] = len(kept_assets)
    manifest["summary"]["in_game"] = sum(1 for a in kept_assets if a["status"] == "in_game")
    manifest["summary"]["wiki_ready"] = sum(1 for a in kept_assets if a["status"] == "wiki_ready")
    manifest["summary"]["planned"] = sum(1 for a in kept_assets if a["status"] == "planned")
    json.dump(manifest, open(manifest_p, "w", encoding="utf-8"), ensure_ascii=False, indent=2)

    print(f"Processed Wave 56..63 OK: +{len(new_assets)} new Stage 6 world/settlement/banner assets (total manifest: {len(kept_assets)})")
    print(f"  Settlement brush entries: {len(brush_meta_settlement)} | World entity brush entries: {len(brush_meta_entity)}")


if __name__ == "__main__":
    main()
