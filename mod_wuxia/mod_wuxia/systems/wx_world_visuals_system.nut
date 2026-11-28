// Runtime System & Non-Destructive Modern Hooks for Row 4:
//   1. Chinese Prefectures, Garrisons, Villages, Oasis Cities & Sect Mountain Gates (`wx_settlement_0.brush` + `gfx/ui/settlements/`)
//   2. 32 World Map Marching Chess Pieces & Caravans (`wx_world_entity_0.brush`)
//   3. 16 Chinese Vertical Long War Standards (`gfx/ui/banners/` + `wx_world_entity_0.brush` + `wx_banners_0.brush`)

::Wuxia.WorldVisuals <- {
	RegisteredBanners = 0,
	MappedTerrainCount = 0,
	MappedLocationPools = 0,
	KnownRegionNames = null,
	KnownWildCampNames = null,
	RegionLabelCache = {}
};

::Wuxia.WorldVisuals.isAsciiName <- function( _s )
{
	if (_s == null || typeof _s != "string" || _s.len() == 0) return false;
	for (local i = 0; i < _s.len(); i = ++i)
	{
		local c = _s[i];
		if (c < 0 || c >= 128) return false;
	}
	return true;
};

::Wuxia.WorldVisuals.hashString <- function( _s )
{
	if (_s == null || typeof _s != "string") return 7;
	local h = 5381;
	for (local i = 0; i < _s.len(); i = ++i)
	{
		h = ((h * 33) + (_s[i] & 0xFF)) & 0x3FFFFFFF;
	}
	return h;
};

::Wuxia.WorldVisuals.isKnownRegionName <- function( _name )
{
	if (_name == null || _name == "") return false;
	if (::Wuxia.WorldVisuals.KnownRegionNames == null)
	{
		::Wuxia.WorldVisuals.KnownRegionNames = {};
		if ("RegionNames" in ::Wuxia.Config.WorldVisuals)
		{
			foreach (_k, arr in ::Wuxia.Config.WorldVisuals.RegionNames)
			{
				foreach (nm in arr)
					::Wuxia.WorldVisuals.KnownRegionNames[nm] <- true;
			}
		}
	}
	return (_name in ::Wuxia.WorldVisuals.KnownRegionNames);
};

::Wuxia.WorldVisuals.isKnownWildCampName <- function( _name )
{
	if (_name == null || _name == "") return false;
	if (::Wuxia.WorldVisuals.KnownWildCampNames == null)
	{
		::Wuxia.WorldVisuals.KnownWildCampNames = {};
		if ("WildCampNames" in ::Wuxia.Config.WorldVisuals)
		{
			foreach (_k, arr in ::Wuxia.Config.WorldVisuals.WildCampNames)
			{
				foreach (nm in arr)
					::Wuxia.WorldVisuals.KnownWildCampNames[nm] <- true;
			}
		}
	}
	local names = ::Wuxia.WorldVisuals.KnownWildCampNames;
	if (_name in names) return true;
	local suffix = _name.find("·");
	return suffix != null && (_name.slice(0, suffix) in names);
};

::Wuxia.WorldVisuals.initGlobals <- function()
{
	local cfg = ::Wuxia.Config.WorldVisuals;

	// Vanilla supplies N/S road ends. Junction pruning can leave a diagonal end as well.
	if ("World" in ::Const && "RoadBrushes" in ::Const.World)
	{
		foreach (dir in ["NE", "SE", "SW", "NW"])
			::Const.World.RoadBrushes.add(::Const.DirectionAsBit[dir], "wx_road_end_" + dir);
	}

	// 1. Set `::Const.PlayerBanners` exclusively to the 12 Wuxia vertical war standards (`banner_51..62`)
	//    so New Campaign always opens & cycles on pure Wuxia standards; legacy `banner_01..34` on old saves
	//    are upgraded seamlessly in `asset_manager.onDeserialize` and `player_banner`.
	if ("PlayerBanners" in ::Const && ::Const.PlayerBanners != null)
	{
		::Const.PlayerBanners = clone cfg.PlayerBanners;
		::Wuxia.WorldVisuals.RegisteredBanners = cfg.PlayerBanners.len();
	}

	// 2. Remap `::Const.World.TerrainSettlementImages` backgrounds onto our 8 Song/Ming landscapes (`wx_bg_*`)
	if ("World" in ::Const && "TerrainSettlementImages" in ::Const.World)
	{
		local arr = ::Const.World.TerrainSettlementImages;
		local mapped = 0;
		foreach (idx, bgPath in cfg.TerrainBackdropMap)
		{
			if (idx >= 0 && idx < arr.len() && arr[idx] != null && ("Background" in arr[idx]))
			{
				arr[idx].Background = bgPath;
				mapped += 1;
			}
		}
		::Wuxia.WorldVisuals.MappedTerrainCount = mapped;
	}

	// 3. Chinese Mercenary Company Names
	if ("Strings" in ::Const && ::Const.Strings != null && "MercenaryCompanyNames" in ::Const.Strings)
	{
		::Const.Strings.MercenaryCompanyNames = clone cfg.MercenaryCompanyNames;
	}

	// 4. Remap `::Const.World.LocationNames` (geographic regions, settlements, wilderness enemy camps & ruins)
	if ("World" in ::Const && "LocationNames" in ::Const.World && ::Const.World.LocationNames != null && "RegionNames" in cfg && "WildCampNames" in cfg)
	{
		local locTbl = ::Const.World.LocationNames;
		local fortCombined = [];
		foreach (fk in ["fort_small", "fort_medium", "fort_large"])
		{
			foreach (fnm in cfg.SettlementNames[fk])
				fortCombined.push(fnm);
		}

		local poolCount = 0;
		local keys = [];
		foreach (k, v in locTbl)
		{
			if (typeof v == "array")
				keys.push(k);
		}
		foreach (k in keys)
		{
			local lk = k.tolower();
			local repl = null;

			// Settlements
			if (lk.find("citystate") != null)
				repl = cfg.SettlementNames.oasis_city;
			else if (lk.find("village") != null || lk.find("hamlet") != null)
				repl = cfg.SettlementNames.village;
			else if (lk.find("fort") != null || lk.find("citadel") != null || lk.find("castle") != null || lk.find("keep") != null || lk.find("watchtower") != null || lk.find("stronghold") != null)
				repl = fortCombined;
			else if (lk.find("goblin") != null)
				repl = cfg.WildCampNames.goblins;
			else if (lk.find("orc") != null)
				repl = cfg.WildCampNames.orcs;
			else if (lk.find("barbarian") != null || lk.find("wildm") != null)
				repl = cfg.WildCampNames.barbarians;
			else if (lk.find("nomad") != null)
				repl = cfg.WildCampNames.nomads;
			else if (lk.find("bandit") != null || lk.find("brigand") != null || lk.find("pirate") != null)
				repl = cfg.WildCampNames.bandits;
			else if (lk.find("undead") != null || lk.find("zombie") != null || lk.find("vampire") != null || lk.find("skeleton") != null || lk.find("graveyard") != null || lk.find("cemetery") != null || lk.find("crypt") != null || lk.find("necromancer") != null || lk.find("tomb") != null || lk.find("barrow") != null)
				repl = cfg.WildCampNames.undead;
			else if (lk.find("ruin") != null || lk.find("abandon") != null || lk.find("battle") != null)
				repl = cfg.WildCampNames.ruins;
			else if (lk.find("city") != null)
				repl = cfg.SettlementNames.prefecture;
			else if (lk.find("town") != null)
				repl = cfg.SettlementNames.town;
			// Geographic Regions
			else if (lk.find("oasis") != null)
				repl = cfg.RegionNames.oasis;
			else if (lk.find("desert") != null || lk.find("dune") != null)
				repl = cfg.RegionNames.desert;
			else if (lk.find("ocean") != null || lk.find("sea") != null || lk.find("coast") != null || lk.find("shore") != null || lk.find("water") != null)
				repl = cfg.RegionNames.coast;
			else if (lk.find("swamp") != null || lk.find("marsh") != null || lk.find("bog") != null || lk.find("wetland") != null)
				repl = cfg.RegionNames.swamp;
			else if (lk.find("snow") != null || lk.find("winter") != null || lk.find("frozen") != null)
				repl = cfg.RegionNames.snow;
			else if (lk.find("tundra") != null || lk.find("highland") != null)
				repl = cfg.RegionNames.tundra;
			else if (lk.find("steppe") != null || lk.find("badland") != null)
				repl = cfg.RegionNames.steppe;
			else if (lk.find("mountain") != null || lk.find("peak") != null)
				repl = cfg.RegionNames.mountains;
			else if (lk.find("hill") != null)
				repl = cfg.RegionNames.hills;
			else if (lk.find("forest") != null || lk.find("wood") != null || lk.find("autumn") != null || lk.find("grove") != null)
				repl = cfg.RegionNames.forest;
			else if (lk.find("plain") != null || lk.find("grass") != null || lk.find("farm") != null || lk.find("field") != null || lk.find("land") != null)
				repl = cfg.RegionNames.plains;

			if (repl != null && repl.len() > 0)
			{
				locTbl[k] = clone repl;
				poolCount += 1;
			}
		}
		::Wuxia.WorldVisuals.MappedLocationPools = poolCount;
	}
};

::Wuxia.WorldVisuals.normalizePlayerBannerID <- function( _variant )
{
	if (_variant >= 51 && _variant <= 62) return _variant;
	local v = _variant <= 0 ? 1 : _variant;
	return 51 + ((v - 1) % 12);
};

::Wuxia.WorldVisuals.mapFactionUIBanner <- function( _bannerBrush )
{
	if (_bannerBrush == null || _bannerBrush == "") return null;
	if (_bannerBrush == "wx_fbanner_noble_01" || _bannerBrush == "wx_fbanner_noble_02" || _bannerBrush == "wx_fbanner_south_01" || _bannerBrush == "wx_fbanner_outlaw_01")
		return "ui/banners/" + _bannerBrush + "s.png";
	if (_bannerBrush.find("wx_fbanner_noble_") == 0 || _bannerBrush.find("wx_fbanner_south_") == 0 || _bannerBrush.find("wx_fbanner_civ_") == 0)
		return "ui/banners/" + _bannerBrush + ".png";
	if (_bannerBrush.find("banner_") == 0 && _bannerBrush.len() == 9)
	{
		local bNum = ::Wuxia.WorldVisuals.parseTrailingDigits(_bannerBrush, 7);
		if (bNum > 0)
			return "ui/banners/banner_" + ::Wuxia.WorldVisuals.normalizePlayerBannerID(bNum) + "s.png";
	}
	return null;
};

::Wuxia.WorldVisuals.resolveFactionUIBanner <- function( _faction )
{
	if (_faction == null) return null;
	local wb = null;
	if (::Wuxia.hasMember(_faction, "getSettlements"))
	{
		local fSets = _faction.getSettlements();
		if (fSets != null && fSets.len() == 1 && fSets[0] != null && ::Wuxia.hasMember(fSets[0], "WX_ResolveSettlementBanner"))
			wb = fSets[0].WX_ResolveSettlementBanner(null);
	}
	if (wb == null && ::Wuxia.hasMember(_faction, "getBannerSmall"))
		wb = ::Wuxia.WorldVisuals.mapWorldBannerBrush(_faction.getBannerSmall());
	return ::Wuxia.WorldVisuals.mapFactionUIBanner(wb);
};

::Wuxia.WorldVisuals.pickRegionNameByTerrain <- function( _terrainType, _seed, _used = null )
{
	local rPools = ::Wuxia.Config.WorldVisuals.RegionNames;
	local pKey = "plains";
	if (_terrainType == 1 || _terrainType == 16) pKey = "coast";
	else if (_terrainType == 3) pKey = "swamp";
	else if (_terrainType == 4) pKey = "hills";
	else if (_terrainType == 5 || _terrainType == 7) pKey = "forest";
	else if (_terrainType == 6 || _terrainType == 12) pKey = "snow";
	else if (_terrainType == 8 || _terrainType == 15) pKey = "steppe";
	else if (_terrainType == 9) pKey = "mountains";
	else if (_terrainType == 14) pKey = "tundra";
	else if (_terrainType == 17) pKey = "desert";
	else if (_terrainType == 18) pKey = "oasis";

	local pool = (pKey in rPools) ? rPools[pKey] : rPools.plains;
	local n = pool.len();
	local s = ::Math.abs(_seed);
	if (_used != null)
	{
		for (local i = 0; i < n; i = ++i)
		{
			local cand = pool[(s + i) % n];
			if (!(cand in _used))
			{
				_used[cand] <- true;
				return cand;
			}
		}
	}
	return pool[s % n];
};

::Wuxia.WorldVisuals.getFlagStr <- function( _flags, _key )
{
	if (_flags == null || !_flags.has(_key)) return "";
	local v = _flags.get(_key);
	return (typeof v == "string") ? v : "";
};

::Wuxia.WorldVisuals.safeGetFaction <- function( _fid )
{
	if (_fid == null || _fid <= 0) return null;
	if (!("World" in getroottable()) || ::World == null || !("FactionManager" in ::World) || ::World.FactionManager == null)
		return null;
	local fm = ::World.FactionManager;
	if (::Wuxia.hasMember(fm, "getFactions"))
	{
		local arr = fm.getFactions();
		if (arr == null || _fid >= arr.len()) return null;
		return arr[_fid];
	}
	try { return fm.getFaction(_fid); } catch (_e) { return null; }
};

::Wuxia.WorldVisuals.localizeVanillaPartyName <- function( _party )
{
	if (_party == null || _party.m.IsPlayer) return;
	if (_party.m.Flags != null)
	{
		local ps = ::Wuxia.WorldVisuals.getFlagStr(_party.m.Flags, "wx_sect_patrol");
		local vd = ::Wuxia.WorldVisuals.getFlagStr(_party.m.Flags, "wx_vendetta");
		local hasSh = _party.m.Flags.has("wx_shanhai_roam") && _party.m.Flags.get("wx_shanhai_roam") != false && _party.m.Flags.get("wx_shanhai_roam") != 0 && _party.m.Flags.get("wx_shanhai_roam") != "";
		if (ps != "" || vd != "" || hasSh)
			return;
	}

	local cur = _party.m.Name;
	if (cur == null || cur == "") return;

	// Resolve owner settlement / faction Chinese prefix if available
	local ownerLabel = "";
	if (::Wuxia.hasMember(_party, "getFaction"))
	{
		local fac = ::Wuxia.WorldVisuals.safeGetFaction(_party.getFaction());
		if (fac != null)
		{
			if (::Wuxia.hasMember(fac, "getSettlements"))
			{
				local fSets = fac.getSettlements();
				if (fSets != null && fSets.len() == 1 && fSets[0] != null)
					ownerLabel = fSets[0].getName();
			}
			if (ownerLabel == "" && ::Wuxia.hasMember(fac, "getName"))
				ownerLabel = fac.getName();
		}
	}

	local newName = null;
	if (::Wuxia.WorldVisuals.isAsciiName(cur))
	{
		local lc = cur.tolower();
		if (lc.find("supply caravan") != null)
			newName = (ownerLabel != "" && !::Wuxia.WorldVisuals.isAsciiName(ownerLabel)) ? (ownerLabel + "军资辎重队") : "藩镇军资辎重队";
		else if (lc.find("caravan") != null)
			newName = "四海行商驼镖队";
		else if (lc.find("peasant") != null || lc.find("villager") != null)
			newName = "乡间行脚百姓";
		else if (lc.find("refugee") != null)
			newName = "乱世逃难流民";
		else if (lc.find("slave") != null || lc.find("indebted") != null)
			newName = "披枷苦役囚徒";
		else if (lc.find("envoy") != null || lc.find("diplomat") != null)
			newName = "州府钦差仪仗";
		else if (lc.find("regiment of ") == 0 || lc.find("conscript") != null)
			newName = (ownerLabel != "" && !::Wuxia.WorldVisuals.isAsciiName(ownerLabel)) ? (ownerLabel + "都护铁卫") : "西域都护铁卫";
		else if (lc.find(" company") != null || lc.find("noble") != null || lc.find("footmen") != null)
			newName = (ownerLabel != "" && !::Wuxia.WorldVisuals.isAsciiName(ownerLabel)) ? (ownerLabel + "巡防营") : "藩镇玄甲巡防营";
		else if (lc.find("militia") != null)
			newName = (ownerLabel != "" && !::Wuxia.WorldVisuals.isAsciiName(ownerLabel)) ? (ownerLabel + "乡勇团练") : "州县乡勇团练";
		else if (lc.find("mercenar") != null || lc.find("bounty hunter") != null)
		{
			local mPool = ::Wuxia.Config.WorldVisuals.MercenaryCompanyNames;
			newName = mPool[::Math.abs(_party.getID()) % mPool.len()];
		}
		else if (lc.find("goblin") != null)
			newName = "南疆五毒游骑";
		else if (lc.find("orc") != null)
			newName = "邪派炼体药人";
		else if (lc.find("nomad") != null || lc.find("cutthroat") != null || lc.find("outlaw") != null)
			newName = "塞外沙路马贼";
		else if (lc.find("barbarian") != null || lc.find("thrall") != null || lc.find("reaver") != null || lc.find("chosen") != null || lc.find("wildm") != null)
			newName = "关外黑水战帮";
		else if (lc.find("zombie") != null || lc.find("necromancer") != null || lc.find("wiederganger") != null || lc.find("geist") != null)
			newName = "湘西符水尸群";
		else if (lc.find("skeleton") != null || lc.find("undead") != null || lc.find("ancient") != null || lc.find("legion") != null || lc.find("necrosavant") != null)
			newName = "前朝玄宫兵俑";
		else if (lc.find("bandit") != null || lc.find("brigand") != null || lc.find("raider") != null || lc.find("poacher") != null || lc.find("thug") != null || lc.find("deserter") != null)
			newName = "绿林拦路响马";
		else if (lc.find("direwolf") != null || lc.find("wolves") != null)
			newName = "山海荒兽 · 天狗妖群";
		else if (lc.find("hyena") != null)
			newName = "山海凶兽 · 蛊雕群";
		else if (lc.find("spider") != null || lc.find("webknecht") != null)
			newName = "山海毒虫 · 赤蛛群";
		else if (lc.find("unhold") != null)
			newName = "山海巨兽 · 朱厌山魈";
		else if (lc.find("lindwurm") != null)
			newName = "山海大妖 · 肥遗毒蛟";
		else if (lc.find("serpent") != null)
			newName = "山海泽妖 · 巴蛇毒虺";
		else if (lc.find("schrat") != null)
			newName = "山海古精 · 建木树妖";
		else if (lc.find("ghoul") != null || lc.find("nachzehrer") != null)
			newName = "山海饕妖 · 狍鸮群";
		else if (lc.find("alp") != null || lc.find("hexe") != null)
			newName = "山海诡祟 · 魇魅妖姬";
	}
	else if ("Contracts" in ::Wuxia && "rewriteText" in ::Wuxia.Contracts)
	{
		local rw = ::Wuxia.Contracts.rewriteText(cur);
		if (rw != cur) newName = rw;
	}

	if (newName != null && newName != "" && newName != cur)
	{
		_party.m.Name = newName;
		if (_party.hasLabel("name") && _party.getLabel("name").Text != "")
			_party.getLabel("name").Text = newName;
	}
};

::Wuxia.WorldVisuals.sanitizeMapEntityLabel <- function( _text )
{
	if (_text == null || _text == "") return _text;
	if (_text.find("Ruins of ") == 0)
	{
		local rPool = ::Wuxia.Config.WorldVisuals.WildCampNames.ruins;
		return rPool[::Wuxia.WorldVisuals.hashString(_text) % rPool.len()];
	}
	if ("Contracts" in ::Wuxia && "rewriteText" in ::Wuxia.Contracts && !::Wuxia.WorldVisuals.isAsciiName(_text))
		return ::Wuxia.Contracts.rewriteText(_text);
	return _text;
};

::Wuxia.WorldVisuals.bindMapLabelsBridge <- function()
{
	local root = ::getroottable();
	if (!("BBMODMapLabels" in root) || root.BBMODMapLabels == null) return;
	local bridge = root.BBMODMapLabels;
	if ("WX_Wrapped" in bridge) return;
	if (!("collect" in bridge) || typeof bridge.collect != "function") return;

	bridge.WX_Wrapped <- true;
	bridge.WX_OrigCollect <- bridge.collect;
	bridge.LastFrame = null;

	bridge.collect = function( _state )
	{
		local batch = this.WX_OrigCollect(_state);
		if (batch == null || !("frame" in batch) || batch.frame == null || !("labels" in batch.frame))
			return batch;

		local labels = batch.frame.labels;
		local needRegionBuild = false;
		for (local i = 0; i < labels.len(); i = ++i)
		{
			local item = labels[i];
			if (item != null && ("region" in item) && item.region && !::Wuxia.WorldVisuals.isKnownRegionName(item.text) && !(item.text in ::Wuxia.WorldVisuals.RegionLabelCache))
			{
				needRegionBuild = true;
				break;
			}
		}

		if (needRegionBuild && _state != null && ::Wuxia.hasMember(_state, "getRegions"))
		{
			local regions = _state.getRegions();
			local usedR = {};
			foreach (_orig, mappedR in ::Wuxia.WorldVisuals.RegionLabelCache)
				usedR[mappedR] <- true;

			foreach (idx, reg in regions)
			{
				if (reg == null || !("Name" in reg) || reg.Name == "") continue;
				if (::Wuxia.WorldVisuals.isKnownRegionName(reg.Name))
				{
					usedR[reg.Name] <- true;
					continue;
				}
				if (!(reg.Name in ::Wuxia.WorldVisuals.RegionLabelCache))
				{
					local tType = ("Type" in reg) ? reg.Type : 2;
					local cx = ("Center" in reg && reg.Center != null && "SquareCoords" in reg.Center) ? reg.Center.SquareCoords.X : idx;
					local cy = ("Center" in reg && reg.Center != null && "SquareCoords" in reg.Center) ? reg.Center.SquareCoords.Y : idx;
					local rSeed = ::Math.abs(cx * 67 + cy * 43 + idx * 13);
					::Wuxia.WorldVisuals.RegionLabelCache[reg.Name] <- ::Wuxia.WorldVisuals.pickRegionNameByTerrain(tType, rSeed, usedR);
				}
			}
		}

		for (local j = 0; j < labels.len(); j = ++j)
		{
			local lbl = labels[j];
			if (lbl == null || !("text" in lbl) || typeof lbl.text != "string") continue;
			if (("region" in lbl) && lbl.region)
			{
				if (lbl.text in ::Wuxia.WorldVisuals.RegionLabelCache)
					lbl.text = ::Wuxia.WorldVisuals.RegionLabelCache[lbl.text];
				else if (!::Wuxia.WorldVisuals.isKnownRegionName(lbl.text))
				{
					local fallbackName = ::Wuxia.WorldVisuals.pickRegionNameByTerrain(2, ::Wuxia.WorldVisuals.hashString(lbl.text), null);
					::Wuxia.WorldVisuals.RegionLabelCache[lbl.text] <- fallbackName;
					lbl.text = fallbackName;
				}
			}
			else
			{
				lbl.text = ::Wuxia.WorldVisuals.sanitizeMapEntityLabel(lbl.text);
			}
		}
		return batch;
	};
};

::Wuxia.WorldVisuals.mapPartyBodyBrush <- function( _brushName, _party = null )
{
	if (_brushName == null || _brushName == "") return null;
	if (_brushName.find("wx_") == 0) return _brushName;

	local cfg = ::Wuxia.Config.WorldVisuals;
	if (_brushName in cfg.PartyExactMap)
		return cfg.PartyExactMap[_brushName];

	foreach (pair in cfg.PartyPrefixMap)
	{
		if (_brushName.find(pair[0]) == 0)
			return pair[1];
	}
	return null;
};

::Wuxia.WorldVisuals.parseTrailingDigits <- function( _str, _prefixLen )
{
	if (_str == null || _str.len() <= _prefixLen) return -1;
	local sub = _str.slice(_prefixLen);
	local val = 0;
	local found = false;
	for (local i = 0; i < sub.len(); i = ++i)
	{
		local ch = sub[i];
		if (ch >= '0' && ch <= '9')
		{
			val = val * 10 + (ch - '0');
			found = true;
		}
		else if (found)
		{
			break;
		}
	}
	return found ? val : -1;
};

::Wuxia.WorldVisuals.mapWorldBannerBrush <- function( _bannerName )
{
	if (_bannerName == null || _bannerName == "") return null;
	if (_bannerName.find("wx_") == 0) return _bannerName;
	if (_bannerName.find("banner_") == 0 && _bannerName.len() == 9)
	{
		local numStr = _bannerName.slice(7);
		local firstCh = numStr[0];
		if (firstCh >= '0' && firstCh <= '9')
		{
			local id = numStr.tointeger();
			if (id >= 51 && id <= 62) return _bannerName;
			return "banner_" + ::Wuxia.WorldVisuals.normalizePlayerBannerID(id);
		}
	}
	if (_bannerName.find("banner_noble_") == 0)
	{
		local n = ::Wuxia.WorldVisuals.parseTrailingDigits(_bannerName, 13);
		if (n >= 1 && n <= 10)
			return "wx_fbanner_noble_" + ::Wuxia.Appearance.pad2(n);
		if (n == 11)
			return "wx_fbanner_civ_01";
		if (n >= 12 && n <= 14)
			return "wx_fbanner_south_0" + (((n - 12) % 3) + 1);
		if (n > 14)
			return "wx_fbanner_noble_" + ::Wuxia.Appearance.pad2(((n - 1) % 10) + 1);
		return "wx_fbanner_noble_01";
	}
	if (_bannerName.find("banner_southern") == 0 || _bannerName.find("banner_citystate") == 0 || _bannerName.find("banner_nomads_") == 0)
	{
		local sn = ::Wuxia.WorldVisuals.parseTrailingDigits(_bannerName, 7);
		local sIdx = (sn >= 1) ? (((sn - 1) % 3) + 1) : 1;
		return "wx_fbanner_south_0" + sIdx;
	}
	if (_bannerName.find("banner_bandits_") == 0 || _bannerName.find("banner_goblins_") == 0 || _bannerName.find("banner_orcs_") == 0 || _bannerName.find("banner_wildmen_") == 0 || _bannerName == "banner_deserters")
		return "wx_fbanner_outlaw_01";
	return null;
};

::Wuxia.WorldVisuals.pickUnusedSiteName <- function( _pool, _seed, _sites, _self = null )
{
	local used = {};
	foreach (site in _sites)
	{
		if (site != null && site != _self)
			used[site.getName()] <- true;
	}
	local n = _pool.len();
	local start = ((_seed % n) + n) % n;
	for (local i = 0; i < n; ++i)
	{
		local cand = _pool[(start + i) % n];
		if (!(cand in used)) return cand;
	}
	local stem = _pool[start];
	local ordinal = 2;
	while ((stem + "·" + ordinal) in used) ++ordinal;
	return stem + "·" + ordinal;
};

::Wuxia.WorldVisuals.pickUniqueSettlementName <- function( _poolKey, _seed, _self )
{
	local pools = ::Wuxia.Config.WorldVisuals.SettlementNames;
	local pool = (_poolKey in pools) ? pools[_poolKey] : pools.town;
	local sites = ::Wuxia.hasWorldField("EntityManager") ? ::World.EntityManager.getSettlements() : [];
	return ::Wuxia.WorldVisuals.pickUnusedSiteName(pool, _seed, sites, _self);
};

// Sync the world-map player marching pawn (`player_party`) directly to the player's #1 operated character's actual Wuxia outfit, face, hair, beard & hat!
::Wuxia.WorldVisuals.syncPlayerLeadAppearance <- function( _party = null )
{
	local p = _party;
	if (p == null && ("World" in getroottable()) && ::World != null && ("State" in ::World) && ::World.State != null)
		p = ::World.State.getPlayer();
	if (p == null || !p.hasSprite("body")) return;

	local wmSubLayers = ["wx_wm_hat_back", "wx_wm_head", "wx_wm_beard", "wx_wm_hair", "wx_wm_hat_front"];
	foreach (sn in wmSubLayers)
	{
		if (!p.hasSprite(sn))
		{
			local added = p.addSprite(sn);
			if (added != null) added.Visible = false;
		}
	}

	local bodySpr = p.getSprite("body");
	local curBodyName = bodySpr.HasBrush ? bodySpr.getBrush().Name : "";
	local isSailing = (::Wuxia.hasMember(p.m, "IsSailing") && p.m.IsSailing) || curBodyName == "figure_player_ship" || curBodyName == "wx_ship_junk_01";
	if (isSailing)
	{
		if (curBodyName != "wx_ship_junk_01" && ::Wuxia.Appearance.brushExists("wx_ship_junk_01"))
			bodySpr.setBrush("wx_ship_junk_01");
		foreach (sn in wmSubLayers)
			p.getSprite(sn).Visible = false;
		p.m.WX_LastBodyBrush <- "wx_ship_junk_01";
		return;
	}

	local roster = ("World" in getroottable() && ::World != null) ? ::World.getPlayerRoster() : null;
	local bros = (roster != null) ? roster.getAll() : [];
	local lead = (bros != null && bros.len() > 0) ? bros[0] : null;
	if (lead == null || !("Appearance" in ::Wuxia))
	{
		if (curBodyName.find("wx_") != 0 && curBodyName.find("wm_") != 0)
			bodySpr.setBrush("wx_fig_player_01");
		foreach (sn in wmSubLayers)
			p.getSprite(sn).Visible = false;
		return;
	}

	local st = ::Wuxia.Appearance.getOrInitState(lead);
	local items = (::Wuxia.hasMember(lead, "getItems")) ? lead.getItems() : null;
	local bodyItem = (items != null) ? items.getItemAtSlot(::Const.ItemSlot.Body) : null;
	local headItem = (items != null) ? items.getItemAtSlot(::Const.ItemSlot.Head) : null;
	if (bodyItem != null && ("Armory" in ::Wuxia) && ("ensureArmorMapped" in ::Wuxia.Armory))
		::Wuxia.Armory.ensureArmorMapped(bodyItem);
	if (headItem != null && ("Armory" in ::Wuxia) && ("ensureHelmetMapped" in ::Wuxia.Armory))
		::Wuxia.Armory.ensureHelmetMapped(headItem);

	local bodyCond = (bodyItem != null) ? ((::Wuxia.hasMember(bodyItem, "getCondition")) ? bodyItem.getCondition() : bodyItem.m.Condition) : 0;
	local baseBody = (bodyItem != null && ("WX_BodyBrush" in bodyItem.m) && bodyItem.m.WX_BodyBrush != null && bodyCond > 0)
		? bodyItem.m.WX_BodyBrush
		: ::Wuxia.Appearance.resolveUnarmoredBodyBrush(lead);
	local wmBody = "wm_" + baseBody;
	if (!::Wuxia.Appearance.brushExists(wmBody))
		wmBody = "wx_fig_player_01";

	bodySpr.setBrush(wmBody);
	if (p.hasSprite("base"))
		p.getSprite("base").Visible = true;
	p.m.WX_LastBodyBrush <- wmBody;

	if (wmBody.find("wm_") != 0 || st == null)
	{
		foreach (sn in wmSubLayers)
			p.getSprite(sn).Visible = false;
		return;
	}

	local flip = bodySpr.isFlippedHorizontally();
	local setWM = function( _sprName, _baseBrush )
	{
		local sp = p.getSprite(_sprName);
		if (sp == null) return;
		local cand = (_baseBrush != null && _baseBrush != "") ? ("wm_" + _baseBrush) : null;
		if (cand != null && ::Wuxia.Appearance.brushExists(cand))
		{
			sp.setBrush(cand);
			sp.Visible = true;
			sp.setHorizontalFlipping(flip);
		}
		else
		{
			sp.Visible = false;
		}
	};

	local headCond = (headItem != null) ? ((::Wuxia.hasMember(headItem, "getCondition")) ? headItem.getCondition() : headItem.m.Condition) : 0;
	local hasHat = (headItem != null && ("WX_HatFrontBrush" in headItem.m) && headItem.m.WX_HatFrontBrush != null && headCond > 0);
	local hatID = (hasHat && ("WX_HatID" in headItem.m)) ? headItem.m.WX_HatID : null;
	local hatBack = hasHat
		? (("WX_HatBackBrush" in headItem.m && headItem.m.WX_HatBackBrush != null) ? headItem.m.WX_HatBackBrush : (hatID != null ? (hatID + "_back") : null))
		: null;
	local hatFront = hasHat ? headItem.m.WX_HatFrontBrush : null;

	local fi = ::Math.max(1, ::Math.min(48, st.FaceIdx));
	local ti = ("HairToneIdx" in st && st.HairToneIdx >= 0) ? ::Math.max(0, ::Math.min(3, st.HairToneIdx)) : 0;
	local toneSuffix = ::Wuxia.Appearance.HairTones[ti].Suffix;

	local hideBeard = (fi >= 33) || (st.BeardIdx <= 0 || st.BeardIdx > 24) || (hatID != null && (hatID in ::Wuxia.Appearance.HideBeardHats));
	local beardBrush = null;
	if (!hideBeard)
	{
		beardBrush = "wx_beard_" + ::Wuxia.Appearance.pad2(st.BeardIdx) + toneSuffix;
		if (!::Wuxia.Appearance.brushExists("wm_" + beardBrush))
			beardBrush = "wx_beard_" + ::Wuxia.Appearance.pad2(st.BeardIdx);
	}

	local hideHair = (st.HairIdx <= 0 || st.HairIdx > 24) || (hatID != null && (hatID in ::Wuxia.Appearance.HideHairHats));
	local hairBrush = null;
	if (!hideHair)
	{
		local useTucked = (hatID != null && !(hatID in ::Wuxia.Appearance.OpenCrownHats));
		local baseH = "wx_hair_" + ::Wuxia.Appearance.pad2(st.HairIdx) + (useTucked ? "_tucked" : "");
		hairBrush = baseH + toneSuffix;
		if (!::Wuxia.Appearance.brushExists("wm_" + hairBrush))
			hairBrush = baseH;
	}

	setWM("wx_wm_hat_back",  hatBack);
	setWM("wx_wm_head",      "wx_head_" + ::Wuxia.Appearance.pad2(fi));
	setWM("wx_wm_beard",     beardBrush);
	setWM("wx_wm_hair",      hairBrush);
	setWM("wx_wm_hat_front", hatFront);
};

// Initialize global Const tables immediately
::Wuxia.WorldVisuals.initGlobals();

::Wuxia.HooksMod.hook("scripts/entity/world/entity_manager", function( q )
{
	q.getUniqueLocationName = @(__original) function( _names )
	{
		if (_names.len() == 0) return __original(_names);
		foreach (name in _names)
			if (!::Wuxia.WorldVisuals.isKnownWildCampName(name)) return __original(_names);
		return ::Wuxia.WorldVisuals.pickUnusedSiteName(_names, ::Math.rand(0, _names.len() - 1), this.getLocations());
	};
});

// =============================================================================
// 1. Player Banner & Tactical Battlefield Bannerman Hooks
// =============================================================================
if ("HooksMod" in ::Wuxia && ::Wuxia.HooksMod != null)
{
	::Wuxia.HooksMod.hook("scripts/states/world/asset_manager", function( q )
	{
		if (::Wuxia.qHas(q, "setBanner"))
		{
			q.setBanner = @(__original) function( ... )
			{
				vargv.insert(0, this);
				local ret = __original.acall(vargv);
				if (this.m.BannerID < 51 || this.m.BannerID > 62)
				{
					this.m.BannerID = ::Wuxia.WorldVisuals.normalizePlayerBannerID(this.m.BannerID);
					this.m.Banner = "banner_" + this.m.BannerID;
				}
				if ("State" in ::World && ::World.State != null)
				{
					local p = ::World.State.getPlayer();
					if (p != null && p.hasSprite("banner"))
						p.getSprite("banner").setBrush(this.m.Banner);
				}
				return ret;
			};
		}

		q.updateLook = @(__original) function( _updateTo = -1 )
		{
			__original(_updateTo);
			::Wuxia.WorldVisuals.syncPlayerLeadAppearance();
		};

		q.onDeserialize = @(__original) function( _in )
		{
			__original(_in);
			// Seamlessly upgrade legacy/empty/foreign banner IDs & names on old saves onto Wuxia vertical banners (51..66)
			this.m.BannerID = ::Wuxia.WorldVisuals.normalizePlayerBannerID(this.m.BannerID);
			this.m.Banner = "banner_" + this.m.BannerID;
			local p = ::World.State.getPlayer();
			if (p != null)
			{
				if (p.hasSprite("banner"))
					p.getSprite("banner").setBrush(this.m.Banner);
				this.updateLook(-1);
			}
			::Wuxia.WorldVisuals.bindMapLabelsBridge();
			if ("ensureAllSettlementWorkshops" in ::Wuxia.WorldVisuals)
				::Wuxia.WorldVisuals.ensureAllSettlementWorkshops();
			if ("SectRelations" in ::Wuxia && "ensureWorldSectSanctums" in ::Wuxia.SectRelations)
				::Wuxia.SectRelations.ensureWorldSectSanctums();
		};
	});

	::Wuxia.HooksMod.hook("scripts/states/world_state", function( q )
	{
		if (::Wuxia.qHas(q, "startNewCampaign"))
		{
			q.startNewCampaign = @(__original) function( ... )
			{
				::Wuxia.WorldVisuals.initGlobals();
				if ("tuneWorldGenSpacing" in ::Wuxia.WorldVisuals)
					::Wuxia.WorldVisuals.tuneWorldGenSpacing();
				::Wuxia.WorldVisuals.LastBalancedSeed <- -1;
				::Wuxia.WorldVisuals.RegionLabelCache = {};
				local callArgs = [this];
				for (local a = 0; a < vargv.len(); a = ++a)
					callArgs.push(vargv[a]);
				__original.acall(callArgs);
				::Wuxia.WorldVisuals.bindMapLabelsBridge();
				if ("ensureAllSettlementWorkshops" in ::Wuxia.WorldVisuals)
					::Wuxia.WorldVisuals.ensureAllSettlementWorkshops();
				if ("SectRelations" in ::Wuxia && "ensureWorldSectSanctums" in ::Wuxia.SectRelations)
					::Wuxia.SectRelations.ensureWorldSectSanctums();

				local cfgSettings = (vargv.len() > 0 && typeof vargv[0] == "table")
					? vargv[0]
					: (("CampaignSettings" in this.m && this.m.CampaignSettings != null) ? this.m.CampaignSettings : null);
				if (cfgSettings != null && ("banner" in cfgSettings) && typeof cfgSettings.banner == "string")
				{
					local parsed = ::Wuxia.WorldVisuals.parseTrailingDigits(cfgSettings.banner, 7);
					local bid = ::Wuxia.WorldVisuals.normalizePlayerBannerID(parsed > 0 ? parsed : 51);
					if (this.m.Assets != null)
					{
						this.m.Assets.m.BannerID = bid;
						this.m.Assets.m.Banner = "banner_" + bid;
					}
					local p = this.getPlayer();
					if (p != null && p.hasSprite("banner"))
						p.getSprite("banner").setBrush("banner_" + bid);

					// Sync any starting `player_banner` in stash or equipped on starting bros
					if (this.m.Assets != null && this.m.Assets.getStash() != null)
					{
						foreach (it in this.m.Assets.getStash().getItems())
						{
							if (it != null && it.getID() == "weapon.player_banner")
							{
								it.m.Variant = bid;
								it.updateVariant();
							}
						}
					}
					local roster = ::World.getPlayerRoster();
					if (roster != null)
					{
						foreach (bro in roster.getAll())
						{
							local mh = (bro != null && bro.getItems() != null) ? bro.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand) : null;
							if (mh != null && mh.getID() == "weapon.player_banner")
							{
								mh.m.Variant = bid;
								mh.updateVariant();
							}
						}
					}
				}
			};
		}
	});

	::Wuxia.HooksMod.hook("scripts/factions/faction", function( q )
	{
		if (::Wuxia.qHas(q, "getUIBanner"))
		{
			q.getUIBanner = @(__original) function()
			{
				local mappedUI = ::Wuxia.WorldVisuals.resolveFactionUIBanner(this);
				if (mappedUI != null) return mappedUI;
				return __original();
			};
		}
		if (::Wuxia.qHas(q, "getUIBannerSmall"))
		{
			q.getUIBannerSmall = @(__original) function()
			{
				local mappedUI = ::Wuxia.WorldVisuals.resolveFactionUIBanner(this);
				if (mappedUI != null) return mappedUI;
				return __original();
			};
		}
	});

	::Wuxia.HooksMod.hook("scripts/items/tools/player_banner", function( q )
	{
		q.WX_ApplyBannerText <- function()
		{
			this.m.Name = "镇团聚义竖幅大纛";
			this.m.Description = "龙头横杆、红缨精钢矛尖高挑的丝绸竖幅战团大纛。大纛所至，四格内同袍皆受掌旗者定力感召而军心稳固；长杆矛尖视同枪戟长兵，可完整施展枪矛与长柄系外功招式。";
		};

		if (::Wuxia.qHas(q, "getTooltip"))
		{
			q.getTooltip = @(__original) function()
			{
				local ret = __original();
				if (ret != null && typeof ret == "array")
				{
					ret.push({
						id = 94,
						type = "text",
						icon = "ui/icons/melee_skill.png",
						text = "【武学适配】视同[color=" + ::Const.UI.Color.PositiveValue + "]枪矛 / 长戟大刀[/color]长兵，完整激活枪戟系外功招式、被动与 5 AP 刺击精通"
					});
				}
				return ret;
			};
		}

		q.create = @(__original) function()
		{
			__original();
			this.WX_ApplyBannerText();
		};

		q.updateVariant = @(__original) function()
		{
			this.m.Variant = ::Wuxia.WorldVisuals.normalizePlayerBannerID(this.m.Variant);
			__original();
			this.WX_ApplyBannerText();
		};

		q.onEquip = @(__original) function()
		{
			this.m.Variant = ::Wuxia.WorldVisuals.normalizePlayerBannerID(this.m.Variant);
			this.updateVariant();
			__original();
		};

		q.onDeserialize = @(__original) function( _in )
		{
			__original(_in);
			this.m.Variant = ::Wuxia.WorldVisuals.normalizePlayerBannerID(this.m.Variant);
			this.updateVariant();
		};
	});

	::Wuxia.HooksMod.hook("scripts/items/tools/faction_banner", function( q )
	{
		q.create = @(__original) function()
		{
			__original();
			this.m.Name = "藩镇帅字牙旗";
			this.m.Description = "藩镇节度大军掌旗官高擎的鎏金矛头帅字牙旗。帅旗所指军心振奋，且长杆矛头视同枪戟长兵，可施展枪矛与长柄系外功招式。";
		};

		if (::Wuxia.qHas(q, "getTooltip"))
		{
			q.getTooltip = @(__original) function()
			{
				local ret = __original();
				if (ret != null && typeof ret == "array")
				{
					ret.push({
						id = 94,
						type = "text",
						icon = "ui/icons/melee_skill.png",
						text = "【武学适配】视同[color=" + ::Const.UI.Color.PositiveValue + "]枪矛 / 长戟大刀[/color]长兵，完整激活枪戟系外功招式与 5 AP 刺击精通"
					});
				}
				return ret;
			};
		}

		q.updateAppearance = @(__original) function()
		{
			if (!this.isEquipped()) return;
			local actor = this.getContainer().getActor();
			if (actor == null) return;
			local vIdx = ((::Math.max(1, this.m.Variant) - 1) % 4) + 1;
			if (actor.hasSprite("background"))
				actor.getSprite("background").setBrush("wx_faction_banner_0" + vIdx);
			if (actor.hasSprite("shaft"))
				actor.getSprite("shaft").setBrush("wx_faction_banner_shaft");
			actor.setDirty(true);
		};
	});

	// =========================================================================
	// 2. World Settlements, Mountain Sect Gates, Houses & Town Interior Hooks
	// =========================================================================
	::Wuxia.HooksMod.hook("scripts/entity/world/settlement", function( q )
	{
		q.WX_ComputeArchProfile <- function()
		{
			local tile = this.getTile();
			local seed = (tile != null) ? ::Math.abs(tile.SquareCoords.X * 73 + tile.SquareCoords.Y * 37) : 7;
			local isMtnOrForest = false;
			local isSwamp = false;
			local isSnow = false;

			if (tile != null && ("TerrainType" in ::Const.World))
			{
				local tt = ::Const.World.TerrainType;
				for (local i = 0; i < 6; i = ++i)
				{
					if (!tile.hasNextTile(i)) continue;
					local nt = tile.getNextTile(i).Type;
					if (nt == tt.Mountains || nt == tt.Hills || nt == tt.Forest || nt == tt.LeaveForest)
						isMtnOrForest = true;
					if (nt == tt.Swamp)
						isSwamp = true;
					if (nt == tt.Snow || nt == tt.SnowyForest)
						isSnow = true;
				}
			}

			local sz = this.getSize();
			if (this.isSouthern())
			{
				return {
					WorldSprite  = "wx_set_oasis_city_01",
					HousesIdx    = 4,
					UICenter     = "ui/settlements/wx_ui_center_oasis",
					UIHousesBase = "ui/settlements/wx_ui_houses_04",
					NamePool     = "oasis_city",
					IsSnow       = false
				};
			}
			if (this.isMilitary())
			{
				if (sz <= 1)
					return { WorldSprite = "wx_set_outpost_01",  HousesIdx = 1, UICenter = "ui/settlements/wx_ui_center_outpost",  UIHousesBase = "ui/settlements/wx_ui_houses_fort", NamePool = "fort_small",  IsSnow = isSnow };
				if (sz == 2)
					return { WorldSprite = "wx_set_garrison_02", HousesIdx = 2, UICenter = "ui/settlements/wx_ui_center_garrison", UIHousesBase = "ui/settlements/wx_ui_houses_fort", NamePool = "fort_medium", IsSnow = isSnow };
				return     { WorldSprite = "wx_set_citadel_03",  HousesIdx = 3, UICenter = "ui/settlements/wx_ui_center_citadel",  UIHousesBase = "ui/settlements/wx_ui_houses_fort", NamePool = "fort_large",  IsSnow = isSnow };
			}
			// Mountain / Forest Sect Gate & Zen Monastery towns!
			if (!this.isCoastal() && isMtnOrForest && sz >= 2 && (seed % 3 != 2))
			{
				if (seed % 2 == 0)
					return { WorldSprite = "wx_set_sect_mountain",  HousesIdx = 2, UICenter = "ui/settlements/wx_ui_center_sect",      UIHousesBase = "ui/settlements/wx_ui_houses_sect", NamePool = "sect_town", IsSnow = isSnow };
				return     { WorldSprite = "wx_set_sect_monastery", HousesIdx = 2, UICenter = "ui/settlements/wx_ui_center_monastery", UIHousesBase = "ui/settlements/wx_ui_houses_sect", NamePool = "sect_town", IsSnow = isSnow };
			}
			// Coastal & Jianghuai Swamp Water-Market towns!
			if (this.isCoastal() || isSwamp)
			{
				if (sz <= 1)
					return { WorldSprite = "wx_set_water_market",  HousesIdx = 1, UICenter = "ui/settlements/wx_ui_center_village",    UIHousesBase = "ui/settlements/wx_ui_houses_water", NamePool = "water_town", IsSnow = isSnow };
				if (sz == 2)
					return { WorldSprite = "wx_set_water_market",  HousesIdx = 2, UICenter = "ui/settlements/wx_ui_center_town",       UIHousesBase = "ui/settlements/wx_ui_houses_water", NamePool = "water_town", IsSnow = isSnow };
				return     { WorldSprite = "wx_set_prefecture_03", HousesIdx = 3, UICenter = "ui/settlements/wx_ui_center_prefecture", UIHousesBase = "ui/settlements/wx_ui_houses_water", NamePool = "water_town", IsSnow = isSnow };
			}
			// Standard Central Plains / Steppe / Snow Villages, County Towns & Grand Prefectures
			if (sz <= 1)
				return { WorldSprite = "wx_set_village_01",    HousesIdx = 1, UICenter = "ui/settlements/wx_ui_center_village",    UIHousesBase = "ui/settlements/wx_ui_houses_01", NamePool = "village",    IsSnow = isSnow };
			if (sz == 2)
				return { WorldSprite = "wx_set_town_02",       HousesIdx = 2, UICenter = "ui/settlements/wx_ui_center_town",       UIHousesBase = "ui/settlements/wx_ui_houses_02", NamePool = "town",       IsSnow = isSnow };
			return     { WorldSprite = "wx_set_prefecture_03", HousesIdx = 3, UICenter = "ui/settlements/wx_ui_center_prefecture", UIHousesBase = "ui/settlements/wx_ui_houses_03", NamePool = "prefecture", IsSnow = isSnow };
		};

		q.WX_RebuildHouseTiles <- function( _prof, _onlyLighting = false )
		{
			if (this.m.HousesTiles == null || !("DetailType" in ::Const.World)) return;
			local isNight = ("getTime" in ::World && ::World.getTime() != null) ? !::World.getTime().IsDaytime : false;
			foreach (h in this.m.HousesTiles)
			{
				local hTile = ::World.getTileSquare(h.X, h.Y);
				if (hTile == null) continue;
				local v = (h.V == 2) ? 2 : 1;
				local baseBrush = "wx_houses_0" + _prof.HousesIdx + "_0" + v;
				if (!_onlyLighting)
				{
					hTile.clear(::Const.World.DetailType.Houses | ::Const.World.DetailType.Lighting);
					local d = hTile.spawnDetail(baseBrush + (this.m.IsActive ? "" : "_ruins"), ::Const.World.ZLevel.Object - 3, ::Const.World.DetailType.Houses);
					if (d != null) d.Scale = 0.85;
				}
				else
				{
					hTile.clear(::Const.World.DetailType.Lighting);
				}

				if (this.m.IsActive && isNight)
				{
					local dl = hTile.spawnDetail(baseBrush + "_light", ::Const.World.ZLevel.Object - 4, ::Const.World.DetailType.Lighting);
					if (dl != null)
					{
						dl.IgnoreAmbientColor = true;
						dl.Scale = 0.85;
					}
				}
			}
		};

		q.WX_ApplyArchVisuals <- function( _rebuildHouses = false )
		{
			local prof = this.WX_ComputeArchProfile();
			local snowSuf = prof.IsSnow ? "_snow" : "";

			// Preserve `_undead` state if Undead Crisis conquered this settlement
			local isUndeadTaken = (this.m.Sprite.find("_undead") != null);
			this.m.Sprite = prof.WorldSprite + (isUndeadTaken ? "_undead" : "");
			this.m.Lighting = prof.WorldSprite + (isUndeadTaken ? "_undead_lights" : "_light");
			this.m.UISprite = "ui/settlement_sprites/" + prof.WorldSprite + ".png";

			if (this.m.UIBackground == null || this.m.UIBackground.find("wx_bg_") == null)
			{
				if (this.isSouthern())
					this.m.UIBackground = "ui/settlements/wx_bg_desert";
				else if (this.m.IsCoastal)
					this.m.UIBackground = "ui/settlements/wx_bg_coast";
				else if (prof.IsSnow)
					this.m.UIBackground = "ui/settlements/wx_bg_snow";
				else if (prof.NamePool == "sect_town")
					this.m.UIBackground = "ui/settlements/wx_bg_mountains";
				else if (prof.NamePool == "water_town")
					this.m.UIBackground = "ui/settlements/wx_bg_swamp";
				else
					this.m.UIBackground = "ui/settlements/wx_bg_plains";
			}

			this.m.UIBackgroundCenter = prof.UICenter + snowSuf;
			local hasPortLeft = this.m.IsCoastal && this.m.Buildings.len() > 3 && this.m.Buildings[3] != null && this.m.Buildings[3].getID() == "building.port";
			this.m.UIBackgroundLeft = hasPortLeft ? ("ui/settlements/wx_ui_water_left" + snowSuf) : (prof.UIHousesBase + "_left" + snowSuf);
			this.m.UIBackgroundRight = prof.UIHousesBase + "_right" + snowSuf;
			this.m.UIRamp = this.isSouthern() ? "ui/settlements/wx_ui_ramp_sand" : ("ui/settlements/wx_ui_ramp_stone" + snowSuf);
			this.m.UIRampPathway = this.isSouthern() ? "ui/settlements/wx_ui_pathway_sand" : ("ui/settlements/wx_ui_pathway_stone" + snowSuf);
			this.m.UIForeground = null;

			// Authentic Chinese Wuxia settlement hover description
			if (this.isSouthern())
				this.m.Description = "扼守西域瀚海商道的绿洲雄城，胡汉商队、驼铃奇珍与沙海武人在此云集。";
			else if (this.isMilitary())
				this.m.Description = (this.getSize() >= 3)
					? "高墙瓮城、铁甲森严的藩镇节度使帅城，屯驻精锐边军以镇抚一方。"
					: "控扼山川要冲的官军卫所戍堡，旌旗猎猎、刁斗森严。";
			else if (prof.NamePool == "sect_town")
				this.m.Description = "依傍名山古刹而建的清幽山门市镇，常有各派游侠与采药道人往来落脚。";
			else if (prof.NamePool == "water_town")
				this.m.Description = "舟楫纵横、渔歌互答的水陆渡埠集镇，南北漕运商货在此昼夜吞吐。";
			else if (this.getSize() >= 3)
				this.m.Description = "街市繁华、百工齐备的中原大州重府，车马喧阗、三教九流汇聚一堂。";
			else if (this.getSize() == 2)
				this.m.Description = "城垣齐整、商肆林立的州县城池，是往来镖局与江湖行客休整补给的要地。";
			else
				this.m.Description = "炊烟袅袅、桑麻环绕的乡间村镇，民风淳朴却也时常饱受乱世匪患惊扰。";

			if (this.hasSprite("body"))
			{
				local bodyBrush = this.m.IsActive ? this.m.Sprite : (prof.WorldSprite + "_ruins");
				this.getSprite("body").setBrush(bodyBrush);
			}
			if (this.hasSprite("lighting"))
			{
				this.getSprite("lighting").setBrush(this.m.Lighting);
			}
			if (this.hasSprite("location_banner"))
			{
				local resolvedB = this.WX_ResolveSettlementBanner(prof);
				if (resolvedB != null && ::Wuxia.Appearance.brushExists(resolvedB))
					this.getSprite("location_banner").setBrush(resolvedB);
			}

			// Localize European or transliterated settlement names into authentic Chinese Wuxia town names
			if (!("Purify" in ::Wuxia && ::Wuxia.Purify.isWuxiaTownName(this.m.Name)))
			{
				local t = this.getTile();
				local nSeed = (t != null) ? ::Math.abs(t.SquareCoords.X * 53 + t.SquareCoords.Y * 97) : 1;
				this.m.Name = ::Wuxia.WorldVisuals.pickUniqueSettlementName(prof.NamePool, nSeed, this);
			}
			this.WX_RefreshMapSectLabel();

			if (_rebuildHouses)
				this.WX_RebuildHouseTiles(prof, false);
		};

		q.WX_RefreshMapSectLabel <- function()
		{
			if (!this.hasLabel("name")) return;
			this.getLabel("name").Text = this.m.Name;
		};

		q.WX_GetUISubTitle <- function( _prof = null )
		{
			local prof = (_prof != null) ? _prof : this.WX_ComputeArchProfile();
			local sz = this.getSize();
			local subBase = "桑麻环绕 · 炊烟袅袅之淳朴乡间村镇";
			if (this.isSouthern())
				subBase = "瀚海商道枢纽 · 胡汉奇珍云集之绿洲雄城";
			else if (this.isMilitary())
			{
				if (sz >= 3) subBase = "铁甲森严 · 藩镇节度使驻节帅府重城";
				else if (sz == 2) subBase = "旌旗猎猎 · 控扼山川要冲之官军卫城";
				else subBase = "刁斗森严 · 戍守边关隘口之烽燧军堡";
			}
			else if (prof.NamePool == "sect_town")
				subBase = (prof.WorldSprite == "wx_set_sect_monastery")
					? "晨钟暮鼓 · 依傍名山古刹之清幽集镇"
					: "云深松风 · 依傍名山幽谷之清幽市镇";
			else if (prof.NamePool == "water_town")
				subBase = "舟楫纵横 · 南北漕运吞吐之水陆古渡";
			else if (sz >= 3)
				subBase = "车马喧阗 · 百工商贾辐辏之大州重府";
			else if (sz == 2)
				subBase = "城垣齐整 · 镖局行客休整之州县城池";

			return subBase;
		};

		q.WX_ResolveSettlementBanner <- function( _prof = null )
		{
			local prof = (_prof != null) ? _prof : this.WX_ComputeArchProfile();
			local tile = this.getTile();
			local seed = (tile != null) ? ::Math.abs(tile.SquareCoords.X * 41 + tile.SquareCoords.Y * 83) : 3;

			if (this.isSouthern())
			{
				local ownerS = (::Wuxia.hasMember(this, "getOwner")) ? this.getOwner() : null;
				if (ownerS != null && ::Wuxia.hasMember(ownerS, "getBannerSmall"))
				{
					local sb = ::Wuxia.WorldVisuals.mapWorldBannerBrush(ownerS.getBannerSmall());
					if (sb != null && sb.find("wx_fbanner_south_") == 0) return sb;
				}
				if (::Wuxia.hasMember(this, "getFactions"))
				{
					foreach (fid in this.getFactions())
					{
						local fac = ::Wuxia.WorldVisuals.safeGetFaction(fid);
						if (fac != null && ::Wuxia.hasMember(fac, "getBannerSmall"))
						{
							local fb = ::Wuxia.WorldVisuals.mapWorldBannerBrush(fac.getBannerSmall());
							if (fb != null && fb.find("wx_fbanner_south_") == 0) return fb;
						}
					}
				}
				return "wx_fbanner_south_0" + ((seed % 3) + 1);
			}

			local owner = (::Wuxia.hasMember(this, "getOwner")) ? this.getOwner() : null;
			if (owner != null && ::Wuxia.hasMember(owner, "getBannerSmall"))
			{
				local ob = owner.getBannerSmall();
				if (ob != null && ob != "banner_noble_11")
				{
					local mappedOwner = ::Wuxia.WorldVisuals.mapWorldBannerBrush(ob);
					if (mappedOwner != null) return mappedOwner;
				}
			}

			if (this.isMilitary())
			{
				if (this.hasSprite("location_banner") && this.getSprite("location_banner").HasBrush)
				{
					local curB = this.getSprite("location_banner").getBrush().Name;
					if (curB.find("wx_fbanner_noble_") == 0) return curB;
					local mb = ::Wuxia.WorldVisuals.mapWorldBannerBrush(curB);
					if (mb != null) return mb;
				}
				return "wx_fbanner_noble_" + ::Wuxia.Appearance.pad2((seed % 10) + 1);
			}

			// Independent civilian towns & regional settlements each fly distinct Song/Ming regional standards
			if (prof.WorldSprite == "wx_set_sect_mountain")
				return "wx_fbanner_civ_02";
			if (prof.WorldSprite == "wx_set_sect_monastery")
				return "wx_fbanner_civ_03";
			if (prof.NamePool == "water_town")
				return "wx_fbanner_civ_04";
			if (prof.IsSnow)
				return "wx_fbanner_civ_05";
			if (this.getSize() <= 1)
				return (seed % 2 == 0) ? "wx_fbanner_civ_06" : "wx_fbanner_civ_01";
			return (seed % 2 == 0) ? "wx_fbanner_civ_01" : "wx_fbanner_civ_06";
		};

		q.onInit = @(__original) function()
		{
			__original();
			this.WX_ApplyArchVisuals(false);
		};

		q.WX_EnsureDisguisePavilion <- function()
		{
			if (this.m.Buildings == null)
				return;

			while (this.m.Buildings.len() < 6)
				this.m.Buildings.push(null);

			// Town screen has 6 slots: 0..4 are shop/facility slots (slot 3 is port on coastal towns), slot 5 is `招贤茶摊` (`building.crowd`).
			local validShopSlots = [];
			foreach (candIdx in [4, 3, 1, 0, 2])
			{
				if (candIdx >= this.m.Buildings.len()) continue;
				if (candIdx == 3 && (this.m.IsCoastal || (this.m.Buildings[3] != null && this.m.Buildings[3].getID() == "building.port")))
					continue;
				if (this.m.Buildings[candIdx] != null && this.m.Buildings[candIdx].getID() == "building.crowd")
					continue;
				validShopSlots.push(candIdx);
			}

			local sz = this.getSize();
			local isMil = this.isMilitary();

			// Guarantee `百工丹坊` (`taxidermist_building`) in all Size >= 2 civil/southern towns, plus Size 3 military capitals when a slot is free!
			if ((!isMil && sz >= 2) || (isMil && sz >= 3))
			{
				local hasWorkshop = false;
				foreach (b2 in this.m.Buildings)
				{
					if (b2 != null && b2.getID() == "building.taxidermist")
					{
						hasWorkshop = true;
						break;
					}
				}
				if (!hasWorkshop)
				{
					local placed = false;
					foreach (slotIdx in validShopSlots)
					{
						if (this.m.Buildings[slotIdx] == null)
						{
							this.addBuilding(::new("scripts/entity/world/settlements/buildings/taxidermist_building"), slotIdx);
							placed = true;
							break;
						}
					}
					// Fallback if a civil town filled all 5 shop slots (e.g. with wardog kennel): swap a non-core auxiliary slot cleanly
					if (!placed && !isMil)
					{
						local replacePriority = ["building.kennel", "building.fletcher", "building.training_hall"];
						foreach (repID in replacePriority)
						{
							if (placed) break;
							foreach (slotIdx in validShopSlots)
							{
								local curB = this.m.Buildings[slotIdx];
								if (curB != null && curB.getID() == repID)
								{
									if (::Wuxia.hasMember(curB, "m") && "Settlement" in curB.m)
										curB.m.Settlement = null;
									this.m.Buildings[slotIdx] = null;
									this.addBuilding(::new("scripts/entity/world/settlements/buildings/taxidermist_building"), slotIdx);
									placed = true;
									break;
								}
							}
						}
					}
				}
			}

			// Size 3 civil/southern cities also host the Disguise Pavilion (`铜镜江湖易容阁`) if a shop slot remains free
			if (!isMil && sz >= 3)
			{
				local hasBarber = false;
				foreach (b in this.m.Buildings)
				{
					if (b != null && b.getID() == "building.barber")
					{
						hasBarber = true;
						break;
					}
				}
				if (!hasBarber)
				{
					foreach (slotIdx in validShopSlots)
					{
						if (this.m.Buildings[slotIdx] == null)
						{
							this.addBuilding(::new("scripts/entity/world/settlements/buildings/barber_building"), slotIdx);
							break;
						}
					}
				}
			}
		};

		q.build = @(__original) function()
		{
			__original();
			this.WX_EnsureDisguisePavilion();
			this.WX_ApplyArchVisuals(true);
		};

		q.setOwner = @(__original) function( _o )
		{
			__original(_o);
			if (this.hasSprite("location_banner"))
			{
				local resolvedB = this.WX_ResolveSettlementBanner(null);
				if (resolvedB != null && ::Wuxia.Appearance.brushExists(resolvedB))
					this.getSprite("location_banner").setBrush(resolvedB);
			}
		};

		q.setActive = @(__original) function( _a, _burn = true )
		{
			__original(_a, _burn);
			this.WX_ApplyArchVisuals(true);
		};

		q.onDeserialize = @(__original) function( _in )
		{
			__original(_in);
			this.WX_EnsureDisguisePavilion();
			this.WX_ApplyArchVisuals(true);
		};

		q.getUIInformation = @(__original) function()
		{
			this.WX_EnsureDisguisePavilion();
			local prof = this.WX_ComputeArchProfile();
			this.WX_ApplyArchVisuals(false);
			local ret = __original();
			if (ret != null && typeof ret == "table")
				ret.SubTitle <- this.WX_GetUISubTitle(prof);
			return ret;
		};

		if (::Wuxia.qHas(q, "getTooltip"))
		{
			q.getTooltip = @(__original) function()
			{
				local ret = __original();
				if (ret != null && typeof ret == "array" && this.m.IsActive)
				{
					if (::Wuxia.hasMember(this, "hasBuilding") && this.hasBuilding("building.taxidermist"))
					{
						ret.push({
							id   = 76,
							type = "text",
							icon = "ui/icons/asset_supplies.png",
							text = "丹炉重镇：[color=#0b4a1e]城内设有【百工丹坊】（可开炉炼丹、存取百草药柜与重锻神兵）[/color]"
						});
					}
					if (("SectRelations" in ::Wuxia) && ("getSettlementSects" in ::Wuxia.SectRelations))
					{
						local sects = ::Wuxia.SectRelations.getSettlementSects(this);
						if (sects.len() > 0 && (sects[0] in ::Wuxia.Config.Sects))
						{
							local pSect = ::Wuxia.Config.Sects[sects[0]];
							local rel = ::Wuxia.SectRelations.getRelation(sects[0]);
							local relStr = (rel > 0 ? ("+" + rel) : ("" + rel));
							local extra = "";
							if (sects.len() > 1)
							{
								local subNames = [];
								for (local k = 1; k < sects.len(); ++k)
									if (sects[k] in ::Wuxia.Config.Sects) subNames.push(::Wuxia.Config.Sects[sects[k]].Name);
								if (subNames.len() > 0)
									extra = "；同城堂口：" + subNames[0] + (subNames.len() > 1 ? ("、" + subNames[1]) : "");
							}
							ret.push({
								id   = 77,
								type = "text",
								icon = "ui/wx_icons/wx_glyph_sect_token.png",
								text = "驻地宗门：[color=#5e2c00]【" + pSect.Name + "】[/color]（交情 " + relStr + "）" + extra + "。入城点击「江湖茶肆」可设席论交或请教本门真传秘籍"
							});
						}
					}
				}
				return ret;
			};
		}

		q.onUpdate = @(__original) function()
		{
			local prevAlpha = this.hasSprite("lighting") ? this.getSprite("lighting").Alpha : 0;
			__original();
			if (this.m.IsActive && this.hasSprite("lighting"))
			{
				local curAlpha = this.getSprite("lighting").Alpha;
				if (prevAlpha == 0 && curAlpha > 0)
				{
					this.WX_RebuildHouseTiles(this.WX_ComputeArchProfile(), true);
				}
			}
		};
	});

	// Hook all concrete settlement subclasses (`large_farming_village`, `medium_steppe_village`, `city_state`, etc.)
	// because vanilla subclasses override `build()` without calling `this.settlement.build()`!
	::Wuxia.HooksMod.hookTree("scripts/entity/world/settlement", function( q )
	{
		if (::Wuxia.qHas(q, "build", false))
		{
			q.build = @(__original) function()
			{
				__original();
				if (::Wuxia.hasMember(this, "WX_EnsureDisguisePavilion"))
					this.WX_EnsureDisguisePavilion();
				if (::Wuxia.hasMember(this, "WX_ApplyArchVisuals"))
					this.WX_ApplyArchVisuals(true);
			};
		}
	});

	::Wuxia.WorldVisuals.LastBalancedSeed <- -1;

	::Wuxia.WorldVisuals.ensureAllSettlementWorkshops <- function()
	{
		if (!("World" in getroottable()) || ::World == null || !("EntityManager" in ::World) || ::World.EntityManager == null)
			return;
		foreach (s in ::World.EntityManager.getSettlements())
		{
			if (s != null && s.isAlive())
			{
				if (::Wuxia.hasMember(s, "WX_EnsureDisguisePavilion"))
					s.WX_EnsureDisguisePavilion();
				if (::Wuxia.hasMember(s, "WX_ApplyArchVisuals"))
					s.WX_ApplyArchVisuals(false);
			}
		}
	};

	::Wuxia.WorldVisuals.tuneWorldGenSpacing <- function()
	{
		if (!("World" in ::Const) || !("Settings" in ::Const.World) || ::Const.World.Settings == null)
			return;
		local ws = ::Const.World.Settings;
		if ("MinDistanceToSettlements" in ws && ws.MinDistanceToSettlements < 11)
			ws.MinDistanceToSettlements = 11;
		if ("LandMassPercentage" in ws && ws.LandMassPercentage < 66)
			ws.LandMassPercentage = 66;
	};

	::Wuxia.WorldVisuals.paveFrontierRoad <- function( _fromTown, _toTown, _navSettings )
	{
		if (_fromTown == null || _toTown == null || _fromTown.getTile() == null || _toTown.getTile() == null)
			return false;
		local nav = ::World.getNavigator();
		local path = nav.findPath(_fromTown.getTile(), _toTown.getTile(), _navSettings, 0);
		if (path == null || path.isEmpty())
			return false;

		local tiles = [_fromTown.getTile()];
		while (!path.isEmpty())
		{
			local pt = path.getCurrent();
			path.pop();
			if (pt != null)
				tiles.push(::World.getTile(pt));
		}
		if (tiles.top() != _toTown.getTile())
			tiles.push(_toTown.getTile());

		local hasNotCompat = ("DetailType" in ::Const.World) && ("NotCompatibleWithRoad" in ::Const.World.DetailType);
		for (local i = 0; i < tiles.len(); ++i)
		{
			local cur = tiles[i];
			if (cur == null) continue;
			local wasRoad = cur.HasRoad;
			cur.HasRoad = true;
			if (hasNotCompat && ::Wuxia.hasMember(cur, "clear"))
			{
				try { cur.clear(::Const.World.DetailType.NotCompatibleWithRoad); } catch (_eClr) {}
			}
			local prevT = (i > 0) ? tiles[i - 1] : null;
			local nextT = (i + 1 < tiles.len()) ? tiles[i + 1] : null;
			if ("RoadDirections" in cur)
			{
				if (prevT != null && cur.getDistanceTo(prevT) == 1)
					cur.RoadDirections = cur.RoadDirections | (1 << cur.getDirectionTo(prevT));
				if (nextT != null && cur.getDistanceTo(nextT) == 1)
					cur.RoadDirections = cur.RoadDirections | (1 << cur.getDirectionTo(nextT));
			}
			// Merge smoothly once we reach an already paved main highway (after leaving origin town)
			if (i >= 2 && wasRoad)
				break;
		}

		// Mirror vanilla road-link bookkeeping safely by inspecting existing element type
		if ("ConnectedToByRoads" in _fromTown.m && typeof _fromTown.m.ConnectedToByRoads == "array"
			&& "ConnectedToByRoads" in _toTown.m && typeof _toTown.m.ConnectedToByRoads == "array")
		{
			local sample = null;
			foreach (st in ::World.EntityManager.getSettlements())
			{
				if (st != null && ("ConnectedToByRoads" in st.m) && st.m.ConnectedToByRoads.len() > 0)
				{
					sample = st.m.ConnectedToByRoads[0];
					break;
				}
			}
			if (sample != null)
			{
				if (typeof sample == "instance")
				{
					_fromTown.m.ConnectedToByRoads.push(::WeakTableRef(_toTown));
					_toTown.m.ConnectedToByRoads.push(::WeakTableRef(_fromTown));
				}
				else if (typeof sample == "integer")
				{
					_fromTown.m.ConnectedToByRoads.push(_toTown.getID());
					_toTown.m.ConnectedToByRoads.push(_fromTown.getID());
				}
			}
		}
		return true;
	};

	// Fill vanilla's huge Eastern / Interior uninhabited settlement gaps BEFORE FactionManager assigns town owners!
	::Wuxia.WorldVisuals.balanceWorldSettlementDistribution <- function( _withFallbackRoads = true )
	{
		if (!("World" in getroottable()) || ::World == null || !("EntityManager" in ::World) || ::World.EntityManager == null)
			return 0;
		local towns = ::World.EntityManager.getSettlements();
		if (towns == null || towns.len() < 6)
			return 0;

		local size = ::World.getMapSize();
		local t0 = towns[0].getTile();
		local mapSeed = (t0 != null ? (t0.SquareCoords.X * 197 + t0.SquareCoords.Y * 89) : 53) + size.X * 13;
		if (::Wuxia.WorldVisuals.LastBalancedSeed == mapSeed)
			return 0;
		::Wuxia.WorldVisuals.LastBalancedSeed = mapSeed;

		local allScripts = ::IO.enumerateFiles("scripts/entity/world/settlements");
		if (allScripts == null || allScripts.len() == 0)
			return 0;

		local pickBySubstr = function( _subs, _fallback )
		{
			foreach (sub in _subs)
			{
				foreach (sp in allScripts)
				{
					if (sp.find("/buildings/") != null || sp.find("/situations/") != null) continue;
					if (sp.find(sub) != null) return sp;
				}
			}
			return _fallback;
		};

		local defaultFarming = pickBySubstr(["medium_farming_village", "large_farming_village", "small_farming_village"], null);
		if (defaultFarming == null) return 0;
		local pools = {
			plains  = [
				pickBySubstr(["large_farming_village"], defaultFarming),
				pickBySubstr(["medium_farming_village"], defaultFarming),
				pickBySubstr(["medium_steppe_village"], defaultFarming)
			],
			forest  = [
				pickBySubstr(["large_lumber_village", "medium_lumber_village"], defaultFarming),
				pickBySubstr(["medium_lumber_village", "medium_farming_village"], defaultFarming)
			],
			hills   = [
				pickBySubstr(["medium_mining_village", "large_mining_village"], defaultFarming),
				pickBySubstr(["small_stone_watchtower", "medium_stone_watchtower", "stone_watchtower"], defaultFarming)
			],
			steppe  = [
				pickBySubstr(["large_steppe_village", "medium_steppe_village"], defaultFarming),
				pickBySubstr(["medium_steppe_village"], defaultFarming)
			],
			snow    = [
				pickBySubstr(["medium_tundra_village", "large_tundra_village"], defaultFarming),
				pickBySubstr(["medium_lumber_village", "small_tundra_village"], defaultFarming)
			]
		};

		local tt = ::Const.World.TerrainType;
		local nav = ::World.getNavigator().createSettings();
		nav.ActionPointCosts = ::Const.World.TerrainTypeNavCost_Flat;
		local originalTownTiles = [];
		foreach (town in towns) originalTownTiles.push(town.getTile());

		local spawnedCount = 0;
		local maxAdditions = 5;

		for (local pass = 0; pass < maxAdditions; ++pass)
		{
			towns = ::World.EntityManager.getSettlements();
			local townTiles = [];
			foreach (town in towns) townTiles.push(town.getTile());
			local siteTiles = [];
			foreach (site in ::World.EntityManager.getLocations())
				if (site != null && site.isAlive()) siteTiles.push(site.getTile());
			local bestTile = null;
			local bestNearTown = null;
			local bestGapScore = -999999;

			for (local tx = 14; tx <= size.X - 14; tx += 4)
			{
				for (local ty = 16; ty <= size.Y - 16; ty += 4)
				{
					local tile = ::World.getTileSquare(tx, ty);
					if (tile == null || tile.IsOccupied || tile.HasRoad) continue;
					if (tile.Type == tt.Ocean || tile.Type == tt.Shore || tile.Type == tt.Mountains
						|| tile.Type == tt.Impassable || tile.Type == tt.Urban || tile.Type == tt.Swamp)
						continue;
					if ("Desert" in tt && tile.Type == tt.Desert)
						continue;

					// Require at least 4 open neighbor tiles for Chinese courtyard houses & attached workshops
					local openAdj = 0;
					for (local d = 0; d < 6; ++d)
					{
						if (!tile.hasNextTile(d)) continue;
						local nt = tile.getNextTile(d);
						if (!nt.IsOccupied && nt.Type != tt.Ocean && nt.Type != tt.Shore && nt.Type != tt.Mountains && nt.Type != tt.Impassable)
							openAdj += 1;
					}
					if (openAdj < 4) continue;

					local minTownD = 9999;
					local nearTown = null;
					foreach (idx, townTile in townTiles)
					{
						local td = tile.getDistanceTo(townTile);
						if (td < minTownD)
						{
							minTownD = td;
							nearTown = towns[idx];
						}
					}
					if (minTownD < 19 || minTownD > 25 || nearTown == null)
						continue;
					// Fill gaps between original towns. Extending a chain out into the
					// wilderness consumes the only remote tiles for the native monolith.
					local nearbyOriginals = 0;
					foreach (townTile in originalTownTiles)
						if (tile.getDistanceTo(townTile) <= 29 && ++nearbyOriginals == 2) break;
					if (nearbyOriginals < 2) continue;

					local nearSite = false;
					foreach (siteTile in siteTiles)
					{
						if (siteTile != null && tile.getDistanceTo(siteTile) < 6)
						{
							nearSite = true;
							break;
						}
					}
					if (nearSite) continue;

					local gapScore = ::Math.min(34, minTownD) * 12 + openAdj * 8;
					if (tile.Type == tt.Plains || ("Steppe" in tt && tile.Type == tt.Steppe) || ("Oasis" in tt && tile.Type == tt.Oasis))
						gapScore += 25;
					if (tx >= (size.X * 52) / 100)
						gapScore += 20; // Gently prioritize underserved central-east & eastern regions

					if (gapScore > bestGapScore)
					{
						// Verify land navigation path exists to nearest town (rejects isolated islands/mountain pockets)
						local pCheck = ::World.getNavigator().findPath(tile, nearTown.getTile(), nav, 0);
						if (pCheck != null && !pCheck.isEmpty() && pCheck.getSize() <= 46)
						{
							bestGapScore = gapScore;
							bestTile = tile;
							bestNearTown = nearTown;
						}
					}
				}
			}

			if (bestTile == null || bestNearTown == null)
				break;

			local biomeKey = "plains";
			if (bestTile.Type == tt.Snow || ("Tundra" in tt && bestTile.Type == tt.Tundra) || ("SnowyForest" in tt && bestTile.Type == tt.SnowyForest))
				biomeKey = "snow";
			else if (("Steppe" in tt && bestTile.Type == tt.Steppe) || ("Oasis" in tt && bestTile.Type == tt.Oasis))
				biomeKey = "steppe";
			else if (bestTile.Type == tt.Hills)
				biomeKey = "hills";
			else if (bestTile.Type == tt.Forest || bestTile.Type == tt.LeaveForest || ("AutumnForest" in tt && bestTile.Type == tt.AutumnForest))
				biomeKey = "forest";

			local pList = pools[biomeKey];
			local chosenScript = pList[(pass + ::Math.abs(mapSeed)) % pList.len()];
			local newTown = null;
			try
			{
				newTown = ::World.spawnLocation(chosenScript, bestTile.Coords);
				if (newTown != null)
				{
					newTown.build();
					if (_withFallbackRoads)
						::Wuxia.WorldVisuals.paveFrontierRoad(newTown, bestNearTown, nav);
					spawnedCount += 1;
				}
			}
			catch (_eSp)
			{
				::logWarning("[mod_wuxia] Frontier settlement spawn skipped at (" + bestTile.SquareCoords.X + "," + bestTile.SquareCoords.Y + "): " + _eSp);
				break;
			}
		}

		if (spawnedCount > 0)
			::logInfo("[mod_wuxia] Balanced world settlement distribution: added " + spawnedCount + " regional hub towns into underserved map sectors.");
		return spawnedCount;
	};

	::Wuxia.HooksMod.hook("scripts/mapgen/templates/world/worldmap_generator", function( q )
	{
		if (::Wuxia.qHas(q, "buildRoads", false))
		{
			q.buildRoads = @(__original) function( _rect, _addRoad = true )
			{
				try { ::Wuxia.WorldVisuals.balanceWorldSettlementDistribution(false); } catch (_eB) {}
				return __original(_rect, _addRoad);
			};
		}
	});

	::Wuxia.WorldVisuals.refreshAllSettlementSectLabels <- function()
	{
		if (!("World" in getroottable()) || ::World == null || ::World.EntityManager == null) return;
		foreach (s in ::World.EntityManager.getSettlements())
		{
			if (s != null && s.isAlive() && ::Wuxia.hasMember(s, "WX_RefreshMapSectLabel"))
				s.WX_RefreshMapSectLabel();
		}
	};

	// =========================================================================
	// 3. Town Shop Buildings & Attached Locations Hooks
	// =========================================================================
	::Wuxia.HooksMod.hook("scripts/entity/world/settlements/buildings/building", function( q )
	{
		q.WX_ApplyBuildingVisuals <- function()
		{
			if (this.m.ID in ::Wuxia.Config.WorldVisuals.BuildingMap)
			{
				local bCfg = ::Wuxia.Config.WorldVisuals.BuildingMap[this.m.ID];
				this.m.UIImage = bCfg[0];
				this.m.UIImageNight = (this.m.ID == "building.crowd") ? null : (bCfg[0] + "_night");
				this.m.Name = bCfg[1];
				this.m.Description = bCfg[2];
				if (::Wuxia.hasMember(this.m, "UIImageClosed") && this.m.ID == "building.arena")
					this.m.UIImageClosed = bCfg[0] + "_closed";
			}
		};

		q.getUIImage = @(__original) function()
		{
			this.WX_ApplyBuildingVisuals();
			return __original();
		};

		q.onDeserialize = @(__original) function( _in )
		{
			__original(_in);
			this.WX_ApplyBuildingVisuals();
		};
	});

	::Wuxia.HooksMod.hookTree("scripts/entity/world/settlements/buildings/building", function( q )
	{
		q.create = @(__original) function()
		{
			__original();
			this.WX_ApplyBuildingVisuals();
		};
	});

	::Wuxia.HooksMod.hook("scripts/entity/world/settlements/buildings/crowd_building", function( q )
	{
		q.getUIImage = @(__original) function()
		{
			this.WX_ApplyBuildingVisuals();
			local res = __original();
			if (res == null) return null;
			return "ui/settlements/wx_bldg_crowd";
		};
	});

	::Wuxia.HooksMod.hook("scripts/entity/world/attached_location", function( q )
	{
		q.WX_ApplyAttachedVisuals <- function()
		{
			if (this.m.ID in ::Wuxia.Config.WorldVisuals.AttachedLocationMap)
			{
				local entry = ::Wuxia.Config.WorldVisuals.AttachedLocationMap[this.m.ID];
				this.m.Name = entry[1];
				if (entry.len() >= 3 && entry[2] != null)
					this.m.Description = entry[2];
				if (entry[0] != null)
				{
					this.m.Sprite = entry[0];
					this.m.SpriteDestroyed = entry[0] + "_ruins";
					if (::Wuxia.hasMember(this, "hasSprite") && this.hasSprite("body"))
						this.getSprite("body").setBrush(this.m.IsActive ? this.m.Sprite : this.m.SpriteDestroyed);
					if (::Wuxia.hasMember(this, "hasSprite") && this.hasSprite("lighting"))
						this.getSprite("lighting").setBrush(entry[0] + "_light");
				}
			}
		};

		q.onInit = @(__original) function()
		{
			__original();
			this.WX_ApplyAttachedVisuals();
		};

		q.setActive = @(__original) function( _a )
		{
			__original(_a);
			this.WX_ApplyAttachedVisuals();
		};

		q.onDeserialize = @(__original) function( _in )
		{
			__original(_in);
			this.WX_ApplyAttachedVisuals();
		};
	});

	::Wuxia.HooksMod.hookTree("scripts/entity/world/attached_location", function( q )
	{
		q.create = @(__original) function()
		{
			__original();
			this.WX_ApplyAttachedVisuals();
		};
	});

	// Ensure Southern Oasis City-States (`city_state` overrides `build`) also preserve Wuxia oasis visuals & Chinese names
	::Wuxia.HooksMod.hook("scripts/entity/world/settlements/city_state", function( q )
	{
		if (::Wuxia.qHas(q, "build", false))
		{
			q.build = @(__original) function()
			{
				__original();
				if (::Wuxia.hasMember(this, "WX_ApplyArchVisuals"))
					this.WX_ApplyArchVisuals(true);
			};
		}
	});

	// Localize Wilderness Enemy Camps, Graveyards & Ruins (`scripts/entity/world/location`) into Low-Magic Wuxia Sites
	::Wuxia.HooksMod.hook("scripts/entity/world/location", function( q )
	{
		q.WX_ApplyWildLocationName <- function()
		{
			if (this.isLocationType(::Const.World.LocationType.Unique)) return;
			if (::Wuxia.hasMember(this, "isLocationType") && "LocationType" in ::Const.World && this.isLocationType(::Const.World.LocationType.Settlement))
				return;
			if (::Wuxia.hasMember(this, "getSize"))
				return;

			local tid = (::Wuxia.hasMember(this, "getTypeID") && this.getTypeID() != null) ? this.getTypeID() : "";
			if (tid.find("location.wx_") == 0 || tid.find("attached_location.") == 0) return;
			if (::Wuxia.hasMember(this, "isLocationType") && "LocationType" in ::Const.World && "AttachedLocation" in ::Const.World.LocationType && this.isLocationType(::Const.World.LocationType.AttachedLocation))
				return;

			local cur = this.m.Name;
			if (cur != null && cur != "" && !::Wuxia.WorldVisuals.isAsciiName(cur) && cur.find("Ruins of ") != 0)
			{
				if (::Wuxia.WorldVisuals.isKnownWildCampName(cur))
				{
					if (this.hasLabel("name")) this.getLabel("name").Text = cur;
					return;
				}
			}

			local lt = tid.tolower();
			local cat = "ruins";
			if (lt.find("goblin") != null)
				cat = "goblins";
			else if (lt.find("orc") != null)
				cat = "orcs";
			else if (lt.find("barbarian") != null || lt.find("wildm") != null)
				cat = "barbarians";
			else if (lt.find("nomad") != null)
				cat = "nomads";
			else if (lt.find("bandit") != null || lt.find("brigand") != null)
				cat = "bandits";
			else if (lt.find("undead") != null || lt.find("skeleton") != null || lt.find("vampire") != null || lt.find("zombie") != null || lt.find("graveyard") != null || lt.find("crypt") != null || lt.find("necromancer") != null || lt.find("lich") != null || lt.find("monolith") != null || lt.find("pyramid") != null)
				cat = "undead";
			else if (::Wuxia.hasMember(this, "getFaction") && this.getFaction() != 0)
			{
				local lFac = ::Wuxia.WorldVisuals.safeGetFaction(this.getFaction());
				if (lFac != null && ::Wuxia.hasMember(lFac, "getType") && "FactionType" in ::Const)
				{
					local ft = lFac.getType();
					if (ft == ::Const.FactionType.Goblins) cat = "goblins";
					else if (ft == ::Const.FactionType.Orcs) cat = "orcs";
					else if (ft == ::Const.FactionType.Barbarians) cat = "barbarians";
					else if ("OrientalBandits" in ::Const.FactionType && ft == ::Const.FactionType.OrientalBandits) cat = "nomads";
					else if (ft == ::Const.FactionType.Bandits) cat = "bandits";
					else if (ft == ::Const.FactionType.Undead || ft == ::Const.FactionType.Zombies) cat = "undead";
				}
			}

			local pools = ::Wuxia.Config.WorldVisuals.WildCampNames;
			local pool = (cat in pools) ? pools[cat] : pools.ruins;
			local tile = (::Wuxia.hasMember(this, "getTile")) ? this.getTile() : null;
			local seed = (tile != null) ? ::Math.abs(tile.SquareCoords.X * 59 + tile.SquareCoords.Y * 89) : ::Wuxia.WorldVisuals.hashString(cur != null ? cur : tid);
			local sites = ::Wuxia.hasWorldField("EntityManager") ? ::World.EntityManager.getLocations() : [];
			this.m.Name = ::Wuxia.WorldVisuals.pickUnusedSiteName(pool, seed, sites, this);
			if (this.hasLabel("name"))
				this.getLabel("name").Text = this.m.Name;
		};

		if (::Wuxia.qHas(q, "onInit"))
		{
			q.onInit = @(__original) function()
			{
				__original();
				this.WX_ApplyWildLocationName();
			};
		}
		if (::Wuxia.qHas(q, "onSpawned"))
		{
			q.onSpawned = @(__original) function()
			{
				// Dynamic late-game garrison scaling for wilderness hostile camps (Era 2..4)
				if (!this.isLocationType(::Const.World.LocationType.Unique)
					&& !("WX_EraBoosted" in this.m) && ::Wuxia.hasMember(this.m, "Resources") && this.m.Resources > 0
					&& !(::Wuxia.hasMember(this, "isLocationType") && "LocationType" in ::Const.World && this.isLocationType(::Const.World.LocationType.Settlement))
					&& !::Wuxia.hasMember(this, "getSize"))
				{
					this.m.WX_EraBoosted <- true;
					local threat = ("CombatRules" in ::Wuxia && "getCampaignThreatProfile" in ::Wuxia.CombatRules)
						? ::Wuxia.CombatRules.getCampaignThreatProfile() : { era = 0 };
					if (threat.era >= 2)
					{
						local mult = 1.0 + 0.12 * (threat.era - 1); // +12% / +24% / +36% camp garrison budget
						this.m.Resources = ::Math.min(560, ::Math.round(this.m.Resources * mult).tointeger());
					}
				}
				__original();
				this.WX_ApplyWildLocationName();
			};
		}
		if (::Wuxia.qHas(q, "onDeserialize"))
		{
			q.onDeserialize = @(__original) function( _in )
			{
				__original(_in);
				this.WX_ApplyWildLocationName();
			};
		}
	});

	// =========================================================================
	// 4. World Map Marching Chess Pieces, Caravans, Ships & Party Flags Hooks
	// =========================================================================
	::Wuxia.HooksMod.hook("scripts/entity/world/party", function( q )
	{
		q.WX_RefreshPartyVisuals <- function()
		{
			if (!this.m.IsPlayer)
				::Wuxia.WorldVisuals.localizeVanillaPartyName(this);

			if (this.m.IsPlayer)
			{
				::Wuxia.WorldVisuals.syncPlayerLeadAppearance(this);
			}
			else if (this.hasSprite("body"))
			{
				local spr = this.getSprite("body");
				if (spr.HasBrush)
				{
					local curName = spr.getBrush().Name;
					local patrolSect = ::Wuxia.WorldVisuals.getFlagStr(this.m.Flags, "wx_sect_patrol");
					local patrolFig  = ::Wuxia.WorldVisuals.getFlagStr(this.m.Flags, "wx_sect_patrol_fig");
					local patrolBan  = ::Wuxia.WorldVisuals.getFlagStr(this.m.Flags, "wx_sect_patrol_banner");
					if (patrolSect != "" && patrolFig != "" && ::Wuxia.Appearance.brushExists(patrolFig))
					{
						if (curName != patrolFig)
							spr.setBrush(patrolFig);
						this.m.WX_LastBodyBrush <- patrolFig;
						if (this.hasSprite("banner") && patrolBan != "" && ::Wuxia.Appearance.brushExists(patrolBan))
						{
							this.getSprite("banner").setBrush(patrolBan);
							this.getSprite("banner").Visible = true;
							this.m.WX_LastBannerBrush <- patrolBan;
						}
					}
					else if (curName.find("wx_") != 0 && curName.find("wm_") != 0)
					{
						local targetBrush = null;
						local sectID = ::Wuxia.WorldVisuals.getFlagStr(this.m.Flags, "wx_vendetta");
						if (sectID != "" && (sectID in ::Wuxia.Config.Sects))
						{
							local vParty = ::Wuxia.Config.Sects[sectID].VendettaParty;
							if (vParty in ::Wuxia.Config.WorldVisuals.VendettaVisualMap)
							{
								local vSpec = ::Wuxia.Config.WorldVisuals.VendettaVisualMap[vParty];
								targetBrush = vSpec[0];
								if (this.hasSprite("banner"))
									this.getSprite("banner").setBrush(vSpec[1]);
							}
						}

						if (targetBrush == null)
							targetBrush = ::Wuxia.WorldVisuals.mapPartyBodyBrush(curName, this);

						if (targetBrush != null && targetBrush != curName)
						{
							spr.setBrush(targetBrush);
							curName = targetBrush;
						}
						this.m.WX_LastBodyBrush <- curName;
					}
				}
			}

			if (this.hasSprite("banner"))
			{
				local bSpr = this.getSprite("banner");
				local pBanCheck = ::Wuxia.WorldVisuals.getFlagStr(this.m.Flags, "wx_sect_patrol_banner");
				if (pBanCheck != "" && ::Wuxia.Appearance.brushExists(pBanCheck))
				{
					bSpr.setBrush(pBanCheck);
					this.m.WX_LastBannerBrush <- pBanCheck;
				}
				else if (bSpr.HasBrush)
				{
					local curB = bSpr.getBrush().Name;
					if (!("WX_LastBannerBrush" in this.m) || this.m.WX_LastBannerBrush != curB)
					{
						local mappedB = null;
						local vFlag = ::Wuxia.WorldVisuals.getFlagStr(this.m.Flags, "wx_vendetta");
						if (!this.m.IsPlayer && vFlag == "" && ::Wuxia.hasMember(this, "getFaction"))
						{
							local fac = ::Wuxia.WorldVisuals.safeGetFaction(this.getFaction());
							if (fac != null)
							{
								if (::Wuxia.hasMember(fac, "getSettlements"))
								{
									local fSets = fac.getSettlements();
									if (fSets != null && fSets.len() == 1 && fSets[0] != null && ::Wuxia.hasMember(fSets[0], "WX_ResolveSettlementBanner"))
										mappedB = fSets[0].WX_ResolveSettlementBanner(null);
								}
								if (mappedB == null && ::Wuxia.hasMember(fac, "getBannerSmall"))
									mappedB = ::Wuxia.WorldVisuals.mapWorldBannerBrush(fac.getBannerSmall());
							}
						}
						if (mappedB == null)
							mappedB = ::Wuxia.WorldVisuals.mapWorldBannerBrush(curB);
						if (mappedB != null && mappedB != curB && ::Wuxia.Appearance.brushExists(mappedB))
						{
							bSpr.setBrush(mappedB);
							curB = mappedB;
						}
						this.m.WX_LastBannerBrush <- curB;
					}
				}
			}
		};

		if (::Wuxia.qHas(q, "getTooltip"))
		{
			q.getTooltip = @(__original) function()
			{
				local ret = __original();
				if (ret != null && typeof ret == "array" && this.m.Flags != null && ("SectRelations" in ::Wuxia))
				{
					local psid = ::Wuxia.WorldVisuals.getFlagStr(this.m.Flags, "wx_sect_patrol");
					if (psid == "") psid = ::Wuxia.WorldVisuals.getFlagStr(this.m.Flags, "wx_vendetta");
					if (psid != "" && (psid in ::Wuxia.Config.Sects))
					{
						if ("discoverSect" in ::Wuxia.SectRelations)
							::Wuxia.SectRelations.discoverSect(psid);
						local pSect = ::Wuxia.Config.Sects[psid];
						local rel = ::Wuxia.SectRelations.getRelation(psid);
						local relStr = (rel > 0 ? ("+" + rel) : ("" + rel));
						local anchor = ::Wuxia.SectRelations.getSectAnchorInfo(psid);
						local homeNote = (anchor.townName != "") ? (" · 驻地：" + anchor.townName) : "";
						ret.push({
							id   = 78,
							type = "text",
							icon = "ui/wx_icons/wx_glyph_sect_token.png",
							text = "所属宗门：[color=#5e2c00]【" + pSect.Name + "】[/color]（当前交情 " + relStr + homeNote + "）"
						});
					}
				}
				return ret;
			};
		}

		q.onAfterInit = @(__original) function()
		{
			__original();
			this.WX_RefreshPartyVisuals();
		};

		q.onDeserialize = @(__original) function( _in )
		{
			__original(_in);
			this.m.WX_LastBodyBrush <- "";
			this.m.WX_LastBannerBrush <- "";
			this.WX_RefreshPartyVisuals();
		};

		q.onUpdate = @(__original) function()
		{
			__original();
			if (this.m.IsPlayer && this.hasSprite("body"))
			{
				local bs = this.getSprite("body");
				local bName = bs.HasBrush ? bs.getBrush().Name : "";
				// Immediately re-sync if vanilla switched to/from ship or reset figure_player_*
				if (bName == "figure_player_ship" || bName.find("figure_player_") == 0)
					::Wuxia.WorldVisuals.syncPlayerLeadAppearance(this);
				local fl = bs.isFlippedHorizontally();
				foreach (sn in ["wx_wm_hat_back", "wx_wm_head", "wx_wm_beard", "wx_wm_hair", "wx_wm_hat_front"])
				{
					if (this.hasSprite(sn))
						this.getSprite(sn).setHorizontalFlipping(fl);
				}
			}
			local nowT = ("Time" in getroottable() && ::Time != null) ? ::Time.getVirtualTimeF() : 0.0;
			if ("WX_NextVisTime" in this.m && nowT < this.m.WX_NextVisTime)
				return;
			this.m.WX_NextVisTime <- nowT + 2.0;
			this.WX_RefreshPartyVisuals();
		};
	});

	// Localize Noble House Faction Names, Mottos & Descriptions unconditionally (even under transliterated l10n mods)
	::Wuxia.HooksMod.hook("scripts/factions/noble_faction", function( q )
	{
		q.WX_EnsureChineseHouseName <- function()
		{
			if ("Purify" in ::Wuxia && "NobleHouses" in ::Wuxia.Purify)
			{
				local list = ::Wuxia.Purify.NobleHouses;
				local entry = list[::Math.abs(this.getID()) % list.len()];
				this.m.Name = entry[0];
				if (::Wuxia.hasMember(this.m, "Motto")) this.m.Motto = entry[1];
				if (::Wuxia.hasMember(this.m, "Description")) this.m.Description = entry[2];
			}
			else if (::Wuxia.WorldVisuals.isAsciiName(this.m.Name))
			{
				local pool = ::Wuxia.Config.WorldVisuals.NobleHouseNames;
				this.m.Name = pool[::Math.abs(this.getID()) % pool.len()];
			}
		};

		q.onDeserialize = @(__original) function( _in )
		{
			__original(_in);
			this.WX_EnsureChineseHouseName();
		};

		q.getName = @(__original) function()
		{
			this.WX_EnsureChineseHouseName();
			return __original();
		};
	});
}
