// Active Move: 玄冥寒毒掌
this.wx_fist_xuanming <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_xuanming";
		this.m.Name = "玄冥寒毒掌";
		this.m.Description = "西域苦寒阴毒奇掌：消耗 5 AP 与 24 内息，掌风奇寒彻骨冻结真元（穿甲 +15%，追加寒毒蚀脉与内息凝滞）。";
		this.m.Icon = "skills/wx_fist_xuanming.png";
		this.m.IconDisabled = "skills/wx_fist_xuanming_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_xuanming";
		this.m.WX_VfxBrush <- "wx_vfx_10";
		this.m.WX_AnimID <- "wx_anim_06";
		this.m.WX_AnimMode <- "frost_tomb";
		this.m.WX_ChoreoID <- "wx_fist_xuanming";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 24;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.42;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 6; _properties.DamageDirectAdd += 0.15;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart"); if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) target.setFatigue(::Math.min(target.getFatigueMax(), target.getFatigue() + 14));
		}
		return hit;
	}
});
