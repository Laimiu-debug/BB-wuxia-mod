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

// Older campaigns can carry a third internal or movement manual. Keep its saved
// mastery intact and let it reactivate when one of the earlier slots is replaced.
::Wuxia.Slots.getPracticedDef <- function( _container, _slot )
{
	local def = ::Wuxia.Slots.getManualDef(_slot.ManualID);
	if (def == null || _slot.Tier <= 0) return null;
	if (def.Category != "neigong" && def.Category != "qinggong") return def;
	local earlier = 0;
	for (local i = 0; i < _slot.SlotIndex; ++i)
	{
		local slot = _container.m.Slots[i], other = ::Wuxia.Slots.getManualDef(slot.ManualID);
		if (slot.Tier > 0 && other != null && other.Category == def.Category && ++earlier == 2) return null;
	}
	return def;
};

::Wuxia.Slots.getActorLevel <- function( _actor )
{
	return _actor == null ? 1 : _actor.getLevel();
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
		local def = ::Wuxia.Slots.getPracticedDef(c, s);
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
	if (typeof _slotIndex != "integer" || _slotIndex < 0 || _slotIndex >= ::Wuxia.Config.SlotLayout.len())
		return { Ok = false, Reason = "无效的武学槽位。" };
	local c = ::Wuxia.Slots.getContainer(_actor);
	if (c == null) return { Ok = false, Reason = "无法读取侠客武学。" };

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

	local slot = c.m.Slots[_slotIndex];

	// Prevent duplicating the same manual in a different slot
	local sameCategory = 0;
	for (local i = 0; i < c.m.Slots.len(); i = ++i)
	{
		if (i == _slotIndex || c.m.Slots[i].ManualID == null) continue;
		if (c.m.Slots[i].ManualID == _manualID)
			return { Ok = false, Reason = "角色已在其他槽位修习「" + def.Name + "」。" };
		local other = ::Wuxia.Slots.getManualDef(c.m.Slots[i].ManualID);
		if (other != null && other.Category == def.Category) ++sameCategory;
	}
	if (sameCategory >= 2 && (def.Category == "neigong" || def.Category == "qinggong"))
		return { Ok = false, Reason = "一人至多兼修两门内功、两门轻功。" };

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

	local stacks = [];
	local replaceable = null;
	local totalPages = 0;

	foreach (it in _stash.getItems())
	{
		if (it != null && it.getID() == "misc.wx_page_item" && it.getManualID() == _manualID)
		{
			stacks.push(it);
			if (it.getPageCount() <= def.FragmentsNeeded) replaceable = it;
			totalPages += it.getPageCount();
		}
	}

	if (totalPages < def.FragmentsNeeded)
		return { Ok = false, Reason = "残页不足（当前 " + totalPages + " / " + def.FragmentsNeeded + "）。" };

	local manualItem = ::new("scripts/items/misc/wx_manual_item");
	manualItem.initManual(_manualID);
	local remaining = def.FragmentsNeeded;
	// In a full stash, an exhausted stack can supply the book's slot.
	local releaseStack = !_stash.isResizable() && !_stash.hasEmptySlot() && replaceable != null;
	if (releaseStack) _stash.remove(replaceable);
	if (_stash.add(manualItem) == null)
	{
		if (releaseStack) _stash.add(replaceable);
		return { Ok = false, Reason = "行囊已满，请先腾出一格存放秘籍。" };
	}
	if (releaseStack) remaining -= replaceable.getPageCount();
	foreach (stack in stacks)
	{
		if (remaining == 0) break;
		if (releaseStack && stack == replaceable) continue;
		local take = ::Math.min(remaining, stack.getPageCount());
		if (take == stack.getPageCount()) _stash.remove(stack);
		else stack.addPageCount(-take);
		remaining -= take;
	}

	return {
		Ok = true,
		ManualName = def.Name
	};
};
