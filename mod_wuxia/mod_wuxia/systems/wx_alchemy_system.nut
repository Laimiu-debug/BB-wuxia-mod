// Core Alchemy & Zero-Slot Herb/Core Cabinet System (百草药柜 · 八卦丹炉 · 高阶洗髓与归元护脉)
// - Universal Ingredient Classifier: automatically recognizes built-in herbs, all 48+ ShanHai Neidan cores,
//   22 ShanHai beast trophies, AND any newly added exotic herbs/cores (`wx_herb_*`, `Herbs`, `ExoticHerbs`, etc.)!
// - Zero-Stash-Slot Cabinet (`::Wuxia.Alchemy.Cabinet`): persisted in `::World.Flags`, 0 Stash slot cost, exact withdrawal.
// - Bagua Cauldron (`::Wuxia.Alchemy.Cauldron`): 16 Jun-Chen-Zuo-Shi formulas, Smart Auto-Fill, Alchemist Mastery & Double-Pill Resonance.

if (!("Alchemy" in ::Wuxia))
	::Wuxia.Alchemy <- {};

::Wuxia.Alchemy.Fallback <- {
	AutoStore          = true,
	AutoTrophy         = false,
	Keys               = {},
	Counts             = {},
	Meta               = {},
	DiscoveredFormulas = {}
};

::Wuxia.Alchemy.resetFallback <- function()
{
	::Wuxia.Alchemy.Fallback.AutoStore          = true;
	::Wuxia.Alchemy.Fallback.AutoTrophy         = false;
	::Wuxia.Alchemy.Fallback.Keys               = {};
	::Wuxia.Alchemy.Fallback.Counts             = {};
	::Wuxia.Alchemy.Fallback.Meta               = {};
	::Wuxia.Alchemy.Fallback.DiscoveredFormulas = {};
};

::Wuxia.Alchemy.isFormulaDiscovered <- function( _formulaID )
{
	if (_formulaID == null || _formulaID == "") return false;
	if (("Alchemy" in ::Wuxia.Config) && ("StarterFormulas" in ::Wuxia.Config.Alchemy) && (_formulaID in ::Wuxia.Config.Alchemy.StarterFormulas))
		return true;
	if (::Wuxia.Alchemy.hasWorldFlags())
		return ::World.Flags.get("wx_alc_known_" + _formulaID) ? true : false;
	return (_formulaID in ::Wuxia.Alchemy.Fallback.DiscoveredFormulas);
};

::Wuxia.Alchemy.discoverFormula <- function( _formulaID )
{
	if (_formulaID == null || _formulaID == "") return false;
	local wasNew = !::Wuxia.Alchemy.isFormulaDiscovered(_formulaID);
	if (::Wuxia.Alchemy.hasWorldFlags())
		::World.Flags.set("wx_alc_known_" + _formulaID, true);
	else
		::Wuxia.Alchemy.Fallback.DiscoveredFormulas[_formulaID] <- true;
	return wasNew;
};

::Wuxia.Alchemy.unlockRandomUndiscoveredFormula <- function( _maxMinJunPotency = 5 )
{
	local preferred = [];
	local fallback  = [];
	foreach (f in ::Wuxia.Config.Alchemy.Formulas)
	{
		if (::Wuxia.Alchemy.isFormulaDiscovered(f.ID)) continue;
		if (f.MinJunPotency <= _maxMinJunPotency)
			preferred.push(f);
		else
			fallback.push(f);
	}
	local pool = preferred.len() > 0 ? preferred : fallback;
	if (pool.len() == 0) return "";
	local picked = pool[::Math.rand(0, pool.len() - 1)];
	::Wuxia.Alchemy.discoverFormula(picked.ID);
	if (picked.PillID in ::Wuxia.Config.Pills)
		return ::Wuxia.Config.Pills[picked.PillID].Name;
	return picked.ID;
};

::Wuxia.Alchemy.hasWorldFlags <- function()
{
	return ::Wuxia.hasWorldField("Flags");
};

::Wuxia.Alchemy.recordWorkshopCraft <- function()
{
	if (!::Wuxia.hasWorldField("Statistics") || !::Wuxia.hasMember(::World.Statistics, "getFlags"))
		return;
	local sFlags = ::World.Statistics.getFlags();
	if (sFlags == null) return;
	sFlags.set("ItemsCrafted", ::Wuxia.Ambitions.getTaxidermistCraftCount() + 1);
	if (::Wuxia.hasWorldField("Ambitions") && ::World.Ambitions.hasActiveAmbition())
		::World.Ambitions.updateUI();
};

// -----------------------------------------------------------------------------
// 1. Dynamic Universal Ingredient Classifier (100% forward-compatible with new Herbs & Cores)
// -----------------------------------------------------------------------------
::Wuxia.Alchemy.normalizeNature <- function( _raw )
{
	if (_raw == null || _raw == "") return null;
	local s = (typeof _raw == "string") ? _raw.tolower() : "";
	if (s in ::Wuxia.Config.Alchemy.Natures) return s;
	if (s == "fire" || s == "sun" || s == "blood" || s.find("阳") != null || s.find("火") != null) return "yang";
	if (s == "ice" || s == "water" || s == "frost" || s.find("阴") != null || s.find("寒") != null || s.find("冰") != null || s.find("水") != null) return "yin";
	if (s == "wood" || s == "life" || s == "heal" || s.find("生") != null || s.find("木") != null) return "vital";
	if (s == "mind" || s == "soul" || s.find("魂") != null || s.find("神") != null) return "spirit";
	if (s == "poison" || s == "toxin" || s.find("毒") != null || s.find("蛊") != null || s.find("瘴") != null) return "venom";
	if (s == "chaos" || s == "marrow" || s == "supreme" || s.find("造化") != null || s.find("混沌") != null || s.find("洗髓") != null) return "origin";
	return null;
};

::Wuxia.Alchemy.inferNatureFromText <- function( _name, _desc = "" )
{
	if (_desc != null && _desc != "" && _name != null && _name != "")
	{
		local fromName = ::Wuxia.Alchemy.inferNatureFromText(_name, "");
		if (fromName != "vital") return fromName;
	}
	local txt = (_name != null ? _name : "") + " " + (_desc != null ? _desc : "");
	if (txt.find("洗髓") != null || txt.find("造化") != null || txt.find("浑沌") != null || txt.find("混沌") != null
		|| txt.find("太虚") != null || txt.find("应龙") != null || txt.find("烛阴") != null || txt.find("乘黄") != null
		|| txt.find("开明") != null || txt.find("防风") != null || txt.find("夸父") != null || txt.find("九转") != null)
		return "origin";

	if (txt.find("毒") != null || txt.find("蛊") != null || txt.find("瘴") != null || txt.find("蛛") != null
		|| txt.find("蝎") != null || txt.find("蜈") != null || txt.find("钦原") != null || txt.find("相柳") != null
		|| txt.find("蜚") != null || txt.find("蚀") != null)
		return "venom";

	if (txt.find("冰") != null || txt.find("寒") != null || txt.find("霜") != null || txt.find("雪") != null
		|| txt.find("水") != null || txt.find("月") != null || txt.find("阴") != null || txt.find("无支祁") != null
		|| txt.find("共工") != null || txt.find("化蛇") != null || txt.find("夫诸") != null || txt.find("玄龟") != null)
		return "yin";

	if (txt.find("金乌") != null || txt.find("毕方") != null || txt.find("祸斗") != null || txt.find("朱厌") != null
		|| txt.find("大日") != null || txt.find("赤炎") != null || txt.find("火丹") != null)
		return "yang";

	if (txt.find("魂") != null || txt.find("魄") != null || txt.find("神") != null || txt.find("梦") != null
		|| txt.find("幻") != null || txt.find("定") != null || txt.find("白泽") != null || txt.find("九尾") != null
		|| txt.find("帝江") != null || txt.find("精卫") != null || txt.find("武罗") != null)
		return "spirit";

	if (txt.find("火") != null || txt.find("炎") != null || txt.find("赤") != null || txt.find("阳") != null
		|| txt.find("日") != null || txt.find("雷") != null || txt.find("金乌") != null || txt.find("毕方") != null
		|| txt.find("祸斗") != null || txt.find("朱厌") != null || txt.find("蚩尤") != null || txt.find("狂") != null
		|| txt.find("虎") != null || txt.find("血") != null)
		return "yang";

	return "vital";
};

::Wuxia.Alchemy.inferPotencyFromValue <- function( _val, _isHerbOrCore = true )
{
	local v = _val != null ? _val : 300;
	if (v >= 2300) return 5;
	if (v >= 1200) return 4;
	if (v >= 550)  return 3;
	if (v >= 250)  return 2;
	return _isHerbOrCore ? 2 : 1;
};

// Look up any optional external Herb config table created by other modules/agents
::Wuxia.Alchemy.lookupExternalHerbConfig <- function( _herbKey )
{
	if (_herbKey == null || _herbKey == "") return null;
	local plain = _herbKey;
	if (plain.find("misc.") == 0) plain = plain.slice(5);

	foreach (tblName in ["Herbs", "ExoticHerbs", "ShanHaiHerbs", "AlchemyHerbs", "SpiritHerbs"])
	{
		if (tblName in ::Wuxia.Config && typeof ::Wuxia.Config[tblName] == "table")
		{
			local tbl = ::Wuxia.Config[tblName];
			if (_herbKey in tbl) return tbl[_herbKey];
			if (plain in tbl)    return tbl[plain];
		}
	}
	return null;
};

::Wuxia.Alchemy.getAllExternalHerbDefs <- function()
{
	local out = {};
	foreach (tblName in ["Herbs", "ExoticHerbs", "ShanHaiHerbs", "AlchemyHerbs", "SpiritHerbs"])
	{
		if (tblName in ::Wuxia.Config && typeof ::Wuxia.Config[tblName] == "table")
		{
			foreach (k, v in ::Wuxia.Config[tblName])
			{
				if (typeof v == "table") out[k] <- v;
			}
		}
	}
	return out;
};

// Inspect a live BB item instance and return standardized Alchemy Metadata (or null if not an alchemy material)
::Wuxia.Alchemy.classifyItem <- function( _item )
{
	if (_item == null || !::Wuxia.hasMember(_item, "getID")) return null;
	local id = _item.getID();
	if (id == null || id == "") return null;

	// Fast-path early exit for equipment, manuals, pages, and finished pills (never raw cauldron herbs/trophies)
	if (id == "misc.wx_manual_item" || id == "misc.wx_page_item" || id == "misc.wx_pill_item"
		|| id.find("weapon.") == 0 || id.find("armor.") == 0 || id.find("shield.") == 0
		|| id.find("ammo.") == 0 || id.find("accessory.") == 0)
		return null;

	// 1. ShanHai / Great Demon Inner Cores (`CoreID` or `misc.wx_core_*`)
	if ((::Wuxia.hasMember(_item.m, "CoreID") && _item.m.CoreID != null && _item.m.CoreID != "") || id.find("misc.wx_core_") == 0)
	{
		local cid = (::Wuxia.hasMember(_item.m, "CoreID") && _item.m.CoreID != "") ? _item.m.CoreID : id.slice(5);
		local cdef = ("ShanHaiCores" in ::Wuxia.Config && (cid in ::Wuxia.Config.ShanHaiCores))
			? ::Wuxia.Config.ShanHaiCores[cid]
			: null;
		local nm = _item.getName();
		local desc = _item.getDescription();
		local val = _item.getValue();
		local nat = null;
		local pot = 0;
		if (cdef != null)
		{
			if ("Nature" in cdef)  nat = ::Wuxia.Alchemy.normalizeNature(cdef.Nature);
			if (nat == null && ("Element" in cdef)) nat = ::Wuxia.Alchemy.normalizeNature(cdef.Element);
			if ("Potency" in cdef) pot = cdef.Potency;
		}
		if (nat == null) nat = ::Wuxia.Alchemy.inferNatureFromText(nm, desc);
		if (pot <= 0)    pot = ::Wuxia.Alchemy.inferPotencyFromValue(val, true);
		if (pot < 4)     pot = 4;

		return {
			Key         = "core:" + cid,
			ItemID      = id,
			SubID       = cid,
			Kind        = "core",
			IsRare      = true,
			Nature      = nat,
			Potency     = pot,
			Name        = nm,
			Description = desc,
			Icon        = _item.getIcon(),
			Value       = val,
			Script      = "scripts/items/misc/" + cid
		};
	}

	// 2. Built-in & Newly Added Exotic Herbs (`HerbID`, `misc.wx_marrow_herb`, `misc.wx_herb*`, or external Herb table)
	local hasHerbMember = (::Wuxia.hasMember(_item.m, "HerbID") && _item.m.HerbID != null && _item.m.HerbID != "");
	local extHerb = ::Wuxia.Alchemy.lookupExternalHerbConfig(hasHerbMember ? _item.m.HerbID : id);
	local isHerbID = (id == "misc.wx_marrow_herb" || id.find("misc.wx_herb") == 0 || id.find("misc.wx_qicao") == 0 || id.find("misc.wx_spirit_herb") == 0);

	if (hasHerbMember || isHerbID || extHerb != null)
	{
		local hid = hasHerbMember ? _item.m.HerbID : (id.find("misc.") == 0 ? id.slice(5) : id);
		local nmH = _item.getName();
		local descH = _item.getDescription();
		local valH = _item.getValue();
		local natH = null;
		local potH = 0;
		local scriptH = hasHerbMember ? ("scripts/items/misc/" + (id.find("misc.") == 0 ? id.slice(5) : "wx_herb_item")) : ("scripts/items/misc/" + hid);

		if (id in ::Wuxia.Config.Alchemy.KnownMaterials)
		{
			local km = ::Wuxia.Config.Alchemy.KnownMaterials[id];
			natH = km.Nature;
			potH = km.Potency;
			scriptH = km.Script;
		}
		if ("HerbNatures" in ::Wuxia.Config.Alchemy && (hid in ::Wuxia.Config.Alchemy.HerbNatures))
		{
			local hn = ::Wuxia.Config.Alchemy.HerbNatures[hid];
			natH = hn.Nature;
			potH = hn.Potency;
		}
		if (extHerb != null)
		{
			if ("Nature" in extHerb) natH = ::Wuxia.Alchemy.normalizeNature(extHerb.Nature);
			if (natH == null && ("Element" in extHerb)) natH = ::Wuxia.Alchemy.normalizeNature(extHerb.Element);
			if ("Potency" in extHerb) potH = extHerb.Potency;
			if ("Script" in extHerb && extHerb.Script != null && extHerb.Script != "") scriptH = extHerb.Script;
		}
		if (natH == null) natH = ::Wuxia.Alchemy.inferNatureFromText(nmH, descH);
		if (potH <= 0)    potH = ::Wuxia.Alchemy.inferPotencyFromValue(valH, true);

		return {
			Key         = "herb:" + hid,
			ItemID      = id,
			SubID       = hasHerbMember ? _item.m.HerbID : "",
			Kind        = "herb",
			IsRare      = (potH >= 3),
			Nature      = natH,
			Potency     = potH,
			Name        = nmH,
			Description = descH,
			Icon        = _item.getIcon(),
			Value       = valH,
			Script      = scriptH
		};
	}

	// 3. Known ShanHai Beast Trophies (`misc.unhold_heart`, `misc.spider_silk`, etc.) & Custom `misc.wx_mat_*`
	if (id in ::Wuxia.Config.Alchemy.KnownMaterials)
	{
		local tmeta = ::Wuxia.Config.Alchemy.KnownMaterials[id];
		local leaf = id.find("misc.") == 0 ? id.slice(5) : id;
		return {
			Key         = "trophy:" + leaf,
			ItemID      = id,
			SubID       = "",
			Kind        = tmeta.Kind,
			IsRare      = (tmeta.Potency >= 4),
			Nature      = tmeta.Nature,
			Potency     = tmeta.Potency,
			Name        = _item.getName(),
			Description = _item.getDescription(),
			Icon        = _item.getIcon(),
			Value       = _item.getValue(),
			Script      = tmeta.Script
		};
	}

	if (id.find("misc.wx_mat_") == 0 || (::Wuxia.hasMember(_item.m, "MatID") && _item.m.MatID != ""))
	{
		local mleaf = (::Wuxia.hasMember(_item.m, "MatID") && _item.m.MatID != "") ? _item.m.MatID : id.slice(5);
		local nmM = _item.getName();
		local descM = _item.getDescription();
		local valM = _item.getValue();
		local potM = ::Wuxia.Alchemy.inferPotencyFromValue(valM, false);
		return {
			Key         = "trophy:" + mleaf,
			ItemID      = id,
			SubID       = mleaf,
			Kind        = "trophy",
			IsRare      = (potM >= 4),
			Nature      = ::Wuxia.Alchemy.inferNatureFromText(nmM, descM),
			Potency     = potM,
			Name        = nmM,
			Description = descM,
			Icon        = _item.getIcon(),
			Value       = valM,
			Script      = "scripts/items/misc/" + mleaf
		};
	}

	return null;
};

// Safely reconstruct an item instance from Cabinet key & saved descriptor
::Wuxia.Alchemy.instantiateByCabinetKey <- function( _key, _savedScript = "", _subID = "" )
{
	local candidates = [];
	if (_savedScript != null && _savedScript != "")
		candidates.push(_savedScript);

	local colon = _key.find(":");
	local prefix = colon != null ? _key.slice(0, colon) : "";
	local tail = colon != null ? _key.slice(colon + 1) : _key;

	if (prefix == "core")
	{
		candidates.push("scripts/items/misc/" + tail);
		candidates.push("scripts/items/misc/wx_shanhai_core_base");
	}
	else if (prefix == "herb")
	{
		if (("misc." + tail) in ::Wuxia.Config.Alchemy.KnownMaterials)
			candidates.push(::Wuxia.Config.Alchemy.KnownMaterials["misc." + tail].Script);
		local ext = ::Wuxia.Alchemy.lookupExternalHerbConfig(tail);
		if (ext != null && ("Script" in ext) && ext.Script != "")
			candidates.push(ext.Script);
		candidates.push("scripts/items/misc/" + tail);
		candidates.push("scripts/items/misc/wx_herb_item");
		candidates.push("scripts/items/misc/wx_exotic_herb_item");
		candidates.push("scripts/items/misc/wx_herb_base");
	}
	else if (prefix == "trophy")
	{
		if (("misc." + tail) in ::Wuxia.Config.Alchemy.KnownMaterials)
			candidates.push(::Wuxia.Config.Alchemy.KnownMaterials["misc." + tail].Script);
		candidates.push("scripts/items/misc/" + tail + "_item");
		candidates.push("scripts/items/misc/" + tail);
	}

	local tried = {};
	for (local i = 0; i < candidates.len(); i = ++i)
	{
		local sc = candidates[i];
		if (sc == null || sc == "" || (sc in tried)) continue;
		tried[sc] <- true;
		try
		{
			local obj = ::new(sc);
			if (obj != null)
			{
				local initKey = (_subID != null && _subID != "") ? _subID : tail;
				if (prefix == "core" && ("initCore" in obj))
					obj.initCore(initKey);
				else if (prefix == "herb")
				{
					if ("initHerb" in obj) obj.initHerb(initKey);
					else if (::Wuxia.hasMember(obj, "setHerbID")) obj.setHerbID(initKey);
				}
				return obj;
			}
		}
		catch (_err) {}
	}
	return null;
};

// -----------------------------------------------------------------------------
// 2. Zero-Stash-Slot Herb & Core Cabinet (`::Wuxia.Alchemy.Cabinet` in `::World.Flags`)
// -----------------------------------------------------------------------------
::Wuxia.Alchemy.Cabinet <- {};

::Wuxia.Alchemy.Cabinet.cntFlag <- function( _key ) { return "wx_cab_n_" + _key; };
::Wuxia.Alchemy.Cabinet.metaFlag <- function( _key ) { return "wx_cab_m_" + _key; };

::Wuxia.Alchemy.Cabinet.isAutoStoreEnabled <- function()
{
	if (::Wuxia.Alchemy.hasWorldFlags())
	{
		if (!::World.Flags.has("wx_cab_autostore")) return true;
		return ::World.Flags.get("wx_cab_autostore") ? true : false;
	}
	return ::Wuxia.Alchemy.Fallback.AutoStore;
};

::Wuxia.Alchemy.Cabinet.setAutoStoreEnabled <- function( _enabled )
{
	local v = _enabled ? true : false;
	if (::Wuxia.Alchemy.hasWorldFlags())
		::World.Flags.set("wx_cab_autostore", v);
	else
		::Wuxia.Alchemy.Fallback.AutoStore = v;
	return v;
};

::Wuxia.Alchemy.Cabinet.isAutoTrophyEnabled <- function()
{
	if (::Wuxia.Alchemy.hasWorldFlags())
	{
		if (!::World.Flags.has("wx_cab_autotrophy")) return false;
		return ::World.Flags.get("wx_cab_autotrophy") ? true : false;
	}
	return ::Wuxia.Alchemy.Fallback.AutoTrophy;
};

::Wuxia.Alchemy.Cabinet.setAutoTrophyEnabled <- function( _enabled )
{
	local v = _enabled ? true : false;
	if (::Wuxia.Alchemy.hasWorldFlags())
		::World.Flags.set("wx_cab_autotrophy", v);
	else
		::Wuxia.Alchemy.Fallback.AutoTrophy = v;
	return v;
};

::Wuxia.Alchemy.Cabinet.registerKey <- function( _key, _script = "", _subID = "" )
{
	if (_key == null || _key == "") return;
	local packed = (_script != null ? _script : "") + "|" + (_subID != null ? _subID : "");
	if (::Wuxia.Alchemy.hasWorldFlags())
	{
		if (packed != "|")
			::World.Flags.set(::Wuxia.Alchemy.Cabinet.metaFlag(_key), packed);
		local raw = ::World.Flags.has("wx_cab_keys") ? ::World.Flags.get("wx_cab_keys") : "";
		if (raw == null || typeof raw != "string") raw = "";
		local token = ";" + _key + ";";
		local padded = ";" + raw + ";";
		if (padded.find(token) == null)
		{
			local next = (raw == "") ? _key : (raw + ";" + _key);
			::World.Flags.set("wx_cab_keys", next);
		}
	}
	else
	{
		::Wuxia.Alchemy.Fallback.Keys[_key] <- true;
		if (packed != "|")
			::Wuxia.Alchemy.Fallback.Meta[_key] <- packed;
	}
};

::Wuxia.Alchemy.Cabinet.getSavedMeta <- function( _key )
{
	local raw = "";
	if (::Wuxia.Alchemy.hasWorldFlags())
	{
		local mf = ::Wuxia.Alchemy.Cabinet.metaFlag(_key);
		if (::World.Flags.has(mf)) raw = ::World.Flags.get(mf);
	}
	else if (_key in ::Wuxia.Alchemy.Fallback.Meta)
	{
		raw = ::Wuxia.Alchemy.Fallback.Meta[_key];
	}
	if (raw == null || typeof raw != "string" || raw == "")
		return { Script = "", SubID = "" };
	local bar = raw.find("|");
	if (bar == null) return { Script = raw, SubID = "" };
	return {
		Script = raw.slice(0, bar),
		SubID  = raw.slice(bar + 1)
	};
};

::Wuxia.Alchemy.Cabinet.getCount <- function( _key )
{
	if (_key == null || _key == "") return 0;
	if (::Wuxia.Alchemy.hasWorldFlags())
	{
		local fk = ::Wuxia.Alchemy.Cabinet.cntFlag(_key);
		if (!::World.Flags.has(fk)) return 0;
		return ::Math.max(0, ::World.Flags.getAsInt(fk));
	}
	if (_key in ::Wuxia.Alchemy.Fallback.Counts)
		return ::Math.max(0, ::Wuxia.Alchemy.Fallback.Counts[_key]);
	return 0;
};

::Wuxia.Alchemy.Cabinet.setCount <- function( _key, _count )
{
	if (_key == null || _key == "") return 0;
	local next = ::Math.max(0, _count);
	if (::Wuxia.Alchemy.hasWorldFlags())
	{
		local fk = ::Wuxia.Alchemy.Cabinet.cntFlag(_key);
		if (next > 0 || ::World.Flags.has(fk))
			::World.Flags.set(fk, next);
	}
	else
	{
		if (next > 0) ::Wuxia.Alchemy.Fallback.Counts[_key] <- next;
		else if (_key in ::Wuxia.Alchemy.Fallback.Counts) delete ::Wuxia.Alchemy.Fallback.Counts[_key];
	}
	return next;
};

::Wuxia.Alchemy.Cabinet.addCount <- function( _key, _delta = 1, _script = "", _subID = "" )
{
	if (_key == null || _key == "") return 0;
	if (_delta > 0)
		::Wuxia.Alchemy.Cabinet.registerKey(_key, _script, _subID);
	local cur = ::Wuxia.Alchemy.Cabinet.getCount(_key);
	return ::Wuxia.Alchemy.Cabinet.setCount(_key, cur + _delta);
};

::Wuxia.Alchemy.Cabinet.getAllKnownKeys <- function()
{
	local map = {};
	if (::Wuxia.Alchemy.hasWorldFlags() && ::World.Flags.has("wx_cab_keys"))
	{
		local raw = ::World.Flags.get("wx_cab_keys");
		if (raw != null && typeof raw == "string" && raw != "")
		{
			foreach (part in split(raw, ";"))
			{
				if (part != "") map[part] <- true;
			}
		}
	}
	else
	{
		foreach (k, _ in ::Wuxia.Alchemy.Fallback.Keys)
			map[k] <- true;
	}

	// Also include known ShanHai cores, built-in materials, and any external Herb tables
	if ("ShanHaiCores" in ::Wuxia.Config)
	{
		foreach (cid, _ in ::Wuxia.Config.ShanHaiCores)
			map["core:" + cid] <- true;
	}
	foreach (mid, info in ::Wuxia.Config.Alchemy.KnownMaterials)
	{
		local leaf = mid.find("misc.") == 0 ? mid.slice(5) : mid;
		map[info.Kind + ":" + leaf] <- true;
	}
	if ("BeastMaterials" in ::Wuxia.Config)
	{
		foreach (mk, _mv in ::Wuxia.Config.BeastMaterials)
			map["trophy:" + mk] <- true;
	}
	foreach (hk, _ in ::Wuxia.Alchemy.getAllExternalHerbDefs())
	{
		local hleaf = hk.find("misc.") == 0 ? hk.slice(5) : hk;
		map["herb:" + hleaf] <- true;
	}

	local list = [];
	foreach (k2, _v in map) list.push(k2);
	return list;
};

// Sweep eligible alchemy ingredients from Stash into Zero-Slot Cabinet
// _includeTrophies: when false (default auto-sweep), sweeps Herbs + Cores; when true, also sweeps Beast Trophies!
::Wuxia.Alchemy.Cabinet.storeFromStash <- function( _stash, _includeWithdrawn = true, _includeTrophies = false )
{
	local herbsMoved    = 0;
	local coresMoved    = 0;
	local trophiesMoved = 0;
	local slotsCleared  = 0;
	if (_stash == null)
		return { herbsMoved = 0, coresMoved = 0, trophiesMoved = 0, slotsCleared = 0 };

	local items = _stash.getItems();
	for (local i = items.len() - 1; i >= 0; i = --i)
	{
		local it = items[i];
		if (it == null) continue;
		if (!_includeWithdrawn && ::Wuxia.isWithdrawnForSale(it))
			continue;

		local meta = ::Wuxia.Alchemy.classifyItem(it);
		if (meta == null) continue;
		if (meta.Kind == "trophy" && !_includeTrophies) continue;

		::Wuxia.Alchemy.Cabinet.addCount(meta.Key, 1, meta.Script, meta.SubID);
		_stash.removeByIndex(i);
		slotsCleared += 1;
		if (meta.Kind == "herb")      herbsMoved += 1;
		else if (meta.Kind == "core") coresMoved += 1;
		else                          trophiesMoved += 1;
	}

	return {
		herbsMoved    = herbsMoved,
		coresMoved    = coresMoved,
		trophiesMoved = trophiesMoved,
		slotsCleared  = slotsCleared
	};
};

// Withdraw 1 ingredient from Cabinet back to Stash (marked WX_WithdrawnForSale so Auto-Store keeps it in Stash for selling/Taxidermist)
::Wuxia.Alchemy.Cabinet.withdrawToStash <- function( _stash, _key, _qty = 1 )
{
	if (_stash == null)
		return { Ok = false, Reason = "当前无法访问战团仓库。" };
	local avail = ::Wuxia.Alchemy.Cabinet.getCount(_key);
	if (avail <= 0)
		return { Ok = false, Reason = "百草药柜中已无此药材存量。" };

	local want = ::Math.max(1, ::Math.min(_qty, avail));
	local saved = ::Wuxia.Alchemy.Cabinet.getSavedMeta(_key);
	local moved = 0;
	local lastName = _key;

	for (local n = 0; n < want; n = ++n)
	{
		local item = ::Wuxia.Alchemy.instantiateByCabinetKey(_key, saved.Script, saved.SubID);
		if (item == null)
		{
			if (moved == 0)
				return { Ok = false, Reason = "无法还原该药材物品实例。" };
			break;
		}
		::Wuxia.markWithdrawnForSale(item);
		if (_stash.add(item) == null)
		{
			if (moved == 0)
				return { Ok = false, Reason = "战团仓库已满，请先清理空位再取出药材。" };
			break;
		}
		lastName = item.getName();
		::Wuxia.Alchemy.Cabinet.addCount(_key, -1);
		moved += 1;
	}

	return {
		Ok    = true,
		Count = moved,
		Name  = lastName
	};
};

// Session cache for static cabinet item metadata (`Key -> base meta table`) so `getUnifiedIngredients`
// never repeatedly calls `::new(...)` for every stored herb/core/trophy on every brew or UI refresh!
::Wuxia.Alchemy.CabinetMetaCache <- {};

::Wuxia.Alchemy.getCachedCabinetMeta <- function( _key, _saved )
{
	if (_key in ::Wuxia.Alchemy.CabinetMetaCache)
		return clone ::Wuxia.Alchemy.CabinetMetaCache[_key];

	local probe = ::Wuxia.Alchemy.instantiateByCabinetKey(_key, _saved.Script, _saved.SubID);
	if (probe == null) return null;
	local meta = ::Wuxia.Alchemy.classifyItem(probe);
	if (meta == null) return null;

	::Wuxia.Alchemy.CabinetMetaCache[_key] <- clone meta;
	return meta;
};

// Gather unified inventory of ALL available alchemy ingredients across BOTH Cabinet AND Stash!
::Wuxia.Alchemy.getUnifiedIngredients <- function( _stash = null )
{
	local stashRef = _stash;
	if (stashRef == null && ("World" in getroottable()) && ::World != null && ("Assets" in ::World) && ::World.Assets != null)
		stashRef = ::World.Assets.getStash();

	local byKey = {};

	// 1. Scan Stash live items first (captures exact live icons/names/scripts!)
	if (stashRef != null)
	{
		local sItems = stashRef.getItems();
		for (local i = 0; i < sItems.len(); i = ++i)
		{
			local it = sItems[i];
			if (it == null) continue;
			local meta = ::Wuxia.Alchemy.classifyItem(it);
			if (meta == null) continue;

			if (!(meta.Key in ::Wuxia.Alchemy.CabinetMetaCache))
				::Wuxia.Alchemy.CabinetMetaCache[meta.Key] <- clone meta;

			if (!(meta.Key in byKey))
			{
				meta.CabinetCount <- ::Wuxia.Alchemy.Cabinet.getCount(meta.Key);
				meta.StashCount   <- 0;
				meta.StashIndices <- [];
				byKey[meta.Key]   <- meta;
			}
			byKey[meta.Key].StashCount += 1;
			byKey[meta.Key].StashIndices.push(i);
		}
	}

	// 2. Scan Cabinet stored items that have count > 0 and weren't already in Stash
	local allKeys = ::Wuxia.Alchemy.Cabinet.getAllKnownKeys();
	for (local k = 0; k < allKeys.len(); k = ++k)
	{
		local key = allKeys[k];
		if (key in byKey) continue;
		local cabCnt = ::Wuxia.Alchemy.Cabinet.getCount(key);
		if (cabCnt <= 0) continue;

		local saved = ::Wuxia.Alchemy.Cabinet.getSavedMeta(key);
		local meta2 = ::Wuxia.Alchemy.getCachedCabinetMeta(key, saved);
		if (meta2 == null) continue;

		meta2.CabinetCount <- cabCnt;
		meta2.StashCount   <- 0;
		meta2.StashIndices <- [];
		byKey[key]         <- meta2;
	}

	local list = [];
	foreach (_k, entry in byKey)
	{
		entry.TotalCount <- entry.CabinetCount + entry.StashCount;
		if (entry.TotalCount > 0)
		{
			local natInfo = (entry.Nature in ::Wuxia.Config.Alchemy.Natures)
				? ::Wuxia.Config.Alchemy.Natures[entry.Nature]
				: ::Wuxia.Config.Alchemy.Natures.vital;
			entry.NatureName  <- natInfo.Name;
			entry.NatureShort <- natInfo.Short;
			entry.NatureColor <- natInfo.Color;
			list.push(entry);
		}
	}

	// Sort: Herbs first, then Cores, then Trophies; within kind by Potency desc, then Name
	local kindRank = { herb = 3, core = 2, trophy = 1 };
	list.sort(function( a, b ) {
		local ra = (a.Kind in kindRank) ? kindRank[a.Kind] : 0;
		local rb = (b.Kind in kindRank) ? kindRank[b.Kind] : 0;
		if (ra != rb) return ra > rb ? -1 : 1;
		if (a.Potency != b.Potency) return a.Potency > b.Potency ? -1 : 1;
		return a.Name <=> b.Name;
	});
	return list;
};

::Wuxia.Alchemy.getCabinetSummaryCounts <- function( _stash = null, _ingList = null )
{
	local list = (_ingList != null) ? _ingList : ::Wuxia.Alchemy.getUnifiedIngredients(_stash);
	local cabHerbs = 0;
	local cabCores = 0;
	local cabTrophies = 0;
	local stashMovable = 0;

	for (local i = 0; i < list.len(); i = ++i)
	{
		local e = list[i];
		if (e.Kind == "herb")      cabHerbs += e.CabinetCount;
		else if (e.Kind == "core") cabCores += e.CabinetCount;
		else                       cabTrophies += e.CabinetCount;
		stashMovable += e.StashCount;
	}
	return {
		cabinetHerbs    = cabHerbs,
		cabinetCores    = cabCores,
		cabinetTrophies = cabTrophies,
		cabinetTotal    = cabHerbs + cabCores + cabTrophies,
		stashMovable    = stashMovable
	};
};

// Consume 1 unit of an ingredient Key (prefers Zero-Slot Cabinet first, then Stash!)
::Wuxia.Alchemy.consumeOneIngredient <- function( _key, _stash )
{
	if (::Wuxia.Alchemy.Cabinet.getCount(_key) > 0)
	{
		::Wuxia.Alchemy.Cabinet.addCount(_key, -1);
		return true;
	}
	if (_stash != null)
	{
		local items = _stash.getItems();
		for (local i = items.len() - 1; i >= 0; i = --i)
		{
			local it = items[i];
			if (it == null) continue;
			local meta = ::Wuxia.Alchemy.classifyItem(it);
			if (meta != null && meta.Key == _key)
			{
				_stash.removeByIndex(i);
				return true;
			}
		}
	}
	return false;
};

// -----------------------------------------------------------------------------
// 3. Alchemist Mastery & Bagua Cauldron Brewing Engine (`::Wuxia.Alchemy.Cauldron`)
// -----------------------------------------------------------------------------
::Wuxia.Alchemy.getAlchemistMastery <- function()
{
	local bonusDoublePct = 0;
	local costMult       = 1.0;
	local masterLabel    = "随军自炼";

	// 1. Check Retinue `丹鼎方士` (`follower.alchemist`)
	if ("World" in getroottable() && ::World != null && ("Retinue" in ::World) && ::World.Retinue != null)
	{
		try
		{
			if ("hasFollower" in ::World.Retinue && ::World.Retinue.hasFollower("follower.alchemist"))
			{
				bonusDoublePct += 20;
				costMult = 0.80;
				masterLabel = "丹鼎方士坐镇";
			}
		}
		catch (_e) {}
	}

	// 1b. Origin persistent rule: Wudu Healer (`scenario.wx_origin_wudu_healer`) alchemy specialization (+15% double/grade chance, -15% charcoal cost)
	if ("World" in getroottable() && ::World != null && ("Assets" in ::World) && ::World.Assets != null && ::World.Assets.getOrigin() != null)
	{
		if (::World.Assets.getOrigin().getID() == "scenario.wx_origin_wudu_healer")
		{
			bonusDoublePct += 15;
			costMult *= 0.85;
			masterLabel = (masterLabel == "随军自炼") ? "南疆百草丹脉" : (masterLabel + " · 南疆百草");
		}
	}

	// 2. Check Roster Brothers for Physician / Herbalist / Monk / Taoist / Scholar backgrounds
	if ("World" in getroottable() && ::World != null && ("getPlayerRoster" in ::World) && ::World.getPlayerRoster() != null)
	{
		local bestBroBonus = 0;
		local bestBroName  = "";
		foreach (bro in ::World.getPlayerRoster().getAll())
		{
			if (bro == null || !bro.isAlive()) continue;
			local bg = bro.getBackground();
			local bgId = bg != null ? bg.getID() : "";
			local bBonus = 0;
			if (bgId == "background.anatomist" || bgId == "background.monk" || bgId == "background.historian")
				bBonus = 12;
			else if (bgId == "background.beast_slayer" || bgId == "background.witchhunter" || bgId == "background.peddler")
				bBonus = 8;

			// High Resolve adds up to +6% furnace control
			local brv = bro.getBaseProperties().Bravery;
			if (brv >= 60)
				bBonus += ::Math.min(6, ::Math.floor((brv - 50) / 10));

			if (bBonus > bestBroBonus)
			{
				bestBroBonus = bBonus;
				bestBroName = bro.getName();
			}
		}
		if (bestBroBonus > 0)
		{
			bonusDoublePct += bestBroBonus;
			if (masterLabel == "随军自炼")
				masterLabel = bestBroName + " 掌炉";
			else
				masterLabel += " · " + bestBroName + " 协炼";
		}
	}

	return {
		BonusDoublePct = ::Math.min(45, bonusDoublePct),
		CostMult       = costMult,
		MasterLabel    = masterLabel
	};
};

::Wuxia.Alchemy.findFormula <- function( _formulaID )
{
	foreach (f in ::Wuxia.Config.Alchemy.Formulas)
	{
		if (f.ID == _formulaID) return f;
	}
	return null;
};

::Wuxia.Alchemy.doesJunMatchFormula <- function( _ingMeta, _formula )
{
	if (_ingMeta == null || _formula == null) return false;
	if (("RequiredCoreKey" in _formula) && _formula.RequiredCoreKey != "" && (!("Key" in _ingMeta) || _ingMeta.Key != _formula.RequiredCoreKey))
		return false;
	if (_ingMeta.Potency < _formula.MinJunPotency) return false;
	if (_formula.RequireRareJun && !_ingMeta.IsRare) return false;

	local natOk = false;
	foreach (n in _formula.JunNatures)
	{
		if (n == _ingMeta.Nature) { natOk = true; break; }
	}
	return natOk;
};

// Evaluate Six-Meridian Generating (`相生`), Overcoming (`相克`), Tribulation Risk (`丹劫`) & Hidden Mutation (`阴阳逆命奇丹`)!
::Wuxia.Alchemy.evaluateSixMeridianSynergy <- function( _junMeta, _auxMetas, _fireMode = "balanced", _masteryBonusPct = 0 )
{
	local res = {
		GenCount         = 0,
		OvercomeCount    = 0,
		PotencyBonus     = 0,
		HarmonyDelta     = 0,
		GenPairs         = 0,
		ClashPairs       = 0,
		ReverseFateReady = false,
		HasCore          = (_junMeta != null && ("Kind" in _junMeta) && _junMeta.Kind == "core"),
		HasYang          = (_junMeta != null && ("Nature" in _junMeta) && _junMeta.Nature == "yang"),
		HasYin           = (_junMeta != null && ("Nature" in _junMeta) && _junMeta.Nature == "yin"),
		HasVital         = (_junMeta != null && ("Nature" in _junMeta) && _junMeta.Nature == "vital"),
		HasVenom         = (_junMeta != null && ("Nature" in _junMeta) && _junMeta.Nature == "venom"),
		HasSpirit        = (_junMeta != null && ("Nature" in _junMeta) && _junMeta.Nature == "spirit"),
		MutationPillID   = "",
		MutationFormulaID = "",
		TribulationPct   = 0,
		RelationLabel    = "平正配伍"
	};
	if (_junMeta == null || _auxMetas == null) return res;

	local relCfg = ("MeridianRelations" in ::Wuxia.Config.Alchemy) ? ::Wuxia.Config.Alchemy.MeridianRelations : null;
	local junNat = _junMeta.Nature;

	foreach (ax in _auxMetas)
	{
		if (ax == null) continue;
		if (("Kind" in ax) && ax.Kind == "core") res.HasCore = true;
		if (("Nature" in ax) && ax.Nature == "yang") res.HasYang = true;
		if (("Nature" in ax) && ax.Nature == "yin") res.HasYin = true;
		if (("Nature" in ax) && ax.Nature == "vital") res.HasVital = true;
		if (("Nature" in ax) && ax.Nature == "venom") res.HasVenom = true;
		if (("Nature" in ax) && ax.Nature == "spirit") res.HasSpirit = true;

		if (relCfg != null)
		{
			local isGen = false;
			if ((ax.Nature in relCfg.Generates) && relCfg.Generates[ax.Nature].find(junNat) != null)
				isGen = true;
			else if ((junNat in relCfg.Generates) && relCfg.Generates[junNat].find(ax.Nature) != null)
				isGen = true;

			local isOvr = false;
			if ((ax.Nature in relCfg.Overcomes) && relCfg.Overcomes[ax.Nature].find(junNat) != null)
				isOvr = true;
			else if ((junNat in relCfg.Overcomes) && relCfg.Overcomes[junNat].find(ax.Nature) != null)
				isOvr = true;

			if (isGen)
			{
				res.GenCount += 1;
				res.PotencyBonus += 1;
				res.HarmonyDelta += 12;
			}
			else if (isOvr)
			{
				res.OvercomeCount += 1;
				res.HarmonyDelta -= 10;
			}
		}
	}

	// Cross-check auxiliary-to-auxiliary generating & Yang×Yin collision pairs!
	if (relCfg != null && _auxMetas.len() >= 2)
	{
		for (local a1 = 0; a1 < _auxMetas.len(); a1 = ++a1)
		{
			for (local a2 = a1 + 1; a2 < _auxMetas.len(); a2 = ++a2)
			{
				local n1 = (_auxMetas[a1] != null && ("Nature" in _auxMetas[a1])) ? _auxMetas[a1].Nature : "";
				local n2 = (_auxMetas[a2] != null && ("Nature" in _auxMetas[a2])) ? _auxMetas[a2].Nature : "";
				if (n1 == "" || n2 == "") continue;
				if (((n1 in relCfg.Generates) && relCfg.Generates[n1].find(n2) != null)
					|| ((n2 in relCfg.Generates) && relCfg.Generates[n2].find(n1) != null))
				{
					res.GenCount += 1;
					res.PotencyBonus += 1;
					res.HarmonyDelta += 8;
				}
			}
		}
	}
	if ((res.HasYang && res.HasYin || res.HasVital && res.HasVenom || res.HasSpirit && res.HasVenom) && res.OvercomeCount == 0)
	{
		res.OvercomeCount += 1;
		res.HarmonyDelta -= 8;
	}

	local rawPot = ("Potency" in _junMeta) ? _junMeta.Potency : 4;
	foreach (ax2 in _auxMetas) if (ax2 != null) rawPot += (("Potency" in ax2) ? ax2.Potency : 3);
	local effTotalPot = rawPot + res.PotencyBonus;

	if (res.HasCore && res.HasYang && res.HasYin && effTotalPot >= 10 && _fireMode == "fierce")
	{
		res.MutationPillID    = "wx_pill_liangyi";
		res.MutationFormulaID = "f_liangyi_niming";
		res.RelationLabel     = "✦ 阴阳相激 · 内丹镇鼎可逆炼【两仪逆命混元丹】！";
	}
	else if (res.HasCore && res.HasVital && res.HasVenom && effTotalPot >= 11 && _fireMode == "fierce")
	{
		res.MutationPillID    = "wx_pill_kurong";
		res.MutationFormulaID = "f_kurong_niepan";
		res.RelationLabel     = "✦ 枯荣相激 · 内丹镇鼎可逆炼【枯荣生死涅槃丸】！";
	}
	else if (res.HasCore && res.HasSpirit && res.HasVenom && effTotalPot >= 11 && _fireMode == "fierce")
	{
		res.MutationPillID    = "wx_pill_shenmo";
		res.MutationFormulaID = "f_shenmo_bixie";
		res.RelationLabel     = "✦ 神魔相激 · 内丹镇鼎可逆炼【神魔一念辟邪丹】！";
	}
	else if (res.OvercomeCount > 0 && res.GenCount > 0)
	{
		res.RelationLabel = "生克交织（相生×" + res.GenCount + " · 相克×" + res.OvercomeCount + "）";
	}
	else if (res.OvercomeCount > 0)
	{
		res.RelationLabel = (res.HasCore && (res.HasYang && res.HasYin || res.HasVital && res.HasVenom || res.HasSpirit && res.HasVenom))
			? "两极相克（切至【武火催霞】且总药力达标可逆炼奇丹！）"
			: ("六脉相克×" + res.OvercomeCount + "（炉气躁动）");
	}
	else if (res.GenCount > 0)
	{
		res.RelationLabel = "六脉相生×" + res.GenCount + "（药力 +" + res.PotencyBonus + " · 炉韵醇和）";
	}

	res.GenPairs = res.GenCount;
	res.ClashPairs = res.OvercomeCount;
	res.ReverseFateReady = (res.MutationPillID != "");

	if (_fireMode == "fierce" && res.MutationPillID == "")
	{
		local trib = 14 + res.OvercomeCount * 12 - res.GenCount * 5 - ::Math.floor(_masteryBonusPct * 0.30);
		res.TribulationPct = ::Math.max(4, ::Math.min(42, trib));
	}
	return res;
};

// Determine the dominant auxiliary Nature (`生机 / 赤阳 / 玄阴 / 镇魂 / 奇毒 / 造化`) from Cauldron slots 1 & 2
::Wuxia.Alchemy.resolveDominantAuxNature <- function( _slotKeys, _ingMap )
{
	if (_slotKeys == null || _ingMap == null) return "";
	local bestNat = "";
	local bestPot = -1;
	for (local si = 1; si < _slotKeys.len() && si <= 2; si = ++si)
	{
		local ak = _slotKeys[si];
		if (ak == null || ak == "" || !(ak in _ingMap)) continue;
		local aux = _ingMap[ak];
		if (aux.Potency > bestPot)
		{
			bestPot = aux.Potency;
			bestNat = aux.Nature;
		}
	}
	return bestNat;
};

// Compute Pill Quality Grade probabilities `[成丹%, 灵纹%, 丹霞极品%]` from surplus potency, harmony, mastery & fire mode!
::Wuxia.Alchemy.calcPillGradeChances <- function( _surplus, _harmonyBonus, _masteryBonusPct, _fireMode = "balanced" )
{
	local fSpec = ("FireModes" in ::Wuxia.Config.Alchemy && (_fireMode in ::Wuxia.Config.Alchemy.FireModes))
		? ::Wuxia.Config.Alchemy.FireModes[_fireMode]
		: { Grade2Bonus = 0, Grade3Bonus = 0 };
	local sur = ::Math.max(0, _surplus);
	local maxG3 = (_fireMode == "fierce") ? 62 : 42;
	local g3 = ::Math.max(2, ::Math.min(maxG3, 8 + sur * 4 + ::Math.floor((_harmonyBonus + _masteryBonusPct) * 0.40) + fSpec.Grade3Bonus));
	local g2 = ::Math.max(15, ::Math.min(54, 30 + sur * 5 + ::Math.floor((_harmonyBonus + _masteryBonusPct) * 0.35) + fSpec.Grade2Bonus));
	if (g2 + g3 > 92) g2 = 92 - g3;
	local g1 = ::Math.max(8, 100 - g2 - g3);
	return [g1, g2, g3];
};

::Wuxia.Alchemy.rollPillVariant <- function( _gradeChances, _auxNature = "", _fireMode = "balanced" )
{
	local ch = (_gradeChances != null && _gradeChances.len() >= 3) ? _gradeChances : [60, 30, 10];
	local r = ::Math.rand(1, 100);
	local grade = 1;
	if (r > ch[0] + ch[1]) grade = 3;
	else if (r > ch[0]) grade = 2;

	local gSpec = ("PillGrades" in ::Wuxia.Config.Alchemy && (grade in ::Wuxia.Config.Alchemy.PillGrades))
		? ::Wuxia.Config.Alchemy.PillGrades[grade]
		: { MinPct = 95, MaxPct = 105 };
	local loPct = gSpec.MinPct;
	if (_fireMode == "gentle" && grade == 1 && loPct < 98)
		loPct = 98;
	local pct = ::Math.rand(loPct, gSpec.MaxPct);
	return {
		Grade      = grade,
		PotencyPct = pct,
		AuxNature  = (_auxNature != null) ? _auxNature : ""
	};
};

// Roll Town 百工丹坊 Blueprint-Crafted Pill with Alchemist Mastery support!
::Wuxia.Alchemy.rollTownCraftedPill <- function( _pillItem )
{
	if (_pillItem == null || _pillItem.getID() != "misc.wx_pill_item") return null;
	local mst = ::Wuxia.Alchemy.getAlchemistMastery();
	local ch = ::Wuxia.Alchemy.calcPillGradeChances(1, 6, mst.BonusDoublePct);
	local rolled = ::Wuxia.Alchemy.rollPillVariant(ch, "");
	_pillItem.initPillVariant(_pillItem.getPillID(), rolled.Grade, rolled.PotencyPct, "");
	if (rolled.Grade >= 2 && ::Wuxia.Alchemy.hasWorldFlags())
		::World.Flags.set("wx_brewed_high_pill", true);
	return rolled;
};

::Wuxia.Alchemy.getAuxEffectPreviewLine <- function( _auxNature, _pillKind )
{
	if (_auxNature == null || _auxNature == "" || !("AuxInfusions" in ::Wuxia.Config.Alchemy) || !(_auxNature in ::Wuxia.Config.Alchemy.AuxInfusions))
		return { Title = "", Color = "#bd9d71", Desc = "" };
	local spec = ::Wuxia.Config.Alchemy.AuxInfusions[_auxNature];
	local desc = spec.PrepDesc;
	if (_pillKind == "infuse_exp") desc = spec.InfuseDesc;
	else if (_pillKind != null && _pillKind.find("heal_") == 0 && _pillKind != "heal_internal_plus") desc = spec.HealDesc;
	else if (_pillKind != null && _pillKind.find("marrow_wash") == 0) desc = "成丹品阶加成：灵纹洗髓成功率 +4% / 丹霞极品洗髓成功率 +8%！";
	else if (_pillKind == "wash_protect") desc = "成丹品阶加成：灵纹护脉额外 +2% / 丹霞极品护脉额外 +5%！";
	else if (_pillKind == "wangchen_grace") desc = "丹霞极品奇效：服下额外荡平身上 1 处轻度走火入魔内伤！";
	else if (_pillKind != null && _pillKind.find("cure_perm_") == 0) desc = "丹霞极品奇效：拔除沉疴暗疾之余额外大补气血与战意！";
	return { Title = spec.Title, Color = spec.Color, Desc = desc };
};

::Wuxia.Alchemy.getCoreImprintPreview <- function( _coreID, _pillKind = "buff_" )
{
	if (_coreID == null || _coreID == "" || !("Alchemy" in ::Wuxia.Config)) return null;
	local cid = (_coreID.find("core:") == 0) ? _coreID.slice(5) : _coreID;
	local imp = ("CoreImprints" in ::Wuxia.Config.Alchemy && (cid in ::Wuxia.Config.Alchemy.CoreImprints))
		? ::Wuxia.Config.Alchemy.CoreImprints[cid]
		: null;
	if (imp == null && "ShanHaiCores" in ::Wuxia.Config && (cid in ::Wuxia.Config.ShanHaiCores))
	{
		local cdef = ::Wuxia.Config.ShanHaiCores[cid];
		local aff = ("Affinity" in cdef) ? cdef.Affinity : "waigong";
		local modeMap = { waigong = "feral_might", qinggong = "gale_stride", henglian = "bastion_shell", tactics = "oracle_sight", neigong_yang = "solar_scorch", neigong_yin = "abyssal_frost" };
		imp = { Title = cdef.Name + "本命韵", Mode = (aff in modeMap) ? modeMap[aff] : "feral_might" };
	}
	if (imp == null) return null;
	local mSpec = ("CoreImprintModes" in ::Wuxia.Config.Alchemy && (imp.Mode in ::Wuxia.Config.Alchemy.CoreImprintModes))
		? ::Wuxia.Config.Alchemy.CoreImprintModes[imp.Mode]
		: { Color = "#f0bc42", TooltipColor = "#5e2c00", PrepDesc = "山海妖丹精魄加持" };
	local desc = mSpec.PrepDesc;
	if (_pillKind == "infuse_exp")
		desc = "大妖本命精魄灌顶：拖入武学插槽额外增幅 +15% 火候！";
	else if (_pillKind != null && _pillKind.find("marrow_wash") == 0)
		desc = "大妖本命精元固本：启用此丹洗经伐髓成功率额外再 +3%！";
	else if (_pillKind != null && _pillKind.find("heal_") == 0 && _pillKind != "heal_internal_plus")
		desc = "大妖本命生机护脉：服敷疗伤额外恢复 +15 气血并稳固战意！";
	return {
		CoreID       = cid,
		Title        = imp.Title,
		Mode         = imp.Mode,
		Color        = mSpec.Color,
		TooltipColor = mSpec.TooltipColor,
		Desc         = desc
	};
};

// Preview a Cauldron brew given selected ingredient keys `[junKey, aux1Key, aux2Key]` & `fireMode` (`gentle / balanced / fierce`)
::Wuxia.Alchemy.previewBrew <- function( _formulaID, _slotKeys, _ingMap = null, _mastery = null, _haveMoney = -1, _fireMode = "balanced" )
{
	local formula = ::Wuxia.Alchemy.findFormula(_formulaID);
	if (formula == null)
		return { Ok = false, Reason = "未知的丹炉古方。" };

	local useFire = (_fireMode != null && "FireModes" in ::Wuxia.Config.Alchemy && (_fireMode in ::Wuxia.Config.Alchemy.FireModes)) ? _fireMode : "balanced";
	local fModeSpec = ::Wuxia.Config.Alchemy.FireModes[useFire];

	local map = _ingMap;
	if (map == null)
	{
		map = {};
		foreach (e in ::Wuxia.Alchemy.getUnifiedIngredients())
			map[e.Key] <- e;
	}

	local mastery = (_mastery != null) ? _mastery : ::Wuxia.Alchemy.getAlchemistMastery();
	local silverCost = ::Math.max(45, ::Math.floor(formula.SilverCost * mastery.CostMult * fModeSpec.CostMult));
	local pdef = ::Wuxia.Config.Pills[formula.PillID];

	if (_slotKeys == null || _slotKeys.len() == 0 || _slotKeys[0] == null || _slotKeys[0] == "")
	{
		return {
			Ok             = false,
			Reason         = "请先在【君药鼎位】放入符合药性的主药（或点击「智能抓药」）。",
			SilverCost     = silverCost,
			FireMode       = useFire,
			TargetPotency  = formula.TargetPotency,
			CurrentPotency = 0,
			MasterLabel    = mastery.MasterLabel
		};
	}

	local junKey = _slotKeys[0];
	if (!(junKey in map))
		return { Ok = false, Reason = "所选君药存量不足。", SilverCost = silverCost, FireMode = useFire };

	local jun = map[junKey];
	if (!::Wuxia.Alchemy.doesJunMatchFormula(jun, formula))
		return { Ok = false, Reason = "「" + jun.Name + "」不符合本方君药药性、本命内丹或药力品阶要求。", SilverCost = silverCost, FireMode = useFire };

	local usedCounts = {};
	usedCounts[junKey] <- 1;

	local auxCount = 0;
	local auxMetas = [];
	local totalPotency = jun.Potency;
	local harmonyBonus = 0;

	for (local si = 1; si < _slotKeys.len() && si <= 2; si = ++si)
	{
		local ak = _slotKeys[si];
		if (ak == null || ak == "") continue;
		if (!(ak in map))
			return { Ok = false, Reason = "所选臣佐辅材存量不足。", SilverCost = silverCost, FireMode = useFire };
		usedCounts[ak] <- ((ak in usedCounts) ? usedCounts[ak] : 0) + 1;
		if (usedCounts[ak] > map[ak].TotalCount)
			return { Ok = false, Reason = "「" + map[ak].Name + "」持有数量不足（同一炉重复占用超出存量）。", SilverCost = silverCost, FireMode = useFire };

		local aux = map[ak];
		auxCount += 1;
		auxMetas.push(aux);
		totalPotency += aux.Potency;
		foreach (jn in formula.JunNatures)
		{
			if (aux.Nature == jn) { harmonyBonus += 8; break; }
		}
		if (aux.Kind == "herb") harmonyBonus += 6;
		else if (aux.Kind == "core") harmonyBonus += 10;
	}

	local syn = ::Wuxia.Alchemy.evaluateSixMeridianSynergy(jun, auxMetas, useFire, mastery.BonusDoublePct);
	totalPotency += syn.PotencyBonus;
	harmonyBonus = ::Math.max(0, harmonyBonus + syn.HarmonyDelta);

	if (("IsHiddenMutation" in formula) && formula.IsHiddenMutation)
	{
		local pairOk = (formula.ID == "f_liangyi_niming" && syn.HasYang && syn.HasYin)
			|| (formula.ID == "f_kurong_niepan" && syn.HasVital && syn.HasVenom)
			|| (formula.ID == "f_shenmo_bixie" && syn.HasSpirit && syn.HasVenom);
		if (!syn.HasCore || !pairOk)
			return { Ok = false, Reason = "逆命奇丹须同炉备齐【山海大妖内丹】与本方要求的两极相克药材激撞！", SilverCost = silverCost, FireMode = useFire, CurrentPotency = totalPotency, TargetPotency = formula.TargetPotency };
		if (useFire != "fierce")
			return { Ok = false, Reason = "逆炼此【阴阳逆命奇丹】必须切换至【武火催霞】猛火合道！", SilverCost = silverCost, FireMode = useFire, CurrentPotency = totalPotency, TargetPotency = formula.TargetPotency };
	}

	if (usedCounts[junKey] > jun.TotalCount)
		return { Ok = false, Reason = "「" + jun.Name + "」存量不足。", SilverCost = silverCost, FireMode = useFire };

	if (auxCount < formula.MinAuxCount)
	{
		return {
			Ok             = false,
			Reason         = "本方至少需配齐 " + formula.MinAuxCount + " 味【臣佐辅药】以调和鼎火（当前已配 " + auxCount + " 味）。",
			SilverCost     = silverCost,
			FireMode       = useFire,
			TargetPotency  = formula.TargetPotency,
			CurrentPotency = totalPotency,
			MasterLabel    = mastery.MasterLabel
		};
	}

	if (totalPotency < formula.TargetPotency)
	{
		return {
			Ok             = false,
			Reason         = "鼎内总药力不足（当前 " + totalPotency + " / 需达 " + formula.TargetPotency + "），请增补相生佐药或换用更高阶奇草/内丹。",
			SilverCost     = silverCost,
			FireMode       = useFire,
			TargetPotency  = formula.TargetPotency,
			CurrentPotency = totalPotency,
			MasterLabel    = mastery.MasterLabel
		};
	}

	local surplus = totalPotency - formula.TargetPotency;
	local maxDbl = (useFire == "fierce") ? 92 : 85;
	local doubleChance = ::Math.max(5, ::Math.min(maxDbl, 12 + surplus * 10 + harmonyBonus + mastery.BonusDoublePct + fModeSpec.DoubleBonus));
	local gradeChances = ::Wuxia.Alchemy.calcPillGradeChances(surplus, harmonyBonus, mastery.BonusDoublePct, useFire);
	local auxNature    = ::Wuxia.Alchemy.resolveDominantAuxNature(_slotKeys, map);
	local auxPreview   = ::Wuxia.Alchemy.getAuxEffectPreviewLine(auxNature, pdef.Kind);
	local coreImp      = (jun.Kind == "core") ? ::Wuxia.Alchemy.getCoreImprintPreview(jun.SubID != "" ? jun.SubID : jun.Key, pdef.Kind) : null;
	local haveMoney = (_haveMoney >= 0)
		? _haveMoney
		: (("World" in getroottable() && ::World != null && ("Assets" in ::World) && ::World.Assets != null)
			? ::World.Assets.getMoney()
			: 999999);

	local byproductName = "";
	if ("BonusByproduct" in formula && (formula.BonusByproduct in ::Wuxia.Config.Pills))
		byproductName = ::Wuxia.Config.Pills[formula.BonusByproduct].Name;

	return {
		Ok               = (haveMoney >= silverCost),
		Reason           = (haveMoney < silverCost) ? ("炉火纹银不足（需 " + silverCost + " 两）。") : "",
		IngredientsReady = true,
		FireMode         = useFire,
		FireTitle        = fModeSpec.Title,
		PillID           = formula.PillID,
		PillName         = pdef.Name,
		BaseYield        = formula.BaseYield,
		SilverCost       = silverCost,
		TargetPotency    = formula.TargetPotency,
		CurrentPotency   = totalPotency,
		PotencyBonus     = syn.PotencyBonus,
		RelationLabel    = syn.RelationLabel,
		TribulationPct   = syn.TribulationPct,
		DoubleChance     = doubleChance,
		GradeChances     = gradeChances,
		AuxNature        = auxNature,
		AuxTitle         = auxPreview.Title,
		AuxColor         = auxPreview.Color,
		AuxDesc          = auxPreview.Desc,
		CoreImprintID    = coreImp != null ? coreImp.CoreID : "",
		CoreImprintTitle = coreImp != null ? coreImp.Title : "",
		CoreImprintColor = coreImp != null ? coreImp.Color : "#f0bc42",
		CoreImprintDesc  = coreImp != null ? coreImp.Desc : "",
		ByproductName    = byproductName,
		MasterLabel      = mastery.MasterLabel
	};
};

// Pre-sort ingredient list once for batch auto-pick across all 50 formulas (reduces 100 sorts -> 2 sorts!)
::Wuxia.Alchemy.buildAutoPickSortedViews <- function( _ingList )
{
	local kindCost = { trophy = 1, herb = 2, core = 3 };
	local sorted = clone _ingList;
	sorted.sort(function( a, b ) {
		if (a.Potency != b.Potency) return a.Potency < b.Potency ? -1 : 1;
		local ka = (a.Kind in kindCost) ? kindCost[a.Kind] : 2;
		local kb = (b.Kind in kindCost) ? kindCost[b.Kind] : 2;
		if (ka != kb) return ka < kb ? -1 : 1;
		if (a.TotalCount != b.TotalCount) return a.TotalCount > b.TotalCount ? -1 : 1;
		return a.Value <=> b.Value;
	});
	local potDesc = clone _ingList;
	potDesc.sort(function( a, b ) { return b.Potency <=> a.Potency; });
	return { sorted = sorted, potDesc = potDesc };
};

// Smart Auto-Fill (`智能抓药`): picks abundant/economical matching ingredients without wasting top-tier unique cores unless needed!
::Wuxia.Alchemy.autoPickIngredients <- function( _formulaID, _ingList = null, _preViews = null )
{
	local formula = ::Wuxia.Alchemy.findFormula(_formulaID);
	if (formula == null) return ["", "", ""];

	local list = _ingList != null ? _ingList : ::Wuxia.Alchemy.getUnifiedIngredients();
	local avail = {};
	foreach (e in list) avail[e.Key] <- e.TotalCount;

	local views = (_preViews != null) ? _preViews : ::Wuxia.Alchemy.buildAutoPickSortedViews(list);
	local sorted  = views.sorted;
	local potDesc = views.potDesc;

	local chosenJun = null;
	for (local i = 0; i < sorted.len(); i = ++i)
	{
		local cand = sorted[i];
		if (avail[cand.Key] > 0 && ::Wuxia.Alchemy.doesJunMatchFormula(cand, formula))
		{
			chosenJun = cand;
			break;
		}
	}
	if (chosenJun == null) return ["", "", ""];

	// Check if minimum-potency Jun can reach TargetPotency with best 2 auxiliaries; if not, upgrade Jun to stronger matching herb/core!
	for (local jIdx = 0; jIdx < sorted.len(); jIdx = ++jIdx)
	{
		local jCand = sorted[jIdx];
		if (!::Wuxia.Alchemy.doesJunMatchFormula(jCand, formula)) continue;

		local tempAvail = clone avail;
		tempAvail[jCand.Key] -= 1;
		local maxReach = jCand.Potency;
		local pickedAuxCnt = 0;
		for (local p = 0; p < potDesc.len() && pickedAuxCnt < 2; p = ++p)
		{
			local pe = potDesc[p];
			while (tempAvail[pe.Key] > 0 && pickedAuxCnt < 2)
			{
				maxReach += pe.Potency;
				tempAvail[pe.Key] -= 1;
				pickedAuxCnt += 1;
			}
		}
		if (pickedAuxCnt >= formula.MinAuxCount && maxReach >= formula.TargetPotency)
		{
			chosenJun = jCand;
			break;
		}
	}

	avail[chosenJun.Key] -= 1;
	local curPot = chosenJun.Potency;
	local auxSlots = ["", ""];
	local filledAux = 0;

	// Pick up to 2 auxiliaries to satisfy both MinAuxCount and TargetPotency
	for (local slotPos = 0; slotPos < 2; slotPos = ++slotPos)
	{
		local needMoreAux = (filledAux < formula.MinAuxCount);
		local remPot = formula.TargetPotency - curPot;
		if (!needMoreAux && remPot <= 0) break;

		local slotsLeftAfterThis = 1 - slotPos;
		local bestSingleAuxPot = 0;
		if (slotsLeftAfterThis > 0)
		{
			for (local m = 0; m < potDesc.len(); m = ++m)
			{
				if (avail[potDesc[m].Key] > 0) { bestSingleAuxPot = potDesc[m].Potency; break; }
			}
		}

		local minNeededThisSlot = ::Math.max(1, remPot - bestSingleAuxPot);
		local picked = null;
		for (local c = 0; c < sorted.len(); c = ++c)
		{
			local sc = sorted[c];
			if (avail[sc.Key] <= 0) continue;
			if (sc.Potency >= minNeededThisSlot)
			{
				picked = sc;
				break;
			}
		}
		if (picked == null)
		{
			// Fallback to highest potency available so player sees partial fill
			for (local fb = 0; fb < potDesc.len(); fb = ++fb)
			{
				if (avail[potDesc[fb].Key] > 0) { picked = potDesc[fb]; break; }
			}
		}
		if (picked != null)
		{
			auxSlots[slotPos] = picked.Key;
			avail[picked.Key] -= 1;
			curPot += picked.Potency;
			filledAux += 1;
		}
	}

	return [chosenJun.Key, auxSlots[0], auxSlots[1]];
};

// Build uniform UI showcase card for any crafted/brewed Wuxia pill item
::Wuxia.Alchemy.buildPillShowcaseCard <- function( _pillItem, _isBonus = false )
{
	if (_pillItem == null) return null;
	local gSpec = (::Wuxia.hasMember(_pillItem, "getGradeSpec")) ? _pillItem.getGradeSpec() : { Grade = 1, Title = "成丹", Color = "#d7b174" };
	local auxSp = (::Wuxia.hasMember(_pillItem, "getAuxSpec")) ? _pillItem.getAuxSpec() : null;
	local pot   = (::Wuxia.hasMember(_pillItem, "getPotencyPct")) ? _pillItem.getPotencyPct() : 100;
	local ico   = _pillItem.getIcon();
	if (ico != null && ico != "" && ico.find("ui/") != 0)
		ico = "ui/items/" + ico;
	local desc  = _pillItem.getDescription();
	return {
		isPill      = true,
		isBonus     = _isBonus,
		name        = _pillItem.getName(),
		icon        = ico,
		grade       = ("Grade" in gSpec) ? gSpec.Grade : 1,
		gradeTitle  = ("Title" in gSpec) ? gSpec.Title : "成丹",
		gradeColor  = ("Color" in gSpec) ? gSpec.Color : "#d7b174",
		potencyPct  = pot,
		auxTitle    = (auxSp != null && ("Title" in auxSp)) ? auxSp.Title : "",
		auxColor    = (auxSp != null && ("Color" in auxSp)) ? auxSp.Color : "#dda21f",
		description = desc != null ? desc : ""
	};
};

::Wuxia.Alchemy.collectSlotInputCards <- function( _slotKeys, _ingMap )
{
	local inputs = [];
	if (_slotKeys == null || _ingMap == null) return inputs;
	for (local i = 0; i < _slotKeys.len(); i = ++i)
	{
		local k = _slotKeys[i];
		if (k == null || k == "" || !(k in _ingMap)) continue;
		local e = _ingMap[k];
		local ico = e.Icon;
		if (ico != null && ico != "" && ico.find("ui/") != 0)
			ico = "ui/items/" + ico;
		inputs.push({
			name        = e.Name,
			icon        = ico,
			nature      = e.Nature,
			natureColor = ("NatureColor" in e) ? e.NatureColor : "#dda21f"
		});
	}
	return inputs;
};

// Execute Bagua Cauldron Brew! Supports 3 Fire Modes (`文火温养 / 中火守正 / 武火催霞`) & Fierce Tribulation (`丹劫暴烈奇毒散`)!
::Wuxia.Alchemy.executeBrew <- function( _formulaID, _slotKeys, _fireMode = "balanced" )
{
	if (!("World" in getroottable()) || ::World == null || !("Assets" in ::World) || ::World.Assets == null)
		return { Ok = false, Reason = "当前仅可在大地图行军、营帐或城镇中开炉炼丹。" };

	local stash = ::World.Assets.getStash();
	if (stash == null)
		return { Ok = false, Reason = "无法访问战团仓库。" };

	local useFire = (_fireMode != null && "FireModes" in ::Wuxia.Config.Alchemy && (_fireMode in ::Wuxia.Config.Alchemy.FireModes)) ? _fireMode : "balanced";
	local ingList = ::Wuxia.Alchemy.getUnifiedIngredients(stash);
	local ingMap = {};
	foreach (e in ingList) ingMap[e.Key] <- e;

	local preview = ::Wuxia.Alchemy.previewBrew(_formulaID, _slotKeys, ingMap, null, -1, useFire);
	if (!preview.Ok)
		return preview;

	local inputCards = ::Wuxia.Alchemy.collectSlotInputCards(_slotKeys, ingMap);
	local formula = ::Wuxia.Alchemy.findFormula(_formulaID);
	local freeSlots = stash.getNumberOfEmptySlots();
	local cabSim = {};
	local slotsFreed = 0;
	for (local si = 0; si < _slotKeys.len(); si = ++si)
	{
		local k = _slotKeys[si];
		if (k == null || k == "") continue;
		if (!(k in cabSim)) cabSim[k] <- ::Wuxia.Alchemy.Cabinet.getCount(k);
		if (cabSim[k] > 0) cabSim[k] -= 1;
		else slotsFreed += 1;
	}

	local maxOutputPills = (preview.DoubleChance > 0) ? (formula.BaseYield + 1) : formula.BaseYield;
	if (freeSlots + slotsFreed < maxOutputPills)
		return { Ok = false, Reason = "战团仓库空位不足（成丹及炉韵双丹至少需预留 " + maxOutputPills + " 格空位；可先将奇草内丹收入百草药柜腾位）。" };

	::World.Assets.addMoney(-preview.SilverCost);
	for (local ci = 0; ci < _slotKeys.len(); ci = ++ci)
	{
		local ck = _slotKeys[ci];
		if (ck != null && ck != "")
			::Wuxia.Alchemy.consumeOneIngredient(ck, stash);
	}

	// Check Fierce-Fire Tribulation (`武火催霞 · 丹劫走火` -> produces usable tactical `丹劫暴烈奇毒散`!)
	local tribPct = ("TribulationPct" in preview) ? preview.TribulationPct : 0;
	if (useFire == "fierce" && tribPct > 0 && ::Math.rand(1, 100) <= tribPct && !("WX_ForceNoTribulation" in ::Wuxia.Alchemy && ::Wuxia.Alchemy.WX_ForceNoTribulation))
	{
		local dj = ::new("scripts/items/misc/wx_tact_danjiesan");
		stash.add(dj);
		::Wuxia.Alchemy.recordWorkshopCraft();
		local djCard = ("Forge" in ::Wuxia && "buildItemShowcaseCard" in ::Wuxia.Forge) ? ::Wuxia.Forge.buildItemShowcaseCard(dj) : null;
		return {
			Ok                    = true,
			IsCrit                = false,
			IsTrialFallback       = true,
			IsTribulation         = true,
			FireMode              = useFire,
			PillID                = "wx_tact_danjiesan",
			PillName              = dj.getName(),
			BaseYield             = 1,
			SilverCost            = preview.SilverCost,
			DiscoveredFormulaID   = "",
			DiscoveredFormulaName = "",
			Inputs                = inputCards,
			Items                 = djCard != null ? [djCard] : [],
			Insight               = "【武火丹劫！】炉内药性燥烈激撞引动丹雷，未能成丸，却凝成一匣战中凶器「" + dj.getName() + "」（可装入腰包投掷蚀甲染毒）！",
			Message               = "【武火丹劫异变！】猛火激撞之下炉药凝为战中奇器「" + dj.getName() + "」×1（耗纹银 " + preview.SilverCost + " 两，可装入腰包投掷破阵）！"
		};
	}

	local roll = ::Math.rand(1, 100);
	local isCrit = (roll <= preview.DoubleChance);
	local createdSummaries = [];
	local createdCards = [];
	local gChances = ("GradeChances" in preview) ? preview.GradeChances : [60, 30, 10];
	local auxNat   = ("AuxNature" in preview) ? preview.AuxNature : "";
	local cImpID   = ("CoreImprintID" in preview) ? preview.CoreImprintID : "";
	local auxTag   = (("AuxTitle" in preview) && preview.AuxTitle != "") ? ("·" + preview.AuxTitle) : "";
	if (("CoreImprintTitle" in preview) && preview.CoreImprintTitle != "")
		auxTag += "·" + preview.CoreImprintTitle;

	local brewedHighGrade = false;
	for (local n = 0; n < formula.BaseYield; n = ++n)
	{
		local p = ::new("scripts/items/misc/wx_pill_item");
		local rVar = ::Wuxia.Alchemy.rollPillVariant(gChances, auxNat, useFire);
		if (rVar.Grade >= 2) brewedHighGrade = true;
		p.initPillVariant(formula.PillID, rVar.Grade, rVar.PotencyPct, rVar.AuxNature, cImpID);
		stash.add(p);
		createdSummaries.push("「" + p.getName() + "」（药效" + rVar.PotencyPct + "%" + auxTag + "）");
		createdCards.push(::Wuxia.Alchemy.buildPillShowcaseCard(p, false));
	}

	local bonusMsg = "";
	local bonusDelivered = false;
	if (isCrit && stash.getNumberOfEmptySlots() > 0)
	{
		local bonusPillID = ("BonusByproduct" in formula && formula.BonusByproduct != "")
			? formula.BonusByproduct
			: formula.PillID;
		local bp = ::new("scripts/items/misc/wx_pill_item");
		local bpVar = ::Wuxia.Alchemy.rollPillVariant(gChances, auxNat, useFire);
		if (bpVar.Grade >= 2) brewedHighGrade = true;
		bp.initPillVariant(bonusPillID, bpVar.Grade, bpVar.PotencyPct, bpVar.AuxNature, cImpID);
		stash.add(bp);
		bonusDelivered = true;
		createdCards.push(::Wuxia.Alchemy.buildPillShowcaseCard(bp, true));
		if (bonusPillID == formula.PillID)
			bonusMsg = " 炉生紫霞、丹韵双成，额外凝出 1 枚「" + bp.getName() + "」（药效" + bpVar.PotencyPct + "%）！";
		else
			bonusMsg = " 鼎内余韵凝丹，额外伴生 1 枚「" + bp.getName() + "」（药效" + bpVar.PotencyPct + "%）！";
	}

	if (brewedHighGrade && ::Wuxia.Alchemy.hasWorldFlags())
		::World.Flags.set("wx_brewed_high_pill", true);
	::Wuxia.Alchemy.recordWorkshopCraft();

	local outStr = createdSummaries[0];
	for (local ci2 = 1; ci2 < createdSummaries.len(); ci2 = ++ci2)
		outStr += "、" + createdSummaries[ci2];

	local newlyRecorded = ::Wuxia.Alchemy.discoverFormula(formula.ID);
	local discNote = newlyRecorded ? (" 【新录丹方】《" + preview.PillName + "》配伍法度已载入《丹经手札》！") : "";
	local firePrefix = ("FireTitle" in preview) ? ("【" + preview.FireTitle + "】") : "";

	return {
		Ok                    = true,
		IsCrit                = bonusDelivered,
		IsTrialFallback       = false,
		IsTribulation         = false,
		FireMode              = useFire,
		PillID                = formula.PillID,
		PillName              = preview.PillName,
		BaseYield             = formula.BaseYield,
		SilverCost            = preview.SilverCost,
		DiscoveredFormulaID   = newlyRecorded ? formula.ID : "",
		DiscoveredFormulaName = newlyRecorded ? preview.PillName : "",
		Inputs                = inputCards,
		Items                 = createdCards,
		Insight               = "",
		Message               = firePrefix + "开炉功成！炼得 " + outStr + "（耗纹银 " + preview.SilverCost + " 两）！" + bonusMsg + discNote
	};
};

// Match `[junKey, aux1Key, aux2Key]` against all 50 Bagua Cauldron Formulas (preferring undiscovered formulas & PreferredAuxNatures!)
::Wuxia.Alchemy.matchBestFormulaForFreeBrew <- function( _slotKeys, _ingMap = null, _legacyAux2Nat = null, _legacyTotalPot = 0 )
{
	local jun = null;
	local auxCount = 0;
	local totalPot = 0;
	local auxNatures = [];

	if (typeof _slotKeys == "string")
	{
		// Support direct nature-probe signature `(junNature, aux1Nature, aux2Nature, totalPot)` used by selftest
		local pPot = (_legacyTotalPot > 0) ? _legacyTotalPot : 6;
		jun = { Nature = _slotKeys, Potency = ::Math.max(2, pPot / 2), IsRare = true };
		if (typeof _ingMap == "string" && _ingMap != "") { auxCount += 1; auxNatures.push(_ingMap); }
		if (typeof _legacyAux2Nat == "string" && _legacyAux2Nat != "") { auxCount += 1; auxNatures.push(_legacyAux2Nat); }
		totalPot = pPot;
	}
	else
	{
		if (_slotKeys == null || _slotKeys.len() == 0 || _slotKeys[0] == null || _slotKeys[0] == "" || _ingMap == null || !(_slotKeys[0] in _ingMap))
			return null;

		jun = _ingMap[_slotKeys[0]];
		totalPot = jun.Potency;
		for (local si = 1; si < _slotKeys.len() && si <= 2; si = ++si)
		{
			local ak = _slotKeys[si];
			if (ak == null || ak == "" || !(ak in _ingMap)) continue;
			auxCount += 1;
			totalPot += _ingMap[ak].Potency;
			auxNatures.push(_ingMap[ak].Nature);
		}
	}
	if (auxCount < 1) return null;

	local bestF = null;
	local bestScore = -1;
	foreach (f in ::Wuxia.Config.Alchemy.Formulas)
	{
		if (("IsHiddenMutation" in f) && f.IsHiddenMutation) continue;
		if (!::Wuxia.Alchemy.doesJunMatchFormula(jun, f)) continue;
		if (auxCount < f.MinAuxCount || totalPot < f.TargetPotency) continue;

		local isUndisc = !::Wuxia.Alchemy.isFormulaDiscovered(f.ID);
		local sigBonus = (("RequiredCoreKey" in f) && f.RequiredCoreKey != "" && ("Key" in jun) && jun.Key == f.RequiredCoreKey) ? 50000 : 0;
		local score = (isUndisc ? 100000 : 0) + sigBonus + f.TargetPotency * 200 + f.MinJunPotency * 40 + (f.RequireRareJun ? 25 : 0);
		if (f.JunNatures.len() > 0 && f.JunNatures[0] == jun.Nature)
			score += 30;
		foreach (an in auxNatures)
		{
			if ("PreferredAuxNatures" in f)
			{
				foreach (pn in f.PreferredAuxNatures)
				{
					if (an == pn) { score += 45; break; }
				}
			}
			foreach (jn in f.JunNatures)
			{
				if (an == jn) { score += 12; break; }
			}
		}
		if (score > bestScore)
		{
			bestScore = score;
			bestF = f;
		}
	}
	return bestF;
};

// Free-Exploration Brew (`自由投药 · 盲投试丹`):
// - If `[jun, aux1, aux2]` matches a true formula -> brews that pill AND permanently records the formula in《丹经手札》!
// - If no exact formula matches -> refines a basic nature-aligned remedy pill (never destroys rare materials empty-handed) + gives Wuxia Cauldron Insight!
::Wuxia.Alchemy.executeFreeBrew <- function( _slotKeys, _fireMode = "balanced" )
{
	if (!("World" in getroottable()) || ::World == null || !("Assets" in ::World) || ::World.Assets == null)
		return { Ok = false, Reason = "当前仅可在大地图行军、营帐或城镇中开炉试丹。" };

	local stash = ::World.Assets.getStash();
	if (stash == null)
		return { Ok = false, Reason = "无法访问战团仓库。" };

	if (_slotKeys == null || _slotKeys.len() == 0 || _slotKeys[0] == null || _slotKeys[0] == "")
		return { Ok = false, Reason = "请先在【君药主引】鼎位投入 1 味主药。" };

	local useFire = (_fireMode != null && "FireModes" in ::Wuxia.Config.Alchemy && (_fireMode in ::Wuxia.Config.Alchemy.FireModes)) ? _fireMode : "balanced";
	local ingList = ::Wuxia.Alchemy.getUnifiedIngredients(stash);
	local ingMap = {};
	foreach (e in ingList) ingMap[e.Key] <- e;

	local junKey = _slotKeys[0];
	if (!(junKey in ingMap))
		return { Ok = false, Reason = "所选君药存量不足。" };

	local jun = ingMap[junKey];
	local usedCounts = {};
	usedCounts[junKey] <- 1;
	local auxCount = 0;
	local auxMetas = [];
	local totalPot = jun.Potency;

	for (local si = 1; si < _slotKeys.len() && si <= 2; si = ++si)
	{
		local ak = _slotKeys[si];
		if (ak == null || ak == "") continue;
		if (!(ak in ingMap))
			return { Ok = false, Reason = "所选臣佐辅药存量不足。" };
		usedCounts[ak] <- ((ak in usedCounts) ? usedCounts[ak] : 0) + 1;
		if (usedCounts[ak] > ingMap[ak].TotalCount)
			return { Ok = false, Reason = "「" + ingMap[ak].Name + "」存量不足以同炉重复投入。" };
		auxCount += 1;
		auxMetas.push(ingMap[ak]);
		totalPot += ingMap[ak].Potency;
	}
	if (usedCounts[junKey] > jun.TotalCount)
		return { Ok = false, Reason = "「" + jun.Name + "」存量不足。" };
	if (auxCount < 1)
		return { Ok = false, Reason = "开炉试丹除君药外，至少须配入 1 味【臣佐辅药】调和鼎火。" };

	local syn = ::Wuxia.Alchemy.evaluateSixMeridianSynergy(jun, auxMetas, useFire, 0);
	totalPot += syn.PotencyBonus;

	// Priority 0: Hidden Yin-Yang Reverse-Fate Mutation (`阴阳逆命奇丹`)!
	if (syn.MutationFormulaID != "")
	{
		local prevMut = ::Wuxia.Alchemy.WX_ForceNoTribulation <- true;
		local mutRes = null;
		try { mutRes = ::Wuxia.Alchemy.executeBrew(syn.MutationFormulaID, _slotKeys, useFire); }
		catch (mErr) { delete ::Wuxia.Alchemy.WX_ForceNoTribulation; throw mErr; }
		delete ::Wuxia.Alchemy.WX_ForceNoTribulation;
		if (mutRes != null && mutRes.Ok)
		{
			mutRes.Message = "【阴阳逆命 · 奇丹降世！】大妖内丹镇压水火相克、武火九转合道——竟逆炼出绝世奇丹「" + mutRes.PillName + "」并载入《丹经手札》！";
			return mutRes;
		}
	}

	// Check if an exact formula matches (including Boss Neidan signature formulas like `f_zhuyin_lunzhuan`!)
	local matched = ::Wuxia.Alchemy.matchBestFormulaForFreeBrew(_slotKeys, ingMap);
	if (matched != null)
	{
		local wasUndiscovered = !::Wuxia.Alchemy.isFormulaDiscovered(matched.ID);
		local res = ::Wuxia.Alchemy.executeBrew(matched.ID, _slotKeys, useFire);
		if (res.Ok && wasUndiscovered && !("IsTribulation" in res && res.IsTribulation))
		{
			res.DiscoveredFormulaID <- matched.ID;
			res.DiscoveredFormulaName <- res.PillName;
			res.Message = "【新悟丹方！】炉生瑞霭，你自君臣药变间悟透《" + res.PillName + "》秘传古方并永久载入《丹经手札》——" + res.Message;
		}
		return res;
	}

	// No exact formula matched -> produce 1 basic nature remedy + Cauldron Insight hint!
	local inputCards = ::Wuxia.Alchemy.collectSlotInputCards(_slotKeys, ingMap);
	local mastery = ::Wuxia.Alchemy.getAlchemistMastery();
	local trialCost = ::Math.max(80, ::Math.floor((90 + totalPot * 28) * mastery.CostMult));
	if (::World.Assets.getMoney() < trialCost)
		return { Ok = false, Reason = "试炉炭火纹银不足（需 " + trialCost + " 两）。" };

	local cabSim = {};
	local slotsFreed = 0;
	for (local kIdx = 0; kIdx < _slotKeys.len(); kIdx = ++kIdx)
	{
		local kk = _slotKeys[kIdx];
		if (kk == null || kk == "") continue;
		if (!(kk in cabSim)) cabSim[kk] <- ::Wuxia.Alchemy.Cabinet.getCount(kk);
		if (cabSim[kk] > 0) cabSim[kk] -= 1;
		else slotsFreed += 1;
	}
	if (stash.getNumberOfEmptySlots() + slotsFreed < 1)
		return { Ok = false, Reason = "战团仓库空位不足（至少需留 1 格空位盛放试炼药散）。" };

	::World.Assets.addMoney(-trialCost);
	for (local ci = 0; ci < _slotKeys.len(); ci = ++ci)
	{
		local ck = _slotKeys[ci];
		if (ck != null && ck != "")
			::Wuxia.Alchemy.consumeOneIngredient(ck, stash);
	}

	local fallbackPillID = "wx_pill_huoluo";
	if (jun.Nature == "yin" || jun.Nature == "venom") fallbackPillID = "wx_pill_qingxin";
	else if (jun.Nature == "spirit") fallbackPillID = "wx_pill_huxin";
	else if (jun.Nature == "yang") fallbackPillID = "wx_pill_longhu";

	local auxNat = ::Wuxia.Alchemy.resolveDominantAuxNature(_slotKeys, ingMap);
	local fbCoreID = (jun.Kind == "core") ? (jun.SubID != "" ? jun.SubID : jun.Key.slice(5)) : "";
	local p = ::new("scripts/items/misc/wx_pill_item");
	p.initPillVariant(fallbackPillID, 1, 96, auxNat, fbCoreID);
	stash.add(p);
	::Wuxia.Alchemy.recordWorkshopCraft();

	// Find closest undiscovered formula for `jun.Nature` to provide non-spoiler Wuxia alchemy insight
	local nearF = null;
	local bestDist = 9999;
	foreach (candF in ::Wuxia.Config.Alchemy.Formulas)
	{
		if (::Wuxia.Alchemy.isFormulaDiscovered(candF.ID)) continue;
		local sharesNat = false;
		foreach (jn in candF.JunNatures)
		{
			if (jn == jun.Nature) { sharesNat = true; break; }
		}
		if (!sharesNat) continue;
		local dist = ::Math.abs(candF.TargetPotency - totalPot) + (candF.RequireRareJun && !jun.IsRare ? 4 : 0);
		if (dist < bestDist) { bestDist = dist; nearF = candF; }
	}

	local insight = "【丹火感悟】此路药性配伍尚差契机，可尝试换用不同药性奇草或大妖内丹为主引推演新方。";
	if (nearF != null)
	{
		if (nearF.RequireRareJun && !jun.IsRare)
			insight = "【丹火感悟】寻常兽材难以承载高阶药变——若换用同属【" + jun.NatureName + "】的天下奇草或山海内丹为君药，必有奇丹凝成！";
		else if (jun.Potency < nearF.MinJunPotency)
			insight = "【丹火感悟】当前君药药力尚浅（药力 " + jun.Potency + "），须择药力 ≥" + nearF.MinJunPotency + " 之【" + jun.NatureName + "】主药方可引动丹变！";
		else if (auxCount < nearF.MinAuxCount)
			insight = "【丹火感悟】此味【" + jun.NatureName + "】君药灵韵充沛，唯独辅火单薄——若配满 " + nearF.MinAuxCount + " 味臣佐辅药调和，定可成方！";
		else if (totalPot < nearF.TargetPotency)
			insight = "【丹火感悟】炉中异香初凝而未聚（当前总药力 " + totalPot + "）——若添入更高品阶辅药将总药力推至 " + nearF.TargetPotency + " 点以上，必悟新丹！";
	}

	return {
		Ok                    = true,
		IsCrit                = false,
		IsTrialFallback       = true,
		PillID                = fallbackPillID,
		PillName              = p.getName(),
		BaseYield             = 1,
		SilverCost            = trialCost,
		DiscoveredFormulaID   = "",
		DiscoveredFormulaName = "",
		Inputs                = inputCards,
		Items                 = [::Wuxia.Alchemy.buildPillShowcaseCard(p, false)],
		Insight               = insight,
		Message               = "试炉成散：凝得「" + p.getName() + "」×1（耗纹银 " + trialCost + " 两）。" + insight
	};
};

// -----------------------------------------------------------------------------
// 4. Advanced Marrow Wash (`太乙紫金洗髓丹` & `易筋锻骨丸`) + `忘尘归元散` Slot Grace Hooks
// -----------------------------------------------------------------------------
::Wuxia.Alchemy.getWashPillCounts <- function( _stash = null )
{
	local stashRef = _stash;
	if (stashRef == null && ("World" in getroottable()) && ::World != null && ("Assets" in ::World) && ::World.Assets != null)
		stashRef = ::World.Assets.getStash();

	local res = {
		wx_pill_xisui       = 0,
		wx_pill_zijin_xisui = 0,
		wx_pill_yijin_wan   = 0,
		wx_pill_humai       = 0,
		wx_pill_zaohua      = 0,
		totalMainWash       = 0,
		totalProtect        = 0
	};
	if (stashRef == null) return res;

	foreach (it in stashRef.getItems())
	{
		if (it == null || it.getID() != "misc.wx_pill_item") continue;
		local pid = it.getPillID();
		if (pid in res) res[pid] += 1;
	}
	res.totalMainWash = res.wx_pill_xisui + res.wx_pill_zijin_xisui + res.wx_pill_yijin_wan;
	res.totalProtect  = res.wx_pill_humai + res.wx_pill_zaohua;
	return res;
};

// Find the HIGHEST-GRADE (`丹霞 > 灵纹 > 成丹`) matching pill in Stash so Marrow Wash always uses the player's best refined pill!
::Wuxia.Alchemy.findPillIndexByID <- function( _stash, _pillID )
{
	if (_stash == null) return -1;
	local items = _stash.getItems();
	local bestIdx = -1;
	local bestScore = -1;
	for (local i = 0; i < items.len(); i = ++i)
	{
		local it = items[i];
		if (it != null && it.getID() == "misc.wx_pill_item" && it.getPillID() == _pillID)
		{
			local g = (::Wuxia.hasMember(it, "getPillGrade")) ? it.getPillGrade() : 1;
			local pct = (::Wuxia.hasMember(it, "getPotencyPct")) ? it.getPotencyPct() : 100;
			local score = g * 1000 + pct;
			if (score > bestScore)
			{
				bestScore = score;
				bestIdx = i;
			}
		}
	}
	return bestIdx;
};

::Wuxia.Alchemy.getWashPreviewEx <- function( _actor, _targetAttrIdx, _replaceAttrIdx = -1, _useProtectPill = false, _washPillID = "wx_pill_xisui" )
{
	local pv = ::Wuxia.MarrowWash.getPreview(_actor, _targetAttrIdx, _replaceAttrIdx, _useProtectPill);
	if (!pv.Ok) return pv;

	local stash = ::Wuxia.getCampaignStash();
	local pillBonus = 0;
	local maxCap = 85;
	local avoidHeavyShock = false;
	local pillName = "洗髓丹";

	if (_washPillID == "wx_pill_zijin_xisui")
	{
		pillBonus = 12;
		maxCap = 90;
		avoidHeavyShock = true;
		pillName = "太乙紫金洗髓丹";
		if (pv.PermInjuryRisk > 0)
			pv.PermInjuryRisk = ::Math.max(0, pv.PermInjuryRisk / 2);
	}
	else if (_washPillID == "wx_pill_yijin_wan")
	{
		pillBonus = (pv.CurrentStar == 0) ? 20 : 3;
		maxCap = 90;
		pillName = "易筋锻骨丸";
	}
	else if (_washPillID == "pending")
	{
		pillName = "孤本功成洗髓契机";
	}

	// Factor in refined Pill Grade (`灵纹 +4%` / `丹霞 +8%` on Wash Pill; `灵纹 +2%` / `丹霞 +5%` + shock mitigation on Protect Pill)!
	if (_washPillID != "pending" && stash != null)
	{
		local wIdx = ::Wuxia.Alchemy.findPillIndexByID(stash, _washPillID);
		if (wIdx >= 0)
		{
			local wItem = stash.getItems()[wIdx];
			pillName = wItem.getName();
			local wGradeBonus = (::Wuxia.hasMember(wItem, "getWashGradeBonus")) ? wItem.getWashGradeBonus() : 0;
			if (wGradeBonus > 0)
			{
				pillBonus += wGradeBonus;
				maxCap = ::Math.max(maxCap, 93);
			}
		}
	}
	if (_useProtectPill && stash != null)
	{
		local pIdx = ::Wuxia.Alchemy.findPillIndexByID(stash, "wx_pill_zaohua");
		if (pIdx < 0) pIdx = ::Wuxia.Alchemy.findPillIndexByID(stash, "wx_pill_humai");
		if (pIdx >= 0)
		{
			local pItem = stash.getItems()[pIdx];
			local pGradeBonus = (::Wuxia.hasMember(pItem, "getProtectGradeBonus")) ? pItem.getProtectGradeBonus() : 0;
			if (pGradeBonus > 0)
			{
				pillBonus += pGradeBonus;
				maxCap = ::Math.max(maxCap, 92);
			}
			if ((::Wuxia.hasMember(pItem, "getPillGrade")) && pItem.getPillGrade() >= 3)
				avoidHeavyShock = true;
		}
	}

	local hasSurgeon = ("World" in getroottable() && ::World != null && ("Retinue" in ::World) && ::World.Retinue != null && ::World.Retinue.hasFollower("follower.surgeon"));
	local avoidZeroShock = (("AvoidShock" in pv) && pv.AvoidShock);
	pv.PillBonus       <- pillBonus;
	pv.WashPillID      <- _washPillID;
	pv.WashPillName    <- pillName;
	pv.AvoidHeavyShock <- (avoidHeavyShock || avoidZeroShock);
	pv.AvoidAllShock   <- avoidZeroShock;
	pv.LightShockDays  <- hasSurgeon ? 1 : 2;
	pv.FinalChance     = ::Math.min(maxCap, pv.BaseChance + pv.PrepBonus + pillBonus);
	return pv;
};

::Wuxia.Alchemy.executeWashEx <- function( _actor, _targetAttrIdx, _replaceAttrIdx = -1, _useProtectPill = false, _usePendingChance = false, _washPillID = "wx_pill_xisui" )
{
	local effectivePill = _usePendingChance ? "pending" : _washPillID;
	local preview = ::Wuxia.Alchemy.getWashPreviewEx(_actor, _targetAttrIdx, _replaceAttrIdx, _useProtectPill, effectivePill);
	if (!preview.Ok) return preview;

	local c = ::Wuxia.Slots.getContainer(_actor);
	if (_usePendingChance)
	{
		if (c == null || c.m.PendingWashChances <= 0)
			return { Ok = false, Reason = "当前无可用功成洗髓契机。" };
		c.m.PendingWashChances -= 1;
	}
	if (c != null)
		c.m.MarrowWashCount += 1;

	local roll = ::Math.rand(1, 100);
	local succeeded = (roll <= preview.FinalChance);

	if (succeeded)
	{
		if (preview.IsReplaceMode && preview.ReplaceAttrIdx >= 0)
		{
			_actor.m.Talents[preview.ReplaceAttrIdx] = 0;
			::Wuxia.MarrowWash.refreshFutureRolls(_actor, preview.ReplaceAttrIdx);
		}
		_actor.m.Talents[_targetAttrIdx] = preview.NextStar;
		::Wuxia.MarrowWash.refreshFutureRolls(_actor, _targetAttrIdx);
		if (::Wuxia.Alchemy.hasWorldFlags())
			::World.Flags.set("wx_marrow_wash_success", true);

		return {
			Ok                 = true,
			Succeeded          = true,
			Roll               = roll,
			Chance             = preview.FinalChance,
			WashPillID         = effectivePill,
			WashPillName       = preview.WashPillName,
			TargetAttrIdx      = _targetAttrIdx,
			TargetAttrName     = preview.TargetAttrName,
			OldStars           = preview.CurrentStar,
			NextStar           = preview.NextStar,
			IsReplaceMode      = preview.IsReplaceMode,
			ReplaceAttrName    = ("ReplaceAttrName" in preview) ? preview.ReplaceAttrName : "",
			AvoidAllShock      = false,
			AvoidHeavyShock    = false,
			GotPermanentInjury = false,
			Message            = "洗经伐髓功成（服「" + preview.WashPillName + "」）！「" + preview.TargetAttrName + "」根骨跃升至 " + preview.NextStar + "★！"
		};
	}

	if (("AvoidAllShock" in preview) && preview.AvoidAllShock)
	{
		return {
			Ok                 = true,
			Succeeded          = false,
			Roll               = roll,
			Chance             = preview.FinalChance,
			WashPillID         = effectivePill,
			WashPillName       = preview.WashPillName,
			TargetAttrIdx      = _targetAttrIdx,
			TargetAttrName     = preview.TargetAttrName,
			OldStars           = preview.CurrentStar,
			NextStar           = preview.NextStar,
			IsReplaceMode      = preview.IsReplaceMode,
			ReplaceAttrName    = ("ReplaceAttrName" in preview) ? preview.ReplaceAttrName : "",
			AvoidAllShock      = true,
			AvoidHeavyShock    = true,
			GotPermanentInjury = false,
			Message            = "洗髓未果，幸得【山海造化护脉金丹】护持心脉，全身奇经八脉毫发无伤！"
		};
	}

	local skills = _actor.getSkills();
	local inj = skills.getSkillByID("effects.wx_internal_injury");
	if (inj == null)
	{
		inj = ::new("scripts/skills/effects/wx_internal_injury");
		skills.add(inj);
	}
	if (preview.AvoidHeavyShock)
		inj.applySeverity(1, 2);
	else
		inj.applySeverity(2, ::Wuxia.Config.MarrowWash.ShockDurationDays);

	local gotPerm = false;
	if (preview.PermInjuryRisk > 0 && ::Math.rand(1, 100) <= preview.PermInjuryRisk)
	{
		gotPerm = true;
		inj.addPermanentMeridianScar();
	}
	skills.update();

	return {
		Ok                 = true,
		Succeeded          = false,
		Roll               = roll,
		Chance             = preview.FinalChance,
		WashPillID         = effectivePill,
		WashPillName       = preview.WashPillName,
		TargetAttrIdx      = _targetAttrIdx,
		TargetAttrName     = preview.TargetAttrName,
		OldStars           = preview.CurrentStar,
		NextStar           = preview.NextStar,
		IsReplaceMode      = preview.IsReplaceMode,
		ReplaceAttrName    = ("ReplaceAttrName" in preview) ? preview.ReplaceAttrName : "",
		AvoidAllShock      = false,
		AvoidHeavyShock    = preview.AvoidHeavyShock,
		GotPermanentInjury = gotPerm,
		Message            = gotPerm
			? "洗经伐髓未成！真气逆冲留下永久「经脉暗疾」（可用生生造化丹拔除）！"
			: (preview.AvoidHeavyShock
				? ("洗经伐髓未成，幸得「" + preview.WashPillName + "」护住心脉，免去重度震荡，仅余 " + inj.m.DaysRemaining + " 日轻度调息。")
				: "洗经伐髓失败！真气逆冲引发「经脉震荡」，需以护心丹或名医调养。")
	};
};

// Non-destructively wrap Slot Manager so `忘尘归元散` (`effects.wx_wangchen_grace`) waives PenaltyDays cleanly!
{
	local origPreviewSwitch = ::Wuxia.Slots.previewManualSwitch;
	::Wuxia.Slots.previewManualSwitch = function( _actor, _slotIndex, _manualID, _isFragment )
	{
		local res = origPreviewSwitch(_actor, _slotIndex, _manualID, _isFragment);
		if (res.Ok && res.PenaltyDays > 0 && _actor != null && _actor.getSkills() != null && _actor.getSkills().hasSkill("effects.wx_wangchen_grace"))
		{
			res.PenaltyDays = 0;
			res.WaivedByWangchen <- true;
		}
		return res;
	};

	local origCanUnequip = ::Wuxia.Slots.canUnequipSlot;
	::Wuxia.Slots.canUnequipSlot = function( _actor, _slotIndex )
	{
		local res = origCanUnequip(_actor, _slotIndex);
		if (res.Ok && res.PenaltyDays > 0 && _actor != null && _actor.getSkills() != null && _actor.getSkills().hasSkill("effects.wx_wangchen_grace"))
		{
			res.PenaltyDays = 0;
			res.WaivedByWangchen <- true;
		}
		return res;
	};

	local origEquipLearned = ::Wuxia.Slots.equipLearnedManual;
	::Wuxia.Slots.equipLearnedManual = function( _actor, _slotIndex, _manualID )
	{
		local hadGrace = (_actor != null && _actor.getSkills() != null && _actor.getSkills().hasSkill("effects.wx_wangchen_grace"));
		local slotHadOld = false;
		if (hadGrace)
		{
			local c = ::Wuxia.Slots.getContainer(_actor);
			if (c != null && _slotIndex >= 0 && _slotIndex < c.m.Slots.len() && c.m.Slots[_slotIndex].ManualID != null && c.m.Slots[_slotIndex].Tier > 0)
				slotHadOld = true;
		}
		local res = origEquipLearned(_actor, _slotIndex, _manualID);
		if (res.Ok && hadGrace && slotHadOld && _actor.getSkills().hasSkill("effects.wx_wangchen_grace"))
		{
			_actor.getSkills().removeByID("effects.wx_wangchen_grace");
			_actor.getSkills().update();
			res.UsedWangchen <- true;
		}
		return res;
	};

	local origUnequipSlot = ::Wuxia.Slots.unequipSlot;
	::Wuxia.Slots.unequipSlot = function( _actor, _slotIndex )
	{
		local hadGrace = (_actor != null && _actor.getSkills() != null && _actor.getSkills().hasSkill("effects.wx_wangchen_grace"));
		local res = origUnequipSlot(_actor, _slotIndex);
		if (res.Ok && hadGrace && _actor.getSkills().hasSkill("effects.wx_wangchen_grace"))
		{
			_actor.getSkills().removeByID("effects.wx_wangchen_grace");
			_actor.getSkills().update();
			res.UsedWangchen <- true;
		}
		return res;
	};

	local origApplyScatter = ::Wuxia.Slots.applyScatterPenalty;
	::Wuxia.Slots.applyScatterPenalty = function( _actor, _days, _withLightInternalInjury )
	{
		if (_actor != null && _days > 0 && _actor.getSkills() != null && _actor.getSkills().hasSkill("effects.wx_wangchen_grace"))
		{
			_actor.getSkills().removeByID("effects.wx_wangchen_grace");
			_actor.getSkills().update();
			return;
		}
		origApplyScatter(_actor, _days, _withLightInternalInjury);
	};
}


::Wuxia.Alchemy.canAcceptBattlePill <- function( _actor, _kindOrPure = false )
{
	if (_actor == null || !::Wuxia.hasMember(_actor, "getSkills") || _actor.getSkills() == null)
		return { Ok = false, WillOverdose = false, WillTriggerToxin = false, Reason = "无法读取侠客经脉状态。" };
	local sk = _actor.getSkills();
	local buff = sk.getSkillByID("effects.wx_pill_battle_buff");
	if (buff == null)
		return { Ok = true, WillOverdose = false, WillTriggerToxin = false };
	if (typeof _kindOrPure == "string" && _kindOrPure != "" && ::Wuxia.hasMember(buff, "hasBuffKind") && buff.hasBuffKind(_kindOrPure))
		return { Ok = false, WillOverdose = false, WillTriggerToxin = false, Reason = "体内已有同类备战药力。" };
	local cur = ::Wuxia.hasMember(buff, "countActiveBuffs") ? buff.countActiveBuffs() : (("Count" in buff.m) ? buff.m.Count : 0);
	if (cur >= 3)
		return { Ok = false, WillOverdose = false, WillTriggerToxin = false, Reason = "体内已有 3 道备战药力上限。" };
	local isPure = (typeof _kindOrPure == "bool") ? _kindOrPure : false;
	local hasBaidu = sk.hasSkill("trait.wx_baidu") || ("Traits" in ::Wuxia && ::Wuxia.Traits.hasBaiduToxinImmunity(_actor));
	local overdose = (cur == 2 && !hasBaidu && !isPure);
	return { Ok = true, WillOverdose = overdose, WillTriggerToxin = overdose };
};
