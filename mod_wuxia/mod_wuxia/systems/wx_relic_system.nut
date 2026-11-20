// Historical Relic Rare Weapon System: applies historical identity, categories & future custom art hooks

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
	if (cfg.CustomArmamentIcon != null) _item.m.ArmamentIcon = cfg.CustomArmamentIcon;
};

::Wuxia.Relics.applyArtOverridesOnly <- function( _item, _relicID )
{
	if (_item == null || !(_relicID in ::Wuxia.Config.RelicWeapons)) return;
	local cfg = ::Wuxia.Config.RelicWeapons[_relicID];
	if (cfg.Categories != null) _item.m.Categories = cfg.Categories;
	if (cfg.CustomIcon != null) _item.m.Icon = cfg.CustomIcon;
	if (cfg.CustomIconLarge != null) _item.m.IconLarge = cfg.CustomIconLarge;
	if (cfg.CustomArmamentIcon != null) _item.m.ArmamentIcon = cfg.CustomArmamentIcon;
};

::Wuxia.Relics.getRelicIDs <- function( _family = null )
{
	local out = [];
	foreach (id, cfg in ::Wuxia.Config.RelicWeapons)
	{
		if (_family == null || cfg.Family == _family) out.push(id);
	}
	out.sort();
	return out;
};

::Wuxia.Relics.createRandomRelic <- function( _family = null )
{
	local pool = ::Wuxia.Relics.getRelicIDs(_family);
	if (pool.len() == 0) return null;
	local pick = pool[::Math.rand(0, pool.len() - 1)];
	return ::new(::Wuxia.Config.RelicWeapons[pick].Script);
};
