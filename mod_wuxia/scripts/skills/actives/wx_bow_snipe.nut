// Sect/Secret Bow Move: 流星追月箭 (5 AP, 20 Qi, range 2-7: +12 RangedSkill, +15% pen, leaves Opening)

this.wx_bow_snipe <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_bow_snipe";
		this.m.Name = "流星追月箭";
		this.m.Description = "屏息开满弓弦贯注内息（2~7 格）：射艺命中 +12、穿甲率 +15%，一箭破开目标「破绽」供前排重创！";
		this.m.KilledString = "流星一箭贯脑";
		this.m.Icon = "skills/active_03.png";
		this.m.IconDisabled = "skills/active_03_sw.png";
		this.m.Overlay = "active_03";
		this.m.SoundOnUse = [
			"sounds/combat/javelin_throw_01.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/javelin_hit_01.wav"
		];
		this.m.IsRanged = true;
		this.m.IsIgnoredAsAOO = true;
		this.m.IsDoingForwardMove = false;
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 2;
		this.m.MaxRange = 7;
		this.m.MaxLevelDifference = 4;
		this.m.InjuriesOnBody = this.Const.Injury.PiercingBody;
		this.m.InjuriesOnHead = this.Const.Injury.PiercingHead;
		this.m.RequiredWeaponTypes = ["Bow"];
		this.m.DirectDamageMult = 0.45;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.RangedSkill += 12;
			_properties.DamageDirectAdd += 0.15;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		local hit = this.wxShootBowAt(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
		}
		return hit;
	}
});
