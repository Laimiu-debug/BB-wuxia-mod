// Active Move: 松风摧心刺
this.wx_sword_cuixin <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_cuixin";
		this.m.Name = "松风摧心刺";
		this.m.Description = "青城阴狠绝命快剑：消耗 4 AP 与 18 内息，专刺受伤残敌心脉（目标气血不满时总伤 +25%，并留流血破绽）。";
		this.m.Icon = "skills/wx_sword_cuixin.png";
		this.m.IconDisabled = "skills/wx_sword_cuixin_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_cuixin";
		this.m.WX_VfxBrush <- "wx_vfx_01";
		this.m.WX_AnimID <- "wx_anim_39";
		this.m.WX_AnimMode <- "spiral_stab";
		this.m.WX_ChoreoID <- "wx_sword_cuixin";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.35;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			if (_targetEntity != null && _targetEntity.getHitpoints() < _targetEntity.getHitpointsMax()) _properties.DamageTotalMult *= 1.25;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
		}
		return hit;
	}
});
