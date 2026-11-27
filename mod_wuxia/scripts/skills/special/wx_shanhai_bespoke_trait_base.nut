// Base Class for Bespoke《山海经》Apex Boss Traits ("一妖一法相 · 一战一考题")
// Zero generic template permutations! Every single one of the 64 Bosses mounts its own `special.wx_boss_trait_<key>`
// driven by its original《山海经》scripture:
//   - Group I   (`segments`,   8 Bosses): True multi-tile coiled dragons & giant serpents (2~3 hexes)
//   - Group II  (`appendages`, 6 Bosses): True multi-headed / twin-serpent monsters (2~5 hexes)
//   - Group III (`totems`,    10 Bosses): Celestial / world-phenomenon deities with dedicated domain totems
//   - Group IV  (`mythic_law`,40 Bosses): Crisp 1-hex Apex Bosses with unique non-repeated combat laws & internal counter-breaks

this.wx_shanhai_bespoke_trait_base <- this.inherit("scripts/skills/skill", {
	m = {
		WX_IsShanHaiBossTrait = true,
		BossKey               = "",
		Spec                  = null,
		RoundCount            = 0,
		OrificeStacks         = 0, // Hundun《日凿七窍》counter (0..7)
		OrificeRuptured       = false,
		LastEnemySkills       = null, // Baize《通万物情》anti-repeat memory (last 3 skills)
		NamedPreyID           = -1,   // Xingxing《知人名》marked target ID
		PrevTileID            = -1,   // Zhujian / Yingzhao movement tracker
		TilesMovedThisTurn    = 0,
		MovedLastTurn         = false,
		StoneChimeStacks      = 0,    // Zheng《音如击石》& Mingshe《其音如磬》resonance counter
		NirvanaUsed           = false,// Yuanchu / Yayu / Erfu conditional rebirth tracker
		NirvanaPending        = false,
		IsChargingOmen        = false,
		OmenBreakPts          = 0,
		OmenBreakNeeded       = 3,
		BellyExposed          = false,// Xingtian《乳目脐口》/ Paoxiaowang《双腋露目》1-turn weakspot window
		KillAPUsedThisTurn    = false,
		SwapUsedThisTurn      = false,
		FollowUpUsedThisTurn  = false,
		BrokenPartsMap        = null,
		LawStacks             = 0,    // Bespoke per-Boss law counter (Bashe bones / Taotie gorge / Jinwu heat / Jiao qi / Zhuyan war-blood)
		SeasonIdx             = 0,    // Luwu《四时囿令》0..3 cycle
		DeafenedTurns         = 0,    // Changyou《四耳听风》sonic-deafen counterplay timer
		InternalBreakPts      = 0,    // 1-Hex Boss internal organ/shield/horn counter-break progress
		InternalBreakMax      = 0,
		InternalBroken        = false
	},

	function initBespokeBossTrait( _bossKey )
	{
		this.m.BossKey = _bossKey;
		this.m.ID = "special.wx_boss_trait_" + _bossKey;
		this.m.Icon = "ui/perks/wx_boss_trait_" + _bossKey + ".png";
		this.m.IconDisabled = "ui/perks/wx_boss_trait_" + _bossKey + "_sw.png";
		this.m.IconMini = "status_effect_74_mini";
		this.m.Type = this.Const.SkillType.Special | this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.Trait;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsHidden = false;
		this.m.IsSerialized = false;
		this.m.LastEnemySkills = [];
		this.m.BrokenPartsMap = {};

		local spec = ("ShanHaiBossSpecs" in ::Wuxia && (_bossKey in ::Wuxia.ShanHaiBossSpecs))
			? ::Wuxia.ShanHaiBossSpecs[_bossKey]
			: null;
		this.m.Spec = spec;
		if (spec != null)
		{
			this.m.Name = spec.TraitName;
			this.m.Description = spec.TraitDesc;
			if ("OmenBreakNeeded" in spec)
				this.m.OmenBreakNeeded = spec.OmenBreakNeeded;
			if ("InternalBreakMax" in spec)
				this.m.InternalBreakMax = spec.InternalBreakMax;
		}
	}

	function getSpec()
	{
		if (this.m.Spec == null && this.m.BossKey != "" && ("ShanHaiBossSpecs" in ::Wuxia) && (this.m.BossKey in ::Wuxia.ShanHaiBossSpecs))
			this.m.Spec = ::Wuxia.ShanHaiBossSpecs[this.m.BossKey];
		return this.m.Spec;
	}

	function isPartBroken( _partKey )
	{
		if (_partKey == null || _partKey == "") return this.m.InternalBroken;
		if (this.m.InternalBroken)
		{
			local spec = this.getSpec();
			if (spec != null && ("InternalPartKey" in spec) && spec.InternalPartKey == _partKey)
				return true;
		}
		return this.m.BrokenPartsMap != null && (_partKey in this.m.BrokenPartsMap) && this.m.BrokenPartsMap[_partKey];
	}

	function markInternalPartBroken( _actor )
	{
		if (this.m.InternalBroken) return;
		this.m.InternalBroken = true;
		local spec = this.getSpec();
		if (spec == null) return;

		local pKey = ("InternalPartKey" in spec) ? spec.InternalPartKey : "core_organ";
		local pName = ("InternalPartName" in spec) ? spec.InternalPartName : "本命要害";
		local pType = ("InternalPartType" in spec) ? spec.InternalPartType : "horn";
		this.m.BrokenPartsMap[pKey] <- true;

		if (_actor != null)
		{
			if ("CraftBridge" in ::Wuxia && "markBossPartBroken" in ::Wuxia.CraftBridge)
				::Wuxia.CraftBridge.markBossPartBroken(_actor, pType);
			if ("InternalLockedSkill" in spec && spec.InternalLockedSkill != "" && ("ShanHaiMultiBody" in ::Wuxia))
				::Wuxia.ShanHaiMultiBody.lockSkill(_actor, spec.InternalLockedSkill);
			local sk = ::Wuxia.hasMember(_actor, "getSkills") ? _actor.getSkills() : null;
			if (sk != null && !sk.hasSkill("effects.wx_status_opening"))
				sk.add(::new("scripts/skills/effects/wx_status_opening"));
		}

		if (::Wuxia.TileField.isLiveTactical() && "EventLog" in ::Tactical && ::Tactical.EventLog != null)
			::Tactical.EventLog.log("[color=#166b2f]【破法断器】" + pName + " 被克制兵刃一举击破，对应妖威随之崩解！[/color]");
	}

	function countAliveTotems( _actor )
	{
		local spec = this.getSpec();
		if (_actor == null || spec == null || !("StructureMode" in spec) || spec.StructureMode != "totems" || !("ShanHaiMultiBody" in ::Wuxia))
			return 0;
		local rec = ::Wuxia.ShanHaiMultiBody.getRecord(_actor);
		if (rec == null) return ("DefaultTotemCount" in spec) ? spec.DefaultTotemCount : 0;
		if (!::Wuxia.ShanHaiMultiBody.isLiveMap(_actor) && rec.Totems.len() == 0 && ("DefaultTotemCount" in spec))
			return ::Math.max(0, spec.DefaultTotemCount - this.m.BrokenPartsMap.len());
		local alive = 0;
		foreach (t in rec.Totems)
		{
			if (t != null && ::Wuxia.hasMember(t, "isAlive") && t.isAlive())
				alive += 1;
		}
		return alive;
	}

	function isTotemKeyAlive( _actor, _totemKey )
	{
		if (_actor == null || !("ShanHaiMultiBody" in ::Wuxia)) return false;
		if (this.isPartBroken(_totemKey)) return false;
		local rec = ::Wuxia.ShanHaiMultiBody.getRecord(_actor);
		if (rec == null || (!::Wuxia.ShanHaiMultiBody.isLiveMap(_actor) && rec.Totems.len() == 0))
			return true;
		foreach (t in rec.Totems)
		{
			if (t != null && ("m" in t) && ("WX_PartKey" in t.m) && t.m.WX_PartKey == _totemKey)
				return ::Wuxia.hasMember(t, "isAlive") && t.isAlive();
		}
		return false;
	}

	function spawnMultiBodyStructure( _actor )
	{
		local spec = this.getSpec();
		if (_actor == null || spec == null || !("StructureMode" in spec)) return;
		local mode = spec.StructureMode;
		if (mode == "segments" && ("Parts" in spec))
			::Wuxia.ShanHaiMultiBody.spawnCoiledSegments(_actor, spec.Parts);
		else if (mode == "appendages" && ("Parts" in spec))
			::Wuxia.ShanHaiMultiBody.spawnSeverableAppendages(_actor, spec.Parts);
		else if (mode == "totems" && ("Parts" in spec))
			::Wuxia.ShanHaiMultiBody.spawnDomainTotems(_actor, spec.Parts, ("TotemMinDist" in spec ? spec.TotemMinDist : 2), ("TotemMaxDist" in spec ? spec.TotemMaxDist : 4));
	}

	function onCombatStarted()
	{
		this.m.RoundCount = 0;
		this.m.OrificeStacks = 0;
		this.m.OrificeRuptured = false;
		this.m.LastEnemySkills = [];
		this.m.NamedPreyID = -1;
		this.m.PrevTileID = -1;
		this.m.TilesMovedThisTurn = 0;
		this.m.MovedLastTurn = false;
		this.m.StoneChimeStacks = 0;
		this.m.NirvanaUsed = false;
		this.m.NirvanaPending = false;
		this.m.IsChargingOmen = false;
		this.m.OmenBreakPts = 0;
		this.m.BellyExposed = false;
		this.m.KillAPUsedThisTurn = false;
		this.m.SwapUsedThisTurn = false;
		this.m.FollowUpUsedThisTurn = false;
		this.m.BrokenPartsMap = {};
		this.m.LawStacks = 0;
		this.m.SeasonIdx = 0;
		this.m.DeafenedTurns = 0;
		this.m.InternalBreakPts = 0;
		this.m.InternalBroken = false;

		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		local spec = this.getSpec();
		if (actor == null || spec == null) return;

		this.spawnMultiBodyStructure(actor);

		if ("InitFieldKind" in spec && spec.InitFieldKind != "" && ::Wuxia.isOnMap(actor))
		{
			local myTile = actor.getTile();
			::Wuxia.TileField.setField(myTile, spec.InitFieldKind, 3, actor);
			local spread = ("InitFieldCount" in spec) ? spec.InitFieldCount : 2;
			local placed = 0;
			for (local d = 0; d < 6 && placed < spread; d = ++d)
			{
				if (!myTile.hasNextTile(d)) continue;
				local nt = myTile.getNextTile(d);
				if (nt != null)
				{
					::Wuxia.TileField.setField(nt, spec.InitFieldKind, 3, actor);
					placed += 1;
				}
			}
		}
		if ("InitWeather" in spec && spec.InitWeather != "")
			::Wuxia.TileField.setWeather(spec.InitWeather, actor.getID(), 3);
	}

	function onSubPartBroken( _partKey )
	{
		this.m.BrokenPartsMap[_partKey] <- true;
		local spec = this.getSpec();
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor != null && spec != null && ("Parts" in spec))
		{
			local rec = ::Wuxia.ShanHaiMultiBody.getOrCreateRecord(actor, "segments");
			foreach (p in spec.Parts)
			{
				if (p.Key == _partKey && ("LockedSkillID" in p) && p.LockedSkillID != "")
					rec.LockedSkills[p.LockedSkillID] <- true;
			}
			// Hujiao broken coil drops soothing ichor cleansing poison from adjacent heroes!
			if (this.m.BossKey == "hujiao" && ::Wuxia.TileField.isLiveTactical() && ::Wuxia.isOnMap(actor))
			{
				foreach (u in ::Tactical.Entities.getAllInstancesAsArray())
				{
					if (u == null || !u.isAlive() || actor.isAlliedWith(u) || !::Wuxia.isOnMap(u)) continue;
					if (actor.getTile().getDistanceTo(u.getTile()) <= 2 && u.getSkills() != null)
						u.getSkills().removeByID("effects.wx_status_poison_dart");
				}
			}
		}
	}

	function onAppendageSevered( _partKey, _lockedSkill, _cauterized, _tile )
	{
		this.m.BrokenPartsMap[_partKey] <- true;
		local spec = this.getSpec();
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (spec != null && _tile != null && !_cauterized && ("SeverSpillField" in spec) && spec.SeverSpillField != "")
		{
			::Wuxia.TileField.setField(_tile, spec.SeverSpillField, 3, actor);
			// Jiufeng uncauterized severed bird-head feeds blood back to main body!
			if (this.m.BossKey == "jiufeng" && actor != null && actor.isAlive())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + 35));
		}
		// Shebishi losing both cyan ear-serpents drains 20% of corpse vitality!
		if (this.m.BossKey == "shebishi" && this.isPartBroken("snake_l") && this.isPartBroken("snake_r") && actor != null && actor.isAlive())
		{
			local drain = ::Math.max(30, ::Math.floor(actor.getHitpoints() * 0.20));
			actor.setHitpoints(::Math.max(1, actor.getHitpoints() - drain));
		}
		if (this.m.IsChargingOmen)
		{
			this.m.IsChargingOmen = false;
			this.m.OmenBreakPts = 0;
		}
	}

	function onTotemDestroyed( _partKey, _killer, _tile )
	{
		this.m.BrokenPartsMap[_partKey] <- true;
		local spec = this.getSpec();
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor == null) return;

		local backlash = (spec != null && "TotemBreakDmg" in spec) ? spec.TotemBreakDmg : 30;
		if (actor.getHitpoints() > backlash + 1)
			actor.setHitpoints(actor.getHitpoints() - backlash);
		else
			actor.setHitpoints(1);

		local sk = actor.getSkills();
		if (sk != null && !sk.hasSkill("effects.wx_status_opening"))
			sk.add(::new("scripts/skills/effects/wx_status_opening"));

		// Bespoke Totem-Break Myths:
		// 1) Kuafu's Denglin Peach Staffs burst sweet dew (+20 Qi & +15 HP to chopper!)
		if (this.m.BossKey == "kuafu" && _killer != null)
		{
			if (::Wuxia.hasMember(_killer, "getFatigue")) ::Wuxia.CombatRules.restoreQi(_killer, 20);
			if (::Wuxia.hasMember(_killer, "getHitpoints")) _killer.setHitpoints(::Math.min(_killer.getHitpointsMax(), _killer.getHitpoints() + 15));
		}
		// 2) Bingyi's twin Ice-Dragon Pillars shatter map-wide frost when both fall!
		else if (this.m.BossKey == "bingyi" && this.countAliveTotems(actor) <= 0 && _tile != null)
		{
			::Wuxia.TileField.dispelFieldsInRadius(_tile, 8, ["abyss_frost"]);
		}
		// 3) Jinwu's Fusang Sun shot down resets solar heat stacks!
		else if (this.m.BossKey == "jinwu")
		{
			this.m.LawStacks = 0;
		}

		if (this.m.IsChargingOmen)
		{
			this.m.IsChargingOmen = false;
			this.m.OmenBreakPts = 0;
		}
	}

	function onTurnStart()
	{
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		local spec = this.getSpec();
		if (actor == null || !actor.isAlive() || spec == null) return;

		this.m.RoundCount += 1;
		this.m.KillAPUsedThisTurn = false;
		this.m.SwapUsedThisTurn = false;
		this.m.FollowUpUsedThisTurn = false;
		this.m.BellyExposed = false;
		if (this.m.DeafenedTurns > 0) this.m.DeafenedTurns -= 1;

		if (spec.StructureMode == "segments" || (spec.StructureMode == "appendages" && this.m.BrokenPartsMap.len() == 0) || (spec.StructureMode == "totems" && this.m.BrokenPartsMap.len() == 0))
			this.spawnMultiBodyStructure(actor);

		// Track movement distance for Zhujian《行衔尾·居蟠尾》& Yingzhao《徇于四海》
		if (::Wuxia.isOnMap(actor) && actor.getTile() != null)
		{
			local curTile = actor.getTile();
			local curTID = ("ID" in curTile) ? curTile.ID : 0;
			this.m.MovedLastTurn = (this.m.PrevTileID != -1 && this.m.PrevTileID != curTID);
			this.m.PrevTileID = curTID;
		}
		this.m.TilesMovedThisTurn = 0;

		if (("TurnFieldKind" in spec) && spec.TurnFieldKind != "" && ::Wuxia.isOnMap(actor))
		{
			local mt = actor.getTile();
			::Wuxia.TileField.setField(mt, spec.TurnFieldKind, 3, actor);
		}

		if ("ShanHaiBossLaws" in ::Wuxia && "onBossTurnStart" in ::Wuxia.ShanHaiBossLaws)
			::Wuxia.ShanHaiBossLaws.onBossTurnStart(this, actor, spec);
	}

	function onUpdate( _properties )
	{
		local spec = this.getSpec();
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (spec == null) return;

		if (("MinAP" in spec) && spec.MinAP > _properties.ActionPoints)
			_properties.ActionPoints = ::Math.min(12, spec.MinAP);
		if (("ImmuneStun" in spec) && spec.ImmuneStun)
			_properties.IsImmuneToStun = true;
		if (("ImmuneDisarm" in spec) && spec.ImmuneDisarm)
			_properties.IsImmuneToDisarm = true;
		if (("ImmuneKnockback" in spec) && spec.ImmuneKnockback)
			_properties.IsImmuneToKnockBackAndGrab = true;
		if (("Headless" in spec) && spec.Headless)
			_properties.IsImmuneToCriticals = true;

		if ("ShanHaiBossLaws" in ::Wuxia && "onBossUpdate" in ::Wuxia.ShanHaiBossLaws)
			::Wuxia.ShanHaiBossLaws.onBossUpdate(this, actor, spec, _properties);
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		local spec = this.getSpec();
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (spec == null || _skill == null || !_skill.isAttack()) return;

		if ("ShanHaiBossLaws" in ::Wuxia && "onBossSkillUsed" in ::Wuxia.ShanHaiBossLaws)
			::Wuxia.ShanHaiBossLaws.onBossSkillUsed(this, actor, spec, _skill, _targetEntity, _properties);
	}

	function onBeforeDamageReceived( _attacker, _skill, _hitInfo, _properties )
	{
		local spec = this.getSpec();
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (spec == null || actor == null) return;

		if ("ShanHaiBossLaws" in ::Wuxia && "onBossBeforeDamage" in ::Wuxia.ShanHaiBossLaws)
			::Wuxia.ShanHaiBossLaws.onBossBeforeDamage(this, actor, spec, _attacker, _skill, _hitInfo, _properties);
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		local spec = this.getSpec();
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (spec == null || actor == null || _targetEntity == null) return;

		if ("ShanHaiBossLaws" in ::Wuxia && "onBossTargetHit" in ::Wuxia.ShanHaiBossLaws)
			::Wuxia.ShanHaiBossLaws.onBossTargetHit(this, actor, spec, _skill, _targetEntity, _damageInflictedHitpoints, _damageInflictedArmor);
	}

	function onTargetKilled( _targetEntity, _skill )
	{
		local spec = this.getSpec();
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (spec == null || actor == null || this.m.KillAPUsedThisTurn) return;
		if (("KillRefundAP" in spec) && spec.KillRefundAP > 0)
		{
			this.m.KillAPUsedThisTurn = true;
			actor.setActionPoints(::Math.min(12, actor.getActionPoints() + spec.KillRefundAP));
			if (("KillHealHP" in spec) && spec.KillHealHP > 0)
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + spec.KillHealHP));
		}
	}

	function getTooltip()
	{
		local spec = this.getSpec();
		local ret = [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description", text = this.getDescription() }
		];
		if (spec != null)
		{
			if ("CanonQuote" in spec && spec.CanonQuote != "")
				ret.push({ id = 9, type = "text", icon = "ui/icons/special.png", text = "《山海原典》：" + spec.CanonQuote });
			if (this.m.BossKey == "hundun")
				ret.push({ id = 10, type = "text", icon = "ui/icons/direct_damage.png", text = "【日凿七窍进度】：已凿开 [color=#c9382b]" + this.m.OrificeStacks + " / 7[/color] 窍" + (this.m.OrificeRuptured ? "（七窍已崩·黄囊已破！）" : "（以点穴/刺剑/短匕/分金锤凿满 7 窍立破浑沌！）") });
			else if (this.m.BossKey == "luwu")
			{
				local sNames = ["春生·司囿回春", "夏烈·赤阳焚甲", "秋杀·金风裂脉", "冬藏·玄冰返震"];
				ret.push({ id = 10, type = "text", icon = "ui/icons/special.png", text = "【当前帝囿四时节令】：[color=#d9822b]" + sNames[this.m.SeasonIdx % 4] + "[/color]" });
			}
			else if (this.m.BossKey == "taotie")
				ret.push({ id = 10, type = "text", icon = "ui/icons/health.png", text = "【饕餮饱食度】：[color=#c9382b]" + this.m.LawStacks + " / 4[/color]（满4层或误吞奇毒猎物当场触发『食人未咽·害及其身』裂腹反噬！）" });
			else if (this.m.InternalBreakMax > 0 && ("InternalPartName" in spec))
			{
				local stTxt = this.m.InternalBroken
					? "[color=#166b2f]已击破（对应凶威已废除）[/color]"
					: ("[color=#c9382b]" + this.m.InternalBreakPts + " / " + this.m.InternalBreakMax + "[/color]（以克制兵刃集火击破）");
				ret.push({ id = 10, type = "text", icon = "ui/icons/armor_body.png", text = "【本命破绽·" + spec.InternalPartName + "】：" + stTxt });
			}
			if (this.m.IsChargingOmen)
			{
				local rem = ::Math.max(0, this.m.OmenBreakNeeded - this.m.OmenBreakPts);
				ret.push({ id = 11, type = "text", icon = "ui/icons/warning.png", text = "[color=#c9382b]【山海异象蓄势中】尚需 " + rem + " 点克制破招值即可当场震断反噬！[/color]" });
			}
			if ("CounterHint" in spec && spec.CounterHint != "")
				ret.push({ id = 12, type = "text", icon = "ui/icons/warning.png", text = "【破局考题】" + spec.CounterHint });
		}
		return ret;
	}
});
