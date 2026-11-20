// Sect Axe Move: 力劈华山 (5 AP, 20 Qi: shatters enemy shield durability if shielded; otherwise +20% total damage + opening)

this.wx_axe_split <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {
		TargetHadShield = false
	},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_axe_split";
		this.m.Name = "力劈华山";
		this.m.Description = "辽东劈山盟刚猛斧招：若目标持盾则震裂其盾牌 24 点耐久并破开「破绽」；若目标未持盾则总伤害提高 20% 并留「破绽」。";
		this.m.KilledString = "当头劈作两段";
		this.m.Icon = "skills/active_24.png";
		this.m.IconDisabled = "skills/active_24_sw.png";
		this.m.Overlay = "active_24";
		this.m.SoundOnUse = [
			"sounds/combat/axe_01.wav",
			"sounds/combat/axe_02.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/axe_hit_01.wav",
			"sounds/combat/axe_hit_02.wav"
		];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Axe"];
		this.m.DirectDamageMult = 0.30;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this && _targetEntity != null && "isArmedWithShield" in _targetEntity && !_targetEntity.isArmedWithShield())
		{
			_properties.DamageTotalMult *= 1.20;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		if (target != null && "isArmedWithShield" in target && target.isArmedWithShield())
		{
			local shield = target.getItems().getItemAtSlot(this.Const.ItemSlot.Offhand);
			if (shield != null)
			{
				shield.applyShieldDamage(24);
			}
		}
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
		}
		return hit;
	}
});
