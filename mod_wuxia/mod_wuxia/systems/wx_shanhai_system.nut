// Runtime System for Shan Hai Jing Mythical Bosses, Red Armors/Helmets/Accessories & Lair Rumor Discovery

::Wuxia.ShanHai <- {};

::Wuxia.ShanHai.initBossEntity <- function( _actor, _bossID )
{
	if (_actor == null || !(_bossID in ::Wuxia.Config.ShanHaiBosses)) return;
	local cfg = ::Wuxia.Config.ShanHaiBosses[_bossID];

	_actor.setName(cfg.Name);
	_actor.m.IsMiniboss = true;

	local b = _actor.m.BaseProperties;
	b.Hitpoints = ::Math.max(180, ::Math.floor(b.Hitpoints * cfg.HpMult));
	b.MeleeSkill += cfg.MeleeSkillBonus;
	b.MeleeDefense += cfg.MeleeDefBonus;
	b.Bravery += cfg.BraveryBonus;

	local skills = _actor.getSkills();
	if (skills != null)
	{
		if ((cfg.Key == "taotie" || cfg.Key == "xingtian") && !skills.hasSkill("perk.steel_brow"))
		{
			skills.add(::new("scripts/skills/perks/perk_steel_brow"));
		}
		local trait = skills.getSkillByID("special.wx_shanhai_boss_trait");
		if (trait == null)
		{
			trait = ::new("scripts/skills/special/wx_shanhai_boss_trait");
			trait.setBossID(cfg.Key);
			skills.add(trait);
		}
		skills.update();
	}
	_actor.m.Hitpoints = _actor.getHitpointsMax();

	// Optional future custom sprite overrides
	if (cfg.CustomBodySprite != null && _actor.hasSprite("body"))
		_actor.getSprite("body").setBrush(cfg.CustomBodySprite);
	if (cfg.CustomHeadSprite != null && _actor.hasSprite("head"))
		_actor.getSprite("head").setBrush(cfg.CustomHeadSprite);
};

::Wuxia.ShanHai.dropBossCore <- function( _bossID, _tile )
{
	if (_tile == null || !(_bossID in ::Wuxia.Config.ShanHaiBosses)) return;
	local cfg = ::Wuxia.Config.ShanHaiBosses[_bossID];
	local core = ::new("scripts/items/misc/" + cfg.CoreID);
	core.drop(_tile);
};

::Wuxia.ShanHai.applyNamedArmorOrHelmet <- function( _item, _gearID, _onDeserializeOnly = false )
{
	if (_item == null || !(_gearID in ::Wuxia.Config.ShanHaiGear)) return;
	local cfg = ::Wuxia.Config.ShanHaiGear[_gearID];
	if (!_onDeserializeOnly)
	{
		_item.m.ID = (cfg.Kind == "helmet" ? "armor.head." : "armor.body.") + cfg.ID;
		_item.m.Name = cfg.Name;
		_item.m.Description = cfg.Description;
		if (_item.m.Value < cfg.Value) _item.m.Value = cfg.Value;
		if (cfg.MinCondition > 0 && _item.m.ConditionMax < cfg.MinCondition)
		{
			_item.m.ConditionMax = cfg.MinCondition;
			_item.m.Condition = cfg.MinCondition;
		}
		if (cfg.MaxStamPen < 0 && _item.m.StaminaModifier < cfg.MaxStamPen)
		{
			_item.m.StaminaModifier = cfg.MaxStamPen;
		}
	}
	if (cfg.CustomIcon != null) _item.m.Icon = cfg.CustomIcon;
	if (cfg.CustomIconLarge != null) _item.m.IconLarge = cfg.CustomIconLarge;
};

::Wuxia.ShanHai.getCompassDirection <- function( _fromTile, _toTile )
{
	local dx = _toTile.SquareCoords.X - _fromTile.SquareCoords.X;
	local dy = _toTile.SquareCoords.Y - _fromTile.SquareCoords.Y;
	local ew = dx > 4 ? "偏东" : (dx < -4 ? "偏西" : "");
	local ns = dy > 4 ? "正北" : (dy < -4 ? "正南" : "");
	if (ns != "" && ew != "") return ns.slice(1) + ew.slice(1) + "方";
	if (ns != "") return ns + "方";
	if (ew != "") return "正" + ew.slice(1) + "方";
	return "近郊四野";
};

::Wuxia.ShanHai.pickUndefeatedLairSite <- function()
{
	if (!("World" in getroottable()) || ::World == null) return null;
	local candidates = [];
	foreach (site in ::World.EntityManager.getLocations())
	{
		if (site != null && site.isAlive() && site.getTypeID().find("location.wx_shanhai_") == 0)
			candidates.push(site);
	}
	if (candidates.len() == 0) return null;
	return candidates[::Math.rand(0, candidates.len() - 1)];
};
