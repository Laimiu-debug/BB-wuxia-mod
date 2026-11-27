// The engine clamps current AP to this getter on every skill refresh.

::Wuxia.HooksMod.hook("scripts/entity/tactical/actor", function( q )
{
	if (::Wuxia.qHas(q, "getName"))
	{
		q.getName = @(__original) function()
		{
			local raw = __original();
			if ("Purify" in ::Wuxia && "formatLocatedActorName" in ::Wuxia.Purify && ("Name" in this.m) && ("Title" in this.m))
			{
				local fixed = ::Wuxia.Purify.formatLocatedActorName(this.m.Name, this.m.Title);
				if (fixed != null) return fixed;
			}
			return raw;
		};
	}

	q.checkMorale = @(__original) function( _change, _difficulty, _type = 0, _showIconBeforeMoraleIcon = "", _noNewLine = false )
	{
		if (_change < 0 && this.getSkills() != null)
		{
			local stance = this.getSkills().getSkillByID("actives.wx_neigong_junwu");
			if (stance != null && stance.m.ActiveBuff) return false;
		}
		local ret = __original(_change, _difficulty, _type, _showIconBeforeMoraleIcon, _noNewLine);
		if (ret && ("CombatRules" in ::Wuxia) && ("bumpTacticalAuraEpoch" in ::Wuxia.CombatRules))
			::Wuxia.CombatRules.bumpTacticalAuraEpoch();
		return ret;
	};

	q.onAttackOfOpportunity = @(__original) function( _entity, _isOnEnter )
	{
		if (!_isOnEnter && _entity != null && ("m" in _entity) && _entity.m != null
			&& ("WX_FreeDisengageRound" in _entity.m) && ("CraftBridge" in ::Wuxia)
			&& _entity.m.WX_FreeDisengageRound == ::Wuxia.CraftBridge.getCurrentRound())
		{
			return false;
		}
		local c = this.getSkills().getSkillByID("special.wx_martial_container");
		this.m.WX_IsIntercepting <- true;
		if (c != null) c.m.IsIntercepting = true;
		local hit;
		try { hit = __original(_entity, _isOnEnter); }
		catch (error)
		{
			this.m.WX_IsIntercepting = false;
			if (c != null) c.m.IsIntercepting = false;
			throw error;
		}
		this.m.WX_IsIntercepting = false;
		if (c != null) c.m.IsIntercepting = false;
		return hit;
	};

	q.getActionPointsMax = @(__original) function()
	{
		local baseMax = __original();
		local skills = this.getSkills();
		local container = skills == null ? null : skills.getSkillByID("special.wx_martial_container");
		if (container == null) return baseMax;
		local permanent = ::Math.min(::Wuxia.Config.Constants.MaxPermanentAP, baseMax + container.getPermanentAPBonus());
		return ::Math.min(::Wuxia.Config.Constants.MaxTemporaryAP, permanent + container.m.TemporaryAPOverflow);
	};

	q.onDeath = @(__original) function( _killer, _skill, _tile, _fatalityType )
	{
		if ("VFX" in ::Wuxia && "clearActorMotion" in ::Wuxia.VFX)
			::Wuxia.VFX.clearActorMotion(this);
		if ("KineticVFX" in ::Wuxia && "releaseActorBusy" in ::Wuxia.KineticVFX)
			::Wuxia.KineticVFX.releaseActorBusy(this);
		local isHandled = ("WX_DeathHandled" in this.m) && this.m.WX_DeathHandled;
		local wxSnap = isHandled ? null : ::Wuxia.Appearance.captureDeathLayers(this);
		local canDropBeast = (!this.isPlayerControlled() && !(("WX_IsBossSubEntity" in this.m) && this.m.WX_IsBossSubEntity) && _tile != null && _killer != null && _killer.isPlayerControlled() && !this.isAlliedWith(_killer));
		if (canDropBeast && ("CraftBridge" in ::Wuxia) && ("BeastCraft" in ::Wuxia) && this.getSkills() != null && this.getSkills().hasSkill("special.wx_shanhai_boss_trait"))
		{
			::Wuxia.BeastCraft.LastDyingBossSnap = ::Wuxia.CraftBridge.detectBrokenBossParts(this, _fatalityType);
		}
		if (!isHandled && wxSnap != null)
			::Wuxia.Appearance.restoreVanillaBrushesForDeath(this, _fatalityType, wxSnap);
		__original(_killer, _skill, _tile, _fatalityType);
		if ("CombatRules" in ::Wuxia && "bumpTacticalAuraEpoch" in ::Wuxia.CombatRules)
			::Wuxia.CombatRules.bumpTacticalAuraEpoch();
		if (!isHandled && wxSnap != null)
			::Wuxia.Appearance.applyWuxiaCorpseDecals(this, _tile, _fatalityType, wxSnap);
		::Wuxia.Appearance.ensurePostDeathPortraitSprite(this);
		if (canDropBeast && ("ShanHai" in ::Wuxia) && ("tryDropWildBeastLoot" in ::Wuxia.ShanHai))
			::Wuxia.ShanHai.tryDropWildBeastLoot(this, _tile);
		if (canDropBeast && ("BeastCraft" in ::Wuxia))
			::Wuxia.BeastCraft.tryDropWildBeastMaterial(this, _killer, _tile);
		if (("WX_GuHost" in this.m) && this.m.WX_GuHost && _tile != null && ("CraftBridge" in ::Wuxia))
		{
			this.m.WX_GuHost = false;
			::Wuxia.CraftBridge.triggerChildGuContagion(this, _tile);
		}
	};

	if (::Wuxia.qHas(q, "onRender"))
	{
		q.onRender = @(__original) function()
		{
			__original();
			if (("WX_Motion" in this.m) && this.m.WX_Motion != null && ("VFX" in ::Wuxia) && ("tickActorMotion" in ::Wuxia.VFX))
			{
				::Wuxia.VFX.tickActorMotion(this);
			}
		};
	}
	else
	{
		q.onRender <- function()
		{
			if (("WX_Motion" in this.m) && this.m.WX_Motion != null && ("VFX" in ::Wuxia) && ("tickActorMotion" in ::Wuxia.VFX))
			{
				::Wuxia.VFX.tickActorMotion(this);
			}
		};
	}

	if (::Wuxia.qHas(q, "onMovementStart"))
	{
		q.onMovementStart = @(__original) function( _tile, _numTiles )
		{
			this.m.WX_PreMoveTile <- this.isPlacedOnMap() ? this.getTile() : _tile;
			if (("WX_Motion" in this.m) && this.m.WX_Motion != null && ("VFX" in ::Wuxia) && ("clearActorMotion" in ::Wuxia.VFX))
				::Wuxia.VFX.clearActorMotion(this);
			return __original(_tile, _numTiles);
		};
	}

	if (::Wuxia.qHas(q, "onMovementFinish"))
	{
		q.onMovementFinish = @(__original) function( _tile )
		{
			local prevT = ("WX_PreMoveTile" in this.m) ? this.m.WX_PreMoveTile : null;
			if ("CombatRules" in ::Wuxia && "bumpTacticalAuraEpoch" in ::Wuxia.CombatRules)
				::Wuxia.CombatRules.bumpTacticalAuraEpoch();
			local ret = __original(_tile);
			if ("CombatRules" in ::Wuxia && "bumpTacticalAuraEpoch" in ::Wuxia.CombatRules)
				::Wuxia.CombatRules.bumpTacticalAuraEpoch();
			if (this.isAlive() && _tile != null)
			{
				if ("ShanHaiMultiBody" in ::Wuxia)
					::Wuxia.ShanHaiMultiBody.onMasterMoved(this, prevT, _tile);
				if ("TileField" in ::Wuxia)
					::Wuxia.TileField.onActorTileTick(this, _tile, false);
				if (("Streams" in ::Wuxia) && this.getSkills() != null && this.getSkills().hasSkill("special.wx_martial_container"))
				{
					local st = ::Wuxia.Streams.getOrCreateState(this);
					if (st != null) st.addWindSteps(1);
				}
			}
			return ret;
		};
	}

	if (::Wuxia.qHas(q, "onDamageReceived"))
	{
		q.onDamageReceived = @(__original) function( _attacker, _skill, _hitInfo )
		{
			local ret = __original(_attacker, _skill, _hitInfo);
			if (this.isAlive() && ("TileField" in ::Wuxia))
				::Wuxia.TileField.onActorDamagedOnTile(this);
			return ret;
		};
	}

	if (::Wuxia.qHas(q, "onPlacedOnMap"))
	{
		q.onPlacedOnMap = @(__original) function()
		{
			__original();
			if ("CombatRules" in ::Wuxia && "bumpTacticalAuraEpoch" in ::Wuxia.CombatRules)
				::Wuxia.CombatRules.bumpTacticalAuraEpoch();
			if ("ShanHai" in ::Wuxia && "ensureWildBeastTrait" in ::Wuxia.ShanHai)
				::Wuxia.ShanHai.ensureWildBeastTrait(this);
			if ("CombatRules" in ::Wuxia && "applyDynamicEnemyScaling" in ::Wuxia.CombatRules)
				::Wuxia.CombatRules.applyDynamicEnemyScaling(this);
		};
	}

	if (::Wuxia.qHas(q, "onTurnStart"))
	{
		q.onTurnStart = @(__original) function()
		{
			if ("CombatRules" in ::Wuxia && "bumpTacticalAuraEpoch" in ::Wuxia.CombatRules)
				::Wuxia.CombatRules.bumpTacticalAuraEpoch();
			__original();
			if ("VFX" in ::Wuxia && "ensureActorSpritesVisible" in ::Wuxia.VFX)
				::Wuxia.VFX.ensureActorSpritesVisible(this);
			if (this.isAlive() && this.isPlacedOnMap() && ("TileField" in ::Wuxia))
				::Wuxia.TileField.onActorTileTick(this, this.getTile(), true);
		};
	}

	if (::Wuxia.qHas(q, "onCombatFinished"))
	{
		q.onCombatFinished = @(__original) function()
		{
			if ("CombatRules" in ::Wuxia && "bumpTacticalAuraEpoch" in ::Wuxia.CombatRules)
				::Wuxia.CombatRules.bumpTacticalAuraEpoch();
			if (("WX_Motion" in this.m) && this.m.WX_Motion != null && ("VFX" in ::Wuxia) && ("clearActorMotion" in ::Wuxia.VFX))
				::Wuxia.VFX.clearActorMotion(this);
			if ("TileField" in ::Wuxia) ::Wuxia.TileField.clearAll();
			if ("ShanHaiMultiBody" in ::Wuxia) ::Wuxia.ShanHaiMultiBody.clearAll();
			return __original();
		};
	}

	q.getTooltip = @(__original) function( _targetedWithSkill = null )
	{
		local ret = __original(_targetedWithSkill);
		if (ret == null || typeof ret != "array") return ret;
		local skills = this.getSkills();
		if (skills == null) return ret;

		local shTrait = ("ShanHai" in ::Wuxia && "findBossTrait" in ::Wuxia.ShanHai) ? ::Wuxia.ShanHai.findBossTrait(skills) : skills.getSkillByID("special.wx_shanhai_boss_trait");
		if (shTrait != null)
		{
			ret.push({
				id = 97,
				type = "text",
				icon = shTrait.getIcon(),
				text = "[color=#721010]【山海凶威】" + shTrait.getName() + "[/color]"
			});
			if (("m" in shTrait) && ("IsCharging" in shTrait.m) && shTrait.m.IsCharging)
			{
				local remBrk = ::Math.max(0, 3 - shTrait.m.BreakProgress);
				ret.push({
					id = 99,
					type = "text",
					icon = "ui/icons/warning.png",
					text = "[color=#c9382b]【凶煞蓄势中】需 " + remBrk + " 点破招值（锤/杖/拳掌/点穴计2，普攻计1）打断反噬！[/color]"
				});
			}
			else if (("m" in shTrait) && ("IsChargingApocalypse" in shTrait.m) && shTrait.m.IsChargingApocalypse)
			{
				ret.push({
					id = 99,
					type = "text",
					icon = "ui/icons/warning.png",
					text = "[color=#c9382b]【十日同炙蓄咒中】速射落空中任意一轮『汤谷炙魂日冕』破咒反噬！[/color]"
				});
			}
			else if (("m" in shTrait) && ("IsInhalingWind" in shTrait.m) && shTrait.m.IsInhalingWind)
			{
				local remW = ::Math.max(0, 3 - shTrait.m.WindBreakProgress);
				ret.push({
					id = 99,
					type = "text",
					icon = "ui/icons/warning.png",
					text = "[color=#5c7cfa]【烛阴瞑夜吞风中】再以点穴/纯阳/破气击中 " + remW + " 点破招值即可截断朔风！[/color]"
				});
			}
		}

		if ("TileField" in ::Wuxia)
		{
			local tfTip = ::Wuxia.TileField.getActorStandingTooltip(this);
			if (tfTip != null)
			{
				ret.push({
					id = 93,
					type = "text",
					icon = "ui/icons/special.png",
					text = "[color=#125e48]" + tfTip + "[/color]"
				});
			}
		}

		local wbTrait = skills.getSkillByID("special.wx_wild_beast_trait");
		if (wbTrait != null)
		{
			ret.push({
				id = 95,
				type = "text",
				icon = wbTrait.getIcon(),
				text = "[color=#6e3b12]【荒兽异禀】" + wbTrait.getName() + "[/color]"
			});
		}

		local setRes = skills.getSkillByID("special.wx_shanhai_set_resonance");
		if (setRes != null && !setRes.isHidden())
		{
			ret.push({
				id = 98,
				type = "text",
				icon = setRes.getIcon(),
				text = "[color=#5e2c00]【" + setRes.getName() + "】[/color]"
			});
		}

		local c = skills.getSkillByID("special.wx_martial_container");
		if (c != null)
		{
			local cnt = 0;
			for (local i = 0; i < c.m.Slots.len(); i = ++i)
			{
				if (c.m.Slots[i].ManualID != null && c.m.Slots[i].Tier > 0) cnt += 1;
			}
			if (cnt > 0)
			{
				local elTxt = "外家把式";
				if (c.m.Slots[0].ManualID != null)
				{
					local mdef = ::Wuxia.Slots.getManualDef(c.m.Slots[0].ManualID);
					if (mdef != null && mdef.Element != null && (mdef.Element in ::Wuxia.Text.Elements))
						elTxt = ::Wuxia.Text.Elements[mdef.Element] + "内息";
				}
				local apBonus = c.getPermanentAPBonus();
				local apNote = apBonus > 0 ? (" · 破境 " + (9 + apBonus) + " AP") : "";
				ret.push({
					id = 96,
					type = "text",
					icon = "ui/wx_icons/wx_icon_qi.png",
					text = "[color=#094039]【武学气象】" + elTxt + " · 身怀 " + cnt + " 门功法" + apNote + "[/color]"
				});
			}
		}

		if (("WX_DynEra" in this.m) && this.m.WX_DynEra >= 1)
		{
			local eraLbl = ("WX_DynLabel" in this.m) ? this.m.WX_DynLabel : "江湖历战";
			ret.push({
				id = 94,
				type = "text",
				icon = "ui/icons/xp_received.png",
				text = "[color=#5e2c00]【江湖演进 · " + eraLbl + "】第 " + this.m.WX_DynEra + " 阶历战强敌[/color]"
			});
		}
		return ret;
	};
});
