// Active Move: 狂风快刀斩
this.wx_saber_kuangfeng <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_kuangfeng";
		this.m.Name = "狂风快刀斩";
		this.m.Description = "大漠狂风骤雨刀路：消耗 4 AP 与 16 内息，顺风疾劈（命中 +6，伤血必令非尸傀目标割裂流血）。";
		this.m.Icon = "skills/wx_saber_kuangfeng.png";
		this.m.IconDisabled = "skills/wx_saber_kuangfeng_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_kuangfeng";
		this.m.WX_VfxBrush <- "wx_vfx_26";
		this.m.WX_AnimID <- "wx_anim_46";
		this.m.WX_AnimMode <- "omnislash6";
		this.m.WX_ChoreoID <- "wx_saber_kuangfeng";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Saber", "Sword"];
		this.m.DirectDamageMult = 0.25;
		this.m.WX_ComboForms = [
			{
				Name = "狂风快刀·一式起风",
				Description = "大漠狂风刀起手式（4 AP / 15 内息）：顺风斜劈（命中 +6，割裂流血），命中后同槽递进为【二式卷云】。",
				AP = 4, Qi = 15, Hit = 6, Dmg = 1.00, Arm = 1.05
			},
			{
				Name = "狂风快刀·二式卷云",
				Description = "狂风连斩承接式（4 AP / 15 内息）：刀风卷云连劈（命中 +10、破甲 +15%，附加流血与失衡），命中递进为终结技【三式断海】。",
				AP = 4, Qi = 15, Hit = 10, Dmg = 1.08, Arm = 1.15
			},
			{
				Name = "狂风快刀·三式断海",
				Description = "狂风快刀终结式（4 AP / 16 内息）：怒涛百叠重劈（命中 +12、总伤 +18%），撕裂流血伤口追加爆血并恢复自身 5 点内息！",
				AP = 4, Qi = 16, Hit = 12, Dmg = 1.18, Arm = 1.20
			}
		];
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			this.wxApplyTagPreHitProps(_targetEntity, _properties);
			local cf = this.wxGetActiveComboForm();
			_properties.MeleeSkill += (cf != null ? cf.Hit : 6);
			_properties.DamageTotalMult *= (cf != null ? cf.Dmg : 1.0);
			_properties.DamageArmorMult *= (cf != null ? cf.Arm : 1.0);
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
			if (target != null && target.isAlive())
			{
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(target))
					this.wxApplyStatusToTarget(target, "effects.bleeding", "scripts/skills/effects/bleeding_effect");
				if (stg >= 1)
					this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
				if (stg == 2 && ("Streams" in ::Wuxia))
				{
					::Wuxia.Streams.triggerBloodBlade(_user, target);
					::Wuxia.CombatRules.restoreQi(_user, 5);
				}
			}
			if ("Streams" in ::Wuxia)
				::Wuxia.Streams.advanceComboStage(_user, this.m.ID, 3, true);
		}
		else if ("Streams" in ::Wuxia)
		{
			::Wuxia.Streams.resetComboStage(_user, this.m.ID);
		}
		return hit;
	}
});
