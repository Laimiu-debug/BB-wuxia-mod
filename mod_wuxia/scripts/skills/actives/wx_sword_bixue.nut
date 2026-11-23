// Active Move: 碧水惊涛剑
this.wx_sword_bixue <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_bixue";
		this.m.Name = "碧水惊涛剑";
		this.m.Description = "武夷剑派绵长叠浪剑：消耗 5 AP 与 20 内息，剑势如春江惊涛拍岸（总伤 +15%，震退目标一格并致失衡）。";
		this.m.Icon = "skills/wx_sword_bixue.png";
		this.m.IconDisabled = "skills/wx_sword_bixue_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_bixue";
		this.m.WX_VfxBrush <- "wx_vfx_21";
		this.m.WX_AnimID <- "wx_anim_79";
		this.m.WX_AnimMode <- "upcut_bixue";
		this.m.WX_ChoreoID <- "wx_sword_bixue";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.28;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 6; _properties.DamageTotalMult *= 1.15;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxTryKnockback(_user, target); this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		return hit;
	}
});
