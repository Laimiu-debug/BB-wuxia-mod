// Runtime System for Shan Hai Jing Mythical Bosses, Wild Beast Neidan/Herb Drops, Red Gear & Lair Rumor Discovery

::Wuxia.ShanHai <- {
	// Bespoke《山海经》Boss Registry: mounts dedicated original-text Trait + 3~4 geometric skills (zero generic cataclysm!)
	BespokeBossSpecs = {
		boss_zhuyin = {
			TraitScript = "scripts/skills/special/wx_boss_trait_zhuyin",
			TraitID     = "special.wx_boss_trait_zhuyin",
			Skills = [
				"scripts/skills/actives/wx_boss_zhuyin_winter_breath",
				"scripts/skills/actives/wx_boss_zhuyin_summer_gale",
				"scripts/skills/actives/wx_boss_zhuyin_coil_crush",
				"scripts/skills/actives/wx_boss_zhuyin_primordial_wind"
			],
			CounterHint = "重兵先碎【赤鳞龙躯/盘山龙尾】破盘绞；勿踩玄冥冻土接夏炎吐息；趁偶轮阖目以点穴/纯阳截断朔风"
		},
		boss_xiangliuwang = {
			TraitScript = "scripts/skills/special/wx_boss_trait_xiangliu",
			TraitID     = "special.wx_boss_trait_xiangliu",
			Skills = [
				"scripts/skills/actives/wx_boss_xiangliu_nine_devour",
				"scripts/skills/actives/wx_boss_xiangliu_mire_ram",
				"scripts/skills/actives/wx_boss_xiangliu_poison_deluge",
				"scripts/skills/actives/wx_boss_xiangliu_miasma_hex"
			],
			CounterHint = "优先斩灭【生肌血首】与【苦毒瘴首】封印对应凶招；以纯阳/烈火/火器灼封断颈防再生；登高台避苦泉"
		},
		boss_nvchou = {
			TraitScript = "scripts/skills/special/wx_boss_trait_nvchou",
			TraitID     = "special.wx_boss_trait_nvchou",
			Skills = [
				"scripts/skills/actives/wx_boss_nvchou_ten_suns_ray",
				"scripts/skills/actives/wx_boss_nvchou_sleeve_shift",
				"scripts/skills/actives/wx_boss_nvchou_scorch_apocalypse"
			],
			CounterHint = "神射/暗器优先『后羿射日』点灭空中日冕破阳炎障并断灭世咒；绕左后盲区背刺避右袂卸劲"
		}
	}
};

::Wuxia.ShanHai.findBossTrait <- function( _skills )
{
	if (_skills == null) return null;
	foreach (_, spec in ::Wuxia.ShanHai.BespokeBossSpecs)
	{
		local bt = _skills.getSkillByID(spec.TraitID);
		if (bt != null) return bt;
	}
	return _skills.getSkillByID("special.wx_shanhai_boss_trait");
};

::Wuxia.ShanHai.initBossEntity <- function( _actor, _bossID )
{
	if (_actor == null || !(_bossID in ::Wuxia.Config.ShanHaiBosses)) return;
	local cfg = ::Wuxia.Config.ShanHaiBosses[_bossID];

	_actor.setName(cfg.Name);
	_actor.m.IsMiniboss <- true;

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

		if (_bossID in ::Wuxia.ShanHai.BespokeBossSpecs)
		{
			local bSpec = ::Wuxia.ShanHai.BespokeBossSpecs[_bossID];
			skills.removeByID("special.wx_shanhai_boss_trait");
			skills.removeByID("actives.wx_boss_cataclysm");
			if (!skills.hasSkill(bSpec.TraitID))
				skills.add(::new(bSpec.TraitScript));
			foreach (skScript in bSpec.Skills)
			{
				local skInst = ::new(skScript);
				if (!skills.hasSkill(skInst.getID()))
					skills.add(skInst);
			}
		}
		else
		{
			local trait = skills.getSkillByID("special.wx_shanhai_boss_trait");
			if (trait == null)
			{
				trait = ::new("scripts/skills/special/wx_shanhai_boss_trait");
				trait.setBossID(cfg.Key);
				skills.add(trait);
			}
			if (!skills.hasSkill("actives.wx_boss_cataclysm"))
				skills.add(::new("scripts/skills/actives/wx_boss_cataclysm"));
		}
		skills.update();
	}
	_actor.m.Hitpoints <- _actor.getHitpointsMax();

	if (cfg.CustomBodySprite != null && _actor.hasSprite("body"))
	{
		_actor.m.WX_BossID <- _bossID;
		_actor.m.WX_CustomEnemyBust <- cfg.CustomBodySprite;
		if (::Wuxia.hasMember(_actor, "getFlags") && _actor.getFlags() != null)
			_actor.getFlags().set("WX_CustomEnemyBust", cfg.CustomBodySprite);
		local sprBody = _actor.getSprite("body");
		sprBody.setBrush(cfg.CustomBodySprite);
		sprBody.Visible = true;
		if ("Appearance" in ::Wuxia && "enforceWuxiaFacing" in ::Wuxia.Appearance)
			::Wuxia.Appearance.enforceWuxiaFacing(_actor);
		else if ("Tactical" in getroottable() && ::Tactical != null && ::Tactical.isActive() && ::Wuxia.hasMember(_actor, "isAlliedWithPlayer"))
			sprBody.setHorizontalFlipping(!_actor.isAlliedWithPlayer());
		if (cfg.CustomHeadSprite == null)
		{
			foreach (sub in [
				"head", "head_frenzy", "head_hurt", "helmet", "helmet_damage", "armor", "surcoat",
				"hair", "beard", "beard_top", "wings", "tattoo_body", "tattoo_head", "body_hurt", "body_blood",
				"legs_back", "legs_front", "tail", "charm_body", "arms_icon", "shield_icon", "injury", "injury_body", "tentacle"
			])
				if (_actor.hasSprite(sub)) _actor.getSprite(sub).Visible = false;
		}
	}
	if (cfg.CustomHeadSprite != null && _actor.hasSprite("head"))
		_actor.getSprite("head").setBrush(cfg.CustomHeadSprite);
	if ("Appearance" in ::Wuxia && "syncLindwurmTail" in ::Wuxia.Appearance)
		::Wuxia.Appearance.syncLindwurmTail(_actor);
};

::Wuxia.ShanHai.dropBossCore <- function( _bossID, _tile, _bossActor = null, _killer = null, _fatalityType = 0 )
{
	if (!(_bossID in ::Wuxia.Config.ShanHaiBosses)) return;
	local cfg = ::Wuxia.Config.ShanHaiBosses[_bossID];

	if (::Wuxia.hasWorldField("Flags"))
	{
		local slain = ::World.Flags.has("wx_slain_shanhai_count") ? ::World.Flags.getAsInt("wx_slain_shanhai_count") : 0;
		::World.Flags.set("wx_slain_shanhai_count", slain + 1);
		::World.Flags.set("wx_last_battle_shanhai_boss", true);
	}

	if (_tile == null) return;
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
		// Only player kills qualify for the part-break guarantee.
		local playerKill = _bossActor != null && !_bossActor.isPlayerControlled() && _killer != null
			&& _killer.isPlayerControlled() && !_bossActor.isAlliedWith(_killer);
		::Wuxia.BeastCraft.dropBossCompanionMaterials(cfg.Key, _tile, playerKill ? _bossActor : null, _fatalityType);
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

::Wuxia.ShanHai.ensureWildBeastTrait <- function( _actor )
{
	if (_actor == null || !::Wuxia.hasMember(_actor, "isAlive") || !_actor.isAlive()) return;
	if (::Wuxia.hasMember(_actor, "isPlayerControlled") && _actor.isPlayerControlled()) return;
	if (!::Wuxia.hasMember(_actor, "getSkills") || !::Wuxia.hasMember(_actor, "getType")) return;
	if (!("Const" in getroottable()) || !("EntityType" in ::Const)) return;

	if (("m" in _actor) && ("WX_IsBossSubEntity" in _actor.m) && _actor.m.WX_IsBossSubEntity) return;
	local sk = _actor.getSkills();
	if (sk == null || ::Wuxia.ShanHai.findBossTrait(sk) != null || sk.hasSkill("special.wx_wild_beast_trait"))
		return;

	local t = _actor.getType();
	local ET = ::Const.EntityType;
	local fam = null;
	if ((("Direwolf" in ET) && t == ET.Direwolf) || (("Wolf" in ET) && t == ET.Wolf)) fam = "direwolf";
	else if (("Hyena" in ET) && t == ET.Hyena) fam = "hyena";
	else if (("Spider" in ET) && t == ET.Spider) fam = "spider";
	else if (("Ghoul" in ET) && t == ET.Ghoul) fam = "ghoul";
	else if ((("Unhold" in ET) && t == ET.Unhold) || (("UnholdFrost" in ET) && t == ET.UnholdFrost) || (("UnholdBog" in ET) && t == ET.UnholdBog)) fam = "unhold";
	else if (("Lindwurm" in ET) && t == ET.Lindwurm) fam = "lindwurm";
	else if (("Schrat" in ET) && t == ET.Schrat) fam = "schrat";
	else if (("Serpent" in ET) && t == ET.Serpent) fam = "serpent";
	else if (("Alp" in ET) && t == ET.Alp) fam = "alp";
	else if (("Hexe" in ET) && t == ET.Hexe) fam = "hexe";
	else if (("SandGolem" in ET) && t == ET.SandGolem) fam = "sand_golem";

	if (fam != null)
	{
		local wt = ::new("scripts/skills/special/wx_wild_beast_trait");
		wt.initByFamily(fam);
		sk.add(wt);
	}
};

// Strictly gate Neidan Cores & Spirit Herbs to Sovereign Bosses, Warlords & Apex Mythic Beasts (zero drops on common/mid mobs)
::Wuxia.ShanHai.tryDropWildBeastLoot <- function( _actor, _tile )
{
	if (_actor == null || _tile == null) return;
	if (("m" in _actor) && ("WX_IsBossSubEntity" in _actor.m) && _actor.m.WX_IsBossSubEntity) return;
	local sk = (::Wuxia.hasMember(_actor, "getSkills")) ? _actor.getSkills() : null;
	if (sk != null && ::Wuxia.ShanHai.findBossTrait(sk) != null) return; // Handled by dropBossCore
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
	else if (("Vampire" in ET) && t == ET.Vampire)           { coreID = "wx_core_jianmo";     coreChance = 14;  herbChance = 6; }
	else if (("Alp" in ET) && t == ET.Alp)                   { coreID = "wx_core_esha";       coreChance = 10;  herbChance = 5; }
	else if (("Ghost" in ET) && t == ET.Ghost)               { coreID = "wx_core_yuanling";   coreChance = 10;  herbChance = 0; }
	else if (("Ghoul" in ET) && t == ET.Ghoul && ::Wuxia.hasMember(_actor, "getSize") && _actor.getSize() >= 3)
	                                                         { coreID = "wx_core_paoxiao";    coreChance = 16;  herbChance = 6; }
	else if (("Hyena" in ET) && t == ET.Hyena && ((sk != null && sk.hasSkill("racial.champion")) || (::Wuxia.hasMember(_actor, "getXPValue") && _actor.getXPValue() >= 175)))
	                                                         { coreID = "wx_core_gudiao";     coreChance = 15;  herbChance = 0; }
	else if (("Spider" in ET) && t == ET.Spider && sk != null && sk.hasSkill("racial.champion"))
	                                                         { coreID = "wx_core_chizhu";     coreChance = 35;  herbChance = 0; }
	// Small/common pack beasts do not spam Neidan Cores; rare wild cores drop only from apex/mature/champion specimens.

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
	local ew = dx > 4 ? "东" : (dx < -4 ? "西" : "");
	local ns = dy > 4 ? "北" : (dy < -4 ? "南" : "");
	if (ns != "" && ew != "") return ew + ns + "方";
	if (ns != "" || ew != "") return "正" + ns + ew + "方";
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

// Resolve `boss_*` config ID from a stronghold site key (`shanhai_zhuyan` -> `boss_zhuyan`)
::Wuxia.ShanHai.getBossIDForSite <- function( _siteKey )
{
	if (_siteKey == null || _siteKey == "") return null;
	if (_siteKey in ::Wuxia.Config.ShanHaiBosses) return _siteKey;
	if (_siteKey.find("shanhai_") == 0)
	{
		local bid = "boss_" + _siteKey.slice(8);
		if (bid in ::Wuxia.Config.ShanHaiBosses) return bid;
	}
	if (_siteKey in ::Wuxia.Config.Strongholds)
	{
		local def = ::Wuxia.Config.Strongholds[_siteKey];
		if ("Troops" in def && typeof def.Troops == "array")
		{
			foreach (tr in def.Troops)
			{
				if (tr in ::Wuxia.Config.ShanHaiBosses) return tr;
			}
		}
	}
	return null;
};

// Classify all 64 ShanHai Bosses cleanly into Tier 1 (玄级), Tier 2 (地级), Tier 3 (天级太古)
::Wuxia.ShanHai.getBossTier <- function( _bossID )
{
	if (_bossID == null || !(_bossID in ::Wuxia.Config.ShanHaiBosses)) return 1;
	local cfg = ::Wuxia.Config.ShanHaiBosses[_bossID];
	local str = ("Strength" in cfg) ? cfg.Strength : 50;
	local coreCfg = (("CoreID" in cfg) && (cfg.CoreID in ::Wuxia.Config.ShanHaiCores)) ? ::Wuxia.Config.ShanHaiCores[cfg.CoreID] : null;
	local isSov = (coreCfg != null && ("TierGroup" in coreCfg) && coreCfg.TierGroup == "sovereign");
	if (isSov || str >= 62)
		return 3;
	if (str >= 56)
		return 2;
	return 1;
};

::Wuxia.ShanHai.getBossTierInfo <- function( _tier )
{
	if (_tier >= 3) return { Tier = 3, Label = "天级太古凶兽", Short = "天级", MinDay = 70, MinRenown = 2000, Color = "#ff6b6b", TooltipColor = "#721010", Advice = "宜 9~11 级大成全队携克制灵丹与神兵讨伐" };
	if (_tier == 2) return { Tier = 2, Label = "地级山海大妖", Short = "地级", MinDay = 32, MinRenown = 950,  Color = "#f0b95b", TooltipColor = "#5e2c00", Advice = "宜 6~8 级成型队伍配克制丹散与破甲兵刃" };
	return { Tier = 1, Label = "玄级荒野凶兽", Short = "玄级", MinDay = 1,  MinRenown = 0,    Color = "#7fe3a8", TooltipColor = "#0a4213", Advice = "宜 4~6 级成军队伍备足丹药试锋" };
};

::Wuxia.ShanHai.isBossUnlockedForCampaign <- function( _bossID, _day, _renown )
{
	local tier = ::Wuxia.ShanHai.getBossTier(_bossID);
	if (tier <= 1) return true;
	// Late-game crisis stirs up all mythic beasts early!
	if ("World" in getroottable() && ::World != null && ("Flags" in ::World) && ::World.Flags != null)
	{
		local cr = ::World.Flags.has("wx_active_crisis") ? ::World.Flags.get("wx_active_crisis") : "";
		if (typeof cr == "string" && cr != "")
		{
			if (tier == 2) return true;
			if (tier == 3 && _day >= 55) return true;
		}
	}
	local info = ::Wuxia.ShanHai.getBossTierInfo(tier);
	return (_day >= info.MinDay) || (_renown >= info.MinRenown);
};

// Pre-combat tactical counterplay hints driven directly by the Boss's live Mechanics flags!
::Wuxia.ShanHai.getBossCounterHint <- function( _bossID )
{
	if (_bossID == null || !(_bossID in ::Wuxia.Config.ShanHaiBosses)) return "";
	if ((_bossID in ::Wuxia.ShanHai.BespokeBossSpecs) && ("CounterHint" in ::Wuxia.ShanHai.BespokeBossSpecs[_bossID]))
		return ::Wuxia.ShanHai.BespokeBossSpecs[_bossID].CounterHint;
	local cfg = ::Wuxia.Config.ShanHaiBosses[_bossID];
	local mech = ("Mechanics" in cfg && cfg.Mechanics != null) ? cfg.Mechanics : {};
	local hints = [];

	if (("OnHitPoison" in mech && mech.OnHitPoison) || ("AuraPoison" in mech && mech.AuraPoison))
		hints.push("备【清心丹/解毒散】防剧毒瘴气");
	if (("RegenHP" in mech && mech.RegenHP > 0) && ("PoisonCutsRegen" in mech && mech.PoisonCutsRegen > 0))
		hints.push("以毒/流血断其回血");
	else if ("RegenHP" in mech && mech.RegenHP > 0)
		hints.push("集火速斩防其持续自愈");
	if ("ThornsNonAxe" in mech && mech.ThornsNonAxe)
		hints.push("遣【巨斧/破盾手】免受铁棘反震");
	if (("AuraResolveOffbalance" in mech && mech.AuraResolveOffbalance) || ("VsHighResolve" in mech && mech.VsHighResolve))
		hints.push("备【定神丹/聚义令】稳固军心防魅惑失衡");
	if (("AuraArmorDmg" in mech && mech.AuraArmorDmg > 0) || ("AuraFatigue" in mech && mech.AuraFatigue > 0))
		hints.push("用【两格长兵/强弓劲弩】避开近身灼甲瘴环");
	if ("RangedMult" in mech && mech.RangedMult < 0.85)
		hints.push("其鳞甲抗箭，宜派近战穿甲主力贴身强杀");
	if (("SteelBrow" in mech && mech.SteelBrow) || ("ImmuneStun" in mech && mech.ImmuneStun))
		hints.push("免爆头/控场，勿过度依赖眩晕与爆头流");
	if ("OnHitDrainHP" in mech && mech.OnHitDrainHP > 0)
		hints.push("高闪避盾卫卡位，防其噬血续航");
	if ("OnHitAcupoint" in mech && mech.OnHitAcupoint)
		hints.push("备【回气/聚灵丹】抵御封穴断气");
	if ("EnrageBelowPct" in mech && mech.EnrageBelowPct > 0)
		hints.push("半血狂暴前预留大招与内息一轮斩杀");
	if (hints.len() == 0)
		hints.push("备足【护心丹/金疮散】与破甲重兵稳扎稳打");

	local out = "";
	local maxH = ::Math.min(3, hints.len());
	for (local i = 0; i < maxH; i = ++i)
	{
		if (i > 0) out += "；";
		out += hints[i];
	}
	return out;
};
