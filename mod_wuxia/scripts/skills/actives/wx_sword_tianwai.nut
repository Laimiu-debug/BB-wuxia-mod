// Active Move: 天外一剑 (Unique Sword Art, 7 AP, 36 Qi, range 2 piercing strike, +25% dmg, +20% direct)

this.wx_sword_tianwai <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_tianwai";
		this.m.WX_VfxBrush <- "wx_vfx_07";
		this.m.WX_AnimID <- "wx_anim_02";
		this.m.WX_AnimMode <- "flying_虹";
		this.m.WX_ChoreoID <- "wx_sword_tianwai";
		this.m.Name = "天外一剑";
		this.m.Description = "剑道极境孤本绝招：消耗 7 AP 与 36 内息，贯出两格剑气直透经脉（伤害 +25%，额外穿甲 +20%，并留破绽）。";
		this.m.Icon = "skills/wx_sword_tianwai.png";
		this.m.IconDisabled = "skills/wx_sword_tianwai_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_tianwai";
		this.m.SoundOnUse = [
			"sounds/combat/riposte_03.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/slash_hit_03.wav"
		];
		this.m.ActionPointCost = 7;
		this.m.FatigueCost = 36;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.IsDoingForwardMove = false;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.45;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 12;
			_properties.DamageTotalMult *= 1.25;
			_properties.DamageDirectAdd += 0.20;
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
		}
		return hit;
	}
});
