// Bespoke《山海经》Boss Registry — Batch S1 (南山经 9 妖) & Batch S2 (西山经 9 妖)
// Anatomically & mythically disciplined:
//   - Multi-tile segments ONLY on colossal coiled serpents (`bashe` 3格, `feiyi` 2格)
//   - Multi-part appendages ONLY on genuine separate co-fighting viper-tail (`xuangui` 巨龟主躯 + 怪水毒虺尾 = 2格)
//   - Domain totems ONLY on Qingqiu Foxfire Shrine Lanterns (`jiuwei` 1+3 `wx_totem_fox_lantern`)
//   - All other 14 Bosses are crisp 1-Hex Apex Bosses (`mythic_law`) with unique non-repeated combat laws!

if (!("ShanHaiBossSpecs" in ::Wuxia)) ::Wuxia.ShanHaiBossSpecs <- {};
if (!("ShanHaiBossMoves" in ::Wuxia)) ::Wuxia.ShanHaiBossMoves <- {};

// 1. 青丘九尾天狐 (南山经 · 1+3 青丘幻狐火灯阵眼)
::Wuxia.ShanHaiBossSpecs.jiuwei <- {
	Key = "jiuwei", Chapter = "南山经",
	TraitName = "青丘九尾·幻灯换影替命相",
	CanonQuote = "《南山经》：青丘之山，有兽焉，其状如狐而九尾，其音如婴儿，能食人。",
	TraitDesc = "青丘千年天狐妖主：开场立起 3 盏白骨【青丘幻狐火灯】并弥漫青丘迷障；每存 1 盏狐灯减免 16% 实伤，每回合首次受近战攻击自动与存活狐灯移形换位脱围，濒死时更可献祭 1 盏狐灯替命重生！",
	CounterHint = "施展《狮吼功/夔牛鼓》震散迷障，神射/轻功优先点灭 3 盏【青丘幻狐火灯】断其换位脱身与替死重生！",
	StructureMode = "totems",
	DefaultTotemCount = 3, TotemShieldPerUnit = 0.16,
	InitFieldKind = "mirage_mist",
	Parts = [
		{ Key = "foxlamp_1", Name = "青丘幻狐火灯·贪妄", HP = 70, Brush = "wx_totem_fox_lantern" },
		{ Key = "foxlamp_2", Name = "青丘幻狐火灯·嗔痴", HP = 70, Brush = "wx_totem_fox_lantern" },
		{ Key = "foxlamp_3", Name = "青丘幻狐火灯·迷魂", HP = 70, Brush = "wx_totem_fox_lantern" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_jiuwei_foxfire_fan <- {
	Name = "九尾妖火扇", Desc = "挥动九尾卷起三格扇形青丘紫焰（灼甲16，铺设【青丘迷障】遮蔽视线并挂破绽）。",
	Geo = "cone_3", AP = 5, Qi = 18, CD = 2, Field = "mirage_mist",
	Hit = 10, Dmg = 1.12, Arm = 1.20, Pen = 0.08,
	BurnArm = 16, DrainQi = 6, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_25", Icon = "skills/wx_smoke_cast.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_jiuwei_infant_charm <- {
	Name = "婴啼摄魂咒", Desc = "发《南山经》凄厉婴儿啼声直刺敌心（射程1~4，抽散12内息并令目标战意动摇）。",
	Geo = "hex_curse", AP = 4, Qi = 15, CD = 2, Field = "mirage_mist",
	Hit = 12, Dmg = 1.00, Arm = 1.00, Pen = 0.05,
	BurnArm = 0, DrainQi = 12, DrainHP = 0, Status = "shaken",
	Vfx = "wx_vfx_30", Icon = "skills/wx_tactics_qimen.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_jiuwei_mirage_swap <- {
	Name = "青丘移形换影", Desc = "借场上存活【青丘幻狐火灯】瞬间乾坤易位，在原地留下迷魂香障。",
	Geo = "totem_swap", AP = 3, Qi = 12, CD = 3, Field = "mirage_mist",
	Hit = 0, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 0, DrainHP = 0, Status = "",
	Vfx = "wx_vfx_25", Icon = "skills/wx_qinggong_meiying.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_jiuwei <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_jiuwei",
	TraitID = "special.wx_boss_trait_jiuwei",
	Skills = ["scripts/skills/actives/wx_boss_jiuwei_foxfire_fan", "scripts/skills/actives/wx_boss_jiuwei_infant_charm", "scripts/skills/actives/wx_boss_jiuwei_mirage_swap"],
	CounterHint = "施展《狮吼功/夔牛鼓》震散迷障，神射/轻功优先点灭 3 盏【青丘幻狐火灯】断其换位脱身与替死重生！"
};

// 2. 苍梧吞象巴蛇 (南山经 · 三格蜿蜒巨蟒躯：蟒首 + 吞象鼓胀腹囊躯 + 碧鳞巨尾)
::Wuxia.ShanHaiBossSpecs.bashe <- {
	Key = "bashe", Chapter = "南山经",
	TraitName = "巴蛇食象·蓄骨吐箭巨蟒躯",
	CanonQuote = "《海内南经》：巴蛇食象，三岁而出其骨，君子服之，无心腹之疾。",
	TraitDesc = "苍梧渊三格巨蟒（蟒首 + 吞象腹囊躯 + 碧鳞巨尾）：每次抓投吞噬猎物即积攒 1 层【腹中象骨】，使下一发《三岁吐骨箭》伤害暴涨 +22%/层！若误吞身染奇毒的猎物则触发『毒饵裂腹』反噬重伤；击碎腹囊躯即永久封印吞象绞！",
	CounterHint = "重兵集火打碎【吞象腹囊躯】封印抓投蓄骨，或故意令带毒前排诱其吞噬触发毒饵裂腹！",
	StructureMode = "segments",
	InitFieldKind = "bitter_mire",
	Parts = [
		{ Key = "belly_sac", Name = "巴蛇·吞象鼓胀腹囊躯", BodyArmor = 230, HeadArmor = 160, MeleeDef = 8, Brush = "wx_part_bashe_sac", LockedSkillID = "actives.wx_boss_bashe_swallow_coil" },
		{ Key = "jade_tail", Name = "巴蛇·苍梧碧鳞巨尾", BodyArmor = 190, HeadArmor = 140, MeleeDef = 12, Brush = "wx_part_bashe_tail", LockedSkillID = "actives.wx_boss_bashe_tail_mire" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_bashe_swallow_coil <- {
	Name = "吞象绞腹噬", Desc = "巨口卷摄 1~2 格猎物拖入腹囊汲血 24 点并蓄积 1 层【象骨】（吞中染毒者反遭裂腹内伤；碎腹囊躯即封印）。",
	Geo = "pull_devour", AP = 5, Qi = 20, CD = 2, Field = "bitter_mire",
	Hit = 12, Dmg = 1.18, Arm = 1.15, Pen = 0.10,
	BurnArm = 14, DrainQi = 8, DrainHP = 24, Status = "poison",
	Vfx = "wx_vfx_22", Icon = "skills/wx_fist_grapple.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_bashe_bone_spit <- {
	Name = "三岁吐骨箭", Desc = "倾尽腹中积攒的【象骨蓄层】喷射蚀甲巨骨贯穿直线 3 格（每层象骨额外提升 22% 伤害与 15% 破甲，附带内伤）。",
	Geo = "line_pierce_3", AP = 5, Qi = 18, CD = 2, Field = "",
	Hit = 10, Dmg = 1.15, Arm = 1.30, Pen = 0.08,
	BurnArm = 18, DrainQi = 0, DrainHP = 0, Status = "injury",
	Vfx = "wx_vfx_22", Icon = "skills/wx_throw_duzhen.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_bashe_tail_mire <- {
	Name = "苍梧盘尾扫", Desc = "挥动碧鳞巨尾横扫扇形三格震飞敌军并溅起【苦毒腐泽】（碎碧鳞巨尾即封印）。",
	Geo = "tail_sweep_arc", AP = 4, Qi = 16, CD = 2, Field = "bitter_mire",
	Hit = 8, Dmg = 1.10, Arm = 1.15, Pen = 0.05,
	BurnArm = 10, DrainQi = 6, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_15", Icon = "skills/wx_pole_sweep.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_bashe <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_bashe",
	TraitID = "special.wx_boss_trait_bashe",
	Skills = ["scripts/skills/actives/wx_boss_bashe_swallow_coil", "scripts/skills/actives/wx_boss_bashe_bone_spit", "scripts/skills/actives/wx_boss_bashe_tail_mire"],
	CounterHint = "重兵集火打碎【吞象腹囊躯】封印抓投蓄骨，或故意令带毒前排诱其吞噬触发毒饵裂腹！"
};

// 3. 章莪独足毕方 (南山经 · 单格异律法相：独足立讹火)
::Wuxia.ShanHaiBossSpecs.bifang <- {
	Key = "bifang", Chapter = "南山经",
	TraitName = "独足讹火·失火折足妖禽相",
	CanonQuote = "《西山/南山》：有鸟焉，其状如鹤，一足，赤文青质而白喙，名曰毕方，见则其邑有讹火。",
	TraitDesc = "单格独足神禽：独立于【赤旱焦土】上时借火凌空（近防+18、远防+24）；一旦脚下焦土被玄阴寒气/玄霜散扑灭，或被《打狗绊字诀》/捕网/铁蒺藜定身锁住独足，当场失衡坠地（近防倒扣 -14）！",
	CounterHint = "以玄阴寒冰掌/玄霜净地散扑灭毕方脚下焦土，并用《打狗绊字诀》或捕网锁死其独足！",
	StructureMode = "mythic_law",
	MinAP = 10,
	InitFieldKind = "drought_scorch",
	TurnFieldKind = "drought_scorch",
};

::Wuxia.ShanHaiBossMoves.wx_boss_bifang_wildfire_hop <- {
	Name = "独足掠火纵", Desc = "独足踏火飞掠 2~3 格扑啄敌军，在起落两地铺下【赤旱焦土】。",
	Geo = "leap_slam_3", AP = 4, Qi = 16, CD = 1, Field = "drought_scorch",
	Hit = 12, Dmg = 1.12, Arm = 1.20, Pen = 0.08,
	BurnArm = 18, DrainQi = 8, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_02", Icon = "skills/wx_qinggong_feiyan.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_bifang_beak_sear <- {
	Name = "白喙贯甲啄", Desc = "白玉长喙携青赤讹火精准贯刺（穿甲+14%，灼毁20点身甲并蒸干10内息）。",
	Geo = "single", AP = 4, Qi = 14, CD = 1, Field = "drought_scorch",
	Hit = 14, Dmg = 1.15, Arm = 1.25, Pen = 0.14,
	BurnArm = 20, DrainQi = 10, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_29", Icon = "skills/wx_sword_pierce.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_bifang_city_conflagration <- {
	Name = "邑有讹火引", Desc = "长鸣自訆引爆全战场所有【赤旱焦土】冲起焚邑火柱（事先净地灭火即可废此绝杀！）。",
	Geo = "field_detonate", AP = 5, Qi = 22, CD = 3, Field = "drought_scorch",
	Hit = 10, Dmg = 1.20, Arm = 1.25, Pen = 0.10,
	BurnArm = 16, DrainQi = 10, DrainHP = 0, Status = "scatter",
	Vfx = "wx_vfx_29", Icon = "skills/wx_saber_huoyandao.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_bifang <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_bifang",
	TraitID = "special.wx_boss_trait_bifang",
	Skills = ["scripts/skills/actives/wx_boss_bifang_wildfire_hop", "scripts/skills/actives/wx_boss_bifang_beak_sear", "scripts/skills/actives/wx_boss_bifang_city_conflagration"],
	CounterHint = "以玄阴寒冰掌/玄霜净地散扑灭毕方脚下焦土，并用《打狗绊字诀》或捕网锁死其独足！"
};

// 4. 鹿吴泽更蛊雕 (南山经 · 单格异律法相：婴啼乘怯追爪 + 本体断角)
::Wuxia.ShanHaiBossSpecs.gudiaowang <- {
	Key = "gudiaowang", Chapter = "南山经",
	TraitName = "泽更婴啼·乘怯追爪攒角相",
	CanonQuote = "《南山经》：鹿吴之山，泽更之水出焉，有兽焉名曰蛊雕，状如雕而有角，其音如婴儿之音，是食人。",
	TraitDesc = "单格食人妖禽：婴啼摄魄，对定力<55或战意动摇的猎物命中+16、总伤+26%、穿甲+10%，且每轮首次重创动摇者立返 2 AP 追杀！以重锤/巨斧正面猛击 2 次可敲断其额顶【鹿吴攒角冠】，封印高空裂颅扑！",
	CounterHint = "统帅《聚义号令》稳住全队定力杜绝其乘怯返AP连斩，重锤/大斧敲断其额上攒角！",
	StructureMode = "mythic_law",
	InternalPartKey = "gudiao_horn", InternalPartName = "鹿吴攒角冠", InternalPartType = "horn",
	InternalBreakMode = "blunt_or_axe", InternalBreakMax = 2, InternalLockedSkill = "actives.wx_boss_gudiaowang_horn_dive",
};

::Wuxia.ShanHaiBossMoves.wx_boss_gudiaowang_infant_wail <- {
	Name = "泽更婴啼啸", Desc = "发出毛骨悚然的婴儿夜啼震荡周身敌军心神，削减10内息并检定战意动摇。",
	Geo = "sonic_roar", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 10, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 10, DrainHP = 0, Status = "shaken",
	Vfx = "wx_vfx_30", Icon = "skills/wx_tactics_shihou.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_gudiaowang_horn_dive <- {
	Name = "攒角裂颅扑", Desc = "振翼腾空 2~3 格以额上巨角俯冲贯顶（对动摇猎物触发返AP追击；重兵断角即封印）。",
	Geo = "leap_slam_3", AP = 5, Qi = 20, CD = 2, Field = "",
	Hit = 14, Dmg = 1.25, Arm = 1.25, Pen = 0.12,
	BurnArm = 16, DrainQi = 0, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_axe_split.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_gudiaowang_talon_rend <- {
	Name = "食人铁爪撕", Desc = "双爪凶戾撕扯近身敌军咽喉，造成深创流血与架势破绽。",
	Geo = "single", AP = 4, Qi = 14, CD = 1, Field = "",
	Hit = 12, Dmg = 1.15, Arm = 1.15, Pen = 0.08,
	BurnArm = 10, DrainQi = 0, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_fist_xiongzhao.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_gudiaowang <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_gudiaowang",
	TraitID = "special.wx_boss_trait_gudiaowang",
	Skills = ["scripts/skills/actives/wx_boss_gudiaowang_infant_wail", "scripts/skills/actives/wx_boss_gudiaowang_horn_dive", "scripts/skills/actives/wx_boss_gudiaowang_talon_rend"],
	CounterHint = "统帅《聚义号令》稳住全队定力杜绝其乘怯返AP连斩，重锤/大斧敲断其额上攒角！"
};

// 5. 招摇白耳狌狌 (南山经 · 单格异律法相：知人名识路数)
::Wuxia.ShanHaiBossSpecs.xingxing <- {
	Key = "xingxing", Chapter = "南山经",
	TraitName = "招摇白耳·知人名破主力相",
	CanonQuote = "《南山经》：招摇之山，有兽焉，其状如禺而白耳，伏行人走，其名曰狌狌，知人名。",
	TraitDesc = "单格通明老猿：每回合初点破我方武艺最高头号主力之真名与师承路数，令其对狌狌造成的伤害直降 40%！唯借烟幕/迷障隐去行藏，或由未被呼名的副手与神射交叉合击方可满伤破敌！",
	CounterHint = "被点名的大哥投掷烟幕弹隐身破除识破，或转守势掩护副C与后排集火！",
	StructureMode = "mythic_law",
	ImmuneStun = true,
};

::Wuxia.ShanHaiBossMoves.wx_boss_xingxing_call_name <- {
	Name = "招摇呼名破妄", Desc = "一口叫破敌手姓名师承与旧伤罩门，令其心神剧震陷入【破绽】并散去12内息。",
	Geo = "hex_curse", AP = 3, Qi = 14, CD = 2, Field = "",
	Hit = 14, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 12, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_15", Icon = "skills/wx_tactics_guigu.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_xingxing_ape_rush <- {
	Name = "伏行人走奔袭", Desc = "四肢伏地疾奔如飞，直线冲撞三格震退沿途敌军并崩裂护甲。",
	Geo = "line_charge_3", AP = 5, Qi = 18, CD = 2, Field = "",
	Hit = 12, Dmg = 1.16, Arm = 1.20, Pen = 0.06,
	BurnArm = 14, DrainQi = 6, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_11", Icon = "skills/wx_fist_nuchao.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_xingxing_counter_palm <- {
	Name = "通明拆招掌", Desc = "洞察刀剑来路顺势拍击手腕神门穴，封锁经脉【点穴封气】。",
	Geo = "single", AP = 4, Qi = 15, CD = 1, Field = "",
	Hit = 14, Dmg = 1.12, Arm = 1.10, Pen = 0.10,
	BurnArm = 8, DrainQi = 8, DrainHP = 0, Status = "acupoint",
	Vfx = "wx_vfx_11", Icon = "skills/wx_fist_acupoint.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_xingxing <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_xingxing",
	TraitID = "special.wx_boss_trait_xingxing",
	Skills = ["scripts/skills/actives/wx_boss_xingxing_call_name", "scripts/skills/actives/wx_boss_xingxing_ape_rush", "scripts/skills/actives/wx_boss_xingxing_counter_palm"],
	CounterHint = "被点名的大哥投掷烟幕弹隐身破除识破，或转守势掩护副C与后排集火！"
};

// 6. 单狐山独目诸犍 (南山经 · 单格异律法相：行则衔尾狂风 · 居则蟠尾盘岳)
::Wuxia.ShanHaiBossSpecs.zhujian <- {
	Key = "zhujian", Chapter = "南山经",
	TraitName = "行则衔尾·居则蟠尾动静双相",
	CanonQuote = "《北山经》：单狐之山，有兽焉，人面豹身，牛耳一目，有长尾，行则衔其尾，居则蟠其尾。",
	TraitDesc = "单格动静双态风兽：上轮曾移动则入【衔尾疾风态】（武艺+14、伤害+20%）；原地未动则入【蟠尾盘岳态】（减伤28%、近防+10并回血22）！以利刃连斩 3 击削断本体豹尾，可一举废除其动静双态与狂冲！",
	CounterHint = "以刀剑锐器连斩削断其长豹尾破双态，或用击退/枪棒逼其小幅移位破除蟠尾铁壁！",
	StructureMode = "mythic_law",
	ImmuneStun = true,
	RegenHP = 22,
	InitFieldKind = "gale_sand",
	InternalPartKey = "leopard_tail", InternalPartName = "衔尾狂飙长豹尾", InternalPartType = "tail",
	InternalBreakMode = "blade", InternalBreakMax = 3, InternalLockedSkill = "actives.wx_boss_zhujian_tail_charge",
};

::Wuxia.ShanHaiBossMoves.wx_boss_zhujian_tail_charge <- {
	Name = "衔尾拔木狂冲", Desc = "口衔豹尾化作拔木狂飙直线碾压 3 格并卷起【裂风沙暴】（利刃断尾即封印）。",
	Geo = "line_charge_3", AP = 5, Qi = 20, CD = 2, Field = "gale_sand",
	Hit = 12, Dmg = 1.22, Arm = 1.25, Pen = 0.08,
	BurnArm = 18, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_15", Icon = "skills/wx_saber_kuanglan.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_zhujian_roar_gale <- {
	Name = "叱呼裂风吼", Desc = "音如叱呼卷起三格扇面风沙，震退近身敌军并遮蔽远射视线。",
	Geo = "cone_3", AP = 4, Qi = 16, CD = 2, Field = "gale_sand",
	Hit = 10, Dmg = 1.10, Arm = 1.15, Pen = 0.05,
	BurnArm = 10, DrainQi = 8, DrainHP = 0, Status = "shaken",
	Vfx = "wx_vfx_15", Icon = "skills/wx_tactics_shihou.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_zhujian_cyclops_gore <- {
	Name = "独目凶牙噬", Desc = "牛耳独目锁定猎物狂暴撕咬，汲取 16 点气血。",
	Geo = "single", AP = 4, Qi = 15, CD = 1, Field = "",
	Hit = 12, Dmg = 1.16, Arm = 1.15, Pen = 0.08,
	BurnArm = 12, DrainQi = 0, DrainHP = 16, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_axe_xueming.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_zhujian <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_zhujian",
	TraitID = "special.wx_boss_trait_zhujian",
	Skills = ["scripts/skills/actives/wx_boss_zhujian_tail_charge", "scripts/skills/actives/wx_boss_zhujian_roar_gale", "scripts/skills/actives/wx_boss_zhujian_cyclops_gore"],
	CounterHint = "以刀剑锐器连斩削断其长豹尾破双态，或用击退/枪棒逼其小幅移位破除蟠尾铁壁！"
};

// 7. 杻阳鸟首玄龟 (南山经 · 双格甲虺同体：巨龟玄壳主躯 + 独立怪水毒虺尾)
::Wuxia.ShanHaiBossSpecs.xuangui <- {
	Key = "xuangui", Chapter = "南山经",
	TraitName = "鸟首虺尾·千年镇海玄甲相",
	CanonQuote = "《南山经》：杻阳之山，怪水出焉，中多玄龟，其状如龟而鸟首虺尾，其音如判木。",
	TraitDesc = "双格甲尾巨兽（巨龟主躯 + 独立【怪水毒虺尾】）：主躯披千年玄甲，未破壳时刀剑箭矢伤害直降45%，唯【重锤/铁锏/重剑/隔甲寸劲】享 132% 碎壳暴伤！重钝猛砸破开主躯玄壳后近防暴跌 18 点，斩断毒虺尾即封印怪水毒抽！",
	CounterHint = "派遣重锤、玄铁重剑或少林寸劲手猛砸主躯砸裂【千年玄甲】，侧翼快刀斩断【怪水毒虺尾】！",
	StructureMode = "appendages",
	Headless = true,
	InternalPartKey = "xuangui_shell", InternalPartName = "千年镇海玄壳", InternalPartType = "shell",
	InternalBreakMode = "blunt", InternalBreakMax = 3, InternalLockedSkill = "actives.wx_boss_xuangui_fortress_ram",
	Parts = [
		{ Key = "viper_tail", Name = "玄龟·怪水毒虺尾", HP = 125, BodyArmor = 130, HeadArmor = 110, MeleeDef = 12, Brush = "wx_part_xuangui_tail", LockedSkillID = "actives.wx_boss_xuangui_viper_tail" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_xuangui_fortress_ram <- {
	Name = "镇海玄甲碾", Desc = "四肢缩入万钧玄壳轰然碾过前排三格，碎盾崩甲（重钝砸裂主躯玄壳即永久封印）。",
	Geo = "cone_3", AP = 5, Qi = 20, CD = 2, Field = "",
	Hit = 10, Dmg = 1.20, Arm = 1.40, Pen = 0.06,
	BurnArm = 24, DrainQi = 10, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_shield_xuanwu.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_xuangui_viper_tail <- {
	Name = "怪水虺尾抽", Desc = "尾部毒虺突袭噬抽侧后三格并注入怪水奇毒（斩断怪水毒虺尾即永久封印）。",
	Geo = "tail_sweep_arc", AP = 4, Qi = 15, CD = 2, Field = "bitter_mire",
	Hit = 12, Dmg = 1.12, Arm = 1.10, Pen = 0.10,
	BurnArm = 8, DrainQi = 6, DrainHP = 0, Status = "poison",
	Vfx = "wx_vfx_22", Icon = "skills/wx_flail_jinshe.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_xuangui_split_wood_roar <- {
	Name = "判木裂耳鸣", Desc = "鸟喙发出裂木巨响震荡周身 6 格敌军耳膜，削耗 10 内息并挂【破绽】。",
	Geo = "ring_quake_6", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 8, Dmg = 1.05, Arm = 1.15, Pen = 0.05,
	BurnArm = 10, DrainQi = 10, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_17", Icon = "skills/wx_hammer_polu.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_xuangui <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_xuangui",
	TraitID = "special.wx_boss_trait_xuangui",
	Skills = ["scripts/skills/actives/wx_boss_xuangui_fortress_ram", "scripts/skills/actives/wx_boss_xuangui_viper_tail", "scripts/skills/actives/wx_boss_xuangui_split_wood_roar"],
	CounterHint = "派遣重锤、玄铁重剑或少林寸劲手猛砸主躯砸裂【千年玄甲】，侧翼快刀斩断【怪水毒虺尾】！"
};

// 8. 丹穴堕火鹓鶵 (南山经 · 单格异律法相：踏火烬羽涅槃)
::Wuxia.ShanHaiBossSpecs.yuanchu <- {
	Key = "yuanchu", Chapter = "南山经",
	TraitName = "丹穴堕火·焦土烬羽涅槃相",
	CanonQuote = "《南山经》：丹穴之山，丹水出焉，有五采古禽，饮食自然，堕劫化腐火祭灵。",
	TraitDesc = "单格丹穴堕魔古凤：首次承受致死打击时，若脚下仍踩着【赤旱焦土】，立即引燃焦土浴火涅槃恢复 42% 气血！提前以玄阴寒气/玄霜散扑灭其脚下焦土，或施以《断续封生印》，即可一击绝灭涅槃！",
	CounterHint = "斩杀前务必用玄阴寒冰掌/玄霜散扑灭其脚下【赤旱焦土】（或将其击退离火），断绝浴火重生！",
	StructureMode = "mythic_law",
	InitFieldKind = "drought_scorch",
	TurnFieldKind = "drought_scorch",
};

::Wuxia.ShanHaiBossMoves.wx_boss_yuanchu_danxue_plume <- {
	Name = "丹穴腐火翎", Desc = "洒出漫天赤紫堕火翎羽覆盖扇形三格，灼穿18身甲并铺设【赤旱焦土】作为涅槃温床。",
	Geo = "cone_3", AP = 5, Qi = 18, CD = 2, Field = "drought_scorch",
	Hit = 12, Dmg = 1.15, Arm = 1.25, Pen = 0.08,
	BurnArm = 18, DrainQi = 8, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_29", Icon = "skills/wx_throw_fan.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_yuanchu_ash_rebirth <- {
	Name = "丹水燎原爆", Desc = "振翼引爆全场【赤旱焦土】喷涌腐火炎柱重创敌阵。",
	Geo = "field_detonate", AP = 5, Qi = 20, CD = 2, Field = "drought_scorch",
	Hit = 12, Dmg = 1.18, Arm = 1.20, Pen = 0.10,
	BurnArm = 16, DrainQi = 8, DrainHP = 0, Status = "scatter",
	Vfx = "wx_vfx_29", Icon = "skills/wx_bow_luori.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_yuanchu_soul_scorch <- {
	Name = "焚心乱神啸", Desc = "丹穴魔音灼烧敌手心脉，抽干 12 内息并引发内伤。",
	Geo = "hex_curse", AP = 4, Qi = 15, CD = 2, Field = "",
	Hit = 12, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 12, DrainHP = 0, Status = "injury",
	Vfx = "wx_vfx_30", Icon = "skills/wx_neigong_taotie.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_yuanchu <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_yuanchu",
	TraitID = "special.wx_boss_trait_yuanchu",
	Skills = ["scripts/skills/actives/wx_boss_yuanchu_danxue_plume", "scripts/skills/actives/wx_boss_yuanchu_ash_rebirth", "scripts/skills/actives/wx_boss_yuanchu_soul_scorch"],
	CounterHint = "斩杀前务必用玄阴寒冰掌/玄霜散扑灭其脚下【赤旱焦土】（或将其击退离火），断绝浴火重生！"
};

// 9. 基山背目猼訑 (南山经 · 单格异律法相：其目在背越围越强 · 远射点瞎破防)
::Wuxia.ShanHaiBossSpecs.boshi <- {
	Key = "boshi", Chapter = "南山经",
	TraitName = "其目在背·反制合围神瞳相",
	CanonQuote = "《南山经》：基山，有兽焉，其状如羊，九尾四耳，其目在背，其名曰猼訑，佩之不畏。",
	TraitDesc = "单格背生神目异兽：背目未瞎时四面皆明，近身每多 1 名我方围攻者，猼訑反而额外暴涨 +5 武艺与 +5 近防（严惩无脑贴身群殴）！唯先用【弓弩/暗器/点穴指】刺瞎脊背神瞳，其近防当场崩跌 -16！",
	CounterHint = "切忌开场一拥而上贴脸群殴！先以神射/唐门暗器/一阳指射瞎其【脊背神目】，再合围痛击！",
	StructureMode = "mythic_law",
	Headless = true,
	RegenHP = 14,
	InternalPartKey = "dorsal_eye", InternalPartName = "脊背神目灵瞳", InternalPartType = "core",
	InternalBreakMode = "ranged_or_acupoint", InternalBreakMax = 2, InternalLockedSkill = "actives.wx_boss_boshi_dorsal_glare",
};

::Wuxia.ShanHaiBossMoves.wx_boss_boshi_nine_tail_whip <- {
	Name = "九尾环身破围扫", Desc = "九条刚尾如铁鞭横扫周身 6 格所有近战围攻者，逼退并挂【失衡】。",
	Geo = "ring_quake_6", AP = 5, Qi = 18, CD = 2, Field = "",
	Hit = 12, Dmg = 1.15, Arm = 1.15, Pen = 0.06,
	BurnArm = 12, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_15", Icon = "skills/wx_axe_whirl.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_boshi_dorsal_glare <- {
	Name = "背目定魄神光", Desc = "脊背神瞳射出奇光震慑 1~3 格目标封锁经脉（远程/点穴射瞎背目即永久封印）。",
	Geo = "ranged_barrage", AP = 4, Qi = 15, CD = 2, Field = "",
	Hit = 14, Dmg = 1.10, Arm = 1.10, Pen = 0.12,
	BurnArm = 8, DrainQi = 12, DrainHP = 0, Status = "acupoint",
	Vfx = "wx_vfx_24", Icon = "skills/wx_fist_yiyang.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_boshi_fearless_ram <- {
	Name = "基山无畏铁抵", Desc = "四耳听风、迎面重撞破开前排架势。",
	Geo = "single", AP = 4, Qi = 14, CD = 1, Field = "",
	Hit = 12, Dmg = 1.18, Arm = 1.25, Pen = 0.06,
	BurnArm = 16, DrainQi = 0, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_17", Icon = "skills/wx_henglian_tongtou.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_boshi <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_boshi",
	TraitID = "special.wx_boss_trait_boshi",
	Skills = ["scripts/skills/actives/wx_boss_boshi_nine_tail_whip", "scripts/skills/actives/wx_boss_boshi_dorsal_glare", "scripts/skills/actives/wx_boss_boshi_fearless_ram"],
	CounterHint = "切忌开场一拥而上贴脸群殴！先以神射/唐门暗器/一阳指射瞎其【脊背神目】，再合围痛击！"
};

// 10. 小次山凶猿朱厌 (西山经 · 单格异律法相：见则大兵沸血叠煞)
::Wuxia.ShanHaiBossSpecs.zhuyan <- {
	Key = "zhuyan", Chapter = "西山经",
	TraitName = "白首赤足·见则大兵沸血相",
	CanonQuote = "《西山经》：小次之山，有兽焉，其状如猿，而白首赤足，名曰朱厌，见则大兵。",
	TraitDesc = "单格大兵灾兆凶猿：每次伤血攻击积攒 1 层【大兵战煞】（每层武艺+3、伤害+4%）并在目标脚下溅出【凶煞血池】，立于血池上每回合自愈 25 气血；走位拉离血池或涂《断续膏》可彻底断其续航！",
	CounterHint = "举盾防伤血叠煞，走位拉扯将其引离【凶煞血池】格，并以《钦原断续蚀壳膏》封死狂血自愈！",
	StructureMode = "mythic_law",
	ImmuneStun = true,
	RegenHP = 25,
	InitFieldKind = "blood_pool",
};

::Wuxia.ShanHaiBossMoves.wx_boss_zhuyan_war_stomp <- {
	Name = "赤足大兵裂地踏", Desc = "赤足重踏震裂周身 6 格并化为【凶煞血池】，重创近身敌军护甲致失衡。",
	Geo = "ring_quake_6", AP = 5, Qi = 20, CD = 2, Field = "blood_pool",
	Hit = 10, Dmg = 1.18, Arm = 1.25, Pen = 0.08,
	BurnArm = 18, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_08", Icon = "skills/wx_hammer_quake.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_zhuyan_crimson_pummel <- {
	Name = "白首碎骨连捶", Desc = "狂猿双拳如擂鼓猛砸前排重甲，透甲震伤脏腑。",
	Geo = "single", AP = 4, Qi = 16, CD = 1, Field = "blood_pool",
	Hit = 12, Dmg = 1.20, Arm = 1.30, Pen = 0.12,
	BurnArm = 20, DrainQi = 6, DrainHP = 0, Status = "injury",
	Vfx = "wx_vfx_11", Icon = "skills/wx_fist_jingang.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_zhuyan_blood_boil <- {
	Name = "见则大兵狂啸", Desc = "引爆全场【凶煞血池】沸腾煞气灼伤踏血敌军（净除血池即可破其大兵杀局）。",
	Geo = "field_detonate", AP = 4, Qi = 18, CD = 3, Field = "blood_pool",
	Hit = 10, Dmg = 1.15, Arm = 1.15, Pen = 0.08,
	BurnArm = 12, DrainQi = 10, DrainHP = 18, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_blood_burst.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_zhuyan <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_zhuyan",
	TraitID = "special.wx_boss_trait_zhuyan",
	Skills = ["scripts/skills/actives/wx_boss_zhuyan_war_stomp", "scripts/skills/actives/wx_boss_zhuyan_crimson_pummel", "scripts/skills/actives/wx_boss_zhuyan_blood_boil"],
	CounterHint = "举盾防伤血叠煞，走位拉扯将其引离【凶煞血池】格，并以《钦原断续蚀壳膏》封死狂血自愈！"
};

// 11. 太华六足四翼肥遗 (西山经 · 双格旱蛟巨躯：毒首 + 六足四翼赤鳞躯)
::Wuxia.ShanHaiBossSpecs.feiyi <- {
	Key = "feiyi", Chapter = "西山经",
	TraitName = "六足四翼·太华天下大旱躯",
	CanonQuote = "《西山经》：太华之山，削成而四方，有蛇焉名曰肥遗，六足四翼，见则天下大旱。",
	TraitDesc = "太华山双格旱蛟（毒首 + 六足赤鳞躯）：场上每多 1 格【赤旱焦土】，大旱热浪每轮额外蒸干近敌 2 点内息（上限10点）；击碎【六足四翼赤鳞躯】不仅永久封印六足狂爬，更当场瓦解大旱蒸息光环！",
	CounterHint = "重兵优先击碎后段【六足四翼赤鳞躯】瓦解大旱蒸息，辅以玄阴内劲扑灭焦土！",
	StructureMode = "segments",
	InitFieldKind = "drought_scorch",
	TurnFieldKind = "drought_scorch",
	Parts = [
		{ Key = "six_leg_body", Name = "肥遗·六足四翼赤鳞躯", BodyArmor = 240, HeadArmor = 170, MeleeDef = 8, Brush = "wx_tail_feiyi", LockedSkillID = "actives.wx_boss_feiyi_six_claw_rush" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_feiyi_drought_wing <- {
	Name = "四翼千里大旱风", Desc = "四翼扇出滚滚赤旱热浪席卷前方三格，灼毁18护甲、蒸干10内息并铺焦土。",
	Geo = "cone_3", AP = 5, Qi = 18, CD = 2, Field = "drought_scorch",
	Hit = 10, Dmg = 1.14, Arm = 1.25, Pen = 0.06,
	BurnArm = 18, DrainQi = 10, DrainHP = 0, Status = "scatter",
	Vfx = "wx_vfx_29", Icon = "skills/wx_saber_ranmu.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_feiyi_six_claw_rush <- {
	Name = "六足裂崖狂爬", Desc = "六足抠石蜿蜒冲撞直线 3 格碾碎盾防（击碎六足赤鳞躯即永久封印）。",
	Geo = "line_charge_3", AP = 5, Qi = 20, CD = 2, Field = "drought_scorch",
	Hit = 12, Dmg = 1.20, Arm = 1.25, Pen = 0.08,
	BurnArm = 16, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_29", Icon = "skills/wx_spear_bawang.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_feiyi_fang_scorch <- {
	Name = "太华焦毒噬", Desc = "赤毒獠牙贯刺近敌，同时引发【暗器剧毒】与护甲熔蚀。",
	Geo = "single", AP = 4, Qi = 15, CD = 1, Field = "",
	Hit = 12, Dmg = 1.15, Arm = 1.20, Pen = 0.10,
	BurnArm = 14, DrainQi = 6, DrainHP = 0, Status = "poison",
	Vfx = "wx_vfx_22", Icon = "skills/wx_dagger_vital.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_feiyi <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_feiyi",
	TraitID = "special.wx_boss_trait_feiyi",
	Skills = ["scripts/skills/actives/wx_boss_feiyi_drought_wing", "scripts/skills/actives/wx_boss_feiyi_six_claw_rush", "scripts/skills/actives/wx_boss_feiyi_fang_scorch"],
	CounterHint = "重兵优先击碎后段【六足四翼赤鳞躯】瓦解大旱蒸息，辅以玄阴内劲扑灭焦土！"
};

// 12. 槐江平圃英招 (西山经 · 单格异律法相：徇于四海冲势 vs 双卫卡翼)
::Wuxia.ShanHaiBossSpecs.yingzhao <- {
	Key = "yingzhao", Chapter = "西山经",
	TraitName = "天帝司圃·徇于四海驰风相",
	CanonQuote = "《西山经》：槐江之山，实惟帝之平圃，神英招司之，其状马身而人面，虎文而鸟翼，徇于四海。",
	TraitDesc = "单格巡海飞马古神：四海阔野无人近身锁控时，乘奔雷冲势武艺+14、总伤+18%；一旦被至少 2 名重盾/枪卫贴身双双卡死控制区（驻足敛翼），即失去冲锋回旋余地（近防 -14、所受伤害 +20%）！",
	CounterHint = "切勿放任其拉开距离助跑飞扑！派 2 名重盾刀卫一左一右贴身卡死其飞翼冲势！",
	StructureMode = "mythic_law",
	MinAP = 10,
	ImmuneStun = true,
	ImmuneDisarm = true,
};

::Wuxia.ShanHaiBossMoves.wx_boss_yingzhao_four_seas_charge <- {
	Name = "徇于四海奔袭", Desc = "马蹄踏风、鸟翼掠空直扑 2~3 格目标，崩甲挂【破绽】。",
	Geo = "leap_slam_3", AP = 5, Qi = 18, CD = 2, Field = "gale_sand",
	Hit = 14, Dmg = 1.20, Arm = 1.25, Pen = 0.10,
	BurnArm = 16, DrainQi = 6, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_03", Icon = "skills/wx_qinggong_zongyue.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_yingzhao_garden_edict <- {
	Name = "平圃天威震喝", Desc = "发天帝司圃威严神音震慑周身敌军，动摇军心并露破绽。",
	Geo = "sonic_roar", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 10, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 10, DrainHP = 0, Status = "shaken",
	Vfx = "wx_vfx_17", Icon = "skills/wx_rally_command.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_yingzhao_wing_slash <- {
	Name = "虎纹风翼横斩", Desc = "双翼如刀横扫前方三格敌阵。",
	Geo = "cone_3", AP = 5, Qi = 18, CD = 1, Field = "",
	Hit = 12, Dmg = 1.15, Arm = 1.20, Pen = 0.08,
	BurnArm = 14, DrainQi = 0, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_01", Icon = "skills/wx_pole_fangtian.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_yingzhao <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_yingzhao",
	TraitID = "special.wx_boss_trait_yingzhao",
	Skills = ["scripts/skills/actives/wx_boss_yingzhao_four_seas_charge", "scripts/skills/actives/wx_boss_yingzhao_garden_edict", "scripts/skills/actives/wx_boss_yingzhao_wing_slash"],
	CounterHint = "切勿放任其拉开距离助跑飞扑！派 2 名重盾刀卫一左一右贴身卡死其飞翼冲势！"
};

// 13. 昆仑下都神陆吾 (西山经 · 单格异律法相：春夏秋冬四时囿令轮转)
::Wuxia.ShanHaiBossSpecs.luwu <- {
	Key = "luwu", Chapter = "西山经",
	TraitName = "司天九部·春夏秋冬四时法相",
	CanonQuote = "《西山经》：昆仑之丘，实惟帝之下都，神陆吾司之，其状虎身而九尾，人面而虎爪，司天之九部及帝之囿时。",
	TraitDesc = "单格昆仑司时镇神：每回合按『春生（回血24）→ 夏烈（破甲+25%）→ 秋杀（武艺+16总伤+18%）→ 冬藏（减伤28%近防+12）』轮转帝囿四时！以相克真气逆时破令（玄阴寒冰破夏烈、纯阳烈火破冬藏）享 +28% 额外暴伤！",
	CounterHint = "察看其当前四时节令：夏烈轮用玄阴寒冰技强攻，冬藏轮用纯阳烈火破防，秋杀轮举盾固守！",
	StructureMode = "mythic_law",
	Headless = true,
	ImmuneStun = true,
};

::Wuxia.ShanHaiBossMoves.wx_boss_luwu_nine_realm_claw <- {
	Name = "司天九部裂虎爪", Desc = "神虎巨爪横扫前方三格撕开重甲，施加深创流血与【破绽】。",
	Geo = "cone_3", AP = 5, Qi = 18, CD = 1, Field = "",
	Hit = 14, Dmg = 1.20, Arm = 1.25, Pen = 0.10,
	BurnArm = 18, DrainQi = 0, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_fist_longzhao.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_luwu_kunlun_pounce <- {
	Name = "昆仑镇都扑", Desc = "挟昆仑山威跃扑 2 格重压敌阵，令目标失衡。",
	Geo = "leap_slam_3", AP = 5, Qi = 18, CD = 2, Field = "",
	Hit = 12, Dmg = 1.18, Arm = 1.25, Pen = 0.08,
	BurnArm = 16, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_hama_push.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_luwu_nine_tail_judgment <- {
	Name = "九尾囿时天刑", Desc = "九条虎尾齐振循四时节令轰击周身 6 格敌军。",
	Geo = "ring_quake_6", AP = 5, Qi = 22, CD = 2, Field = "",
	Hit = 12, Dmg = 1.22, Arm = 1.20, Pen = 0.10,
	BurnArm = 16, DrainQi = 10, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_17", Icon = "skills/wx_hammer_pocheng.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_luwu <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_luwu",
	TraitID = "special.wx_boss_trait_luwu",
	Skills = ["scripts/skills/actives/wx_boss_luwu_nine_realm_claw", "scripts/skills/actives/wx_boss_luwu_kunlun_pounce", "scripts/skills/actives/wx_boss_luwu_nine_tail_judgment"],
	CounterHint = "察看其当前四时节令：夏烈轮用玄阴寒冰技强攻，冬藏轮用纯阳烈火破防，秋杀轮举盾固守！"
};

// 14. 昆仑毒蜂钦原 (西山经 · 单格异律法相：蜇木则枯蚀盾 + 远射折翼坠地)
::Wuxia.ShanHaiBossSpecs.qinyuan <- {
	Key = "qinyuan", Chapter = "西山经",
	TraitName = "蜇石则烂·枯木蚀盾飞蜂相",
	CanonQuote = "《西山经》：昆仑之丘，有鸟焉，其状如蜂，大如鸳鸯，名曰钦原，蜇鸟兽则死，蜇木则枯。",
	TraitDesc = "单格昆仑奇毒巨蜂：11 AP 振翅浮空（近战劈砍命中难及、近战受击减免25%），每击直接腐蚀副手木铁盾牌 18 点耐久并注奇毒；唯以【弓弩/暗器/一阳指】或捕网击中 2 次折翼断针，令其坠地失速并封印绝命毒针！",
	CounterHint = "战前服《清心解毒丹》，开场以神射/唐门暗器/捕网将其『折翼断针』打落地面再行围杀！",
	StructureMode = "mythic_law",
	MinAP = 11,
	InitFieldKind = "bitter_mire",
	InternalPartKey = "venom_stinger", InternalPartName = "鸳鸯毒翼与尾针", InternalPartType = "wing",
	InternalBreakMode = "ranged_or_acupoint", InternalBreakMax = 2, InternalLockedSkill = "actives.wx_boss_qinyuan_stone_sting",
};

::Wuxia.ShanHaiBossMoves.wx_boss_qinyuan_stone_sting <- {
	Name = "蜇石烂铁绝命针", Desc = "尾针疾刺穿透铁甲（穿甲+18%，蚀损盾牌18耐久并引发脏腑内伤；远程折翼断针即封印）。",
	Geo = "single", AP = 4, Qi = 15, CD = 1, Field = "bitter_mire",
	Hit = 16, Dmg = 1.22, Arm = 1.30, Pen = 0.18,
	BurnArm = 22, DrainQi = 8, DrainHP = 0, Status = "injury",
	Vfx = "wx_vfx_22", Icon = "skills/wx_dagger_fuxue.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_qinyuan_venom_swarm <- {
	Name = "枯木毒蜂攒射", Desc = "振翅射出漫天毒针覆盖 1~4 格目标并化出【苦毒腐泽】。",
	Geo = "ranged_barrage", AP = 4, Qi = 16, CD = 1, Field = "bitter_mire",
	Hit = 14, Dmg = 1.12, Arm = 1.15, Pen = 0.12,
	BurnArm = 12, DrainQi = 6, DrainHP = 0, Status = "poison",
	Vfx = "wx_vfx_27", Icon = "skills/wx_throw_kongque.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_qinyuan_flutter_evade <- {
	Name = "鸳鸯毒翼震雾", Desc = "双翼急振洒下蚀甲毒粉震退周身近敌。",
	Geo = "ring_quake_6", AP = 3, Qi = 14, CD = 2, Field = "bitter_mire",
	Hit = 10, Dmg = 1.05, Arm = 1.15, Pen = 0.08,
	BurnArm = 12, DrainQi = 8, DrainHP = 0, Status = "poison",
	Vfx = "wx_vfx_22", Icon = "skills/wx_neigong_wudu.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_qinyuan <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_qinyuan",
	TraitID = "special.wx_boss_trait_qinyuan",
	Skills = ["scripts/skills/actives/wx_boss_qinyuan_stone_sting", "scripts/skills/actives/wx_boss_qinyuan_venom_swarm", "scripts/skills/actives/wx_boss_qinyuan_flutter_evade"],
	CounterHint = "战前服《清心解毒丹》，开场以神射/唐门暗器/捕网将其『折翼断针』打落地面再行围杀！"
};

// 15. 阴山食月天狗 (西山经 · 单格异律法相：永夜噬孤星 vs 同袍并肩)
::Wuxia.ShanHaiBossSpecs.tiangouwang <- {
	Key = "tiangouwang", Chapter = "西山经",
	TraitName = "白首榴音·食月噬孤星凶相",
	CanonQuote = "《西山经》：阴山，有兽焉，其状如狸而白首，名曰天狗，其音如榴榴，如流星坠地。",
	TraitDesc = "单格阴山凶星兽皇：降下【天狗食月】永夜，专挑落单孤客下手（对相邻无友军的孤立目标命中+16、总伤暴涨+32%！首杀立返 3 AP）；只要全队保持两人以上并肩结阵，天狗伤害反而折损 16%！",
	CounterHint = "严禁单人脱队孤军深入！全员保持两人并肩结阵（『同袍并肩』），前排架《铁枪拒马》截断扑杀！",
	StructureMode = "mythic_law",
	MinAP = 11,
	KillRefundAP = 3, KillHealHP = 30,
	InitWeather = "zhuyin_night",
};

::Wuxia.ShanHaiBossMoves.wx_boss_tiangouwang_meteor_drop <- {
	Name = "流星坠地扑杀", Desc = "化作炽白陨星跃扑 2~3 格目标（对落单孤客爆出致命重创），落地炸开【赤旱焦土】。",
	Geo = "leap_slam_3", AP = 4, Qi = 16, CD = 1, Field = "drought_scorch",
	Hit = 15, Dmg = 1.22, Arm = 1.25, Pen = 0.10,
	BurnArm = 16, DrainQi = 0, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_02", Icon = "skills/wx_sword_tianwai.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_tiangouwang_eclipse_howl <- {
	Name = "天狗食月暗夜嚎", Desc = "仰天榴榴长嗥吞没天光，散播【青丘迷障】并令敌军战意动摇。",
	Geo = "sonic_roar", AP = 3, Qi = 14, CD = 3, Field = "mirage_mist",
	Hit = 10, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 10, DrainHP = 0, Status = "shaken",
	Vfx = "wx_vfx_19", Icon = "skills/wx_qinggong_meiying.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_tiangouwang_throat_fang <- {
	Name = "白首噬月断喉", Desc = "专挑落单孤敌狠咬咽喉，造成重创流血。",
	Geo = "single", AP = 4, Qi = 14, CD = 1, Field = "",
	Hit = 14, Dmg = 1.18, Arm = 1.15, Pen = 0.12,
	BurnArm = 10, DrainQi = 6, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_dagger_execute.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_tiangouwang <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_tiangouwang",
	TraitID = "special.wx_boss_trait_tiangouwang",
	Skills = ["scripts/skills/actives/wx_boss_tiangouwang_meteor_drop", "scripts/skills/actives/wx_boss_tiangouwang_eclipse_howl", "scripts/skills/actives/wx_boss_tiangouwang_throat_fang"],
	CounterHint = "严禁单人脱队孤军深入！全员保持两人并肩结阵（『同袍并肩』），前排架《铁枪拒马》截断扑杀！"
};

// 16. 章峨五尾赤豹狰 (西山经 · 单格异律法相：音如击石三叠反震 + 重锤碎独角)
::Wuxia.ShanHaiBossSpecs.zheng <- {
	Key = "zheng", Chapter = "西山经",
	TraitName = "五尾一角·音如击石铮鸣相",
	CanonQuote = "《西山经》：章峨之山，无草木，多瑶碧，有兽焉，其状如赤豹，五尾一角，其音如击石，其名如狰。",
	TraitDesc = "单格瑶碧赤豹：额生【击石赤晶独角】，每承受 3 次非钝器攻击即迸发金石铮鸣反震攻者【失衡】！唯以重锤/铁锏/重剑单发猛砸，既不触发击石反震，更可一举敲碎赤晶独角封印崩岩冲！",
	CounterHint = "切忌用飞刀快剑高频刮痧触发 3 叠击石反震！用重锤/重剑重砸敲碎其额上赤晶独角！",
	StructureMode = "mythic_law",
	InternalPartKey = "crimson_horn", InternalPartName = "击石赤晶独角", InternalPartType = "horn",
	InternalBreakMode = "blunt", InternalBreakMax = 2, InternalLockedSkill = "actives.wx_boss_zheng_horn_shatter",
};

::Wuxia.ShanHaiBossMoves.wx_boss_zheng_horn_shatter <- {
	Name = "独角瑶碧崩岩冲", Desc = "顶起赤晶独角直线狂冲 3 格崩碎敌盾与22点重甲（重锤敲碎独角即永久封印）。",
	Geo = "line_charge_3", AP = 5, Qi = 18, CD = 2, Field = "",
	Hit = 13, Dmg = 1.22, Arm = 1.35, Pen = 0.08,
	BurnArm = 22, DrainQi = 6, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_hammer_shatter.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_zheng_stone_chime <- {
	Name = "音如击石裂金啸", Desc = "发出金石相击之铮鸣震荡周身 6 格，崩损甲胄并挂【破绽】。",
	Geo = "ring_quake_6", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 10, Dmg = 1.12, Arm = 1.25, Pen = 0.06,
	BurnArm = 14, DrainQi = 10, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_17", Icon = "skills/wx_tactics_kuiniu.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_zheng_five_tail_rend <- {
	Name = "五尾赤豹连抓", Desc = "五尾如鞭配合豹爪连环撕扯扇形三格。",
	Geo = "cone_3", AP = 4, Qi = 15, CD = 1, Field = "",
	Hit = 12, Dmg = 1.15, Arm = 1.15, Pen = 0.08,
	BurnArm = 12, DrainQi = 0, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_saber_sweep.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_zheng <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_zheng",
	TraitID = "special.wx_boss_trait_zheng",
	Skills = ["scripts/skills/actives/wx_boss_zheng_horn_shatter", "scripts/skills/actives/wx_boss_zheng_stone_chime", "scripts/skills/actives/wx_boss_zheng_five_tail_rend"],
	CounterHint = "切忌用飞刀快剑高频刮痧触发 3 叠击石反震！用重锤/重剑重砸敲碎其额上赤晶独角！"
};

// 17. 天山无面浑沌 (西山经 · 单格异律法相：日凿一窍，七日浑沌死)
::Wuxia.ShanHaiBossSpecs.hundun <- {
	Key = "hundun", Chapter = "西山经",
	TraitName = "黄囊无面·日凿七窍死浑沌",
	CanonQuote = "《西山经》：天山有神，状如黄囊，赤如丹火，六足四翼，浑敦无面目，是识歌舞。《庄子》：日凿一窍，七日而浑沌死。",
	TraitDesc = "单格四大凶兽浑沌：浑圆无面免爆头免眩晕，常规劈砍射箭伤害减免 42%！唯以【点穴指劲/刺剑/短匕/长枪】精准刺凿，每击凿开 1 道玄窍，凿满 7 窍当场引爆 30% 最大气血并崩解黄囊神体（近防-16）！",
	CounterHint = "还原『日凿七窍死浑沌』典故：派一阳指/参合指/点穴手/刺剑短匕合力刺满 7 窍一举轰杀！",
	StructureMode = "mythic_law",
	Headless = true,
	ImmuneStun = true,
	RegenHP = 18,
};

::Wuxia.ShanHaiBossMoves.wx_boss_hundun_chaos_dance <- {
	Name = "六足识歌狂舞", Desc = "循太古荒歌节拍六足四翼狂舞回旋，震荡周身 6 格敌军失衡散功。",
	Geo = "ring_quake_6", AP = 5, Qi = 20, CD = 2, Field = "drought_scorch",
	Hit = 12, Dmg = 1.18, Arm = 1.25, Pen = 0.08,
	BurnArm = 16, DrainQi = 10, DrainHP = 0, Status = "scatter",
	Vfx = "wx_vfx_29", Icon = "skills/wx_axe_whirl.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_hundun_crimson_sac <- {
	Name = "丹火黄囊坠压", Desc = "赤如丹火的浑圆巨躯腾跃重压 1~2 格目标，铺设【赤旱焦土】。",
	Geo = "leap_slam_3", AP = 5, Qi = 18, CD = 2, Field = "drought_scorch",
	Hit = 12, Dmg = 1.22, Arm = 1.30, Pen = 0.08,
	BurnArm = 20, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_29", Icon = "skills/wx_henglian_tiebushan.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_hundun_vortex_pull <- {
	Name = "浑沌无窍归墟引", Desc = "四翼卷起混沌气璇将 2~3 格远敌强行吸入身侧重创。",
	Geo = "pull_devour", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 12, Dmg = 1.12, Arm = 1.15, Pen = 0.10,
	BurnArm = 12, DrainQi = 12, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_19", Icon = "skills/wx_neigong_xixing.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_hundun <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_hundun",
	TraitID = "special.wx_boss_trait_hundun",
	Skills = ["scripts/skills/actives/wx_boss_hundun_chaos_dance", "scripts/skills/actives/wx_boss_hundun_crimson_sac", "scripts/skills/actives/wx_boss_hundun_vortex_pull"],
	CounterHint = "还原『日凿七窍死浑沌』典故：派一阳指/参合指/点穴手/刺剑短匕合力刺满 7 窍一举轰杀！"
};

// 18. 西王母玉山神狡 (西山经 · 单格异律法相：大穰夺气蓄瑞 vs 破气返元)
::Wuxia.ShanHaiBossSpecs.jiao <- {
	Key = "jiao", Chapter = "西山经",
	TraitName = "豹文牛角·大穰蓄瑞夺气相",
	CanonQuote = "《西山经》：玉山，王母所居也，有兽焉，其状如犬而豹文，其角如牛，名曰狡，其音如吠犬，见则其国大穰。",
	TraitDesc = "单格玉山瑞凶犬皇：每次命中夺取我方元气化为【大穰瑞气】（每层武艺/近防+4，满3层当场自愈 35 气血）；若在其蓄气未满3层前以【破气剑/一阳指/点穴/吸星】刺破气旋，反可夺回 15 点充沛内息！",
	CounterHint = "在其叠满 3 层瑞气回血前，用《独孤破气/一阳指/点穴/吸星》刺破瑞气反哺自身 15 内息！",
	StructureMode = "mythic_law",
	MinAP = 10,
};

::Wuxia.ShanHaiBossMoves.wx_boss_jiao_ox_horn_toss <- {
	Name = "玉山牛角挑岳", Desc = "以一对青铜般弯牛巨角猛顶前排，崩毁20点护甲并夺取1层瑞气。",
	Geo = "single", AP = 4, Qi = 15, CD = 1, Field = "",
	Hit = 15, Dmg = 1.20, Arm = 1.30, Pen = 0.08,
	BurnArm = 20, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_spear_bawang.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_jiao_leopard_lunge <- {
	Name = "豹文恶犬连扑", Desc = "豹纹健躯疾跃 2~3 格撕咬咽喉致深创流血。",
	Geo = "leap_slam_3", AP = 4, Qi = 16, CD = 1, Field = "",
	Hit = 14, Dmg = 1.18, Arm = 1.15, Pen = 0.10,
	BurnArm = 12, DrainQi = 0, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_saber_zhanlang.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_jiao_harvest_bark <- {
	Name = "见则大穰震吠", Desc = "音如雷犬狂吠震荡周身 6 格敌军气海，抽散8内息并挂【破绽】。",
	Geo = "ring_quake_6", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 12, Dmg = 1.14, Arm = 1.15, Pen = 0.08,
	BurnArm = 12, DrainQi = 8, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_17", Icon = "skills/wx_tactics_kuiniu.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_jiao <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_jiao",
	TraitID = "special.wx_boss_trait_jiao",
	Skills = ["scripts/skills/actives/wx_boss_jiao_ox_horn_toss", "scripts/skills/actives/wx_boss_jiao_leopard_lunge", "scripts/skills/actives/wx_boss_jiao_harvest_bark"],
	CounterHint = "在其叠满 3 层瑞气回血前，用《独孤破气/一阳指/点穴/吸星》刺破瑞气反哺自身 15 内息！"
};
