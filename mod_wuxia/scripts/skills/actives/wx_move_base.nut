// Base class for weapon-bound Wuxia active moves

this.wx_move_base <- this.inherit("scripts/skills/skill", {
	m = {
		RequiredWeaponTypes = [],
		InflictStatusID     = null,
		InflictStatusScript = null,
		InflictChancePct    = 100
	},

	function create()
	{
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.OffensiveTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsStacking = false;
		this.m.IsAttack = true;
		this.m.IsWeaponSkill = true;
		this.m.InjuriesOnBody = this.Const.Injury.CuttingBody;
		this.m.InjuriesOnHead = this.Const.Injury.CuttingHead;
		this.m.DirectDamageMult = 0.25;
	}

	function wxHasRequiredWeapon()
	{
		local container = this.getContainer();
		local actor = container == null ? null : container.getActor();
		local items = actor == null ? null : actor.getItems();
		local weapon = items == null ? null : items.getItemAtSlot(::Const.ItemSlot.Mainhand);
		return ::Wuxia.CombatRules.matchesWeapon(weapon, this.m.RequiredWeaponTypes);
	}

	function isHidden()
	{
		return this.skill.isHidden() || !this.wxHasRequiredWeapon();
	}

	function isUsable()
	{
		if (!this.skill.isUsable() || !this.wxHasRequiredWeapon()) return false;
		if (this.m.RequiredWeaponTypes.find("Throwing") != null)
		{
			local item = this.getContainer().getActor().getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
			return item.getAmmoMax() == 0 || item.getAmmo() > 0;
		}
		return true;
	}

	function wxThrowAt( _user, _target )
	{
		local item = _user.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
		local hit = this.attackEntity(_user, _target);
		if (item.getAmmoMax() > 0) item.consumeAmmo();
		return hit;
	}

	function getFatigueCost()
	{
		local cost = this.skill.getFatigueCost();
		local actor = this.getContainer().getActor();
		local c = ::Wuxia.Slots.getContainer(actor);
		if (c != null && c.m.CachedAggFlags != null && c.m.CachedAggFlags.WeaponQiDiscount > 0.0)
		{
			cost = ::Math.max(1, ::Math.floor(cost * (1.0 - c.m.CachedAggFlags.WeaponQiDiscount)));
		}
		return cost;
	}

	function wxApplyStatusToTarget( _target, _effectID, _effectScript, _chanceFlag = null )
	{
		if (_target == null || !_target.isAlive() || _effectID == null || _effectScript == null)
			return;
		if ((_effectID == "effects.wx_status_acupoint" || _effectID == "effects.wx_status_poison_dart") && ::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_target))
			return;
		if (_chanceFlag != null)
		{
			local c = this.getContainer().getSkillByID("special.wx_martial_container");
			local chance = c == null || c.m.CachedAggFlags == null ? null : c.m.CachedAggFlags[_chanceFlag];
			if (chance != null && ::Math.rand(1, 100) > chance) return;
		}
		local sk = _target.getSkills();
		if (sk == null) return;
		local eff = sk.getSkillByID(_effectID);
		if (eff == null)
		{
			eff = ::new(_effectScript);
			sk.add(eff);
		}
		else if ("resetDuration" in eff)
		{
			eff.resetDuration();
		}
	}

	function getTooltip()
	{
		local ret = this.getDefaultTooltip();
		if (this.m.RequiredWeaponTypes.len() > 0)
		{
			local joined = "";
			for (local i = 0; i < this.m.RequiredWeaponTypes.len(); i = ++i)
			{
				if (i > 0) joined += " / ";
				joined += this.m.RequiredWeaponTypes[i];
			}
			ret.push({
				id = 15,
				type = "text",
				icon = "ui/icons/regular_damage.png",
				text = "兵器要求：" + joined
			});
		}
		return ret;
	}
});
