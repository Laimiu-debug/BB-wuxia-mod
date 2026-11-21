// Core Alchemy & Zero-Slot Herb/Core Cabinet System (百草药柜 · 八卦丹炉 · 高阶洗髓与归元护脉)
// - Universal Ingredient Classifier: automatically recognizes built-in herbs, all 48+ ShanHai Neidan cores,
//   22 ShanHai beast trophies, AND any newly added exotic herbs/cores (`wx_herb_*`, `Herbs`, `ExoticHerbs`, etc.)!
// - Zero-Stash-Slot Cabinet (`::Wuxia.Alchemy.Cabinet`): persisted in `::World.Flags`, 0 Stash slot cost, exact withdrawal.
// - Bagua Cauldron (`::Wuxia.Alchemy.Cauldron`): 16 Jun-Chen-Zuo-Shi formulas, Smart Auto-Fill, Alchemist Mastery & Double-Pill Resonance.

if (!("Alchemy" in ::Wuxia))
	::Wuxia.Alchemy <- {};

::Wuxia.Alchemy.Fallback <- {
	AutoStore      = true,
	AutoTrophy     = false,
	Keys           = {},
	Counts         = {},
	Meta           = {}
};

::Wuxia.Alchemy.resetFallback <- function()
{
	::Wuxia.Alchemy.Fallback.AutoStore  = true;
	::Wuxia.Alchemy.Fallback.AutoTrophy = false;
	::Wuxia.Alchemy.Fallback.Keys       = {};
	::Wuxia.Alchemy.Fallback.Counts     = {};
	::Wuxia.Alchemy.Fallback.Meta       = {};
};

::Wuxia.Alchemy.hasWorldFlags <- function()
{
	return ("World" in getroottable()) && ::World != null && ("Flags" in ::World) && ::World.Flags != null;
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

	// Never treat manuals, pages, or finished pills as raw cauldron herbs/trophies
	if (id == "misc.wx_manual_item" || id == "misc.wx_page_item" || id == "misc.wx_pill_item")
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
			IsRare      = true,
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
		if (!_includeWithdrawn && ("WX_WithdrawnForSale" in it.m) && it.m.WX_WithdrawnForSale)
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
		item.m.WX_WithdrawnForSale <- true;
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
		local probe = ::Wuxia.Alchemy.instantiateByCabinetKey(key, saved.Script, saved.SubID);
		if (probe == null) continue;
		local meta2 = ::Wuxia.Alchemy.classifyItem(probe);
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

::Wuxia.Alchemy.getCabinetSummaryCounts <- function( _stash = null )
{
	local list = ::Wuxia.Alchemy.getUnifiedIngredients(_stash);
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
		BonusDoublePct = ::Math.min(35, bonusDoublePct),
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
	if (_ingMeta.Potency < _formula.MinJunPotency) return false;
	if (_formula.RequireRareJun && !_ingMeta.IsRare) return false;

	local natOk = false;
	foreach (n in _formula.JunNatures)
	{
		if (n == _ingMeta.Nature) { natOk = true; break; }
	}
	return natOk;
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

// Compute Pill Quality Grade probabilities `[成丹%, 灵纹%, 丹霞极品%]` from surplus potency, harmony & alchemist mastery
::Wuxia.Alchemy.calcPillGradeChances <- function( _surplus, _harmonyBonus, _masteryBonusPct )
{
	local sur = ::Math.max(0, _surplus);
	local g3 = ::Math.min(42, 8 + sur * 4 + ::Math.floor((_harmonyBonus + _masteryBonusPct) * 0.40));
	local g2 = ::Math.min(48, 30 + sur * 5 + ::Math.floor((_harmonyBonus + _masteryBonusPct) * 0.35));
	if (g2 + g3 > 90) g2 = 90 - g3;
	local g1 = ::Math.max(10, 100 - g2 - g3);
	return [g1, g2, g3];
};

::Wuxia.Alchemy.rollPillVariant <- function( _gradeChances, _auxNature = "" )
{
	local ch = (_gradeChances != null && _gradeChances.len() >= 3) ? _gradeChances : [60, 30, 10];
	local r = ::Math.rand(1, 100);
	local grade = 1;
	if (r > ch[0] + ch[1]) grade = 3;
	else if (r > ch[0]) grade = 2;

	local gSpec = ("PillGrades" in ::Wuxia.Config.Alchemy && (grade in ::Wuxia.Config.Alchemy.PillGrades))
		? ::Wuxia.Config.Alchemy.PillGrades[grade]
		: { MinPct = 95, MaxPct = 105 };
	local pct = ::Math.rand(gSpec.MinPct, gSpec.MaxPct);
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

// Preview a Cauldron brew given selected ingredient keys `[junKey, aux1Key, aux2Key]`
::Wuxia.Alchemy.previewBrew <- function( _formulaID, _slotKeys, _ingMap = null )
{
	local formula = ::Wuxia.Alchemy.findFormula(_formulaID);
	if (formula == null)
		return { Ok = false, Reason = "未知的丹炉古方。" };

	local map = _ingMap;
	if (map == null)
	{
		map = {};
		foreach (e in ::Wuxia.Alchemy.getUnifiedIngredients())
			map[e.Key] <- e;
	}

	local mastery = ::Wuxia.Alchemy.getAlchemistMastery();
	local silverCost = ::Math.max(50, ::Math.floor(formula.SilverCost * mastery.CostMult));
	local pdef = ::Wuxia.Config.Pills[formula.PillID];

	if (_slotKeys == null || _slotKeys.len() == 0 || _slotKeys[0] == null || _slotKeys[0] == "")
	{
		return {
			Ok             = false,
			Reason         = "请先在【君药鼎位】放入符合药性的主药（或点击「智能抓药」）。",
			SilverCost     = silverCost,
			TargetPotency  = formula.TargetPotency,
			CurrentPotency = 0,
			MasterLabel    = mastery.MasterLabel
		};
	}

	local junKey = _slotKeys[0];
	if (!(junKey in map))
		return { Ok = false, Reason = "所选君药存量不足。", SilverCost = silverCost };

	local jun = map[junKey];
	if (!::Wuxia.Alchemy.doesJunMatchFormula(jun, formula))
		return { Ok = false, Reason = "「" + jun.Name + "」不符合本方君药药性或药力品阶要求。", SilverCost = silverCost };

	// Count total usage per key across [jun, aux1, aux2] to verify stock
	local usedCounts = {};
	usedCounts[junKey] <- 1;

	local auxCount = 0;
	local totalPotency = jun.Potency;
	local harmonyBonus = 0;

	for (local si = 1; si < _slotKeys.len() && si <= 2; si = ++si)
	{
		local ak = _slotKeys[si];
		if (ak == null || ak == "") continue;
		if (!(ak in map))
			return { Ok = false, Reason = "所选臣佐辅材存量不足。", SilverCost = silverCost };
		usedCounts[ak] <- ((ak in usedCounts) ? usedCounts[ak] : 0) + 1;
		if (usedCounts[ak] > map[ak].TotalCount)
			return { Ok = false, Reason = "「" + map[ak].Name + "」持有数量不足（同一炉重复占用超出存量）。", SilverCost = silverCost };

		local aux = map[ak];
		auxCount += 1;
		totalPotency += aux.Potency;
		// Harmony bonus if aux matches one of the formula's JunNatures or is an exotic herb/core
		foreach (jn in formula.JunNatures)
		{
			if (aux.Nature == jn) { harmonyBonus += 8; break; }
		}
		if (aux.Kind == "herb") harmonyBonus += 6;
		else if (aux.Kind == "core") harmonyBonus += 10;
	}

	if (usedCounts[junKey] > jun.TotalCount)
		return { Ok = false, Reason = "「" + jun.Name + "」存量不足。", SilverCost = silverCost };

	if (auxCount < formula.MinAuxCount)
	{
		return {
			Ok             = false,
			Reason         = "本方至少需配齐 " + formula.MinAuxCount + " 味【臣佐辅药】以调和鼎火（当前已配 " + auxCount + " 味）。",
			SilverCost     = silverCost,
			TargetPotency  = formula.TargetPotency,
			CurrentPotency = totalPotency,
			MasterLabel    = mastery.MasterLabel
		};
	}

	if (totalPotency < formula.TargetPotency)
	{
		return {
			Ok             = false,
			Reason         = "鼎内总药力不足（当前 " + totalPotency + " / 需达 " + formula.TargetPotency + "），请增补佐药或换用更高阶奇草/内丹。",
			SilverCost     = silverCost,
			TargetPotency  = formula.TargetPotency,
			CurrentPotency = totalPotency,
			MasterLabel    = mastery.MasterLabel
		};
	}

	local surplus = totalPotency - formula.TargetPotency;
	local doubleChance = ::Math.min(85, 12 + surplus * 10 + harmonyBonus + mastery.BonusDoublePct);
	local gradeChances = ::Wuxia.Alchemy.calcPillGradeChances(surplus, harmonyBonus, mastery.BonusDoublePct);
	local auxNature    = ::Wuxia.Alchemy.resolveDominantAuxNature(_slotKeys, map);
	local auxPreview   = ::Wuxia.Alchemy.getAuxEffectPreviewLine(auxNature, pdef.Kind);
	local haveMoney = ("World" in getroottable() && ::World != null && ("Assets" in ::World) && ::World.Assets != null)
		? ::World.Assets.getMoney()
		: 999999;

	local byproductName = "";
	if ("BonusByproduct" in formula && (formula.BonusByproduct in ::Wuxia.Config.Pills))
		byproductName = ::Wuxia.Config.Pills[formula.BonusByproduct].Name;

	return {
		Ok             = (haveMoney >= silverCost),
		Reason         = (haveMoney < silverCost) ? ("炉火纹银不足（需 " + silverCost + " 两）。") : "",
		PillID         = formula.PillID,
		PillName       = pdef.Name,
		BaseYield      = formula.BaseYield,
		SilverCost     = silverCost,
		TargetPotency  = formula.TargetPotency,
		CurrentPotency = totalPotency,
		DoubleChance   = doubleChance,
		GradeChances   = gradeChances,
		AuxNature      = auxNature,
		AuxTitle       = auxPreview.Title,
		AuxColor       = auxPreview.Color,
		AuxDesc        = auxPreview.Desc,
		ByproductName  = byproductName,
		MasterLabel    = mastery.MasterLabel
	};
};

// Smart Auto-Fill (`智能抓药`): picks abundant/economical matching ingredients without wasting top-tier unique cores unless needed!
::Wuxia.Alchemy.autoPickIngredients <- function( _formulaID, _ingList = null )
{
	local formula = ::Wuxia.Alchemy.findFormula(_formulaID);
	if (formula == null) return ["", "", ""];

	local list = _ingList != null ? _ingList : ::Wuxia.Alchemy.getUnifiedIngredients();
	local avail = {};
	foreach (e in list) avail[e.Key] <- e.TotalCount;

	// Sort candidates economically: lowest sufficient Potency first, higher TotalCount first, Trophies/Herbs before Unique Cores
	local kindCost = { trophy = 1, herb = 2, core = 3 };
	local sorted = clone list;
	sorted.sort(function( a, b ) {
		if (a.Potency != b.Potency) return a.Potency < b.Potency ? -1 : 1;
		local ka = (a.Kind in kindCost) ? kindCost[a.Kind] : 2;
		local kb = (b.Kind in kindCost) ? kindCost[b.Kind] : 2;
		if (ka != kb) return ka < kb ? -1 : 1;
		if (a.TotalCount != b.TotalCount) return a.TotalCount > b.TotalCount ? -1 : 1;
		return a.Value < b.Value ? -1 : 1;
	});

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
	local bestTwoAuxPot = 0;
	local potDesc = clone list;
	potDesc.sort(function( a, b ) { return a.Potency > b.Potency ? -1 : 1; });

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

// Execute Bagua Cauldron Brew! Consumes ingredients from Cabinet/Stash + Silver, delivers Pills to Stash!
::Wuxia.Alchemy.executeBrew <- function( _formulaID, _slotKeys )
{
	if (!("World" in getroottable()) || ::World == null || !("Assets" in ::World) || ::World.Assets == null)
		return { Ok = false, Reason = "当前仅可在大地图行军、营帐或城镇中开炉炼丹。" };

	local stash = ::World.Assets.getStash();
	if (stash == null)
		return { Ok = false, Reason = "无法访问战团仓库。" };

	local ingList = ::Wuxia.Alchemy.getUnifiedIngredients(stash);
	local ingMap = {};
	foreach (e in ingList) ingMap[e.Key] <- e;

	local preview = ::Wuxia.Alchemy.previewBrew(_formulaID, _slotKeys, ingMap);
	if (!preview.Ok)
		return preview;

	local formula = ::Wuxia.Alchemy.findFormula(_formulaID);
	local freeSlots = stash.getNumberOfEmptySlots();
	// Check how many Stash slots will be freed by consuming Stash-only ingredients
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

	local maxOutputPills = formula.BaseYield + 1;
	if (freeSlots + slotsFreed < formula.BaseYield)
		return { Ok = false, Reason = "战团仓库空位不足（至少需留出 " + formula.BaseYield + " 格空位盛放成丹；可先将奇草内丹收入百草药柜腾位）。" };

	// Deduct Silver & Ingredients
	::World.Assets.addMoney(-preview.SilverCost);
	for (local ci = 0; ci < _slotKeys.len(); ci = ++ci)
	{
		local ck = _slotKeys[ci];
		if (ck != null && ck != "")
			::Wuxia.Alchemy.consumeOneIngredient(ck, stash);
	}

	// Roll for Double-Pill Resonance (`紫气东来 · 丹韵暴击`) & Independent Pill Grades (`成丹 / 灵纹 / 丹霞`) + Aux Nature!
	local roll = ::Math.rand(1, 100);
	local isCrit = (roll <= preview.DoubleChance);
	local createdSummaries = [];
	local gChances = ("GradeChances" in preview) ? preview.GradeChances : [60, 30, 10];
	local auxNat   = ("AuxNature" in preview) ? preview.AuxNature : "";
	local auxTag   = (("AuxTitle" in preview) && preview.AuxTitle != "") ? ("·" + preview.AuxTitle) : "";

	for (local n = 0; n < formula.BaseYield; n = ++n)
	{
		local p = ::new("scripts/items/misc/wx_pill_item");
		local rVar = ::Wuxia.Alchemy.rollPillVariant(gChances, auxNat);
		p.initPillVariant(formula.PillID, rVar.Grade, rVar.PotencyPct, rVar.AuxNature);
		stash.add(p);
		createdSummaries.push("「" + p.getName() + "」（药效" + rVar.PotencyPct + "%" + auxTag + "）");
	}

	local bonusMsg = "";
	if (isCrit && stash.getNumberOfEmptySlots() > 0)
	{
		local bonusPillID = ("BonusByproduct" in formula && formula.BonusByproduct != "")
			? formula.BonusByproduct
			: formula.PillID;
		local bp = ::new("scripts/items/misc/wx_pill_item");
		local bpVar = ::Wuxia.Alchemy.rollPillVariant(gChances, auxNat);
		bp.initPillVariant(bonusPillID, bpVar.Grade, bpVar.PotencyPct, bpVar.AuxNature);
		stash.add(bp);
		if (bonusPillID == formula.PillID)
			bonusMsg = " 炉生紫霞、丹韵双成，额外凝出 1 枚「" + bp.getName() + "」（药效" + bpVar.PotencyPct + "%）！";
		else
			bonusMsg = " 鼎内余韵凝丹，额外伴生 1 枚「" + bp.getName() + "」（药效" + bpVar.PotencyPct + "%）！";
	}

	local outStr = createdSummaries[0];
	for (local ci2 = 1; ci2 < createdSummaries.len(); ci2 = ++ci2)
		outStr += "、" + createdSummaries[ci2];

	return {
		Ok        = true,
		IsCrit    = isCrit,
		PillID    = formula.PillID,
		PillName  = preview.PillName,
		BaseYield = formula.BaseYield,
		Message   = "开炉功成！炼得 " + outStr + "（耗纹银 " + preview.SilverCost + " 两）！" + bonusMsg
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

	local stash = (("World" in getroottable()) && ::World != null && ::World.Assets != null) ? ::World.Assets.getStash() : null;
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

	local avoidZeroShock = (("AvoidShock" in pv) && pv.AvoidShock);
	pv.PillBonus       <- pillBonus;
	pv.WashPillID      <- _washPillID;
	pv.WashPillName    <- pillName;
	pv.AvoidHeavyShock <- (avoidHeavyShock || avoidZeroShock);
	pv.AvoidAllShock   <- avoidZeroShock;
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

		return {
			Ok        = true,
			Succeeded = true,
			Roll      = roll,
			Chance    = preview.FinalChance,
			Message   = "洗经伐髓功成（服「" + preview.WashPillName + "」）！「" + preview.TargetAttrName + "」根骨跃升至 " + preview.NextStar + "★！"
		};
	}

	if (("AvoidAllShock" in preview) && preview.AvoidAllShock)
	{
		return {
			Ok                 = true,
			Succeeded          = false,
			Roll               = roll,
			Chance             = preview.FinalChance,
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
		GotPermanentInjury = gotPerm,
		Message            = gotPerm
			? "洗经伐髓未成！真气逆冲留下永久「经脉暗疾」（可用生生造化丹拔除）！"
			: (preview.AvoidHeavyShock
				? "洗经伐髓未成，幸得「太乙紫金洗髓丹」护住心脉，免去重度震荡，仅余 2 日轻度调息。"
				: "洗经伐髓失败！真气逆冲引发「经脉震荡」，需以护心丹或名医调养。")
	};
};

// Non-destructively wrap Slot Manager so `忘尘归元散` (`effects.wx_wangchen_grace`) waives PenaltyDays cleanly!
{
	local origCanEquipLearned = ::Wuxia.Slots.canEquipLearnedManual;
	::Wuxia.Slots.canEquipLearnedManual = function( _actor, _slotIndex, _manualID )
	{
		local res = origCanEquipLearned(_actor, _slotIndex, _manualID);
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
