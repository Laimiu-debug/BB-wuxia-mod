#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Idempotently registers Stage `7_scenes` (第七卷 · 奇遇插画与过场画卷, 79 assets) into `art/manifest.json`:
  - 32 Event Illustrations (`wx_ev_01`..`wx_ev_32`)
  - 6 Main Menu Scrolls & Skin Elements (`wx_menu_bg_01..04`, `wx_main_menu_banner`, `wx_main_menu_logo`)
  - 8 Loading Scrolls (`wx_loading_01..08`)
  - 5 Campaign Epilogue Scrolls (`wx_game_lost`, `wx_retirement_01..04`)
  - 10 Campfire Backdrops, Tents, Fire, Escort Carts & Slot Seals
  - 18 Seated Jianghu Retinue Followers (`wx_alchemist_01`..`wx_brigand_01` + `_b.png` hover states)
"""

import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MANIFEST_PATH = os.path.join(ROOT, "art", "manifest.json")

STAGE_DEF = {
    "id": "7_scenes",
    "name": "第七卷 · 奇遇插画与过场画卷",
    "desc": "32幅江湖奇遇插画、主菜单与载入退隐十七幅长卷、篝火营帐镖车与十八位幕僚坐姿立绘（79/79）",
}

EVENT_DEFS = [
    ("wx_ev_01", "迎风茶寮论剑图", "茶楼择席 · 门派拜访奇遇", "event_01.png", "烟雨江南水乡茶楼二层凭栏木案，青瓷茶盏热气袅袅，案横古朴长剑，绑定各州府茶楼门派择席与客栈秘闻。"),
    ("wx_ev_02", "老榆酒肆拍刀图", "酒肆生事 · 扳腕赌斗奇遇", "event_02.png", "喧嚣路旁老酒肆八仙桌上，彪形豪客横拍单刀震翻瓷碗碎银，绑定酒肆挑战、绿林扳腕与豪饮事件。"),
    ("wx_ev_03", "青灯书肆鉴谱图", "坊市古籍 · 残页拼鉴奇遇", "event_03.png", "烛影摇曳的城镇古书肆内，老掌柜展开泛黄经络武学卷轴细辨真伪，绑定书肆淘书、残页交换与赝本秘闻。"),
    ("wx_ev_04", "子夜无常鬼市图", "幽冥灯笼 · 压轴竞拍奇遇", "event_04.png", "惨绿纸灯高悬的地下鬼市暗集，青铜鬼面掌柜掀开红绸露出鎏金宝匣，绑定无常鬼市绝学与神兵竞拍。"),
    ("wx_ev_05", "天下武林大会图", "旌旗演武 · 群雄争魁盛会", "event_80.png", "群峰之下巨型木构演武高台旌旗猎猎，红金龙纹英雄榜悬于木柱，绑定终极事件天下武林大会与演武试剑台。"),
    ("wx_ev_06", "威远千里走镖图", "黑金龙旗 · 镖行启程画卷", "event_80.png", "残阳古道上黑金走龙镖旗迎风招展，刀枪趟子手护卫重箱镖车前行，绑定初走江湖正式开局与威远设宴。"),
    ("wx_ev_07", "药浴伐毛洗髓图", "灵汤蒸腾 · 脱胎换骨奇遇", "event_18.png", "幽静密室柏木大桶药雾蒸腾，武者盘坐药汤之中周身经络泛起淡金真芒，绑定洗髓伐毛余韵奇遇。"),
    ("wx_ev_08", "逆血走火心魔图", "阴阳逆冲 · 残本入魔危机", "event_33.png", "石室寒砖上武者单膝跪地呕血，半身冰蓝半身赤焰，背后黑煞心魔狂舞，绑定内功相克与残本心魔危机。"),
    ("wx_ev_09", "松林寒夜吐纳图", "孤月篝火 · 周天调息奇遇", "event_09.png", "皓月寒松林间篝火微明，守夜侠客盘膝五心朝天，淡青真气萦绕周身，绑定守夜吐纳与内功冥想事件。"),
    ("wx_ev_10", "飞瀑寒潭剑冢图", "万丈飞流 · 残剑悟道奇遇", "event_10.png", "苍翠深谷银河飞瀑直落寒潭，苔石孤冢倒插十余柄古拙断剑，绑定观瀑顿悟与荒山古剑冢奇遇。"),
    ("wx_ev_11", "竹林月下拆招图", "剑气惊叶 · 名宿喂招奇遇", "event_11.png", "清冷月色洒入幽篁竹海，退隐老剑客以青竹代剑与少侠拆解精妙招式，绑定名宿指点与营中切磋事件。"),
    ("wx_ev_12", "杏林紫铜丹炉图", "金针灵芝 · 悬壶济世奇遇", "event_18.png", "药香氤氲的医馆木案上紫铜三足丹炉白烟袅袅，旁列血芝、金针与青瓷药瓶，绑定名医治内伤与试毒炼丹。"),
    ("wx_ev_13", "断桥宿敌寻仇图", "寒雾孤桥 · 刀剑相向奇遇", "event_13.png", "凄迷山水古石拱桥之上，蓝衣与绯衣剑客拔刃交锋火星四溅，绑定门派寻仇死斗、折冲说客与除邪事件。"),
    ("wx_ev_14", "险隘官道劫镖图", "烈焰残车 · 绿林剪径奇遇", "event_14.png", "乱山松隘巨木横拦官道，中箭镖车燃起黑烟烈火，蒙面刀匪四面合围，绑定山寨买路钱、劫余残镖与重伤信使。"),
    ("wx_ev_15", "烟雨古刹奇丐图", "青铜梵钟 · 藏拙高人奇遇", "event_15.png", "细雨霏霏的千年古寺飞檐铜钟下，怀抱双葫芦的破衣老丐笑看热茶，绑定少室化缘、奇丐指点与武僧比力。"),
    ("wx_ev_16", "唐门机括苗毒图", "袖箭银针 · 五毒奇物奇遇", "event_16.png", "暗木桌上精雕黄铜机括匣盛满寒芒袖箭，竹篓青蛇吐信、黑蝎翘尾，绑定唐门行商、五毒易物与丐帮密报。"),
    ("wx_ev_17", "前朝玄宫石门图", "青铜兽首 · 墨家机关禁地", "event_17.png", "荒山峭壁嵌着巨型青铜饕餮重门，玄铁锁链缠绕机关铜轮，幽蓝长明灯不灭，绑定古墓石门与断壁残垣考据。"),
    ("wx_ev_18", "夜雾湘西赶尸图", "惨绿纸灯 · 摄魂铜铃奇闻", "event_33.png", "三更浓雾山道上杏黄道袍赶尸匠高挑绿灯摇动铜铃，身后贴符尸傀列队随行，绑定湘西赶尸与掘墓凶兆。"),
    ("wx_ev_19", "荒山青丘狐庙图", "残破红幔 · 九尾石像秘闻", "event_19.png", "古木藤蔓缠绕的荒山野祠红幔低垂，孤烛映照石雕九尾灵狐神像，绑定青丘狐仙野庙奇遇。"),
    ("wx_ev_20", "风雪荒郊黑店图", "断幌药酒 · 剔骨寒刀凶险", "event_20.png", "暴雪夜色下的孤寂荒原野店木幌摇晃，柜头粗陶酒坛飘出诡异紫烟与剔骨尖刀，绑定荒郊黑店奇遇。"),
    ("wx_ev_21", "独臂猎师舆图图", "短匕指山 · 山海秘境寻踪", "event_21.png", "昏黄油灯下颈挂兽牙的独臂老猎妖师以短匕钉住羊皮古舆图，绑定探明《山海经》凶兽秘境方位事件。"),
    ("wx_ev_22", "深林朱厌巨迹图", "断折古松 · 炽红兽印异象", "event_07.png", "幽暗老林合抱巨松被蛮力拦腰拍断，泥地深陷泛着凶煞红光的巨猿足印，绑定朱厌兽踪与深山铁木采集。"),
    ("wx_ev_23", "焦岩肥遗蜕鳞图", "赤裂旱渊 · 丈长古蛇巨蜕", "event_23.png", "赤地千里的焦黑火山裂谷间冒出硫磺浓烟，岩缝盘绕丈许青铜色巨蛇蜕皮，绑定六足四翼肥遗蜕鳞奇遇。"),
    ("wx_ev_24", "云崖白泽古碑图", "灵雾瑞霭 · 通万物情神碑", "event_10.png", "云海危崖之上矗立苍苔斑驳的上古瑞兽白泽石碑，碧白灵雾盘旋护佑，绑定白泽古祠与山海迷雾奇遇。"),
    ("wx_ev_25", "血月边关烽烟图", "乱世凶兆 · 狼烟四起大势", "event_25.png", "一轮赤红血月高悬群山之巅，远近边塞烽火台黑烟烈焰接连冲霄，绑定江湖大势危机前兆事件。"),
    ("wx_ev_26", "关津胥吏苛税图", "铁戟拦关 · 算盘盘剥世情", "event_26.png", "木石税卡前锦衣税吏手拨算盘冷眼盘剥，两侧红缨长戟官兵虎视眈眈，绑定官道苛税、逃兵盘查与世家争执。"),
    ("wx_ev_27", "枯鸦瘟村流民图", "白幡荒巷 · 扶老携幼苦旅", "event_27.png", "昏黄风沙中的破败荒村木门悬白幡、寒鸦栖立，饥民拄杖蹒跚远行，绑定疫病荒村与饥荒流民事件。"),
    ("wx_ev_28", "雨巷朱墙暗记图", "密函火漆 · 江湖暗桩秘闻", "event_28.png", "夜雨滂沱的深宅朱墙暗巷内，黑衣夜行客手执火漆密信驻足粉笔暗记前，绑定宫闱秘闻、捷径密信与妙手空空。"),
    ("wx_ev_29", "芦苇沉箱残碑图", "寒江铁锁 · 前朝剑痕古碑", "event_29.png", "秋水芦苇浅滩半掩铁锁古木沉箱，岸畔残碑深刻两道凌厉交错剑痕，绑定渔夫捞箱与史官残碑考据。"),
    ("wx_ev_30", "营火百工砺刃图", "角弓铁砧 · 匠心修缮日常", "event_30.png", "温暖篝火映照的营地木案上，老匠师俯身油石磨利寒刃，旁置角弓与扎甲内衬，绑定弓匠、裁缝与刽子手磨刀。"),
    ("wx_ev_31", "营火庖厨欢宴图", "铁釜肉汤 · 琵琶骰子同袍", "event_31.png", "暮色营火上架起大铁锅炖肉飘香，同袍围坐掷象牙骰、抚曲颈琵琶欢笑，绑定屠夫设宴、肉羹、赌骰与弹唱。"),
    ("wx_ev_32", "风雪残驿名宿图", "红泥暖灶 · 苍獒老客奇遇", "event_32.png", "大雪封山的破败古驿站内炉火正旺，白须武林名宿温酒静坐，猛犬守立门畔，绑定游方长老、收留猎犬与市集杂耍。"),
]

SCREEN_DEFS = [
    # Main Menu Scrolls & Skin
    ("wx_menu_bg_01", "主菜单与门楣徽印", "残阳孤侠俯瞰九州城池卷", "主菜单轮换长卷 01 · 1920×1080", "1920×1080 RGB 全屏水墨重彩画卷", "screen16x9", "art/hd/wx_menu_bg_01.jpg", "art/game/ui/screens/wx_menu_bg_01.jpg", "gfx/ui/screens/wx_menu_bg_01.jpg", "ui/screens/loading_screen_01.jpg", "ui/mods/mod_wuxia/screens_wuxia.js", "斗笠佩剑孤侠立于苍松危崖俯瞰云海中的唐宋楼阁重城与远方血色残阳，右侧深墨留白承托主菜单悬幡。"),
    ("wx_menu_bg_02", "主菜单与门楣徽印", "风雨客栈江湖群豪聚义卷", "主菜单轮换长卷 02 · 1920×1080", "1920×1080 RGB 全屏水墨重彩画卷", "screen16x9", "art/hd/wx_menu_bg_02.jpg", "art/game/ui/screens/wx_menu_bg_02.jpg", "gfx/ui/screens/wx_menu_bg_02.jpg", "ui/screens/loading_screen_02.jpg", "ui/mods/mod_wuxia/screens_wuxia.js", "暴雨电光映照荒野双层木构老客栈，武僧、刀客与侠女围坐暖黄灯火酒桌擦拭兵刃。"),
    ("wx_menu_bg_03", "主菜单与门楣徽印", "云海古刹群峰仙山胜境卷", "主菜单轮换长卷 03 · 1920×1080", "1920×1080 RGB 全屏水墨重彩画卷", "screen16x9", "art/hd/wx_menu_bg_03.jpg", "art/game/ui/screens/wx_menu_bg_03.jpg", "gfx/ui/screens/wx_menu_bg_03.jpg", "ui/screens/loading_screen_03.jpg", "ui/mods/mod_wuxia/screens_wuxia.js", "险峻奇峰刺破浩渺云海，百级石阶蜿蜒通向绝顶飞檐武林宗门，白鹤掠过晨曦金光。"),
    ("wx_menu_bg_04", "主菜单与门楣徽印", "风雪古战场残旗断戟苍茫卷", "主菜单轮换长卷 04 · 1920×1080", "1920×1080 RGB 全屏水墨重彩画卷", "screen16x9", "art/hd/wx_menu_bg_04.jpg", "art/game/ui/screens/wx_menu_bg_04.jpg", "gfx/ui/screens/wx_menu_bg_04.jpg", "ui/screens/loading_screen_04.jpg", "ui/mods/mod_wuxia/screens_wuxia.js", "凛冽风雪席卷荒原古战场，残破镖旗与断矛重刀斜插冻土，五名风尘侠客踏雪前行。"),
    ("wx_main_menu_banner", "主菜单与门楣徽印", "玄锦暗金云纹主菜单悬幡", "主菜单按钮垂幅 · 245×595 RGBA", "245×595 RGBA 透明底丝绸战幡", "camp", "art/hd/wx_main_menu_banner.png", "art/game/ui/skin/wx_main_menu_banner.png", "gfx/ui/skin/wx_main_menu_banner.png", "ui/skin/main_menu_banner.png", "ui/mods/mod_wuxia/mod_wuxia.css", "乌木铜箍横杆悬挂的玄黑镶暗红战损锦缎垂幡，四角暗金祥云纹压边，底部撕裂流苏随风微垂。"),
    ("wx_main_menu_logo", "主菜单与门楣徽印", "刀剑八卦盾『武侠江湖』徽印", "主菜单标题总徽 · 400×350 RGBA", "400×350 RGBA 透明底鎏金徽印", "camp", "art/hd/wx_main_menu_logo.png", "art/game/ui/skin/wx_main_menu_logo.png", "gfx/ui/skin/wx_main_menu_logo.png", "ui/skin/main_menu_logo.png", "ui/mods/mod_wuxia/screens_wuxia.js", "九环厚背大刀与青霜汉剑交错衬托青铜八卦护心圆盾，正中浮雕赤金行楷『武侠江湖』与 BATTLE BROTHERS 铭文。"),
    # 8 Loading Scrolls
    ("wx_loading_01", "过场载入画卷（8幅）", "竹海夜雨绿林劫镖激战图", "载入过场画卷 01 · 1920×1080", "1920×1080 RGB 载入过场画卷", "screen16x9", "art/hd/wx_loading_01.jpg", "art/game/ui/screens/wx_loading_01.jpg", "gfx/ui/screens/wx_loading_01.jpg", "ui/screens/loading_screen_01.jpg", "mod_wuxia/hooks/config/wx_screens_hook.nut", "暴雨如注的幽暗竹林泥道上，镖师结圆阵挥舞苗刀藤牌迎战自竹梢飞扑而下的蒙面刺客。"),
    ("wx_loading_02", "过场载入画卷（8幅）", "昆仑雪谷围猎山海朱厌图", "载入过场画卷 02 · 1920×1080", "1920×1080 RGB 载入过场画卷", "screen16x9", "art/hd/wx_loading_02.jpg", "art/game/ui/screens/wx_loading_02.jpg", "gfx/ui/screens/wx_loading_02.jpg", "ui/screens/loading_screen_02.jpg", "mod_wuxia/hooks/config/wx_screens_hook.nut", "暴雪封锁的昆仑冰峡间，白首赤足的上古凶猿朱厌咆哮挥臂，六名侠客持长枪钩镰与暗器合力围猎。"),
    ("wx_loading_03", "过场载入画卷（8幅）", "大漠残障塞外铁骑冲阵图", "载入过场画卷 03 · 1920×1080", "1920×1080 RGB 载入过场画卷", "screen16x9", "art/hd/wx_loading_03.jpg", "art/game/ui/screens/wx_loading_03.jpg", "gfx/ui/screens/wx_loading_03.jpg", "ui/screens/loading_screen_05.jpg", "mod_wuxia/hooks/config/wx_screens_hook.nut", "黄沙漫卷的西域坍塌烽燧下，重甲陌刀盾卫死守残垣，迎击弯刀呼啸冲锋的关外披甲马贼。"),
    ("wx_loading_04", "过场载入画卷（8幅）", "前朝地宫青铜机关俑苏醒图", "载入过场画卷 04 · 1920×1080", "1920×1080 RGB 载入过场画卷", "screen16x9", "art/hd/wx_loading_04.jpg", "art/game/ui/screens/wx_loading_04.jpg", "gfx/ui/screens/wx_loading_04.jpg", "ui/screens/loading_screen_06.jpg", "mod_wuxia/hooks/config/wx_screens_hook.nut", "幽蓝鬼火照亮的秦汉水银地下玄宫，双目泛绿光的青铜持戈机关卫士踏破尘封向探墓侠客逼近。"),
    ("wx_loading_05", "过场载入画卷（8幅）", "蜀道悬栈五毒唐门伏击图", "载入过场画卷 05 · 1920×1080", "1920×1080 RGB 载入过场画卷", "screen16x9", "art/hd/wx_loading_05.jpg", "art/game/ui/screens/wx_loading_05.jpg", "gfx/ui/screens/wx_loading_05.jpg", "ui/screens/loading_screen_07.jpg", "mod_wuxia/hooks/config/wx_screens_hook.nut", "万丈深渊之上的巴蜀绝壁木栈道毒雾弥漫，侠客举圆盾格挡暗处攒射而来的吹箭毒针与霹雳火弹。"),
    ("wx_loading_06", "过场载入画卷（8幅）", "中原旷野藩镇长戟军阵图", "载入过场画卷 06 · 1920×1080", "1920×1080 RGB 载入过场画卷", "screen16x9", "art/hd/wx_loading_06.jpg", "art/game/ui/screens/wx_loading_06.jpg", "gfx/ui/screens/wx_loading_06.jpg", "ui/screens/loading_screen_08.jpg", "mod_wuxia/hooks/config/wx_screens_hook.nut", "铅云密布的焦土平原上，地方节度使铁甲长戟方阵与神机火铳齐鸣，江湖群侠拔刃迎敌。"),
    ("wx_loading_07", "过场载入画卷（8幅）", "焦土血战无首刑天凶魂图", "载入过场画卷 07 · 1920×1080", "1920×1080 RGB 载入过场画卷", "screen16x9", "art/hd/wx_loading_07.jpg", "art/game/ui/screens/wx_loading_07.jpg", "gfx/ui/screens/wx_loading_07.jpg", "ui/screens/loading_screen_10.jpg", "mod_wuxia/hooks/config/wx_screens_hook.nut", "赤电撕裂天幕的上古焦黑废墟间，以乳为目以脐为口的巨人刑天挥干戚劈地，众侠客浴血死战。"),
    ("wx_loading_08", "过场载入画卷（8幅）", "子夜运河无常鬼市秘景图", "载入过场画卷 08 · 1920×1080", "1920×1080 RGB 载入过场画卷", "screen16x9", "art/hd/wx_loading_08.jpg", "art/game/ui/screens/wx_loading_08.jpg", "gfx/ui/screens/wx_loading_08.jpg", "ui/screens/loading_screen_11.jpg", "mod_wuxia/hooks/config/wx_screens_hook.nut", "绿灯摇曳的地下暗河石拱渡口，乌篷船悄然靠岸，佩戴面具的江湖奇客汇聚子夜黑市交易秘宝。"),
    # 5 Epilogue Scrolls
    ("wx_game_lost", "战役结局与退隐长卷（5幅）", "全军覆没 · 残阳荒冢断旗悲歌", "团灭结局长卷 · 1920×1080", "1920×1080 RGB 团灭结局画卷", "screen16x9", "art/hd/wx_game_lost.jpg", "art/game/ui/screens/wx_game_lost.jpg", "gfx/ui/screens/wx_game_lost.jpg", "ui/screens/game_lost.jpg", "ui/mods/mod_wuxia/screens_wuxia.js", "残阳如血的荒凉山岗上，数柄缺口刀剑斜插新坟，破碎战旗挂上枯鸦高枝，见证一队江湖同袍的悲壮落幕。"),
    ("wx_retirement_01", "战役结局与退隐长卷（5幅）", "败走散伙 · 孤客牵驴风尘远去", "黯然退隐长卷 01 · 右侧墨韵留白", "1920×1080 RGB 退隐结局长卷", "screen16x9", "art/hd/wx_retirement_01.jpg", "art/game/ui/screens/wx_retirement_01.jpg", "gfx/ui/screens/wx_retirement_01.jpg", "ui/screens/retirement_01.jpg", "ui/mods/mod_wuxia/screens_wuxia.js", "阴雨泥泞古道旁，缠着绷带的独眼老刀客牵着瘦驴回望远山，右侧平滑渐入纯黑承托退隐判词。"),
    ("wx_retirement_02", "战役结局与退隐长卷（5幅）", "小成归隐 · 溪畔草堂耕读传剑", "安稳退隐长卷 02 · 右侧墨韵留白", "1920×1080 RGB 退隐结局长卷", "screen16x9", "art/hd/wx_retirement_02.jpg", "art/game/ui/screens/wx_retirement_02.jpg", "gfx/ui/screens/wx_retirement_02.jpg", "ui/screens/retirement_02.jpg", "ui/mods/mod_wuxia/screens_wuxia.js", "桃花竹溪畔的茅檐小院内，卸甲归田的剑客坐于石桌品茗，看稚子挥木剑习武，右侧平滑渐入纯黑。"),
    ("wx_retirement_03", "战役结局与退隐长卷（5幅）", "富甲一方 · 开宗立派广收门徒", "显赫退隐长卷 03 · 右侧墨韵留白", "1920×1080 RGB 退隐结局长卷", "screen16x9", "art/hd/wx_retirement_03.jpg", "art/game/ui/screens/wx_retirement_03.jpg", "gfx/ui/screens/wx_retirement_03.jpg", "ui/screens/retirement_03.jpg", "ui/mods/mod_wuxia/screens_wuxia.js", "锦衣玉带的昔日总镖头端坐雕梁画栋庄园太师椅上，金银满箱、众弟子抱拳侍立，右侧平滑渐入纯黑。"),
    ("wx_retirement_04", "战役结局与退隐长卷（5幅）", "名震天下 · 凯旋州城百姓夹道", "传奇退隐长卷 04 · 右侧墨韵留白", "1920×1080 RGB 退隐结局长卷", "screen16x9", "art/hd/wx_retirement_04.jpg", "art/game/ui/screens/wx_retirement_04.jpg", "gfx/ui/screens/wx_retirement_04.jpg", "ui/screens/retirement_04.jpg", "ui/mods/mod_wuxia/screens_wuxia.js", "金彩漫天的繁华州府长街上，身披百战鱼鳞甲的一代宗师高举巨斧，百姓捧酒献花欢呼，右侧平滑渐入纯黑。"),
]

CAMP_SCENE_DEFS = [
    ("wx_camp_bg_day", "篝火营帐、镖车与印信（10项）", "青山翠竹晨雾野营天幕（昼）", "营地白昼远景 · 1024×588", "1024×588 RGB 营地远景天幕", "screen16x9", "art/hd/wx_camp_bg_day.jpg", "art/game/ui/campfire/wx_camp_bg_day.jpg", "", "gfx/ui/campfire/wx_camp_bg_day.jpg", "ui/settlements/bg_landscape_01.jpg", "ui/mods/mod_wuxia/screens_wuxia.js", "晨曦薄雾笼罩的苍松翠竹与远方水墨奇峰，为白昼扎营修整界面铺陈清朗江湖意境。"),
    ("wx_camp_bg_night", "篝火营帐、镖车与印信（10项）", "寒星孤月苍松野营天幕（夜）", "营地夜间远景 · 1024×588", "1024×588 RGB 营地远景天幕", "screen16x9", "art/hd/wx_camp_bg_night.jpg", "art/game/ui/campfire/wx_camp_bg_night.jpg", "", "gfx/ui/campfire/wx_camp_bg_night.jpg", "ui/settlements/bg_landscape_01_night.jpg", "ui/mods/mod_wuxia/screens_wuxia.js", "皎洁满月与漫天星河映照幽蓝群峰竹影，衬托夜间营火温暖火光。"),
    ("wx_campfire_tents_01", "篝火营帐、镖车与印信（10项）", "江湖行营油布帐与虎盾草席层", "营地中景图层 · 1024×588 RGBA", "1024×588 RGBA 透明天幕营帐层", "screen16x9", "art/hd/wx_campfire_tents_01.png", "art/game/ui/campfire/wx_campfire_tents_01.png", "", "gfx/ui/campfire/wx_campfire_tents_01.png", "ui/campfire/campfire_tents_01.png", "ui/mods/mod_wuxia/screens_wuxia.js", "三顶补丁粗麻油布行军帐、红缨枪架虎头藤牌、铁箍镖箱、绛红牙旗与五席芦苇坐垫无缝融入苔草营地。"),
    ("wx_fire_01", "篝火营帐、镖车与印信（10项）", "青石围拢松柴烈焰篝火层", "营地前景篝火 · 1024×588 RGBA", "1024×588 RGBA 篝火与暖光层", "camp", "art/hd/wx_fire_01.png", "art/game/ui/campfire/wx_fire_01.png", "", "gfx/ui/campfire/wx_fire_01.png", "ui/campfire/fire_01.png", "ui/mods/mod_wuxia/screens_wuxia.js", "河滩青石围拢的干燥松木篝火熊熊跃动，向四周地面投射温暖橙金火光。"),
    ("wx_cart_01", "篝火营帐、镖车与印信（10项）", "一阶辎重 · 竹篓陶坛驮驴", "随行粮草载具 T1 · 386×434 (+_b)", "386×434 RGBA 透明底立绘 (+_b 高亮态)", "camp", "art/hd/wx_cart_01.png", "art/game/ui/campfire/wx_cart_01.png", "art/game/ui/campfire/wx_cart_01_b.png", "gfx/ui/campfire/wx_cart_01.png", "ui/campfire/cart_01.png", "ui/mods/mod_wuxia/screens_wuxia.js", "健壮灰褐毛驴背负双侧竹编货篓、草捆米袋与封泥酒坛，初涉江湖小队本分脚力。"),
    ("wx_cart_02", "篝火营帐、镖车与印信（10项）", "二阶辎重 · 双轮铁箍木板镖车", "随行粮草载具 T2 · 442×462 (+_b)", "442×462 RGBA 透明底立绘 (+_b 高亮态)", "camp", "art/hd/wx_cart_02.png", "art/game/ui/campfire/wx_cart_02.png", "art/game/ui/campfire/wx_cart_02_b.png", "gfx/ui/campfire/wx_cart_02.png", "ui/campfire/cart_02.png", "ui/mods/mod_wuxia/screens_wuxia.js", "麻绳捆扎樟木铁扣镖箱、火药木桶并覆油布防雨的双轮木板大车。"),
    ("wx_cart_03", "篝火营帐、镖车与印信（10项）", "三阶辎重 · 四旗护印重箱镖车", "随行粮草载具 T3 · 364×488 (+_b)", "364×488 RGBA 透明底立绘 (+_b 高亮态)", "camp", "art/hd/wx_cart_03.png", "art/game/ui/campfire/wx_cart_03.png", "art/game/ui/campfire/wx_cart_03_b.png", "gfx/ui/campfire/wx_cart_03.png", "ui/campfire/cart_03.png", "ui/mods/mod_wuxia/screens_wuxia.js", "四角插暗红镖局三角牙旗、满载鎏金铜锁重镖箱的四轮加固走镖大车。"),
    ("wx_cart_04", "篝火营帐、镖车与印信（10项）", "四阶辎重 · 乌篷铁甲总镖头大车", "随行粮草载具 T4 · 415×588 (+_b)", "415×588 RGBA 透明底立绘 (+_b 高亮态)", "camp", "art/hd/wx_cart_04.png", "art/game/ui/campfire/wx_cart_04.png", "art/game/ui/campfire/wx_cart_04_b.png", "gfx/ui/campfire/wx_cart_04.png", "ui/campfire/cart_04.png", "ui/mods/mod_wuxia/screens_wuxia.js", "拱形厚黑油毡大篷配铆钉铁护板的重型镖团总辎重车，满载粮袋瓷坛与兵器甲胄。"),
    ("wx_free_slot", "篝火营帐、镖车与印信（10项）", "可延揽幕僚 · 青铜八卦十字印", "空余幕僚席位印标 · 200×190 (+_b)", "200×190 RGBA 席位悬标 (+_b 高亮态)", "camp", "art/hd/wx_free_slot.png", "art/game/ui/campfire/wx_free_slot.png", "art/game/ui/campfire/wx_free_slot_b.png", "gfx/ui/campfire/wx_free_slot.png", "ui/campfire/free_slot.png", "ui/mods/mod_wuxia/screens_wuxia.js", "精铸古黄铜八卦阳爻圆印，正中镶银白十字招贤徽记，悬于空余芦苇席上方提示可延揽随行奇人。"),
    ("wx_locked_slot", "篝火营帐、镖车与印信（10项）", "未解锁席位 · 寒铁盘链铜锁印", "未解锁幕僚席位印标 · 200×190 (+_b)", "200×190 RGBA 席位悬标 (+_b 高亮态)", "camp", "art/hd/wx_locked_slot.png", "art/game/ui/campfire/wx_locked_slot.png", "art/game/ui/campfire/wx_locked_slot_b.png", "gfx/ui/campfire/wx_locked_slot.png", "ui/campfire/locked_slot.png", "ui/mods/mod_wuxia/screens_wuxia.js", "玄铁八卦圆盘十字缠绕粗重铁链并以老式黄铜簧锁紧扣，提示声望尚浅暂未开启该幕僚席。"),
]

FOLLOWER_DEFS = [
    ("alchemist_01",     "丹鼎方士",   (296, 303), "白发鹤髯道袍老方士盘膝研钵捣药，左手托一枚泛碧绿灵光的青玉丹葫芦，对应原版炼金术士。"),
    ("blacksmith_01",    "百炼随匠",   (325, 306), "赤膊虬肌披牛皮围裙的随军铁匠端坐磨刀石前，双掌以油石精研柳叶厚刀，对应原版随军铁匠。"),
    ("cook_01",          "五味行厨",   (259, 315), "富态慈眉系麻布围裙的大厨手持木杓搅动热气腾腾的红泥炖肉砂锅，旁立封泥酒坛，对应原版厨师。"),
    ("drill_01",         "演武总教头", (271, 333), "面刻刀疤身披牛皮札甲的刚毅总教头盘膝横按少林熟铜齐眉棍督训弟子，对应原版教官。"),
    ("surgeon_01",       "杏林医官",   (285, 320), "素麻深衣儒雅医官开启百宝药箱，指拈三枚救命毫针正待施展金针渡穴，对应原版外科医官。"),
    ("scout_01",         "踏雪夜斥",   (264, 272), "头戴竹编斗笠身披苍绿蓑衣的精干斥候盘膝展阅皮卷路引，尽谙山林捷径，对应原版斥候。"),
    ("lookout_01",       "苍鹰望哨",   (287, 316), "背负角弓羽箭的俊朗猎手左臂厚皮护腕稳架一羽金眸苍鹰巡视远方敌情，对应原版瞭望手。"),
    ("quartermaster_01", "掌印辎重官", (276, 349), "身披狼毛重裘的老练押镖管事端坐捆扎枪矛箭篓与盘绳前核对账册，对应原版军需官。"),
    ("paymaster_01",     "铁算账房",   (282, 309), "头戴乌纱展角官帽的精明账房先生膝横黄花梨算盘，手托雪花官银元宝，对应原版账房。"),
    ("recruiter_01",     "江湖牙人",   (313, 318), "锦缎镶边袍服的干练牙人手捧红封《英雄名册》与青玉印章广招天下豪杰，对应原版招募员。"),
    ("trader_01",        "丝路奇商",   (345, 339), "头戴貂皮暖帽身披织金锦袍的西域富商守着满溢珍珠珊瑚与彩绸的百宝箱，对应原版行商。"),
    ("cartographer_01",  "山海舆图师", (275, 286), "白须青衫老学者悬腕执狼毫毛笔，在长卷宣纸上细绘九州山川与山海秘境，对应原版制图师。"),
    ("bounty_hunter_01", "六扇门快捕", (299, 325), "玄黑镶红飞鱼劲装捕头按膝端坐，手扣精钢锁链与捕快腰牌追缉江洋大盗，对应原版赏金猎人。"),
    ("minstrel_01",      "盲眼琵琶客", (295, 310), "灰布蒙眼披蓑衣的沧桑江湖琴客怀抱四弦曲颈琵琶弹唱古今侠客悲歌，对应原版吟游诗人。"),
    ("negotiator_01",    "茶楼折冲客", (255, 346), "云鬓玉簪着翠绿旗袍袄裙的雅致女说客轻摇兰花折扇、手捧青瓷香茗周旋各方，对应原版谈判家。"),
    ("scavenger_01",     "摸金拾遗客", (300, 257), "饱经风霜的荒野拾遗汉子肩靠撬铁杖、手提暖光防风油灯检视古旧残盔，对应原版拾荒者。"),
    ("agent_01",         "玄衣密谍",   (292, 350), "玄黑风帽蒙面夜行密探盘膝隐于暗影，双手展开竹简密报洞察各大藩镇动向，对应原版密探。"),
    ("brigand_01",       "识途响马",   (252, 293), "满脸凶悍刀疤的无袖皮甲绿林老匪盘膝抛玩精钢柳叶飞刀，熟知各地商队肥羊，对应原版强盗眼线。"),
]


def count_generated_files():
    cnt = 0
    for base in (os.path.join(ROOT, "art"), os.path.join(ROOT, "mod_wuxia", "gfx")):
        if os.path.exists(base):
            for _, _, fns in os.walk(base):
                cnt += sum(1 for fn in fns if fn.endswith((".png", ".jpg")))
    return cnt


def main():
    manifest = json.load(open(MANIFEST_PATH, "r", encoding="utf-8"))

    # Remove any prior 7_scenes entries for clean idempotency
    stages = [s for s in manifest["stages"] if s["id"] != "7_scenes"]
    stages.append(STAGE_DEF)
    manifest["stages"] = stages

    new_assets = []

    # 1. 32 Event Illustrations
    for ev_id, name, sub, fallback, brief in EVENT_DEFS:
        new_assets.append({
            "id": ev_id,
            "stage": "7_scenes",
            "group": "江湖奇遇水墨重彩插画（32幅）",
            "name": name,
            "sub": sub,
            "spec": "210×210 RGBA 原版级阴影铜框插画",
            "slotKind": "event210",
            "status": "in_game",
            "hdPath": f"art/hd/{ev_id}.png",
            "previewPath": f"art/game/ui/events/{ev_id}.png",
            "swPath": "",
            "smallPath": "",
            "gameTarget": f"gfx/ui/events/{ev_id}.png",
            "vanillaFallback": f"ui/events/{fallback}",
            "codeRef": "mod_wuxia/scripts/events/events/",
            "brief": brief,
        })

    # 2. 19 Menu, Loading & Epilogue Scrolls + Skin Elements
    for sid, grp, name, sub, spec, skind, hdp, prevp, gtarget, vfb, cref, brief in SCREEN_DEFS:
        new_assets.append({
            "id": sid,
            "stage": "7_scenes",
            "group": grp,
            "name": name,
            "sub": sub,
            "spec": spec,
            "slotKind": skind,
            "status": "in_game",
            "hdPath": hdp,
            "previewPath": prevp,
            "swPath": "",
            "smallPath": "",
            "gameTarget": gtarget,
            "vanillaFallback": vfb,
            "codeRef": cref,
            "brief": brief,
        })

    # 3. 10 Campfire Scene Layers, Carts & Slot Seals
    for cid, grp, name, sub, spec, skind, hdp, prevp, hovp, gtarget, vfb, cref, brief in CAMP_SCENE_DEFS:
        entry = {
            "id": cid,
            "stage": "7_scenes",
            "group": grp,
            "name": name,
            "sub": sub,
            "spec": spec,
            "slotKind": skind,
            "status": "in_game",
            "hdPath": hdp,
            "previewPath": prevp,
            "swPath": "",
            "smallPath": "",
            "gameTarget": gtarget,
            "vanillaFallback": vfb,
            "codeRef": cref,
            "brief": brief,
        }
        if hovp:
            entry["hoverPath"] = hovp
        new_assets.append(entry)

    # 4. 18 Seated Campfire Retinue Followers
    for stem, title, (fw, fh), brief in FOLLOWER_DEFS:
        fid = f"wx_{stem}"
        new_assets.append({
            "id": fid,
            "stage": "7_scenes",
            "group": "篝火随行十八幕僚坐姿立绘（18位）",
            "name": f"随行幕僚 · {title}",
            "sub": f"篝火席位立绘 · {fw}×{fh} (+_b 高亮态)",
            "spec": f"{fw}×{fh} RGBA 盘膝立绘 (+_b 悬停金辉)",
            "slotKind": "camp",
            "status": "in_game",
            "hdPath": f"art/hd/{fid}.png",
            "previewPath": f"art/game/ui/campfire/{fid}.png",
            "hoverPath": f"art/game/ui/campfire/{fid}_b.png",
            "swPath": "",
            "smallPath": "",
            "gameTarget": f"gfx/ui/campfire/{fid}.png",
            "vanillaFallback": f"ui/campfire/{stem}.png",
            "codeRef": "mod_wuxia/hooks/config/wx_screens_hook.nut",
            "brief": brief,
        })

    new_ids = set(x["id"] for x in new_assets)
    kept_assets = [a for a in manifest["assets"] if a["id"] not in new_ids and a.get("stage") != "7_scenes"]
    manifest["assets"] = kept_assets + new_assets

    manifest["version"] = f"1.0.0-events-screens-campfire-{len(manifest['assets'])}"
    manifest["summary"] = {
        "total": len(manifest["assets"]),
        "wiki_ready": sum(1 for a in manifest["assets"] if a["status"] == "wiki_ready"),
        "in_game": sum(1 for a in manifest["assets"] if a["status"] == "in_game"),
        "planned": sum(1 for a in manifest["assets"] if a["status"] == "planned"),
        "png_files_generated": count_generated_files(),
    }

    with open(MANIFEST_PATH, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)

    print(f"SUCCESS: Registered {len(new_assets)} Stage 7 (`7_scenes`) assets! Total manifest assets = {manifest['summary']['total']} (in_game={manifest['summary']['in_game']}).")


if __name__ == "__main__":
    main()
