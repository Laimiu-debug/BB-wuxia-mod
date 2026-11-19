// Core 5 pills & Marrow Wash probability parameters

::Wuxia.Config.MarrowWash <- {
	BaseChance = {
		[0] = 45, // 0★ -> 1★ (Replace old star or fill open star slot)
		[1] = 30, // 1★ -> 2★
		[2] = 15  // 2★ -> 3★
	},
	MaxPrepBonus            = 20, // Combined cap from Resolve, HP health, Main Neigong Tier, Protect Pill
	ProtectPillChanceBonus  = 5,
	HighStarPermInjuryPct   = 18, // 15~20% permanent internal injury risk on 2★/3★ fail without Protect Pill
	ShockDurationDays       = 5
};

::Wuxia.Config.Pills <- {
	wx_pill_jinchuang = {
		ID          = "wx_pill_jinchuang",
		Name        = "金疮散",
		Description = "外敷内服皆宜的跌打良药，可加快外伤愈合或立即解除一处轻度外伤。",
		Kind        = "heal_external",
		Icon        = "consumables/medicine_01.png",
		Value       = 180
	},
	wx_pill_huxin = {
		ID          = "wx_pill_huxin",
		Name        = "护心丹",
		Description = "温养经脉的灵丹，可化解散功虚弱、内伤与经脉震荡。",
		Kind        = "heal_internal",
		Icon        = "consumables/antidote_01.png",
		Value       = 450
	},
	wx_pill_ningshen = {
		ID          = "wx_pill_ningshen",
		Name        = "凝神丸",
		Description = "凝聚心神的修炼丹药。拖拽至任意未满重武学插槽，可立即灌注 150 点火候。",
		Kind        = "infuse_exp",
		ExpAmount   = 150,
		Icon        = "consumables/happy_powder_01.png",
		Value       = 600
	},
	wx_pill_xisui = {
		ID          = "wx_pill_xisui",
		Name        = "洗髓丹",
		Description = "极稀有的伐毛洗髓奇药，可在「武学修为」页发起一次洗经伐髓（冲星或易筋换星）。存在失败风险。",
		Kind        = "marrow_wash",
		Icon        = "consumables/potion_01.png",
		Value       = 4500
	},
	wx_pill_humai = {
		ID          = "wx_pill_humai",
		Name        = "护脉丹",
		Description = "洗经伐髓前辅服的护脉宝丹：提升 5% 洗髓成功率，并在失败时免除永久暗疾风险。",
		Kind        = "wash_protect",
		Icon        = "consumables/potion_02.png",
		Value       = 1500
	}
};
