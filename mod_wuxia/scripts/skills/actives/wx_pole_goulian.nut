// Active Move: 钩镰锁足拽
this.wx_pole_goulian <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_pole_goulian";
		this.m.Name = "钩镰锁足拽";
		this.m.Description = "破骑钩镰长兵秘技：消耗 5 AP 与 20 内息，自两格外钩住敌腿硬拽至身前并令其失衡。";
		this.m.Icon = "skills/wx_pole_goulian.png";
		this.m.IconDisabled = "skills/wx_pole_goulian_sw.png";
		this.m.Overlay = "wx_ov_wx_pole_goulian";
		this.m.WX_VfxBrush <- "wx_vfx_31";
		this.m.WX_AnimID <- "wx_anim_28";
		this.m.WX_AnimMode <- "hook_pull";
		this.m.WX_ChoreoID <- "wx_pole_goulian";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Polearm", "Spear"];
		this.m.DirectDamageMult = 0.26;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxTryPullToAdjacent(_user, target); this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		return hit;
	}
});
