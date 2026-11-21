// Runtime System for Shan Hai Jing Mythical Bosses, Wild Beast Neidan/Herb Drops, Red Gear & Lair Rumor Discovery

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
		local mech = ("Mechanics" in cfg && cfg.Mechanics != null) ? cfg.Mechanics : {};
		if (("SteelBrow" in mech) && mech.SteelBrow && !skills.hasSkill("perk.steel_brow"))
			skills.add(::new("scripts/skills/perks/perk_steel_brow"));
		if (("Underdog" in mech) && mech.Underdog && !skills.hasSkill("perk.underdog"))
			skills.add(::new("scripts/skills/perks/perk_underdog"));
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

	if (cfg.CustomBodySprite != null && _actor.hasSprite("body"))
	{
		_actor.m.WX_BossID <- _bossID;
		_actor.m.WX_CustomEnemyBust <- cfg.CustomBodySprite;
		local sprBody = _actor.getSprite("body");
		sprBody.setBrush(cfg.CustomBodySprite);
		if ("Tactical" in getroottable() && ::Tactical != null && ::Tactical.isActive() && ::Wuxia.hasMember(_actor, "isAlliedWithPlayer"))
			sprBody.setHorizontalFlipping(!_actor.isAlliedWithPlayer());
		if (cfg.CustomHeadSprite == null)
		{
			foreach (sub in [
				"head", "head_frenzy", "helmet", "helmet_damage", "armor", "surcoat",
				"hair", "beard", "beard_top", "wings", "tattoo_body", "tattoo_head",
				"legs_back", "legs_front", "tail", "charm_body", "arms_icon", "shield_icon", "injury", "injury_body"
			])
				if (_actor.hasSprite(sub)) _actor.getSprite(sub).Visible = false;
		}
	}
	if (cfg.CustomHeadSprite != null && _actor.hasSprite("head"))
		_actor.getSprite("head").setBrush(cfg.CustomHeadSprite);
};

::Wuxia.ShanHai.dropBossCore <- function( _bossID, _tile )
{
	if (_tile == null || !(_bossID in ::Wuxia.Config.ShanHaiBosses)) return;
	local cfg = ::Wuxia.Config.ShanHaiBosses[_bossID];
	local core = ::new("scripts/items/misc/" + cfg.CoreID);
	core.drop(_tile);

	// 45% bonus chance for Lair Apex Bosses to also drop a《山海本草》Rare Spirit Herb!
	if (::Math.rand(1, 100) <= 45)
	{
		local hItem = ::Wuxia.ShanHai.createRandomHerb();
		if (hItem != null) hItem.drop(_tile);
	}
	if ("BeastCraft" in ::Wuxia)
	{
		::Wuxia.BeastCraft.dropBossCompanionMaterials(cfg.Key, _tile);
	}
};

// Compute Neidan Martial Affinity Resonance Exp when infused into a brother's slot!
::Wuxia.ShanHai.getCoreInfuseExp <- function( _coreID, _manualDef )
{
	if (!(_coreID in ::Wuxia.Config.ShanHaiCores)) return 350;
	local cfg = ::Wuxia.Config.ShanHaiCores[_coreID];
	local baseExp = cfg.ExpAmount;
	if (typeof _manualDef == "string")
		_manualDef = ("Manuals" in ::Wuxia.Config && (_manualDef in ::Wuxia.Config.Manuals)) ? ::Wuxia.Config.Manuals[_manualDef] : null;
	if (_manualDef == null) return baseExp;

	// Highest tier resonance: Shan Hai Unique Totem Manuals!
	if (_manualDef.ID.find("wx_manual_shanhai_") == 0)
		return baseExp + 180;

	local aff = ("Affinity" in cfg) ? cfg.Affinity : "";
	local matched = false;
	if (aff == "waigong" && _manualDef.Category == "waigong") matched = true;
	else if (aff == "qinggong" && _manualDef.Category == "qinggong") matched = true;
	else if (aff == "henglian" && _manualDef.Category == "henglian") matched = true;
	else if (aff == "tactics" && _manualDef.Category == "tactics") matched = true;
	else if (aff == "neigong_yang" && _manualDef.Category == "neigong" && (_manualDef.Element == "yang" || _manualDef.Element == "harmony")) matched = true;
	else if (aff == "neigong_yin" && _manualDef.Category == "neigong" && (_manualDef.Element == "yin" || _manualDef.Element == "evil" || _manualDef.Element == "harmony")) matched = true;

	return matched ? (baseExp + 100) : baseExp;
};

::Wuxia.ShanHai.getHerbIDs <- function()
{
	local out = [];
	if ("Herbs" in ::Wuxia.Config)
	{
		foreach (hid, _ in ::Wuxia.Config.Herbs) out.push(hid);
		out.sort();
	}
	return out;
};

::Wuxia.ShanHai.createHerbItem <- function( _herbID )
{
	if (_herbID == "wx_marrow_herb")
		return ::new("scripts/items/misc/wx_marrow_herb");
	return ::new("scripts/items/misc/" + _herbID);
};

::Wuxia.ShanHai.createRandomHerb <- function( _excludeMarrow = false )
{
	local pool = [];
	if ("Herbs" in ::Wuxia.Config)
	{
		foreach (hid, _ in ::Wuxia.Config.Herbs)
		{
			if (_excludeMarrow && hid == "wx_marrow_herb") continue;
			pool.push(hid);
		}
	}
	if (pool.len() == 0) return null;
	local pick = pool[::Math.rand(0, pool.len() - 1)];
	return ::Wuxia.ShanHai.createHerbItem(pick);
};

::Wuxia.ShanHai.getSovereignCoreIDs <- function()
{
	local out = [];
	foreach (cid, cfg in ::Wuxia.Config.ShanHaiCores)
	{
		if (("TierGroup" in cfg) && cfg.TierGroup == "sovereign")
			out.push(cid);
	}
	out.sort();
	return out;
};

::Wuxia.ShanHai.createRandomSovereignCore <- function()
{
	local pool = ::Wuxia.ShanHai.getSovereignCoreIDs();
	if (pool.len() == 0) return null;
	local pick = pool[::Math.rand(0, pool.len() - 1)];
	return ::new("scripts/items/misc/" + pick);
};

// Strictly gate Neidan Cores & Spirit Herbs to Sovereign Bosses, Warlords & Apex Mythic Beasts (zero drops on common/mid mobs)
::Wuxia.ShanHai.tryDropWildBeastLoot <- function( _actor, _tile )
{
	if (_actor == null || _tile == null) return;
	local sk = (::Wuxia.hasMember(_actor, "getSkills")) ? _actor.getSkills() : null;
	if (sk != null && sk.hasSkill("special.wx_shanhai_boss_trait")) return; // Handled by dropBossCore
	if (!(::Wuxia.hasMember(_actor, "getType")) || !("Const" in getroottable()) || !("EntityType" in ::Const)) return;

	local t = _actor.getType();
	local ET = ::Const.EntityType;
	local coreID = null;
	local coreChance = 0;
	local herbChance = 0;

	if (("Kraken" in ET) && t == ET.Kraken)                  { coreID = "wx_core_zelong";     coreChance = 100; herbChance = 100; }
	else if (("TricksterGod" in ET) && t == ET.TricksterGod) { coreID = "wx_core_shenlu";     coreChance = 100; herbChance = 100; }
	else if (("Lindwurm" in ET) && t == ET.Lindwurm)         { coreID = "wx_core_mangshe";    coreChance = 22;  herbChance = 15; }
	else if (("Schrat" in ET) && t == ET.Schrat)             { coreID = "wx_core_shujing";    coreChance = 20;  herbChance = 16; }
	else if (("Hexe" in ET) && t == ET.Hexe)                 { coreID = "wx_core_yaomei";     coreChance = 20;  herbChance = 14; }
	else if (("UnholdBog" in ET) && t == ET.UnholdBog)       { coreID = "wx_core_shuiyuan";   coreChance = 15;  herbChance = 10; }
	else if (("UnholdFrost" in ET) && t == ET.UnholdFrost)   { coreID = "wx_core_canglang";   coreChance = 16;  herbChance = 10; }
	else if (("Unhold" in ET) && t == ET.Unhold)             { coreID = "wx_core_canglang";   coreChance = 12;  herbChance = 8; }
	else if (("ZombieBoss" in ET) && t == ET.ZombieBoss)     { coreID = "wx_core_shiwang";    coreChance = 28;  herbChance = 14; }
	else if (("SkeletonBoss" in ET) && t == ET.SkeletonBoss) { coreID = "wx_core_jiguanyong"; coreChance = 28;  herbChance = 14; }
	else if (("OrcWarlord" in ET) && t == ET.OrcWarlord)     { coreID = "wx_core_yaoren";     coreChance = 26;  herbChance = 14; }
	// Common & mid wild beasts (Spider, Direwolf, Hyena, Ghoul, Serpent, Ghost, Alp, Vampire) NEVER drop Neidan Cores or Spirit Herbs!

	if (coreID != null && (coreID in ::Wuxia.Config.ShanHaiCores) && ::Math.rand(1, 100) <= coreChance)
	{
		local cItem = ::new("scripts/items/misc/" + coreID);
		cItem.drop(_tile);
	}
	if (herbChance > 0 && ::Math.rand(1, 100) <= herbChance)
	{
		local hItem = ::Wuxia.ShanHai.createRandomHerb(true);
		if (hItem != null) hItem.drop(_tile);
	}
};

::Wuxia.ShanHai.applyNamedArmorOrHelmet <- function( _item, _gearID, _onDeserializeOnly = false )
{
	if (_item == null || !(_gearID in ::Wuxia.Config.ShanHaiGear)) return;
	local cfg = ::Wuxia.Config.ShanHaiGear[_gearID];
	local prefix = (cfg.Kind == "helmet") ? "armor.head." : ((cfg.Kind == "shield") ? "shield." : "armor.body.");
	_item.m.ID = prefix + cfg.ID;
	if (!_onDeserializeOnly)
	{
		_item.m.Name = cfg.Name;
		_item.m.Description = cfg.Description;
		if (_item.m.Value < cfg.Value) _item.m.Value = cfg.Value;
		if (cfg.MinCondition > 0 && _item.m.ConditionMax < cfg.MinCondition)
		{
			_item.m.ConditionMax = cfg.MinCondition;
			_item.m.Condition = cfg.MinCondition;
		}
		if (("MaxCondition" in cfg) && cfg.MaxCondition > 0 && _item.m.ConditionMax > cfg.MaxCondition)
		{
			_item.m.ConditionMax = cfg.MaxCondition;
			_item.m.Condition = cfg.MaxCondition;
		}
		if (cfg.MaxStamPen < 0 && _item.m.StaminaModifier < cfg.MaxStamPen)
		{
			_item.m.StaminaModifier = cfg.MaxStamPen;
		}
		if (("MinStamPen" in cfg) && cfg.MinStamPen < 0 && _item.m.StaminaModifier > cfg.MinStamPen)
		{
			_item.m.StaminaModifier = cfg.MinStamPen;
		}
		if (("FixedVision" in cfg) && cfg.FixedVision != null && (::Wuxia.hasMember(_item.m, "Vision")))
		{
			_item.m.Vision = cfg.FixedVision;
		}
		if ("MeleeDefense" in cfg && ::Wuxia.hasMember(_item.m, "MeleeDefense") && _item.m.MeleeDefense < cfg.MeleeDefense)
			_item.m.MeleeDefense = cfg.MeleeDefense;
		if ("RangedDefense" in cfg && ::Wuxia.hasMember(_item.m, "RangedDefense") && _item.m.RangedDefense < cfg.RangedDefense)
			_item.m.RangedDefense = cfg.RangedDefense;
	}
	if (cfg.CustomIcon != null) _item.m.Icon = cfg.CustomIcon;
	if (cfg.CustomIconLarge != null) _item.m.IconLarge = cfg.CustomIconLarge;
	if (cfg.Kind == "armor")
	{
		_item.m.WX_BodyBrush <- ("BodyBrush" in cfg && cfg.BodyBrush != null) ? cfg.BodyBrush : cfg.ID;
	}
	else if (cfg.Kind == "helmet")
	{
		local hatBase = ("HatID" in cfg && cfg.HatID != null) ? cfg.HatID : cfg.ID;
		_item.m.WX_HatID <- hatBase;
		_item.m.WX_HatFrontBrush <- hatBase + "_front";
		_item.m.WX_HatBackBrush <- hatBase + "_back";
	}
	else if (cfg.Kind == "shield")
	{
		_item.m.WX_ShieldBrush <- ("ShieldBrush" in cfg && cfg.ShieldBrush != null) ? cfg.ShieldBrush : ("shd_" + cfg.ID);
	}
	_item.m.WX_ShanHaiGearID <- _gearID;
	_item.m.WX_GearTraitID <- ("TraitID" in cfg) ? cfg.TraitID : null;
	_item.m.WX_MappedID <- _item.m.ID;
	_item.m.WX_ExpectedIcon <- _item.m.Icon;
	if ("BeastCraft" in ::Wuxia && "bindTraitMethods" in ::Wuxia.BeastCraft)
		::Wuxia.BeastCraft.bindTraitMethods(_item);
	if (_onDeserializeOnly && ("Forge" in ::Wuxia) && ("syncDeserializedNamed" in ::Wuxia.Forge))
		::Wuxia.Forge.syncDeserializedNamed(_item);
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
	local uncharted = [];
	local allAlive = [];
	foreach (site in ::World.EntityManager.getLocations())
	{
		if (site != null && site.isAlive() && site.getTypeID().find("location.wx_shanhai_") == 0)
		{
			allAlive.push(site);
			if (!site.getFlags().get("wx_charted"))
				uncharted.push(site);
		}
	}
	if (uncharted.len() > 0)
		return uncharted[::Math.rand(0, uncharted.len() - 1)];
	if (allAlive.len() == 0) return null;
	return allAlive[::Math.rand(0, allAlive.len() - 1)];
};
