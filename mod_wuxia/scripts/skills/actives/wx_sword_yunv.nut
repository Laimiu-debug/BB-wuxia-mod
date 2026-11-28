// Active Move: 冷月双飞剑
this.wx_sword_yunv <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_yunv";
		this.m.Name = "冷月双飞剑";
		this.m.Description = "终南古墓清冷快剑：消耗 4 AP 与 16 内息，剑走轻灵双刺咽喉（命中 +10，身法高于目标时额外穿甲 +12%）。";
		this.m.Icon = "skills/wx_sword_yunv.png";
		this.m.IconDisabled = "skills/wx_sword_yunv_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_yunv";
		this.m.WX_VfxBrush <- "wx_vfx_01";
		this.m.WX_AnimID <- "wx_anim_77";
		this.m.WX_AnimMode <- "flurry_yunv";
		this.m.WX_ChoreoID <- "wx_sword_yunv";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.30;
		this.m.WX_ComboForms = [
			{
				Name = "冷月双飞·左式素心",
				Description = "古墓双剑起手式（4 AP / 15 内息）：剑走轻灵（命中 +10，身法高于目标额外穿甲 +12%），命中递进为 3 AP【右式双飞】。",
				AP = 4, Qi = 15, Hit = 10, Dmg = 1.00
			},
			{
				Name = "冷月双飞·右式双飞",
				Description = "古墓双剑交剪式（3 AP / 14 内息）：疾风剪喉（命中 +12，额外穿甲 +12%），施加【破绽】并在敌旁凝出一柄驻场气剑！",
				AP = 3, Qi = 14, Hit = 12, Dmg = 1.08
			}
		];
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			this.wxApplyTagPreHitProps(_targetEntity, _properties);
			local cf = this.wxGetActiveComboForm();
			local u = this.getContainer().getActor();
			_properties.MeleeSkill += (cf != null ? cf.Hit : 10);
			_properties.DamageTotalMult *= (cf != null ? cf.Dmg : 1.0);
			if (u != null && _targetEntity != null && (u.getInitiative() > _targetEntity.getInitiative() || cf != null && cf.AP == 3))
			{
				if ("Streams" in ::Wuxia) ::Wuxia.Streams.addCappedPen(_properties, 0.12);
			}
		}
	}

	function onUse( _user, _targetTile )
	{
		local stg = ("Streams" in ::Wuxia) ? ::Wuxia.Streams.getComboStage(_user, this.m.ID) : 0;
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit)
		{
			if (stg == 1 && target != null && target.isAlive())
			{
				this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
				if ("Streams" in ::Wuxia) ::Wuxia.Streams.spawnSwordNode(_user, _targetTile);
			}
			if ("Streams" in ::Wuxia) ::Wuxia.Streams.advanceComboStage(_user, this.m.ID, 2, true);
		}
		else if ("Streams" in ::Wuxia)
		{
			::Wuxia.Streams.resetComboStage(_user, this.m.ID);
		}
		return hit;
	}
});
