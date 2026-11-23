// Active Move: 黑砂透骨掌
this.wx_fist_heisha <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_heisha";
		this.m.Name = "黑砂透骨掌";
		this.m.Description = "绿林阴毒铁砂毒掌：消耗 4 AP 与 16 内息，掌带腥黑毒砂隔衣伤肺（穿甲 +14%，附加内伤）。";
		this.m.Icon = "skills/wx_fist_heisha.png";
		this.m.IconDisabled = "skills/wx_fist_heisha_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_heisha";
		this.m.WX_VfxBrush <- "wx_vfx_11";
		this.m.WX_AnimID <- "wx_anim_108";
		this.m.WX_AnimMode <- "shadow_heisha";
		this.m.WX_ChoreoID <- "wx_fist_heisha";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.38;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 6; _properties.DamageDirectAdd += 0.14;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_internal_injury", "scripts/skills/effects/wx_internal_injury");
		}
		return hit;
	}
});
