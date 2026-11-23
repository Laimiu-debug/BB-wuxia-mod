// Active Move: 雁门斩马劈
this.wx_saber_podao <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_podao";
		this.m.Name = "雁门斩马劈";
		this.m.Description = "九边重刀破骑绝杀：消耗 6 AP 与 26 内息，双手抡刀自上而下重劈肩甲（破甲 +42%，总伤 +16%，致敌失衡）。";
		this.m.Icon = "skills/wx_saber_podao.png";
		this.m.IconDisabled = "skills/wx_saber_podao_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_podao";
		this.m.WX_VfxBrush <- "wx_vfx_05";
		this.m.WX_AnimID <- "wx_anim_91";
		this.m.WX_AnimMode <- "sky_podao";
		this.m.WX_ChoreoID <- "wx_saber_podao";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 26;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Saber", "Sword"];
		this.m.DirectDamageMult = 0.30;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 6; _properties.DamageArmorMult *= 1.42; _properties.DamageTotalMult *= 1.16;
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
