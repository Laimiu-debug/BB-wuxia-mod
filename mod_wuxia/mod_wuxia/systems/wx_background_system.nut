// Non-destructive Background Wuxia Remapper + Price-Tiered Starter Manual Auto-Installer

::Wuxia.Backgrounds <- {
	SuppressAutoAssign = false
};

::Wuxia.Backgrounds.getEntry <- function( _bgID )
{
	if (_bgID != null && (_bgID in ::Wuxia.Config.Backgrounds))
		return ::Wuxia.Config.Backgrounds[_bgID];
	return null;
};

// Fallback tier inference for any unmapped / future DLC background by daily wage / hiring cost
::Wuxia.Backgrounds.resolveTier <- function( _bgSkill )
{
	if (_bgSkill == null) return 0;
	local entry = ::Wuxia.Backgrounds.getEntry(_bgSkill.getID());
	if (entry != null) return entry.Tier;

	local daily = ("getDailyCost" in _bgSkill) ? _bgSkill.getDailyCost() : 0;
	if (daily >= 20) return 2;
	if (daily >= 9)  return 1;
	return 0;
};

// Pick the best manual from _pool that matches _category and (for waigong) prefers the actor's equipped mainhand weapon
::Wuxia.Backgrounds.pickMatchingManual <- function( _pool, _category, _mainhand )
{
	local weaponMatches = [];
	local categoryMatches = [];

	foreach (mid in _pool)
	{
		local def = ::Wuxia.Slots.getManualDef(mid);
		if (def == null || def.Category != _category) continue;
		categoryMatches.push(mid);
		if (_mainhand != null && def.WeaponTypes.len() > 0 && ::Wuxia.CombatRules.matchesWeapon(_mainhand, def.WeaponTypes))
		{
			weaponMatches.push(mid);
		}
	}

	if (weaponMatches.len() > 0)
		return weaponMatches[::Math.rand(0, weaponMatches.len() - 1)];
	if (categoryMatches.len() > 0)
		return categoryMatches[::Math.rand(0, categoryMatches.len() - 1)];
	return null;
};

::Wuxia.Backgrounds.pickWeaponAwareWaigong <- function( _quality, _mainhand, _preferredPool )
{
	if (_preferredPool != null && _preferredPool.len() > 0)
	{
		local fromPool = ::Wuxia.Backgrounds.pickMatchingManual(_preferredPool, "waigong", _mainhand);
		if (fromPool != null)
		{
			local def = ::Wuxia.Slots.getManualDef(fromPool);
			if (_mainhand == null || ::Wuxia.CombatRules.matchesWeapon(_mainhand, def.WeaponTypes))
				return fromPool;
		}
	}

	// Scan global catalog for a waigong of _quality matching actual held weapon (e.g. Bow hunter -> 雁行掩射谱, Staff -> 护阵棒法)
	if (_mainhand != null)
	{
		local matched = [];
		foreach (mid, def in ::Wuxia.Config.Manuals)
		{
			if (def.Category == "waigong" && def.Quality == _quality && ::Wuxia.CombatRules.matchesWeapon(_mainhand, def.WeaponTypes))
				matched.push(mid);
		}
		if (matched.len() > 0)
			return matched[::Math.rand(0, matched.len() - 1)];
	}

	if (_preferredPool != null && _preferredPool.len() > 0)
	{
		local fallback = ::Wuxia.Backgrounds.pickMatchingManual(_preferredPool, "waigong", null);
		if (fallback != null) return fallback;
	}
	return _quality == "sect" ? "wx_manual_qingfeng" : "wx_manual_jichujian";
};

::Wuxia.Backgrounds.pickNeigong <- function( _quality, _preferredPool )
{
	if (_preferredPool != null && _preferredPool.len() > 0)
	{
		local picked = ::Wuxia.Backgrounds.pickMatchingManual(_preferredPool, "neigong", null);
		if (picked != null) return picked;
	}
	return _quality == "sect" ? "wx_manual_songtao" : "wx_manual_tuna";
};

// Silently pre-install Tier 1 (1 common) or Tier 2 (1 sect + 1 common) manuals into Level 1 slots (0 = neigong, 1 = waigong)
::Wuxia.Backgrounds.assignStarterManuals <- function( _actor )
{
	if (::Wuxia.Backgrounds.SuppressAutoAssign || _actor == null) return [];
	local bg = _actor.getBackground();
	if (bg == null) return [];

	local c = ::Wuxia.Slots.getContainer(_actor);
	if (c == null) return [];

	// Never overwrite if slots already carry manuals (e.g. deserialized or custom scripted characters)
	if (c.m.Slots[0].ManualID != null || c.m.Slots[1].ManualID != null) return [];

	local tier = ::Wuxia.Backgrounds.resolveTier(bg);
	if (tier <= 0) return [];

	local entry = ::Wuxia.Backgrounds.getEntry(bg.getID());
	local commonPool = (entry != null && "CommonPool" in entry) ? entry.CommonPool : ["wx_manual_tuna", "wx_manual_xingqi", "wx_manual_liuheqiang"];
	local sectPool   = (entry != null && "SectPool" in entry)   ? entry.SectPool   : ["wx_manual_songtao", "wx_manual_weiyuan", "wx_manual_qingfeng"];

	local items = _actor.getItems();
	local mainhand = items != null ? items.getItemAtSlot(::Const.ItemSlot.Mainhand) : null;

	// If unarmed martial artist background (e.g. 市井拳师 / 行脚僧) has GrantWraps, give starter cloth wraps so Fist waigong works out of the box!
	if (mainhand == null && items != null && entry != null && ("GrantWraps" in entry) && entry.GrantWraps)
	{
		local off = items.getItemAtSlot(::Const.ItemSlot.Offhand);
		if (off == null)
		{
			local wraps = ::new("scripts/items/weapons/wx_fist_wraps");
			items.equip(wraps);
			mainhand = wraps;
		}
	}

	local granted = [];

	if (tier == 1)
	{
		// 江湖行当: 1 Common manual in either Slot 0 (neigong) or Slot 1 (waigong)
		local mid = commonPool[::Math.rand(0, commonPool.len() - 1)];
		local def = ::Wuxia.Slots.getManualDef(mid);
		if (def != null && def.Category == "waigong" && mainhand != null && !::Wuxia.CombatRules.matchesWeapon(mainhand, def.WeaponTypes))
		{
			// Weapon mismatch -> switch to weapon-matching common waigong or common neigong
			local altWai = ::Wuxia.Backgrounds.pickWeaponAwareWaigong("common", mainhand, null);
			local altDef = ::Wuxia.Slots.getManualDef(altWai);
			if (altDef != null && ::Wuxia.CombatRules.matchesWeapon(mainhand, altDef.WeaponTypes))
				mid = altWai;
			else
				mid = ::Wuxia.Backgrounds.pickNeigong("common", commonPool);
			def = ::Wuxia.Slots.getManualDef(mid);
		}

		if (def != null)
		{
			local slotIdx = (def.Category == "neigong") ? 0 : 1;
			c.m.Slots[slotIdx].ManualID   = mid;
			c.m.Slots[slotIdx].Tier       = 1;
			c.m.Slots[slotIdx].Exp        = 0;
			c.m.Slots[slotIdx].IsFragment = false;
			granted.push(def.Name);
		}
	}
	else if (tier >= 2)
	{
		// 成名高手: 1 Sect manual + 1 Common manual across Slot 0 (neigong) & Slot 1 (waigong)
		local sectIsWaigong = (::Math.rand(1, 100) <= 65);
		local neiID = null;
		local waiID = null;

		if (sectIsWaigong)
		{
			waiID = ::Wuxia.Backgrounds.pickWeaponAwareWaigong("sect", mainhand, sectPool);
			local wDef = ::Wuxia.Slots.getManualDef(waiID);
			if (wDef == null || (mainhand != null && !::Wuxia.CombatRules.matchesWeapon(mainhand, wDef.WeaponTypes)))
			{
				// Held weapon has no sect manual yet -> give sect Neigong + common Waigong instead!
				neiID = ::Wuxia.Backgrounds.pickNeigong("sect", sectPool);
				waiID = ::Wuxia.Backgrounds.pickWeaponAwareWaigong("common", mainhand, commonPool);
			}
			else
			{
				neiID = ::Wuxia.Backgrounds.pickNeigong("common", commonPool);
			}
		}
		else
		{
			neiID = ::Wuxia.Backgrounds.pickNeigong("sect", sectPool);
			waiID = ::Wuxia.Backgrounds.pickWeaponAwareWaigong("common", mainhand, commonPool);
		}

		if (neiID != null)
		{
			c.m.Slots[0].ManualID   = neiID;
			c.m.Slots[0].Tier       = 1;
			c.m.Slots[0].Exp        = 0;
			c.m.Slots[0].IsFragment = false;
			granted.push(::Wuxia.Slots.getManualDef(neiID).Name);
		}
		if (waiID != null)
		{
			c.m.Slots[1].ManualID   = waiID;
			c.m.Slots[1].Tier       = 1;
			c.m.Slots[1].Exp        = 0;
			c.m.Slots[1].IsFragment = false;
			granted.push(::Wuxia.Slots.getManualDef(waiID).Name);
		}
	}

	if (granted.len() > 0)
	{
		c.syncGrantedSkills();
		_actor.getSkills().update();
		if ("WX_RefreshStarterNote" in bg) bg.WX_RefreshStarterNote(granted);
	}
	return granted;
};

::Wuxia.HooksMod.hook("scripts/skills/backgrounds/character_background", function( q )
{
	q.WX_ApplyMapping <- function()
	{
		local entry = ::Wuxia.Backgrounds.getEntry(this.getID());
		if (entry == null) return;
		this.m.Name = entry.Name;
		this.m.BackgroundDescription = entry.Desc;
	};

	q.WX_FormatDescription <- function( _baseDesc )
	{
		local entry = ::Wuxia.Backgrounds.getEntry(this.getID());
		local text = (entry != null) ? entry.Desc : _baseDesc;
		if (("WX_StarterManualNames" in this.m) && this.m.WX_StarterManualNames != null && this.m.WX_StarterManualNames.len() > 0)
		{
			local joined = "";
			for (local i = 0; i < this.m.WX_StarterManualNames.len(); i = ++i)
			{
				if (i > 0) joined += "、";
				joined += "《" + this.m.WX_StarterManualNames[i] + "》";
			}
			text += "\n\n[color=#8f6b29]【随身武学】入门即习有一重 " + joined + "。[/color]";
		}
		return text;
	};

	q.WX_RefreshStarterNote <- function( _names )
	{
		if (!("WX_StarterManualNames" in this.m))
			this.m.WX_StarterManualNames <- [];
		this.m.WX_StarterManualNames = clone _names;
		this.m.Description = this.WX_FormatDescription(this.m.Description);
	};

	q.getName = @(__original) function()
	{
		this.WX_ApplyMapping();
		return __original();
	};

	q.onAdded = @(__original) function()
	{
		this.WX_ApplyMapping();
		__original();
		this.m.Description = this.WX_FormatDescription(this.m.Description);
	};

	q.buildDescription = @(__original) function( _isFinal = false )
	{
		this.WX_ApplyMapping();
		__original(_isFinal);
		this.m.Description = this.WX_FormatDescription(this.m.Description);
	};

	q.onDeserialize = @(__original) function( _in )
	{
		__original(_in);
		this.WX_ApplyMapping();
		this.m.Description = this.WX_FormatDescription(this.m.Description);
	};
});
