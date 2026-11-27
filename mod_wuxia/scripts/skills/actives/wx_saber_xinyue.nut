// Active Move: 瀚海弯月斩
this.wx_saber_xinyue <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_xinyue";
		this.m.Name = "瀚海弯月斩";
		this.m.Description = "大漠居合快刀：消耗 4 AP 与 16 内息，新月弧光斜掠咽喉（命中 +9，击头率 +10%，伤血必流血）；【纳刀蓄势】下自动升格为『拔刀·孤月一闪』（额外穿甲 +10%、破格反架势，当击斩敌残心返蓄势）。";
		this.m.Icon = "skills/wx_saber_xinyue.png";
		this.m.IconDisabled = "skills/wx_saber_xinyue_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_xinyue";
		this.m.WX_VfxBrush <- "wx_vfx_02";
		this.m.WX_AnimID <- "wx_anim_89";
		this.m.WX_AnimMode <- "flurry_xinyue";
		this.m.WX_ChoreoID <- "wx_saber_xinyue";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Saber", "Sword"];
		this.m.DirectDamageMult = 0.28;
	}
	function getName()
	{
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		if (actor != null && ("Streams" in ::Wuxia) && ::Wuxia.Streams.isIaidoReady(actor))
			return "拔刀·孤月一闪";
		return this.wx_move_base.getName();
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			this.wxApplyTagPreHitProps(_targetEntity, _properties);
			_properties.MeleeSkill += 9;
			_properties.HitChance[::Const.BodyPart.Head] += 10;
			local cont = this.getContainer();
			local actor = cont != null ? cont.getActor() : null;
			if (actor != null && ("Streams" in ::Wuxia) && ::Wuxia.Streams.applyIaidoPreHit(actor, _properties))
				_properties.MeleeSkill += 6;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		local wasIaido = ("Streams" in ::Wuxia) && ::Wuxia.Streams.isIaidoReady(_user);
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(target))
				this.wxApplyStatusToTarget(target, "effects.bleeding", "scripts/skills/effects/bleeding_effect");
			if (wasIaido && target.getSkills() != null)
				target.getSkills().removeByID("effects.wx_status_counter_stance");
		}
		if ("Streams" in ::Wuxia)
			::Wuxia.Streams.consumeIaidoPostHit(_user, target, target != null && !target.isAlive());
		this.wxTriggerTagPostMechanic(_user, target, _targetTile, hit);
		return hit;
	}
});
