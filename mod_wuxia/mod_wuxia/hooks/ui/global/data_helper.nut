// UI Data serialization helpers + data_helper hook for Character Screen (武学修为 & 藏经阁) & Tactical HUD

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

::Wuxia.UI.buildPassiveSummaryTags <- function( _agg )
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
	local totalPen = ::Math.min(0.25, _agg.DirectDmgBonus + _agg.EmptyOffhandPen);
	if (totalPen > 0.001) tags.push("穿甲+" + ::Math.round(totalPen * 100) + "%");
	if (_agg.ArmorDmgBonus > 0.001) tags.push("破甲+" + ::Math.round(_agg.ArmorDmgBonus * 100) + "%");
	if (_agg.WeaponQiDiscount > 0.001) tags.push("省气" + ::Math.round(_agg.WeaponQiDiscount * 100) + "%");
	if (_agg.QiShieldPct > 0.001) tags.push("护体" + ::Math.round(_agg.QiShieldPct * 100) + "%");
	if (_agg.InitToDefRatio > 0.001) tags.push("身法转防" + ::Math.round(_agg.InitToDefRatio * 100) + "%");
	if (_agg.HeavyArmorScale > 0.001) tags.push("披甲减负" + ::Math.round(_agg.HeavyArmorScale * 100) + "%");
	return tags;
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
	local aggTags  = ::Wuxia.UI.buildPassiveSummaryTags(aggFlags);

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
		appearance             = appInfo,
		talents                = talents,
		baseStats              = baseStats,
		attrLabels             = ::Wuxia.Text.Attributes,
		slots                  = slotsData,
		learnedManuals         = learnedManuals,
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

	if ("convertItemToUIData" in q)
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

::Wuxia.UI.buildSectRelationsDirectory <- function()
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

	local curTown = ("getCurrentTown" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getCurrentTown() : null;
	local townSeats = (curTown != null && ("getTownTeaHouseSeats" in ::Wuxia.SectRelations))
		? ::Wuxia.SectRelations.getTownTeaHouseSeats(curTown)
		: {};
	local curMoney = ("World" in getroottable() && ::World != null && ("Assets" in ::World) && ::World.Assets != null)
		? ::World.Assets.getMoney()
		: 0;

	local sectList = [];
	local ids = [];
	foreach (sid, _ in ::Wuxia.Config.Sects) ids.push(sid);
	ids.sort();

	foreach (sid in ids)
	{
		local s = ::Wuxia.Config.Sects[sid];
		local rel = ::Wuxia.SectRelations.getRelation(sid);
		local isVendetta = ::Wuxia.SectRelations.isVendettaActive(sid);
		local statusLbl = "素昧平生";
		if (isVendetta) statusLbl = "不死不休 · 寻仇追缉";
		else if (rel <= -15) statusLbl = "结怨冷眼";
		else if (rel >= 60) statusLbl = "莫逆之交 · 倾囊相授";
		else if (rel >= 25) statusLbl = "礼尚往来 · 登堂请教";
		else if (rel > 5) statusLbl = "点头之交";

		local mList = [];
		if ("ShopManuals" in s)
		{
			foreach (sm in s.ShopManuals)
			{
				local mdef = ::Wuxia.Slots.getManualDef(sm.ManualID);
				if (mdef == null) continue;
				mList.push({
					id              = mdef.ID,
					name            = mdef.Name,
					quality         = mdef.Quality,
					qualityLabel    = (mdef.Quality in ::Wuxia.Text.Qualities) ? ::Wuxia.Text.Qualities[mdef.Quality] : mdef.Quality,
					categoryLabel   = (mdef.Category in ::Wuxia.Text.Categories) ? ::Wuxia.Text.Categories[mdef.Category] : mdef.Category,
					minRel          = sm.MinRel,
					price           = sm.Price,
					unlocked        = (rel >= sm.MinRel),
					vaultBooks      = ::Wuxia.Library.getManualCount(mdef.ID),
					vaultPages      = ::Wuxia.Library.getPageCount(mdef.ID),
					fragmentsNeeded = mdef.FragmentsNeeded,
					learnedCount    = (mdef.ID in rosterLearnedCounts) ? rosterLearnedCounts[mdef.ID] : 0
				});
			}
		}

		local anchor = ("getSectAnchorInfo" in ::Wuxia.SectRelations)
			? ::Wuxia.SectRelations.getSectAnchorInfo(sid)
			: { townName = "", dir = "", dist = -1 };
		local isSeated = (sid in townSeats);
		local seatBadge = isSeated ? townSeats[sid] : "";
		local banqCd = ("getTeaCooldownLeft" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getTeaCooldownLeft("banq", sid, 3) : 0;
		local sparCd = ("getTeaCooldownLeft" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getTeaCooldownLeft("spar", sid, 5) : 0;

		local regKey = ("Region" in s) ? s.Region : "plains";
		local alignKey = ("Alignment" in s) ? s.Alignment : "neutral";
		sectList.push({
			id             = s.ID,
			name           = s.Name,
			region         = regKey,
			regionLabel    = ::Wuxia.SectRelations.getRegionLabel(regKey),
			alignment      = alignKey,
			alignmentLabel = (alignKey in alignLabels) ? alignLabels[alignKey] : "江湖门派",
			description    = ("Description" in s) ? s.Description : "",
			relation       = rel,
			vendettaRel    = s.VendettaRel,
			isVendetta     = isVendetta,
			statusLabel    = statusLbl,
			anchorTownName = anchor.townName,
			anchorDir      = anchor.dir,
			anchorDist     = anchor.dist,
			isSeatedInTown = isSeated,
			seatBadge      = seatBadge,
			banquetCd      = banqCd,
			sparCd         = sparCd,
			manuals        = mList
		});
	}

	sectList.sort(function( _a, _b ) {
		if (_a.isSeatedInTown != _b.isSeatedInTown) return _a.isSeatedInTown ? -1 : 1;
		if (_a.isSeatedInTown)
		{
			local rank = { ["本城驻地"] = 1, ["同城堂口"] = 2, ["同道传书"] = 3, ["地界行客"] = 4 };
			local ra = (_a.seatBadge in rank) ? rank[_a.seatBadge] : 9;
			local rb = (_b.seatBadge in rank) ? rank[_b.seatBadge] : 9;
			if (ra != rb) return ra < rb ? -1 : 1;
		}
		if (_a.relation != _b.relation) return _a.relation > _b.relation ? -1 : 1;
		return _a.id <=> _b.id;
	});

	local seatedCnt = 0;
	foreach (_k, _v in townSeats) seatedCnt += 1;

	return {
		ok              = true,
		inTown          = (curTown != null),
		townName        = (curTown != null ? curTown.getName() : ""),
		townSeatedCount = seatedCnt,
		money           = curMoney,
		localRegion     = (curTown != null && ("getSettlementRegion" in ::Wuxia.SectRelations))
			? ::Wuxia.SectRelations.getSettlementRegion(curTown)
			: ::Wuxia.SectRelations.getLocalRegion(),
		regions         = regions,
		sects           = sectList
	};
};

::Wuxia.UI.attachSectTeaHouseRPCs <- function( q )
{
	q.onWXGetSectRelations <- function( _data = null )
	{
		return ::Wuxia.UI.buildSectRelationsDirectory();
	};

	q.onWXTeaHouseBuyManual <- function( _data )
	{
		if (_data == null || typeof _data != "array" || _data.len() < 2)
			return { ok = false, reason = "参数缺失。" };
		local op = ::Wuxia.SectRelations.teaHouseBuyManual(_data[0], _data[1]);
		if (!op.ok) return op;
		local payload = ::Wuxia.UI.buildSectRelationsDirectory();
		payload.actionMessage <- op.message;
		return payload;
	};

	q.onWXTeaHouseBanquet <- function( _data )
	{
		local sid = (typeof _data == "array" && _data.len() > 0) ? _data[0] : ("" + _data);
		local op = ::Wuxia.SectRelations.teaHouseBanquet(sid);
		if (!op.ok) return op;
		local payload = ::Wuxia.UI.buildSectRelationsDirectory();
		payload.actionMessage <- op.message;
		return payload;
	};

	q.onWXTeaHouseSpar <- function( _data )
	{
		if (_data == null || typeof _data != "array" || _data.len() < 2)
			return { ok = false, reason = "参数缺失。" };
		local op = ::Wuxia.SectRelations.teaHouseSpar(_data[0], _data[1]);
		if (!op.ok) return op;
		local payload = ::Wuxia.UI.buildSectRelationsDirectory();
		payload.actionMessage <- op.message;
		return payload;
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
		local c = _entity.getSkills().getSkillByID("special.wx_martial_container");
		data.wxPermanentAP <- data.actionPointsMax - (c == null ? 0 : c.m.TemporaryAPOverflow);
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
