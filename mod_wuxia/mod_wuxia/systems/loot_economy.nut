// M3 System: Enemy Wuxia Loadouts, Identical "What You See Is What You Drop" Loot & Town Shop Stocking

::Wuxia.Loot.EnemyLoadouts <- {
	// Tier 1: Bandits / Outcasts (大路货 — strictly low drop rates on trash mobs)
	bandit_thug = { Script = "scripts/entity/tactical/enemies/bandit_thug", DropChance = 6, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_tuna",      Tier = 1, Weight = 40 },
		{ ManualID = "wx_manual_wuhudao",   Tier = 1, Weight = 35 },
		{ ManualID = "wx_manual_jichujian", Tier = 1, Weight = 25 }
	] },
	bandit_raider = { Script = "scripts/entity/tactical/enemies/bandit_raider", DropChance = 9, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_xingqi",    Tier = 1, Weight = 30 },
		{ ManualID = "wx_manual_wuhudao",   Tier = 2, Weight = 30 },
		{ ManualID = "wx_manual_heifeng",   Tier = 1, Weight = 25 },
		{ ManualID = "wx_manual_yingpi",    Tier = 1, Weight = 15 }
	] },
	bandit_marksman = { Script = "scripts/entity/tactical/enemies/bandit_marksman", DropChance = 9, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_xiushou",   Tier = 2, Weight = 45 },
		{ ManualID = "wx_manual_jianbu",    Tier = 1, Weight = 30 },
		{ ManualID = "wx_manual_baoyu",     Tier = 1, Weight = 25 },
		{ ManualID = "wx_manual_yanxing",   Tier = 2, Weight = 30 }
	] },
	// Tier 2: Elites / Sect Swordsmen / Mercenaries (门派上乘残页)
	mercenary = { Script = "scripts/entity/tactical/humans/mercenary", DropChance = 18, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_songtao",   Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_weiyuan",   Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_qingfeng",  Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_tiebushan", Tier = 2, Weight = 25 }
	] },
	// Tier 3: Leaders / Bosses (上乘/绝学残页为主)
	bandit_leader = { Script = "scripts/entity/tactical/enemies/bandit_leader", DropChance = 38, IsBoss = true, CustomBust = "wx_enemy_bandit_lord", Manuals = [
		{ ManualID = "wx_manual_xuesha",    Tier = 2, Weight = 30 },
		{ ManualID = "wx_manual_duanyue",   Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_tiebushan", Tier = 2, Weight = 20 },
		{ ManualID = "wx_manual_heifeng",   Tier = 3, Weight = 15 }
	] },
	swordmaster = { Script = "scripts/entity/tactical/humans/swordmaster", DropChance = 52, IsBoss = true, IsGrandmaster = true, CustomBust = "wx_enemy_sword_saint", Manuals = [
		{ ManualID = "wx_manual_guiyuan",   Tier = 3, Weight = 25 },
		{ ManualID = "wx_manual_huifeng",   Tier = 3, Weight = 30 },
		{ ManualID = "wx_manual_taxue",     Tier = 3, Weight = 20 },
		{ ManualID = "wx_manual_jinchan",   Tier = 3, Weight = 15 },
		{ ManualID = "wx_manual_tianwai",   Tier = 2, Weight = 10 }
	] },

	// M4.2 Ecology Expansion: 塞外马贼 (Nomads)
	nomad_outlaw = { Troop = "NomadOutlaw", DropChance = 10, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_hanhai_wandao_ru", Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_liusha_bu",        Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_liesha_tuna",      Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_chanzi",           Tier = 2, Weight = 25 }
	] },
	nomad_leader = { Troop = "NomadLeader", DropChance = 38, IsBoss = true, CustomBust = "wx_enemy_nomad_khan", Manuals = [
		{ ManualID = "wx_manual_hanhai_xinyue",    Tier = 3, Weight = 30 },
		{ ManualID = "wx_manual_mingzun_huo",      Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_hanhai_guke",      Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_hanhai_shishen",   Tier = 2, Weight = 20 },
		{ ManualID = "wx_manual_hamagong",         Tier = 2, Weight = 20 }
	] },
	southern_assassin = { Troop = "Assassin", DropChance = 50, IsBoss = true, IsGrandmaster = true, CustomBust = "wx_enemy_blade_dancer", Manuals = [
		{ ManualID = "wx_manual_youming_bi",       Tier = 3, Weight = 30 },
		{ ManualID = "wx_manual_youming_guibu",    Tier = 3, Weight = 25 },
		{ ManualID = "wx_manual_yinsha_guixi",     Tier = 3, Weight = 25 },
		{ ManualID = "wx_manual_mingzun_shenghuoling", Tier = 3, Weight = 20 }
	] },

	// M4.2 Ecology Expansion: 常规官军与基层战兵 (Standard Human Line Troops — lightweight Tier-1 martial cohesion)
	footman = { Troop = "Footman", DropChance = 7, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_tiebushan", Tier = 1, Weight = 50 },
		{ ManualID = "wx_manual_wuhudao",   Tier = 1, Weight = 50 }
	] },
	billman = { Troop = "Billman", DropChance = 7, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_xingqi",    Tier = 1, Weight = 50 },
		{ ManualID = "wx_manual_weiyuan",   Tier = 1, Weight = 50 }
	] },
	arbalester = { Troop = "Arbalester", DropChance = 7, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_xiushou",   Tier = 1, Weight = 55 },
		{ ManualID = "wx_manual_jianbu",    Tier = 1, Weight = 45 }
	] },
	conscript = { Troop = "Conscript", DropChance = 7, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_liesha_tuna",      Tier = 1, Weight = 50 },
		{ ManualID = "wx_manual_hanhai_wandao_ru", Tier = 1, Weight = 50 }
	] },
	gunner = { Troop = "Gunner", DropChance = 9, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_shazhou_leihuo_chong", Tier = 1, Weight = 60 },
		{ ManualID = "wx_manual_jianbu",               Tier = 1, Weight = 40 }
	] },
	nomad_cutthroat = { Troop = "NomadCutthroat", DropChance = 6, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_liesha_tuna", Tier = 1, Weight = 50 },
		{ ManualID = "wx_manual_liusha_bu",   Tier = 1, Weight = 50 }
	] },
	barbarian_thrall = { Troop = "BarbarianThrall", DropChance = 6, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_heishui_xue",     Tier = 1, Weight = 50 },
		{ ManualID = "wx_manual_heishui_kuangfu", Tier = 1, Weight = 50 }
	] },

	// M4.2 Ecology Expansion: 地方藩镇与军镇高手 (Noble Military & City-State Elites)
	standard_bearer = { Troop = "StandardBearer", DropChance = 20, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_yaqi_zhenzhen",    Tier = 2, Weight = 40 },
		{ ManualID = "wx_manual_juyiling",         Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_baima_zhenshu",    Tier = 2, Weight = 25 }
	] },
	sergeant = { Troop = "Sergeant", DropChance = 18, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_juyiling",         Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_baima_zhenshu",    Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_luoyang_changfeng", Tier = 2, Weight = 30 }
	] },
	knight = { Troop = "Knight", DropChance = 42, IsBoss = true, CustomBust = "wx_enemy_garrison_capt", Manuals = [
		{ ManualID = "wx_manual_hengshan_tiebi",   Tier = 3, Weight = 30 },
		{ ManualID = "wx_manual_yanmen_zhenjun",   Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_cuijia_liuhua",    Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_shaolin_jinzhong", Tier = 2, Weight = 20 },
		{ ManualID = "wx_manual_babao_liangyinqiang", Tier = 2, Weight = 20 }
	] },
	officer = { Troop = "Officer", DropChance = 38, IsBoss = true, CustomBust = "wx_enemy_shenji_officer", Manuals = [
		{ ManualID = "wx_manual_huaiyang_jindao",  Tier = 3, Weight = 30 },
		{ ManualID = "wx_manual_shazhou_leihuo_chong", Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_wuwei_shuaiqi",    Tier = 2, Weight = 20 },
		{ ManualID = "wx_manual_gufeng",           Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_taiyuan_huoyandao", Tier = 2, Weight = 20 }
	] },
	gladiator = { Troop = "Gladiator", DropChance = 20, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_qianjiang_nuchao_zhang", Tier = 2, Weight = 30 },
		{ ManualID = "wx_manual_shuofang_jingua",  Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_lingnan_tengdun",  Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_jinchan",          Tier = 2, Weight = 20 }
	] },

	// M4.2 Ecology Expansion: 关外铁骑战帮 (Barbarians)
	barbarian_marauder = { Troop = "BarbarianMarauder", DropChance = 10, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_heishui_xue",      Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_heishui_kuangfu",  Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_xueyuan_zong",     Tier = 2, Weight = 30 }
	] },
	barbarian_chosen = { Troop = "BarbarianChampion", DropChance = 42, IsBoss = true, CustomBust = "wx_enemy_barb_chosen", Manuals = [
		{ ManualID = "wx_manual_heishui_xueming_fu", Tier = 3, Weight = 35 },
		{ ManualID = "wx_manual_pishan_kaitian",   Tier = 2, Weight = 30 },
		{ ManualID = "wx_manual_zhenyue_qianjun",  Tier = 2, Weight = 35 }
	] },

	// M4.2 Ecology Expansion: 五毒奇门伏兵 (Goblins)
	goblin_ambusher = { Troop = "GoblinAmbusher", DropChance = 10, IsBoss = false, CustomBust = "wx_enemy_wudu_blowgun", Manuals = [
		{ ManualID = "wx_manual_wudu_chuijian",    Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_wudu_shehang",     Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_wudu",             Tier = 2, Weight = 30 }
	] },
	goblin_overseer = { Troop = "GoblinOverseer", DropChance = 40, IsBoss = true, CustomBust = "wx_enemy_wudu_overseer", Manuals = [
		{ ManualID = "wx_manual_wudu_wanxian",     Tier = 3, Weight = 35 },
		{ ManualID = "wx_manual_tangmen_guanyin_lei", Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_wudu_jinshe_bian", Tier = 2, Weight = 30 }
	] },

	// M4.2 Ecology Expansion: 邪派炼体药人 (Orcs)
	orc_berserker = { Troop = "OrcBerserker", DropChance = 14, IsBoss = false, CustomBust = "wx_enemy_bronze_yaoren", Manuals = [
		{ ManualID = "wx_manual_xuesha",    Tier = 2, Weight = 50 },
		{ ManualID = "wx_manual_duanyue",   Tier = 2, Weight = 50 }
	] },
	orc_warrior = { Troop = "OrcWarrior", DropChance = 16, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_tiebushan", Tier = 3, Weight = 60 },
		{ ManualID = "wx_manual_jinzhong",  Tier = 2, Weight = 40 }
	] },
	orc_warlord = { Troop = "OrcWarlord", DropChance = 52, IsBoss = true, IsGrandmaster = true, CustomBust = "wx_enemy_yaoren_lord", Manuals = [
		{ ManualID = "wx_manual_jinzhong",  Tier = 3, Weight = 45 },
		{ ManualID = "wx_manual_xuesha",    Tier = 3, Weight = 30 },
		{ ManualID = "wx_manual_duanyue",   Tier = 3, Weight = 25 }
	] },

	// M4.2 Ecology Expansion: 前朝古墓与湘西尸傀邪宗 (Undead & Ancient Dead Elites)
	skeleton_heavy = { Troop = "SkeletonHeavy", DropChance = 15, IsBoss = false, CustomBust = "wx_enemy_tomb_automaton", Manuals = [
		{ ManualID = "wx_manual_tiebushan", Tier = 3, Weight = 55 },
		{ ManualID = "wx_manual_weiyuan",   Tier = 3, Weight = 45 }
	] },
	necromancer = { Troop = "Necromancer", DropChance = 42, IsBoss = true, CustomBust = "wx_enemy_corpse_taoist", Manuals = [
		{ ManualID = "wx_manual_zhenhun",   Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_xuesha",    Tier = 2, Weight = 40 },
		{ ManualID = "wx_manual_wudu",      Tier = 3, Weight = 25 }
	] },
	vampire = { Troop = "Vampire", DropChance = 38, IsBoss = true, CustomBust = "wx_enemy_blood_vampire", Manuals = [
		{ ManualID = "wx_manual_suodi",     Tier = 3, Weight = 40 },
		{ ManualID = "wx_manual_heifeng",   Tier = 3, Weight = 35 },
		{ ManualID = "wx_manual_zhenhun",   Tier = 2, Weight = 25 }
	] }
};

::Wuxia.Loot.resolveEnemyScript <- function( _profile )
{
	if ("Script" in _profile && _profile.Script != null && _profile.Script != "")
		return _profile.Script;
	if ("Troop" in _profile && (_profile.Troop in ::Const.World.Spawn.Troops))
		return ::Const.World.Spawn.Troops[_profile.Troop].Script;
	return null;
};

::Wuxia.Loot.applyLoadoutToEnemy <- function( _actor, _archetypeKey )
{
	if (_actor == null) return;
	local profiles = _archetypeKey in ::Wuxia.Config.Fighters ? ::Wuxia.Config.Fighters : ::Wuxia.Loot.EnemyLoadouts;
	if (!(_archetypeKey in profiles)) return;
	local loadout = profiles[_archetypeKey].Manuals;
	local c = ::Wuxia.Slots.getContainer(_actor);
	if (c == null) return;

	_actor.m.WX_LoadoutKey <- _archetypeKey;

	local prof = profiles[_archetypeKey];
	local isBossOrElite = (("IsBoss" in prof) && prof.IsBoss) || loadout.len() >= 3;
	local threat = ("CombatRules" in ::Wuxia && "getCampaignThreatProfile" in ::Wuxia.CombatRules)
		? ::Wuxia.CombatRules.getCampaignThreatProfile() : { era = 0 };
	local era = threat.era;

	// Equip archetype manuals and dynamically scale Manual Tiers (`一重 -> 二重 -> 三重大成`) with campaign Era!
	local usedSlots = {};
	local neigongCount = 0;
	local qinggongCount = 0;

	foreach (entry in loadout)
	{
		local def = ::Wuxia.Slots.getManualDef(entry.ManualID);
		if (def == null) continue;
		if (def.Category == "neigong" && neigongCount >= 2) continue;
		if (def.Category == "qinggong" && qinggongCount >= 2) continue;

		local dynTier = entry.Tier;
		if (era == 1)
		{
			if (isBossOrElite) dynTier = ::Math.min(3, dynTier + 1);
			else if (::Math.rand(1, 100) <= 45) dynTier = ::Math.min(2, dynTier + 1);
		}
		else if (era == 2)
		{
			dynTier = ::Math.min(isBossOrElite ? 3 : 2, dynTier + 1);
			if (!isBossOrElite && entry.Tier >= 2) dynTier = ::Math.min(3, entry.Tier + 1);
		}
		else if (era == 3)
		{
			dynTier = isBossOrElite ? 3 : ::Math.min(3, ::Math.max(2, dynTier + (::Math.rand(1, 100) <= 50 ? 2 : 1)));
		}
		else if (era >= 4)
		{
			dynTier = 3;
		}

		for (local i = 0; i < ::Wuxia.Config.SlotLayout.len(); i = ++i)
		{
			if (i in usedSlots) continue;
			if (::Wuxia.Slots.isCategoryAllowedInSlot(i, def.Category))
			{
				c.m.Slots[i].ManualID   = entry.ManualID;
				c.m.Slots[i].Tier       = dynTier;
				c.m.Slots[i].Exp        = 0;
				c.m.Slots[i].IsFragment = false;
				usedSlots[i] <- true;
				if (def.Category == "neigong") neigongCount += 1;
				else if (def.Category == "qinggong") qinggongCount += 1;
				break;
			}
		}
	}

	// Unlock thematic supplementary slots in Era 1..4 (strictly obeying AGENTS.md <= 2 Neigong, <= 2 Qinggong, 7-slot cap)
	local tryFillExtraManual = function( _manualID, _tier )
	{
		local exDef = ::Wuxia.Slots.getManualDef(_manualID);
		if (exDef == null) return false;
		if (exDef.Category == "neigong" && neigongCount >= 2) return false;
		if (exDef.Category == "qinggong" && qinggongCount >= 2) return false;
		foreach (slCheck in c.m.Slots)
		{
			if (slCheck.ManualID == _manualID) return false;
		}
		for (local sIdx = 0; sIdx < ::Wuxia.Config.SlotLayout.len(); sIdx = ++sIdx)
		{
			if (sIdx in usedSlots) continue;
			if (::Wuxia.Slots.isCategoryAllowedInSlot(sIdx, exDef.Category))
			{
				c.m.Slots[sIdx].ManualID   = _manualID;
				c.m.Slots[sIdx].Tier       = ::Math.max(1, ::Math.min(3, _tier));
				c.m.Slots[sIdx].Exp        = 0;
				c.m.Slots[sIdx].IsFragment = false;
				usedSlots[sIdx] <- true;
				if (exDef.Category == "neigong") neigongCount += 1;
				else if (exDef.Category == "qinggong") qinggongCount += 1;
				return true;
			}
		}
		return false;
	};

	if ((era >= 2 || (era == 1 && isBossOrElite)) && qinggongCount == 0)
	{
		local qgID = (era >= 3 && isBossOrElite) ? "wx_manual_taxue" : ((era >= 2 && isBossOrElite) ? "wx_manual_yanxing" : "wx_manual_jianbu");
		tryFillExtraManual(qgID, isBossOrElite ? ::Math.min(3, era) : ::Math.min(2, era));
	}
	if (era >= 2)
	{
		local bodyArmorMax = (::Wuxia.hasMember(_actor, "getArmorMax")) ? _actor.getArmorMax(::Const.BodyPart.Body) : 0;
		local hlID = (bodyArmorMax >= 135)
			? ((era >= 4 && isBossOrElite) ? "wx_manual_jinzhong" : "wx_manual_tiebushan")
			: (isBossOrElite ? "wx_manual_jinchan" : "wx_manual_yingpi");
		tryFillExtraManual(hlID, isBossOrElite ? ::Math.min(3, era) : ::Math.max(1, era - 1));
	}
	if (era >= 3 && (isBossOrElite || era >= 4) && neigongCount < 2)
	{
		local mainDef = (c.m.Slots[0].ManualID != null) ? ::Wuxia.Slots.getManualDef(c.m.Slots[0].ManualID) : null;
		local mainEl = (mainDef != null && mainDef.Element != null) ? mainDef.Element : "neutral";
		local ngID = "wx_manual_songtao";
		if (isBossOrElite)
			ngID = (mainEl == "yang") ? "wx_manual_songtao" : "wx_manual_guiyuan";
		else
			ngID = (mainEl == "yin" || mainEl == "evil") ? "wx_manual_tuna" : "wx_manual_xingqi";
		tryFillExtraManual(ngID, isBossOrElite ? ::Math.min(3, era - 1) : 2);
	}

	c.syncGrantedSkills();
	local skills = _actor.getSkills();

	// Late-game Jianghu leaders & grandmasters consume battle elixirs before combat in Era 3..4
	if (era >= 3 && (isBossOrElite || (era >= 4 && ::Math.rand(1, 100) <= 35)) && !skills.hasSkill("effects.wx_pill_battle_buff"))
	{
		local pillBuff = ::new("scripts/skills/effects/wx_pill_battle_buff");
		pillBuff.addPillBuff(isBossOrElite ? "buff_zhuyu" : "buff_hugu");
		if (era >= 4 && isBossOrElite)
			pillBuff.addPillBuff("buff_jinzun");
		skills.add(pillBuff);
	}

	skills.update();

	// Anti-double-stacking fairness: strip overlapping vanilla defensive perks when an enemy equips equivalent Wuxia manuals!
	// Note: `perk.brawny` and `perk.steel_brow` are granted directly via `GrantSkills` in `syncGrantedSkills()` (non-stacking),
	// so removing them here would strip the manual's own granted perk.
	if (c.m.CachedAggFlags != null)
	{
		local agg = c.m.CachedAggFlags;
		if (agg.LightArmorMitigation > 0 && skills.hasSkill("perk.nimble"))
			skills.removeByID("perk.nimble");
		if (agg.HeavyArmorScale > 0 && skills.hasSkill("perk.battle_forged"))
			skills.removeByID("perk.battle_forged");
		if (agg.InitToDefRatio > 0 && skills.hasSkill("perk.dodge"))
			skills.removeByID("perk.dodge");
		if ((agg.StaffGuard || agg.UnderdogGuard) && skills.hasSkill("perk.underdog"))
			skills.removeByID("perk.underdog");
		if (agg.EmptyOffhandPen > 0 && skills.hasSkill("perk.duelist"))
			skills.removeByID("perk.duelist");
		skills.update();
	}

	// Ensure martial enemies possess the matching vanilla AI behavior drivers for their Wuxia tactical skills!
	if (::Wuxia.hasMember(_actor, "getAIAgent") && _actor.getAIAgent() != null)
	{
		local agent = _actor.getAIAgent();
		local addedBeh = false;
		local ensureBeh = function( _agent, _behID, _behScript )
		{
			try
			{
				if (::Wuxia.hasMember(_agent, "getBehavior") && _agent.getBehavior(_behID) == null)
				{
					_agent.addBehavior(::new(_behScript));
					addedBeh = true;
				}
			}
			catch (_e) {}
		};
		local hasPrefix = function( _skContainer, _pfx )
		{
			foreach (s in _skContainer.getAllSkillsOfType(::Const.SkillType.Active))
			{
				if (s != null && s.getID().find(_pfx) == 0) return true;
			}
			return false;
		};
		if (skills.hasSkill("actives.wx_meditate") || hasPrefix(skills, "actives.wx_neigong_"))
			ensureBeh(agent, ::Const.AI.Behavior.ID.Recover, "scripts/ai/tactical/behaviors/ai_recover");
		if (hasPrefix(skills, "actives.wx_neigong_") || hasPrefix(skills, "actives.wx_henglian_") || hasPrefix(skills, "actives.wx_shield_"))
			ensureBeh(agent, ::Const.AI.Behavior.ID.Indomitable, "scripts/ai/tactical/behaviors/ai_indomitable");
		if (skills.hasSkill("actives.wx_blood_burst"))
			ensureBeh(agent, ::Const.AI.Behavior.ID.Adrenaline, "scripts/ai/tactical/behaviors/ai_adrenaline");
		if (hasPrefix(skills, "actives.wx_qinggong_"))
			ensureBeh(agent, ::Const.AI.Behavior.ID.Disengage, "scripts/ai/tactical/behaviors/ai_disengage");
		if (hasPrefix(skills, "actives.wx_tactics_") || skills.hasSkill("actives.wx_staff_challenge"))
		{
			ensureBeh(agent, ::Const.AI.Behavior.ID.Warcry, "scripts/ai/tactical/behaviors/ai_warcry");
			ensureBeh(agent, ::Const.AI.Behavior.ID.Rally, "scripts/ai/tactical/behaviors/ai_rally");
		}
		if (skills.hasSkill("actives.wx_sword_counter") || skills.hasSkill("actives.wx_poise_charge"))
			ensureBeh(agent, ::Const.AI.Behavior.ID.Riposte, "scripts/ai/tactical/behaviors/ai_defend_riposte");
		if (skills.hasSkill("actives.wx_axe_split"))
			ensureBeh(agent, ::Const.AI.Behavior.ID.SplitShield, "scripts/ai/tactical/behaviors/ai_attack_splitshield");
		if (skills.hasSkill("actives.wx_shield_tiebi") || skills.hasSkill("actives.wx_shield_xuanwu"))
			ensureBeh(agent, ::Const.AI.Behavior.ID.ShieldWall, "scripts/ai/tactical/behaviors/ai_defend_shieldwall");
		if (skills.hasSkill("actives.wx_shield_bash_qi"))
			ensureBeh(agent, ::Const.AI.Behavior.ID.KnockBack, "scripts/ai/tactical/behaviors/ai_defend_knock_back");
		if (skills.hasSkill("actives.wx_saber_sweep") || skills.hasSkill("actives.wx_pole_sweep") || skills.hasSkill("actives.wx_axe_whirl")
			|| skills.hasSkill("actives.wx_sword_wanjian") || skills.hasSkill("actives.wx_saber_abi") || skills.hasSkill("actives.wx_saber_kuanglan")
			|| skills.hasSkill("actives.wx_fist_rulai") || skills.hasSkill("actives.wx_pole_pojun") || skills.hasSkill("actives.wx_staff_qingou") || skills.hasSkill("actives.wx_hammer_pocheng"))
			ensureBeh(agent, ::Const.AI.Behavior.ID.Swing, "scripts/ai/tactical/behaviors/ai_attack_swing");
		if (addedBeh && ::Wuxia.hasMember(agent, "finalizeBehaviors"))
		{
			try { agent.finalizeBehaviors(); } catch (_eFin) {}
		}
	}
};

::Wuxia.Loot.pickWeightedManual <- function( _loadout )
{
	local totalW = 0;
	foreach (e in _loadout) totalW += e.Weight;
	if (totalW <= 0) return null;

	local roll = ::Math.rand(1, totalW);
	local acc = 0;
	foreach (e in _loadout)
	{
		acc += e.Weight;
		if (roll <= acc) return e.ManualID;
	}
	return _loadout[0].ManualID;
};

::Wuxia.Loot.getEquippedDropPool <- function( _actor, _profile )
{
	local pool = [];
	local c = _actor.getSkills().getSkillByID("special.wx_martial_container");
	if (c == null) return pool;
	local equipped = {};
	foreach (slot in c.m.Slots)
		if (slot.ManualID != null && slot.Tier > 0) equipped[slot.ManualID] <- true;
	foreach (entry in _profile.Manuals)
		if (entry.ManualID in equipped) pool.push(entry);
	return pool;
};

::Wuxia.Loot.onEnemyKilledDrop <- function( _tile, _profile, _pool )
{
	local isBoss = _profile.IsBoss;
	local isGrandmaster = ("IsGrandmaster" in _profile) && _profile.IsGrandmaster;

	// Strictly gated drop rates: common street manuals or single torn pages (`wx_page_item`)
	local effDropChance = _profile.DropChance;
	if ("World" in getroottable() && ::World != null && ("Assets" in ::World) && ::World.Assets != null && ::World.Assets.getOrigin() != null && ::World.Assets.getOrigin().getID() == "scenario.wx_origin_blood_remnant")
	{
		effDropChance = ::Math.min(100, ::Math.round(effDropChance * 1.25).tointeger());
	}
	if (_pool.len() > 0 && ::Math.rand(1, 100) <= effDropChance)
	{
		local manualID = ::Wuxia.Loot.pickWeightedManual(_pool);
		local def = ::Wuxia.Slots.getManualDef(manualID);
		if (def != null)
		{
			if (def.Quality == "common" || (isGrandmaster && ::Math.rand(1, 100) <= 8))
			{
				local mItem = ::new("scripts/items/misc/wx_manual_item");
				mItem.initManual(manualID);
				mItem.drop(_tile);
			}
			else if (def.FragmentsNeeded > 0)
			{
				local pageItem = ::new("scripts/items/misc/wx_page_item");
				pageItem.initPages(manualID, 1);
				pageItem.drop(_tile);
			}
		}
	}

	// Boss bonus drop: basic healing/qi pills only (`洗髓丹` is strictly reserved for Boss-herb Alchemy!)
	if (isBoss && ::Math.rand(1, 100) <= (isGrandmaster ? 24 : 15))
	{
		local pillRoll = ::Math.rand(1, 100);
		local pid = "wx_pill_jinchuang";
		if (isGrandmaster && pillRoll <= 20) pid = "wx_pill_humai";
		else if (pillRoll <= 55)             pid = "wx_pill_ningshen";
		else if (pillRoll <= 85)             pid = "wx_pill_huxin";

		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill(pid);
		pill.drop(_tile);
	}
};

::Wuxia.Loot.getManualIDsByQuality <- function( _quality )
{
	local list = [];
	foreach (id, def in ::Wuxia.Config.Manuals)
	{
		if (def.Quality == _quality) list.push(id);
	}
	return list;
};

// Random events are scored on the moving world map, including the approach to a town.
::Wuxia.Loot.isNearMarketTown <- function()
{
	local player = ::World.State.getPlayer();
	if (player == null) return false;
	local tile = player.getTile();
	foreach (town in ::World.EntityManager.getSettlements())
		if (town.isAlliedWithPlayer() && town.getTile().getDistanceTo(tile) <= 2) return true;
	return false;
};

::Wuxia.Loot.purchaseEventItem <- function( _item, _price, _successScreen )
{
	if (::World.Assets.getMoney() < _price) return "NoMoney";
	if (_item != null && ::Wuxia.Library.isAutoStoreEnabled())
	{
		local id = _item.getID();
		if (id == "misc.wx_manual_item")
		{
			::Wuxia.Library.addManual(_item.getManualID(), 1);
			::World.Assets.addMoney(-_price);
			return _successScreen;
		}
		else if (id == "misc.wx_page_item")
		{
			::Wuxia.Library.addPages(_item.getManualID(), _item.getPageCount());
			::World.Assets.addMoney(-_price);
			return _successScreen;
		}
	}
	if (::World.Assets.getStash().add(_item) == null) return "NoRoom";
	::World.Assets.addMoney(-_price);
	return _successScreen;
};

::Wuxia.Loot.makeNoRoomScreen <- function()
{
	return {
		ID = "NoRoom", Text = "行囊已满，放不下这件货物。你收起银两，辞别了对方。",
		Image = "", List = [], Characters = [],
		Options = [{ Text = "改日再来。", function getResult( _event ) { return 0; } }],
		function start( _event ) {}
	};
};

::Wuxia.Loot.injectTownShopStock <- function( _stash )
{
	if (_stash == null) return;

	// Avoid over-stuffing if shop already has a full Wuxia manual shelf (4 balanced common books)
	local existingManuals = 0;
	local seenManuals = {};
	foreach (it in _stash.getItems())
	{
		if (it != null && it.getID() == "misc.wx_manual_item")
		{
			existingManuals += 1;
			if (::Wuxia.hasMember(it, "getManualID"))
				seenManuals[it.getManualID()] <- true;
		}
	}
	if (existingManuals < 4)
	{
		// Stock 4 category-balanced common manuals (1 Neigong + 1 Qinggong/Henglian + 2 Waigong)
		// to eliminate early-game RNG droughts when filling 12-bro starter slots!
		local byCat = { neigong = [], support = [], waigong = [] };
		foreach (mid, def in ::Wuxia.Config.Manuals)
		{
			if (def.Quality != "common") continue;
			if (def.Category == "neigong") byCat.neigong.push(mid);
			else if (def.Category == "waigong") byCat.waigong.push(mid);
			else byCat.support.push(mid);
		}
		local desiredPools = [byCat.neigong, byCat.support, byCat.waigong, byCat.waigong];
		for (local i = existingManuals; i < 4; i = ++i)
		{
			local pool = desiredPools[i % desiredPools.len()];
			if (pool.len() == 0) pool = ::Wuxia.Loot.getManualIDsByQuality("common");
			local picked = null;
			for (local tries = 0; tries < 8 && pool.len() > 0; tries = ++tries)
			{
				local cand = pool[::Math.rand(0, pool.len() - 1)];
				if (!(cand in seenManuals)) { picked = cand; break; }
			}
			if (picked == null && pool.len() > 0)
				picked = pool[::Math.rand(0, pool.len() - 1)];
			if (picked != null)
			{
				seenManuals[picked] <- true;
				local mItem = ::new("scripts/items/misc/wx_manual_item");
				mItem.initManual(picked);
				_stash.add(mItem);
			}
		}
	}

	// Stock starter paired cloth wraps (麻布缠手) in marketplace if none present
	local hasWraps = false;
	foreach (it in _stash.getItems())
	{
		if (it != null && it.getID() == "weapon.wx_fist_wraps") { hasWraps = true; break; }
	}
	if (!hasWraps)
	{
		_stash.add(::new("scripts/items/weapons/wx_fist_wraps"));
	}

	// Strictly stock ONLY basic medical & common battle-prep powders in town markets!
	// Rare elixirs, wash pills, Neidan cores & Spirit Herbs are NEVER sold in ordinary town shops.
	local shopPills = ["wx_pill_jinchuang", "wx_pill_huxin"];
	if (::Math.rand(1, 100) <= 35)
		shopPills.push("wx_pill_ningshen");
	if (::Math.rand(1, 100) <= 45)
	{
		local basicPrepPool = ["wx_pill_huoluo", "wx_pill_qingxin", "wx_pill_hugu", "wx_pill_dingshen"];
		shopPills.push(basicPrepPool[::Math.rand(0, basicPrepPool.len() - 1)]);
	}
	foreach (pid in shopPills)
	{
		local p = ::new("scripts/items/misc/wx_pill_item");
		p.initPill(pid);
		_stash.add(p);
	}
};

::Wuxia.Loot.injectWeaponsmithStock <- function( _stash )
{
	if (_stash == null) return;
	local existingFist = 0;
	foreach (it in _stash.getItems())
	{
		if (it != null && (it.getID() == "weapon.wx_fist_iron" || it.getID() == "weapon.wx_fist_heavy"))
			existingFist += 1;
	}
	if (existingFist >= 1) return;

	_stash.add(::new("scripts/items/weapons/wx_fist_iron"));
	if (::Math.rand(1, 100) <= 35)
	{
		_stash.add(::new("scripts/items/weapons/wx_fist_heavy"));
	}
	// Famous Red Relics (`传世神兵`) are strictly earned via Stronghold/Boss conquests & Ghost Market auctions, never sold in town smithies!
};
