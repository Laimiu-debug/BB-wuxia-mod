// Wuxia Congenital & Acquired Trait Configuration
// 1. VanillaTraitMap: Non-destructive Wuxia renaming & atmospheric descriptions for 58 vanilla `trait.*` skills (keeps 100% vanilla IDs & event compatibility).
// 2. MeridianTraits: 10 authentic Wuxia congenital meridian/comprehension traits obeying AGENTS.md anti-inflation caps (pure mechanism & mastery hooks).

::Wuxia.Config.Traits <- {
	VanillaTraitMap = {
		["trait.iron_lungs"]       = ["先天胎息", "此人天生丹田绵长、呼吸吐纳自合周天之数，酣战之中内息源源不绝。"],
		["trait.athletic"]         = ["猿猱健骨", "筋骨舒展如苍猿攀崖，长途跋涉与临阵腾挪皆比常人省却几分内息。"],
		["trait.dexterous"]        = ["十指通灵", "手腕灵巧、指节修长敏锐，出招认穴往往能抢在敌手破绽初露的一瞬。"],
		["trait.sure_footing"]     = ["落地生根", "下盘桩功扎实稳健，哪怕身陷乱刃围攻亦步法不乱、极善闪展拆招。"],
		["trait.quick"]            = ["疾风身架", "体态矫健迅捷，拔刃抢攻快如电光石火，总能占得交手先机。"],
		["trait.swift"]            = ["流星赶月", "身法轻捷似离弦飞矢，电光火石间便能欺身抢拍。"],
		["trait.strong"]           = ["天生神力", "双臂肌肉虬结、力能举鼎，披挂沉重铁甲犹若无物。"],
		["trait.tough"]            = ["筋骨如铁", "皮糙肉厚、经络坚韧，寻常刀剑创口难伤其根本元气。"],
		["trait.huge"]             = ["凛凛巨躯", "身高八尺、虎背熊腰，挥动兵刃势大力沉，唯靶大稍难闪避。"],
		["trait.tiny"]             = ["矮小精悍", "身材短小灵动，最擅钻隙避矢，唯正面劈砍气力略逊三分。"],
		["trait.fearless"]         = ["浑身是胆", "视千军万马与妖邪魔影如草芥，临阵从不知畏惧退缩为何物。"],
		["trait.brave"]            = ["侠肝义胆", "胸怀豪气、临危不乱，纵逢劲敌当前亦敢挺身亮剑。"],
		["trait.determined"]       = ["道心坚毅", "心志稳若磐石，一朝踏入沙场便战意昂扬、百折不回。"],
		["trait.deathwish"]        = ["向死忘生", "看淡生死荣辱的亡命狂客，哪怕血染征袍亦绝不动摇溃散。"],
		["trait.bloodthirsty"]     = ["嗜血煞性", "眼底常带三分凶戾杀气，见血愈兴奋，挥刀断首毫不手软。"],
		["trait.brute"]            = ["凶蛮霸力", "出招专奔天灵面门狠砸猛劈，重击之下往往令敌颅裂甲碎，唯准头略糙。"],
		["trait.drunkard"]         = ["醉里乾坤", "嗜酒如命的江湖酒徒，三分酒意上涌便胆气豪壮、出招愈发凶猛难测，只是常丢三落四。"],
		["trait.eagle_eyes"]       = ["鹰视千步", "双眸锐利如塞北苍鹰，数里之外的风吹草动与林间伏兵皆难逃法眼。"],
		["trait.night_owl"]        = ["夜行如昼", "惯走子夜黑道的江湖夜行客，暗夜交锋双目清明更胜白昼。"],
		["trait.teamplayer"]       = ["同袍守望", "最重江湖义气与同门配合，放箭挥兵时绝不误伤自家弟兄。"],
		["trait.loyal"]            = ["忠肝守义", "一诺千金的忠义汉子，纵使义社暂陷困顿断炊，亦绝不背主求荣。"],
		["trait.spartan"]          = ["苦行清修", "惯于餐风宿露、粗茶淡饭，行军途中极少耗费口粮给养。"],
		["trait.optimist"]         = ["旷达豪迈", "生性洒脱乐观，谈笑间常能稳住自己的一腔豪情。"],
		["trait.bright"]           = ["颖悟敏学", "心思通透、领悟极快，历战之中增长武道历练远较常人神速。"],
		["trait.lucky"]            = ["洪福齐天", "冥冥中似有气运庇佑，刀箭临身总能险之又险地偏开半寸。"],
		["trait.survivor"]         = ["九死命硬", "阎王殿前走过几遭的硬命人，纵然重伤倒地亦十有九次能留得性命。"],
		["trait.weasel"]           = ["泥鳅滑脚", "见势不妙时脚底抹油溜得比谁都快，敌军极难在其脱战时留人。"],
		["trait.paranoid"]         = ["惊弓暗影", "常年行走险恶江湖养成的多疑习气，步步防人暗算，守御严密而先手迟疑。"],
		["trait.superstitious"]    = ["畏鬼信邪", "笃信阴阳鬼神之说，遭遇邪宗妖术与古墓冥物时格外心惊肉跳。"],
		["trait.craven"]           = ["贪生畏战", "胆小惜命，一旦战局吃紧便两股战战、萌生退意。"],
		["trait.dastard"]          = ["鼠胆怯阵", "未战先怯，踏入沙场便心怀惴惴，士气极易动摇。"],
		["trait.fainthearted"]     = ["心虚胆薄", "心志怯弱，难当血肉横飞的大阵硬仗。"],
		["trait.hesitant"]         = ["临阵迟疑", "出手前总要瞻前顾后思量再三，往往错失抢攻良机。"],
		["trait.insecure"]         = ["妄自菲薄", "常觉自身武艺低微，无法像同袍那般保持昂扬战意。"],
		["trait.pessimist"]        = ["郁郁寡欢", "看惯乱世凄凉，心头常萦悲观丧气之念。"],
		["trait.asthmatic"]        = ["肺腑旧喘", "早年风寒或内劲暗伤留下的喘疾，久战之下内息回复略显吃力。"],
		["trait.clumsy"]           = ["手脚粗笨", "招式架子常走样变形，出招准头比常人逊色几分。"],
		["trait.clubfooted"]       = ["跛足沉步", "天生足疾或旧伤未愈，翻山涉水与长距奔袭颇耗内息。"],
		["trait.cocky"]            = ["狂傲轻敌", "自恃武勇目空一切，胆气虽壮却常因轻敌而门户大开。"],
		["trait.disloyal"]         = ["见利忘义", "无利不起早的市侩之徒，一旦断饷缺粮便随时准备卷铺盖走人。"],
		["trait.fat"]              = ["体态臃肿", "贪恋杯中之物与肥甘厚味，气血虽厚实，奈何内息与身法大打折扣。"],
		["trait.fragile"]          = ["体弱气虚", "先天元气不足、身骨单薄，难受重创。"],
		["trait.gluttonous"]       = ["饕餮大肚", "饭量惊人，每顿干粮酒肉皆要吃下常人双份方肯罢休。"],
		["trait.greedy"]           = ["嗜财如命", "眼皮子极浅，开口闭口皆离不开纹银酬劳，索要日饷更苛。"],
		["trait.irrational"]       = ["喜怒无常", "性情乖张古怪，临阵战意忽高忽低难以捉摸。"],
		["trait.night_blind"]      = ["雀目夜盲", "一入昏暗子夜便两眼昏花，夜战视野大受掣肘。"],
		["trait.short_sighted"]    = ["目力昏花", "远处景物模糊难辨，不擅百步穿杨之技。"],
		["trait.bleeder"]          = ["血脉难凝", "一旦被利刃割破皮肉便血流不止，须留神及时止血包扎。"],
		["trait.ailing"]           = ["缠绵病骨", "旧疾缠身，气血调理与中毒抗性皆逊常人一筹。"],
		["trait.dumb"]             = ["鲁钝木讷", "榆木脑袋不开窍，参悟实战历练总比旁人慢上半拍。"],
		["trait.impatient"]        = ["急躁冒进", "按捺不住性子，首轮交锋总是争先恐后抢出阵前。"],
		["trait.hate_undead"]      = ["痛恨尸邪", "曾见亲族惨遭尸傀祸害，面对古墓冥俑与湘西行尸时杀意沸腾、心无惧色。"],
		["trait.hate_greenskins"]  = ["深恨毒魔", "与南疆五毒及邪派炼体药人结有血海深仇，临阵见之必欲除之而后快。"],
		["trait.hate_beasts"]      = ["猎妖悍胆", "久历荒山恶兽搏杀，面对山海凶禽猛兽时毫无惧意、愈战愈勇。"],
		["trait.fear_undead"]      = ["惧怕阴尸", "对死而复行的尸傀机关心存阴影，交锋时定力大减。"],
		["trait.fear_greenskins"]  = ["畏惧药魔", "曾被五毒奇蛊或狂暴药人吓破胆魄，重逢时难掩心怯。"],
		["trait.fear_beasts"]      = ["畏惧凶兽", "听闻山泽巨兽咆哮便手脚发软，不愿与之正面撄锋。"],
		["trait.old"]              = ["岁月催人", "英雄迟暮、气血渐衰，然数十年江湖阅历沉淀出泰山崩于前而不改色的定力。"]
	},

	// 10 Authentic Wuxia Congenital Meridian & Martial Aptitude Traits (Strict AGENTS.md zero-stat-bloat design)
	MeridianTraits = {
		wx_qijing = {
			ID          = "trait.wx_qijing",
			Script      = "scripts/skills/traits/wx_trait_qijing",
			Name        = "奇经通脉",
			Icon        = "ui/perks/wx_emblem_neigong.png",
			Description = "天生任督二脉与奇经八脉半通，乃是可遇不可求的修道良才。",
			Titles      = ["通脉客", "玉髓子"],
			Stats       = { Stamina = 4 },
			WashBonus   = 8,
			MasteryCat  = "neigong",
			MasteryMult = 0.25,
			Bullets     = [
				"「洗经伐髓」冲星与易筋成功率额外 [color=#135214]+8%[/color]",
				"内功心法战后与灌注火候获取 [color=#135214]+25%[/color]",
				"内息上限 [color=#135214]+4[/color]"
			],
			Excluded    = ["trait.wx_zaolie", "trait.asthmatic"]
		},
		wx_wuxing = {
			ID          = "trait.wx_wuxing",
			Script      = "scripts/skills/traits/wx_trait_wuxing",
			Name        = "武学顿悟",
			Icon        = "ui/perks/wx_emblem_tactics.png",
			Description = "灵台澄澈、举一反三，旁人苦练数载的招式关窍，此人一经实证便豁然贯通。",
			Titles      = ["武痴", "明心客"],
			Stats       = {},
			AllMastery  = 0.20,
			Bullets     = [
				"全类别已装武学战后与丹药/残页火候获取 [color=#135214]+20%[/color]"
			],
			Excluded    = ["trait.dumb"]
		},
		wx_jiangu = {
			ID          = "trait.wx_jiangu",
			Script      = "scripts/skills/traits/wx_trait_jiangu",
			Name        = "天生剑骨",
			Icon        = "ui/perks/wx_emblem_sword.png",
			Description = "指腕锋锐清冽，一握三尺青锋或分水短匕便人剑相合、剑气自生。",
			Titles      = ["剑胚", "清霜客"],
			Stats       = { Initiative = 3 },
			WeaponFams  = ["Sword", "Dagger"],
			WpnQiSave   = 0.10,
			MasteryMult = 0.30,
			Bullets     = [
				"装备剑、短匕类兵刃时，主动外功招式内息消耗 [color=#135214]-10%[/color]",
				"剑法与短匕外功火候获取 [color=#135214]+30%[/color]，身法 [color=#135214]+3[/color]"
			],
			Excluded    = ["trait.clumsy"]
		},
		wx_daochi = {
			ID          = "trait.wx_daochi",
			Script      = "scripts/skills/traits/wx_trait_daochi",
			Name        = "霸刀狂痴",
			Icon        = "ui/perks/wx_emblem_saber.png",
			Description = "生就一副大开大合的刚猛筋骨，最喜挥动沉重战刀、巨斧与重锤破甲裂阵。",
			Titles      = ["刀痴", "裂甲客"],
			Stats       = { Bravery = 3 },
			WeaponFams  = ["Saber", "Cleaver", "Axe", "Hammer"],
			WpnArmorDmg = 0.06,
			MasteryMult = 0.30,
			Bullets     = [
				"装备刀、大斧、重锤类兵刃时，攻击破甲效能 [color=#135214]+6%[/color]",
				"刀/斧/锤外功火候获取 [color=#135214]+30%[/color]，定力 [color=#135214]+3[/color]"
			],
			Excluded    = ["trait.fainthearted", "trait.tiny"]
		},
		wx_quanyi = {
			ID          = "trait.wx_quanyi",
			Script      = "scripts/skills/traits/wx_trait_quanyi",
			Name        = "百骸拳意",
			Icon        = "ui/perks/wx_emblem_fist.png",
			Description = "周身大筋紧绷如弓弦，寸劲发于腰胯脊背，修习拳掌与长杆奇兵事半功倍。",
			Titles      = ["铁桥手", "鸣筋客"],
			Stats       = { Stamina = 3 },
			WeaponFams  = ["Fist", "Spear", "Polearm", "Staff", "Flail"],
			AntiIntInj  = true,
			MasteryMult = 0.30,
			Bullets     = [
				"拳掌、枪棍长兵与软鞭外功火候获取 [color=#135214]+30%[/color]",
				"周身护脉大筋稳固，受刚猛重击震出「内伤」的概率减半，内息上限 [color=#135214]+3[/color]"
			],
			Excluded    = ["trait.fragile"]
		},
		wx_baidu = {
			ID          = "trait.wx_baidu",
			Script      = "scripts/skills/traits/wx_trait_baidu",
			Name        = "百毒药体",
			Icon        = "ui/perks/wx_emblem_odd.png",
			Description = "幼时曾误食山泽异草或经药汤浸炼，脏腑对奇毒与霸道丹力皆具异禀耐受。",
			Titles      = ["药人子", "尝百草"],
			Stats       = { Hitpoints = 3 },
			NoDanToxin  = true,
			CleansePct  = 25,
			Bullets     = [
				"单场混服第 3 颗备战灵丹时[color=#135214]免除「丹毒郁结」反噬[/color]",
				"每回合初有 [color=#135214]25%[/color] 概率自行化去体内奇毒，气血上限 [color=#135214]+3[/color]"
			],
			Excluded    = ["trait.ailing"]
		},
		wx_qingling = {
			ID          = "trait.wx_qingling",
			Script      = "scripts/skills/traits/wx_trait_qingling",
			Name        = "仙鹤轻骨",
			Icon        = "ui/perks/wx_emblem_qinggong.png",
			Description = "骨质轻盈中空似云中白鹤，提气纵跃如履平地，唯身板稍显清瘦。",
			Titles      = ["鹤骨客", "踏风子"],
			Stats       = { Initiative = 6, Hitpoints = -4 },
			MasteryCat  = "qinggong",
			MasteryMult = 0.30,
			Bullets     = [
				"轻功身法火候获取 [color=#135214]+30%[/color]，身法 [color=#135214]+6[/color]",
				"身骨清瘦：气血上限 [color=#8f1d1d]-4[/color]"
			],
			Excluded    = ["trait.wx_tonggu", "trait.fat", "trait.clubfooted"]
		},
		wx_tonggu = {
			ID          = "trait.wx_tonggu",
			Script      = "scripts/skills/traits/wx_trait_tonggu",
			Name        = "天生铜骨",
			Icon        = "ui/perks/wx_emblem_henglian.png",
			Description = "骨骼沉重致密异于常人，最宜打熬横练金钟硬功，只是起落略显滞重。",
			Titles      = ["铜骨汉", "石桩客"],
			Stats       = { Hitpoints = 6, Initiative = -5 },
			InjuryMult  = 1.15,
			MasteryCat  = "henglian",
			MasteryMult = 0.30,
			Bullets     = [
				"横练杂学火候获取 [color=#135214]+30%[/color]，气血上限 [color=#135214]+6[/color]、抗外伤阈值 [color=#135214]+15%[/color]",
				"骨骼沉重：身法 [color=#8f1d1d]-5[/color]"
			],
			Excluded    = ["trait.wx_qingling", "trait.fragile"]
		},
		wx_shenmu = {
			ID          = "trait.wx_shenmu",
			Script      = "scripts/skills/traits/wx_trait_shenmu",
			Name        = "穿云神目",
			Icon        = "ui/perks/wx_emblem_ranged.png",
			Description = "瞳仁深邃聚光，隔着漫天风沙亦能看清百步外飞蚊振翅。",
			Titles      = ["神目客", "破云手"],
			Stats       = { RangedSkill = 2 },
			WeaponFams  = ["Bow", "Crossbow", "Throwing", "Firearm"],
			LongAcc     = 3,
			MasteryMult = 0.30,
			Bullets     = [
				"弓弩、暗器与神机火器外功火候获取 [color=#135214]+30%[/color]",
				"射艺 [color=#135214]+2[/color]，距离 ≥4 格远射额外 [color=#135214]+3[/color] 命中"
			],
			Excluded    = ["trait.short_sighted", "trait.night_blind"]
		},
		wx_zaolie = {
			ID          = "trait.wx_zaolie",
			Script      = "scripts/skills/traits/wx_trait_zaolie",
			Name        = "经脉燥烈",
			Icon        = "ui/perks/wx_perk_neigong_yang.png",
			Description = "体内纯阳血气奔涌如沸汤，搏杀酣畅淋漓，却最忌阴阳邪气混杂逆行。",
			Titles      = ["烈脉客", "赤血汉"],
			Stats       = { Bravery = 5 },
			HitQiBonus  = 1,
			ConflictAdd = 8,
			Bullets     = [
				"定力 [color=#135214]+5[/color]，近战命中额外回复 [color=#135214]1[/color] 点内息（每回合限 2 次）",
				"经脉刚烈：若强行混修阴阳/正邪相克内功，内息逆冲概率 [color=#8f1d1d]+8%[/color]"
			],
			Excluded    = ["trait.wx_qijing", "trait.craven"]
		}
	}
};
