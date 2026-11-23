// Active Move: 钱塘裂岸掌
this.wx_fist_nuchao <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_nuchao";
		this.m.Name = "钱塘裂岸掌";
		this.m.Description = "江浙潮帮排山掌力：消耗 5 AP 与 20 内息，掌风如钱塘大潮卷退强敌（总伤 +18%，击退一格并附内伤）。";
		this.m.Icon = "skills/wx_fist_nuchao.png";
		this.m.IconDisabled = "skills/wx_fist_nuchao_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_nuchao";
		this.m.WX_VfxBrush <- "wx_vfx_21";
		this.m.WX_AnimID <- "wx_anim_100";
		this.m.WX_AnimMode <- "upcut_nuchao";
		this.m.WX_ChoreoID <- "wx_fist_nuchao";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.38;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 6; _properties.DamageTotalMult *= 1.18;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxTryKnockback(_user, target); this.wxApplyStatusToTarget(target, "effects.wx_internal_injury", "scripts/skills/effects/wx_internal_injury");
		}
		return hit;
	}
});
