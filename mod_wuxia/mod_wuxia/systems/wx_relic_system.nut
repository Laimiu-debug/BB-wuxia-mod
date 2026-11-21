// Historical & Shan Hai Divine Relic Rare Weapon System: applies identity, categories & paperdoll handheld `.brush` sprites

::Wuxia.Relics <- {};

::Wuxia.Relics.applyRelic <- function( _item, _relicID )
{
	if (_item == null || !(_relicID in ::Wuxia.Config.RelicWeapons)) return;
	local cfg = ::Wuxia.Config.RelicWeapons[_relicID];
	_item.m.ID = "weapon." + cfg.ID;
	_item.m.Name = "传世·" + cfg.Name;
	_item.m.Description = cfg.Description;
	if (_item.m.Value < cfg.MinValue) _item.m.Value = cfg.MinValue;
	if (cfg.Categories != null) _item.m.Categories = cfg.Categories;
	if (cfg.CustomIcon != null) _item.m.Icon = cfg.CustomIcon;
	if (cfg.CustomIconLarge != null) _item.m.IconLarge = cfg.CustomIconLarge;
	_item.m.ShowArmamentIcon = true;
	local armBrush = (cfg.CustomArmamentIcon != null) ? cfg.CustomArmamentIcon : ("arm_" + cfg.ID);
	if (cfg.Family != "Crossbow") _item.m.ArmamentIcon = armBrush;
	_item.m.WX_RelicID <- _relicID;
	_item.m.WX_ArmBrush <- armBrush;
	_item.m.WX_GearTraitID <- ("TraitID" in cfg) ? cfg.TraitID : null;
	_item.m.WX_MappedID <- _item.m.ID;
	_item.m.WX_ExpectedIcon <- _item.m.Icon;
	if ("BeastCraft" in ::Wuxia && "bindTraitMethods" in ::Wuxia.BeastCraft)
		::Wuxia.BeastCraft.bindTraitMethods(_item);
};

::Wuxia.Relics.applyArtOverridesOnly <- function( _item, _relicID )
{
	if (_item == null || !(_relicID in ::Wuxia.Config.RelicWeapons)) return;
	local cfg = ::Wuxia.Config.RelicWeapons[_relicID];
	_item.m.ID = "weapon." + cfg.ID;
	if (cfg.Categories != null) _item.m.Categories = cfg.Categories;
	if (cfg.CustomIcon != null) _item.m.Icon = cfg.CustomIcon;
	if (cfg.CustomIconLarge != null) _item.m.IconLarge = cfg.CustomIconLarge;
	_item.m.ShowArmamentIcon = true;
	local armBrush = (cfg.CustomArmamentIcon != null) ? cfg.CustomArmamentIcon : ("arm_" + cfg.ID);
	if (cfg.Family != "Crossbow") _item.m.ArmamentIcon = armBrush;
	_item.m.WX_RelicID <- _relicID;
	_item.m.WX_ArmBrush <- armBrush;
	_item.m.WX_GearTraitID <- ("TraitID" in cfg) ? cfg.TraitID : null;
	_item.m.WX_MappedID <- _item.m.ID;
	_item.m.WX_ExpectedIcon <- _item.m.Icon;
	if ("BeastCraft" in ::Wuxia && "bindTraitMethods" in ::Wuxia.BeastCraft)
		::Wuxia.BeastCraft.bindTraitMethods(_item);
	if ("Forge" in ::Wuxia && "syncDeserializedNamed" in ::Wuxia.Forge)
		::Wuxia.Forge.syncDeserializedNamed(_item);
};

::Wuxia.Relics.getRelicIDs <- function( _family = null, _shanHaiOnly = false )
{
	local out = [];
	foreach (id, cfg in ::Wuxia.Config.RelicWeapons)
	{
		if (_family != null && cfg.Family != _family) continue;
		if (_shanHaiOnly && (!("IsShanHai" in cfg) || !cfg.IsShanHai)) continue;
		out.push(id);
	}
	out.sort();
	return out;
};

::Wuxia.Relics.createRandomRelic <- function( _family = null )
{
	local pool = ::Wuxia.Relics.getRelicIDs(_family, false);
	if (pool.len() == 0) return null;
	local pick = pool[::Math.rand(0, pool.len() - 1)];
	return ::new(::Wuxia.Config.RelicWeapons[pick].Script);
};

::Wuxia.Relics.createRandomShanHaiRelic <- function( _family = null )
{
	local pool = ::Wuxia.Relics.getRelicIDs(_family, true);
	if (pool.len() == 0) return ::Wuxia.Relics.createRandomRelic(_family);
	local pick = pool[::Math.rand(0, pool.len() - 1)];
	return ::new(::Wuxia.Config.RelicWeapons[pick].Script);
};
