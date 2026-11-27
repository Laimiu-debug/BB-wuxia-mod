// Runtime System for Beast & Shan Hai Jing Forging:
//   - Applies Tier-A Beast Gear (`wx_beast_*`) & Armor Upgrades (`wx_up_*`) stats/visuals
//   - Injects `WX_GearTraitID` passive skill (`special.wx_gear_spirit_trait`) & tooltip row onto all Beast/Shan-Hai gear
//   - Drops forging materials (`wx_mat_*`) from wild Shan-Hai beasts & companion materials from all 64 Shan-Hai Bosses
//   - Unlocks Wuxia crafting blueprints in 百工丹坊 immediately as soon as ANY primary material/core is held or identified!

::Wuxia.BeastCraft <- {
	EntityTypeToKey      = null,
	QueryStashCounts     = null,
	SkipAutoStoreInQuery = false,
	LastDyingBossSnap    = null
};

::Wuxia.BeastCraft.buildStashCountMap <- function( _stashItems )
{
	local counts = {};
	if (_stashItems == null) return counts;
	foreach (it in _stashItems)
	{
		if (it == null) continue;
		local id = it.getID();
		counts[id] <- (id in counts) ? (counts[id] + 1) : 1;
	}
	return counts;
};

::Wuxia.BeastCraft.getCachedIngredientCabKey <- function( _ing )
{
	if (_ing == null) return "";
	if ("WX_CabKey" in _ing) return _ing.WX_CabKey;
	local key = "";
	if (("Instance" in _ing) && _ing.Instance != null
		&& ("Alchemy" in ::Wuxia) && ("classifyItem" in ::Wuxia.Alchemy))
	{
		local meta = ::Wuxia.Alchemy.classifyItem(_ing.Instance);
		if (meta != null && ("Key" in meta) && meta.Key != null)
			key = meta.Key;
	}
	_ing.WX_CabKey <- key;
	return key;
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
	if (body != null && ("m" in body))
	{
		if (("WX_GearTraitID" in body.m) && body.m.WX_GearTraitID != null)
		{
			if ("GearTraits" in ::Wuxia.Config && (body.m.WX_GearTraitID in ::Wuxia.Config.GearTraits))
			{
				local tcfg = ::Wuxia.Config.GearTraits[body.m.WX_GearTraitID];
				if (("ImmuneAcidAndFireAura" in tcfg) && tcfg.ImmuneAcidAndFireAura)
					return true;
			}
		}
		if (::Wuxia.hasMember(body, "getUpgrade") && body.getUpgrade() != null)
		{
			local upg = body.getUpgrade();
			if (("m" in upg) && ("WX_UpgCfgID" in upg.m) && upg.m.WX_UpgCfgID == "wx_up_xuanlin")
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
	if (sk != null && ((("ShanHai" in ::Wuxia) && ("findBossTrait" in ::Wuxia.ShanHai) && ::Wuxia.ShanHai.findBossTrait(sk) != null) || sk.hasSkill("special.wx_shanhai_boss_trait")))
		return; // Handled by dropBossCore!
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
	// 【百工猎妖录】4 件神通「百工庖丁」：亲手猎杀野外异兽额外 35% 独立概率再剥取 1 份百工奇材！
	if (spec.Pool.len() > 0 && ("ShanHaiSets" in ::Wuxia) && ::Wuxia.ShanHaiSets.hasActiveTier(_killer, "wx_set_baigong", 4))
	{
		if (::Math.rand(1, 100) <= 35)
		{
			local bonusMatID = spec.Pool[::Math.rand(0, spec.Pool.len() - 1)];
			local bonusItem = ::new("scripts/items/misc/" + bonusMatID);
			bonusItem.drop(_tile);
		}
	}
};

::Wuxia.BeastCraft.dropBossCompanionMaterials <- function( _bossKey, _tile, _bossActor = null, _fatalityType = 0 )
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

	// Monster-Hunter Part-Break Essence Loot (`破部位定向必掉奇材` via `::Wuxia.CraftBridge`)
	if ("CraftBridge" in ::Wuxia)
	{
		local spec = ::Wuxia.CraftBridge.resolveBossPartEssenceSpec(_bossKey);
		if (spec != null && ("EssenceID" in spec))
		{
			local partBroken = false;
			if (_bossActor != null)
			{
				partBroken = ::Wuxia.CraftBridge.detectBrokenBossParts(_bossActor, _fatalityType).Broken;
			}
			else if (::Wuxia.BeastCraft.LastDyingBossSnap != null && ::Wuxia.BeastCraft.LastDyingBossSnap.Broken)
			{
				partBroken = true;
			}
			local dropChance = partBroken ? 100 : 20;
			if (::Math.rand(1, 100) <= dropChance)
			{
				try
				{
					local pItem = ::new("scripts/items/misc/" + spec.EssenceID);
					if (pItem != null) pItem.drop(_tile);
				}
				catch (_pErr) {}
			}
		}
	}
	::Wuxia.BeastCraft.LastDyingBossSnap = null;
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
	if (::Wuxia.BeastCraft.QueryStashCounts != null)
	{
		local qsc = ::Wuxia.BeastCraft.QueryStashCounts;
		if (itemID in qsc) out.Stash = qsc[itemID];
	}
	else if (_stashItems != null)
	{
		foreach (it in _stashItems)
		{
			if (it != null && it.getID() == itemID)
				out.Stash += 1;
		}
	}
	if (("Alchemy" in ::Wuxia) && ("Cabinet" in ::Wuxia.Alchemy))
	{
		local cabKey = ::Wuxia.BeastCraft.getCachedIngredientCabKey(_ing);
		if (cabKey != "")
			out.Cabinet = ::Wuxia.Alchemy.Cabinet.getCount(cabKey);
	}
	out.Total = out.Stash + out.Cabinet;
	return out;
};

// Reserve distinct units and all output slots before the town charges for this batch.
::Wuxia.BeastCraft.prepareCraft <- function( _bp, _stash )
{
	local plan = { Reason = null, Consume = [], Keep = [], Cabinet = {}, Products = [] };
	local reserved = {}, cabinetReserved = {};
	local alchemist = ::World.Retinue.hasFollower("follower.alchemist");
	foreach (component in _bp.m.PreviewComponents)
	{
		local need = component.Num;
		foreach (it in _stash.getItems())
		{
			if (need == 0) break;
			if (it == null || it in reserved || it.getID() != component.Instance.getID()) continue;
			reserved[it] <- true;
			if (alchemist && it.getMagicNumber() <= 25) plan.Keep.push(it);
			else plan.Consume.push(it);
			--need;
		}

		if (need == 0) continue;
		local meta = ::Wuxia.Alchemy.classifyItem(component.Instance);
		local prior = meta != null && meta.Key in cabinetReserved ? cabinetReserved[meta.Key] : 0;
		if (meta == null || ::Wuxia.Alchemy.Cabinet.getCount(meta.Key) < prior + need)
			return { Reason = "制作材料不足，请重新选择丹方。" };
		cabinetReserved[meta.Key] <- prior + need;
		if (!(meta.Key in plan.Cabinet)) plan.Cabinet[meta.Key] <- 0;
		for (local i = 0; i < need; ++i)
			if (!alchemist || ::Math.rand(1, 100) > 25) ++plan.Cabinet[meta.Key];
	}

	// Recipes can yield several different items. Collect the actual batch before consuming anything.
	local products = plan.Products;
	_bp.onCraft({ add = function( item ) { products.push(item); return products.len() - 1; } });
	if (products.len() == 0) return { Reason = "此配方未产生物品。" };
	if (!_stash.isResizable() && products.len() > _stash.getNumberOfEmptySlots() + plan.Consume.len())
		return { Reason = "仓库空间不足，无法放下本炉全部成品。" };
	return plan;
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
						ret.push({ id = 69, type = "text", icon = "ui/icons/special.png", text = "[color=#094039]【百工镶缀】[/color]" + bTxt });
					}
				}
				if ("Forge" in ::Wuxia && "injectForgeTooltip" in ::Wuxia.Forge)
					ret = ::Wuxia.Forge.injectForgeTooltip(this, ret);
				if ("ShanHaiSets" in ::Wuxia && "injectSetTooltip" in ::Wuxia.ShanHaiSets)
					ret = ::Wuxia.ShanHaiSets.injectSetTooltip(this, ret);
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
						_result.push({ id = 69, type = "text", icon = "ui/icons/special.png", text = "[color=#094039]【" + gTag + ucfg.Name + "】[/color]" + bTxt2 });
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
				if ("ShanHaiSets" in ::Wuxia && "injectSetTooltip" in ::Wuxia.ShanHaiSets)
					ret = ::Wuxia.ShanHaiSets.injectSetTooltip(this, ret);
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
	if (_item == null || !("m" in _item))
		return;
	if ("Forge" in ::Wuxia && "syncExtendedMeta" in ::Wuxia.Forge)
		::Wuxia.Forge.syncExtendedMeta(_item);

	local tid = ("WX_GearTraitID" in _item.m && _item.m.WX_GearTraitID != null) ? _item.m.WX_GearTraitID : "";
	local hasTraitCfg = (tid != "" && "GearTraits" in ::Wuxia.Config && (tid in ::Wuxia.Config.GearTraits));
	local hasWMod = ("WX_WeaponModID" in _item.m && _item.m.WX_WeaponModID != null && _item.m.WX_WeaponModID != "");
	local hasQuench = ("WX_QuenchID" in _item.m && _item.m.WX_QuenchID != null && _item.m.WX_QuenchID != "" && _item.m.WX_QuenchID != "none");
	local hasBeastUpg = (::Wuxia.hasMember(_item, "getUpgrade") && _item.getUpgrade() != null && ("m" in _item.getUpgrade()) && ("WX_UpgCfgID" in _item.getUpgrade().m) && _item.getUpgrade().m.WX_UpgCfgID != null);

	if (!hasTraitCfg && !hasWMod && !hasQuench && !hasBeastUpg)
		return;

	if (::Wuxia.hasMember(_item.m, "SkillPtrs") && _item.m.SkillPtrs != null)
	{
		foreach (sk in _item.m.SkillPtrs)
		{
			if (sk != null && sk.getID() == "special.wx_gear_spirit_trait")
			{
				sk.setTraitID(hasTraitCfg ? tid : "");
				return;
			}
		}
	}
	local itemCont = (::Wuxia.hasMember(_item, "getContainer")) ? _item.getContainer() : null;
	if (itemCont == null || !::Wuxia.hasMember(itemCont, "getActor") || itemCont.getActor() == null)
		return;

	local traitSk = ::new("scripts/skills/special/wx_gear_spirit_trait");
	traitSk.setTraitID(hasTraitCfg ? tid : "");
	_item.addSkill(traitSk);
};

::Wuxia.BeastCraft.injectTraitTooltip <- function( _item, _ret )
{
	if (_ret == null || typeof _ret != "array" || _item == null || !("m" in _item))
		return _ret;
	if ("Forge" in ::Wuxia && "syncExtendedMeta" in ::Wuxia.Forge)
		::Wuxia.Forge.syncExtendedMeta(_item);

	local tid = ("WX_GearTraitID" in _item.m && _item.m.WX_GearTraitID != null) ? _item.m.WX_GearTraitID : "";
	if (tid != "" && "GearTraits" in ::Wuxia.Config && (tid in ::Wuxia.Config.GearTraits))
	{
		local already968 = false;
		foreach (row in _ret)
		{
			if (row != null && typeof row == "table" && ("id" in row) && row.id == 968)
			{
				already968 = true;
				break;
			}
		}
		if (!already968)
		{
			local tcfg = ::Wuxia.Config.GearTraits[tid];
			local tagPrefix = (tcfg.Tier == "relic")
				? ("[color=#721010]【名器器灵 · " + tcfg.Title + "】[/color]")
				: ((tcfg.Tier == "shanhai")
					? ("[color=#5e2c00]【山海神通 · " + tcfg.Title + "】[/color]")
					: ("[color=#094039]【百工兽魄 · " + tcfg.Title + "】[/color]"));
			local mwSuffix = (("WX_ForgeGrade" in _item.m) && _item.m.WX_ForgeGrade >= 3)
				? " [color=#6c1f04]（神工共鸣：触发率/效能额外精进！）[/color]"
				: "";
			_ret.push({
				id = 968,
				type = "text",
				icon = tcfg.Icon,
				text = tagPrefix + tcfg.Text + mwSuffix
			});
		}
	}

	if ("WX_WeaponModID" in _item.m && _item.m.WX_WeaponModID != null && _item.m.WX_WeaponModID != ""
		&& "WeaponAttachments" in ::Wuxia.Config && (_item.m.WX_WeaponModID in ::Wuxia.Config.WeaponAttachments))
	{
		local already967 = false;
		foreach (rMod in _ret)
		{
			if (rMod != null && typeof rMod == "table" && ("id" in rMod) && rMod.id == 967) { already967 = true; break; }
		}
		if (!already967)
		{
			local mcfg = ::Wuxia.Config.WeaponAttachments[_item.m.WX_WeaponModID];
			_ret.push({
				id = 967,
				type = "text",
				icon = "ui/icons/special.png",
				text = "[color=#0e3969]【兵刃铭配 · " + mcfg.Name + "】[/color]" + mcfg.BonusText
			});
		}
	}

	if ("Forge" in ::Wuxia && "injectForgeTooltip" in ::Wuxia.Forge)
		_ret = ::Wuxia.Forge.injectForgeTooltip(_item, _ret);
	if ("ShanHaiSets" in ::Wuxia && "injectSetTooltip" in ::Wuxia.ShanHaiSets)
		_ret = ::Wuxia.ShanHaiSets.injectSetTooltip(_item, _ret);
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
		"scripts/items/helmets/helmet",
		"scripts/items/accessory/accessory"
	])
	{
		::Wuxia.HooksMod.hook(clsPath, function( q )
		{
			if (::Wuxia.qHas(q, "onEquip"))
			{
				q.onEquip = @(__original) function()
				{
					__original();
					::Wuxia.BeastCraft.injectTraitSkill(this);
				};
			}

			if (::Wuxia.qHas(q, "getTooltip"))
			{
				q.getTooltip = @(__original) function()
				{
					local ret = __original();
					return ::Wuxia.BeastCraft.injectTraitTooltip(this, ret);
				};
			}

			if (clsPath == "scripts/items/shields/shield" && ::Wuxia.qHas(q, "applyShieldDamage"))
			{
				q.applyShieldDamage = @(__original) function( _damage, _playHitSound = true )
				{
					if (("WX_GearTraitID" in this.m) && this.m.WX_GearTraitID == "shanhai_shd_fangfeng" && _damage > 1)
						_damage = ::Math.max(1, ::Math.round(_damage * 0.70).tointeger());
					return __original(_damage, _playHitSound);
				};
			}
		});
	}

	::Wuxia.HooksMod.hook("scripts/crafting/blueprint", function( q )
	{
		q.isCraftable = @(__original) function()
		{
			if (this.getID().find("blueprint.wx_") == 0 && ::Wuxia.BeastCraft.QueryStashCounts != null)
			{
				local comps = this.m.PreviewComponents;
				if (comps == null || comps.len() == 0) return false;
				foreach (c in comps)
					if (::Wuxia.BeastCraft.countIngredient(c, null).Total < c.Num) return false;
				return true;
			}
			if (__original()) return true;
			if (this.getID().find("blueprint.wx_") != 0) return false;
			local items = ::World.Assets.getStash().getItems();
			foreach (c in this.m.PreviewComponents)
				if (::Wuxia.BeastCraft.countIngredient(c, items).Total < c.Num) return false;
			return this.m.PreviewComponents.len() != 0;
		};

		q.isQualified = @(__original) function()
		{
			if (this.getID().find("blueprint.wx_") == 0 && ::Wuxia.BeastCraft.QueryStashCounts != null)
			{
				if (this.m.TimesCrafted > 0) return true;
				local flags = ::World.Statistics.getFlags();
				foreach (c in this.m.PreviewComponents)
					if (flags.get(c.Instance.getID() + "_identified")
						|| ::Wuxia.BeastCraft.countIngredient(c, null).Total > 0) return true;
				return false;
			}
			if (__original()) return true;
			if (this.getID().find("blueprint.wx_") != 0) return false;
			local items = ::World.Assets.getStash().getItems();
			local flags = ::World.Statistics.getFlags();
			foreach (c in this.m.PreviewComponents)
				if (flags.get(c.Instance.getID() + "_identified")
					|| ::Wuxia.BeastCraft.countIngredient(c, items).Total > 0) return true;
			return false;
		};

		q.getIngredients = @(__original) function()
		{
			if (this.getID().find("blueprint.wx_") == 0 && ::Wuxia.BeastCraft.QueryStashCounts != null)
			{
				local fastRows = [];
				local comps = this.m.PreviewComponents;
				for (local i = 0; i < comps.len(); i = ++i)
				{
					local c = comps[i];
					local total = ::Wuxia.BeastCraft.countIngredient(c, null).Total;
					local img = c.Instance.getIcon();
					for (local k = 0; k < c.Num; k = ++k)
						fastRows.push({ InstanceID = i, ImagePath = img, IsMissing = (k + 1 > total) });
				}
				return fastRows;
			}
			local rows = __original();
			if (this.getID().find("blueprint.wx_") != 0) return rows;
			local items = ::World.Assets.getStash().getItems();
			local seen = {}, counts = {};
			foreach (row in rows)
			{
				local i = row.InstanceID;
				if (!(i in seen))
				{
					seen[i] <- 0;
					counts[i] <- ::Wuxia.BeastCraft.countIngredient(this.m.PreviewComponents[i], items).Total;
				}
				row.IsMissing = ++seen[i] > counts[i];
			}
			return rows;
		};

		q.craft = @(__original) function()
		{
			if (this.getID().find("blueprint.wx_") != 0) return __original();
			local stash = ::World.Assets.getStash();
			local plan = ("WX_CraftPlan" in this.m && this.m.WX_CraftPlan != null)
				? this.m.WX_CraftPlan : ::Wuxia.BeastCraft.prepareCraft(this, stash);
			if (plan.Reason != null) return;
			::Wuxia.Forge.rollTownProducts(plan.Products);
			foreach (it in plan.Consume) stash.remove(it);
			foreach (it in plan.Keep) it.setMagicNumber(::Math.rand(1, 100));
			foreach (key, n in plan.Cabinet) ::Wuxia.Alchemy.Cabinet.addCount(key, -n);
			foreach (product in plan.Products) stash.add(product);
			++this.m.TimesCrafted;
			this.updateAchievement("IMadeThis", 1, 1);
		};
	});
}
