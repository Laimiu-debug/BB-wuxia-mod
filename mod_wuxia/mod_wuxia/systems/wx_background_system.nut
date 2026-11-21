// Non-destructive Background Wuxia Remapper + 500 Independent Biographies + Chinese Names/Titles + Price-Tiered Starter Manuals

::Wuxia.Backgrounds <- {
	SuppressAutoAssign = false,
	RecentBioIDs = []
};

if (!("BackgroundBios" in ::Wuxia.Config))
	::Wuxia.Config.BackgroundBios <- {};

::Wuxia.Backgrounds.getEntry <- function( _bgID )
{
	if (_bgID != null && (_bgID in ::Wuxia.Config.Backgrounds))
		return ::Wuxia.Config.Backgrounds[_bgID];
	return null;
};

::Wuxia.Backgrounds.getBioPool <- function( _bgID )
{
	if (_bgID != null && (_bgID in ::Wuxia.Config.BackgroundBios) && ::Wuxia.Config.BackgroundBios[_bgID].len() > 0)
		return ::Wuxia.Config.BackgroundBios[_bgID];
	if ("background.vagabond" in ::Wuxia.Config.BackgroundBios && ::Wuxia.Config.BackgroundBios["background.vagabond"].len() > 0)
		return ::Wuxia.Config.BackgroundBios["background.vagabond"];
	return [];
};

::Wuxia.Backgrounds.findBioByID <- function( _bioID )
{
	if (_bioID == null || _bioID == "") return null;
	foreach (bgID, list in ::Wuxia.Config.BackgroundBios)
	{
		foreach (item in list)
		{
			if (item.ID == _bioID) return item;
		}
	}
	return null;
};

::Wuxia.Backgrounds.getAllBioCount <- function()
{
	local total = 0;
	foreach (bgID, list in ::Wuxia.Config.BackgroundBios)
		total += list.len();
	return total;
};

::Wuxia.Backgrounds.pickUniqueBio <- function( _bgID )
{
	local pool = ::Wuxia.Backgrounds.getBioPool(_bgID);
	if (pool.len() == 0) return null;

	// Avoid duplicating any bio currently held by an active roster brother
	local usedInRoster = {};
	if ("World" in getroottable() && ::World != null && ("getPlayerRoster" in ::World))
	{
		local roster = ::World.getPlayerRoster();
		if (roster != null)
		{
			foreach (bro in roster.getAll())
			{
				if (bro == null || !bro.isAlive()) continue;
				local bg = bro.getBackground();
				if (bg != null && ("WX_BioID" in bg.m) && bg.m.WX_BioID != null)
					usedInRoster[bg.m.WX_BioID] <- true;
			}
		}
	}

	local recentMap = {};
	foreach (rid in ::Wuxia.Backgrounds.RecentBioIDs)
		recentMap[rid] <- true;

	local fresh = [];
	local notInRoster = [];
	foreach (item in pool)
	{
		if (!(item.ID in usedInRoster))
		{
			notInRoster.push(item);
			if (!(item.ID in recentMap))
				fresh.push(item);
		}
	}

	local chosen = null;
	if (fresh.len() > 0)
		chosen = fresh[::Math.rand(0, fresh.len() - 1)];
	else if (notInRoster.len() > 0)
		chosen = notInRoster[::Math.rand(0, notInRoster.len() - 1)];
	else
		chosen = pool[::Math.rand(0, pool.len() - 1)];

	::Wuxia.Backgrounds.RecentBioIDs.push(chosen.ID);
	if (::Wuxia.Backgrounds.RecentBioIDs.len() > 32)
		::Wuxia.Backgrounds.RecentBioIDs.remove(0);

	return chosen;
};

::Wuxia.Backgrounds.renderBioTemplate <- function( _template, _name )
{
	if (_template == null) return "";
	local rep = (_name != null && _name != "") ? _name : "此人";
	local token = "%name%";
	local tLen = token.len();
	local out = "";
	local pos = 0;
	while (true)
	{
		local idx = _template.find(token, pos);
		if (idx == null)
		{
			out += _template.slice(pos);
			break;
		}
		out += _template.slice(pos, idx) + rep;
		pos = idx + tLen;
	}
	return out;
};

::Wuxia.Backgrounds.extractActorShortName <- function( _bgSkill )
{
	if (_bgSkill == null) return "";
	local container = _bgSkill.getContainer();
	if (container == null) return "";
	local actor = container.getActor();
	if (actor == null) return "";
	if (::Wuxia.hasMember(actor, "getNameOnly"))
	{
		local n = actor.getNameOnly();
		if (n != null && n != "") return n;
	}
	if (::Wuxia.hasMember(actor, "getName"))
	{
		local fn = actor.getName();
		if (fn != null && fn != "") return fn;
	}
	return "";
};

::Wuxia.Backgrounds.isSavedWuxiaBio <- function( _coreDesc, _entry )
{
	if (_coreDesc == null || _coreDesc == "") return false;
	if (_entry != null && _coreDesc == _entry.Desc) return false;
	// If it starts with ASCII letters (vanilla English bio), replace with a Wuxia bio
	local c0 = _coreDesc[0];
	if ((c0 >= 65 && c0 <= 90) || (c0 >= 97 && c0 <= 122)) return false;
	// Must be longer than a short 1-sentence label (>= 120 UTF-8 bytes ~ 40 Chinese chars)
	return _coreDesc.len() >= 120;
};

// Fallback tier inference for any unmapped / future DLC background by daily wage / hiring cost
::Wuxia.Backgrounds.resolveTier <- function( _bgSkill )
{
	if (_bgSkill == null) return 0;
	local entry = ::Wuxia.Backgrounds.getEntry(_bgSkill.getID());
	if (entry != null) return entry.Tier;

	local daily = (::Wuxia.hasMember(_bgSkill, "getDailyCost")) ? _bgSkill.getDailyCost() : 0;
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
	local useGlobal = (::Math.rand(1, 100) <= 55);
	if (!useGlobal && _preferredPool != null && _preferredPool.len() > 0)
	{
		local picked = ::Wuxia.Backgrounds.pickMatchingManual(_preferredPool, "neigong", null);
		if (picked != null) return picked;
	}
	local allQual = [];
	foreach (mid, def in ::Wuxia.Config.Manuals)
	{
		if (def.Category == "neigong" && def.Quality == _quality)
			allQual.push(mid);
	}
	if (allQual.len() > 0)
		return allQual[::Math.rand(0, allQual.len() - 1)];
	if (_preferredPool != null && _preferredPool.len() > 0)
	{
		local fb = ::Wuxia.Backgrounds.pickMatchingManual(_preferredPool, "neigong", null);
		if (fb != null) return fb;
	}
	return _quality == "sect" ? "wx_manual_songtao" : "wx_manual_tuna";
};

// Roll a guaranteed-unique Wuxia name for `_actor` (respecting female FaceIdx >= 33 & roster uniqueness)
::Wuxia.Backgrounds.rollUniqueActorName <- function( _actor, _usedMap = null, _poolKey = null )
{
	if (_actor == null) return "";
	local used = (_usedMap != null) ? _usedMap : {};
	if ("World" in getroottable() && ::World != null && ("getPlayerRoster" in ::World) && ::World.getPlayerRoster() != null)
	{
		foreach (b in ::World.getPlayerRoster().getAll())
		{
			if (b != null && b != _actor && ::Wuxia.hasMember(b, "getNameOnly"))
			{
				local en = b.getNameOnly();
				if (en != null && en != "") used[en] <- true;
			}
		}
	}

	local isFem = false;
	if ("Appearance" in ::Wuxia && "getOrInitState" in ::Wuxia.Appearance)
	{
		local st = ::Wuxia.Appearance.getOrInitState(_actor);
		if (st != null && ("FaceIdx" in st) && st.FaceIdx >= 33)
			isFem = true;
	}

	local pool = null;
	if (isFem && ("Appearance" in ::Wuxia.Config) && ("FemaleHeroineNames" in ::Wuxia.Config.Appearance))
	{
		pool = ::Wuxia.Config.Appearance.FemaleHeroineNames;
	}
	if (pool == null || pool.len() == 0)
	{
		local pk = _poolKey;
		if (pk == null || pk == "")
		{
			local bg = ::Wuxia.hasMember(_actor, "getBackground") ? _actor.getBackground() : null;
			local bgID = (bg != null) ? bg.getID() : "";
			if ("BackgroundNames" in ::Wuxia.Config && (bgID in ::Wuxia.Config.BackgroundNames))
				pk = ::Wuxia.Config.BackgroundNames[bgID].Pool;
		}
		if (pk != null && ("NamePools" in ::Wuxia.Config) && (pk in ::Wuxia.Config.NamePools))
			pool = ::Wuxia.Config.NamePools[pk];
		else if ("NamePools" in ::Wuxia.Config && ("jianghu" in ::Wuxia.Config.NamePools))
			pool = ::Wuxia.Config.NamePools.jianghu;
	}

	if (pool == null || pool.len() == 0) return "";
	local fresh = [];
	foreach (nm in pool)
	{
		if (!(nm in used)) fresh.push(nm);
	}
	local chosen = (fresh.len() > 0) ? fresh[::Math.rand(0, fresh.len() - 1)] : pool[::Math.rand(0, pool.len() - 1)];
	used[chosen] <- true;
	if ("m" in _actor) _actor.m.WX_HeroineNameChecked <- true;
	if (::Wuxia.hasMember(_actor, "setName")) _actor.setName(chosen);
	return chosen;
};

// Pick a manual from the full 264-manual catalog matching `_category`, `_quality`, and `_mainhand` weapon, avoiding duplicates in `_usedMap`
::Wuxia.Backgrounds.pickCatalogManual <- function( _category, _quality, _mainhand = null, _usedMap = null, _fallbackID = null )
{
	local used = (_usedMap != null) ? _usedMap : {};
	local fresh = [];
	local allMatches = [];
	foreach (mid, def in ::Wuxia.Config.Manuals)
	{
		if (def.Category != _category || def.Quality != _quality) continue;
		if (_category == "waigong" && _mainhand != null && def.WeaponTypes.len() > 0 && !::Wuxia.CombatRules.matchesWeapon(_mainhand, def.WeaponTypes))
			continue;
		allMatches.push(mid);
		if (!(mid in used))
			fresh.push(mid);
	}
	local chosen = null;
	if (fresh.len() > 0)
		chosen = fresh[::Math.rand(0, fresh.len() - 1)];
	else if (allMatches.len() > 0)
		chosen = allMatches[::Math.rand(0, allMatches.len() - 1)];
	else
		chosen = _fallbackID;

	if (chosen != null)
		used[chosen] <- true;
	return chosen;
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
		c.ensureSlotsRegisteredInLearned();
		c.syncGrantedSkills();
		_actor.getSkills().update();
		if ("WX_RefreshStarterNote" in bg) bg.WX_RefreshStarterNote(granted);
	}
	return granted;
};

// Apply global Chinese names table immediately on load
if ("ApplyGlobalChineseNames" in ::Wuxia)
	::Wuxia.ApplyGlobalChineseNames();

::Wuxia.HooksMod.hook("scripts/skills/backgrounds/character_background", function( q )
{
	q.WX_ApplyMapping <- function()
	{
		local id = this.getID();
		local entry = ::Wuxia.Backgrounds.getEntry(id);
		if (entry != null)
		{
			this.m.Name = entry.Name;
			this.m.BackgroundDescription = entry.Desc;
		}
		if ("BackgroundNames" in ::Wuxia.Config && (id in ::Wuxia.Config.BackgroundNames))
		{
			local ncfg = ::Wuxia.Config.BackgroundNames[id];
			if (("NamePools" in ::Wuxia.Config) && (ncfg.Pool in ::Wuxia.Config.NamePools))
				this.m.Names = clone ::Wuxia.Config.NamePools[ncfg.Pool];
			if ("Titles" in ncfg && ncfg.Titles.len() > 0)
				this.m.Titles = clone ncfg.Titles;
		}
	};

	q.WX_EnsurePersonalBio <- function()
	{
		if (!("WX_BioID" in this.m)) this.m.WX_BioID <- null;
		if (!("WX_BioTemplate" in this.m)) this.m.WX_BioTemplate <- null;
		if (!("WX_SavedBio" in this.m)) this.m.WX_SavedBio <- null;

		if (this.m.WX_BioTemplate != null || this.m.WX_SavedBio != null)
			return;

		local chosen = ::Wuxia.Backgrounds.pickUniqueBio(this.getID());
		if (chosen != null)
		{
			this.m.WX_BioID = chosen.ID;
			this.m.WX_BioTemplate = chosen.Text;
		}
	};

	q.WX_FormatDescription <- function( _baseDesc )
	{
		this.WX_EnsurePersonalBio();
		local entry = ::Wuxia.Backgrounds.getEntry(this.getID());
		local actorName = ::Wuxia.Backgrounds.extractActorShortName(this);
		local text = "";

		if (("WX_BioTemplate" in this.m) && this.m.WX_BioTemplate != null)
		{
			text = ::Wuxia.Backgrounds.renderBioTemplate(this.m.WX_BioTemplate, actorName);
		}
		else if (("WX_SavedBio" in this.m) && this.m.WX_SavedBio != null)
		{
			text = this.m.WX_SavedBio;
		}
		else
		{
			text = (entry != null) ? entry.Desc : _baseDesc;
		}

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
		else if (("WX_SavedStarterSuffix" in this.m) && this.m.WX_SavedStarterSuffix != null && this.m.WX_SavedStarterSuffix != "")
		{
			text += this.m.WX_SavedStarterSuffix;
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

	q.WX_RefreshNameInBio <- function()
	{
		if (("WX_BioTemplate" in this.m) && this.m.WX_BioTemplate != null)
			this.m.Description = this.WX_FormatDescription(this.m.Description);
	};

	q.getName = @(__original) function()
	{
		this.WX_ApplyMapping();
		local entry = ::Wuxia.Backgrounds.getEntry(this.getID());
		if (entry != null) return entry.Name;
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

		local raw = this.m.Description != null ? this.m.Description : "";
		local marker = "\n\n[color=#8f6b29]【随身武学】";
		local idx = raw.find(marker);
		local core = raw;
		if (idx != null)
		{
			core = raw.slice(0, idx);
			this.m.WX_SavedStarterSuffix <- raw.slice(idx);
		}

		local entry = ::Wuxia.Backgrounds.getEntry(this.getID());
		if (::Wuxia.Backgrounds.isSavedWuxiaBio(core, entry))
		{
			this.m.WX_SavedBio <- core;
		}
		this.m.Description = this.WX_FormatDescription(this.m.Description);
	};
});

// Keep personal biography synchronized whenever a brother's name is changed (e.g. starting scenario or player rename)
::Wuxia.HooksMod.hook("scripts/entity/tactical/actor", function( q )
{
	q.setName = @(__original) function( _n )
	{
		__original(_n);
		if (::Wuxia.hasMember(this, "getBackground"))
		{
			local bg = this.getBackground();
			if (bg != null && ("WX_RefreshNameInBio" in bg))
				bg.WX_RefreshNameInBio();
		}
	};
});
