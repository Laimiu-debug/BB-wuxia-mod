// Independent Wuxia Sect Mountain Gates / Manors (`location.wx_sect_sanctum`), Fog-of-War Discovery & Tavern Tea-House System
// Zero Faction ID cost (strictly preserves < 64 Faction ID engine guardrail!).

::Wuxia.SectRelations.SanctumSpecs <- {
	shaolin  = { Prefix = "少室山门", Brush = "wx_set_sect_monastery", Banner = "banner_53" },
	taihe    = { Prefix = "太和云顶", Brush = "wx_set_sect_mountain",  Banner = "banner_54" },
	qingfeng = { Prefix = "翠屏试剑峰", Brush = "wx_set_sect_mountain", Banner = "banner_52" },
	tangmen  = { Prefix = "巴蜀幽篁堡", Brush = "wx_att_sect_dojo",    Banner = "banner_59" },
	wudu     = { Prefix = "南疆万蛊坛", Brush = "wx_set_outpost_01",   Banner = "wx_fbanner_outlaw_01" },
	gaibang  = { Prefix = "君山聚义总舵", Brush = "wx_set_water_market", Banner = "banner_60" },
	weiyuan  = { Prefix = "顺天总镖号", Brush = "wx_att_sect_dojo",    Banner = "banner_51" },
	heifeng  = { Prefix = "黑风绝岭总寨", Brush = "wx_set_outpost_01", Banner = "wx_fbanner_outlaw_01" },
	shenji   = { Prefix = "西塞神机堡", Brush = "wx_set_garrison_02",  Banner = "wx_fbanner_south_01" },
	pishan   = { Prefix = "长白聚义山庄", Brush = "wx_att_sect_dojo",  Banner = "banner_58" },
	zhenyue  = { Prefix = "太行铸锤崖", Brush = "wx_set_sect_mountain", Banner = "banner_55" },
	jiujie   = { Prefix = "云梦烟波坞", Brush = "wx_set_water_market", Banner = "banner_57" },
	yinsha   = { Prefix = "流沙暗影分坛", Brush = "wx_set_outpost_01", Banner = "banner_61" },
	xuanbing = { Prefix = "昆仑琼瑶宫", Brush = "wx_set_sect_mountain", Banner = "banner_56" }
};

::Wuxia.SectRelations.MajorSectPriority <- [
	"shaolin", "taihe", "qingfeng", "tangmen", "gaibang", "weiyuan", "xuanbing",
	"pishan", "zhenyue", "jiujie", "shenji", "wudu", "heifeng", "yinsha"
];

::Wuxia.SectRelations.AnchorCache <- {
	MapKey          = "",
	TownToSects     = {},
	SectToSanctumID = {}
};

::Wuxia.SectRelations.getExchangeSects <- function()
{
	local ids = [];
	foreach (id, sect in ::Wuxia.Config.Sects)
		if (sect.ShopManuals.len() > 0) ids.push(id);
	ids.sort();
	return ids;
};

::Wuxia.SectRelations.getRegionLabel <- function( _region )
{
	if (_region != null && (_region in ::Wuxia.Config.SectRegions))
		return ::Wuxia.Config.SectRegions[_region];
	return "四方江湖";
};

::Wuxia.SectRelations.getSanctumVisualSpec <- function( _sectID )
{
	local sDef = (_sectID in ::Wuxia.Config.Sects) ? ::Wuxia.Config.Sects[_sectID] : null;
	local sName = (sDef != null) ? sDef.Name : "隐世山门";
	local desc = (sDef != null && "Description" in sDef) ? sDef.Description : "名动一方的江湖宗门山门所在。";
	local reg = (sDef != null && "Region" in sDef) ? sDef.Region : "mountains";
	local align = (sDef != null && "Alignment" in sDef) ? sDef.Alignment : "neutral";

	if (_sectID in ::Wuxia.SectRelations.SanctumSpecs)
	{
		local sp = ::Wuxia.SectRelations.SanctumSpecs[_sectID];
		return {
			FullName    = sp.Prefix + " · " + sName,
			WorldBrush  = sp.Brush,
			BannerBrush = sp.Banner,
			Description = desc
		};
	}

	local brush = "wx_att_sect_dojo";
	local prefix = "隐世山庄";
	local banner = "banner_52";

	if (align == "outlaw")
	{
		brush = "wx_set_outpost_01";
		prefix = "险谷总寨";
		banner = "wx_fbanner_outlaw_01";
	}
	else if (reg == "mountains" || reg == "snow")
	{
		brush = (_sectID.find("si") != null || _sectID.find("chan") != null) ? "wx_set_sect_monastery" : "wx_set_sect_mountain";
		prefix = (reg == "snow") ? "寒山剑庐" : "幽岳山门";
		banner = (reg == "snow") ? "banner_56" : "banner_54";
	}
	else if (reg == "swamp")
	{
		brush = "wx_set_water_market";
		prefix = "烟波水寨";
		banner = "wx_fbanner_civ_04";
	}
	else if (reg == "desert")
	{
		brush = "wx_att_sect_dojo";
		prefix = "瀚海别院";
		banner = "wx_fbanner_south_02";
	}
	else if (reg == "forest")
	{
		brush = "wx_att_sect_dojo";
		prefix = "幽林山庄";
		banner = "banner_59";
	}
	else
	{
		brush = "wx_att_sect_dojo";
		prefix = "名门山庄";
		banner = "banner_51";
	}

	return {
		FullName    = prefix + " · " + sName,
		WorldBrush  = brush,
		BannerBrush = banner,
		Description = desc
	};
};

::Wuxia.SectRelations.getLocalRegion <- function()
{
	if (!("World" in getroottable()) || ::World == null || !("State" in ::World) || ::World.State == null || ::World.State.getPlayer() == null)
		return "plains";

	local tile = ::World.State.getPlayer().getTile();
	if (tile == null) return "plains";

	local t = tile.Type;
	local tt = ::Const.World.TerrainType;
	if (("Snow" in tt && t == tt.Snow) || ("Tundra" in tt && t == tt.Tundra))
		return "snow";
	if (("Desert" in tt && t == tt.Desert) || ("Oasis" in tt && t == tt.Oasis))
		return "desert";
	if (("Mountains" in tt && t == tt.Mountains) || ("Hills" in tt && t == tt.Hills))
		return "mountains";
	if (("Swamp" in tt && t == tt.Swamp))
		return "swamp";
	if (("Forest" in tt && t == tt.Forest) || ("LeaveForest" in tt && t == tt.LeaveForest) || ("AutumnForest" in tt && t == tt.AutumnForest))
		return "forest";
	return "plains";
};

::Wuxia.SectRelations.pickRegionalTrio <- function( _region )
{
	local localPool = [];
	local otherPool = [];

	foreach (id, sect in ::Wuxia.Config.Sects)
	{
		if (sect.ShopManuals.len() == 0) continue;
		if (("Region" in sect) && sect.Region == _region)
			localPool.push(id);
		else
			otherPool.push(id);
	}

	local chosen = [];
	local pickUniqueFrom = function( _arr )
	{
		if (_arr.len() == 0) return null;
		local idx = ::Math.rand(0, _arr.len() - 1);
		local val = _arr[idx];
		_arr.remove(idx);
		return val;
	};

	while (chosen.len() < 2 && localPool.len() > 0)
		chosen.push(pickUniqueFrom(localPool));
	while (chosen.len() < 3 && otherPool.len() > 0)
		chosen.push(pickUniqueFrom(otherPool));
	while (chosen.len() < 3 && localPool.len() > 0)
		chosen.push(pickUniqueFrom(localPool));
	return chosen;
};

::Wuxia.SectRelations.getFlagKey <- function( _sectID )
{
	return "wx_sect_rel_" + _sectID;
};

::Wuxia.SectRelations.getRelation <- function( _sectID )
{
	if (!(_sectID in ::Wuxia.Config.Sects)) return 0;
	local def = ::Wuxia.Config.Sects[_sectID];
	if (!("World" in getroottable()) || ::World == null || !("Flags" in ::World) || ::World.Flags == null)
		return def.DefaultRel;

	local key = ::Wuxia.SectRelations.getFlagKey(_sectID);
	if (!::World.Flags.has(key))
		::World.Flags.set(key, def.DefaultRel);
	return ::World.Flags.getAsInt(key);
};

::Wuxia.SectRelations.discoverSect <- function( _sectID )
{
	if (_sectID == null || _sectID == "" || !(_sectID in ::Wuxia.Config.Sects)) return;
	if ("World" in getroottable() && ::World != null && ("Flags" in ::World) && ::World.Flags != null)
		::World.Flags.set("wx_sect_known_" + _sectID, true);
};

::Wuxia.SectRelations.isSectKnown <- function( _sectID )
{
	if (_sectID == null || _sectID == "" || !(_sectID in ::Wuxia.Config.Sects)) return false;
	if (!("World" in getroottable()) || ::World == null || !("Flags" in ::World) || ::World.Flags == null)
		return true;

	if (::World.Flags.get("wx_sect_known_" + _sectID))
		return true;

	local def = ::Wuxia.Config.Sects[_sectID];
	local curRel = ::Wuxia.SectRelations.getRelation(_sectID);
	if (curRel != def.DefaultRel || ::Wuxia.SectRelations.isVendettaActive(_sectID))
	{
		::World.Flags.set("wx_sect_known_" + _sectID, true);
		return true;
	}

	// Famous household Three-Pillars (`少室禅院`, `太和玄门`, `天下丐帮`) are known by reputation even before finding their mountain gate
	if (_sectID == "shaolin" || _sectID == "taihe" || _sectID == "gaibang")
		return true;

	return false;
};

::Wuxia.SectRelations.isDiscovered <- function( _sectID )
{
	return ::Wuxia.SectRelations.isSectKnown(_sectID);
};

::Wuxia.SectRelations.addRelation <- function( _sectID, _delta, _fromRipple = false )
{
	if (!(_sectID in ::Wuxia.Config.Sects)) return 0;
	::Wuxia.SectRelations.discoverSect(_sectID);
	local adjDelta = _delta;
	// Retinue Negotiator (`茶楼折冲客`) grants +20% positive sect standing gain!
	if (!_fromRipple && adjDelta > 0 && "World" in getroottable() && ::World != null && ("Retinue" in ::World) && ::World.Retinue != null && ::World.Retinue.hasFollower("follower.negotiator"))
	{
		adjDelta = ::Math.max(adjDelta + 1, ::Math.round(adjDelta * 1.20).tointeger());
	}
	// Origin rule: `初走江湖` (`scenario.wx_jianghu_start`) grants +10% positive sect standing gain!
	if (!_fromRipple && adjDelta > 0 && "World" in getroottable() && ::World != null && ("Assets" in ::World) && ::World.Assets != null && ::World.Assets.getOrigin() != null && ::World.Assets.getOrigin().getID() == "scenario.wx_jianghu_start")
	{
		adjDelta = ::Math.max(adjDelta + 1, ::Math.round(adjDelta * 1.10).tointeger());
	}
	local cur = ::Wuxia.SectRelations.getRelation(_sectID);
	local next = ::Math.max(-100, ::Math.min(100, cur + adjDelta));
	if ("World" in getroottable() && ::World != null && ("Flags" in ::World) && ::World.Flags != null)
		::World.Flags.set(::Wuxia.SectRelations.getFlagKey(_sectID), next);

	// Righteous vs Outlaw Jianghu alignment coupling: currying heavy favor with one camp cools rival camp sects slightly
	if (!_fromRipple && adjDelta >= 8 && "World" in getroottable() && ::World != null && ("Flags" in ::World) && ::World.Flags != null)
	{
		local myAlign = ("Alignment" in ::Wuxia.Config.Sects[_sectID]) ? ::Wuxia.Config.Sects[_sectID].Alignment : "neutral";
		local oppAlign = (myAlign == "righteous") ? "outlaw" : (myAlign == "outlaw" ? "righteous" : null);
		if (oppAlign != null)
		{
			local nudged = 0;
			foreach (otherID, otherDef in ::Wuxia.Config.Sects)
			{
				if (otherID == _sectID || otherDef.Alignment != oppAlign) continue;
				if (!::Wuxia.SectRelations.isSectKnown(otherID)) continue;
				local oRel = ::Wuxia.SectRelations.getRelation(otherID);
				if (oRel > -25)
				{
					::Wuxia.SectRelations.addRelation(otherID, -2, true);
					nudged += 1;
					if (nudged >= 2) break;
				}
			}
		}
	}
	return next;
};

::Wuxia.SectRelations.isVendettaActive <- function( _sectID )
{
	if (!(_sectID in ::Wuxia.Config.Sects)) return false;
	return ::Wuxia.SectRelations.getRelation(_sectID) <= ::Wuxia.Config.Sects[_sectID].VendettaRel;
};

::Wuxia.SectRelations.getSettlementRegion <- function( _s )
{
	if (_s == null) return "plains";
	if (::Wuxia.hasMember(_s, "isSouthern") && _s.isSouthern()) return "desert";

	local tile = (::Wuxia.hasMember(_s, "getTile")) ? _s.getTile() : null;
	if (tile != null && ("TerrainType" in ::Const.World))
	{
		local tt = ::Const.World.TerrainType;
		local hasMtn = false;
		local hasForest = false;
		local hasSwamp = false;
		local hasSnow = false;

		if (tile.Type == tt.Snow || ("Tundra" in tt && tile.Type == tt.Tundra)) hasSnow = true;
		if (tile.Type == tt.Swamp) hasSwamp = true;
		if (tile.Type == tt.Mountains || tile.Type == tt.Hills) hasMtn = true;
		if (tile.Type == tt.Forest || tile.Type == tt.LeaveForest || ("AutumnForest" in tt && tile.Type == tt.AutumnForest)) hasForest = true;

		for (local d = 0; d < 6; ++d)
		{
			if (!tile.hasNextTile(d)) continue;
			local nt = tile.getNextTile(d).Type;
			if (nt == tt.Snow || ("SnowyForest" in tt && nt == tt.SnowyForest)) hasSnow = true;
			if (nt == tt.Mountains || nt == tt.Hills) hasMtn = true;
			if (nt == tt.Forest || nt == tt.LeaveForest || ("AutumnForest" in tt && nt == tt.AutumnForest)) hasForest = true;
			if (nt == tt.Swamp) hasSwamp = true;
		}

		if (hasSnow) return "snow";
		if (hasMtn) return "mountains";
		if (hasForest) return "forest";
		if (hasSwamp || (::Wuxia.hasMember(_s, "isCoastal") && _s.isCoastal())) return "swamp";
	}
	return "plains";
};

::Wuxia.SectRelations.findSanctumSpawnTile <- function( _region, _seed )
{
	if (!("World" in getroottable()) || ::World == null || ::World.EntityManager == null) return null;
	local size = ::World.getMapSize();
	local tt = ::Const.World.TerrainType;
	local towns = ::World.EntityManager.getSettlements();
	local locs = ::World.EntityManager.getLocations();

	local totalTiles = (size.X - 6) * (size.Y - 6);
	if (totalTiles <= 0) return null;
	local w = size.X - 6;
	local isExpandedMap = (size.X >= 145);
	local minTownSep = isExpandedMap ? 7 : 5;
	local maxTownSep = isExpandedMap ? 28 : 20;
	local minSiteSep = isExpandedMap ? 7 : 5;

	local bestTile = null;
	local bestScore = -999999;
	local samples = ::Math.min(1200, totalTiles);
	local stepOffset = ::Math.abs(_seed * 193 + 37) % totalTiles;

	for (local i = 0; i < samples; i = ++i)
	{
		local idx = (stepOffset + (i * totalTiles) / samples) % totalTiles;
		local tx = 3 + (idx % w);
		local ty = 3 + (idx / w);
		local tile = ::World.getTileSquare(tx, ty);
		if (tile == null || tile.IsOccupied || tile.HasRoad) continue;
		if (tile.Type == tt.Ocean || tile.Type == tt.Shore || tile.Type == tt.Mountains || tile.Type == tt.Impassable || tile.Type == tt.Urban)
			continue;

		// Keep independent Mountain Gates / Manors spaciously separated from Towns & other Sites!
		local minTownD = 9999;
		local tooClose = false;
		foreach (tw in towns)
		{
			if (tw == null || !tw.isAlive() || tw.getTile() == null) continue;
			local d = tile.getDistanceTo(tw.getTile());
			if (d < minTownSep) { tooClose = true; break; }
			if (d < minTownD) minTownD = d;
		}
		if (tooClose || minTownD > maxTownSep) continue;

		foreach (lc in locs)
		{
			if (lc != null && lc.isAlive() && lc.getTile() != null && tile.getDistanceTo(lc.getTile()) < minSiteSep)
			{
				tooClose = true;
				break;
			}
		}
		if (tooClose) continue;

		local adjMtn = false;
		local adjWater = false;
		local adjRoad = false;
		for (local d = 0; d < 6; ++d)
		{
			if (!tile.hasNextTile(d)) continue;
			local nt = tile.getNextTile(d);
			if (nt.Type == tt.Mountains || nt.Type == tt.Hills) adjMtn = true;
			if (nt.Type == tt.Ocean || nt.Type == tt.Shore || nt.Type == tt.Swamp) adjWater = true;
			if (nt.HasRoad) adjRoad = true;
		}

		local score = 0;
		if (_region == "mountains")
		{
			if (tile.Type == tt.Hills) score += 260;
			if (adjMtn) score += 220;
			if (tile.Type == tt.Forest || tile.Type == tt.LeaveForest) score += 80;
		}
		else if (_region == "snow")
		{
			if (tile.Type == tt.Snow || ("SnowyForest" in tt && tile.Type == tt.SnowyForest)) score += 320;
			else if ("Tundra" in tt && tile.Type == tt.Tundra) score += 220;
			if (adjMtn) score += 80;
		}
		else if (_region == "desert")
		{
			if ("Oasis" in tt && tile.Type == tt.Oasis) score += 320;
			else if ("Desert" in tt && tile.Type == tt.Desert) score += 260;
			else if ("Steppe" in tt && tile.Type == tt.Steppe) score += 150;
		}
		else if (_region == "forest")
		{
			if (tile.Type == tt.Forest || tile.Type == tt.LeaveForest || ("AutumnForest" in tt && tile.Type == tt.AutumnForest)) score += 300;
			if (adjMtn) score += 60;
		}
		else if (_region == "swamp")
		{
			if (tile.Type == tt.Swamp) score += 300;
			if (adjWater) score += 180;
		}
		else // plains
		{
			if (tile.Type == tt.Plains || ("Steppe" in tt && tile.Type == tt.Steppe)) score += 240;
			if (adjRoad) score += 110;
		}

		// Prefer convenient 6..13 tile ring around settlements so reachable without road clutter
		if (minTownD >= 6 && minTownD <= 13) score += 75;

		if (score > bestScore)
		{
			bestScore = score;
			bestTile = tile;
		}
	}
	return bestTile;
};

// Spawn & index 18 Independent Sect Mountain Gates / Manors / Strongholds (`location.wx_sect_sanctum`) on the World Map!
// Zero Settlements polluted (`TownToSects` stays empty), Zero Faction IDs consumed!
::Wuxia.SectRelations.ensureWorldSectSanctums <- function()
{
	if (!("World" in getroottable()) || ::World == null || !("EntityManager" in ::World) || ::World.EntityManager == null || !("Flags" in ::World) || ::World.Flags == null)
		return;

	local rawTowns = ::World.EntityManager.getSettlements();
	if (rawTowns == null || rawTowns.len() == 0) return;

	local firstT = rawTowns[0].getTile();
	local mapSeed = (firstT != null) ? ::Math.abs(firstT.SquareCoords.X * 131 + firstT.SquareCoords.Y * 71 + rawTowns.len() * 19) : 97;
	local key = rawTowns.len() + ":" + rawTowns[0].getID() + ":" + mapSeed;

	local sectToSanctum = {};
	foreach (loc in ::World.EntityManager.getLocations())
	{
		if (loc != null && loc.isAlive() && loc.getTypeID() == "location.wx_sect_sanctum")
		{
			local lsid = ("getSectID" in loc) ? loc.getSectID() : loc.getFlags().get("wx_sect_id");
			if (lsid != null && lsid != "")
				sectToSanctum[lsid] <- loc.getID();
		}
	}

	if (!::World.Flags.get("wx_sanctums_spawned_v1"))
	{
		// Select 18 Sects for independent World-Map Sanctums: 14 Major Sects + 4 deterministic Regional Manors
		local chosen = [];
		local seen = {};
		foreach (ms in ::Wuxia.SectRelations.MajorSectPriority)
		{
			if (ms in ::Wuxia.Config.Sects)
			{
				chosen.push(ms);
				seen[ms] <- true;
			}
		}

		local minorPool = [];
		foreach (sid, sDef in ::Wuxia.Config.Sects)
		{
			if (!(sid in seen) && sDef.ShopManuals.len() > 0)
				minorPool.push(sid);
		}
		minorPool.sort();
		local mSize = ::World.getMapSize();
		local extraMinorCount = (mSize != null && mSize.X >= 145) ? 8 : 4;
		for (local k = 0; k < extraMinorCount && minorPool.len() > 0; k = ++k)
		{
			local pickIdx = (mapSeed + k * 7) % minorPool.len();
			local picked = minorPool[pickIdx];
			minorPool.remove(pickIdx);
			chosen.push(picked);
			seen[picked] <- true;
		}

		local p = ::Wuxia.hasWorldField("State") ? ::World.State.getPlayer() : null;
		local pTile = (p != null) ? p.getTile() : null;

		for (local idx = 0; idx < chosen.len(); idx = ++idx)
		{
			local sid = chosen[idx];
			if (sid in sectToSanctum) continue;

			local sDef = ::Wuxia.Config.Sects[sid];
			local reg = ("Region" in sDef) ? sDef.Region : "mountains";
			local sTile = ::Wuxia.SectRelations.findSanctumSpawnTile(reg, mapSeed + idx * 41);
			if (sTile == null) continue;

			local site = ::World.spawnLocation("scripts/entity/world/locations/wx_sect_sanctum", sTile.Coords);
			if (site == null) continue;
			site.setSectID(sid);
			site.onSpawned();

			// Reveal only if player has high starting standing (e.g. Origin Sect >= 20) or it's a nearby Escort/Righteous hall within 16 tiles!
			local startRel = ::Wuxia.SectRelations.getRelation(sid);
			local nearStart = (pTile != null && sDef.Alignment == "righteous" && pTile.getDistanceTo(sTile) <= 16);
			if (startRel >= 20 || nearStart)
			{
				site.setDiscovered(true);
				::Wuxia.SectRelations.discoverSect(sid);
			}
			else
			{
				site.setDiscovered(false);
			}

			sectToSanctum[sid] <- site.getID();
			::World.Flags.set("wx_sanctum_id_" + sid, site.getID());
		}

		::World.Flags.set("wx_sanctums_spawned_v1", true);
	}

	::Wuxia.SectRelations.AnchorCache.MapKey = key;
	::Wuxia.SectRelations.AnchorCache.TownToSects = {};
	::Wuxia.SectRelations.AnchorCache.SectToSanctumID = sectToSanctum;
};

// Keep backwards-compatible alias
::Wuxia.SectRelations.ensureWorldSectAnchors <- function()
{
	::Wuxia.SectRelations.ensureWorldSectSanctums();
};

// Sects are NEVER bound onto towns anymore — returns empty array!
::Wuxia.SectRelations.getSettlementSects <- function( _settlement )
{
	return [];
};

::Wuxia.SectRelations.getSectSanctumEntity <- function( _sectID )
{
	if (_sectID == null || _sectID == "" || !::Wuxia.hasWorldField("EntityManager"))
		return null;
	::Wuxia.SectRelations.ensureWorldSectSanctums();
	if (_sectID in ::Wuxia.SectRelations.AnchorCache.SectToSanctumID)
	{
		local eid = ::Wuxia.SectRelations.AnchorCache.SectToSanctumID[_sectID];
		local ent = ::World.getEntityByID(eid);
		if (ent != null && ent.isAlive()) return ent;
	}
	return null;
};

::Wuxia.SectRelations.getSectAnchorInfo <- function( _sectID )
{
	local empty = { townName = "", dir = "", dist = -1, townObj = null, sanctumObj = null, hasSanctum = false, isDiscovered = false };
	if (!(_sectID in ::Wuxia.Config.Sects) || !::Wuxia.hasWorldField("EntityManager"))
		return empty;

	local sanctum = ::Wuxia.SectRelations.getSectSanctumEntity(_sectID);
	local sDef = ::Wuxia.Config.Sects[_sectID];
	local regLbl = ::Wuxia.SectRelations.getRegionLabel(("Region" in sDef) ? sDef.Region : "plains");

	if (sanctum == null)
	{
		return {
			townName     = "四方游历 · " + regLbl + "酒肆茶座可遇传人",
			dir          = "",
			dist         = -1,
			townObj      = null,
			sanctumObj   = null,
			hasSanctum   = false,
			isDiscovered = false
		};
	}

	local disc = sanctum.isDiscovered();
	if (!disc)
	{
		return {
			townName     = "山门隐于【" + regLbl + "】迷雾（可探图或赴酒肆打探方位）",
			dir          = "",
			dist         = -1,
			townObj      = sanctum,
			sanctumObj   = sanctum,
			hasSanctum   = true,
			isDiscovered = false
		};
	}

	local p = ::Wuxia.hasWorldField("State") ? ::World.State.getPlayer() : null;
	local pTile = (p != null) ? p.getTile() : null;
	local tTile = sanctum.getTile();
	local dir = (pTile != null && tTile != null && ("ShanHai" in ::Wuxia)) ? ::Wuxia.ShanHai.getCompassDirection(pTile, tTile) : "";
	local dist = (pTile != null && tTile != null) ? pTile.getDistanceTo(tTile) : -1;

	return {
		townName     = sanctum.getName(),
		dir          = dir,
		dist         = dist,
		townObj      = sanctum,
		sanctumObj   = sanctum,
		hasSanctum   = true,
		isDiscovered = true
	};
};

// Detect if the player is currently visiting a Sect Mountain Gate (`location.wx_sect_sanctum`)
::Wuxia.SectRelations.getCurrentSanctum <- function()
{
	if (!::Wuxia.hasWorldField("State") || !::Wuxia.hasWorldField("Flags") || !::Wuxia.hasWorldField("EntityManager"))
		return null;
	local p = ::World.State.getPlayer();
	if (p == null || p.getTile() == null) return null;
	local pTile = p.getTile();

	local activeSid = ::World.Flags.get("wx_active_sanctum_sect");
	if (activeSid != null && typeof activeSid == "string" && activeSid != "")
	{
		local ent = ::Wuxia.SectRelations.getSectSanctumEntity(activeSid);
		if (ent != null && ent.getTile() != null && pTile.getDistanceTo(ent.getTile()) <= 1)
			return ent;
	}

	foreach (loc in ::World.EntityManager.getLocations())
	{
		if (loc != null && loc.isAlive() && loc.getTypeID() == "location.wx_sect_sanctum" && loc.getTile() != null && pTile.getDistanceTo(loc.getTile()) == 0)
			return loc;
	}
	return null;
};

::Wuxia.SectRelations.getCurrentTown <- function()
{
	if (!::Wuxia.hasWorldField("State"))
		return null;
	local ws = ::World.State;
	if (::Wuxia.hasMember(ws, "getCurrentTown"))
	{
		local ct = ws.getCurrentTown();
		if (ct != null && (!::Wuxia.hasMember(ct, "isAlive") || ct.isAlive()))
			return ct;
	}
	if ("m" in ws && ("CurrentTown" in ws.m) && ws.m.CurrentTown != null)
		return ws.m.CurrentTown;

	local p = ws.getPlayer();
	if (p == null || p.getTile() == null || !::Wuxia.hasWorldField("EntityManager"))
		return null;
	local pTile = p.getTile();
	foreach (s in ::World.EntityManager.getSettlements())
	{
		if (s != null && s.isAlive() && s.getTile() != null && pTile.getDistanceTo(s.getTile()) == 0)
			return s;
	}
	return null;
};

// Resolve Roaming Disciples seated in `_town`'s Tavern Tea-House (`迎客酒肆 · 二楼茶座`):
//   1. 2 Weekly-rotating Regional Visiting Sects (`酒肆行客`)
//   2. 1 Cross-region Wandering Sect (`云游散客`)
//   3. Friendly Sects with Relation >= 30 (`飞鸽赴约`)
::Wuxia.SectRelations.getTownTeaHouseSeats <- function( _town )
{
	local result = {};
	if (_town == null) return result;

	local reg = ::Wuxia.SectRelations.getSettlementRegion(_town);
	local regPool = [];
	local roamPool = [];
	foreach (sid, sDef in ::Wuxia.Config.Sects)
	{
		if (sDef.ShopManuals.len() == 0) continue;
		if ((("Region" in sDef) ? sDef.Region : "plains") == reg)
			regPool.push(sid);
		else
			roamPool.push(sid);
	}
	regPool.sort();
	roamPool.sort();

	local week = ("getTime" in ::World && ::World.getTime() != null) ? (::World.getTime().Days / 4) : 0;
	local seed = ::Math.abs(_town.getID() * 19 + week * 13);

	if (regPool.len() > 0)
	{
		local idx1 = seed % regPool.len();
		result[regPool[idx1]] <- "酒肆行客";
		if (regPool.len() > 1)
		{
			local idx2 = (idx1 + 1 + (seed / 7) % (regPool.len() - 1)) % regPool.len();
			result[regPool[idx2]] <- "酒肆行客";
		}
	}
	if (roamPool.len() > 0)
	{
		local rIdx = (seed * 3 + 5) % roamPool.len();
		if (!(roamPool[rIdx] in result))
			result[roamPool[rIdx]] <- "云游门人";
	}

	foreach (sid, sDef in ::Wuxia.Config.Sects)
	{
		if (sDef.ShopManuals.len() == 0 || (sid in result)) continue;
		if (::Wuxia.SectRelations.getRelation(sid) >= 30)
			result[sid] <- "飞鸽赴约";
	}

	return result;
};

::Wuxia.SectRelations.getTeaCooldownLeft <- function( _kind, _sectID, _cooldownDays )
{
	if (!::Wuxia.hasWorldField("Flags") || ::World.getTime() == null)
		return 0;
	local flag = "wx_tea_" + _kind + "_" + _sectID;
	if (!::World.Flags.has(flag)) return 0;
	local effCd = _cooldownDays;
	if (effCd > 1 && (_kind == "banq" || _kind == "spar" || _kind == "rumor" || _kind == "recruit"))
	{
		if (("Retinue" in ::World) && ::World.Retinue != null && ::World.Retinue.hasFollower("follower.negotiator"))
			effCd -= 1;
	}
	local lastDay = ::World.Flags.getAsInt(flag);
	local curDay = ::World.getTime().Days;
	local rem = effCd - (curDay - lastDay);
	return rem > 0 ? rem : 0;
};

::Wuxia.SectRelations.getSanctumSealLeft <- function( _sectID )
{
	if (!::Wuxia.hasWorldField("Flags") || ::World.getTime() == null)
		return 0;
	local flag = "wx_sanctum_sealed_" + _sectID;
	if (!::World.Flags.has(flag)) return 0;
	local lastDay = ::World.Flags.getAsInt(flag);
	local curDay = ::World.getTime().Days;
	local rem = 15 - (curDay - lastDay);
	return rem > 0 ? rem : 0;
};

// Resolve whether the player can currently interact face-to-face with `_sectID` (either at its Mountain Gate OR in a Town Tavern!)
::Wuxia.SectRelations.resolveActiveMeeting <- function( _sectID )
{
	local sanctum = ::Wuxia.SectRelations.getCurrentSanctum();
	if (sanctum != null)
	{
		local ssid = ("getSectID" in sanctum) ? sanctum.getSectID() : sanctum.getFlags().get("wx_sect_id");
		if (ssid == _sectID)
		{
			local sealDays = ::Wuxia.SectRelations.getSanctumSealLeft(_sectID);
			if (sealDays > 0)
			{
				local sNm = (_sectID in ::Wuxia.Config.Sects) ? ::Wuxia.Config.Sects[_sectID].Name : "本门";
				return { Ok = false, AtSanctum = true, Sealed = true, Reason = "【" + sNm + "】山门前番遭强敌踢馆重创，全山戒严闭关疗伤（尚余 " + sealDays + " 日方重开知客堂）！" };
			}
			return { Ok = true, AtSanctum = true, PlaceName = sanctum.getName() };
		}
	}

	local town = ::Wuxia.SectRelations.getCurrentTown();
	if (town != null)
	{
		local seats = ::Wuxia.SectRelations.getTownTeaHouseSeats(town);
		if (_sectID in seats)
			return { Ok = true, AtSanctum = false, PlaceName = town.getName() + "酒肆茶座" };
		return { Ok = false, Reason = "该宗门传人今日未在【" + town.getName() + "】酒肆歇脚，可亲赴其独立山门拜访或改日再遇。" };
	}

	return { Ok = false, Reason = "须亲临该派大地图【独立山门/山庄】，或在城池【迎客酒肆 · 二楼茶座】偶遇传人方能当面请教。" };
};

::Wuxia.SectRelations.teaHouseBuyManual <- function( _sectID, _manualID )
{
	if (!(_sectID in ::Wuxia.Config.Sects))
		return { ok = false, reason = "未找到该江湖宗门。" };

	local meet = ::Wuxia.SectRelations.resolveActiveMeeting(_sectID);
	if (!meet.Ok)
		return { ok = false, reason = meet.Reason };

	local sect = ::Wuxia.Config.Sects[_sectID];
	local offer = null;
	foreach (sm in sect.ShopManuals)
	{
		if (sm.ManualID == _manualID) { offer = sm; break; }
	}
	if (offer == null)
		return { ok = false, reason = "该宗门未传授此部秘籍。" };

	local rel = ::Wuxia.SectRelations.getRelation(_sectID);
	local reqRel = offer.MinRel;
	local moralNote = "";
	if (offer.MinRel >= 45 && "World" in getroottable() && ::World != null && ::World.Assets != null)
	{
		local moral = ::World.Assets.getMoralReputation();
		if (sect.Alignment == "righteous" && moral < 25)
		{
			reqRel += 12;
			moralNote = "（因义社凶名在外，名门正派心存戒备，镇派秘籍门槛提高 +12）";
		}
		else if (sect.Alignment == "outlaw" && moral > 75)
		{
			reqRel += 8;
			moralNote = "（因义社侠名过盛，绿林邪派疑心重重，秘籍门槛提高 +8）";
		}
	}
	if (rel < reqRel)
		return { ok = false, reason = "与【" + sect.Name + "】交情不足（需 ≥" + reqRel + "，当前 " + rel + "）" + moralNote + "，可先奉茗论交或演武拆招。" };

	// Supreme manuals (`MinRel >= 45`) of sects that own an independent Mountain Gate require visiting the Mountain Gate (unless莫逆之交 rel >= 65)!
	local hasSanctum = (::Wuxia.SectRelations.getSectSanctumEntity(_sectID) != null);
	if (!meet.AtSanctum && hasSanctum && offer.MinRel >= 45 && rel < 65)
	{
		return { ok = false, reason = "镇派真传秘籍不在酒肆外传！请亲自前往【" + sect.Name + "】山门藏经阁拜求（或交情臻至 65 莫逆之交）。" };
	}

	if (::World.Assets.getMoney() < offer.Price)
		return { ok = false, reason = "行囊纹银不足（需 " + offer.Price + " 两）。" };

	local mdef = ::Wuxia.Slots.getManualDef(offer.ManualID);
	if (mdef == null)
		return { ok = false, reason = "秘籍数据异常。" };

	local mItem = ::new("scripts/items/misc/wx_manual_item");
	mItem.initManual(offer.ManualID);
	local payRes = ::Wuxia.Loot.purchaseEventItem(mItem, offer.Price, "OK");
	if (payRes == "NoMoney")
		return { ok = false, reason = "行囊纹银不足。" };
	if (payRes == "NoRoom")
		return { ok = false, reason = "行囊空间已满，请先整理仓库或开启藏经阁自动收纳。" };

	local newRel = ::Wuxia.SectRelations.addRelation(_sectID, 2);
	local destNote = ::Wuxia.Library.isAutoStoreEnabled() ? "已直接收录入【藏经阁】" : "已放入战团行囊";
	local venueStr = meet.AtSanctum ? ("于【" + meet.PlaceName + "】奉上香火束脩 ") : ("于【" + meet.PlaceName + "】奉上束脩 ");
	return {
		ok      = true,
		message = venueStr + offer.Price + " 两，请得【" + sect.Name + "】秘传《" + mdef.Name + "》（" + destNote + "，交情 +2 → " + newRel + "）！"
	};
};

::Wuxia.SectRelations.teaHouseBanquet <- function( _sectID )
{
	if (!(_sectID in ::Wuxia.Config.Sects))
		return { ok = false, reason = "未找到该江湖宗门。" };

	local meet = ::Wuxia.SectRelations.resolveActiveMeeting(_sectID);
	if (!meet.Ok)
		return { ok = false, reason = meet.Reason };

	local cd = ::Wuxia.SectRelations.getTeaCooldownLeft("banq", _sectID, 3);
	if (cd > 0)
		return { ok = false, reason = "近日已拜会款待过该派，尚需相隔 " + cd + " 日再行登门。" };

	local cost = 350;
	if (::World.Assets.getMoney() < cost)
		return { ok = false, reason = "备办礼敬茗酒需纹银 " + cost + " 两，当前盘缠不足。" };

	::World.Assets.addMoney(-cost);
	::World.Flags.set("wx_tea_banq_" + _sectID, ::World.getTime().Days);
	local sect = ::Wuxia.Config.Sects[_sectID];
	local gain = meet.AtSanctum ? 18 : 14;
	local newRel = ::Wuxia.SectRelations.addRelation(_sectID, gain);
	local msg = meet.AtSanctum
		? ("亲登【" + meet.PlaceName + "】递帖奉礼、与执事长老品茗论道，【" + sect.Name + "】交情 +" + gain + "（当前：" + newRel + "）！")
		: ("于【" + meet.PlaceName + "】设上等酒席款待【" + sect.Name + "】游历门人，宗门交情 +" + gain + "（当前：" + newRel + "）！");
	return {
		ok      = true,
		message = msg
	};
};

::Wuxia.SectRelations.teaHouseSpar <- function( _sectID, _mode )
{
	if (!(_sectID in ::Wuxia.Config.Sects))
		return { ok = false, reason = "未找到该江湖宗门。" };

	local meet = ::Wuxia.SectRelations.resolveActiveMeeting(_sectID);
	if (!meet.Ok)
		return { ok = false, reason = meet.Reason };

	local sect = ::Wuxia.Config.Sects[_sectID];
	if (_mode == "offend")
	{
		local nextRel = ::Wuxia.SectRelations.addRelation(_sectID, -35);
		local vWarn = ::Wuxia.SectRelations.isVendettaActive(_sectID) ? "该派已传下江湖追杀令，小心道上寻仇高手（可赴城镇易容阁敛息消解）！" : "双方梁子已结！";
		local actTxt = meet.AtSanctum ? ("于【" + meet.PlaceName + "】当众剑劈知客牌匾") : ("于【" + meet.PlaceName + "】当众拂袖撕碎门帖");
		return {
			ok      = true,
			message = actTxt + "，【" + sect.Name + "】交情 -35（当前：" + nextRel + "）！" + vWarn
		};
	}

	local cd = ::Wuxia.SectRelations.getTeaCooldownLeft("spar", _sectID, 5);
	if (cd > 0)
		return { ok = false, reason = "近日已与该派切磋印证，需潜心体悟 " + cd + " 日后再行拆招。" };

	local bros = (::World.getPlayerRoster() != null) ? ::World.getPlayerRoster().getAll() : [];
	local bestBro = null;
	local bestScore = -1;
	foreach (b in bros)
	{
		if (b == null || !b.isAlive()) continue;
		local cp = b.getCurrentProperties();
		local sc = cp.getMeleeSkill() + ::Math.floor(cp.getBravery() * 0.5);
		if (sc > bestScore) { bestScore = sc; bestBro = b; }
	}
	if (bestBro == null)
		return { ok = false, reason = "麾下暂无可登台拆招之侠客。" };

	::World.Flags.set("wx_tea_spar_" + _sectID, ::World.getTime().Days);
	local strongWin = (bestScore + ::Math.rand(1, 20) >= 90);
	local relGain = (strongWin ? 12 : 7) + (meet.AtSanctum ? 3 : 0);
	local expGain = (strongWin ? 65 : 40) + (meet.AtSanctum ? 20 : 0);
	local newRel = ::Wuxia.SectRelations.addRelation(_sectID, relGain);

	if ("Mastery" in ::Wuxia && "grantFlatExpToEquipped" in ::Wuxia.Mastery)
	{
		::Wuxia.Mastery.grantFlatExpToEquipped(bestBro, expGain);
	}
	else
	{
		local cont = ::Wuxia.Slots.getContainer(bestBro);
		if (cont != null)
		{
			for (local si = 0; si < cont.m.Slots.len(); si = ++si)
			{
				if (cont.m.Slots[si].ManualID != null && cont.m.Slots[si].Tier > 0)
					::Wuxia.Mastery.addExpToSlot(bestBro, si, expGain);
			}
		}
	}

	return {
		ok      = true,
		message = bestBro.getName() + " 于【" + meet.PlaceName + "】演武坪与【" + sect.Name + "】高手拆招印证，" + (strongWin ? "招式精妙引满堂喝彩" : "点到为止互有启发") + "！交情 +" + relGain + "（→ " + newRel + "），全身已装功法历练 +" + expGain + "！"
	};
};

// Tavern Rumor Inquiry (`打探山门与丹道秘闻`): reveals 1 undiscovered Sect Sanctum on the map (or 1 undiscovered Alchemy Formula if all sanctums found!)
::Wuxia.SectRelations.tavernInquireRumor <- function()
{
	local town = ::Wuxia.SectRelations.getCurrentTown();
	if (town == null)
		return { ok = false, reason = "须在城池【迎客酒肆】中方能向酒保与四方茶客打探秘闻。" };

	local cd = ::Wuxia.SectRelations.getTeaCooldownLeft("rumor", "global", 2);
	if (cd > 0)
		return { ok = false, reason = "近日刚在此间打探过风声，尚需隔 " + cd + " 日再有新消息传来。" };

	local cost = 160;
	if (::World.Assets.getMoney() < cost)
		return { ok = false, reason = "请酒保与行脚客饮酒打探需纹银 " + cost + " 两。" };

	::Wuxia.SectRelations.ensureWorldSectSanctums();
	local hiddenSanctums = [];
	foreach (sid, eid in ::Wuxia.SectRelations.AnchorCache.SectToSanctumID)
	{
		local ent = ::World.getEntityByID(eid);
		if (ent != null && ent.isAlive() && !ent.isDiscovered())
			hiddenSanctums.push({ sid = sid, ent = ent });
	}

	if (hiddenSanctums.len() > 0)
	{
		::World.Assets.addMoney(-cost);
		::World.Flags.set("wx_tea_rumor_global", ::World.getTime().Days);
		local picked = hiddenSanctums[::Math.rand(0, hiddenSanctums.len() - 1)];
		picked.ent.setDiscovered(true);
		::Wuxia.SectRelations.discoverSect(picked.sid);
		local info = ::Wuxia.SectRelations.getSectAnchorInfo(picked.sid);
		local dirNote = (info.dir != "" && info.dist >= 0) ? ("（位于此处" + info.dir + "约 " + info.dist + " 格）") : "";
		return {
			ok      = true,
			message = "奉上酒资 " + cost + " 两，老镖客低声指点迷津：已在世界舆图上标明独立山门【" + picked.ent.getName() + "】" + dirNote + "，并录入《江湖名刺》！"
		};
	}

	// All Mountain Gates already discovered -> impart an undiscovered Alchemy Formula rumor!
	if ("Alchemy" in ::Wuxia && "unlockRandomUndiscoveredFormula" in ::Wuxia.Alchemy)
	{
		local unlockedPill = ::Wuxia.Alchemy.unlockRandomUndiscoveredFormula(3);
		if (unlockedPill != "")
		{
			::World.Assets.addMoney(-cost);
			::World.Flags.set("wx_tea_rumor_global", ::World.getTime().Days);
			return {
				ok      = true,
				message = "奉上酒资 " + cost + " 两，偶遇游方老药师酒后吐露古方秘要：已将《" + unlockedPill + "》配伍法度载入《丹经手札》！"
			};
		}
	}

	return { ok = false, reason = "九州各派山门方位与市井丹方传闻皆已尽入掌中，暂无未明风声。" };
};

// Sanctum Pill-Elder Guidance (`求教宗门丹经`): at a Sect Mountain Gate with Relation >= 35, learn 1 undiscovered Alchemy Formula!
::Wuxia.SectRelations.sanctumAskAlchemy <- function( _sectID )
{
	if (!(_sectID in ::Wuxia.Config.Sects))
		return { ok = false, reason = "未找到该江湖宗门。" };

	local meet = ::Wuxia.SectRelations.resolveActiveMeeting(_sectID);
	if (!meet.Ok || !meet.AtSanctum)
		return { ok = false, reason = "唯有亲自登临宗门山门，方能入丹房求教秘传丹经。" };

	local rel = ::Wuxia.SectRelations.getRelation(_sectID);
	if (rel < 35)
		return { ok = false, reason = "需与本门交情达 35 以上，丹房长老方肯指点不传丹方（当前：" + rel + "）。" };

	local cd = ::Wuxia.SectRelations.getTeaCooldownLeft("alc", _sectID, 6);
	if (cd > 0)
		return { ok = false, reason = "丹房长老近日已指点过一卷丹诀，请隔 " + cd + " 日再来请益。" };

	local cost = 480;
	if (::World.Assets.getMoney() < cost)
		return { ok = false, reason = "奉上丹房香火资需纹银 " + cost + " 两。" };

	if (!("Alchemy" in ::Wuxia) || !("unlockRandomUndiscoveredFormula" in ::Wuxia.Alchemy))
		return { ok = false, reason = "丹经系统尚未就绪。" };

	local pillName = ::Wuxia.Alchemy.unlockRandomUndiscoveredFormula(5);
	if (pillName == "")
		return { ok = false, reason = "《丹经手札》全部 " + ::Wuxia.Config.Alchemy.Formulas.len() + " 道古方已尽数参透，再无未录之方！" };

	::World.Assets.addMoney(-cost);
	::World.Flags.set("wx_tea_alc_" + _sectID, ::World.getTime().Days);
	local sect = ::Wuxia.Config.Sects[_sectID];
	return {
		ok      = true,
		message = "于【" + sect.Name + "】丹房奉上香火 " + cost + " 两，长老展卷亲授君臣火候——《" + pillName + "》古方已永久载入《丹经手札》！"
	};
};

// Award or deduct Sect Relations organically when slaying Outlaw Bosses or fighting Sect Patrols
::Wuxia.SectRelations.onCombatActorSlain <- function( _party, _isBoss )
{
	if (_party == null || ("isNull" in _party && _party.isNull()) || !::Wuxia.hasWorldField("State")) return;

	local flags = _party.getFlags();
	local patrol = (flags != null && flags.has("wx_sect_patrol")) ? flags.get("wx_sect_patrol") : "";
	if (typeof patrol != "string") patrol = "";
	local sid = patrol;
	if (sid == "" && flags != null && flags.has("wx_vendetta"))
	{
		local vd = flags.get("wx_vendetta");
		if (typeof vd == "string") sid = vd;
	}
	if (::Wuxia.hasMember(_party, "WX_GetBattleMode"))
	{
		if (_party.WX_GetBattleMode() == "trial") return;
		sid = _party.getSectID();
	}

	local isOutlaw = false;
	if (sid != null && typeof sid == "string" && sid != "" && (sid in ::Wuxia.Config.Sects))
	{
		isOutlaw = ::Wuxia.Config.Sects[sid].Alignment == "outlaw";
		if (patrol == sid)
		{
			this.discoverSect(sid);
			this.addRelation(sid, isOutlaw ? -6 : -12);
		}
		if (!isOutlaw) return;
	}
	else if (::Wuxia.hasWorldField("FactionManager"))
	{
		local faction = ::World.FactionManager.getFaction(_party.getFaction());
		isOutlaw = faction != null && (faction.getType() == ::Const.FactionType.Bandits || faction.getType() == ::Const.FactionType.OrientalBandits);
	}
	if (isOutlaw && ::Wuxia.hasWorldField("Flags"))
	{
		local prevSlain = ::World.Flags.getAsInt("wx_sq_enemies_slain");
		::World.Flags.set("wx_sq_enemies_slain", prevSlain + 1);
	}

	if (!_isBoss) return;

	// Slaying a Boss boosts standing (+4) with the nearest Righteous/Neutral Sect Sanctum!
	local p = ::World.State.getPlayer();
	if (p == null || p.getTile() == null || ::World.EntityManager == null) return;
	local pTile = p.getTile();
	::Wuxia.SectRelations.ensureWorldSectSanctums();

	local bestSid = "";
	local minD = 9999;
	foreach (sid, eid in ::Wuxia.SectRelations.AnchorCache.SectToSanctumID)
	{
		if (!(sid in ::Wuxia.Config.Sects) || ::Wuxia.Config.Sects[sid].Alignment == "outlaw") continue;
		local ent = ::World.getEntityByID(eid);
		if (ent == null || !ent.isAlive() || ent.getTile() == null) continue;
		local d = pTile.getDistanceTo(ent.getTile());
		if (d < minD) { minD = d; bestSid = sid; }
	}
	if (bestSid != "")
	{
		local afterR = ::Wuxia.SectRelations.addRelation(bestSid, 4);
		if ("Tactical" in getroottable() && ::Tactical != null && ("EventLog" in ::Tactical) && ::Tactical.EventLog != null)
		{
			::Tactical.EventLog.logEx("斩除一方凶顽，【" + ::Wuxia.Config.Sects[bestSid].Name + "】闻讯嘉许（宗门交情 +4 → " + afterR + "）");
		}
	}
};
