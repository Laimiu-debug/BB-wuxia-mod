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
			if ("m" in _actor && "Talents" in _actor.m)
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
			return { Advanced = false, BlockedByReq = true, Missing = reqCheck.Missing };
		}
	}

	slot.Exp -= needed;
	slot.Tier = nextTier;

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

	slot.Exp += _amount;

	local result = { Advanced = false, NewTier = slot.Tier, BlockedByReq = false, Missing = [] };
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
		}
		else
		{
			result.BlockedByReq = step.BlockedByReq;
			result.Missing = step.Missing;
			break;
		}
	}
	return result;
};

::Wuxia.Mastery.addExpToEquipped <- function( _actor, _baseGain )
{
	local c = ::Wuxia.Slots.getContainer(_actor);
	if (c == null) return;

	for (local i = 0; i < c.m.Slots.len(); i = ++i)
	{
		local slot = c.m.Slots[i];
		if (slot.ManualID == null || slot.Tier <= 0 || slot.IsFragment) continue;
		::Wuxia.Mastery.addExpToSlot(_actor, i, _baseGain);
	}
};

::Wuxia.Mastery.infuseWithPill <- function( _actor, _slotIndex, _expAmount )
{
	local c = ::Wuxia.Slots.getContainer(_actor);
	if (c == null || _slotIndex < 0 || _slotIndex >= c.m.Slots.len())
		return { Ok = false, Reason = "无效槽位。" };

	local slot = c.m.Slots[_slotIndex];
	if (slot.ManualID == null || slot.Tier <= 0)
		return { Ok = false, Reason = "该插槽尚未装配功法。" };
	if (slot.IsFragment)
		return { Ok = false, Reason = "残本强修止步一重，无法灌注火候。" };
	if (::Wuxia.Slots.getPracticedDef(c, slot) == null)
		return { Ok = false, Reason = "此功法已封存，更换较早槽位的同类功法即可恢复。" };

	local def = ::Wuxia.Slots.getManualDef(slot.ManualID);
	if (def == null || slot.Tier >= def.Levels.len())
		return { Ok = false, Reason = "该功法已达三重大成。" };

	local res = ::Wuxia.Mastery.addExpToSlot(_actor, _slotIndex, _expAmount);
	return {
		Ok = true,
		ManualName = def.Name,
		Advanced = res.Advanced,
		NewTier = res.NewTier,
		BlockedByReq = res.BlockedByReq,
		Missing = res.Missing
	};
};
