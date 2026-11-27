// Base class for the 10 Wuxia Congenital Meridian & Martial Aptitude Traits (`trait.wx_*`)
this.wx_meridian_trait_base <- this.inherit("scripts/skills/traits/character_trait", {
	m = {
		WX_TraitKey   = "",
		WX_HitQiCount = 0
	},

	function initByTraitKey( _key )
	{
		this.character_trait.create();
		this.m.WX_TraitKey = _key;
		local def = ("Traits" in ::Wuxia.Config && (_key in ::Wuxia.Config.Traits.MeridianTraits))
			? ::Wuxia.Config.Traits.MeridianTraits[_key] : null;
		if (def != null)
		{
			this.m.ID          = def.ID;
			this.m.Name        = def.Name;
			this.m.Icon        = def.Icon;
			this.m.Description = def.Description;
			this.m.Titles      = clone def.Titles;
			this.m.Excluded    = ("Excluded" in def) ? clone def.Excluded : [];
		}
		this.m.Order = this.Const.SkillOrder.Trait;
	}

	function getTooltip()
	{
		local ret = [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description", text = this.getDescription() }
		];
		local def = ::Wuxia.Traits.getMeridianDef(this.m.WX_TraitKey);
		if (def != null && ("Bullets" in def))
		{
			local rid = 10;
			foreach (b in def.Bullets)
			{
				ret.push({ id = rid, type = "text", icon = "ui/icons/special.png", text = b });
				rid += 1;
			}
		}
		return ret;
	}

	function onTurnStart()
	{
		this.m.WX_HitQiCount = 0;
		local def = ::Wuxia.Traits.getMeridianDef(this.m.WX_TraitKey);
		if (def != null && ("CleansePct" in def) && def.CleansePct > 0 && ::Math.rand(1, 100) <= def.CleansePct)
		{
			local sk = this.getContainer();
			if (sk != null)
			{
				foreach (pid in ["effects.wx_status_poison_dart", "effects.spider_poison", "effects.goblin_poison"])
				{
					if (sk.hasSkill(pid)) { sk.removeByID(pid); break; }
				}
			}
		}
	}

	function onUpdate( _properties )
	{
		local def = ::Wuxia.Traits.getMeridianDef(this.m.WX_TraitKey);
		if (def == null) return;
		if ("Stats" in def)
		{
			foreach (k, v in def.Stats)
			{
				if (k in _properties) _properties[k] += v;
			}
		}
		if (("InjuryMult" in def) && def.InjuryMult > 1.0)
			_properties.ThresholdToReceiveInjuryMult *= def.InjuryMult;

		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		local items = (actor != null && ::Wuxia.hasMember(actor, "getItems")) ? actor.getItems() : null;
		local mainW = items != null ? items.getItemAtSlot(::Const.ItemSlot.Mainhand) : null;
		if (mainW != null && ("WeaponFams" in def) && ("WpnArmorDmg" in def) && ::Wuxia.CombatRules.matchesWeapon(mainW, def.WeaponFams))
		{
			_properties.DamageArmorMult += def.WpnArmorDmg;
		}
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		local def = ::Wuxia.Traits.getMeridianDef(this.m.WX_TraitKey);
		if (def == null || _skill == null || !_skill.isAttack()) return;
		if (("LongAcc" in def) && def.LongAcc > 0 && _skill.isRanged() && _targetEntity != null)
		{
			local cont = this.getContainer();
			local actor = cont != null ? cont.getActor() : null;
			if (actor != null && ::Wuxia.isOnMap(actor) && ::Wuxia.isOnMap(_targetEntity))
			{
				if (actor.getTile().getDistanceTo(_targetEntity.getTile()) >= 4)
					_properties.RangedSkill += def.LongAcc;
			}
		}
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		local def = ::Wuxia.Traits.getMeridianDef(this.m.WX_TraitKey);
		if (def == null || _skill == null || !_skill.isAttack() || _skill.isRanged()) return;
		if (("HitQiBonus" in def) && def.HitQiBonus > 0 && this.m.WX_HitQiCount < 2)
		{
			local cont = this.getContainer();
			local actor = cont != null ? cont.getActor() : null;
			if (actor != null && _targetEntity != null && !actor.isAlliedWith(_targetEntity))
			{
				this.m.WX_HitQiCount += 1;
				::Wuxia.CombatRules.restoreQi(actor, def.HitQiBonus);
			}
		}
	}
});
