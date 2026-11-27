// Runtime System for Shan Hai Jing Mythic Set Resonance (`7 大山海神系共鸣套 + 百工猎妖录 + 11 组同源本命真魂`)
// Zero save-game bytes: evaluates worn equipment slots dynamically, deduplicates 2H/paired weapons,
// injects live set progress into item/blueprint/upgrade tooltips, and wires Qinggong/Ranged Qi discount!

::Wuxia.ShanHaiSets <- {
	BeastEntityKeys = {
		Unhold = true, UnholdFrost = true, UnholdBog = true, Lindwurm = true,
		Serpent = true, Direwolf = true, Hyena = true, Ghoul = true,
		Spider = true, Alp = true, Hexe = true, Schrat = true,
		Kraken = true, TricksterGod = true, SandGolem = true
	}
};

::Wuxia.ShanHaiSets.resolveItemGearKey <- function( _item )
{
	if (_item == null || !("ShanHaiItemToSet" in ::Wuxia.Config))
		return null;

	local map = ::Wuxia.Config.ShanHaiItemToSet;
	if ("m" in _item && _item.m != null)
	{
		foreach (fld in ["WX_RelicID", "WX_ShanHaiGearID", "WX_BeastGearID", "WX_UpgCfgID", "GearID", "UpgID"])
		{
			if ((fld in _item.m) && _item.m[fld] != null && _item.m[fld] != "" && (_item.m[fld] in map))
				return _item.m[fld];
		}
	}

	if (::Wuxia.hasMember(_item, "getID"))
	{
		local rawID = _item.getID();
		if (rawID != null && rawID != "")
		{
			if (rawID in map) return rawID;
			foreach (pfx in ["weapon.", "armor.body.", "armor.head.", "shield.", "accessory.", "armor_upgrade."])
			{
				if (rawID.find(pfx) == 0)
				{
					local sub = rawID.slice(pfx.len());
					if (sub in map) return sub;
				}
			}
		}
	}
	return null;
};

::Wuxia.ShanHaiSets.evaluateActorSets <- function( _actor )
{
	local res = {
		SetCounts       = {},
		SetEquippedKeys = {},
		TotemCounts     = {},
		ActiveSets      = [],
		ActiveTotems    = []
	};
	if (_actor == null || !(::Wuxia.hasMember(_actor, "getItems")) || !("ShanHaiItemToSet" in ::Wuxia.Config))
		return res;

	local items = _actor.getItems();
	if (items == null) return res;

	local seenKeys = {};
	local addKey = function( _gKey )
	{
		if (_gKey == null || (_gKey in seenKeys)) return;
		seenKeys[_gKey] <- true;

		if (_gKey in ::Wuxia.Config.ShanHaiItemToSet)
		{
			local sid = ::Wuxia.Config.ShanHaiItemToSet[_gKey];
			if (!(sid in res.SetCounts))
			{
				res.SetCounts[sid] <- 0;
				res.SetEquippedKeys[sid] <- [];
			}
			res.SetCounts[sid] += 1;
			res.SetEquippedKeys[sid].push(_gKey);
		}
		if (("ShanHaiItemToTotem" in ::Wuxia.Config) && (_gKey in ::Wuxia.Config.ShanHaiItemToTotem))
		{
			local tid = ::Wuxia.Config.ShanHaiItemToTotem[_gKey];
			if (!(tid in res.TotemCounts)) res.TotemCounts[tid] <- 0;
			res.TotemCounts[tid] += 1;
		}
	};

	// Strictly inspect active worn slots ONLY (never Bag!), deduplicating 2H / paired-fist Mainhand+Offhand references!
	foreach (slotId in [
		::Const.ItemSlot.Mainhand,
		::Const.ItemSlot.Offhand,
		::Const.ItemSlot.Body,
		::Const.ItemSlot.Head,
		::Const.ItemSlot.Accessory
	])
	{
		local it = items.getItemAtSlot(slotId);
		if (it == null) continue;
		addKey(::Wuxia.ShanHaiSets.resolveItemGearKey(it));

		// Inlaid Beast Armor Upgrade on Body Armor also counts toward 百工猎妖录!
		if (slotId == ::Const.ItemSlot.Body && ("m" in it) && it.m != null && ::Wuxia.hasMember(it.m, "Upgrade") && it.m.Upgrade != null)
		{
			addKey(::Wuxia.ShanHaiSets.resolveItemGearKey(it.m.Upgrade));
		}
	}

	foreach (sid in ::Wuxia.Config.ShanHaiSetOrder)
	{
		if ((sid in res.SetCounts) && res.SetCounts[sid] >= 2)
		{
			res.ActiveSets.push({
				SetID = sid,
				Count = res.SetCounts[sid]
			});
		}
	}

	foreach (tid in ::Wuxia.Config.ShanHaiTotemOrder)
	{
		if ((tid in res.TotemCounts) && res.TotemCounts[tid] >= 2)
			res.ActiveTotems.push(tid);
	}

	return res;
};

::Wuxia.ShanHaiSets.ensureActorResonanceSkill <- function( _actor )
{
	if (_actor == null || !(::Wuxia.hasMember(_actor, "getSkills")))
		return null;
	local skills = _actor.getSkills();
	if (skills == null) return null;
	local sk = skills.getSkillByID("special.wx_shanhai_set_resonance");
	if (sk == null)
	{
		sk = ::new("scripts/skills/special/wx_shanhai_set_resonance");
		skills.add(sk);
	}
	return sk;
};

::Wuxia.ShanHaiSets.hasActiveTier <- function( _actor, _setID, _need )
{
	if (_actor == null) return false;
	local ev = ::Wuxia.ShanHaiSets.evaluateActorSets(_actor);
	return (_setID in ev.SetCounts) && ev.SetCounts[_setID] >= _need;
};

::Wuxia.ShanHaiSets.isBeastOrShanHaiTarget <- function( _target )
{
	if (_target == null) return false;
	local tsk = (::Wuxia.hasMember(_target, "getSkills")) ? _target.getSkills() : null;
	if (tsk != null && ((("ShanHai" in ::Wuxia) && ("findBossTrait" in ::Wuxia.ShanHai) && ::Wuxia.ShanHai.findBossTrait(tsk) != null) || tsk.hasSkill("special.wx_shanhai_boss_trait")))
		return true;
	if (::Wuxia.hasMember(_target, "getType") && ("BeastCraft" in ::Wuxia) && ("getEntityKey" in ::Wuxia.BeastCraft))
	{
		local eKey = ::Wuxia.BeastCraft.getEntityKey(_target.getType());
		if (eKey != null && (eKey in ::Wuxia.ShanHaiSets.BeastEntityKeys))
			return true;
	}
	return false;
};

::Wuxia.ShanHaiSets.resolveItemOwnerActor <- function( _item )
{
	if (_item == null) return null;
	if (::Wuxia.hasMember(_item, "getContainer"))
	{
		local cont = _item.getContainer();
		if (cont != null && ::Wuxia.hasMember(cont, "getActor"))
			return cont.getActor();
	}
	if ("m" in _item && _item.m != null && ::Wuxia.hasMember(_item.m, "Armor") && _item.m.Armor != null)
	{
		local arm = _item.m.Armor;
		if (::Wuxia.hasMember(arm, "getContainer") && arm.getContainer() != null && ::Wuxia.hasMember(arm.getContainer(), "getActor"))
			return arm.getContainer().getActor();
	}
	return null;
};

::Wuxia.ShanHaiSets.injectSetTooltip <- function( _item, _ret, _ownerOverride = null )
{
	if (_ret == null || typeof _ret != "array" || _item == null)
		return _ret;
	foreach (row in _ret)
	{
		if (row != null && typeof row == "table" && ("id" in row) && row.id == 975)
			return _ret;
	}

	local gKey = ::Wuxia.ShanHaiSets.resolveItemGearKey(_item);
	if (gKey == null || !(gKey in ::Wuxia.Config.ShanHaiItemToSet))
		return _ret;

	local sid = ::Wuxia.Config.ShanHaiItemToSet[gKey];
	local scfg = ::Wuxia.Config.ShanHaiSets[sid];
	local owner = _ownerOverride != null ? _ownerOverride : ::Wuxia.ShanHaiSets.resolveItemOwnerActor(_item);
	local ev = owner != null ? ::Wuxia.ShanHaiSets.evaluateActorSets(owner) : null;
	local curCount = (ev != null && (sid in ev.SetCounts)) ? ev.SetCounts[sid] : 0;
	local maxNeed = scfg.Bonuses[scfg.Bonuses.len() - 1].Need;

	local tagKind = (scfg.Tier == "shanhai") ? "山海共鸣" : "猎妖套装";
	local countSuffix = (owner != null)
		? ("（已穿戴 " + curCount + "/" + maxNeed + " 件）")
		: ("（共鸣池 " + scfg.Pieces.len() + " 件可选）");

	local setCol = ("TooltipColor" in scfg) ? scfg.TooltipColor : scfg.Color;
	_ret.push({
		id = 975,
		type = "text",
		icon = scfg.Icon,
		text = "[color=" + setCol + "]【" + tagKind + " · " + scfg.Name + countSuffix + "】[/color]" + scfg.StyleTag
	});

	local subId = 976;
	foreach (b in scfg.Bonuses)
	{
		local active = (owner != null && curCount >= b.Need);
		local prefix = active
			? ("[color=#0a4213]◆ [" + b.Need + "件·" + b.Title + "（已激活）]：[/color]")
			: ("[color=#43392c]◇ [" + b.Need + "件·" + b.Title + "]：[/color][color=#43392c]");
		local suffix = active ? "" : "[/color]";
		_ret.push({
			id = subId++,
			type = "text",
			icon = "ui/icons/special.png",
			text = prefix + b.Text + suffix
		});
	}

	if (("ShanHaiItemToTotem" in ::Wuxia.Config) && (gKey in ::Wuxia.Config.ShanHaiItemToTotem))
	{
		local tid = ::Wuxia.Config.ShanHaiItemToTotem[gKey];
		local tcfg = ::Wuxia.Config.ShanHaiTotemPairs[tid];
		local tCount = (ev != null && (tid in ev.TotemCounts)) ? ev.TotemCounts[tid] : 0;
		local tActive = (owner != null && tCount >= tcfg.Need);
		local tText = tActive
			? ("[color=#5e2c00]★ [" + tcfg.Title + "（已觉醒）]：[/color]" + tcfg.Text)
			: ("[color=#43392c]☆ [" + tcfg.Title + "（同源2件彩蛋）]：" + tcfg.Text + "[/color]");
		_ret.push({
			id = 979,
			type = "text",
			icon = "ui/icons/bravery.png",
			text = tText
		});
	}

	return _ret;
};

if ("HooksMod" in ::Wuxia && ::Wuxia.HooksMod != null)
{
	// 1. Auto-attach zero-save resonance skill whenever any item is equipped, and inject Set Tooltip across all item trees!
	foreach (clsPath in [
		"scripts/items/item",
		"scripts/items/weapons/weapon",
		"scripts/items/shields/shield",
		"scripts/items/armor/armor",
		"scripts/items/helmets/helmet",
		"scripts/items/accessory/accessory",
		"scripts/items/armor_upgrades/armor_upgrade"
	])
	{
		::Wuxia.HooksMod.hook(clsPath, function( q )
		{
			if (::Wuxia.qHas(q, "onEquip"))
			{
				q.onEquip = @(__original) function()
				{
					__original();
					local owner = ::Wuxia.ShanHaiSets.resolveItemOwnerActor(this);
					if (owner != null)
						::Wuxia.ShanHaiSets.ensureActorResonanceSkill(owner);
				};
			}

			if (::Wuxia.qHas(q, "getTooltip"))
			{
				q.getTooltip = @(__original) function()
				{
					local ret = __original();
					return ::Wuxia.ShanHaiSets.injectSetTooltip(this, ret);
				};
			}
		});
	}

	// 2. Also surface 百工猎妖录 set progress on Body Armors carrying an inlaid Beast Armor Upgrade (`wx_up_*`)!
	::Wuxia.HooksMod.hook("scripts/items/armor/armor", function( q )
	{
		if (::Wuxia.qHas(q, "setUpgrade"))
		{
			q.setUpgrade = @(__original) function( _upgrade )
			{
				__original(_upgrade);
				local owner = ::Wuxia.ShanHaiSets.resolveItemOwnerActor(this);
				if (owner != null)
				{
					::Wuxia.ShanHaiSets.ensureActorResonanceSkill(owner);
					if (::Wuxia.hasMember(owner, "getSkills") && owner.getSkills() != null)
						owner.getSkills().update();
				}
			};
		}

		if (::Wuxia.qHas(q, "getTooltip"))
		{
			q.getTooltip = @(__original) function()
			{
				local ret = __original();
				// If the body armor itself isn't a set piece, but has an inlaid Beast Upgrade (`wx_up_*`), display 百工猎妖录 progress!
				if (::Wuxia.ShanHaiSets.resolveItemGearKey(this) == null
					&& ::Wuxia.hasMember(this.m, "Upgrade") && this.m.Upgrade != null
					&& ::Wuxia.ShanHaiSets.resolveItemGearKey(this.m.Upgrade) != null)
				{
					local owner = ::Wuxia.ShanHaiSets.resolveItemOwnerActor(this);
					ret = ::Wuxia.ShanHaiSets.injectSetTooltip(this.m.Upgrade, ret, owner);
				}
				return ret;
			};
		}
	});

	// 3. 青丘风翎套 2 件【扶摇借风】：远程招式与轻功身法招式内息消耗 -20%！
	::Wuxia.HooksMod.hook("scripts/skills/skill", function( q )
	{
		if (::Wuxia.qHas(q, "getFatigueCost"))
		{
			q.getFatigueCost = @(__original) function()
			{
				local cost = __original();
				if (cost <= 1 || !this.isActive()) return cost;
				local sid = this.getID();
				local isQinggongMove = (sid.find("actives.wx_qinggong_") == 0
					|| sid == "actives.footwork"
					|| sid == "actives.wx_light_leap"
					|| sid == "actives.wx_shadow_swap");
				if (!this.isRanged() && !isQinggongMove) return cost;

				local cont = this.getContainer();
				local actor = cont == null ? null : cont.getActor();
				if (actor != null && ::Wuxia.ShanHaiSets.hasActiveTier(actor, "wx_set_qingqiu", 2))
				{
					cost = ::Math.max(1, ::Math.floor(cost * 0.80));
				}
				return cost;
			};
		}
	});
}
