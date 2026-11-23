// Active Move: 千蛛万毒手
this.wx_fist_qianzhu <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_qianzhu";
		this.m.Name = "千蛛万毒手";
		this.m.Description = "南疆五毒阴狠毒功：消耗 4 AP 与 18 内息，十指奇毒顺血攻心（命中 +8，穿甲 +14%，必附奇毒蚀脉与破绽）。";
		this.m.Icon = "skills/wx_fist_qianzhu.png";
		this.m.IconDisabled = "skills/wx_fist_qianzhu_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_qianzhu";
		this.m.WX_VfxBrush <- "wx_vfx_28";
		this.m.WX_AnimID <- "wx_anim_101";
		this.m.WX_AnimMode <- "shadow_qianzhu";
		this.m.WX_ChoreoID <- "wx_fist_qianzhu";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.40;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8; _properties.DamageDirectAdd += 0.14;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart"); this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
		}
		return hit;
	}
});
