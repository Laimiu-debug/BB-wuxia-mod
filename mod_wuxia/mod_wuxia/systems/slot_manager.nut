// Martial Slot Manager: validation, equip/overwrite, scatter penalty, page crafting, conflict check

::Wuxia.Slots.getContainer <- function( _actor )
{
	if (_actor == null) return null;
	local skills = _actor.getSkills();
	if (skills == null) return null;

	local c = skills.getSkillByID("special.wx_martial_container");
	if (c == null)
	{
		c = ::new("scripts/skills/special/wx_martial_container");
		skills.add(c);
	}
	return c;
};

::Wuxia.Slots.getManualDef <- function( _manualID )
{
	if (_manualID == null || !(_manualID in ::Wuxia.Config.Manuals))
		return null;
	return ::Wuxia.Config.Manuals[_manualID];
};

::Wuxia.Slots.isCategoryAllowedInSlot <- function( _slotIndex, _category )
{
	if (_slotIndex < 0 || _slotIndex >= ::Wuxia.Config.SlotLayout.len())
		return false;
	local cfg = ::Wuxia.Config.SlotLayout[_slotIndex];
	foreach (allowed in cfg.AllowedCategories)
	{
		if (allowed == _category) return true;
	}
	return false;
};

::Wuxia.Slots.getActorLevel <- function( _actor )
{
	if (_actor != null && ("getLevel" in _actor))
		return _actor.getLevel();
	return 1;
};

::Wuxia.Slots.isSlotUnlocked <- function( _actor, _slotIndex )
{
	if (_slotIndex < 0 || _slotIndex >= ::Wuxia.Config.SlotLayout.len())
		return false;
	local cfg = ::Wuxia.Config.SlotLayout[_slotIndex];
	return ::Wuxia.Slots.getActorLevel(_actor) >= cfg.UnlockLevel;
};

::Wuxia.Slots.hasManualEquipped <- function( _actor, _manualID )
{
	local c = ::Wuxia.Slots.getContainer(_actor);
	if (c == null) return false;
	foreach (s in c.m.Slots)
	{
		if (s.ManualID == _manualID) return true;
	}
	return false;
};

::Wuxia.Slots.hasNeigongConflict <- function( _actor )
{
	local c = ::Wuxia.Slots.getContainer(_actor);
	if (c == null) return false;

	local elements = [];
	local hasHarmonize = false;

	foreach (s in c.m.Slots)
	{
		if (s.ManualID == null || s.Tier <= 0) continue;
		local def = ::Wuxia.Slots.getManualDef(s.ManualID);
		if (def == null) continue;
		if (def.Category == "neigong" && def.Element != null)
		{
			elements.push(def.Element);
		}
		local lvl = def.Levels[::Math.min(s.Tier, def.Levels.len()) - 1];
		if ("HarmonizeConflict" in lvl.Flags && lvl.Flags.HarmonizeConflict)
		{
			hasHarmonize = true;
		}
	}

	if (hasHarmonize || elements.len() <= 1) return false;

	local hasYang = false;
	local hasYin = false;
	local hasEvil = false;
	foreach (el in elements)
	{
		if (el == "yang") hasYang = true;
		else if (el == "yin") hasYin = true;
		else if (el == "evil") hasEvil = true;
	}

	// Yang + Yin conflict, or Yang + Evil conflict
	if (hasYang && hasYin) return true;
	if (hasYang && hasEvil) return true;
	return false;
};

::Wuxia.Slots.canEquipManual <- function( _actor, _slotIndex, _manualID, _isFragment = false )
{
	local def = ::Wuxia.Slots.getManualDef(_manualID);
	if (def == null)
		return { Ok = false, Reason = "未知武学秘籍。" };

	if (!::Wuxia.Slots.isSlotUnlocked(_actor, _slotIndex))
	{
		local reqLvl = ::Wuxia.Config.SlotLayout[_slotIndex].UnlockLevel;
		return { Ok = false, Reason = "该插槽需角色达到 " + reqLvl + " 级方可解锁。" };
	}

	if (!::Wuxia.Slots.isCategoryAllowedInSlot(_slotIndex, def.Category))
	{
		local slotName = ::Wuxia.Config.SlotLayout[_slotIndex].Label;
		return { Ok = false, Reason = "「" + def.Name + "」不可装入「" + slotName + "」槽位。" };
	}

	if (_isFragment && !def.AllowFragmentLearn)
		return { Ok = false, Reason = "此功法无残本强修路径。" };

	local c = ::Wuxia.Slots.getContainer(_actor);
	local slot = c.m.Slots[_slotIndex];

	// Prevent duplicating the same manual in a different slot
	for (local i = 0; i < c.m.Slots.len(); i = ++i)
	{
		if (i != _slotIndex && c.m.Slots[i].ManualID == _manualID)
			return { Ok = false, Reason = "角色已在其他槽位修习「" + def.Name + "」。" };
	}

	local isOverwrite = (slot.ManualID != null);
	local oldDef = isOverwrite ? ::Wuxia.Slots.getManualDef(slot.ManualID) : null;
	local penaltyDays = 0;
	local causesInternalInjury = false;

	if (isOverwrite && oldDef != null)
	{
		penaltyDays = (oldDef.Quality in ::Wuxia.Config.ScatterPenaltyDays) ? ::Wuxia.Config.ScatterPenaltyDays[oldDef.Quality] : 3;
		if (_slotIndex == 0 || oldDef.Quality == "secret" || oldDef.Quality == "unique")
			causesInternalInjury = true;
	}

	return {
		Ok = true,
		IsOverwrite = isOverwrite,
		OldManualName = oldDef != null ? oldDef.Name : "",
		PenaltyDays = penaltyDays,
		CausesInternalInjury = causesInternalInjury
	};
};

::Wuxia.Slots.applyScatterPenalty <- function( _actor, _days, _withLightInternalInjury )
{
	if (_actor == null || _days <= 0) return;
	local skills = _actor.getSkills();

	local weak = skills.getSkillByID("effects.wx_scatter_weakness");
	if (weak == null)
	{
		weak = ::new("scripts/skills/effects/wx_scatter_weakness");
		skills.add(weak);
	}
	weak.setDaysRemaining(_days);

	if (_withLightInternalInjury)
	{
		local inj = skills.getSkillByID("effects.wx_internal_injury");
		if (inj == null)
		{
			inj = ::new("scripts/skills/effects/wx_internal_injury");
			skills.add(inj);
		}
		inj.applySeverity(1, _days);
	}
};

::Wuxia.Slots.equipManual <- function( _actor, _slotIndex, _manualID, _isFragment = false )
{
	local check = ::Wuxia.Slots.canEquipManual(_actor, _slotIndex, _manualID, _isFragment);
	if (!check.Ok) return check;

	local c = ::Wuxia.Slots.getContainer(_actor);
	local slot = c.m.Slots[_slotIndex];

	if (check.IsOverwrite)
	{
		::Wuxia.Slots.applyScatterPenalty(_actor, check.PenaltyDays, check.CausesInternalInjury);
	}

	slot.ManualID   = _manualID;
	slot.Tier       = 1;
	slot.Exp        = 0;
	slot.IsFragment = _isFragment;

	c.syncGrantedSkills();
	_actor.getSkills().update();

	return {
		Ok = true,
		IsOverwrite = check.IsOverwrite,
		PenaltyDays = check.PenaltyDays,
		CausesInternalInjury = check.CausesInternalInjury,
		HasConflict = ::Wuxia.Slots.hasNeigongConflict(_actor)
	};
};

::Wuxia.Slots.craftManualFromStash <- function( _stash, _manualID )
{
	if (_stash == null)
		return { Ok = false, Reason = "无法访问行囊。" };

	local def = ::Wuxia.Slots.getManualDef(_manualID);
	if (def == null || def.FragmentsNeeded <= 0)
		return { Ok = false, Reason = "此功法不可由残页拼合。" };

	local items = _stash.getItems();
	local matchingSlots = [];
	local totalPages = 0;

	for (local i = 0; i < items.len(); i = ++i)
	{
		local it = items[i];
		if (it != null && it.getID() == "misc.wx_page_item" && it.getManualID() == _manualID)
		{
			matchingSlots.push(i);
			totalPages += it.getPageCount();
		}
	}

	if (totalPages < def.FragmentsNeeded)
		return { Ok = false, Reason = "残页不足（当前 " + totalPages + " / " + def.FragmentsNeeded + "）。" };

	local remainingToConsume = def.FragmentsNeeded;
	foreach (idx in matchingSlots)
	{
		if (remainingToConsume <= 0) break;
		local it = items[idx];
		if (it == null) continue;
		local take = ::Math.min(remainingToConsume, it.getPageCount());
		it.addPageCount(-take);
		remainingToConsume -= take;
		if (it.getPageCount() <= 0)
		{
			_stash.removeByIndex(idx);
		}
	}

	local manualItem = ::new("scripts/items/misc/wx_manual_item");
	manualItem.initManual(_manualID);
	_stash.add(manualItem);

	return {
		Ok = true,
		ManualName = def.Name
	};
};
