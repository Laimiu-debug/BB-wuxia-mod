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
		if (this.m.RequiredWeaponTypes.len() == 0) return true;
		local actor = this.getContainer().getActor();
		if (actor == null) return false;
		local weapon = actor.getMainhandItem();
		if (weapon == null) return false;

		foreach (wtName in this.m.RequiredWeaponTypes)
		{
			if ("WeaponType" in ::Const.Items && wtName in ::Const.Items.WeaponType)
			{
				if ("isWeaponType" in weapon && weapon.isWeaponType(::Const.Items.WeaponType[wtName]))
					return true;
			}
		}
		return false;
	}

	function isHidden()
	{
		return this.skill.isHidden() || !this.wxHasRequiredWeapon();
	}

	function isUsable()
	{
		return this.skill.isUsable() && this.wxHasRequiredWeapon();
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

	function wxApplyStatusToTarget( _target, _effectID, _effectScript )
	{
		if (_target == null || !_target.isAlive() || _effectID == null || _effectScript == null)
			return;
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
