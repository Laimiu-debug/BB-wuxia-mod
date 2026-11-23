// Non-Destructive Wuxia Equipment Visual & Paperdoll Remapping System (`::Wuxia.Armory`)
// Maps vanilla & DLC medieval weapons, famed red weapons, shields, offhand nets, robes/armors,
// hats/helmets, armor upgrades & accessories onto registered `wx_weapons_0.brush` (`arm_*`, `shd_*`),
// `wx_busts_0.brush` (`wx_body_*`, `wx_hat_*_front`, `wx_hat_*_back`), and loose UI item icons
// (`70x140` & `70x70`) while preserving 100% of vanilla combat mechanics, saves & corpses.

::Wuxia.Armory <- {
	// [WuxiaAssetID, Folder ("melee"|"ranged"), ChineseName]
	WeaponMap = {
		// Swords (剑)
		["weapon.wooden_stick"]            = ["wx_wpn_staff_01",  "melee",  "齐眉白蜡木长棍"],
		["weapon.wooden_stake"]            = ["wx_wpn_sword_01",  "melee",  "削尖桃木镇邪短剑"],
		["weapon.lute"]                    = ["wx_wpn_sword_01",  "melee",  "梨园藏锋演武木剑"],
		["weapon.shortsword"]              = ["wx_wpn_sword_02",  "melee",  "锈铁云头短剑"],
		["weapon.falchion"]                = ["wx_wpn_saber_02",  "melee",  "绿林铁盘柳叶刀"],
		["weapon.arming_sword"]            = ["wx_wpn_sword_03",  "melee",  "青钢制式长剑"],
		["weapon.noble_sword"]             = ["wx_wpn_sword_04",  "melee",  "百炼松纹宝剑"],
		["weapon.fencing_sword"]           = ["wx_wpn_sword_06",  "melee",  "寒星游龙细刺剑"],
		["weapon.shamshir"]                = ["wx_wpn_saber_07",  "melee",  "塞外镔铁马贼弯刀"],
		["weapon.saif"]                    = ["wx_wpn_saber_07",  "melee",  "西域镔铁吹毛快刀"],
		["weapon.warbrand"]                = ["wx_wpn_saber_06",  "melee",  "戚家双手长苗刀"],
		["weapon.longsword"]               = ["wx_wpn_sword_07",  "melee",  "八面汉制双手长剑"],
		["weapon.greatsword"]              = ["wx_wpn_sword_08",  "melee",  "乌金无锋重铁剑"],
		["weapon.ancient_sword"]           = ["wx_wpn_sword_05",  "melee",  "前朝青铜八棱古剑"],
		["weapon.rhomphaia"]               = ["wx_wpn_saber_08",  "melee",  "前朝双手斩马古刃"],

		// Sabers / Cleavers (刀)
		["weapon.butchers_cleaver"]        = ["wx_wpn_saber_01",  "melee",  "柴房豁口砍柴刀"],
		["weapon.scramasax"]               = ["wx_wpn_saber_02",  "melee",  "绿林铁盘柳叶刀"],
		["weapon.goblin_falchion"]         = ["wx_wpn_saber_02",  "melee",  "五毒青竹弯弧短刀"],
		["weapon.military_cleaver"]        = ["wx_wpn_saber_03",  "melee",  "百炼军镇雁翎刀"],
		["weapon.scimitar"]                = ["wx_wpn_saber_04",  "melee",  "江湖宽刃牛尾刀"],
		["weapon.khopesh"]                 = ["wx_wpn_saber_05",  "melee",  "铁环九连鬼头大刀"],
		["weapon.crypt_cleaver"]           = ["wx_wpn_saber_05",  "melee",  "前朝镇墓鬼头重刀"],
		["weapon.orc_cleaver"]             = ["wx_wpn_saber_05",  "melee",  "药人狂煞锯齿重刀"],
		["weapon.headchopper"]             = ["wx_wpn_saber_05",  "melee",  "药人狂煞锯齿重刀"],
		["weapon.two_handed_scimitar"]     = ["wx_wpn_saber_08",  "melee",  "双手破甲斩马厚刀"],
		["weapon.barbarian_cleaver"]       = ["wx_wpn_saber_05",  "melee",  "黑水蛮骨重环大刀"],
		["weapon.two_handed_cleaver"]      = ["wx_wpn_saber_08",  "melee",  "关外碎甲双持狂刀"],
		["weapon.cleaver"]                 = ["wx_wpn_saber_03",  "melee",  "江湖厚背朴刀"],

		// Spears & Polearms (枪杆长兵)
		["weapon.goblin_spear"]            = ["wx_wpn_spear_01",  "melee",  "五毒淬药倒刺竹矛"],
		["weapon.militia_spear"]           = ["wx_wpn_spear_02",  "melee",  "乡勇生铁短矛"],
		["weapon.boar_spear"]              = ["wx_wpn_spear_03",  "melee",  "白蜡杆红缨快枪"],
		["weapon.fighting_spear"]          = ["wx_wpn_spear_04",  "melee",  "威远十字横挡铁枪"],
		["weapon.ancient_spear"]           = ["wx_wpn_spear_06",  "melee",  "边军四棱透甲锥枪"],
		["weapon.firelance"]               = ["wx_wpn_spear_05",  "melee",  "神机梨花喷火铁枪"],
		["weapon.spetum"]                  = ["wx_wpn_pole_06",   "melee",  "清源三尖两刃刀"],
		["weapon.pitchfork"]               = ["wx_wpn_pole_01",   "melee",  "庄户三齿铁草叉"],
		["weapon.warfork"]                 = ["wx_wpn_pole_03",   "melee",  "行脚僧月牙方便铲"],
		["weapon.hooked_blade"]            = ["wx_wpn_pole_02",   "melee",  "水寨倒刺钩镰枪"],
		["weapon.goblin_pike"]             = ["wx_wpn_pole_02",   "melee",  "南疆钩藤割脉长矛"],
		["weapon.pike"]                    = ["wx_wpn_spear_07",  "melee",  "军阵攒竹步战长槊"],
		["weapon.billhook"]                = ["wx_wpn_pole_07",   "melee",  "藩镇单耳青铁长戟"],
		["weapon.bladed_pike"]             = ["wx_wpn_pole_04",   "melee",  "边关长杆破甲朴刀"],
		["weapon.ancient_bladed_pike"]     = ["wx_wpn_pole_07",   "melee",  "前朝玄宫青铜长戈"],
		["weapon.warscythe"]               = ["wx_wpn_pole_05",   "melee",  "前朝镇陵偃月铜刀"],
		["weapon.swordlance"]              = ["wx_wpn_pole_05",   "melee",  "武科制式偃月大刀"],
		["weapon.polemace"]                = ["wx_wpn_pole_08",   "melee",  "塞外长柄狼牙槊"],
		["weapon.oriental_polemace"]       = ["wx_wpn_pole_08",   "melee",  "西域九环熟铜长杵"],
		["weapon.longaxe"]                 = ["wx_wpn_axe_06",    "melee",  "步战长杆蛾眉战斧"],

		// Hammers / Maces / Staffs (锤锏棍杖)
		["weapon.bludgeon"]                = ["wx_wpn_staff_02",  "melee",  "少室熟铜包头棍"],
		["weapon.goedendag"]               = ["wx_wpn_staff_03",  "melee",  "精铁螺纹少林棍"],
		["weapon.cudgel"]                  = ["wx_wpn_staff_04",  "melee",  "沧桑铁木龙头拐杖"],
		["weapon.orc_wooden_club"]         = ["wx_wpn_hammer_01", "melee",  "蛮荒铁钉硬木巨棒"],
		["weapon.morning_star"]            = ["wx_wpn_hammer_02", "melee",  "塞外短柄狼牙铁棒"],
		["weapon.orc_metal_club"]          = ["wx_wpn_hammer_02", "melee",  "药人生铁狼牙重棒"],
		["weapon.winged_mace"]             = ["wx_wpn_hammer_04", "melee",  "黄铜蒜头破甲骨朵"],
		["weapon.flanged_mace"]            = ["wx_wpn_hammer_04", "melee",  "乌钢六瓣破甲瓜锤"],
		["weapon.nomad_mace"]              = ["wx_wpn_hammer_06", "melee",  "捕头四棱精钢单锏"],
		["weapon.light_southern_mace"]     = ["wx_wpn_hammer_01", "melee",  "铁钉枣木骨朵棒"],
		["weapon.heavy_southern_mace"]     = ["wx_wpn_hammer_04", "melee",  "西域错金破甲骨朵"],
		["weapon.pickaxe"]                 = ["wx_wpn_hammer_05", "melee",  "矿山开石尖嘴铁镐"],
		["weapon.military_pick"]           = ["wx_wpn_hammer_05", "melee",  "军镇鹤嘴破甲铁锤"],
		["weapon.warhammer"]               = ["wx_wpn_hammer_03", "melee",  "八棱百炼精铁单锤"],
		["weapon.two_handed_wooden_hammer"]= ["wx_wpn_staff_06",  "melee",  "疯魔精铁方便杖"],
		["weapon.two_handed_mace"]         = ["wx_wpn_staff_08",  "melee",  "乌木错金盘纹重杖"],
		["weapon.two_handed_flanged_mace"] = ["wx_wpn_hammer_07", "melee",  "玄铁立瓜双手重锤"],
		["weapon.two_handed_hammer"]       = ["wx_wpn_hammer_07", "melee",  "玄铁立瓜双手重锤"],
		["weapon.polehammer"]              = ["wx_wpn_hammer_08", "melee",  "鹰嘴倒刺长柄破城锤"],
		["weapon.skull_hammer"]            = ["wx_wpn_hammer_07", "melee",  "关外碎颅白骨重锤"],
		["weapon.two_handed_spiked_mace"]  = ["wx_wpn_staff_07",  "melee",  "关外狼牙铁箍重棒"],

		// Axes (斧钺)
		["weapon.hatchet"]                 = ["wx_wpn_axe_01",    "melee",  "山林樵夫伐木短斧"],
		["weapon.hand_axe"]                = ["wx_wpn_axe_02",    "melee",  "黑风寨阔口铁板斧"],
		["weapon.fighting_axe"]            = ["wx_wpn_axe_03",    "melee",  "精铁新月单手战斧"],
		["weapon.headsplitter"]            = ["wx_wpn_axe_04",    "melee",  "药人乌钢碎颅战斧"],
		["weapon.orc_axe"]                 = ["wx_wpn_axe_04",    "melee",  "药人乌钢碎颅战斧"],
		["weapon.woodcutters_axe"]         = ["wx_wpn_axe_05",    "melee",  "双手劈山大板斧"],
		["weapon.greataxe"]                = ["wx_wpn_axe_07",    "melee",  "镇边玄铁长柯重钺"],
		["weapon.bardiche"]                = ["wx_wpn_axe_05",    "melee",  "辽东双手劈山重斧"],
		["weapon.heavy_rusty_axe"]         = ["wx_wpn_axe_08",    "melee",  "关外蛮骨重铁巨斧"],
		["weapon.mansplitter"]             = ["wx_wpn_axe_08",    "melee",  "炼体药人开山巨斧"],
		["weapon.orc_axe_2h"]              = ["wx_wpn_axe_08",    "melee",  "炼体药人开山巨斧"],
		["weapon.rusty_warblade"]          = ["wx_wpn_pole_04",   "melee",  "关外寒铁重斩马刀"],

		// Daggers / Flails / Whips (匕刺软鞭连枷)
		["weapon.knife"]                   = ["wx_wpn_dagger_01", "melee",  "猎户剥皮小尖刀"],
		["weapon.dagger"]                  = ["wx_wpn_dagger_02", "melee",  "水陆绿林牛耳尖刀"],
		["weapon.rondel_dagger"]           = ["wx_wpn_dagger_03", "melee",  "寒铁三棱透甲锥匕"],
		["weapon.bollock_dagger"]          = ["wx_wpn_dagger_04", "melee",  "水上漂精钢分水刺"],
		["weapon.qatal_dagger"]            = ["wx_wpn_dagger_05", "melee",  "西域寒月处决弯匕"],
		["weapon.notched_blade"]           = ["wx_wpn_dagger_06", "melee",  "五毒青磷蛇形短剑"],
		["weapon.goblin_notched_blade"]    = ["wx_wpn_dagger_06", "melee",  "五毒锯齿放血蛇刃"],
		["weapon.wooden_flail"]            = ["wx_wpn_staff_05",  "melee",  "精钢锁环三节棍"],
		["weapon.reinforced_wooden_flail"] = ["wx_wpn_whip_02",   "melee",  "江湖精铁七节鞭"],
		["weapon.flail"]                   = ["wx_wpn_flail_01",  "melee",  "绿林双链铁刺连枷"],
		["weapon.three_headed_flail"]      = ["wx_wpn_whip_03",   "melee",  "乌钢倒刺九节龙鞭"],
		["weapon.two_handed_flail"]        = ["wx_wpn_flail_02",  "melee",  "边关双手重铁扫子枷"],
		["weapon.berserker_chain"]         = ["wx_wpn_whip_04",   "melee",  "狂魔玄铁锁命重链"],
		["weapon.orc_flail_2h"]            = ["wx_wpn_flail_02",  "melee",  "药人玄铁重链枷"],
		["weapon.battle_whip"]             = ["wx_wpn_whip_01",   "melee",  "浸油牛皮牧马长鞭"],

		// Bows / Crossbows / Firearms / Throwing (弓弩火器暗器)
		["weapon.wonky_bow"]               = ["wx_wpn_bow_01",    "ranged", "猎寨青竹短弓"],
		["weapon.short_bow"]               = ["wx_wpn_bow_01",    "ranged", "山野桑木猎户短弓"],
		["weapon.hunting_bow"]             = ["wx_wpn_bow_02",    "ranged", "塞外牛角桦皮筋弓"],
		["weapon.composite_bow"]           = ["wx_wpn_bow_02",    "ranged", "朔漠角端骑射劲弓"],
		["weapon.war_bow"]                 = ["wx_wpn_bow_03",    "ranged", "边关九石铁胎大弓"],
		["weapon.masterwork_bow"]          = ["wx_wpn_bow_03",    "ranged", "百工铁胎神射雕弓"],
		["weapon.light_crossbow"]          = ["wx_wpn_xbow_01",   "ranged", "猎寨青竹药箭轻弩"],
		["weapon.crossbow"]                = ["wx_wpn_xbow_02",   "ranged", "军镇神机踏张铁弩"],
		["weapon.heavy_crossbow"]          = ["wx_wpn_xbow_03",   "ranged", "蜀传机巧诸葛连珠弩"],
		["weapon.spiked_impaler"]          = ["wx_wpn_xbow_03",   "ranged", "五毒破甲毒蒺藜重弩"],
		["weapon.handgonne"]               = ["wx_wpn_gun_01",    "ranged", "边军火绳单管手铳"],
		["weapon.sling"]                   = ["wx_wpn_throw_01",  "ranged", "走镖飞蝗鹅卵石袋"],
		["weapon.javelin"]                 = ["wx_wpn_throw_01",  "ranged", "江湖淬铁甩手飞镖囊"],
		["weapon.heavy_javelin"]           = ["wx_wpn_spear_01",  "melee",  "关外破盾透甲重投梭"],
		["weapon.barbarian_javelin"]       = ["wx_wpn_spear_01",  "melee",  "关外破盾透甲重投梭"],
		["weapon.throwing_axe"]            = ["wx_wpn_throw_01",  "ranged", "绿林旋风飞蝗铁镖"],
		["weapon.heavy_throwing_axe"]      = ["wx_wpn_axe_04",    "melee",  "关外旋风碎骨飞斧"],
		["weapon.barbarian_throwing_axe"]  = ["wx_wpn_axe_04",    "melee",  "关外旋风碎骨飞斧"],
		["weapon.throwing_spear"]          = ["wx_wpn_spear_01",  "melee",  "破盾透甲投掷短梭"],
		["weapon.goblin_bow"]              = ["wx_wpn_bow_01",    "ranged", "五毒青竹毒矢短弓"],
		["weapon.goblin_heavy_bow"]        = ["wx_wpn_bow_02",    "ranged", "南疆乌竹吹毒劲弓"],
		["weapon.bola"]                    = ["wx_wpn_throw_01",  "ranged", "南疆绊马缠丝飞石索"],
		["weapon.goblin_spiked_balls"]     = ["wx_wpn_throw_01",  "ranged", "五毒铁蒺藜暗器囊"]
	},

	// Vanilla Famed / Named Red Weapons (`weapon.named_*`) -> 100% Dedicated Non-Shared Wuxia Famed Art (`weapons/named/wx_famed_*`)
	// [WuxiaAssetID, Folder ("melee"|"ranged"|"named")]
	NamedWeaponMap = {
		["weapon.named_sword"]                  = ["wx_famed_01", "named"],
		["weapon.named_noble_sword"]            = ["wx_famed_02", "named"],
		["weapon.named_fencing_sword"]          = ["wx_famed_03", "named"],
		["weapon.named_greatsword"]             = ["wx_famed_04", "named"],
		["weapon.named_longsword"]              = ["wx_famed_05", "named"],
		["weapon.named_estoc"]                  = ["wx_famed_06", "named"],
		["weapon.named_warbrand"]               = ["wx_famed_07", "named"],
		["weapon.named_shamshir"]               = ["wx_famed_08", "named"],
		["weapon.named_cleaver"]                = ["wx_famed_09", "named"],
		["weapon.named_military_cleaver"]       = ["wx_famed_10", "named"],
		["weapon.named_crypt_cleaver"]          = ["wx_famed_11", "named"],
		["weapon.named_khopesh"]                = ["wx_famed_12", "named"],
		["weapon.named_two_handed_scimitar"]    = ["wx_famed_13", "named"],
		["weapon.named_two_handed_cleaver"]     = ["wx_famed_14", "named"],
		["weapon.named_barbarian_cleaver"]      = ["wx_famed_15", "named"],
		["weapon.named_orc_cleaver"]            = ["wx_famed_16", "named"],
		["weapon.named_spear"]                  = ["wx_famed_17", "named"],
		["weapon.named_fighting_spear"]         = ["wx_famed_18", "named"],
		["weapon.named_goblin_spear"]           = ["wx_famed_19", "named"],
		["weapon.named_spetum"]                 = ["wx_famed_20", "named"],
		["weapon.named_pike"]                   = ["wx_famed_21", "named"],
		["weapon.named_goblin_pike"]            = ["wx_famed_22", "named"],
		["weapon.named_billhook"]               = ["wx_famed_23", "named"],
		["weapon.named_bladed_pike"]            = ["wx_famed_24", "named"],
		["weapon.named_ancient_bladed_pike"]    = ["wx_famed_25", "named"],
		["weapon.named_warscythe"]              = ["wx_famed_26", "named"],
		["weapon.named_swordlance"]             = ["wx_famed_27", "named"],
		["weapon.named_rusty_warblade"]         = ["wx_famed_28", "named"],
		["weapon.named_polemace"]               = ["wx_famed_29", "named"],
		["weapon.named_longaxe"]                = ["wx_famed_30", "named"],
		["weapon.named_mace"]                   = ["wx_famed_31", "named"],
		["weapon.named_nomad_mace"]             = ["wx_famed_32", "named"],
		["weapon.named_two_handed_mace"]        = ["wx_famed_33", "named"],
		["weapon.named_two_handed_flanged_mace"]= ["wx_famed_34", "named"],
		["weapon.named_two_handed_spiked_mace"] = ["wx_famed_35", "named"],
		["weapon.named_warhammer"]              = ["wx_famed_36", "named"],
		["weapon.named_two_handed_hammer"]      = ["wx_famed_37", "named"],
		["weapon.named_skullhammer"]            = ["wx_famed_38", "named"],
		["weapon.named_skull_hammer"]           = ["wx_famed_38", "named"],
		["weapon.named_polehammer"]             = ["wx_famed_39", "named"],
		["weapon.named_axe"]                    = ["wx_famed_40", "named"],
		["weapon.named_fighting_axe"]           = ["wx_famed_41", "named"],
		["weapon.named_greataxe"]               = ["wx_famed_42", "named"],
		["weapon.named_bardiche"]               = ["wx_famed_43", "named"],
		["weapon.named_poleaxe"]                = ["wx_famed_44", "named"],
		["weapon.named_exesword"]               = ["wx_famed_45", "named"],
		["weapon.named_heavy_rusty_axe"]        = ["wx_famed_46", "named"],
		["weapon.named_flail"]                  = ["wx_famed_47", "named"],
		["weapon.named_three_headed_flail"]     = ["wx_famed_48", "named"],
		["weapon.named_two_handed_flail"]       = ["wx_famed_49", "named"],
		["weapon.named_battle_whip"]            = ["wx_famed_50", "named"],
		["weapon.named_dagger"]                 = ["wx_famed_51", "named"],
		["weapon.named_rondel_dagger"]          = ["wx_famed_52", "named"],
		["weapon.named_qatal_dagger"]           = ["wx_famed_53", "named"],
		["weapon.named_bow"]                    = ["wx_famed_54", "named"],
		["weapon.named_warbow"]                 = ["wx_famed_55", "named"],
		["weapon.named_goblin_heavy_bow"]       = ["wx_famed_56", "named"],
		["weapon.named_crossbow"]               = ["wx_famed_57", "named"],
		["weapon.named_handgonne"]              = ["wx_famed_58", "named"],
		["weapon.named_javelin"]                = ["wx_famed_59", "named"],
		["weapon.named_throwing_axe"]           = ["wx_famed_60", "named"],
		["weapon.named_goblin_falchion"]        = ["wx_famed_61", "named"],
		["weapon.named_orc_axe"]                = ["wx_famed_62", "named"]
	},

	// [ShieldAssetID, ChineseName]
	ShieldMap = {
		["shield.buckler"]               = ["wx_shd_02", "闽粤桐油老藤牌"],
		["shield.wooden_shield"]         = ["wx_shd_01", "乡勇包铁榆木圆盾"],
		["shield.oriental_light_shield"] = ["wx_shd_03", "戚家军虎头彩绘藤牌"],
		["shield.southern_light_shield"] = ["wx_shd_03", "戚家军虎头彩绘藤牌"],
		["shield.sipar_shield"]          = ["wx_shd_09", "西域错金弯月铁盾"],
		["shield.worn_heater_shield"]    = ["wx_shd_04", "威远镖局铆钉铁边盾"],
		["shield.heater_shield"]         = ["wx_shd_05", "百炼乌钢护心圆盾"],
		["shield.faction_heater_shield"] = ["wx_shd_06", "藩镇吞兽熟铜团牌"],
		["shield.worn_kite_shield"]      = ["wx_shd_07", "军阵窥窗步兵立盾"],
		["shield.kite_shield"]           = ["wx_shd_07", "军阵窥窗步兵立盾"],
		["shield.faction_kite_shield"]   = ["wx_shd_12", "禁军盘龙鎏金重盾"],
		["shield.auxiliary_shield"]      = ["wx_shd_10", "玄门八卦黄铜圆盾"],
		["shield.coffin_shield"]         = ["wx_shd_08", "前朝镇墓饕餮绿锈铜盾"],
		["shield.tower_shield"]          = ["wx_shd_08", "前朝玄宫千钧镇陵巨盾"],
		["shield.goblin_light_shield"]   = ["wx_shd_11", "五毒青鳞尖刺铁盾"],
		["shield.goblin_heavy_shield"]   = ["wx_shd_11", "南疆百足毒藤圆盾"],
		["shield.orc_light_shield"]      = ["wx_shd_04", "药人铁箍生皮圆盾"],
		["shield.orc_heavy_shield"]      = ["wx_shd_11", "药人重铁尖刺巨盾"]
	},

	// Offhand Nets, Tactical Bombs & Flasks (`tool.*` and offhand `weapon.*_bomb/*_flask/holy_water`)
	// [IconRel, IconLargeRel, OffhandBrushOrNull, ChineseName]
	ToolMap = {
		["tool.throwing_net"]            = ["tools/wx_wpn_tool_01_70x70.png",    "tools/wx_wpn_tool_01.png",    "shd_wx_wpn_tool_01",    "南疆浸油牛筋捕兽网筒"],
		["tool.reinforced_throwing_net"] = ["tools/wx_wpn_tool_01_70x70.png",    "tools/wx_wpn_tool_01.png",    "shd_wx_wpn_tool_01",    "唐门精铁铅坠锁兽网筒"],
		["weapon.fire_bomb"]             = ["tools/wx_tool_fire_bomb_70x70.png", "tools/wx_tool_fire_bomb.png", "shd_wx_tool_fire_bomb", "霹雳堂赤焰雷火弹"],
		["tool.fire_bomb"]               = ["tools/wx_tool_fire_bomb_70x70.png", "tools/wx_tool_fire_bomb.png", "shd_wx_tool_fire_bomb", "霹雳堂赤焰雷火弹"],
		["weapon.smoke_bomb"]            = ["tools/wx_tool_smoke_bomb_70x70.png","tools/wx_tool_smoke_bomb.png","shd_wx_tool_smoke_bomb","唐门五云迷魂烟弹"],
		["tool.smoke_bomb"]              = ["tools/wx_tool_smoke_bomb_70x70.png","tools/wx_tool_smoke_bomb.png","shd_wx_tool_smoke_bomb","唐门五云迷魂烟弹"],
		["weapon.daze_bomb"]             = ["tools/wx_tool_daze_bomb_70x70.png", "tools/wx_tool_daze_bomb.png", "shd_wx_tool_daze_bomb", "震天铁壳惊雷闪光弹"],
		["tool.daze_bomb"]               = ["tools/wx_tool_daze_bomb_70x70.png", "tools/wx_tool_daze_bomb.png", "shd_wx_tool_daze_bomb", "震天铁壳惊雷闪光弹"],
		["weapon.acid_flask"]            = ["tools/wx_tool_acid_flask_70x70.png","tools/wx_tool_acid_flask.png","shd_wx_tool_acid_flask","五毒蚀甲化骨毒瓶"],
		["tool.acid_flask"]              = ["tools/wx_tool_acid_flask_70x70.png","tools/wx_tool_acid_flask.png","shd_wx_tool_acid_flask","五毒蚀甲化骨毒瓶"],
		["weapon.holy_water"]            = ["tools/wx_tool_holy_water_70x70.png","tools/wx_tool_holy_water.png","shd_wx_tool_holy_water","龙虎山天师镇尸符水"],
		["tool.holy_water"]              = ["tools/wx_tool_holy_water_70x70.png","tools/wx_tool_holy_water.png","shd_wx_tool_holy_water","龙虎山天师镇尸符水"]
	},

	// Ammunition Quivers, Bolt Cases & Powder Bags (`ammo.*`)
	// [IconRel, ChineseName]
	AmmoMap = {
		["ammo.arrows"]                  = ["ammo/wx_ammo_arrows.png", "雕翎狼牙箭壶"],
		["ammo.quiver_of_arrows"]        = ["ammo/wx_ammo_arrows.png", "雕翎狼牙箭壶"],
		["ammo.large_quiver_of_arrows"]  = ["ammo/wx_ammo_arrows.png", "神射重装雕翎大箭壶"],
		["ammo.bolts"]                   = ["ammo/wx_ammo_bolts.png",  "神机破甲钢弩匣"],
		["ammo.quiver_of_bolts"]         = ["ammo/wx_ammo_bolts.png",  "神机破甲钢弩匣"],
		["ammo.large_quiver_of_bolts"]   = ["ammo/wx_ammo_bolts.png",  "武侯连珠重装钢弩匣"],
		["ammo.powder_bag"]              = ["ammo/wx_ammo_powder.png", "神机营黑火药铅弹袋"]
	},

	// [BodyAssetID, ChineseName]
	ArmorMap = {
		["armor.body.tattered_sackcloth"]   = ["wx_body_civ_01",  "庄稼汉草绳褐麻短褐"],
		["armor.body.sackcloth"]            = ["wx_body_civ_04",  "老渔翁芦苇披领补丁褂"],
		["armor.body.linen_tunic"]          = ["wx_body_civ_11",  "落第寒儒洗白皂边澜衫"],
		["armor.body.noble_tunic"]          = ["wx_body_sect_04", "世家公子云纹锦缎长衫"],
		["armor.body.cloth_tunic"]          = ["wx_body_civ_08",  "码头脚夫搭肩白汗巾褂"],
		["armor.body.thick_tunic"]          = ["wx_body_civ_06",  "游方郎中青布百草囊衫"],
		["armor.body.apron"]                = ["wx_body_civ_02",  "铁匠焦痕厚牛皮围裙装"],
		["armor.body.butcher_apron"]        = ["wx_body_civ_03",  "屠户暗血油皮护胸装"],
		["armor.body.monk_robe"]            = ["wx_body_sect_01", "少室武僧杏黄交领僧衣"],
		["armor.body.wizard_robe"]          = ["wx_body_sect_02", "太和紫霄飞鹤阴阳道袍"],
		["armor.body.cultist_leather_robe"] = ["wx_body_sect_09", "血煞魔宗赤黑铆钉皮衣"],
		["armor.body.leather_wraps"]        = ["wx_body_civ_05",  "矿工铆皮护肩粗帆衣"],
		["armor.body.leather_tunic"]        = ["wx_body_sect_03", "清风剑派竹青云领剑衫"],
		["armor.body.padded_surcoat"]       = ["wx_body_sect_04", "华岳紫霞暗云丝绸劲袍"],
		["armor.body.gambeson"]             = ["wx_body_arm_01",  "威远镖局护胸黑革趟子甲"],
		["armor.body.blotched_gambeson"]    = ["wx_body_sect_05", "丐帮九袋麻绳百结战衣"],
		["armor.body.padded_leather"]       = ["wx_body_arm_02",  "绿林水磨硬牛皮柳叶札甲"],
		["armor.body.ragged_surcoat"]       = ["wx_body_arm_03",  "朔漠白骨扣双层生牛皮甲"],
		["armor.body.rugged_surcoat"]       = ["wx_body_arm_03",  "关外苍狼毛领生牛皮甲"],
		["armor.body.leather_lamellar"]     = ["wx_body_arm_04",  "大宋步人漆皮披膊熟革甲"],
		["armor.body.worn_mail_shirt"]      = ["wx_body_arm_06",  "江湖百战残破锁子甲衫"],
		["armor.body.patched_mail_shirt"]   = ["wx_body_arm_06",  "绿林铁叶补缀锁子甲"],
		["armor.body.basic_mail_shirt"]     = ["wx_body_arm_06",  "边关夜不收苍狼皮锁子甲"],
		["armor.body.mail_shirt"]           = ["wx_body_arm_07",  "九边军镇绛红铜钉棉铁甲"],
		["armor.body.mail_hauberk"]         = ["wx_body_arm_08",  "神机营防火铁胸黑革罩甲"],
		["armor.body.reinforced_mail_hauberk"]= ["wx_body_hvy_01","百炼精钢鱼鳞护心重甲"],
		["armor.body.footman_armor"]        = ["wx_body_arm_09",  "靖海楼水师青蛟皮软鳞甲"],
		["armor.body.light_scale_armor"]    = ["wx_body_arm_10",  "桃花传世金丝软猬倒刺甲"],
		["armor.body.leather_scale_armor"]  = ["wx_body_arm_05",  "南诏浸油老藤叠鳞轻甲"],
		["armor.body.sellsword_armor"]      = ["wx_body_hvy_05",  "关外黑貂领连环铁镜重甲"],
		["armor.body.heavy_iron_armor"]     = ["wx_body_hvy_05",  "关外冷锻重铁护镜战铠"],
		["armor.body.lamellar_harness"]     = ["wx_body_hvy_03",  "武经总要宋制步人重铁札甲"],
		["armor.body.scale_armor"]          = ["wx_body_hvy_02",  "盛唐遗制双圆护心镜明光铠"],
		["armor.body.heavy_lamellar_armor"] = ["wx_body_hvy_04",  "北庭冷锻叠板铁浮屠重铠"],
		["armor.body.coat_of_scales"]       = ["wx_body_hvy_06",  "镇国大将黄金吞兽鱼鳞帅铠"],
		["armor.body.coat_of_plates"]       = ["wx_body_hvy_07",  "少室金刚乌金巨铆横练重铠"],
		["armor.body.assassin_robe"]        = ["wx_body_sect_10", "无常鬼市飞刀夜行黑衣"],
		["armor.body.nomad_robe"]           = ["wx_body_sect_12", "塞外瀚海盘绳游牧袍"],
		["armor.body.thick_nomad_robe"]     = ["wx_body_sect_13", "西域圣火暗纹绯红锦袍"],
		["armor.body.cloth_sash"]           = ["wx_body_civ_12",  "西域武生盘扣绛红短打"],
		["armor.body.oriental_padded_vest"] = ["wx_body_sect_06", "丝路机袖暗囊护胸马甲"],
		["armor.body.stitched_nomad_armor"] = ["wx_body_arm_05",  "南诏浸油老藤编织胸铠"],
		["armor.body.southern_mail_shirt"]  = ["wx_body_hvy_10",  "葱岭大食旋纹镔铁明镜重铠"],
		["armor.body.southern_long_mail_with_padding"] = ["wx_body_hvy_10", "西域金丝棉衬镔铁长铠"],
		["armor.body.padded_mail_and_lamellar_hauberk"]= ["wx_body_hvy_03", "西域叠札护心重铁铠"],
		["armor.body.animal_hide_armor"]    = ["wx_body_civ_09",  "关外金钱豹皮护胸猎衣"],
		["armor.body.reinforced_animal_hide_armor"] = ["wx_body_hvy_09", "黑水兽骨锁链黑铁凶甲"],
		["armor.body.scrap_metal_armor"]    = ["wx_body_hvy_09",  "关外碎铁铆链百战重甲"],
		["armor.body.thick_plated_barbarian_armor"] = ["wx_body_hvy_09", "北境霸主尖刺黑铁重铠"],
		["armor.body.ancient_breastplate"]  = ["wx_body_hvy_08",  "前朝地宫铜绿饕餮镇陵古铠"],
		["armor.body.ancient_scale_harness"]= ["wx_body_hvy_08",  "前朝玄宫青铜鱼鳞镇墓铠"],
		["armor.body.ancient_plate_harness"]= ["wx_body_hvy_08",  "前朝镇陵鎏金吞兽古重铠"]
	},

	// [HatAssetID, ChineseName]
	HelmetMap = {
		["armor.head.headscarf"]            = ["wx_hat_01", "伙夫靛青包头布巾"],
		["armor.head.straw_hat"]            = ["wx_hat_02", "庄稼汉毛边遮阳草帽"],
		["armor.head.hood"]                 = ["wx_hat_03", "江南桐油竹骨雨笠"],
		["armor.head.aketon_cap"]           = ["wx_hat_05", "掌柜六瓣瓜皮小帽"],
		["armor.head.full_aketon_cap"]      = ["wx_hat_06", "寒儒青布东坡幅巾"],
		["armor.head.open_leather_cap"]     = ["wx_hat_12", "清风云纹嵌玉抹额"],
		["armor.head.headband"]             = ["wx_hat_13", "丐帮五帝铜钱麻额箍"],
		["armor.head.full_leather_cap"]     = ["wx_hat_07", "青苍竹篾尖顶斗笠"],
		["armor.head.witchhunter_hat"]      = ["wx_hat_07", "江湖夜行青竹宽檐笠"],
		["armor.head.feathered_hat"]        = ["wx_hat_09", "太和紫金八卦道冠"],
		["armor.head.physician_mask"]       = ["wx_hat_24", "药王谷防疫香草覆面巾"],
		["armor.head.cultist_hood"]         = ["wx_hat_08", "幽冥玄布蒙面风帽"],
		["armor.head.cultist_leather_hood"] = ["wx_hat_24", "湘西麻绳披孝尖风帽"],
		["armor.head.Southern_head_wrap"]   = ["wx_hat_15", "南疆苗银新月流苏冠"],
		["armor.head.southern_head_wrap"]   = ["wx_hat_15", "南疆苗银新月流苏冠"],
		["armor.head.nomad_head_wrap"]      = ["wx_hat_01", "瀚海防沙缠头青巾"],
		["armor.head.assassin_head_wrap"]   = ["wx_hat_08", "暗夜隐杀黑纱覆面巾"],
		["armor.head.assassin_face_mask"]   = ["wx_hat_17", "黑铁獠牙夜叉半面具"],
		["armor.head.gunner_hat"]           = ["wx_hat_31", "神机营棉衬熟铁护耳盔"],
		["armor.head.nasal_helmet"]         = ["wx_hat_25", "大宋红缨精铁笠子盔"],
		["armor.head.padded_nasal_helmet"]  = ["wx_hat_26", "明军黑漆宽檐铁军笠"],
		["armor.head.nasal_helmet_with_mail"]= ["wx_hat_27","唐风鎏金眉庇护鼻重盔"],
		["armor.head.mail_coif"]            = ["wx_hat_20", "西域缠巾锁子护颈盔"],
		["armor.head.wrapped_southern_helmet"]= ["wx_hat_20","葱岭缠巾精钢护颈盔"],
		["armor.head.spiked_skull_cap_with_mail"]= ["wx_hat_28","塞外尖顶锁子护颈兜鍪"],
		["armor.head.heavy_lamellar_helmet"]= ["wx_hat_28", "西域重札护颈尖顶胄"],
		["armor.head.turban_helmet"]        = ["wx_hat_30", "圣火错金缠巾重铁冠"],
		["armor.head.kettle_hat"]           = ["wx_hat_26", "九边制式黑漆铁军笠"],
		["armor.head.padded_kettle_hat"]    = ["wx_hat_25", "红缨熟铁步战笠子盔"],
		["armor.head.kettle_hat_with_mail"] = ["wx_hat_25", "禁军红缨锁子顿项铁笠"],
		["armor.head.kettle_hat_with_closed_mail"]= ["wx_hat_27","禁军覆面锁子重铁笠"],
		["armor.head.flat_top_helmet"]      = ["wx_hat_27", "唐风鎏金眉庇护鼻重盔"],
		["armor.head.flat_top_with_mail"]   = ["wx_hat_27", "藩镇铁札护颈平顶重盔"],
		["armor.head.nordic_helmet"]        = ["wx_hat_28", "北庭冷锻护鼻兜鍪"],
		["armor.head.steppe_helmet_with_mail"]= ["wx_hat_28","边镇尖顶铁札兜鍪"],
		["armor.head.bascinet_with_mail"]   = ["wx_hat_30", "内府鎏金盘龙双翼铁冠"],
		["armor.head.sallet_helmet"]        = ["wx_hat_30", "威远鎏金双翼护卫铁冠"],
		["armor.head.barbute_helmet"]       = ["wx_hat_29", "铁浮屠冷锻全覆铁面胄"],
		["armor.head.crude_faceguard_helmet"]= ["wx_hat_29","关外冷铁护面百战兜鍪"],
		["armor.head.closed_scrap_metal_helmet"]= ["wx_hat_29","关外铆铁全覆重战胄"],
		["armor.head.heavy_horned_plate_helmet"]= ["wx_hat_32","黑水双角吞天重铁霸胄"],
		["armor.head.full_helm"]            = ["wx_hat_32", "节度使金龙吞脊帅字胄"],
		["armor.head.great_helm"]           = ["wx_hat_32", "镇国金龙吞脊重铁帅胄"],
		["armor.head.closed_flat_top_helmet"]= ["wx_hat_29","铁浮屠全覆冷锻重铁胄"],
		["armor.head.bear_headpiece"]       = ["wx_hat_19", "朔北苍狼吞首皮兜"],
		["armor.head.ancient_household_helmet"]= ["wx_hat_23","前朝绿锈护鼻覆面铜胄"],
		["armor.head.ancient_legionary_helmet"]= ["wx_hat_23","前朝玄宫青铜守陵胄"],
		["armor.head.ancient_honorguard_helmet"]= ["wx_hat_18","哭丧青铜兰陵全脸面"]
	},

	// Non-pet Accessories (`accessory.*` -> `gfx/ui/items/accessory/wx_back_01..16.png`)
	AccessoryMap = {
		["accessory.bandage_item"]            = ["wx_back_07", "百草堂止血金创药篓"],
		["accessory.antidote_item"]           = ["wx_back_06", "药王谷辟毒清心葫芦"],
		["accessory.poison_item"]             = ["wx_back_10", "五毒碧磷淬刃毒囊"],
		["accessory.spider_poison_item"]      = ["wx_back_10", "南疆巨蛛蚀脉毒腺囊"],
		["accessory.sergeant_badge"]          = ["wx_back_08", "威远总镖头虎符令旗"],
		["accessory.undead_trophy"]           = ["wx_back_12", "朱砂百枚古铜钱辟邪剑"],
		["accessory.goblin_trophy"]           = ["wx_back_10", "千机百宝牛皮暗器囊"],
		["accessory.orc_trophy"]              = ["wx_back_14", "吊睛白额猛虎皮披挂"],
		["accessory.nachzehrer_trophy"]       = ["wx_back_11", "少室百八颗紫檀镇魂珠"],
		["accessory.alp_trophy"]              = ["wx_back_15", "天机阁乌金辟魇铁算盘"],
		["accessory.hexe_trophy"]             = ["wx_back_16", "清微派封邪山川符箓筒"]
	},

	FallbackCivBodies  = ["wx_body_civ_01", "wx_body_civ_04", "wx_body_civ_06", "wx_body_civ_07", "wx_body_civ_09", "wx_body_civ_10", "wx_body_civ_11", "wx_body_civ_12"],
	FallbackSectBodies = ["wx_body_sect_01", "wx_body_sect_02", "wx_body_sect_03", "wx_body_sect_04", "wx_body_sect_05", "wx_body_sect_06", "wx_body_sect_07", "wx_body_sect_08", "wx_body_sect_11", "wx_body_sect_14", "wx_body_sect_15", "wx_body_sect_16"],
	FallbackArmBodies  = ["wx_body_arm_01", "wx_body_arm_02", "wx_body_arm_03", "wx_body_arm_04", "wx_body_arm_05", "wx_body_arm_06", "wx_body_arm_07", "wx_body_arm_08", "wx_body_arm_09", "wx_body_arm_10"],
	FallbackHvyBodies  = ["wx_body_hvy_01", "wx_body_hvy_02", "wx_body_hvy_03", "wx_body_hvy_04", "wx_body_hvy_05", "wx_body_hvy_06", "wx_body_hvy_07", "wx_body_hvy_09", "wx_body_hvy_10"],

	FallbackLightHats  = ["wx_hat_01", "wx_hat_03", "wx_hat_04", "wx_hat_06", "wx_hat_07", "wx_hat_11", "wx_hat_12", "wx_hat_13", "wx_hat_14", "wx_hat_15", "wx_hat_16"],
	FallbackMedHats    = ["wx_hat_09", "wx_hat_10", "wx_hat_19", "wx_hat_20", "wx_hat_21", "wx_hat_24", "wx_hat_25", "wx_hat_26", "wx_hat_31"],
	FallbackHvyHats    = ["wx_hat_27", "wx_hat_28", "wx_hat_29", "wx_hat_30", "wx_hat_32"]
};

// Merge Stage 3 extra character robes/armors & boolean hats from `::Wuxia.Config.Appearance`
if ("Appearance" in ::Wuxia.Config)
{
	if ("ExtraArmorMap" in ::Wuxia.Config.Appearance)
	{
		foreach (ak, av in ::Wuxia.Config.Appearance.ExtraArmorMap)
		{
			if (!(ak in ::Wuxia.Armory.ArmorMap))
				::Wuxia.Armory.ArmorMap[ak] <- av;
		}
	}
	if ("ExtraHelmetMap" in ::Wuxia.Config.Appearance)
	{
		foreach (hk, hv in ::Wuxia.Config.Appearance.ExtraHelmetMap)
		{
			if (!(hk in ::Wuxia.Armory.HelmetMap))
				::Wuxia.Armory.HelmetMap[hk] <- hv;
		}
	}
}

::Wuxia.Armory.hashString <- function( _s )
{
	local h = 5381;
	for (local i = 0; i < _s.len(); i = ++i)
		h = ((h * 33) + _s[i]) & 0x3FFFFFFF;
	if (h < 0) h = -h;
	return h;
};

::Wuxia.Armory.isNaturalMonsterAttack <- function( _id )
{
	return _id.find("ghoul") != null || _id.find("ijirok") != null || _id.find("wolf") != null || _id.find("spider") != null || _id.find("lindwurm") != null || _id.find("unhold") != null || _id.find("schrat") != null || _id.find("kraken") != null || _id.find("serpent") != null || _id.find("hyena") != null;
};

::Wuxia.Armory.isCrossbowItem <- function( _item, _id )
{
	if (_id.find("crossbow") != null || _id.find("impaler") != null || _id.find("shenbinu") != null || _id.find("gudiaonu") != null)
		return true;
	if (::Wuxia.Appearance.hasMember(_item, "isWeaponType") && ("Const" in getroottable()) && ("WeaponType" in ::Const.Items))
	{
		if ("Crossbow" in ::Const.Items.WeaponType && _item.isWeaponType(::Const.Items.WeaponType.Crossbow))
			return true;
	}
	return false;
};

::Wuxia.Armory.resolveFallbackWeaponSpec <- function( _item, _id )
{
	local is2H = ::Wuxia.Appearance.hasMember(_item, "isItemType") && ("Const" in getroottable()) && _item.isItemType(::Const.Items.ItemType.TwoHanded);
	local hasWT = ::Wuxia.Appearance.hasMember(_item, "isWeaponType") && ("Const" in getroottable()) && ("WeaponType" in ::Const.Items);
	local WT = hasWT ? ::Const.Items.WeaponType : null;

	if ((hasWT && ("Firearm" in WT) && _item.isWeaponType(WT.Firearm)) || _id.find("gonne") != null || _id.find("gun") != null)
		return ["wx_wpn_gun_02", "ranged"];
	if ((hasWT && ("Crossbow" in WT) && _item.isWeaponType(WT.Crossbow)) || _id.find("crossbow") != null || _id.find("impaler") != null)
		return ["wx_wpn_xbow_02", "ranged"];
	if ((hasWT && ("Bow" in WT) && _item.isWeaponType(WT.Bow)) || _id.find("bow") != null)
		return ["wx_wpn_bow_02", "ranged"];
	if ((hasWT && ("Throwing" in WT) && _item.isWeaponType(WT.Throwing)) || _id.find("javelin") != null || _id.find("sling") != null || _id.find("bola") != null)
		return ["wx_wpn_throw_01", "ranged"];
	if ((hasWT && ("Dagger" in WT) && _item.isWeaponType(WT.Dagger)) || _id.find("dagger") != null || _id.find("knife") != null)
		return ["wx_wpn_dagger_03", "melee"];
	if ((hasWT && ("Flail" in WT) && _item.isWeaponType(WT.Flail)) || _id.find("flail") != null || _id.find("whip") != null || _id.find("chain") != null)
		return is2H ? ["wx_wpn_flail_02", "melee"] : ["wx_wpn_whip_02", "melee"];
	if ((hasWT && ("Cleaver" in WT) && _item.isWeaponType(WT.Cleaver)) || _id.find("cleaver") != null || _id.find("scimitar") != null || _id.find("khopesh") != null)
		return is2H ? ["wx_wpn_saber_08", "melee"] : ["wx_wpn_saber_04", "melee"];
	if ((hasWT && ("Sword" in WT) && _item.isWeaponType(WT.Sword)) || _id.find("sword") != null || _id.find("falchion") != null || _id.find("shamshir") != null || _id.find("warbrand") != null)
		return is2H ? ["wx_wpn_sword_07", "melee"] : ["wx_wpn_sword_04", "melee"];
	if ((hasWT && ("Polearm" in WT) && _item.isWeaponType(WT.Polearm)) || _id.find("pike") != null || _id.find("bill") != null || _id.find("scythe") != null || _id.find("lance") != null || _id.find("banner") != null)
		return ["wx_wpn_pole_06", "melee"];
	if ((hasWT && ("Spear" in WT) && _item.isWeaponType(WT.Spear)) || _id.find("spear") != null || _id.find("spetum") != null)
		return is2H ? ["wx_wpn_spear_07", "melee"] : ["wx_wpn_spear_04", "melee"];
	if ((hasWT && ("Axe" in WT) && _item.isWeaponType(WT.Axe)) || _id.find("axe") != null || _id.find("bardiche") != null)
		return is2H ? ["wx_wpn_axe_07", "melee"] : ["wx_wpn_axe_03", "melee"];
	if ((hasWT && ("Hammer" in WT) && _item.isWeaponType(WT.Hammer)) || _id.find("hammer") != null || _id.find("pick") != null)
		return is2H ? ["wx_wpn_hammer_07", "melee"] : ["wx_wpn_hammer_03", "melee"];
	if ((hasWT && ("Mace" in WT) && _item.isWeaponType(WT.Mace)) || _id.find("mace") != null || _id.find("club") != null || _id.find("bludgeon") != null)
		return is2H ? ["wx_wpn_staff_08", "melee"] : ["wx_wpn_hammer_04", "melee"];
	return is2H ? ["wx_wpn_staff_06", "melee"] : ["wx_wpn_sword_03", "melee"];
};

::Wuxia.Armory.applyWuxiaItemDescription <- function( _item, _id, _assetKey, _isNamed = false )
{
	if (_item == null || !::Wuxia.Appearance.hasMember(_item, "m")) return;
	local prefix = _isNamed ? "百炼传世名匠呕心千锤之作。" : "";

	if (_id.find("tool.") == 0 || _id.find("_bomb") != null || _id.find("_flask") != null || _id.find("holy_water") != null)
	{
		if (_id.find("net") != null)
			_item.m.Description = "以桐油浸韧牛筋编结、四角缀精铁铅坠的奇门锁兽网，掷出即可困缚强敌身法。";
		else if (_id.find("fire_bomb") != null)
			_item.m.Description = "内填猛火油与硝磺铁砂的霹雳堂陶壳雷火弹，掷地烈焰翻腾，专破密集军阵。";
		else if (_id.find("smoke_bomb") != null)
			_item.m.Description = "唐门秘配五云迷烟弹，击碎后浓烟蔽目，可助同袍遮蔽敌矢、从容脱身变阵。";
		else if (_id.find("daze_bomb") != null)
			_item.m.Description = "生铁薄壳密装银粉惊雷药的震天弹，轰鸣炫目，令周遭敌手心神俱震、真气涣散。";
		else if (_id.find("acid_flask") != null)
			_item.m.Description = "南疆五毒教以百虫腐骨水封存的琉璃毒瓶，泼洒即蚀透重铁甲胄。";
		else
			_item.m.Description = "净坛朱砂与纯阳符水封存的驱邪宝瓶，泼中尸傀妖物如沸汤泼雪。";
		return;
	}

	if (_id.find("ammo.") == 0)
	{
		if (_id.find("powder") != null)
			_item.m.Description = "油纸防潮密封的颗粒黑火药与铅铁铳子囊，供神机火铳临阵装填轰击。";
		else if (_id.find("bolt") != null)
			_item.m.Description = "三棱破甲钢簇配硬木短杆的机括弩矢匣，专供踏张铁弩与连珠弩攒射。";
		else
			_item.m.Description = "精选雕翎白桦箭杆配百炼透甲铁簇的箭囊，供各路弓手挽弓远射。";
		return;
	}

	if (_id.find("weapon.") == 0)
	{
		local ak = _assetKey != null ? _assetKey : "";
		if (ak.find("wx_wpn_sword_") == 0)
			_item.m.Description = prefix + "剑身中正修长、双刃霜寒的百炼利剑，轻灵迅捷、进退有度，最合剑宗外功路数。";
		else if (ak.find("wx_wpn_saber_") == 0)
			_item.m.Description = prefix + "背厚刃薄、劈砍势大力沉的江湖快刀，斩肉断筋极易令敌血如泉涌。";
		else if (ak.find("wx_wpn_spear_") == 0)
			_item.m.Description = prefix + "韧木长杆配寒铁枪尖的百兵之王，中宫直刺、拒敌先机，善于固守阵线要冲。";
		else if (ak.find("wx_wpn_pole_") == 0)
			_item.m.Description = prefix + "长杆重刃兼备的军阵长兵，隔阵横扫或钩劈破盾皆具雷霆威势。";
		else if (ak.find("wx_wpn_staff_") == 0)
			_item.m.Description = prefix + "沉实坚韧的内家棍杖，扫砸封架浑然一体，劲透重甲极易震慑敌手经脉。";
		else if (ak.find("wx_wpn_hammer_") == 0)
			_item.m.Description = prefix + "千钧沉铁铸就的破甲锤锏，专为粉碎重装铁甲与前朝机关铜骨而生。";
		else if (ak.find("wx_wpn_axe_") == 0)
			_item.m.Description = prefix + "刃口刚猛厚重的劈山战斧，势若开山裂石，碎盾破甲尤为凶悍。";
		else if (ak.find("wx_wpn_dagger_") == 0)
			_item.m.Description = prefix + "寸铁藏锋、贴身夺命的寒铁短匕，善于寻隙刺入甲叶缝隙直取要害。";
		else if (ak.find("wx_wpn_whip_") == 0 || ak.find("wx_wpn_flail_") == 0)
			_item.m.Description = prefix + "刚柔并济的奇门软鞭链枷，劲力诡谲难测，可绕过藤牌铁盾直击敌首。";
		else if (ak.find("wx_wpn_bow_") == 0)
			_item.m.Description = prefix + "桑木角筋层叠胶合的良弓，挽满如月、箭出如流星赶月。";
		else if (ak.find("wx_wpn_xbow_") == 0)
			_item.m.Description = prefix + "机括精密、劲力刚猛的破甲劲弩，纵是重甲悍卒近身亦难挡一矢之威。";
		else if (ak.find("wx_wpn_gun_") == 0)
			_item.m.Description = prefix + "神机营秘铸火绳铁铳，铅砂雷火齐发，轰击密集敌阵声震百步。";
		else
			_item.m.Description = prefix + "便于随身扣发的江湖投掷暗器，近距离出手劲急狠辣、破盾透甲。";
		return;
	}

	if (_id.find("shield.") == 0)
	{
		if (_assetKey == "wx_shd_02" || _assetKey == "wx_shd_03")
			_item.m.Description = prefix + "老藤浸桐油密编而成的轻便藤牌，韧而不折，格挡箭矢刀剑极为灵便。";
		else
			_item.m.Description = prefix + "精铁包镶、护心稳固的军阵重盾，立盾守线可为同袍撑起铜墙铁壁。";
		return;
	}

	if (_id.find("armor.body.") == 0)
	{
		local cMax = ::Wuxia.Appearance.hasMember(_item.m, "ConditionMax") ? _item.m.ConditionMax : 80;
		if (cMax <= 95)
			_item.m.Description = prefix + "剪裁利落、便于提气纵跃的江湖劲装袍服，不滞内息流转，契合轻装卸力身法。";
		else if (cMax <= 195)
			_item.m.Description = prefix + "内衬熟革、外缀精铁甲叶的武林实战战袄，兼顾刀剑防护与行气灵便。";
		else
			_item.m.Description = prefix + "甲叶层叠严密的百炼重甲，刀箭难伤；若辅以横练『披甲行气』更能发挥千钧守御之威。";
		return;
	}

	if (_id.find("armor.head.") == 0)
	{
		local hcMax = ::Wuxia.Appearance.hasMember(_item.m, "ConditionMax") ? _item.m.ConditionMax : 70;
		if (hcMax <= 85)
			_item.m.Description = prefix + "遮阳避雨而不掩耳目听风辨位的江湖冠笠巾帻，轻灵潇洒。";
		else if (hcMax <= 185)
			_item.m.Description = prefix + "精铁护额、内衬软毡的制式战笠兜鍪，稳护天灵要穴而不大碍视野。";
		else
			_item.m.Description = prefix + "覆面护颈俱全的乌钢重型铁胄，坚不可摧，可御重锤强弩当头猛击。";
		return;
	}

	if (_id.find("accessory.") == 0)
	{
		_item.m.Description = "江湖豪客随身佩挂的奇门信物与护身佩饰，兼具定神醒脑或增益战力之效。";
		return;
	}

	if (_id.find("armor_upgrade.") == 0)
	{
		_item.m.Description = "可披挂镶缀于身甲之上的百工护具披风，右键使用即可与护甲融为一体。";
		return;
	}
};

::Wuxia.Armory.applyWeaponVisualSpec <- function( _item, _id, _wid, _sub, _newNameOrNull )
{
	if (_newNameOrNull != null) _item.m.Name = _newNameOrNull;
	local isNamed = ::Wuxia.Appearance.hasMember(_item, "isItemType") && ("Const" in getroottable()) && _item.isItemType(::Const.Items.ItemType.Named);
	::Wuxia.Armory.applyWuxiaItemDescription(_item, _id, _wid, isNamed);
	local iconSm = "weapons/" + _sub + "/" + _wid + "_70x70.png";
	local iconLg = "weapons/" + _sub + "/" + _wid + ".png";
	local armBrush = "arm_" + _wid;
	_item.m.Icon = iconSm;
	_item.m.IconLarge = iconLg;
	_item.m.ShowArmamentIcon = true;
	// Crossbows append `_unloaded` to `m.ArmamentIcon` inside vanilla `crossbow.updateAppearance()`,
	// so keep `m.ArmamentIcon` vanilla on crossbows while overriding `arms_icon` via `WX_ArmBrush`!
	if (!::Wuxia.Armory.isCrossbowItem(_item, _id))
	{
		_item.m.ArmamentIcon = armBrush;
	}
	_item.m.WX_ArmBrush <- armBrush;
	_item.m.WX_MappedID <- _id;
	_item.m.WX_ExpectedIcon <- iconSm;
};

::Wuxia.Armory.ensureItemMapped <- function( _item, _force = false )
{
	if (_item == null || !::Wuxia.Appearance.hasMember(_item, "m") || !::Wuxia.Appearance.hasMember(_item, "getID")) return;
	if ("BeastCraft" in ::Wuxia && "bindTraitMethods" in ::Wuxia.BeastCraft)
		::Wuxia.BeastCraft.bindTraitMethods(_item);

	local id = _item.getID();
	if (id == null || id == "") return; // Still inside base create() before child assigns ID

	local curIcon = (::Wuxia.Appearance.hasMember(_item.m, "Icon") && _item.m.Icon != null) ? _item.m.Icon : "";
	if (!_force && ("WX_MappedID" in _item.m) && _item.m.WX_MappedID == id && ("WX_ExpectedIcon" in _item.m) && curIcon == _item.m.WX_ExpectedIcon)
		return;

	// Never overwrite our custom Wuxia relics, fists, named fists, pills, manuals, Shan Hai gear, or War Banners (`wx_world_visuals_system.nut`)!
	if (id == "weapon.player_banner" || id == "weapon.faction_banner")
	{
		_item.m.WX_MappedID <- id;
		_item.m.WX_ExpectedIcon <- curIcon;
		return;
	}
	if (id.find(".wx_") != null || id.find("wx_") == 0)
	{
		if (id.find("weapon.wx_") == 0 && !("WX_ArmBrush" in _item.m) && ::Wuxia.Appearance.hasMember(_item.m, "ArmamentIcon") && _item.m.ArmamentIcon != "")
		{
			_item.m.WX_ArmBrush <- _item.m.ArmamentIcon;
		}
		_item.m.WX_MappedID <- id;
		_item.m.WX_ExpectedIcon <- curIcon;
		return;
	}

	local isNamed = ::Wuxia.Appearance.hasMember(_item, "isItemType") && ("Const" in getroottable()) && _item.isItemType(::Const.Items.ItemType.Named);

	// 1. Offhand Tools, Throwing Nets & Tactical Bombs/Flasks (`tool.*` and `weapon.*_bomb/*_flask/holy_water` — MUST precede `weapon.*` fallback!)
	if (id in ::Wuxia.Armory.ToolMap)
	{
		local tEntry = ::Wuxia.Armory.ToolMap[id];
		_item.m.Icon = tEntry[0];
		_item.m.IconLarge = tEntry[1];
		_item.m.ShowArmamentIcon = false;
		if (tEntry[2] != null) _item.m.WX_ShieldBrush <- tEntry[2];
		if (!isNamed && tEntry[3] != null) _item.m.Name = tEntry[3];
		::Wuxia.Armory.applyWuxiaItemDescription(_item, id, tEntry[2], isNamed);
		_item.m.WX_MappedID <- id;
		_item.m.WX_ExpectedIcon <- tEntry[0];
		return;
	}

	// 2. Ammunition Quivers, Bolt Cases & Powder Bags (`ammo.*`)
	if (id in ::Wuxia.Armory.AmmoMap)
	{
		local amEntry = ::Wuxia.Armory.AmmoMap[id];
		_item.m.Icon = amEntry[0];
		if (!isNamed && amEntry[1] != null) _item.m.Name = amEntry[1];
		::Wuxia.Armory.applyWuxiaItemDescription(_item, id, amEntry[0], isNamed);
		_item.m.WX_MappedID <- id;
		_item.m.WX_ExpectedIcon <- amEntry[0];
		return;
	}
	if (id.find("ammo.") == 0 && curIcon != "")
	{
		local amIcon = (id.find("bolt") != null) ? "ammo/wx_ammo_bolts.png"
			: ((id.find("powder") != null) ? "ammo/wx_ammo_powder.png" : "ammo/wx_ammo_arrows.png");
		_item.m.Icon = amIcon;
		::Wuxia.Armory.applyWuxiaItemDescription(_item, id, amIcon, isNamed);
		_item.m.WX_MappedID <- id;
		_item.m.WX_ExpectedIcon <- amIcon;
		return;
	}

	// 3. Weapons (`weapon.*`) — Base, DLC, Named Famed & Universal Category Fallback
	if (id in ::Wuxia.Armory.WeaponMap)
	{
		local wEntry = ::Wuxia.Armory.WeaponMap[id];
		::Wuxia.Armory.applyWeaponVisualSpec(_item, id, wEntry[0], wEntry[1], isNamed ? null : wEntry[2]);
		return;
	}
	if (id in ::Wuxia.Armory.NamedWeaponMap)
	{
		local nwEntry = ::Wuxia.Armory.NamedWeaponMap[id];
		::Wuxia.Armory.applyWeaponVisualSpec(_item, id, nwEntry[0], nwEntry[1], null);
		return;
	}
	if (id.find("weapon.") == 0 && curIcon != "" && !::Wuxia.Armory.isNaturalMonsterAttack(id))
	{
		local fbSpec = ::Wuxia.Armory.resolveFallbackWeaponSpec(_item, id);
		::Wuxia.Armory.applyWeaponVisualSpec(_item, id, fbSpec[0], fbSpec[1], null);
		return;
	}

	// 3. Shields (`shield.*`)
	if (id in ::Wuxia.Armory.ShieldMap)
	{
		local sEntry = ::Wuxia.Armory.ShieldMap[id];
		local sid = sEntry[0];
		if (!isNamed) _item.m.Name = sEntry[1];
		::Wuxia.Armory.applyWuxiaItemDescription(_item, id, sid, isNamed);
		local sIcon = "shields/" + sid + "_70x70.png";
		_item.m.Icon = sIcon;
		_item.m.IconLarge = "shields/" + sid + ".png";
		_item.m.WX_ShieldBrush <- "shd_" + sid;
		_item.m.WX_MappedID <- id;
		_item.m.WX_ExpectedIcon <- sIcon;
		return;
	}
	if (id.find("shield.") == 0 && curIcon != "" && !::Wuxia.Armory.isNaturalMonsterAttack(id))
	{
		local famedPool = ["wx_shd_06", "wx_shd_09", "wx_shd_10", "wx_shd_12"];
		local sid2 = isNamed
			? famedPool[::Wuxia.Armory.hashString(id) % famedPool.len()]
			: ("wx_shd_" + ::Wuxia.Appearance.pad2(1 + (::Wuxia.Armory.hashString(id) % 12)));
		::Wuxia.Armory.applyWuxiaItemDescription(_item, id, sid2, isNamed);
		local sIcon2 = "shields/" + sid2 + "_70x70.png";
		_item.m.Icon = sIcon2;
		_item.m.IconLarge = "shields/" + sid2 + ".png";
		_item.m.WX_ShieldBrush <- "shd_" + sid2;
		_item.m.WX_MappedID <- id;
		_item.m.WX_ExpectedIcon <- sIcon2;
		return;
	}

	// 4. Body Robes & Armors (`armor.body.*`)
	if (id in ::Wuxia.Armory.ArmorMap)
	{
		local aEntry = ::Wuxia.Armory.ArmorMap[id];
		local aid = aEntry[0];
		if (!isNamed) _item.m.Name = aEntry[1];
		::Wuxia.Armory.applyWuxiaItemDescription(_item, id, aid, isNamed);
		local aIcon = "armor/" + aid + "_70x70.png";
		_item.m.Icon = aIcon;
		_item.m.IconLarge = "armor/" + aid + ".png";
		_item.m.WX_BodyBrush <- aid;
		_item.m.WX_MappedID <- id;
		_item.m.WX_ExpectedIcon <- aIcon;
		return;
	}
	if (id.find("armor.body.") == 0 && curIcon != "" && !::Wuxia.Armory.isNaturalMonsterAttack(id))
	{
		local cMax = ::Wuxia.Appearance.hasMember(_item.m, "ConditionMax") ? _item.m.ConditionMax : 80;
		local pool = cMax <= 55 ? ::Wuxia.Armory.FallbackCivBodies
			: (cMax <= 115 ? ::Wuxia.Armory.FallbackSectBodies
			: (cMax <= 210 ? ::Wuxia.Armory.FallbackArmBodies : ::Wuxia.Armory.FallbackHvyBodies));
		local pickA = pool[::Wuxia.Armory.hashString(id) % pool.len()];
		::Wuxia.Armory.applyWuxiaItemDescription(_item, id, pickA, isNamed);
		local aIcon2 = "armor/" + pickA + "_70x70.png";
		_item.m.Icon = aIcon2;
		_item.m.IconLarge = "armor/" + pickA + ".png";
		_item.m.WX_BodyBrush <- pickA;
		_item.m.WX_MappedID <- id;
		_item.m.WX_ExpectedIcon <- aIcon2;
		return;
	}

	// 5. Hats, Crowns, Masks & Helmets (`armor.head.*`)
	if (id in ::Wuxia.Armory.HelmetMap)
	{
		local hEntry = ::Wuxia.Armory.HelmetMap[id];
		local hid = hEntry[0];
		if (!isNamed) _item.m.Name = hEntry[1];
		::Wuxia.Armory.applyWuxiaItemDescription(_item, id, hid, isNamed);
		local hIcon = "helmets/" + hid + ".png";
		_item.m.Icon = hIcon;
		_item.m.WX_HatID <- hid;
		_item.m.WX_HatFrontBrush <- hid + "_front";
		_item.m.WX_HatBackBrush <- hid + "_back";
		_item.m.WX_MappedID <- id;
		_item.m.WX_ExpectedIcon <- hIcon;
		return;
	}
	if (id.find("armor.head.") == 0 && curIcon != "" && !::Wuxia.Armory.isNaturalMonsterAttack(id))
	{
		local hcMax = ::Wuxia.Appearance.hasMember(_item.m, "ConditionMax") ? _item.m.ConditionMax : 70;
		local hPool = hcMax <= 65 ? ::Wuxia.Armory.FallbackLightHats
			: (hcMax <= 175 ? ::Wuxia.Armory.FallbackMedHats : ::Wuxia.Armory.FallbackHvyHats);
		local pickH = hPool[::Wuxia.Armory.hashString(id) % hPool.len()];
		::Wuxia.Armory.applyWuxiaItemDescription(_item, id, pickH, isNamed);
		local hIcon2 = "helmets/" + pickH + ".png";
		_item.m.Icon = hIcon2;
		_item.m.WX_HatID <- pickH;
		_item.m.WX_HatFrontBrush <- pickH + "_front";
		_item.m.WX_HatBackBrush <- pickH + "_back";
		_item.m.WX_MappedID <- id;
		_item.m.WX_ExpectedIcon <- hIcon2;
		return;
	}

	// 6. Non-pet Accessories (`accessory.*`) & Armor Attachments (`armor_upgrade.*`)
	if (id in ::Wuxia.Armory.AccessoryMap)
	{
		local accEntry = ::Wuxia.Armory.AccessoryMap[id];
		local accIcon = "accessory/" + accEntry[0] + ".png";
		_item.m.Icon = accIcon;
		if (!isNamed && accEntry[1] != null) _item.m.Name = accEntry[1];
		::Wuxia.Armory.applyWuxiaItemDescription(_item, id, accEntry[0], isNamed);
		_item.m.WX_MappedID <- id;
		_item.m.WX_ExpectedIcon <- accIcon;
		return;
	}
	if ("Appearance" in ::Wuxia.Config && "ArmorUpgradeMap" in ::Wuxia.Config.Appearance && (id in ::Wuxia.Config.Appearance.ArmorUpgradeMap))
	{
		local upEntry = ::Wuxia.Config.Appearance.ArmorUpgradeMap[id];
		local upIcon0 = "armor_upgrades/" + upEntry[0] + ".png";
		_item.m.Icon = upIcon0;
		_item.m.OverlayIcon = "";
		_item.m.OverlayIconLarge = "";
		if (!isNamed && upEntry[1] != null) _item.m.Name = upEntry[1];
		::Wuxia.Armory.applyWuxiaItemDescription(_item, id, upEntry[0], isNamed);
		_item.m.WX_BackBrush <- upEntry[0];
		_item.m.WX_MappedID <- id;
		_item.m.WX_ExpectedIcon <- upIcon0;
		return;
	}
	if (id.find("armor_upgrade.") == 0 && curIcon != "")
	{
		local idxU = 1 + (::Wuxia.Armory.hashString(id) % 16);
		local bkBrush = "wx_back_" + ::Wuxia.Appearance.pad2(idxU);
		local upIcon = "armor_upgrades/" + bkBrush + ".png";
		_item.m.Icon = upIcon;
		_item.m.OverlayIcon = "";
		_item.m.OverlayIconLarge = "";
		::Wuxia.Armory.applyWuxiaItemDescription(_item, id, bkBrush, isNamed);
		_item.m.WX_BackBrush <- bkBrush;
		_item.m.WX_MappedID <- id;
		_item.m.WX_ExpectedIcon <- upIcon;
		return;
	}

	_item.m.WX_MappedID <- id;
	_item.m.WX_ExpectedIcon <- curIcon;
};

::Wuxia.Armory.ensureUpgradeMapped <- function( _upgrade )
{
	::Wuxia.Armory.ensureItemMapped(_upgrade);
};

::Wuxia.Armory.ensureArmorMapped <- function( _armor )
{
	::Wuxia.Armory.ensureItemMapped(_armor);
};

::Wuxia.Armory.ensureHelmetMapped <- function( _helmet )
{
	::Wuxia.Armory.ensureItemMapped(_helmet);
};

::Wuxia.Armory.syncItemOwnerActor <- function( _item )
{
	if (_item == null || !::Wuxia.Appearance.hasMember(_item, "getContainer")) return;
	local cont = _item.getContainer();
	if (cont == null || !::Wuxia.Appearance.hasMember(cont, "getActor")) return;
	local actor = cont.getActor();
	if (actor != null) ::Wuxia.Armory.syncActorHandheldAndArmor(actor);
};

::Wuxia.Armory.syncActorHandheldAndArmor <- function( _actor )
{
	if (_actor == null || !::Wuxia.Appearance.hasMember(_actor, "m")) return;
	if ("WX_SyncingAppearance" in _actor.m && _actor.m.WX_SyncingAppearance) return;
	if (!::Wuxia.Appearance.hasMember(_actor, "hasSprite") || !::Wuxia.Appearance.hasMember(_actor, "getItems")) return;
	if (::Wuxia.Appearance.hasMember(_actor, "isAlive") && !_actor.isAlive()) return;

	_actor.m.WX_SyncingAppearance <- true;
	try
	{
		local items = _actor.getItems();
		if (items == null)
		{
			_actor.m.WX_SyncingAppearance = false;
			return;
		}

		local mainItem = items.getItemAtSlot(::Const.ItemSlot.Mainhand);
		local offItem  = items.getItemAtSlot(::Const.ItemSlot.Offhand);
		local bodyItem = items.getItemAtSlot(::Const.ItemSlot.Body);
		local headItem = items.getItemAtSlot(::Const.ItemSlot.Head);

		if (mainItem != null) ::Wuxia.Armory.ensureItemMapped(mainItem);
		if (offItem != null)  ::Wuxia.Armory.ensureItemMapped(offItem);
		if (bodyItem != null) ::Wuxia.Armory.ensureItemMapped(bodyItem);
		if (headItem != null) ::Wuxia.Armory.ensureItemMapped(headItem);

		local changed = false;

		// Bespoke hand-painted enemy busts already include their signature weapon/pose!
		if ("WX_CustomEnemyBust" in _actor.m && _actor.m.WX_CustomEnemyBust != null)
		{
			if (::Wuxia.Appearance.applyCustomEnemyBust(_actor, _actor.m.WX_CustomEnemyBust, true)) changed = true;
			if (::Wuxia.Appearance.hideSpriteIfVisible(_actor, "arms_icon")) changed = true;
			if (::Wuxia.Appearance.hideSpriteIfVisible(_actor, "shield_icon")) changed = true;
			if (changed && ::Wuxia.Appearance.hasMember(_actor, "setDirty")) _actor.setDirty(true);
			_actor.m.WX_SyncingAppearance = false;
			return;
		}

		if (!::Wuxia.Appearance.isEligibleHumanActor(_actor))
		{
			_actor.m.WX_SyncingAppearance = false;
			return;
		}

		// Refresh 1000-Faces human layers + boolean hair/hat_back/hat_front/beard/body interlock (deferred dirty!)
		if (::Wuxia.Appearance.refreshActorSprites(_actor, true)) changed = true;

		local white = ::Wuxia.Appearance.getWhiteColor();
		local inSpinFlip = (("WX_Motion" in _actor.m) && _actor.m.WX_Motion != null && _actor.m.WX_Motion.flippedTemp);
		local hasTacFlip = (!inSpinFlip && "Tactical" in getroottable() && ::Tactical != null && ::Tactical.isActive() && ::Wuxia.Appearance.hasMember(_actor, "isAlliedWithPlayer"));
		local tacFlip = hasTacFlip ? !_actor.isAlliedWithPlayer() : false;

		// Apply or clear paperdoll handheld weapon (`wx_weapons_0.brush` -> `arm_*`)
		if (_actor.hasSprite("arms_icon"))
		{
			local sprArm = _actor.getSprite("arms_icon");
			local armBrush = (mainItem != null && ("WX_ArmBrush" in mainItem.m)) ? mainItem.m.WX_ArmBrush : null;
			local showArm = (mainItem != null && armBrush != null && (!::Wuxia.Appearance.hasMember(mainItem.m, "ShowArmamentIcon") || mainItem.m.ShowArmamentIcon));
			if (showArm && (!("doesBrushExist" in getroottable()) || ::doesBrushExist(armBrush)))
			{
				if (::Wuxia.Appearance.applySpriteIfChanged(sprArm, armBrush, white)) changed = true;
				if (hasTacFlip && ::Wuxia.Appearance.setFlipIfChanged(sprArm, tacFlip)) changed = true;
			}
			else if ((mainItem == null || !::Wuxia.Appearance.hasMember(mainItem.m, "ShowArmamentIcon") || !mainItem.m.ShowArmamentIcon) && sprArm.Visible)
			{
				sprArm.Visible = false;
				changed = true;
			}
		}

		// Apply or clear paperdoll offhand shield / net (`wx_weapons_0.brush` -> `shd_*`)
		if (_actor.hasSprite("shield_icon"))
		{
			local sprShd = _actor.getSprite("shield_icon");
			local shdBrush = (offItem != null && ("WX_ShieldBrush" in offItem.m)) ? offItem.m.WX_ShieldBrush : null;
			local offCond = (offItem != null)
				? (::Wuxia.Appearance.hasMember(offItem, "getCondition") ? offItem.getCondition() : (::Wuxia.Appearance.hasMember(offItem.m, "Condition") ? offItem.m.Condition : 1))
				: 0;
			if (shdBrush != null && offCond > 0 && (!("doesBrushExist" in getroottable()) || ::doesBrushExist(shdBrush)))
			{
				if (::Wuxia.Appearance.applySpriteIfChanged(sprShd, shdBrush, white)) changed = true;
				if (hasTacFlip && ::Wuxia.Appearance.setFlipIfChanged(sprShd, tacFlip)) changed = true;
			}
			else if ((offItem == null || offCond <= 0 || shdBrush == null) && sprShd.Visible)
			{
				sprShd.Visible = false;
				changed = true;
			}
		}

		// Finalize dirty state ONLY if at least one visual layer actually changed (prevents per-hit/per-cast portrait FBO stalls!)
		if (changed && ::Wuxia.Appearance.hasMember(_actor, "setDirty"))
		{
			_actor.setDirty(true);
		}
	}
	catch (err)
	{
		_actor.m.WX_SyncingAppearance = false;
		throw err;
	}
	_actor.m.WX_SyncingAppearance = false;
};

// 1. Hook base item getters & deserialization so shops, stashes, tooltips & saves always see Wuxia icons & names
::Wuxia.HooksMod.hook("scripts/items/item", function( q )
{
	q.getName = @(__original) function()
	{
		::Wuxia.Armory.ensureItemMapped(this);
		if ("Purify" in ::Wuxia) ::Wuxia.Purify.applyItemText(this);
		return __original();
	};

	if (::Wuxia.qHas(q, "getDescription"))
	{
		q.getDescription = @(__original) function()
		{
			::Wuxia.Armory.ensureItemMapped(this);
			if ("Purify" in ::Wuxia) ::Wuxia.Purify.applyItemText(this);
			return __original();
		};
	}

	q.getIcon = @(__original) function()
	{
		::Wuxia.Armory.ensureItemMapped(this);
		return __original();
	};

	q.getIconLarge = @(__original) function()
	{
		::Wuxia.Armory.ensureItemMapped(this);
		return __original();
	};

	q.onDeserialize = @(__original) function( _in )
	{
		__original(_in);
		::Wuxia.Armory.ensureItemMapped(this, true);
	};
});

// 2. Hook weapon, shield, armor & helmet `updateVariant` and `updateAppearance` so variant rolls,
//    faction painting, repairs, attachments & mid-combat durability hits NEVER revert to medieval art!
::Wuxia.HooksMod.hook("scripts/items/weapons/weapon", function( q )
{
	q.updateVariant = @(__original) function()
	{
		__original();
		::Wuxia.Armory.ensureItemMapped(this, true);
	};

	q.updateAppearance = @(__original) function()
	{
		::Wuxia.Armory.ensureItemMapped(this);
		__original();
		::Wuxia.Armory.syncItemOwnerActor(this);
	};
});

::Wuxia.HooksMod.hook("scripts/items/shields/shield", function( q )
{
	q.updateVariant = @(__original) function()
	{
		__original();
		::Wuxia.Armory.ensureItemMapped(this, true);
	};

	q.updateAppearance = @(__original) function()
	{
		::Wuxia.Armory.ensureItemMapped(this);
		__original();
		::Wuxia.Armory.syncItemOwnerActor(this);
	};
});

::Wuxia.HooksMod.hook("scripts/items/armor/armor", function( q )
{
	q.updateVariant = @(__original) function()
	{
		__original();
		::Wuxia.Armory.ensureItemMapped(this, true);
	};

	q.updateAppearance = @(__original) function()
	{
		::Wuxia.Armory.ensureItemMapped(this);
		__original();
		::Wuxia.Armory.syncItemOwnerActor(this);
	};

	q.setUpgrade = @(__original) function( _upgrade )
	{
		if (_upgrade != null) ::Wuxia.Armory.ensureItemMapped(_upgrade, true);
		__original(_upgrade);
		::Wuxia.Armory.ensureItemMapped(this, true);
		::Wuxia.Armory.syncItemOwnerActor(this);
	};
});

::Wuxia.HooksMod.hook("scripts/items/helmets/helmet", function( q )
{
	q.updateVariant = @(__original) function()
	{
		__original();
		::Wuxia.Armory.ensureItemMapped(this, true);
	};

	q.updateAppearance = @(__original) function()
	{
		::Wuxia.Armory.ensureItemMapped(this);
		__original();
		::Wuxia.Armory.syncItemOwnerActor(this);
	};
});

// 3. Hook item_container so equipping, unequipping, or updating appearance syncs paperdoll layers cleanly
::Wuxia.HooksMod.hook("scripts/items/item_container", function( q )
{
	q.updateAppearance = @(__original) function()
	{
		__original();
		::Wuxia.Armory.syncActorHandheldAndArmor(this.getActor());
	};

	q.equip = @(__original) function( _item )
	{
		if (_item != null) ::Wuxia.Armory.ensureItemMapped(_item);
		local res = __original(_item);
		::Wuxia.Armory.syncActorHandheldAndArmor(this.getActor());
		return res;
	};

	q.unequip = @(__original) function( _item )
	{
		local res = __original(_item);
		::Wuxia.Armory.syncActorHandheldAndArmor(this.getActor());
		return res;
	};
});

// 4. Hook `scripts/entity/tactical/human` (`onAppearanceChanged`, `onFactionChanged`, `onCombatStart`, `onCombatFinished`)
//    so EVERY human actor (roster brothers, town hire candidates, event previews & human enemies) stays 100% Wuxia!
::Wuxia.HooksMod.hook("scripts/entity/tactical/human", function( q )
{
	q.onAppearanceChanged = @(__original) function( _appearance, _setDirty = true )
	{
		__original(_appearance, _setDirty);
		::Wuxia.Armory.syncActorHandheldAndArmor(this);
	};

	q.onFactionChanged = @(__original) function()
	{
		__original();
		::Wuxia.Armory.syncActorHandheldAndArmor(this);
	};
});
