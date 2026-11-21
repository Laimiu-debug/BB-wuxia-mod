// Stage 3 (`3_characters`) Global Human 1000-Faces, Armor Upgrade & 50-Bust Enemy Integration Hooks
// Non-destructively covers:
//   1. Extra Stage-3 `wx_char_*` robes/armors/hats & `armor_upgrade.*` -> `wx_back_01..16` remapping
//   2. `scripts/entity/tactical/human` (`onInit`, `assignRandomEquipment`, `onFactionChanged`, `onDamageReceived`, safe `onDeath`)
//   3. All human & bespoke-bust enemy scripts in `::Const.World.Spawn.Troops` (Bandits, Nomads, Noble/Southern Armies,
//      Militia, Caravans, Mercenaries, Barbarians, Five-Venoms/Goblins, Yaoren/Orcs, Tomb Automatons/Skeletons,
//      Xiangxi Jiangshi/Zombies, Necromancers, Vampires & Tomb Wraiths/Ghosts)

// 1. Merge Stage-3 `wx_char_*` & `armor_upgrade.*` visual mappings into `::Wuxia.Armory`
if ("Armory" in ::Wuxia && "Appearance" in ::Wuxia.Config)
{
	local appCfg = ::Wuxia.Config.Appearance;
	foreach (aid, aSpec in appCfg.ExtraArmorMap)
	{
		if (!(aid in ::Wuxia.Armory.ArmorMap))
			::Wuxia.Armory.ArmorMap[aid] <- aSpec;
	}
	foreach (hid, hSpec in appCfg.ExtraHelmetMap)
	{
		if (!(hid in ::Wuxia.Armory.HelmetMap))
			::Wuxia.Armory.HelmetMap[hid] <- hSpec;
	}

	foreach (cb in ["wx_char_cloth_short", "wx_char_raincape"])
		::Wuxia.Armory.FallbackCivBodies.push(cb);
	foreach (sb in ["wx_char_robe_swordsman", "wx_char_robe_taoist", "wx_char_robe_monk", "wx_char_robe_beggar", "wx_char_armor_wudu"])
		::Wuxia.Armory.FallbackSectBodies.push(sb);
	foreach (ab in ["wx_char_armor_brigandine", "wx_char_armor_jinyi"])
		::Wuxia.Armory.FallbackArmBodies.push(ab);
	::Wuxia.Armory.FallbackHvyBodies.push("wx_char_armor_shanwen");

	foreach (lh in ["wx_char_hat_bamboo", "wx_char_hat_topknot", "wx_char_hat_taoist"])
		::Wuxia.Armory.FallbackLightHats.push(lh);
	::Wuxia.Armory.FallbackHvyHats.push("wx_char_hat_helm_fengchi");

	::Wuxia.Armory.ensureUpgradeMapped <- function( _upg )
	{
		if (_upg == null || !::Wuxia.Appearance.hasMember(_upg, "getID")) return;
		if ("WX_UpgMapped" in _upg.m && _upg.m.WX_UpgMapped) return;

		local id = _upg.getID();
		if (id == null || id == "" || id.find("armor_upgrade.") != 0) return;
		_upg.m.WX_UpgMapped <- true;

		local map = ::Wuxia.Config.Appearance.ArmorUpgradeMap;
		local backID = null;
		if (id in map)
		{
			backID = map[id][0];
			_upg.m.Name = map[id][1];
		}
		else
		{
			local idxB = 1 + (::Wuxia.Armory.hashString(id) % 16);
			backID = "wx_back_" + ::Wuxia.Appearance.pad2(idxB);
		}

		_upg.m.Icon = "armor_upgrades/" + backID + ".png";
		if (::Wuxia.hasMember(_upg.m, "OverlayIconLarge") && _upg.m.OverlayIconLarge != "")
			_upg.m.OverlayIconLarge = "armor_upgrades/" + backID + ".png";
		_upg.m.WX_BackBrush <- backID;
	};
}

// Hook `armor_upgrade` so armor attachments display `wx_back_01..16` icons, names & paperdoll cloaks/banners
::Wuxia.HooksMod.hook("scripts/items/armor_upgrades/armor_upgrade", function( q )
{
	q.getName = @(__original) function()
	{
		if ("ensureUpgradeMapped" in ::Wuxia.Armory) ::Wuxia.Armory.ensureUpgradeMapped(this);
		return __original();
	};

	q.getIcon = @(__original) function()
	{
		if ("ensureUpgradeMapped" in ::Wuxia.Armory) ::Wuxia.Armory.ensureUpgradeMapped(this);
		return __original();
	};

	if ("getOverlayIconLarge" in q)
	{
		q.getOverlayIconLarge = @(__original) function()
		{
			if ("ensureUpgradeMapped" in ::Wuxia.Armory) ::Wuxia.Armory.ensureUpgradeMapped(this);
			return __original();
		};
	}

	if ("updateAppearance" in q)
	{
		q.updateAppearance = @(__original) function( _app )
		{
			if ("ensureUpgradeMapped" in ::Wuxia.Armory) ::Wuxia.Armory.ensureUpgradeMapped(this);
			__original(_app);
			if (this.m.Armor != null && this.m.Armor.getContainer() != null)
				::Wuxia.Armory.syncActorHandheldAndArmor(this.m.Armor.getContainer().getActor());
		};
	}

	if ("onAdded" in q)
	{
		q.onAdded = @(__original) function()
		{
			if ("ensureUpgradeMapped" in ::Wuxia.Armory) ::Wuxia.Armory.ensureUpgradeMapped(this);
			__original();
			if (this.m.Armor != null && this.m.Armor.getContainer() != null)
				::Wuxia.Armory.syncActorHandheldAndArmor(this.m.Armor.getContainer().getActor());
		};
	}

	if ("onDeserialize" in q)
	{
		q.onDeserialize = @(__original) function( _in )
		{
			__original(_in);
			if ("ensureUpgradeMapped" in ::Wuxia.Armory) ::Wuxia.Armory.ensureUpgradeMapped(this);
		};
	}
});

// 2. Global `scripts/entity/tactical/human` Hook (covers all player brothers, townsfolk, militia, armies & human enemies)
::Wuxia.HooksMod.hook("scripts/entity/tactical/human", function( q )
{
	q.onInit = @(__original) function()
	{
		__original();
		::Wuxia.Appearance.saveOriginalVanillaBrushes(this);
		local autoBust = ::Wuxia.Appearance.resolveAutoEnemyBust(this);
		if (autoBust != null)
			::Wuxia.Appearance.applyCustomEnemyBust(this, autoBust);
		else
			::Wuxia.Appearance.refreshActorSprites(this);
	};

	q.assignRandomEquipment = @(__original) function()
	{
		__original();
		local autoBust = ::Wuxia.Appearance.resolveAutoEnemyBust(this);
		if (autoBust != null)
			::Wuxia.Appearance.applyCustomEnemyBust(this, autoBust);
		::Wuxia.Armory.syncActorHandheldAndArmor(this);
	};

	q.onFactionChanged = @(__original) function()
	{
		__original();
		local flip = !this.isAlliedWithPlayer();
		if ("WX_CustomEnemyBust" in this.m && this.m.WX_CustomEnemyBust != null)
		{
			if (this.hasSprite("body")) this.getSprite("body").setHorizontalFlipping(flip);
			return;
		}
		foreach (lyr in ["body", "surcoat", "tattoo_body", "armor_upgrade_back", "head", "tattoo_head", "beard", "hair", "helmet", "arms_icon", "shield_icon"])
		{
			if (this.hasSprite(lyr))
				this.getSprite(lyr).setHorizontalFlipping(flip);
		}
	};

	q.onDamageReceived = @(__original) function( _attacker, _skill, _hitInfo )
	{
		local ret = __original(_attacker, _skill, _hitInfo);
		if (this.isAlive())
		{
			::Wuxia.Armory.syncActorHandheldAndArmor(this);
		}
		return ret;
	};

	q.onDeath = @(__original) function( _killer, _skill, _tile, _fatalityType )
	{
		this.m.WX_DeathHandled <- true;
		local wxDeathSnap = ::Wuxia.Appearance.captureDeathLayers(this);
		::Wuxia.Appearance.restoreVanillaBrushesForDeath(this);
		__original(_killer, _skill, _tile, _fatalityType);
		::Wuxia.Appearance.applyWuxiaCorpseDecals(this, _tile, _fatalityType, wxDeathSnap);
	};
});

// Ensure every tactical actor with a bespoke `wx_enemy_*`, `wx_beast_*` or `wx_boss_*` bust flips correctly toward the player
::Wuxia.HooksMod.hook("scripts/entity/tactical/actor", function( q )
{
	q.onFactionChanged = @(__original) function()
	{
		__original();
		if (this.hasSprite("body"))
		{
			local sb = this.getSprite("body");
			local bn = (sb != null && sb.HasBrush) ? sb.getBrush().Name : "";
			if (("WX_CustomEnemyBust" in this.m && this.m.WX_CustomEnemyBust != null) || bn.find("wx_boss_") == 0 || bn.find("wx_beast_") == 0 || bn.find("wx_enemy_") == 0 || bn.find("wx_char_enemy_") == 0)
			{
				sb.setHorizontalFlipping(!this.isAlliedWithPlayer());
			}
		}
	};
});

// 3. Complete `::Const.World.Spawn.Troops` Hook for all Human Subclasses & Bespoke Non-Human Enemy Archetypes
local registerAppearanceTroopHook = function( _scriptPath )
{
	::Wuxia.HooksMod.hook(_scriptPath, function( q )
	{
		if ("onInit" in q)
		{
			q.onInit = @(__original) function()
			{
				__original();
				::Wuxia.Appearance.saveOriginalVanillaBrushes(this);
				local autoBust = ::Wuxia.Appearance.resolveAutoEnemyBust(this);
				if (autoBust != null)
					::Wuxia.Appearance.applyCustomEnemyBust(this, autoBust);
				else if (::Wuxia.Appearance.isEligibleHumanActor(this))
					::Wuxia.Appearance.refreshActorSprites(this);
			};
		}

		if ("assignRandomEquipment" in q)
		{
			q.assignRandomEquipment = @(__original) function()
			{
				__original();
				local autoBust = ::Wuxia.Appearance.resolveAutoEnemyBust(this);
				if (autoBust != null)
					::Wuxia.Appearance.applyCustomEnemyBust(this, autoBust);
				::Wuxia.Armory.syncActorHandheldAndArmor(this);
			};
		}

		if ("onFactionChanged" in q)
		{
			q.onFactionChanged = @(__original) function()
			{
				__original();
				if ("WX_CustomEnemyBust" in this.m && this.m.WX_CustomEnemyBust != null && this.hasSprite("body"))
				{
					this.getSprite("body").setHorizontalFlipping(!this.isAlliedWithPlayer());
				}
			};
		}

		if ("grow" in q)
		{
			q.grow = @(__original) function( _instant = false )
			{
				__original(_instant);
				if ("WX_CustomEnemyBust" in this.m && this.m.WX_CustomEnemyBust != null)
				{
					::Wuxia.Appearance.applyCustomEnemyBust(this, this.m.WX_CustomEnemyBust);
					if (::Wuxia.hasMember(this, "getSize") && this.hasSprite("body"))
					{
						local gSz = this.getSize();
						this.getSprite("body").Scale = (gSz >= 3) ? 1.22 : ((gSz == 2) ? 1.11 : 1.0);
					}
				}
			};
		}

		if ("setFrenzy" in q)
		{
			q.setFrenzy = @(__original) function( _f )
			{
				__original(_f);
				if ("WX_CustomEnemyBust" in this.m && this.m.WX_CustomEnemyBust != null)
					::Wuxia.Appearance.applyCustomEnemyBust(this, this.m.WX_CustomEnemyBust);
			};
		}

		if ("onResurrected" in q)
		{
			q.onResurrected = @(__original) function( _info )
			{
				__original(_info);
				local autoBust = ::Wuxia.Appearance.resolveAutoEnemyBust(this);
				if (autoBust != null)
					::Wuxia.Appearance.applyCustomEnemyBust(this, autoBust);
				::Wuxia.Armory.syncActorHandheldAndArmor(this);
			};
		}

		if ("onDeath" in q)
		{
			q.onDeath = @(__original) function( _killer, _skill, _tile, _fatalityType )
			{
				this.m.WX_DeathHandled <- true;
				local wxDeathSnap = ::Wuxia.Appearance.captureDeathLayers(this);
				::Wuxia.Appearance.restoreVanillaBrushesForDeath(this);
				__original(_killer, _skill, _tile, _fatalityType);
				::Wuxia.Appearance.applyWuxiaCorpseDecals(this, _tile, _fatalityType, wxDeathSnap);
			};
		}
	});
};

if ("Const" in getroottable() && "World" in ::Const && "Spawn" in ::Const.World && "Troops" in ::Const.World.Spawn)
{
	local seenTroopScripts = {
		["scripts/entity/tactical/human"]  = true,
		["scripts/entity/tactical/player"] = true
	};
	local bustMap   = ::Wuxia.Config.Appearance.EnemyEntityBustMap;
	local humanMap  = ::Wuxia.Config.Appearance.HumanEntityPresets;

	foreach (troopKey, troopDef in ::Const.World.Spawn.Troops)
	{
		if (troopDef == null || !("Script" in troopDef) || troopDef.Script == null || troopDef.Script == "")
			continue;
		local sp = troopDef.Script;
		if (sp in seenTroopScripts)
			continue;

		local eKey = ("ID" in troopDef) ? (function( _id ) {
			foreach (k, v in ::Const.EntityType) { if (v == _id) return k; }
			return "";
		})(troopDef.ID) : "";

		local isHumanScript = (sp.find("scripts/entity/tactical/humans/") == 0)
			|| (sp.find("bandit_") != null)
			|| (sp.find("nomad_") != null)
			|| (sp.find("barbarian_") != null)
			|| (sp.find("cultist") != null)
			|| (sp.find("peasant") != null)
			|| (sp.find("militia") != null)
			|| (sp.find("caravan_") != null);

		if (isHumanScript || (eKey in bustMap) || (eKey in humanMap))
		{
			seenTroopScripts[sp] <- true;
			registerAppearanceTroopHook(sp);
		}
	}

	local extraScripts = [
		"scripts/entity/tactical/enemies/skeleton_boss",
		"scripts/entity/tactical/enemies/zombie_betrayer",
		"scripts/entity/tactical/enemies/ghost"
	];
	if ("EntityType" in ::Const)
	{
		if ("SpiderEggs" in ::Const.EntityType)  extraScripts.push("scripts/entity/tactical/enemies/spider_eggs");
		if ("SchratSmall" in ::Const.EntityType) extraScripts.push("scripts/entity/tactical/enemies/schrat_small");
	}
	foreach (extraEnemySp in extraScripts)
	{
		if (!(extraEnemySp in seenTroopScripts))
		{
			seenTroopScripts[extraEnemySp] <- true;
			registerAppearanceTroopHook(extraEnemySp);
		}
	}
}
