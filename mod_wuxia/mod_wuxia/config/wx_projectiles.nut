// Declarative Registry of 16 Standalone Wuxia Flying Projectiles (`wx_projectiles_0.brush`)
// Covers 飞蝗石、柳叶飞刀、孔雀翎、神机火铳弹丸、袖箭飞行轨迹 + full Jianghu bow/crossbow/poison/bomb arsenal.

::Wuxia.Config.ProjectileOrder <- [
	"feihuangshi",
	"liuyefeidao",
	"kongqueling",
	"huochongdan",
	"xiujian",
	"shenjishi",
	"diaolingjian",
	"liuxingjian",
	"chuijian",
	"sangmending",
	"lihuazhen",
	"xuanfengbiao",
	"jinqianbiao",
	"touzhisuo",
	"feishisuo",
	"pilileihuo"
];

::Wuxia.Config.Projectiles <- {
	feihuangshi = {
		ID = "feihuangshi",
		Key = "WX_Feihuangshi",
		Brush = "wx_proj_feihuangshi",
		Name = "飞蝗铁胆石",
		IsRotated = true,
		TimeScale = 1.05,
		DecalBase = "Stone"
	},
	liuyefeidao = {
		ID = "liuyefeidao",
		Key = "WX_Liuyefeidao",
		Brush = "wx_proj_liuyefeidao",
		Name = "寒星柳叶飞刀",
		IsRotated = true,
		TimeScale = 1.25,
		DecalBase = "Javelin"
	},
	kongqueling = {
		ID = "kongqueling",
		Key = "WX_Kongqueling",
		Brush = "wx_proj_kongqueling",
		Name = "唐门孔雀翎",
		IsRotated = true,
		TimeScale = 1.35,
		DecalBase = "Arrow"
	},
	huochongdan = {
		ID = "huochongdan",
		Key = "WX_Huochongdan",
		Brush = "wx_proj_huochongdan",
		Name = "神机火铳赤焰弹丸",
		IsRotated = true,
		TimeScale = 1.65,
		DecalBase = "None"
	},
	xiujian = {
		ID = "xiujian",
		Key = "WX_Xiujian",
		Brush = "wx_proj_xiujian",
		Name = "机簧玄铁袖箭",
		IsRotated = true,
		TimeScale = 1.32,
		DecalBase = "Arrow"
	},
	shenjishi = {
		ID = "shenjishi",
		Key = "WX_Shenjishi",
		Brush = "wx_proj_shenjishi",
		Name = "神臂破甲重弩矢",
		IsRotated = true,
		TimeScale = 1.25,
		DecalBase = "Arrow"
	},
	diaolingjian = {
		ID = "diaolingjian",
		Key = "WX_Diaolingjian",
		Brush = "wx_proj_diaolingjian",
		Name = "边关雕翎铁胎箭",
		IsRotated = true,
		TimeScale = 1.12,
		DecalBase = "Arrow"
	},
	liuxingjian = {
		ID = "liuxingjian",
		Key = "WX_Liuxingjian",
		Brush = "wx_proj_liuxingjian",
		Name = "震天金翎追月箭",
		IsRotated = true,
		TimeScale = 1.38,
		DecalBase = "Arrow"
	},
	chuijian = {
		ID = "chuijian",
		Key = "WX_Chuijian",
		Brush = "wx_proj_chuijian",
		Name = "五毒乌竹吹箭毒针",
		IsRotated = true,
		TimeScale = 1.28,
		DecalBase = "Arrow"
	},
	sangmending = {
		ID = "sangmending",
		Key = "WX_Sangmending",
		Brush = "wx_proj_sangmending",
		Name = "五毒倒刺丧门钉",
		IsRotated = true,
		TimeScale = 1.22,
		DecalBase = "Arrow"
	},
	lihuazhen = {
		ID = "lihuazhen",
		Key = "WX_Lihuazhen",
		Brush = "wx_proj_lihuazhen",
		Name = "暴雨梨花千枚银针",
		IsRotated = true,
		TimeScale = 1.38,
		DecalBase = "Arrow"
	},
	xuanfengbiao = {
		ID = "xuanfengbiao",
		Key = "WX_Xuanfengbiao",
		Brush = "wx_proj_xuanfengbiao",
		Name = "绿林旋风十字铁镖",
		IsRotated = false,
		TimeScale = 1.12,
		DecalBase = "Axe"
	},
	jinqianbiao = {
		ID = "jinqianbiao",
		Key = "WX_Jinqianbiao",
		Brush = "wx_proj_jinqianbiao",
		Name = "走镖甩手金钱梭镖",
		IsRotated = true,
		TimeScale = 1.22,
		DecalBase = "Arrow"
	},
	touzhisuo = {
		ID = "touzhisuo",
		Key = "WX_Touzhisuo",
		Brush = "wx_proj_touzhisuo",
		Name = "破盾透甲投掷短梭",
		IsRotated = true,
		TimeScale = 1.08,
		DecalBase = "Javelin"
	},
	feishisuo = {
		ID = "feishisuo",
		Key = "WX_Feishisuo",
		Brush = "wx_proj_feishisuo",
		Name = "南疆绊马缠丝飞石索",
		IsRotated = false,
		TimeScale = 1.02,
		DecalBase = "None"
	},
	pilileihuo = {
		ID = "pilileihuo",
		Key = "WX_Pilileihuo",
		Brush = "wx_proj_pilileihuo",
		Name = "蜀中霹雳雷火弹",
		IsRotated = false,
		TimeScale = 0.96,
		DecalBase = "None"
	}
};

// Weapon ID -> Default Wuxia Projectile ID
::Wuxia.Config.WeaponProjectileMap <- {
	// 飞蝗石 (Slings)
	["weapon.sling"]                  = "feihuangshi",
	["weapon.nomad_sling"]            = "feihuangshi",
	["weapon.staff_sling"]            = "feihuangshi",

	// 柳叶飞刀 / 旋风铁镖 / 投掷短梭 / 飞石索 (Thrown Hidden Weapons)
	["weapon.javelin"]                = "liuyefeidao",
	["weapon.heavy_javelin"]          = "liuyefeidao",
	["weapon.named_javelin"]          = "liuyefeidao",
	["weapon.wx_relic_feidaonang"]    = "liuyefeidao",
	["weapon.orc_javelin"]            = "touzhisuo",
	["weapon.throwing_spear"]         = "touzhisuo",
	["weapon.throwing_axe"]           = "xuanfengbiao",
	["weapon.heavy_throwing_axe"]     = "xuanfengbiao",
	["weapon.named_throwing_axe"]     = "xuanfengbiao",
	["weapon.bola"]                   = "feishisuo",

	// 袖箭 / 诸葛连弩 / 神臂重弩 / 毒蒺藜弩 (Sleeve Darts & Crossbows)
	["weapon.light_crossbow"]         = "xiujian",
	["weapon.heavy_crossbow"]         = "xiujian",
	["weapon.crossbow"]               = "shenjishi",
	["weapon.named_crossbow"]         = "shenjishi",
	["weapon.wx_relic_shenbinu"]      = "shenjishi",
	["weapon.spiked_impaler"]         = "sangmending",

	// 雕翎铁胎箭 / 震天金翎箭 / 五毒吹箭毒针 (Bows & Blowguns)
	["weapon.wonky_bow"]              = "diaolingjian",
	["weapon.short_bow"]              = "diaolingjian",
	["weapon.hunting_bow"]            = "diaolingjian",
	["weapon.composite_bow"]          = "diaolingjian",
	["weapon.war_bow"]                = "diaolingjian",
	["weapon.masterwork_bow"]         = "liuxingjian",
	["weapon.named_warbow"]           = "liuxingjian",
	["weapon.wx_relic_zhentiangong"]  = "liuxingjian",
	["weapon.goblin_bow"]             = "chuijian",
	["weapon.goblin_heavy_bow"]       = "chuijian",
	["weapon.named_goblin_heavy_bow"] = "chuijian",

	// 神机火铳弹丸 (Ming Shenji Firearms)
	["weapon.handgonne"]              = "huochongdan",
	["weapon.named_handgonne"]        = "huochongdan",
	["weapon.wx_relic_xunleichong"]   = "huochongdan"
};

// Active Skill ID -> Bespoke Wuxia Projectile ID
::Wuxia.Config.SkillProjectileMap <- {
	["actives.wx_throwing_rain"]      = "lihuazhen",
	["actives.wx_throw_fan"]          = "liuyefeidao",
	["actives.wx_throw_duzhen"]       = "sangmending",
	["actives.wx_throw_pilidan"]      = "pilileihuo",
	["actives.wx_smoke_cast"]         = "pilileihuo",
	["actives.wx_bow_snipe"]          = "liuxingjian",
	["actives.wx_bow_liuxing"]        = "liuxingjian",
	["actives.wx_crossbow_shenji"]    = "shenjishi",
	["actives.sling_stone"]           = "feihuangshi",
	["actives.throw_javelin"]         = "liuyefeidao",
	["actives.throw_axe"]             = "xuanfengbiao",
	["actives.throw_spear"]           = "touzhisuo",
	["actives.throw_balls"]           = "feishisuo",
	["actives.fire_handgonne"]        = "huochongdan",
	["actives.throw_fire_bomb"]       = "pilileihuo",
	["actives.throw_daze_bomb"]       = "pilileihuo",
	["actives.throw_smoke_bomb"]      = "pilileihuo"
};
