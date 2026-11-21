// Secret Fist Move 1: 拈花点穴指 (4 AP, 14 Qi, +8 hit chance, 80% dmg, applies 2-turn 点穴封气)

this.wx_fist_acupoint <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_acupoint";
		this.m.WX_VfxBrush <- "wx_vfx_16";
		this.m.WX_AnimID <- "wx_anim_23";
		this.m.WX_AnimMode <- "lotus_poke";
		this.m.WX_ChoreoID <- "wx_fist_acupoint";
		this.m.Name = "拈花点穴指";
		this.m.Description = "并指如兰疾点大穴：命中额外 +8、造成八成内劲伤，令目标 2 回合陷入「点穴封气」（回气 -8、招式耗气 +35%）。";
		this.m.Icon = "skills/wx_fist_acupoint.png";
		this.m.IconDisabled = "skills/wx_fist_acupoint_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_acupoint";
		this.m.SoundOnUse = [
			"sounds/combat/hand_02.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/hand_hit_02.wav"
		];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 14;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.InjuriesOnBody = this.Const.Injury.BluntBody;
		this.m.InjuriesOnHead = this.Const.Injury.BluntHead;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.45;
		this.m.IsIgnoredAsAOO = true;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8;
			_properties.DamageTotalMult *= 0.80;
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);
		if (hit)
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_acupoint", "scripts/skills/effects/wx_status_acupoint");
		}
		return hit;
	}
});
