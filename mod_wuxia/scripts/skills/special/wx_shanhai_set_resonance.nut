// Singleton Zero-Save-Footprint Runtime Skill for Shan Hai Jing Set Resonance (`山海共鸣` & `本命真魂`)
// Dynamically evaluates equipped gear across Mainhand/Offhand/Body(+Upgrade)/Head/Accessory,
// hides itself when 0 sets are active, and surfaces live status icon + tooltip when >=1 set is active!

this.wx_shanhai_set_resonance <- this.inherit("scripts/skills/skill", {
	m = {
		CachedEval                = null,
		BingzhuKillUsedThisTurn   = false,
		BingzhuDreadUsedThisBattle = false,
		CanglongStrikeUsedThisTurn = false,
		BeimingQiThisTurn         = 0,
		BeimingChillUsedThisBattle = 0,
		HasKunlunWard             = false,
		StartTileID               = -1
	},

	function create()
	{
		this.m.ID = "special.wx_shanhai_set_resonance";
		this.m.Name = "山海套装共鸣";
		this.m.Description = "多件山海神兵宝甲或百工猎妖奇物同源共鸣所激发的上古异禀。";
		this.m.Icon = "ui/perks/wx_shanhai_boss_trait.png";
		this.m.Type = this.Const.SkillType.Special | this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.Trait + 2;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsHidden = true;
		this.m.IsSerialized = false;
	}

	function getEval()
	{
		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();
		if (actor == null || !("ShanHaiSets" in ::Wuxia)) return null;
		return ::Wuxia.ShanHaiSets.evaluateActorSets(actor);
	}

	function hasTier( _setID, _need )
	{
		local ev = this.m.CachedEval != null ? this.m.CachedEval : this.getEval();
		if (ev == null || !(_setID in ev.SetCounts)) return false;
		return ev.SetCounts[_setID] >= _need;
	}

	function wxApplyStatusSafe( _tsk, _effectID, _scriptPath )
	{
		if (_tsk == null) return;
		local ex = _tsk.getSkillByID(_effectID);
		if (ex == null) _tsk.add(::new(_scriptPath));
		else if (::Wuxia.hasMember(ex, "resetDuration")) ex.resetDuration();
	}

	function wxCountNegativeStatuses( _tsk )
	{
		if (_tsk == null) return 0;
		local cnt = 0;
		foreach (eid in [
			"effects.wx_status_poison_dart", "effects.spider_poison", "effects.goblin_poison",
			"effects.bleeding", "effects.wx_status_opening", "effects.wx_status_offbalance",
			"effects.wx_status_acupoint", "effects.wx_scatter_weakness", "effects.wx_status_frost_chill",
			"effects.wx_internal_injury", "effects.stunned", "effects.dazed", "effects.net", "effects.staggered"
		])
		{
			if (_tsk.hasSkill(eid)) cnt += 1;
		}
		return cnt;
	}

	function getTooltip()
	{
		local ret = [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description", text = this.getDescription() }
		];
		local ev = this.getEval();
		if (ev == null) return ret;

		local rowId = 10;
		foreach (act in ev.ActiveSets)
		{
			local scfg = ::Wuxia.Config.ShanHaiSets[act.SetID];
			local setCol = ("TooltipColor" in scfg) ? scfg.TooltipColor : scfg.Color;
			ret.push({
				id = rowId++,
				type = "text",
				icon = scfg.Icon,
				text = "[color=" + setCol + "]【" + scfg.Name + "（已穿戴 " + act.Count + " 件）】[/color]"
			});
			foreach (b in scfg.Bonuses)
			{
				if (act.Count >= b.Need)
				{
					ret.push({
						id = rowId++,
						type = "text",
						icon = "ui/icons/special.png",
						text = "[color=#0a4213]◆ [" + b.Need + "件·" + b.Title + "]：[/color]" + b.Text
					});
				}
			}
		}

		foreach (tid in ev.ActiveTotems)
		{
			local tcfg = ::Wuxia.Config.ShanHaiTotemPairs[tid];
			ret.push({
				id = rowId++,
				type = "text",
				icon = "ui/icons/bravery.png",
				text = "[color=#5e2c00]★ [" + tcfg.Title + "]：[/color]" + tcfg.Text
			});
		}

		if (this.m.HasKunlunWard && this.hasTier("wx_set_kunlun", 3))
		{
			ret.push({
				id = rowId++,
				type = "text",
				icon = "ui/icons/armor_body.png",
				text = "[color=#533200]【玄龟护体已凝结】[/color]下次受击气血实伤 -25% 并修复 8 点身甲"
			});
		}
		return ret;
	}

	function onCombatStarted()
	{
		this.m.BingzhuKillUsedThisTurn = false;
		this.m.BingzhuDreadUsedThisBattle = false;
		this.m.CanglongStrikeUsedThisTurn = false;
		this.m.BeimingQiThisTurn = 0;
		this.m.BeimingChillUsedThisBattle = 0;
		this.m.StartTileID = -1;
		local ev = this.getEval();
		this.m.CachedEval = ev;
		this.m.HasKunlunWard = (ev != null && ("wx_set_kunlun" in ev.SetCounts) && ev.SetCounts.wx_set_kunlun >= 3);
	}

	function onCombatFinished()
	{
		this.m.BingzhuKillUsedThisTurn = false;
		this.m.BingzhuDreadUsedThisBattle = false;
		this.m.CanglongStrikeUsedThisTurn = false;
		this.m.BeimingQiThisTurn = 0;
		this.m.BeimingChillUsedThisBattle = 0;
		this.m.HasKunlunWard = false;
		this.m.StartTileID = -1;
	}

	function onTurnStart()
	{
		this.m.BingzhuKillUsedThisTurn = false;
		this.m.CanglongStrikeUsedThisTurn = false;
		this.m.BeimingQiThisTurn = 0;
		this.m.HasKunlunWard = false;

		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();
		if (actor == null || !actor.isAlive()) return;

		if (::Wuxia.hasMember(actor, "isPlacedOnMap") && actor.isPlacedOnMap() && actor.getTile() != null)
			this.m.StartTileID = actor.getTile().ID;
		else
			this.m.StartTileID = -1;

		local ev = this.getEval();
		this.m.CachedEval = ev;
		if (ev == null) return;

		// 大荒金乌套 3 件：十日焚邪 — 回合初自动驱散散功虚弱与寒凝封穴
		if (this.hasTier("wx_set_jinwu", 3))
		{
			if (cont.hasSkill("effects.wx_scatter_weakness")) cont.removeByID("effects.wx_scatter_weakness");
			if (cont.hasSkill("effects.wx_status_frost_chill")) cont.removeByID("effects.wx_status_frost_chill");
			if (cont.hasSkill("effects.chilled")) cont.removeByID("effects.chilled");
		}

		local items = (::Wuxia.hasMember(actor, "getItems")) ? actor.getItems() : null;
		local body = items == null ? null : items.getItemAtSlot(::Const.ItemSlot.Body);
		local shd  = items == null ? null : items.getItemAtSlot(::Const.ItemSlot.Offhand);

		// 百工猎妖录 4 件：百工庖丁 — 每回合初修复 5 点身甲并回复 2 点内息
		if (this.hasTier("wx_set_baigong", 4))
		{
			::Wuxia.CombatRules.restoreQi(actor, 2);
			if (body != null && ::Wuxia.hasMember(body, "getArmor") && body.getArmor() < body.getArmorMax())
				body.setArmor(::Math.min(body.getArmorMax(), body.getArmor() + 5));
		}

		// 同源双件【本命真魂】回合初调息与修甲自愈
		foreach (tid in ev.ActiveTotems)
		{
			local tcfg = ::Wuxia.Config.ShanHaiTotemPairs[tid];
			if (("TurnQi" in tcfg) && tcfg.TurnQi > 0)
				::Wuxia.CombatRules.restoreQi(actor, tcfg.TurnQi);
			if (("TurnHP" in tcfg) && tcfg.TurnHP > 0 && actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + tcfg.TurnHP));
			if (("TurnBodyArmor" in tcfg) && tcfg.TurnBodyArmor > 0 && body != null && ::Wuxia.hasMember(body, "getArmor") && body.getArmor() < body.getArmorMax())
				body.setArmor(::Math.min(body.getArmorMax(), body.getArmor() + tcfg.TurnBodyArmor));
			if (("TurnShield" in tcfg) && tcfg.TurnShield > 0 && shd != null && ::Wuxia.hasMember(shd.m, "Condition") && shd.m.Condition > 0 && shd.m.Condition < shd.m.ConditionMax)
			{
				shd.m.Condition = ::Math.min(shd.m.ConditionMax, shd.m.Condition + tcfg.TurnShield);
				if (::Wuxia.hasMember(shd, "updateAppearance")) shd.updateAppearance();
			}
		}
	}

	function onTurnEnd()
	{
		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();
		if (actor == null || !actor.isAlive()) return;

		local ev = this.getEval();
		this.m.CachedEval = ev;
		if (this.hasTier("wx_set_kunlun", 3) && ::Wuxia.hasMember(actor, "isPlacedOnMap") && actor.isPlacedOnMap() && actor.getTile() != null)
		{
			if (this.m.StartTileID != -1 && actor.getTile().ID == this.m.StartTileID)
				this.m.HasKunlunWard = true;
		}
	}

	function onUpdate( _properties )
	{
		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();
		local ev = this.getEval();
		this.m.CachedEval = ev;

		if (ev == null || (ev.ActiveSets.len() == 0 && ev.ActiveTotems.len() == 0))
		{
			this.m.IsHidden = true;
			return;
		}

		this.m.IsHidden = false;
		if (ev.ActiveSets.len() > 0)
		{
			local primary = ::Wuxia.Config.ShanHaiSets[ev.ActiveSets[0].SetID];
			this.m.Icon = primary.Icon;
			if (ev.ActiveSets.len() == 1)
				this.m.Name = "山海共鸣 · " + primary.ShortName + "（" + ev.ActiveSets[0].Count + "件）";
			else
				this.m.Name = "山海多重共鸣（" + ev.ActiveSets.len() + "套已激活）";
		}
		else
		{
			local firstT = ::Wuxia.Config.ShanHaiTotemPairs[ev.ActiveTotems[0]];
			this.m.Icon = "ui/perks/wx_shanhai_boss_trait.png";
			this.m.Name = firstT.Title;
		}

		// 2. 苍龙雷泽套 3 件：免疫击退抓取与震晕，自身定力 +8
		if (this.hasTier("wx_set_canglong", 3))
		{
			_properties.IsImmuneToKnockBackAndGrab = true;
			_properties.IsImmuneToStun = true;
			_properties.Bravery += 8;
		}

		// 3. 大荒金乌套 3 件：抗惊骇检定定力 +20
		if (this.hasTier("wx_set_jinwu", 3))
		{
			if (("MoraleCheckBravery" in _properties) && typeof _properties.MoraleCheckBravery == "array" && _properties.MoraleCheckBravery.len() > 0)
				_properties.MoraleCheckBravery[0] += 20;
		}

		// 4. 幽冥相柳套 2 件：百毒不侵
		if (this.hasTier("wx_set_xiangliu", 2))
		{
			_properties.IsImmuneToPoison = true;
			if (cont != null && cont.hasSkill("effects.wx_status_poison_dart"))
				cont.removeByID("effects.wx_status_poison_dart");
		}

		// 5. 昆仑瑞兽套 2 件：头身甲总负重惩罚减轻 15%（返还内息上限与身法）
		if (this.hasTier("wx_set_kunlun", 2) && actor != null)
		{
			local pen = ::Wuxia.CombatRules.getArmorStaminaPenalty(actor);
			local refund = ::Math.floor(pen * 0.15);
			if (refund > 0)
			{
				_properties.Stamina += refund;
				_properties.Initiative += refund;
			}
		}

		// 6. 青丘风翎套 2/3 件：视野 +1，3 件夜战视物如昼
		if (this.hasTier("wx_set_qingqiu", 2))
			_properties.Vision += 1;
		if (this.hasTier("wx_set_qingqiu", 3) && ("IsAffectedByNight" in _properties))
			_properties.IsAffectedByNight = false;

		// 8. 百工猎妖录 2 件：抗惊骇检定定力 +10
		if (this.hasTier("wx_set_baigong", 2))
		{
			if (("MoraleCheckBravery" in _properties) && typeof _properties.MoraleCheckBravery == "array" && _properties.MoraleCheckBravery.len() > 0)
				_properties.MoraleCheckBravery[0] += 10;
		}

		// 11 组同源【本命真魂】常驻气魄与小彩蛋加成
		foreach (tid in ev.ActiveTotems)
		{
			local tcfg = ::Wuxia.Config.ShanHaiTotemPairs[tid];
			if ("Bravery" in tcfg) _properties.Bravery += tcfg.Bravery;
			if ("Initiative" in tcfg) _properties.Initiative += tcfg.Initiative;
			if ("Vision" in tcfg) _properties.Vision += tcfg.Vision;
			if ("InjuryMult" in tcfg) _properties.ThresholdToReceiveInjuryMult *= tcfg.InjuryMult;
		}
	}

	function onAfterUpdate( _properties )
	{
		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();
		if (actor == null) return;

		// 苍龙雷泽套 3 件友军定力光环（若自身未穿苍龙 3 件，受周身 2 格内穿戴苍龙 3 件的同袍庇护，定力 +8，不叠加）
		if (!this.hasTier("wx_set_canglong", 3) && ("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive()
			&& ::Wuxia.hasMember(actor, "isPlacedOnMap") && actor.isPlacedOnMap() && actor.getTile() != null)
		{
			local myTile = actor.getTile();
			local allies = ::Tactical.Entities.getInstancesOfFaction(actor.getFaction());
			foreach (ally in allies)
			{
				if (ally == null || ally.getID() == actor.getID() || !ally.isAlive() || !ally.isPlacedOnMap()) continue;
				if (ally.getMoraleState() == ::Const.MoraleState.Fleeing) continue;
				if (myTile.getDistanceTo(ally.getTile()) <= 2 && ::Wuxia.ShanHaiSets.hasActiveTier(ally, "wx_set_canglong", 3))
				{
					_properties.Bravery += 8;
					break;
				}
			}
		}
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == null || !_skill.isAttack() || _targetEntity == null) return;
		local ev = this.m.CachedEval != null ? this.m.CachedEval : this.getEval();
		if (ev == null) return;

		// 1. 兵主凶煞套 3 件：对总护甲高于 50% 的目标破甲伤害 +15%
		if (this.hasTier("wx_set_bingzhu", 3) && ::Wuxia.hasMember(_targetEntity, "getArmor") && ::Wuxia.hasMember(_targetEntity, "getArmorMax"))
		{
			local curA = _targetEntity.getArmor(::Const.BodyPart.Body) + _targetEntity.getArmor(::Const.BodyPart.Head);
			local maxA = _targetEntity.getArmorMax(::Const.BodyPart.Body) + _targetEntity.getArmorMax(::Const.BodyPart.Head);
			if (maxA > 0 && curA * 2 >= maxA)
				_properties.DamageArmorMult *= 1.15;
		}

		// 3. 大荒金乌套 2 件：攻击流血/中毒/散功目标额外穿甲 +10%（严守 AGENTS.md §4.1 全身额外穿甲 +25% 硬封顶！）
		if (this.hasTier("wx_set_jinwu", 2) && ::Wuxia.hasMember(_targetEntity, "getSkills") && _targetEntity.getSkills() != null)
		{
			local tsk = _targetEntity.getSkills();
			local hasAffliction = tsk.hasSkill("effects.bleeding")
				|| tsk.hasSkill("effects.wx_status_poison_dart")
				|| tsk.hasSkill("effects.spider_poison")
				|| tsk.hasSkill("effects.goblin_poison")
				|| tsk.hasSkill("effects.wx_scatter_weakness");
			if (hasAffliction)
			{
				local cont = this.getContainer();
				local actor = cont == null ? null : cont.getActor();
				local mc = cont == null ? null : cont.getSkillByID("special.wx_martial_container");
				local usedPen = 0.0;
				if (mc != null && mc.m.CachedAggFlags != null)
				{
					usedPen = mc.m.CachedAggFlags.DirectDmgBonus;
					if (mc.m.CachedAggFlags.EmptyOffhandPen > 0.0 && ::Wuxia.CombatRules.hasSingleHandEmptyOffhand(actor))
						usedPen = ::Math.minf(0.25, usedPen + mc.m.CachedAggFlags.EmptyOffhandPen);
				}
				local addPen = ::Math.maxf(0.0, ::Math.minf(0.10, 0.25 - usedPen));
				if (addPen > 0.0)
					_properties.DamageDirectAdd += addPen;
			}
		}

		// 8. 百工猎妖录 2 件：迎战山泽异兽与山海首领攻击总伤 +10%
		if (this.hasTier("wx_set_baigong", 2) && ::Wuxia.ShanHaiSets.isBeastOrShanHaiTarget(_targetEntity))
		{
			_properties.DamageTotalMult *= 1.10;
		}
	}

	function onBeforeDamageReceived( _attacker, _skill, _hitInfo, _properties )
	{
		local ev = this.m.CachedEval != null ? this.m.CachedEval : this.getEval();
		if (ev == null) return;

		// 5. 昆仑瑞兽套 2 件：铜头铁额免疫头部额外暴击倍率
		if (this.hasTier("wx_set_kunlun", 2) && _hitInfo != null && ("BodyPart" in _hitInfo) && _hitInfo.BodyPart == ::Const.BodyPart.Head)
		{
			if (("BodyDamageMult" in _hitInfo) && _hitInfo.BodyDamageMult > 1.0)
				_hitInfo.BodyDamageMult = 1.0;
		}

		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();

		// 5. 昆仑瑞兽套 3 件：【玄龟护体】首次受击气血实伤 -25%（严守 AGENTS.md §3.1 实伤减免 60% 硬上限 -> >= 0.40）并修复 8 身甲
		if (this.m.HasKunlunWard && this.hasTier("wx_set_kunlun", 3) && _hitInfo != null && _hitInfo.DamageRegular > 0)
		{
			this.m.HasKunlunWard = false;
			_properties.DamageReceivedRegularMult = ::Math.maxf(0.40, _properties.DamageReceivedRegularMult * 0.75);
			if (actor != null && ::Wuxia.hasMember(actor, "getItems") && actor.getItems() != null)
			{
				local body = actor.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (body != null && ::Wuxia.hasMember(body, "getArmor") && body.getArmor() < body.getArmorMax())
					body.setArmor(::Math.min(body.getArmorMax(), body.getArmor() + 8));
			}
			if (actor != null && ("VFX" in ::Wuxia))
				::Wuxia.VFX.playTriggerVfx(actor, "wx_vfx_17", "wx_fx_golden_bell", 0, 0, 1.04);
		}

		// 本命真魂·流波夔牛：受近战攻击反震攻击者 4 点内息
		if (_attacker != null && actor != null && _attacker.getID() != actor.getID() && _attacker.isAlive() && _skill != null && !_skill.isRanged())
		{
			foreach (tid in ev.ActiveTotems)
			{
				local tcfg = ::Wuxia.Config.ShanHaiTotemPairs[tid];
				if (("ThornsQi" in tcfg) && tcfg.ThornsQi > 0 && !::Wuxia.CombatRules.isUndeadOrConstruct(_attacker) && ::Wuxia.hasMember(_attacker, "getFatigue"))
					_attacker.setFatigue(::Math.min(_attacker.getFatigueMax(), _attacker.getFatigue() + tcfg.ThornsQi));
			}
		}
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		if (_skill == null || !_skill.isAttack()) return;
		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();
		if (actor == null || _targetEntity == null || !_targetEntity.isAlive() || actor.isAlliedWith(_targetEntity))
			return;

		local ev = this.m.CachedEval != null ? this.m.CachedEval : this.getEval();
		if (ev == null) return;

		local tsk = (::Wuxia.hasMember(_targetEntity, "getSkills")) ? _targetEntity.getSkills() : null;
		local tItems = (::Wuxia.hasMember(_targetEntity, "getItems")) ? _targetEntity.getItems() : null;
		local tBody = tItems == null ? null : tItems.getItemAtSlot(::Const.ItemSlot.Body);
		local tHead = tItems == null ? null : tItems.getItemAtSlot(::Const.ItemSlot.Head);

		// 1. 兵主凶煞套 3 件：首记近战重击震慑敌胆
		if (this.hasTier("wx_set_bingzhu", 3) && !this.m.BingzhuDreadUsedThisBattle && !_skill.isRanged()
			&& (_damageInflictedHitpoints >= 12 || _damageInflictedArmor >= 25))
		{
			this.m.BingzhuDreadUsedThisBattle = true;
			this.wxApplyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ::Wuxia.hasMember(_targetEntity, "checkMorale"))
				_targetEntity.checkMorale(-1, -15);
		}

		// 2. 苍龙雷泽套 2 件：每回合首击苍龙惊雷（8 点破甲 + 8 点无视护甲雷震实伤）
		if (this.hasTier("wx_set_canglong", 2) && !this.m.CanglongStrikeUsedThisTurn)
		{
			this.m.CanglongStrikeUsedThisTurn = true;
			if (tBody != null && ::Wuxia.hasMember(tBody, "getArmor") && tBody.getArmor() > 0)
				tBody.setArmor(::Math.max(0, tBody.getArmor() - 8));
			if (_targetEntity.getHitpoints() > 1)
				_targetEntity.setHitpoints(::Math.max(1, _targetEntity.getHitpoints() - 8));
			if ("VFX" in ::Wuxia)
				::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_12", "wx_fx_lightning_strike", 0, 0, 1.05);
		}

		// 3. 大荒金乌套 3 件：十日焚邪 — 对尸傀/古墓机关/山海首领额外灼伤 12 身甲与 12 气血
		if (this.hasTier("wx_set_jinwu", 3))
		{
			local isEvilOrBoss = ::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity)
				|| (tsk != null && tsk.hasSkill("special.wx_shanhai_boss_trait"));
			if (isEvilOrBoss)
			{
				if (tBody != null && ::Wuxia.hasMember(tBody, "getArmor") && tBody.getArmor() > 0)
					tBody.setArmor(::Math.max(0, tBody.getArmor() - 12));
				if (_targetEntity.getHitpoints() > 1)
					_targetEntity.setHitpoints(::Math.max(1, _targetEntity.getHitpoints() - 12));
				if ("VFX" in ::Wuxia)
					::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_06", "wx_fx_fire_slash", 0, 0, 1.04);
			}
		}

		// 4. 幽冥相柳套 2/3 件：九首蚀脉 & 万毒蚀甲
		if (this.hasTier("wx_set_xiangliu", 2) && tsk != null && _damageInflictedHitpoints >= 4 && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity))
		{
			local alreadyPoisoned = tsk.hasSkill("effects.wx_status_poison_dart") || tsk.hasSkill("effects.spider_poison") || tsk.hasSkill("effects.goblin_poison");
			if (alreadyPoisoned)
			{
				this.wxApplyStatusSafe(tsk, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart");
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ::Wuxia.hasMember(_targetEntity, "getFatigue"))
					_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + 6));
			}
			else if (::Math.rand(1, 100) <= 45)
			{
				this.wxApplyStatusSafe(tsk, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart");
			}
		}
		if (this.hasTier("wx_set_xiangliu", 3) && tsk != null && this.wxCountNegativeStatuses(tsk) >= 2)
		{
			if (tBody != null && ::Wuxia.hasMember(tBody, "getArmor") && tBody.getArmor() > 0)
				tBody.setArmor(::Math.max(0, tBody.getArmor() - 15));
			if (tHead != null && ::Wuxia.hasMember(tHead, "getArmor") && tHead.getArmor() > 0)
				tHead.setArmor(::Math.max(0, tHead.getArmor() - 10));
		}

		// 6. 青丘风翎套 3 件：高地或距离 ≥4 格命中附加失衡并 50% 震露破绽
		if (this.hasTier("wx_set_qingqiu", 3) && tsk != null && ::Wuxia.hasMember(actor, "isPlacedOnMap") && actor.isPlacedOnMap()
			&& ::Wuxia.hasMember(_targetEntity, "isPlacedOnMap") && _targetEntity.isPlacedOnMap())
		{
			local myT = actor.getTile();
			local tgT = _targetEntity.getTile();
			if (myT != null && tgT != null && (myT.Level > tgT.Level || myT.getDistanceTo(tgT) >= 4))
			{
				this.wxApplyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
				if (::Math.rand(1, 100) <= 50)
					this.wxApplyStatusSafe(tsk, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			}
		}

		// 7. 北溟寒渊套 2/3 件：寒渊凝脉 & 弱水封穴
		if (this.hasTier("wx_set_beiming", 2) && tsk != null && this.m.BeimingQiThisTurn < 2)
		{
			local hasCC = tsk.hasSkill("effects.wx_status_offbalance")
				|| tsk.hasSkill("effects.wx_status_opening")
				|| tsk.hasSkill("effects.wx_status_acupoint")
				|| tsk.hasSkill("effects.wx_status_frost_chill")
				|| tsk.hasSkill("effects.chilled")
				|| tsk.hasSkill("effects.stunned")
				|| tsk.hasSkill("effects.dazed");
			if (hasCC)
			{
				this.m.BeimingQiThisTurn += 1;
				::Wuxia.CombatRules.restoreQi(actor, 5);
			}
		}
		if (this.hasTier("wx_set_beiming", 3) && tsk != null && this.m.BeimingChillUsedThisBattle < 2
			&& (_damageInflictedHitpoints >= 10 || _damageInflictedArmor >= 22))
		{
			this.m.BeimingChillUsedThisBattle += 1;
			this.wxApplyStatusSafe(tsk, "effects.wx_status_frost_chill", "scripts/skills/effects/wx_status_frost_chill");
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ::Wuxia.hasMember(_targetEntity, "getFatigue"))
				_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + 8));
			if ("VFX" in ::Wuxia)
				::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_21", "wx_fx_ice_spikes", 0, 0, 1.04);
		}

		// 同源双件【本命真魂】命中灼甲与碎盾彩蛋
		foreach (tid in ev.ActiveTotems)
		{
			local tcfg = ::Wuxia.Config.ShanHaiTotemPairs[tid];
			if (("OnHitArmor" in tcfg) && tcfg.OnHitArmor > 0 && tBody != null && ::Wuxia.hasMember(tBody, "getArmor") && tBody.getArmor() > 0)
				tBody.setArmor(::Math.max(0, tBody.getArmor() - tcfg.OnHitArmor));
			if (!_skill.isRanged() && ("ShieldBreak" in tcfg) && tcfg.ShieldBreak > 0 && ::Wuxia.hasMember(_targetEntity, "isArmedWithShield") && _targetEntity.isArmedWithShield())
			{
				local sh = tItems == null ? null : tItems.getItemAtSlot(::Const.ItemSlot.Offhand);
				if (sh != null && ::Wuxia.hasMember(sh, "applyShieldDamage"))
					sh.applyShieldDamage(tcfg.ShieldBreak);
			}
		}
	}

	function onTargetKilled( _targetEntity, _skill )
	{
		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();
		if (actor == null || !actor.isAlive()) return;

		// 1. 兵主凶煞套 2 件：凶煞噬血 — 斩敌回 8 内息 + 活物回 6 气血（每回合限 1 次）
		if (this.hasTier("wx_set_bingzhu", 2) && !this.m.BingzhuKillUsedThisTurn)
		{
			this.m.BingzhuKillUsedThisTurn = true;
			::Wuxia.CombatRules.restoreQi(actor, 8);
			if ((_targetEntity == null || !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity)) && actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + 6));
		}
	}
});
