// Lightweight Sect Relations & Regional Jianghu Discovery stored in World.Flags (Zero Faction ID cost)

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

// Detect the geographic Jianghu region around the player's current position / nearest settlement
::Wuxia.SectRelations.getLocalRegion <- function()
{
	if (!("World" in getroottable()) || ::World == null || ::World.State == null || ::World.State.getPlayer() == null)
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

// Return up to 3 distinct sect IDs for a town tea-house: 2 local-region sects + 1 roaming/global sect
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
	{
		chosen.push(pickUniqueFrom(localPool));
	}
	while (chosen.len() < 3 && otherPool.len() > 0)
	{
		chosen.push(pickUniqueFrom(otherPool));
	}
	while (chosen.len() < 3 && localPool.len() > 0)
	{
		chosen.push(pickUniqueFrom(localPool));
	}
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
	if (!("World" in getroottable()) || ::World == null || ::World.Flags == null)
		return def.DefaultRel;

	local key = ::Wuxia.SectRelations.getFlagKey(_sectID);
	if (!::World.Flags.has(key))
	{
		::World.Flags.set(key, def.DefaultRel);
	}
	return ::World.Flags.getAsInt(key);
};

::Wuxia.SectRelations.addRelation <- function( _sectID, _delta )
{
	if (!(_sectID in ::Wuxia.Config.Sects)) return 0;
	local cur = ::Wuxia.SectRelations.getRelation(_sectID);
	local next = ::Math.max(-100, ::Math.min(100, cur + _delta));
	if ("World" in getroottable() && ::World != null && ::World.Flags != null)
	{
		::World.Flags.set(::Wuxia.SectRelations.getFlagKey(_sectID), next);
	}
	return next;
};

::Wuxia.SectRelations.isVendettaActive <- function( _sectID )
{
	if (!(_sectID in ::Wuxia.Config.Sects)) return false;
	return ::Wuxia.SectRelations.getRelation(_sectID) <= ::Wuxia.Config.Sects[_sectID].VendettaRel;
};
