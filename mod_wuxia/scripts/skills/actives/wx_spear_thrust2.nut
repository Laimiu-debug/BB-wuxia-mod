// Sect/Secret Spear Move: 百鸟朝凤刺 (5 AP, 18 Qi, range 1-2: +10 hit, knocks adjacent target back 1 tile & leaves Opening)

this.wx_spear_thrust2 <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_spear_thrust2";
		this.m.Name = "百鸟朝凤刺";
		this.m.Description = "抖擞大枪幻出漫天枪影（1~2 格）：命中 +10、穿甲 +10%，命中必留「破绽」；若目标贴身则一枪将其震退 1 格重夺长兵距离！";
		this.m.KilledString = "乱枪穿心";
		this.m.Icon = "skills/active_18.png";
		this.m.IconDisabled = "skills/active_18_sw.png";
		this.m.Overlay = "active_18";
		this.m.SoundOnUse = [
			"sounds/combat/thrust_01.wav",
			"sounds/combat/thrust_02.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/thrust_hit_01.wav"
		];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 18;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.InjuriesOnBody = this.Const.Injury.PiercingBody;
		this.m.InjuriesOnHead = this.Const.Injury.PiercingHead;
		this.m.RequiredWeaponTypes = ["Spear", "Polearm"];
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
		local wasAdjacent = (_user.isPlacedOnMap() && _user.getTile().getDistanceTo(_targetTile) == 1);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			if (wasAdjacent) this.wxTryKnockback(_user, target);
		}
		return hit;
	}
});
