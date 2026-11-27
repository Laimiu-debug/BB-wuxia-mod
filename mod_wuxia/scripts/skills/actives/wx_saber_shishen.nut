// Active Move: 天狼噬魂斩
this.wx_saber_shishen <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_shishen";
		this.m.Name = "天狼噬魂斩";
		this.m.Description = "塞外天狼血刀秘技：消耗 5 AP 与 22 内息，凶狼扑噬撕裂伤口（对已流血或破绽目标总伤 +28%，回复自身 8 点气血）。";
		this.m.Icon = "skills/wx_saber_shishen.png";
		this.m.IconDisabled = "skills/wx_saber_shishen_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_shishen";
		this.m.WX_VfxBrush <- "wx_vfx_06";
		this.m.WX_AnimID <- "wx_anim_90";
		this.m.WX_AnimMode <- "shadow_shishen";
		this.m.WX_ChoreoID <- "wx_saber_shishen";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 22;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Saber", "Sword"];
		this.m.DirectDamageMult = 0.32;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			this.wxApplyTagPreHitProps(_targetEntity, _properties);
			_properties.MeleeSkill += 8;
			local actor = this.getContainer().getActor();
			local st = (actor != null && "Streams" in ::Wuxia) ? ::Wuxia.Streams.getState(actor) : null;
			local bb = st != null ? (st.m.BloodBladeStacks * 0.04) : 0.0;
			if (_targetEntity != null && _targetEntity.getSkills() != null && (_targetEntity.getSkills().hasSkill("effects.bleeding") || _targetEntity.getSkills().hasSkill("effects.wx_status_opening")))
				_properties.DamageTotalMult *= (1.28 + bb);
			else
				_properties.DamageTotalMult *= (1.12 + bb);
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && ("Streams" in ::Wuxia))
		{
			::Wuxia.Streams.triggerBloodBlade(_user, target);
		}
		this.wxTriggerTagPostMechanic(_user, target, _targetTile, hit);
		return hit;
	}
});
