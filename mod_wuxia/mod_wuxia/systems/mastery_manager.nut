// Mastery Manager: exp accumulation, requirement validation, 3-tier breakthroughs, pill infusion

::Wuxia.Mastery.getActorBaseStat <- function( _actor, _statKey )
{
	if (_actor == null) return 0;
	local b = _actor.getBaseProperties();
	if (b == null) return 0;
	if (_statKey in b) return b[_statKey];
	return 0;
};

::Wuxia.Mastery.checkRequirements <- function( _actor, _manualDef )
{
	if (_manualDef == null || !("Requirements" in _manualDef))
		return { Met = true, Missing = [] };

	local missing = [];
	local statLabels = {
		Hitpoints     = "气血",
		Bravery       = "定力",
		Stamina       = "内息",
		Initiative    = "身法",
		MeleeSkill    = "武艺",
		RangedSkill   = "射艺",
		MeleeDefense  = "招架",
		RangedDefense = "避暗"
	};

	foreach (k, reqVal in _manualDef.Requirements)
	{
		if (k == "MinStarsOnAny")
		{
			local maxStar = 0;
			if (::Wuxia.Appearance.hasMember(_actor, "m") && ::Wuxia.Appearance.hasMember(_actor.m, "Talents"))
			{
				foreach (st in _actor.m.Talents)
				{
					if (st > maxStar) maxStar = st;
				}
			}
			if (maxStar < reqVal)
				missing.push("任意根骨需 ≥ " + reqVal + "★");
		}
		else
		{
			local cur = ::Wuxia.Mastery.getActorBaseStat(_actor, k);
			if (cur < reqVal)
			{
				local lbl = (k in statLabels) ? statLabels[k] : k;
				missing.push(lbl + "需 ≥ " + reqVal + "（当前 " + cur + "）");
			}
		}
	}

	return {
		Met = missing.len() == 0,
		Missing = missing
	};
};

::Wuxia.Mastery.getNextTierExpNeeded <- function( _slot )
{
	if (_slot == null || _slot.ManualID == null || _slot.Tier <= 0) return 0;
	local def = ::Wuxia.Slots.getManualDef(_slot.ManualID);
	if (def == null) return 0;
	if (_slot.IsFragment) return 0; // Fragment-learned manuals cap at Tier 1
	if (_slot.Tier >= def.Levels.len()) return 0;
	return def.Levels[_slot.Tier].ExpNeeded;
};

::Wuxia.Mastery.tryAdvanceSlot <- function( _actor, _slotIndex )
{
	local c = ::Wuxia.Slots.getContainer(_actor);
	if (c == null || _slotIndex < 0 || _slotIndex >= c.m.Slots.len())
		return { Advanced = false, BlockedByReq = false, Missing = [] };

	local slot = c.m.Slots[_slotIndex];
	if (slot.ManualID == null || slot.Tier <= 0 || slot.IsFragment)
		return { Advanced = false, BlockedByReq = false, Missing = [] };

	local def = ::Wuxia.Slots.getPracticedDef(c, slot);
	if (def == null || slot.Tier >= def.Levels.len())
		return { Advanced = false, BlockedByReq = false, Missing = [] };

	local needed = def.Levels[slot.Tier].ExpNeeded;
	if (slot.Exp < needed)
		return { Advanced = false, BlockedByReq = false, Missing = [] };

	// Gate Tier 3 (Grandmaster breakthrough) behind Requirements
	local nextTier = slot.Tier + 1;
	if (nextTier >= 3)
	{
		local reqCheck = ::Wuxia.Mastery.checkRequirements(_actor, def);
		if (!reqCheck.Met)
		{
			slot.Exp = needed; // Hold at cap until requirements are met
			c.syncSlotToLearned(_slotIndex);
			return { Advanced = false, BlockedByReq = true, Missing = reqCheck.Missing };
		}
	}

	slot.Exp -= needed;
	slot.Tier = nextTier;
	c.syncSlotToLearned(_slotIndex);

	// Grant one-time unique mastery rewards (e.g. Taixu Zhenjing Tier 3 Wash Chance)
	local lvlData = def.Levels[slot.Tier - 1];
	if ("GrantWashChance" in lvlData.Flags && lvlData.Flags.GrantWashChance > 0)
	{
		if (!(def.ID in c.m.UsedUniqueEffects))
		{
			c.m.UsedUniqueEffects[def.ID] <- true;
			c.m.PendingWashChances += lvlData.Flags.GrantWashChance;
		}
	}

	c.syncGrantedSkills();
	_actor.getSkills().update();

	return { Advanced = true, NewTier = slot.Tier, ManualName = def.Name, BlockedByReq = false, Missing = [] };
};

::Wuxia.Mastery.addExpToSlot <- function( _actor, _slotIndex, _amount )
{
	if (_amount <= 0) return { Advanced = false };
	local c = ::Wuxia.Slots.getContainer(_actor);
	if (c == null || _slotIndex < 0 || _slotIndex >= c.m.Slots.len())
		return { Advanced = false };

	local slot = c.m.Slots[_slotIndex];
	if (slot.ManualID == null || slot.Tier <= 0 || slot.IsFragment)
		return { Advanced = false };

	local def = ::Wuxia.Slots.getPracticedDef(c, slot);
	if (def == null || slot.Tier >= def.Levels.len())
		return { Advanced = false };

	local previousExp = slot.Exp;
	local spentOnBreakthroughs = 0;
	slot.Exp += _amount;
	c.syncSlotToLearned(_slotIndex);

	local result = { Advanced = false, NewTier = slot.Tier, BlockedByReq = false, Missing = [], ExpGained = 0 };
	// Allow chained advances if a huge pill/battle burst crosses a threshold
	local guard = 0;
	while (guard < 3)
	{
		guard = ++guard;
		local step = ::Wuxia.Mastery.tryAdvanceSlot(_actor, _slotIndex);
		if (step.Advanced)
		{
			result.Advanced = true;
			result.NewTier = step.NewTier;
			spentOnBreakthroughs += def.Levels[step.NewTier - 1].ExpNeeded;
		}
		else
		{
			result.BlockedByReq = step.BlockedByReq;
			result.Missing = step.Missing;
			break;
		}
	}
	result.ExpGained = slot.Exp + spentOnBreakthroughs - previousExp;
	return result;
};

// Backward-compatible alias used by Sanctum Elder Empowerment & Tea Sparring
::Wuxia.Mastery.addSlotExp <- ::Wuxia.Mastery.addExpToSlot;

// Track active martial moves used by a brother during the current battle for slot exercise mastery bonus
::Wuxia.Mastery.recordSkillUse <- function( _actor, _skillID )
{
	if (_actor == null || _skillID == null || _skillID == "" || !::Wuxia.hasMember(_actor, "m") || _actor.m == null) return;
	if (!("WX_BattleUsedSkills" in _actor.m) || typeof _actor.m.WX_BattleUsedSkills != "table")
		_actor.m.WX_BattleUsedSkills <- {};
	if (_skillID in _actor.m.WX_BattleUsedSkills)
		_actor.m.WX_BattleUsedSkills[_skillID] += 1;
	else
		_actor.m.WX_BattleUsedSkills[_skillID] <- 1;
};

::Wuxia.Mastery.resetBattleSkillUses <- function( _actor )
{
	if (_actor != null && ::Wuxia.hasMember(_actor, "m") && _actor.m != null)
		_actor.m.WX_BattleUsedSkills <- {};
};

// Compute dynamic post-battle mastery XP based on enemy battle difficulty, Training Hall, Retinue & Origin rules
::Wuxia.Mastery.computeBaseBattleExp <- function( _actor )
{
	local baseExp = 28;
	try
	{
		if ("Tactical" in getroottable() && ::Tactical != null && ("Entities" in ::Tactical) && ::Tactical.Entities != null)
		{
			local combatStats = null;
			if ("State" in ::Tactical && ::Tactical.State != null && ("m" in ::Tactical.State) && ("StrategicProperties" in ::Tactical.State.m) && ::Tactical.State.m.StrategicProperties != null)
			{
				local sp = ::Tactical.State.m.StrategicProperties;
				if ("Party" in sp && sp.Party != null && ::Wuxia.hasMember(sp.Party, "getStrength"))
				{
					local str = sp.Party.getStrength();
					if (str >= 420) baseExp = 68;
					else if (str >= 280) baseExp = 52;
					else if (str >= 160) baseExp = 40;
					else if (str >= 90) baseExp = 32;
					else baseExp = 24;
				}
				if ("IsBossFight" in sp && sp.IsBossFight) baseExp += 18;
				if ("LocationTemplate" in sp && sp.LocationTemplate != null) baseExp += 8;
			}
			// Also check combat kills / ShanHai boss flag on tactical state
			if ("CombatStats" in _actor.m && _actor.m.CombatStats != null)
				combatStats = _actor.m.CombatStats;
			if (combatStats != null)
			{
				local kills = ("Kills" in combatStats) ? combatStats.Kills : 0;
				local dmg   = ("DamageDealtHitpoints" in combatStats) ? combatStats.DamageDealtHitpoints : 0;
				local taken = ("DamageReceivedHitpoints" in combatStats) ? combatStats.DamageReceivedHitpoints : 0;
				baseExp += ::Math.min(18, kills * 5 + (dmg >= 120 ? 5 : 0) + (taken >= 30 ? 4 : 0));
			}
		}
	}
	catch (_e) {}

	// ShanHai Apex Boss fight global bonus
	if ("World" in getroottable() && ::World != null && ("Flags" in ::World) && ::World.Flags != null && ::World.Flags.get("wx_last_battle_shanhai_boss"))
	{
		baseExp += 28;
	}

	return ::Math.max(20, ::Math.min(95, baseExp));
};

::Wuxia.Mastery.awardPostBattleExp <- function( _actor )
{
	local c = ::Wuxia.Slots.getContainer(_actor);
	if (c == null) return;

	local baseGain = ::Wuxia.Mastery.computeBaseBattleExp(_actor);
	local sk = (::Wuxia.hasMember(_actor, "getSkills")) ? _actor.getSkills() : null;

	// 1. Pill Tihu buff multiplier
	local mult = 1.0;
	local pBuff = sk != null ? sk.getSkillByID("effects.wx_pill_battle_buff") : null;
	if (pBuff != null && ("HasTihu" in pBuff.m) && pBuff.m.HasTihu)
	{
		local sc = (("PotencyScalePct" in pBuff.m) ? pBuff.m.PotencyScalePct : 100) / 100.0;
		mult += 0.50 * sc;
	}
	else if (("WX_TihuMasteryMult" in _actor.m) && _actor.m.WX_TihuMasteryMult > 1.0)
	{
		mult += (_actor.m.WX_TihuMasteryMult - 1.0);
	}
	if ("WX_TihuMasteryMult" in _actor.m)
		_actor.m.WX_TihuMasteryMult = 1.0;

	// 2. Town Training Hall (`effects.trained` -> 演武木人馆) grants +45% martial mastery XP
	//    (also honors `WX_HadTrainedThisBattle` when a 1-battle training buff just expired in `onCombatFinished`!)
	local hadTrained = (sk != null && sk.hasSkill("effects.trained"))
		|| (("WX_HadTrainedThisBattle" in _actor.m) && _actor.m.WX_HadTrainedThisBattle);
	if (hadTrained)
		mult += 0.45;
	if ("WX_HadTrainedThisBattle" in _actor.m)
		_actor.m.WX_HadTrainedThisBattle = false;

	// 3. Retinue Drill Sergeant (`follower.drill_sergeant` -> 演武总教头) boosts Tier 1-2 manuals by +25%!
	local hasDrill = ("World" in getroottable() && ::World != null && ("Retinue" in ::World) && ::World.Retinue != null && ::World.Retinue.hasFollower("follower.drill_sergeant"));

	// 4. Starting Origin persistent mastery rules
	local originID = "";
	if ("World" in getroottable() && ::World != null && ("Assets" in ::World) && ::World.Assets != null && ::World.Assets.getOrigin() != null)
		originID = ::World.Assets.getOrigin().getID();
	if (originID == "scenario.wx_origin_lone_sword")
		mult += 0.25;

	local usedMap = ("WX_BattleUsedSkills" in _actor.m && typeof _actor.m.WX_BattleUsedSkills == "table") ? _actor.m.WX_BattleUsedSkills : {};

	for (local i = 0; i < c.m.Slots.len(); i = ++i)
	{
		local slot = c.m.Slots[i];
		if (slot.ManualID == null || slot.Tier <= 0 || slot.IsFragment) continue;
		local def = ::Wuxia.Slots.getPracticedDef(c, slot);
		if (def == null) continue;

		local slotMult = mult;
		if (hasDrill && slot.Tier < 3)
			slotMult += 0.25;
		if (originID == "scenario.wx_origin_shaolin_monks" && (def.Category == "neigong" || def.Category == "henglian"))
			slotMult += 0.20;

		// Per-slot active exercise bonus: actually using a manual's granted skill in battle yields +10..+18 extra mastery XP!
		local exerciseBonus = 0;
		if (slot.Tier - 1 < def.Levels.len())
		{
			for (local lv = 0; lv < slot.Tier; lv = ++lv)
			{
				foreach (skId in def.Levels[lv].GrantSkills)
				{
					local fullId = (skId.find("actives.") == 0) ? skId : ("actives." + skId);
					if ((fullId in usedMap) || (skId in usedMap))
					{
						local uses = (fullId in usedMap) ? usedMap[fullId] : usedMap[skId];
						exerciseBonus = ::Math.max(exerciseBonus, ::Math.min(18, 8 + uses * 4));
					}
				}
			}
		}

		local finalGain = ::Math.max(12, ::Math.round((baseGain + exerciseBonus) * slotMult).tointeger());
		::Wuxia.Mastery.addExpToSlot(_actor, i, finalGain);
	}

	::Wuxia.Mastery.resetBattleSkillUses(_actor);
};

::Wuxia.Mastery.addExpToEquipped <- function( _actor, _baseGain )
{
	local c = ::Wuxia.Slots.getContainer(_actor);
	if (c == null) return;

	local gain = _baseGain;
	if (_actor != null && ::Wuxia.hasMember(_actor, "m") && _actor.m != null)
	{
		local mult = 1.0;
		local sk = (::Wuxia.hasMember(_actor, "getSkills")) ? _actor.getSkills() : null;
		local pBuff = sk != null ? sk.getSkillByID("effects.wx_pill_battle_buff") : null;
		if (pBuff != null && ("HasTihu" in pBuff.m) && pBuff.m.HasTihu)
		{
			local sc = (("PotencyScalePct" in pBuff.m) ? pBuff.m.PotencyScalePct : 100) / 100.0;
			mult = 1.0 + 0.50 * sc;
		}
		else if (("WX_TihuMasteryMult" in _actor.m) && _actor.m.WX_TihuMasteryMult > 1.0)
		{
			mult = _actor.m.WX_TihuMasteryMult;
		}
		if (mult > 1.0)
			gain = ::Math.max(_baseGain + 1, ::Math.round(_baseGain * mult).tointeger());
		if ("WX_TihuMasteryMult" in _actor.m)
			_actor.m.WX_TihuMasteryMult = 1.0;
	}

	for (local i = 0; i < c.m.Slots.len(); i = ++i)
	{
		local slot = c.m.Slots[i];
		if (slot.ManualID == null || slot.Tier <= 0 || slot.IsFragment) continue;
		::Wuxia.Mastery.addExpToSlot(_actor, i, gain);
	}
};

::Wuxia.Mastery.grantFlatExpToEquipped <- ::Wuxia.Mastery.addExpToEquipped;

::Wuxia.Mastery.checkInfusionSlot <- function( _actor, _container, _slotIndex )
{
	if (_container == null || _slotIndex < 0 || _slotIndex >= _container.m.Slots.len())
		return { Ok = false, Reason = "无效槽位。" };

	local slot = _container.m.Slots[_slotIndex];
	if (slot.ManualID == null || slot.Tier <= 0)
		return { Ok = false, Reason = "该插槽尚未装配功法。" };
	if (slot.IsFragment)
		return { Ok = false, Reason = "残本强修止步一重，无法灌注火候。" };

	local def = ::Wuxia.Slots.getPracticedDef(_container, slot);
	if (def == null)
		return { Ok = false, Reason = "此功法已封存，更换较早槽位的同类功法即可恢复。" };
	if (slot.Tier >= def.Levels.len())
		return { Ok = false, Reason = "该功法已达三重大成。" };
	if (slot.Tier >= 2 && slot.Exp >= def.Levels[slot.Tier].ExpNeeded && !this.checkRequirements(_actor, def).Met)
		return { Ok = false, Reason = "此功法火候已满，须先满足三重突破条件。" };

	return { Ok = true, Def = def };
};

::Wuxia.Mastery.infuseWithPill <- function( _actor, _slotIndex, _expAmount )
{
	local check = this.checkInfusionSlot(_actor, ::Wuxia.Slots.getContainer(_actor), _slotIndex);
	if (!check.Ok) return check;
	local res = ::Wuxia.Mastery.addExpToSlot(_actor, _slotIndex, _expAmount);
	return {
		Ok = true,
		ManualName = check.Def.Name,
		ExpAmount = res.ExpGained,
		Advanced = res.Advanced,
		NewTier = res.NewTier,
		BlockedByReq = res.BlockedByReq,
		Missing = res.Missing
	};
};

// Infuse 1 spare martial page into an equipped non-fragment manual slot (参悟化功)
::Wuxia.Mastery.getPageBaseExp <- function( _quality )
{
	if (_quality == "unique") return 120;
	if (_quality == "secret") return 75;
	if (_quality == "sect")   return 40;
	return 20;
};

::Wuxia.Mastery.infuseWithPage <- function( _actor, _slotIndex, _pageManualID )
{
	local check = this.checkInfusionSlot(_actor, ::Wuxia.Slots.getContainer(_actor), _slotIndex);
	if (!check.Ok) return check;

	local pageDef = ::Wuxia.Slots.getManualDef(_pageManualID);
	if (pageDef == null)
		return { Ok = false, Reason = "未知武学残页。" };

	local def = check.Def;
	local baseExp = ::Wuxia.Mastery.getPageBaseExp(pageDef.Quality);
	local mult = 1.0;
	local resonance = "";
	if (pageDef.ID == def.ID)
	{
		mult = 1.5;
		resonance = "同名印证 (+50%)";
	}
	else if (pageDef.Category == def.Category)
	{
		mult = 1.25;
		resonance = "同脉触类 (+25%)";
	}

	local expAmt = ::Math.max(1, ::Math.floor(baseExp * mult));
	local res = ::Wuxia.Mastery.addExpToSlot(_actor, _slotIndex, expAmt);
	return {
		Ok = true,
		ManualName = def.Name,
		PageManualName = pageDef.Name,
		ExpAmount = res.ExpGained,
		Resonance = resonance,
		Advanced = res.Advanced,
		NewTier = res.NewTier,
		BlockedByReq = res.BlockedByReq,
		Missing = res.Missing
	};
};
