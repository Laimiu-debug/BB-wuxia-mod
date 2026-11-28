// Sect Dagger Move: 分水断脉刺 (4 AP, 14 Qi: +10 hit, +10% pen, inflicts bleed & drains 12 Qi)

this.wx_dagger_vital <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_dagger_vital";
		this.m.WX_VfxBrush <- "wx_vfx_04";
		this.m.WX_AnimID <- "wx_anim_33";
		this.m.WX_AnimMode <- "twin_fang";
		this.m.WX_ChoreoID <- "wx_dagger_vital";
		this.m.Name = "分水断脉刺";
		this.m.Description = "贴身短刃疾挑敌手腕脉气门：命中 +10、穿甲 +10%，击中生人附加割裂流血并震散其 12 点内息。";
		this.m.KilledString = "短刺挑断大筋";
		this.m.Icon = "skills/wx_dagger_vital.png";
		this.m.IconDisabled = "skills/wx_dagger_vital_sw.png";
		this.m.Overlay = "wx_ov_wx_dagger_vital";
		this.m.SoundOnUse = [
			"sounds/combat/stab_01.wav",
			"sounds/combat/stab_02.wav",
			"sounds/combat/stab_03.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/stab_hit_01.wav",
			"sounds/combat/stab_hit_02.wav",
			"sounds/combat/stab_hit_03.wav"
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
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive() && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(target))
		{
			if (!::Wuxia.CombatRules.isImmuneToBleeding(target))
			{
				local bleed = ::new("scripts/skills/effects/bleeding_effect");
				bleed.setDamage(5);
				target.getSkills().add(bleed);
			}
			target.setFatigue(::Math.min(target.getFatigueMax(), target.getFatigue() + 12));
		}
		return hit;
	}
});
