// Active Move: 雪龙穿云刺
this.wx_spear_xuelong <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_spear_xuelong";
		this.m.Name = "雪龙穿云刺";
		this.m.Description = "长白苦寒绝域神枪：消耗 5 AP 与 22 内息，枪卷暴雪寒芒贯刺两格目标（穿甲 +16%，命中 +8，致敌失衡）。";
		this.m.Icon = "skills/wx_spear_xuelong.png";
		this.m.IconDisabled = "skills/wx_spear_xuelong_sw.png";
		this.m.Overlay = "wx_ov_wx_spear_xuelong";
		this.m.WX_VfxBrush <- "wx_vfx_10";
		this.m.WX_AnimID <- "wx_anim_111";
		this.m.WX_AnimMode <- "upcut_xuelong";
		this.m.WX_ChoreoID <- "wx_spear_xuelong";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 22;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Spear", "Polearm"];
		this.m.DirectDamageMult = 0.34;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8; _properties.DamageDirectAdd += 0.16; _properties.DamageTotalMult *= 1.12;
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
