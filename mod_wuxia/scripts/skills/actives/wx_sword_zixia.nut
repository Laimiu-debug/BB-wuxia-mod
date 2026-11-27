// Active Move: 紫霞破气剑
this.wx_sword_zixia <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_zixia";
		this.m.Name = "紫霞破气剑";
		this.m.Description = "华山紫气贯刃绝艺：消耗 5 AP 与 21 内息，紫霞真气透剑破开内家护体（穿甲 +15%，破甲 +20%，附加内伤）。";
		this.m.Icon = "skills/wx_sword_zixia.png";
		this.m.IconDisabled = "skills/wx_sword_zixia_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_zixia";
		this.m.WX_VfxBrush <- "wx_vfx_04";
		this.m.WX_AnimID <- "wx_anim_82";
		this.m.WX_AnimMode <- "pierce_zixia";
		this.m.WX_ChoreoID <- "wx_sword_zixia";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 21;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.35;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			this.wxApplyTagPreHitProps(_targetEntity, _properties);
			_properties.MeleeSkill += 8;
			if ("Streams" in ::Wuxia) ::Wuxia.Streams.addCappedPen(_properties, 0.15);
			_properties.DamageArmorMult *= 1.20;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit)
		{
			if (target != null && target.isAlive())
			{
				this.wxApplyStatusToTarget(target, "effects.wx_internal_injury", "scripts/skills/effects/wx_internal_injury");
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(target))
					::Wuxia.CombatRules.spendQi(target, 8);
			}
			if ("Streams" in ::Wuxia)
				::Wuxia.Streams.spawnSwordNode(_user, _targetTile);
		}
		this.wxTriggerTagPostMechanic(_user, target, _targetTile, hit);
		return hit;
	}
});
