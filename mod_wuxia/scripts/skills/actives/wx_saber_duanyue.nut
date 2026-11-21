// Active Move: 断岳狂斩 (Secret Saber Art, 6 AP, 26 Qi, +30% dmg & +30% armor dmg; combos with kill +3 AP)

this.wx_saber_duanyue <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_duanyue";
		this.m.WX_VfxBrush <- "wx_vfx_05";
		this.m.WX_AnimID <- "wx_anim_44";
		this.m.WX_AnimMode <- "leap_cleave";
		this.m.WX_ChoreoID <- "wx_saber_duanyue";
		this.m.Name = "断岳狂斩";
		this.m.Description = "断岳狂刀杀招：伤害 +30%、破甲 +30%，并易致敌「失衡」；配合本门心劲斩杀可立返 3 AP！";
		this.m.Icon = "skills/wx_saber_duanyue.png";
		this.m.IconDisabled = "skills/wx_saber_duanyue_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_duanyue";
		this.m.SoundOnUse = [
			"sounds/combat/cleave_03.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/cleave_hit_hitpoints_02.wav"
		];
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 26;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Saber"];
		this.m.DirectDamageMult = 0.30;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.DamageTotalMult *= 1.30;
			_properties.DamageArmorMult *= 1.30;
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		return hit;
	}
});
