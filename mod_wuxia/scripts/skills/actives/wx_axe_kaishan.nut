// Active Move: 旋风开山斩
this.wx_axe_kaishan <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_axe_kaishan";
		this.m.Name = "旋风开山斩";
		this.m.Description = "绿林霸主巨斧劈山式：消耗 6 AP 与 26 内息，力劈华山无坚不摧（总伤 +22%，破甲 +25%）。";
		this.m.Icon = "skills/wx_axe_kaishan.png";
		this.m.IconDisabled = "skills/wx_axe_kaishan_sw.png";
		this.m.Overlay = "wx_ov_wx_axe_kaishan";
		this.m.WX_VfxBrush <- "wx_vfx_02";
		this.m.WX_AnimID <- "wx_anim_30";
		this.m.WX_AnimMode <- "giant_axe";
		this.m.WX_ChoreoID <- "wx_axe_kaishan";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 26;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Axe"];
		this.m.DirectDamageMult = 0.32;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.DamageTotalMult *= 1.22; _properties.DamageArmorMult *= 1.25;
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
