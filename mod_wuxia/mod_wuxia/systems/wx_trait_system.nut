// Wuxia Trait System:
// 1. Non-destructively remaps 58 vanilla `character_trait` names & descriptions into Wuxia Jianghu terminology
//    while preserving 100% of vanilla `trait.*` IDs and all 300+ vanilla/Wuxia event checks!
// 2. Drives the 10 authentic Wuxia Congenital Meridian & Aptitude Traits (`trait.wx_*`).

::Wuxia.Traits <- {
	TraitOrder = [
		"wx_qijing", "wx_wuxing", "wx_jiangu", "wx_daochi", "wx_quanyi",
		"wx_baidu", "wx_qingling", "wx_tonggu", "wx_shenmu", "wx_zaolie"
	]
};

::Wuxia.Traits.getMeridianDef <- function( _key )
{
	if (_key != null && ("Traits" in ::Wuxia.Config) && (_key in ::Wuxia.Config.Traits.MeridianTraits))
		return ::Wuxia.Config.Traits.MeridianTraits[_key];
	return null;
};

::Wuxia.Traits.getActorMeridianDefs <- function( _actor )
{
	local out = [];
	if (_actor == null || !::Wuxia.hasMember(_actor, "getSkills") || _actor.getSkills() == null)
		return out;
	local sk = _actor.getSkills();
	foreach (key in ::Wuxia.Traits.TraitOrder)
	{
		local def = ::Wuxia.Traits.getMeridianDef(key);
		if (def != null && sk.hasSkill(def.ID))
			out.push(def);
	}
	return out;
};

::Wuxia.Traits.getWashPrepBonus <- function( _actor )
{
	local bonus = 0;
	foreach (def in ::Wuxia.Traits.getActorMeridianDefs(_actor))
	{
		if ("WashBonus" in def) bonus += def.WashBonus;
	}
	return bonus;
};

::Wuxia.Traits.hasBaiduToxinImmunity <- function( _actor )
{
	foreach (def in ::Wuxia.Traits.getActorMeridianDefs(_actor))
	{
		if (("NoDanToxin" in def) && def.NoDanToxin) return true;
	}
	return false;
};

::Wuxia.Traits.getExtraConflictRisk <- function( _actor )
{
	local extra = 0;
	foreach (def in ::Wuxia.Traits.getActorMeridianDefs(_actor))
	{
		if ("ConflictAdd" in def) extra += def.ConflictAdd;
	}
	return extra;
};

::Wuxia.Traits.hasAntiInternalInjury <- function( _actor )
{
	foreach (def in ::Wuxia.Traits.getActorMeridianDefs(_actor))
	{
		if (("AntiIntInj" in def) && def.AntiIntInj) return true;
	}
	return false;
};

// Returns additive mastery XP multiplier bonus (e.g. 0.20..0.30) from a brother's congenital traits for `_manualDef`
::Wuxia.Traits.getMasteryBonusMult <- function( _actor, _manualDef )
{
	if (_actor == null || _manualDef == null) return 0.0;
	local best = 0.0;
	foreach (def in ::Wuxia.Traits.getActorMeridianDefs(_actor))
	{
		local cur = 0.0;
		if ("AllMastery" in def)
			cur = def.AllMastery;
		if (("MasteryCat" in def) && def.MasteryCat == _manualDef.Category && ("MasteryMult" in def))
			cur = ::Math.maxf(cur, def.MasteryMult);
		if (("WeaponFams" in def) && _manualDef.Category == "waigong" && ("WeaponTypes" in _manualDef) && ("MasteryMult" in def))
		{
			foreach (wf in def.WeaponFams)
			{
				if (_manualDef.WeaponTypes.find(wf) != null)
				{
					cur = ::Math.maxf(cur, def.MasteryMult);
					break;
				}
			}
		}
		if (cur > best) best = cur;
	}
	return best;
};

::Wuxia.Traits.getSlotExpBonusPct <- function( _actor, _manualDef )
{
	if (_actor == null || _manualDef == null) return 0;
	local total = 0.0;
	foreach (def in ::Wuxia.Traits.getActorMeridianDefs(_actor))
	{
		if ("AllMastery" in def)
			total += def.AllMastery;
		local matchedSpec = false;
		if (("MasteryCat" in def) && def.MasteryCat == _manualDef.Category && ("MasteryMult" in def))
		{
			total += def.MasteryMult;
			matchedSpec = true;
		}
		if (!matchedSpec && ("WeaponFams" in def) && _manualDef.Category == "waigong" && ("WeaponTypes" in _manualDef) && ("MasteryMult" in def))
		{
			foreach (wf in def.WeaponFams)
			{
				if (_manualDef.WeaponTypes.find(wf) != null)
				{
					total += def.MasteryMult;
					break;
				}
			}
		}
	}
	return ::Math.round(total * 100);
};

::Wuxia.Traits.getMoveQiSaveMult <- function( _actor, _skill )
{
	if (_skill == null || !::Wuxia.hasMember(_actor, "getItems") || _actor.getItems() == null) return 0.0;
	local weapon = _actor.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
	local skills = _actor.getSkills();
	if (weapon == null || skills == null) return 0.0;
	local bestSave = 0.0;
	foreach (_, def in ::Wuxia.Config.Traits.MeridianTraits)
	{
		if (("WpnQiSave" in def) && skills.hasSkill(def.ID) && ::Wuxia.CombatRules.matchesWeapon(weapon, def.WeaponFams))
			bestSave = ::Math.maxf(bestSave, def.WpnQiSave);
	}
	return bestSave;
};

// Roll a congenital Wuxia meridian trait on fresh character recruitment (~28% chance, biased toward held weapon / background)
::Wuxia.Traits.tryAssignCongenitalTrait <- function( _actor, _chancePct = 28 )
{
	if (_actor == null || !::Wuxia.hasMember(_actor, "getSkills") || _actor.getSkills() == null)
		return null;
	if (::Wuxia.Traits.getActorMeridianDefs(_actor).len() > 0)
		return null;
	if (::Math.rand(1, 100) > _chancePct)
		return null;

	local sk = _actor.getSkills();
	local items = ::Wuxia.hasMember(_actor, "getItems") ? _actor.getItems() : null;
	local mainW = items != null ? items.getItemAtSlot(::Const.ItemSlot.Mainhand) : null;

	local candidates = [];
	foreach (key in ::Wuxia.Traits.TraitOrder)
	{
		local def = ::Wuxia.Traits.getMeridianDef(key);
		if (def == null) continue;
		local blocked = false;
		if ("Excluded" in def)
		{
			foreach (exId in def.Excluded)
			{
				if (sk.hasSkill(exId)) { blocked = true; break; }
			}
		}
		if (blocked) continue;

		local weight = 10;
		if (mainW != null && ("WeaponFams" in def) && ::Wuxia.CombatRules.matchesWeapon(mainW, def.WeaponFams))
			weight = 28;
		for (local w = 0; w < weight; w = ++w)
			candidates.push(key);
	}
	if (candidates.len() == 0) return null;

	local pickedKey = candidates[::Math.rand(0, candidates.len() - 1)];
	local pickedDef = ::Wuxia.Traits.getMeridianDef(pickedKey);
	local tr = ::new(pickedDef.Script);
	sk.add(tr);
	sk.update();
	return pickedDef.ID;
};

// Non-destructive hook on `scripts/skills/traits/character_trait` to localize all 58 vanilla traits cleanly
if ("HooksMod" in ::Wuxia && ::Wuxia.HooksMod != null)
{
	::Wuxia.HooksMod.hook("scripts/skills/traits/character_trait", function( q )
	{
		q.WX_ApplyVanillaTraitText <- function()
		{
			local id = (::Wuxia.hasMember(this.m, "ID") && this.m.ID != null) ? this.m.ID : "";
			if (id == "" || id.find("trait.wx_") == 0) return;
			if ("Traits" in ::Wuxia.Config && (id in ::Wuxia.Config.Traits.VanillaTraitMap))
			{
				local entry = ::Wuxia.Config.Traits.VanillaTraitMap[id];
				this.m.Name = entry[0];
				this.m.Description = entry[1];
			}
		};

		if (::Wuxia.qHas(q, "onAdded"))
		{
			q.onAdded = @(__original) function()
			{
				this.WX_ApplyVanillaTraitText();
				__original();
				this.WX_ApplyVanillaTraitText();
			};
		}

		if (::Wuxia.qHas(q, "getName"))
		{
			q.getName = @(__original) function()
			{
				this.WX_ApplyVanillaTraitText();
				return __original();
			};
		}

		if (::Wuxia.qHas(q, "getDescription"))
		{
			q.getDescription = @(__original) function()
			{
				this.WX_ApplyVanillaTraitText();
				return ::Wuxia.Purify.rewriteCurrencyAndSupplyTerms(__original());
			};
		}

		if (::Wuxia.qHas(q, "getTooltip"))
		{
			q.getTooltip = @(__original) function()
			{
				this.WX_ApplyVanillaTraitText();
				local ret = __original();
				if (ret != null && typeof ret == "array")
				{
					for (local i = 0; i < ret.len(); i = ++i)
					{
						local row = ret[i];
						if (row != null && typeof row == "table" && ("text" in row) && typeof row.text == "string")
							row.text = ::Wuxia.Purify.rewriteCurrencyAndSupplyTerms(row.text);
					}
				}
				return ret;
			};
		}
	});
}
