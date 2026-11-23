// Active Move: 莲花落缠杖
this.wx_staff_lianhua <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_staff_lianhua";
		this.m.Name = "莲花落缠杖";
		this.m.Description = "丐门缠丝巧棒：消耗 4 AP 与 15 内息，棒随身转敲打手腕膝弯（命中 +10，附加散劲虚弱）。";
		this.m.Icon = "skills/wx_staff_lianhua.png";
		this.m.IconDisabled = "skills/wx_staff_lianhua_sw.png";
		this.m.Overlay = "wx_ov_wx_staff_lianhua";
		this.m.WX_VfxBrush <- "wx_vfx_15";
		this.m.WX_AnimID <- "wx_anim_120";
		this.m.WX_AnimMode <- "whip_lianhua";
		this.m.WX_ChoreoID <- "wx_staff_lianhua";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 15;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Staff"];
		this.m.DirectDamageMult = 0.28;
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
			this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness");
		}
		return hit;
	}
});
