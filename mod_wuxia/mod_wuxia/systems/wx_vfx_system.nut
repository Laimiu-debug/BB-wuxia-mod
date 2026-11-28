// Wuxia Tactical Martial Arts Qi-Aura & 72-Skill Zero-Duplicate Action VFX Engine v3.0
// Compiles & drives `wx_effects_0.brush` + `wx_effects_1.brush`:
//   - All 32 Hand-Painted Wuxia Qi-Auras (`wx_vfx_01..32`: 刀剑气芒 / 拳掌内劲 / 内功护罡 / 奇门毒火)
//   - All 72 Strictly 1-to-1 Unique 4-Frame Martial Action Sequences (`wx_anim_01..72_f1..f4` = 288 frames!)
//   - All 16 Hand-Painted Dharma/Array Signature Elements (`wx_fx_*`)
//   - Full tactical integration across:
//       (1) All 72 Wuxia Active Moves + Multi-Tile AoE Sweeps
//       (2) Basic Weapon Attacks by Martial Practitioners & Relic Weapon Wielders
//       (3) Neigong True Qi Shield, Frost Ring (`wx_vfx_21`), Iron-Shirt Reflection, Wudu Venom, Counter Stances
//       (4) Xiangxi Necromancers (`wx_vfx_30`) & All 64 Shan Hai Jing Mythical Apex Bosses!

::Wuxia.VFX <- {
	Config = {
		ShowSkillVfx      = true,
		EnableActorMotion = true,
		ShowSkillCutIn    = false,
		EnableWuxiaSfx    = true
	},
	EnableWuxiaSfx = true,
	isSfxEnabled = function()
	{
		if ("EnableWuxiaSfx" in ::Wuxia.VFX && !::Wuxia.VFX.EnableWuxiaSfx)
			return false;
		return !("Config" in ::Wuxia.VFX) || !("EnableWuxiaSfx" in ::Wuxia.VFX.Config) || ::Wuxia.VFX.Config.EnableWuxiaSfx;
	},
	resolveMoveSoundBank = function( _skill )
	{
		if (_skill == null) return null;
		local sid = (::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null) ? _skill.getID() : "";
		local reqs = (::Wuxia.hasMember(_skill, "m") && _skill.m != null && ::Wuxia.hasMember(_skill.m, "RequiredWeaponTypes") && _skill.m.RequiredWeaponTypes != null)
			? _skill.m.RequiredWeaponTypes : [];

		if (sid.find("acupoint") != null || sid.find("yiyang") != null || sid.find("canhe") != null || sid.find("nianhua") != null || sid.find("fuxue") != null)
		{
			return {
				use = ["sounds/wx_combat/wx_finger_acupoint_01.wav", "sounds/wx_combat/wx_finger_acupoint_02.wav"],
				hit = ["sounds/wx_combat/wx_finger_acupoint_02.wav", "sounds/wx_combat/wx_palm_inch_01.wav"]
			};
		}
		if (sid.find("wx_gun_") == 8 || sid.find("pilidan") != null || reqs.find("Firearm") != null)
		{
			return {
				use = ["sounds/wx_combat/wx_firelance_boom_01.wav"],
				hit = ["sounds/wx_combat/wx_thunder_quake_01.wav"]
			};
		}
		if (reqs.find("Fist") != null)
		{
			if (sid.find("xianglong") != null || sid.find("rulai") != null || sid.find("jingang") != null || sid.find("nuchao") != null || sid.find("hama") != null)
			{
				return {
					use = ["sounds/wx_combat/wx_palm_dragon_01.wav", "sounds/wx_combat/wx_palm_dragon_02.wav"],
					hit = ["sounds/wx_combat/wx_palm_inch_01.wav", "sounds/wx_combat/wx_thunder_quake_01.wav"]
				};
			}
			return {
				use = ["sounds/wx_combat/wx_palm_inch_01.wav", "sounds/wx_combat/wx_palm_dragon_01.wav"],
				hit = ["sounds/wx_combat/wx_palm_inch_01.wav"]
			};
		}
		if (reqs.find("Sword") != null || reqs.find("Dagger") != null)
		{
			return {
				use = ["sounds/wx_combat/wx_sword_qi_01.wav", "sounds/wx_combat/wx_sword_qi_02.wav"],
				hit = ["sounds/wx_combat/wx_sword_hit_01.wav"]
			};
		}
		if (reqs.find("Saber") != null || reqs.find("Cleaver") != null)
		{
			return {
				use = ["sounds/wx_combat/wx_saber_gale_01.wav", "sounds/wx_combat/wx_saber_gale_02.wav"],
				hit = ["sounds/wx_combat/wx_sword_hit_01.wav"]
			};
		}
		if (reqs.find("Flail") != null || sid.find("whip") != null)
		{
			return {
				use = ["sounds/wx_combat/wx_whip_crack_01.wav"],
				hit = ["sounds/wx_combat/wx_whip_crack_01.wav", "sounds/wx_combat/wx_sword_hit_01.wav"]
			};
		}
		if (reqs.find("Hammer") != null || reqs.find("Axe") != null)
		{
			return {
				use = ["sounds/wx_combat/wx_saber_gale_02.wav", "sounds/wx_combat/wx_thunder_quake_01.wav"],
				hit = ["sounds/wx_combat/wx_thunder_quake_01.wav"]
			};
		}
		if (reqs.find("Spear") != null || reqs.find("Polearm") != null || reqs.find("Staff") != null)
		{
			return {
				use = ["sounds/wx_combat/wx_spear_phoenix_01.wav"],
				hit = ["sounds/wx_combat/wx_sword_hit_01.wav", "sounds/wx_combat/wx_palm_inch_01.wav"]
			};
		}
		if (reqs.find("Throwing") != null || reqs.find("Bow") != null || reqs.find("Crossbow") != null)
		{
			return {
				use = ["sounds/wx_combat/wx_throwing_rain_01.wav"],
				hit = ["sounds/wx_combat/wx_sword_hit_01.wav"]
			};
		}
		return null;
	},
	Cache                  = {},
	FlipbookCache          = {},
	ColorCache             = {},
	VecZero                = null,
	LoggedErrors           = {},
	BattleResourcesQueued  = false,
	BattleTextures         = {},
	LastQinggongCast       = {},

	TacticalVfxTextures = [
		"gfx/wx_kinetic_0.png",
		"gfx/wx_kinetic_1.png",
		"gfx/wx_kinetic_2.png",
		"gfx/wx_kinetic_3.png",
		"gfx/wx_kinetic_4.png",
		"gfx/wx_kinetic_5.png",
		"gfx/wx_kinetic_6.png",
		"gfx/wx_kinetic_7.png",
		"gfx/wx_kinetic_8.png",
		"gfx/wx_effects_0.png",
		"gfx/wx_effects_1.png",
		"gfx/wx_effects_2.png",
		"gfx/wx_effects_3.png",
		"gfx/wx_effects_4.png",
		"gfx/wx_effects_5.png",
		"gfx/wx_projectiles_0.png",
		"gfx/wx_corpses_0.png",
		"gfx/wx_corpses_1.png"
	],
	TacticalBaseTextures = [
		"gfx/wx_effects_4.png",
		"gfx/wx_projectiles_0.png",
		"gfx/wx_corpses_1.png"
	],
	// One brush per combat texture lets the renderer finish the upload during deployment.
	BattleTextureBrushes = {
		["gfx/wx_kinetic_0.png"] = "wx_kin_sword_slash_00",
		["gfx/wx_kinetic_1.png"] = "wx_kin_blood_arc_00",
		["gfx/wx_kinetic_2.png"] = "wx_kin_buddha_palm_00",
		["gfx/wx_kinetic_3.png"] = "wx_kin_taiji_seal_00",
		["gfx/wx_kinetic_4.png"] = "wx_kin_lotus_poke_00",
		["gfx/wx_kinetic_5.png"] = "wx_kin_peacock_fan_00",
		["gfx/wx_kinetic_6.png"] = "wx_kin_snow_step_00",
		["gfx/wx_kinetic_7.png"] = "wx_kin_sword_slash_L_01",
		["gfx/wx_kinetic_8.png"] = "wx_kin_sword_slash_L_00",
		["gfx/wx_effects_0.png"] = "wx_anim_01_f1",
		["gfx/wx_effects_1.png"] = "wx_anim_133_f1",
		["gfx/wx_effects_2.png"] = "wx_anim_19_f1",
		["gfx/wx_effects_3.png"] = "wx_anim_64_f1",
		["gfx/wx_effects_4.png"] = "wx_ov_wx_dagger_yingci",
		["gfx/wx_effects_5.png"] = "wx_vfx_30",
		["gfx/wx_projectiles_0.png"] = "wx_proj_chuijian"
	},

	SeqToKineticSheet = {
		wx_kin_celestial_beam = ["gfx/wx_kinetic_0.png", "gfx/wx_kinetic_7.png", "gfx/wx_kinetic_8.png"],
		wx_kin_dragon_surge   = ["gfx/wx_kinetic_0.png", "gfx/wx_kinetic_7.png", "gfx/wx_kinetic_8.png"],
		wx_kin_flame_cleave   = ["gfx/wx_kinetic_0.png", "gfx/wx_kinetic_7.png", "gfx/wx_kinetic_8.png"],
		wx_kin_flame_pillar   = ["gfx/wx_kinetic_0.png"],
		wx_kin_sword_slash    = ["gfx/wx_kinetic_0.png", "gfx/wx_kinetic_7.png", "gfx/wx_kinetic_8.png"],
		wx_kin_thunder_bolt   = ["gfx/wx_kinetic_0.png"],
		wx_kin_blood_arc      = ["gfx/wx_kinetic_1.png", "gfx/wx_kinetic_8.png"],
		wx_kin_claw_rend      = ["gfx/wx_kinetic_1.png", "gfx/wx_kinetic_7.png", "gfx/wx_kinetic_8.png"],
		wx_kin_shadow_cross   = ["gfx/wx_kinetic_1.png", "gfx/wx_kinetic_7.png", "gfx/wx_kinetic_8.png"],
		wx_kin_spear_drill    = ["gfx/wx_kinetic_1.png", "gfx/wx_kinetic_8.png"],
		wx_kin_whip_lash      = ["gfx/wx_kinetic_1.png", "gfx/wx_kinetic_7.png", "gfx/wx_kinetic_8.png"],
		wx_kin_whirl_cyclone  = ["gfx/wx_kinetic_1.png", "gfx/wx_kinetic_8.png"],
		wx_kin_arrow_barrage  = ["gfx/wx_kinetic_2.png", "gfx/wx_kinetic_8.png"],
		wx_kin_buddha_palm    = ["gfx/wx_kinetic_2.png"],
		wx_kin_earth_shatter  = ["gfx/wx_kinetic_2.png"],
		wx_kin_frost_burst    = ["gfx/wx_kinetic_2.png"],
		wx_kin_sonic_wave     = ["gfx/wx_kinetic_2.png"],
		wx_kin_venom_mire     = ["gfx/wx_kinetic_2.png"],
		wx_kin_golden_dome    = ["gfx/wx_kinetic_3.png"],
		wx_kin_qinggong_gust  = ["gfx/wx_kinetic_3.png", "gfx/wx_kinetic_8.png"],
		wx_kin_soul_vortex    = ["gfx/wx_kinetic_3.png", "gfx/wx_kinetic_7.png"],
		wx_kin_taiji_seal     = ["gfx/wx_kinetic_3.png"],
		wx_kin_bamboo_bind    = ["gfx/wx_kinetic_4.png", "gfx/wx_kinetic_7.png", "gfx/wx_kinetic_8.png"],
		wx_kin_fist_flurry    = ["gfx/wx_kinetic_4.png", "gfx/wx_kinetic_7.png", "gfx/wx_kinetic_8.png"],
		wx_kin_flying_knives  = ["gfx/wx_kinetic_4.png", "gfx/wx_kinetic_8.png"],
		wx_kin_giant_axe      = ["gfx/wx_kinetic_4.png", "gfx/wx_kinetic_7.png", "gfx/wx_kinetic_8.png"],
		wx_kin_lotus_poke     = ["gfx/wx_kinetic_4.png"],
		wx_kin_phoenix_spear  = ["gfx/wx_kinetic_4.png", "gfx/wx_kinetic_7.png", "gfx/wx_kinetic_8.png"],
		wx_kin_cannon_blast   = ["gfx/wx_kinetic_5.png"],
		wx_kin_gold_needles   = ["gfx/wx_kinetic_5.png"],
		wx_kin_peacock_fan    = ["gfx/wx_kinetic_5.png", "gfx/wx_kinetic_7.png", "gfx/wx_kinetic_8.png"],
		wx_kin_tidal_wave     = ["gfx/wx_kinetic_5.png", "gfx/wx_kinetic_7.png"],
		wx_kin_war_banner     = ["gfx/wx_kinetic_5.png"],
		wx_kin_xuanwu_aegis   = ["gfx/wx_kinetic_5.png"],
		wx_kin_moon_crescent  = ["gfx/wx_kinetic_6.png", "gfx/wx_kinetic_8.png"],
		wx_kin_prism_burst    = ["gfx/wx_kinetic_6.png"],
		wx_kin_smoke_cloud    = ["gfx/wx_kinetic_6.png"],
		wx_kin_snow_step      = ["gfx/wx_kinetic_6.png", "gfx/wx_kinetic_7.png", "gfx/wx_kinetic_8.png"],
		wx_kin_sword_rain     = ["gfx/wx_kinetic_6.png", "gfx/wx_kinetic_8.png"],
		wx_kin_warp_seal      = ["gfx/wx_kinetic_6.png"]
	},

	MotionBodyLayers = [
		"body", "armor", "surcoat", "tattoo_body", "armor_upgrade_back",
		"armor_upgrade_front", "injury_body", "body_hurt", "body_blood", "dirt",
		"quiver", "legs_back", "legs_front", "tail", "wings", "charm_body", "tentacle"
	],
	MotionHeadLayers = [
		"head", "head_frenzy", "head_hurt", "closed_eyes", "eye_rings",
		"tattoo_head", "injury", "permanent_injury_1", "permanent_injury_2",
		"permanent_injury_3", "permanent_injury_4",
		"beard", "beard_top", "hair", "helmet", "helmet_damage",
		"helmet_bottom", "helmet_top", "helmet_vanity", "helmet_lower"
	],
	MotionWeaponLayers = [
		"arms_icon", "shaft"
	],
	MotionShieldLayers = [
		"shield_icon"
	],

	// Legacy & expanded sequence labels (`wx_anim_01..72`)
	AnimLabels = {
		wx_anim_01 = "清风快剑·四帧连斩", wx_anim_02 = "天外飞剑·四帧化虹",
		wx_anim_03 = "燃木霸刀·四帧烈劈", wx_anim_04 = "修罗血海·四帧狂斩",
		wx_anim_05 = "亢龙有悔·四帧真龙", wx_anim_06 = "玄冥寒毒·四帧冰晶",
		wx_anim_07 = "一阳贯日·四帧指虹", wx_anim_08 = "九阴白骨·四帧鬼爪",
		wx_anim_09 = "寒星盘龙·四帧螺旋", wx_anim_10 = "裂地崩山·四帧碎岩",
		wx_anim_11 = "横扫千军·四帧龙卷", wx_anim_12 = "流星追月·四帧贯箭",
		wx_anim_13 = "暴雨梨花·四帧千针", wx_anim_14 = "霹雳雷火·四帧轰天",
		wx_anim_15 = "凌波微步·四帧残影", wx_anim_16 = "少林金钟·四帧护罡",
		wx_anim_17 = "紫电三仙·四帧幻剑", wx_anim_18 = "两仪太极·四帧化剑",
		wx_anim_19 = "玄铁无锋·四帧崩山", wx_anim_20 = "冰火两仪·四帧合璧",
		wx_anim_21 = "大日如来·四帧佛掌", wx_anim_22 = "崆峒七伤·四帧五劲",
		wx_anim_23 = "拈花金莲·四帧封穴", wx_anim_24 = "北冥黑渊·四帧噬气",
		wx_anim_25 = "百鸟朝凤·四帧凰枪", wx_anim_26 = "方天画戟·四帧双月",
		wx_anim_27 = "打狗缠竹·四帧盘根", wx_anim_28 = "钩镰破骑·四帧锁拽",
		wx_anim_29 = "雷霆碎岳·四帧落雷", wx_anim_30 = "盘古开天·四帧巨钺",
		wx_anim_31 = "不动玄武·四帧铁壁", wx_anim_32 = "灵蛇锁喉·四帧毒鞭",
		wx_anim_33 = "幽冥断脉·四帧鬼刺", wx_anim_34 = "落日连珠·四帧流星",
		wx_anim_35 = "金刚狮吼·四帧雷音", wx_anim_36 = "聚义号令·四帧帅旗"
	},

	// 72 / 72 Strictly Unique Per-Skill Choreography Registry:
	// `[Label, UniqueAnimID (wx_anim_01..72), Mode, QiAuraBrush (wx_vfx_01..32), SigFxBrush (wx_fx_*), Volleys, Shake]`
	SkillChoreo = {
		// 1. Sword (11)
		wx_sword_combo     = ["清风三叠·连环疾斩", "wx_anim_01", "combo3",       "wx_vfx_01", "wx_fx_sword_phantom", 2, 4],
		wx_acupoint_strike = ["拂柳认穴·七星封脉", "wx_anim_37", "acupoint",     "wx_vfx_12", "wx_fx_lotus_seal",    1, 3],
		wx_sword_counter   = ["回锋守月·借剑反撩", "wx_anim_38", "counter",      "wx_vfx_01", "wx_fx_bagua",         0, 2],
		wx_sword_pierce    = ["穿云破甲·螺旋贯胸", "wx_anim_09", "drill_lunge",  "wx_vfx_03", "wx_fx_sonic_ring",    1, 6],
		wx_sword_duoming   = ["夺命三仙·幻影合击", "wx_anim_17", "clone3",       "wx_vfx_04", "wx_fx_sword_phantom", 3, 5],
		wx_sword_cuixin    = ["松风摧心·青旋透脏", "wx_anim_39", "spiral_stab",  "wx_vfx_01", "wx_fx_lotus_seal",    1, 5],
		wx_sword_dugu      = ["独孤破刃·九宫荡剑", "wx_anim_40", "disarm_arc",   "wx_vfx_07", "wx_fx_sword_phantom", 1, 5],
		wx_sword_taiji     = ["两仪化劲·阴阳鱼阵", "wx_anim_18", "taiji_field",  "wx_vfx_15", "wx_fx_bagua",         1, 5],
		wx_sword_zhongjian = ["玄铁无锋·大巧崩山", "wx_anim_19", "gravity_cut",  "wx_vfx_05", "wx_fx_earth_fissure", 0, 8],
		wx_sword_feixian   = ["天河落星·七曜剑雨", "wx_anim_41", "star_rain",    "wx_vfx_08", "wx_fx_sword_phantom", 4, 6],
		wx_sword_tianwai   = ["天外飞仙·御剑化虹", "wx_anim_02", "flying_虹",    "wx_vfx_07", "wx_fx_sword_phantom", 2, 7],

		// 2. Saber (9)
		wx_poise_charge    = ["沉刀按锷·虎踞蓄意", "wx_anim_42", "poise_draw",   "wx_vfx_24", "wx_fx_sonic_ring",    0, 3],
		wx_saber_cleave    = ["劈空裂风·半月重斩", "wx_anim_43", "crescent",     "wx_vfx_02", "wx_fx_sonic_ring",    0, 5],
		wx_saber_duanyue   = ["断岳腾空·翻身碎岩", "wx_anim_44", "leap_cleave",  "wx_vfx_05", "wx_fx_earth_fissure", 0, 7],
		wx_saber_sweep     = ["八方狂澜·沧溟旋斩", "wx_anim_45", "tidal_sweep",  "wx_vfx_21", "wx_fx_sonic_ring",    0, 6],
		wx_saber_kuangfeng = ["狂风骤雨·六合乱刃", "wx_anim_46", "omnislash6",   "wx_vfx_26", "wx_fx_claw_slash",    3, 5],
		wx_saber_fanzhen   = ["两仪刀剑·冰火十字", "wx_anim_20", "twin_cross",   "wx_vfx_21", "wx_fx_ice_spikes",    1, 6],
		wx_saber_modao     = ["唐军陌刀·碎骑挑斩", "wx_anim_47", "modao_upcut",  "wx_vfx_05", "wx_fx_earth_fissure", 1, 7],
		wx_saber_ranmu     = ["燃木烈阳·焚天火柱", "wx_anim_03", "fire_pillar",  "wx_vfx_02", "wx_fx_earth_fissure", 1, 7],
		wx_saber_xuehai    = ["修罗血海·噬魂归元", "wx_anim_04", "blood_siphon", "wx_vfx_06", "wx_fx_blood_orb",     2, 6],
		wx_saber_huoyandao = ["晋阳炎罡·劈空火刃", "wx_anim_73", "taiyuan_flame","wx_vfx_02", "wx_fx_earth_fissure", 2, 7],

		// 3. Fist / Palm / Finger / Claw (12)
		wx_fist_jab        = ["少林冲拳·连珠破风", "wx_anim_48", "rapid_jab",    "wx_vfx_09", "wx_fx_sonic_ring",    0, 4],
		wx_fist_shock      = ["贴山寸劲·隔甲透背", "wx_anim_49", "inch_pulse",   "wx_vfx_11", "wx_fx_sonic_ring",    1, 6],
		wx_fist_acupoint   = ["拈花一笑·金莲锁穴", "wx_anim_23", "lotus_poke",   "wx_vfx_16", "wx_fx_lotus_seal",    1, 3],
		wx_fist_disarm     = ["空手入刃·盘龙夺兵", "wx_anim_50", "disarm_grab",  "wx_vfx_15", "wx_fx_sword_phantom", 0, 5],
		wx_fist_grapple    = ["擒龙探爪·虚空摄敌", "wx_anim_51", "vacuum_pull",  "wx_vfx_09", "wx_fx_dragon_head",   2, 6],
		wx_fist_jingang    = ["大日如来·金刚巨掌", "wx_anim_21", "buddha_palm",  "wx_vfx_09", "wx_fx_buddha_palm",   1, 7],
		wx_fist_taiji      = ["揽雀云手·太极借力", "wx_anim_52", "taiji_orb",    "wx_vfx_15", "wx_fx_bagua",         1, 5],
		wx_fist_qishang    = ["崆峒七伤·五行乱劲", "wx_anim_22", "prism5_hit",   "wx_vfx_11", "wx_fx_blood_orb",     2, 7],
		wx_fist_jiuyin     = ["九阴白骨·鬼爪撕天", "wx_anim_08", "ghost_claw",   "wx_vfx_13", "wx_fx_claw_slash",    0, 6],
		wx_fist_yiyang     = ["大理一阳·金虹贯日", "wx_anim_07", "sun_laser",    "wx_vfx_12", "wx_fx_lotus_seal",    2, 6],
		wx_fist_xuanming   = ["玄冥神掌·寒晶冰狱", "wx_anim_06", "frost_tomb",   "wx_vfx_10", "wx_fx_ice_spikes",    1, 6],
		wx_fist_xianglong  = ["亢龙有悔·真龙盘空", "wx_anim_05", "dragon_coil",  "wx_vfx_09", "wx_fx_dragon_head",   2, 8],

		// 4. Spear / Polearm / Staff (9)
		wx_spear_guard     = ["威远枪阵·拒马铁壁", "wx_anim_53", "spear_wall",   "wx_vfx_03", "wx_fx_sonic_ring",    0, 3],
		wx_spear_thrust2   = ["百鸟朝凤·九影攒刺", "wx_anim_25", "phoenix9",     "wx_vfx_02", "wx_fx_sword_phantom", 3, 5],
		wx_spear_liuhua    = ["梨花暴雨·万点寒星", "wx_anim_54", "petal_storm",  "wx_vfx_03", "wx_fx_gold_needle",   3, 5],
		wx_spear_bawang    = ["霸王挑山·破甲升龙", "wx_anim_55", "dragon_up",    "wx_vfx_05", "wx_fx_dragon_head",   1, 7],
		wx_spear_liangyin  = ["八宝亮寅·白虎穿星", "wx_anim_74", "silver_tiger_spear", "wx_vfx_03", "wx_fx_sonic_ring", 3, 6],
		wx_pole_sweep      = ["横扫千军·烈风龙卷", "wx_anim_11", "cyclone_pole", "wx_vfx_06", "wx_fx_whip_arc",      0, 6],
		wx_pole_goulian    = ["钩镰破甲·锁足倒拽", "wx_anim_28", "hook_pull",    "wx_vfx_31", "wx_fx_whip_arc",      2, 5],
		wx_pole_fangtian   = ["方天画戟·无双月斩", "wx_anim_26", "halberd_x",    "wx_vfx_07", "wx_fx_earth_fissure", 1, 8],
		wx_staff_challenge = ["横杖顿地·金刚怒喝", "wx_anim_56", "taunt_slam",   "wx_vfx_14", "wx_fx_sonic_ring",    0, 5],
		wx_staff_dagou     = ["打狗缠字·青竹盘根", "wx_anim_27", "bamboo_bind",  "wx_vfx_15", "wx_fx_whip_arc",      1, 4],

		// 5. Hammer / Axe / Shield (8)
		wx_hammer_shatter  = ["震岳碎甲·崩星重击", "wx_anim_57", "armor_break",  "wx_vfx_14", "wx_fx_sonic_ring",    0, 7],
		wx_hammer_quake    = ["裂地崩山·三叠地刺", "wx_anim_10", "earth_wave",   "wx_vfx_05", "wx_fx_earth_fissure", 0, 9],
		wx_hammer_leiting  = ["雷霆碎岳·九天落雷", "wx_anim_29", "sky_thunder",  "wx_vfx_14", "wx_fx_thunder_bolt",  1, 8],
		wx_axe_split       = ["力劈华山·断盾裂颅", "wx_anim_58", "shield_split", "wx_vfx_02", "wx_fx_earth_fissure", 0, 7],
		wx_axe_whirl       = ["黑水狂斧·血风轮转", "wx_anim_59", "berserk_spin", "wx_vfx_06", "wx_fx_blood_orb",     0, 7],
		wx_axe_kaishan     = ["盘古开天·巨钺分海", "wx_anim_30", "giant_axe",    "wx_vfx_02", "wx_fx_earth_fissure", 0, 9],
		wx_shield_bash_qi  = ["铁壁靠山·崩云撞击", "wx_anim_60", "shield_ram",   "wx_vfx_17", "wx_fx_golden_bell",   0, 6],
		wx_shield_tiebi    = ["不动明王·玄武甲阵", "wx_anim_31", "hex_fortress", "wx_vfx_17", "wx_fx_golden_bell",   0, 3],

		// 6. Dagger / Whip / Flail / Ranged / Throwing (14)
		wx_dagger_vital    = ["分水断脉·双刺剪血", "wx_anim_33", "twin_fang",    "wx_vfx_04", "wx_fx_blood_orb",     0, 4],
		wx_dagger_fuxue    = ["鬼影附骨·瞬步背刺", "wx_anim_61", "backstab",     "wx_vfx_25", "wx_fx_claw_slash",    1, 5],
		wx_dagger_execute  = ["幽冥绝杀·暗夜一线", "wx_anim_62", "night_exec",   "wx_vfx_30", "wx_fx_claw_slash",    1, 7],
		wx_flail_lash      = ["云梦软鞭·越盾击顶", "wx_anim_63", "over_shield",  "wx_vfx_32", "wx_fx_whip_arc",      1, 5],
		wx_flail_entangle  = ["锁喉缠丝·三匝绞杀", "wx_anim_64", "neck_coil",    "wx_vfx_31", "wx_fx_lotus_seal",    1, 5],
		wx_whip_suohou     = ["灵蛇出洞·青鳞毒鞭", "wx_anim_32", "viper_whip",   "wx_vfx_32", "wx_fx_whip_arc",      2, 5],
		wx_bow_snipe       = ["流星追月·破音贯日", "wx_anim_12", "sonic_arrow",  "wx_vfx_03", "wx_fx_sonic_ring",    1, 6],
		wx_bow_liuxing     = ["落日连珠·三矢追星", "wx_anim_34", "triple_arc",   "wx_vfx_02", "wx_fx_sonic_ring",    3, 5],
		wx_crossbow_shenji = ["神机劲弩·旋钢透甲", "wx_anim_65", "heavy_bolt",   "wx_vfx_29", "wx_fx_sonic_ring",    1, 7],
		wx_throwing_rain   = ["唐门暴雨·梨花千针", "wx_anim_13", "needle24",     "wx_vfx_27", "wx_fx_gold_needle",   5, 5],
		wx_throw_fan       = ["漫天花雨·七星飞刀", "wx_anim_66", "fan_knives7",  "wx_vfx_27", "wx_fx_sword_phantom", 4, 4],
		wx_throw_duzhen    = ["五毒丧门·百足瘴钉", "wx_anim_67", "venom_spikes", "wx_vfx_28", "wx_fx_poison_skull",  3, 5],
		wx_throw_pilidan   = ["霹雳雷火·赤硝轰天", "wx_anim_14", "bomb_arc",     "wx_vfx_29", "wx_fx_thunder_bolt",  1, 9],
		wx_smoke_cast      = ["奇门瘴雾·墨烟障目", "wx_anim_68", "smoke_screen", "wx_vfx_25", "wx_fx_poison_skull",  1, 3],

		// 7. Inner Qi / Qinggong / Tactics (9)
		wx_meditate        = ["周天吐纳·三花聚顶", "wx_anim_69", "lotus_breath", "wx_vfx_18", "wx_fx_lotus_seal",    0, 1],
		wx_blood_burst     = ["天魔燃血·赤焰破限", "wx_anim_70", "blood_flame",  "wx_vfx_20", "wx_fx_blood_orb",     0, 4],
		wx_neigong_jinzhong= ["少林金钟·梵音护体", "wx_anim_16", "golden_bell",  "wx_vfx_17", "wx_fx_golden_bell",   0, 3],
		wx_neigong_xixing  = ["北冥黑渊·鲸吞噬气", "wx_anim_24", "black_hole",   "wx_vfx_19", "wx_fx_bagua",         3, 5],
		wx_qinggong_zongyue= ["武当梯云·踏风登天", "wx_anim_71", "cloud_jump",   "wx_vfx_26", "wx_fx_sonic_ring",    0, 2],
		wx_qinggong_lingbo = ["凌波微步·八卦残影", "wx_anim_15", "mirage_step",  "wx_vfx_25", "wx_fx_bagua",         0, 2],
		wx_rally_command   = ["总瓢把令·帅旗招展", "wx_anim_36", "war_banner",   "wx_vfx_24", "wx_fx_banner_crest",  0, 3],
		wx_tactics_jinzhen = ["扁鹊渡穴·五气金针", "wx_anim_72", "heal_needles", "wx_vfx_22", "wx_fx_gold_needle",   3, 2],
		wx_tactics_shihou  = ["佛门狮吼·五叠震魂", "wx_anim_35", "lion_roar",    "wx_vfx_23", "wx_fx_sonic_ring",    0, 8],
		wx_hama_push       = ["白驼金蟾·蓄劲推山", "wx_anim_75", "toad_leap_slam","wx_vfx_28","wx_fx_sonic_ring",    2, 8],
		// === Expanded 96 Active Skills (wx_anim_76..171) ===
		wx_sword_wanjian       = ["万剑归宗·九天剑潮", "wx_anim_76", "flurry_wanjian", "wx_vfx_08", "wx_fx_sword_phantom", 4, 8],
		wx_sword_yunv          = ["冷月清辉·双剑交剪", "wx_anim_77", "flurry_yunv", "wx_vfx_01", "wx_fx_sword_phantom", 2, 4],
		wx_sword_canhe         = ["姑苏柳絮·随风拂穴", "wx_anim_78", "taiji_canhe", "wx_vfx_15", "wx_fx_bagua", 1, 4],
		wx_sword_bixue         = ["武夷碧水·惊涛叠剑", "wx_anim_79", "upcut_bixue", "wx_vfx_21", "wx_fx_sonic_ring", 1, 6],
		wx_sword_xuanbing      = ["昆仑玄霜·冰封剑狱", "wx_anim_80", "upcut_xuanbing", "wx_vfx_10", "wx_fx_ice_spikes", 1, 6],
		wx_sword_miejian       = ["峨眉金顶·绝命贯眉", "wx_anim_81", "sky_miejian", "wx_vfx_07", "wx_fx_lotus_seal", 1, 6],
		wx_sword_zixia         = ["西岳紫霞·破气贯虹", "wx_anim_82", "pierce_zixia", "wx_vfx_04", "wx_fx_sword_phantom", 2, 6],
		wx_sword_zhenwu        = ["真武七星·荡魔剑印", "wx_anim_83", "taiji_zhenwu", "wx_vfx_12", "wx_fx_bagua", 2, 6],
		wx_sword_huifeng       = ["回锋折燕·惊鸿返刺", "wx_anim_84", "flurry_huifeng", "wx_vfx_01", "wx_fx_sword_phantom", 1, 5],
		wx_sword_kuangfeng     = ["落英缤纷·疾风掠剑", "wx_anim_85", "flurry_luoying", "wx_vfx_26", "wx_fx_sword_phantom", 2, 4],
		wx_sword_qinggang      = ["青釭裂铠·寒星洞甲", "wx_anim_86", "pierce_qinggang", "wx_vfx_03", "wx_fx_sonic_ring", 1, 6],
		wx_sword_yinsha        = ["幽冥鬼影·追魂穿心", "wx_anim_87", "shadow_yinsha", "wx_vfx_30", "wx_fx_claw_slash", 1, 6],
		wx_saber_abi           = ["阿鼻地狱·血海屠城", "wx_anim_88", "aoe_abi", "wx_vfx_06", "wx_fx_blood_orb", 0, 9],
		wx_saber_xinyue        = ["瀚海孤月·流沙掠刃", "wx_anim_89", "flurry_xinyue", "wx_vfx_02", "wx_fx_whip_arc", 1, 5],
		wx_saber_shishen       = ["天狼啸月·噬血撕喉", "wx_anim_90", "shadow_shishen", "wx_vfx_06", "wx_fx_claw_slash", 1, 7],
		wx_saber_podao         = ["雁门雄关·斩马裂铠", "wx_anim_91", "sky_podao", "wx_vfx_05", "wx_fx_earth_fissure", 0, 8],
		wx_saber_kuanglan      = ["八荒六合·金刀霸浪", "wx_anim_92", "aoe_kuanglan", "wx_vfx_24", "wx_fx_sonic_ring", 0, 7],
		wx_saber_bagua         = ["玄虚八卦·游身斜斩", "wx_anim_93", "taiji_baguadao", "wx_vfx_15", "wx_fx_bagua", 1, 5],
		wx_saber_tuxiong       = ["黑水战帮·屠熊裂胸", "wx_anim_94", "sky_tuxiong", "wx_vfx_02", "wx_fx_claw_slash", 0, 7],
		wx_saber_zhanlang      = ["洞庭怒涛·翻江断浪", "wx_anim_95", "upcut_zhanlang", "wx_vfx_21", "wx_fx_sonic_ring", 1, 6],
		wx_saber_baji          = ["淮阳金刀·八极崩锷", "wx_anim_96", "pierce_baji", "wx_vfx_14", "wx_fx_sonic_ring", 0, 6],
		wx_saber_lingnan       = ["南岭矮步·滚堂削足", "wx_anim_97", "taiji_lingnan", "wx_vfx_01", "wx_fx_whip_arc", 0, 5],
		wx_saber_chiyou        = ["凶黎兵主·五兵裂阵", "wx_anim_98", "sky_chiyou", "wx_vfx_02", "wx_fx_earth_fissure", 1, 9],
		wx_fist_rulai          = ["千手如来·万佛朝宗", "wx_anim_99", "sky_rulai", "wx_vfx_09", "wx_fx_buddha_palm", 2, 9],
		wx_fist_nuchao         = ["钱塘大潮·惊涛裂岸", "wx_anim_100", "upcut_nuchao", "wx_vfx_21", "wx_fx_sonic_ring", 1, 7],
		wx_fist_qianzhu        = ["五毒千蛛·蚀心毒丝", "wx_anim_101", "shadow_qianzhu", "wx_vfx_28", "wx_fx_poison_skull", 2, 5],
		wx_fist_piaoxue        = ["金顶穿云·飘雪绵掌", "wx_anim_102", "taiji_piaoxue", "wx_vfx_16", "wx_fx_buddha_palm", 1, 5],
		wx_fist_longzhao       = ["少室龙爪·裂甲分筋", "wx_anim_103", "pierce_longzhao", "wx_vfx_09", "wx_fx_claw_slash", 0, 6],
		wx_fist_xiongzhao      = ["黑水荒原·苍熊裂石", "wx_anim_104", "sky_xiongzhao", "wx_vfx_11", "wx_fx_claw_slash", 0, 7],
		wx_fist_canhezhi       = ["姑苏参合·凌空剑指", "wx_anim_105", "pierce_canhezhi", "wx_vfx_12", "wx_fx_sword_phantom", 2, 5],
		wx_fist_nianhua        = ["灵山拈花·错骨锁脉", "wx_anim_106", "taiji_nianhua", "wx_vfx_16", "wx_fx_lotus_seal", 1, 4],
		wx_fist_tiegang        = ["南派铁线·崩桥碎甲", "wx_anim_107", "pierce_tiegang", "wx_vfx_14", "wx_fx_sonic_ring", 0, 5],
		wx_fist_heisha         = ["铁掌黑砂·透骨灼腑", "wx_anim_108", "shadow_heisha", "wx_vfx_11", "wx_fx_poison_skull", 1, 5],
		wx_fist_luohan         = ["少室罗汉·伏虎冲捶", "wx_anim_109", "flurry_luohan", "wx_vfx_09", "wx_fx_sonic_ring", 0, 5],
		wx_spear_panlong       = ["长风盘龙·追魂贯喉", "wx_anim_110", "pierce_panlong", "wx_vfx_03", "wx_fx_dragon_head", 1, 6],
		wx_spear_xuelong       = ["长白雪龙·穿云裂冰", "wx_anim_111", "upcut_xuelong", "wx_vfx_10", "wx_fx_ice_spikes", 2, 6],
		wx_spear_zhenbiao      = ["威远定鼎·镇岳崩云", "wx_anim_112", "pierce_zhenbiao", "wx_vfx_24", "wx_fx_dragon_head", 1, 7],
		wx_spear_shouguan      = ["北岳雄关·铁矛守隘", "wx_anim_113", "pierce_shouguan", "wx_vfx_03", "wx_fx_sonic_ring", 1, 5],
		wx_spear_yaqi          = ["中军牙旗·破阵扬威", "wx_anim_114", "aoe_yaqi", "wx_vfx_24", "wx_fx_banner_crest", 1, 6],
		wx_pole_pojun          = ["破军龙骧·铁戟摧阵", "wx_anim_115", "aoe_pojun", "wx_vfx_02", "wx_fx_earth_fissure", 0, 8],
		wx_pole_fenjiang       = ["洞庭夜叉·分江裂浪", "wx_anim_116", "pierce_fenjiang", "wx_vfx_21", "wx_fx_claw_slash", 1, 6],
		wx_staff_qingou        = ["天下无狗·八方棒影", "wx_anim_117", "flurry_qingou", "wx_vfx_15", "wx_fx_whip_arc", 2, 7],
		wx_staff_fengmo        = ["少室护法·紧那伏魔", "wx_anim_118", "sky_fengmo", "wx_vfx_02", "wx_fx_golden_bell", 0, 8],
		wx_staff_weituo        = ["韦陀献杵·金雷灌顶", "wx_anim_119", "sky_weituo", "wx_vfx_14", "wx_fx_buddha_palm", 0, 7],
		wx_staff_lianhua       = ["莲花落拍·缠丝叩腕", "wx_anim_120", "whip_lianhua", "wx_vfx_15", "wx_fx_lotus_seal", 1, 4],
		wx_staff_zhenjiang     = ["川江盘龙·镇水横棒", "wx_anim_121", "aoe_zhenjiang", "wx_vfx_21", "wx_fx_sonic_ring", 0, 6],
		wx_hammer_pocheng      = ["九曜坠星·一锤破城", "wx_anim_122", "earth_pocheng", "wx_vfx_05", "wx_fx_earth_fissure", 1, 9],
		wx_hammer_qianjun      = ["太行万钧·碎星崩岩", "wx_anim_123", "earth_qianjun", "wx_vfx_14", "wx_fx_earth_fissure", 0, 8],
		wx_hammer_jingua       = ["朔方金瓜·碎胄裂额", "wx_anim_124", "sky_jingua", "wx_vfx_14", "wx_fx_sonic_ring", 0, 6],
		wx_hammer_polu         = ["北岳擂鼓·双锤震胆", "wx_anim_125", "aoe_polu", "wx_vfx_23", "wx_fx_sonic_ring", 0, 8],
		wx_hammer_faqiu        = ["发丘分金·破棺断石", "wx_anim_126", "pierce_faqiu", "wx_vfx_05", "wx_fx_lotus_seal", 0, 6],
		wx_axe_kaitian         = ["劈山裂岳·神钺断峰", "wx_anim_127", "sky_kaitian", "wx_vfx_02", "wx_fx_earth_fissure", 0, 9],
		wx_axe_xueming         = ["荒原狂魔·血斧噬生", "wx_anim_128", "aoe_xueming", "wx_vfx_06", "wx_fx_blood_orb", 1, 7],
		wx_axe_poche           = ["边军宣花·碎盾摧车", "wx_anim_129", "sky_poche", "wx_vfx_02", "wx_fx_sonic_ring", 0, 7],
		wx_dagger_jingke       = ["图穷匕见·白虹贯日", "wx_anim_130", "shadow_jingke", "wx_vfx_07", "wx_fx_sword_phantom", 1, 8],
		wx_dagger_zhuanzhu     = ["炙鱼藏剑·三甲洞穿", "wx_anim_131", "pierce_zhuanzhu", "wx_vfx_03", "wx_fx_sonic_ring", 1, 6],
		wx_dagger_yingci       = ["幽谷墨烟·无影双刺", "wx_anim_132", "shadow_yingci", "wx_vfx_25", "wx_fx_claw_slash", 1, 5],
		wx_dagger_shenghuo     = ["西域圣火·奇令诡刃", "wx_anim_133", "flurry_shenghuo", "wx_vfx_02", "wx_fx_lotus_seal", 1, 5],
		wx_flail_panlong       = ["九节盘龙·越盾碎顶", "wx_anim_134", "whip_panlong", "wx_vfx_32", "wx_fx_dragon_head", 1, 6],
		wx_flail_jinshe        = ["五毒金蛇·缠颈噬魂", "wx_anim_135", "whip_jinshe", "wx_vfx_28", "wx_fx_whip_arc", 2, 5],
		wx_flail_liuxing       = ["云梦三首·流星乱坠", "wx_anim_136", "flurry_liuxing", "wx_vfx_14", "wx_fx_whip_arc", 2, 6],
		wx_bow_luori           = ["大荒落日·一矢焚天", "wx_anim_137", "pierce_luori", "wx_vfx_02", "wx_fx_dragon_head", 2, 8],
		wx_bow_jiuxing         = ["九星连珠·破云贯日", "wx_anim_138", "flurry_jiuxing", "wx_vfx_03", "wx_fx_sonic_ring", 3, 6],
		wx_bow_yanxing         = ["塞外苍狼·追风鸣镝", "wx_anim_139", "pierce_yanxing", "wx_vfx_26", "wx_fx_sonic_ring", 1, 5],
		wx_crossbow_liannu     = ["唐门机括·连珠毒矢", "wx_anim_140", "flurry_liannu", "wx_vfx_28", "wx_fx_poison_skull", 3, 5],
		wx_gun_leihuo          = ["沙州神机·三眼雷火", "wx_anim_141", "aoe_leihuo", "wx_vfx_29", "wx_fx_thunder_bolt", 2, 8],
		wx_gun_huolong         = ["神机火龙·焚城轰雷", "wx_anim_142", "earth_huolong", "wx_vfx_29", "wx_fx_earth_fissure", 3, 9],
		wx_neigong_zixia       = ["紫霞东来·流云归元", "wx_anim_143", "stance_zixia", "wx_vfx_04", "wx_fx_lotus_seal", 0, 2],
		wx_neigong_yijin       = ["少室易筋·洗髓生莲", "wx_anim_144", "stance_yijin", "wx_vfx_22", "wx_fx_buddha_palm", 0, 3],
		wx_neigong_hanbing     = ["玄阴寒狱·六角霜罡", "wx_anim_145", "stance_hanbing", "wx_vfx_21", "wx_fx_ice_spikes", 0, 3],
		wx_neigong_douzhuan    = ["斗转星移·星璇借力", "wx_anim_146", "stance_douzhuan", "wx_vfx_19", "wx_fx_bagua", 0, 3],
		wx_neigong_wudu        = ["万蛊出柙·碧璘护体", "wx_anim_147", "aoe_wuduzhang", "wx_vfx_28", "wx_fx_poison_skull", 0, 4],
		wx_neigong_guiyuan     = ["太和抱元·先天清气", "wx_anim_148", "stance_guiyuan", "wx_vfx_18", "wx_fx_bagua", 0, 2],
		wx_neigong_taotie      = ["饕餮凶魄·鲸吞万气", "wx_anim_149", "aoe_taotie", "wx_vfx_20", "wx_fx_blood_orb", 0, 6],
		wx_neigong_chaoxi      = ["沧海潮生·碧波调息", "wx_anim_150", "stance_chaoxi", "wx_vfx_21", "wx_fx_lotus_seal", 0, 2],
		wx_neigong_junwu       = ["九边铁血·杀伐冲霄", "wx_anim_151", "stance_junwu", "wx_vfx_24", "wx_fx_banner_crest", 0, 4],
		wx_qinggong_yanxing    = ["飞燕抄水·掠波滑步", "wx_anim_152", "step_yanxing", "wx_vfx_25", "wx_fx_sonic_ring", 0, 2],
		wx_qinggong_shuishang  = ["一苇渡江·踏浪凌波", "wx_anim_153", "step_shuishang", "wx_vfx_21", "wx_fx_lotus_seal", 0, 2],
		wx_qinggong_feiyan     = ["穿云飞燕·凌霄掠影", "wx_anim_154", "step_feiyan", "wx_vfx_26", "wx_fx_sword_phantom", 0, 2],
		wx_qinggong_meiying    = ["幽谷魅影·分身迷踪", "wx_anim_155", "step_meiying", "wx_vfx_25", "wx_fx_claw_slash", 0, 2],
		wx_qinggong_shenxing   = ["神行百变·泥鳅滑影", "wx_anim_156", "step_shenxing", "wx_vfx_25", "wx_fx_bagua", 0, 2],
		wx_qinggong_xuelian    = ["昆仑飞雪·踏雪无痕", "wx_anim_157", "step_xuelian", "wx_vfx_21", "wx_fx_ice_spikes", 0, 2],
		wx_qinggong_chanchu    = ["金蟾折跃·落地震尘", "wx_anim_158", "step_chanchu", "wx_vfx_28", "wx_fx_sonic_ring", 0, 4],
		wx_qinggong_suodi      = ["缩地成寸·咫尺天涯", "wx_anim_159", "step_suodi", "wx_vfx_26", "wx_fx_bagua", 0, 3],
		wx_henglian_tiebushan  = ["少林铁布·铜皮铁骨", "wx_anim_160", "stance_tiebushan", "wx_vfx_17", "wx_fx_golden_bell", 0, 3],
		wx_henglian_jinchan    = ["金蝉脱壳·柔云卸甲", "wx_anim_161", "stance_jinchan", "wx_vfx_15", "wx_fx_lotus_seal", 0, 2],
		wx_henglian_tongtou    = ["铁额铜头·迎面撞山", "wx_anim_162", "pierce_tongtou", "wx_vfx_17", "wx_fx_sonic_ring", 0, 7],
		wx_henglian_panshi     = ["北岳磐石·渊渟岳峙", "wx_anim_163", "stance_panshi", "wx_vfx_05", "wx_fx_earth_fissure", 0, 4],
		wx_shield_xuanwu       = ["太古玄武·铁壁龟阵", "wx_anim_164", "stance_xuanwu", "wx_vfx_17", "wx_fx_golden_bell", 0, 4],
		wx_tactics_guigu       = ["鬼谷纵横·星盘演兵", "wx_anim_165", "aoe_guigu", "wx_vfx_24", "wx_fx_banner_crest", 0, 4],
		wx_tactics_kuiniu      = ["东海夔牛·苍雷裂胆", "wx_anim_166", "aoe_kuiniu", "wx_vfx_23", "wx_fx_thunder_bolt", 0, 9],
		wx_tactics_bamen       = ["六韬八门·金锁连营", "wx_anim_167", "aoe_bamen", "wx_vfx_24", "wx_fx_bagua", 0, 3],
		wx_tactics_qimen       = ["奇门遁甲·八阵迷烟", "wx_anim_168", "stance_qimen", "wx_vfx_25", "wx_fx_bagua", 0, 3],
		wx_throw_liuyedao      = ["子母飞刀·寒星追命", "wx_anim_169", "flurry_liuyedao", "wx_vfx_27", "wx_fx_sword_phantom", 3, 5],
		wx_throw_kongque       = ["孔雀开屏·七彩绝杀", "wx_anim_170", "flurry_kongque", "wx_vfx_27", "wx_fx_gold_needle", 5, 7],
		wx_whip_xiangxi        = ["辰州铜铃·引路摄魂", "wx_anim_171", "whip_xiangxi", "wx_vfx_30", "wx_fx_whip_arc", 1, 6]
	}
};

// Populate all 72 `wx_anim_01..72` labels into `AnimLabels` so every sequence ID resolves cleanly
foreach (_skKey, _chSpec in ::Wuxia.VFX.SkillChoreo)
{
	::Wuxia.VFX.AnimLabels[_chSpec[1]] <- _chSpec[0];
}

::Wuxia.VFX.getSkillChoreoLabel <- function( _skill )
{
	if (_skill == null) return "";
	if (::Wuxia.hasMember(_skill.m, "WX_ChoreoID") && _skill.m.WX_ChoreoID != null && (_skill.m.WX_ChoreoID in ::Wuxia.VFX.SkillChoreo))
		return ::Wuxia.VFX.SkillChoreo[_skill.m.WX_ChoreoID][0];
	if (::Wuxia.hasMember(_skill.m, "WX_AnimID") && _skill.m.WX_AnimID != null && (_skill.m.WX_AnimID in ::Wuxia.VFX.AnimLabels))
		return ::Wuxia.VFX.AnimLabels[_skill.m.WX_AnimID];
	return "";
};

// ============================================================================
// Settings, Persistence & Tactical Resource Preloading (Zero-Stutter Engine)
// ============================================================================

::Wuxia.VFX.OptionsDirtyInSession <- false;

::Wuxia.VFX.isVfxEnabled <- function()
{
	return ::Wuxia.VFX.Config.ShowSkillVfx;
};

::Wuxia.VFX.isMotionEnabled <- function()
{
	return ::Wuxia.VFX.Config.EnableActorMotion;
};

::Wuxia.VFX.isCutInEnabled <- function()
{
	return ::Wuxia.VFX.Config.ShowSkillVfx && ::Wuxia.VFX.Config.ShowSkillCutIn;
};

if (!("Settings" in ::Wuxia))
{
	::Wuxia.Settings <- {
		FastRitual = false,
		getPayload = function()
		{
			return {
				showSkillVfx      = ::Wuxia.VFX.Config.ShowSkillVfx,
				enableActorMotion = ::Wuxia.VFX.Config.EnableActorMotion,
				showSkillCutIn    = ::Wuxia.VFX.Config.ShowSkillCutIn,
				enableWuxiaSfx    = ::Wuxia.VFX.Config.EnableWuxiaSfx,
				FastRitual        = ::Wuxia.Settings.FastRitual
			};
		},
		updateSetting = function( _key, _val )
		{
			local b = (_val == true || _val == 1 || _val == "1" || _val == "true");
			if (_key == "enableWuxiaSfx" || _key == "EnableWuxiaSfx")
			{
				::Wuxia.VFX.Config.EnableWuxiaSfx = b;
				::Wuxia.VFX.EnableWuxiaSfx = b;
			}
			else if (_key == "showSkillVfx" || _key == "ShowSkillVfx")
				::Wuxia.VFX.Config.ShowSkillVfx = b;
			else if (_key == "enableActorMotion" || _key == "EnableActorMotion")
				::Wuxia.VFX.Config.EnableActorMotion = b;
			else if (_key == "showSkillCutIn" || _key == "ShowSkillCutIn")
				::Wuxia.VFX.Config.ShowSkillCutIn = b;
			else if (_key == "FastRitual" || _key == "fastRitual")
				::Wuxia.Settings.FastRitual = b;
			::Wuxia.VFX.OptionsDirtyInSession = true;
			::Wuxia.VFX.saveOptionsToWorld();
			return ::Wuxia.Settings.getPayload();
		}
	};
}

::Wuxia.VFX.getOptions <- function()
{
	return {
		showSkillVfx      = ::Wuxia.VFX.Config.ShowSkillVfx,
		enableActorMotion = ::Wuxia.VFX.Config.EnableActorMotion,
		showSkillCutIn    = ::Wuxia.VFX.Config.ShowSkillCutIn
	};
};

::Wuxia.VFX.saveOptionsToWorld <- function()
{
	try
	{
		if ("World" in getroottable() && ::World != null && ("Flags" in ::World) && ::World.Flags != null)
		{
			::World.Flags.set("wx_opt_skill_vfx", ::Wuxia.VFX.Config.ShowSkillVfx ? 1 : 0);
			::World.Flags.set("wx_opt_actor_motion", ::Wuxia.VFX.Config.EnableActorMotion ? 1 : 0);
			::World.Flags.set("wx_opt_skill_cutin", ::Wuxia.VFX.Config.ShowSkillCutIn ? 1 : 0);
		}
	}
	catch (_e) {}
};

::Wuxia.VFX.loadOptionsFromWorld <- function()
{
	try
	{
		if ("World" in getroottable() && ::World != null && ("Flags" in ::World) && ::World.Flags != null)
		{
			if (::Wuxia.VFX.OptionsDirtyInSession)
			{
				::Wuxia.VFX.saveOptionsToWorld();
				return;
			}
			if (::World.Flags.has("wx_opt_skill_vfx"))
				::Wuxia.VFX.Config.ShowSkillVfx = (::World.Flags.getAsInt("wx_opt_skill_vfx") != 0);
			if (::World.Flags.has("wx_opt_actor_motion"))
				::Wuxia.VFX.Config.EnableActorMotion = (::World.Flags.getAsInt("wx_opt_actor_motion") != 0);
			if (::World.Flags.has("wx_opt_skill_cutin"))
				::Wuxia.VFX.Config.ShowSkillCutIn = (::World.Flags.getAsInt("wx_opt_skill_cutin") != 0);
		}
	}
	catch (_e) {}
};

// Track registration and whether the texture has a brush in this battle scene.
::Wuxia.VFX.queueBattleTexture <- function( _path )
{
	if (_path in ::Wuxia.VFX.BattleTextures) return false;
	::Tactical.addResource(_path);
	::Wuxia.VFX.BattleTextures[_path] <- false;
	return true;
};

::Wuxia.VFX.queueKineticProfile <- function( _profile )
{
	local added = false;
	foreach (seq in [_profile.seq, _profile.seq2])
	{
		if (!(seq in ::Wuxia.VFX.SeqToKineticSheet)) continue;
		foreach (path in ::Wuxia.VFX.SeqToKineticSheet[seq])
			if (::Wuxia.VFX.queueBattleTexture(path)) added = true;
	}
	return added;
};

::Wuxia.VFX.warmBattleTextures <- function()
{
	if (!::Wuxia.VFX.isVfxEnabled() || !::Wuxia.VFX.BattleResourcesQueued) return;
	local tile = ::Tactical.getTileSquare(0, 0);
	if (tile == null) return;

	// Late additions to the native resource package are not retained. A transparent map detail
	// holds each texture until clearScene, including when effects are enabled mid-battle.
	foreach (path, ready in ::Wuxia.VFX.BattleTextures)
	{
		if (ready || !(path in ::Wuxia.VFX.BattleTextureBrushes)) continue;
		local detail = tile.spawnDetail(::Wuxia.VFX.BattleTextureBrushes[path], 0, false, false);
		if (detail == null) continue;
		detail.Alpha = 0;
		detail.Scale = 0.0;
		::Wuxia.VFX.BattleTextures[path] = true;
	}
};

::Wuxia.VFX.registerTacticalResources <- function( _loadImmediately = false )
{
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Wuxia.hasMember(::Tactical, "addResource")) return;
	local previousCount = ::Wuxia.VFX.BattleTextures.len();
	foreach (path in ::Wuxia.VFX.TacticalBaseTextures)
		::Wuxia.VFX.queueBattleTexture(path);

	local showVfx = ::Wuxia.VFX.isVfxEnabled();
	if (showVfx)
	{
		foreach (path in ["gfx/wx_effects_0.png", "gfx/wx_effects_1.png", "gfx/wx_effects_2.png",
			"gfx/wx_effects_3.png", "gfx/wx_effects_5.png", "gfx/wx_kinetic_0.png", "gfx/wx_kinetic_3.png"])
			::Wuxia.VFX.queueBattleTexture(path);
	}

	if (::Wuxia.hasMember(::Tactical, "Entities") && ::Tactical.Entities != null)
	{
		foreach (actor in ::Tactical.Entities.getAllInstancesAsArray())
		{
			if (actor == null) continue;
			if (("WX_CustomEnemyBust" in actor.m && actor.m.WX_CustomEnemyBust != null)
				|| ("WX_BossID" in actor.m && actor.m.WX_BossID != null))
				::Wuxia.VFX.queueBattleTexture("gfx/wx_corpses_0.png");

			if (!showVfx) continue;
			foreach (skill in actor.getSkills().m.Skills)
			{
				if (skill == null) continue;
				local id = skill.getID();
				if (typeof id != "string" || id.find("actives.wx_") != 0) continue;
				local profile = ::Wuxia.KineticVFX.getProfile(id.slice(8));
				if (profile != null) ::Wuxia.VFX.queueKineticProfile(profile);
			}
		}
	}

	::Wuxia.VFX.BattleResourcesQueued = true;
	if (_loadImmediately && ::Wuxia.VFX.BattleTextures.len() > previousCount)
	{
		::Tactical.loadResources();
		::Wuxia.VFX.warmBattleTextures();
	}
};

::Wuxia.VFX.setOptions <- function( _showVfx, _enableMotion, _fromUI = false, _showCutIn = null )
{
	local prevVfx = ::Wuxia.VFX.Config.ShowSkillVfx;
	if (_showVfx != null)
		::Wuxia.VFX.Config.ShowSkillVfx = (_showVfx == true || _showVfx == 1);
	if (_enableMotion != null)
		::Wuxia.VFX.Config.EnableActorMotion = (_enableMotion == true || _enableMotion == 1);
	if (_showCutIn != null)
		::Wuxia.VFX.Config.ShowSkillCutIn = (_showCutIn == true || _showCutIn == 1);

	if (_fromUI)
	{
		::Wuxia.VFX.OptionsDirtyInSession = true;
		::Wuxia.VFX.saveOptionsToWorld();
	}

	if ("Tactical" in getroottable() && ::Tactical != null && ::Tactical.isActive())
	{
		if (::Wuxia.VFX.Config.ShowSkillVfx && !prevVfx)
			::Wuxia.VFX.registerTacticalResources(true);
		if (!::Wuxia.VFX.Config.EnableActorMotion)
			::Wuxia.VFX.clearAllActiveMotions();
		if (!::Wuxia.VFX.isCutInEnabled())
		{
			try
			{
				if ("State" in ::Tactical && ::Tactical.State != null && ::Tactical.State.m.TacticalScreen != null && ::Tactical.State.m.TacticalScreen.m.JSHandle != null)
					::Tactical.State.m.TacticalScreen.m.JSHandle.asyncCall("wxCloseCombatCue", null);
			}
			catch (_eCue) {}
		}
	}
	return ::Wuxia.VFX.getOptions();
};

// ============================================================================
// Pure-Squirrel Math, Coordinate & Cached Color Utilities
// ============================================================================

::Wuxia.VFX.sqrt <- function( _val )
{
	local x = _val.tofloat();
	if (x <= 0.0) return 0.0;
	local y = (x + 1.0) * 0.5;
	for (local i = 0; i < 8; i = ++i)
		y = 0.5 * (y + x / y);
	return y;
};

::Wuxia.VFX.clamp01 <- function( _v )
{
	local f = _v.tofloat();
	if (f < 0.0) return 0.0;
	if (f > 1.0) return 1.0;
	return f;
};

::Wuxia.VFX.easeOut <- function( _t )
{
	local k = ::Wuxia.VFX.clamp01(_t);
	local inv = 1.0 - k;
	return 1.0 - inv * inv;
};

::Wuxia.VFX.easeInOut <- function( _t )
{
	local k = ::Wuxia.VFX.clamp01(_t);
	return k * k * (3.0 - 2.0 * k);
};

::Wuxia.VFX.arch01 <- function( _t )
{
	local k = ::Wuxia.VFX.clamp01(_t);
	return 4.0 * k * (1.0 - k);
};

// Smooth periodic sine approximation taking full turns (1.0 = 360 deg); zero Math.sin dependency!
::Wuxia.VFX.sinTurns <- function( _turns )
{
	local x = _turns.tofloat();
	x = x - ::Math.floor(x);
	if (x > 0.5) x -= 1.0;
	local ax = x < 0.0 ? -x : x;
	local raw = 16.0 * x * (0.5 - ax);
	local araw = raw < 0.0 ? -raw : raw;
	return 0.225 * (raw * araw - raw) + raw;
};

::Wuxia.VFX.cosTurns <- function( _turns )
{
	return ::Wuxia.VFX.sinTurns(_turns.tofloat() + 0.25);
};

::Wuxia.VFX.getNowF <- function()
{
	if ("Time" in getroottable() && ::Time != null && ("getVirtualTimeF" in ::Time))
		return ::Time.getVirtualTimeF();
	return 0.0;
};

// Canonical Battle Brothers horizontal facing sign: player & allies face Right (+1.0), enemies face Left (-1.0)
::Wuxia.VFX.getActorFacingSign <- function( _actor )
{
	if (_actor == null) return 1.0;
	try
	{
		if (::Wuxia.hasMember(_actor, "isAlliedWithPlayer"))
			return _actor.isAlliedWithPlayer() ? 1.0 : -1.0;
		if (::Wuxia.hasMember(_actor, "isPlayerControlled"))
			return _actor.isPlayerControlled() ? 1.0 : -1.0;
	}
	catch (_e) {}
	return 1.0;
};

::Wuxia.VFX.shouldFlipLeft <- function( _dir, _user = null )
{
	if (_dir != null)
	{
		if (_dir.X < -0.15) return true;
		if (_dir.X > 0.15) return false;
	}
	return ::Wuxia.VFX.getActorFacingSign(_user) < 0.0;
};

// Native OpenGL tactical direction vector (+X = Right/East, +Y = Up/North matching `tile.Pos` & `sprite.vs`)
::Wuxia.VFX.getDirVec <- function( _fromTile, _toTile, _user = null )
{
	local defX = ::Wuxia.VFX.getActorFacingSign(_user);
	if (_fromTile == null || _toTile == null || _fromTile.ID == _toTile.ID)
		return { X = defX, Y = 0.0 };
	try
	{
		if (("Pos" in _fromTile) && ("Pos" in _toTile) && _fromTile.Pos != null && _toTile.Pos != null)
		{
			local dx = (_toTile.Pos.X - _fromTile.Pos.X).tofloat();
			local dy = (_toTile.Pos.Y - _fromTile.Pos.Y).tofloat();
			local len = ::Wuxia.VFX.sqrt(dx * dx + dy * dy);
			if (len > 0.001)
				return { X = dx / len, Y = dy / len };
		}
		if (::Wuxia.hasMember(_fromTile, "getDirectionTo"))
		{
			local d = _fromTile.getDirectionTo(_toTile);
			local hexDirs = [
				{ X =  0.00, Y =  1.00 }, // N (Up)
				{ X =  0.86, Y =  0.50 }, // NE
				{ X =  0.86, Y = -0.50 }, // SE
				{ X =  0.00, Y = -1.00 }, // S (Down)
				{ X = -0.86, Y = -0.50 }, // SW
				{ X = -0.86, Y =  0.50 }  // NW
			];
			if (d >= 0 && d < hexDirs.len())
				return hexDirs[d];
		}
	}
	catch (_e) {}
	return { X = defX, Y = 0.0 };
};

::Wuxia.VFX.getSkyTileAbove <- function( _tile, _steps = 2 )
{
	if (_tile == null) return null;
	local cur = _tile;
	for (local i = 0; i < _steps; i = ++i)
	{
		if (::Wuxia.hasMember(cur, "hasNextTile") && cur.hasNextTile(::Const.Direction.N))
			cur = cur.getNextTile(::Const.Direction.N);
		else
			break;
	}
	return cur;
};

::Wuxia.VFX.buildAttackEffect <- function( _brushName )
{
	if (_brushName == null || _brushName == "") return null;
	if (_brushName in ::Wuxia.VFX.Cache)
		return ::Wuxia.VFX.Cache[_brushName];

	if (!("Const" in getroottable()) || !("Tactical" in ::Const) || !("AttackEffectSlash" in ::Const.Tactical))
		return null;

	local srcEff = ::Const.Tactical.AttackEffectSlash;
	local custom = null;
	if (typeof srcEff == "array")
	{
		custom = [];
		foreach (elem in srcEff)
		{
			if (typeof elem == "table")
			{
				local c = clone elem;
				if ("Brush" in c) c.Brush = _brushName;
				custom.push(c);
			}
			else
			{
				custom.push(elem);
			}
		}
	}
	else if (typeof srcEff == "table")
	{
		custom = clone srcEff;
		if ("Brush" in custom) custom.Brush = _brushName;
	}
	::Wuxia.VFX.Cache[_brushName] <- custom;
	return custom;
};

::Wuxia.VFX.logOnce <- function( _key, _err )
{
	if (_key in ::Wuxia.VFX.LoggedErrors) return;
	::Wuxia.VFX.LoggedErrors[_key] <- true;
	::logWarning("[WX-VFX] " + _key + ": " + _err);
};

::Wuxia.VFX.makeColorRGBA <- function( _r, _g, _b, _a )
{
	local r = ::Math.max(0, ::Math.min(255, _r.tointeger()));
	local g = ::Math.max(0, ::Math.min(255, _g.tointeger()));
	local b = ::Math.max(0, ::Math.min(255, _b.tointeger()));
	local a = ::Math.max(0, ::Math.min(255, _a.tointeger()));
	local key = "" + r + "_" + g + "_" + b + "_" + a;
	if (key in ::Wuxia.VFX.ColorCache)
		return ::Wuxia.VFX.ColorCache[key];
	local c = ::createColor("#ffffff");
	c.R = r;
	c.G = g;
	c.B = b;
	c.A = a;
	::Wuxia.VFX.ColorCache[key] <- c;
	return c;
};

::Wuxia.VFX.getVecZero <- function()
{
	if (::Wuxia.VFX.VecZero == null)
		::Wuxia.VFX.VecZero = ::createVec(0.0, 0.0);
	return ::Wuxia.VFX.VecZero;
};

// ============================================================================
// Silky 4-Stage Fade-In / Translucent Peak / Fade-Out Particle Engine
// Zero raw-sticker pop-in: always starts at Alpha=0, blooms into translucent
// Qi energy (175..225), rotates natively via TorqueMin/Max, and fades to 0!
// ============================================================================

::Wuxia.VFX.makeDynamicParticle <- function(
	_brushName, _delayMs, _lifeSec = 0.22, _scale = 1.08,
	_vx = 0, _vy = 0, _torque = 0, _qty = 1, _fx = 0, _fy = 0,
	_ox = 0, _oy = 0, _peakAlpha = 215, _fadeInSec = 0.09, _fadeOutSec = 0.18,
	_tintR = 255, _tintG = 255, _tintB = 255
)
{
	if (_brushName == null || _brushName == "") return null;
	if (!("Const" in getroottable()) || !("Tactical" in ::Const)) return null;

	local vxF = _vx.tofloat();
	local vyF = _vy.tofloat();
	local speed = ::Wuxia.VFX.sqrt(vxF * vxF + vyF * vyF);
	local dx = speed > 0.01 ? (vxF / speed) : 0.0;
	local dy = speed > 0.01 ? (vyF / speed) : 0.0;

	local fadeIn  = ::Math.maxf(0.04, _fadeInSec.tofloat());
	local holdSec = ::Math.maxf(0.06, _lifeSec.tofloat() * 0.48);
	local fadeOut = ::Math.maxf(0.11, _fadeOutSec.tofloat());
	local sc      = ::Math.maxf(0.45, _scale.tofloat());
	local qty     = ::Math.max(1, _qty.tointeger());
	local delay   = ::Math.max(0, _delayMs.tointeger());
	local peakA   = ::Math.max(40, ::Math.min(235, _peakAlpha.tointeger()));
	local softA   = ::Math.max(25, ::Math.floor(peakA * 0.72));

	local rotMin = 0;
	local rotMax = 0;
	local tq = _torque.tofloat();
	if (tq != 0.0)
	{
		local rSpan = ::Math.min(30, ::Math.abs(_torque) / 8);
		rotMin = -rSpan;
		rotMax = rSpan;
	}

	local colZero = ::Wuxia.VFX.makeColorRGBA(_tintR, _tintG, _tintB, 0);
	local colPeak = ::Wuxia.VFX.makeColorRGBA(_tintR, _tintG, _tintB, peakA);
	local colSoft = ::Wuxia.VFX.makeColorRGBA(_tintR, _tintG, _tintB, softA);
	local dirVec  = (speed > 0.01) ? ::createVec(dx, dy) : ::Wuxia.VFX.getVecZero();
	local fVec    = (_fx == 0 && _fy == 0) ? ::Wuxia.VFX.getVecZero() : ::createVec(_fx.tofloat(), _fy.tofloat());
	local oxF     = _ox.tofloat();
	local oyF     = _oy.tofloat();

	return {
		Delay            = delay,
		Quantity         = qty,
		LifeTimeQuantity = qty,
		SpawnRate        = 1000,
		Brushes          = [_brushName],
		Stages = [
			{
				LifeTimeMin    = fadeIn,
				LifeTimeMax    = fadeIn + 0.02,
				ColorMin       = colZero,
				ColorMax       = colZero,
				ScaleMin       = sc * 0.64,
				ScaleMax       = sc * 0.68,
				RotationMin    = rotMin,
				RotationMax    = rotMax,
				TorqueMin      = tq,
				TorqueMax      = tq,
				VelocityMin    = speed,
				VelocityMax    = speed,
				DirectionMin   = dirVec,
				DirectionMax   = dirVec,
				SpawnOffsetMin = ::createVec(oxF - 3.0, oyF - 3.0),
				SpawnOffsetMax = ::createVec(oxF + 3.0, oyF + 3.0),
				ForceMin       = fVec,
				ForceMax       = fVec
			},
			{
				LifeTimeMin = holdSec,
				LifeTimeMax = holdSec + 0.02,
				ColorMin    = colPeak,
				ColorMax    = colPeak,
				ScaleMin    = sc * 1.00,
				ScaleMax    = sc * 1.04,
				VelocityMin = speed * 0.85,
				VelocityMax = speed * 0.85,
				ForceMin    = fVec,
				ForceMax    = fVec
			},
			{
				LifeTimeMin = fadeOut,
				LifeTimeMax = fadeOut + 0.03,
				ColorMin    = colSoft,
				ColorMax    = colSoft,
				ScaleMin    = sc * 1.09,
				ScaleMax    = sc * 1.13,
				VelocityMin = speed * 0.45,
				VelocityMax = speed * 0.45,
				ForceMin    = fVec,
				ForceMax    = fVec
			},
			{
				LifeTimeMin = 0.02,
				LifeTimeMax = 0.03,
				ColorMin    = colZero,
				ColorMax    = colZero,
				ScaleMin    = sc * 1.24,
				ScaleMax    = sc * 1.28,
				VelocityMin = speed * 0.15,
				VelocityMax = speed * 0.15,
				ForceMin    = fVec,
				ForceMax    = fVec
			}
		]
	};
};

::Wuxia.VFX.makeFrameParticle <- function( _brushName, _delayMs, _lifeSec = 0.16, _scale = 1.08 )
{
	return ::Wuxia.VFX.makeDynamicParticle(_brushName, _delayMs, _lifeSec, _scale, 0, 12, 0, 1, 0, 0, 0, 0, 205, 0.07, 0.16);
};

::Wuxia.VFX.buildFlipbookStages <- function( _animID )
{
	if (_animID == null || _animID == "") return null;
	if (_animID in ::Wuxia.VFX.FlipbookCache)
		return ::Wuxia.VFX.FlipbookCache[_animID];

	local f1 = ::Wuxia.VFX.makeDynamicParticle(_animID + "_f1", 0,   0.14, 0.94, 0, 14, 0, 1, 0, 0, 0, -4, 180, 0.07, 0.14);
	local f2 = ::Wuxia.VFX.makeDynamicParticle(_animID + "_f2", 75,  0.16, 1.08, 0, 18, 0, 1, 0, 0, 0,  0, 205, 0.07, 0.16);
	local f3 = ::Wuxia.VFX.makeDynamicParticle(_animID + "_f3", 155, 0.20, 1.20, 0, 12, 0, 1, 0, 0, 0,  4, 222, 0.08, 0.20);
	local f4 = ::Wuxia.VFX.makeDynamicParticle(_animID + "_f4", 260, 0.18, 1.12, 0, 24, 0, 1, 0, 0, 0,  8, 175, 0.07, 0.20);
	if (f1 == null) return null;

	local seq = [f1, f2, f3, f4];
	::Wuxia.VFX.FlipbookCache[_animID] <- seq;
	return seq;
};

// The native emitter terminates the process on an unknown brush, before Squirrel can catch it.
::Wuxia.VFX.resolveParticleBrushes <- function( _brushes, _flipX = false )
{
	if (typeof _brushes != "array" || _brushes.len() == 0 || !("doesBrushExist" in getroottable())) return null;
	local result = _brushes;
	foreach (index, brush in _brushes)
	{
		if (typeof brush != "string" || brush == "") return null;
		if (_flipX && ::Wuxia.Appearance.brushExists(brush + "_L"))
		{
			if (result == _brushes) result = clone _brushes;
			result[index] = brush + "_L";
		}
		else if (!::Wuxia.Appearance.brushExists(brush))
		{
			::Wuxia.VFX.logOnce("particle:" + brush, "Brush is not registered");
			return null;
		}
	}
	return result;
};

::Wuxia.VFX.spawnParticleSpec <- function( _spec, _tile, _flipX = false, _extraDelayMs = 0 )
{
	if (!::Wuxia.VFX.isVfxEnabled()) return;
	if (_spec == null || _tile == null || !_tile.IsVisibleForPlayer) return;
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
	if (!("spawnParticleEffect" in ::Tactical)) return;
	local d = _spec.Delay + _extraDelayMs;
	if (d < 0) d = 0;
	local brushes = ::Wuxia.VFX.resolveParticleBrushes(_spec.Brushes, _flipX);
	if (brushes == null) return;
	::Tactical.spawnParticleEffect(
		false,
		brushes,
		_tile,
		d,
		_spec.Quantity,
		_spec.LifeTimeQuantity,
		_spec.SpawnRate,
		_spec.Stages
	);
};

::Wuxia.VFX.spawnDynamicAt <- function(
	_tile, _brushName, _delayMs = 0, _lifeSec = 0.22, _scale = 1.08,
	_vx = 0, _vy = 0, _torque = 0, _qty = 1, _fx = 0, _fy = 0, _flipX = false,
	_ox = 0, _oy = 0, _peakAlpha = 212, _fadeInSec = 0.09, _fadeOutSec = 0.18,
	_tintR = 255, _tintG = 255, _tintB = 255
)
{
	if (!::Wuxia.VFX.isVfxEnabled()) return;
	if (_tile == null || !_tile.IsVisibleForPlayer || _brushName == null || _brushName == "") return;
	local p = ::Wuxia.VFX.makeDynamicParticle(
		_brushName, _delayMs, _lifeSec, _scale,
		_vx, _vy, _torque, _qty, _fx, _fy,
		_ox, _oy, _peakAlpha, _fadeInSec, _fadeOutSec,
		_tintR, _tintG, _tintB
	);
	if (p != null)
	{
		::Wuxia.VFX.spawnParticleSpec(p, _tile, _flipX, 0);
	}
};

::Wuxia.VFX.spawnSingleFrameAt <- function( _tile, _brushName, _delayMs = 0, _lifeSec = 0.18, _scale = 1.08, _flipX = false )
{
	::Wuxia.VFX.spawnDynamicAt(_tile, _brushName, _delayMs, _lifeSec, _scale, 0, 10, 0, 1, 0, 0, _flipX, 0, 0, 200, 0.08, 0.18);
};

// Cross-faded 4-frame spatial progression: glides smoothly from approach -> midpoint -> impact -> dissipation!
::Wuxia.VFX.spawnFlipbookAt <- function( _tile, _animID, _baseDelayMs = 0, _scaleMult = 1.0, _flipX = false, _dir = null )
{
	if (!::Wuxia.VFX.isVfxEnabled()) return;
	if (_tile == null || !_tile.IsVisibleForPlayer || _animID == null || _animID == "") return;

	if (_dir == null && _scaleMult >= 0.96 && _scaleMult <= 1.04)
	{
		local seq = ::Wuxia.VFX.buildFlipbookStages(_animID);
		if (seq != null)
		{
			foreach (sp in seq)
				::Wuxia.VFX.spawnParticleSpec(sp, _tile, _flipX, _baseDelayMs);
		}
		return;
	}

	local dx = (_dir != null) ? _dir.X : 0.0;
	local dy = (_dir != null) ? _dir.Y : 0.0;
	::Wuxia.VFX.spawnDynamicAt(_tile, _animID + "_f1", _baseDelayMs + 0,   0.13, 0.90 * _scaleMult, dx * 65.0, dy * 65.0, 0, 1, 0, 0, _flipX, -dx * 22.0, -dy * 22.0, 180, 0.07, 0.14);
	::Wuxia.VFX.spawnDynamicAt(_tile, _animID + "_f2", _baseDelayMs + 75,  0.15, 1.04 * _scaleMult, dx * 72.0, dy * 72.0, 0, 1, 0, 0, _flipX, -dx * 8.0,  -dy * 8.0,  205, 0.07, 0.15);
	::Wuxia.VFX.spawnDynamicAt(_tile, _animID + "_f3", _baseDelayMs + 150, 0.20, 1.18 * _scaleMult, dx * 26.0, dy * 26.0, 0, 1, 0, 0, _flipX, 0.0,        0.0,        222, 0.08, 0.20);
	::Wuxia.VFX.spawnDynamicAt(_tile, _animID + "_f4", _baseDelayMs + 255, 0.18, 1.12 * _scaleMult, dx * 40.0, dy * 40.0 + 18.0, 0, 1, 0, 0, _flipX, dx * 8.0, dy * 8.0, 175, 0.07, 0.20);
};

// Spawns a translucent, smoothly fading afterimage silhouette of the actor's live paperdoll (zero extra textures!)
::Wuxia.VFX.spawnAfterimage <- function( _actor, _ox = 0.0, _oy = 0.0, _delayMs = 0, _alpha = 135, _r = 185, _g = 225, _b = 255 )
{
	if (!::Wuxia.VFX.isVfxEnabled() || !::Wuxia.isOnMap(_actor)) return;
	local tile = _actor.getTile();
	if (tile == null || !tile.IsVisibleForPlayer) return;
	if (!::Wuxia.hasMember(_actor, "hasSprite") || !_actor.hasSprite("body")) return;

	try
	{
		local sb = _actor.getSprite("body");
		if (sb == null || !sb.Visible || !sb.HasBrush) return;
		local bName = sb.getBrush().Name;
		if (bName == null || bName == "") return;
		local isFlip = sb.isFlippedHorizontally();

		::Wuxia.VFX.spawnDynamicAt(tile, bName, _delayMs, 0.10, 1.0, 0, 6, 0, 1, 0, 0, isFlip, _ox, _oy, _alpha, 0.03, 0.20, _r, _g, _b);
		if (_actor.hasSprite("head"))
		{
			local sh = _actor.getSprite("head");
			if (sh != null && sh.Visible && sh.HasBrush)
			{
				local hName = sh.getBrush().Name;
				if (hName != null && hName != "")
					::Wuxia.VFX.spawnDynamicAt(tile, hName, _delayMs, 0.10, 1.0, 0, 6, 0, 1, 0, 0, isFlip, _ox, _oy, _alpha, 0.03, 0.20, _r, _g, _b);
			}
		}
	}
	catch (_e) {}
};

::Wuxia.VFX.shakeEntityFrom <- function( _target, _originTile, _intensity = 5 )
{
	if (_target == null || !_target.isAlive() || !_target.isPlacedOnMap() || _originTile == null) return;
	if ("getShaker" in ::Tactical && ::Tactical.getShaker() != null)
	{
		::Tactical.getShaker().shake(_target, _originTile, _intensity);
	}
};

// ============================================================================
// 60 FPS Actor Motion Choreography Engine (`onRender` + Differential Sprite Offsets)
// Creates anticipation pullback space even at 1-hex melee range, articulated
// torso/head/weapon motion, aerial leaps, cyclone spins, shadow blinks,
// inner-Qi levitation, and target hit-flash / recoil / launch / dodge sway!
// ============================================================================

::Wuxia.VFX.classifyMotionKind <- function( _mode )
{
	if (_mode == null || _mode == "") return "lunge_pierce";
	if (_mode == "sky_thunder" || _mode == "buddha_palm" || _mode == "giant_axe" || _mode == "leap_cleave"
		|| _mode == "gravity_cut" || _mode == "shield_split" || _mode == "earth_wave" || _mode == "toad_leap_slam"
		|| _mode.find("sky_") == 0 || _mode.find("earth_") == 0)
		return "sky_slam";
	if (_mode == "combo3" || _mode == "clone3" || _mode == "omnislash6" || _mode == "rapid_jab"
		|| _mode == "prism5_hit" || _mode == "phoenix9" || _mode == "petal_storm" || _mode == "silver_tiger_spear"
		|| _mode == "twin_cross" || _mode == "halberd_x" || _mode == "twin_fang"
		|| _mode.find("flurry_") == 0)
		return "flurry_blitz";
	if (_mode == "backstab" || _mode == "night_exec" || _mode.find("shadow_") == 0)
		return "shadow_blink";
	if (_mode == "tidal_sweep" || _mode == "cyclone_pole" || _mode == "berserk_spin"
		|| _mode == "lion_roar" || _mode == "taunt_slam" || _mode.find("aoe_") == 0)
		return "cyclone_spin";
	if (_mode == "modao_upcut" || _mode == "dragon_up" || _mode == "fire_pillar"
		|| _mode == "taiyuan_flame" || _mode == "frost_tomb" || _mode == "crescent"
		|| _mode == "ghost_claw" || _mode == "blood_siphon" || _mode.find("upcut_") == 0)
		return "upcut_launch";
	if (_mode == "taiji_field" || _mode == "taiji_orb" || _mode == "disarm_arc" || _mode == "disarm_grab"
		|| _mode == "over_shield" || _mode == "neck_coil" || _mode == "viper_whip" || _mode == "bamboo_bind"
		|| _mode.find("taiji_") == 0 || _mode.find("whip_") == 0)
		return "taiji_deflect";
	if (_mode == "vacuum_pull" || _mode == "hook_pull" || _mode == "black_hole")
		return "pull_grapple";
	if (_mode == "cloud_jump" || _mode == "mirage_step" || _mode.find("step_") == 0)
		return "qinggong_leap";
	if (_mode == "counter" || _mode == "spear_wall" || _mode == "hex_fortress" || _mode == "golden_bell"
		|| _mode == "lotus_breath" || _mode == "poise_draw" || _mode == "blood_flame" || _mode == "war_banner"
		|| _mode == "heal_needles" || _mode.find("stance_") == 0)
		return "stance_meditate";
	if (_mode == "dragon_coil" || _mode == "sun_laser" || _mode == "flying_虹" || _mode == "star_rain"
		|| _mode == "sonic_arrow" || _mode == "triple_arc" || _mode == "heavy_bolt" || _mode == "needle24"
		|| _mode == "fan_knives7" || _mode == "venom_spikes" || _mode == "bomb_arc" || _mode == "smoke_screen")
		return "ranged_release";
	return "lunge_pierce";
};

::Wuxia.VFX.getMotionSpeedScale <- function( _actor )
{
	local scale = 1.0;
	try
	{
		if ("Settings" in getroottable() && ::Settings != null && ("getGameplaySettings" in ::Settings))
		{
			local gs = ::Settings.getGameplaySettings();
			if (gs != null)
			{
				local isPlayer = (_actor != null && ::Wuxia.hasMember(_actor, "isPlayerControlled") && _actor.isPlayerControlled());
				if (isPlayer && gs.FasterPlayerMovement) scale = 0.78;
				else if (!isPlayer && gs.FasterAIMovement) scale = 0.72;
			}
		}
		if ("Time" in getroottable() && ::Time != null && ("getVirtualSpeed" in ::Time))
		{
			local vs = ::Time.getVirtualSpeed();
			if (vs > 1.05)
				scale = scale / ::Math.minf(2.5, vs);
		}
	}
	catch (_e) {}
	return ::Math.maxf(0.28, scale);
};

::Wuxia.VFX.applyActorArticulatedOffset <- function( _actor, _bx, _by, _hx, _hy, _wx, _wy, _sx, _sy )
{
	if (_actor == null || !::Wuxia.hasMember(_actor, "hasSprite") || !::Wuxia.hasMember(_actor, "setSpriteOffset")) return;
	local vBody = ::createVec(::Math.round(_bx), ::Math.round(_by));
	local vHead = (_hx == 0.0 && _hy == 0.0) ? vBody : ::createVec(::Math.round(_bx + _hx), ::Math.round(_by + _hy));
	local vWpn  = (_wx == 0.0 && _wy == 0.0) ? vBody : ::createVec(::Math.round(_bx + _wx), ::Math.round(_by + _wy));
	local vShd  = (_sx == 0.0 && _sy == 0.0) ? vBody : ::createVec(::Math.round(_bx + _sx), ::Math.round(_by + _sy));

	foreach (lyr in ::Wuxia.VFX.MotionBodyLayers)
	{
		if (_actor.hasSprite(lyr)) _actor.setSpriteOffset(lyr, vBody);
	}
	foreach (lyr2 in ::Wuxia.VFX.MotionHeadLayers)
	{
		if (_actor.hasSprite(lyr2)) _actor.setSpriteOffset(lyr2, vHead);
	}
	foreach (lyr3 in ::Wuxia.VFX.MotionWeaponLayers)
	{
		if (_actor.hasSprite(lyr3)) _actor.setSpriteOffset(lyr3, vWpn);
	}
	foreach (lyr4 in ::Wuxia.VFX.MotionShieldLayers)
	{
		if (_actor.hasSprite(lyr4)) _actor.setSpriteOffset(lyr4, vShd);
	}
};

::Wuxia.VFX.setActorLayersFlip <- function( _actor, _flip )
{
	if (_actor == null || !::Wuxia.hasMember(_actor, "hasSprite")) return;
	foreach (lyr in ::Wuxia.VFX.MotionBodyLayers)
	{
		if (_actor.hasSprite(lyr)) _actor.getSprite(lyr).setHorizontalFlipping(_flip);
	}
	foreach (lyr2 in ::Wuxia.VFX.MotionHeadLayers)
	{
		if (_actor.hasSprite(lyr2)) _actor.getSprite(lyr2).setHorizontalFlipping(_flip);
	}
	foreach (lyr3 in ::Wuxia.VFX.MotionWeaponLayers)
	{
		if (_actor.hasSprite(lyr3)) _actor.getSprite(lyr3).setHorizontalFlipping(_flip);
	}
	foreach (lyr4 in ::Wuxia.VFX.MotionShieldLayers)
	{
		if (_actor.hasSprite(lyr4)) _actor.getSprite(lyr4).setHorizontalFlipping(_flip);
	}
};

// Bug 3 Fix: NEVER call `storeSpriteColors()` / `fadeToStoredColors()` or fade Alpha < 255 on live actors!
// Under fast combat speed / Qinggong teleports / elevation step-fades, an actor's transient Alpha can be 0 when
// `storeSpriteColors()` runs, poisoning stored colors with Alpha = 0 so `fadeToStoredColors()` turns the unit invisible!
::Wuxia.VFX.ensureActorSpritesVisible <- function( _actor )
{
	if (_actor == null || !::Wuxia.hasMember(_actor, "isAlive") || !_actor.isAlive() || !::Wuxia.hasMember(_actor, "hasSprite"))
		return;
	local white = ::Wuxia.VFX.makeColorRGBA(255, 255, 255, 255);
	try
	{
		if (::Wuxia.hasMember(_actor, "fadeTo"))
			_actor.fadeTo(white, 0);
		if (_actor.hasSprite("body"))
		{
			local sb = _actor.getSprite("body");
			if (sb != null && sb.HasBrush)
			{
				sb.Color = white;
				if (!sb.Visible) sb.Visible = true;
			}
		}
		if ("Armory" in ::Wuxia && "syncActorHandheldAndArmor" in ::Wuxia.Armory && ("Appearance" in ::Wuxia) && ::Wuxia.Appearance.isEligibleHumanActor(_actor))
		{
			if (_actor.hasSprite("head") && !_actor.getSprite("head").Visible)
				::Wuxia.Armory.syncActorHandheldAndArmor(_actor);
		}
	}
	catch (_eVis) {}
};

::Wuxia.VFX.beginActorTint <- function( _actor, _r, _g, _b, _a, _ms )
{
	if (_actor == null || !::Wuxia.hasMember(_actor, "fadeTo")) return;
	if (("m" in _actor) && _actor.m != null && ("IsMoving" in _actor.m) && _actor.m.IsMoving) return;
	try
	{
		// Strictly clamp Alpha to 255 so rapid overlapping animations can NEVER turn an actor transparent/invisible!
		_actor.fadeTo(::Wuxia.VFX.makeColorRGBA(_r, _g, _b, 255), _ms);
		_actor.m.WX_MotionTinted <- true;
	}
	catch (_e) {}
};

::Wuxia.VFX.endActorTint <- function( _actor, _ms = 120 )
{
	if (_actor == null || !("m" in _actor) || _actor.m == null) return;
	local wasTinted = ("WX_MotionTinted" in _actor.m) && _actor.m.WX_MotionTinted;
	_actor.m.WX_MotionTinted <- false;
	if (!wasTinted) return;
	try
	{
		local white = ::Wuxia.VFX.makeColorRGBA(255, 255, 255, 255);
		if (_ms <= 0 || (("IsMoving" in _actor.m) && _actor.m.IsMoving))
			::Wuxia.VFX.ensureActorSpritesVisible(_actor);
		else if (::Wuxia.hasMember(_actor, "fadeTo"))
			_actor.fadeTo(white, _ms);
	}
	catch (_e) {}
};

::Wuxia.VFX.clearActorMotion <- function( _actor, _forceReset = false )
{
	if (_actor == null || !("m" in _actor) || _actor.m == null) return;
	local mo = ("WX_Motion" in _actor.m) ? _actor.m.WX_Motion : null;
	if (mo == null && !_forceReset)
	{
		::Wuxia.VFX.endActorTint(_actor, 60);
		return;
	}
	_actor.m.WX_Motion <- null;
	try
	{
		if (mo != null && mo.flippedTemp)
			::Wuxia.VFX.setActorLayersFlip(_actor, mo.origFlip);
		::Wuxia.VFX.applyActorArticulatedOffset(_actor, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
		local isMovingNow = ("IsMoving" in _actor.m) && _actor.m.IsMoving;
		if (!isMovingNow && ::Wuxia.hasMember(_actor, "setAlwaysApplySpriteOffset"))
			_actor.setAlwaysApplySpriteOffset(false);
		if (_forceReset && !isMovingNow && ::Wuxia.hasMember(_actor, "resetRenderEffects"))
			_actor.resetRenderEffects();
		::Wuxia.VFX.endActorTint(_actor, _forceReset ? 0 : 80);
		::Wuxia.VFX.ensureActorSpritesVisible(_actor);
		local isHuman = ("Appearance" in ::Wuxia) && ::Wuxia.Appearance.isEligibleHumanActor(_actor);
		local wasRenderEnabled = (mo != null && ("wasRenderEnabled" in mo)) ? mo.wasRenderEnabled : false;
		// NEVER disable render callback while vanilla BB is moving/fading the actor or if vanilla already had it enabled!
		if (!isMovingNow && !wasRenderEnabled && ((mo != null && mo.disableRenderOnEnd) || (_forceReset && isHuman)) && ::Wuxia.hasMember(_actor, "setRenderCallbackEnabled"))
			_actor.setRenderCallbackEnabled(false);
		if (::Wuxia.hasMember(_actor, "setDirty"))
			_actor.setDirty(true);
	}
	catch (_e) {}
};

::Wuxia.VFX.clearAllActiveMotions <- function( _forceRoster = false )
{
	try
	{
		if ("Tactical" in getroottable() && ::Tactical != null && ("Entities" in ::Tactical) && ::Tactical.Entities != null)
		{
			local all = ::Tactical.Entities.getAllInstances();
			if (all != null)
			{
				foreach (facList in all)
				{
					if (facList == null) continue;
					foreach (a in facList)
						::Wuxia.VFX.clearActorMotion(a, _forceRoster);
				}
			}
		}
	}
	catch (_e) {}

	if (_forceRoster)
	{
		try
		{
			if ("World" in getroottable() && ::World != null && ::Wuxia.hasMember(::World, "getPlayerRoster") && ::World.getPlayerRoster() != null)
			{
				local bros = ::World.getPlayerRoster().getAll();
				if (bros != null)
				{
					foreach (bro in bros)
						::Wuxia.VFX.clearActorMotion(bro, true);
				}
			}
		}
		catch (_e2) {}
	}
};

::Wuxia.VFX.startActorMotion <- function( _actor, _kind, _dir, _durSec, _delaySec = 0.0, _extra = null )
{
	if (!::Wuxia.VFX.isMotionEnabled()) return false;
	if (_actor == null || !::Wuxia.isOnMap(_actor) || !_actor.isAlive()) return false;
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return false;
	try
	{
		if (("Entities" in ::Tactical) && ::Tactical.Entities != null && ::Wuxia.hasMember(::Tactical.Entities, "isCombatFinished") && ::Tactical.Entities.isCombatFinished())
			return false;
	}
	catch (_eFin) {}
	local tile = _actor.getTile();
	if (tile == null || !tile.IsVisibleForPlayer) return false;
	if (!::Wuxia.hasMember(_actor, "setSpriteOffset") || !::Wuxia.hasMember(_actor, "setRenderCallbackEnabled")) return false;

	// Clean any prior motion before starting a new one
	::Wuxia.VFX.clearActorMotion(_actor);

	local now = ::Wuxia.VFX.getNowF();
	local spd = ::Wuxia.VFX.getMotionSpeedScale(_actor);
	local dx = (_dir != null) ? _dir.X.tofloat() : ::Wuxia.VFX.getActorFacingSign(_actor);
	local dy = (_dir != null) ? _dir.Y.tofloat() : 0.0;
	local faceSign = (dx < -0.15) ? -1.0 : ((dx > 0.15) ? 1.0 : ::Wuxia.VFX.getActorFacingSign(_actor));
	local origFlip = false;
	if (_actor.hasSprite("body"))
		origFlip = _actor.getSprite("body").isFlippedHorizontally();
	local isHuman = ("Appearance" in ::Wuxia) && ::Wuxia.Appearance.isEligibleHumanActor(_actor);
	local wasRenderEnabled = false;
	try
	{
		if (::Wuxia.hasMember(_actor, "isRenderCallbackEnabled"))
			wasRenderEnabled = _actor.isRenderCallbackEnabled();
	}
	catch (_eRC) {}

	_actor.m.WX_Motion <- {
		kind               = _kind,
		dx                 = dx,
		dy                 = dy,
		px                 = -dy * faceSign,
		py                 = dx * faceSign,
		startTime          = now + _delaySec.tofloat() * spd,
		lastPoseTime       = -1.0,
		duration           = ::Math.maxf(0.16, _durSec.tofloat() * spd),
		origFlip           = origFlip,
		flippedTemp        = false,
		afterimage1Done    = false,
		afterimage2Done    = false,
		tintStarted        = false,
		tintEnded          = false,
		wasRenderEnabled   = wasRenderEnabled,
		disableRenderOnEnd = isHuman && !wasRenderEnabled,
		extra              = _extra
	};

	try
	{
		if (::Wuxia.hasMember(_actor, "setAlwaysApplySpriteOffset"))
			_actor.setAlwaysApplySpriteOffset(true);
		_actor.setRenderCallbackEnabled(true);
	}
	catch (_e) {}
	return true;
};

::Wuxia.VFX.startCasterMotion <- function( _user, _mode, _dir, _isQinggongLanding = false )
{
	if (!::Wuxia.VFX.isMotionEnabled() || _user == null) return false;
	local kind = _isQinggongLanding ? "qinggong_leap" : ::Wuxia.VFX.classifyMotionKind(_mode);
	local dur = 0.46;
	if (kind == "sky_slam" || kind == "cyclone_spin" || kind == "stance_meditate") dur = 0.52;
	else if (kind == "flurry_blitz" || kind == "shadow_blink" || kind == "upcut_launch" || kind == "taiji_deflect") dur = 0.48;
	else if (kind == "ranged_release" || kind == "qinggong_leap") dur = 0.42;

	local ok = ::Wuxia.VFX.startActorMotion(_user, kind, _dir, dur, 0.0, _mode);
	if (ok && ("getShaker" in ::Tactical) && ::Tactical.getShaker() != null && ("cancel" in ::Tactical.getShaker()))
	{
		try { ::Tactical.getShaker().cancel(_user); } catch (_e) {}
	}
	return ok;
};

::Wuxia.VFX.startTargetReaction <- function( _target, _mode, _dir, _hit, _isRanged = false )
{
	if (!::Wuxia.VFX.isMotionEnabled() || _target == null || !_target.isAlive() || !::Wuxia.isOnMap(_target)) return false;
	local delaySec = _isRanged ? 0.18 : 0.11;
	if (!_hit)
	{
		return ::Wuxia.VFX.startActorMotion(_target, "dodge_sway", _dir, 0.30, _isRanged ? 0.14 : 0.08, _mode);
	}

	local mKind = ::Wuxia.VFX.classifyMotionKind(_mode);
	local reactKind = "hit_recoil";
	local dur = 0.34;
	if (mKind == "upcut_launch" || mKind == "sky_slam")
	{
		reactKind = "hit_launch";
		dur = 0.40;
	}
	else if (mKind == "flurry_blitz")
	{
		reactKind = "hit_flurry";
		dur = 0.38;
	}
	else if (mKind == "pull_grapple")
	{
		reactKind = "hit_pull";
		dur = 0.34;
	}
	return ::Wuxia.VFX.startActorMotion(_target, reactKind, _dir, dur, delaySec, _mode);
};

// Frame-by-frame 60 FPS curve evaluator called from hooked `actor.onRender()`
::Wuxia.VFX.tickActorMotion <- function( _actor )
{
	if (_actor == null || !("m" in _actor) || _actor.m == null || !("WX_Motion" in _actor.m) || _actor.m.WX_Motion == null)
		return;

	local mo = _actor.m.WX_Motion;
	if (!_actor.isAlive() || !::Wuxia.isOnMap(_actor) || !("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive())
	{
		::Wuxia.VFX.clearActorMotion(_actor);
		return;
	}

	local now = ::Wuxia.VFX.getNowF();
	if (now < mo.startTime)
		return;

	local p = (now - mo.startTime) / mo.duration;
	if (p >= 1.0)
	{
		::Wuxia.VFX.clearActorMotion(_actor);
		return;
	}
	// Combat resolution uses scheduled events. Only the visual pose needs sampling at 60 Hz.
	if (mo.lastPoseTime >= 0.0 && now - mo.lastPoseTime < 1.0 / 60.0) return;
	mo.lastPoseTime = now;

	local dx = mo.dx;
	local dy = mo.dy;
	local px = mo.px;
	local py = mo.py;
	local bx = 0.0; local by = 0.0;
	local hx = 0.0; local hy = 0.0;
	local wx = 0.0; local wy = 0.0;
	local sx = 0.0; local sy = 0.0;
	local k = 0.0;
	local kind = mo.kind;

	if (kind.find("kin_") == 0 && ("KineticVFX" in ::Wuxia) && ("evalActorMotion" in ::Wuxia.KineticVFX))
	{
		if (::Wuxia.KineticVFX.evalActorMotion(_actor, mo, p))
			return;
	}

	if (kind == "lunge_pierce" || kind == "basic_strike")
	{
		local isBasic = (kind == "basic_strike");
		local backD = isBasic ? 15.0 : 25.0;
		local fwdD  = isBasic ? 28.0 : 44.0;
		local wExt  = isBasic ? 10.0 : 18.0;
		if (p < 0.20)
		{
			k = ::Wuxia.VFX.easeOut(p / 0.20);
			bx = -dx * backD * k;
			by = -dy * backD * k - (isBasic ? 3.0 : 5.0) * k;
			hx = -dx * 3.0 * k;
			hy = -2.0 * k;
			wx = -dx * 8.0 * k;
		}
		else if (p < 0.56)
		{
			k = ::Wuxia.VFX.easeOut((p - 0.20) / 0.36);
			local dist = -backD + (backD + fwdD) * k;
			bx = dx * dist;
			by = dy * dist + ::Wuxia.VFX.arch01(k) * (isBasic ? 4.0 : 7.0);
			hx = dx * 5.0 * k;
			wx = dx * wExt * k;
			sx = -dx * 4.0 * k;
			if (!isBasic && !mo.afterimage1Done && k > 0.22)
			{
				mo.afterimage1Done = true;
				::Wuxia.VFX.spawnAfterimage(_actor, bx - dx * 18.0, by - dy * 18.0, 0, 128, 175, 225, 255);
			}
			if (!isBasic && !mo.afterimage2Done && k > 0.58)
			{
				mo.afterimage2Done = true;
				::Wuxia.VFX.spawnAfterimage(_actor, bx - dx * 14.0, by - dy * 14.0, 0, 110, 210, 240, 255);
			}
		}
		else
		{
			k = 1.0 - ::Wuxia.VFX.easeInOut((p - 0.56) / 0.44);
			bx = dx * fwdD * k;
			by = dy * fwdD * k;
			hx = dx * 4.0 * k;
			wx = dx * wExt * k;
		}
	}
	else if (kind == "sky_slam")
	{
		if (p < 0.18)
		{
			k = ::Wuxia.VFX.easeOut(p / 0.18);
			bx = -dx * 16.0 * k;
			by = -dy * 16.0 * k - 8.0 * k;
			hy = -3.0 * k;
			wy = 10.0 * k;
		}
		else if (p < 0.54)
		{
			k = (p - 0.18) / 0.36;
			local ek = ::Wuxia.VFX.easeOut(k);
			local alt = ::Wuxia.VFX.arch01(k) * 56.0;
			local dist = -16.0 + 54.0 * ek;
			bx = dx * dist;
			by = dy * dist + alt;
			hx = dx * 4.0 * ek;
			hy = 4.0 * ::Wuxia.VFX.arch01(k);
			wx = dx * 14.0 * ek;
			wy = (k < 0.60 ? 14.0 : -10.0);
			if (!mo.afterimage1Done && k > 0.32)
			{
				mo.afterimage1Done = true;
				::Wuxia.VFX.spawnAfterimage(_actor, bx - dx * 10.0, by - 12.0, 0, 125, 255, 215, 145);
			}
		}
		else if (p < 0.72)
		{
			k = (p - 0.54) / 0.18;
			local bounce = -::Wuxia.VFX.arch01(k) * 8.0;
			bx = dx * (38.0 - 6.0 * k);
			by = dy * (38.0 - 6.0 * k) + bounce;
			hx = dx * 5.0 * (1.0 - k);
			hy = bounce * 0.4;
			wx = dx * 18.0 * (1.0 - k * 0.4);
			wy = -8.0 * (1.0 - k);
		}
		else
		{
			k = 1.0 - ::Wuxia.VFX.easeInOut((p - 0.72) / 0.28);
			bx = dx * 32.0 * k;
			by = dy * 32.0 * k;
			wx = dx * 10.0 * k;
		}
	}
	else if (kind == "flurry_blitz")
	{
		if (p < 0.16)
		{
			k = ::Wuxia.VFX.easeOut(p / 0.16);
			bx = -dx * 20.0 * k;
			by = -dy * 20.0 * k - 4.0 * k;
			wx = -dx * 8.0 * k;
		}
		else if (p < 0.78)
		{
			k = (p - 0.16) / 0.62;
			local wave = ::Wuxia.VFX.sinTurns(k * 1.5);
			local pulse = ::Wuxia.VFX.arch01((k * 3.0) - ::Math.floor(k * 3.0));
			local fwd = 26.0 + pulse * 16.0;
			local lat = wave * 16.0;
			bx = dx * fwd + px * lat;
			by = dy * fwd + py * lat + pulse * 6.0;
			hx = dx * 5.0;
			wx = dx * (12.0 + pulse * 10.0) + px * (wave * 6.0);
			if (!mo.afterimage1Done && k > 0.20)
			{
				mo.afterimage1Done = true;
				::Wuxia.VFX.spawnAfterimage(_actor, bx - dx * 16.0, by - dy * 16.0, 0, 125, 170, 235, 255);
			}
			if (!mo.afterimage2Done && k > 0.56)
			{
				mo.afterimage2Done = true;
				::Wuxia.VFX.spawnAfterimage(_actor, bx - dx * 14.0, by - dy * 14.0, 0, 120, 220, 185, 255);
			}
		}
		else
		{
			k = 1.0 - ::Wuxia.VFX.easeInOut((p - 0.78) / 0.22);
			bx = dx * 28.0 * k;
			by = dy * 28.0 * k;
			wx = dx * 12.0 * k;
		}
	}
	else if (kind == "upcut_launch")
	{
		if (p < 0.20)
		{
			k = ::Wuxia.VFX.easeOut(p / 0.20);
			bx = -dx * 22.0 * k;
			by = -dy * 22.0 * k - 9.0 * k;
			wy = -8.0 * k;
		}
		else if (p < 0.58)
		{
			k = ::Wuxia.VFX.easeOut((p - 0.20) / 0.38);
			local dist = -22.0 + 60.0 * k;
			local rise = ::Wuxia.VFX.arch01(k) * 30.0;
			bx = dx * dist;
			by = dy * dist + rise;
			hx = dx * 4.0 * k;
			hy = 3.0 * k;
			wx = dx * 16.0 * k;
			wy = 18.0 * k;
			if (!mo.afterimage1Done && k > 0.35)
			{
				mo.afterimage1Done = true;
				::Wuxia.VFX.spawnAfterimage(_actor, bx - dx * 14.0, by - 10.0, 0, 125, 255, 195, 140);
			}
		}
		else
		{
			k = 1.0 - ::Wuxia.VFX.easeInOut((p - 0.58) / 0.42);
			bx = dx * 38.0 * k;
			by = dy * 38.0 * k + 8.0 * k;
			wx = dx * 12.0 * k;
			wy = 10.0 * k;
		}
	}
	else if (kind == "cyclone_spin")
	{
		if (p < 0.14)
		{
			k = p / 0.14;
			by = -5.0 * k;
		}
		else if (p < 0.78)
		{
			k = (p - 0.14) / 0.64;
			local orbit = ::Wuxia.VFX.arch01(k);
			local ox = ::Wuxia.VFX.cosTurns(k * 1.0) * 20.0 * orbit;
			local oy = ::Wuxia.VFX.sinTurns(k * 1.0) * 14.0 * orbit;
			bx = dx * 20.0 * orbit + ox;
			by = dy * 20.0 * orbit + oy + 8.0 * orbit;
			wx = ox * 0.75;
			wy = oy * 0.75;
			local wantFlip = (k > 0.24 && k < 0.72) ? !mo.origFlip : mo.origFlip;
			if (wantFlip != (mo.flippedTemp ? !mo.origFlip : mo.origFlip))
			{
				::Wuxia.VFX.setActorLayersFlip(_actor, wantFlip);
				mo.flippedTemp = (wantFlip != mo.origFlip);
			}
			if (!mo.afterimage1Done && k > 0.30)
			{
				mo.afterimage1Done = true;
				::Wuxia.VFX.spawnAfterimage(_actor, bx, by, 0, 115, 255, 165, 140);
			}
		}
		else
		{
			if (mo.flippedTemp)
			{
				::Wuxia.VFX.setActorLayersFlip(_actor, mo.origFlip);
				mo.flippedTemp = false;
			}
			k = 1.0 - ::Wuxia.VFX.easeInOut((p - 0.78) / 0.22);
			bx = dx * 14.0 * k;
			by = dy * 14.0 * k;
		}
	}
	else if (kind == "shadow_blink")
	{
		if (p < 0.18)
		{
			k = p / 0.18;
			bx = -dx * 16.0 * k;
			by = -dy * 16.0 * k;
			if (!mo.tintStarted)
			{
				mo.tintStarted = true;
				::Wuxia.VFX.spawnAfterimage(_actor, 0.0, 0.0, 0, 145, 165, 140, 225);
				::Wuxia.VFX.beginActorTint(_actor, 160, 150, 215, 65, 80);
			}
		}
		else if (p < 0.62)
		{
			k = ::Wuxia.VFX.easeOut((p - 0.18) / 0.44);
			bx = dx * (46.0 * k) + px * (18.0 * ::Wuxia.VFX.arch01(k));
			by = dy * (46.0 * k) + py * (18.0 * ::Wuxia.VFX.arch01(k)) + 6.0 * ::Wuxia.VFX.arch01(k);
			hx = dx * 6.0 * k;
			wx = dx * 18.0 * k;
			if (!mo.tintEnded && k > 0.28)
			{
				mo.tintEnded = true;
				::Wuxia.VFX.endActorTint(_actor, 70);
				::Wuxia.VFX.spawnAfterimage(_actor, bx - dx * 20.0, by - dy * 20.0, 0, 125, 190, 130, 245);
			}
		}
		else
		{
			k = 1.0 - ::Wuxia.VFX.easeInOut((p - 0.62) / 0.38);
			bx = dx * 46.0 * k;
			by = dy * 46.0 * k;
			wx = dx * 14.0 * k;
		}
	}
	else if (kind == "taiji_deflect")
	{
		local arc = ::Wuxia.VFX.arch01(p);
		local sway = ::Wuxia.VFX.sinTurns(p * 1.0) * 20.0;
		bx = dx * (28.0 * arc) + px * sway;
		by = dy * (28.0 * arc) + py * sway + 9.0 * arc;
		hx = dx * 4.0 * arc;
		wx = dx * 14.0 * arc + px * (sway * 0.45);
		wy = 6.0 * arc;
	}
	else if (kind == "pull_grapple")
	{
		if (p < 0.38)
		{
			k = ::Wuxia.VFX.easeOut(p / 0.38);
			bx = dx * 26.0 * k;
			by = dy * 26.0 * k;
			wx = dx * 16.0 * k;
		}
		else if (p < 0.78)
		{
			k = ::Wuxia.VFX.easeOut((p - 0.38) / 0.40);
			local dist = 26.0 - 50.0 * k;
			bx = dx * dist;
			by = dy * dist - 4.0 * k;
			wx = dx * (16.0 * (1.0 - k));
		}
		else
		{
			k = 1.0 - ::Wuxia.VFX.easeInOut((p - 0.78) / 0.22);
			bx = -dx * 24.0 * k;
			by = -dy * 24.0 * k;
		}
	}
	else if (kind == "ranged_release")
	{
		local isStar = (mo.extra == "star_rain");
		if (p < 0.28)
		{
			k = ::Wuxia.VFX.easeOut(p / 0.28);
			bx = -dx * 16.0 * k;
			by = -dy * 16.0 * k + (isStar ? (34.0 * k) : 0.0);
			wx = -dx * 8.0 * k;
		}
		else if (p < 0.62)
		{
			k = ::Wuxia.VFX.easeOut((p - 0.28) / 0.34);
			local dist = -16.0 + 36.0 * k;
			bx = dx * dist;
			by = dy * dist + (isStar ? (34.0 * (1.0 - k * 0.4)) : 0.0);
			wx = dx * 14.0 * k;
		}
		else
		{
			k = 1.0 - ::Wuxia.VFX.easeInOut((p - 0.62) / 0.38);
			bx = dx * 20.0 * k;
			by = dy * 20.0 * k + (isStar ? (20.0 * k) : 0.0);
			wx = dx * 10.0 * k;
		}
	}
	else if (kind == "stance_meditate")
	{
		local arc = ::Wuxia.VFX.arch01(p);
		local isBlood = (mo.extra == "blood_flame");
		local isBell  = (mo.extra == "golden_bell" || mo.extra == "hex_fortress" || mo.extra == "war_banner");
		by = arc * (mo.extra == "poise_draw" ? -7.0 : 18.0);
		wy = arc * 10.0;
		sy = arc * 6.0;
		if (!mo.tintStarted && p > 0.12)
		{
			mo.tintStarted = true;
			if (isBlood)      ::Wuxia.VFX.beginActorTint(_actor, 255, 175, 165, 255, 130);
			else if (isBell)  ::Wuxia.VFX.beginActorTint(_actor, 255, 238, 175, 255, 130);
			else              ::Wuxia.VFX.beginActorTint(_actor, 215, 245, 255, 255, 130);
		}
		if (!mo.tintEnded && p > 0.62)
		{
			mo.tintEnded = true;
			::Wuxia.VFX.endActorTint(_actor, 180);
		}
	}
	else if (kind == "qinggong_leap")
	{
		// Descending graceful landing drop + crouch cushion onto target hex
		if (p < 0.72)
		{
			k = ::Wuxia.VFX.easeOut(p / 0.72);
			by = 46.0 * (1.0 - k);
			bx = -dx * 18.0 * (1.0 - k);
			if (!mo.afterimage1Done && p > 0.16)
			{
				mo.afterimage1Done = true;
				::Wuxia.VFX.spawnAfterimage(_actor, bx, by + 10.0, 0, 125, 185, 240, 255);
			}
		}
		else
		{
			k = (p - 0.72) / 0.28;
			by = -::Wuxia.VFX.arch01(k) * 7.0;
		}
	}
	else if (kind == "hit_recoil")
	{
		local arc = ::Wuxia.VFX.arch01(p);
		bx = dx * 22.0 * arc;
		by = dy * 22.0 * arc + 4.0 * arc;
		hx = dx * 6.0 * arc;
		if (!mo.tintStarted)
		{
			mo.tintStarted = true;
			::Wuxia.VFX.beginActorTint(_actor, 255, 240, 210, 255, 65);
		}
		if (!mo.tintEnded && p > 0.42)
		{
			mo.tintEnded = true;
			::Wuxia.VFX.endActorTint(_actor, 140);
		}
	}
	else if (kind == "hit_launch")
	{
		if (p < 0.78)
		{
			k = p / 0.78;
			local arc = ::Wuxia.VFX.arch01(k);
			bx = dx * 24.0 * arc;
			by = dy * 24.0 * arc + 34.0 * arc;
			hx = dx * 7.0 * arc;
			hy = 5.0 * arc;
		}
		else
		{
			k = (p - 0.78) / 0.22;
			by = -::Wuxia.VFX.arch01(k) * 6.0;
		}
		if (!mo.tintStarted)
		{
			mo.tintStarted = true;
			::Wuxia.VFX.beginActorTint(_actor, 255, 232, 185, 255, 70);
		}
		if (!mo.tintEnded && p > 0.45)
		{
			mo.tintEnded = true;
			::Wuxia.VFX.endActorTint(_actor, 150);
		}
	}
	else if (kind == "hit_flurry")
	{
		local env = ::Wuxia.VFX.arch01(p);
		local jib = ::Wuxia.VFX.sinTurns(p * 2.5) * 10.0 * env;
		bx = dx * 18.0 * env + px * jib;
		by = dy * 18.0 * env + py * jib + 4.0 * env;
		hx = dx * 5.0 * env + px * (jib * 0.4);
		if (!mo.tintStarted)
		{
			mo.tintStarted = true;
			::Wuxia.VFX.beginActorTint(_actor, 255, 238, 215, 255, 65);
		}
		if (!mo.tintEnded && p > 0.50)
		{
			mo.tintEnded = true;
			::Wuxia.VFX.endActorTint(_actor, 140);
		}
	}
	else if (kind == "hit_pull")
	{
		local arc = ::Wuxia.VFX.arch01(p);
		bx = -dx * 24.0 * arc;
		by = -dy * 24.0 * arc + 5.0 * arc;
		hx = -dx * 5.0 * arc;
		if (!mo.tintStarted)
		{
			mo.tintStarted = true;
			::Wuxia.VFX.beginActorTint(_actor, 240, 230, 255, 255, 70);
		}
		if (!mo.tintEnded && p > 0.45)
		{
			mo.tintEnded = true;
			::Wuxia.VFX.endActorTint(_actor, 140);
		}
	}
	else if (kind == "dodge_sway")
	{
		local arc = ::Wuxia.VFX.arch01(p);
		local side = ((_actor.getID() % 2) == 0) ? 1.0 : -1.0;
		bx = px * 22.0 * side * arc - dx * 6.0 * arc;
		by = py * 22.0 * side * arc + 7.0 * arc;
		hx = px * 5.0 * side * arc;
	}

	::Wuxia.VFX.applyActorArticulatedOffset(_actor, bx, by, hx, hy, wx, wy, sx, sy);
};

// Lightweight trigger VFX for Martial Passives, True Qi Shield, Frost Ring, Counter-Stances & Shan Hai Bosses!
::Wuxia.VFX.playTriggerVfx <- function( _actorOrTile, _qiAuraBrush, _sigBrush = null, _vy = 0, _torque = 0, _scale = 1.12 )
{
	if (!::Wuxia.VFX.isVfxEnabled()) return;
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
	if (_actorOrTile == null || _qiAuraBrush == null || _qiAuraBrush == "") return;

	local tile = null;
	try
	{
		if ("IsVisibleForPlayer" in _actorOrTile)
			tile = _actorOrTile;
		else if ((::Wuxia.hasMember(_actorOrTile, "isPlacedOnMap")) && _actorOrTile.isPlacedOnMap())
			tile = _actorOrTile.getTile();
	}
	catch (_e) {}
	if (tile == null || !tile.IsVisibleForPlayer) return;

	// Legacy callers pass negative _vy meaning upward drift; flip into native OpenGL +Y = Up
	local upVy = -_vy.tofloat();
	try
	{
		::Wuxia.VFX.spawnDynamicAt(tile, _qiAuraBrush, 0, 0.24, _scale, 0, upVy, _torque, 1, 0, 0, false, 0, 0, 195, 0.08, 0.19);
		if (_sigBrush != null && _sigBrush != "")
			::Wuxia.VFX.spawnDynamicAt(tile, _sigBrush, 75, 0.22, _scale * 0.94, 0, upVy * 0.5, -_torque * 0.5, 1, 0, 0, false, 0, 0, 185, 0.08, 0.18);
	}
	catch (_err)
	{
		::Wuxia.VFX.logOnce("playTriggerVfx:" + _qiAuraBrush, _err);
	}
};

// Synchronized Secondary-Hex VFX for Multi-Target AoE Sweeps (lightweight & smoothly faded to avoid overdraw)
::Wuxia.VFX.playAoESecondaryVfx <- function( _skill, _user, _adjTile, _delayMs = 85 )
{
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
	if (_skill != null && ("m" in _skill) && ("WX_KineticSuppressLegacy" in _skill.m) && _skill.m.WX_KineticSuppressLegacy) return;
	if (_adjTile == null || !_adjTile.IsVisibleForPlayer) return;

	local choreoID = (_skill != null && ::Wuxia.hasMember(_skill.m, "WX_ChoreoID")) ? _skill.m.WX_ChoreoID : null;
	local spec = (choreoID != null && (choreoID in ::Wuxia.VFX.SkillChoreo)) ? ::Wuxia.VFX.SkillChoreo[choreoID] : null;
	local animID = (spec != null) ? spec[1] : ((_skill != null && ::Wuxia.hasMember(_skill.m, "WX_AnimID")) ? _skill.m.WX_AnimID : "wx_anim_11");
	local mode   = (spec != null) ? spec[2] : "tidal_sweep";
	local qiAura = (_skill != null && ::Wuxia.hasMember(_skill.m, "WX_VfxBrush") && _skill.m.WX_VfxBrush != null) ? _skill.m.WX_VfxBrush : (spec != null ? spec[3] : "wx_vfx_06");
	local originTile = (_user != null && _user.isPlacedOnMap()) ? _user.getTile() : _adjTile;
	local dir = ::Wuxia.VFX.getDirVec(originTile, _adjTile, _user);
	local flipX = ::Wuxia.VFX.shouldFlipLeft(dir, _user);

	try
	{
		if (::Wuxia.VFX.isVfxEnabled())
		{
			local dBase = _delayMs + (::Wuxia.VFX.isMotionEnabled() ? 65 : 0);
			::Wuxia.VFX.spawnDynamicAt(_adjTile, qiAura, dBase, 0.20, 1.10, dir.X * 42.0, dir.Y * 42.0, 140, 1, 0, 0, flipX, -dir.X * 10.0, -dir.Y * 10.0, 195, 0.08, 0.18);
			::Wuxia.VFX.spawnDynamicAt(_adjTile, animID + "_f3", dBase + 55, 0.18, 1.10, dir.X * 24.0, dir.Y * 24.0, 0, 1, 0, 0, flipX, 0.0, 0.0, 200, 0.07, 0.18);
		}
		if (_adjTile.IsOccupiedByActor && originTile.ID != _adjTile.ID)
		{
			local adjEnt = _adjTile.getEntity();
			if (::Wuxia.VFX.isMotionEnabled())
				::Wuxia.VFX.startTargetReaction(adjEnt, mode, dir, true, false);
			else
				::Wuxia.VFX.shakeEntityFrom(adjEnt, originTile, 5);
		}
	}
	catch (_err)
	{
		::Wuxia.VFX.logOnce("playAoESecondaryVfx:" + animID, _err);
	}
};

// Full 171-Skill Multi-Layered Qi-Aura + 4-Frame Cross-Faded Spatial VFX + 60 FPS Actor Choreography!
::Wuxia.VFX.playSkillVfx <- function( _skill, _user, _targetTile, _brushName )
{
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
	if (_skill != null && ("m" in _skill) && ("WX_KineticSuppressLegacy" in _skill.m) && _skill.m.WX_KineticSuppressLegacy) return;

	local originTile = (_user != null && _user.isPlacedOnMap()) ? _user.getTile() : null;
	local tile = _targetTile != null ? _targetTile : originTile;
	if (tile == null) return;

	local choreoID = (_skill != null && ::Wuxia.hasMember(_skill.m, "WX_ChoreoID")) ? _skill.m.WX_ChoreoID : null;
	local spec = (choreoID != null && (choreoID in ::Wuxia.VFX.SkillChoreo)) ? ::Wuxia.VFX.SkillChoreo[choreoID] : null;
	local animID  = (spec != null) ? spec[1] : ((_skill != null && ::Wuxia.hasMember(_skill.m, "WX_AnimID")) ? _skill.m.WX_AnimID : "wx_anim_01");
	local mode    = (spec != null) ? spec[2] : ((_skill != null && ::Wuxia.hasMember(_skill.m, "WX_AnimMode")) ? _skill.m.WX_AnimMode : "crescent");
	local qiAura  = (_brushName != null && _brushName != "") ? _brushName : ((spec != null) ? spec[3] : "wx_vfx_01");
	local sigFx   = (spec != null) ? spec[4] : qiAura;
	local volleys = (spec != null) ? spec[5] : 0;
	local shakePow= (spec != null) ? spec[6] : 5;

	local dir = ::Wuxia.VFX.getDirVec(originTile, tile, _user);
	local flipX = ::Wuxia.VFX.shouldFlipLeft(dir, _user);
	local isRangedWpnSkill = (_skill != null && (::Wuxia.hasMember(_skill, "isRanged")) && _skill.isRanged());
	local isAttackSkill = (_skill != null && (::Wuxia.hasMember(_skill, "isAttack")) && _skill.isAttack());
	local isQinggongMode = (mode == "cloud_jump" || mode == "mirage_step" || mode.find("step_") == 0);

	// Detect two-phase Qinggong teleport cast (`playSkillVfx` called at takeoff tile, then immediately after teleport at landing tile)
	local isQinggongLanding = false;
	if (isQinggongMode && _user != null && ::Wuxia.hasMember(_user, "getID"))
	{
		local uid = _user.getID();
		local nowT = ::Wuxia.VFX.getNowF();
		if ((uid in ::Wuxia.VFX.LastQinggongCast) && (nowT - ::Wuxia.VFX.LastQinggongCast[uid].time) < 0.25 && ::Wuxia.VFX.LastQinggongCast[uid].tileID != tile.ID)
		{
			isQinggongLanding = true;
			dir = ::Wuxia.VFX.getDirVec(::Wuxia.VFX.LastQinggongCast[uid].tile, tile, _user);
			flipX = ::Wuxia.VFX.shouldFlipLeft(dir, _user);
			delete ::Wuxia.VFX.LastQinggongCast[uid];
		}
		else
		{
			::Wuxia.VFX.LastQinggongCast[uid] <- { time = nowT, tileID = tile.ID, tile = tile };
		}
	}

	// Set pending impact spec FIRST so hit/miss reactions & climax VFX always align cleanly!
	local impactSpec = {
		animID        = animID,
		mode          = mode,
		qiAura        = qiAura,
		sigFx         = sigFx,
		volleys       = volleys,
		shakePow      = shakePow,
		isRanged      = isRangedWpnSkill,
		playedPrimary = false
	};
	if (isAttackSkill && _skill != null && ("m" in _skill))
	{
		_skill.m.WX_PendingImpactVfx <- impactSpec;
	}

	// Drive 60 FPS articulated caster motion (pullback -> lunge/leap/spin/blink/levitation -> return)
	if (_user != null && ::Wuxia.VFX.isMotionEnabled())
	{
		if (!isQinggongMode || isQinggongLanding)
			::Wuxia.VFX.startCasterMotion(_user, mode, dir, isQinggongLanding);
	}

	if (!::Wuxia.VFX.isVfxEnabled())
		return;

	try
	{
		// 0. SMOOTH ORIGIN QI-WINDUP (glides outward along attack vector from caster's stance)
		if (_user != null && originTile != null && tile.ID != originTile.ID)
		{
			::Wuxia.VFX.spawnDynamicAt(originTile, animID + "_f1", 0, 0.14, 0.96, dir.X * 65.0, dir.Y * 65.0, 0, 1, 0, 0, flipX, -dir.X * 10.0, -dir.Y * 10.0, 185, 0.06, 0.15);
		}
		if (originTile != null && (mode == "backstab" || mode == "night_exec" || mode.find("shadow_") == 0))
		{
			::Wuxia.VFX.spawnDynamicAt(originTile, "wx_vfx_25", 0, 0.22, 1.10, dir.X * 70.0, dir.Y * 70.0, 90, 1, 0, 0, flipX, 0, 0, 185, 0.06, 0.18);
		}

		// 1. VOLLEY / SWORD-QI / DRAGON / FINGER-BEAM / SIPHON / HOOK TRAJECTORIES
		if (volleys > 0 && originTile != null && tile.ID != originTile.ID && ("spawnProjectileEffect" in ::Tactical))
		{
			local projBrush = sigFx;
			local projRot = true;
			if (isRangedWpnSkill && ("Projectiles" in ::Wuxia) && ("getVfxVolleySpec" in ::Wuxia.Projectiles))
			{
				local vSpec = ::Wuxia.Projectiles.getVfxVolleySpec(_skill, _user, sigFx);
				projBrush = vSpec.Brush;
				projRot = vSpec.IsRotated;
			}
			local cappedVolleys = ::Math.min(3, volleys);

			if (mode == "blood_siphon" || mode == "black_hole" || mode == "vacuum_pull" || mode == "hook_pull")
			{
				::Tactical.spawnProjectileEffect(sigFx, originTile, tile, 1.45, 0.92, true, false);
			}
			else if (mode == "star_rain")
			{
				local skyTile = ::Wuxia.VFX.getSkyTileAbove(tile, 2);
				for (local v = 0; v < cappedVolleys; v = ++v)
				{
					if (skyTile != null && skyTile.ID != tile.ID)
						::Tactical.spawnProjectileEffect("wx_fx_sword_phantom", skyTile, tile, 1.35 + v * 0.18, 0.96, true, false);
				}
			}
			else
			{
				local baseSpd = (mode == "sun_laser" || mode == "flying_虹" || mode == "sonic_arrow" || mode == "heavy_bolt") ? 1.95 : 1.25;
				local pScale = (mode == "dragon_coil") ? 1.18 : 0.92;
				for (local v2 = 0; v2 < cappedVolleys; v2 = ++v2)
				{
					::Tactical.spawnProjectileEffect(projBrush, originTile, tile, baseSpd + v2 * 0.16, pScale, projRot, false);
				}
			}
		}

		if (!isAttackSkill)
		{
			if (isQinggongMode && !isQinggongLanding)
			{
				// Takeoff burst only (landing climax fires on second call at destination hex!)
				::Wuxia.VFX.spawnDynamicAt(tile, qiAura, 0, 0.22, 1.10, 0, 65, 110, 1, 0, 0, flipX, 0, 0, 195, 0.06, 0.18);
				::Wuxia.VFX.spawnDynamicAt(tile, sigFx, 35, 0.20, 1.06, 0, 20, 140, 1, 0, 0, flipX, 0, 0, 185, 0.06, 0.18);
			}
			else
			{
				::Wuxia.VFX.playTargetImpactVfx(_skill, _user, originTile, tile, impactSpec);
			}
		}
	}
	catch (_err)
	{
		::Wuxia.VFX.logOnce("playSkillVfx:" + animID, _err);
	}
};

// Swift translucent glancing sweep when a dedicated Wuxia active attack misses (dodge)
::Wuxia.VFX.playTargetMissVfx <- function( _skill, _user, _originTile, _tile, _spec )
{
	if (!::Wuxia.VFX.isVfxEnabled()) return;
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive() || _tile == null || _spec == null) return;
	if (!_tile.IsVisibleForPlayer) return;
	try
	{
		local dir = ::Wuxia.VFX.getDirVec(_originTile, _tile, _user);
		local flipX = ::Wuxia.VFX.shouldFlipLeft(dir, _user);
		local d0 = (_spec.isRanged) ? 145 : (::Wuxia.VFX.isMotionEnabled() ? 85 : 25);
		::Wuxia.VFX.spawnDynamicAt(_tile, _spec.animID + "_f2", d0,      0.14, 1.02, dir.X * 85.0, dir.Y * 85.0, 0, 1, 0, 0, flipX, -dir.X * 14.0, -dir.Y * 14.0, 175, 0.06, 0.15);
		::Wuxia.VFX.spawnDynamicAt(_tile, _spec.qiAura,         d0 + 50, 0.16, 0.98, dir.X * 72.0, dir.Y * 72.0, 0, 1, 0, 0, flipX, 0.0, 0.0, 165, 0.06, 0.16);
	}
	catch (_err)
	{
		::Wuxia.VFX.logOnce("playTargetMissVfx:" + _spec.animID, _err);
	}
};

::Wuxia.VFX.playTargetImpactVfx <- function( _skill, _user, _originTile, _tile, _spec )
{
	if (!::Wuxia.VFX.isVfxEnabled()) return;
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive() || _tile == null || _spec == null) return;

	local originTile = _originTile;
	local tile       = _tile;
	local animID     = _spec.animID;
	local mode       = _spec.mode;
	local qiAura     = _spec.qiAura;
	local sigFx      = _spec.sigFx;
	local volleys    = _spec.volleys;
	local shakePow   = _spec.shakePow;
	local isAttack   = (_skill != null && ::Wuxia.hasMember(_skill, "isAttack") && _skill.isAttack());
	local motionPad  = (isAttack && ::Wuxia.VFX.isMotionEnabled()) ? 95 : 0;
	local d0         = ("isRanged" in _spec && _spec.isRanged) ? 165 : motionPad;
	local dir        = ::Wuxia.VFX.getDirVec(originTile, tile, _user);
	local flipX      = ::Wuxia.VFX.shouldFlipLeft(dir, _user);

	try
	{
		if (!_spec.playedPrimary && originTile != null && tile.ID != originTile.ID && ("spawnProjectileEffect" in ::Tactical))
		{
			if (mode == "blood_siphon" || mode == "black_hole" || mode == "vacuum_pull" || mode == "hook_pull")
			{
				local pullBrush = (mode == "black_hole") ? "wx_vfx_19" : (mode == "blood_siphon" ? "wx_fx_blood_orb" : sigFx);
				local sCnt = ::Math.min(2, volleys);
				for (local s = 0; s < sCnt; s = ++s)
				{
					::Tactical.spawnProjectileEffect(pullBrush, tile, originTile, 1.12 + s * 0.18, 0.90, false, false);
				}
				::Wuxia.VFX.spawnDynamicAt(originTile, qiAura, d0 + 180, 0.24, 1.12, 0, 32, 130, 1, 0, 0, flipX, 0, 0, 200, 0.08, 0.19);
			}
			else if (mode == "star_rain")
			{
				local vCnt = ::Math.min(3, volleys);
				for (local v = 0; v < vCnt; v = ++v)
				{
					::Wuxia.VFX.spawnDynamicAt(tile, "wx_vfx_08", d0 + 25 + v * 55, 0.18, 1.10, -24, -145, 0, 1, 0, 0, flipX, (v - 1) * 14.0, 36.0, 205, 0.06, 0.16);
				}
			}
		}
		_spec.playedPrimary = true;

		// 2. BESPOKE SMOOTHLY-FADED TACTICAL ACTION PATTERNS (Zero Raw Stickers, Native +Y=Up!)
		if (mode == "sky_thunder" || mode == "buddha_palm" || mode == "giant_axe" || mode == "leap_cleave" || mode == "gravity_cut" || mode == "shield_split" || mode.find("sky_") == 0)
		{
			local skyT = ::Wuxia.VFX.getSkyTileAbove(tile, 2);
			if (skyT != null && skyT.ID != tile.ID && ("spawnProjectileEffect" in ::Tactical) && (mode == "sky_thunder" || mode == "buddha_palm" || mode == "giant_axe"))
				::Tactical.spawnProjectileEffect(sigFx, skyT, tile, 1.75, 1.18, false, false);
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f2", d0 + 15,  0.15, 1.14, 0, -135, 0, 1, 0, 0, flipX, 0, 34, 205, 0.06, 0.15);
			::Wuxia.VFX.spawnDynamicAt(tile, qiAura,         d0 + 85,  0.24, 1.24, 0, 12,   0, 1, 0, 0, flipX, 0, 0,  218, 0.08, 0.22);
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f3", d0 + 115, 0.22, 1.24, 0, 8,    0, 1, 0, 0, flipX, 0, 0,  222, 0.08, 0.22);
			::Wuxia.VFX.spawnDynamicAt(tile, sigFx,          d0 + 150, 0.24, 1.20, 0, mode == "sky_thunder" ? -65 : 22, 0, 1, 0, 0, flipX, 0, mode == "sky_thunder" ? 22 : -4, 205, 0.07, 0.22);
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f4", d0 + 235, 0.20, 1.12, 0, 24,   0, 1, 0, 0, flipX, 0, 4,  175, 0.07, 0.20);
		}
		else if (mode == "earth_wave" || mode.find("earth_") == 0)
		{
			::Wuxia.VFX.spawnFlipbookAt(tile, animID, d0, 1.08, flipX, dir);
			::Wuxia.VFX.spawnDynamicAt(tile, qiAura, d0 + 95,  0.24, 1.22, 0, 28, 0, 1, 0, 0, flipX, 0, -4, 215, 0.08, 0.22);
			::Wuxia.VFX.spawnDynamicAt(tile, sigFx,  d0 + 130, 0.24, 1.20, 0, 38, 0, 1, 0, 0, flipX, 0, -6, 205, 0.08, 0.22);
			local eStep = 0;
			for (local dirIdx = 0; dirIdx < ::Const.Direction.COUNT; dirIdx = ++dirIdx)
			{
				if (!tile.hasNextTile(dirIdx)) continue;
				local adjE = tile.getNextTile(dirIdx);
				if (!adjE.IsOccupiedByActor || (_user != null && _user.isAlliedWith(adjE.getEntity()))) continue;
				::Wuxia.VFX.spawnDynamicAt(adjE, sigFx,  d0 + 155 + eStep * 45, 0.20, 1.04, 0, 32, 0, 1, 0, 0, flipX, 0, -4, 195, 0.07, 0.20);
				if (!::Wuxia.VFX.isMotionEnabled())
					::Wuxia.VFX.shakeEntityFrom(adjE.getEntity(), tile, 6);
				eStep += 1;
				if (eStep >= 3) break;
			}
		}
		else if (mode == "cloud_jump" || mode == "mirage_step" || mode.find("step_") == 0)
		{
			// Graceful landing swirl + dissolving Bagua / afterimage echo
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f3", 20,  0.18, 1.12, 0, 18,  90, 1, 0, 0, flipX, 0, 6, 205, 0.07, 0.18);
			::Wuxia.VFX.spawnDynamicAt(tile, qiAura,         65,  0.24, 1.16, 0, 24, -120, 1, 0, 0, flipX, 0, 0, 200, 0.08, 0.22);
			::Wuxia.VFX.spawnDynamicAt(tile, sigFx,          105, 0.24, 1.12, 0, 14,  150, 1, 0, 0, flipX, 0, -4, 190, 0.08, 0.22);
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f4", 170, 0.18, 1.06, 0, 28,  0,   1, 0, 0, flipX, 0, 4, 170, 0.07, 0.18);
		}
		else if (mode == "backstab" || mode == "night_exec" || mode.find("shadow_") == 0)
		{
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f2", d0 + 10,  0.15, 1.10, dir.X * 65.0, dir.Y * 65.0, 0, 1, 0, 0, flipX, -dir.X * 16.0, -dir.Y * 16.0, 200, 0.06, 0.15);
			::Wuxia.VFX.spawnDynamicAt(tile, qiAura,         d0 + 60,  0.22, 1.18, dir.X * 30.0, dir.Y * 30.0, 0, 1, 0, 0, flipX, 0, 0, 215, 0.07, 0.20);
			::Wuxia.VFX.spawnDynamicAt(tile, sigFx,          d0 + 95,  0.22, 1.16, 0, 14, 0, 1, 0, 0, flipX, 0, 0, 210, 0.07, 0.20);
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f3", d0 + 120, 0.20, 1.18, 0, 10, 0, 1, 0, 0, flipX, 0, 0, 218, 0.07, 0.20);
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f4", d0 + 210, 0.18, 1.08, 0, 28, 0, 1, 0, 0, flipX, 0, 6, 170, 0.07, 0.18);
		}
		else if (mode == "counter" || mode == "spear_wall" || mode == "hex_fortress" || mode == "golden_bell" || mode == "lotus_breath" || mode == "poise_draw" || mode == "blood_flame" || mode.find("stance_") == 0)
		{
			local hostTile = originTile != null ? originTile : tile;
			local liftVy = (mode == "blood_flame" || mode == "poise_draw" || mode == "lotus_breath") ? 46 : 16;
			local spinTq = (mode == "counter" || mode == "lotus_breath" || mode.find("stance_") == 0) ? 130 : 0;
			::Wuxia.VFX.spawnDynamicAt(hostTile, animID + "_f1", 0,   0.16, 1.04, 0, liftVy * 0.5, 0, 1, 0, 0, false, 0, -4, 185, 0.08, 0.16);
			::Wuxia.VFX.spawnDynamicAt(hostTile, qiAura,         55,  0.28, 1.22, 0, liftVy, spinTq, 1, 0, 0, false, 0, 0, 210, 0.10, 0.24);
			::Wuxia.VFX.spawnDynamicAt(hostTile, animID + "_f3", 130, 0.22, 1.18, 0, liftVy * 0.4, 0, 1, 0, 0, false, 0, 2, 215, 0.08, 0.22);
			::Wuxia.VFX.spawnDynamicAt(hostTile, sigFx,          175, 0.26, 1.20, 0, 12, -spinTq, 1, 0, 0, false, 0, 0, 195, 0.09, 0.24);
			::Wuxia.VFX.spawnDynamicAt(hostTile, animID + "_f4", 265, 0.20, 1.10, 0, 24, 0, 1, 0, 0, false, 0, 6, 170, 0.08, 0.20);
		}
		else if (mode == "lion_roar" || mode == "taunt_slam" || mode == "war_banner" || mode == "tidal_sweep" || mode == "cyclone_pole" || mode == "berserk_spin" || mode.find("aoe_") == 0)
		{
			local center = (mode == "lion_roar" || mode == "taunt_slam" || mode == "war_banner")
				? (originTile != null ? originTile : tile)
				: tile;
			local isSpin = (mode == "tidal_sweep" || mode == "cyclone_pole" || mode == "berserk_spin");
			::Wuxia.VFX.spawnFlipbookAt(center, animID, d0, 1.08, flipX, isSpin ? null : dir);
			::Wuxia.VFX.spawnDynamicAt(center, qiAura, d0 + 45,  0.26, 1.26, 0, isSpin ? 8 : 26, isSpin ? 240 : 0, 1, 0, 0, flipX, 0, 0, 212, 0.08, 0.22);
			::Wuxia.VFX.spawnDynamicAt(center, sigFx,  d0 + 115, 0.26, 1.20, 0, mode == "war_banner" ? 38 : 10, isSpin ? -200 : 0, 1, 0, 0, flipX, 0, 0, 200, 0.08, 0.22);

			local rStep = 0;
			for (local d = 0; d < ::Const.Direction.COUNT; d = ++d)
			{
				if (!center.hasNextTile(d)) continue;
				local adj = center.getNextTile(d);
				local adjDir = ::Wuxia.VFX.getDirVec(center, adj);
				if (mode == "war_banner")
				{
					if (adj.IsOccupiedByActor && _user != null && _user.isAlliedWith(adj.getEntity()))
						::Wuxia.VFX.spawnDynamicAt(adj, "wx_vfx_24", d0 + 80 + rStep * 35, 0.24, 1.06, 0, 28, 0, 1, 0, 0, false, 0, 0, 195, 0.08, 0.20);
				}
				else if (adj.IsOccupiedByActor || (rStep % 2 == 0))
				{
					::Wuxia.VFX.spawnDynamicAt(adj, isSpin ? qiAura : sigFx, d0 + 75 + rStep * 32, 0.20, 1.00, adjDir.X * 52.0, adjDir.Y * 52.0, isSpin ? 180 : 0, 1, 0, 0, false, 0, 0, 185, 0.07, 0.18);
					if (adj.IsOccupiedByActor && _user != null && !_user.isAlliedWith(adj.getEntity()) && !::Wuxia.VFX.isMotionEnabled())
						::Wuxia.VFX.shakeEntityFrom(adj.getEntity(), center, shakePow);
				}
				rStep += 1;
			}
		}
		else if (mode == "combo3" || mode == "clone3" || mode == "omnislash6" || mode == "rapid_jab" || mode == "prism5_hit" || mode == "phoenix9" || mode == "petal_storm" || mode == "silver_tiger_spear" || mode.find("flurry_") == 0)
		{
			local strikes = (mode == "omnislash6") ? 3 : (mode == "rapid_jab" ? 2 : 3);
			for (local k = 0; k < strikes; k = ++k)
			{
				local side = (k % 2 == 0) ? 1.0 : -1.0;
				local fKey = animID + "_f" + ((k % 3) + 2);
				::Wuxia.VFX.spawnDynamicAt(tile, fKey,   d0 + k * 75,      0.14, 1.06 + k * 0.05, dir.X * 60.0 + side * 24.0, dir.Y * 60.0 + side * 18.0, side * 140, 1, 0, 0, flipX, -dir.X * 12.0 + side * 6.0, -dir.Y * 12.0, 200, 0.06, 0.15);
				::Wuxia.VFX.spawnDynamicAt(tile, qiAura, d0 + 35 + k * 75, 0.16, 1.10,            -side * 24.0, side * 20.0, -side * 120, 1, 0, 0, flipX, side * 5.0, 0.0, 195, 0.06, 0.16);
			}
			::Wuxia.VFX.spawnDynamicAt(tile, sigFx,          d0 + strikes * 70,      0.22, 1.18, 0, 12, 0, 1, 0, 0, flipX, 0, 0, 212, 0.07, 0.20);
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f4", d0 + strikes * 70 + 80, 0.18, 1.10, dir.X * 26.0, dir.Y * 26.0 + 18.0, 0, 1, 0, 0, flipX, 0, 4, 175, 0.07, 0.18);
		}
		else if (mode == "taiji_field" || mode == "taiji_orb" || mode == "disarm_arc" || mode == "disarm_grab" || mode.find("taiji_") == 0)
		{
			::Wuxia.VFX.spawnFlipbookAt(tile, animID, d0, 1.04, flipX, dir);
			local isDisarm = (mode == "disarm_arc" || mode == "disarm_grab");
			::Wuxia.VFX.spawnDynamicAt(tile, qiAura, d0 + 60,  0.24, 1.18, dir.X * 38.0, dir.Y * 38.0, 190, 1, 0, 0, flipX, 0, 0, 208, 0.08, 0.22);
			// Disarm launches a spinning weapon phantom skyward (+Y = Up, gravity -Y = Down!)
			::Wuxia.VFX.spawnDynamicAt(tile, sigFx,  d0 + 115, 0.26, isDisarm ? 1.08 : 1.20, isDisarm ? 38.0 : 0.0, isDisarm ? 145.0 : 8.0, isDisarm ? 260 : -160, 1, 0, isDisarm ? -210 : 0, flipX, 0, 0, 205, 0.07, 0.22);
		}
		else if (mode == "modao_upcut" || mode == "dragon_up" || mode == "fire_pillar" || mode == "taiyuan_flame" || mode == "toad_leap_slam" || mode == "frost_tomb" || mode.find("upcut_") == 0)
		{
			::Wuxia.VFX.spawnFlipbookAt(tile, animID, d0, 1.08, flipX, dir);
			::Wuxia.VFX.spawnDynamicAt(tile, qiAura, d0 + 65,  0.24, 1.20, dir.X * 36.0, 92.0, 0, 1, 0, 0, flipX, 0, -6, 215, 0.08, 0.22);
			::Wuxia.VFX.spawnDynamicAt(tile, sigFx,  d0 + 120, 0.24, 1.20, 0, 78.0, 0, 1, 0, 0, flipX, 0, -4, 205, 0.08, 0.22);
			if (mode == "frost_tomb")
				::Wuxia.VFX.spawnDynamicAt(tile, "wx_vfx_21", d0 + 155, 0.24, 1.16, 0, 14, 90, 1, 0, 0, false, 0, 0, 200, 0.08, 0.22);
		}
		else if (mode == "over_shield" || mode == "neck_coil" || mode == "viper_whip" || mode == "bamboo_bind" || mode.find("whip_") == 0)
		{
			::Wuxia.VFX.spawnFlipbookAt(tile, animID, d0, 1.04, flipX, dir);
			::Wuxia.VFX.spawnDynamicAt(tile, qiAura, d0 + 65,  0.22, 1.18, dir.X * 52.0, mode == "over_shield" ? 55.0 : 10.0, 160, 1, 0, 0, flipX, 0, 0, 210, 0.08, 0.20);
			::Wuxia.VFX.spawnDynamicAt(tile, sigFx,  d0 + 120, 0.22, 1.16, 0, 12, -160, 1, 0, 0, flipX, 0, 0, 200, 0.08, 0.20);
			if (mode == "viper_whip")
				::Wuxia.VFX.spawnDynamicAt(tile, "wx_vfx_28", d0 + 165, 0.22, 1.08, 0, 32, 0, 1, 0, 0, false, 0, 0, 195, 0.07, 0.20);
		}
		else
		{
			::Wuxia.VFX.spawnFlipbookAt(tile, animID, d0, shakePow >= 7 ? 1.10 : 1.02, flipX, dir);

			local pushVx = (mode == "drill_lunge" || mode == "inch_pulse" || mode == "shield_ram" || mode == "dragon_coil") ? (dir.X * 85.0) : (dir.X * 36.0);
			local pushVy = (mode == "drill_lunge" || mode == "inch_pulse" || mode == "shield_ram" || mode == "dragon_coil") ? (dir.Y * 85.0) : (dir.Y * 36.0);
			local spin   = (mode == "spiral_stab") ? 220 : ((mode == "acupoint" || mode == "lotus_poke") ? 130 : 0);

			::Wuxia.VFX.spawnDynamicAt(tile, qiAura, d0 + 80,  0.24, 1.20, pushVx, pushVy, spin, 1, 0, 0, flipX, -dir.X * 8.0, -dir.Y * 8.0, 218, 0.08, 0.22);
			::Wuxia.VFX.spawnDynamicAt(tile, sigFx,  d0 + 130, 0.24, 1.18, 0, mode == "heal_needles" || mode == "smoke_screen" ? 38.0 : 10.0, -spin * 0.5, 1, 0, 0, flipX, 0, 0, 205, 0.08, 0.22);
		}

		// Soft directional impact shimmer (replaces hard non-fading `spawnAttackEffect` raw sticker!)
		if (tile.IsOccupiedByActor && originTile != null && originTile.ID != tile.ID && shakePow >= 6 && !::Wuxia.VFX.isMotionEnabled())
		{
			::Wuxia.VFX.shakeEntityFrom(tile.getEntity(), originTile, ::Math.min(7, shakePow));
		}
	}
	catch (_err)
	{
		::Wuxia.VFX.logOnce("playTargetImpactVfx:" + animID, _err);
	}
};

// Resolves authentic Wuxia Qi-Aura (`wx_vfx_01..32`) for martial practitioners & Relic Weapon wielders
::Wuxia.VFX.resolvePractitionerWeaponVfx <- function( _skill, _user )
{
	if (_skill == null || _user == null || !(::Wuxia.hasMember(_user, "getItems")) || _user.getItems() == null)
		return null;

	local mainW = _user.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
	local wID = (mainW != null && (::Wuxia.hasMember(mainW, "getID")) && mainW.getID() != null) ? mainW.getID() : "";
	local isRelicOrFist = (wID.find("weapon.wx_relic_") == 0 || wID.find("weapon.wx_fist") == 0 || wID.find("weapon.wx_named_fist") == 0);

	local c = (::Wuxia.hasMember(_user, "getSkills") && _user.getSkills() != null) ? _user.getSkills().getSkillByID("special.wx_martial_container") : null;
	local practicedCount = 0;
	local elem = "";
	if (c != null && ("m" in c) && (::Wuxia.hasMember(c.m, "Slots")))
	{
		for (local i = 0; i < c.m.Slots.len(); i = ++i)
		{
			local sl = c.m.Slots[i];
			if (sl != null && sl.ManualID != null && sl.Tier > 0)
			{
				practicedCount += 1;
				if (i == 0)
				{
					local mdef = ::Wuxia.Slots.getManualDef(sl.ManualID);
					if (mdef != null && mdef.Element != null) elem = mdef.Element;
				}
			}
		}
	}

	if (!isRelicOrFist && practicedCount <= 0)
		return null;

	local skID = (::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null) ? _skill.getID() : "";
	local apCost = (::Wuxia.hasMember(_skill.m, "ActionPointCost")) ? _skill.m.ActionPointCost : 4;
	local isAoE = ((::Wuxia.hasMember(_skill.m, "IsAOE") && _skill.m.IsAOE) || skID.find("swing") != null || skID.find("thresh") != null || skID.find("reap") != null);
	local isHeavy = (apCost >= 6 || skID.find("smite") != null || skID.find("split") != null || skID.find("crush") != null);

	if (mainW == null) return null;
	if (::Wuxia.CombatRules.matchesWeapon(mainW, ["Fist"]))
		return elem == "yin" ? "wx_vfx_10" : (elem == "evil" ? "wx_vfx_13" : (isHeavy ? "wx_vfx_11" : "wx_vfx_09"));
	if (::Wuxia.CombatRules.matchesWeapon(mainW, ["Sword"]))
	{
		if (skID.find("lunge") != null) return "wx_vfx_03";
		if (skID.find("riposte") != null) return "wx_vfx_15";
		if (isAoE) return elem == "yin" ? "wx_vfx_21" : "wx_vfx_06";
		if (isHeavy) return "wx_vfx_05";
		return elem == "evil" ? "wx_vfx_04" : (elem == "yang" ? "wx_vfx_02" : "wx_vfx_01");
	}
	if (::Wuxia.CombatRules.matchesWeapon(mainW, ["Cleaver", "Saber"]))
	{
		if (isAoE) return "wx_vfx_06";
		return elem == "yin" ? "wx_vfx_21" : (elem == "evil" ? "wx_vfx_06" : "wx_vfx_02");
	}
	if (::Wuxia.CombatRules.matchesWeapon(mainW, ["Spear", "Polearm"]))
		return isAoE ? "wx_vfx_06" : (skID.find("hook") != null ? "wx_vfx_31" : "wx_vfx_03");
	if (::Wuxia.CombatRules.matchesWeapon(mainW, ["Staff"]))
		return isHeavy ? "wx_vfx_14" : "wx_vfx_15";
	if (::Wuxia.CombatRules.matchesWeapon(mainW, ["Hammer"]))
		return isAoE || isHeavy ? "wx_vfx_05" : "wx_vfx_14";
	if (::Wuxia.CombatRules.matchesWeapon(mainW, ["Axe"]))
		return isAoE ? "wx_vfx_06" : (isHeavy ? "wx_vfx_05" : "wx_vfx_02");
	if (::Wuxia.CombatRules.matchesWeapon(mainW, ["Flail"]))
		return isAoE ? "wx_vfx_31" : "wx_vfx_32";
	if (::Wuxia.CombatRules.matchesWeapon(mainW, ["Dagger"]))
		return (skID.find("puncture") != null || skID.find("deathblow") != null) ? "wx_vfx_07" : "wx_vfx_04";
	if (::Wuxia.CombatRules.matchesWeapon(mainW, ["Firearm"]))
		return "wx_vfx_29";
	if (::Wuxia.CombatRules.matchesWeapon(mainW, ["Throwing"]))
		return elem == "evil" ? "wx_vfx_28" : "wx_vfx_27";
	if (::Wuxia.CombatRules.matchesWeapon(mainW, ["Bow", "Crossbow"]))
		return elem == "yang" ? "wx_vfx_02" : "wx_vfx_03";

	return "wx_vfx_01";
};

::Wuxia.VFX.isShanHaiCreature <- function( _actor )
{
	if (_actor == null || !("m" in _actor) || _actor.m == null) return false;
	if (("WX_BossID" in _actor.m) && _actor.m.WX_BossID != null) return true;
	if (("WX_CustomEnemyBust" in _actor.m) && _actor.m.WX_CustomEnemyBust != null)
	{
		local b = _actor.m.WX_CustomEnemyBust;
		if (b.find("wx_boss_") == 0 || b.find("wx_beast_") == 0 || b.find("wx_tail_") == 0)
			return true;
	}
	return false;
};

// Maps every Shan Hai Boss (`wx_boss_*`) & Wild/Spawn Shan Hai Beast (`wx_beast_*`, `wx_tail_*`) natural attack/spell
// to authentic 60fps Actor Motion + Qi-Aura (`wx_vfx_*`) + Signature FX (`wx_fx_*`) choreography!
::Wuxia.VFX.resolveShanHaiChoreo <- function( _skill, _user )
{
	if (!::Wuxia.VFX.isShanHaiCreature(_user)) return null;
	local skID = (_skill != null && ::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null) ? _skill.getID() : "";
	if (skID.find("actives.wx_") == 0) return null; // Dedicated Wuxia active skills already have full SkillChoreo

	local isBoss = ("WX_BossID" in _user.m) && _user.m.WX_BossID != null;
	local key = isBoss ? _user.m.WX_BossID : (("WX_CustomEnemyBust" in _user.m && _user.m.WX_CustomEnemyBust != null) ? _user.m.WX_CustomEnemyBust : "");
	if (key.find("boss_") == 0) key = key.slice(5);
	else if (key.find("wx_boss_") == 0) key = key.slice(8);
	else if (key.find("wx_beast_") == 0) key = key.slice(9);
	else if (key.find("wx_tail_") == 0) key = key.slice(8);

	// 1. Default motion & FX by creature's elemental/mythic lineage
	local mKind = "lunge_pierce";
	local aura  = "wx_vfx_13";
	local sig   = "wx_fx_claw_slash";
	local scale = isBoss ? 1.24 : 1.08;
	local shake = isBoss ? 7 : 5;

	if (key == "jinwu" || key == "bifang" || key == "huodou" || key == "feiyi" || key == "feiyi_wild"
		|| key == "yuanchu" || key == "nvchou" || key == "kuafu" || key == "jiufeng" || key == "denglin")
	{
		mKind = "upcut_launch"; aura = "wx_vfx_02"; sig = "wx_fx_earth_fissure";
	}
	else if (key == "zhuyin" || key == "bingyi" || key == "gonggong" || key == "wuzhiqi" || key == "changyou"
		|| key == "fuzhu" || key == "huashe" || key == "yinglong" || key == "chenghuang" || key == "liangqu" || key == "ranyi")
	{
		mKind = "upcut_launch"; aura = "wx_vfx_10"; sig = "wx_fx_ice_spikes";
	}
	else if (key == "kui" || key == "qiangliang" || key == "liuzhe" || key == "leishou" || key == "aohen")
	{
		mKind = "sky_slam"; aura = "wx_vfx_14"; sig = "wx_fx_thunder_bolt";
	}
	else if (key == "qinyuan" || key == "bashe" || key == "bashe_wild" || key == "xiangliuwang" || key == "xiangliu"
		|| key == "xiangliu_chu" || key == "jiuying" || key == "fei" || key == "mingshe" || key == "hujiao"
		|| key == "shebishi" || key == "chizhu" || key == "xuanfeng" || key == "ziyu" || key == "feichong" || key == "jiaochong")
	{
		mKind = "lunge_pierce"; aura = "wx_vfx_28"; sig = "wx_fx_poison_skull";
	}
	else if (key == "jiuwei" || key == "jiuwei_wild" || key == "wuluo" || key == "dijiang" || key == "hundun"
		|| key == "erfu" || key == "jingwei" || key == "eshou" || key == "chiru" || key == "gengfu" || key == "huan")
	{
		mKind = "taiji_deflect"; aura = "wx_vfx_30"; sig = "wx_fx_lotus_seal";
	}
	else if (key == "xingtian" || key == "chiyou" || key == "zaochi" || key == "yingzhao" || key == "taowu" || key == "qiongqi")
	{
		mKind = "cyclone_spin"; aura = "wx_vfx_06"; sig = "wx_fx_claw_slash";
	}
	else if (key == "xuangui" || key == "jumang" || key == "luwu" || key == "baize" || key == "kaiming"
		|| key == "fangfeng" || key == "jianmu" || key == "jianmu_ling" || key == "zhuyan" || key == "zhuyan_wild")
	{
		mKind = "sky_slam"; aura = "wx_vfx_05"; sig = "wx_fx_earth_fissure";
	}
	else if (key == "taotie" || key == "paoxiaowang" || key == "paoxiao" || key == "yayu" || key == "zhuhuai" || key == "dangkang")
	{
		mKind = "upcut_launch"; aura = "wx_vfx_06"; sig = "wx_fx_blood_orb";
	}
	else if (key == "tiangouwang" || key == "tiangou" || key == "mengji" || key == "gudiaowang" || key == "gudiao"
		|| key == "zheng" || key == "zouyu" || key == "jiao" || key == "shanhui" || key == "bo")
	{
		mKind = "flurry_blitz"; aura = "wx_vfx_13"; sig = "wx_fx_claw_slash";
	}

	// 2. Refine motion & signature FX by exact vanilla monster skill ID!
	if (skID.find("fling") != null || skID.find("sweep") != null || skID.find("tail_slam") != null || skID.find("round_swing") != null || skID.find("thresh") != null)
	{
		mKind = "cyclone_spin";
		sig = "wx_fx_sonic_ring";
		shake = ::Math.max(shake, 8);
	}
	else if (skID.find("crush") != null || skID.find("uproot") != null || skID.find("smite") != null || skID.find("split") != null)
	{
		mKind = "sky_slam";
		sig = (aura == "wx_vfx_14") ? "wx_fx_thunder_bolt" : "wx_fx_earth_fissure";
		shake = ::Math.max(shake, 8);
	}
	else if (skID.find("drag") != null || skID.find("hook") != null || skID.find("ensnare") != null || skID.find("kraken_move") != null)
	{
		mKind = "pull_grapple";
		aura = "wx_vfx_31";
		sig = "wx_fx_whip_arc";
	}
	else if (skID.find("web") != null || skID.find("poison") != null || skID.find("spider_bite") != null)
	{
		mKind = (skID.find("web") != null) ? "ranged_release" : "lunge_pierce";
		aura = "wx_vfx_28";
		sig = "wx_fx_poison_skull";
	}
	else if (skID.find("charm") != null || skID.find("hex") != null || skID.find("nightmare") != null || skID.find("sleep") != null || skID.find("ghastly") != null || skID.find("horrify") != null)
	{
		mKind = "stance_meditate";
		aura = (skID.find("charm") != null || skID.find("hex") != null) ? "wx_vfx_04" : "wx_vfx_30";
		sig = (skID.find("charm") != null || skID.find("hex") != null) ? "wx_fx_lotus_seal" : "wx_fx_bagua";
	}
	else if (skID.find("gorge") != null || skID.find("swallow") != null || skID.find("feast") != null || skID.find("kraken_bite") != null)
	{
		mKind = "upcut_launch";
		aura = (aura == "wx_vfx_10" || aura == "wx_vfx_28") ? aura : "wx_vfx_06";
		sig = "wx_fx_blood_orb";
	}
	else if (skID.find("werewolf") != null || skID.find("hyena") != null || skID.find("ghoul_claws") != null)
	{
		mKind = "flurry_blitz";
	}
	else if (skID.find("darkflight") != null)
	{
		mKind = "shadow_blink";
		aura = "wx_vfx_25";
	}
	else if (skID.find("shield") != null || skID.find("warcry") != null || skID.find("bark") != null)
	{
		mKind = "stance_meditate";
		aura = "wx_vfx_17";
		sig = "wx_fx_golden_bell";
	}
	else if (skID.find("charge") != null)
	{
		mKind = "lunge_pierce";
		shake = ::Math.max(shake, 8);
	}

	return {
		kind  = mKind,
		aura  = aura,
		sig   = sig,
		scale = scale,
		shake = shake,
		isBoss = isBoss
	};
};

::Wuxia.VFX.playShanHaiUseVfx <- function( _skill, _user, _targetTile )
{
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
	if (_skill == null || !::Wuxia.isOnMap(_user)) return;
	local spec = ::Wuxia.VFX.resolveShanHaiChoreo(_skill, _user);
	if (spec == null) return;

	local originTile = _user.getTile();
	local tile = _targetTile != null ? _targetTile : originTile;
	if (tile == null) return;
	if (!tile.IsVisibleForPlayer && (originTile == null || !originTile.IsVisibleForPlayer)) return;

	local dir = ::Wuxia.VFX.getDirVec(originTile, tile, _user);
	local flipX = ::Wuxia.VFX.shouldFlipLeft(dir, _user);

	if (::Wuxia.VFX.isMotionEnabled())
	{
		local dur = (spec.kind == "sky_slam" || spec.kind == "cyclone_spin") ? 0.50 : 0.42;
		::Wuxia.VFX.startActorMotion(_user, spec.kind, dir, dur, 0.0, spec.aura);
		if ("getShaker" in ::Tactical && ::Tactical.getShaker() != null && ("cancel" in ::Tactical.getShaker()))
		{
			try { ::Tactical.getShaker().cancel(_user); } catch (_e) {}
		}
	}

	// Non-attack monster spells (web, charm, hex, sleep, feast, warcry, shield, uproot self-cast, darkflight)
	// emit immediate cast + target VFX directly from `use` since `attackEntity` is not invoked!
	local isAtk = (::Wuxia.hasMember(_skill, "isAttack") && _skill.isAttack());
	if (!isAtk && ::Wuxia.VFX.isVfxEnabled())
	{
		try
		{
			if (originTile != null && originTile.IsVisibleForPlayer)
				::Wuxia.VFX.spawnDynamicAt(originTile, spec.aura, 0, 0.24, spec.scale * 0.95, 0, 18, 95, 1, 0, 0, flipX, 0, 0, 200, 0.07, 0.20);
			if (tile != null && tile.IsVisibleForPlayer && (originTile == null || tile.ID != originTile.ID))
			{
				::Wuxia.VFX.spawnDynamicAt(tile, spec.aura, 70, 0.28, spec.scale, dir.X * 24.0, dir.Y * 24.0, -110, 1, 0, 0, flipX, 0, 0, 220, 0.08, 0.22);
				::Wuxia.VFX.spawnDynamicAt(tile, spec.sig, 110, 0.28, spec.scale * 1.04, 0, 14, 0, 1, 0, 0, flipX, 0, 0, 215, 0.08, 0.24);
			}
		}
		catch (_e) {}
	}
};

::Wuxia.VFX.playShanHaiImpactVfx <- function( _skill, _user, _hitTile, _targetEntity, _hit )
{
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return false;
	if (_skill == null || !::Wuxia.isOnMap(_user) || _hitTile == null) return false;
	local spec = ::Wuxia.VFX.resolveShanHaiChoreo(_skill, _user);
	if (spec == null) return false;

	local originTile = _user.getTile();
	local dir = ::Wuxia.VFX.getDirVec(originTile, _hitTile, _user);
	local flipX = ::Wuxia.VFX.shouldFlipLeft(dir, _user);
	local isRanged = (::Wuxia.hasMember(_skill, "isRanged") && _skill.isRanged());

	if (_targetEntity != null && _targetEntity.isAlive() && ::Wuxia.VFX.isMotionEnabled())
	{
		local reactMode = (spec.kind == "sky_slam" || spec.kind == "upcut_launch") ? "sky_slam" : ((spec.kind == "flurry_blitz") ? "flurry_blitz" : "crescent");
		::Wuxia.VFX.startTargetReaction(_targetEntity, reactMode, dir, _hit, isRanged);
	}

	if (!::Wuxia.VFX.isVfxEnabled() || !_hitTile.IsVisibleForPlayer) return true;

	try
	{
		if (_hit)
		{
			::Wuxia.VFX.spawnDynamicAt(_hitTile, spec.aura, 45, 0.24, spec.scale, dir.X * 48.0, dir.Y * 48.0, (spec.kind == "cyclone_spin" ? 210 : 0), 1, 0, 0, flipX, -dir.X * 10.0, -dir.Y * 10.0, 224, 0.07, 0.22);
			::Wuxia.VFX.spawnDynamicAt(_hitTile, spec.sig, 90, 0.26, spec.scale * 1.05, dir.X * 20.0, dir.Y * 20.0 + 10.0, 0, 1, 0, 0, flipX, 0, 0, 215, 0.08, 0.22);
			if (spec.isBoss && originTile != null && originTile.IsVisibleForPlayer)
				::Wuxia.VFX.spawnDynamicAt(originTile, "wx_fx_sonic_ring", 20, 0.18, 1.05, 0, 6, 0, 1, 0, 0, flipX, 0, 0, 150, 0.05, 0.16);
		}
		else
		{
			::Wuxia.VFX.spawnDynamicAt(_hitTile, spec.aura, 45, 0.16, spec.scale * 0.85, dir.X * 68.0, dir.Y * 68.0, 0, 1, 0, 0, flipX, 0, 0, 130, 0.05, 0.14);
		}
	}
	catch (_e) {}
	return true;
};

::Wuxia.VFX.playFolkloricCastVfx <- function( _skill, _user, _targetTile )
{
	if (!::Wuxia.VFX.isVfxEnabled()) return;
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
	if (_skill == null || !::Wuxia.isOnMap(_user)) return;

	local skID = (::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null) ? _skill.getID() : "";
	if (skID == "actives.possess_undead" || skID == "actives.raise_undead")
	{
		::Wuxia.VFX.playTriggerVfx(_user, "wx_vfx_30", null, -25, 90, 1.18);
		if (_targetTile != null)
			::Wuxia.VFX.playTriggerVfx(_targetTile, "wx_vfx_30", null, -35, -90, 1.22);
	}
	else if (skID == "actives.darkflight")
	{
		::Wuxia.VFX.playTriggerVfx(_user, "wx_vfx_25", "wx_fx_blood_orb", -30, 0, 1.14);
		if (_targetTile != null)
			::Wuxia.VFX.playTriggerVfx(_targetTile, "wx_vfx_25", null, 0, 0, 1.14);
	}
};

::Wuxia.VFX.playWeaponQiAura <- function( _skill, _user, _targetTile, _targetEntity = null )
{
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
	if (_skill == null || !::Wuxia.isOnMap(_user)) return;

	local skID = (::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null) ? _skill.getID() : "";
	// Never double-fire on dedicated Wuxia active moves (`actives.wx_*` already invoke `playSkillVfx`)
	if (skID.find("actives.wx_") == 0) return;

	if (!(::Wuxia.hasMember(_skill, "isAttack")) || !_skill.isAttack() || !(::Wuxia.hasMember(_skill.m, "IsWeaponSkill")) || !_skill.m.IsWeaponSkill)
		return;

	local tile = _targetTile != null ? _targetTile : _user.getTile();
	if (tile == null || !tile.IsVisibleForPlayer) return;

	local originTile = _user.getTile();
	local dir = ::Wuxia.VFX.getDirVec(originTile, tile, _user);
	local isRanged = (::Wuxia.hasMember(_skill, "isRanged") && _skill.isRanged());

	// Crisp martial lunge & target hit reaction even on standard weapon attacks!
	if (::Wuxia.VFX.isMotionEnabled() && !isRanged)
	{
		::Wuxia.VFX.startActorMotion(_user, "basic_strike", dir, 0.34, 0.0, skID);
		if ("getShaker" in ::Tactical && ::Tactical.getShaker() != null && ("cancel" in ::Tactical.getShaker()))
		{
			try { ::Tactical.getShaker().cancel(_user); } catch (_e) {}
		}
		if (_targetEntity != null && _targetEntity.isAlive())
			::Wuxia.VFX.startTargetReaction(_targetEntity, "crescent", dir, true, false);
	}

	if (!::Wuxia.VFX.isVfxEnabled()) return;

	local auraBrush = ::Wuxia.VFX.resolvePractitionerWeaponVfx(_skill, _user);
	if (auraBrush == null || auraBrush == "") return;

	try
	{
		local flipX = ::Wuxia.VFX.shouldFlipLeft(dir, _user);
		local apCost = (::Wuxia.hasMember(_skill.m, "ActionPointCost")) ? _skill.m.ActionPointCost : 4;
		local isHeavy = (apCost >= 6);
		local isSpin = (skID.find("round_swing") != null || skID.find("thresh") != null);

		if (skID.find("lunge") != null && originTile != null)
			::Wuxia.VFX.spawnDynamicAt(originTile, "wx_vfx_25", 0, 0.20, 1.06, dir.X * 65.0, dir.Y * 65.0, 0, 1, 0, 0, flipX, 0, 0, 185, 0.06, 0.16);

		::Wuxia.VFX.spawnDynamicAt(
			tile, auraBrush, ::Wuxia.VFX.isMotionEnabled() ? 75 : 25,
			isHeavy ? 0.22 : 0.18, isHeavy ? 1.16 : 1.02,
			dir.X * 45.0, dir.Y * 45.0, isSpin ? 200 : 0, 1, 0, 0, flipX,
			-dir.X * 10.0, -dir.Y * 10.0, 200, 0.07, 0.18
		);
	}
	catch (_err)
	{
		::Wuxia.VFX.logOnce("playWeaponQiAura:" + auraBrush, _err);
	}
};

::Wuxia.VFX.onAttackLanded <- function( _skill, _user, _hitTile, _targetEntity = null )
{
	if (_skill == null || _hitTile == null) return;
	if (("m" in _skill) && ("WX_KineticSuppressLegacy" in _skill.m) && _skill.m.WX_KineticSuppressLegacy)
	{
		if ("KineticVFX" in ::Wuxia && "onKineticAttackResult" in ::Wuxia.KineticVFX)
			::Wuxia.KineticVFX.onKineticAttackResult(_skill, _user, _hitTile, _targetEntity, true);
		return;
	}
	local originTile = (_user != null && _user.isPlacedOnMap()) ? _user.getTile() : null;
	if (("m" in _skill) && ("WX_PendingImpactVfx" in _skill.m) && _skill.m.WX_PendingImpactVfx != null)
	{
		local pSpec = _skill.m.WX_PendingImpactVfx;
		if (_targetEntity != null && _targetEntity.isAlive() && ::Wuxia.VFX.isMotionEnabled())
		{
			local dir = ::Wuxia.VFX.getDirVec(originTile, _hitTile);
			::Wuxia.VFX.startTargetReaction(_targetEntity, pSpec.mode, dir, true, ("isRanged" in pSpec && pSpec.isRanged));
		}
		::Wuxia.VFX.playTargetImpactVfx(_skill, _user, originTile, _hitTile, pSpec);
		return;
	}
	if (::Wuxia.VFX.playShanHaiImpactVfx(_skill, _user, _hitTile, _targetEntity, true))
		return;
	::Wuxia.VFX.playWeaponQiAura(_skill, _user, _hitTile, _targetEntity);
};

::Wuxia.VFX.onAttackMissed <- function( _skill, _user, _missTile, _targetEntity = null )
{
	if (_skill == null || _missTile == null) return;
	if (("m" in _skill) && ("WX_KineticSuppressLegacy" in _skill.m) && _skill.m.WX_KineticSuppressLegacy)
	{
		if ("KineticVFX" in ::Wuxia && "onKineticAttackResult" in ::Wuxia.KineticVFX)
			::Wuxia.KineticVFX.onKineticAttackResult(_skill, _user, _missTile, _targetEntity, false);
		return;
	}
	local originTile = (_user != null && _user.isPlacedOnMap()) ? _user.getTile() : null;
	if (("m" in _skill) && ("WX_PendingImpactVfx" in _skill.m) && _skill.m.WX_PendingImpactVfx != null)
	{
		local pSpec = _skill.m.WX_PendingImpactVfx;
		if (_targetEntity != null && _targetEntity.isAlive() && ::Wuxia.VFX.isMotionEnabled())
		{
			local dir = ::Wuxia.VFX.getDirVec(originTile, _missTile);
			::Wuxia.VFX.startTargetReaction(_targetEntity, pSpec.mode, dir, false, ("isRanged" in pSpec && pSpec.isRanged));
		}
		::Wuxia.VFX.playTargetMissVfx(_skill, _user, originTile, _missTile, pSpec);
		return;
	}
	if (::Wuxia.VFX.playShanHaiImpactVfx(_skill, _user, _missTile, _targetEntity, false))
		return;
	if (_targetEntity != null && _targetEntity.isAlive() && ::Wuxia.VFX.isMotionEnabled() && originTile != null)
	{
		local dir2 = ::Wuxia.VFX.getDirVec(originTile, _missTile);
		local isRanged2 = (::Wuxia.hasMember(_skill, "isRanged") && _skill.isRanged());
		::Wuxia.VFX.startTargetReaction(_targetEntity, "crescent", dir2, false, isRanged2);
	}
};

// ============================================================================
// Non-Destructive Engine Hooks:
// 1. `scripts/skills/skill` (`use` & `attackEntity`)
// 2. Tactical state and actor resource loading (battle-scoped VFX atlases).
// 3. `scripts/states/world_state` (save/load options cleanly in `::World.Flags`)
// 4. `scripts/ui/screens/menu/modules/options_menu_module` (RPCs for native Options -> Gameplay toggles)
// ============================================================================
if ("HooksMod" in ::Wuxia && ::Wuxia.HooksMod != null)
{
	::Wuxia.HooksMod.hook("scripts/skills/skill", function( q )
	{
		q.use = @(__original) function( _targetTile, _forFree = false )
		{
			local user = (this.getContainer() != null) ? this.getContainer().getActor() : null;
			local prevAP = (user != null && ::Wuxia.hasMember(user, "getActionPoints")) ? user.getActionPoints() : 0;
			local prevFat = (user != null && ::Wuxia.hasMember(user, "getFatigue")) ? user.getFatigue() : 0;
			this.m.WX_InSkillUse <- true;
			this.m.WX_AttackAttempted <- false;
			this.m.WX_RecordedThisUse <- false;
			::Wuxia.VFX.playFolkloricCastVfx(this, user, _targetTile);
			::Wuxia.VFX.playShanHaiUseVfx(this, user, _targetTile);
			local ret = false;
			try
			{
				ret = __original(_targetTile, _forFree);
			}
			catch (err)
			{
				this.m.WX_InSkillUse <- false;
				this.m.WX_AttackAttempted <- false;
				this.m.WX_RecordedThisUse <- false;
				if ("WX_PendingImpactVfx" in this.m) this.m.WX_PendingImpactVfx = null;
				throw err;
			}
			local alreadyRec = ("WX_RecordedThisUse" in this.m) && this.m.WX_RecordedThisUse;
			local didExecute = ret
				|| (("WX_AttackAttempted" in this.m) && this.m.WX_AttackAttempted)
				|| (!_forFree && user != null && ::Wuxia.hasMember(user, "getActionPoints")
					&& (user.getActionPoints() < prevAP || user.getFatigue() > prevFat));
			this.m.WX_InSkillUse <- false;
			this.m.WX_AttackAttempted <- false;
			this.m.WX_RecordedThisUse <- false;
			if (!alreadyRec && didExecute && user != null && user.isPlayerControlled() && ("Mastery" in ::Wuxia) && ("recordSkillUse" in ::Wuxia.Mastery))
			{
				::Wuxia.Mastery.recordSkillUse(user, this.getID());
			}
			if ("WX_PendingImpactVfx" in this.m) this.m.WX_PendingImpactVfx = null;
			return ret;
		};

		q.attackEntity = @(__original) function( _user, _targetEntity, _allowDiversion = true )
		{
			this.m.WX_AttackAttempted <- true;
			local suppressRec = ("WX_KineticSuppressLegacy" in this.m) && this.m.WX_KineticSuppressLegacy;
			if (!suppressRec && _user != null && ::Wuxia.hasMember(_user, "isPlayerControlled") && _user.isPlayerControlled()
				&& ("Mastery" in ::Wuxia) && ("recordSkillUse" in ::Wuxia.Mastery)
				&& (!("WX_RecordedThisUse" in this.m) || !this.m.WX_RecordedThisUse))
			{
				if (("WX_InSkillUse" in this.m) && this.m.WX_InSkillUse)
					this.m.WX_RecordedThisUse <- true;
				::Wuxia.Mastery.recordSkillUse(_user, this.getID());
			}
			local targetTile = ::Wuxia.isOnMap(_targetEntity) ? _targetEntity.getTile() : null;
			local hit = __original(_user, _targetEntity, _allowDiversion);
			local finalTile = ::Wuxia.isOnMap(_targetEntity) ? _targetEntity.getTile() : targetTile;
			if (finalTile != null)
			{
				if (hit)
					::Wuxia.VFX.onAttackLanded(this, _user, finalTile, _targetEntity);
				else
					::Wuxia.VFX.onAttackMissed(this, _user, finalTile, _targetEntity);
			}
			return hit;
		};
	});

	// Vanilla calls actor.loadResources after both campaign deployment and scenario generation,
	// before it loads the temporary tactical resource package.
	::Wuxia.HooksMod.hook("scripts/entity/tactical/actor", function( q )
	{
		q.loadResources = @(__original) function()
		{
			if (!::Wuxia.VFX.BattleResourcesQueued) ::Wuxia.VFX.registerTacticalResources();
			return __original();
		};
	});

	::Wuxia.HooksMod.hook("scripts/states/tactical_state", function( q )
	{
		q.init = @(__original) function()
		{
			::Wuxia.VFX.BattleTextures = {};
			::Wuxia.VFX.BattleResourcesQueued = false;
			::Wuxia.VFX.LastQinggongCast = {};
			local result = __original();
			::Wuxia.VFX.warmBattleTextures();
			return result;
		};
		if (::Wuxia.qHas(q, "onBattleEnded"))
		{
			q.onBattleEnded = @(__original) function()
			{
				::Wuxia.VFX.clearAllActiveMotions(true);
				if ("KineticVFX" in ::Wuxia && "clearAll" in ::Wuxia.KineticVFX)
					::Wuxia.KineticVFX.clearAll();
				return __original();
			};
		}
		if (::Wuxia.qHas(q, "onFinish"))
		{
			q.onFinish = @(__original) function()
			{
				::Wuxia.VFX.clearAllActiveMotions(true);
				if ("KineticVFX" in ::Wuxia && "clearAll" in ::Wuxia.KineticVFX)
					::Wuxia.KineticVFX.clearAll();
				::Wuxia.VFX.BattleResourcesQueued = false;
				::Wuxia.VFX.BattleTextures = {};
				::Wuxia.VFX.LastQinggongCast = {};
				local ret = __original();
				::Wuxia.VFX.clearAllActiveMotions(true);
				return ret;
			};
		}
	});

	::Wuxia.HooksMod.hook("scripts/states/world_state", function( q )
	{
		if (::Wuxia.qHas(q, "onDeserialize"))
		{
			q.onDeserialize = @(__original) function( _in )
			{
				local res = __original(_in);
				::Wuxia.VFX.loadOptionsFromWorld();
				return res;
			};
		}
		if (::Wuxia.qHas(q, "onSerialize"))
		{
			q.onSerialize = @(__original) function( _out )
			{
				::Wuxia.VFX.saveOptionsToWorld();
				return __original(_out);
			};
		}
	});

	::Wuxia.HooksMod.hook("scripts/ui/screens/menu/modules/options_menu_module", function( q )
	{
		q.onWXQueryCombatOptions <- function()
		{
			return ::Wuxia.VFX.getOptions();
		};

		q.onWXApplyCombatOptions <- function( _data )
		{
			if (_data == null)
				return ::Wuxia.VFX.getOptions();
			local sv = null;
			local em = null;
			local sc = null;
			if (typeof _data == "array")
			{
				if (_data.len() >= 1) sv = _data[0];
				if (_data.len() >= 2) em = _data[1];
				if (_data.len() >= 3) sc = _data[2];
			}
			else if (typeof _data == "table")
			{
				if ("showSkillVfx" in _data) sv = _data.showSkillVfx;
				if ("enableActorMotion" in _data) em = _data.enableActorMotion;
				if ("showSkillCutIn" in _data) sc = _data.showSkillCutIn;
			}
			else
			{
				return ::Wuxia.VFX.getOptions();
			}
			return ::Wuxia.VFX.setOptions(sv, em, true, sc);
		};
	});
}
