// Active Move: 绊字缠足杖
this.wx_staff_dagou <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_staff_dagou";
		this.m.Name = "绊字缠足杖";
		this.m.Description = "丐门竹棒三十六路精髓：消耗 4 AP 与 18 内息，棒影贴地横扫脚踝（命中 +12，令对手失衡并损内息）。";
		this.m.Icon = "skills/wx_staff_dagou.png";
		this.m.IconDisabled = "skills/wx_staff_dagou_sw.png";
		this.m.Overlay = "wx_ov_wx_staff_dagou";
		this.m.WX_VfxBrush <- "wx_vfx_15";
		this.m.WX_AnimID <- "wx_anim_27";
		this.m.WX_AnimMode <- "bamboo_bind";
		this.m.WX_ChoreoID <- "wx_staff_dagou";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Staff", "Mace", "Polearm"];
		this.m.DirectDamageMult = 0.28;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 12;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance"); if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) target.setFatigue(::Math.min(target.getFatigueMax(), target.getFatigue() + 10));
		}
		return hit;
	}
});
