// Active Move: 无影鬼刺杀
this.wx_dagger_yingci <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_dagger_yingci";
		this.m.Name = "无影鬼刺杀";
		this.m.Description = "青城幽谷暗夜双刺：消耗 4 AP 与 17 内息，鬼烟掩护双匕交剪（命中 +12，对落单或失衡目标总伤 +26%）。";
		this.m.Icon = "skills/wx_dagger_yingci.png";
		this.m.IconDisabled = "skills/wx_dagger_yingci_sw.png";
		this.m.Overlay = "wx_ov_wx_dagger_yingci";
		this.m.WX_VfxBrush <- "wx_vfx_25";
		this.m.WX_AnimID <- "wx_anim_132";
		this.m.WX_AnimMode <- "shadow_yingci";
		this.m.WX_ChoreoID <- "wx_dagger_yingci";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 17;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Dagger"];
		this.m.DirectDamageMult = 0.36;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 12; if (_targetEntity != null && _targetEntity.getSkills().hasSkill("effects.wx_status_offbalance")) _properties.DamageTotalMult *= 1.26; else _properties.DamageTotalMult *= 1.10;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		return hit;
	}
});
