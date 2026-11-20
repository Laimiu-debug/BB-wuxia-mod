// Sect Dagger Move: 分水断脉刺 (4 AP, 14 Qi: +10 hit, +10% pen, inflicts bleed & drains 12 Qi)

this.wx_dagger_vital <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_dagger_vital";
		this.m.Name = "分水断脉刺";
		this.m.Description = "贴身短刃疾挑敌手腕脉气门：命中 +10、穿甲 +10%，击中生人附加割裂流血并震散其 12 点内息。";
		this.m.KilledString = "短刺挑断大筋";
		this.m.Icon = "skills/active_202.png";
		this.m.IconDisabled = "skills/active_202_sw.png";
		this.m.Overlay = "active_202";
		this.m.SoundOnUse = [
			"sounds/combat/dagger_01.wav",
			"sounds/combat/dagger_02.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/dagger_hit_01.wav",
			"sounds/combat/dagger_hit_02.wav"
		];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 14;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.InjuriesOnBody = this.Const.Injury.PiercingBody;
		this.m.InjuriesOnHead = this.Const.Injury.PiercingHead;
		this.m.RequiredWeaponTypes = ["Dagger"];
		this.m.DirectDamageMult = 0.30;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 10;
			_properties.DamageDirectAdd += 0.10;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive() && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(target))
		{
			local bleed = ::new("scripts/skills/effects/bleeding_effect");
			bleed.setDamage(5);
			target.getSkills().add(bleed);
			target.setFatigue(::Math.min(target.getFatigueMax(), target.getFatigue() + 12));
		}
		return hit;
	}
});
