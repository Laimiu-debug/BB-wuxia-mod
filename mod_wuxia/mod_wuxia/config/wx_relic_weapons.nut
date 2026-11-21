// Declarative Registry of 37 Historical & Classical Chinese Famous Weapons (传世神兵红武)
// Uses vanilla named_* famed weapon icons & paperdoll sprites as placeholders right now;
// drop custom PNG/brush paths into CustomIcon / CustomIconLarge / CustomArmamentIcon later with zero code changes!

::Wuxia.Config.RelicWeapons <- {
	wx_relic_taie = {
		ID = "wx_relic_taie", Name = "太阿古剑", Family = "Sword",
		Script = "scripts/items/weapons/named/wx_relic_taie", BaseNamedScript = "scripts/items/weapons/named/named_sword",
		MinValue = 6800, Categories = null,
		CustomIcon = "weapons/named/wx_relic_taie_70x70.png", CustomIconLarge = "weapons/named/wx_relic_taie.png", CustomArmamentIcon = null,
		Description = "春秋铸剑宗师欧冶子、干将合铸之威道名剑。剑身苍古沉凝，出匣之日三军披靡，剑锋削铁透甲。"
	},
	wx_relic_longyuan = {
		ID = "wx_relic_longyuan", Name = "七星龙渊剑", Family = "Sword",
		Script = "scripts/items/weapons/named/wx_relic_longyuan", BaseNamedScript = "scripts/items/weapons/named/named_sword",
		MinValue = 6500, Categories = null,
		CustomIcon = "weapons/named/wx_relic_longyuan_70x70.png", CustomIconLarge = "weapons/named/wx_relic_longyuan.png", CustomArmamentIcon = null,
		Description = "采茨山之铜与天外寒铁所铸诚信高洁之剑，剑脊嵌铜七星，俯视剑身恍如临万丈深渊。"
	},
	wx_relic_chengying = {
		ID = "wx_relic_chengying", Name = "承影细剑", Family = "Sword",
		Script = "scripts/items/weapons/named/wx_relic_chengying", BaseNamedScript = "scripts/items/weapons/named/named_fencing_sword",
		MinValue = 6600, Categories = null,
		CustomIcon = "weapons/named/wx_relic_chengying_70x70.png", CustomIconLarge = "weapons/named/wx_relic_chengying.png", CustomArmamentIcon = null,
		Description = "商周传世精致古剑，白昼只见剑柄不见剑刃，暮色微光下唯有淡淡剑影掠喉，轻捷无双。"
	},
	wx_relic_ganjiang = {
		ID = "wx_relic_ganjiang", Name = "干将百炼阳剑", Family = "Sword",
		Script = "scripts/items/weapons/named/wx_relic_ganjiang", BaseNamedScript = "scripts/items/weapons/named/named_estoc",
		MinValue = 6700, Categories = null,
		CustomIcon = "weapons/named/wx_relic_ganjiang_70x70.png", CustomIconLarge = "weapons/named/wx_relic_ganjiang.png", CustomArmamentIcon = null,
		Description = "吴地名匠干将采五山铁精六合真金所铸雄剑，剑面布满百炼龟甲暗纹，专刺百炼重铠缝隙。"
	},
	wx_relic_moye = {
		ID = "wx_relic_moye", Name = "莫邪流水阴剑", Family = "Sword",
		Script = "scripts/items/weapons/named/wx_relic_moye", BaseNamedScript = "scripts/items/weapons/named/named_shamshir",
		MinValue = 6700, Categories = null,
		CustomIcon = "weapons/named/wx_relic_moye_70x70.png", CustomIconLarge = "weapons/named/wx_relic_moye.png", CustomArmamentIcon = null,
		Description = "与干将并称的传世雌剑，剑纹漫理如秋水微波，刃口薄若蝉翼，拂过甲衣便见血封喉。"
	},
	wx_relic_chixiao = {
		ID = "wx_relic_chixiao", Name = "赤霄斩蛇长剑", Family = "Sword",
		Script = "scripts/items/weapons/named/wx_relic_chixiao", BaseNamedScript = "scripts/items/weapons/named/named_warbrand",
		MinValue = 7200, Categories = null,
		CustomIcon = "weapons/named/wx_relic_chixiao_70x70.png", CustomIconLarge = "weapons/named/wx_relic_chixiao.png", CustomArmamentIcon = null,
		Description = "芒砀山云气所钟帝道双手长剑，剑长三尺有余、刃如霜雪而泛赤霞，劈刺兼备威压群丑。"
	},
	wx_relic_juque = {
		ID = "wx_relic_juque", Name = "巨阙至尊大剑", Family = "Sword",
		Script = "scripts/items/weapons/named/wx_relic_juque", BaseNamedScript = "scripts/items/weapons/named/named_greatsword",
		MinValue = 7800, Categories = null,
		CustomIcon = "weapons/named/wx_relic_juque_70x70.png", CustomIconLarge = "weapons/named/wx_relic_juque.png", CustomArmamentIcon = null,
		Description = "越王勾践五剑之首，阔刃厚背钝重如宫阙巨石，挥剑指天则金石俱裂、坚甲成灰。"
	},
	wx_relic_longque = {
		ID = "wx_relic_longque", Name = "大夏龙雀宝刀", Family = "Saber",
		Script = "scripts/items/weapons/named/wx_relic_longque", BaseNamedScript = "scripts/items/weapons/named/named_cleaver",
		MinValue = 6800, Categories = null,
		CustomIcon = "weapons/named/wx_relic_longque_70x70.png", CustomIconLarge = "weapons/named/wx_relic_longque.png", CustomArmamentIcon = null,
		Description = "大夏国主赫连勃勃命百工千灌百炼所铸天下名刀，刀环雕金龙衔雀，斩铁甲如劈朽木。"
	},
	wx_relic_minghong = {
		ID = "wx_relic_minghong", Name = "鸣鸿古刀", Family = "Saber",
		Script = "scripts/items/weapons/named/wx_relic_minghong", BaseNamedScript = "scripts/items/weapons/named/named_khopesh",
		MinValue = 6600, Categories = null,
		CustomIcon = "weapons/named/wx_relic_minghong_70x70.png", CustomIconLarge = "weapons/named/wx_relic_minghong.png", CustomArmamentIcon = null,
		Description = "上古铸鼎遗金凝成之神刀，刀身暗赤微弯，临敌未出鞘先发清越鹤鸣震慑胆魄。"
	},
	wx_relic_xiuchun = {
		ID = "wx_relic_xiuchun", Name = "御赐龙鳞绣春刀", Family = "Saber",
		Script = "scripts/items/weapons/named/wx_relic_xiuchun", BaseNamedScript = "scripts/items/weapons/named/named_cleaver",
		MinValue = 6200, Categories = null,
		CustomIcon = "weapons/named/wx_relic_xiuchun_70x70.png", CustomIconLarge = "weapons/named/wx_relic_xiuchun.png", CustomArmamentIcon = null,
		Description = "明廷内府御用监取镔铁璇纹钢千折百锻之指挥使佩刀，收腰弧刃轻灵毒辣。"
	},
	wx_relic_modao = {
		ID = "wx_relic_modao", Name = "大唐嗣业斩马陌刀", Family = "Cleaver",
		Script = "scripts/items/weapons/named/wx_relic_modao", BaseNamedScript = "scripts/items/weapons/named/named_crypt_cleaver",
		MinValue = 7900, Categories = null,
		CustomIcon = "weapons/named/wx_relic_modao_70x70.png", CustomIconLarge = "weapons/named/wx_relic_modao.png", CustomArmamentIcon = null,
		Description = "安西陌刀将李嗣业破阵遗兵，重十五斤双刃长柄，如墙而进，当嗣业之刀者人马俱碎！"
	},
	wx_relic_kunwu = {
		ID = "wx_relic_kunwu", Name = "昆吾割玉弯刀", Family = "Saber",
		Script = "scripts/items/weapons/named/wx_relic_kunwu", BaseNamedScript = "scripts/items/weapons/named/named_two_handed_scimitar",
		MinValue = 7500, Categories = null,
		CustomIcon = "weapons/named/wx_relic_kunwu_70x70.png", CustomIconLarge = "weapons/named/wx_relic_kunwu.png", CustomArmamentIcon = null,
		Description = "西域昆吾山赤铜流沙铁精所铸双手重弯刀，切美玉如切凝脂，沙海刀客奉为至宝。"
	},
	wx_relic_tulong = {
		ID = "wx_relic_tulong", Name = "玄铁沉水重宝刀", Family = "Cleaver",
		Script = "scripts/items/weapons/named/wx_relic_tulong", BaseNamedScript = "scripts/items/weapons/named/named_rusty_warblade",
		MinValue = 7600, Categories = null,
		CustomIcon = "weapons/named/wx_relic_tulong_70x70.png", CustomIconLarge = "weapons/named/wx_relic_tulong.png", CustomArmamentIcon = null,
		Description = "取海底乌金沉铁掺陨铁重铸的无锋阔背狂刀，刀体乌黑无光而沉猛绝伦，专破横练金钟。"
	},
	wx_relic_liquan = {
		ID = "wx_relic_liquan", Name = "沥泉盘龙神枪", Family = "Spear",
		Script = "scripts/items/weapons/named/wx_relic_liquan", BaseNamedScript = "scripts/items/weapons/named/named_spear",
		MinValue = 6800, Categories = null,
		CustomIcon = "weapons/named/wx_relic_liquan_70x70.png", CustomIconLarge = "weapons/named/wx_relic_liquan.png", CustomArmamentIcon = null,
		Description = "岳武穆于沥泉奇洞所得抗金神枪，枪缨如火、枪尖寒芒吞吐，守线控距万夫莫开。"
	},
	wx_relic_hutouqiang = {
		ID = "wx_relic_hutouqiang", Name = "虎头湛金长枪", Family = "Spear",
		Script = "scripts/items/weapons/named/wx_relic_hutouqiang", BaseNamedScript = "scripts/items/weapons/named/named_spetum",
		MinValue = 7000, Categories = null,
		CustomIcon = "weapons/named/wx_relic_hutouqiang_70x70.png", CustomIconLarge = "weapons/named/wx_relic_hutouqiang.png", CustomArmamentIcon = null,
		Description = "吞口铸黄金猛虎、枪尖百炼精钢的名将重枪，两格攒刺直透咽喉重铠。"
	},
	wx_relic_huaji = {
		ID = "wx_relic_huaji", Name = "温侯方天画戟", Family = "Polearm",
		Script = "scripts/items/weapons/named/wx_relic_huaji", BaseNamedScript = "scripts/items/weapons/named/named_billhook",
		MinValue = 8000, Categories = null,
		CustomIcon = "weapons/named/wx_relic_huaji_70x70.png", CustomIconLarge = "weapons/named/wx_relic_huaji.png", CustomArmamentIcon = null,
		Description = "戟杆彩绘蟠龙、两侧月牙利刃配中宫透甲枪尖的旷世凶兵，钩拉劈刺皆具千钧神威！"
	},
	wx_relic_yanyue = {
		ID = "wx_relic_yanyue", Name = "青龙冷艳锯", Family = "Polearm",
		Script = "scripts/items/weapons/named/wx_relic_yanyue", BaseNamedScript = "scripts/items/weapons/named/named_swordlance",
		MinValue = 8000, Categories = null,
		CustomIcon = "weapons/named/wx_relic_yanyue_70x70.png", CustomIconLarge = "weapons/named/wx_relic_yanyue.png", CustomArmamentIcon = null,
		Description = "重八十二斤的传世青龙偃月大刀，刀背锯齿森然，一挥横扫敌阵衣甲尽裂。"
	},
	wx_relic_goulianqiang = {
		ID = "wx_relic_goulianqiang", Name = "破虏神机钩镰枪", Family = "Polearm",
		Script = "scripts/items/weapons/named/wx_relic_goulianqiang", BaseNamedScript = "scripts/items/weapons/named/named_bladed_pike",
		MinValue = 7100, Categories = null,
		CustomIcon = "weapons/named/wx_relic_goulianqiang_70x70.png", CustomIconLarge = "weapons/named/wx_relic_goulianqiang.png", CustomArmamentIcon = null,
		Description = "宋明边军专为克制铁浮屠重骑秘造的百炼钩镰长枪，倒钩破甲精准狠辣。"
	},
	wx_relic_bawangqiang = {
		ID = "wx_relic_bawangqiang", Name = "乌金霸王破阵枪", Family = "Spear",
		Script = "scripts/items/weapons/named/wx_relic_bawangqiang", BaseNamedScript = "scripts/items/weapons/named/named_pike",
		MinValue = 7400, Categories = null,
		CustomIcon = "weapons/named/wx_relic_bawangqiang_70x70.png", CustomIconLarge = "weapons/named/wx_relic_bawangqiang.png", CustomArmamentIcon = null,
		Description = "西楚遗风乌金盘龙大枪，枪身沉逾百斤，非天生神力不能轻舞，一刺震退万军。"
	},
	wx_relic_huntiegun = {
		ID = "wx_relic_huntiegun", Name = "紧那罗混铁盘龙棍", Family = "Staff",
		Script = "scripts/items/weapons/named/wx_relic_huntiegun", BaseNamedScript = "scripts/items/weapons/named/named_two_handed_mace",
		MinValue = 7200, Categories = "棍棒, 双手",
		CustomIcon = "weapons/named/wx_relic_huntiegun_70x70.png", CustomIconLarge = "weapons/named/wx_relic_huntiegun.png", CustomArmamentIcon = null,
		Description = "少室禅院护寺神僧紧那罗王遗留百斤齐眉混铁棍，棍身盘龙浮雕，完美催动天下棍棒武学！"
	},
	wx_relic_lvzhuzhang = {
		ID = "wx_relic_lvzhuzhang", Name = "天下丐帮绿玉竹杖", Family = "Staff",
		Script = "scripts/items/weapons/named/wx_relic_lvzhuzhang", BaseNamedScript = "scripts/items/weapons/named/named_mace",
		MinValue = 6800, Categories = "棍棒, 单手",
		CustomIcon = "weapons/named/wx_relic_lvzhuzhang_70x70.png", CustomIconLarge = "weapons/named/wx_relic_lvzhuzhang.png", CustomArmamentIcon = null,
		Description = "天下第一大帮历代帮主传承信物，通体碧绿似玉却坚逾精钢，使护阵与打狗绝学如有神助。"
	},
	wx_relic_longlinzhao = {
		ID = "wx_relic_longlinzhao", Name = "天蚕乌金龙鳞爪", Family = "Fist",
		Script = "scripts/items/weapons/named/wx_relic_longlinzhao", BaseNamedScript = "scripts/items/weapons/named/wx_named_fist",
		MinValue = 6800, Categories = null,
		CustomIcon = "weapons/named/wx_relic_longlinzhao_70x70.png", CustomIconLarge = "weapons/named/wx_relic_longlinzhao.png", CustomArmamentIcon = null,
		Description = "以雪山天蚕丝混织乌金鳞片锻成的传世成对鹰爪护手，刀剑难伤，擒拿碎甲无往不利。"
	},
	wx_relic_jingangwan = {
		ID = "wx_relic_jingangwan", Name = "达摩伏虎金刚护腕", Family = "Fist",
		Script = "scripts/items/weapons/named/wx_relic_jingangwan", BaseNamedScript = "scripts/items/weapons/named/wx_named_fist",
		MinValue = 7000, Categories = null,
		CustomIcon = "weapons/named/wx_relic_jingangwan_70x70.png", CustomIconLarge = "weapons/named/wx_relic_jingangwan.png", CustomArmamentIcon = null,
		Description = "少室禅院首座代代相传的寒铁重护腕，对拳交击声若洪钟，隔甲震腑威力倍增。"
	},
	wx_relic_wengjinchui = {
		ID = "wx_relic_wengjinchui", Name = "擂鼓瓮金巨锤", Family = "Hammer",
		Script = "scripts/items/weapons/named/wx_relic_wengjinchui", BaseNamedScript = "scripts/items/weapons/named/named_two_handed_hammer",
		MinValue = 8000, Categories = null,
		CustomIcon = "weapons/named/wx_relic_wengjinchui_70x70.png", CustomIconLarge = "weapons/named/wx_relic_wengjinchui.png", CustomArmamentIcon = null,
		Description = "隋唐无敌猛将遗制双瓮金锤，锤面阔如战鼓，轰落之时铁甲金盔尽成齑粉！"
	},
	wx_relic_shutongjian = {
		ID = "wx_relic_shutongjian", Name = "四棱熟铜瓦面锏", Family = "Hammer",
		Script = "scripts/items/weapons/named/wx_relic_shutongjian", BaseNamedScript = "scripts/items/weapons/named/named_warhammer",
		MinValue = 6600, Categories = null,
		CustomIcon = "weapons/named/wx_relic_shutongjian_70x70.png", CustomIconLarge = "weapons/named/wx_relic_shutongjian.png", CustomArmamentIcon = null,
		Description = "唐初翼国公秦叔宝成名重器，无刃四棱沉铜铸就，专破百炼锁子甲而隔甲碎骨。"
	},
	wx_relic_jinzuan_chui = {
		ID = "wx_relic_jinzuan_chui", Name = "八宝震山长柄金锤", Family = "Hammer",
		Script = "scripts/items/weapons/named/wx_relic_jinzuan_chui", BaseNamedScript = "scripts/items/weapons/named/named_polehammer",
		MinValue = 7200, Categories = null,
		CustomIcon = "weapons/named/wx_relic_jinzuan_chui_70x70.png", CustomIconLarge = "weapons/named/wx_relic_jinzuan_chui.png", CustomArmamentIcon = null,
		Description = "边关上将帐前破城长柄重金锤，隔阵砸碎前排重盾铁盔。"
	},
	wx_relic_xuanhuafu = {
		ID = "wx_relic_xuanhuafu", Name = "混金八卦宣花大斧", Family = "Axe",
		Script = "scripts/items/weapons/named/wx_relic_xuanhuafu", BaseNamedScript = "scripts/items/weapons/named/named_greataxe",
		MinValue = 7600, Categories = null,
		CustomIcon = "weapons/named/wx_relic_xuanhuafu_70x70.png", CustomIconLarge = "weapons/named/wx_relic_xuanhuafu.png", CustomArmamentIcon = null,
		Description = "卢国公程知节三板斧定江山之成名巨斧，月牙阔刃嵌金八卦，劈盾断人势不可挡。"
	},
	wx_relic_pochengyue = {
		ID = "wx_relic_pochengyue", Name = "商周饕餮青铜重钺", Family = "Axe",
		Script = "scripts/items/weapons/named/wx_relic_pochengyue", BaseNamedScript = "scripts/items/weapons/named/named_bardiche",
		MinValue = 7500, Categories = null,
		CustomIcon = "weapons/named/wx_relic_pochengyue_70x70.png", CustomIconLarge = "weapons/named/wx_relic_pochengyue.png", CustomArmamentIcon = null,
		Description = "古墓王陵出土的天子征伐大钺，青铜暗锷饰狰狞饕餮纹，千年不锈锋利噬血。"
	},
	wx_relic_kaitian_changfu = {
		ID = "wx_relic_kaitian_changfu", Name = "辽东玄铁开山长斧", Family = "Axe",
		Script = "scripts/items/weapons/named/wx_relic_kaitian_changfu", BaseNamedScript = "scripts/items/weapons/named/named_poleaxe",
		MinValue = 7000, Categories = null,
		CustomIcon = "weapons/named/wx_relic_kaitian_changfu_70x70.png", CustomIconLarge = "weapons/named/wx_relic_kaitian_changfu.png", CustomArmamentIcon = null,
		Description = "辽东劈山盟历代盟主执掌的两格长杆破阵重斧，专碎前排龟甲大盾。"
	},
	wx_relic_wujinbian = {
		ID = "wx_relic_wujinbian", Name = "呼延乌金竹节钢鞭", Family = "Flail",
		Script = "scripts/items/weapons/named/wx_relic_wujinbian", BaseNamedScript = "scripts/items/weapons/named/named_three_headed_flail",
		MinValue = 6700, Categories = null,
		CustomIcon = "weapons/named/wx_relic_wujinbian_70x70.png", CustomIconLarge = "weapons/named/wx_relic_wujinbian.png", CustomArmamentIcon = null,
		Description = "河东呼延将门家传乌金重节鞭，挥动间诡变莫测，绕过铁盾直敲面门天灵。"
	},
	wx_relic_dashenbian = {
		ID = "wx_relic_dashenbian", Name = "云梦软金九节龙鞭", Family = "Flail",
		Script = "scripts/items/weapons/named/wx_relic_dashenbian", BaseNamedScript = "scripts/items/weapons/named/named_battle_whip",
		MinValue = 6400, Categories = null,
		CustomIcon = "weapons/named/wx_relic_dashenbian_70x70.png", CustomIconLarge = "weapons/named/wx_relic_dashenbian.png", CustomArmamentIcon = null,
		Description = "揉合赤金丝与蛟筋编织的奇门九节长软鞭，隔步卷刃锁喉、撕裂皮肉见血。"
	},
	wx_relic_yuchang = {
		ID = "wx_relic_yuchang", Name = "专诸鱼肠短剑", Family = "Dagger",
		Script = "scripts/items/weapons/named/wx_relic_yuchang", BaseNamedScript = "scripts/items/weapons/named/named_dagger",
		MinValue = 7000, Categories = null,
		CustomIcon = "weapons/named/wx_relic_yuchang_70x70.png", CustomIconLarge = "weapons/named/wx_relic_yuchang.png", CustomArmamentIcon = null,
		Description = "欧冶子所铸勇绝短剑，曾藏炙鱼腹中刺透吴王僚三层棠溪重甲，乃天下刺客至尊名器！"
	},
	wx_relic_xufuren = {
		ID = "wx_relic_xufuren", Name = "徐夫人淬血寒匕", Family = "Dagger",
		Script = "scripts/items/weapons/named/wx_relic_xufuren", BaseNamedScript = "scripts/items/weapons/named/named_qatal_dagger",
		MinValue = 7000, Categories = null,
		CustomIcon = "weapons/named/wx_relic_xufuren_70x70.png", CustomIconLarge = "weapons/named/wx_relic_xufuren.png", CustomArmamentIcon = null,
		Description = "赵人徐夫人所铸、燕太子丹以百草奇药淬炼之图穷匕见凶刃，贴身处决寸铁封喉。"
	},
	wx_relic_zhentiangong = {
		ID = "wx_relic_zhentiangong", Name = "薛家震天铁胎神弓", Family = "Bow",
		Script = "scripts/items/weapons/named/wx_relic_zhentiangong", BaseNamedScript = "scripts/items/weapons/named/named_warbow",
		MinValue = 7400, Categories = null,
		CustomIcon = "weapons/named/wx_relic_zhentiangong_70x70.png", CustomIconLarge = "weapons/named/wx_relic_zhentiangong.png", CustomArmamentIcon = null,
		Description = "三箭定天山之传世铁胎龙角强弓，非臂力过人难开满弦，一矢破空百步贯甲！"
	},
	wx_relic_shenbinu = {
		ID = "wx_relic_shenbinu", Name = "大宋克敌神臂重弩", Family = "Crossbow",
		Script = "scripts/items/weapons/named/wx_relic_shenbinu", BaseNamedScript = "scripts/items/weapons/named/named_crossbow",
		MinValue = 7200, Categories = null,
		CustomIcon = "weapons/named/wx_relic_shenbinu_70x70.png", CustomIconLarge = "weapons/named/wx_relic_shenbinu.png", CustomArmamentIcon = null,
		Description = "党项巧匠李宏献予宋廷、后经韩世忠改良之破甲劲弩，专射重甲铁骑胸膛。"
	},
	wx_relic_xunleichong = {
		ID = "wx_relic_xunleichong", Name = "赵氏神机五雷连铳", Family = "Firearm",
		Script = "scripts/items/weapons/named/wx_relic_xunleichong", BaseNamedScript = "scripts/items/weapons/named/named_handgonne",
		MinValue = 7600, Categories = null,
		CustomIcon = "weapons/named/wx_relic_xunleichong_70x70.png", CustomIconLarge = "weapons/named/wx_relic_xunleichong.png", CustomArmamentIcon = null,
		Description = "明工部火器大家赵士祯参酌佛郎机与鸟铳精铸之神机重火器，铅砂轰鸣震慑千军！"
	},
	wx_relic_feidaonang = {
		ID = "wx_relic_feidaonang", Name = "百炼寒星柳叶飞刀", Family = "Throwing",
		Script = "scripts/items/weapons/named/wx_relic_feidaonang", BaseNamedScript = "scripts/items/weapons/named/named_javelin",
		MinValue = 6600, Categories = null,
		CustomIcon = "weapons/named/wx_relic_feidaonang_70x70.png", CustomIconLarge = "weapons/named/wx_relic_feidaonang.png", CustomArmamentIcon = null,
		Description = "巴蜀名匠以寒星陨铁薄锻而成的十二柄柳叶飞刀，出手无影、例不虚发。"
	},
	wx_relic_xingtianqi = {
		ID = "wx_relic_xingtianqi", Name = "刑天舞干断首戚", Family = "Axe",
		Script = "scripts/items/weapons/named/wx_relic_xingtianqi", BaseNamedScript = "scripts/items/weapons/named/named_heavy_rusty_axe",
		MinValue = 8200, Categories = null,
		CustomIcon = "weapons/named/wx_relic_xingtianqi_70x70.png", CustomIconLarge = "weapons/named/wx_relic_xingtianqi.png", CustomArmamentIcon = null,
		Description = "《山海经·海外西经》常羊战魂不灭神髓重铸的上古巨戚：阔钺沉锋凶煞滔天，破甲碎盾无人可挡！"
	},
	wx_relic_qiongqizhao = {
		ID = "wx_relic_qiongqizhao", Name = "穷奇裂风血骨爪", Family = "Fist",
		Script = "scripts/items/weapons/named/wx_relic_qiongqizhao", BaseNamedScript = "scripts/items/weapons/named/wx_named_fist",
		MinValue = 7600, Categories = null,
		CustomIcon = "weapons/named/wx_relic_qiongqizhao_70x70.png", CustomIconLarge = "weapons/named/wx_relic_qiongqizhao.png", CustomArmamentIcon = null,
		Description = "取西极凶兽穷奇弯钩利爪配裂风妖丹精炼的成对凶兵护手，出爪如恶风撕喉！"
	},
};
