// Bespoke《山海经》Boss Registry — Batches S3 (北山经 7) + S4 (东山/中山经 21) + S5 (大荒/海内/海外经 15)
// Strictly faithful to《山海经》anatomy & mythology:
//   - Multi-tile segments ONLY on true giant dragons/serpents (`yinglong` 3格, `gonggong` 2格, `hujiao` 2格, `mingshe` 2格, `huashe` 2格)
//   - Multi-head appendages ONLY on true multi-headed / twin-serpent monsters (`jiuying` 3格, `kaiming` 3格, `jiufeng` 3格, `shebishi` 3格)
//   - Domain totems ONLY on world-phenomenon deities (`dijiang`, `kui`, `jingwei`, `jumang`, `kuafu`, `chiyou`, `jinwu`, `bingyi`)
//     each using its own bespoke hand-painted `wx_totem_*` sprite!
//   - All remaining 26 Bosses here are crisp 1-Hex Apex Bosses (`mythic_law`) with unique non-repeated combat laws!

if (!("ShanHaiBossSpecs" in ::Wuxia)) ::Wuxia.ShanHaiBossSpecs <- {};
if (!("ShanHaiBossMoves" in ::Wuxia)) ::Wuxia.ShanHaiBossMoves <- {};

// 19. 邽山猬毛穷奇 (北山经 · 单格异律法相：毁信恶忠·惩善助恶猬刺律)
::Wuxia.ShanHaiBossSpecs.qiongqi <- {
	Key = "qiongqi", Chapter = "北山经",
	TraitName = "猬毛嗥狗·毁信恶忠惩善相",
	CanonQuote = "《北山经》：邽山，有兽焉，其状如牛，猬毛，名曰穷奇，音如嗥狗，是食人。《神异经》：毁信恶忠，惩善助恶。",
	TraitDesc = "单格四大凶兽穷奇：专噬正气君子——对定力≥65 的侠士命中+15、总伤+25%，且正士近战砍中穷奇反遭猬毛铁刺损甲12点；而对定力<50 的市井泼皮/浪子反而命中-10、伤害-18%！重锤猛砸可砸扁其猬毛刺脊封印攒射！",
	CounterHint = "切勿让高定力统帅裸身硬扛！遣低定力狂徒/奇兵贴身缠斗，重锤猛砸砸平其背脊猬刺！",
	StructureMode = "mythic_law",
	MinAP = 11,
	InitFieldKind = "gale_sand",
	InternalPartKey = "quill_ridge", InternalPartName = "邽山猬毛铁刺脊", InternalPartType = "shell",
	InternalBreakMode = "blunt", InternalBreakMax = 2, InternalLockedSkill = "actives.wx_boss_qiongqi_quill_volley",
};

::Wuxia.ShanHaiBossMoves.wx_boss_qiongqi_evil_gale <- {
	Name = "惩善裂风扑", Desc = "乘狂风跃扑 2~3 格专噬高定力正士咽喉，落地卷起【裂风沙暴】致深创流血。",
	Geo = "leap_slam_3", AP = 4, Qi = 16, CD = 1, Field = "gale_sand",
	Hit = 14, Dmg = 1.20, Arm = 1.20, Pen = 0.12,
	BurnArm = 14, DrainQi = 0, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_fist_xiongzhao.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_qiongqi_quill_volley <- {
	Name = "猬毛铁刺攒射", Desc = "倒竖全身如钢针般的猬毛攒射 1~4 格目标（重锤砸平背脊猬刺即永久封印）。",
	Geo = "ranged_barrage", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 14, Dmg = 1.15, Arm = 1.25, Pen = 0.14,
	BurnArm = 16, DrainQi = 6, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_27", Icon = "skills/wx_throwing_rain.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_qiongqi_howl_betray <- {
	Name = "嗥狗毁信狂啸", Desc = "音如恶犬狂嗥动摇军心，破除周身敌军架势【破绽】。",
	Geo = "sonic_roar", AP = 3, Qi = 14, CD = 2, Field = "gale_sand",
	Hit = 10, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 10, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_30", Icon = "skills/wx_tactics_shihou.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_qiongqi <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_qiongqi",
	TraitID = "special.wx_boss_trait_qiongqi",
	Skills = ["scripts/skills/actives/wx_boss_qiongqi_evil_gale", "scripts/skills/actives/wx_boss_qiongqi_quill_volley", "scripts/skills/actives/wx_boss_qiongqi_howl_betray"],
	CounterHint = "切勿让高定力统帅裸身硬扛！遣低定力狂徒/奇兵贴身缠斗，重锤猛砸砸平其背脊猬刺！"
};

// 20. 钩吾贪食饕餮 (北山经 · 单格异律法相：有首无身·食人未咽害及其身)
::Wuxia.ShanHaiBossSpecs.taotie <- {
	Key = "taotie", Chapter = "北山经",
	TraitName = "有首无身·食人未咽害其身相",
	CanonQuote = "《吕氏春秋/北山经》：周鼎著饕餮，有首无身，食人未咽，害及其身；羊身人面，虎齿人爪。",
	TraitDesc = "单格贪食凶神：每次命中贪吞血气累积【饱食度（1~4）】；若误吞身染【奇毒】的毒饵猎物，或连续贪食叠满 4 层饱食度，当场应验『食人未咽，害及其身』——咽喉崩裂反噬自身 35~45 气血并陷【内伤+破绽】！",
	CounterHint = "故意让身带奇毒的单位诱其施展《吞天噬血狂咬》引爆毒饵裂腹，或举盾诱其贪吞满 4 层自爆！",
	StructureMode = "mythic_law",
	Headless = true,
	InitFieldKind = "blood_pool",
};

::Wuxia.ShanHaiBossMoves.wx_boss_taotie_glutton_devour <- {
	Name = "吞天噬血狂咬", Desc = "巨口将 1~2 格猎物强拽入怀狂噬汲血 32 点并叠饱食度（吞中带毒者当场裂腹反噬！）。",
	Geo = "pull_devour", AP = 5, Qi = 20, CD = 1, Field = "blood_pool",
	Hit = 14, Dmg = 1.24, Arm = 1.25, Pen = 0.12,
	BurnArm = 18, DrainQi = 12, DrainHP = 32, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_neigong_taotie.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_taotie_bronze_maw <- {
	Name = "虎齿裂鼎横扫", Desc = "人爪虎齿横扫扇形三格，崩毁重甲并溅洒【凶煞血池】。",
	Geo = "cone_3", AP = 5, Qi = 18, CD = 2, Field = "blood_pool",
	Hit = 12, Dmg = 1.18, Arm = 1.30, Pen = 0.08,
	BurnArm = 20, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_08", Icon = "skills/wx_saber_tuxiong.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_taotie_vortex_gorge <- {
	Name = "饕餮鲸吞万气", Desc = "大口倒吸强抽周身 6 格敌军 14 点内息与 18 点鲜血。",
	Geo = "ring_quake_6", AP = 4, Qi = 16, CD = 2, Field = "blood_pool",
	Hit = 10, Dmg = 1.10, Arm = 1.15, Pen = 0.08,
	BurnArm = 12, DrainQi = 14, DrainHP = 18, Status = "scatter",
	Vfx = "wx_vfx_19", Icon = "skills/wx_neigong_xixing.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_taotie <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_taotie",
	TraitID = "special.wx_boss_trait_taotie",
	Skills = ["scripts/skills/actives/wx_boss_taotie_glutton_devour", "scripts/skills/actives/wx_boss_taotie_bronze_maw", "scripts/skills/actives/wx_boss_taotie_vortex_gorge"],
	CounterHint = "故意让身带奇毒的单位诱其施展《吞天噬血狂咬》引爆毒饵裂腹，或举盾诱其贪吞满 4 层自爆！"
};

// 21. 弱水龙首猰貐 (北山经 · 单格异律法相：弱水沉兵 + 巫彭不死药逆命)
::Wuxia.ShanHaiBossSpecs.yayu <- {
	Key = "yayu", Chapter = "北山经",
	TraitName = "弱水沉羽·巫彭不死药逆命相",
	CanonQuote = "《海内西经/北山经》：猰貐龙首，居弱水中，食人；帝乃命巫彭操不死之药以距之，化为食人凶神。",
	TraitDesc = "单格堕落古神：周身萦绕鸿毛不浮的弱水寒气，令近战攻者每击额外沉耗 6 点内息；首次濒死凭体内残存巫彭不死药复苏 135 气血——唯以《断续封生印》或纯阳烈火斩杀可彻底焚灭死药！",
	CounterHint = "斩杀前施《钦原断续蚀壳膏》或以纯阳烈火收尾焚灭不死药，利刃斩断龙角可封其寒渊扑！",
	StructureMode = "mythic_law",
	RegenHP = 18,
	InitFieldKind = "abyss_frost",
	InternalPartKey = "yayu_horn", InternalPartName = "弱水逆命龙角", InternalPartType = "horn",
	InternalBreakMode = "blade", InternalBreakMax = 3, InternalLockedSkill = "actives.wx_boss_yayu_ruoshui_pounce",
};

::Wuxia.ShanHaiBossMoves.wx_boss_yayu_ruoshui_pounce <- {
	Name = "弱水寒渊锁脉扑", Desc = "挟弱水寒气跃扑 2~3 格封锁猎物经脉【点穴封气】（利刃断龙角即封印）。",
	Geo = "leap_slam_3", AP = 5, Qi = 18, CD = 2, Field = "abyss_frost",
	Hit = 14, Dmg = 1.22, Arm = 1.20, Pen = 0.12,
	BurnArm = 16, DrainQi = 10, DrainHP = 0, Status = "acupoint",
	Vfx = "wx_vfx_21", Icon = "skills/wx_fist_xuanming.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_yayu_dragon_claw <- {
	Name = "少咸噬骨龙爪", Desc = "龙首凶威撕裂前方三格血肉，汲血 18 点并造成流血。",
	Geo = "cone_3", AP = 5, Qi = 18, CD = 1, Field = "",
	Hit = 13, Dmg = 1.18, Arm = 1.20, Pen = 0.10,
	BurnArm = 14, DrainQi = 0, DrainHP = 18, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_fist_jiuyin.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_yayu_undying_pulse <- {
	Name = "巫彭死药邪潮", Desc = "体内残余不死神药逆冲爆散，震伤周身 6 格脏腑并散功。",
	Geo = "ring_quake_6", AP = 4, Qi = 16, CD = 2, Field = "abyss_frost",
	Hit = 10, Dmg = 1.12, Arm = 1.15, Pen = 0.08,
	BurnArm = 10, DrainQi = 10, DrainHP = 20, Status = "scatter",
	Vfx = "wx_vfx_30", Icon = "skills/wx_neigong_wudu.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_yayu <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_yayu",
	TraitID = "special.wx_boss_trait_yayu",
	Skills = ["scripts/skills/actives/wx_boss_yayu_ruoshui_pounce", "scripts/skills/actives/wx_boss_yayu_dragon_claw", "scripts/skills/actives/wx_boss_yayu_undying_pulse"],
	CounterHint = "斩杀前施《钦原断续蚀壳膏》或以纯阳烈火收尾焚灭不死药，利刃斩断龙角可封其寒渊扑！"
};

// 22. 天山歌舞帝江 (北山经 · 1+3 天山歌舞空间裂隙阵眼)
::Wuxia.ShanHaiBossSpecs.dijiang <- {
	Key = "dijiang", Chapter = "北山经",
	TraitName = "丹火六足·天山歌舞移空相",
	CanonQuote = "《西山经》：天山，有神焉，其状如黄囊，赤如丹火，六足四翼，浑敦无面目，是识歌舞，实惟帝江也。",
	TraitDesc = "识歌舞通空间之天山异神：开场撕开 3 道悬鸣钟磬的【天山歌舞空间裂隙】，赋予 48% 实伤减免，且每轮受近战攻击自动踏着舞步与空间裂隙移形换位！唯有先行踏碎 3 道空间裂隙方可锚定真身！",
	CounterHint = "分兵优先击碎 3 道【天山歌舞空间裂隙】剥夺其减伤与移形坐标，以狮子吼清散迷障！",
	StructureMode = "totems",
	MinAP = 10,
	Headless = true,
	DefaultTotemCount = 3, TotemShieldPerUnit = 0.16,
	InitFieldKind = "mirage_mist",
	Parts = [
		{ Key = "rift_1", Name = "天山歌舞空间裂隙·宫音", HP = 75, Brush = "wx_totem_space_rift" },
		{ Key = "rift_2", Name = "天山歌舞空间裂隙·商音", HP = 75, Brush = "wx_totem_space_rift" },
		{ Key = "rift_3", Name = "天山歌舞空间裂隙·羽音", HP = 75, Brush = "wx_totem_space_rift" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_dijiang_warp_shift <- {
	Name = "六足踏歌移空", Desc = "循太古舞步与场上【歌舞空间裂隙】瞬息换位，在原地留下迷障。",
	Geo = "totem_swap", AP = 3, Qi = 12, CD = 2, Field = "mirage_mist",
	Hit = 0, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 0, DrainHP = 0, Status = "",
	Vfx = "wx_vfx_26", Icon = "skills/wx_qinggong_suodi.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_dijiang_song_ripple <- {
	Name = "识歌乱神弦光", Desc = "引动空间裂隙钟磬齐鸣激射丹霞音刃，震散连线敌军真气【散功虚弱】。",
	Geo = "totem_ray", AP = 5, Qi = 18, CD = 2, Field = "mirage_mist",
	Hit = 14, Dmg = 1.16, Arm = 1.15, Pen = 0.12,
	BurnArm = 12, DrainQi = 12, DrainHP = 0, Status = "scatter",
	Vfx = "wx_vfx_26", Icon = "skills/wx_neigong_douzhuan.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_dijiang_six_wing_gust <- {
	Name = "四翼丹火旋舞", Desc = "四翼掀起赤丹气浪横扫扇形三格致敌失衡。",
	Geo = "cone_3", AP = 4, Qi = 16, CD = 1, Field = "",
	Hit = 12, Dmg = 1.15, Arm = 1.20, Pen = 0.08,
	BurnArm = 14, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_29", Icon = "skills/wx_qinggong_lingbo.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_dijiang <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_dijiang",
	TraitID = "special.wx_boss_trait_dijiang",
	Skills = ["scripts/skills/actives/wx_boss_dijiang_warp_shift", "scripts/skills/actives/wx_boss_dijiang_song_ripple", "scripts/skills/actives/wx_boss_dijiang_six_wing_gust"],
	CounterHint = "分兵优先击碎 3 道【天山歌舞空间裂隙】剥夺其减伤与移形坐标，以狮子吼清散迷障！"
};

// 23. 钩吾腋目狍鸮 (北山经 · 单格异律法相：目在腋下 · 挥爪露目一击刺瞎)
::Wuxia.ShanHaiBossSpecs.paoxiaowang <- {
	Key = "paoxiaowang", Chapter = "北山经",
	TraitName = "目在腋下·挥爪露目破绽相",
	CanonQuote = "《北山经》：钩吾之山，有兽焉，羊身人面，其目在腋下，虎齿人爪，其音如婴儿，名曰狍鸮，是食人。",
	TraitDesc = "单格腋下生目凶祖：双臂垂护时腋目洞察八方（近防+14、免合围惩罚）；但每当其挥起双臂施展《人爪虎齿噬脏咬》后，双腋邪瞳将彻底暴露 1 回合——此时以刺剑/短匕/弓弩/点穴直刺双腋，当场打出 +40% 暴伤并永久刺瞎邪瞳（近防倒扣-14）！",
	CounterHint = "举盾诱其挥爪使出《人爪虎齿噬脏咬》露出双腋，立即以短匕/刺剑/神射一击刺瞎腋下邪瞳！",
	StructureMode = "mythic_law",
	Headless = true,
	InternalPartKey = "armpit_eyes", InternalPartName = "双腋窥世邪瞳", InternalPartType = "core",
	InternalBreakMode = "ranged_or_acupoint", InternalBreakMax = 3, InternalLockedSkill = "actives.wx_boss_paoxiaowang_armpit_beam",
};

::Wuxia.ShanHaiBossMoves.wx_boss_paoxiaowang_armpit_beam <- {
	Name = "双腋邪瞳破绽光", Desc = "双胁巨目陡张射出摄魄凶光横扫三格，尽破敌军架势（刺瞎双腋邪瞳即永久封印）。",
	Geo = "cone_3", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 14, Dmg = 1.16, Arm = 1.20, Pen = 0.10,
	BurnArm = 14, DrainQi = 8, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_30", Icon = "skills/wx_tactics_guigu.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_paoxiaowang_tiger_fang <- {
	Name = "人爪虎齿噬脏咬", Desc = "双臂大张擒拿猎物噬咬汲血 25 点（收招后双腋邪瞳暴露 1 回合破绽窗！）。",
	Geo = "pull_devour", AP = 5, Qi = 20, CD = 2, Field = "blood_pool",
	Hit = 13, Dmg = 1.22, Arm = 1.25, Pen = 0.12,
	BurnArm = 18, DrainQi = 8, DrainHP = 25, Status = "injury",
	Vfx = "wx_vfx_08", Icon = "skills/wx_fist_longzhao.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_paoxiaowang_infant_shriek <- {
	Name = "钩吾夜婴惊魂啼", Desc = "发出诡异婴儿啼哭震荡周身 6 格战意。",
	Geo = "ring_quake_6", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 10, Dmg = 1.08, Arm = 1.10, Pen = 0.05,
	BurnArm = 8, DrainQi = 10, DrainHP = 0, Status = "shaken",
	Vfx = "wx_vfx_30", Icon = "skills/wx_tactics_shihou.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_paoxiaowang <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_paoxiaowang",
	TraitID = "special.wx_boss_trait_paoxiaowang",
	Skills = ["scripts/skills/actives/wx_boss_paoxiaowang_armpit_beam", "scripts/skills/actives/wx_boss_paoxiaowang_tiger_fang", "scripts/skills/actives/wx_boss_paoxiaowang_infant_shriek"],
	CounterHint = "举盾诱其挥爪使出《人爪虎齿噬脏咬》露出双腋，立即以短匕/刺剑/神射一击刺瞎腋下邪瞳！"
};

// 24. 小侯四耳长右 (北山经 · 单格异律法相：四耳听弦避矢 vs 狮吼雷铳震聋)
::Wuxia.ShanHaiBossSpecs.changyou <- {
	Key = "changyou", Chapter = "北山经",
	TraitName = "状如禺四耳·听弦避矢漫水相",
	CanonQuote = "《东山/北山经》：有兽焉，其状如禺而四耳，其名长右，其音如吟，见则郡县大水。",
	TraitDesc = "单格四耳水猿：四耳未聋时未卜先听弓弦，远防+26且所受远程伤害直减 55%；唯以《狮吼功》《夔牛震天鼓》或《神机火铳》巨响震聋其四耳 2 回合，令其耳鸣头眩（双防倒扣 -12）！",
	CounterHint = "切勿直接开弓刮痧！先吼一嗓子《狮吼功/夔牛鼓》或轰一发火铳震聋其四耳，再集火输出！",
	StructureMode = "mythic_law",
	RegenHP = 15,
	InitFieldKind = "abyss_frost",
};

::Wuxia.ShanHaiBossMoves.wx_boss_changyou_deluge_palm <- {
	Name = "郡县大水寒潮掌", Desc = "双掌掀起滔天寒水拍击扇形三格，铺设【玄冥冻土】并震散真气。",
	Geo = "cone_3", AP = 5, Qi = 18, CD = 1, Field = "abyss_frost",
	Hit = 12, Dmg = 1.16, Arm = 1.20, Pen = 0.08,
	BurnArm = 14, DrainQi = 14, DrainHP = 0, Status = "scatter",
	Vfx = "wx_vfx_21", Icon = "skills/wx_fist_nuchao.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_changyou_four_ear_echo <- {
	Name = "四耳听涛悲吟", Desc = "四耳共振发如人呻吟之低频水音，抽耗敌军 14 内息致失衡。",
	Geo = "sonic_roar", AP = 4, Qi = 15, CD = 2, Field = "abyss_frost",
	Hit = 10, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 14, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_21", Icon = "skills/wx_neigong_chaoxi.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_changyou_flood_surge <- {
	Name = "寒泽漫灌冰爆", Desc = "引爆全场【玄冥冻土】寒泉冻结踏冰敌手经脉【点穴封气】。",
	Geo = "field_detonate", AP = 5, Qi = 20, CD = 3, Field = "abyss_frost",
	Hit = 12, Dmg = 1.18, Arm = 1.15, Pen = 0.10,
	BurnArm = 12, DrainQi = 10, DrainHP = 0, Status = "acupoint",
	Vfx = "wx_vfx_21", Icon = "skills/wx_neigong_hanbing.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_changyou <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_changyou",
	TraitID = "special.wx_boss_trait_changyou",
	Skills = ["scripts/skills/actives/wx_boss_changyou_deluge_palm", "scripts/skills/actives/wx_boss_changyou_four_ear_echo", "scripts/skills/actives/wx_boss_changyou_flood_surge"],
	CounterHint = "切勿直接开弓刮痧！先吼一嗓子《狮吼功/夔牛鼓》或轰一发火铳震聋其四耳，再集火输出！"
};

// 25. 石者山白豹孟极 (北山经 · 单格异律法相：雾隐善伏刺破绽)
::Wuxia.ShanHaiBossSpecs.mengji <- {
	Key = "mengji", Chapter = "北山经",
	TraitName = "文题白身·雾隐善伏奇袭相",
	CanonQuote = "《北山经》：石者之山，有兽焉，其状如豹，而文题白身，名曰孟极，是善伏，其鸣自呼。",
	TraitDesc = "单格善伏白豹皇：隐于【青丘迷障】中时双防暴涨（近防+18、远防+22），对带有【破绽/失衡】的猎物总伤提升 28%；一旦迷障被《狮吼功/八门金锁/醒心香》驱散，白豹无所遁形（近防反跌 -10）！",
	CounterHint = "以《狮吼功/八门金锁阵/白泽破妄香》荡清迷障逼出真身，稳固阵型清除破绽！",
	StructureMode = "mythic_law",
	MinAP = 11,
	InitFieldKind = "mirage_mist",
};

::Wuxia.ShanHaiBossMoves.wx_boss_mengji_ambush_pounce <- {
	Name = "石者善伏匿影扑", Desc = "自迷雾中暴起跃扑 2~3 格目标撕开甲缝挂【破绽】。",
	Geo = "leap_slam_3", AP = 4, Qi = 16, CD = 1, Field = "mirage_mist",
	Hit = 16, Dmg = 1.20, Arm = 1.20, Pen = 0.12,
	BurnArm = 14, DrainQi = 0, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_25", Icon = "skills/wx_dagger_yingci.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_mengji_white_claw <- {
	Name = "文题白豹断脉抓", Desc = "迅疾利爪连抓要害，对破绽猎物爆出致命割裂流血。",
	Geo = "single", AP = 4, Qi = 14, CD = 1, Field = "",
	Hit = 15, Dmg = 1.18, Arm = 1.15, Pen = 0.12,
	BurnArm = 12, DrainQi = 6, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_dagger_jingke.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_mengji_self_call_mist <- {
	Name = "其鸣自呼迷踪雾", Desc = "长啸一声『孟极』唤起石雾遮天蔽日，令近敌失衡。",
	Geo = "sonic_roar", AP = 3, Qi = 12, CD = 2, Field = "mirage_mist",
	Hit = 10, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_25", Icon = "skills/wx_smoke_cast.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_mengji <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_mengji",
	TraitID = "special.wx_boss_trait_mengji",
	Skills = ["scripts/skills/actives/wx_boss_mengji_ambush_pounce", "scripts/skills/actives/wx_boss_mengji_white_claw", "scripts/skills/actives/wx_boss_mengji_self_call_mist"],
	CounterHint = "以《狮吼功/八门金锁阵/白泽破妄香》荡清迷障逼出真身，稳固阵型清除破绽！"
};

// 26. 东海流波山夔牛 (东山经 · 1+2 东海流波引雷水漩阵眼)
::Wuxia.ShanHaiBossSpecs.kui <- {
	Key = "kui", Chapter = "东山经",
	TraitName = "苍身一足·日月雷音连环导",
	CanonQuote = "《大荒东经》：东海中有流波山，有兽焉，状如牛，苍身而无角，一足，出入水则必风雨，其光如日月，其声如雷，其名曰夔。",
	TraitDesc = "流波山太古雷兽：开场召出 2 眼【东海流波引雷水漩】并降下雷暴；每次攻击会向受击者相邻格所有同袍跳跃传导 14 点紫电雷伤！全队散开站位避免连环导电，优先击毁 2 眼引雷水漩破其雷域护障！",
	CounterHint = "全员间隔 1 格散开站位断绝紫电连环跳跃，分兵击毁 2 眼【东海流波引雷水漩】！",
	StructureMode = "totems",
	Headless = true,
	ImmuneStun = true,
	DefaultTotemCount = 2, TotemShieldPerUnit = 0.18,
	InitFieldKind = "thunder_pool",
	TurnFieldKind = "thunder_pool",
	InitWeather = "kui_thunderstorm",
	Parts = [
		{ Key = "thunder_eye_1", Name = "东海流波引雷水漩·东渊", HP = 90, Brush = "wx_totem_thunder_vortex" },
		{ Key = "thunder_eye_2", Name = "东海流波引雷水漩·西溟", HP = 90, Brush = "wx_totem_thunder_vortex" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_kui_one_foot_thunder <- {
	Name = "独足踏海落九雷", Desc = "苍身一足重顿大地引九天紫电轰炸周身 6 格，化为【流波雷池】并崩甲22点。",
	Geo = "ring_quake_6", AP = 5, Qi = 20, CD = 2, Field = "thunder_pool",
	Hit = 12, Dmg = 1.22, Arm = 1.35, Pen = 0.10,
	BurnArm = 22, DrainQi = 10, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_14", Icon = "skills/wx_hammer_leiting.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_kui_sun_moon_glare <- {
	Name = "光如日月贯雷线", Desc = "胸发日月强光联通场上【流波引雷水漩】激射高压电弧。",
	Geo = "totem_ray", AP = 5, Qi = 18, CD = 2, Field = "thunder_pool",
	Hit = 14, Dmg = 1.20, Arm = 1.25, Pen = 0.12,
	BurnArm = 18, DrainQi = 10, DrainHP = 0, Status = "scatter",
	Vfx = "wx_vfx_14", Icon = "skills/wx_tactics_kuiniu.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_kui_storm_drum <- {
	Name = "声如雷霆五百里", Desc = "黄帝皮鼓之源！巨吼引爆全场【流波雷池】麻痹震碎敌胆。",
	Geo = "field_detonate", AP = 5, Qi = 22, CD = 3, Field = "thunder_pool",
	Hit = 12, Dmg = 1.20, Arm = 1.25, Pen = 0.10,
	BurnArm = 16, DrainQi = 12, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_17", Icon = "skills/wx_hammer_polu.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_kui <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_kui",
	TraitID = "special.wx_boss_trait_kui",
	Skills = ["scripts/skills/actives/wx_boss_kui_one_foot_thunder", "scripts/skills/actives/wx_boss_kui_sun_moon_glare", "scripts/skills/actives/wx_boss_kui_storm_drum"],
	CounterHint = "全员间隔 1 格散开站位断绝紫电连环跳跃，分兵击毁 2 眼【东海流波引雷水漩】！"
};

// 27. 太山大疫灾兽蜚 (东山经 · 单格异律法相：枯水死草大疫 vs 纯阳烈火焚疫)
::Wuxia.ShanHaiBossSpecs.fei <- {
	Key = "fei", Chapter = "东山经",
	TraitName = "行水则竭·行草则死大疫相",
	CanonQuote = "《东山经》：太山，有兽焉，其状如牛而白首，一目而蛇尾，其名曰蜚，行水则竭，行草则死，见则天下大疫。",
	TraitDesc = "单格太山大疫灾兽：周身 3 格笼罩『枯水绝草』疫障（每回合抽干敌军 6 内息并步步漫溢苦毒腐泽）；唯【纯阳内功/烈火刀法/火龙铳】可触发『烈火焚疫』（对蜚造成 +28% 净化暴伤并当场烧净脚下毒泽），快刃断尾可封大疫扫！",
	CounterHint = "战前服《清心辟瘴丹》，主攻手运纯阳内功或持《燃木刀/火龙铳》烈火焚疫享 +28% 克制伤！",
	StructureMode = "mythic_law",
	Headless = true,
	ImmuneStun = true,
	InitFieldKind = "bitter_mire",
	TurnFieldKind = "bitter_mire",
	InternalPartKey = "plague_tail", InternalPartName = "太山大疫毒蛇尾", InternalPartType = "tail",
	InternalBreakMode = "blade", InternalBreakMax = 3, InternalLockedSkill = "actives.wx_boss_fei_serpent_tail",
};

::Wuxia.ShanHaiBossMoves.wx_boss_fei_wither_plague <- {
	Name = "枯水死草绝命瘴", Desc = "独目喷涌灰绿大疫尸瘴席卷扇形三格，铺设【苦毒腐泽】并染奇毒。",
	Geo = "cone_3", AP = 5, Qi = 18, CD = 1, Field = "bitter_mire",
	Hit = 12, Dmg = 1.16, Arm = 1.20, Pen = 0.10,
	BurnArm = 16, DrainQi = 10, DrainHP = 0, Status = "poison",
	Vfx = "wx_vfx_22", Icon = "skills/wx_neigong_wudu.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_fei_serpent_tail <- {
	Name = "蛇尾天下大疫扫", Desc = "甩动毒蛇长尾抽击侧后三格重创脏腑（利刃斩断毒蛇尾即永久封印）。",
	Geo = "tail_sweep_arc", AP = 5, Qi = 18, CD = 2, Field = "bitter_mire",
	Hit = 12, Dmg = 1.20, Arm = 1.20, Pen = 0.10,
	BurnArm = 14, DrainQi = 8, DrainHP = 0, Status = "injury",
	Vfx = "wx_vfx_22", Icon = "skills/wx_whip_suohou.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_fei_cyclops_ram <- {
	Name = "白首独目枯泽冲", Desc = "牛躯狂冲直线 3 格碾开阵线。",
	Geo = "line_charge_3", AP = 5, Qi = 20, CD = 2, Field = "bitter_mire",
	Hit = 13, Dmg = 1.22, Arm = 1.30, Pen = 0.08,
	BurnArm = 20, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_axe_poche.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_fei <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_fei",
	TraitID = "special.wx_boss_trait_fei",
	Skills = ["scripts/skills/actives/wx_boss_fei_wither_plague", "scripts/skills/actives/wx_boss_fei_serpent_tail", "scripts/skills/actives/wx_boss_fei_cyclops_ram"],
	CounterHint = "战前服《清心辟瘴丹》，主攻手运纯阳内功或持《燃木刀/火龙铳》烈火焚疫享 +28% 克制伤！"
};

// 28. 凶犁折翼应龙 (东山经 · 三格上古真龙躯：龙首 + 折翼青金逆鳞躯 + 画地蓄水尾)
::Wuxia.ShanHaiBossSpecs.yinglong <- {
	Key = "yinglong", Chapter = "东山经",
	TraitName = "画地成江·不得复上下数旱躯",
	CanonQuote = "《大荒东经》：应龙处南极，杀蚩尤与夸父，不得复上，故下数旱。《天问》：应龙何画？河海何历？",
	TraitDesc = "三格真龙战魂（真龙首 + 折翼逆鳞躯 + 画地蓄水尾）：立于自身所画【玄冥寒江】水脉上时近防+14、总伤+18%；若用烈火将其脚下水脉蒸干化为【赤旱焦土】，应验『不得复上·下数旱』（近防反跌-12）！碎躯断尾可逐一封印龙爪与摆尾！",
	CounterHint = "以纯阳烈火/火器蒸发应龙脚下寒江令其陷入『失水旱困』，重兵分段击碎【折翼逆鳞躯】与【蓄水尾】！",
	StructureMode = "segments",
	Headless = true,
	InitFieldKind = "abyss_frost",
	Parts = [
		{ Key = "wing_body", Name = "应龙·折翼青金逆鳞躯", BodyArmor = 270, HeadArmor = 200, MeleeDef = 12, Brush = "wx_part_yinglong_body", LockedSkillID = "actives.wx_boss_yinglong_slay_demon_claw" },
		{ Key = "river_tail", Name = "应龙·画地成江蓄水尾", BodyArmor = 230, HeadArmor = 170, MeleeDef = 14, Brush = "wx_tail_yinglong", LockedSkillID = "actives.wx_boss_yinglong_coiled_tail" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_yinglong_draw_river <- {
	Name = "画地成江沧溟息", Desc = "以龙爪画地引九渊寒水贯穿直线 3 格，铺设寒江水脉并封锁气穴【点穴封气】。",
	Geo = "line_pierce_3", AP = 5, Qi = 20, CD = 2, Field = "abyss_frost",
	Hit = 15, Dmg = 1.22, Arm = 1.25, Pen = 0.14,
	BurnArm = 20, DrainQi = 10, DrainHP = 0, Status = "acupoint",
	Vfx = "wx_vfx_21", Icon = "skills/wx_spear_xuelong.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_yinglong_slay_demon_claw <- {
	Name = "斩蚩尤破魔龙爪", Desc = "昔斩兵主之神爪横裂前方三格重铠（击碎折翼青金逆鳞躯即永久封印）。",
	Geo = "cone_3", AP = 5, Qi = 20, CD = 1, Field = "",
	Hit = 15, Dmg = 1.25, Arm = 1.35, Pen = 0.12,
	BurnArm = 24, DrainQi = 6, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_03", Icon = "skills/wx_fist_longzhao.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_yinglong_coiled_tail <- {
	Name = "凶犁坠天盘龙尾", Desc = "蓄水巨尾横扫扇形三格震飞群敌（击碎画地蓄水尾即永久封印）。",
	Geo = "tail_sweep_arc", AP = 4, Qi = 16, CD = 2, Field = "abyss_frost",
	Hit = 13, Dmg = 1.18, Arm = 1.25, Pen = 0.08,
	BurnArm = 16, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_21", Icon = "skills/wx_pole_sweep.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_yinglong <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_yinglong",
	TraitID = "special.wx_boss_trait_yinglong",
	Skills = ["scripts/skills/actives/wx_boss_yinglong_draw_river", "scripts/skills/actives/wx_boss_yinglong_slay_demon_claw", "scripts/skills/actives/wx_boss_yinglong_coiled_tail"],
	CounterHint = "以纯阳烈火/火器蒸发应龙脚下寒江令其陷入『失水旱困』，重兵分段击碎【折翼逆鳞躯】与【蓄水尾】！"
};

// 29. 西荒傲狠檮杌 (东山经 · 单格异律法相：死战不退越伤越狂 + 断丈八尾)
::Wuxia.ShanHaiBossSpecs.taowu <- {
	Key = "taowu", Chapter = "东山经",
	TraitName = "尾长丈八·傲狠死战不退相",
	CanonQuote = "《神异经》：西方荒中有兽焉，其状如虎而犬毛，人面虎足猪口牙，尾长一丈八尺，搅乱荒中，名檮杌。",
	TraitDesc = "单格四大凶兽檮杌：傲狠死战绝不动摇免控免缴械，每损失 18% 气血便永久叠 1 重【傲狠凶威】（武艺+5、总伤+8%，残血凶猛绝伦！）；唯以《太极剑/斗转星移》借力打力反制其重击，并用刀斧削断丈八长尾封其横扫！",
	CounterHint = "残血阶段切忌硬拼！以《太极化劲/斗转星移》借力偏转其高额凶威，快刀先断丈八虎尾！",
	StructureMode = "mythic_law",
	Headless = true,
	ImmuneStun = true,
	ImmuneDisarm = true,
	InternalPartKey = "long_tail", InternalPartName = "一丈八尺铁虎尾", InternalPartType = "tail",
	InternalBreakMode = "blade", InternalBreakMax = 3, InternalLockedSkill = "actives.wx_boss_taowu_eighteen_tail",
};

::Wuxia.ShanHaiBossMoves.wx_boss_taowu_eighteen_tail <- {
	Name = "丈八虎尾搅荒扫", Desc = "一丈八尺巨尾如铁柱横扫三格震飞前排（刀斧削断丈八虎尾即永久封印）。",
	Geo = "tail_sweep_arc", AP = 5, Qi = 18, CD = 1, Field = "",
	Hit = 14, Dmg = 1.22, Arm = 1.30, Pen = 0.08,
	BurnArm = 20, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_staff_zhenjiang.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_taowu_boar_tusk_gore <- {
	Name = "猪口獠牙碎脏冲", Desc = "顶起凶牙直线狂冲 3 格撞碎护心镜致【内伤】。",
	Geo = "line_charge_3", AP = 5, Qi = 20, CD = 2, Field = "blood_pool",
	Hit = 14, Dmg = 1.24, Arm = 1.30, Pen = 0.12,
	BurnArm = 22, DrainQi = 6, DrainHP = 0, Status = "injury",
	Vfx = "wx_vfx_08", Icon = "skills/wx_saber_chiyou.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_taowu_unruly_frenzy <- {
	Name = "傲狠不退裂骨爪", Desc = "死战狂爪疯狂撕扯近敌造成深创流血。",
	Geo = "single", AP = 4, Qi = 15, CD = 1, Field = "",
	Hit = 15, Dmg = 1.20, Arm = 1.20, Pen = 0.10,
	BurnArm = 16, DrainQi = 0, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_saber_tuxiong.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_taowu <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_taowu",
	TraitID = "special.wx_boss_trait_taowu",
	Skills = ["scripts/skills/actives/wx_boss_taowu_eighteen_tail", "scripts/skills/actives/wx_boss_taowu_boar_tusk_gore", "scripts/skills/actives/wx_boss_taowu_unruly_frenzy"],
	CounterHint = "残血阶段切忌硬拼！以《太极化劲/斗转星移》借力偏转其高额凶威，快刀先断丈八虎尾！"
};

// 30. 泿水四足虎蛟 (东山经 · 双格盘蛟躯：蛟首 + 四足虎纹盘蛟躯)
::Wuxia.ShanHaiBossSpecs.hujiao <- {
	Key = "hujiao", Chapter = "东山经",
	TraitName = "鱼身蛇尾·食者不肿盘蛟躯",
	CanonQuote = "《南山/东山》：祷过之山，泿水出焉，其中有虎蛟，其状鱼身而蛇尾，其音如鸳鸯，食者不肿。",
	TraitDesc = "泿水双格毒蛟（蛟首 + 四足虎纹盘蛟躯）：对中毒目标缠绞伤害暴涨 +25%；重兵打碎其【四足虎纹盘蛟躯】，不仅永久封印毒涧抓投绞杀，更应验『食者不肿』迸发蛟脂清净周遭友军奇毒！",
	CounterHint = "集火打碎后段【四足虎纹盘蛟躯】封印抓投并触发清毒蛟脂，备百草解毒散护前排！",
	StructureMode = "segments",
	InitFieldKind = "bitter_mire",
	Parts = [
		{ Key = "tiger_coil", Name = "虎蛟·四足虎纹盘蛟躯", BodyArmor = 215, HeadArmor = 150, MeleeDef = 10, Brush = "wx_part_hujiao_coil", LockedSkillID = "actives.wx_boss_hujiao_mire_coil" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_hujiao_mire_coil <- {
	Name = "四足虎爪缠涧绞", Desc = "四足毒爪将 1~2 格猎物拖入毒涧死死盘绞汲血 16 点（击碎虎纹盘蛟躯即封印并净毒）。",
	Geo = "pull_devour", AP = 5, Qi = 18, CD = 2, Field = "bitter_mire",
	Hit = 14, Dmg = 1.18, Arm = 1.20, Pen = 0.10,
	BurnArm = 16, DrainQi = 8, DrainHP = 16, Status = "opening",
	Vfx = "wx_vfx_22", Icon = "skills/wx_fist_grapple.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_hujiao_venom_fang <- {
	Name = "玉涧透甲双毒牙", Desc = "毒牙直透铁甲缝隙注入奇毒并伤及内腑。",
	Geo = "single", AP = 4, Qi = 15, CD = 1, Field = "bitter_mire",
	Hit = 14, Dmg = 1.18, Arm = 1.25, Pen = 0.14,
	BurnArm = 14, DrainQi = 6, DrainHP = 0, Status = "poison",
	Vfx = "wx_vfx_22", Icon = "skills/wx_flail_jinshe.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_hujiao_tail_splash <- {
	Name = "鱼身蛇尾毒浪拍", Desc = "蛇尾拍击泥潭激起扇形三格毒浪致内伤。",
	Geo = "cone_3", AP = 4, Qi = 16, CD = 2, Field = "bitter_mire",
	Hit = 12, Dmg = 1.12, Arm = 1.15, Pen = 0.08,
	BurnArm = 12, DrainQi = 6, DrainHP = 0, Status = "injury",
	Vfx = "wx_vfx_22", Icon = "skills/wx_saber_zhanlang.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_hujiao <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_hujiao",
	TraitID = "special.wx_boss_trait_hujiao",
	Skills = ["scripts/skills/actives/wx_boss_hujiao_mire_coil", "scripts/skills/actives/wx_boss_hujiao_venom_fang", "scripts/skills/actives/wx_boss_hujiao_tail_splash"],
	CounterHint = "集火打碎后段【四足虎纹盘蛟躯】封印抓投并触发清毒蛟脂，备百草解毒散护前排！"
};

// 31. 北岳四角诸怀 (东山经 · 单格异律法相：鸣雁嗜血追创 + 重锤断四角)
::Wuxia.ShanHaiBossSpecs.zhuhuai <- {
	Key = "zhuhuai", Chapter = "东山经",
	TraitName = "四角人目·鸣雁嗜血狂冲相",
	CanonQuote = "《北山经》：北岳之山，有兽焉，其状如牛，而四角、人目、彘耳，其名曰诸怀，其音如鸣雁，是食人。",
	TraitDesc = "单格北岳四角凶牛：嗅血狂暴——攻击正在【流血】的猎物时武艺+14、总伤+22%，首杀立返 2 AP 并狂回 35 气血！及时用绷带/金创药止血断其血怒，并以重锤敲断额上四角封印崩城狂冲！",
	CounterHint = "及时包扎止住流血伤口勿给其嗜血加成，重锤正面猛砸敲断其【北岳四巨角】！",
	StructureMode = "mythic_law",
	Headless = true,
	ImmuneStun = true,
	KillRefundAP = 2, KillHealHP = 35,
	InternalPartKey = "four_horns", InternalPartName = "北岳裂阵四巨角", InternalPartType = "horn",
	InternalBreakMode = "blunt", InternalBreakMax = 2, InternalLockedSkill = "actives.wx_boss_zhuhuai_four_horn_ram",
};

::Wuxia.ShanHaiBossMoves.wx_boss_zhuhuai_four_horn_ram <- {
	Name = "四角崩城狂冲", Desc = "低首挺出四根巨角直线冲撞 3 格崩毁24点护甲（重锤砸断四角即永久封印）。",
	Geo = "line_charge_3", AP = 5, Qi = 20, CD = 2, Field = "",
	Hit = 14, Dmg = 1.24, Arm = 1.35, Pen = 0.10,
	BurnArm = 24, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_pole_pojun.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_zhuhuai_goose_cry <- {
	Name = "音如鸣雁夺魄啸", Desc = "发诡异孤雁长鸣扰乱敌军心智，暴露【破绽】。",
	Geo = "sonic_roar", AP = 3, Qi = 14, CD = 2, Field = "",
	Hit = 10, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 10, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_17", Icon = "skills/wx_tactics_kuiniu.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_zhuhuai_man_eater <- {
	Name = "彘耳人目噬生咬", Desc = "凶残撕咬近敌汲取 24 点鲜血并致流血。",
	Geo = "single", AP = 4, Qi = 15, CD = 1, Field = "blood_pool",
	Hit = 14, Dmg = 1.18, Arm = 1.20, Pen = 0.10,
	BurnArm = 14, DrainQi = 0, DrainHP = 24, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_axe_xueming.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_zhuhuai <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_zhuhuai",
	TraitID = "special.wx_boss_trait_zhuhuai",
	Skills = ["scripts/skills/actives/wx_boss_zhuhuai_four_horn_ram", "scripts/skills/actives/wx_boss_zhuhuai_goose_cry", "scripts/skills/actives/wx_boss_zhuhuai_man_eater"],
	CounterHint = "及时包扎止住流血伤口勿给其嗜血加成，重锤正面猛砸敲断其【北岳四巨角】！"
};

// 32. 奢比之尸 (东山经 · 三格共生：不腐古尸主躯 + 左右双耳两巨青蛇)
::Wuxia.ShanHaiBossSpecs.shebishi <- {
	Key = "shebishi", Chapter = "东山经",
	TraitName = "犬耳珥两青蛇·双蛇渡生古尸",
	CanonQuote = "《海外东经/大荒东经》：奢比之尸在其北，兽身、人面、大耳，珥两青蛇。",
	TraitDesc = "三格共生古尸神：死躯免毒免点穴，左右双耳盘踞 2 条独立共生【珥耳巨青蛇】源源不断渡入生机（每存 1 蛇每轮回血 13 点）；同时斩毙左右两条巨青蛇，不仅彻底断绝再生与毒瘴，更当场抽走奢比尸 20% 尸元气血！",
	CounterHint = "双翼刀剑齐出，优先斩灭左右 2 条独立【珥耳巨青蛇】断其渡生回血并重创尸元！",
	StructureMode = "appendages",
	Headless = true,
	ImmuneStun = true,
	RegenHP = 26,
	SeverSpillField = "bitter_mire",
	Parts = [
		{ Key = "snake_l", Name = "奢比尸·左耳珥巨青蛇", HP = 105, BodyArmor = 110, HeadArmor = 100, MeleeDef = 12, Brush = "wx_part_cyan_serpent", LockedSkillID = "actives.wx_boss_shebishi_twin_serpents" },
		{ Key = "snake_r", Name = "奢比尸·右耳珥巨青蛇", HP = 105, BodyArmor = 110, HeadArmor = 100, MeleeDef = 12, Brush = "wx_part_cyan_serpent", LockedSkillID = "actives.wx_boss_shebishi_miasma_burst" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_shebishi_twin_serpents <- {
	Name = "贯耳双青蛇攒噬", Desc = "双耳巨青蛇电射噬咬 1~3 格目标注入尸毒（斩左耳巨青蛇即永久封印）。",
	Geo = "ranged_barrage", AP = 4, Qi = 15, CD = 1, Field = "bitter_mire",
	Hit = 14, Dmg = 1.16, Arm = 1.15, Pen = 0.12,
	BurnArm = 12, DrainQi = 8, DrainHP = 18, Status = "poison",
	Vfx = "wx_vfx_22", Icon = "skills/wx_whip_suohou.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_shebishi_corpse_claw <- {
	Name = "大荒古尸裂胸爪", Desc = "兽身尸爪横扫三格吸取 22 点生机气血。",
	Geo = "cone_3", AP = 5, Qi = 18, CD = 1, Field = "",
	Hit = 13, Dmg = 1.20, Arm = 1.25, Pen = 0.08,
	BurnArm = 18, DrainQi = 6, DrainHP = 22, Status = "offbalance",
	Vfx = "wx_vfx_08", Icon = "skills/wx_fist_jiuyin.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_shebishi_miasma_burst <- {
	Name = "青蛇腐尸瘴爆", Desc = "催发尸腐毒雾轰击周身 6 格（斩右耳巨青蛇即永久封印）。",
	Geo = "ring_quake_6", AP = 4, Qi = 16, CD = 2, Field = "bitter_mire",
	Hit = 10, Dmg = 1.12, Arm = 1.15, Pen = 0.08,
	BurnArm = 14, DrainQi = 10, DrainHP = 0, Status = "poison",
	Vfx = "wx_vfx_22", Icon = "skills/wx_neigong_wudu.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_shebishi <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_shebishi",
	TraitID = "special.wx_boss_trait_shebishi",
	Skills = ["scripts/skills/actives/wx_boss_shebishi_twin_serpents", "scripts/skills/actives/wx_boss_shebishi_corpse_claw", "scripts/skills/actives/wx_boss_shebishi_miasma_burst"],
	CounterHint = "双翼刀剑齐出，优先斩灭左右 2 条独立【珥耳巨青蛇】断其渡生回血并重创尸元！"
};

// 33. 发鸠填海精卫 (东山经 · 1+3 西山发鸠五彩填海灵石阵眼)
::Wuxia.ShanHaiBossSpecs.jingwei <- {
	Key = "jingwei", Chapter = "东山经",
	TraitName = "衔西山木石·堙东海千载魂",
	CanonQuote = "《北山经》：炎帝之少女名曰女娃，游于东海，溺而不返，故为精卫，常衔西山之木石，以堙于东海。",
	TraitDesc = "炎帝少女千年溺海执念魂：灵体虚化，场上悬浮 3 座【西山五彩填海灵石阵】提供 54% 实伤减免并交织木石流星雨；击碎五彩灵石破除灵障，且主修【纯阳内功】者出招可额外度化魂体享 +35% 伤害！",
	CounterHint = "重锤/弓弩先行击碎 3 座【西山五彩填海灵石阵】，派纯阳内功高手主攻度化怨魂！",
	StructureMode = "totems",
	DefaultTotemCount = 3, TotemShieldPerUnit = 0.18,
	InitFieldKind = "abyss_frost",
	Parts = [
		{ Key = "stone_1", Name = "西山五彩填海灵石·青木", HP = 75, Brush = "wx_totem_spirit_stone" },
		{ Key = "stone_2", Name = "西山五彩填海灵石·赤丹", HP = 75, Brush = "wx_totem_spirit_stone" },
		{ Key = "stone_3", Name = "西山五彩填海灵石·玄玉", HP = 75, Brush = "wx_totem_spirit_stone" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_jingwei_stone_barrage <- {
	Name = "衔木石堙东海雨", Desc = "催动场上【五彩填海灵石】化作流星石雨轰击敌阵连线，砸裂甲胄致失衡。",
	Geo = "totem_ray", AP = 5, Qi = 18, CD = 1, Field = "",
	Hit = 14, Dmg = 1.20, Arm = 1.30, Pen = 0.10,
	BurnArm = 18, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_throw_pilidan.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_jingwei_drowned_wail <- {
	Name = "溺而不返千载怨", Desc = "凄厉精卫啼鸣直击心魂，令敌军战意动摇并散功。",
	Geo = "sonic_roar", AP = 4, Qi = 15, CD = 2, Field = "abyss_frost",
	Hit = 12, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 12, DrainHP = 0, Status = "shaken",
	Vfx = "wx_vfx_30", Icon = "skills/wx_whip_xiangxi.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_jingwei_spirit_shift <- {
	Name = "白喙赤足渡海影", Desc = "与场上【五彩填海灵石】互换方位，飘忽难测。",
	Geo = "totem_swap", AP = 3, Qi = 12, CD = 2, Field = "abyss_frost",
	Hit = 0, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 0, DrainHP = 0, Status = "",
	Vfx = "wx_vfx_21", Icon = "skills/wx_qinggong_shuishang.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_jingwei <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_jingwei",
	TraitID = "special.wx_boss_trait_jingwei",
	Skills = ["scripts/skills/actives/wx_boss_jingwei_stone_barrage", "scripts/skills/actives/wx_boss_jingwei_drowned_wail", "scripts/skills/actives/wx_boss_jingwei_spirit_shift"],
	CounterHint = "重锤/弓弩先行击碎 3 座【西山五彩填海灵石阵】，派纯阳内功高手主攻度化怨魂！"
};

// 34. 钦山金玉当康 (东山经 · 单格异律法相：金玉厚革护体 + 断青玉牙露软腹)
::Wuxia.ShanHaiBossSpecs.dangkang <- {
	Key = "dangkang", Chapter = "东山经",
	TraitName = "钦山多金玉·重甲护腑青牙相",
	CanonQuote = "《东山经》：钦山多金玉，有兽焉，其状如豚而有牙，其名曰当康，其鸣自叫，见则天下大穰。",
	TraitDesc = "单格钦山金玉巨豚：浑身凝结金玉矿甲，身甲高于 80 点时直接减免 35% 气血实伤（严防低破甲刺客偷血）；唯以重锤/开山斧猛劈破甲并敲断其【青玉巨獠牙】，当场废除犁阵冲且令其近防暴跌 -12！",
	CounterHint = "切忌用低破甲轻兵刮痧！必用重锤/大斧先行破甲敲断【青玉巨獠牙】再取其性命！",
	StructureMode = "mythic_law",
	ImmuneStun = true,
	InternalPartKey = "jade_tusk", InternalPartName = "钦山青玉巨獠牙", InternalPartType = "horn",
	InternalBreakMode = "blunt_or_axe", InternalBreakMax = 2, InternalLockedSkill = "actives.wx_boss_dangkang_tusk_plow",
};

::Wuxia.ShanHaiBossMoves.wx_boss_dangkang_tusk_plow <- {
	Name = "青玉巨牙犁阵冲", Desc = "挺起一对青玉獠牙直线犁穿 3 格敌阵，崩毁22点护甲（锤斧敲断青玉牙即永久封印）。",
	Geo = "line_charge_3", AP = 5, Qi = 18, CD = 2, Field = "",
	Hit = 13, Dmg = 1.22, Arm = 1.35, Pen = 0.08,
	BurnArm = 22, DrainQi = 6, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_spear_bawang.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_dangkang_self_call <- {
	Name = "当康自叫震山鸣", Desc = "高呼本名震荡周身 6 格敌军耳膜挂【破绽】。",
	Geo = "ring_quake_6", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 10, Dmg = 1.10, Arm = 1.20, Pen = 0.06,
	BurnArm = 12, DrainQi = 10, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_17", Icon = "skills/wx_tactics_shihou.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_dangkang_boar_slam <- {
	Name = "钦山金玉重躯撞", Desc = "万钧豚躯迎面猛撞造成内伤。",
	Geo = "single", AP = 4, Qi = 14, CD = 1, Field = "",
	Hit = 12, Dmg = 1.18, Arm = 1.25, Pen = 0.08,
	BurnArm = 16, DrainQi = 0, DrainHP = 0, Status = "injury",
	Vfx = "wx_vfx_17", Icon = "skills/wx_shield_bash_qi.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_dangkang <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_dangkang",
	TraitID = "special.wx_boss_trait_dangkang",
	Skills = ["scripts/skills/actives/wx_boss_dangkang_tusk_plow", "scripts/skills/actives/wx_boss_dangkang_self_call", "scripts/skills/actives/wx_boss_dangkang_boar_slam"],
	CounterHint = "切忌用低破甲轻兵刮痧！必用重锤/大斧先行破甲敲断【青玉巨獠牙】再取其性命！"
};

// 35. 都广通天建木句芒 (中山经 · 1+3 通天建木九枸盘根阵眼)
::Wuxia.ShanHaiBossSpecs.jumang <- {
	Key = "jumang", Chapter = "中山经",
	TraitName = "百仞无枝·九欘九枸通天建木",
	CanonQuote = "《海内经》：有木，青叶紫茎，玄华黄实，名曰建木，百仞无枝，上有九欘，下有九枸，其实如麻。",
	TraitDesc = "都广之野通天建木化生神树：场上破土扎下 3 株紫茎青叶【通天建木九枸盘根】（每株每轮输送 8 点回春气血并提供 15% 木灵护障）；非斧类近战砍击必遭铁棘反伤 10 点护甲，唯【巨斧/开山钺】伐木享 +32% 克制暴伤且免反刺！",
	CounterHint = "必派【巨斧/开山钺】猛将主攻伐木，先行砍断 3 株【建木九枸盘根】断绝回春根脉！",
	StructureMode = "totems",
	Headless = true,
	ImmuneStun = true,
	RegenHP = 24,
	DefaultTotemCount = 3, TotemShieldPerUnit = 0.15,
	Parts = [
		{ Key = "root_1", Name = "通天建木九枸盘根·东欘", HP = 95, Brush = "wx_totem_jianmu_root" },
		{ Key = "root_2", Name = "通天建木九枸盘根·南枸", HP = 95, Brush = "wx_totem_jianmu_root" },
		{ Key = "root_3", Name = "通天建木九枸盘根·西华", HP = 95, Brush = "wx_totem_jianmu_root" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_jumang_nine_roots <- {
	Name = "下有九枸地刺穿", Desc = "催动场上【九枸盘根】破土穿刺连线敌军，震退失衡。",
	Geo = "totem_ray", AP = 5, Qi = 18, CD = 2, Field = "",
	Hit = 13, Dmg = 1.20, Arm = 1.25, Pen = 0.10,
	BurnArm = 18, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_15", Icon = "skills/wx_staff_dagou.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_jumang_thorn_canopy <- {
	Name = "青叶紫茎铁棘扫", Desc = "挥舞紫茎巨枝横扫扇形三格割裂流血。",
	Geo = "cone_3", AP = 5, Qi = 18, CD = 1, Field = "",
	Hit = 12, Dmg = 1.18, Arm = 1.25, Pen = 0.08,
	BurnArm = 16, DrainQi = 6, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_15", Icon = "skills/wx_pole_sweep.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_jumang_spring_surge <- {
	Name = "太皞春神抽髓潮", Desc = "建木神威抽取周身 6 格敌军 12 内息滋养木躯。",
	Geo = "ring_quake_6", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 10, Dmg = 1.10, Arm = 1.15, Pen = 0.06,
	BurnArm = 10, DrainQi = 12, DrainHP = 20, Status = "scatter",
	Vfx = "wx_vfx_15", Icon = "skills/wx_neigong_guiyuan.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_jumang <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_jumang",
	TraitID = "special.wx_boss_trait_jumang",
	Skills = ["scripts/skills/actives/wx_boss_jumang_nine_roots", "scripts/skills/actives/wx_boss_jumang_thorn_canopy", "scripts/skills/actives/wx_boss_jumang_spring_surge"],
	CounterHint = "必派【巨斧/开山钺】猛将主攻伐木，先行砍断 3 株【建木九枸盘根】断绝回春根脉！"
};

// 36. 淮涡水猿无支祁 (中山经 · 单格异律法相：力逾九象挣锁 vs 点穴定身镇猿)
::Wuxia.ShanHaiBossSpecs.wuzhiqi <- {
	Key = "wuzhiqi", Chapter = "中山经",
	TraitName = "力逾九象·龟山禹锁镇狂猿",
	CanonQuote = "《古岳渎经/山海》：淮涡水神名无支祁，形若猿猴，青躯白首，金目雪牙，颈伸百尺，力逾九象，禹锁于龟山足下。",
	TraitDesc = "单格淮水奇猿妖圣：身负大禹镇淮玄铁索，半血以下挣锁狂暴（暴涨至 11 AP、武艺+15、总伤+24%）！唯以【点穴封气】或【定身捕网/打狗绊】引动大禹铁索重压，当场锁死其神力（压至 7 AP、近防暴跌 -15）！",
	CounterHint = "半血挣锁前务必以《一阳指/兰花拂穴/天罗捕网》施加点穴或定身，借大禹铁索反镇狂猿！",
	StructureMode = "mythic_law",
	ImmuneStun = true,
	InitFieldKind = "abyss_frost",
};

::Wuxia.ShanHaiBossMoves.wx_boss_wuzhiqi_chain_sweep <- {
	Name = "百尺长颈铁索扫", Desc = "甩动身上镇淮玄铁巨索横扫扇形三格，寒渊阴劲封锁气穴【点穴封气】。",
	Geo = "cone_3", AP = 5, Qi = 18, CD = 1, Field = "abyss_frost",
	Hit = 14, Dmg = 1.20, Arm = 1.25, Pen = 0.10,
	BurnArm = 18, DrainQi = 10, DrainHP = 0, Status = "acupoint",
	Vfx = "wx_vfx_21", Icon = "skills/wx_flail_panlong.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_wuzhiqi_nine_elephant_slam <- {
	Name = "力逾九象覆海扑", Desc = "挟九象神力跃扑 2~3 格轰塌阵线。",
	Geo = "leap_slam_3", AP = 5, Qi = 20, CD = 2, Field = "abyss_frost",
	Hit = 13, Dmg = 1.24, Arm = 1.30, Pen = 0.10,
	BurnArm = 20, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_21", Icon = "skills/wx_hama_push.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_wuzhiqi_huai_vortex <- {
	Name = "淮涡寒渊摄敌引", Desc = "卷起淮水漩涡将远处目标拽入贴身重击散功。",
	Geo = "pull_devour", AP = 4, Qi = 16, CD = 2, Field = "abyss_frost",
	Hit = 13, Dmg = 1.15, Arm = 1.15, Pen = 0.08,
	BurnArm = 12, DrainQi = 12, DrainHP = 0, Status = "scatter",
	Vfx = "wx_vfx_21", Icon = "skills/wx_fist_nuchao.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_wuzhiqi <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_wuzhiqi",
	TraitID = "special.wx_boss_trait_wuzhiqi",
	Skills = ["scripts/skills/actives/wx_boss_wuzhiqi_chain_sweep", "scripts/skills/actives/wx_boss_wuzhiqi_nine_elephant_slam", "scripts/skills/actives/wx_boss_wuzhiqi_huai_vortex"],
	CounterHint = "半血挣锁前务必以《一阳指/兰花拂穴/天罗捕网》施加点穴或定身，借大禹铁索反镇狂猿！"
};

// 37. 凶水水火怪九婴 (中山经 · 三格水火多首巨妖：主躯 + 玄冥喷水蛇首 + 焚天喷火蛇首)
::Wuxia.ShanHaiBossSpecs.jiuying <- {
	Key = "jiuying", Chapter = "中山经",
	TraitName = "凶水水火怪·双首冰炎蒸爆相",
	CanonQuote = "《淮南子》：北方有凶水，九婴水火之怪，为人害，尧乃使羿诛凿齿于畴华，杀九婴于凶水之上。",
	TraitDesc = "三格水火多首巨妖：主躯两翼探出独立长颈【玄冥喷水首】与【焚天喷火首】——单数轮漫玄冥霜、双数轮贯赤旱火，冰火交叠瞬间引爆全场【寒暑蒸汽崩甲爆】！集火斩断任意一首即可拆散其水火连环爆！",
	CounterHint = "切勿站在单数轮遗留的【玄冥冻土】上硬接双数轮烈火吐息！优先斩断喷火首或喷水首拆解冰火连爆！",
	StructureMode = "appendages",
	RegenHP = 18,
	SeverSpillField = "bitter_mire",
	Parts = [
		{ Key = "water_head", Name = "九婴·凶水玄冥喷水首", HP = 130, BodyArmor = 135, HeadArmor = 125, MeleeDef = 10, Brush = "wx_part_jiuying_water", LockedSkillID = "actives.wx_boss_jiuying_water_deluge" },
		{ Key = "fire_head", Name = "九婴·凶水焚天喷火首", HP = 130, BodyArmor = 135, HeadArmor = 125, MeleeDef = 10, Brush = "wx_part_jiuying_fire", LockedSkillID = "actives.wx_boss_jiuying_fire_torrent" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_jiuying_water_deluge <- {
	Name = "九婴玄冥毒水潮", Desc = "喷水凶首倾泻极寒毒潮覆盖扇形三格铺冻土（斩断玄冥喷水首即永久封印）。",
	Geo = "cone_3", AP = 5, Qi = 18, CD = 1, Field = "abyss_frost",
	Hit = 13, Dmg = 1.18, Arm = 1.20, Pen = 0.10,
	BurnArm = 14, DrainQi = 10, DrainHP = 0, Status = "poison",
	Vfx = "wx_vfx_21", Icon = "skills/wx_fist_xuanming.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_jiuying_fire_torrent <- {
	Name = "九婴焚天烈火柱", Desc = "喷火凶首贯射三格烈焰（遇冻土立爆水火蒸汽！斩断焚天喷火首即永久封印）。",
	Geo = "line_pierce_3", AP = 5, Qi = 18, CD = 1, Field = "drought_scorch",
	Hit = 14, Dmg = 1.22, Arm = 1.30, Pen = 0.12,
	BurnArm = 22, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_29", Icon = "skills/wx_gun_huolong.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_jiuying_nine_neck_bite <- {
	Name = "群首交剪噬魂舞", Desc = "群蛇长颈交错疯狂撕咬周身 6 格近敌。",
	Geo = "ring_quake_6", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 12, Dmg = 1.15, Arm = 1.15, Pen = 0.08,
	BurnArm = 14, DrainQi = 6, DrainHP = 16, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_saber_abi.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_jiuying <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_jiuying",
	TraitID = "special.wx_boss_trait_jiuying",
	Skills = ["scripts/skills/actives/wx_boss_jiuying_water_deluge", "scripts/skills/actives/wx_boss_jiuying_fire_torrent", "scripts/skills/actives/wx_boss_jiuying_nine_neck_bite"],
	CounterHint = "切勿站在单数轮遗留的【玄冥冻土】上硬接双数轮烈火吐息！优先斩断喷火首或喷水首拆解冰火连爆！"
};

// 38. 雀首风伯飞廉 (中山经 · 单格异律法相：回风折矢反伤射手)
::Wuxia.ShanHaiBossSpecs.feilian <- {
	Key = "feilian", Chapter = "中山经",
	TraitName = "雀首鹿身·统御八风回矢相",
	CanonQuote = "《楚辞/三辅黄图》：飞廉神禽，能致风气，鹿身头如雀有角，蛇尾豹文，统御八风。",
	TraitDesc = "单格风伯妖尊：立于【裂风沙暴】之中时远防+28，且施展『回风折矢』——任何远程射击不仅伤害减免55%，更被狂风倒卷折返刺伤射手 10 点气血！唯以《八门金锁阵》定风或两格钩镰近战围斩可破！",
	CounterHint = "严禁弓弩隔风对射（必遭回风折矢反伤）！以《八门金锁阵》靖风并用近战重兵贴脸斩杀！",
	StructureMode = "mythic_law",
	MinAP = 11,
	InitFieldKind = "gale_sand",
	TurnFieldKind = "gale_sand",
};

::Wuxia.ShanHaiBossMoves.wx_boss_feilian_wind_step <- {
	Name = "风伯奔属掠空斩", Desc = "御狂风跨跃 2~3 格斜掠咽喉，起落皆化【裂风沙暴】。",
	Geo = "leap_slam_3", AP = 4, Qi = 16, CD = 1, Field = "gale_sand",
	Hit = 15, Dmg = 1.18, Arm = 1.20, Pen = 0.12,
	BurnArm = 14, DrainQi = 6, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_15", Icon = "skills/wx_qinggong_feiyan.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_feilian_cyclone_blade <- {
	Name = "雀角回风飓刃扇", Desc = "扇出三道裂空风刃撕开前排甲胄挂【破绽】。",
	Geo = "cone_3", AP = 4, Qi = 16, CD = 1, Field = "gale_sand",
	Hit = 14, Dmg = 1.16, Arm = 1.20, Pen = 0.10,
	BurnArm = 16, DrainQi = 8, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_01", Icon = "skills/wx_saber_kuangfeng.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_feilian_tempest_burst <- {
	Name = "八风统御龙卷爆", Desc = "引爆全战场【裂风沙暴】卷飞踏沙敌军致失衡。",
	Geo = "field_detonate", AP = 5, Qi = 20, CD = 3, Field = "gale_sand",
	Hit = 12, Dmg = 1.20, Arm = 1.20, Pen = 0.10,
	BurnArm = 14, DrainQi = 10, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_15", Icon = "skills/wx_pole_sweep.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_feilian <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_feilian",
	TraitID = "special.wx_boss_trait_feilian",
	Skills = ["scripts/skills/actives/wx_boss_feilian_wind_step", "scripts/skills/actives/wx_boss_feilian_cyclone_blade", "scripts/skills/actives/wx_boss_feilian_tempest_burst"],
	CounterHint = "严禁弓弩隔风对射（必遭回风折矢反伤）！以《八门金锁阵》靖风并用近战重兵贴脸斩杀！"
};

// 39. 东望山通万物白泽 (中山经 · 单格异律法相：识破复读旧招)
::Wuxia.ShanHaiBossSpecs.baize <- {
	Key = "baize", Chapter = "中山经",
	TraitName = "能言达万物情·万法识破瑞煞相",
	CanonQuote = "《云笈七签/山海图赞》：黄帝巡于东海，白泽出，能言，达知万物之情，鬼神之事，书之以戒于民。",
	TraitDesc = "单格通晓天下武学总纲之瑞兽：实时记忆我方最近施展的 2 门招式——若任何人重复使出刚用过的同款招式，白泽当场识破卸去 55% 伤害并反震攻者【破绽】与 10 点内息！轮换不同招式则招招满伤！",
	CounterHint = "严禁连续复读同一招式！全队轮换不同兵器与招式名称交替出招，即可刀刀满伤破其通玄！",
	StructureMode = "mythic_law",
	ImmuneStun = true,
	ImmuneDisarm = true,
	RegenHP = 16,
};

::Wuxia.ShanHaiBossMoves.wx_boss_baize_expose_flaw <- {
	Name = "达知万物点破绽", Desc = "口吐人言一语道破敌手武学罩门，施加【破绽】并震散12内息。",
	Geo = "hex_curse", AP = 3, Qi = 14, CD = 1, Field = "",
	Hit = 16, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 12, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_24", Icon = "skills/wx_tactics_guigu.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_baize_auspicious_horn <- {
	Name = "东望通玄贯气冲", Desc = "白泽灵角化虹贯穿直线 3 格敌阵，散去护体真气。",
	Geo = "line_pierce_3", AP = 5, Qi = 18, CD = 2, Field = "",
	Hit = 14, Dmg = 1.20, Arm = 1.25, Pen = 0.12,
	BurnArm = 16, DrainQi = 10, DrainHP = 0, Status = "scatter",
	Vfx = "wx_vfx_12", Icon = "skills/wx_sword_dugu.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_baize_spirit_shock <- {
	Name = "万鬼辟易瑞罡震", Desc = "周身迸发浩然白泽图谱神光震退 6 格近敌。",
	Geo = "ring_quake_6", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 12, Dmg = 1.14, Arm = 1.15, Pen = 0.08,
	BurnArm = 12, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_24", Icon = "skills/wx_neigong_yijin.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_baize <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_baize",
	TraitID = "special.wx_boss_trait_baize",
	Skills = ["scripts/skills/actives/wx_boss_baize_expose_flaw", "scripts/skills/actives/wx_boss_baize_auspicious_horn", "scripts/skills/actives/wx_boss_baize_spirit_shock"],
	CounterHint = "严禁连续复读同一招式！全队轮换不同兵器与招式名称交替出招，即可刀刀满伤破其通玄！"
};

// 40. 狱法善投山挥 (中山经 · 单格异律法相：远距怪笑砸盔 vs 贴身慌乱失防)
::Wuxia.ShanHaiBossSpecs.shanhui <- {
	Key = "shanhui", Chapter = "中山经",
	TraitName = "善投见人笑·远狂近怯风犬相",
	CanonQuote = "《北山/中山经》：狱法之山，有兽焉，其状如犬而人面，善投，见人则笑，其名山挥，其行如风，见则天下大风。",
	TraitDesc = "单格善投飞石风犬：拉开距离时怪笑腾跃（远防+20），投掷巨岩额外砸毁目标头盔 18 点护甲；但一旦被软鞭/钩镰枪拽近或被轻功贴脸缠住（身旁有敌），立即怯战失笑（近防暴跌 -14）！",
	CounterHint = "切勿与其远距对耗头盔！用《金蛇软鞭/钩镰枪》拽入怀中或轻功贴脸锁住，近防立跌 -14！",
	StructureMode = "mythic_law",
	MinAP = 11,
	InitFieldKind = "gale_sand",
};

::Wuxia.ShanHaiBossMoves.wx_boss_shanhui_boulder_hurl <- {
	Name = "狱法善投裂颅石", Desc = "怪笑抓起巨岩精准砸击 1~4 格目标头盔（额外崩毁头甲18点并致失衡）。",
	Geo = "ranged_barrage", AP = 4, Qi = 15, CD = 1, Field = "",
	Hit = 16, Dmg = 1.20, Arm = 1.35, Pen = 0.12,
	BurnArm = 20, DrainQi = 6, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_hammer_jingua.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_shanhui_mocking_laugh <- {
	Name = "见人则笑大风起", Desc = "人面狂笑掀起漫天风沙，动摇敌心并露【破绽】。",
	Geo = "sonic_roar", AP = 3, Qi = 12, CD = 2, Field = "gale_sand",
	Hit = 12, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 10, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_15", Icon = "skills/wx_qinggong_shenxing.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_shanhui_wind_dash <- {
	Name = "行如疾风扑喉刺", Desc = "借风势疾跃 2~3 格叩击重穴封气。",
	Geo = "leap_slam_3", AP = 4, Qi = 16, CD = 2, Field = "gale_sand",
	Hit = 14, Dmg = 1.16, Arm = 1.15, Pen = 0.10,
	BurnArm = 12, DrainQi = 8, DrainHP = 0, Status = "acupoint",
	Vfx = "wx_vfx_15", Icon = "skills/wx_fist_acupoint.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_shanhui <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_shanhui",
	TraitID = "special.wx_boss_trait_shanhui",
	Skills = ["scripts/skills/actives/wx_boss_shanhui_boulder_hurl", "scripts/skills/actives/wx_boss_shanhui_mocking_laugh", "scripts/skills/actives/wx_boss_shanhui_wind_dash"],
	CounterHint = "切勿与其远距对耗头盔！用《金蛇软鞭/钩镰枪》拽入怀中或轻功贴脸锁住，近防立跌 -14！"
};

// 41. 中曲食虎铁驳 (中山经 · 单格异律法相：可以御兵抗利刃 + 战鼓修甲 + 唯钝碎角)
::Wuxia.ShanHaiBossSpecs.bo <- {
	Key = "bo", Chapter = "中山经",
	TraitName = "音如战鼓·食虎豹御兵铁躯",
	CanonQuote = "《西山/中山经》：中曲之山，有兽焉，其状如马而白身黑尾，一角，虎牙爪，音如鼓，其名曰驳，是食虎豹，可以御兵。",
	TraitDesc = "单格食虎神骏：应验原典『可以御兵』——刀剑枪戟锋刃对其伤害折减 38%，且每轮战鼓嘶鸣自动修复 20 点身甲；唯【重锤/铁锏/拳掌隔甲寸劲】可破御兵皮享 +28% 暴伤并敲碎螺旋铁独角断其修甲与冲锋！",
	CounterHint = "收起刀剑锋刃！改派【重锤/铁锏/拳掌寸劲】破其『御兵铁皮』并敲碎独角断绝修甲！",
	StructureMode = "mythic_law",
	Headless = true,
	ImmuneStun = true,
	InternalPartKey = "bo_horn", InternalPartName = "食虎螺旋铁独角", InternalPartType = "horn",
	InternalBreakMode = "blunt", InternalBreakMax = 2, InternalLockedSkill = "actives.wx_boss_bo_tiger_eater_charge",
};

::Wuxia.ShanHaiBossMoves.wx_boss_bo_tiger_eater_charge <- {
	Name = "食虎豹螺旋贯胸冲", Desc = "白马雷奔直线贯冲 3 格，螺旋独角崩碎26点重甲（重钝敲碎铁独角即封印）。",
	Geo = "line_charge_3", AP = 5, Qi = 20, CD = 2, Field = "",
	Hit = 15, Dmg = 1.25, Arm = 1.40, Pen = 0.12,
	BurnArm = 26, DrainQi = 8, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_17", Icon = "skills/wx_spear_panlong.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_bo_saw_fang <- {
	Name = "锯牙虎爪裂铠噬", Desc = "锯齿巨牙撕开铁甲造成深创内伤。",
	Geo = "single", AP = 4, Qi = 16, CD = 1, Field = "",
	Hit = 14, Dmg = 1.20, Arm = 1.30, Pen = 0.10,
	BurnArm = 20, DrainQi = 0, DrainHP = 0, Status = "injury",
	Vfx = "wx_vfx_08", Icon = "skills/wx_saber_podao.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_bo_war_drum_neigh <- {
	Name = "音如战鼓震军嘶", Desc = "长嘶如擂战鼓震退周身 6 格近敌致失衡。",
	Geo = "ring_quake_6", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 11, Dmg = 1.12, Arm = 1.20, Pen = 0.06,
	BurnArm = 14, DrainQi = 10, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_hammer_polu.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_bo <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_bo",
	TraitID = "special.wx_boss_trait_bo",
	Skills = ["scripts/skills/actives/wx_boss_bo_tiger_eater_charge", "scripts/skills/actives/wx_boss_bo_saw_fang", "scripts/skills/actives/wx_boss_bo_war_drum_neigh"],
	CounterHint = "收起刀剑锋刃！改派【重锤/铁锏/拳掌寸劲】破其『御兵铁皮』并敲碎独角断绝修甲！"
};

// 42. 南荒厌火祸斗 (中山经 · 单格异律法相：吞火回血 · 唯玄阴寒冰激克)
::Wuxia.ShanHaiBossSpecs.huodou <- {
	Key = "huodou", Chapter = "中山经",
	TraitName = "厌火食炭·吞火自愈唯冰克相",
	CanonQuote = "《山海图赞/海外南经》：厌火之兽，厥名祸斗，状如黑犬，食火喷烟，所至焦烂。",
	TraitDesc = "单格食火凶犬皇：立于焦土自愈，若误用【纯阳/烈火/火铳】攻之反为其大补回血 20 点！非玄阴真气近战必遭火星溅损 10 护甲；唯【玄阴寒冰掌/玄冰剑/雪龙枪】可触发极寒炸膛打出 +40% 克制暴伤！",
	CounterHint = "严禁使用纯阳火刀与火铳（反为其补血）！专派玄阴寒冰流派主攻享 +40% 寒克暴伤！",
	StructureMode = "mythic_law",
	MinAP = 10,
	InitFieldKind = "drought_scorch",
	TurnFieldKind = "drought_scorch",
};

::Wuxia.ShanHaiBossMoves.wx_boss_huodou_flame_spit <- {
	Name = "食炭喷炎贯火线", Desc = "张口喷出三格赤炭火柱熔毁20护甲并铺设【赤旱焦土】。",
	Geo = "line_pierce_3", AP = 4, Qi = 16, CD = 1, Field = "drought_scorch",
	Hit = 14, Dmg = 1.18, Arm = 1.30, Pen = 0.10,
	BurnArm = 20, DrainQi = 8, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_29", Icon = "skills/wx_gun_leihuo.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_huodou_ember_pounce <- {
	Name = "黑犬流火扑喉", Desc = "挟黑烟烈焰跃扑 2~3 格目标撕咬。",
	Geo = "leap_slam_3", AP = 4, Qi = 16, CD = 1, Field = "drought_scorch",
	Hit = 14, Dmg = 1.18, Arm = 1.20, Pen = 0.10,
	BurnArm = 16, DrainQi = 8, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_29", Icon = "skills/wx_saber_huoyandao.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_huodou_ash_detonate <- {
	Name = "所至火灾燎原爆", Desc = "引爆全场【赤旱焦土】焚灼踏火敌军真气。",
	Geo = "field_detonate", AP = 5, Qi = 20, CD = 3, Field = "drought_scorch",
	Hit = 12, Dmg = 1.22, Arm = 1.25, Pen = 0.10,
	BurnArm = 18, DrainQi = 10, DrainHP = 0, Status = "scatter",
	Vfx = "wx_vfx_29", Icon = "skills/wx_throw_pilidan.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_huodou <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_huodou",
	TraitID = "special.wx_boss_trait_huodou",
	Skills = ["scripts/skills/actives/wx_boss_huodou_flame_spit", "scripts/skills/actives/wx_boss_huodou_ember_pounce", "scripts/skills/actives/wx_boss_huodou_ash_detonate"],
	CounterHint = "严禁使用纯阳火刀与火铳（反为其补血）！专派玄阴寒冰流派主攻享 +40% 寒克暴伤！"
};

// 43. 青要密都神武罗 (中山经 · 单格异律法相：鸣玉乱息共鸣 + 神射碎耳镼)
::Wuxia.ShanHaiBossSpecs.wuluo <- {
	Key = "wuluo", Chapter = "中山经",
	TraitName = "穿耳以镼·鸣玉乱息绝脉相",
	CanonQuote = "《中山经》：青要之山，实惟帝之密都，神武罗司之，其状人面而豹文，小要而白齿，而穿耳以镼，其鸣如鸣玉。",
	TraitDesc = "单格青要密都司神：双耳悬佩【鸣玉耳镼】激荡清音——对我方内息疲劳≥40 的乱息侠客伤害暴涨 +24%！保持归元调息控住内息水位，并以神射/暗器/点穴精准击碎其耳上玉镼，永久封印鸣玉绝脉弦！",
	CounterHint = "及时调息勿使疲劳超过 40 点，派神射手/唐门飞刀精准点碎其双耳【鸣玉镼】绝其音杀！",
	StructureMode = "mythic_law",
	MinAP = 10,
	InitFieldKind = "mirage_mist",
	InternalPartKey = "jade_earrings", InternalPartName = "青要穿耳鸣玉镼", InternalPartType = "core",
	InternalBreakMode = "ranged_or_acupoint", InternalBreakMax = 2, InternalLockedSkill = "actives.wx_boss_wuluo_jade_chime",
};

::Wuxia.ShanHaiBossMoves.wx_boss_wuluo_jade_chime <- {
	Name = "鸣玉穿耳绝脉弦", Desc = "双耳玉镼齐鸣激射翡翠音弦封锁 1~4 格目标要穴【点穴封气】（击碎耳上鸣玉镼即封印）。",
	Geo = "ranged_barrage", AP = 5, Qi = 18, CD = 1, Field = "",
	Hit = 15, Dmg = 1.18, Arm = 1.20, Pen = 0.14,
	BurnArm = 14, DrainQi = 10, DrainHP = 0, Status = "acupoint",
	Vfx = "wx_vfx_24", Icon = "skills/wx_fist_canhezhi.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_wuluo_leopard_flash <- {
	Name = "小腰豹纹掠影抓", Desc = "身姿如电掠扑 2~3 格割裂咽喉。",
	Geo = "leap_slam_3", AP = 4, Qi = 15, CD = 1, Field = "mirage_mist",
	Hit = 15, Dmg = 1.16, Arm = 1.15, Pen = 0.12,
	BurnArm = 12, DrainQi = 0, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_25", Icon = "skills/wx_sword_yunv.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_wuluo_secret_capital_shift <- {
	Name = "青要密都迷烟咒", Desc = "袖拂青要云雾震散周身敌军内息并布下迷障。",
	Geo = "sonic_roar", AP = 3, Qi = 12, CD = 2, Field = "mirage_mist",
	Hit = 10, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 10, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_25", Icon = "skills/wx_qinggong_meiying.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_wuluo <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_wuluo",
	TraitID = "special.wx_boss_trait_wuluo",
	Skills = ["scripts/skills/actives/wx_boss_wuluo_jade_chime", "scripts/skills/actives/wx_boss_wuluo_leopard_flash", "scripts/skills/actives/wx_boss_wuluo_secret_capital_shift"],
	CounterHint = "及时调息勿使疲劳超过 40 点，派神射手/唐门飞刀精准点碎其双耳【鸣玉镼】绝其音杀！"
};

// 44. 鲜山四翼鸣蛇 (中山经 · 双格金鳞旱蛇躯：蛇首 + 四翼金鳞磬鸣躯)
::Wuxia.ShanHaiBossSpecs.mingshe <- {
	Key = "mingshe", Chapter = "中山经",
	TraitName = "蛇身四翼·音如古磬大旱躯",
	CanonQuote = "《中山经》：鲜山多金玉，有蛇焉，其状如蛇而四翼，其音如磬，其名曰鸣蛇，见则其邑大旱。",
	TraitDesc = "鲜山双格金翼旱蛇（蛇首 + 四翼金鳞磬鸣躯）：刀剑箭矢击中鳞翼会激起『古磬共鸣』满3次反震失衡，唯重锤/木杖闷击不鸣；集火打碎【四翼金鳞磬鸣躯】即折翼落地，永久封印古磬反震与四翼掠空冲！",
	CounterHint = "派重锤/长棍手闷击砸碎【四翼金鳞磬鸣躯】破除古磬共鸣与掠空冲，玄阴真气灭焦土！",
	StructureMode = "segments",
	InitFieldKind = "drought_scorch",
	Parts = [
		{ Key = "gold_wing_body", Name = "鸣蛇·四翼金鳞磬鸣躯", BodyArmor = 225, HeadArmor = 160, MeleeDef = 12, Brush = "wx_part_mingshe_wingbody", LockedSkillID = "actives.wx_boss_mingshe_four_wing_swoop" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_mingshe_chime_wave <- {
	Name = "音如古磬裂脉震", Desc = "鳞翼摩擦发出金玉古磬巨响震荡周身 6 格，散去真气并铺旱火。",
	Geo = "ring_quake_6", AP = 4, Qi = 18, CD = 2, Field = "drought_scorch",
	Hit = 12, Dmg = 1.15, Arm = 1.20, Pen = 0.10,
	BurnArm = 14, DrainQi = 12, DrainHP = 0, Status = "scatter",
	Vfx = "wx_vfx_17", Icon = "skills/wx_flail_panlong.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_mingshe_four_wing_swoop <- {
	Name = "四翼大旱掠空冲", Desc = "四翼齐振贴地疾冲直线 3 格灼裂护甲（击碎四翼金鳞磬鸣躯即封印）。",
	Geo = "line_charge_3", AP = 5, Qi = 18, CD = 2, Field = "drought_scorch",
	Hit = 14, Dmg = 1.20, Arm = 1.25, Pen = 0.10,
	BurnArm = 18, DrainQi = 8, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_29", Icon = "skills/wx_spear_liangyin.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_mingshe_gold_fang <- {
	Name = "鲜山金石毒牙刺", Desc = "金玉毒牙刁钻噬腕注入奇毒。",
	Geo = "single", AP = 4, Qi = 14, CD = 1, Field = "",
	Hit = 14, Dmg = 1.16, Arm = 1.15, Pen = 0.12,
	BurnArm = 12, DrainQi = 6, DrainHP = 0, Status = "poison",
	Vfx = "wx_vfx_22", Icon = "skills/wx_dagger_fuxue.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_mingshe <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_mingshe",
	TraitID = "special.wx_boss_trait_mingshe",
	Skills = ["scripts/skills/actives/wx_boss_mingshe_chime_wave", "scripts/skills/actives/wx_boss_mingshe_four_wing_swoop", "scripts/skills/actives/wx_boss_mingshe_gold_fang"],
	CounterHint = "派重锤/长棍手闷击砸碎【四翼金鳞磬鸣躯】破除古磬共鸣与掠空冲，玄阴真气灭焦土！"
};

// 45. 阳山鸟翼化蛇 (中山经 · 双格寒鳞蛇躯：豺首 + 鸟翼蛇行寒鳞躯)
::Wuxia.ShanHaiBossSpecs.huashe <- {
	Key = "huashe", Chapter = "中山经",
	TraitName = "人面豺身·鸟翼蛇行大水躯",
	CanonQuote = "《中山经》：阳山多石，有兽焉，其状如人面而豺身，鸟翼而蛇行，其音如叱呼，其名曰化蛇，见则其邑大水。",
	TraitDesc = "阳山双格寒水怪蛇（豺首 + 鸟翼寒鳞躯）：立于【玄冥冻土】且鸟翼完好时滑翔借水近防+15；击碎后段【鸟翼蛇行寒鳞躯】令其折翼坠泥（近防倒扣 -14）并永久封印大水蛇行冲！",
	CounterHint = "重兵集火击碎后段【鸟翼蛇行寒鳞躯】令其折翼暴跌近防，纯阳外功融化玄冥冻土！",
	StructureMode = "segments",
	InitFieldKind = "abyss_frost",
	Parts = [
		{ Key = "frost_wing_body", Name = "化蛇·鸟翼蛇行寒鳞躯", BodyArmor = 220, HeadArmor = 155, MeleeDef = 12, Brush = "wx_tail_huashe", LockedSkillID = "actives.wx_boss_huashe_slither_flood" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_huashe_slither_flood <- {
	Name = "蛇行见则大水冲", Desc = "鸟翼助推蛇躯裹挟洪流直线碾过 3 格（击碎鸟翼寒鳞躯即永久封印）。",
	Geo = "line_charge_3", AP = 5, Qi = 18, CD = 2, Field = "abyss_frost",
	Hit = 14, Dmg = 1.20, Arm = 1.25, Pen = 0.10,
	BurnArm = 16, DrainQi = 10, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_21", Icon = "skills/wx_pole_fenjiang.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_huashe_rebuke_roar <- {
	Name = "音如叱呼寒风扇", Desc = "人面发出怒叱狂啸，卷起三格寒霜挫动敌军战意。",
	Geo = "cone_3", AP = 4, Qi = 16, CD = 2, Field = "abyss_frost",
	Hit = 12, Dmg = 1.14, Arm = 1.15, Pen = 0.08,
	BurnArm = 12, DrainQi = 10, DrainHP = 0, Status = "shaken",
	Vfx = "wx_vfx_21", Icon = "skills/wx_sword_xuanbing.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_huashe_jackal_bite <- {
	Name = "豺身锁脉阴寒噬", Desc = "阴寒利齿咬中经络造成【点穴封气】。",
	Geo = "single", AP = 4, Qi = 14, CD = 1, Field = "abyss_frost",
	Hit = 14, Dmg = 1.16, Arm = 1.15, Pen = 0.12,
	BurnArm = 10, DrainQi = 8, DrainHP = 0, Status = "acupoint",
	Vfx = "wx_vfx_21", Icon = "skills/wx_fist_xuanming.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_huashe <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_huashe",
	TraitID = "special.wx_boss_trait_huashe",
	Skills = ["scripts/skills/actives/wx_boss_huashe_slither_flood", "scripts/skills/actives/wx_boss_huashe_rebuke_roar", "scripts/skills/actives/wx_boss_huashe_jackal_bite"],
	CounterHint = "重兵集火击碎后段【鸟翼蛇行寒鳞躯】令其折翼暴跌近防，纯阳外功融化玄冥冻土！"
};

// 46. 敖岸四角白鹿夫诸 (中山经 · 单格异律法相：温柔白鹿·重伤引洪反涌)
::Wuxia.ShanHaiBossSpecs.fuzhu <- {
	Key = "fuzhu", Chapter = "中山经",
	TraitName = "四角白鹿·伤鹿引洪反噬相",
	CanonQuote = "《中山经》：中次三经敖岸之山，有兽焉，其状如白鹿而四角，名曰夫诸，见则其邑大水。",
	TraitDesc = "单格敖岸温柔白鹿：神态洁白温驯，但凡单次蛮力直击造成 ≥35 点实伤，即引动『敖岸大水反涌』瞬间冰封攻者脚下化为【玄冥冻土】并倒抽 10 点内息！宜用多段快剑、流血奇毒或纯阳化冰稳步克之！",
	CounterHint = "慎用单发蛮力重劈引洪冻脚！以快剑连击、流血奇毒消磨，配合纯阳内功融冰回气！",
	StructureMode = "mythic_law",
	InitFieldKind = "abyss_frost",
};

::Wuxia.ShanHaiBossMoves.wx_boss_fuzhu_four_antler_frost <- {
	Name = "四角寒霜贯冰刺", Desc = "四只玉白鹿角凝聚极寒冰枪贯穿直线 3 格封锁经脉。",
	Geo = "line_pierce_3", AP = 5, Qi = 18, CD = 1, Field = "abyss_frost",
	Hit = 14, Dmg = 1.18, Arm = 1.20, Pen = 0.12,
	BurnArm = 14, DrainQi = 10, DrainHP = 0, Status = "acupoint",
	Vfx = "wx_vfx_21", Icon = "skills/wx_spear_xuelong.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_fuzhu_white_stag_leap <- {
	Name = "白鹿踏澜凌波跃", Desc = "轻灵跃扑 2~3 格洒下漫天霜华致敌失衡。",
	Geo = "leap_slam_3", AP = 4, Qi = 15, CD = 1, Field = "abyss_frost",
	Hit = 14, Dmg = 1.15, Arm = 1.15, Pen = 0.10,
	BurnArm = 12, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_21", Icon = "skills/wx_qinggong_xuelian.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_fuzhu_frost_mirror <- {
	Name = "敖岸大水漫泽爆", Desc = "鹿鸣清越引爆全场【玄冥冻土】寒潮震散真气。",
	Geo = "field_detonate", AP = 4, Qi = 16, CD = 2, Field = "abyss_frost",
	Hit = 13, Dmg = 1.16, Arm = 1.15, Pen = 0.10,
	BurnArm = 12, DrainQi = 10, DrainHP = 0, Status = "scatter",
	Vfx = "wx_vfx_21", Icon = "skills/wx_sword_xuanbing.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_fuzhu <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_fuzhu",
	TraitID = "special.wx_boss_trait_fuzhu",
	Skills = ["scripts/skills/actives/wx_boss_fuzhu_four_antler_frost", "scripts/skills/actives/wx_boss_fuzhu_white_stag_leap", "scripts/skills/actives/wx_boss_fuzhu_frost_mirror"],
	CounterHint = "慎用单发蛮力重劈引洪冻脚！以快剑连击、流血奇毒消磨，配合纯阳内功融冰回气！"
};

// 47. 常羊战神刑天 (大荒海内经 · 单格战神法相：持青铜巨干正面铁壁 + 舞戚收势露脐口)
::Wuxia.ShanHaiBossSpecs.xingtian <- {
	Key = "xingtian", Chapter = "大荒海内经",
	TraitName = "乳目脐口·常羊舞干戚战神魄",
	CanonQuote = "《海外西经》：刑天与帝至此争神，帝断其首，葬之常羊之山，乃以乳为目，以脐为口，操干戚以舞。",
	TraitDesc = "单格无首不灭古战神：断首之躯免疫爆头、眩晕与缴械，首杀返3 AP！左手高举【常羊青铜巨干】正面减伤 35%（唯巨斧劈盾可破）；每当施展《操干戚以狂舞》收势后腹脐大张 1 轮，以【刺剑/点穴/寸劲】直刺脐口享 +40% 破腑暴伤！",
	CounterHint = "开山巨斧先劈裂其手中【常羊青铜巨干】，抓其《操干戚狂舞》后露脐窗口以刺剑/寸劲穿腹！",
	StructureMode = "mythic_law",
	Headless = true,
	ImmuneStun = true,
	ImmuneDisarm = true,
	KillRefundAP = 3, KillHealHP = 25,
	InternalPartKey = "bronze_gan", InternalPartName = "常羊青铜巨干盾", InternalPartType = "shell",
	InternalBreakMode = "axe", InternalBreakMax = 2, InternalLockedSkill = "actives.wx_boss_xingtian_navel_roar",
};

::Wuxia.ShanHaiBossMoves.wx_boss_xingtian_ganqi_whirl <- {
	Name = "操干戚以狂舞", Desc = "无首战躯挥舞神戚旋斩周身 6 格血浪翻涌（收招后腹上脐口微露 1 回合！）。",
	Geo = "ring_quake_6", AP = 5, Qi = 20, CD = 2, Field = "blood_pool",
	Hit = 14, Dmg = 1.25, Arm = 1.30, Pen = 0.10,
	BurnArm = 22, DrainQi = 8, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_axe_whirl.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_xingtian_axe_decap <- {
	Name = "争神断天巨戚劈", Desc = "携弑帝余威猛劈前方扇形三格，崩毁26点重甲并震裂内腑。",
	Geo = "cone_3", AP = 5, Qi = 20, CD = 1, Field = "",
	Hit = 15, Dmg = 1.24, Arm = 1.40, Pen = 0.12,
	BurnArm = 26, DrainQi = 6, DrainHP = 0, Status = "injury",
	Vfx = "wx_vfx_02", Icon = "skills/wx_axe_kaitian.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_xingtian_navel_roar <- {
	Name = "乳目脐口破军撞", Desc = "顶起手中青铜巨干直线撞翻 3 格敌阵（巨斧劈裂巨干盾即永久封印）。",
	Geo = "line_charge_3", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 13, Dmg = 1.18, Arm = 1.25, Pen = 0.08,
	BurnArm = 18, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_shield_bash_qi.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_xingtian <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_xingtian",
	TraitID = "special.wx_boss_trait_xingtian",
	Skills = ["scripts/skills/actives/wx_boss_xingtian_ganqi_whirl", "scripts/skills/actives/wx_boss_xingtian_axe_decap", "scripts/skills/actives/wx_boss_xingtian_navel_roar"],
	CounterHint = "开山巨斧先劈裂其手中【常羊青铜巨干】，抓其《操干戚狂舞》后露脐窗口以刺剑/寸劲穿腹！"
};

// 48. 逐日夸父巨骸 (大荒海内经 · 1+2 邓林弃杖花叶桃木阵眼)
::Wuxia.ShanHaiBossSpecs.kuafu <- {
	Key = "kuafu", Chapter = "大荒海内经",
	TraitName = "逐日渴死·弃杖化邓林巨神骸",
	CanonQuote = "《海外北经》：夸父与日逐走，入日；渴，饮于河渭不足，北饮大泽，未至道渴而死，弃其杖，化为邓林。",
	TraitDesc = "逐日巨神枯骸：场上矗立 2 株花繁露滴的【邓林弃杖桃木】，存活时大日渴气每轮抽干近敌 6 点内息；若我方侠客抢先砍倒桃杖，不仅当场痛饮桃林甘露（回补 20 内息与 15 气血），两杖尽毁更令夸父陷入『道渴力竭』（武艺-15、近防-12）！",
	CounterHint = "派前排主力抢先砍倒 2 株【邓林弃杖桃木】痛饮甘露回气回血，令夸父道渴力竭！",
	StructureMode = "totems",
	Headless = true,
	ImmuneStun = true,
	ImmuneDisarm = true,
	DefaultTotemCount = 2, TotemShieldPerUnit = 0.16,
	InitFieldKind = "drought_scorch",
	Parts = [
		{ Key = "peach_staff_1", Name = "邓林弃杖甘露桃木·日阳", HP = 85, Brush = "wx_totem_peach_staff" },
		{ Key = "peach_staff_2", Name = "邓林弃杖甘露桃木·渭水", HP = 85, Brush = "wx_totem_peach_staff" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_kuafu_denglin_sweep <- {
	Name = "邓林桃杖横扫八荒", Desc = "挥动万钧神木巨杖横扫扇形三格，崩毁22点护甲并铺焦土。",
	Geo = "cone_3", AP = 5, Qi = 18, CD = 1, Field = "drought_scorch",
	Hit = 14, Dmg = 1.22, Arm = 1.35, Pen = 0.10,
	BurnArm = 22, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_staff_fengmo.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_kuafu_thirst_drain <- {
	Name = "北饮大泽渴渊吼", Desc = "仰天焦渴咆哮抽干周身 6 格敌军 16 点内息！",
	Geo = "ring_quake_6", AP = 4, Qi = 16, CD = 2, Field = "drought_scorch",
	Hit = 12, Dmg = 1.12, Arm = 1.15, Pen = 0.08,
	BurnArm = 14, DrainQi = 16, DrainHP = 0, Status = "scatter",
	Vfx = "wx_vfx_29", Icon = "skills/wx_neigong_taotie.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_kuafu_sun_chase_stride <- {
	Name = "逐日入日跨山踏", Desc = "巨神迈开逐日大步直线践踏 3 格敌阵。",
	Geo = "line_charge_3", AP = 5, Qi = 20, CD = 2, Field = "drought_scorch",
	Hit = 14, Dmg = 1.24, Arm = 1.30, Pen = 0.10,
	BurnArm = 20, DrainQi = 10, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_29", Icon = "skills/wx_hammer_pocheng.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_kuafu <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_kuafu",
	TraitID = "special.wx_boss_trait_kuafu",
	Skills = ["scripts/skills/actives/wx_boss_kuafu_denglin_sweep", "scripts/skills/actives/wx_boss_kuafu_thirst_drain", "scripts/skills/actives/wx_boss_kuafu_sun_chase_stride"],
	CounterHint = "派前排主力抢先砍倒 2 株【邓林弃杖桃木】痛饮甘露回气回血，令夸父道渴力竭！"
};

// 49. 涿鹿兵主蚩尤 (大荒海内经 · 1+3 凶黎五兵青铜魔冢阵眼)
::Wuxia.ShanHaiBossSpecs.chiyou <- {
	Key = "chiyou", Chapter = "大荒海内经",
	TraitName = "铜头铁额·五兵魔冢百里雾主",
	CanonQuote = "《大荒北经/龙鱼河图》：蚩尤铜头铁额，食铁石，作五兵伐黄帝，请风伯雨师，纵大风雨兴百里大雾。",
	TraitDesc = "万古兵主残魄：场上竖立【魔戈·魔钺·魔弩】三座青铜五兵魔冢，各赋予蚩尤独立神通（魔戈+12近防、魔钺+25%破甲、魔弩+12武艺与14远防）并兴涿鹿大雾！按需先行拔除对应魔冢即可逐项剥夺兵主神兵加持！",
	CounterHint = "以《八门金锁/狮子吼》破百里大雾，优先捣毁【断岳魔钺冢】与【裂天魔戈冢】卸其攻防！",
	StructureMode = "totems",
	MinAP = 10,
	Headless = true,
	ImmuneStun = true,
	ImmuneDisarm = true,
	DefaultTotemCount = 3, TotemShieldPerUnit = 0.16,
	InitFieldKind = "mirage_mist",
	Parts = [
		{ Key = "armory_ge", Name = "凶黎五兵魔冢·裂天魔戈", HP = 95, Brush = "wx_totem_chiyou_armory" },
		{ Key = "armory_yue", Name = "凶黎五兵魔冢·断岳魔钺", HP = 95, Brush = "wx_totem_chiyou_armory" },
		{ Key = "armory_nu", Name = "凶黎五兵魔冢·贯日魔弩", HP = 95, Brush = "wx_totem_chiyou_armory" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_chiyou_five_arms_cleave <- {
	Name = "万古五兵裂天斩", Desc = "五兵齐鸣横劈前方扇形三格，崩碎26点重甲并挂【破绽】。",
	Geo = "cone_3", AP = 5, Qi = 20, CD = 1, Field = "",
	Hit = 16, Dmg = 1.26, Arm = 1.40, Pen = 0.14,
	BurnArm = 26, DrainQi = 8, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_02", Icon = "skills/wx_saber_chiyou.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_chiyou_wind_rain_fog <- {
	Name = "请风伯雨师兴大雾", Desc = "召唤涿鹿百里迷雾与狂风席卷敌阵，散去真气并遮蔽视野。",
	Geo = "sonic_roar", AP = 4, Qi = 16, CD = 2, Field = "mirage_mist",
	Hit = 12, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 12, DrainHP = 0, Status = "scatter",
	Vfx = "wx_vfx_25", Icon = "skills/wx_tactics_qimen.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_chiyou_bronze_head_ram <- {
	Name = "铜头铁额五兵齐射", Desc = "催动场上存活【五兵魔冢】齐射兵煞锋芒贯穿敌阵致内伤。",
	Geo = "totem_ray", AP = 5, Qi = 20, CD = 2, Field = "gale_sand",
	Hit = 15, Dmg = 1.24, Arm = 1.35, Pen = 0.12,
	BurnArm = 22, DrainQi = 8, DrainHP = 0, Status = "injury",
	Vfx = "wx_vfx_17", Icon = "skills/wx_henglian_tongtou.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_chiyou <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_chiyou",
	TraitID = "special.wx_boss_trait_chiyou",
	Skills = ["scripts/skills/actives/wx_boss_chiyou_five_arms_cleave", "scripts/skills/actives/wx_boss_chiyou_wind_rain_fog", "scripts/skills/actives/wx_boss_chiyou_bronze_head_ram"],
	CounterHint = "以《八门金锁/狮子吼》破百里大雾，优先捣毁【断岳魔钺冢】与【裂天魔戈冢】卸其攻防！"
};

// 50. 畴华持盾凿齿 (大荒海内经 · 单格异律法相：戈盾拒矢 → 斧碎铁盾后羿一箭穿胸)
::Wuxia.ShanHaiBossSpecs.zaochi <- {
	Key = "zaochi", Chapter = "大荒海内经",
	TraitName = "齿长六尺·畴华持戈盾抗羿相",
	CanonQuote = "《海外南经/淮南子》：羿与凿齿战于寿华之野，羿射杀之；为人兽首，齿如凿，长五六尺，持戈盾。",
	TraitDesc = "单格畴华凶魔：手持【兽面巨铁盾】严密护身（未破盾前远防+28且减免 70% 远程伤害）；一旦派巨斧猛士劈碎其手中铁盾，不仅永久封印戈盾推进，更还原『后羿射杀凿齿』典故——此后一切远程射击对其造成 +50% 贯胸暴伤！",
	CounterHint = "先派巨斧手《劈盾/力劈华山》劈碎其手中巨铁盾，随后强弓劲弩集火享 +50% 后羿诛魔暴伤！",
	StructureMode = "mythic_law",
	Headless = true,
	ImmuneDisarm = true,
	InternalPartKey = "iron_shield", InternalPartName = "畴华兽面巨铁盾", InternalPartType = "shell",
	InternalBreakMode = "axe", InternalBreakMax = 2, InternalLockedSkill = "actives.wx_boss_zaochi_shield_phalanx",
};

::Wuxia.ShanHaiBossMoves.wx_boss_zaochi_shield_phalanx <- {
	Name = "持戈盾畴华推进", Desc = "高举兽面巨盾直线撞退 3 格敌军并崩毁20护甲（巨斧劈碎铁盾即永久封印）。",
	Geo = "line_charge_3", AP = 5, Qi = 18, CD = 2, Field = "",
	Hit = 13, Dmg = 1.20, Arm = 1.30, Pen = 0.08,
	BurnArm = 20, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_shield_tiebi.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_zaochi_chisel_fang <- {
	Name = "六尺凿齿透铠噬", Desc = "六尺长牙如铁凿直穿重铠（穿甲+20%），重创脏腑【内伤】。",
	Geo = "single", AP = 4, Qi = 16, CD = 1, Field = "blood_pool",
	Hit = 15, Dmg = 1.24, Arm = 1.30, Pen = 0.20,
	BurnArm = 22, DrainQi = 0, DrainHP = 0, Status = "injury",
	Vfx = "wx_vfx_08", Icon = "skills/wx_dagger_zhuanzhu.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_zaochi_halberd_hook <- {
	Name = "青铜战戈横钩斩", Desc = "长戈横扫扇形三格割裂流血。",
	Geo = "cone_3", AP = 5, Qi = 18, CD = 1, Field = "",
	Hit = 13, Dmg = 1.18, Arm = 1.25, Pen = 0.10,
	BurnArm = 16, DrainQi = 6, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_01", Icon = "skills/wx_pole_goulian.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_zaochi <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_zaochi",
	TraitID = "special.wx_boss_trait_zaochi",
	Skills = ["scripts/skills/actives/wx_boss_zaochi_shield_phalanx", "scripts/skills/actives/wx_boss_zaochi_chisel_fang", "scripts/skills/actives/wx_boss_zaochi_halberd_hook"],
	CounterHint = "先派巨斧手《劈盾/力劈华山》劈碎其手中巨铁盾，随后强弓劲弩集火享 +50% 后羿诛魔暴伤！"
};

// 51. 疏属反缚贰负尸 (大荒海内经 · 单格异律法相：铁枷困神二阶段脱缚怨起)
::Wuxia.ShanHaiBossSpecs.erfu <- {
	Key = "erfu", Chapter = "大荒海内经",
	TraitName = "疏属反缚·断枷怨尸双态相",
	CanonQuote = "《海内西经》：贰负之臣曰危，杀猰貐，帝乃梏之疏属之山，桎其右足，反缚两手与发，系之山上木。",
	TraitDesc = "单格受梏蛇身古神尸：初被玄铁重枷反缚（减伤28%且抡重枷封穴）；重锤敲断重枷可封其重枷横砸，但濒死瞬间贰负将挣断天帝桎梏怨毒复起（回血135并入 10 AP 狂尸二阶段）——唯提前施《断续封生印》或纯阳烈火可镇杀于枷下！",
	CounterHint = "重锤破枷封印重枷横砸，濒死斩杀前务必挂《钦原断续蚀壳膏》或以纯阳烈火阻止其断枷尸变！",
	StructureMode = "mythic_law",
	Headless = true,
	InternalPartKey = "iron_shackle", InternalPartName = "疏属山反缚玄铁重枷", InternalPartType = "shell",
	InternalBreakMode = "blunt", InternalBreakMax = 2, InternalLockedSkill = "actives.wx_boss_erfu_shackle_smash",
};

::Wuxia.ShanHaiBossMoves.wx_boss_erfu_shackle_smash <- {
	Name = "反缚玄铁重枷砸", Desc = "抡起身上万钧囚神铁枷猛砸前方三格，震封经脉【点穴封气】（重锤砸断铁枷即封印）。",
	Geo = "cone_3", AP = 5, Qi = 20, CD = 1, Field = "",
	Hit = 13, Dmg = 1.22, Arm = 1.35, Pen = 0.10,
	BurnArm = 22, DrainQi = 10, DrainHP = 0, Status = "acupoint",
	Vfx = "wx_vfx_17", Icon = "skills/wx_flail_liuxing.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_erfu_serpent_drag <- {
	Name = "桎足蛇身锁链拽", Desc = "铁索缠卷将 1~2 格敌手强拽至身前失衡。",
	Geo = "pull_devour", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 14, Dmg = 1.16, Arm = 1.20, Pen = 0.08,
	BurnArm = 14, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_pole_goulian.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_erfu_grudge_eruption <- {
	Name = "疏属囚神千年怨", Desc = "爆发被缚千年之尸怨冲击周身 6 格散去真气。",
	Geo = "ring_quake_6", AP = 4, Qi = 16, CD = 2, Field = "bitter_mire",
	Hit = 11, Dmg = 1.14, Arm = 1.15, Pen = 0.08,
	BurnArm = 12, DrainQi = 12, DrainHP = 0, Status = "scatter",
	Vfx = "wx_vfx_30", Icon = "skills/wx_whip_xiangxi.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_erfu <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_erfu",
	TraitID = "special.wx_boss_trait_erfu",
	Skills = ["scripts/skills/actives/wx_boss_erfu_shackle_smash", "scripts/skills/actives/wx_boss_erfu_serpent_drag", "scripts/skills/actives/wx_boss_erfu_grudge_eruption"],
	CounterHint = "重锤破枷封印重枷横砸，濒死斩杀前务必挂《钦原断续蚀壳膏》或以纯阳烈火阻止其断枷尸变！"
};

// 52. 会稽专车巨灵防风氏 (大荒海内经 · 单格异律法相：三丈专车巨骨唯重钝可碎)
::Wuxia.ShanHaiBossSpecs.fangfeng <- {
	Key = "fangfeng", Chapter = "大荒海内经",
	TraitName = "骨节专车·三丈守风巨神骸",
	CanonQuote = "《国语/大荒》：昔禹致群神于会稽之山，防风氏后至，禹杀而戮之，其骨节专车，守封嵎之山。",
	TraitDesc = "单格身长三丈、一节骸骨可装满整车之巨灵古骸：免疫流血、奇毒与眩晕，普通刀剑弓矢砍射巨骨伤害直降 45%！唯【重锤/金瓜铁锏/玄铁重剑/少林隔甲寸劲】可震裂专车巨骨打出 132% 碎骨暴伤！",
	CounterHint = "严禁轻刀弓箭刮痧！全员换装【重锤/铁锏/重剑/寸劲拳掌】硬砸专车巨骨！",
	StructureMode = "mythic_law",
	Headless = true,
	ImmuneStun = true,
	InitFieldKind = "gale_sand",
};

::Wuxia.ShanHaiBossMoves.wx_boss_fangfeng_cart_bone_slam <- {
	Name = "专车巨骨裂岳砸", Desc = "挥动大如车轴的骸骨重臂横砸三格，崩碎26点重甲并卷起风沙。",
	Geo = "cone_3", AP = 5, Qi = 20, CD = 1, Field = "gale_sand",
	Hit = 13, Dmg = 1.25, Arm = 1.45, Pen = 0.10,
	BurnArm = 26, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_hammer_qianjun.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_fangfeng_guiji_typhoon <- {
	Name = "封嵎守风飓暴吼", Desc = "巨灵咆哮引爆全场【裂风沙暴】震飞近敌。",
	Geo = "ring_quake_6", AP = 5, Qi = 18, CD = 2, Field = "gale_sand",
	Hit = 12, Dmg = 1.18, Arm = 1.25, Pen = 0.08,
	BurnArm = 18, DrainQi = 10, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_15", Icon = "skills/wx_hammer_quake.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_fangfeng_titan_stomp <- {
	Name = "三丈神骸踏山扑", Desc = "沉重跨跃践踏 1~2 格目标致脏腑重伤。",
	Geo = "leap_slam_3", AP = 5, Qi = 20, CD = 2, Field = "",
	Hit = 13, Dmg = 1.22, Arm = 1.35, Pen = 0.10,
	BurnArm = 22, DrainQi = 8, DrainHP = 0, Status = "injury",
	Vfx = "wx_vfx_17", Icon = "skills/wx_hammer_pocheng.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_fangfeng <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_fangfeng",
	TraitID = "special.wx_boss_trait_fangfeng",
	Skills = ["scripts/skills/actives/wx_boss_fangfeng_cart_bone_slam", "scripts/skills/actives/wx_boss_fangfeng_guiji_typhoon", "scripts/skills/actives/wx_boss_fangfeng_titan_stomp"],
	CounterHint = "严禁轻刀弓箭刮痧！全员换装【重锤/铁锏/重剑/寸劲拳掌】硬砸专车巨骨！"
};

// 53. 昆仑百神门开明兽 (大荒海内经 · 三格九首天兽：虎躯主身 + 司刑人面虎首 + 司御金甲虎首)
::Wuxia.ShanHaiBossSpecs.kaiming <- {
	Key = "kaiming", Chapter = "大荒海内经",
	TraitName = "九首人面·东向立昆仑百神门",
	CanonQuote = "《海内西经》：昆仑南渊深三百仞，开明兽身大类虎而九首，皆人面，东向立昆仑上，天兽守门。",
	TraitDesc = "镇守昆仑九门之三格多首天兽：主躯两翼探出独立人面【司刑怒目虎首】与【司御金甲虎首】（每存 1 首为主躯提供 +7 近防并镇守侧翼）；分兵逐一斩落两具伴生人面虎首，即可破除天门铁壁并封印神光与金爪！",
	CounterHint = "分左右两路优先斩落【司刑怒目虎首】与【司御金甲虎首】削去 14 点护主近防并封死双凶招！",
	StructureMode = "appendages",
	Headless = true,
	ImmuneStun = true,
	Parts = [
		{ Key = "wrath_head", Name = "开明兽·司刑怒目人面虎首", HP = 135, BodyArmor = 165, HeadArmor = 155, MeleeDef = 12, Brush = "wx_part_kaiming_wrath", LockedSkillID = "actives.wx_boss_kaiming_nine_glare" },
		{ Key = "guard_head", Name = "开明兽·司御金甲人面虎首", HP = 135, BodyArmor = 185, HeadArmor = 175, MeleeDef = 12, Brush = "wx_part_kaiming_guard", LockedSkillID = "actives.wx_boss_kaiming_gate_sweep" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_kaiming_nine_glare <- {
	Name = "东向立昆仑天威光", Desc = "九首齐张射出昆仑天刑神光封锁 1~4 格目标气穴（斩司刑虎首即永久封印）。",
	Geo = "ranged_barrage", AP = 4, Qi = 16, CD = 1, Field = "",
	Hit = 16, Dmg = 1.18, Arm = 1.20, Pen = 0.14,
	BurnArm = 16, DrainQi = 10, DrainHP = 0, Status = "acupoint",
	Vfx = "wx_vfx_24", Icon = "skills/wx_sword_zhenwu.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_kaiming_gate_sweep <- {
	Name = "百神之门金爪扫", Desc = "巨虎金爪横扫前方三格撕碎24点护甲挂【破绽】（斩司御虎首即封印）。",
	Geo = "cone_3", AP = 5, Qi = 20, CD = 1, Field = "",
	Hit = 15, Dmg = 1.24, Arm = 1.35, Pen = 0.10,
	BurnArm = 24, DrainQi = 8, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_08", Icon = "skills/wx_fist_jingang.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_kaiming_abyss_roar <- {
	Name = "三百仞南渊镇狱吼", Desc = "九首同吼震荡周身 6 格敌军失衡。",
	Geo = "ring_quake_6", AP = 4, Qi = 18, CD = 2, Field = "",
	Hit = 12, Dmg = 1.15, Arm = 1.20, Pen = 0.08,
	BurnArm = 14, DrainQi = 10, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_tactics_shihou.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_kaiming <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_kaiming",
	TraitID = "special.wx_boss_trait_kaiming",
	Skills = ["scripts/skills/actives/wx_boss_kaiming_nine_glare", "scripts/skills/actives/wx_boss_kaiming_gate_sweep", "scripts/skills/actives/wx_boss_kaiming_abyss_roar"],
	CounterHint = "分左右两路优先斩落【司刑怒目虎首】与【司御金甲虎首】削去 14 点护主近防并封死双凶招！"
};

// 54. 汤谷扶桑三足金乌皇 (大荒海内经 · 1+3 扶桑浴日三足阳炎轮阵眼)
::Wuxia.ShanHaiBossSpecs.jinwu <- {
	Key = "jinwu", Chapter = "大荒海内经",
	TraitName = "汤谷扶桑·十日载乌焚天皇",
	CanonQuote = "《海外东经/大荒东经》：汤谷上有扶桑，十日所浴，九日居下枝，一日居上枝，皆载于乌。",
	TraitDesc = "大日真火三足金乌皇：开场悬起 3 轮【扶桑浴日阳炎轮】（每轮减伤 18% 并每回合为金乌蓄积 +10% 大日真火增伤，最高+30%）；效仿后羿射日，每射爆 1 轮阳炎轮当场清空其真火层数并反噬 30 气血！",
	CounterHint = "神弓/劲弩优先『后羿射日』点爆 3 轮【扶桑浴日阳炎轮】断其真火叠层与减伤，玄阴掌清焦土！",
	StructureMode = "totems",
	MinAP = 11,
	DefaultTotemCount = 3, TotemShieldPerUnit = 0.18,
	InitFieldKind = "drought_scorch",
	TurnFieldKind = "drought_scorch",
	InitWeather = "nvchou_scorch",
	Parts = [
		{ Key = "fusang_sun_1", Name = "扶桑上枝浴日阳炎轮·朝曦", HP = 80, Brush = "wx_totem_fusang_sun" },
		{ Key = "fusang_sun_2", Name = "扶桑下枝浴日阳炎轮·正阳", HP = 80, Brush = "wx_totem_fusang_sun" },
		{ Key = "fusang_sun_3", Name = "扶桑汤谷浴日阳炎轮·暮火", HP = 80, Brush = "wx_totem_fusang_sun" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_jinwu_fusang_solar_flare <- {
	Name = "扶桑十日贯空炎", Desc = "引动场上【扶桑浴日阳炎轮】齐射熔金日珥光束，焚毁22护甲并铺焦土。",
	Geo = "totem_ray", AP = 5, Qi = 20, CD = 1, Field = "drought_scorch",
	Hit = 16, Dmg = 1.24, Arm = 1.35, Pen = 0.14,
	BurnArm = 22, DrainQi = 10, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_29", Icon = "skills/wx_bow_luori.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_jinwu_three_claw_dive <- {
	Name = "三足金乌焚城扑", Desc = "化作一轮烈日俯冲 2~3 格重创目标。",
	Geo = "leap_slam_3", AP = 4, Qi = 16, CD = 1, Field = "drought_scorch",
	Hit = 15, Dmg = 1.20, Arm = 1.25, Pen = 0.12,
	BurnArm = 18, DrainQi = 8, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_02", Icon = "skills/wx_sword_feixian.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_jinwu_bath_of_fire <- {
	Name = "汤谷浴日万火燎原", Desc = "引爆全战场【赤旱焦土】冲起十日炎柱震散真气。",
	Geo = "field_detonate", AP = 5, Qi = 22, CD = 3, Field = "drought_scorch",
	Hit = 13, Dmg = 1.22, Arm = 1.30, Pen = 0.12,
	BurnArm = 20, DrainQi = 12, DrainHP = 0, Status = "scatter",
	Vfx = "wx_vfx_29", Icon = "skills/wx_saber_ranmu.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_jinwu <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_jinwu",
	TraitID = "special.wx_boss_trait_jinwu",
	Skills = ["scripts/skills/actives/wx_boss_jinwu_fusang_solar_flare", "scripts/skills/actives/wx_boss_jinwu_three_claw_dive", "scripts/skills/actives/wx_boss_jinwu_bath_of_fire"],
	CounterHint = "神弓/劲弩优先『后羿射日』点爆 3 轮【扶桑浴日阳炎轮】断其真火叠层与减伤，玄阴掌清焦土！"
};

// 55. 林氏国五采仁虎驺虞 (大荒海内经 · 单格异律法相：仁兽不杀降卒·专挫锋芒高手)
::Wuxia.ShanHaiBossSpecs.zouyu <- {
	Key = "zouyu", Chapter = "大荒海内经",
	TraitName = "五采毕具·不杀降卒千里仁虎",
	CanonQuote = "《海内北经》：林氏国有珍兽，大若虎，五采毕具，尾长于身，名曰驺虞，乘之日行千里。",
	TraitDesc = "单格五采仁虎：恪守仁兽天律——对已陷入战意动摇的弱者手下留情（伤害折减35%），却专挑武艺≥75 的绝顶锋芒高手精准制裁（命中+14并震散杀气）！以捕网/拒马限其 11 AP 纵跃，利刃断长尾可封其摆尾扫！",
	CounterHint = "用《天罗捕网/铁枪拒马》限制其 11 AP 千里腾跃，统帅清散功、利刃斩断五采长尾！",
	StructureMode = "mythic_law",
	MinAP = 11,
	RegenHP = 15,
	InternalPartKey = "five_color_tail", InternalPartName = "长于身五采灵尾", InternalPartType = "tail",
	InternalBreakMode = "blade", InternalBreakMax = 3, InternalLockedSkill = "actives.wx_boss_zouyu_long_tail_sweep",
};

::Wuxia.ShanHaiBossMoves.wx_boss_zouyu_thousand_li_leap <- {
	Name = "日行千里踏云跃", Desc = "五采神躯瞬息跨跃 2~3 格拍中锋芒高手肩井穴挂【破绽】。",
	Geo = "leap_slam_3", AP = 4, Qi = 15, CD = 1, Field = "",
	Hit = 16, Dmg = 1.18, Arm = 1.20, Pen = 0.12,
	BurnArm = 14, DrainQi = 8, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_24", Icon = "skills/wx_qinggong_zongyue.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_zouyu_long_tail_sweep <- {
	Name = "尾长于身五采扫", Desc = "长逾虎身的五彩灵尾横扫三格卸力击退（利刃斩断五采长尾即永久封印）。",
	Geo = "tail_sweep_arc", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 14, Dmg = 1.18, Arm = 1.20, Pen = 0.08,
	BurnArm = 14, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_24", Icon = "skills/wx_saber_bagua.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_zouyu_benevolent_awe <- {
	Name = "林氏仁兽止戈威", Desc = "五采瑞光普照震散周身敌军杀伐真气【散功虚弱】。",
	Geo = "sonic_roar", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 12, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 12, DrainHP = 0, Status = "scatter",
	Vfx = "wx_vfx_24", Icon = "skills/wx_neigong_guiyuan.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_zouyu <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_zouyu",
	TraitID = "special.wx_boss_trait_zouyu",
	Skills = ["scripts/skills/actives/wx_boss_zouyu_thousand_li_leap", "scripts/skills/actives/wx_boss_zouyu_long_tail_sweep", "scripts/skills/actives/wx_boss_zouyu_benevolent_awe"],
	CounterHint = "用《天罗捕网/铁枪拒马》限制其 11 AP 千里腾跃，统帅清散功、利刃斩断五采长尾！"
};

// 56. 怒触不周水神共工 (大荒海内经 · 双格巨蛇神躯：朱发神首 + 不周黑水巨蛇躯)
::Wuxia.ShanHaiBossSpecs.gonggong <- {
	Key = "gonggong", Chapter = "大荒海内经",
	TraitName = "朱发蛇身·天倾西北水归低躯",
	CanonQuote = "《淮南子/大荒西经》：共工人面蛇身朱发，怒而触不周之山，天柱折，地维绝，天倾西北，水潦尘埃归焉。",
	TraitDesc = "双格上古水神（共工首 + 不周黑水巨蛇躯）：应验『天倾西北，水潦归低』高低差法则——对地势低于共工或踏于【玄冥冻土】者伤害暴涨 +25%，而抢占高地（地势高于共工）者受共工伤害直减 25%！碎蛇躯封黑水倾泻！",
	CounterHint = "全队抢占高于共工的山坡高地减伤 25%，重兵集火打碎【不周黑水巨蛇躯】封印黑水寒潮！",
	StructureMode = "segments",
	Headless = true,
	ImmuneStun = true,
	InitFieldKind = "abyss_frost",
	TurnFieldKind = "abyss_frost",
	Parts = [
		{ Key = "blackwater_body", Name = "共工·不周黑水巨蛇躯", BodyArmor = 265, HeadArmor = 195, MeleeDef = 12, Brush = "wx_tail_gonggong", LockedSkillID = "actives.wx_boss_gonggong_tilt_deluge" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_gonggong_pillar_shatter <- {
	Name = "怒触不周天柱折", Desc = "朱发怒张化作崩天洪流直线撞穿 3 格，粉碎26点重甲致失衡（高台可减免其洪威）。",
	Geo = "line_charge_3", AP = 5, Qi = 22, CD = 2, Field = "abyss_frost",
	Hit = 15, Dmg = 1.28, Arm = 1.40, Pen = 0.12,
	BurnArm = 26, DrainQi = 10, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_21", Icon = "skills/wx_spear_zhenbiao.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_gonggong_tilt_deluge <- {
	Name = "地维绝黑水东倾", Desc = "黑水巨蛇躯掀起三格灭世寒潮冻结经脉（击碎不周黑水巨蛇躯即永久封印）。",
	Geo = "cone_3", AP = 5, Qi = 18, CD = 1, Field = "abyss_frost",
	Hit = 14, Dmg = 1.20, Arm = 1.25, Pen = 0.10,
	BurnArm = 18, DrainQi = 12, DrainHP = 0, Status = "acupoint",
	Vfx = "wx_vfx_21", Icon = "skills/wx_fist_nuchao.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_gonggong_red_hair_lash <- {
	Name = "朱发狂涛震八荒", Desc = "漫天赤发与黑水激荡轰击周身 6 格致内伤。",
	Geo = "ring_quake_6", AP = 4, Qi = 18, CD = 2, Field = "abyss_frost",
	Hit = 12, Dmg = 1.16, Arm = 1.20, Pen = 0.08,
	BurnArm = 16, DrainQi = 8, DrainHP = 0, Status = "injury",
	Vfx = "wx_vfx_21", Icon = "skills/wx_pole_pojun.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_gonggong <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_gonggong",
	TraitID = "special.wx_boss_trait_gonggong",
	Skills = ["scripts/skills/actives/wx_boss_gonggong_pillar_shatter", "scripts/skills/actives/wx_boss_gonggong_tilt_deluge", "scripts/skills/actives/wx_boss_gonggong_red_hair_lash"],
	CounterHint = "全队抢占高于共工的山坡高地减伤 25%，重兵集火打碎【不周黑水巨蛇躯】封印黑水寒潮！"
};

// 57. 湘南苍黑青兕 (大荒海内经 · 单格异律法相：正面铁革减伤45% vs 绕背突袭+25%)
::Wuxia.ShanHaiBossSpecs.siwang <- {
	Key = "siwang", Chapter = "大荒海内经",
	TraitName = "舜葬湘南·正甲坚不可摧兕相",
	CanonQuote = "《海内南经》：兕在舜葬东，湘水南，其状如牛，苍黑，一角；制以为甲，坚不可摧。",
	TraitDesc = "单格苍梧铁兕：正面额肩兕革厚重无匹，承受正前方扇面（0/1/5向）一切实伤与破甲均减免 45%！唯借轻功绕至其侧后臀腹（2/3/4向）背刺享 +25% 额外暴伤，重锤断独角可封破城冲！",
	CounterHint = "前排举盾诱敌牵制正面，主力轻功绕至青兕【侧后盲区】背刺享 +25% 暴伤，重锤敲断独角！",
	StructureMode = "mythic_law",
	Headless = true,
	ImmuneStun = true,
	InternalPartKey = "rhino_horn", InternalPartName = "湘南苍黑破城独角", InternalPartType = "horn",
	InternalBreakMode = "blunt", InternalBreakMax = 2, InternalLockedSkill = "actives.wx_boss_siwang_city_breaker",
};

::Wuxia.ShanHaiBossMoves.wx_boss_siwang_city_breaker <- {
	Name = "湘南独角破城冲", Desc = "万钧苍黑巨躯顶角狂冲 3 格，一击崩碎28点重铠（重锤敲断破城独角即永久封印）。",
	Geo = "line_charge_3", AP = 5, Qi = 20, CD = 2, Field = "",
	Hit = 14, Dmg = 1.26, Arm = 1.45, Pen = 0.10,
	BurnArm = 28, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_hammer_pocheng.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_siwang_iron_hide_quake <- {
	Name = "苍梧铁革震岳踏", Desc = "四蹄重踏震裂周身 6 格敌军架势【破绽】。",
	Geo = "ring_quake_6", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 11, Dmg = 1.15, Arm = 1.25, Pen = 0.06,
	BurnArm = 16, DrainQi = 8, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_17", Icon = "skills/wx_henglian_panshi.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_siwang_horn_gore <- {
	Name = "青兕挑腹裂创顶", Desc = "低首猛挑前排腹部造成重创流血。",
	Geo = "single", AP = 4, Qi = 15, CD = 1, Field = "",
	Hit = 13, Dmg = 1.20, Arm = 1.30, Pen = 0.10,
	BurnArm = 20, DrainQi = 0, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_spear_bawang.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_siwang <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_siwang",
	TraitID = "special.wx_boss_trait_siwang",
	Skills = ["scripts/skills/actives/wx_boss_siwang_city_breaker", "scripts/skills/actives/wx_boss_siwang_iron_hide_quake", "scripts/skills/actives/wx_boss_siwang_horn_gore"],
	CounterHint = "前排举盾诱敌牵制正面，主力轻功绕至青兕【侧后盲区】背刺享 +25% 暴伤，重锤敲断独角！"
};

// 58. 北极天柜九凤 (大荒海内经 · 三格九首妖禽：妖禽主躯 + 泣血人面妖首 + 摄魂人面妖首)
::Wuxia.ShanHaiBossSpecs.jiufeng <- {
	Key = "jiufeng", Chapter = "大荒海内经",
	TraitName = "北极天柜·九首人面泣血妖皇",
	CanonQuote = "《大荒北经》：大荒之中，有山名曰北极天柜，海水北注焉，有神九首人面鸟身，名曰九凤。",
	TraitDesc = "三格九首妖禽皇：主躯两侧探出长颈人面【北极泣血妖首】与【北极摄魂妖首】；若用普通冷兵刃斩落妖首，断颈腥血将在地面爆出【凶煞血池】并反哺九凤 35 点气血！唯以纯阳/烈火/火器灼烧斩首方可净血绝根！",
	CounterHint = "务必由纯阳内功侠客或持《燃木刀/火焰刀/雷火铳》收尾灼斩两具妖首，阻止断颈爆血回哺！",
	StructureMode = "appendages",
	MinAP = 10,
	SeverSpillField = "blood_pool",
	Parts = [
		{ Key = "blood_head", Name = "九凤·北极泣血人面妖首", HP = 115, BodyArmor = 125, HeadArmor = 115, MeleeDef = 14, Brush = "wx_part_jiufeng_blood", LockedSkillID = "actives.wx_boss_jiufeng_blood_plume" },
		{ Key = "soul_head", Name = "九凤·北极摄魂人面妖首", HP = 115, BodyArmor = 125, HeadArmor = 115, MeleeDef = 14, Brush = "wx_part_jiufeng_soul", LockedSkillID = "actives.wx_boss_jiufeng_nine_soul_cry" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_jiufeng_blood_plume <- {
	Name = "北极天柜泣血翎", Desc = "双翼洒下漫天泣血毒羽覆盖扇形三格并化【凶煞血池】（斩泣血人面妖首即封印）。",
	Geo = "cone_3", AP = 5, Qi = 18, CD = 1, Field = "blood_pool",
	Hit = 14, Dmg = 1.20, Arm = 1.20, Pen = 0.12,
	BurnArm = 16, DrainQi = 6, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_throw_fan.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_jiufeng_nine_soul_cry <- {
	Name = "九首人面摄魂啼", Desc = "九张人面同发诡笑啼哭震溃敌军战意（斩摄魂人面妖首即永久封印）。",
	Geo = "sonic_roar", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 12, Dmg = 1.00, Arm = 1.00, Pen = 0.00,
	BurnArm = 0, DrainQi = 12, DrainHP = 0, Status = "shaken",
	Vfx = "wx_vfx_30", Icon = "skills/wx_whip_xiangxi.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_jiufeng_crimson_swoop <- {
	Name = "海水北注噬血扑", Desc = "高空俯冲 2~3 格噬咬猎物汲取 24 点气血。",
	Geo = "leap_slam_3", AP = 5, Qi = 18, CD = 2, Field = "blood_pool",
	Hit = 15, Dmg = 1.20, Arm = 1.20, Pen = 0.12,
	BurnArm = 14, DrainQi = 0, DrainHP = 24, Status = "opening",
	Vfx = "wx_vfx_08", Icon = "skills/wx_qinggong_feiyan.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_jiufeng <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_jiufeng",
	TraitID = "special.wx_boss_trait_jiufeng",
	Skills = ["scripts/skills/actives/wx_boss_jiufeng_blood_plume", "scripts/skills/actives/wx_boss_jiufeng_nine_soul_cry", "scripts/skills/actives/wx_boss_jiufeng_crimson_swoop"],
	CounterHint = "务必由纯阳内功侠客或持《燃木刀/火焰刀/雷火铳》收尾灼斩两具妖首，阻止断颈爆血回哺！"
};

// 59. 白民二千岁乘黄 (大荒海内经 · 单格异律法相：近身夺寿元结琥珀金身 vs 远攻破气)
::Wuxia.ShanHaiBossSpecs.chenghuang <- {
	Key = "chenghuang", Chapter = "大荒海内经",
	TraitName = "背上有角·二千岁夺寿琥珀相",
	CanonQuote = "《海外西经》：白民之国有乘黄，其状如狐，其背上有角，乘之寿二千岁。",
	TraitDesc = "单格二千岁长生神狐：回合初若身旁贴有我方单位，立即抽吸其 8 点寿元内息凝成『二千岁琥珀障』（减免 35% 实伤并回血 20）；拉开两格长兵/弓弩距离令其无元可吸，或以破气技/利刃削断背角即可破金身！",
	CounterHint = "莫贴脸送寿元护盾！以两格长枪与弓弩隔格集火，并用《破气剑/一阳指》或快刃斩断背上龙角！",
	StructureMode = "mythic_law",
	MinAP = 10,
	RegenHP = 20,
	InternalPartKey = "back_dragon_horn", InternalPartName = "二千岁背生龙角", InternalPartType = "horn",
	InternalBreakMode = "blade_or_ranged", InternalBreakMax = 3, InternalLockedSkill = "actives.wx_boss_chenghuang_dragon_horn_ray",
};

::Wuxia.ShanHaiBossMoves.wx_boss_chenghuang_dragon_horn_ray <- {
	Name = "背上龙角贯虹光", Desc = "背生双龙角迸发金珀瑞虹贯穿直线 3 格封锁气穴（削断背上龙角即永久封印）。",
	Geo = "line_pierce_3", AP = 5, Qi = 18, CD = 1, Field = "",
	Hit = 15, Dmg = 1.20, Arm = 1.25, Pen = 0.14,
	BurnArm = 16, DrainQi = 10, DrainHP = 0, Status = "acupoint",
	Vfx = "wx_vfx_12", Icon = "skills/wx_fist_yiyang.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_chenghuang_longevity_pulse <- {
	Name = "寿二千岁夺元潮", Desc = "二千岁古狐生机流转，抽吸周身 6 格敌军 12 内息并自愈 20 气血。",
	Geo = "ring_quake_6", AP = 4, Qi = 16, CD = 2, Field = "",
	Hit = 12, Dmg = 1.12, Arm = 1.15, Pen = 0.08,
	BurnArm = 10, DrainQi = 12, DrainHP = 20, Status = "scatter",
	Vfx = "wx_vfx_24", Icon = "skills/wx_neigong_yijin.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_chenghuang_fox_grace_leap <- {
	Name = "白民国瑞影腾跃", Desc = "轻灵幻跃 2~3 格留迷障破敌架势。",
	Geo = "leap_slam_3", AP = 4, Qi = 15, CD = 1, Field = "mirage_mist",
	Hit = 15, Dmg = 1.16, Arm = 1.15, Pen = 0.10,
	BurnArm = 12, DrainQi = 0, DrainHP = 0, Status = "opening",
	Vfx = "wx_vfx_25", Icon = "skills/wx_qinggong_lingbo.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_chenghuang <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_chenghuang",
	TraitID = "special.wx_boss_trait_chenghuang",
	Skills = ["scripts/skills/actives/wx_boss_chenghuang_dragon_horn_ray", "scripts/skills/actives/wx_boss_chenghuang_longevity_pulse", "scripts/skills/actives/wx_boss_chenghuang_fox_grace_leap"],
	CounterHint = "莫贴脸送寿元护盾！以两格长枪与弓弩隔格集火，并用《破气剑/一阳指》或快刃斩断背上龙角！"
};

// 60. 从极渊河伯冰夷 (大荒海内经 · 1+2 从极寒渊盘龙玄冰柱阵眼)
::Wuxia.ShanHaiBossSpecs.bingyi <- {
	Key = "bingyi", Chapter = "大荒海内经",
	TraitName = "从极三百仞·人面乘两龙河伯",
	CanonQuote = "《海内北经》：从极之渊深三百仞，维冰夷恒都焉，冰夷人面，乘两龙。",
	TraitDesc = "三百仞极渊河伯水神：场上耸立 2 尊盘绕冰龙的【从极渊盘龙玄冰柱】赋予 40% 玄冰护盾；凡内息疲劳≥55 者被冰夷击中必遭寒极冻脉【点穴封气】！分兵砸碎左右 2 尊盘龙冰柱即可一举震碎全场玄冥冻土！",
	CounterHint = "分兵优先击碎左右 2 尊【从极渊盘龙玄冰柱】净除全场寒冰，控住疲劳水位防冻脉封穴！",
	StructureMode = "totems",
	MinAP = 10,
	ImmuneStun = true,
	DefaultTotemCount = 2, TotemShieldPerUnit = 0.20,
	InitFieldKind = "abyss_frost",
	TurnFieldKind = "abyss_frost",
	Parts = [
		{ Key = "ice_dragon_1", Name = "从极渊盘龙玄冰柱·左骖", HP = 100, Brush = "wx_totem_ice_dragon_pillar" },
		{ Key = "ice_dragon_2", Name = "从极渊盘龙玄冰柱·右服", HP = 100, Brush = "wx_totem_ice_dragon_pillar" },
	],
};

::Wuxia.ShanHaiBossMoves.wx_boss_bingyi_twin_dragon_frost <- {
	Name = "乘两龙寒渊合击", Desc = "引动场上【盘龙玄冰柱】齐喷极寒龙息交叉贯穿敌阵，封锁气穴【点穴封气】。",
	Geo = "totem_ray", AP = 5, Qi = 20, CD = 1, Field = "abyss_frost",
	Hit = 15, Dmg = 1.22, Arm = 1.25, Pen = 0.14,
	BurnArm = 18, DrainQi = 12, DrainHP = 0, Status = "acupoint",
	Vfx = "wx_vfx_21", Icon = "skills/wx_sword_xuanbing.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_bingyi_fathom_freeze <- {
	Name = "三百仞恒都冰封", Desc = "袖卷从极寒潮冰封前方扇形三格致失衡。",
	Geo = "cone_3", AP = 4, Qi = 16, CD = 1, Field = "abyss_frost",
	Hit = 14, Dmg = 1.18, Arm = 1.20, Pen = 0.10,
	BurnArm = 16, DrainQi = 10, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_21", Icon = "skills/wx_neigong_hanbing.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_bingyi_glacier_shatter <- {
	Name = "河伯碎冰断脉爆", Desc = "引爆全战场【玄冥冻土】炸裂寒冰尖刺重创踏冰者内腑。",
	Geo = "field_detonate", AP = 5, Qi = 20, CD = 3, Field = "abyss_frost",
	Hit = 13, Dmg = 1.22, Arm = 1.25, Pen = 0.12,
	BurnArm = 16, DrainQi = 10, DrainHP = 0, Status = "injury",
	Vfx = "wx_vfx_21", Icon = "skills/wx_fist_xuanming.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_bingyi <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_bingyi",
	TraitID = "special.wx_boss_trait_bingyi",
	Skills = ["scripts/skills/actives/wx_boss_bingyi_twin_dragon_frost", "scripts/skills/actives/wx_boss_bingyi_fathom_freeze", "scripts/skills/actives/wx_boss_bingyi_glacier_shatter"],
	CounterHint = "分兵优先击碎左右 2 尊【从极渊盘龙玄冰柱】净除全场寒冰，控住疲劳水位防冻脉封穴！"
};

// 61. 北极虎神强良 (大荒海内经 · 单格异律法相：长肘操蛇两格反噬远射)
::Wuxia.ShanHaiBossSpecs.qiangliang <- {
	Key = "qiangliang", Chapter = "大荒海内经",
	TraitName = "虎首人身·长肘操蛇反噬相",
	CanonQuote = "《大荒北经》：大荒之中，有山名曰北极天柜，有神，口衔蛇，操蛇，其状虎首人身，四蹄长肘，名曰强良。",
	TraitDesc = "单格北极凶猛虎神：臂肘修长且口手操握赤毒蛇——凡在 2 格内对其施展远程射击者，必遭赤蛇隔空反噬染【奇毒】！以快剑/飞刀精准斩断其口手所操赤毒蛇，即可拔除两格反噬并封印操蛇抓噬！",
	CounterHint = "切勿在 2 格内开弓放镖！先派刀剑好手贴身斩断其【口衔操握赤毒蛇】绝其毒噬！",
	StructureMode = "mythic_law",
	Headless = true,
	ImmuneStun = true,
	InternalPartKey = "held_serpent", InternalPartName = "口衔操握赤毒蛇", InternalPartType = "head",
	InternalBreakMode = "blade_or_ranged", InternalBreakMax = 2, InternalLockedSkill = "actives.wx_boss_qiangliang_mouth_serpent",
};

::Wuxia.ShanHaiBossMoves.wx_boss_qiangliang_mouth_serpent <- {
	Name = "口衔操蛇双毒噬", Desc = "口手赤蛇猛然窜出将 1~2 格猎物拽近注入烈性蛇毒（快刃斩断赤毒蛇即永久封印）。",
	Geo = "pull_devour", AP = 4, Qi = 16, CD = 1, Field = "bitter_mire",
	Hit = 15, Dmg = 1.20, Arm = 1.20, Pen = 0.12,
	BurnArm = 14, DrainQi = 8, DrainHP = 16, Status = "poison",
	Vfx = "wx_vfx_22", Icon = "skills/wx_flail_jinshe.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_qiangliang_long_elbow_cleave <- {
	Name = "四蹄长肘裂阵横扫", Desc = "借超长铁肘挥动重戈横扫扇形三格，崩毁22点护甲并致深创流血。",
	Geo = "cone_3", AP = 5, Qi = 20, CD = 1, Field = "",
	Hit = 14, Dmg = 1.24, Arm = 1.35, Pen = 0.10,
	BurnArm = 22, DrainQi = 6, DrainHP = 0, Status = "bleed",
	Vfx = "wx_vfx_08", Icon = "skills/wx_pole_fangtian.png"
};

::Wuxia.ShanHaiBossMoves.wx_boss_qiangliang_tiger_god_leap <- {
	Name = "北极虎神踏阵扑", Desc = "四蹄生风猛扑 2~3 格重压敌阵致失衡。",
	Geo = "leap_slam_3", AP = 5, Qi = 18, CD = 2, Field = "",
	Hit = 14, Dmg = 1.20, Arm = 1.25, Pen = 0.10,
	BurnArm = 18, DrainQi = 8, DrainHP = 0, Status = "offbalance",
	Vfx = "wx_vfx_17", Icon = "skills/wx_fist_xiongzhao.png"
};

::Wuxia.ShanHai.BespokeBossSpecs.boss_qiangliang <- {
	TraitScript = "scripts/skills/special/wx_boss_trait_qiangliang",
	TraitID = "special.wx_boss_trait_qiangliang",
	Skills = ["scripts/skills/actives/wx_boss_qiangliang_mouth_serpent", "scripts/skills/actives/wx_boss_qiangliang_long_elbow_cleave", "scripts/skills/actives/wx_boss_qiangliang_tiger_god_leap"],
	CounterHint = "切勿在 2 格内开弓放镖！先派刀剑好手贴身斩断其【口衔操握赤毒蛇】绝其毒噬！"
};
