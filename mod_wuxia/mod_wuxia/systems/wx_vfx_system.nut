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
	Cache         = {},
	FlipbookCache = {},

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
		wx_tactics_shihou  = ["佛门狮吼·五叠震魂", "wx_anim_35", "lion_roar",    "wx_vfx_23", "wx_fx_sonic_ring",    0, 8]
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

::Wuxia.VFX.getDirVec <- function( _fromTile, _toTile )
{
	if (_fromTile == null || _toTile == null || _fromTile.ID == _toTile.ID)
		return { X = 1.0, Y = 0.0 };
	try
	{
		if (("Pos" in _fromTile) && ("Pos" in _toTile) && _fromTile.Pos != null && _toTile.Pos != null)
		{
			local dx = (_toTile.Pos.X - _fromTile.Pos.X).tofloat();
			local dy = (_toTile.Pos.Y - _fromTile.Pos.Y).tofloat();
			local len = ::Math.sqrt(dx * dx + dy * dy);
			if (len > 0.001)
				return { X = dx / len, Y = -(dy / len) };
		}
		if (::Wuxia.hasMember(_fromTile, "getDirectionTo"))
		{
			local d = _fromTile.getDirectionTo(_toTile);
			local hexDirs = [
				{ X =  0.00, Y = -1.00 }, // N
				{ X =  0.86, Y = -0.50 }, // NE
				{ X =  0.86, Y =  0.50 }, // SE
				{ X =  0.00, Y =  1.00 }, // S
				{ X = -0.86, Y =  0.50 }, // SW
				{ X = -0.86, Y = -0.50 }  // NW
			];
			if (d >= 0 && d < hexDirs.len())
				return hexDirs[d];
		}
	}
	catch (_e) {}
	return { X = 1.0, Y = 0.0 };
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

::Wuxia.VFX.makeDynamicParticle <- function( _brushName, _delayMs, _lifeSec = 0.16, _scale = 1.0, _vx = 0, _vy = 0, _torque = 0, _qty = 1, _fx = 0, _fy = 0 )
{
	if (!("Const" in getroottable()) || !("Tactical" in ::Const) || !("DustParticles" in ::Const.Tactical) || ::Const.Tactical.DustParticles.len() == 0)
		return null;

	local st = clone ::Const.Tactical.DustParticles[0];
	st.Brushes <- [_brushName];
	st.Delay <- _delayMs;
	st.Quantity <- _qty;
	st.LifeTimeQuantity <- _qty;
	st.SpawnRate <- 100;
	if ("Stages" in st && typeof st.Stages == "array" && st.Stages.len() > 0)
	{
		local newStages = [];
		local s0 = clone st.Stages[0];
		if ("LifeTimeMin" in s0) s0.LifeTimeMin = _lifeSec;
		if ("LifeTimeMax" in s0) s0.LifeTimeMax = _lifeSec + 0.04;
		if ("ScaleMin" in s0) s0.ScaleMin = _scale;
		if ("ScaleMax" in s0) s0.ScaleMax = _scale * 1.12;
		if ("VelocityMin" in s0) s0.VelocityMin = ::createVec(_vx, _vy);
		if ("VelocityMax" in s0) s0.VelocityMax = ::createVec(_vx, _vy);
		if ("ForceMin" in s0) s0.ForceMin = ::createVec(_fx, _fy);
		if ("ForceMax" in s0) s0.ForceMax = ::createVec(_fx, _fy);
		if ("TorqueMin" in s0) s0.TorqueMin = _torque;
		if ("TorqueMax" in s0) s0.TorqueMax = _torque;
		newStages.push(s0);
		st.Stages = newStages;
	}
	return st;
};

::Wuxia.VFX.makeFrameParticle <- function( _brushName, _delayMs, _lifeSec = 0.13, _scale = 1.0 )
{
	return ::Wuxia.VFX.makeDynamicParticle(_brushName, _delayMs, _lifeSec, _scale, 0, 0, 0, 1);
};

::Wuxia.VFX.buildFlipbookStages <- function( _animID )
{
	if (_animID == null || _animID == "") return null;
	if (_animID in ::Wuxia.VFX.FlipbookCache)
		return ::Wuxia.VFX.FlipbookCache[_animID];

	local f1 = ::Wuxia.VFX.makeDynamicParticle(_animID + "_f1", 0,   0.11, 0.92);
	local f2 = ::Wuxia.VFX.makeDynamicParticle(_animID + "_f2", 75,  0.12, 1.02);
	local f3 = ::Wuxia.VFX.makeDynamicParticle(_animID + "_f3", 160, 0.16, 1.12);
	local f4 = ::Wuxia.VFX.makeDynamicParticle(_animID + "_f4", 265, 0.18, 1.05);
	if (f1 == null) return null;

	local seq = [f1, f2, f3, f4];
	::Wuxia.VFX.FlipbookCache[_animID] <- seq;
	return seq;
};

::Wuxia.VFX.spawnDynamicAt <- function( _tile, _brushName, _delayMs = 0, _lifeSec = 0.18, _scale = 1.0, _vx = 0, _vy = 0, _torque = 0, _qty = 1, _fx = 0, _fy = 0 )
{
	if (_tile == null || !_tile.IsVisibleForPlayer || _brushName == null || _brushName == "") return;
	local p = ::Wuxia.VFX.makeDynamicParticle(_brushName, _delayMs, _lifeSec, _scale, _vx, _vy, _torque, _qty, _fx, _fy);
	if (p != null)
	{
		::Tactical.spawnParticleEffect(false, [p], _tile, 0, 1, 1.0, 1.0);
	}
};

::Wuxia.VFX.spawnSingleFrameAt <- function( _tile, _brushName, _delayMs = 0, _lifeSec = 0.16, _scale = 1.0 )
{
	::Wuxia.VFX.spawnDynamicAt(_tile, _brushName, _delayMs, _lifeSec, _scale, 0, 0, 0, 1);
};

::Wuxia.VFX.shakeEntityFrom <- function( _target, _originTile, _intensity = 5 )
{
	if (_target == null || !_target.isAlive() || !_target.isPlacedOnMap() || _originTile == null) return;
	if ("getShaker" in ::Tactical && ::Tactical.getShaker() != null)
	{
		::Tactical.getShaker().shake(_target, _originTile, _intensity);
	}
};

// Lightweight trigger VFX for Martial Passives, True Qi Shield, Frost Ring, Counter-Stances & Shan Hai Bosses!
::Wuxia.VFX.playTriggerVfx <- function( _actorOrTile, _qiAuraBrush, _sigBrush = null, _vy = 0, _torque = 0, _scale = 1.05 )
{
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

	try
	{
		::Wuxia.VFX.spawnDynamicAt(tile, _qiAuraBrush, 0, 0.24, _scale, 0, _vy, _torque, 1);
		if (_sigBrush != null && _sigBrush != "")
			::Wuxia.VFX.spawnDynamicAt(tile, _sigBrush, 65, 0.22, _scale * 0.96, 0, _vy * 0.5, -_torque * 0.5, 1);
	}
	catch (_err) {}
};

// Synchronized Secondary-Hex VFX for Multi-Target AoE Sweeps (`八方狂澜斩 / 横扫千军 / 旋风断魂斧 / 裂地崩山锤 / 漫天花雨`)
::Wuxia.VFX.playAoESecondaryVfx <- function( _skill, _user, _adjTile, _delayMs = 55 )
{
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
	if (_adjTile == null || !_adjTile.IsVisibleForPlayer) return;

	local choreoID = (_skill != null && ::Wuxia.hasMember(_skill.m, "WX_ChoreoID")) ? _skill.m.WX_ChoreoID : null;
	local spec = (choreoID != null && (choreoID in ::Wuxia.VFX.SkillChoreo)) ? ::Wuxia.VFX.SkillChoreo[choreoID] : null;
	local animID = (spec != null) ? spec[1] : ((_skill != null && ::Wuxia.hasMember(_skill.m, "WX_AnimID")) ? _skill.m.WX_AnimID : "wx_anim_11");
	local qiAura = (_skill != null && ::Wuxia.hasMember(_skill.m, "WX_VfxBrush") && _skill.m.WX_VfxBrush != null) ? _skill.m.WX_VfxBrush : (spec != null ? spec[3] : "wx_vfx_06");
	local sigFx = (spec != null) ? spec[4] : null;
	local originTile = (_user != null && _user.isPlacedOnMap()) ? _user.getTile() : _adjTile;
	local dir = ::Wuxia.VFX.getDirVec(originTile, _adjTile);

	try
	{
		::Wuxia.VFX.spawnDynamicAt(_adjTile, qiAura, _delayMs, 0.22, 1.06, dir.X * 42, dir.Y * 42, 140, 1);
		::Wuxia.VFX.spawnDynamicAt(_adjTile, animID + "_f3", _delayMs + 45, 0.18, 1.04, 0, 0, 0, 1);
		if (sigFx != null && sigFx != "")
			::Wuxia.VFX.spawnDynamicAt(_adjTile, sigFx, _delayMs + 85, 0.18, 0.94, 0, -25, 0, 1);
		if (_adjTile.IsOccupiedByActor && originTile.ID != _adjTile.ID)
			::Wuxia.VFX.shakeEntityFrom(_adjTile.getEntity(), originTile, 5);
	}
	catch (_err) {}
};

// Full 72-Skill Multi-Layered Qi-Aura (`wx_vfx_01..32`) + 4-Frame Action VFX (`wx_anim_01..72`) + Dharma Signature (`wx_fx_*`)
// Windup & trajectories play on cast; target impact & slash overlays fire ONLY when `attackEntity` actually hits!
::Wuxia.VFX.playSkillVfx <- function( _skill, _user, _targetTile, _brushName )
{
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;

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

	local dir = ::Wuxia.VFX.getDirVec(originTile, tile);
	local isRangedWpnSkill = (_skill != null && (::Wuxia.hasMember(_skill, "isRanged")) && _skill.isRanged());
	local isAttackSkill = (_skill != null && (::Wuxia.hasMember(_skill, "isAttack")) && _skill.isAttack());

	try
	{
		// 0. ORIGIN QI-WINDUP (Do not override vanilla Shaker on _user before attackEntity!)
		if (_user != null && originTile != null && tile.ID != originTile.ID && shakePow >= 3)
		{
			::Wuxia.VFX.spawnDynamicAt(originTile, animID + "_f1", 0, 0.13, 0.94, dir.X * 52, dir.Y * 52, 0, 1);
		}
		if (originTile != null && (mode == "backstab" || mode == "night_exec"))
		{
			::Wuxia.VFX.spawnDynamicAt(originTile, "wx_vfx_25", 0, 0.24, 1.08, dir.X * 80, dir.Y * 80, 0, 1);
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

			if (mode == "blood_siphon" || mode == "black_hole" || mode == "vacuum_pull" || mode == "hook_pull")
			{
				::Tactical.spawnProjectileEffect(sigFx, originTile, tile, 1.45, 0.95, true, false);
			}
			else if (mode == "star_rain")
			{
				local skyTile = ::Wuxia.VFX.getSkyTileAbove(tile, 2);
				for (local v = 0; v < volleys; v = ++v)
				{
					if (skyTile != null && skyTile.ID != tile.ID)
						::Tactical.spawnProjectileEffect("wx_fx_sword_phantom", skyTile, tile, 1.35 + v * 0.16, 1.02, true, false);
				}
			}
			else
			{
				local baseSpd = (mode == "sun_laser" || mode == "flying_虹" || mode == "sonic_arrow" || mode == "heavy_bolt") ? 1.95 : 1.18;
				local pScale = (mode == "dragon_coil") ? 1.28 : 0.96;
				for (local v2 = 0; v2 < volleys; v2 = ++v2)
				{
					::Tactical.spawnProjectileEffect(projBrush, originTile, tile, baseSpd + v2 * 0.15, pScale, projRot, false);
				}
			}
		}

		local impactSpec = {
			animID   = animID,
			mode     = mode,
			qiAura   = qiAura,
			sigFx    = sigFx,
			volleys  = volleys,
			shakePow = shakePow,
			playedPrimary = false
		};

		if (isAttackSkill && _skill != null && ("m" in _skill))
		{
			_skill.m.WX_PendingImpactVfx <- impactSpec;
		}
		else
		{
			::Wuxia.VFX.playTargetImpactVfx(_skill, _user, originTile, tile, impactSpec);
		}
	}
	catch (_err) {}
};

::Wuxia.VFX.playTargetImpactVfx <- function( _skill, _user, _originTile, _tile, _spec )
{
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive() || _tile == null || _spec == null) return;

	local originTile = _originTile;
	local tile       = _tile;
	local animID     = _spec.animID;
	local mode       = _spec.mode;
	local qiAura     = _spec.qiAura;
	local sigFx      = _spec.sigFx;
	local volleys    = _spec.volleys;
	local shakePow   = _spec.shakePow;
	local dir        = ::Wuxia.VFX.getDirVec(originTile, tile);

	try
	{
		if (!_spec.playedPrimary && originTile != null && tile.ID != originTile.ID && ("spawnProjectileEffect" in ::Tactical))
		{
			if (mode == "blood_siphon" || mode == "black_hole" || mode == "vacuum_pull" || mode == "hook_pull")
			{
				local pullBrush = (mode == "black_hole") ? "wx_vfx_19" : (mode == "blood_siphon" ? "wx_fx_blood_orb" : sigFx);
				for (local s = 0; s < volleys; s = ++s)
				{
					::Tactical.spawnProjectileEffect(pullBrush, tile, originTile, 1.08 + s * 0.18, 0.92, false, false);
				}
				::Wuxia.VFX.spawnDynamicAt(originTile, qiAura, 210, 0.25, 1.12, 0, -28, 120, 1);
			}
			else if (mode == "star_rain")
			{
				for (local v = 0; v < volleys; v = ++v)
				{
					::Wuxia.VFX.spawnDynamicAt(tile, "wx_vfx_08", 45 + v * 45, 0.18, 1.08, -30, 195, 0, 1);
				}
			}
		}
		_spec.playedPrimary = true;

		// 2. BESPOKE TACTICAL ACTION PATTERNS (Zero Generic Fallthroughs!)
		if (mode == "sky_thunder" || mode == "buddha_palm" || mode == "giant_axe" || mode == "leap_cleave" || mode == "gravity_cut" || mode == "shield_split")
		{
			// High-altitude plunge / sky lightning / colossal Buddha palm / Pangu battleaxe slam!
			local skyT = ::Wuxia.VFX.getSkyTileAbove(tile, 2);
			if (skyT != null && skyT.ID != tile.ID && ("spawnProjectileEffect" in ::Tactical) && (mode == "sky_thunder" || mode == "buddha_palm" || mode == "giant_axe"))
				::Tactical.spawnProjectileEffect(sigFx, skyT, tile, 1.75, 1.25, false, false);
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f2", 25,  0.16, 1.18, 0, 210, 0, 1);
			::Wuxia.VFX.spawnDynamicAt(tile, qiAura,        110, 0.24, 1.26, 0, 0,   0, 1);
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f3",135, 0.22, 1.25, 0, 0,   0, 1);
			::Wuxia.VFX.spawnDynamicAt(tile, sigFx,         165, 0.24, 1.22, 0, mode == "sky_thunder" ? 90 : -20, 0, 1);
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f4",255, 0.22, 1.14, 0, 0,   0, 1);
		}
		else if (mode == "earth_wave")
		{
			// Multi-tile tectonic fissure erupting at primary target & rippling to adjacent enemy tiles!
			local seqE = ::Wuxia.VFX.buildFlipbookStages(animID);
			if (seqE != null && tile.IsVisibleForPlayer)
				::Tactical.spawnParticleEffect(false, seqE, tile, 0, 1, 1.0, 1.22);
			::Wuxia.VFX.spawnDynamicAt(tile, qiAura, 95, 0.26, 1.28, 0, -30, 0, 1);
			::Wuxia.VFX.spawnDynamicAt(tile, sigFx, 130, 0.28, 1.24, 0, -45, 0, 1);
			local eStep = 0;
			for (local d0 = 0; d0 < ::Const.Direction.COUNT; d0 = ++d0)
			{
				if (!tile.hasNextTile(d0)) continue;
				local adjE = tile.getNextTile(d0);
				if (!adjE.IsOccupiedByActor || (_user != null && _user.isAlliedWith(adjE.getEntity()))) continue;
				::Wuxia.VFX.spawnDynamicAt(adjE, sigFx, 150 + eStep * 40, 0.22, 1.02, 0, -40, 0, 1);
				::Wuxia.VFX.spawnDynamicAt(adjE, qiAura, 175 + eStep * 40, 0.20, 0.96, 0, 0, 0, 1);
				::Wuxia.VFX.shakeEntityFrom(adjE.getEntity(), tile, 6);
				eStep += 1;
			}
		}
		else if (mode == "cloud_jump" || mode == "mirage_step")
		{
			// Qinggong lightness footwork: ink/cyclone burst at origin + gliding afterimage + Bagua landing!
			if (originTile != null)
			{
				::Wuxia.VFX.spawnDynamicAt(originTile, qiAura,        0,  0.26, 1.12, 0, mode == "cloud_jump" ? -90 : 0, 90, 1);
				::Wuxia.VFX.spawnDynamicAt(originTile, animID + "_f1",25, 0.18, 1.02, dir.X * 65, dir.Y * 65 - 35, 0, 1);
				::Wuxia.VFX.spawnDynamicAt(originTile, sigFx,         55, 0.24, 1.06, 0, 0, 120, 1);
			}
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f3", 115, 0.22, 1.10, 0, 0, 0, 1);
			::Wuxia.VFX.spawnDynamicAt(tile, qiAura,         150, 0.26, 1.12, 0, 0, -90, 1);
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f4", 225, 0.22, 1.04, 0, 0, 0, 1);
		}
		else if (mode == "backstab" || mode == "night_exec")
		{
			// Shadow assassin blink: vanish in ink smoke at caster tile -> crimson-violet throat sever on target!
			if (originTile != null)
				::Wuxia.VFX.spawnDynamicAt(originTile, "wx_vfx_25", 0, 0.24, 1.08, dir.X * 80, dir.Y * 80, 0, 1);
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f2", 55,  0.16, 1.12, -dir.X * 45, -dir.Y * 45, 0, 1);
			::Wuxia.VFX.spawnDynamicAt(tile, qiAura,         95,  0.24, 1.20, 0, 0, 0, 1);
			::Wuxia.VFX.spawnDynamicAt(tile, sigFx,          125, 0.22, 1.18, 0, 0, 0, 1);
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f3", 145, 0.20, 1.18, 0, 0, 0, 1);
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f4", 240, 0.20, 1.05, 0, -25, 0, 1);
		}
		else if (mode == "counter" || mode == "spear_wall" || mode == "hex_fortress" || mode == "golden_bell" || mode == "lotus_breath" || mode == "poise_draw" || mode == "blood_flame")
		{
			// Self-cast Stances, Parries, Golden Bell, Lotus Meditation, Poise Draw & Demon Blood Burst!
			local hostTile = originTile != null ? originTile : tile;
			local liftVy = (mode == "blood_flame" || mode == "poise_draw" || mode == "lotus_breath") ? -65 : 0;
			local spinTq = (mode == "counter" || mode == "lotus_breath") ? 110 : 0;
			::Wuxia.VFX.spawnDynamicAt(hostTile, animID + "_f1", 0,   0.15, 1.00, 0, liftVy * 0.5, 0, 1);
			::Wuxia.VFX.spawnDynamicAt(hostTile, qiAura,         55,  0.34, 1.24, 0, liftVy, spinTq, 1);
			::Wuxia.VFX.spawnDynamicAt(hostTile, animID + "_f3", 120, 0.26, 1.18, 0, liftVy * 0.4, 0, 1);
			::Wuxia.VFX.spawnDynamicAt(hostTile, sigFx,          165, 0.30, 1.20, 0, 0, -spinTq, 1);
			::Wuxia.VFX.spawnDynamicAt(hostTile, animID + "_f4", 250, 0.24, 1.08, 0, 0, 0, 1);
		}
		else if (mode == "lion_roar" || mode == "taunt_slam" || mode == "war_banner" || mode == "tidal_sweep" || mode == "cyclone_pole" || mode == "berserk_spin")
		{
			// Radial AoE Sonic Roar / Command War-Banner Halo / 360° Cyclone Sweeps!
			local center = (mode == "lion_roar" || mode == "taunt_slam" || mode == "war_banner")
				? (originTile != null ? originTile : tile)
				: tile;
			local isSpin = (mode == "tidal_sweep" || mode == "cyclone_pole" || mode == "berserk_spin");
			local seqR = ::Wuxia.VFX.buildFlipbookStages(animID);
			if (seqR != null && center.IsVisibleForPlayer)
				::Tactical.spawnParticleEffect(false, seqR, center, 0, 1, 1.0, 1.22);
			::Wuxia.VFX.spawnDynamicAt(center, qiAura, 45,  0.28, 1.30, 0, isSpin ? 0 : -30, isSpin ? 280 : 0, 1);
			::Wuxia.VFX.spawnDynamicAt(center, sigFx,  105, 0.28, 1.22, 0, mode == "war_banner" ? -45 : 0, isSpin ? -220 : 0, 1);

			local rStep = 0;
			for (local d = 0; d < ::Const.Direction.COUNT; d = ++d)
			{
				if (!center.hasNextTile(d)) continue;
				local adj = center.getNextTile(d);
				local adjDir = ::Wuxia.VFX.getDirVec(center, adj);
				if (mode == "war_banner")
				{
					if (adj.IsOccupiedByActor && _user != null && _user.isAlliedWith(adj.getEntity()))
						::Wuxia.VFX.spawnDynamicAt(adj, "wx_vfx_24", 80 + rStep * 30, 0.26, 0.98, 0, -25, 0, 1);
				}
				else
				{
					::Wuxia.VFX.spawnDynamicAt(adj, isSpin ? qiAura : sigFx, 70 + rStep * 30, 0.20, 0.94, adjDir.X * 55, adjDir.Y * 55, isSpin ? 200 : 0, 1);
					if (adj.IsOccupiedByActor && _user != null && !_user.isAlliedWith(adj.getEntity()))
						::Wuxia.VFX.shakeEntityFrom(adj.getEntity(), center, shakePow);
				}
				rStep += 1;
			}
		}
		else if (mode == "combo3" || mode == "clone3" || mode == "omnislash6" || mode == "rapid_jab" || mode == "prism5_hit" || mode == "phoenix9" || mode == "petal_storm")
		{
			// Multi-Hit Rapid Blitzes, 3-Clone Convergence & 9-Phoenix Volleys!
			local strikes = (mode == "omnislash6") ? 4 : (mode == "rapid_jab" ? 2 : 3);
			for (local k = 0; k < strikes; k = ++k)
			{
				local side = (k % 2 == 0) ? 1 : -1;
				local fKey = animID + "_f" + ((k % 3) + 2);
				::Wuxia.VFX.spawnDynamicAt(tile, fKey,  k * 65,      0.15, 1.06 + k * 0.05, dir.X * 65 + side * 28, dir.Y * 65 - side * 24, side * 140, 1);
				::Wuxia.VFX.spawnDynamicAt(tile, qiAura, 25 + k * 65, 0.16, 1.08,            -side * 32, side * 28, -side * 120, 1);
			}
			::Wuxia.VFX.spawnDynamicAt(tile, sigFx,          strikes * 62,      0.22, 1.18, 0, 0, 0, 1);
			::Wuxia.VFX.spawnDynamicAt(tile, animID + "_f4", strikes * 62 + 80, 0.20, 1.08, 0, 0, 0, 1);
		}
		else if (mode == "taiji_field" || mode == "taiji_orb" || mode == "disarm_arc" || mode == "disarm_grab")
		{
			// Yin-Yang Taiji Deflection & Weapon-Snatching Disarm Arcs!
			local seqT = ::Wuxia.VFX.buildFlipbookStages(animID);
			if (seqT != null && tile.IsVisibleForPlayer)
				::Tactical.spawnParticleEffect(false, seqT, tile, 0, 1, 1.0, 1.12);
			local isDisarm = (mode == "disarm_arc" || mode == "disarm_grab");
			::Wuxia.VFX.spawnDynamicAt(tile, qiAura, 60,  0.26, 1.18, dir.X * 45, dir.Y * 45, 220, 1);
			// Disarm launches a spinning weapon phantom skyward (`vy = -165, torque = 420`)!
			::Wuxia.VFX.spawnDynamicAt(tile, sigFx,  110, 0.28, isDisarm ? 1.05 : 1.24, isDisarm ? 45 : 0, isDisarm ? -165 : 0, isDisarm ? 420 : -180, 1, 0, isDisarm ? 260 : 0);
		}
		else if (mode == "modao_upcut" || mode == "dragon_up" || mode == "fire_pillar" || mode == "frost_tomb")
		{
			// Upward Ground-Ripping Launches (`陌刀 / 霸王升龙枪`), Blazing Fire Pillar (`燃木刀`), Glacial Ice Tomb (`玄冥掌`)!
			local seqU = ::Wuxia.VFX.buildFlipbookStages(animID);
			if (seqU != null && tile.IsVisibleForPlayer)
				::Tactical.spawnParticleEffect(false, seqU, tile, 0, 1, 1.0, 1.18);
			::Wuxia.VFX.spawnDynamicAt(tile, qiAura, 70,  0.24, 1.22, dir.X * 40, -115, 0, 1);
			::Wuxia.VFX.spawnDynamicAt(tile, sigFx,  120, 0.28, 1.24, 0, -95, 0, 1);
			if (mode == "frost_tomb")
				::Wuxia.VFX.spawnDynamicAt(tile, "wx_vfx_21", 155, 0.28, 1.18, 0, 0, 0, 1);
		}
		else if (mode == "over_shield" || mode == "neck_coil" || mode == "viper_whip" || mode == "bamboo_bind")
		{
			// Whip / Flail / Dog-Beating Bamboo Coils!
			local seqW = ::Wuxia.VFX.buildFlipbookStages(animID);
			if (seqW != null && tile.IsVisibleForPlayer)
				::Tactical.spawnParticleEffect(false, seqW, tile, 0, 1, 1.0, 1.12);
			::Wuxia.VFX.spawnDynamicAt(tile, qiAura, 65,  0.24, 1.18, dir.X * 60, mode == "over_shield" ? -70 : 0, 180, 1);
			::Wuxia.VFX.spawnDynamicAt(tile, sigFx,  125, 0.26, 1.16, 0, 0, -180, 1);
			if (mode == "viper_whip")
				::Wuxia.VFX.spawnDynamicAt(tile, "wx_vfx_28", 165, 0.24, 1.04, 0, -35, 0, 1);
		}
		else
		{
			// Precision Pierces (`drill_lunge`, `spiral_stab`, `acupoint`, `lotus_poke`, `inch_pulse`),
			// Twin Crosses (`twin_cross`, `halberd_x`, `twin_fang`), Dragon Rush, Ghost Claw, Bombs, Healing Needles & Ranged Impacts!
			local seq = ::Wuxia.VFX.buildFlipbookStages(animID);
			if (seq != null && tile.IsVisibleForPlayer)
				::Tactical.spawnParticleEffect(false, seq, tile, 0, 1, 1.0, shakePow >= 7 ? 1.20 : 1.08);

			local pushVx = (mode == "drill_lunge" || mode == "inch_pulse" || mode == "shield_ram" || mode == "dragon_coil") ? (dir.X * 95) : (dir.X * 35);
			local pushVy = (mode == "drill_lunge" || mode == "inch_pulse" || mode == "shield_ram" || mode == "dragon_coil") ? (dir.Y * 95) : (dir.Y * 35);
			local spin   = (mode == "spiral_stab") ? 280 : ((mode == "acupoint" || mode == "lotus_poke") ? 120 : 0);

			::Wuxia.VFX.spawnDynamicAt(tile, qiAura, 85,  0.24, 1.20, pushVx, pushVy, spin, 1);
			::Wuxia.VFX.spawnDynamicAt(tile, sigFx,  135, 0.26, 1.18, 0, mode == "heal_needles" || mode == "smoke_screen" ? -40 : 0, -spin * 0.5, 1);
		}

		// 3. TACTICAL DIRECTIONAL ATTACK SLASH OVERLAY (`spawnAttackEffect` using authentic `qiAura = wx_vfx_*`)
		// Only reached on confirmed hits (`onAttackLanded`) for attack skills; do NOT pre-shake target so vanilla hit/dodge animations play cleanly!
		if (_skill != null && (::Wuxia.hasMember(_skill, "spawnAttackEffect")) && tile.IsVisibleForPlayer && _skill.isAttack())
		{
			local climaxEff = ::Wuxia.VFX.buildAttackEffect(qiAura);
			if (climaxEff != null) _skill.spawnAttackEffect(tile, climaxEff);
		}
	}
	catch (_err)
	{
	}
};

// Resolves & plays authentic Wuxia Qi-Aura (`wx_vfx_01..32`) when a martial practitioner or Relic Weapon wielder
// uses ANY standard weapon attack (`slash`, `chop`, `swing`, `impale`, `smite`, `lunge`, `riposte`, `quick_shot`, etc.)!
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

	// Match weapon family -> authentic hand-painted `wx_vfx_*` Qi-Aura!
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

::Wuxia.VFX.playFolkloricCastVfx <- function( _skill, _user, _targetTile )
{
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
	if (_skill == null || _user == null || !_user.isPlacedOnMap()) return;

	local skID = (::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null) ? _skill.getID() : "";
	if (skID == "actives.possess_undead" || skID == "actives.raise_undead")
	{
		::Wuxia.VFX.playTriggerVfx(_user, "wx_vfx_30", null, -25, 90, 1.15);
		if (_targetTile != null)
			::Wuxia.VFX.playTriggerVfx(_targetTile, "wx_vfx_30", null, -35, -90, 1.18);
	}
	else if (skID == "actives.darkflight")
	{
		::Wuxia.VFX.playTriggerVfx(_user, "wx_vfx_25", "wx_fx_blood_orb", -30, 0, 1.10);
		if (_targetTile != null)
			::Wuxia.VFX.playTriggerVfx(_targetTile, "wx_vfx_25", null, 0, 0, 1.10);
	}
};

::Wuxia.VFX.playWeaponQiAura <- function( _skill, _user, _targetTile )
{
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
	if (_skill == null || _user == null || !_user.isPlacedOnMap()) return;

	local skID = (::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null) ? _skill.getID() : "";
	// Never double-fire on dedicated Wuxia active moves (`actives.wx_*` already invoke `playSkillVfx`)
	if (skID.find("actives.wx_") == 0) return;

	if (!(::Wuxia.hasMember(_skill, "isAttack")) || !_skill.isAttack() || !(::Wuxia.hasMember(_skill.m, "IsWeaponSkill")) || !_skill.m.IsWeaponSkill)
		return;

	local tile = _targetTile != null ? _targetTile : _user.getTile();
	if (tile == null || !tile.IsVisibleForPlayer) return;

	local auraBrush = ::Wuxia.VFX.resolvePractitionerWeaponVfx(_skill, _user);
	if (auraBrush == null || auraBrush == "") return;

	try
	{
		local originTile = _user.getTile();
		local dir = ::Wuxia.VFX.getDirVec(originTile, tile);
		local apCost = (::Wuxia.hasMember(_skill.m, "ActionPointCost")) ? _skill.m.ActionPointCost : 4;
		local isHeavy = (apCost >= 6);
		local isSpin = (skID.find("round_swing") != null || skID.find("thresh") != null);

		if (skID.find("lunge") != null && originTile != null)
			::Wuxia.VFX.spawnDynamicAt(originTile, "wx_vfx_25", 0, 0.20, 1.02, dir.X * 70, dir.Y * 70, 0, 1);

		::Wuxia.VFX.spawnDynamicAt(tile, auraBrush, 35, isHeavy ? 0.24 : 0.19, isHeavy ? 1.14 : 0.96, dir.X * 42, dir.Y * 42, isSpin ? 240 : 0, 1);
		if (::Wuxia.hasMember(_skill, "spawnAttackEffect"))
		{
			local eff = ::Wuxia.VFX.buildAttackEffect(auraBrush);
			if (eff != null) _skill.spawnAttackEffect(tile, eff);
		}
	}
	catch (_err) {}
};

::Wuxia.VFX.onAttackLanded <- function( _skill, _user, _hitTile )
{
	if (_skill == null || _hitTile == null) return;
	if (("m" in _skill) && ("WX_PendingImpactVfx" in _skill.m) && _skill.m.WX_PendingImpactVfx != null)
	{
		local originTile = (_user != null && _user.isPlacedOnMap()) ? _user.getTile() : null;
		::Wuxia.VFX.playTargetImpactVfx(_skill, _user, originTile, _hitTile, _skill.m.WX_PendingImpactVfx);
		return;
	}
	::Wuxia.VFX.playWeaponQiAura(_skill, _user, _hitTile);
};

// Non-destructive hook on `scripts/skills/skill`:
// - `onUse` plays non-attack folkloric sorcery VFX and cleans up deferred impact state;
// - `attackEntity` triggers target impact slashes ONLY when `hit == true` so missed attacks cleanly dodge!
if ("HooksMod" in ::Wuxia && ::Wuxia.HooksMod != null)
{
	::Wuxia.HooksMod.hook("scripts/skills/skill", function( q )
	{
		q.onUse = @(__original) function( _user, _targetTile )
		{
			::Wuxia.VFX.playFolkloricCastVfx(this, _user, _targetTile);
			local ret = false;
			try
			{
				ret = __original(_user, _targetTile);
			}
			catch (err)
			{
				if ("WX_PendingImpactVfx" in this.m) this.m.WX_PendingImpactVfx = null;
				throw err;
			}
			if ("WX_PendingImpactVfx" in this.m) this.m.WX_PendingImpactVfx = null;
			return ret;
		};

		q.attackEntity = @(__original) function( _user, _targetEntity, _allowDiversion = true )
		{
			local targetTile = (_targetEntity != null && _targetEntity.isPlacedOnMap()) ? _targetEntity.getTile() : null;
			local hit = __original(_user, _targetEntity, _allowDiversion);
			if (hit)
			{
				local finalTile = (_targetEntity != null && _targetEntity.isPlacedOnMap()) ? _targetEntity.getTile() : targetTile;
				if (finalTile != null)
					::Wuxia.VFX.onAttackLanded(this, _user, finalTile);
			}
			return hit;
		};
	});
}
