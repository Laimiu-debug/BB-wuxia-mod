// UI Data serialization helpers + data_helper hook for Character Screen (武学修为 & 藏经阁) & Tactical HUD

::Wuxia.Settings <- {
	syncFromWorldFlags = function()
	{
		if (!("World" in getroottable()) || ::World == null || !("Flags" in ::World) || ::World.Flags == null)
			return;
		local f = ::World.Flags;
		if ("VFX" in ::Wuxia && "Config" in ::Wuxia.VFX)
		{
			if (f.has("wx_cfg_vfx"))    ::Wuxia.VFX.Config.ShowSkillVfx      = f.get("wx_cfg_vfx") ? true : false;
			if (f.has("wx_cfg_motion")) ::Wuxia.VFX.Config.EnableActorMotion = f.get("wx_cfg_motion") ? true : false;
			if (f.has("wx_cfg_cutin"))  ::Wuxia.VFX.Config.ShowSkillCutIn    = f.get("wx_cfg_cutin") ? true : false;
			if (f.has("wx_cfg_sfx"))    ::Wuxia.VFX.Config.EnableWuxiaSfx    = f.get("wx_cfg_sfx") ? true : false;
		}
		if ("CombatRules" in ::Wuxia && f.has("wx_cfg_lock_era0"))
		{
			::Wuxia.CombatRules.ForcedThreatEra = f.get("wx_cfg_lock_era0") ? 0 : -1;
		}
	},

	getPayload = function()
	{
		::Wuxia.Settings.syncFromWorldFlags();
		local vfxCfg = ("VFX" in ::Wuxia && "Config" in ::Wuxia.VFX) ? ::Wuxia.VFX.Config : {};
		local threat = ("CombatRules" in ::Wuxia && "getCampaignThreatProfile" in ::Wuxia.CombatRules)
			? ::Wuxia.CombatRules.getCampaignThreatProfile()
			: { era = 0, label = "初入江湖" };
		return {
			ok                = true,
			showSkillVfx      = ("ShowSkillVfx" in vfxCfg) ? vfxCfg.ShowSkillVfx : true,
			enableActorMotion = ("EnableActorMotion" in vfxCfg) ? vfxCfg.EnableActorMotion : true,
			showSkillCutIn    = ("ShowSkillCutIn" in vfxCfg) ? vfxCfg.ShowSkillCutIn : false,
			enableWuxiaSfx    = ("EnableWuxiaSfx" in vfxCfg) ? vfxCfg.EnableWuxiaSfx : true,
			autoStoreLibrary  = ::Wuxia.Library.isAutoStoreEnabled(),
			dynamicThreatOn   = !("CombatRules" in ::Wuxia) || ::Wuxia.CombatRules.ForcedThreatEra < 0,
			currentEra        = threat.era,
			currentEraLabel   = threat.label
		};
	},

	updateSetting = function( _key, _val )
	{
		local bVal = _val ? true : false;
		local hasWF = ("World" in getroottable()) && ::World != null && ("Flags" in ::World) && ::World.Flags != null;
		if (_key == "showSkillVfx" && ("VFX" in ::Wuxia))
		{
			::Wuxia.VFX.setOptions(bVal, null);
			if (hasWF) ::World.Flags.set("wx_cfg_vfx", bVal);
		}
		else if (_key == "enableActorMotion" && ("VFX" in ::Wuxia))
		{
			::Wuxia.VFX.Config.EnableActorMotion = bVal;
			if (hasWF) ::World.Flags.set("wx_cfg_motion", bVal);
		}
		else if (_key == "showSkillCutIn" && ("VFX" in ::Wuxia))
		{
			::Wuxia.VFX.Config.ShowSkillCutIn = bVal;
			if (hasWF) ::World.Flags.set("wx_cfg_cutin", bVal);
		}
		else if (_key == "enableWuxiaSfx" && ("VFX" in ::Wuxia))
		{
			::Wuxia.VFX.Config.EnableWuxiaSfx = bVal;
			if (hasWF) ::World.Flags.set("wx_cfg_sfx", bVal);
		}
		else if (_key == "autoStoreLibrary")
		{
			::Wuxia.Library.setAutoStoreEnabled(bVal);
		}
		else if (_key == "dynamicThreatOn" && ("CombatRules" in ::Wuxia))
		{
			::Wuxia.CombatRules.ForcedThreatEra = bVal ? -1 : 0;
			if (hasWF) ::World.Flags.set("wx_cfg_lock_era0", !bVal);
		}
		return ::Wuxia.Settings.getPayload();
	}
};

::Wuxia.UI <- {};

::Wuxia.UI.QualityRank <- {
	unique = 4,
	secret = 3,
	sect   = 2,
	common = 1
};

::Wuxia.UI.formatWeaponLabel <- function( _def )
{
	local wStr = "";
	if (_def != null && ("WeaponTypes" in _def) && _def.WeaponTypes.len() > 0)
	{
		for (local wi = 0; wi < _def.WeaponTypes.len(); wi = ++wi)
		{
			if (wi > 0) wStr += "/";
			local wt = _def.WeaponTypes[wi];
			wStr += (("WeaponTypeNames" in ::Wuxia.Text && wt in ::Wuxia.Text.WeaponTypeNames) ? ::Wuxia.Text.WeaponTypeNames[wt] : wt);
		}
	}
	return wStr;
};

::Wuxia.UI._LevelSummaryCache <- {};

::Wuxia.UI.buildLevelSummaries <- function( _def )
{
	local summaries = [];
	if (_def == null || !("Levels" in _def)) return summaries;
	if (("ID" in _def) && (_def.ID in ::Wuxia.UI._LevelSummaryCache))
		return ::Wuxia.UI._LevelSummaryCache[_def.ID];
	for (local lv = 0; lv < _def.Levels.len(); lv = ++lv)
	{
		summaries.push({
			tier      = lv + 1,
			title     = ::Wuxia.Text.TierNames[lv + 1],
			text      = _def.Levels[lv].Summary,
			expNeeded = _def.Levels[lv].ExpNeeded
		});
	}
	if ("ID" in _def)
		::Wuxia.UI._LevelSummaryCache[_def.ID] <- summaries;
	return summaries;
};

::Wuxia.UI.buildPassiveSummaryTags <- function( _agg, _actor = null )
{
	local tags = [];
	if (_agg == null) return tags;
	local stMap = [
		["MeleeSkill", "武艺"],
		["RangedSkill", "射艺"],
		["MeleeDefense", "招架"],
		["RangedDefense", "避暗"],
		["Stamina", "内息"],
		["Initiative", "身法"],
		["Hitpoints", "气血"],
		["Bravery", "定力"],
		["FatigueRecoveryRate", "回气"]
	];
	for (local i = 0; i < stMap.len(); i = ++i)
	{
		local k = stMap[i][0];
		local lbl = stMap[i][1];
		if (k in _agg.Stats && _agg.Stats[k] != 0)
		{
			local v = _agg.Stats[k];
			tags.push(lbl + (v > 0 ? "+" : "") + v);
		}
	}
	local activeOffhandPen = (_agg.EmptyOffhandPen > 0.0 && (_actor == null || ::Wuxia.CombatRules.hasSingleHandEmptyOffhand(_actor)))
		? _agg.EmptyOffhandPen
		: 0.0;
	local totalPen = ::Math.minf(0.25, _agg.DirectDmgBonus + activeOffhandPen);
	if (totalPen > 0.001) tags.push("穿甲+" + ::Math.round(totalPen * 100) + "%");
	if (_agg.ArmorDmgBonus > 0.001) tags.push("破甲+" + ::Math.round(_agg.ArmorDmgBonus * 100) + "%");
	if (_agg.WeaponQiDiscount > 0.001) tags.push("省气" + ::Math.round(_agg.WeaponQiDiscount * 100) + "%");
	if (_agg.QiShieldPct > 0.001) tags.push("护体" + ::Math.round(_agg.QiShieldPct * 100) + "%");
	if (_agg.InitToDefRatio > 0.001) tags.push("身法转防" + ::Math.round(_agg.InitToDefRatio * 100) + "%");
	if (_agg.HeavyArmorScale > 0.001) tags.push("披甲减负" + ::Math.round(_agg.HeavyArmorScale * 100) + "%");
	return tags;
};

// 7-slot Build Diagnostics: warns on Math.max passive overlap, 50% aux Neigong, hard caps & Tier-3 stat shortfalls
::Wuxia.UI.buildBuildDiagnostics <- function( _actor, _c, _agg, _slotsData, _subNeigongSlotIdx )
{
	local diags = [];
	if (_actor == null || _c == null || _agg == null || _slotsData == null) return diags;

	local activeWaigongMatched = 0;
	local activeQinggong = 0;
	local blockedNames = [];

	for (local i = 0; i < _slotsData.len(); i = ++i)
	{
		local sl = _slotsData[i];
		if (sl.manualID == null || sl.tier <= 0 || sl.isSealed) continue;
		if (sl.category == "waigong" && sl.matchesWeapon)
			activeWaigongMatched += 1;
		else if (sl.category == "qinggong")
			activeQinggong += 1;

		if (sl.tier == 2 && sl.missingReqs != null && sl.missingReqs.len() > 0)
		{
			local missStr = "";
			for (local mi = 0; mi < sl.missingReqs.len(); mi = ++mi)
				missStr += (mi > 0 ? "、" : "") + sl.missingReqs[mi];
			blockedNames.push(sl.rawName + "(" + missStr + ")");
		}
	}

	if (activeWaigongMatched >= 2)
	{
		diags.push({
			level = "info",
			short = "双外功取高",
			detail = "当前兵器同时激活 " + activeWaigongMatched + " 门外功：主动招式池合并，但常驻攻防/穿甲/破甲等被动按最高单项生效（Math.max，不叠加）。"
		});
	}

	if (activeQinggong >= 2)
	{
		diags.push({
			level = "info",
			short = "双轻功取高",
			detail = "已装配 " + activeQinggong + " 门轻功：身法转防比例与常驻攻防取最高单项生效（禁止叠加）。"
		});
	}

	if (_subNeigongSlotIdx >= 1)
	{
		diags.push({
			level = "info",
			short = "辅内折半",
			detail = "辅修第 2 门内功提供的内息上限与每回合回气按 50% 折算，若五行相克还会触发真气滞涩。"
		});
	}

	local gufengActive = (_agg.EmptyOffhandPen > 0.001 && ::Wuxia.CombatRules.hasSingleHandEmptyOffhand(_actor));
	if (_agg.EmptyOffhandPen > 0.001 && !gufengActive)
	{
		diags.push({
			level = "warn",
			short = "孤锋未生效",
			detail = "已修习《孤锋诀》，但当前并非「单手兵器 + 空副手」架势（如持盾或持双手兵刃），空副手额外穿甲暂不生效。"
		});
	}
	local rawPen = _agg.DirectDmgBonus + (gufengActive ? _agg.EmptyOffhandPen : 0.0);
	if (rawPen > 0.251)
	{
		diags.push({
			level = "warn",
			short = "穿甲触顶25%",
			detail = "当前外功穿甲与孤锋诀合计 +" + ::Math.round(rawPen * 100) + "%，已达全身额外穿甲 +25% 硬上限，溢出部分不再计入。"
		});
	}

	if (_agg.LightArmorMitigation > 0.001 && _agg.QiShieldPct > 0.001)
	{
		local combinedKeep = (1.0 - _agg.LightArmorMitigation) * (1.0 - _agg.QiShieldPct);
		if (combinedKeep < 0.405)
		{
			diags.push({
				level = "warn",
				short = "卸力护体60%封顶",
				detail = "轻装卸力与真气护体叠加后的总气血减伤受 60% 全局硬封顶约束，可考虑腾出槽位转修输出或控场。"
			});
		}
	}

	if (blockedNames.len() > 0)
	{
		local bStr = "";
		for (local bi = 0; bi < blockedNames.len() && bi < 2; bi = ++bi)
			bStr += (bi > 0 ? "；" : "") + blockedNames[bi];
		diags.push({
			level = "warn",
			short = "三重欠属性",
			detail = "以下二重功法冲击三重大成尚缺门坎属性（可升级加点或服洗髓丹突破）：" + bStr
		});
	}

	return diags;
};

::Wuxia.UI.buildLearnedManualsData <- function( _actor, _c, _heldWpn )
{
	local list = [];
	if (_actor == null || _c == null) return list;
	_c.ensureSlotsRegisteredInLearned();

	local equippedSlotByManual = {};
	for (local si = 0; si < _c.m.Slots.len(); si = ++si)
	{
		local sl = _c.m.Slots[si];
		if (sl.ManualID != null && sl.Tier > 0)
			equippedSlotByManual[sl.ManualID] <- si;
	}

	foreach (mid, entry in _c.m.LearnedManuals)
	{
		local def = ::Wuxia.Slots.getManualDef(mid);
		if (def == null) continue;

		local tier = ::Math.max(1, ::Math.min(entry.Tier, def.Levels.len()));
		local expNeeded = (!entry.IsFragment && tier < def.Levels.len()) ? def.Levels[tier].ExpNeeded : 0;
		local reqCheck = ::Wuxia.Mastery.checkRequirements(_actor, def);
		local blockedByReq = (!entry.IsFragment && tier == 2 && expNeeded > 0 && entry.Exp >= expNeeded && !reqCheck.Met);
		local qKey = (def.Quality == "secret") ? "supreme" : def.Quality;
		local eqIdx = (mid in equippedSlotByManual) ? equippedSlotByManual[mid] : -1;

		list.push({
			manualID          = def.ID,
			name              = def.Name,
			category          = def.Category,
			categoryLabel     = (def.Category in ::Wuxia.Text.Categories) ? ::Wuxia.Text.Categories[def.Category] : def.Category,
			quality           = def.Quality,
			qualityRank       = (def.Quality in ::Wuxia.UI.QualityRank) ? ::Wuxia.UI.QualityRank[def.Quality] : 1,
			qualityLabel      = (def.Quality in ::Wuxia.Text.Qualities) ? ::Wuxia.Text.Qualities[def.Quality] : def.Quality,
			element           = def.Element != null ? def.Element : "",
			elementLabel      = (def.Element != null && def.Element in ::Wuxia.Text.Elements) ? ::Wuxia.Text.Elements[def.Element] : "",
			icon              = def.Icon,
			bookIcon          = "ui/items/misc/wx_book_" + def.Category + "_" + qKey + ".png",
			tier              = tier,
			tierLabel         = ::Wuxia.Text.TierNames[::Math.min(tier, 3)],
			exp               = entry.Exp,
			expNeeded         = expNeeded,
			isFragment        = entry.IsFragment,
			equippedSlotIndex = eqIdx,
			meetsTier3Req     = reqCheck.Met,
			blockedByReq      = blockedByReq,
			missingReqs       = reqCheck.Missing,
			weaponLabel       = ::Wuxia.UI.formatWeaponLabel(def),
			matchesWeapon     = ::Wuxia.CombatRules.matchesWeapon(_heldWpn, def.WeaponTypes),
			description       = def.Description,
			levelSummaries    = ::Wuxia.UI.buildLevelSummaries(def)
		});
	}

	list.sort(function( a, b ) {
		local aEq = a.equippedSlotIndex >= 0 ? 1 : 0;
		local bEq = b.equippedSlotIndex >= 0 ? 1 : 0;
		if (aEq != bEq) return aEq > bEq ? -1 : 1;
		if (a.qualityRank != b.qualityRank) return a.qualityRank > b.qualityRank ? -1 : 1;
		return a.name <=> b.name;
	});
	return list;
};

::Wuxia.UI.buildBrotherMartialData <- function( _actor )
{
	if (_actor == null) return null;
	local c = ::Wuxia.Slots.getContainer(_actor);
	c.ensureSlotsRegisteredInLearned();
	local level = ::Wuxia.Slots.getActorLevel(_actor);
	local skills = _actor.getSkills();
	local heldWpn = (::Wuxia.hasMember(_actor, "getItems") && _actor.getItems() != null) ? _actor.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand) : null;

	local slotsData = [];
	local emptyUnlockedSlots = 0;

	for (local i = 0; i < ::Wuxia.Config.SlotLayout.len(); i = ++i)
	{
		local cfg = ::Wuxia.Config.SlotLayout[i];
		local s = c.m.Slots[i];
		local unlocked = (level >= cfg.UnlockLevel);
		if (unlocked && (s.ManualID == null || s.Tier <= 0))
			emptyUnlockedSlots += 1;

		local item = {
			slotIndex         = i,
			slotType          = cfg.SlotType,
			slotLabel         = cfg.Label,
			unlockLevel       = cfg.UnlockLevel,
			unlocked          = unlocked,
			allowedCategories = cfg.AllowedCategories,
			manualID          = null,
			name              = "",
			rawName           = "",
			category          = "",
			categoryLabel     = "",
			quality           = "",
			qualityLabel      = "",
			element           = "",
			elementLabel      = "",
			icon              = "",
			bookIcon          = "",
			tier              = 0,
			tierLabel         = "",
			exp               = 0,
			expNeeded         = 0,
			isFragment        = false,
			isSealed          = false,
			blockedByReq      = false,
			missingReqs       = [],
			weaponLabel       = "",
			matchesWeapon     = true,
			description       = "",
			levelSummaries    = []
		};

		if (s.ManualID != null && s.Tier > 0)
		{
			local def = ::Wuxia.Slots.getManualDef(s.ManualID);
			if (def != null)
			{
				local nextNeed = ::Wuxia.Mastery.getNextTierExpNeeded(s);
				local reqCheck = ::Wuxia.Mastery.checkRequirements(_actor, def);
				local blocked = (!s.IsFragment && s.Tier == 2 && nextNeed > 0 && s.Exp >= nextNeed && !reqCheck.Met);
				local qKey = (def.Quality == "secret") ? "supreme" : def.Quality;
				local sealed = (::Wuxia.Slots.getPracticedDef(c, s) == null);

				item.manualID       = def.ID;
				item.rawName        = def.Name;
				item.name           = def.Name + (sealed ? "（已封存）" : "");
				item.isSealed       = sealed;
				item.category       = def.Category;
				item.categoryLabel  = (def.Category in ::Wuxia.Text.Categories) ? ::Wuxia.Text.Categories[def.Category] : def.Category;
				item.quality        = def.Quality;
				item.qualityLabel   = (def.Quality in ::Wuxia.Text.Qualities) ? ::Wuxia.Text.Qualities[def.Quality] : def.Quality;
				item.element        = def.Element != null ? def.Element : "";
				item.elementLabel   = (def.Element != null && def.Element in ::Wuxia.Text.Elements) ? ::Wuxia.Text.Elements[def.Element] : "";
				item.icon           = def.Icon;
				item.bookIcon       = "ui/items/misc/wx_book_" + def.Category + "_" + qKey + ".png";
				item.tier           = s.Tier;
				item.tierLabel      = ::Wuxia.Text.TierNames[::Math.min(s.Tier, 3)];
				item.exp            = s.Exp;
				item.expNeeded      = nextNeed;
				item.isFragment     = s.IsFragment;
				item.blockedByReq   = blocked;
				item.missingReqs    = reqCheck.Missing;
				item.weaponLabel    = ::Wuxia.UI.formatWeaponLabel(def);
				item.matchesWeapon  = ::Wuxia.CombatRules.matchesWeapon(heldWpn, def.WeaponTypes);
				item.description    = def.Description;
				item.levelSummaries = ::Wuxia.UI.buildLevelSummaries(def);
			}
		}

		slotsData.push(item);
	}

	local learnedManuals = ::Wuxia.UI.buildLearnedManualsData(_actor, c, heldWpn);

	// Count how many unlocked empty slots can be immediately filled by this brother's unequipped learned manuals
	local equipableHintCount = 0;
	if (emptyUnlockedSlots > 0 && learnedManuals.len() > 0)
	{
		for (local idx = 0; idx < slotsData.len(); idx = ++idx)
		{
			if (!slotsData[idx].unlocked || slotsData[idx].manualID != null) continue;
			for (local li = 0; li < learnedManuals.len(); li = ++li)
			{
				local lm = learnedManuals[li];
				if (lm.equippedSlotIndex >= 0) continue;
				if (::Wuxia.Slots.canEquipLearnedManual(_actor, idx, lm.manualID).Ok)
				{
					equipableHintCount += 1;
					break;
				}
			}
		}
	}

	local mainElementLabel = "未修内功";
	local mainElementKey = "none";
	if (c.m.Slots[0].ManualID != null)
	{
		local mdef = ::Wuxia.Slots.getManualDef(c.m.Slots[0].ManualID);
		if (mdef != null && mdef.Element != null)
		{
			mainElementKey = mdef.Element;
			if (mdef.Element in ::Wuxia.Text.Elements)
				mainElementLabel = ::Wuxia.Text.Elements[mdef.Element];
		}
	}

	local unlockedEmptySlots = 0;
	local subNeigongSlotIdx = -1;
	local subElementKey = "none";
	for (local si = 0; si < slotsData.len(); si = ++si)
	{
		if (slotsData[si].unlocked && slotsData[si].manualID == null)
			unlockedEmptySlots += 1;
		if (si >= 1 && slotsData[si].manualID != null && slotsData[si].category == "neigong")
		{
			subNeigongSlotIdx = si;
			subElementKey = slotsData[si].element != "" ? slotsData[si].element : "neutral";
		}
	}

	local activeMoves      = [];
	local tempInjuryNames  = [];
	local hasScatter       = false;
	local scatterDays      = 0;
	local internalSeverity = 0;
	local internalDays     = 0;
	local permScars        = 0;
	local battlePillLabels = [];

	if (skills != null)
	{
		local allActives = skills.getAllSkillsOfType(::Const.SkillType.Active);
		for (local ai = 0; ai < allActives.len(); ai = ++ai)
		{
			local sk = allActives[ai];
			if (sk == null) continue;
			local sid = sk.getID();
			if (sid.find("actives.wx_") == 0)
			{
				local wOk = ("wxHasRequiredWeapon" in sk) ? sk.wxHasRequiredWeapon() : true;
				local wReq = ("wxFormatWeaponList" in sk) ? sk.wxFormatWeaponList() : "";
				local animLbl = ("VFX" in ::Wuxia && "getSkillChoreoLabel" in ::Wuxia.VFX)
					? ::Wuxia.VFX.getSkillChoreoLabel(sk)
					: "";
				activeMoves.push({
					id        = sid,
					name      = sk.getName(),
					icon      = "ui/" + sk.m.Icon,
					ap        = sk.getActionPointCost(),
					qi        = sk.getFatigueCost(),
					rawQi     = sk.m.FatigueCost,
					weaponOk  = wOk,
					weaponReq = wReq,
					animLabel = animLbl,
					desc      = sk.getDescription()
				});
			}
		}

		local wounds = skills.getAllSkillsOfType(::Const.SkillType.TemporaryInjury);
		for (local wi2 = 0; wi2 < wounds.len(); wi2 = ++wi2)
		{
			if (wounds[wi2] != null) tempInjuryNames.push(wounds[wi2].getName());
		}

		local sc = skills.getSkillByID("effects.wx_scatter_weakness");
		if (sc != null)
		{
			hasScatter = true;
			scatterDays = sc.m.DaysRemaining;
		}
		local inj = skills.getSkillByID("effects.wx_internal_injury");
		if (inj != null)
		{
			internalSeverity = inj.m.Severity;
			internalDays     = inj.m.DaysRemaining;
			permScars        = inj.m.PermanentScars;
		}
		local pb = skills.getSkillByID("effects.wx_pill_battle_buff");
		if (pb != null && (::Wuxia.hasMember(pb, "getSummaryLabels")))
		{
			battlePillLabels = pb.getSummaryLabels();
		}
	}

	local aggFlags = ::Wuxia.CombatRules.getAggregateFlags(c);
	local aggTags  = ::Wuxia.UI.buildPassiveSummaryTags(aggFlags, _actor);
	local buildDiags = ::Wuxia.UI.buildBuildDiagnostics(_actor, c, aggFlags, slotsData, subNeigongSlotIdx);

	local talents = [0, 0, 0, 0, 0, 0, 0, 0];
	if (::Wuxia.Appearance.hasMember(_actor, "m") && ::Wuxia.Appearance.hasMember(_actor.m, "Talents"))
	{
		for (local t = 0; t < 8 && t < _actor.m.Talents.len(); t = ++t)
			talents[t] = _actor.m.Talents[t];
	}

	local b = _actor.getBaseProperties();
	local baseStats = [
		b.Hitpoints, b.Bravery, b.Stamina, b.Initiative,
		b.MeleeSkill, b.RangedSkill, b.MeleeDefense, b.RangedDefense
	];
	local appInfo = ("Appearance" in ::Wuxia)
		? ::Wuxia.Appearance.getLabelsForState(::Wuxia.Appearance.getOrInitState(_actor), _actor)
		: null;

	return {
		entityId               = _actor.getID(),
		imagePath              = ::Wuxia.Appearance.hasMember(_actor, "getImagePath") ? _actor.getImagePath() : "",
		name                   = _actor.getName(),
		level                  = level,
		hp                     = _actor.getHitpoints(),
		hpMax                  = _actor.getHitpointsMax(),
		actionPointsMax        = _actor.getActionPointsMax() - c.m.TemporaryAPOverflow,
		permanentAPBonus       = c.getPermanentAPBonus(),
		mainElementKey         = mainElementKey,
		mainElementLabel       = mainElementLabel,
		subNeigongSlotIdx      = subNeigongSlotIdx,
		subElementKey          = subElementKey,
		unlockedEmptySlots     = unlockedEmptySlots,
		hasConflict            = ::Wuxia.Slots.hasNeigongConflict(_actor),
		pendingWashChances     = c.m.PendingWashChances,
		tempInjuryNames        = tempInjuryNames,
		hasScatterWeakness     = hasScatter,
		scatterDays            = scatterDays,
		internalSeverity       = internalSeverity,
		internalDays           = internalDays,
		permScars              = permScars,
		battlePillLabels       = battlePillLabels,
		activeMoves            = activeMoves,
		aggSummaryTags         = aggTags,
		buildDiagnostics       = buildDiags,
		appearance             = appInfo,
		talents                = talents,
		baseStats              = baseStats,
		attrLabels             = ::Wuxia.Text.Attributes,
		slots                  = slotsData,
		learnedManuals         = learnedManuals,
		loadoutPresets         = ::Wuxia.Slots.getLoadoutPresets(_actor),
		emptyUnlockedSlots     = emptyUnlockedSlots,
		equipableSlotHintCount = equipableHintCount
	};
};

// Build Stash Pills & Shan Hai Neidan Cores data (for quick heal, battle prep, marrow wash & slot exp infusion)
::Wuxia.UI.buildStashPillsData <- function()
{
	local pills            = [];
	local washPillCount    = 0;
	local protectPillCount = 0;

	if (!("World" in getroottable()) || ::World == null || !("Assets" in ::World) || ::World.Assets == null)
		return { pills = pills, washPillCount = 0, protectPillCount = 0 };

	local stash = ::World.Assets.getStash();
	if (stash == null)
		return { pills = pills, washPillCount = 0, protectPillCount = 0 };

	local items = stash.getItems();
	for (local j = 0; j < items.len(); j = ++j)
	{
		local it = items[j];
		if (it == null) continue;
		local id = it.getID();

		if (id == "misc.wx_pill_item")
		{
			local pid = it.getPillID();
			if (!(pid in ::Wuxia.Config.Pills)) continue;
			local pdef = ::Wuxia.Config.Pills[pid];

			if (pdef.Kind == "marrow_wash")  washPillCount += 1;
			if (pdef.Kind == "wash_protect") protectPillCount += 1;

			local pQuality = ("Quality" in pdef) ? pdef.Quality : "sect";
			local pSub     = ("SubLabel" in pdef) ? pdef.SubLabel : "江湖丹药";

			if (pdef.Kind == "infuse_exp")
			{
				pills.push({
					stashIndex    = j,
					itemKind      = "pill_infuse",
					pillKind      = pdef.Kind,
					pillID        = pdef.ID,
					name          = pdef.Name,
					categoryLabel = pSub,
					quality       = pQuality,
					qualityLabel  = "修为灵丹",
					icon          = "ui/items/" + pdef.Icon,
					expAmount     = pdef.ExpAmount,
					description   = pdef.Description
				});
			}
			else if (pdef.Kind == "marrow_wash" || pdef.Kind == "wash_protect")
			{
				pills.push({
					stashIndex    = j,
					itemKind      = "pill_wash",
					pillKind      = pdef.Kind,
					pillID        = pdef.ID,
					name          = pdef.Name,
					categoryLabel = pSub,
					quality       = pQuality,
					qualityLabel  = "洗髓奇药",
					icon          = "ui/items/" + pdef.Icon,
					expAmount     = 0,
					description   = pdef.Description
				});
			}
			else
			{
				local isPrep = (pdef.Kind.find("buff_") == 0);
				pills.push({
					stashIndex    = j,
					itemKind      = "pill_consume",
					pillKind      = pdef.Kind,
					pillID        = pdef.ID,
					name          = pdef.Name,
					categoryLabel = pSub,
					quality       = pQuality,
					qualityLabel  = isPrep ? "备战灵丹" : "疗伤灵药",
					icon          = "ui/items/" + pdef.Icon,
					expAmount     = 0,
					description   = pdef.Description
				});
			}
		}
		else if (::Wuxia.hasMember(it.m, "HerbID") && ("Herbs" in ::Wuxia.Config) && (it.m.HerbID in ::Wuxia.Config.Herbs))
		{
			local hdef = ::Wuxia.Config.Herbs[it.m.HerbID];
			local hQuality = ("Quality" in hdef) ? hdef.Quality : "sect";
			if (hdef.Kind == "herb_infuse")
			{
				pills.push({
					stashIndex    = j,
					itemKind      = "pill_infuse",
					pillKind      = "herb_infuse",
					pillID        = hdef.ID,
					name          = hdef.Name,
					categoryLabel = hdef.SubLabel,
					quality       = hQuality,
					qualityLabel  = "山海仙株",
					icon          = "ui/items/" + hdef.Icon,
					expAmount     = hdef.ExpAmount,
					description   = hdef.Description
				});
			}
			else
			{
				pills.push({
					stashIndex    = j,
					itemKind      = "pill_consume",
					pillKind      = hdef.Kind,
					pillID        = hdef.ID,
					name          = hdef.Name,
					categoryLabel = hdef.SubLabel,
					quality       = hQuality,
					qualityLabel  = "山海奇草",
					icon          = "ui/items/" + hdef.Icon,
					expAmount     = 0,
					description   = hdef.Description
				});
			}
		}
		else if (::Wuxia.hasMember(it.m, "CoreID") && (it.m.CoreID in ::Wuxia.Config.ShanHaiCores))
		{
			local cdef = ::Wuxia.Config.ShanHaiCores[it.m.CoreID];
			local tierLbl = (("TierGroup" in cdef) && cdef.TierGroup == "sovereign") ? "太古神丹"
				: ((("TierGroup" in cdef) && cdef.TierGroup == "wild") ? "山泽妖丹" : "大妖内丹");
			pills.push({
				stashIndex    = j,
				itemKind      = "pill_infuse",
				pillKind      = "neidan",
				pillID        = cdef.ID,
				name          = cdef.Name,
				categoryLabel = cdef.Chapter + "·内丹",
				quality       = "unique",
				qualityLabel  = tierLbl,
				icon          = "ui/items/" + it.getIcon(),
				expAmount     = cdef.ExpAmount,
				description   = cdef.Description + "（常规 +" + cdef.ExpAmount + " 火候，同脉共鸣 +" + (cdef.ExpAmount + 100) + "，山海孤本共鸣 +" + (cdef.ExpAmount + 180) + "！）"
			});
		}
	}

	return {
		pills            = pills,
		washPillCount    = washPillCount,
		protectPillCount = protectPillCount
	};
};

// Build Company 藏经阁 (Manual & Page Vault) UI state for the selected brother
::Wuxia.UI.buildLibraryUIData <- function( _actor = null )
{
	local items = [];
	local stash = ("World" in getroottable() && ::World != null && ("Assets" in ::World) && ::World.Assets != null)
		? ::World.Assets.getStash()
		: null;
	local heldWpn = (_actor != null && ::Wuxia.hasMember(_actor, "getItems") && _actor.getItems() != null)
		? _actor.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand)
		: null;
	local broContainer = (_actor != null) ? ::Wuxia.Slots.getContainer(_actor) : null;
	if (broContainer != null) broContainer.ensureSlotsRegisteredInLearned();

	// Count how many roster brothers have learned each manual + total pages per quality for 2:1 wildcard check
	local rosterLearnedCounts = {};
	if ("World" in getroottable() && ::World != null && ("Assets" in ::World) && ::World.Assets != null && ::World.getPlayerRoster() != null)
	{
		foreach (rb in ::World.getPlayerRoster().getAll())
		{
			if (rb == null || !rb.isAlive()) continue;
			local rc = ::Wuxia.Slots.getContainer(rb);
			if (rc == null) continue;
			rc.ensureSlotsRegisteredInLearned();
			foreach (lmid, lentry in rc.m.LearnedManuals)
			{
				if (!lentry.IsFragment)
				{
					if (!(lmid in rosterLearnedCounts)) rosterLearnedCounts[lmid] <- 0;
					rosterLearnedCounts[lmid] += 1;
				}
			}
		}
	}

	local maps = ::Wuxia.Library.getOwnedMaps();
	local ownedIDs = {};
	local qualityPageTotals = {};
	foreach (midB, bVal in maps.Books)
	{
		if (bVal > 0 && (midB in ::Wuxia.Config.Manuals))
			ownedIDs[midB] <- true;
	}
	foreach (midP0, pc in maps.Pages)
	{
		if (pc > 0 && (midP0 in ::Wuxia.Config.Manuals))
		{
			ownedIDs[midP0] <- true;
			local def0 = ::Wuxia.Config.Manuals[midP0];
			if (!(def0.Quality in qualityPageTotals)) qualityPageTotals[def0.Quality] <- 0;
			qualityPageTotals[def0.Quality] += pc;
		}
	}

	foreach (mid, _flag in ownedIDs)
	{
		local def = ::Wuxia.Config.Manuals[mid];
		local bCnt = (mid in maps.Books) ? maps.Books[mid] : 0;
		local pCnt = (mid in maps.Pages) ? maps.Pages[mid] : 0;
		if (bCnt <= 0 && pCnt <= 0) continue;

		local qKey = (def.Quality == "secret") ? "supreme" : def.Quality;
		local qRank = (def.Quality in ::Wuxia.UI.QualityRank) ? ::Wuxia.UI.QualityRank[def.Quality] : 1;
		local wStr = ::Wuxia.UI.formatWeaponLabel(def);
		local wMatch = ::Wuxia.CombatRules.matchesWeapon(heldWpn, def.WeaponTypes);
		local reqCheck = (_actor != null) ? ::Wuxia.Mastery.checkRequirements(_actor, def) : { Met = true, Missing = [] };
		local lEntry = (broContainer != null) ? broContainer.getLearnedEntry(mid) : null;
		local alreadyFullLearned = (lEntry != null && !lEntry.IsFragment);
		local learnedIsFrag = (lEntry != null && lEntry.IsFragment);
		local rosterCnt = (mid in rosterLearnedCounts) ? rosterLearnedCounts[mid] : 0;
		local summaries = ::Wuxia.UI.buildLevelSummaries(def);

		if (bCnt > 0)
		{
			items.push({
				itemKind          = "manual",
				manualID          = def.ID,
				name              = def.Name,
				count             = bCnt,
				category          = def.Category,
				categoryLabel     = ::Wuxia.Text.Categories[def.Category],
				quality           = def.Quality,
				qualityRank       = qRank,
				qualityLabel      = ::Wuxia.Text.Qualities[def.Quality],
				elementLabel      = (def.Element != null && def.Element in ::Wuxia.Text.Elements) ? ::Wuxia.Text.Elements[def.Element] : "",
				icon              = "ui/items/misc/wx_book_" + def.Category + "_" + qKey + ".png",
				emblemIcon        = def.Icon,
				weaponLabel       = wStr,
				matchesWeapon     = wMatch,
				alreadyLearned    = alreadyFullLearned,
				learnedIsFragment = learnedIsFrag,
				learnedByCount    = rosterCnt,
				meetsTier3Req     = reqCheck.Met,
				missingReqs       = reqCheck.Missing,
				basePrice         = def.BasePrice,
				description       = def.Description,
				levelSummaries    = summaries,
				sortPriority      = alreadyFullLearned ? 10 : 30
			});
		}

		if (pCnt > 0)
		{
			local qTotal = (def.Quality in qualityPageTotals) ? qualityPageTotals[def.Quality] : pCnt;
			local spareAvail = ::Math.max(0, qTotal - pCnt);
			local missingOwn = ::Math.max(0, def.FragmentsNeeded - pCnt);
			local spareNeed = missingOwn * 2;
			local canExact = (def.FragmentsNeeded > 0 && pCnt >= def.FragmentsNeeded);
			local canWild  = (!canExact && def.FragmentsNeeded > 0 && pCnt >= 1 && spareAvail >= spareNeed);

			items.push({
				itemKind           = "page",
				manualID           = def.ID,
				name               = def.Name,
				count              = pCnt,
				fragmentsNeeded    = def.FragmentsNeeded,
				canCraft           = canExact,
				canWildcardCraft   = canWild,
				spareNeeded        = spareNeed,
				infuseBaseExp      = ::Wuxia.Mastery.getPageBaseExp(def.Quality),
				allowFragmentLearn = def.AllowFragmentLearn,
				category           = def.Category,
				categoryLabel      = ::Wuxia.Text.Categories[def.Category],
				quality            = def.Quality,
				qualityRank        = qRank,
				qualityLabel       = ::Wuxia.Text.Qualities[def.Quality],
				elementLabel       = (def.Element != null && def.Element in ::Wuxia.Text.Elements) ? ::Wuxia.Text.Elements[def.Element] : "",
				icon               = "ui/items/misc/wx_page_" + qKey + ".png",
				emblemIcon         = def.Icon,
				weaponLabel        = wStr,
				matchesWeapon      = wMatch,
				alreadyLearned     = alreadyFullLearned,
				learnedIsFragment  = learnedIsFrag,
				learnedByCount     = rosterCnt,
				meetsTier3Req      = reqCheck.Met,
				missingReqs        = reqCheck.Missing,
				basePrice          = ::Math.max(100, ::Math.floor(def.BasePrice / ::Math.max(1, def.FragmentsNeeded))),
				description        = def.Description,
				levelSummaries     = summaries,
				sortPriority       = canExact ? 40 : (canWild ? 25 : 5)
			});
		}
	}

	items.sort(function( a, b ) {
		if (a.sortPriority != b.sortPriority) return a.sortPriority > b.sortPriority ? -1 : 1;
		if (a.itemKind != b.itemKind) return a.itemKind == "manual" ? -1 : 1;
		if (a.qualityRank != b.qualityRank) return a.qualityRank > b.qualityRank ? -1 : 1;
		return a.name <=> b.name;
	});

	return {
		autoStore    = ::Wuxia.Library.isAutoStoreEnabled(),
		summary      = ::Wuxia.Library.getSummaryCounts(),
		stashMovable = ::Wuxia.Library.countMovableInStash(stash, true),
		items        = items
	};
};

// Keep legacy helper for any external callers
::Wuxia.UI.buildStashWuxiaItems <- function( _actor = null )
{
	local p = ::Wuxia.UI.buildStashPillsData();
	return {
		items            = p.pills,
		washPillCount    = p.washPillCount,
		protectPillCount = p.protectPillCount
	};
};

::Wuxia.HooksMod.hook("scripts/ui/global/data_helper", function( q )
{
	q.addCharacterToUIData = @(__original) function( _entity, _target )
	{
		if (_entity != null && ("Armory" in ::Wuxia))
		{
			::Wuxia.Armory.syncActorHandheldAndArmor(_entity);
		}
		__original(_entity, _target);
		if (_entity != null && _target != null)
		{
			_target.wxMartial <- ::Wuxia.UI.buildBrotherMartialData(_entity);
		}
	};

	if (::Wuxia.qHas(q, "convertItemToUIData"))
	{
		q.convertItemToUIData = @(__original) function( _item, _forceSmallIcon, _owner = null )
		{
			local ret = __original(_item, _forceSmallIcon, _owner);
			if (ret != null && typeof ret == "table" && _item != null && (::Wuxia.hasMember(_item, "getID")))
			{
				local iid = _item.getID();
				if (iid == "misc.wx_manual_item")
				{
					local mid = _item.getManualID();
					local def = ::Wuxia.Slots.getManualDef(mid);
					local own = ::Wuxia.Library.getOwnershipSummary(mid);
					ret.wxItemKind   <- "manual";
					ret.wxManualID   <- mid;
					ret.wxQuality    <- def != null ? def.Quality : "common";
					ret.wxVaultBooks <- own.bookCount;
					ret.wxVaultPages <- own.pageCount;
					ret.wxPagesReq   <- own.fragmentsNeeded;
					ret.wxLearnedCnt <- own.learnedCount;
				}
				else if (iid == "misc.wx_page_item")
				{
					local midP = _item.getManualID();
					local defP = ::Wuxia.Slots.getManualDef(midP);
					local ownP = ::Wuxia.Library.getOwnershipSummary(midP);
					ret.wxItemKind   <- "page";
					ret.wxManualID   <- midP;
					ret.wxQuality    <- defP != null ? defP.Quality : "sect";
					ret.wxVaultBooks <- ownP.bookCount;
					ret.wxVaultPages <- ownP.pageCount;
					ret.wxStackPages <- _item.getPageCount();
					ret.wxPagesReq   <- ::Math.max(1, ownP.fragmentsNeeded);
					ret.wxLearnedCnt <- ownP.learnedCount;
				}
				else if (iid == "misc.wx_pill_item")
				{
					local pid = _item.getPillID();
					local pdef = (pid in ::Wuxia.Config.Pills) ? ::Wuxia.Config.Pills[pid] : null;
					ret.wxItemKind <- "pill";
					ret.wxQuality  <- (pdef != null && "Quality" in pdef) ? pdef.Quality : "sect";
				}
			}
			return ret;
		};
	}
});

::Wuxia.UI.buildSectRelationsDirectory <- function( _allowTeaHouse = true, _allowSanctum = true )
{
	local regionOrder = ["plains", "mountains", "forest", "swamp", "snow", "desert"];
	local regions = [];
	foreach (rk in regionOrder)
	{
		regions.push({
			id    = rk,
			label = (rk in ::Wuxia.Config.SectRegions) ? ::Wuxia.Config.SectRegions[rk] : rk
		});
	}

	local alignLabels = {
		righteous = "名门正宗",
		neutral   = "中立世家",
		outlaw    = "绿林奇门"
	};

	local rosterLearnedCounts = {};
	if ("World" in getroottable() && ::World != null && ("State" in ::World) && ::World.State != null && ("getPlayerRoster" in ::World) && ::World.getPlayerRoster() != null)
	{
		foreach (rb in ::World.getPlayerRoster().getAll())
		{
			if (rb == null || !rb.isAlive()) continue;
			local rc = ::Wuxia.Slots.getContainer(rb);
			if (rc == null) continue;
			rc.ensureSlotsRegisteredInLearned();
			foreach (lmid, lentry in rc.m.LearnedManuals)
			{
				if (!lentry.IsFragment)
				{
					if (!(lmid in rosterLearnedCounts)) rosterLearnedCounts[lmid] <- 0;
					rosterLearnedCounts[lmid] += 1;
				}
			}
		}
	}

	local curSanctum = (_allowSanctum && "getCurrentSanctum" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getCurrentSanctum() : null;
	local sanctumSectID = (curSanctum != null && "getSectID" in curSanctum) ? curSanctum.getSectID() : "";
	local sanctumName = (curSanctum != null) ? curSanctum.getName() : "";
	if (sanctumSectID != "" && "discoverSect" in ::Wuxia.SectRelations)
		::Wuxia.SectRelations.discoverSect(sanctumSectID);

	local curTown = (_allowTeaHouse && curSanctum == null && "getCurrentTown" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getCurrentTown() : null;
	local townSeats = (curTown != null && ("getTownTeaHouseSeats" in ::Wuxia.SectRelations))
		? ::Wuxia.SectRelations.getTownTeaHouseSeats(curTown)
		: {};
	if (curTown != null && "discoverSect" in ::Wuxia.SectRelations)
	{
		foreach (tsid, _b in townSeats)
			::Wuxia.SectRelations.discoverSect(tsid);
	}
	if (sanctumSectID != "")
		townSeats[sanctumSectID] <- "亲临山门";

	local curMoney = ("World" in getroottable() && ::World != null && ("Assets" in ::World) && ::World.Assets != null)
		? ::World.Assets.getMoney()
		: 0;
	local rumorCd = ("getTeaCooldownLeft" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getTeaCooldownLeft("rumor", "global", 2) : 0;

	local sectList = [];
	local ids = [];
	foreach (sid, _ in ::Wuxia.Config.Sects) ids.push(sid);
	ids.sort();

	foreach (sid in ids)
	{
		local s = ::Wuxia.Config.Sects[sid];
		local rel = ::Wuxia.SectRelations.getRelation(sid);
		local isVendetta = ::Wuxia.SectRelations.isVendettaActive(sid);
		local isAtThisSanctum = (sanctumSectID == sid);
		local isSeated = (sid in townSeats);

		// Check if player owns or has learned any manual from this sect (automatically reveals sect in directory)
		local ownsAnySectManual = false;
		if ("ShopManuals" in s)
		{
			foreach (chkSm in s.ShopManuals)
			{
				if (::Wuxia.Library.getManualCount(chkSm.ManualID) > 0
					|| ::Wuxia.Library.getPageCount(chkSm.ManualID) > 0
					|| (chkSm.ManualID in rosterLearnedCounts))
				{
					ownsAnySectManual = true;
					break;
				}
			}
		}
		if (ownsAnySectManual && "discoverSect" in ::Wuxia.SectRelations)
			::Wuxia.SectRelations.discoverSect(sid);

		local isKnown = ("isSectKnown" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.isSectKnown(sid) : true;
		if (!isKnown && !isSeated && !isAtThisSanctum)
			continue;

		local statusLbl = "素昧平生";
		if (isVendetta) statusLbl = "不死不休 · 寻仇追缉";
		else if (rel <= -15) statusLbl = "结怨冷眼";
		else if (rel >= 60) statusLbl = "莫逆之交 · 倾囊相授";
		else if (rel >= 25) statusLbl = "礼尚往来 · 登堂请教";
		else if (rel > 5) statusLbl = "点头之交";

		local anchor = ("getSectAnchorInfo" in ::Wuxia.SectRelations)
			? ::Wuxia.SectRelations.getSectAnchorInfo(sid)
			: { townName = "", dir = "", dist = -1, hasSanctum = false, isDiscovered = false };

		local mList = [];
		local revealedManualCount = 0;
		if ("ShopManuals" in s)
		{
			foreach (sm in s.ShopManuals)
			{
				local mdef = ::Wuxia.Slots.getManualDef(sm.ManualID);
				if (mdef == null) continue;
				local vBooks = ::Wuxia.Library.getManualCount(mdef.ID);
				local vPages = ::Wuxia.Library.getPageCount(mdef.ID);
				local lCnt = (mdef.ID in rosterLearnedCounts) ? rosterLearnedCounts[mdef.ID] : 0;
				local hasOwned = (vBooks > 0 || vPages > 0 || lCnt > 0);
				local isRevealed = hasOwned || (rel >= sm.MinRel) || (isAtThisSanctum && sm.MinRel <= 25);
				if (isRevealed) revealedManualCount += 1;

				local needSanctum = (!isAtThisSanctum && ("hasSanctum" in anchor && anchor.hasSanctum) && sm.MinRel >= 45 && rel < 65);
				local catLbl = (mdef.Category in ::Wuxia.Text.Categories) ? ::Wuxia.Text.Categories[mdef.Category] : mdef.Category;
				local qLbl = (mdef.Quality in ::Wuxia.Text.Qualities) ? ::Wuxia.Text.Qualities[mdef.Quality] : mdef.Quality;
				local qBookKey = (mdef.Quality == "secret") ? "supreme" : mdef.Quality;
				local bookIco = "ui/items/misc/wx_book_" + mdef.Category + "_" + qBookKey + ".png";

				mList.push({
					id              = isRevealed ? mdef.ID : "",
					name            = isRevealed ? mdef.Name : "？？？",
					isRevealed      = isRevealed,
					requiresSanctum = needSanctum,
					maskedHint      = needSanctum ? "镇派真传 · 须亲赴本门山门" : ("秘传未显 · 需交情 ≥" + sm.MinRel),
					quality         = mdef.Quality,
					qualityLabel    = isRevealed ? qLbl : (sm.MinRel >= 45 ? "镇派秘传" : "本门秘传"),
					category        = mdef.Category,
					categoryLabel   = catLbl,
					bookIcon        = bookIco,
					skillIcon       = isRevealed ? mdef.Icon : "",
					minRel          = sm.MinRel,
					price           = sm.Price,
					unlocked        = (rel >= sm.MinRel) && !needSanctum,
					vaultBooks      = vBooks,
					vaultPages      = vPages,
					fragmentsNeeded = mdef.FragmentsNeeded,
					learnedCount    = lCnt
				});
			}
		}

		local seatBadge = isSeated ? townSeats[sid] : "";
		local banqCd    = ("getTeaCooldownLeft" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getTeaCooldownLeft("banq", sid, 3) : 0;
		local sparCd    = ("getTeaCooldownLeft" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getTeaCooldownLeft("spar", sid, 5) : 0;
		local alcCd     = ("getTeaCooldownLeft" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getTeaCooldownLeft("alc", sid, 6) : 0;
		local sealDays  = ("getSanctumSealLeft" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getSanctumSealLeft(sid) : 0;
		local trialCd   = ("getTeaCooldownLeft" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getTeaCooldownLeft("trial", sid, 8) : 0;
		local raidCd    = ("getTeaCooldownLeft" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getTeaCooldownLeft("raid", sid, 15) : 0;
		local recruitCd = ("getTeaCooldownLeft" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getTeaCooldownLeft("recruit", sid, 10) : 0;
		local empowerCd = ("getTeaCooldownLeft" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getTeaCooldownLeft("emp", sid, 5) : 0;
		local healCd     = ("getTeaCooldownLeft" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getTeaCooldownLeft("heal", sid, 3) : 0;
		local herbCd     = ("getTeaCooldownLeft" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getTeaCooldownLeft("herb", sid, 4) : 0;
		local rareHerbCd = ("getTeaCooldownLeft" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getTeaCooldownLeft("herb_rare", sid, 7) : 0;
		local herbCatalog = null;
		if (isAtThisSanctum && ("getSectApothecaryCatalog" in ::Wuxia.SectRelations))
		{
			local hcat = ::Wuxia.SectRelations.getSectApothecaryCatalog(sid);
			herbCatalog = {
				common      = ::Wuxia.SectRelations.describeHerbIds(hcat.common),
				commonCost  = hcat.commonCost,
				commonQty   = hcat.commonQty,
				commonRel   = hcat.commonRel,
				commonCdMax = hcat.commonCdMax,
				rare        = ::Wuxia.SectRelations.describeHerbIds(hcat.rare),
				rareCost    = hcat.rareCost,
				rareQty     = hcat.rareQty,
				rareRel     = hcat.rareRel,
				rareCdMax   = hcat.rareCdMax
			};
		}
		local questInfo = (isAtThisSanctum && ("getSanctumQuestInfo" in ::Wuxia.SectRelations))
			? ::Wuxia.SectRelations.getSanctumQuestInfo(sid)
			: null;

		local regKey = ("Region" in s) ? s.Region : "plains";
		local alignKey = ("Alignment" in s) ? s.Alignment : "neutral";
		sectList.push({
			id                  = s.ID,
			name                = s.Name,
			region              = regKey,
			regionLabel         = ::Wuxia.SectRelations.getRegionLabel(regKey),
			alignment           = alignKey,
			alignmentLabel      = (alignKey in alignLabels) ? alignLabels[alignKey] : "江湖门派",
			description         = ("Description" in s) ? s.Description : "",
			relation            = rel,
			vendettaRel         = s.VendettaRel,
			isVendetta          = isVendetta,
			statusLabel         = statusLbl,
			anchorTownName      = anchor.townName,
			anchorDir           = anchor.dir,
			anchorDist          = anchor.dist,
			hasSanctum          = ("hasSanctum" in anchor) ? anchor.hasSanctum : false,
			sanctumDiscovered   = ("isDiscovered" in anchor) ? anchor.isDiscovered : false,
			isAtSanctum         = isAtThisSanctum,
			isSeatedInTown      = isSeated,
			seatBadge           = seatBadge,
			banquetCd           = banqCd,
			sparCd              = sparCd,
			alcCd               = alcCd,
			sealDays            = sealDays,
			trialCd             = trialCd,
			raidCd              = raidCd,
			recruitCd           = recruitCd,
			recruitCost         = ("getSanctumRecruitCost" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getSanctumRecruitCost(sid) : 1800,
			empowerCd           = empowerCd,
			healCd              = healCd,
			herbCd              = herbCd,
			rareHerbCd          = rareHerbCd,
			herbCatalog         = herbCatalog,
			questInfo           = questInfo,
			revealedManualCount = revealedManualCount,
			manuals             = mList
		});
	}

	sectList.sort(function( _a, _b ) {
		if (_a.isAtSanctum != _b.isAtSanctum) return _a.isAtSanctum ? -1 : 1;
		if (_a.isSeatedInTown != _b.isSeatedInTown) return _a.isSeatedInTown ? -1 : 1;
		if (_a.isSeatedInTown)
		{
			local rank = { ["亲临山门"] = 1, ["酒肆行客"] = 2, ["云游门人"] = 3, ["飞鸽赴约"] = 4 };
			local ra = (_a.seatBadge in rank) ? rank[_a.seatBadge] : 9;
			local rb = (_b.seatBadge in rank) ? rank[_b.seatBadge] : 9;
			if (ra != rb) return ra < rb ? -1 : 1;
		}
		if (_a.relation != _b.relation) return _a.relation > _b.relation ? -1 : 1;
		return _a.id <=> _b.id;
	});

	local seatedCnt = 0;
	foreach (_k, _v in townSeats) seatedCnt += 1;

	local isNight = ("World" in getroottable() && ::World != null && ::Wuxia.hasMember(::World, "getTime") && ::World.getTime() != null && ("IsDaytime" in ::World.getTime()) && !::World.getTime().IsDaytime);
	local rosterCnt = ("World" in getroottable() && ::World != null && ::Wuxia.hasMember(::World, "getPlayerRoster") && ::World.getPlayerRoster() != null)
		? ::World.getPlayerRoster().getSize()
		: 0;
	local rosterMax = ("World" in getroottable() && ::World != null && ("Assets" in ::World) && ::World.Assets != null)
		? ::World.Assets.getBrothersMax()
		: 12;
	local sanctumSceneKey = (sanctumSectID != "" && ("getSanctumSceneKey" in ::Wuxia.SectRelations))
		? ::Wuxia.SectRelations.getSanctumSceneKey(sanctumSectID)
		: "";
	local sanctumBannerImg = (sanctumSectID != "" && ("getSanctumBannerUIPath" in ::Wuxia.SectRelations))
		? ::Wuxia.SectRelations.getSanctumBannerUIPath(sanctumSectID)
		: "";
	local sanctumDisciple = (sanctumSectID != "" && ("getSanctumDisciplePreview" in ::Wuxia.SectRelations))
		? ::Wuxia.SectRelations.getSanctumDisciplePreview(sanctumSectID)
		: null;

	return {
		ok               = true,
		inSanctum        = (curSanctum != null),
		sanctumSectID    = sanctumSectID,
		sanctumName      = sanctumName,
		sanctumSceneKey  = sanctumSceneKey,
		sanctumBannerImg = sanctumBannerImg,
		sanctumDisciple  = sanctumDisciple,
		isNight          = isNight,
		rosterCount      = rosterCnt,
		rosterMax        = rosterMax,
		inTown           = (curTown != null),
		townName         = (curTown != null ? curTown.getName() : ""),
		townSeatedCount  = seatedCnt,
		rumorCd          = rumorCd,
		knownSectCount   = sectList.len(),
		totalSectCount   = ids.len(),
		money            = curMoney,
		localRegion      = (curTown != null && ("getSettlementRegion" in ::Wuxia.SectRelations))
			? ::Wuxia.SectRelations.getSettlementRegion(curTown)
			: ::Wuxia.SectRelations.getLocalRegion(),
		regions          = regions,
		sects            = sectList
	};
};

::Wuxia.UI.playShowcaseSound <- function( _cue )
{
	if (_cue == null || typeof _cue != "string" || _cue == "") return false;
	if (!("Sound" in getroottable()) || ::Sound == null) return false;

	local useWxSfx = !("VFX" in ::Wuxia) || !("isSfxEnabled" in ::Wuxia.VFX) || ::Wuxia.VFX.isSfxEnabled();
	local pick = null;
	local vol  = 0.72;
	if (_cue == "alchemy_start")
	{
		local arr = useWxSfx
			? ["sounds/wx_ritual/wx_alchemy_flare.wav"]
			: ["sounds/ambience/buildings/alchemist_metal_pot_01.wav", "sounds/ambience/buildings/alchemist_metal_pot_02.wav", "sounds/ambience/buildings/alchemist_metal_pot_03.wav"];
		pick = arr[::Math.rand(0, arr.len() - 1)];
		vol = 0.76;
	}
	else if (_cue == "alchemy_success")
	{
		local arr = useWxSfx
			? ["sounds/wx_ritual/wx_alchemy_flare.wav", "sounds/wx_ritual/wx_qi_meditate.wav"]
			: ["sounds/crafting/crafting_potion_01.wav", "sounds/crafting/crafting_potion_02.wav", "sounds/crafting/crafting_potion_03.wav", "sounds/crafting/crafting_potion_04.wav"];
		pick = arr[::Math.rand(0, arr.len() - 1)];
		vol = 0.82;
	}
	else if (_cue == "alchemy_crit" || _cue == "cultivate_breakthrough" || _cue == "wash_success" || _cue == "forge_masterwork")
	{
		local arr = useWxSfx
			? ["sounds/wx_ritual/wx_breakthrough_gong.wav"]
			: ["sounds/ambience/buildings/temple_bell_00.wav", "sounds/ambience/buildings/temple_bell_01.wav", "sounds/ambience/buildings/temple_bell_02.wav", "sounds/ambience/buildings/temple_bell_03.wav"];
		pick = arr[::Math.rand(0, arr.len() - 1)];
		vol = 0.82;
	}
	else if (_cue == "alchemy_trial" || _cue == "wash_fail")
	{
		local arr = ["sounds/enemies/miasma_spell_01.wav", "sounds/enemies/miasma_spell_02.wav"];
		pick = arr[::Math.rand(0, arr.len() - 1)];
		vol = 0.68;
	}
	else if (_cue == "forge_hammer")
	{
		local arr = ["sounds/ambience/buildings/blacksmith_hammering_01.wav", "sounds/ambience/buildings/blacksmith_hammering_03.wav", "sounds/ambience/buildings/blacksmith_hammering_05.wav", "sounds/ambience/buildings/blacksmith_hammering_07.wav"];
		pick = arr[::Math.rand(0, arr.len() - 1)];
		vol = 0.88;
	}
	else if (_cue == "forge_quench")
	{
		pick = useWxSfx ? "sounds/wx_ritual/wx_forge_quench.wav" : "sounds/ambience/buildings/blacksmith_hot_water_00.wav";
		vol = 0.84;
	}
	else if (_cue == "cultivate_infuse" || _cue == "manual_craft" || _cue == "manual_learn")
	{
		local arr = useWxSfx
			? ["sounds/wx_ritual/wx_qi_meditate.wav"]
			: ["sounds/crafting/crafting_general_01.wav", "sounds/crafting/crafting_general_02.wav", "sounds/crafting/crafting_general_03.wav"];
		pick = arr[::Math.rand(0, arr.len() - 1)];
		vol = 0.76;
	}
	else if (_cue == "wash_start")
	{
		pick = useWxSfx ? "sounds/wx_ritual/wx_marrow_wash.wav" : "sounds/combat/rally_the_troops_01.wav";
		vol = 0.72;
	}
	else if (_cue == "pill_drink")
	{
		local arr = ["sounds/inventory/pills_swallow_01.wav", "sounds/combat/drink_01.wav", "sounds/combat/drink_02.wav"];
		pick = arr[::Math.rand(0, arr.len() - 1)];
		vol = 0.82;
	}
	else if (_cue == "sect_gain")
	{
		local arr = ["sounds/coins_01.wav", "sounds/coins_02.wav", "sounds/coins_03.wav"];
		pick = arr[::Math.rand(0, arr.len() - 1)];
		vol = 0.76;
	}
	else if (_cue == "spar_clash")
	{
		local arr = useWxSfx
			? ["sounds/wx_combat/wx_sword_qi_01.wav", "sounds/wx_combat/wx_sword_qi_02.wav", "sounds/wx_combat/wx_palm_dragon_01.wav"]
			: ["sounds/combat/riposte_01.wav", "sounds/combat/riposte_02.wav", "sounds/combat/riposte_03.wav", "sounds/combat/shield_hit_metal_01.wav"];
		pick = arr[::Math.rand(0, arr.len() - 1)];
		vol = 0.78;
	}
	else if (_cue == "offend_crack")
	{
		pick = useWxSfx ? "sounds/wx_combat/wx_thunder_quake_01.wav" : "sounds/combat/shatter_hit_01.wav";
		vol = 0.80;
	}
	else if (_cue == "disguise_smoke")
	{
		pick = useWxSfx ? "sounds/wx_combat/wx_qinggong_step_01.wav" : "sounds/barber_01.wav";
		vol = 0.80;
	}
	else if (_cue == "heal_chime")
	{
		local arr = useWxSfx
			? ["sounds/wx_ritual/wx_qi_meditate.wav", "sounds/wx_combat/wx_golden_bell_01.wav"]
			: ["sounds/ambience/buildings/temple_bell_01.wav", "sounds/ambience/buildings/temple_bell_02.wav"];
		pick = arr[::Math.rand(0, arr.len() - 1)];
		vol = 0.75;
	}
	else if (_cue == "sweep_whoosh")
	{
		pick = "sounds/cloth_01.wav";
		vol = 0.78;
	}

	if (pick == null) return false;
	try { ::Sound.play(pick, vol); return true; } catch (_e) { return false; }
};

::Wuxia.UI.buildManualShowcaseCard <- function( _manualID, _extraTag = "" )
{
	local def = ::Wuxia.Slots.getManualDef(_manualID);
	if (def == null)
	{
		return {
			name        = _manualID,
			icon        = "ui/items/misc/wx_book_waigong_common.png",
			overlayIcon = "",
			gradeTitle  = "武学秘籍",
			gradeColor  = "#d7b174",
			subLabel    = _extraTag,
			description = ""
		};
	}
	local qKey = (def.Quality == "secret") ? "supreme" : def.Quality;
	local qLbl = (def.Quality in ::Wuxia.Text.Qualities) ? ::Wuxia.Text.Qualities[def.Quality] : def.Quality;
	local catLbl = (def.Category in ::Wuxia.Text.Categories) ? ::Wuxia.Text.Categories[def.Category] : def.Category;
	local qCols = { common = "#c8ba9e", sect = "#5ec47a", secret = "#b58ae6", supreme = "#b58ae6", unique = "#f0bc42" };
	local qCol = (def.Quality in qCols) ? qCols[def.Quality] : "#d7b174";
	local skIco = (def.Icon != null && def.Icon != "")
		? ((def.Icon.find("ui/") == 0) ? def.Icon : ("ui/" + def.Icon))
		: "";
	local sub = qLbl + " · " + catLbl + (_extraTag != "" ? (" · " + _extraTag) : "");
	return {
		id          = def.ID,
		name        = "《" + def.Name + "》",
		icon        = "ui/items/misc/wx_book_" + def.Category + "_" + qKey + ".png",
		overlayIcon = skIco,
		gradeTitle  = qLbl,
		gradeColor  = qCol,
		subLabel    = sub,
		description = ("Description" in def && def.Description != null) ? def.Description : ""
	};
};

::Wuxia.UI.attachSectTeaHouseRPCs <- function( q, _allowTeaHouse = false, _allowSanctum = false )
{
	if (!::Wuxia.qHas(q, "onWXShowcaseSound"))
	{
		q.onWXShowcaseSound <- function( _cue )
		{
			local key = (typeof _cue == "array" && _cue.len() > 0) ? _cue[0] : _cue;
			::Wuxia.UI.playShowcaseSound(key);
			return { ok = true };
		};
	}

	q.onWXGetSectRelations <- function( _data = null )
	{
		return ::Wuxia.UI.buildSectRelationsDirectory(_allowTeaHouse, _allowSanctum);
	};

	q.onWXGetActiveSectQuests <- function( _data = null )
	{
		local list = ("SectRelations" in ::Wuxia && "getAllActiveSanctumQuests" in ::Wuxia.SectRelations)
			? ::Wuxia.SectRelations.getAllActiveSanctumQuests()
			: [];
		return { ok = true, quests = list };
	};

	q.onWXTeaHouseBuyManual <- function( _data )
	{
		if (!_allowTeaHouse && !_allowSanctum)
			return { ok = false, reason = "此卷仅为随身【江湖名刺录】情报册——如需请教秘籍，请亲赴城镇【迎客酒肆 · 二楼茶座】或各派【独立山门】！" };
		if (_data == null || typeof _data != "array" || _data.len() < 2)
			return { ok = false, reason = "参数缺失。" };
		local op = ::Wuxia.SectRelations.teaHouseBuyManual(_data[0], _data[1]);
		if (!op.ok) return op;
		local payload = ::Wuxia.UI.buildSectRelationsDirectory(_allowTeaHouse, _allowSanctum);
		payload.actionMessage <- op.message;
		if ("showcase" in op && op.showcase != null) payload.wxShowcase <- op.showcase;
		return payload;
	};

	q.onWXTeaHouseBanquet <- function( _data )
	{
		if (!_allowTeaHouse && !_allowSanctum)
			return { ok = false, reason = "此卷仅为随身【江湖名刺录】情报册——如需设席结交，请亲赴城镇【迎客酒肆 · 二楼茶座】或各派【独立山门】！" };
		local sid = (typeof _data == "array" && _data.len() > 0) ? _data[0] : ("" + _data);
		local op = ::Wuxia.SectRelations.teaHouseBanquet(sid);
		if (!op.ok) return op;
		local payload = ::Wuxia.UI.buildSectRelationsDirectory(_allowTeaHouse, _allowSanctum);
		payload.actionMessage <- op.message;
		if ("showcase" in op && op.showcase != null) payload.wxShowcase <- op.showcase;
		return payload;
	};

	q.onWXTeaHouseSpar <- function( _data )
	{
		if (!_allowTeaHouse && !_allowSanctum)
			return { ok = false, reason = "此卷仅为随身【江湖名刺录】情报册——如需拆招切磋，请亲赴城镇【迎客酒肆 · 二楼茶座】或各派【独立山门】！" };
		if (_data == null || typeof _data != "array" || _data.len() < 2)
			return { ok = false, reason = "参数缺失。" };
		local op = ::Wuxia.SectRelations.teaHouseSpar(_data[0], _data[1]);
		if (!op.ok) return op;
		local payload = ::Wuxia.UI.buildSectRelationsDirectory(_allowTeaHouse, _allowSanctum);
		payload.actionMessage <- op.message;
		if ("showcase" in op && op.showcase != null) payload.wxShowcase <- op.showcase;
		return payload;
	};

	q.onWXTavernInquireRumor <- function( _data = null )
	{
		if (!_allowTeaHouse)
			return { ok = false, reason = "须置身城镇【迎客酒肆】内，方可向掌柜酒保打探山门秘闻与丹方线索！" };
		local op = ::Wuxia.SectRelations.tavernInquireRumor();
		if (!op.ok) return op;
		local payload = ::Wuxia.UI.buildSectRelationsDirectory(_allowTeaHouse, _allowSanctum);
		payload.actionMessage <- op.message;
		if ("showcase" in op && op.showcase != null) payload.wxShowcase <- op.showcase;
		return payload;
	};

	q.onWXSanctumAskAlchemy <- function( _data )
	{
		if (!_allowSanctum)
			return { ok = false, reason = "须亲赴该派【独立山门】丹堂，方可请教不传丹诀！" };
		local sid = (typeof _data == "array" && _data.len() > 0) ? _data[0] : ("" + _data);
		local op = ::Wuxia.SectRelations.sanctumAskAlchemy(sid);
		if (!op.ok) return op;
		local payload = ::Wuxia.UI.buildSectRelationsDirectory(_allowTeaHouse, _allowSanctum);
		payload.actionMessage <- op.message;
		if ("showcase" in op && op.showcase != null) payload.wxShowcase <- op.showcase;
		return payload;
	};

	q.onWXSanctumStartBattle <- function( _data )
	{
		if (!_allowSanctum)
			return { ok = false, reason = "须亲率义社登临该派【独立山门】，方能闯阵求道！" };
		if (_data == null || typeof _data != "array" || _data.len() < 2)
			return { ok = false, reason = "参数缺失。" };
		return ::Wuxia.SectRelations.sanctumStartBattle(_data[0], _data[1]);
	};

	q.onWXSanctumRecruitDisciple <- function( _data )
	{
		if (!_allowSanctum)
			return { ok = false, reason = "须亲赴该派【独立山门】求贤堂，方可延请门人下山助拳！" };
		local sid = (typeof _data == "array" && _data.len() > 0) ? _data[0] : ("" + _data);
		local op = ::Wuxia.SectRelations.sanctumRecruitDisciple(sid);
		if (!op.ok) return op;
		local payload = ::Wuxia.UI.buildSectRelationsDirectory(_allowTeaHouse, _allowSanctum);
		payload.actionMessage <- op.message;
		if ("showcase" in op && op.showcase != null) payload.wxShowcase <- op.showcase;
		return payload;
	};

	q.onWXSanctumElderEmpower <- function( _data )
	{
		if (!_allowSanctum)
			return { ok = false, reason = "须亲赴该派【独立山门】传功殿，方可请求宿老传功灌顶！" };
		local sid = (typeof _data == "array" && _data.len() > 0) ? _data[0] : ("" + _data);
		local op = ::Wuxia.SectRelations.sanctumElderEmpower(sid);
		if (!op.ok) return op;
		local payload = ::Wuxia.UI.buildSectRelationsDirectory(_allowTeaHouse, _allowSanctum);
		payload.actionMessage <- op.message;
		if ("showcase" in op && op.showcase != null) payload.wxShowcase <- op.showcase;
		return payload;
	};

	q.onWXSanctumHealInternal <- function( _data )
	{
		if (!_allowSanctum)
			return { ok = false, reason = "须亲赴该派【独立山门】传功殿，方可请求长老推宫过穴疗伤！" };
		local sid = (typeof _data == "array" && _data.len() > 0) ? _data[0] : ("" + _data);
		local op = ::Wuxia.SectRelations.sanctumHealInternal(sid);
		if (!op.ok) return op;
		local payload = ::Wuxia.UI.buildSectRelationsDirectory(_allowTeaHouse, _allowSanctum);
		payload.actionMessage <- op.message;
		if ("showcase" in op && op.showcase != null) payload.wxShowcase <- op.showcase;
		return payload;
	};

	q.onWXSanctumHandleQuest <- function( _data )
	{
		if (!_allowSanctum)
			return { ok = false, reason = "须亲赴该派【独立山门】知客堂，方可揭领或复命宗门法帖！" };
		local sid = (typeof _data == "array" && _data.len() > 0) ? _data[0] : ("" + _data);
		local op = ::Wuxia.SectRelations.sanctumHandleQuest(sid);
		if (!op.ok) return op;
		local payload = ::Wuxia.UI.buildSectRelationsDirectory(_allowTeaHouse, _allowSanctum);
		payload.actionMessage <- op.message;
		payload.activeSectQuests <- ::Wuxia.SectRelations.getAllActiveSanctumQuests();
		if ("showcase" in op && op.showcase != null) payload.wxShowcase <- op.showcase;
		return payload;
	};

	q.onWXSanctumBuyHerbs <- function( _data )
	{
		if (!_allowSanctum)
			return { ok = false, reason = "须亲赴该派【独立山门】药庐，方可求购本门道地灵草！" };
		local sid  = (typeof _data == "array" && _data.len() > 0) ? _data[0] : ("" + _data);
		local tier = (typeof _data == "array" && _data.len() >= 2 && _data[1] != null && _data[1] != "") ? _data[1] : "common";
		local op = ::Wuxia.SectRelations.sanctumBuyHerbs(sid, tier);
		if (!op.ok) return op;
		local payload = ::Wuxia.UI.buildSectRelationsDirectory(_allowTeaHouse, _allowSanctum);
		payload.actionMessage <- op.message;
		if ("showcase" in op && op.showcase != null) payload.wxShowcase <- op.showcase;
		return payload;
	};

	q.onWXCloseSanctum <- function( _data = null )
	{
		if ("World" in getroottable() && ::World != null && ("Flags" in ::World) && ::World.Flags != null)
			::World.Flags.set("wx_active_sanctum_sect", "");
		return { ok = true };
	};

	q.onWXGetModSettings <- function( _data = null )
	{
		return ::Wuxia.Settings.getPayload();
	};

	q.onWXUpdateModSetting <- function( _data )
	{
		if (_data == null || typeof _data != "array" || _data.len() < 2)
			return ::Wuxia.Settings.getPayload();
		return ::Wuxia.Settings.updateSetting("" + _data[0], _data[1]);
	};
};

::Wuxia.HooksMod.hook("scripts/ui/screens/tactical/modules/turn_sequence_bar/turn_sequence_bar", function( q )
{
	q.convertEntityToUIData = @(__original) function( _entity, _isLastEntity = false )
	{
		if (_entity != null && ("Armory" in ::Wuxia))
		{
			::Wuxia.Armory.syncActorHandheldAndArmor(_entity);
		}
		local data = __original(_entity, _isLastEntity);
		if (_entity != null && data != null && ("actionPointsMax" in data))
		{
			local c = _entity.getSkills().getSkillByID("special.wx_martial_container");
			data.wxPermanentAP <- data.actionPointsMax - (c == null ? 0 : c.m.TemporaryAPOverflow);
		}
		return data;
	};

	q.onQueryEntitySkills = @(__original) function( _data )
	{
		local res = __original(_data);
		if (res == null || typeof res != "array" || !("Tactical" in getroottable()) || ::Tactical == null)
			return res;

		local entity = ::Tactical.getEntityByID(_data);
		if (entity == null || entity.getSkills() == null)
			return res;

		for (local i = 0; i < res.len(); i = ++i)
		{
			local entry = res[i];
			if (entry == null || !("id" in entry)) continue;
			local sk = entity.getSkills().getSkillByID(entry.id);
			if (sk == null) continue;
			entry.wxAp <- sk.getActionPointCost();
			entry.wxQi <- sk.getFatigueCost();
			entry.wxAvailAp <- entity.getActionPoints();
			entry.wxAvailQi <- ::Math.max(0, entity.getFatigueMax() - entity.getFatigue());
			local sid = entry.id;
			local lineage = "basic";
			if (sid.find("actives.wx_meditate") == 0 || sid.find("actives.wx_neigong_") == 0 || sid.find("actives.wx_blood_") == 0)
				lineage = "neigong";
			else if (sid.find("actives.wx_qinggong_") == 0 || sid == "actives.footwork" || sid == "actives.rotation")
				lineage = "qinggong";
			else if (sid.find("actives.wx_tactics_") == 0 || sid.find("actives.wx_rally_") == 0 || sid.find("actives.wx_shield_") == 0)
				lineage = "tactics";
			else if (sid.find("actives.wx_") == 0)
				lineage = "waigong";
			entry.wxLineage <- lineage;
		}
		return res;
	};
});

// Guard vanilla `tooltip.nut` against null cursor coordinates when window is unfocused / Alt-Tabbed during load
::Wuxia.HooksMod.hook("scripts/ui/screens/tooltip/modules/tooltip", function( q )
{
	if (::Wuxia.qHas(q, "mouseEnterTile"))
	{
		q.mouseEnterTile = @(__original) function( _x, _y, _entityId = null )
		{
			if (_x == null || _y == null) return;
			return __original(_x, _y, _entityId);
		};
	}
	if (::Wuxia.qHas(q, "mouseHoverTile"))
	{
		q.mouseHoverTile = @(__original) function( _x, _y )
		{
			if (_x == null || _y == null) return;
			return __original(_x, _y);
		};
	}
});
