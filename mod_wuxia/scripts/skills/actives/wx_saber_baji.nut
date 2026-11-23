// Active Move: 淮阳八极斩
this.wx_saber_baji <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_baji";
		this.m.Name = "淮阳八极斩";
		this.m.Description = "将门沉稳贴身劲刀：消耗 4 AP 与 16 内息，肩刀齐至震碎护甲（破甲 +28%，命中 +6）。";
		this.m.Icon = "skills/wx_saber_baji.png";
		this.m.IconDisabled = "skills/wx_saber_baji_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_baji";
		this.m.WX_VfxBrush <- "wx_vfx_14";
		this.m.WX_AnimID <- "wx_anim_96";
		this.m.WX_AnimMode <- "pierce_baji";
		this.m.WX_ChoreoID <- "wx_saber_baji";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Saber", "Sword"];
		this.m.DirectDamageMult = 0.26;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 6; _properties.DamageArmorMult *= 1.28;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			
		}
		return hit;
	}
});
