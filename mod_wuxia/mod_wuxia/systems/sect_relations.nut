// Lightweight Sect Relations stored in World.Flags (Zero Faction ID cost)

::Wuxia.SectRelations.getExchangeSects <- function()
{
	local ids = [];
	foreach (id, sect in ::Wuxia.Config.Sects)
		if (sect.ShopManuals.len() > 0) ids.push(id);
	ids.sort();
	return ids;
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
