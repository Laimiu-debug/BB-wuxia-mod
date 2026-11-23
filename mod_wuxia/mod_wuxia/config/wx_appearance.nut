// Stage 3 (`3_characters`) Declarative 1000-Faces Modular Paperdoll & Enemy Bust Configuration
// Referenced by `art/manifest.json` (`mod_wuxia/mod_wuxia/config/wx_appearance.nut`).
// Covers:
//   - 48 Wuxia faces (`wx_head_01..32` male + `wx_head_33..48` female heroines)
//   - 25 hair states (`0` shaved + `wx_hair_01..24` & `wx_hair_01..24_tucked`) x 4 tones (`乌墨黑/风霜褐/两鬓霜灰/鹤发银白`)
//   - 25 beard states (`0` clean-shaven + `wx_beard_01..24`) x 4 tones
//   - 13 facial scar/mark/eyepatch overlays (`0` unscarred + `wx_scar_01..12`) + permanent injury auto-mapping
//   - 17 back cloak/sword-box/gourd/banner/pelt overlays (`0` none + `wx_back_01..16`) + vanilla `armor_upgrade.*` remapping
//   - 72-background authentic Jianghu appearance presets + female heroine name pool
//   - Complete 50-bust bespoke enemy mapping (`wx_enemy_*` & `wx_char_enemy_*`) + human faction presets

::Wuxia.Config.Appearance <- {
	FaceLabels = [
		"自动相貌",
		"俊朗剑眉少侠面", "方颐阔口壮汉面", "独眼纵疤悍匪面", "饱经风霜老镖头面",
		"白面清冷儒生面", "高颧古铜塞外汉面", "鹰钩鼻阴鸷刺客面", "慈眉善目老衲面",
		"清癯孤高道骨面", "黝黑敦厚庄稼汉面", "酒糟红鼻醉侠面", "拧眉横肉恶霸面",
		"丹凤狭目冷探面", "惨青病容试毒师面", "浓眉国字威严将面", "枯槁灰白邪修面",
		"圆脸讨喜店伴面", "浓眉虎目武生面", "高鼻深目西域面", "吊梢眼机灵贼面",
		"宽额煤印铁匠面", "面如冠玉公子面", "日晒紫红水客面", "十字剑疤少侠面",
		"咬牙暴筋狂客面", "睡眼惺忪奇才面", "断鼻淤青拳手面", "薄唇笑面师爷面",
		"颌下双痣相士面", "紫膛阔颌金刚面", "细目鹰视神射面", "大耳敦实军卒面",
		"清冷剑眉峨眉女侠面", "英气明眸镖局少主面", "蜜色高颧塞外女骑面", "泪痣丹凤客栈掌柜面",
		"灵动圆颊小师妹面", "玄纱覆面圣女面", "疤面冷眸女刺客面", "慈威深纹古庵老尼面",
		"碧瞳清冷南疆蛊女面", "朱砂额印刀马旦面", "素雅温婉药谷医女面", "风霜坚韧江海渔妇面",
		"柳眉冷笑黑道女魁面", "端庄清丽书香才女面", "金瞳深目西域胡姬面", "铁面霜眉六扇女捕面"
	],

	HairLabels = [
		"落发光头",
		"红绳劲武高马尾", "狂放披肩乱散发", "斑白道家高挽髻", "头陀铁箍落发式",
		"兽骨横簪浪人髻", "塞外铜环多股辫", "青布束髻书生发", "草绳蓬乱乞儿发",
		"白玉小冠高束墨发", "铜簪半挽披肩长发", "斜绺劲武高扬马尾", "双缕龙须垂鬓剑髻",
		"青皮短茬沙门戒发", "太极木簪圆盘道髻", "寒儒青布方巾束髻", "绛红英雄抹额狂发",
		"盘顶多股精编武髻", "两鬓风霜半束灰发", "怒发冲冠纯白宗师发", "少年双丫总角圆髻",
		"明制马尾网巾齐束发", "落拓浪子歪斜散髻", "翠竹横簪清客中发", "乌金铆铁箍狂狮鬃发"
	],

	HairTones = [
		{ Suffix = "",       Name = "乌墨黑" },
		{ Suffix = "_brown", Name = "风霜褐" },
		{ Suffix = "_grey",  Name = "两鬓霜灰" },
		{ Suffix = "_white", Name = "鹤发银白" }
	],

	BeardLabels = [
		"净面无须",
		"关圣垂胸美髯须", "虬髯豪客张扬须", "精明账房山羊须", "西域浓密卷曲须",
		"仙风霜白长寿须", "铜箍双股铁辫须", "青黑沧桑短胡茬", "连鬓恶虎钢针须",
		"修整雅正八字胡", "豪侠飞扬虎须髭", "细长垂缕八字须", "精干下颌山羊须",
		"剑客八字配尖须", "儒雅束结三绺髯", "卧蚕丹凤垂胸髯", "沧桑连鬓短茬胡",
		"镖头方正浓密髯", "绿林怒张虬髯胡", "塞外双股铁箍辫", "连鬓留口悍刀胡",
		"太和鹤发银白髯", "铁匠花白连鬓髯", "西域赤褐卷曲髯", "宗师银灰飘逸须"
	],

	ScarLabels = [
		"白璧无瑕",
		"横鼻破相刀疤", "贯眉纵目剑痕", "左颊十字剑疤", "黑革独眼皮罩",
		"听风玄布蒙眼带", "刺配青印黥纹", "火药焦灼赤疤", "眉心朱砂剑印",
		"西洋铜框圆目镜", "南疆噬脉青蛊纹", "朔漠血战涂面纹", "裂口横腮凶疤"
	],

	BackLabels = [
		"轻装无负",
		"残血猩红大将披风", "夜鸦墨黑破边短披风", "塞外雪狼厚毛护肩大氅", "背负铜角沉香古木剑匣",
		"背后十字双雁翎刀鞘", "朱漆红绳老酒大葫芦", "神农百草青竹采药背篓", "威远走镖黑底金纹小令旗",
		"节度镇军四面护背大靠旗", "千机百宝牛皮暗器腰肩囊", "少室百八颗碗口紫檀念珠", "朱砂红线百枚古铜钱辟邪剑",
		"寒江棕草防雨护肩蓑披", "吊睛白额猛虎皮英雄披肩", "铁算盘神算子乌金腰挂", "铜箍油皮山川舆图背筒"
	],

	// Open-crown headbands, topknot crowns & half-masks let full `wx_hair_XX` crown rise naturally
	OpenCrownHats = {
		wx_hat_01 = true, wx_hat_09 = true, wx_hat_10 = true, wx_hat_12 = true,
		wx_hat_13 = true, wx_hat_14 = true, wx_hat_15 = true, wx_hat_16 = true,
		wx_hat_17 = true, wx_hat_21 = true, wx_hat_22 = true,
		wx_char_hat_topknot = true, wx_char_hat_taoist = true
	},

	// Full enclosed war helmets / full bronze masks hide hair completely
	HideHairHats = {
		wx_hat_18 = true, wx_hat_23 = true, wx_hat_29 = true, wx_hat_32 = true,
		wx_helm_taotie = true, wx_helm_chiyou = true
	},

	// Lower-face masks / assassin cowls / enclosed faceplates hide beard cleanly
	HideBeardHats = {
		wx_hat_08 = true, wx_hat_17 = true, wx_hat_18 = true, wx_hat_23 = true,
		wx_hat_29 = true
	},

	// Authentic Jianghu heroine names assigned when a newly generated recruit rolls `FaceIdx >= 33`
	FemaleHeroineNames = [
		"顾寒梅", "柳轻鸿", "沈霜竹", "林昭雪", "裴凌薇", "谢红袖", "苏映月", "秦惊鸿",
		"叶晚舟", "萧秋水", "慕容雪", "唐飞燕", "陆青萝", "白凝霜", "楚寒烟", "燕归云",
		"温佩兰", "江素心", "纪凝竹", "霍明珠", "钟灵秀", "曲幽兰", "殷红药", "程灵素",
		"周芷兰", "赵敏仪", "郭襄儿", "何铁手", "水笙儿", "凌霜华", "花弄影", "叶芷青"
	],

	// Permanent facial injury -> automatic Wuxia facial scar/eyepatch overlay when `ScarIdx == 0`
	PermanentInjuryScarMap = [
		["injury.missing_eye",  4],  // 黑革独眼皮罩
		["injury.burned_face",  7],  // 火药焦灼赤疤
		["injury.ripped_ear",   1],  // 横鼻破相刀疤
		["injury.missing_ear",  12], // 裂口横腮凶疤
		["injury.broken_nose",  2]   // 贯眉纵目剑痕
	],

	// Additional Stage-3 `wx_char_*` & `wx_hat_*` item visual mappings merged into `::Wuxia.Armory`
	ExtraArmorMap = {
		["armor.body.noble_tunic"]                       = ["wx_char_robe_swordsman",   "名门潇洒剑客青衫"],
		["armor.body.dark_southern_robe"]                = ["wx_char_robe_taoist",      "玄门紫霄阴阳道袍"],
		["armor.body.southern_robe"]                     = ["wx_char_robe_monk",        "古刹行脚苦行僧衣"],
		["armor.body.ragged_dark_surcoat"]               = ["wx_char_robe_beggar",      "丐帮九袋百衲战衣"],
		["armor.body.wanderers_coat"]                    = ["wx_char_raincape",         "寒江孤舟烟雨蓑衣"],
		["armor.body.patched_mail_shirt"]                = ["wx_char_armor_brigandine", "边军铁叶铆钉布面甲"],
		["armor.body.worn_mail_shirt"]                   = ["wx_char_armor_brigandine", "关外旧战铁叶布面甲"],
		["armor.body.decayed_coat_of_scales"]            = ["wx_char_armor_shanwen",    "前朝古制山文重铁铠"],
		["armor.body.padded_mail_and_lamellar_hauberk"]  = ["wx_char_armor_shanwen",    "藩镇百炼山文重铁铠"],
		["armor.body.southern_long_mail_with_padding"]   = ["wx_char_armor_jinyi",      "内府飞鱼织金曳撒甲"],
		["armor.body.oriental_padded_vest"]              = ["wx_char_armor_wudu",       "南疆五毒百蛊藤皮衣"],
		["armor.body.linothorax"]                        = ["wx_char_cloth_short",      "江湖束腰劲装短打"]
	},

	ExtraHelmetMap = {
		["armor.head.wanderers_hat"]                     = ["wx_char_hat_bamboo",       "侠客潇洒青竹斗笠"],
		["armor.head.hunters_hat"]                       = ["wx_char_hat_bamboo",       "侠客潇洒青竹斗笠"],
		["armor.head.noble_headgear"]                    = ["wx_char_hat_topknot",      "江湖束发白玉木簪冠"],
		["armor.head.historian_hat"]                     = ["wx_char_hat_taoist",       "太和混元莲花道冠"],
		["armor.head.decayed_full_helm"]                 = ["wx_char_hat_helm_fengchi", "前朝鎏金凤翅兜鍪胄"],
		["armor.head.heavy_horned_plate_helmet"]         = ["wx_char_hat_helm_fengchi", "关外铁角凤翅重铁胄"],
		["armor.head.southern_head_wrap"]                = ["wx_hat_04",                "塞外防沙盘头缠巾"],
		["armor.head.nomad_leather_cap"]                 = ["wx_hat_19",                "漠北苍狼皮护耳帽"],
		["armor.head.nomad_light_helmet"]                = ["wx_hat_20",                "西域缠巾铁叶轻兜"],
		["armor.head.nomad_reinforced_helmet"]           = ["wx_hat_28",                "瀚海尖顶护鼻铁兜鍪"],
		["armor.head.spiked_skull_cap_with_mail"]        = ["wx_hat_24",                "黑水白骨护颈铁盔"]
	},

	// Vanilla `armor_upgrade.*` -> `[wx_back_XX, ChineseName]` (`70x70` icon in `ui/items/armor_upgrades/wx_back_XX.png`)
	ArmorUpgradeMap = {
		["armor_upgrade.direwolf_pelt"]                  = ["wx_back_03", "塞外苍狼厚毛护肩大氅"],
		["armor_upgrade.direwolf_pelt_upgrade"]          = ["wx_back_03", "塞外苍狼厚毛护肩大氅"],
		["armor_upgrade.hyena_fur"]                      = ["wx_back_14", "吊睛猛虎皮英雄披肩"],
		["armor_upgrade.hyena_fur_upgrade"]              = ["wx_back_14", "吊睛猛虎皮英雄披肩"],
		["armor_upgrade.unhold_fur"]                     = ["wx_back_03", "雪原白猿巨毛护背大氅"],
		["armor_upgrade.unhold_fur_upgrade"]             = ["wx_back_03", "雪原白猿巨毛护背大氅"],
		["armor_upgrade.lindwurm_scales"]                = ["wx_back_01", "太华青蛟鳞猩红大将披风"],
		["armor_upgrade.lindwurm_scales_upgrade"]        = ["wx_back_01", "太华青蛟鳞猩红大将披风"],
		["armor_upgrade.serpent_skin"]                   = ["wx_back_13", "岭南赤蟒皮防雨护肩蓑披"],
		["armor_upgrade.serpent_skin_upgrade"]           = ["wx_back_13", "岭南赤蟒皮防雨护肩蓑披"],
		["armor_upgrade.protective_runes"]               = ["wx_back_12", "天师朱砂百枚铜钱辟邪剑挂"],
		["armor_upgrade.protective_runes_and_sigils"]    = ["wx_back_12", "天师朱砂百枚铜钱辟邪剑挂"],
		["armor_upgrade.heraldic_plates"]                = ["wx_back_09", "节度镇军四面护背大靠旗"],
		["armor_upgrade.heraldic_shoulderplates"]        = ["wx_back_09", "节度镇军四面护背大靠旗"],
		["armor_upgrade.additional_padding"]             = ["wx_back_02", "夜鸦墨黑夹棉护背短披风"],
		["armor_upgrade.light_padding_replacement"]      = ["wx_back_08", "威远轻骑黑底金纹护背令旗"],
		["armor_upgrade.bone_platings"]                  = ["wx_back_10", "千机兽骨护心暗器腰肩囊"],
		["armor_upgrade.horn_plate"]                     = ["wx_back_14", "关外铁犀角猛虎皮披肩"],
		["armor_upgrade.metal_pauldrons"]                = ["wx_back_01", "镇边精钢吞肩大将红披风"],
		["armor_upgrade.double_mail"]                    = ["wx_back_05", "九边连环锁子双刀护背鞘"]
	},

	// Curated Wuxia appearance presets by vanilla `background.*` ID
	BackgroundPresets = {
		["background.monk"] = {
			Faces = [8, 10, 18, 25, 30, 40], Hairs = [0, 0, 4, 13], Tones = [0, 0, 2, 3],
			Beards = [0, 0, 7, 16, 21], Scars = [0, 0, 8], Backs = [0, 11, 11, 6], UnarmoredBody = "wx_char_robe_monk"
		},
		["background.flagellant"] = {
			Faces = [8, 16, 25, 30], Hairs = [0, 4, 13], Tones = [0, 2],
			Beards = [0, 7, 8], Scars = [1, 3, 8, 12], Backs = [0, 11], UnarmoredBody = "wx_char_robe_monk"
		},
		["background.swordmaster"] = {
			Faces = [1, 4, 9, 15, 22, 24, 33], Hairs = [3, 9, 12, 14, 18, 19], Tones = [2, 2, 3, 0],
			Beards = [5, 13, 14, 21, 24, 0], Scars = [0, 2, 3, 5, 8], Backs = [4, 4, 12, 6, 2], UnarmoredBody = "wx_char_robe_swordsman"
		},
		["background.retired_soldier"] = {
			Faces = [3, 4, 15, 21, 27, 30, 32], Hairs = [3, 17, 18, 19, 21], Tones = [1, 2, 2, 3],
			Beards = [1, 7, 16, 17, 22, 24], Scars = [1, 2, 3, 4, 12], Backs = [1, 5, 8, 9, 0], UnarmoredBody = "wx_char_cloth_short"
		},
		["background.hedge_knight"] = {
			Faces = [2, 3, 12, 15, 25, 30], Hairs = [1, 2, 11, 16, 17, 24], Tones = [0, 0, 1, 2],
			Beards = [1, 2, 8, 10, 18, 20], Scars = [1, 2, 3, 12, 0], Backs = [1, 9, 14, 5], UnarmoredBody = "wx_char_cloth_short"
		},
		["background.sellsword"] = {
			Faces = [1, 2, 3, 13, 18, 24, 31, 34, 48], Hairs = [1, 5, 10, 11, 16, 17, 22], Tones = [0, 0, 1],
			Beards = [0, 7, 10, 13, 16, 20], Scars = [0, 1, 2, 3], Backs = [2, 4, 5, 6, 0], UnarmoredBody = "wx_char_robe_swordsman"
		},
		["background.squire"] = {
			Faces = [1, 5, 17, 18, 22, 24, 34, 37], Hairs = [1, 9, 11, 12, 20, 21], Tones = [0, 0, 1],
			Beards = [0, 0, 9, 13], Scars = [0, 0, 3], Backs = [4, 8, 2, 0], UnarmoredBody = "wx_char_robe_swordsman"
		},
		["background.adventurous_noble"] = {
			Faces = [1, 5, 15, 22, 33, 34, 46], Hairs = [9, 10, 12, 17, 21, 23], Tones = [0, 0, 1],
			Beards = [0, 9, 13, 14, 15], Scars = [0, 0, 8], Backs = [1, 4, 9, 0], UnarmoredBody = "wx_char_robe_swordsman"
		},
		["background.disowned_noble"] = {
			Faces = [1, 5, 9, 13, 22, 24, 33, 46], Hairs = [9, 10, 12, 22, 23], Tones = [0, 1, 2],
			Beards = [0, 7, 13, 14], Scars = [0, 2, 3], Backs = [2, 4, 6, 0], UnarmoredBody = "wx_char_robe_swordsman"
		},
		["background.bastard"] = {
			Faces = [1, 7, 13, 18, 22, 24, 39], Hairs = [1, 5, 10, 11, 22], Tones = [0, 0, 1],
			Beards = [0, 7, 12, 13], Scars = [0, 2, 3], Backs = [2, 4, 5, 0], UnarmoredBody = "wx_char_robe_swordsman"
		},
		["background.assassin"] = {
			Faces = [7, 13, 14, 20, 31, 38, 39, 45], Hairs = [1, 5, 11, 12, 17], Tones = [0, 0, 2],
			Beards = [0, 0, 11, 12], Scars = [0, 2, 3, 5, 10], Backs = [2, 10, 5, 0], UnarmoredBody = "wx_char_cloth_short"
		},
		["background.killer_on_the_run"] = {
			Faces = [3, 7, 12, 13, 20, 25, 39, 45], Hairs = [2, 5, 8, 16, 22], Tones = [0, 1],
			Beards = [0, 7, 8, 18, 20], Scars = [1, 2, 6, 12], Backs = [2, 10, 13, 0], UnarmoredBody = "wx_char_cloth_short"
		},
		["background.witchhunter"] = {
			Faces = [9, 13, 15, 29, 31, 33, 48], Hairs = [3, 9, 12, 14, 21], Tones = [0, 1, 2],
			Beards = [0, 12, 13, 14, 21], Scars = [0, 2, 8, 10], Backs = [12, 12, 2, 10], UnarmoredBody = "wx_char_robe_taoist"
		},
		["background.cultist"] = {
			Faces = [7, 9, 14, 16, 29, 38, 41], Hairs = [2, 3, 14, 19, 24], Tones = [0, 2, 3],
			Beards = [0, 3, 11, 21], Scars = [8, 10, 11, 5], Backs = [12, 2, 10, 0], UnarmoredBody = "wx_char_robe_taoist"
		},
		["background.anatomist"] = {
			Faces = [5, 9, 14, 28, 29, 41, 43], Hairs = [7, 14, 15, 23], Tones = [0, 1, 2],
			Beards = [0, 3, 9, 11, 14], Scars = [0, 7, 9, 10], Backs = [7, 7, 10, 16], UnarmoredBody = "wx_char_robe_taoist"
		},
		["background.historian"] = {
			Faces = [5, 9, 22, 26, 28, 29, 46], Hairs = [3, 7, 9, 14, 15, 23], Tones = [0, 2, 3],
			Beards = [0, 3, 9, 14, 21], Scars = [0, 0, 9], Backs = [16, 15, 0], UnarmoredBody = "wx_char_robe_swordsman"
		},
		["background.minstrel"] = {
			Faces = [1, 5, 11, 17, 22, 26, 36, 42, 46], Hairs = [7, 9, 10, 15, 22, 23], Tones = [0, 1],
			Beards = [0, 0, 9, 14], Scars = [0, 8, 9], Backs = [6, 16, 0], UnarmoredBody = "wx_char_robe_swordsman"
		},
		["background.eunuch"] = {
			Faces = [5, 13, 14, 17, 22, 28], Hairs = [7, 9, 15, 21], Tones = [0, 2, 3],
			Beards = [0], Scars = [0], Backs = [0, 15, 2], UnarmoredBody = "wx_char_robe_swordsman"
		},
		["background.belly_dancer"] = {
			Faces = [35, 36, 38, 41, 42, 46, 47], Hairs = [9, 10, 12, 17, 20, 23], Tones = [0, 1],
			Beards = [0], Scars = [0, 8], Backs = [0, 2, 10], UnarmoredBody = "wx_char_robe_swordsman"
		},
		["background.nomad"] = {
			Faces = [6, 19, 25, 31, 35, 47], Hairs = [5, 6, 16, 17, 24], Tones = [0, 1, 1],
			Beards = [0, 4, 6, 19, 23], Scars = [0, 1, 11], Backs = [3, 5, 16, 0], UnarmoredBody = "wx_char_cloth_short"
		},
		["background.gladiator"] = {
			Faces = [2, 6, 18, 19, 25, 27, 30, 42], Hairs = [1, 6, 11, 16, 24], Tones = [0, 1],
			Beards = [0, 4, 6, 8, 10, 23], Scars = [1, 2, 11, 12], Backs = [1, 14, 5, 0], UnarmoredBody = "wx_char_cloth_short"
		},
		["background.wildman"] = {
			Faces = [2, 6, 12, 25, 27, 30], Hairs = [2, 5, 6, 8, 24], Tones = [0, 1, 2],
			Beards = [2, 4, 6, 8, 18, 23], Scars = [1, 11, 12, 0], Backs = [3, 14, 0], UnarmoredBody = "wx_char_cloth_short"
		},
		["background.barbarian"] = {
			Faces = [2, 6, 12, 19, 25, 30, 35], Hairs = [2, 5, 6, 16, 24], Tones = [0, 1, 2],
			Beards = [2, 6, 8, 18, 19, 23], Scars = [1, 11, 12], Backs = [3, 14, 5], UnarmoredBody = "wx_char_cloth_short"
		},
		["background.hunter"] = {
			Faces = [4, 6, 10, 18, 31, 35, 44], Hairs = [1, 5, 11, 17, 21], Tones = [0, 1],
			Beards = [0, 7, 12, 16, 17], Scars = [0, 1, 3], Backs = [3, 13, 14, 10], UnarmoredBody = "wx_char_cloth_short"
		},
		["background.poacher"] = {
			Faces = [6, 10, 20, 31, 35, 37], Hairs = [1, 5, 8, 11, 22], Tones = [0, 1],
			Beards = [0, 7, 12, 16], Scars = [0, 1, 6], Backs = [13, 10, 3, 0], UnarmoredBody = "wx_char_cloth_short"
		},
		["background.beast_slayer"] = {
			Faces = [3, 4, 7, 15, 25, 31, 39], Hairs = [1, 5, 11, 16, 18], Tones = [0, 1, 2],
			Beards = [0, 7, 10, 16, 20], Scars = [1, 2, 3, 4, 10], Backs = [14, 3, 10, 12], UnarmoredBody = "wx_char_cloth_short"
		},
		["background.caravan_hand"] = {
			Faces = [2, 4, 10, 18, 32, 34], Hairs = [1, 11, 16, 17, 21], Tones = [0, 1, 2],
			Beards = [0, 7, 10, 17, 20], Scars = [0, 1, 3], Backs = [8, 8, 5, 13, 0], UnarmoredBody = "wx_char_cloth_short"
		},
		["background.messenger"] = {
			Faces = [1, 10, 17, 20, 31, 34, 37], Hairs = [1, 11, 20, 21], Tones = [0, 1],
			Beards = [0, 0, 7], Scars = [0], Backs = [8, 16, 13, 0], UnarmoredBody = "wx_char_cloth_short"
		},
		["background.peddler"] = {
			Faces = [5, 17, 20, 28, 29, 36], Hairs = [7, 15, 21, 23], Tones = [0, 1, 2],
			Beards = [0, 3, 9, 11], Scars = [0, 9], Backs = [15, 7, 16, 0], UnarmoredBody = "wx_char_cloth_short"
		},
		["background.gambler"] = {
			Faces = [1, 11, 13, 20, 22, 26, 28, 36], Hairs = [9, 10, 22, 23], Tones = [0, 1],
			Beards = [0, 3, 9, 12], Scars = [0, 3], Backs = [15, 6, 0], UnarmoredBody = "wx_char_robe_swordsman"
		},
		["background.brawler"] = {
			Faces = [2, 11, 12, 18, 25, 27, 30], Hairs = [0, 1, 4, 13, 16, 24], Tones = [0, 1],
			Beards = [0, 2, 7, 8, 18, 20], Scars = [1, 12, 0], Backs = [0, 6, 14], UnarmoredBody = "wx_char_cloth_short"
		},
		["background.fisherman"] = {
			Faces = [4, 10, 23, 32, 44], Hairs = [1, 5, 8, 21, 22], Tones = [0, 1, 2],
			Beards = [0, 7, 16, 22], Scars = [0, 1], Backs = [13, 13, 6, 0], UnarmoredBody = "wx_char_raincape"
		},
		["background.beggar"] = {
			Faces = [4, 8, 10, 11, 20, 26], Hairs = [2, 8, 18, 22], Tones = [0, 1, 2, 3],
			Beards = [0, 5, 7, 16, 22], Scars = [0, 1, 6], Backs = [6, 6, 13, 0], UnarmoredBody = "wx_char_robe_beggar"
		},
		["background.cripple"] = {
			Faces = [3, 4, 14, 21, 27, 29], Hairs = [2, 8, 18, 22], Tones = [1, 2, 3],
			Beards = [5, 7, 16, 22], Scars = [4, 5, 1, 7, 12], Backs = [0, 6, 7], UnarmoredBody = "wx_char_robe_beggar"
		},
		["background.thief"] = {
			Faces = [7, 13, 17, 20, 36, 39, 45], Hairs = [1, 5, 8, 11, 20, 22], Tones = [0, 1],
			Beards = [0, 0, 7, 12], Scars = [0, 6, 3], Backs = [2, 10, 0], UnarmoredBody = "wx_char_cloth_short"
		},
		["background.deserter"] = {
			Faces = [3, 10, 12, 20, 27, 32], Hairs = [1, 8, 17, 21, 22], Tones = [0, 1],
			Beards = [0, 7, 16, 20], Scars = [6, 1, 3, 0], Backs = [0, 2, 8], UnarmoredBody = "wx_char_cloth_short"
		},
		["background.raider"] = {
			Faces = [2, 3, 7, 12, 20, 25, 45], Hairs = [1, 2, 5, 16, 22, 24], Tones = [0, 1],
			Beards = [0, 2, 7, 8, 18, 20], Scars = [1, 3, 4, 6, 12], Backs = [2, 5, 14, 0], UnarmoredBody = "wx_char_cloth_short"
		}
	},

	// Non-human & boss/elite `::Const.EntityType` -> bespoke `wx_enemy_*` / `wx_char_enemy_*` busts (`wx_beasts_0.brush`)
	EnemyEntityBustMap = {
		BanditLeader         = ["wx_enemy_bandit_lord", "wx_enemy_liaodong_boss", "wx_enemy_dongting_pirate"],
		NomadLeader          = ["wx_enemy_nomad_khan", "wx_enemy_mobei_centurion"],
		Assassin             = ["wx_enemy_youming_assassin", "wx_enemy_blade_dancer"],
		BladeDancer          = ["wx_enemy_blade_dancer", "wx_enemy_emei_sword"],
		Swordmaster          = ["wx_enemy_sword_saint", "wx_enemy_taihe_elder"],
		HedgeKnight          = ["wx_enemy_hedge_general", "wx_enemy_xuesha_juggernaut"],
		MasterArcher         = ["wx_enemy_tangmen_killer"],
		Knight               = ["wx_enemy_garrison_capt"],
		Officer              = ["wx_enemy_shenji_officer", "wx_enemy_dongchang_agent"],
		Gunner               = ["wx_enemy_shenji_musketeer"],
		Executioner          = ["wx_enemy_xuesha_juggernaut", "wx_enemy_mingzun_hierophant"],
		DesertStalker        = ["wx_enemy_mobei_centurion", "wx_enemy_tangmen_killer"],
		DesertDevil          = ["wx_enemy_blade_dancer", "wx_enemy_taihe_elder"],
		BountyHunter         = ["wx_enemy_liushan_bailiff", "wx_enemy_weiyuan_captain"],
		BarbarianChampion    = ["wx_enemy_barb_chosen", "wx_enemy_heishui_berserker"],
		BarbarianDrummer     = ["wx_enemy_barb_drummer"],
		BarbarianBeastmaster = ["wx_enemy_steppe_shaman"],
		BarbarianMadman      = ["wx_enemy_heishui_berserker"],
		GoblinAmbusher       = ["wx_enemy_wudu_blowgun", "wx_enemy_nanman_rattan"],
		GoblinFighter        = ["wx_enemy_nanman_rattan", "wx_enemy_wudu_blowgun"],
		GoblinWolfrider      = ["wx_enemy_nanman_rattan"],
		GoblinShaman         = ["wx_enemy_wudu_shaman", "wx_enemy_wudu_gushaman"],
		GoblinOverseer       = ["wx_enemy_wudu_overseer"],
		OrcYoung             = ["wx_char_enemy_yaoren"],
		OrcBerserker         = ["wx_enemy_bronze_yaoren", "wx_enemy_heishui_berserker"],
		OrcWarrior           = ["wx_enemy_bronze_yaoren", "wx_char_enemy_yaoren"],
		OrcWarlord           = ["wx_enemy_yaoren_lord", "wx_enemy_wanxian_patriarch"],
		SkeletonLight        = ["wx_enemy_mohist_puppet", "wx_enemy_tomb_automaton"],
		SkeletonMedium       = ["wx_enemy_tomb_automaton"],
		SkeletonHeavy        = ["wx_enemy_tomb_general", "wx_enemy_tomb_automaton"],
		SkeletonPriest       = ["wx_enemy_jiuyou_necromancer"],
		SkeletonBoss         = ["wx_enemy_ancient_lord"],
		SkeletonLich         = ["wx_enemy_ancient_lord", "wx_enemy_jiuyou_necromancer"],
		Zombie               = ["wx_char_enemy_corpse"],
		ZombieYeoman         = ["wx_char_enemy_corpse", "wx_enemy_iron_jiangshi"],
		ZombieKnight         = ["wx_enemy_iron_jiangshi"],
		ZombieBetrayer       = ["wx_enemy_iron_jiangshi"],
		ZombieBoss           = ["wx_enemy_ancient_lord", "wx_enemy_iron_jiangshi"],
		Necromancer          = ["wx_enemy_corpse_taoist", "wx_enemy_chenzhou_herder", "wx_enemy_jiuyou_necromancer"],
		Vampire              = ["wx_enemy_blood_vampire", "wx_enemy_tomb_swordwraith"],
		Ghost                = ["wx_enemy_tomb_wraith", "wx_enemy_crimson_wraith"],
		// Wild《山海异兽》tactical bust pools (`wx_beasts_0.brush` + `wx_corpses_0.brush`, 75 unique busts, zero cross-pool sharing)
		Direwolf             = ["wx_beast_tiangou", "wx_beast_heju", "wx_beast_xibian", "wx_beast_quanfeng", "wx_beast_bibi", "wx_beast_zhuru", "wx_beast_ershu", "wx_beast_luoshu", "wx_beast_tianma"],
		Hyena                = ["wx_beast_gudiao", "wx_beast_wenbao", "wx_beast_huan", "wx_beast_zhishou", "wx_beast_taodiao", "wx_beast_mafu", "wx_beast_changfu", "wx_beast_manman", "wx_beast_sanqingniao"],
		Spider               = ["wx_beast_chizhu", "wx_beast_xuanfeng", "wx_beast_feichong", "wx_beast_jiaochong"],
		SpiderEggs           = ["wx_beast_chizhu_egg"],
		Ghoul                = ["wx_beast_paoxiao", "wx_beast_changshe", "wx_beast_longzhi", "wx_beast_changbi", "wx_beast_shirou", "wx_beast_juru", "wx_beast_lili", "wx_beast_bingfeng", "wx_beast_haozhi", "wx_beast_guanxiong"],
		Serpent              = ["wx_beast_bashe_wild", "wx_beast_feiyi_hui", "wx_beast_suanyu", "wx_beast_qiuyu", "wx_beast_honghui", "wx_beast_ranyi", "wx_beast_ziyu", "wx_beast_wenyao"],
		Unhold               = ["wx_beast_zhuyan_wild", "wx_beast_huanshu", "wx_beast_yonghe", "wx_beast_shanxiao", "wx_beast_yimu", "wx_beast_lingling", "wx_beast_jianyang", "wx_beast_jiuli"],
		UnholdFrost          = ["wx_beast_liangqu", "wx_beast_aohen", "wx_beast_leishou", "wx_beast_liuzhe", "wx_beast_nieer"],
		UnholdBog            = ["wx_beast_tianwu", "wx_beast_heichi", "wx_beast_nengbie", "wx_beast_zhubie"],
		Schrat               = ["wx_beast_jianmu", "wx_beast_denglin"],
		SchratSmall          = ["wx_beast_jianmu_ling"],
		Alp                  = ["wx_beast_eshou", "wx_beast_quuru", "wx_beast_qitu", "wx_beast_feishu", "wx_beast_zhuniao", "wx_beast_huantou", "wx_beast_yumin"],
		Hexe                 = ["wx_beast_jiuwei_wild", "wx_beast_chiru", "wx_beast_gengfu"],
		Lindwurm             = ["wx_beast_feiyi_wild"],
		Kraken               = ["wx_beast_xiangliu"],
		KrakenTentacle       = ["wx_beast_xiangliu_chu"],
		TricksterGod         = ["wx_beast_yuanhu"]
	},

	// Authentic《山海经》species names per `wx_beast_*` bust (all 75 wild & spawn beasts)
	BeastBustNames = {
		wx_beast_tiangou      = "阴山天狗",
		wx_beast_heju         = "北号猲狙",
		wx_beast_xibian       = "天帝溪边犬",
		wx_beast_quanfeng     = "犬封战獒",
		wx_beast_bibi         = "獙獙翼狐",
		wx_beast_zhuru        = "朱獳妖狐",
		wx_beast_ershu        = "丹熏尾飞耳鼠",
		wx_beast_luoshu       = "杻阳鹿蜀斑马",
		wx_beast_tianma       = "马成飞天马",
		wx_beast_gudiao       = "西山蛊雕",
		wx_beast_wenbao       = "荆山文豹",
		wx_beast_huan         = "独目三尾讙",
		wx_beast_zhishou      = "浮玉食人彘",
		wx_beast_taodiao      = "赤目饕雕",
		wx_beast_mafu         = "蔓渠马腹",
		wx_beast_changfu      = "基山三首尚付",
		wx_beast_manman       = "崇吾比翼蛮蛮",
		wx_beast_sanqingniao  = "三危三青鸟",
		wx_beast_chizhu       = "五毒赤蛛",
		wx_beast_chizhu_egg   = "赤蛛蛊卵",
		wx_beast_xuanfeng     = "昆仑玄蜂",
		wx_beast_feichong     = "枯水蜚虫",
		wx_beast_jiaochong    = "双首骄虫",
		wx_beast_paoxiao      = "北山狍鸮",
		wx_beast_changshe     = "四耳长舌兽",
		wx_beast_longzhi      = "九首蠪侄",
		wx_beast_changbi      = "海外长臂妖",
		wx_beast_shirou       = "太岁视肉怪",
		wx_beast_juru         = "倚帝狙如",
		wx_beast_lili         = "柜山掘地狸力",
		wx_beast_bingfeng     = "双首黑彘并封",
		wx_beast_haozhi       = "竹山黑棘豪彘",
		wx_beast_guanxiong    = "海外穿胸尸卒",
		wx_beast_bashe_wild   = "苍梧巴蛇",
		wx_beast_feiyi_hui    = "浑夕肥遗虺",
		wx_beast_suanyu       = "四翼酸与",
		wx_beast_qiuyu        = "余峨犰狳虺",
		wx_beast_honghui      = "流波双首虹虺",
		wx_beast_ranyi        = "六足冉遗鱼",
		wx_beast_ziyu         = "独角毒茈鱼",
		wx_beast_wenyao       = "夜飞文鳐鱼",
		wx_beast_zhuyan_wild  = "小次山朱厌",
		wx_beast_huanshu      = "尧光猾褕豪兽",
		wx_beast_yonghe       = "丰山雍和猿",
		wx_beast_shanxiao     = "巫山赤发山魈",
		wx_beast_yimu         = "北荒一目蛮",
		wx_beast_lingling     = "空桑巨牛軨軨",
		wx_beast_jianyang     = "泰戏铁羬羊",
		wx_beast_jiuli        = "凶黎铜角魔兵",
		wx_beast_liangqu      = "历儿白首梁渠",
		wx_beast_aohen        = "三危四角獓狠",
		wx_beast_leishou      = "亶爰双爪类兽",
		wx_beast_liuzhe       = "流波奔雷夔犊",
		wx_beast_nieer        = "北荒聂耳妖",
		wx_beast_tianwu       = "朝阳八首天吴",
		wx_beast_heichi       = "东荒黑齿祝",
		wx_beast_nengbie      = "三足能鳖",
		wx_beast_zhubie       = "六足吐珠鳖",
		wx_beast_jianmu       = "都广建木树精",
		wx_beast_denglin      = "邓林炎木灵",
		wx_beast_jianmu_ling  = "建木盘根木灵",
		wx_beast_eshou        = "幽谷梦魇讹兽",
		wx_beast_quuru        = "祷过白首瞿如",
		wx_beast_qitu         = "嶓冢三首鵸鵌",
		wx_beast_feishu       = "天池滑翼飞鼠",
		wx_beast_zhuniao      = "柜山人手鴸鸟",
		wx_beast_huantou      = "大荒翼人驩头",
		wx_beast_yumin        = "南荒黑羽羽民",
		wx_beast_jiuwei_wild  = "青丘惑心妖魅",
		wx_beast_chiru        = "青丘人面赤鱬",
		wx_beast_gengfu       = "清冷渊耕父魅",
		wx_beast_feiyi_wild   = "太华六足肥遗蛟",
		wx_beast_xiangliu     = "九首相柳泽妖",
		wx_beast_xiangliu_chu = "相柳剧毒触蟒",
		wx_beast_yuanhu       = "尸胡龙角妴胡"
	},

	// World-map & combat-log `::Const.Strings.EntityName` Shan-Hai localization
	ShanHaiEntityStrings = {
		Direwolf       = "山海天狗",
		Hyena          = "大漠蛊雕",
		Spider         = "五毒赤蛛",
		SpiderEggs     = "赤蛛蛊卵",
		Ghoul          = "荒冢咆哮",
		Serpent        = "沧泽巴蛇",
		Unhold         = "荒山朱厌",
		UnholdFrost    = "雪山白猿",
		UnholdBog      = "泽国天吴",
		Schrat         = "建木树精",
		SchratSmall    = "建木灵苗",
		Alp            = "幽冥噩兽",
		Hexe           = "青丘妖魅",
		Lindwurm       = "深渊毒蛟",
		Kraken         = "沧溟泽龙",
		KrakenTentacle = "相柳剧毒触蟒",
		TricksterGod   = "昆仑龙角灵麋"
	},

	// Faction-authentic 1000-Faces presets for rank-and-file human NPC/enemy `::Const.EntityType` units
	HumanEntityPresets = {
		BanditThug = {
			Faces = [2, 3, 10, 11, 12, 20, 25, 27], Hairs = [0, 2, 5, 8, 16, 22], Tones = [0, 1],
			Beards = [0, 7, 8, 16, 18, 20], Scars = [0, 1, 6, 12], Backs = [0, 0, 6, 13], UnarmoredBody = "wx_char_cloth_short"
		},
		BanditRaider = {
			Faces = [2, 3, 7, 12, 18, 20, 25, 45], Hairs = [1, 2, 5, 11, 16, 24], Tones = [0, 1],
			Beards = [0, 2, 7, 8, 18, 20], Scars = [0, 1, 3, 4, 6, 12], Backs = [0, 2, 5, 14], UnarmoredBody = "wx_char_cloth_short"
		},
		BanditPoacher = {
			Faces = [6, 10, 20, 31, 37], Hairs = [1, 5, 8, 11, 22], Tones = [0, 1],
			Beards = [0, 7, 12], Scars = [0, 1], Backs = [0, 10, 13], UnarmoredBody = "wx_char_cloth_short"
		},
		BanditMarksman = {
			Faces = [7, 13, 20, 31, 39], Hairs = [1, 5, 11, 17, 21], Tones = [0, 1],
			Beards = [0, 7, 12, 16], Scars = [0, 2, 4], Backs = [0, 10, 2], UnarmoredBody = "wx_char_cloth_short"
		},
		NomadCutthroat = {
			Faces = [6, 19, 20, 25, 35, 47], Hairs = [5, 6, 16, 24], Tones = [0, 1],
			Beards = [0, 4, 6, 19, 23], Scars = [0, 1, 11], Backs = [0, 2, 3], UnarmoredBody = "wx_char_cloth_short"
		},
		NomadOutlaw = {
			Faces = [6, 19, 25, 30, 35, 47], Hairs = [5, 6, 16, 17, 24], Tones = [0, 1],
			Beards = [0, 4, 6, 19, 23], Scars = [0, 1, 3, 11], Backs = [0, 3, 5], UnarmoredBody = "wx_char_cloth_short"
		},
		NomadSlinger = {
			Faces = [6, 19, 20, 31, 35], Hairs = [5, 6, 16], Tones = [0, 1],
			Beards = [0, 4, 19], Scars = [0, 11], Backs = [0, 10], UnarmoredBody = "wx_char_cloth_short"
		},
		NomadArcher = {
			Faces = [6, 19, 31, 35, 47], Hairs = [5, 6, 11, 17], Tones = [0, 1],
			Beards = [0, 4, 6, 19], Scars = [0, 11], Backs = [0, 3, 10], UnarmoredBody = "wx_char_cloth_short"
		},
		Footman = {
			Faces = [2, 4, 15, 18, 30, 32], Hairs = [1, 17, 21], Tones = [0, 1],
			Beards = [0, 7, 10, 16, 17, 20], Scars = [0, 1, 3], Backs = [0, 8], UnarmoredBody = "wx_char_cloth_short"
		},
		Billman = {
			Faces = [2, 10, 15, 18, 32], Hairs = [1, 17, 21], Tones = [0, 1],
			Beards = [0, 7, 16, 17], Scars = [0, 1, 2], Backs = [0, 8], UnarmoredBody = "wx_char_cloth_short"
		},
		Arbalester = {
			Faces = [10, 13, 18, 31, 32], Hairs = [1, 17, 21], Tones = [0, 1],
			Beards = [0, 7, 9, 12], Scars = [0, 9], Backs = [0, 10], UnarmoredBody = "wx_char_cloth_short"
		},
		StandardBearer = {
			Faces = [4, 15, 18, 30, 32], Hairs = [1, 17, 18, 21], Tones = [0, 1, 2],
			Beards = [1, 10, 17, 20], Scars = [0, 1, 3], Backs = [9, 8], UnarmoredBody = "wx_char_cloth_short"
		},
		Sergeant = {
			Faces = [3, 4, 15, 25, 30, 48], Hairs = [1, 16, 17, 18, 21], Tones = [0, 1, 2],
			Beards = [1, 8, 10, 17, 20], Scars = [1, 2, 3, 4], Backs = [9, 1, 8], UnarmoredBody = "wx_char_cloth_short"
		},
		Conscript = {
			Faces = [6, 10, 18, 19, 32], Hairs = [1, 6, 17, 21], Tones = [0, 1],
			Beards = [0, 4, 7, 16, 19], Scars = [0, 1], Backs = [0, 8], UnarmoredBody = "wx_char_cloth_short"
		},
		Engineer = {
			Faces = [5, 14, 21, 28, 29], Hairs = [7, 15, 21], Tones = [0, 1, 2],
			Beards = [0, 3, 9, 22], Scars = [7, 9, 0], Backs = [10, 16], UnarmoredBody = "wx_char_cloth_short"
		},
		Militia = {
			Faces = [1, 10, 17, 23, 32, 34, 44], Hairs = [1, 7, 8, 20, 21], Tones = [0, 1],
			Beards = [0, 0, 7, 16], Scars = [0, 1], Backs = [0, 13], UnarmoredBody = "wx_char_cloth_short"
		},
		MilitiaRanged = {
			Faces = [10, 17, 20, 31, 37], Hairs = [1, 8, 11, 21], Tones = [0, 1],
			Beards = [0, 7], Scars = [0], Backs = [0, 10, 13], UnarmoredBody = "wx_char_cloth_short"
		},
		MilitiaVeteran = {
			Faces = [2, 4, 10, 18, 32], Hairs = [1, 17, 18, 21], Tones = [0, 1, 2],
			Beards = [7, 16, 17, 22], Scars = [0, 1, 3], Backs = [8, 0], UnarmoredBody = "wx_char_cloth_short"
		},
		MilitiaCaptain = {
			Faces = [4, 15, 18, 30, 34], Hairs = [1, 17, 18, 21], Tones = [0, 1, 2],
			Beards = [1, 10, 17, 20], Scars = [1, 3, 0], Backs = [8, 1], UnarmoredBody = "wx_char_cloth_short"
		},
		Mercenary = {
			Faces = [1, 2, 3, 13, 18, 24, 31, 33, 34, 48], Hairs = [1, 5, 9, 10, 11, 16, 17], Tones = [0, 1],
			Beards = [0, 7, 10, 13, 16, 20], Scars = [0, 1, 2, 3], Backs = [2, 4, 5, 6, 8], UnarmoredBody = "wx_char_robe_swordsman"
		},
		MercenaryRanged = {
			Faces = [1, 6, 13, 31, 34, 35], Hairs = [1, 5, 11, 17], Tones = [0, 1],
			Beards = [0, 7, 12], Scars = [0, 2], Backs = [10, 2, 3], UnarmoredBody = "wx_char_cloth_short"
		},
		CaravanHand = {
			Faces = [2, 10, 17, 23, 32], Hairs = [1, 8, 17, 21], Tones = [0, 1],
			Beards = [0, 7, 16], Scars = [0, 1], Backs = [8, 13, 0], UnarmoredBody = "wx_char_cloth_short"
		},
		CaravanGuard = {
			Faces = [2, 4, 15, 18, 32, 34], Hairs = [1, 11, 16, 17, 21], Tones = [0, 1],
			Beards = [0, 7, 10, 17, 20], Scars = [0, 1, 3], Backs = [8, 8, 5], UnarmoredBody = "wx_char_cloth_short"
		},
		BarbarianThrall = {
			Faces = [2, 6, 12, 25, 27], Hairs = [2, 5, 6, 8, 24], Tones = [0, 1],
			Beards = [2, 6, 8, 18, 19], Scars = [1, 11, 12], Backs = [0, 3], UnarmoredBody = "wx_char_cloth_short"
		},
		BarbarianMarauder = {
			Faces = [2, 6, 12, 19, 25, 30, 35], Hairs = [2, 5, 6, 16, 24], Tones = [0, 1, 2],
			Beards = [2, 6, 8, 18, 19, 23], Scars = [1, 11, 12], Backs = [3, 14, 5], UnarmoredBody = "wx_char_cloth_short"
		},
		Peasant = {
			Faces = [4, 10, 17, 23, 36, 44], Hairs = [1, 7, 8, 20, 21], Tones = [0, 1, 2],
			Beards = [0, 7, 16, 22], Scars = [0], Backs = [0, 7, 13], UnarmoredBody = "wx_char_cloth_short"
		},
		SouthernPeasant = {
			Faces = [6, 17, 19, 28, 35, 36], Hairs = [6, 7, 15, 21], Tones = [0, 1],
			Beards = [0, 4, 9, 19], Scars = [0], Backs = [0, 15, 16], UnarmoredBody = "wx_char_cloth_short"
		}
	}
};
