// Active Move: 破刃荡剑式
this.wx_sword_dugu <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_dugu";
		this.m.Name = "破刃荡剑式";
		this.m.Description = "专破天下兵刃守势之妙着：消耗 5 AP 与 24 内息，挑荡敌手兵刃架势（命中解除盾墙/枪阵/反击并留破绽）。";
		this.m.Icon = "skills/wx_sword_dugu.png";
		this.m.IconDisabled = "skills/wx_sword_dugu_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_dugu";
		this.m.WX_VfxBrush <- "wx_vfx_07";
		this.m.WX_AnimID <- "wx_anim_40";
		this.m.WX_AnimMode <- "disarm_arc";
		this.m.WX_ChoreoID <- "wx_sword_dugu";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 24;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.32;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 10;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			local tsk = target.getSkills(); if (tsk != null) { tsk.removeByID("effects.shieldwall"); tsk.removeByID("effects.spearwall"); tsk.removeByID("effects.riposte"); tsk.removeByID("effects.wx_status_counter_stance"); };
			this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
		}
		return hit;
	}
});
