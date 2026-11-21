// Runtime System for Beast & Shan Hai Jing Forging:
//   - Applies Tier-A Beast Gear (`wx_beast_*`) & Armor Upgrades (`wx_up_*`) stats/visuals
//   - Injects `WX_GearTraitID` passive skill (`special.wx_gear_spirit_trait`) & tooltip row onto all Beast/Shan-Hai gear
//   - Drops forging materials (`wx_mat_*`) from wild Shan-Hai beasts & companion materials from all 64 Shan-Hai Bosses
//   - Unlocks Wuxia crafting blueprints in 百工丹坊 immediately as soon as ANY primary material/core is held or identified!

::Wuxia.BeastCraft <- {
	EntityTypeToKey = null
};

::Wuxia.BeastCraft.getEntityKey <- function( _typeIdx )
{
	if (::Wuxia.BeastCraft.EntityTypeToKey == null)
	{
		::Wuxia.BeastCraft.EntityTypeToKey = {};
		if ("Const" in getroottable() && "EntityType" in ::Const)
		{
			foreach (k, v in ::Const.EntityType)
			{
				if (typeof v == "integer")
					::Wuxia.BeastCraft.EntityTypeToKey[v] <- k;
			}
		}
	}
	return (_typeIdx in ::Wuxia.BeastCraft.EntityTypeToKey) ? ::Wuxia.BeastCraft.EntityTypeToKey[_typeIdx] : null;
};

::Wuxia.BeastCraft.hasAuraWard <- function( _actor )
{
	if (_actor == null || !(::Wuxia.hasMember(_actor, "getItems")) || _actor.getItems() == null) return false;
	local body = _actor.getItems().getItemAtSlot(::Const.ItemSlot.Body);
	if (body != null && ("m" in body) && ("WX_GearTraitID" in body.m) && body.m.WX_GearTraitID != null)
	{
		if ("GearTraits" in ::Wuxia.Config && (body.m.WX_GearTraitID in ::Wuxia.Config.GearTraits))
		{
			local tcfg = ::Wuxia.Config.GearTraits[body.m.WX_GearTraitID];
			if (("ImmuneAcidAndFireAura" in tcfg) && tcfg.ImmuneAcidAndFireAura)
				return true;
		}
	}
	return false;
};

::Wuxia.BeastCraft.applyBeastWeapon <- function( _item, _gearID, _onDeserializeOnly = false )
{
	if (_item == null || !("BeastGear" in ::Wuxia.Config) || !(_gearID in ::Wuxia.Config.BeastGear)) return;
	local cfg = ::Wuxia.Config.BeastGear[_gearID];
	_item.m.ID = "weapon." + cfg.ID;
	if (!_onDeserializeOnly)
	{
		_item.m.Name = cfg.Name;
		_item.m.Description = cfg.Description;
		_item.m.Value = cfg.Value;
		_item.m.Condition = cfg.Condition;
		_item.m.ConditionMax = cfg.Condition;
		_item.m.StaminaModifier = cfg.StaminaModifier;
		_item.m.RegularDamage = cfg.RegularDamage;
		_item.m.RegularDamageMax = cfg.RegularDamageMax;
		_item.m.ArmorDamageMult = cfg.ArmorDamageMult;
		_item.m.DirectDamageMult = cfg.DirectDamageMult;
	}
	if ("Categories" in cfg && cfg.Categories != null) _item.m.Categories = cfg.Categories;
	_item.m.Icon = cfg.Icon;
	_item.m.IconLarge = cfg.IconLarge;
	_item.m.ShowArmamentIcon = true;
	_item.m.ArmamentIcon = cfg.ArmBrush;
	_item.m.WX_ArmBrush <- cfg.ArmBrush;
	_item.m.WX_BeastGearID <- _gearID;
	_item.m.WX_GearTraitID <- ("TraitID" in cfg) ? cfg.TraitID : null;
	_item.m.WX_MappedID <- _item.m.ID;
	_item.m.WX_ExpectedIcon <- _item.m.Icon;
	::Wuxia.BeastCraft.bindTraitMethods(_item);
	if (_onDeserializeOnly && ("Forge" in ::Wuxia) && ("restoreFromVariant" in ::Wuxia.Forge))
		::Wuxia.Forge.restoreFromVariant(_item);
};

::Wuxia.BeastCraft.applyBeastShield <- function( _item, _gearID, _onDeserializeOnly = false )
{
	if (_item == null || !("BeastGear" in ::Wuxia.Config) || !(_gearID in ::Wuxia.Config.BeastGear)) return;
	local cfg = ::Wuxia.Config.BeastGear[_gearID];
	_item.m.ID = "shield." + cfg.ID;
	if (!_onDeserializeOnly)
	{
		_item.m.Name = cfg.Name;
		_item.m.Description = cfg.Description;
		_item.m.Value = cfg.Value;
		_item.m.Condition = cfg.Condition;
		_item.m.ConditionMax = cfg.Condition;
		_item.m.MeleeDefense = cfg.MeleeDefense;
		_item.m.RangedDefense = cfg.RangedDefense;
		_item.m.StaminaModifier = cfg.StaminaModifier;
	}
	_item.m.Icon = cfg.Icon;
	_item.m.IconLarge = cfg.IconLarge;
	_item.m.WX_ShieldBrush <- cfg.ShieldBrush;
	_item.m.WX_BeastGearID <- _gearID;
	_item.m.WX_GearTraitID <- ("TraitID" in cfg) ? cfg.TraitID : null;
	_item.m.WX_MappedID <- _item.m.ID;
	_item.m.WX_ExpectedIcon <- _item.m.Icon;
	::Wuxia.BeastCraft.bindTraitMethods(_item);
	if (_onDeserializeOnly && ("Forge" in ::Wuxia) && ("restoreFromVariant" in ::Wuxia.Forge))
		::Wuxia.Forge.restoreFromVariant(_item);
};

::Wuxia.BeastCraft.applyBeastArmorOrHelmet <- function( _item, _gearID, _onDeserializeOnly = false )
{
	if (_item == null || !("BeastGear" in ::Wuxia.Config) || !(_gearID in ::Wuxia.Config.BeastGear)) return;
	local cfg = ::Wuxia.Config.BeastGear[_gearID];
	_item.m.ID = (cfg.Kind == "helmet" ? "armor.head." : "armor.body.") + cfg.ID;
	if (!_onDeserializeOnly)
	{
		_item.m.Name = cfg.Name;
		_item.m.Description = cfg.Description;
		_item.m.Value = cfg.Value;
		_item.m.Condition = cfg.Condition;
		_item.m.ConditionMax = cfg.Condition;
		_item.m.StaminaModifier = cfg.StaminaModifier;
		if ("Vision" in cfg && ::Wuxia.hasMember(_item.m, "Vision")) _item.m.Vision = cfg.Vision;
	}
	_item.m.Icon = cfg.Icon;
	if (cfg.Kind == "armor")
	{
		_item.m.IconLarge = cfg.IconLarge;
		_item.m.WX_BodyBrush <- cfg.BodyBrush;
	}
	else
	{
		_item.m.WX_HatID <- cfg.HatID;
		_item.m.WX_HatFrontBrush <- cfg.HatID + "_front";
		_item.m.WX_HatBackBrush <- cfg.HatID + "_back";
	}
	_item.m.WX_BeastGearID <- _gearID;
	_item.m.WX_GearTraitID <- ("TraitID" in cfg) ? cfg.TraitID : null;
	_item.m.WX_MappedID <- _item.m.ID;
	_item.m.WX_ExpectedIcon <- _item.m.Icon;
	::Wuxia.BeastCraft.bindTraitMethods(_item);
	if (_onDeserializeOnly && ("Forge" in ::Wuxia) && ("restoreFromVariant" in ::Wuxia.Forge))
		::Wuxia.Forge.restoreFromVariant(_item);
};

::Wuxia.BeastCraft.applyBeastUpgrade <- function( _upg, _gearID, _onDeserializeOnly = false )
{
	if (_upg == null || !("BeastGear" in ::Wuxia.Config) || !(_gearID in ::Wuxia.Config.BeastGear)) return;
	local cfg = ::Wuxia.Config.BeastGear[_gearID];
	_upg.m.ID = "armor_upgrade." + cfg.ID;
	if (!_onDeserializeOnly)
	{
		_upg.m.Name = cfg.Name;
		_upg.m.Description = cfg.Description;
		_upg.m.Value = cfg.Value;
		_upg.m.ConditionModifier = cfg.ArmorBonus;
		_upg.m.StaminaModifier = cfg.StaminaModifier;
	}
	_upg.m.Icon = "armor_upgrades/" + cfg.BackBrush + ".png";
	_upg.m.OverlayIcon = "";
	_upg.m.OverlayIconLarge = "";
	_upg.m.WX_BackBrush <- cfg.BackBrush;
	_upg.m.WX_UpgMapped <- true;
	_upg.m.WX_UpgCfgID <- _gearID;
	_upg.m.WX_MappedID <- _upg.m.ID;
	_upg.m.WX_ExpectedIcon <- _upg.m.Icon;
	::Wuxia.BeastCraft.bindTraitMethods(_upg);
};

::Wuxia.BeastCraft.initBlueprint <- function( _bp, _bpID )
{
	if (_bp == null || !("CraftBlueprints" in ::Wuxia.Config) || !(_bpID in ::Wuxia.Config.CraftBlueprints)) return;
	local cfg = ::Wuxia.Config.CraftBlueprints[_bpID];
	_bp.m.ID = "blueprint." + _bpID;
	_bp.m.PreviewCraftable = ::new(cfg.Product);
	if (_bp.m.PreviewCraftable != null)
		_bp.m.PreviewCraftable.m.WX_IsBlueprintPreview <- true;
	_bp.m.Cost = cfg.Cost;
	_bp.init(cfg.Ingredients);
};

::Wuxia.BeastCraft.craftBlueprintProduct <- function( _bpID, _stash )
{
	if (_stash == null || !("CraftBlueprints" in ::Wuxia.Config) || !(_bpID in ::Wuxia.Config.CraftBlueprints)) return;
	local cfg = ::Wuxia.Config.CraftBlueprints[_bpID];
	_stash.add(::new(cfg.Product));
};

::Wuxia.BeastCraft.tryDropWildBeastMaterial <- function( _actor, _killer, _tile )
{
	if (_actor == null || _tile == null || _killer == null) return;
	if (!(::Wuxia.hasMember(_killer, "isPlayerControlled")) || !_killer.isPlayerControlled() || _actor.isAlliedWith(_killer)) return;
	local sk = (::Wuxia.hasMember(_actor, "getSkills")) ? _actor.getSkills() : null;
	if (sk != null && sk.hasSkill("special.wx_shanhai_boss_trait")) return; // Handled by dropBossCore!
	if (!(::Wuxia.hasMember(_actor, "getType")) || !("WildBeastDrops" in ::Wuxia.Config)) return;

	local eKey = ::Wuxia.BeastCraft.getEntityKey(_actor.getType());
	if (eKey == null || !(eKey in ::Wuxia.Config.WildBeastDrops)) return;

	local spec = ::Wuxia.Config.WildBeastDrops[eKey];
	if (spec.Pool.len() > 0 && ::Math.rand(1, 100) <= spec.Chance)
	{
		local matID = spec.Pool[::Math.rand(0, spec.Pool.len() - 1)];
		local matItem = ::new("scripts/items/misc/" + matID);
		matItem.drop(_tile);
	}
};

::Wuxia.BeastCraft.dropBossCompanionMaterials <- function( _bossKey, _tile )
{
	if (_tile == null || !("BossBonusLoot" in ::Wuxia.Config)) return;
	local bonus = (_bossKey in ::Wuxia.Config.BossBonusLoot)
		? ::Wuxia.Config.BossBonusLoot[_bossKey]
		: { Mat = "wx_mat_shagu", Trophy = "unhold_hide_item" };

	local count = (::Math.rand(1, 100) <= 45) ? 2 : 1;
	for (local i = 0; i < count; i = ++i)
	{
		local mat = ::new("scripts/items/misc/" + bonus.Mat);
		mat.drop(_tile);
	}
	if ("Trophy" in bonus && bonus.Trophy != null && bonus.Trophy != "")
	{
		local tr = ::new("scripts/items/misc/" + bonus.Trophy);
		tr.drop(_tile);
	}
};

::Wuxia.BeastCraft.getBlueprintComponents <- function( _bp )
{
	if (_bp == null || !("m" in _bp)) return null;
	if (::Wuxia.hasMember(_bp.m, "PreviewComponents") && _bp.m.PreviewComponents != null)
		return _bp.m.PreviewComponents;
	if (::Wuxia.hasMember(_bp.m, "Ingredients") && _bp.m.Ingredients != null)
		return _bp.m.Ingredients;
	return null;
};

::Wuxia.BeastCraft.countIngredient <- function( _ing, _stashItems )
{
	local out = { Stash = 0, Cabinet = 0, Total = 0, Meta = null };
	if (_ing == null || !("Instance" in _ing) || _ing.Instance == null) return out;
	local itemID = _ing.Instance.getID();
	if (_stashItems != null)
	{
		foreach (it in _stashItems)
		{
			if (it != null && it.getID() == itemID)
				out.Stash += 1;
		}
	}
	if (("Alchemy" in ::Wuxia) && ("Cabinet" in ::Wuxia.Alchemy) && ("classifyItem" in ::Wuxia.Alchemy))
	{
		local meta = ::Wuxia.Alchemy.classifyItem(_ing.Instance);
		if (meta != null)
		{
			out.Meta = meta;
			out.Cabinet = ::Wuxia.Alchemy.Cabinet.getCount(meta.Key);
		}
	}
	out.Total = out.Stash + out.Cabinet;
	return out;
};

::Wuxia.BeastCraft.bindTraitMethods <- function( _item )
{
	if (_item == null || !("m" in _item))
		return;

	if (("WX_UpgCfgID" in _item.m) && _item.m.WX_UpgCfgID != null)
	{
		if (!("WX_BoundUpgTooltipFn" in _item.m) || _item.getTooltip != _item.m.WX_BoundUpgTooltipFn)
		{
			local baseUpgTT = _item.getTooltip;
			local wrappedUpgTT = (function()
			{
				local ret = baseUpgTT.call(this);
				if (ret != null && typeof ret == "array" && ("BeastGear" in ::Wuxia.Config) && (this.m.WX_UpgCfgID in ::Wuxia.Config.BeastGear))
				{
					local hasRow = false;
					foreach (r in ret) { if (r != null && typeof r == "table" && ("id" in r) && r.id == 69) { hasRow = true; break; } }
					if (!hasRow)
					{
						local ucfg = ::Wuxia.Config.BeastGear[this.m.WX_UpgCfgID];
						local bTxt = this.getEffectiveBonusText();
						ret.push({ id = 69, type = "text", icon = "ui/icons/special.png", text = "[color=#2f6e62]【百工镶缀】[/color]" + bTxt });
					}
				}
				if ("Forge" in ::Wuxia && "injectForgeTooltip" in ::Wuxia.Forge)
					ret = ::Wuxia.Forge.injectForgeTooltip(this, ret);
				return ret;
			}).bindenv(_item);
			_item.getTooltip <- wrappedUpgTT;
			_item.m.WX_BoundUpgTooltipFn <- wrappedUpgTT;
		}
		if (!("WX_BoundArmorTooltipFn" in _item.m) || _item.onArmorTooltip != _item.m.WX_BoundArmorTooltipFn)
		{
			local baseArmTT = _item.onArmorTooltip;
			local wrappedArmTT = (function( _result )
			{
				baseArmTT.call(this, _result);
				if (_result != null && typeof _result == "array" && ("BeastGear" in ::Wuxia.Config) && (this.m.WX_UpgCfgID in ::Wuxia.Config.BeastGear))
				{
					local hasRow = false;
					foreach (r in _result) { if (r != null && typeof r == "table" && ("id" in r) && r.id == 69) { hasRow = true; break; } }
					if (!hasRow)
					{
						local ucfg = ::Wuxia.Config.BeastGear[this.m.WX_UpgCfgID];
						local bTxt2 = this.getEffectiveBonusText();
						local gTag = (("WX_ForgeGradeTitle" in this.m) && this.m.WX_ForgeGradeTitle != null && this.m.WX_ForgeGradeTitle != "") ? (this.m.WX_ForgeGradeTitle + "·") : "";
						_result.push({ id = 69, type = "text", icon = "ui/icons/special.png", text = "[color=#2f6e62]【" + gTag + ucfg.Name + "】[/color]" + bTxt2 });
					}
				}
			}).bindenv(_item);
			_item.onArmorTooltip <- wrappedArmTT;
			_item.m.WX_BoundArmorTooltipFn <- wrappedArmTT;
		}
	}

	if (!("WX_GearTraitID" in _item.m) || _item.m.WX_GearTraitID == null)
	{
		if (("WX_RelicID" in _item.m) && _item.m.WX_RelicID != null
			&& (!("WX_BoundRelicTooltipFn" in _item.m) || _item.getTooltip != _item.m.WX_BoundRelicTooltipFn))
		{
			local baseRelicTT = _item.getTooltip;
			local wrappedRelicTT = (function()
			{
				local ret = baseRelicTT.call(this);
				if ("Forge" in ::Wuxia && "injectForgeTooltip" in ::Wuxia.Forge)
					ret = ::Wuxia.Forge.injectForgeTooltip(this, ret);
				return ret;
			}).bindenv(_item);
			_item.getTooltip <- wrappedRelicTT;
			_item.m.WX_BoundRelicTooltipFn <- wrappedRelicTT;
		}
		return;
	}

	if (!("WX_BoundEquipFn" in _item.m) || _item.onEquip != _item.m.WX_BoundEquipFn)
	{
		local baseOnEquip = _item.onEquip;
		local wrappedEquip = (function()
		{
			baseOnEquip.call(this);
			::Wuxia.BeastCraft.injectTraitSkill(this);
		}).bindenv(_item);
		_item.onEquip <- wrappedEquip;
		_item.m.WX_BoundEquipFn <- wrappedEquip;
	}
	if (!("WX_BoundTooltipFn" in _item.m) || _item.getTooltip != _item.m.WX_BoundTooltipFn)
	{
		local baseGetTooltip = _item.getTooltip;
		local wrappedTooltip = (function()
		{
			local ret = baseGetTooltip.call(this);
			return ::Wuxia.BeastCraft.injectTraitTooltip(this, ret);
		}).bindenv(_item);
		_item.getTooltip <- wrappedTooltip;
		_item.m.WX_BoundTooltipFn <- wrappedTooltip;
	}
};

::Wuxia.BeastCraft.injectTraitSkill <- function( _item )
{
	if (_item == null || !("m" in _item) || !("WX_GearTraitID" in _item.m) || _item.m.WX_GearTraitID == null)
		return;
	local tid = _item.m.WX_GearTraitID;
	if (!("GearTraits" in ::Wuxia.Config) || !(tid in ::Wuxia.Config.GearTraits))
		return;
	if (::Wuxia.hasMember(_item.m, "SkillPtrs") && _item.m.SkillPtrs != null)
	{
		foreach (sk in _item.m.SkillPtrs)
		{
			if (sk != null && ("m" in sk) && (::Wuxia.hasMember(sk.m, "TraitID")) && sk.m.TraitID == tid)
				return;
		}
	}
	local traitSk = ::new("scripts/skills/special/wx_gear_spirit_trait");
	traitSk.setTraitID(tid);
	_item.addSkill(traitSk);
};

::Wuxia.BeastCraft.injectTraitTooltip <- function( _item, _ret )
{
	if (_ret == null || typeof _ret != "array" || _item == null || !("m" in _item))
		return _ret;
	if (!("WX_GearTraitID" in _item.m) || _item.m.WX_GearTraitID == null)
		return _ret;
	local tid = _item.m.WX_GearTraitID;
	if (!("GearTraits" in ::Wuxia.Config) || !(tid in ::Wuxia.Config.GearTraits))
		return _ret;
	foreach (row in _ret)
	{
		if (row != null && typeof row == "table" && ("id" in row) && row.id == 968)
			return _ret;
	}
	local tcfg = ::Wuxia.Config.GearTraits[tid];
	local tagPrefix = (tcfg.Tier == "shanhai")
		? ("[color=#d99b26]【山海神通 · " + tcfg.Title + "】[/color]")
		: ("[color=#2f6e62]【百工兽魄 · " + tcfg.Title + "】[/color]");
	local mwSuffix = (("WX_ForgeGrade" in _item.m) && _item.m.WX_ForgeGrade >= 3)
		? " [color=#f0bc42]（神工共鸣：触发率/效能额外精进！）[/color]"
		: "";
	_ret.push({
		id = 968,
		type = "text",
		icon = tcfg.Icon,
		text = tagPrefix + tcfg.Text + mwSuffix
	});
	if ("Forge" in ::Wuxia && "injectForgeTooltip" in ::Wuxia.Forge)
		_ret = ::Wuxia.Forge.injectForgeTooltip(_item, _ret);
	return _ret;
};

if ("HooksMod" in ::Wuxia && ::Wuxia.HooksMod != null)
{
	// 1. Universal Passive Trait Injection & Tooltip Display across ALL Item Subtrees (`weapon`, `shield`, `armor`, `helmet`)
	foreach (clsPath in [
		"scripts/items/item",
		"scripts/items/weapons/weapon",
		"scripts/items/shields/shield",
		"scripts/items/armor/armor",
		"scripts/items/helmets/helmet"
	])
	{
		::Wuxia.HooksMod.hook(clsPath, function( q )
		{
			if ("onEquip" in q)
			{
				q.onEquip = @(__original) function()
				{
					__original();
					::Wuxia.BeastCraft.injectTraitSkill(this);
				};
			}

			if ("getTooltip" in q)
			{
				q.getTooltip = @(__original) function()
				{
					local ret = __original();
					return ::Wuxia.BeastCraft.injectTraitTooltip(this, ret);
				};
			}
		});
	}

	// 2. Zero-Friction Blueprint Auto-Discovery & Seamless 百草药柜 Ingredient Consumption in 百工丹坊!
	::Wuxia.HooksMod.hook("scripts/crafting/blueprint", function( q )
	{
		if ("isQualified" in q)
		{
			q.isQualified = @(__original) function()
			{
				if (__original()) return true;
				local bpID = (::Wuxia.hasMember(this.m, "ID") && this.m.ID != null) ? this.m.ID : "";
				if (bpID.find("blueprint.wx_") != 0 || this.m.PreviewCraftable == null) return false;
				local comps = ::Wuxia.BeastCraft.getBlueprintComponents(this);
				if (comps == null || comps.len() == 0) return false;
				if (!("World" in getroottable()) || ::World == null) return false;

				local statsFlags = ("Statistics" in ::World && ::World.Statistics != null) ? ::World.Statistics.getFlags() : null;
				local stash = ("Assets" in ::World && ::World.Assets != null) ? ::World.Assets.getStash() : null;

				foreach (ing in comps)
				{
					if (ing == null || !("Instance" in ing) || ing.Instance == null) continue;
					local itemID = ing.Instance.getID();
					if (statsFlags != null && statsFlags.get(itemID + "_identified"))
						return true;
					if (stash != null && stash.getItemByID(itemID) != null)
						return true;
				}
				return false;
			};
		}

		if ("isCraftable" in q)
		{
			q.isCraftable = @(__original) function()
			{
				if (__original()) return true;
				if (!this.isQualified()) return false;
				local comps = ::Wuxia.BeastCraft.getBlueprintComponents(this);
				if (comps == null || comps.len() == 0) return false;
				if (!("World" in getroottable()) || ::World == null || !("Assets" in ::World) || ::World.Assets == null) return false;
				local stash = ::World.Assets.getStash();
				if (stash == null) return false;
				local items = stash.getItems();
				foreach (c in comps)
				{
					if (c == null || !("Instance" in c) || c.Instance == null) return false;
					local cnt = ::Wuxia.BeastCraft.countIngredient(c, items);
					if (cnt.Total < c.Num) return false;
				}
				return true;
			};
		}

		if ("getIngredients" in q)
		{
			q.getIngredients = @(__original) function()
			{
				local ret = __original();
				local comps = ::Wuxia.BeastCraft.getBlueprintComponents(this);
				if (ret == null || typeof ret != "array" || comps == null) return ret;
				if (!("World" in getroottable()) || ::World == null || !("Assets" in ::World) || ::World.Assets == null) return ret;
				local stash = ::World.Assets.getStash();
				if (stash == null) return ret;
				local items = stash.getItems();
				local n = ::Math.min(ret.len(), comps.len());
				for (local i = 0; i < n; i = ++i)
				{
					local r = ret[i];
					local c = comps[i];
					if (r != null && typeof r == "table" && ("IsMissing" in r) && r.IsMissing && c != null)
					{
						local cnt = ::Wuxia.BeastCraft.countIngredient(c, items);
						if (cnt.Total >= c.Num) r.IsMissing = false;
					}
				}
				return ret;
			};
		}

		if ("craft" in q)
		{
			q.craft = @(__original) function()
			{
				local stash = (("World" in getroottable()) && ::World != null && ("Assets" in ::World) && ::World.Assets != null)
					? ::World.Assets.getStash()
					: null;
				local origLen = (stash != null && stash.getItems() != null) ? stash.getItems().len() : -1;
				local comps = ::Wuxia.BeastCraft.getBlueprintComponents(this);
				if (stash != null && comps != null)
				{
					local items = stash.getItems();
					foreach (c in comps)
					{
						if (c == null || !("Instance" in c) || c.Instance == null) continue;
						local cnt = ::Wuxia.BeastCraft.countIngredient(c, items);
						if (cnt.Stash < c.Num && cnt.Cabinet > 0 && cnt.Meta != null)
						{
							local take = ::Math.min(c.Num - cnt.Stash, cnt.Cabinet);
							for (local k = 0; k < take; k = ++k)
							{
								local tmp = ::Wuxia.Alchemy.instantiateByCabinetKey(cnt.Meta.Key, cnt.Meta.Script, cnt.Meta.SubID);
								if (tmp != null)
								{
									::Wuxia.Alchemy.Cabinet.addCount(cnt.Meta.Key, -1);
									items.push(tmp);
								}
							}
						}
					}
				}
				__original();
				if (stash != null && origLen >= 0)
				{
					local itemsAfter = stash.getItems();
					while (itemsAfter.len() > origLen && itemsAfter.top() == null)
						itemsAfter.pop();
				}
			};
		}
	});
}
