// Shared Composable Equipment Passive Skill (`名器器灵` · `百工兽魄` · `山海神通` · `兵刃铭配` · `炉火淬引`)
// Attached dynamically by Relic/Beast/Shan-Hai weapons, shields, armors & helmets in `onEquip()`,
// and automatically removed by Battle Brothers' native `item.onUnequip()`!

this.wx_gear_spirit_trait <- this.inherit("scripts/skills/skill", {
	m = {
		TraitID            = "",
		KillHealsThisTurn  = 0,
		SelfQiThisTurn     = 0,
		DrainHpThisTurn    = 0,
		ModStacksThisTurn  = 0,
		ModQiThisTurn      = 0,
		QuenchHealTurn     = 0,
		PhaseUsedThisTurn  = false,
		MissQiThisTurn     = 0,
		LastHitTargetID    = -1,
		NextRoundInitBonus = 0,
		ActiveInitBonus    = 0,
		BattleSwingsUsed   = 0,
		RallyUsedBattle    = 0,
		AmmoRefundBattle   = 0,
		FirstHitTargets    = null,
		IsIntercepting     = false,
		XunleiHitsThisTurn = 0,
		XunleiSmokeActive  = false,
		DefStanceThisTurn  = 0,
		BaizeRiposteReady  = false,
		BattleSaveUsed     = false,
		DangkangBoostDone  = false
	},

	function create()
	{
		this.m.ID = "special.wx_gear_spirit_trait";
		this.m.Name = "兵甲灵蕴";
		this.m.Description = "传世名器、异兽奇材与山海内丹淬入兵甲所凝的本命神通。";
		this.m.Icon = "ui/perks/wx_shanhai_boss_trait.png";
		this.m.Type = this.Const.SkillType.Special;
		this.m.Order = this.Const.SkillOrder.Trait;
		this.m.IsActive = false;
		this.m.IsStacking = true;
		this.m.IsHidden = true;
		this.m.IsSerialized = false;
	}

	function setTraitID( _traitID )
	{
		this.m.TraitID = (_traitID != null) ? _traitID : "";
		local cfg = this.getTraitCfg();
		if (cfg != null)
		{
			this.m.Name = cfg.Title;
			this.m.Description = cfg.Text;
		}
	}

	function setTrait( _traitID, _itemName = null, _item = null )
	{
		this.setTraitID(_traitID);
		this.m.DirectItemRef <- _item;
		if (_item != null)
			this.setItem(_item);
	}

	function getTraitCfg()
	{
		if (this.m.TraitID != "" && "GearTraits" in ::Wuxia.Config && (this.m.TraitID in ::Wuxia.Config.GearTraits))
			return ::Wuxia.Config.GearTraits[this.m.TraitID];
		return null;
	}

	function getAttachedWeaponModID()
	{
		local it = ("DirectItemRef" in this.m && this.m.DirectItemRef != null) ? this.m.DirectItemRef : this.getItem();
		if (it != null && ::Wuxia.hasMember(it, "m") && it.m != null && ("WX_WeaponModID" in it.m) && it.m.WX_WeaponModID != null)
			return it.m.WX_WeaponModID;
		return "";
	}

	function getAttachedQuenchID()
	{
		local it = ("DirectItemRef" in this.m && this.m.DirectItemRef != null) ? this.m.DirectItemRef : this.getItem();
		if (it != null && ::Wuxia.hasMember(it, "m") && it.m != null && ("WX_QuenchID" in it.m) && it.m.WX_QuenchID != null)
			return it.m.WX_QuenchID;
		return "none";
	}

	function getAttachedArmorUpgID()
	{
		local it = ("DirectItemRef" in this.m && this.m.DirectItemRef != null) ? this.m.DirectItemRef : this.getItem();
		if (it != null && ::Wuxia.hasMember(it, "getUpgrade") && it.getUpgrade() != null)
		{
			local upg = it.getUpgrade();
			if (("m" in upg) && upg.m != null && ("WX_UpgCfgID" in upg.m) && upg.m.WX_UpgCfgID != null)
				return upg.m.WX_UpgCfgID;
		}
		return "";
	}

	function isMasterworkGear()
	{
		local it = this.getItem();
		return (it != null && ::Wuxia.hasMember(it, "m") && ("WX_ForgeGrade" in it.m) && it.m.WX_ForgeGrade >= 3);
	}

	function wxGetCurrentRound()
	{
		if (("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive()
			&& ("TurnSequenceBar" in ::Tactical) && ::Tactical.TurnSequenceBar != null)
		{
			return ::Tactical.TurnSequenceBar.getCurrentRound();
		}
		return 1;
	}

	function wxApplyStatusSafe( _tsk, _effectID, _scriptPath )
	{
		if (_tsk == null) return;
		local ex = _tsk.getSkillByID(_effectID);
		if (ex == null) _tsk.add(::new(_scriptPath));
		else if (::Wuxia.hasMember(ex, "resetDuration")) ex.resetDuration();
	}

	function wxIsTargetControlled( _tsk )
	{
		if (_tsk == null) return false;
		return _tsk.hasSkill("effects.wx_status_opening")
			|| _tsk.hasSkill("effects.wx_status_offbalance")
			|| _tsk.hasSkill("effects.wx_status_acupoint")
			|| _tsk.hasSkill("effects.stunned")
			|| _tsk.hasSkill("effects.dazed")
			|| _tsk.hasSkill("effects.net")
			|| _tsk.hasSkill("effects.rooted")
			|| _tsk.hasSkill("effects.web");
	}

	function wxGetTargetBodyArmor( _target, _tItems )
	{
		if (_tItems != null && _tItems.getItemAtSlot(::Const.ItemSlot.Body) != null)
		{
			local b = _tItems.getItemAtSlot(::Const.ItemSlot.Body);
			if (::Wuxia.hasMember(b, "getArmor")) return b.getArmor();
		}
		if (_target != null && ::Wuxia.hasMember(_target, "getArmor"))
			return _target.getArmor(::Const.BodyPart.Body);
		return 0;
	}

	function wxFindAdjacentEnemy( _actor, _centerEntity )
	{
		if (_actor == null || _centerEntity == null || !::Wuxia.hasMember(_centerEntity, "isPlacedOnMap") || !_centerEntity.isPlacedOnMap())
			return null;
		local tTile = _centerEntity.getTile();
		if (tTile == null || !::Wuxia.hasMember(tTile, "hasNextTile")) return null;
		for (local d = 0; d < 6; d = ++d)
		{
			if (!tTile.hasNextTile(d)) continue;
			local adjT = tTile.getNextTile(d);
			if (adjT != null && ::Wuxia.isTileOccupiedByActor(adjT) && adjT.getEntity() != null)
			{
				local ent = adjT.getEntity();
				if (ent.getID() != _centerEntity.getID() && ent.isAlive() && !_actor.isAlliedWith(ent))
					return ent;
			}
		}
		return null;
	}

	function wxTryKnockbackOrCrush( _actor, _target, _crushArmor, _crushQi )
	{
		local pushed = false;
		if (_actor != null && _target != null && ::Wuxia.hasMember(_actor, "isPlacedOnMap") && _actor.isPlacedOnMap()
			&& ::Wuxia.hasMember(_target, "isPlacedOnMap") && _target.isPlacedOnMap()
			&& ("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive())
		{
			local cp = ::Wuxia.hasMember(_target, "getCurrentProperties") ? _target.getCurrentProperties() : null;
			local immuneKb = (cp != null && ("IsImmuneToKnockBackAndGrab" in cp) && cp.IsImmuneToKnockBackAndGrab);
			local myT = _actor.getTile();
			local tgT = _target.getTile();
			if (!immuneKb && myT != null && tgT != null && ::Wuxia.hasMember(myT, "getDirectionTo") && ::Wuxia.hasMember(tgT, "hasNextTile"))
			{
				local dir = myT.getDirectionTo(tgT);
				if (tgT.hasNextTile(dir))
				{
					local dst = tgT.getNextTile(dir);
					if (dst != null && dst.IsEmpty && ::Math.abs(dst.Level - tgT.Level) <= 1)
					{
						try
						{
							::Tactical.getNavigator().teleport(_target, dst, null, null, true);
							pushed = true;
						}
						catch (_kbErr) { pushed = false; }
					}
				}
			}
		}
		if (!pushed && _target != null)
		{
			if (_crushArmor > 0 && ::Wuxia.hasMember(_target, "getItems") && _target.getItems() != null)
			{
				local b = _target.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (b != null && ::Wuxia.hasMember(b, "getArmor") && b.getArmor() > 0)
					b.setArmor(::Math.max(0, b.getArmor() - _crushArmor));
			}
			if (_crushQi > 0 && !::Wuxia.CombatRules.isUndeadOrConstruct(_target) && ::Wuxia.hasMember(_target, "getFatigue"))
				_target.setFatigue(::Math.min(_target.getFatigueMax(), _target.getFatigue() + _crushQi));
		}
		return pushed;
	}

	function wxRallyNearbyAllies( _actor )
	{
		if (this.m.RallyUsedBattle >= 2 || _actor == null) return;
		if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()
			|| !::Wuxia.hasMember(_actor, "isPlacedOnMap") || !_actor.isPlacedOnMap() || _actor.getTile() == null)
			return;
		local myT = _actor.getTile();
		local allies = ::Tactical.Entities.getInstancesOfFaction(_actor.getFaction());
		local rallied = false;
		foreach (al in allies)
		{
			if (al == null || !al.isAlive() || !al.isPlacedOnMap() || al.getTile() == null) continue;
			if (myT.getDistanceTo(al.getTile()) <= 2 && ::Wuxia.hasMember(al, "getMoraleState")
				&& (al.getMoraleState() == ::Const.MoraleState.Wavering || al.getMoraleState() == ::Const.MoraleState.Breaking))
			{
				al.setMoraleState(::Const.MoraleState.Steady);
				rallied = true;
			}
		}
		if (rallied) this.m.RallyUsedBattle += 1;
	}

	function onCombatStarted()
	{
		this.m.BattleSwingsUsed   = 0;
		this.m.RallyUsedBattle    = 0;
		this.m.AmmoRefundBattle   = 0;
		this.m.NextRoundInitBonus = 0;
		this.m.ActiveInitBonus    = 0;
		this.m.FirstHitTargets    = {};
		this.m.PhaseUsedThisTurn  = false;
		this.m.XunleiHitsThisTurn = 0;
		this.m.XunleiSmokeActive  = false;
		this.m.DefStanceThisTurn  = 0;
		this.m.BaizeRiposteReady  = false;
		this.m.BattleSaveUsed     = false;
		this.m.DangkangBoostDone  = false;

		local cfg = this.getTraitCfg();
		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();
		if (cfg != null && actor != null && actor.isAlive())
		{
			local sm = ("ShanHaiMode" in cfg) ? cfg.ShanHaiMode : "";
			if (sm == "acc_baize" && ::Wuxia.hasMember(actor, "m") && actor.m != null)
			{
				local curM = ("WX_TihuMasteryMult" in actor.m) ? actor.m.WX_TihuMasteryMult : 1.0;
				actor.m.WX_TihuMasteryMult <- (curM + 0.15);
			}
			else if (sm == "acc_dangkang" && !this.m.DangkangBoostDone && ::Wuxia.hasMember(actor, "getMoraleState")
				&& actor.getMoraleState() != ::Const.MoraleState.Ignore && actor.getMoraleState() < ::Const.MoraleState.Confident)
			{
				this.m.DangkangBoostDone = true;
				actor.setMoraleState(::Math.min(::Const.MoraleState.Confident, actor.getMoraleState() + 1));
			}
		}
	}

	function onCombatFinished()
	{
		this.m.BattleSwingsUsed   = 0;
		this.m.RallyUsedBattle    = 0;
		this.m.AmmoRefundBattle   = 0;
		this.m.NextRoundInitBonus = 0;
		this.m.ActiveInitBonus    = 0;
		this.m.FirstHitTargets    = null;
		this.m.PhaseUsedThisTurn  = false;
		this.m.XunleiHitsThisTurn = 0;
		this.m.XunleiSmokeActive  = false;
		this.m.DefStanceThisTurn  = 0;
		this.m.BaizeRiposteReady  = false;
		this.m.BattleSaveUsed     = false;
		this.m.DangkangBoostDone  = false;
	}

	function onTurnStart()
	{
		this.m.KillHealsThisTurn = 0;
		this.m.SelfQiThisTurn    = 0;
		this.m.DrainHpThisTurn   = 0;
		this.m.ModStacksThisTurn = 0;
		this.m.ModQiThisTurn     = 0;
		this.m.QuenchHealTurn    = 0;
		this.m.PhaseUsedThisTurn = false;
		this.m.MissQiThisTurn    = 0;
		this.m.LastHitTargetID   = -1;
		this.m.XunleiHitsThisTurn = 0;
		this.m.XunleiSmokeActive  = false;
		this.m.DefStanceThisTurn  = 0;
		this.m.ActiveInitBonus   = this.m.NextRoundInitBonus;
		this.m.NextRoundInitBonus = 0;

		local cfg = this.getTraitCfg();
		local qid = this.getAttachedQuenchID();
		local upg = this.getAttachedArmorUpgID();
		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();
		if (actor == null || !actor.isAlive()) return;

		if (qid == "frost" && !::Wuxia.CombatRules.isUndeadOrConstruct(actor))
		{
			::Wuxia.CombatRules.restoreQi(actor, 1);
		}
		if (upg == "wx_up_chiling" && cont != null)
		{
			if (cont.hasSkill("effects.wx_status_frost_chill")) cont.removeByID("effects.wx_status_frost_chill");
			if (cont.hasSkill("effects.chilled")) cont.removeByID("effects.chilled");
		}
		else if (upg == "wx_up_gujing" && ("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.isActorInMiasmaOrSwamp(actor))
		{
			::Wuxia.CombatRules.restoreQi(actor, 2);
		}

		if (cfg == null) return;

		local bmode = ("BeastMode" in cfg) ? cfg.BeastMode : "";
		local smode = ("ShanHaiMode" in cfg) ? cfg.ShanHaiMode : "";

		if (bmode == "helm_ward" && cont != null)
		{
			foreach (mID in ["effects.charmed", "effects.sleeping"])
			{
				if (cont.hasSkill(mID)) cont.removeByID(mID);
			}
		}

		if (smode == "armor_jumang" && cont != null)
		{
			foreach (jID in ["effects.bleeding", "effects.web", "effects.rooted", "effects.net"])
			{
				if (cont.hasSkill(jID)) { cont.removeByID(jID); break; }
			}
		}
		else if (smode == "armor_bifang" && cont != null)
		{
			foreach (bfID in ["effects.wx_status_frost_chill", "effects.chilled", "effects.web"])
			{
				if (cont.hasSkill(bfID)) cont.removeByID(bfID);
			}
		}
		else if (smode == "helm_jinwu" && cont != null)
		{
			foreach (jwID in ["effects.charmed", "effects.sleeping", "effects.dazed"])
			{
				if (cont.hasSkill(jwID)) cont.removeByID(jwID);
			}
		}
		else if (smode == "shd_jumang" && cont != null)
		{
			foreach (sjID in ["effects.wx_status_poison_dart", "effects.spider_poison", "effects.goblin_poison", "effects.acid", "effects.lindwurm_acid"])
			{
				if (cont.hasSkill(sjID)) { cont.removeByID(sjID); break; }
			}
		}
		else if (smode == "acc_jiuwei" && !this.m.BattleSaveUsed && cont != null)
		{
			local inMindHex = cont.hasSkill("effects.charmed") || cont.hasSkill("effects.sleeping")
				|| (::Wuxia.hasMember(actor, "getMoraleState") && actor.getMoraleState() <= ::Const.MoraleState.Wavering && actor.getMoraleState() != ::Const.MoraleState.Ignore);
			if (inMindHex)
			{
				this.m.BattleSaveUsed = true;
				if (cont.hasSkill("effects.charmed")) cont.removeByID("effects.charmed");
				if (cont.hasSkill("effects.sleeping")) cont.removeByID("effects.sleeping");
				if (::Wuxia.hasMember(actor, "getMoraleState") && actor.getMoraleState() < ::Const.MoraleState.Steady && actor.getMoraleState() != ::Const.MoraleState.Ignore)
					actor.setMoraleState(::Const.MoraleState.Steady);
				::Wuxia.CombatRules.restoreQi(actor, 6);
			}
		}
		else if (smode == "acc_wuzhiqi" && ("CraftBridge" in ::Wuxia)
			&& (::Wuxia.CraftBridge.isWetOrConductiveEnv(actor, null) || ::Wuxia.CraftBridge.isActorInMiasmaOrSwamp(actor)))
		{
			::Wuxia.CombatRules.restoreQi(actor, 3);
		}
		else if (smode == "acc_hundun" && cont != null)
		{
			local clearedHd = false;
			foreach (hdID in ["effects.wx_status_acupoint", "effects.dazed"])
			{
				if (cont.hasSkill(hdID)) { cont.removeByID(hdID); clearedHd = true; }
			}
			if (clearedHd)
				::Wuxia.CombatRules.restoreQi(actor, 4);
		}
		else if (smode == "acc_chenghuang" && actor.getHitpointsMax() > 0)
		{
			if ((actor.getHitpoints().tofloat() / actor.getHitpointsMax().tofloat()) >= 0.70)
			{
				if (::Wuxia.hasMember(actor, "getItems") && actor.getItems() != null)
				{
					local chB = actor.getItems().getItemAtSlot(::Const.ItemSlot.Body);
					if (chB != null && ::Wuxia.hasMember(chB, "getArmor") && chB.getArmor() < chB.getArmorMax())
						chB.setArmor(::Math.min(chB.getArmorMax(), chB.getArmor() + 5));
				}
			}
			else if (actor.getHitpoints() < actor.getHitpointsMax())
			{
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + 5));
			}
		}

		if (("ImmuneAcidAndFireAura" in cfg) && cfg.ImmuneAcidAndFireAura && cont != null)
		{
			foreach (acidID in ["effects.acid", "effects.lindwurm_acid"])
			{
				if (cont.hasSkill(acidID)) cont.removeByID(acidID);
			}
		}

		if (("ZhuyinBladeCycle" in cfg) && cfg.ZhuyinBladeCycle && cont != null && (this.wxGetCurrentRound() % 2) == 0)
		{
			if (cont.hasSkill("effects.wx_status_frost_chill")) cont.removeByID("effects.wx_status_frost_chill");
			if (cont.hasSkill("effects.chilled")) cont.removeByID("effects.chilled");
		}

		local mwBonus = this.isMasterworkGear() ? 2 : 0;

		if (("TurnRegenHP" in cfg) && cfg.TurnRegenHP > 0 && actor.getHitpoints() < actor.getHitpointsMax())
		{
			actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + cfg.TurnRegenHP + (mwBonus > 0 ? 1 : 0)));
		}

		local items = (::Wuxia.hasMember(actor, "getItems")) ? actor.getItems() : null;
		if (items != null)
		{
			if (("TurnRegenBodyArmor" in cfg) && cfg.TurnRegenBodyArmor > 0)
			{
				local body = items.getItemAtSlot(::Const.ItemSlot.Body);
				if (body != null && (::Wuxia.hasMember(body, "getArmor")) && (::Wuxia.hasMember(body, "getArmorMax")) && body.getArmor() < body.getArmorMax())
				{
					body.setArmor(::Math.min(body.getArmorMax(), body.getArmor() + cfg.TurnRegenBodyArmor + mwBonus));
				}
			}
			if (("TurnRegenShield" in cfg) && cfg.TurnRegenShield > 0)
			{
				local shd = items.getItemAtSlot(::Const.ItemSlot.Offhand);
				if (shd != null && (::Wuxia.hasMember(shd.m, "Condition")) && (::Wuxia.hasMember(shd.m, "ConditionMax")) && shd.m.Condition > 0 && shd.m.Condition < shd.m.ConditionMax)
				{
					local shdGain = cfg.TurnRegenShield + mwBonus;
					if (("EcoDoubleShieldRegen" in cfg) && cfg.EcoDoubleShieldRegen && ::Wuxia.hasMember(actor, "isPlacedOnMap") && actor.isPlacedOnMap() && actor.getTile() != null)
					{
						local tl = actor.getTile();
						local isLush = ("Properties" in tl && tl.Properties != null && ("WX_PurifiedDew" in tl.Properties) && tl.Properties.WX_PurifiedDew)
							|| ("Type" in tl && (tl.Type == ::Const.Tactical.TerrainType.Forest || tl.Type == ::Const.Tactical.TerrainType.Swamp || tl.Type == ::Const.Tactical.TerrainType.Plains));
						if (isLush) shdGain = cfg.TurnRegenShield * 2 + mwBonus;
					}
					shd.m.Condition = ::Math.min(shd.m.ConditionMax, shd.m.Condition + shdGain);
					if (::Wuxia.hasMember(shd, "updateAppearance")) shd.updateAppearance();
				}
			}
		}
	}

	function onUpdate( _properties )
	{
		local cfg = this.getTraitCfg();
		local wmod = this.getAttachedWeaponModID();
		local qid  = this.getAttachedQuenchID();
		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();
		local round = this.wxGetCurrentRound();

		// 1. Inlaid Weapon Attachment (`兵刃铭配` 13 families) passive update
		if (wmod == "wx_wmod_sword_tassel")
		{
			_properties.MeleeSkill += 3;
			if (this.m.ModStacksThisTurn > 0)
				_properties.MeleeDefense += ::Math.min(4, this.m.ModStacksThisTurn * 2);
		}
		else if (wmod == "wx_wmod_staff_ferrule")
		{
			_properties.DamageReceivedArmorMult *= 0.90;
		}
		else if (wmod == "wx_wmod_cleaver_ring" && this.m.ModStacksThisTurn > 0)
		{
			_properties.IsImmuneToStun = true;
		}

		// 2. Quench Catalyst Affix (`炉火淬引`) passive update
		if (qid == "thunder" && round <= 1)
		{
			_properties.Initiative += 8;
		}
		else if (qid == "frost")
		{
			_properties.FatigueRecoveryRate += 1;
		}

		if (this.m.ActiveInitBonus > 0)
			_properties.Initiative += this.m.ActiveInitBonus;
		if (this.m.XunleiSmokeActive)
			_properties.RangedDefense += 8;
		if (this.m.DefStanceThisTurn > 0)
		{
			_properties.MeleeDefense += this.m.DefStanceThisTurn;
			_properties.RangedDefense += this.m.DefStanceThisTurn;
		}

		if (cfg == null) return;

		local bmode = ("BeastMode" in cfg) ? cfg.BeastMode : "";
		local smode = ("ShanHaiMode" in cfg) ? cfg.ShanHaiMode : "";
		if (bmode == "armor_swift" && ("MovementFatigueCostMult" in _properties))
			_properties.MovementFatigueCostMult *= 0.75;

		if (smode == "armor_chiyou")
		{
			if ("SurroundedDefense" in _properties) _properties.SurroundedDefense += 4;
			if ("IsImmuneToDaze" in _properties) _properties.IsImmuneToDaze = true;
		}
		else if (smode == "helm_kaiming" || smode == "acc_boshi")
		{
			if ("SurroundedDefense" in _properties) _properties.SurroundedDefense += 3;
		}
		else if (smode == "acc_jingwei" && actor != null && ::Wuxia.hasMember(actor, "getHitpointsMax") && actor.getHitpointsMax() > 0)
		{
			if ((actor.getHitpoints().tofloat() / actor.getHitpointsMax().tofloat()) < 0.55)
			{
				_properties.DamageArmorMult += 0.12;
				if ("CraftBridge" in ::Wuxia)
					::Wuxia.CraftBridge.multCappedRegularDamageReceived(_properties, 0.90);
			}
		}

		local rmode = ("RelicMode" in cfg) ? cfg.RelicMode : "";
		if (rmode == "longyuan")
		{
			local steadyStance = (cont == null) || (!cont.hasSkill("effects.wx_status_opening") && !cont.hasSkill("effects.wx_status_offbalance"));
			if (steadyStance) _properties.MeleeDefense += 4;
		}
		else if (rmode == "huntiegun")
		{
			if ("SurroundedDefense" in _properties)
				_properties.SurroundedDefense += 3;
		}
		else if (rmode == "shutongjian")
		{
			if ("ThresholdToInflictInjuryMult" in _properties)
				_properties.ThresholdToInflictInjuryMult *= 0.80;
		}

		// 3. Squad Paired Relic Resonance (`干将 × 莫邪 雌雄双剑共鸣`)
		if (("PartnerRelic" in cfg) && cfg.PartnerRelic != "" && actor != null && ("CraftBridge" in ::Wuxia))
		{
			local partner = ::Wuxia.CraftBridge.findSquadRelicPartner(actor, cfg.PartnerRelic, 4);
			if (partner != null && ("ResonanceMDef" in cfg))
			{
				_properties.MeleeDefense += cfg.ResonanceMDef;
			}
		}

		if ("Stats" in cfg)
		{
			foreach (stat, delta in cfg.Stats)
			{
				_properties[stat] += delta;
			}
		}

		if (("FirstRoundInit" in cfg) && cfg.FirstRoundInit > 0 && round <= 1)
		{
			_properties.Initiative += cfg.FirstRoundInit;
		}

		if ("RangedDmgMult" in cfg)
			_properties.DamageReceivedRangedMult *= cfg.RangedDmgMult;
		if ("ArmorDmgTakenMult" in cfg)
			_properties.DamageReceivedArmorMult *= cfg.ArmorDmgTakenMult;
		if ("ArmorDmgBonus" in cfg)
			_properties.DamageArmorMult += cfg.ArmorDmgBonus;
		if ("InjuryThresholdMult" in cfg)
			_properties.ThresholdToReceiveInjuryMult *= cfg.InjuryThresholdMult;
		if (("PoisonImmune" in cfg) && cfg.PoisonImmune)
			_properties.IsImmuneToPoison = true;
		if (("ImmuneKnockback" in cfg) && cfg.ImmuneKnockback)
			_properties.IsImmuneToKnockBackAndGrab = true;
		if (("NightOwl" in cfg) && cfg.NightOwl)
			_properties.IsAffectedByNight = false;
		if (("AntiFearBonus" in cfg) && cfg.AntiFearBonus > 0 && typeof _properties.MoraleCheckBravery == "array" && _properties.MoraleCheckBravery.len() > 0)
			_properties.MoraleCheckBravery[0] += cfg.AntiFearBonus;

		if (("LowHpThreshold" in cfg) && actor != null && (::Wuxia.hasMember(actor, "getHitpoints")) && (::Wuxia.hasMember(actor, "getHitpointsMax")) && actor.getHitpointsMax() > 0)
		{
			if ((actor.getHitpoints().tofloat() / actor.getHitpointsMax().tofloat()) < cfg.LowHpThreshold)
			{
				if ("LowHpDmgPct" in cfg) _properties.DamageTotalMult *= (1.0 + cfg.LowHpDmgPct);
				if ("LowHpResolve" in cfg) _properties.Bravery += cfg.LowHpResolve;
				if (("LowHpImmuneStun" in cfg) && cfg.LowHpImmuneStun) _properties.IsImmuneToStun = true;
			}
		}

		if (("CycleZhuyin" in cfg) && cfg.CycleZhuyin)
		{
			if ((round % 2) == 1)
			{
				_properties.MeleeDefense += 5;
				_properties.RangedDefense += 5;
				_properties.FatigueRecoveryRate += 3;
			}
			else
			{
				_properties.DamageTotalMult *= 1.10;
			}
		}

		if (("ZhuyinBladeCycle" in cfg) && cfg.ZhuyinBladeCycle)
		{
			if ((round % 2) == 1)
			{
				_properties.MeleeDefense += 4;
				_properties.RangedDefense += 4;
			}
			else
			{
				_properties.DamageTotalMult *= 1.12;
			}
		}
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == null || !_skill.isAttack() || (::Wuxia.hasMember(_skill, "m") && _skill.m != null && ::Wuxia.hasMember(_skill.m, "IsWeaponSkill") && !_skill.m.IsWeaponSkill))
			return;

		local cfg  = this.getTraitCfg();
		local wmod = this.getAttachedWeaponModID();
		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();
		local intercepting = this.m.IsIntercepting || (actor != null && ::Wuxia.hasMember(actor, "m") && actor.m != null && ("WX_IsIntercepting" in actor.m) && actor.m.WX_IsIntercepting);
		local tsk = (_targetEntity != null && ::Wuxia.hasMember(_targetEntity, "getSkills")) ? _targetEntity.getSkills() : null;
		local tItems = (_targetEntity != null && ::Wuxia.hasMember(_targetEntity, "getItems")) ? _targetEntity.getItems() : null;

		// 1. All 13 Weapon Attachments (`兵刃铭配`) pre-attack synergy
		if (wmod != "" && ("CraftBridge" in ::Wuxia))
		{
			if (wmod == "wx_wmod_saber_guard" && actor != null)
			{
				local hasPoise = (cont != null && cont.hasSkill("effects.wx_status_poise_charge"));
				if (hasPoise || ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "push_advance"))
					_properties.DamageArmorMult += 0.12;
			}
			else if (wmod == "wx_wmod_spear_tassel" && intercepting && !_skill.isRanged())
			{
				_properties.MeleeSkill += 6;
			}
			else if (wmod == "wx_wmod_polearm_hook" && tsk != null && tsk.hasSkill("effects.wx_status_offbalance"))
			{
				_properties.DamageTotalMult *= 1.08;
			}
			else if (wmod == "wx_wmod_axe_wedge" && _targetEntity != null && ::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
			{
				_properties.DamageTotalMult *= 1.12;
			}
			else if (wmod == "wx_wmod_dagger_groove" && !_skill.isRanged()
				&& (::Wuxia.CraftBridge.hasSkillMechanic(_skill, "detonate_opening") || (tsk != null && tsk.hasSkill("effects.wx_status_opening"))))
			{
				if ("HitChance" in _properties && typeof _properties.HitChance == "array" && _properties.HitChance.len() > ::Const.BodyPart.Head)
					_properties.HitChance[::Const.BodyPart.Head] += 8;
			}
			else if (wmod == "wx_wmod_bow_string" && _skill.isRanged())
			{
				if ("FatigueEffectMult" in _properties) _properties.FatigueEffectMult *= 0.88;
				if (actor != null && _targetEntity != null && ::Wuxia.hasMember(actor, "isPlacedOnMap") && actor.isPlacedOnMap()
					&& ::Wuxia.hasMember(_targetEntity, "isPlacedOnMap") && _targetEntity.isPlacedOnMap())
				{
					local myT = actor.getTile();
					local tgT = _targetEntity.getTile();
					if (myT != null && tgT != null && (myT.Level > tgT.Level || myT.getDistanceTo(tgT) >= 5))
						_properties.RangedSkill += 5;
				}
			}
			else if (wmod == "wx_wmod_mech_spring" && _skill.isRanged())
			{
				if ("FatigueEffectMult" in _properties) _properties.FatigueEffectMult *= 0.85;
			}
		}

		if (cfg == null) return;

		// 2. Overhauled Beast & Shan-Hai Environmental / Archetype Bonuses
		local bmode = ("BeastMode" in cfg) ? cfg.BeastMode : "";
		local smode = ("ShanHaiMode" in cfg) ? cfg.ShanHaiMode : "";
		if (bmode == "sword_venom" && !_skill.isRanged() && tsk != null
			&& (tsk.hasSkill("effects.wx_status_poison_dart") || tsk.hasSkill("effects.spider_poison") || tsk.hasSkill("effects.goblin_poison")))
		{
			_properties.MeleeSkill += 5;
		}
		else if (bmode == "bow_venom" && _skill.isRanged() && tsk != null
			&& (tsk.hasSkill("effects.web") || tsk.hasSkill("effects.net") || tsk.hasSkill("effects.rooted")))
		{
			_properties.DamageArmorMult += 0.20;
		}

		if (smode == "bo" && !_skill.isRanged() && _targetEntity != null)
		{
			if (this.wxGetTargetBodyArmor(_targetEntity, tItems) >= 100 || (("ShanHaiSets" in ::Wuxia) && ::Wuxia.ShanHaiSets.isBeastOrShanHaiTarget(_targetEntity)))
				_properties.MeleeSkill += 8;
		}
		else if (smode == "chiyou_wpn" && !_skill.isRanged() && actor != null
			&& ("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive()
			&& ::Wuxia.hasMember(actor, "isPlacedOnMap") && actor.isPlacedOnMap() && actor.getTile() != null)
		{
			local woundFoes = 0;
			local myTc = actor.getTile();
			foreach (entC in ::Tactical.Entities.getAllInstancesAsArray())
			{
				if (entC == null || !entC.isAlive() || !entC.isPlacedOnMap() || actor.isAlliedWith(entC)) continue;
				if (myTc.getDistanceTo(entC.getTile()) <= 2 && entC.getSkills() != null
					&& (entC.getSkills().hasSkill("effects.bleeding") || entC.getSkills().hasSkill("effects.wx_status_opening")))
				{
					woundFoes += 1;
				}
			}
			if (woundFoes > 0)
				_properties.MeleeSkill += ::Math.min(9, woundFoes * 3);
		}
		else if (smode == "hujiao" && !_skill.isRanged() && _targetEntity != null && ::Wuxia.hasMember(_targetEntity, "isArmedWithShield") && _targetEntity.isArmedWithShield())
		{
			_properties.MeleeSkill += 8;
		}
		else if (smode == "yingzhao" && _skill.isRanged() && actor != null)
		{
			local highOrMoved = (("ActionPoints" in actor.m) && ::Wuxia.hasMember(actor, "getActionPointsMax") && actor.getActionPoints() < actor.getActionPointsMax());
			if (!highOrMoved && _targetEntity != null && ::Wuxia.hasMember(actor, "isPlacedOnMap") && actor.isPlacedOnMap()
				&& ::Wuxia.hasMember(_targetEntity, "isPlacedOnMap") && _targetEntity.isPlacedOnMap())
			{
				highOrMoved = (actor.getTile().Level > _targetEntity.getTile().Level);
			}
			if (highOrMoved)
			{
				_properties.RangedSkill += 6;
				if ("FatigueEffectMult" in _properties) _properties.FatigueEffectMult *= 0.80;
			}
		}
		else if (smode == "armor_luwu" && !_skill.isRanged())
		{
			local isFistOrAoO = intercepting || _skill.getID().find("fist") != null || (("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "concuss_armor"));
			if (isFistOrAoO)
				_properties.DamageArmorMult += 0.15;
		}
		else if (smode == "armor_baize" && !_skill.isRanged() && this.m.BaizeRiposteReady)
		{
			_properties.MeleeSkill += 6;
		}
		else if ((smode == "helm_bashe" || smode == "acc_baize") && _targetEntity != null && ("ShanHaiSets" in ::Wuxia) && ::Wuxia.ShanHaiSets.isBeastOrShanHaiTarget(_targetEntity))
		{
			if (_skill.isRanged()) _properties.RangedSkill += 5;
			else _properties.MeleeSkill += 5;
		}
		else if (smode == "helm_jinwu" && _targetEntity != null && ::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
		{
			if (_skill.isRanged()) _properties.RangedSkill += 6;
			else _properties.MeleeSkill += 6;
		}
		else if (smode == "acc_fuzhu" && actor != null && ("CraftBridge" in ::Wuxia))
		{
			local ngF = ::Wuxia.CraftBridge.getActorNeigongProfile(actor);
			if ((ngF.MainElement == "yin" || ngF.MainElement == "neutral" || ngF.MainElement == "harmony") && ("FatigueEffectMult" in _properties))
				_properties.FatigueEffectMult *= 0.92;
		}
		else if (smode == "acc_xingxing" && _targetEntity != null && ::Wuxia.hasMember(_targetEntity, "getHitpoints") && ::Wuxia.hasMember(_targetEntity, "getHitpointsMax")
			&& _targetEntity.getHitpoints() < _targetEntity.getHitpointsMax())
		{
			if (_skill.isRanged()) _properties.RangedSkill += 4;
			else _properties.MeleeSkill += 4;
		}
		if (("SmokeSightHit" in cfg) && cfg.SmokeSightHit > 0 && ("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.isShadowOrSmokeEnv(actor, _targetEntity))
		{
			if (_skill.isRanged()) _properties.RangedSkill += cfg.SmokeSightHit;
			else _properties.MeleeSkill += cfg.SmokeSightHit;
		}
		if (("VsBeastDmgPct" in cfg) && _targetEntity != null && ("ShanHaiSets" in ::Wuxia) && ::Wuxia.ShanHaiSets.isBeastOrShanHaiTarget(_targetEntity))
		{
			_properties.DamageTotalMult *= (1.0 + cfg.VsBeastDmgPct);
		}
		if (("WetArmorBonus" in cfg) && ("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.isWetOrConductiveEnv(actor, _targetEntity))
		{
			_properties.DamageArmorMult += cfg.WetArmorBonus;
		}
		if (("JinwuSolarBonus" in cfg) && cfg.JinwuSolarBonus && _targetEntity != null)
		{
			local isEvil = ::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity);
			local onFire = false;
			if (::Wuxia.hasMember(_targetEntity, "isPlacedOnMap") && _targetEntity.isPlacedOnMap() && _targetEntity.getTile() != null)
			{
				local eff = ("Properties" in _targetEntity.getTile() && _targetEntity.getTile().Properties != null && ("Effect" in _targetEntity.getTile().Properties))
					? _targetEntity.getTile().Properties.Effect : null;
				if (eff != null && typeof eff == "table" && ("Type" in eff) && eff.Type != null && (eff.Type.find("fire") != null || eff.Type.find("scorch") != null))
					onFire = true;
			}
			if (isEvil || onFire)
				_properties.DamageTotalMult *= 1.12;
		}

		// 《承影细剑》暮色无影: Night / Smoke / Mirage shadow strike (+18 Hit & ignore target Dodge)
		if (("ChengyingMode" in cfg) && cfg.ChengyingMode && !_skill.isRanged() && ("CraftBridge" in ::Wuxia))
		{
			if (::Wuxia.CraftBridge.isShadowOrSmokeEnv(actor, _targetEntity))
			{
				_properties.MeleeSkill += 18;
				if (tsk != null)
				{
					local tInit = ::Wuxia.hasMember(_targetEntity, "getInitiative") ? ::Math.max(0, _targetEntity.getInitiative()) : 0;
					local dodgeBonus = tsk.hasSkill("effects.dodge") ? ::Math.floor(tInit * 0.15) : 0;
					local tMc = tsk.getSkillByID("special.wx_martial_container");
					if (tMc != null && tMc.m.CachedAggFlags != null)
						dodgeBonus += ::Math.floor(tInit * tMc.m.CachedAggFlags.InitToDefRatio);
					if (dodgeBonus > 0)
						_properties.MeleeSkill += dodgeBonus;
				}
			}
		}

		// 《应龙斩魔蓄水剑》沧海蓄水: Wet / Swamp / Snow / Purified-Dew conductive bonus
		if (("YinglongLightning" in cfg) && cfg.YinglongLightning && !_skill.isRanged() && ("CraftBridge" in ::Wuxia))
		{
			if (::Wuxia.CraftBridge.isWetOrConductiveEnv(actor, _targetEntity))
			{
				_properties.MeleeSkill += 6;
				if ("FatigueEffectMult" in _properties)
					_properties.FatigueEffectMult *= 0.85;
				if ("FatigueCostMult" in _properties)
					_properties.FatigueCostMult *= 0.85;
			}
		}

		if (!_skill.isRanged() && ("ZoCBonusHit" in cfg) && cfg.ZoCBonusHit > 0 && intercepting)
		{
			_properties.MeleeSkill += cfg.ZoCBonusHit;
		}

		// 3. All 37 Historical Famous Relic Weapon Spirits (`RelicMode`) pre-attack mechanics
		local rmode = ("RelicMode" in cfg) ? cfg.RelicMode : "";
		if (rmode != "")
		{
			local tArm = this.wxGetTargetBodyArmor(_targetEntity, tItems);
			local isShielded = (_targetEntity != null && ::Wuxia.hasMember(_targetEntity, "isArmedWithShield") && _targetEntity.isArmedWithShield());

			if (rmode == "taie" && _targetEntity != null && ::Wuxia.hasMember(_targetEntity, "getMoraleState") && _targetEntity.getMoraleState() <= ::Const.MoraleState.Wavering)
			{
				_properties.DamageArmorMult += 0.15;
				if (isShielded) _properties.MeleeSkill += 12;
			}
			else if (rmode == "longyuan" && ("CraftBridge" in ::Wuxia))
			{
				if (::Wuxia.CraftBridge.hasSkillMechanic(_skill, "step_through") || (cont != null && cont.hasSkill("effects.wx_status_counter_stance")))
				{
					if ("FatigueEffectMult" in _properties) _properties.FatigueEffectMult *= 0.85;
				}
			}
			else if (rmode == "chixiao" && _targetEntity != null)
			{
				local isSnakeBeastOrEvil = ::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity)
					|| (("ShanHaiSets" in ::Wuxia) && ::Wuxia.ShanHaiSets.isBeastOrShanHaiTarget(_targetEntity));
				if (isSnakeBeastOrEvil)
					_properties.DamageTotalMult *= 1.14;
			}
			else if (rmode == "longque" && _targetEntity != null && ::Wuxia.hasMember(_targetEntity, "getArmor") && ::Wuxia.hasMember(_targetEntity, "getArmorMax"))
			{
				local curA = _targetEntity.getArmor(::Const.BodyPart.Body) + _targetEntity.getArmor(::Const.BodyPart.Head);
				local maxA = _targetEntity.getArmorMax(::Const.BodyPart.Body) + _targetEntity.getArmorMax(::Const.BodyPart.Head);
				if (maxA > 0 && curA * 2 >= maxA)
					_properties.DamageArmorMult += 0.18;
			}
			else if (rmode == "minghong" && !_skill.isRanged())
			{
				local hasPoiseM = (cont != null && cont.hasSkill("effects.wx_status_poise_charge"));
				local unseen = (_targetEntity != null && (this.m.FirstHitTargets == null || !(_targetEntity.getID() in this.m.FirstHitTargets)));
				if (hasPoiseM || unseen)
					_properties.MeleeSkill += 12;
			}
			else if (rmode == "xiuchun" && !_skill.isRanged())
			{
				local aff = tsk != null && (tsk.hasSkill("effects.bleeding") || tsk.hasSkill("effects.wx_status_acupoint") || tsk.hasSkill("effects.wx_status_opening"));
				local pushSk = ("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "push_advance");
				if (aff || pushSk)
					_properties.MeleeSkill += 8;
			}
			else if (rmode == "modao" && _targetEntity != null)
			{
				local isBossOrBeast = (("ShanHaiSets" in ::Wuxia) && ::Wuxia.ShanHaiSets.isBeastOrShanHaiTarget(_targetEntity))
					|| (tsk != null && (tsk.hasSkill("special.wx_shanhai_boss_trait") || tsk.hasSkill("effects.wx_status_poise_charge")));
				if (isBossOrBeast)
					_properties.DamageTotalMult *= 1.15;
			}
			else if (rmode == "kunwu" && !_skill.isRanged() && isShielded)
			{
				_properties.MeleeSkill += 10;
			}
			else if (rmode == "liquan" && intercepting && !_skill.isRanged())
			{
				if ("FatigueEffectMult" in _properties) _properties.FatigueEffectMult *= 0.50;
			}
			else if (rmode == "hutouqiang" && !_skill.isRanged() && ("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "pierce_line"))
			{
				if ("HitChance" in _properties && typeof _properties.HitChance == "array" && _properties.HitChance.len() > ::Const.BodyPart.Head)
					_properties.HitChance[::Const.BodyPart.Head] += 12;
			}
			else if (rmode == "huaji" && tsk != null && tsk.hasSkill("effects.wx_status_opening") && tsk.hasSkill("effects.wx_status_offbalance"))
			{
				_properties.DamageTotalMult *= 1.14;
			}
			else if (rmode == "yanyue" && !_skill.isRanged() && actor != null)
			{
				local nearEnemies = 0;
				if (("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive()
					&& ::Wuxia.hasMember(actor, "isPlacedOnMap") && actor.isPlacedOnMap() && actor.getTile() != null)
				{
					local mTile = actor.getTile();
					for (local dy = 0; dy < 6; dy = ++dy)
					{
						if (!mTile.hasNextTile(dy)) continue;
						local nt = mTile.getNextTile(dy);
						if (nt.IsOccupiedByActor && nt.getEntity() != null && nt.getEntity().isAlive() && !actor.isAlliedWith(nt.getEntity()))
							nearEnemies += 1;
					}
				}
				if (nearEnemies >= 2 || _skill.getID().find("sweep") != null)
					_properties.DamageArmorMult += 0.18;
			}
			else if (rmode == "goulianqiang" && _targetEntity != null)
			{
				if (tArm >= 120 || (("ShanHaiSets" in ::Wuxia) && ::Wuxia.ShanHaiSets.isBeastOrShanHaiTarget(_targetEntity)))
					_properties.MeleeSkill += 9;
			}
			else if (rmode == "longlinzhao" && !_skill.isRanged())
			{
				local sidL = _skill.getID();
				if (sidL.find("grapple") != null || sidL.find("acupoint") != null || sidL.find("disarm") != null)
				{
					_properties.MeleeSkill += 9;
					if ("FatigueEffectMult" in _properties) _properties.FatigueEffectMult *= 0.85;
				}
			}
			else if (rmode == "jingangwan" && !_skill.isRanged() && tArm >= 80 && ("CraftBridge" in ::Wuxia))
			{
				::Wuxia.CraftBridge.addCappedDirectDamage(_properties, 0.08);
			}
			else if (rmode == "xuanhuafu" && !_skill.isRanged() && this.m.BattleSwingsUsed < 3)
			{
				_properties.MeleeSkill += 8;
				_properties.DamageArmorMult += 0.20;
			}
			else if (rmode == "pochengyue" && tsk != null && tsk.hasSkill("effects.bleeding"))
			{
				_properties.DamageTotalMult *= 1.10;
			}
			else if (rmode == "yuchang" && !_skill.isRanged() && this.wxIsTargetControlled(tsk) && ("CraftBridge" in ::Wuxia))
			{
				_properties.MeleeSkill += 10;
				::Wuxia.CraftBridge.addCappedDirectDamage(_properties, 0.10);
			}
			else if (rmode == "xufuren" && !_skill.isRanged() && ("CraftBridge" in ::Wuxia))
			{
				if (::Wuxia.CraftBridge.hasSkillMechanic(_skill, "surround_scale") || ::Wuxia.CraftBridge.isShadowOrSmokeEnv(actor, _targetEntity))
				{
					if ("HitChance" in _properties && typeof _properties.HitChance == "array" && _properties.HitChance.len() > ::Const.BodyPart.Head)
						_properties.HitChance[::Const.BodyPart.Head] += 12;
				}
			}
			else if (rmode == "zhentiangong" && _skill.isRanged())
			{
				local highOrFar = ("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "high_ground");
				if (!highOrFar && actor != null && _targetEntity != null
					&& ::Wuxia.hasMember(actor, "isPlacedOnMap") && actor.isPlacedOnMap()
					&& ::Wuxia.hasMember(_targetEntity, "isPlacedOnMap") && _targetEntity.isPlacedOnMap())
				{
					local myT2 = actor.getTile();
					local tgT2 = _targetEntity.getTile();
					if (myT2 != null && tgT2 != null && (myT2.Level > tgT2.Level || myT2.getDistanceTo(tgT2) >= 5))
						highOrFar = true;
				}
				if (highOrFar)
					_properties.DamageArmorMult += 0.20;
			}
			else if (rmode == "shenbinu" && _skill.isRanged() && _targetEntity != null)
			{
				if (tArm >= 100 || (tsk != null && tsk.hasSkill("special.wx_shanhai_boss_trait")))
					_properties.RangedSkill += 8;
			}
			else if (rmode == "feidaonang" && _skill.isRanged() && tsk != null && tsk.hasSkill("effects.wx_status_opening"))
			{
				local closeEnough = true;
				if (actor != null && _targetEntity != null && ::Wuxia.hasMember(actor, "isPlacedOnMap") && actor.isPlacedOnMap()
					&& ::Wuxia.hasMember(_targetEntity, "isPlacedOnMap") && _targetEntity.isPlacedOnMap())
				{
					closeEnough = (actor.getTile().getDistanceTo(_targetEntity.getTile()) <= 3);
				}
				if (closeEnough)
					_properties.RangedSkill += 12;
			}
		}

		if (_targetEntity != null)
		{
			if (("VsShakenHit" in cfg) && cfg.VsShakenHit > 0 && (::Wuxia.hasMember(_targetEntity, "getMoraleState")) && _targetEntity.getMoraleState() <= ::Const.MoraleState.Wavering)
			{
				if (_skill.isRanged()) _properties.RangedSkill += cfg.VsShakenHit;
				else _properties.MeleeSkill += cfg.VsShakenHit;
			}
			if (("VsHighResolveHit" in cfg) && cfg.VsHighResolveHit > 0 && (::Wuxia.hasMember(_targetEntity, "getCurrentProperties")) && _targetEntity.getCurrentProperties() != null)
			{
				if (_targetEntity.getCurrentProperties().Bravery >= 60)
					_properties.MeleeSkill += cfg.VsHighResolveHit;
			}
			if (_skill.isRanged() && ("CloseRangeHit" in cfg) && cfg.CloseRangeHit > 0 && actor != null && (::Wuxia.hasMember(actor, "isPlacedOnMap")) && actor.isPlacedOnMap() && (::Wuxia.hasMember(_targetEntity, "isPlacedOnMap")) && _targetEntity.isPlacedOnMap())
			{
				if (actor.getTile().getDistanceTo(_targetEntity.getTile()) <= 3)
					_properties.RangedSkill += cfg.CloseRangeHit;
			}
		}
	}

	function onMissed( _attacker, _skill )
	{
		local cfg = this.getTraitCfg();
		if (cfg == null) return;
		if (_skill != null && _skill.isRanged()) return;
		local rmode = ("RelicMode" in cfg) ? cfg.RelicMode : "";
		local smode = ("ShanHaiMode" in cfg) ? cfg.ShanHaiMode : "";
		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();

		if ((rmode == "lvzhuzhang" || smode == "shd_yinglong") && this.m.MissQiThisTurn < 2 && actor != null && actor.isAlive())
		{
			this.m.MissQiThisTurn += 1;
			::Wuxia.CombatRules.restoreQi(actor, 3);
		}
		if (smode == "armor_baize")
		{
			this.m.BaizeRiposteReady = true;
		}
		else if ((smode == "shd_zaochi" || smode == "acc_boshi") && _attacker != null && _attacker.isAlive() && ::Wuxia.hasMember(_attacker, "getSkills"))
		{
			local pctM = (smode == "shd_zaochi") ? 35 : 30;
			if (::Math.rand(1, 100) <= pctM)
				this.wxApplyStatusSafe(_attacker.getSkills(), "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
		}
	}

	function onBeforeDamageReceived( _attacker, _skill, _hitInfo, _properties )
	{
		local cfg = this.getTraitCfg();
		local upg = this.getAttachedArmorUpgID();
		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();

		if (upg == "wx_up_shagu" && _attacker != null && actor != null && _attacker.getID() != actor.getID() && _attacker.isAlive() && _skill != null && !_skill.isRanged())
		{
			if (::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
			{
				local sgB = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (sgB != null && ::Wuxia.hasMember(sgB, "getArmor") && sgB.getArmor() > 0)
					sgB.setArmor(::Math.max(0, sgB.getArmor() - 5));
			}
		}
		else if (upg == "wx_up_gujing" && this.m.SelfQiThisTurn < 1 && actor != null && _attacker != null && _attacker.getSkills() != null)
		{
			if (_attacker.getSkills().hasSkill("effects.wx_status_blade_coating") || (_skill != null && _skill.getID().find("poison") != null))
			{
				this.m.SelfQiThisTurn += 1;
				::Wuxia.CombatRules.restoreQi(actor, 2);
			}
		}

		if (cfg == null) return;

		local bmode = ("BeastMode" in cfg) ? cfg.BeastMode : "";
		local smode = ("ShanHaiMode" in cfg) ? cfg.ShanHaiMode : "";

		if (("SteelBrow" in cfg) && cfg.SteelBrow && _hitInfo != null && ("BodyPart" in _hitInfo) && _hitInfo.BodyPart == ::Const.BodyPart.Head)
		{
			if (("BodyDamageMult" in _hitInfo) && _hitInfo.BodyDamageMult > 1.0)
				_hitInfo.BodyDamageMult = 1.0;
		}

		if (bmode == "armor_scales" && !this.m.PhaseUsedThisTurn && _skill != null && !_skill.isRanged())
		{
			this.m.PhaseUsedThisTurn = true;
			_properties.DamageReceivedArmorMult *= 0.85;
		}
		if (smode == "armor_xuangui" && !this.m.PhaseUsedThisTurn && _hitInfo != null && ("DamageArmor" in _hitInfo) && _hitInfo.DamageArmor >= 20)
		{
			this.m.PhaseUsedThisTurn = true;
			_properties.DamageReceivedArmorMult *= 0.70;
		}
		else if (smode == "shd_xuangui" && cont != null && cont.hasSkill("effects.shieldwall") && ("CraftBridge" in ::Wuxia))
		{
			::Wuxia.CraftBridge.multCappedRegularDamageReceived(_properties, 0.85);
		}
		else if (smode == "acc_yayu" && !this.m.BattleSaveUsed && actor != null && actor.getHitpointsMax() > 0)
		{
			local estReg = (_hitInfo != null && ("DamageRegular" in _hitInfo)) ? _hitInfo.DamageRegular : 0;
			if ((actor.getHitpoints() - estReg).tofloat() / actor.getHitpointsMax().tofloat() < 0.35)
			{
				this.m.BattleSaveUsed = true;
				if (cont != null && cont.hasSkill("effects.bleeding")) cont.removeByID("effects.bleeding");
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + 18));
			}
		}

		// 《帝江幻空丹面 / 飞廉御风羽衣》空间折跃卸力（严守 <=60% 全局减伤红线！）
		if (("PhaseShiftPct" in cfg) && cfg.PhaseShiftPct > 0.0 && !this.m.PhaseUsedThisTurn && _hitInfo != null && ("CraftBridge" in ::Wuxia))
		{
			local isRangedHit = (_skill != null && _skill.isRanged());
			local isHeavyHit  = (("DamageRegular" in _hitInfo) && _hitInfo.DamageRegular >= 22);
			if (isRangedHit || isHeavyHit)
			{
				this.m.PhaseUsedThisTurn = true;
				::Wuxia.CraftBridge.multCappedRegularDamageReceived(_properties, 1.0 - cfg.PhaseShiftPct);
			}
		}

		if (_attacker != null && actor != null && _attacker.getID() != actor.getID() && _attacker.isAlive() && _skill != null && !_skill.isRanged())
		{
			if (smode == "armor_zhuyan" && this.m.SelfQiThisTurn < 2 && actor.getHitpointsMax() > 0
				&& (actor.getHitpoints().tofloat() / actor.getHitpointsMax().tofloat()) < 0.60)
			{
				this.m.SelfQiThisTurn += 1;
				::Wuxia.CombatRules.restoreQi(actor, 3);
			}
			else if (smode == "armor_feiyi" && _attacker.getSkills() != null
				&& (_attacker.getSkills().hasSkill("effects.wx_status_poison_dart") || _attacker.getSkills().hasSkill("effects.spider_poison") || _attacker.getSkills().hasSkill("effects.goblin_poison")))
			{
				if (_attacker.getHitpoints() > 7)
					_attacker.setHitpoints(_attacker.getHitpoints() - 6);
			}
			else if (smode == "armor_yinglong" && ("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.isWetOrConductiveEnv(actor, _attacker))
			{
				if (::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
				{
					local ylA = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Body);
					if (ylA != null && ylA.getArmor() > 0) ylA.setArmor(::Math.max(0, ylA.getArmor() - 6));
				}
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(_attacker) && ::Wuxia.hasMember(_attacker, "getFatigue"))
					_attacker.setFatigue(::Math.min(_attacker.getFatigueMax(), _attacker.getFatigue() + 4));
			}
			else if (smode == "armor_kui" && _attacker.getSkills() != null && ::Math.rand(1, 100) <= 30)
			{
				this.wxApplyStatusSafe(_attacker.getSkills(), "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
			else if (smode == "helm_chiyou" && _hitInfo != null && ("BodyPart" in _hitInfo) && _hitInfo.BodyPart == ::Const.BodyPart.Head)
			{
				if (::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
				{
					local cyA = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Body);
					if (cyA != null && cyA.getArmor() > 0) cyA.setArmor(::Math.max(0, cyA.getArmor() - 10));
				}
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(_attacker) && ::Wuxia.hasMember(_attacker, "getFatigue"))
					_attacker.setFatigue(::Math.min(_attacker.getFatigueMax(), _attacker.getFatigue() + 5));
			}
			else if (smode == "helm_bingyi" && _attacker.getSkills() != null)
			{
				this.wxApplyStatusSafe(_attacker.getSkills(), "effects.wx_status_frost_chill", "scripts/skills/effects/wx_status_frost_chill");
			}
			else if (smode == "shd_kui" && _hitInfo != null && ("DamageRegular" in _hitInfo) && _hitInfo.DamageRegular >= 18
				&& !::Wuxia.CombatRules.isUndeadOrConstruct(_attacker) && ::Wuxia.hasMember(_attacker, "checkMorale"))
			{
				_attacker.checkMorale(-1, -10);
			}
			if (("ThornsMeleeArmor" in cfg) && cfg.ThornsMeleeArmor > 0 && (::Wuxia.hasMember(_attacker, "getItems")) && _attacker.getItems() != null)
			{
				local atkBody = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (atkBody != null && (::Wuxia.hasMember(atkBody, "getArmor")) && atkBody.getArmor() > 0)
					atkBody.setArmor(::Math.max(0, atkBody.getArmor() - cfg.ThornsMeleeArmor));
			}
			if (("ThornsMeleeQi" in cfg) && cfg.ThornsMeleeQi > 0 && !::Wuxia.CombatRules.isUndeadOrConstruct(_attacker) && (::Wuxia.hasMember(_attacker, "getFatigue")))
			{
				_attacker.setFatigue(::Math.min(_attacker.getFatigueMax(), _attacker.getFatigue() + cfg.ThornsMeleeQi));
			}
			if (("ThornsPoisonPct" in cfg) && cfg.ThornsPoisonPct > 0 && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_attacker)
				&& ::Wuxia.hasMember(_attacker, "getSkills") && _attacker.getSkills() != null && ::Math.rand(1, 100) <= cfg.ThornsPoisonPct)
			{
				this.wxApplyStatusSafe(_attacker.getSkills(), "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart");
			}
		}
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		if (_skill == null || !_skill.isAttack()) return;

		local cfg  = this.getTraitCfg();
		local wmod = this.getAttachedWeaponModID();
		local qid  = this.getAttachedQuenchID();
		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();
		if (actor == null || _targetEntity == null || !_targetEntity.isAlive() || actor.isAlliedWith(_targetEntity))
			return;

		local tsk = (::Wuxia.hasMember(_targetEntity, "getSkills")) ? _targetEntity.getSkills() : null;
		local tItems = (::Wuxia.hasMember(_targetEntity, "getItems")) ? _targetEntity.getItems() : null;
		local mwFlat = this.isMasterworkGear() ? 2 : 0;
		local mwPct  = this.isMasterworkGear() ? 8 : 0;
		local intercepting = this.m.IsIntercepting || (::Wuxia.hasMember(actor, "m") && actor.m != null && ("WX_IsIntercepting" in actor.m) && actor.m.WX_IsIntercepting);

		// 1. Quench Catalyst on-hit (`赤火淬锋`)
		if (qid == "flame" && !_skill.isRanged() && tItems != null)
		{
			local qBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
			if (qBody != null && ::Wuxia.hasMember(qBody, "getArmor") && qBody.getArmor() > 0)
				qBody.setArmor(::Math.max(0, qBody.getArmor() - 5));
		}

		// 2. All 13 Weapon Attachments (`兵刃铭配`) on-hit mechanics
		if (wmod != "" && ("CraftBridge" in ::Wuxia))
		{
			if (wmod == "wx_wmod_sword_tassel" && !_skill.isRanged())
			{
				if (this.m.ModStacksThisTurn < 2)
					this.m.ModStacksThisTurn += 1;
				if (this.m.ModQiThisTurn < 2
					&& (::Wuxia.CraftBridge.hasSkillMechanic(_skill, "step_through") || (cont != null && cont.hasSkill("effects.wx_status_counter_stance"))))
				{
					this.m.ModQiThisTurn += 1;
					::Wuxia.CombatRules.restoreQi(actor, 2);
				}
			}
			else if (wmod == "wx_wmod_saber_guard" && !_skill.isRanged() && tsk != null)
			{
				if (this.m.ModQiThisTurn < 2 && tsk.hasSkill("effects.bleeding"))
				{
					this.m.ModQiThisTurn += 1;
					::Wuxia.CombatRules.restoreQi(actor, 3);
				}
			}
			else if (wmod == "wx_wmod_cleaver_ring" && !_skill.isRanged())
			{
				this.m.ModStacksThisTurn = 1;
				if (::Wuxia.hasMember(_targetEntity, "isArmedWithShield") && _targetEntity.isArmedWithShield() && tItems != null)
				{
					local cShd = tItems.getItemAtSlot(::Const.ItemSlot.Offhand);
					if (cShd != null && ::Wuxia.hasMember(cShd, "applyShieldDamage"))
						cShd.applyShieldDamage(10);
				}
				if (tItems != null && (::Wuxia.CraftBridge.hasSkillMechanic(_skill, "concuss_armor") || _damageInflictedArmor >= 18))
				{
					local cBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
					if (cBody != null && ::Wuxia.hasMember(cBody, "getArmor") && cBody.getArmor() > 0)
						cBody.setArmor(::Math.max(0, cBody.getArmor() - 8));
				}
			}
			else if (wmod == "wx_wmod_spear_tassel" && !_skill.isRanged() && tsk != null)
			{
				if (::Wuxia.CraftBridge.hasSkillMechanic(_skill, "pierce_line") && ::Math.rand(1, 100) <= 45)
					this.wxApplyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
			else if (wmod == "wx_wmod_polearm_hook" && !_skill.isRanged() && tsk != null)
			{
				if (::Wuxia.CraftBridge.hasSkillMechanic(_skill, "pull_closer"))
					this.wxApplyStatusSafe(tsk, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			}
			else if (wmod == "wx_wmod_staff_ferrule" && !_skill.isRanged())
			{
				if (::Math.rand(1, 100) <= 50)
					::Wuxia.CraftBridge.applyBossCounterHit(actor, _targetEntity, { BreakPts = 1 });
			}
			else if (wmod == "wx_wmod_fist_cuff" && !_skill.isRanged())
			{
				if (tItems != null
					&& (::Wuxia.CraftBridge.hasSkillMechanic(_skill, "concuss_armor") || _skill.getID().find("acupoint") != null || _skill.getID().find("fist") != null))
				{
					local fBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
					if (fBody != null && ::Wuxia.hasMember(fBody, "getArmor") && fBody.getArmor() > 0)
						fBody.setArmor(::Math.max(0, fBody.getArmor() - 8));
				}
				if (tsk != null && (tsk.hasSkill("effects.wx_status_offbalance") || tsk.hasSkill("effects.wx_status_acupoint"))
					&& !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ::Wuxia.hasMember(_targetEntity, "getFatigue"))
				{
					_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + 6));
				}
			}
			else if (wmod == "wx_wmod_hammer_stud" && !_skill.isRanged())
			{
				if (tItems != null)
				{
					local hBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
					if (hBody != null && ::Wuxia.hasMember(hBody, "getArmor") && hBody.getArmor() > 0)
						hBody.setArmor(::Math.max(0, hBody.getArmor() - 8));
				}
				if (_damageInflictedArmor >= 20 || ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "concuss_armor"))
					::Wuxia.CraftBridge.applyBossCounterHit(actor, _targetEntity, { CorrodeShell = 1 });
			}
			else if (wmod == "wx_wmod_axe_wedge" && !_skill.isRanged() && tItems != null)
			{
				if (::Wuxia.CraftBridge.hasSkillMechanic(_skill, "shatter_shield")
					|| (::Wuxia.hasMember(_targetEntity, "isArmedWithShield") && _targetEntity.isArmedWithShield()))
				{
					local aBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
					if (aBody != null && ::Wuxia.hasMember(aBody, "getArmor") && aBody.getArmor() > 0)
						aBody.setArmor(::Math.max(0, aBody.getArmor() - 12));
				}
			}
			else if (wmod == "wx_wmod_flail_ring" && !_skill.isRanged() && _bodyPart == ::Const.BodyPart.Head)
			{
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
				{
					if (::Wuxia.hasMember(_targetEntity, "getFatigue"))
						_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + 5));
					if (::Wuxia.hasMember(_targetEntity, "checkMorale"))
						_targetEntity.checkMorale(-1, -8);
				}
			}
			else if (wmod == "wx_wmod_mech_spring" && _skill.isRanged() && tItems != null)
			{
				local isClose = true;
				if (::Wuxia.hasMember(actor, "isPlacedOnMap") && actor.isPlacedOnMap() && ::Wuxia.hasMember(_targetEntity, "isPlacedOnMap") && _targetEntity.isPlacedOnMap())
					isClose = (actor.getTile().getDistanceTo(_targetEntity.getTile()) <= 3);
				if (isClose)
				{
					local mBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
					if (mBody != null && ::Wuxia.hasMember(mBody, "getArmor") && mBody.getArmor() > 0)
						mBody.setArmor(::Math.max(0, mBody.getArmor() - 8));
				}
			}
		}

		if (cfg == null) return;

		// 3. Bespoke Paired & Sampled Historical Relic Spirits (`干将 / 莫邪 / 承影 / 应龙`)
		if (("GanjiangMode" in cfg) && cfg.GanjiangMode && !_skill.isRanged())
		{
			local tArmVal = this.wxGetTargetBodyArmor(_targetEntity, tItems);
			if (tsk != null && tArmVal >= 90 && ::Math.rand(1, 100) <= (45 + mwPct))
				this.wxApplyStatusSafe(tsk, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			if (tItems != null && ("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "detonate_opening"))
			{
				local gjBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
				if (gjBody != null && gjBody.getArmor() > 0)
					gjBody.setArmor(::Math.max(0, gjBody.getArmor() - (14 + mwFlat)));
			}
			if (("CraftBridge" in ::Wuxia) && this.m.SelfQiThisTurn < 2)
			{
				local moyePartner = ::Wuxia.CraftBridge.findSquadRelicPartner(actor, "wx_relic_moye", 4);
				if (moyePartner != null)
				{
					this.m.SelfQiThisTurn += 1;
					::Wuxia.CombatRules.restoreQi(actor, 3);
					::Wuxia.CombatRules.restoreQi(moyePartner, 3);
				}
			}
		}

		if (("MoyeMode" in cfg) && cfg.MoyeMode && !_skill.isRanged())
		{
			if (this.m.SelfQiThisTurn < 2 && ("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "detonate_bleed"))
			{
				this.m.SelfQiThisTurn += 1;
				::Wuxia.CombatRules.restoreQi(actor, 4);
			}
			if ("CraftBridge" in ::Wuxia)
			{
				local gjPartner = ::Wuxia.CraftBridge.findSquadRelicPartner(actor, "wx_relic_ganjiang", 4);
				local exposed = (tsk != null && (tsk.hasSkill("effects.wx_status_opening") || tsk.hasSkill("effects.bleeding")));
				if (gjPartner != null && exposed)
				{
					if (_targetEntity.getHitpoints() > 11)
						_targetEntity.setHitpoints(_targetEntity.getHitpoints() - (10 + mwFlat));
					if (tItems != null)
					{
						local myBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
						if (myBody != null && myBody.getArmor() > 0)
							myBody.setArmor(::Math.max(0, myBody.getArmor() - 10));
					}
				}
			}
		}

		if (("ChengyingMode" in cfg) && cfg.ChengyingMode && !_skill.isRanged() && this.m.SelfQiThisTurn < 2)
		{
			local isStep = ("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "step_through");
			local isCtrl = this.wxIsTargetControlled(tsk);
			if (isStep || isCtrl)
			{
				this.m.SelfQiThisTurn += 1;
				::Wuxia.CombatRules.restoreQi(actor, 4);
			}
		}

		// 4. All Remaining 34 Historical Relic Spirits (`RelicMode`) on-hit mechanics
		local rmode = ("RelicMode" in cfg) ? cfg.RelicMode : "";
		if (rmode != "")
		{
			if (rmode == "taie" && !_skill.isRanged())
			{
				if (::Wuxia.hasMember(actor, "getMoraleState") && actor.getMoraleState() == ::Const.MoraleState.Confident
					&& !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ::Wuxia.hasMember(_targetEntity, "checkMorale"))
				{
					_targetEntity.checkMorale(-1, -12);
				}
			}
			else if (rmode == "chixiao" && !_skill.isRanged() && _damageInflictedHitpoints >= 25)
			{
				this.wxRallyNearbyAllies(actor);
			}
			else if (rmode == "juque" && !_skill.isRanged() && _damageInflictedArmor >= 28)
			{
				this.wxApplyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
				this.wxTryKnockbackOrCrush(actor, _targetEntity, 12, 0);
			}
			else if (rmode == "longque" && !_skill.isRanged())
			{
				local remBody = this.wxGetTargetBodyArmor(_targetEntity, tItems);
				if (remBody <= 0 && (_damageInflictedArmor > 0 || _damageInflictedHitpoints >= 15))
				{
					this.wxApplyStatusSafe(tsk, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
					if (!::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ::Wuxia.hasMember(_targetEntity, "checkMorale"))
						_targetEntity.checkMorale(-1, -15);
				}
			}
			else if (rmode == "minghong" && !_skill.isRanged())
			{
				if (this.m.FirstHitTargets == null) this.m.FirstHitTargets = {};
				local tidM = _targetEntity.getID();
				local isFirstM = !(tidM in this.m.FirstHitTargets);
				this.m.FirstHitTargets[tidM] <- true;
				local hasPoiseH = (cont != null && cont.hasSkill("effects.wx_status_poise_charge"));
				if ((isFirstM || hasPoiseH) && !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ::Wuxia.hasMember(_targetEntity, "getFatigue"))
					_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + 8));
			}
			else if (rmode == "modao" && !_skill.isRanged() && tsk != null)
			{
				foreach (stID in ["effects.wx_status_counter_stance", "effects.riposte", "effects.shieldwall"])
				{
					if (tsk.hasSkill(stID)) tsk.removeByID(stID);
				}
			}
			else if (rmode == "kunwu" && !_skill.isRanged())
			{
				if (this.m.LastHitTargetID == _targetEntity.getID() && tsk != null && !::Wuxia.CombatRules.isImmuneToBleeding(_targetEntity))
				{
					local deepBleed = ::new("scripts/skills/effects/bleeding_effect");
					deepBleed.setDamage(8);
					tsk.add(deepBleed);
				}
			}
			else if (rmode == "tulong" && !_skill.isRanged() && ("CraftBridge" in ::Wuxia))
			{
				if (::Wuxia.CraftBridge.hasSkillMechanic(_skill, "concuss_armor") || _damageInflictedArmor >= 22)
				{
					if (!::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ::Wuxia.hasMember(_targetEntity, "getFatigue"))
						_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + 10));
					::Wuxia.CraftBridge.applyBossCounterHit(actor, _targetEntity, { CorrodeShell = 1 });
				}
			}
			else if (rmode == "liquan" && !_skill.isRanged() && intercepting && tsk != null)
			{
				if (::Math.rand(1, 100) <= (50 + mwPct))
					this.wxApplyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
			else if (rmode == "hutouqiang" && !_skill.isRanged() && tsk != null && tsk.hasSkill("effects.wx_status_opening"))
			{
				local behindEnt = this.wxFindAdjacentEnemy(actor, _targetEntity);
				if (behindEnt != null && ::Wuxia.hasMember(behindEnt, "getItems") && behindEnt.getItems() != null)
				{
					local bhBody = behindEnt.getItems().getItemAtSlot(::Const.ItemSlot.Body);
					if (bhBody != null && ::Wuxia.hasMember(bhBody, "getArmor") && bhBody.getArmor() > 0)
						bhBody.setArmor(::Math.max(0, bhBody.getArmor() - (12 + mwFlat)));
				}
			}
			else if (rmode == "huaji" && !_skill.isRanged() && tsk != null && ("CraftBridge" in ::Wuxia))
			{
				if (::Wuxia.CraftBridge.hasSkillMechanic(_skill, "pull_closer") || _skill.getID().find("fangtian") != null || _skill.getID().find("hook") != null)
				{
					this.wxApplyStatusSafe(tsk, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
					this.wxApplyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
				}
			}
			else if (rmode == "goulianqiang" && !_skill.isRanged() && tsk != null)
			{
				if (::Math.rand(1, 100) <= (45 + mwPct))
				{
					this.wxApplyStatusSafe(tsk, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
					this.wxApplyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
				}
			}
			else if (rmode == "bawangqiang" && !_skill.isRanged() && _damageInflictedHitpoints >= 18)
			{
				this.wxTryKnockbackOrCrush(actor, _targetEntity, 14, 6);
			}
			else if (rmode == "huntiegun" && !_skill.isRanged() && ("CraftBridge" in ::Wuxia))
			{
				if (::Wuxia.CraftBridge.hasSkillMechanic(_skill, "concuss_armor") || _damageInflictedArmor >= 18)
				{
					if (!::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ::Wuxia.hasMember(_targetEntity, "getFatigue"))
						_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + 6));
					local adjH = this.wxFindAdjacentEnemy(actor, _targetEntity);
					if (adjH != null && !::Wuxia.CombatRules.isUndeadOrConstruct(adjH) && ::Wuxia.hasMember(adjH, "getFatigue"))
						adjH.setFatigue(::Math.min(adjH.getFatigueMax(), adjH.getFatigue() + 6));
				}
			}
			else if (rmode == "lvzhuzhang" && !_skill.isRanged() && tsk != null)
			{
				local isCtrlMove = intercepting || (("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "pull_closer"))
					|| _skill.getID().find("dagou") != null || _skill.getID().find("staff") != null;
				if (isCtrlMove && ::Math.rand(1, 100) <= (55 + mwPct))
					this.wxApplyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
			else if (rmode == "longlinzhao" && !_skill.isRanged())
			{
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ::Wuxia.hasMember(_targetEntity, "getFatigue"))
					_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + 5));
				if (tsk != null && ::Math.rand(1, 100) <= (45 + mwPct))
					this.wxApplyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
			else if (rmode == "jingangwan" && !_skill.isRanged())
			{
				if (tItems != null && this.wxGetTargetBodyArmor(_targetEntity, tItems) >= 80)
				{
					local jgBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
					if (jgBody != null && jgBody.getArmor() > 0)
						jgBody.setArmor(::Math.max(0, jgBody.getArmor() - (10 + mwFlat)));
				}
				if ("CraftBridge" in ::Wuxia)
					::Wuxia.CraftBridge.applyBossCounterHit(actor, _targetEntity, { BreakPts = 1 });
			}
			else if (rmode == "wengjinchui" && !_skill.isRanged() && ("CraftBridge" in ::Wuxia))
			{
				::Wuxia.CraftBridge.applyBossCounterHit(actor, _targetEntity, { CorrodeShell = 1 });
			}
			else if (rmode == "shutongjian" && !_skill.isRanged() && tsk != null && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity))
			{
				local onOpen = tsk.hasSkill("effects.wx_status_opening") || (("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "detonate_opening"));
				if (onOpen && ::Math.rand(1, 100) <= (45 + mwPct))
					this.wxApplyStatusSafe(tsk, "effects.wx_status_acupoint", "scripts/skills/effects/wx_status_acupoint");
			}
			else if (rmode == "jinzuan_chui" && !_skill.isRanged() && _damageInflictedArmor >= 25 && tsk != null)
			{
				this.wxApplyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
			else if (rmode == "xuanhuafu" && !_skill.isRanged() && this.m.BattleSwingsUsed < 3)
			{
				this.m.BattleSwingsUsed += 1;
				::Wuxia.CombatRules.restoreQi(actor, 3);
			}
			else if (rmode == "pochengyue" && !_skill.isRanged() && this.m.KillHealsThisTurn < 2
				&& tsk != null && tsk.hasSkill("effects.bleeding") && !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
			{
				this.m.KillHealsThisTurn += 1;
				if (actor.getHitpoints() < actor.getHitpointsMax())
					actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + 6));
				::Wuxia.CombatRules.restoreQi(actor, 3);
			}
			else if (rmode == "kaitian_changfu" && !_skill.isRanged() && tItems != null)
			{
				local shHit = (("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "shatter_shield"))
					|| (::Wuxia.hasMember(_targetEntity, "isArmedWithShield") && _targetEntity.isArmedWithShield());
				if (shHit)
				{
					local ktBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
					if (ktBody != null && ::Wuxia.hasMember(ktBody, "getArmor") && ktBody.getArmor() > 0)
						ktBody.setArmor(::Math.max(0, ktBody.getArmor() - (18 + mwFlat)));
					this.wxApplyStatusSafe(tsk, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
				}
			}
			else if (rmode == "wujinbian" && !_skill.isRanged())
			{
				local hitHeadOrShd = (_bodyPart == ::Const.BodyPart.Head) || (::Wuxia.hasMember(_targetEntity, "isArmedWithShield") && _targetEntity.isArmedWithShield());
				if (hitHeadOrShd && !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ::Wuxia.hasMember(_targetEntity, "getFatigue"))
					_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + 9));
				if (_bodyPart == ::Const.BodyPart.Head && tsk != null && ::Math.rand(1, 100) <= (50 + mwPct))
					this.wxApplyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
			else if (rmode == "dashenbian")
			{
				if (_damageInflictedHitpoints >= 5 && tsk != null && !::Wuxia.CombatRules.isImmuneToBleeding(_targetEntity))
				{
					local bWh = ::new("scripts/skills/effects/bleeding_effect");
					bWh.setDamage(5);
					tsk.add(bWh);
				}
				if ("CraftBridge" in ::Wuxia)
					::Wuxia.CraftBridge.applyBossCounterHit(actor, _targetEntity, { BreakPts = 1 });
			}
			else if (rmode == "zhentiangong" && _skill.isRanged() && tsk != null)
			{
				if (::Math.rand(1, 100) <= (45 + mwPct))
					this.wxApplyStatusSafe(tsk, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			}
			else if (rmode == "shenbinu" && _skill.isRanged() && tItems != null)
			{
				local isShanHai = (tsk != null && ((("ShanHai" in ::Wuxia) && ("findBossTrait" in ::Wuxia.ShanHai) && ::Wuxia.ShanHai.findBossTrait(tsk) != null) || tsk.hasSkill("special.wx_shanhai_boss_trait")));
				if (this.wxGetTargetBodyArmor(_targetEntity, tItems) >= 100 || isShanHai)
				{
					local sbBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
					if (sbBody != null && ::Wuxia.hasMember(sbBody, "getArmor") && sbBody.getArmor() > 0)
						sbBody.setArmor(::Math.max(0, sbBody.getArmor() - (14 + mwFlat)));
				}
			}
			else if (rmode == "xunleichong" && _skill.isRanged())
			{
				this.m.XunleiHitsThisTurn += 1;
				if (this.m.XunleiHitsThisTurn == 2)
				{
					this.m.XunleiSmokeActive = true;
					::Wuxia.CombatRules.restoreQi(actor, 4);
				}
			}
			else if (rmode == "feidaonang" && _skill.isRanged() && this.m.AmmoRefundBattle < 3 && ("CraftBridge" in ::Wuxia))
			{
				if (::Wuxia.CraftBridge.hasSkillMechanic(_skill, "detonate_opening"))
				{
					local fItem = ("DirectItemRef" in this.m && this.m.DirectItemRef != null) ? this.m.DirectItemRef : this.getItem();
					if (fItem != null && ::Wuxia.hasMember(fItem, "m") && ::Wuxia.hasMember(fItem.m, "Ammo") && fItem.m.Ammo < fItem.m.AmmoMax)
					{
						this.m.AmmoRefundBattle += 1;
						fItem.m.Ammo = ::Math.min(fItem.m.AmmoMax, fItem.m.Ammo + 1);
					}
				}
			}
		}
		this.m.LastHitTargetID = _targetEntity.getID();

		// 4b. Overhauled Beast & Shan-Hai (`BeastMode` + `ShanHaiMode`) on-hit triggers
		local bmodeH = ("BeastMode" in cfg) ? cfg.BeastMode : "";
		local smodeH = ("ShanHaiMode" in cfg) ? cfg.ShanHaiMode : "";
		if (bmodeH == "fist_leech" && !_skill.isRanged() && tsk != null && tItems != null
			&& (tsk.hasSkill("effects.bleeding") || tsk.hasSkill("effects.wx_status_offbalance")))
		{
			local flB = tItems.getItemAtSlot(::Const.ItemSlot.Body);
			if (flB != null && flB.getArmor() > 0) flB.setArmor(::Math.max(0, flB.getArmor() - 8));
		}
		else if (bmodeH == "sword_venom" && !_skill.isRanged() && tsk != null
			&& (tsk.hasSkill("effects.wx_status_poison_dart") || tsk.hasSkill("effects.spider_poison") || tsk.hasSkill("effects.goblin_poison"))
			&& !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ::Wuxia.hasMember(_targetEntity, "getFatigue"))
		{
			_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + 5));
		}
		else if (bmodeH == "saber_dread" && !_skill.isRanged() && tsk != null && tsk.hasSkill("effects.bleeding")
			&& !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ::Wuxia.hasMember(_targetEntity, "checkMorale"))
		{
			_targetEntity.checkMorale(-1, -8);
		}
		else if (bmodeH == "bow_venom" && _skill.isRanged() && _damageInflictedHitpoints >= 4 && tsk != null)
		{
			this.wxApplyStatusSafe(tsk, "effects.wx_status_frost_chill", "scripts/skills/effects/wx_status_frost_chill");
		}

		if (smodeH != "")
		{
			if (smodeH == "bo" && !_skill.isRanged() && tsk != null && tsk.hasSkill("effects.wx_status_opening") && ("CraftBridge" in ::Wuxia))
			{
				::Wuxia.CraftBridge.applyBossCounterHit(actor, _targetEntity, { CorrodeShell = 1 });
			}
			else if (smodeH == "mingshe" && !_skill.isRanged())
			{
				local headOrShd = (_bodyPart == ::Const.BodyPart.Head) || (::Wuxia.hasMember(_targetEntity, "isArmedWithShield") && _targetEntity.isArmedWithShield());
				if (headOrShd)
				{
					if (tItems != null)
					{
						local msB = tItems.getItemAtSlot(::Const.ItemSlot.Body);
						if (msB != null && msB.getArmor() > 0) msB.setArmor(::Math.max(0, msB.getArmor() - 10));
					}
					local msAdj = this.wxFindAdjacentEnemy(actor, _targetEntity);
					if (msAdj != null && !::Wuxia.CombatRules.isUndeadOrConstruct(msAdj) && ::Wuxia.hasMember(msAdj, "getFatigue"))
						msAdj.setFatigue(::Math.min(msAdj.getFatigueMax(), msAdj.getFatigue() + 5));
				}
			}
			else if (smodeH == "qinyuan_dag" && !_skill.isRanged() && _damageInflictedHitpoints >= 3 && ("CraftBridge" in ::Wuxia))
			{
				if (tItems != null)
				{
					local qyB = tItems.getItemAtSlot(::Const.ItemSlot.Body);
					if (qyB != null && qyB.getArmor() > 0) qyB.setArmor(::Math.max(0, qyB.getArmor() - 10));
				}
				::Wuxia.CraftBridge.applyBossCounterHit(actor, _targetEntity, { SealRegenTurns = 1 });
			}
			else if (smodeH == "hujiao" && !_skill.isRanged() && tsk != null
				&& (tsk.hasSkill("effects.wx_status_poison_dart") || tsk.hasSkill("effects.spider_poison") || tsk.hasSkill("effects.goblin_poison")))
			{
				this.wxApplyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
			else if (smodeH == "gudiao" && _skill.isRanged() && _damageInflictedHitpoints >= 12
				&& !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ::Wuxia.hasMember(_targetEntity, "checkMorale"))
			{
				_targetEntity.checkMorale(-1, -12);
			}
			else if (smodeH == "huodouchong" && _skill.isRanged() && tsk != null)
			{
				local poisonedOrWeb = tsk.hasSkill("effects.wx_status_poison_dart") || tsk.hasSkill("effects.spider_poison")
					|| tsk.hasSkill("effects.goblin_poison") || tsk.hasSkill("effects.web") || tsk.hasSkill("effects.net");
				if (poisonedOrWeb && _targetEntity.getHitpoints() > 11)
					_targetEntity.setHitpoints(_targetEntity.getHitpoints() - (10 + mwFlat));
			}
			else if (smodeH == "tiangou" && _skill.isRanged() && tsk != null)
			{
				local wasOpen = tsk.hasSkill("effects.wx_status_opening");
				if (::Wuxia.hasMember(_targetEntity, "getHitpointsMax") && _targetEntity.getHitpointsMax() > 0
					&& ((_targetEntity.getHitpoints() + _damageInflictedHitpoints).tofloat() / _targetEntity.getHitpointsMax().tofloat()) >= 0.80)
				{
					this.wxApplyStatusSafe(tsk, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
				}
				if (wasOpen && this.m.AmmoRefundBattle < 3)
				{
					local tgItem = ("DirectItemRef" in this.m && this.m.DirectItemRef != null) ? this.m.DirectItemRef : this.getItem();
					if (tgItem != null && ::Wuxia.hasMember(tgItem, "m") && ::Wuxia.hasMember(tgItem.m, "Ammo") && tgItem.m.Ammo < tgItem.m.AmmoMax)
					{
						this.m.AmmoRefundBattle += 1;
						tgItem.m.Ammo = ::Math.min(tgItem.m.AmmoMax, tgItem.m.Ammo + 1);
					}
				}
			}
			else if (smodeH == "armor_qiongqi" && !_skill.isRanged())
			{
				local shakyOrBleed = (tsk != null && tsk.hasSkill("effects.bleeding"))
					|| (::Wuxia.hasMember(_targetEntity, "getMoraleState") && _targetEntity.getMoraleState() <= ::Const.MoraleState.Wavering);
				if (shakyOrBleed && this.m.DefStanceThisTurn < 4)
					this.m.DefStanceThisTurn = 4;
			}
			else if (smodeH == "armor_baize" && !_skill.isRanged())
			{
				this.m.BaizeRiposteReady = false;
			}
			else if (smodeH == "helm_siwang" && !_skill.isRanged() && tItems != null)
			{
				local isChargeOrHeavy = (_damageInflictedArmor >= 20) || (("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "push_advance"));
				if (isChargeOrHeavy)
				{
					local swB = tItems.getItemAtSlot(::Const.ItemSlot.Body);
					if (swB != null && swB.getArmor() > 0) swB.setArmor(::Math.max(0, swB.getArmor() - 8));
				}
			}
			else if (smodeH == "acc_wuluo" && ("CraftBridge" in ::Wuxia)
				&& (::Wuxia.CraftBridge.hasSkillMechanic(_skill, "step_through") || ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "push_advance")))
			{
				if (this.m.DefStanceThisTurn < 3)
					this.m.DefStanceThisTurn = 3;
			}
		}

		// 5. Overhauled Shan-Hai Weapon Spirits (`应龙 / 烛九阴 / 相柳 / 陆吾 / 夔牛`)
		if (("YinglongLightning" in cfg) && cfg.YinglongLightning && !_skill.isRanged() && ("CraftBridge" in ::Wuxia))
		{
			local wetOrPierce = ::Wuxia.CraftBridge.isWetOrConductiveEnv(actor, _targetEntity)
				|| ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "pierce_line");
			if (wetOrPierce)
			{
				local arcTarget = this.wxFindAdjacentEnemy(actor, _targetEntity);
				local shockEnt = (arcTarget != null) ? arcTarget : _targetEntity;
				if (shockEnt.getHitpoints() > 11)
					shockEnt.setHitpoints(shockEnt.getHitpoints() - (10 + mwFlat));
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(shockEnt) && ::Wuxia.hasMember(shockEnt, "getFatigue"))
					shockEnt.setFatigue(::Math.min(shockEnt.getFatigueMax(), shockEnt.getFatigue() + 6));
			}
		}

		if (("ZhuyinBladeCycle" in cfg) && cfg.ZhuyinBladeCycle && !_skill.isRanged())
		{
			if ((this.wxGetCurrentRound() % 2) == 1)
			{
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ::Wuxia.hasMember(_targetEntity, "getFatigue"))
					_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + 8));
				if (tsk != null && ::Math.rand(1, 100) <= (45 + mwPct))
					this.wxApplyStatusSafe(tsk, "effects.wx_status_frost_chill", "scripts/skills/effects/wx_status_frost_chill");
			}
			else if (tItems != null)
			{
				local zyB = tItems.getItemAtSlot(::Const.ItemSlot.Body);
				if (zyB != null && ::Wuxia.hasMember(zyB, "getArmor") && zyB.getArmor() > 0)
					zyB.setArmor(::Math.max(0, zyB.getArmor() - (14 + mwFlat)));
			}
		}

		if (("SpreadPoisonAdj" in cfg) && cfg.SpreadPoisonAdj && tsk != null)
		{
			local hasPoison = tsk.hasSkill("effects.wx_status_poison_dart") || tsk.hasSkill("effects.spider_poison") || tsk.hasSkill("effects.goblin_poison");
			if (hasPoison)
			{
				local adjP = this.wxFindAdjacentEnemy(actor, _targetEntity);
				if (adjP != null && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(adjP) && ::Wuxia.hasMember(adjP, "getSkills") && adjP.getSkills() != null)
					this.wxApplyStatusSafe(adjP.getSkills(), "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart");
			}
		}

		if (("LuwuFistMode" in cfg) && cfg.LuwuFistMode && !_skill.isRanged())
		{
			if (intercepting && tsk != null)
				this.wxApplyStatusSafe(tsk, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			if (("CraftBridge" in ::Wuxia) && (::Wuxia.CraftBridge.hasSkillMechanic(_skill, "concuss_armor") || _skill.getID().find("acupoint") != null))
				::Wuxia.CraftBridge.applyBossCounterHit(actor, _targetEntity, { BreakPts = 1 });
		}

		if (("AdjQiShock" in cfg) && cfg.AdjQiShock > 0 && !_skill.isRanged())
		{
			local adjQ = this.wxFindAdjacentEnemy(actor, _targetEntity);
			if (adjQ != null && !::Wuxia.CombatRules.isUndeadOrConstruct(adjQ) && ::Wuxia.hasMember(adjQ, "getFatigue"))
				adjQ.setFatigue(::Math.min(adjQ.getFatigueMax(), adjQ.getFatigue() + cfg.AdjQiShock));
		}

		if (("OnHeavyBossBreak" in cfg) && cfg.OnHeavyBossBreak > 0 && !_skill.isRanged()
			&& (_damageInflictedHitpoints >= 12 || _damageInflictedArmor >= 22) && ("CraftBridge" in ::Wuxia))
		{
			::Wuxia.CraftBridge.applyBossCounterHit(actor, _targetEntity, { BreakPts = cfg.OnHeavyBossBreak });
		}

		// 6. Standard Declarative GearTrait Triggers
		if (("OnHitArmorBurn" in cfg) && cfg.OnHitArmorBurn > 0 && tItems != null)
		{
			local tBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
			if (tBody != null && (::Wuxia.hasMember(tBody, "getArmor")) && tBody.getArmor() > 0)
				tBody.setArmor(::Math.max(0, tBody.getArmor() - (cfg.OnHitArmorBurn + mwFlat)));
		}

		if (("OnHitDrainQi" in cfg) && cfg.OnHitDrainQi > 0 && !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && (::Wuxia.hasMember(_targetEntity, "getFatigue")))
		{
			_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + cfg.OnHitDrainQi + (mwFlat > 0 ? 1 : 0)));
		}

		if (("OnHitSelfQi" in cfg) && cfg.OnHitSelfQi > 0 && this.m.SelfQiThisTurn < 2)
		{
			this.m.SelfQiThisTurn += 1;
			::Wuxia.CombatRules.restoreQi(actor, cfg.OnHitSelfQi);
		}

		if (!_skill.isRanged() && ("ShieldBreakBonus" in cfg) && cfg.ShieldBreakBonus > 0 && (::Wuxia.hasMember(_targetEntity, "isArmedWithShield")) && _targetEntity.isArmedWithShield())
		{
			local sh = tItems.getItemAtSlot(::Const.ItemSlot.Offhand);
			if (sh != null && ::Wuxia.hasMember(sh, "applyShieldDamage"))
				sh.applyShieldDamage(cfg.ShieldBreakBonus + mwFlat);
		}

		if (tsk != null)
		{
			if (("OnHitPoisonPct" in cfg) && cfg.OnHitPoisonPct > 0 && _damageInflictedHitpoints >= 4 && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity))
			{
				if (::Math.rand(1, 100) <= (cfg.OnHitPoisonPct + mwPct))
					this.wxApplyStatusSafe(tsk, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart");
			}
			if (("OnHitBleedPct" in cfg) && cfg.OnHitBleedPct > 0 && _damageInflictedHitpoints >= 4 && !::Wuxia.CombatRules.isImmuneToBleeding(_targetEntity))
			{
				if (::Math.rand(1, 100) <= (cfg.OnHitBleedPct + mwPct))
				{
					local bleed = ::new("scripts/skills/effects/bleeding_effect");
					bleed.setDamage(5);
					tsk.add(bleed);
				}
			}
			if (("OnHitOpeningPct" in cfg) && cfg.OnHitOpeningPct > 0 && ::Math.rand(1, 100) <= (cfg.OnHitOpeningPct + mwPct))
			{
				this.wxApplyStatusSafe(tsk, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			}
			if (("OnHitOffbalancePct" in cfg) && cfg.OnHitOffbalancePct > 0 && ::Math.rand(1, 100) <= (cfg.OnHitOffbalancePct + mwPct))
			{
				this.wxApplyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
			if (("OnHitOffbalanceHeavyPct" in cfg) && cfg.OnHitOffbalanceHeavyPct > 0 && (_damageInflictedHitpoints >= 14 || _damageInflictedArmor >= 25))
			{
				if (::Math.rand(1, 100) <= (cfg.OnHitOffbalanceHeavyPct + mwPct))
					this.wxApplyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
			if (("VsControlledDrainHP" in cfg) && cfg.VsControlledDrainHP > 0 && this.m.DrainHpThisTurn < 2 && !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
			{
				if (this.wxIsTargetControlled(tsk) && actor.getHitpoints() < actor.getHitpointsMax())
				{
					this.m.DrainHpThisTurn += 1;
					actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + cfg.VsControlledDrainHP));
				}
			}
		}
	}

	function onTargetKilled( _targetEntity, _skill )
	{
		local cfg = this.getTraitCfg();
		local qid = this.getAttachedQuenchID();
		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();
		if (::Wuxia.CombatRules.isSelfOrDyingKill(actor, _targetEntity)) return;

		if (qid == "blood" && this.m.QuenchHealTurn < 1 && (_targetEntity == null || !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity)))
		{
			this.m.QuenchHealTurn += 1;
			if (actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + 5));
		}

		if (cfg == null) return;

		local rmode = ("RelicMode" in cfg) ? cfg.RelicMode : "";
		local smodeK = ("ShanHaiMode" in cfg) ? cfg.ShanHaiMode : "";
		if (smodeK == "chiyou_wpn" && _targetEntity != null)
		{
			local adjFoe = this.wxFindAdjacentEnemy(actor, _targetEntity);
			if (adjFoe != null && !::Wuxia.CombatRules.isUndeadOrConstruct(adjFoe) && ::Wuxia.hasMember(adjFoe, "checkMorale"))
				adjFoe.checkMorale(-1, -10);
		}
		if (rmode == "chixiao")
		{
			this.wxRallyNearbyAllies(actor);
		}
		else if (rmode == "xiuchun")
		{
			this.m.NextRoundInitBonus = 12;
		}
		else if (rmode == "pochengyue" && this.m.KillHealsThisTurn < 2 && (_targetEntity == null || !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity)))
		{
			this.m.KillHealsThisTurn += 1;
			if (actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + 6));
			::Wuxia.CombatRules.restoreQi(actor, 3);
		}
		else if (rmode == "feidaonang" && this.m.AmmoRefundBattle < 3)
		{
			local fItemK = ("DirectItemRef" in this.m && this.m.DirectItemRef != null) ? this.m.DirectItemRef : this.getItem();
			if (fItemK != null && ::Wuxia.hasMember(fItemK, "m") && ::Wuxia.hasMember(fItemK.m, "Ammo") && fItemK.m.Ammo < fItemK.m.AmmoMax)
			{
				this.m.AmmoRefundBattle += 1;
				fItemK.m.Ammo = ::Math.min(fItemK.m.AmmoMax, fItemK.m.Ammo + 1);
			}
		}

		if (("OnKillQiRegen" in cfg) && cfg.OnKillQiRegen > 0)
		{
			::Wuxia.CombatRules.restoreQi(actor, cfg.OnKillQiRegen);
		}

		local cap = ("KillHealCap" in cfg) ? cfg.KillHealCap : 1;
		if (("OnKillHealHP" in cfg) && cfg.OnKillHealHP > 0 && this.m.KillHealsThisTurn < cap && (_targetEntity == null || !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity)))
		{
			this.m.KillHealsThisTurn += 1;
			if (actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + cfg.OnKillHealHP));
		}

		if (("OnKillRefundAmmo" in cfg) && cfg.OnKillRefundAmmo > 0)
		{
			local item = this.getItem();
			if (item != null && ::Wuxia.hasMember(item, "m") && (::Wuxia.hasMember(item.m, "Ammo")) && (::Wuxia.hasMember(item.m, "AmmoMax")) && item.m.Ammo < item.m.AmmoMax)
			{
				item.m.Ammo = ::Math.min(item.m.AmmoMax, item.m.Ammo + cfg.OnKillRefundAmmo);
			}
		}
	}
});
