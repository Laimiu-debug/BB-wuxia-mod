// Active Move: 威远守线刺 (Spear/Polearm, 5 AP, 16 Qi, range 1-2, +10% hit, inflicts 失衡)

this.wx_spear_guard <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_spear_guard";
		this.m.WX_VfxBrush <- "wx_vfx_03";
		this.m.WX_AnimID <- "wx_anim_53";
		this.m.WX_AnimMode <- "spear_wall";
		this.m.WX_ChoreoID <- "wx_spear_guard";
		this.m.Name = "威远守线刺";
		this.m.Description = "威远镖局控距枪法。刺击 1~2 格目标时命中 +10%，命中后有机会令敌手「失衡」（招架 -10、身法 -15），概率随功法重数提升。";
		this.m.Icon = "skills/wx_spear_guard.png";
		this.m.IconDisabled = "skills/wx_spear_guard_sw.png";
		this.m.Overlay = "wx_ov_wx_spear_guard";
		this.m.SoundOnUse = [
			"sounds/combat/thrust_01.wav",
			"sounds/combat/thrust_02.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/thrust_hit_01.wav"
		];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Spear", "Polearm"];
		this.m.DirectDamageMult = 0.25;
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
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);
		if ("Streams" in ::Wuxia) ::Wuxia.Streams.activateSpearWallStance(_user, 2);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance", "InflictOffBalancePct");
		}
		return hit;
	}
});
