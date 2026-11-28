// Active Move: 绊字缠足杖
this.wx_staff_dagou <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_staff_dagou";
		this.m.Name = "绊字缠足杖";
		this.m.Description = "丐门竹棒三十六路精髓：消耗 4 AP 与 18 内息，棒影贴地横扫脚踝（命中 +12，令对手失衡并损内息）。";
		this.m.Icon = "skills/wx_staff_dagou.png";
		this.m.IconDisabled = "skills/wx_staff_dagou_sw.png";
		this.m.Overlay = "wx_ov_wx_staff_dagou";
		this.m.WX_VfxBrush <- "wx_vfx_15";
		this.m.WX_AnimID <- "wx_anim_27";
		this.m.WX_AnimMode <- "bamboo_bind";
		this.m.WX_ChoreoID <- "wx_staff_dagou";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Staff", "Mace", "Polearm"];
		this.m.DirectDamageMult = 0.28;
		this.m.WX_ComboForms = [
			{
				Name = "打狗棒·绊字诀",
				Description = "打狗棒起手式（4 AP / 16 内息）：竹棒贴地横扫脚踝（命中 +12，令对手失衡并损10内息），命中递进为【缠字诀】。",
				AP = 4, Qi = 16, Hit = 12, Dmg = 1.00
			},
			{
				Name = "打狗棒·缠字诀",
				Description = "打狗棒承接式（4 AP / 16 内息）：棒随身走如藤蔓缠腕（命中 +14），两格强拽来敌入阵并挂【散功虚弱】，命中递进为【天下无狗】。",
				AP = 4, Qi = 16, Hit = 14, Dmg = 1.10
			},
			{
				Name = "打狗棒·天下无狗",
				Description = "打狗棒绝学终结技（5 AP / 18 内息）：八方棒影齐发（命中 +16、总伤 +20%），当场敲断敌方蓄势/山海凶兆并横扫紧邻 2 敌！",
				AP = 5, Qi = 18, Hit = 16, Dmg = 1.20
			}
		];
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			this.wxApplyTagPreHitProps(_targetEntity, _properties);
			local cf = this.wxGetActiveComboForm();
			_properties.MeleeSkill += (cf != null ? cf.Hit : 12);
			_properties.DamageTotalMult *= (cf != null ? cf.Dmg : 1.0);
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
				this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(target))
					target.setFatigue(::Math.min(target.getFatigueMax(), target.getFatigue() + 10));
				if (stg == 1)
				{
					this.wxTryPullToAdjacent(_user, target);
					this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness");
				}
				else if (stg == 2)
				{
					if ("Streams" in ::Wuxia) ::Wuxia.Streams.interruptEnemyCharge(_user, target, 2);
					if (_targetTile != null && ::Wuxia.hasMember(_targetTile, "hasNextTile"))
					{
						local extra = 0;
						for (local d = 0; d < 6 && extra < 2; d = ++d)
						{
							if (!_targetTile.hasNextTile(d)) continue;
							local adj = _targetTile.getNextTile(d);
							if (adj != null && adj.IsOccupiedByActor && adj.getEntity() != null && adj.getEntity().isAlive() && !_user.isAlliedWith(adj.getEntity()))
							{
								this.attackEntity(_user, adj.getEntity());
								extra += 1;
							}
						}
					}
				}
			}
			if ("Streams" in ::Wuxia) ::Wuxia.Streams.advanceComboStage(_user, this.m.ID, 3, true);
		}
		else if ("Streams" in ::Wuxia)
		{
			::Wuxia.Streams.resetComboStage(_user, this.m.ID);
		}
		return hit;
	}
});
