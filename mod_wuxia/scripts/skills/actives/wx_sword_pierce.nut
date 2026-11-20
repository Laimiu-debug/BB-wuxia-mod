// Sect/Secret Sword Move: 穿云透甲刺 (4 AP, 16 Qi: +8 hit, +20% armor pen, +10% headshot)

this.wx_sword_pierce <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_pierce";
		this.m.Name = "穿云透甲刺";
		this.m.Description = "凝内劲于剑尖直取甲胄缝隙：命中 +8，穿甲伤害率提高 20%，击中头部几率额外 +10%。";
		this.m.KilledString = "一剑洞穿咽喉";
		this.m.Icon = "skills/active_02.png";
		this.m.IconDisabled = "skills/active_02_sw.png";
		this.m.Overlay = "active_02";
		this.m.SoundOnUse = [
			"sounds/combat/thrust_01.wav",
			"sounds/combat/thrust_02.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/thrust_hit_01.wav"
		];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.InjuriesOnBody = this.Const.Injury.PiercingBody;
		this.m.InjuriesOnHead = this.Const.Injury.PiercingHead;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.30;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8;
			_properties.DamageDirectAdd += 0.20;
			_properties.HitChance[this.Const.BodyPart.Head] += 10;
		}
	}

	function onUse( _user, _targetTile )
	{
		return this.attackEntity(_user, _targetTile.getEntity());
	}
});
