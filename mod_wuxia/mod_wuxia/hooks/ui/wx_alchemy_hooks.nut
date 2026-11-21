// Backend Item, Status, UI, Shop & Loot Integration Hooks for Deepened Alchemy (八卦丹炉 · 百草药柜 · 丹毒上限 · 续脉造化)
// 100% Non-Destructive via Modern Hooks: seamlessly layers onto `wx_pill_item`, `wx_pill_battle_buff`, `wx_internal_injury`,
// `character_screen`, `world_screen_topbar_options_module`, `town_shop_dialog_module`, and `tactical_combat_result_screen`!

if (!("UI" in ::Wuxia))
	::Wuxia.UI <- {};

// -----------------------------------------------------------------------------
// 1. Hook `wx_internal_injury` (ensure compatibility aliases for MarrowWash)
// -----------------------------------------------------------------------------
::Wuxia.HooksMod.hook("scripts/skills/effects/wx_internal_injury", function( q )
{
	if (!("applyHeavyShock" in q))
	{
		q.applyHeavyShock <- function()
		{
			this.applySeverity(2, ::Wuxia.Config.MarrowWash.ShockDurationDays);
		};
	}
	if (!("applyPermanentDamage" in q))
	{
		q.applyPermanentDamage <- function()
		{
			this.addPermanentMeridianScar();
		};
	}
});

// -----------------------------------------------------------------------------
// 2. Hook `wx_pill_battle_buff`: Add 4 ShanHai Counter Elixirs + 2-Pill Dan-Toxin Overload Cap
//    (Preserves 1/2/3-byte varint U8 save compatibility AND keeps legacy direct `addPillBuff` selftest intact!)
// -----------------------------------------------------------------------------
::Wuxia.HooksMod.hook("scripts/skills/effects/wx_pill_battle_buff", function( q )
{
	q.m.HasBihuo          <- false; // 玄冰辟火丸: ShanHai fire/miasma aura immunity, -15% ranged dmg, +2 Qi rec
	q.m.HasYuji           <- false; // 玉肌止血散: Bleeding immunity, +25% injury threshold, +5 HP regen/turn
	q.m.HasLonghu         <- false; // 龙虎提纵散: +15 Initiative, +5 RangedDef, Knockback/Grab immunity
	q.m.HasFengmo         <- false; // 疯魔燃血丸: +15% Headshot, +15% ArmorDmg, +10% ArmorPen (capped at 25%), 2d post-battle light injury
	q.m.HasDanToxin       <- false; // 丹毒郁结: Triggered when consuming a 3rd non-Danxia battle pill (-15 Stamina, -3 Qi rec, 3d post-battle light injury)
	q.m.FengmoNoInjury    <- false; // 丹霞极品疯魔燃血丸免除战后 2 日内伤反噬
	q.m.PotencyScalePct   <- 100;   // 成丹/灵纹/丹霞药效倍率 (92..155)
	q.m.AuxMask           <- 0;     // 药引丹韵位掩码: 1=生机, 2=赤阳, 4=玄阴, 8=镇魂, 16=奇毒, 32=造化

	q.applyPillPotencyAndAux <- function( _potencyPct, _auxNature = "", _waiveFengmoInjury = false )
	{
		if (_potencyPct != null && _potencyPct > this.m.PotencyScalePct)
			this.m.PotencyScalePct = ::Math.min(160, _potencyPct);
		if (_waiveFengmoInjury)
			this.m.FengmoNoInjury = true;
		if (_auxNature != null && _auxNature != "" && ("Alchemy" in ::Wuxia.Config) && ("AuxInfusions" in ::Wuxia.Config.Alchemy) && (_auxNature in ::Wuxia.Config.Alchemy.AuxInfusions))
		{
			this.m.AuxMask = this.m.AuxMask | ::Wuxia.Config.Alchemy.AuxInfusions[_auxNature].Bit;
		}
		this.updateLabel();
	};

	q.countActiveBuffs <- function()
	{
		local n = 0;
		foreach (fld in [
			"HasQingxin", "HasHugu", "HasDingshen", "HasZhuyu", "HasDuheng", "HasDixiu",
			"HasBingxin", "HasGuiyuan", "HasBaishe", "HasJinzun", "HasHerbSwift", "HasHerbCalm",
			"HasBihuo", "HasYuji", "HasLonghu", "HasFengmo"
		])
		{
			if ((fld in this.m) && this.m[fld]) n += 1;
		}
		return n;
	};

	q.canAcceptBattlePill <- function( _kind, _actorName = "侠客" )
	{
		if (this.hasBuffKind(_kind))
			return { Ok = false, Reason = _actorName + " 体内已有同类丹药药力流转，无需重复服食。" };
		local cur = this.countActiveBuffs();
		if (cur >= 3)
			return { Ok = false, Reason = _actorName + " 体内已混杂 3 道备战药力（丹毒盈脉），绝不可再强吞第 4 枚备战灵丹！" };
		return {
			Ok               = true,
			WillTriggerToxin = (cur >= 2)
		};
	};

	q.applyDanToxinOverload <- function()
	{
		this.m.HasDanToxin = true;
		this.updateLabel();
	};

	q.addPillBuff = @(__original) function( _kind )
	{
		if (_kind == "buff_bihuo")       this.m.HasBihuo  = true;
		else if (_kind == "buff_yuji")   this.m.HasYuji   = true;
		else if (_kind == "buff_longhu") this.m.HasLonghu = true;
		else if (_kind == "buff_fengmo") this.m.HasFengmo = true;
		__original(_kind);
	};

	q.hasBuffKind = @(__original) function( _kind )
	{
		if (_kind == "buff_bihuo")  return this.m.HasBihuo;
		if (_kind == "buff_yuji")   return this.m.HasYuji;
		if (_kind == "buff_longhu") return this.m.HasLonghu;
		if (_kind == "buff_fengmo") return this.m.HasFengmo;
		return __original(_kind);
	};

	q.updateLabel = @(__original) function()
	{
		__original();
		local extra = [];
		if (this.m.HasBihuo)  extra.push("辟火");
		if (this.m.HasYuji)   extra.push("玉肌");
		if (this.m.HasLonghu) extra.push("提纵");
		if (this.m.HasFengmo) extra.push("疯魔");
		if (extra.len() > 0)
		{
			local extStr = this.wxJoin(extra, "·");
			if (this.m.Name == "丹药行气")
				this.m.Name = "丹力：" + extStr;
			else
				this.m.Name += "·" + extStr;
		}
		if (this.m.HasDanToxin && this.m.Name.find("丹毒") == null)
			this.m.Name += "（丹毒郁结）";
	};

	q.getSummaryLabels = @(__original) function()
	{
		local list = __original();
		if (this.m.HasBihuo)    list.push("玄冰辟火(抗灼瘴)");
		if (this.m.HasYuji)     list.push("玉肌止血(免割裂)");
		if (this.m.HasLonghu)   list.push("龙虎提纵(+15身法)");
		if (this.m.HasFengmo)   list.push("疯魔燃血(凶煞破甲)");
		if (this.m.PotencyScalePct >= 135) list.push("丹霞药力(" + this.m.PotencyScalePct + "%)");
		else if (this.m.PotencyScalePct >= 112) list.push("灵纹药力(" + this.m.PotencyScalePct + "%)");
		if ((this.m.AuxMask & 1) != 0)  list.push("生机丹韵(+3回血)");
		if ((this.m.AuxMask & 2) != 0)  list.push("赤阳丹韵(+8%破甲)");
		if ((this.m.AuxMask & 4) != 0)  list.push("玄阴丹韵(+2回气)");
		if ((this.m.AuxMask & 8) != 0)  list.push("镇魂丹韵(+6定力)");
		if ((this.m.AuxMask & 16) != 0) list.push("奇毒丹韵(淬毒)");
		if ((this.m.AuxMask & 32) != 0) list.push("造化丹韵(+8血+6气)");
		if (this.m.HasDanToxin) list.push("丹毒郁结(-15气)");
		return list;
	};

	q.getTooltip = @(__original) function()
	{
		local ret = __original();
		local pos = ::Const.UI.Color.PositiveValue;
		local neg = ::Const.UI.Color.NegativeValue;
		local sc  = this.m.PotencyScalePct / 100.0;
		if (this.m.PotencyScalePct >= 112)
		{
			local gLbl = this.m.PotencyScalePct >= 135 ? "丹霞极品" : "灵纹上品";
			ret.push({ id = 21, type = "text", icon = "ui/icons/xp_received.png", text = "【" + gLbl + "丹火加持】体内灵丹数值药效已增幅至 [color=" + pos + "]" + this.m.PotencyScalePct + "%[/color]！" });
		}
		if (this.m.HasBihuo)
			ret.push({ id = 22, type = "text", icon = "ui/icons/armor_body.png", text = "【玄冰辟火丸】免疫山海凶兽毒火灼甲与蒸气光环，远射受击 [color=" + pos + "]-15%[/color]，回气 [color=" + pos + "]+" + ::Math.round(2 * sc) + "[/color]" });
		if (this.m.HasYuji)
			ret.push({ id = 23, type = "text", icon = "ui/icons/health.png", text = "【玉肌止血散】全程免疫流血割裂，外伤承受阈值 [color=" + pos + "]+25%[/color]，每回合初自愈 [color=" + pos + "]" + ::Math.round(5 * sc) + "[/color] 点气血" });
		if (this.m.HasLonghu)
			ret.push({ id = 24, type = "text", icon = "ui/icons/initiative.png", text = "【龙虎提纵散】轻功身法 [color=" + pos + "]+" + ::Math.round(15 * sc) + "[/color]，避暗 [color=" + pos + "]+" + ::Math.min(7, ::Math.round(5 * sc)) + "[/color]，免击退与巨蟒缠拽" });
		if (this.m.HasFengmo)
			ret.push({ id = 25, type = "text", icon = "ui/icons/chance_to_hit_head.png", text = "【疯魔燃血丸】取首率 [color=" + pos + "]+15%[/color]，破甲 [color=" + pos + "]+" + ::Math.round(15 * sc) + "%[/color]，穿甲 [color=" + pos + "]+10%[/color]（受 25% 封顶约束；" + (this.m.FengmoNoInjury ? "丹霞无瑕已免战后内伤！" : "战后留 2 日轻内伤") + "）" });
		if ((this.m.AuxMask & 1) != 0)
			ret.push({ id = 26, type = "text", icon = "ui/icons/health.png", text = "【生机丹韵】每回合初额外温养自愈 [color=" + pos + "]+3[/color] 气血" });
		if ((this.m.AuxMask & 2) != 0)
			ret.push({ id = 27, type = "text", icon = "ui/icons/armor_damage.png", text = "【赤阳丹韵】纯阳药引催劲，攻击破甲效能 [color=" + pos + "]+8%[/color]" });
		if ((this.m.AuxMask & 4) != 0)
			ret.push({ id = 28, type = "text", icon = "ui/icons/fatigue.png", text = "【玄阴丹韵】寒髓润脉，每回合额外回气 [color=" + pos + "]+2[/color]" });
		if ((this.m.AuxMask & 8) != 0)
			ret.push({ id = 30, type = "text", icon = "ui/icons/bravery.png", text = "【镇魂丹韵】定力 [color=" + pos + "]+6[/color]，抗惊骇检定额外 [color=" + pos + "]+8[/color]" });
		if ((this.m.AuxMask & 16) != 0)
			ret.push({ id = 31, type = "text", icon = "ui/icons/special.png", text = "【奇毒丹韵】伤血 ≥5 时有 [color=" + pos + "]25%[/color] 概率附着【暗器奇毒】" });
		if ((this.m.AuxMask & 32) != 0)
			ret.push({ id = 32, type = "text", icon = "ui/icons/health.png", text = "【造化丹韵】临时气血上限 [color=" + pos + "]+8[/color]、内息上限 [color=" + pos + "]+6[/color]" });
		if (this.m.HasDanToxin)
			ret.push({ id = 29, type = "text", icon = "ui/icons/warning.png", text = "[color=" + neg + "]【丹毒郁结】超量混服第 3 枚备战丹：内息上限 -15、回气 -3，战后必染 3 日内伤！[/color]" });
		return ret;
	};

	q.onTurnStart <- function()
	{
		local container = this.getContainer();
		local actor = container != null ? container.getActor() : null;
		if (actor == null || !actor.isAlive()) return;
		local sc = this.m.PotencyScalePct / 100.0;

		if (this.m.HasYuji)
		{
			if (container.hasSkill("effects.bleeding"))
				container.removeByID("effects.bleeding");
			if (actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + ::Math.round(5 * sc)));
		}
		if ((this.m.AuxMask & 1) != 0 && actor.getHitpoints() < actor.getHitpointsMax())
		{
			actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + 3));
		}
		if (this.m.HasBihuo && actor.getFatigue() > 0)
		{
			actor.setFatigue(::Math.max(0, actor.getFatigue() - ::Math.round(2 * sc)));
		}
		if ((this.m.AuxMask & 4) != 0 && actor.getFatigue() > 0)
		{
			actor.setFatigue(::Math.max(0, actor.getFatigue() - 2));
		}
	};

	q.onTargetHit <- function( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		if ((this.m.AuxMask & 16) == 0 || _skill == null || !_skill.isAttack() || _damageInflictedHitpoints < 5)
			return;
		local container = this.getContainer();
		local actor = container != null ? container.getActor() : null;
		if (actor == null || _targetEntity == null || !_targetEntity.isAlive() || actor.isAlliedWith(_targetEntity))
			return;
		if (::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity))
			return;
		if (::Math.rand(1, 100) <= 25 && (::Wuxia.hasMember(_targetEntity, "getSkills")) && _targetEntity.getSkills() != null)
		{
			local tsk = _targetEntity.getSkills();
			local ex = tsk.getSkillByID("effects.wx_status_poison_dart");
			if (ex == null) tsk.add(::new("scripts/skills/effects/wx_status_poison_dart"));
			else if ("resetDuration" in ex) ex.resetDuration();
		}
	};

	q.onUpdate = @(__original) function( _properties )
	{
		local prevStam = _properties.Stamina;
		local prevBrav = _properties.Bravery;
		local prevHP   = _properties.Hitpoints;
		local prevInit = _properties.Initiative;
		local prevRDef = _properties.RangedDefense;
		local prevRec  = _properties.FatigueRecoveryRate;
		__original(_properties);

		local sc = this.m.PotencyScalePct / 100.0;
		if (sc > 1.02 || sc < 0.98)
		{
			local dStam = _properties.Stamina - prevStam;
			local dBrav = _properties.Bravery - prevBrav;
			local dHP   = _properties.Hitpoints - prevHP;
			local dInit = _properties.Initiative - prevInit;
			local dRec  = _properties.FatigueRecoveryRate - prevRec;
			if (dStam > 0) _properties.Stamina = prevStam + ::Math.round(dStam * sc);
			if (dBrav > 0) _properties.Bravery = prevBrav + ::Math.round(dBrav * sc);
			if (dHP > 0)   _properties.Hitpoints = prevHP + ::Math.round(dHP * sc);
			if (dInit > 0) _properties.Initiative = prevInit + ::Math.round(dInit * sc);
			if (dRec > 0)  _properties.FatigueRecoveryRate = prevRec + ::Math.round(dRec * sc);
		}

		if (this.m.HasBihuo)
		{
			_properties.DamageReceivedRangedMult *= 0.85;
			local bihuoRec = ::Math.round(2 * sc);
			if (_properties.FatigueRecoveryRate - prevRec < bihuoRec)
				_properties.FatigueRecoveryRate = prevRec + bihuoRec;
		}
		if (this.m.HasYuji)
		{
			_properties.ThresholdToReceiveInjuryMult *= 1.25;
			if ("IsImmuneToBleeding" in _properties)
				_properties.IsImmuneToBleeding = true;
		}
		if (this.m.HasLonghu)
		{
			local wantInit = ::Math.round(15 * sc);
			local curInitGain = _properties.Initiative - prevInit;
			if (curInitGain < wantInit)
				_properties.Initiative += (wantInit - curInitGain);
			local wantRDef = ::Math.min(7, ::Math.round(5 * sc));
			local curRDefGain = _properties.RangedDefense - prevRDef;
			if (curRDefGain < wantRDef)
				_properties.RangedDefense += (wantRDef - curRDefGain);
			_properties.IsImmuneToKnockBackAndGrab = true;
		}
		if (this.m.HasFengmo)
		{
			if ("HitChance" in _properties && typeof _properties.HitChance == "array" && _properties.HitChance.len() > ::Const.BodyPart.Head)
				_properties.HitChance[::Const.BodyPart.Head] += 15;
			_properties.DamageArmorMult += (0.15 * sc);
			// Strictly respect global +25% total extra armor penetration ceiling per AGENTS.md!
			local curAdd = _properties.DamageDirectAdd;
			local room = (0.25 > curAdd) ? (0.25 - curAdd) : 0.0;
			local addPen = (0.10 < room) ? 0.10 : room;
			if (addPen > 0.0)
				_properties.DamageDirectAdd += addPen;
		}

		// Apply Auxiliary Herb Nature Side-Effects (`药引丹韵`)
		if ((this.m.AuxMask & 2) != 0)
			_properties.DamageArmorMult += 0.08;
		if ((this.m.AuxMask & 4) != 0)
			_properties.FatigueRecoveryRate += 2;
		if ((this.m.AuxMask & 8) != 0)
		{
			_properties.Bravery += 6;
			if (("MoraleCheckBravery" in _properties) && typeof _properties.MoraleCheckBravery == "array" && _properties.MoraleCheckBravery.len() > 0)
				_properties.MoraleCheckBravery[0] += 8;
		}
		if ((this.m.AuxMask & 32) != 0)
		{
			_properties.Hitpoints += 8;
			_properties.Stamina += 6;
		}

		if (this.m.HasDanToxin)
		{
			_properties.Stamina -= 15;
			_properties.FatigueRecoveryRate -= 3;
		}
	};

	q.onCombatFinished = @(__original) function()
	{
		local container = this.getContainer();
		local needFengmoInj = (this.m.HasFengmo && !this.m.FengmoNoInjury);
		if (container != null && (needFengmoInj || this.m.HasDanToxin))
		{
			local actor = container.getActor();
			if (actor != null && actor.isAlive())
			{
				local days = this.m.HasDanToxin ? 3 : 2;
				local inj = container.getSkillByID("effects.wx_internal_injury");
				if (inj == null)
				{
					inj = ::new("scripts/skills/effects/wx_internal_injury");
					container.add(inj);
				}
				inj.applySeverity(1, days);
			}
		}
		__original();
	};

	// Clean 1/2/3/5-byte varint U8 stream (100% compatible with old 1/2/3-byte saves!)
	q.onSerialize = @(__original) function( _out )
	{
		this.skill.onSerialize(_out);
		local mask1 = (this.m.HasQingxin ? 1 : 0)
			| (this.m.HasHugu ? 2 : 0)
			| (this.m.HasDingshen ? 4 : 0)
			| (((::Wuxia.hasMember(this.m, "HasZhuyu")) && this.m.HasZhuyu) ? 8 : 0)
			| (((::Wuxia.hasMember(this.m, "HasDuheng")) && this.m.HasDuheng) ? 16 : 0)
			| (((::Wuxia.hasMember(this.m, "HasDixiu")) && this.m.HasDixiu) ? 32 : 0)
			| (((::Wuxia.hasMember(this.m, "HasBingxin")) && this.m.HasBingxin) ? 64 : 0);

		local mask2 = (((::Wuxia.hasMember(this.m, "HasGuiyuan")) && this.m.HasGuiyuan) ? 1 : 0)
			| (((::Wuxia.hasMember(this.m, "HasBaishe")) && this.m.HasBaishe) ? 2 : 0)
			| (((::Wuxia.hasMember(this.m, "HasJinzun")) && this.m.HasJinzun) ? 4 : 0)
			| (((::Wuxia.hasMember(this.m, "HasHerbSwift")) && this.m.HasHerbSwift) ? 8 : 0)
			| (((::Wuxia.hasMember(this.m, "HasHerbCalm")) && this.m.HasHerbCalm) ? 16 : 0)
			| (this.m.HasBihuo ? 32 : 0)
			| (this.m.HasYuji ? 64 : 0);

		local mask3 = (this.m.HasLonghu ? 1 : 0)
			| (this.m.HasFengmo ? 2 : 0)
			| (this.m.HasDanToxin ? 4 : 0)
			| (this.m.FengmoNoInjury ? 8 : 0);

		local hasExt = (this.m.AuxMask != 0 || this.m.PotencyScalePct != 100);

		if (hasExt)
		{
			_out.writeU8(mask1 | 128);
			_out.writeU8(mask2 | 128);
			_out.writeU8(mask3 | 128);
			_out.writeU8(this.m.AuxMask & 63);
			_out.writeU8(::Math.max(80, ::Math.min(200, this.m.PotencyScalePct)));
		}
		else if (mask3 != 0)
		{
			_out.writeU8(mask1 | 128);
			_out.writeU8(mask2 | 128);
			_out.writeU8(mask3);
		}
		else if (mask2 != 0)
		{
			_out.writeU8(mask1 | 128);
			_out.writeU8(mask2);
		}
		else
		{
			_out.writeU8(mask1);
		}
	};

	q.onDeserialize = @(__original) function( _in )
	{
		this.skill.onDeserialize(_in);
		local mask1 = _in.readU8();
		local mask2 = ((mask1 & 128) != 0) ? _in.readU8() : 0;
		local mask3 = ((mask2 & 128) != 0) ? _in.readU8() : 0;
		local hasExt = ((mask3 & 128) != 0);

		this.m.HasQingxin   = (mask1 & 1)  != 0;
		this.m.HasHugu      = (mask1 & 2)  != 0;
		this.m.HasDingshen  = (mask1 & 4)  != 0;
		this.m.HasZhuyu     = (mask1 & 8)  != 0;
		this.m.HasDuheng    = (mask1 & 16) != 0;
		this.m.HasDixiu     = (mask1 & 32) != 0;
		this.m.HasBingxin   = (mask1 & 64) != 0;

		this.m.HasGuiyuan   = (mask2 & 1)  != 0;
		this.m.HasBaishe    = (mask2 & 2)  != 0;
		this.m.HasJinzun    = (mask2 & 4)  != 0;
		this.m.HasHerbSwift = (mask2 & 8)  != 0;
		this.m.HasHerbCalm  = (mask2 & 16) != 0;
		this.m.HasBihuo     = (mask2 & 32) != 0;
		this.m.HasYuji      = (mask2 & 64) != 0;

		this.m.HasLonghu      = (mask3 & 1) != 0;
		this.m.HasFengmo      = (mask3 & 2) != 0;
		this.m.HasDanToxin    = (mask3 & 4) != 0;
		this.m.FengmoNoInjury = (mask3 & 8) != 0;

		if (hasExt)
		{
			this.m.AuxMask         = _in.readU8() & 63;
			this.m.PotencyScalePct = _in.readU8();
		}
		else
		{
			this.m.AuxMask         = 0;
			this.m.PotencyScalePct = 100;
		}
		this.updateLabel();
	};
});

// -----------------------------------------------------------------------------
// 3. Hook `wx_pill_item`: Support `生生造化丹`, `黑玉断续膏`, `忘尘归元散` & 2-Pill Dan-Toxin Cap!
// -----------------------------------------------------------------------------
::Wuxia.HooksMod.hook("scripts/items/misc/wx_pill_item", function( q )
{
	q.isDirectConsumeKind = @(__original) function( _kind )
	{
		if (_kind == "cure_perm_scar" || _kind == "cure_perm_injury" || _kind == "wangchen_grace")
			return true;
		return __original(_kind);
	};

	q.getTooltip = @(__original) function()
	{
		local ret = __original();
		if (this.m.PillID in ::Wuxia.Config.Pills)
		{
			local def = ::Wuxia.Config.Pills[this.m.PillID];
			if (def.Kind == "marrow_wash_supreme" || def.Kind == "marrow_wash_yijin")
			{
				ret.push({
					id = 16,
					type = "text",
					icon = "ui/icons/bravery.png",
					text = "用法：在「武学修为」页点击「✦ 洗经伐髓」即可择丹启用"
				});
			}
			else if (def.Kind != null && def.Kind.find("buff_") == 0)
			{
				ret.push({
					id = 17,
					type = "text",
					icon = "ui/icons/special.png",
					text = "丹毒法度：单人稳妥承载 [color=" + ::Const.UI.Color.PositiveValue + "]2 种[/color] 备战药力；强吞第 3 枚将致「丹毒郁结」"
				});
			}
		}
		return ret;
	};

	q.applyToActorWithMessage = @(__original) function( _actor )
	{
		if (_actor == null || !(this.m.PillID in ::Wuxia.Config.Pills))
			return { Ok = false, Reason = "无效的侠客或丹药配置。" };

		local def = ::Wuxia.Config.Pills[this.m.PillID];
		local skills = _actor.getSkills();
		if (skills == null)
			return { Ok = false, Reason = "无法读取角色状态。" };

		if (def.Kind == "cure_perm_scar")
		{
			local injScar = skills.getSkillByID("effects.wx_internal_injury");
			if (injScar == null || injScar.m.PermanentScars <= 0)
				return { Ok = false, Reason = _actor.getName() + " 奇经八脉并无永久暗疾，无需耗费珍稀的「" + def.Name + "」（寻常内伤服护心丹即可）。" };

			injScar.m.PermanentScars = ::Math.max(0, injScar.m.PermanentScars - 1);
			injScar.cureTemporary();
			if (skills.hasSkill("effects.wx_scatter_weakness"))
				skills.removeByID("effects.wx_scatter_weakness");
			if (_actor.getHitpoints() < _actor.getHitpointsMax())
				_actor.setHitpoints(_actor.getHitpointsMax());
			skills.update();
			return {
				Ok      = true,
				Message = _actor.getName() + " 服下旷世奇药「" + def.Name + "」，枯脉逢春，彻底拔除 1 处永久「经脉暗疾」并涤尽内伤！"
			};
		}

		if (def.Kind == "cure_perm_injury")
		{
			local perms = skills.getAllSkillsOfType(::Const.SkillType.PermanentInjury);
			if (perms.len() == 0)
				return { Ok = false, Reason = _actor.getName() + " 筋骨完好并无永久伤残，无需耗费珍稀的「" + def.Name + "」。" };

			local pName = perms[0].getName();
			perms[0].removeSelf();

			local tempWounds = skills.getAllSkillsOfType(::Const.SkillType.TemporaryInjury);
			for (local wi = 0; wi < tempWounds.len(); wi = ++wi)
				tempWounds[wi].removeSelf();

			if (_actor.getHitpoints() < _actor.getHitpointsMax())
				_actor.setHitpoints(_actor.getHitpointsMax());
			skills.update();
			if (::Wuxia.hasMember(_actor, "updateInjuryVisuals"))
				_actor.updateInjuryVisuals();
			return {
				Ok      = true,
				Message = _actor.getName() + " 敷服圣药「" + def.Name + "」，断骨重续，陈年永久伤残「" + pName + "」竟彻底痊愈！"
			};
		}

		if (def.Kind == "wangchen_grace")
		{
			if (skills.hasSkill("effects.wx_scatter_weakness"))
			{
				skills.removeByID("effects.wx_scatter_weakness");
				if ((::Wuxia.hasMember(this, "getPillGrade")) && this.getPillGrade() >= 3)
				{
					local injW = skills.getSkillByID("effects.wx_internal_injury");
					if (injW != null && injW.m.Severity > 0) injW.cureTemporary();
				}
				skills.update();
				return {
					Ok      = true,
					Message = _actor.getName() + " 服下「" + this.getName() + "」，丹田紊乱顷刻归元，立解「散功虚弱」！"
				};
			}
			if (skills.hasSkill("effects.wx_wangchen_grace"))
				return { Ok = false, Reason = _actor.getName() + " 体内已有「归元护脉」药力，下一次换装功法已免散功调息，无需重复服药。" };

			if ((::Wuxia.hasMember(this, "getPillGrade")) && this.getPillGrade() >= 3)
			{
				local injW2 = skills.getSkillByID("effects.wx_internal_injury");
				if (injW2 != null && injW2.m.Severity > 0) injW2.cureTemporary();
			}
			skills.add(::new("scripts/skills/effects/wx_wangchen_grace"));
			skills.update();
			return {
				Ok      = true,
				Message = _actor.getName() + " 服下「" + this.getName() + "」，凝结「归元护脉」——下一次换装或卸下任意武学免除全部散功调息！"
			};
		}

		if (def.Kind != null && def.Kind.find("buff_") == 0)
		{
			local buff = skills.getSkillByID("effects.wx_pill_battle_buff");
			local willToxin = false;
			local isDanxiaPure = ((::Wuxia.hasMember(this, "getPillGrade")) && this.getPillGrade() >= 3);
			if (buff != null && ("canAcceptBattlePill" in buff))
			{
				local chk = buff.canAcceptBattlePill(def.Kind, _actor.getName());
				if (!chk.Ok) return chk;
				willToxin = chk.WillTriggerToxin && !isDanxiaPure;
			}
			local res = __original(_actor);
			if (res.Ok && willToxin)
			{
				local buffAfter = skills.getSkillByID("effects.wx_pill_battle_buff");
				if (buffAfter != null && ("applyDanToxinOverload" in buffAfter))
				{
					buffAfter.applyDanToxinOverload();
					skills.update();
					res.Message += "（警告：混服第 3 道备战药力引发【丹毒郁结】，本战内息上限 -15、回气 -3 且战后染轻内伤！）";
				}
			}
			else if (res.Ok && isDanxiaPure && buff != null && buff.countActiveBuffs() >= 3)
			{
				res.Message += "（【丹霞无瑕】药性纯净圆融，稳妥兼容第 3 道备战药力而未引发丹毒郁结！）";
			}
			return res;
		}

		return __original(_actor);
	};
});

// -----------------------------------------------------------------------------
// 4. Cabinet Infusable Cores & Spirit Herbs + Bagua Cauldron UI Endpoints
// -----------------------------------------------------------------------------
::Wuxia.Alchemy.getCabinetInfusableItems <- function()
{
	local out = [];
	if ("ShanHaiCores" in ::Wuxia.Config)
	{
		local cids = [];
		foreach (cid, _d in ::Wuxia.Config.ShanHaiCores) cids.push(cid);
		cids.sort();
		for (local i = 0; i < cids.len(); i = ++i)
		{
			local id = cids[i];
			local cnt = ::Wuxia.Alchemy.Cabinet.getCount("core:" + id);
			if (cnt > 0)
			{
				local cdef = ::Wuxia.Config.ShanHaiCores[id];
				out.push({
					CabKey    = "core:" + id,
					Kind      = "core",
					SubID     = id,
					Count     = cnt,
					Name      = cdef.Name,
					Icon      = (cdef.CustomIcon != null && cdef.CustomIcon != "") ? cdef.CustomIcon : cdef.Icon,
					ExpAmount = cdef.ExpAmount,
					Desc      = cdef.Description
				});
			}
		}
	}
	if ("Herbs" in ::Wuxia.Config)
	{
		local hids = [];
		foreach (hid, hd in ::Wuxia.Config.Herbs)
		{
			if (hd.Kind == "herb_infuse") hids.push(hid);
		}
		hids.sort();
		for (local h = 0; h < hids.len(); h = ++h)
		{
			local hid2 = hids[h];
			local hcnt = ::Wuxia.Alchemy.Cabinet.getCount("herb:" + hid2);
			if (hcnt > 0)
			{
				local hdef = ::Wuxia.Config.Herbs[hid2];
				out.push({
					CabKey    = "herb:" + hid2,
					Kind      = "herb",
					SubID     = hid2,
					Count     = hcnt,
					Name      = hdef.Name,
					Icon      = hdef.Icon,
					ExpAmount = hdef.ExpAmount,
					Desc      = hdef.Description
				});
			}
		}
	}
	return out;
};

if ("buildStashPillsData" in ::Wuxia.UI)
{
	local origBuildStashPills = ::Wuxia.UI.buildStashPillsData;
	::Wuxia.UI.buildStashPillsData = function()
	{
		local res = origBuildStashPills();
		if (res == null || !("pills" in res)) return res;

		local stashItems = (("World" in getroottable()) && ::World != null && ::World.Assets != null && ::World.Assets.getStash() != null)
			? ::World.Assets.getStash().getItems()
			: null;

		for (local i = 0; i < res.pills.len(); i = ++i)
		{
			local p = res.pills[i];
			if (p.pillKind == "marrow_wash_supreme" || p.pillKind == "marrow_wash_yijin")
			{
				p.itemKind = "pill_wash";
				p.qualityLabel = "洗髓奇药";
				res.washPillCount += 1;
			}
			if (stashItems != null && p.stashIndex >= 0 && p.stashIndex < stashItems.len())
			{
				local liveIt = stashItems[p.stashIndex];
				if (liveIt != null && liveIt.getID() == "misc.wx_pill_item")
				{
					p.name = liveIt.getName();
					if (::Wuxia.hasMember(liveIt, "getEffectiveExpAmount") && p.itemKind == "pill_infuse")
						p.expAmount = liveIt.getEffectiveExpAmount();
					if (::Wuxia.hasMember(liveIt, "getRichDescription"))
						p.description = liveIt.getRichDescription();
					if (::Wuxia.hasMember(liveIt, "getPillGrade"))
					{
						local pg = liveIt.getPillGrade();
						if (pg >= 3) p.quality = "unique";
						else if (pg == 2 && p.quality == "sect") p.quality = "secret";
					}
				}
			}
		}

		local cabInf = ::Wuxia.Alchemy.getCabinetInfusableItems();
		for (local ci = 0; ci < cabInf.len(); ci = ++ci)
		{
			local entry = cabInf[ci];
			res.pills.push({
				stashIndex    = -1000 - ci,
				itemKind      = "pill_infuse",
				pillKind      = "cabinet_infuse",
				pillID        = entry.SubID,
				name          = entry.Name + (entry.Count > 1 ? (" ×" + entry.Count) : ""),
				categoryLabel = entry.Kind == "core" ? "药柜内丹" : "药柜仙株",
				quality       = "unique",
				qualityLabel  = "百草药柜",
				icon          = "ui/items/" + entry.Icon,
				expAmount     = entry.ExpAmount,
				description   = entry.Desc + "（现存于零占格【百草药柜】×" + entry.Count + "，可直接拖入或点击灌注火候！）"
			});
		}
		return res;
	};
}

::Wuxia.UI.wxJoinStrings <- function( _arr, _sep )
{
	local s = "";
	for (local i = 0; i < _arr.len(); i = ++i)
	{
		if (i > 0) s += _sep;
		s += _arr[i];
	}
	return s;
};

::Wuxia.UI.buildAlchemyModalPayload <- function()
{
	local hasWorld = ("World" in getroottable()) && ::World != null && ::World.Assets != null;
	local stash = hasWorld ? ::World.Assets.getStash() : null;
	local money = hasWorld ? ::World.Assets.getMoney() : 0;

	local ingList = ::Wuxia.Alchemy.getUnifiedIngredients(stash);
	local ingMap = {};
	local uiIngredients = [];

	for (local i = 0; i < ingList.len(); i = ++i)
	{
		local e = ingList[i];
		ingMap[e.Key] <- e;
		uiIngredients.push({
			key          = e.Key,
			itemID       = e.ItemID,
			name         = e.Name,
			kind         = e.Kind,
			isRare       = e.IsRare,
			nature       = e.Nature,
			natureName   = e.NatureName,
			natureShort  = e.NatureShort,
			natureColor  = e.NatureColor,
			potency      = e.Potency,
			cabinetCount = e.CabinetCount,
			stashCount   = e.StashCount,
			totalCount   = e.TotalCount,
			icon         = "ui/items/" + e.Icon,
			value        = e.Value,
			description  = e.Description
		});
	}

	local ownedPills = {};
	if (stash != null)
	{
		foreach (it in stash.getItems())
		{
			if (it != null && it.getID() == "misc.wx_pill_item")
			{
				local pid = it.getPillID();
				ownedPills[pid] <- ((pid in ownedPills) ? ownedPills[pid] : 0) + 1;
			}
		}
	}

	local mastery = ::Wuxia.Alchemy.getAlchemistMastery();
	local uiFormulas = [];

	for (local fi = 0; fi < ::Wuxia.Config.Alchemy.Formulas.len(); fi = ++fi)
	{
		local f = ::Wuxia.Config.Alchemy.Formulas[fi];
		if (!(f.PillID in ::Wuxia.Config.Pills)) continue;
		local pdef = ::Wuxia.Config.Pills[f.PillID];
		local qLabel = ("Quality" in pdef && pdef.Quality in ::Wuxia.Text.Qualities) ? ::Wuxia.Text.Qualities[pdef.Quality] : "灵丹";

		local natShorts = [];
		for (local ni = 0; ni < f.JunNatures.len(); ni = ++ni)
		{
			local nk = f.JunNatures[ni];
			if (nk in ::Wuxia.Config.Alchemy.Natures)
				natShorts.push(::Wuxia.Config.Alchemy.Natures[nk].Short);
		}

		local autoPick = ::Wuxia.Alchemy.autoPickIngredients(f.ID, ingList);
		local autoPv = ::Wuxia.Alchemy.previewBrew(f.ID, autoPick, ingMap);

		uiFormulas.push({
			id             = f.ID,
			category       = f.Category,
			pillID         = f.PillID,
			pillKind       = pdef.Kind,
			name           = pdef.Name,
			subLabel       = ("SubLabel" in pdef) ? pdef.SubLabel : "江湖灵丹",
			quality        = pdef.Quality,
			qualityLabel   = qLabel,
			icon           = "ui/items/" + pdef.Icon,
			description    = pdef.Description,
			formulaNote    = f.FormulaNote,
			baseYield      = f.BaseYield,
			junNatures     = f.JunNatures,
			junNatureText  = ::Wuxia.UI.wxJoinStrings(natShorts, "/"),
			minJunPotency  = f.MinJunPotency,
			requireRareJun = f.RequireRareJun,
			minAuxCount    = f.MinAuxCount,
			targetPotency  = f.TargetPotency,
			silverCost     = ::Math.max(50, ::Math.floor(f.SilverCost * mastery.CostMult)),
			ownedCount     = (f.PillID in ownedPills) ? ownedPills[f.PillID] : 0,
			canAutoBrew    = autoPv.Ok,
			autoPick       = autoPick,
			autoPreview    = autoPv
		});
	}

	local uiNatures = [];
	local uiAuxInfusions = {};
	foreach (nk2 in ["origin", "vital", "yang", "yin", "spirit", "venom"])
	{
		local nd = ::Wuxia.Config.Alchemy.Natures[nk2];
		uiNatures.push({
			id    = nd.ID,
			name  = nd.Name,
			short = nd.Short,
			color = nd.Color,
			seal  = nd.Seal,
			desc  = nd.Desc
		});
		if ("AuxInfusions" in ::Wuxia.Config.Alchemy && (nk2 in ::Wuxia.Config.Alchemy.AuxInfusions))
		{
			local ax = ::Wuxia.Config.Alchemy.AuxInfusions[nk2];
			uiAuxInfusions[nk2] <- {
				id         = ax.ID,
				title      = ax.Title,
				color      = ax.Color,
				prepDesc   = ax.PrepDesc,
				infuseDesc = ax.InfuseDesc,
				healDesc   = ax.HealDesc
			};
		}
	}

	local forgePayload = null;
	if ("Forge" in ::Wuxia)
	{
		local sm = ::Wuxia.Forge.getSmithMastery();
		local cat = ::Wuxia.Forge.findReforgeCatalyst(stash);
		forgePayload = {
			smithLabel    = sm.SmithLabel,
			bonusHighPct  = sm.BonusHighPct,
			hasDiscount   = (sm.CostMult < 0.99),
			chances       = sm.Chances,
			pity          = ::Wuxia.Forge.getPity(),
			catalystFound = cat.Found,
			catalystName  = cat.Name,
			catalystTotal = ::Wuxia.Forge.countTotalBeastMats(stash),
			items         = ::Wuxia.Forge.collectReforgeableList(stash)
		};
	}

	return {
		ok             = true,
		money          = money,
		stashSpaceUsed = stash != null ? stash.getNumberOfFilledSlots() : 0,
		stashSpaceMax  = stash != null ? stash.getCapacity() : 0,
		autoStore      = ::Wuxia.Alchemy.Cabinet.isAutoStoreEnabled(),
		autoTrophy     = ::Wuxia.Alchemy.Cabinet.isAutoTrophyEnabled(),
		mastery        = {
			masterLabel    = mastery.MasterLabel,
			bonusDoublePct = mastery.BonusDoublePct,
			hasDiscount    = (mastery.CostMult < 0.99)
		},
		summary        = ::Wuxia.Alchemy.getCabinetSummaryCounts(stash),
		natures        = uiNatures,
		auxInfusions   = uiAuxInfusions,
		ingredients    = uiIngredients,
		formulas       = uiFormulas,
		forge          = forgePayload
	};
};

::Wuxia.UI.attachAlchemyRPCs <- function( _q )
{
	_q.WX_wrapAlchemyResponse <- function( _payload, _entityId = null, _syncStash = false )
	{
		if (("WX_attachVanillaSync" in this) && _payload != null && typeof _payload == "table")
		{
			local bro = (_entityId != null && "WX_findBrotherById" in this) ? this.WX_findBrotherById(_entityId) : null;
			this.WX_attachVanillaSync(_payload, bro, bro != null, _syncStash);
			if (_entityId != null && ::Wuxia.hasMember(this, "onWXGetState"))
				_payload.wxCharState <- this.onWXGetState(_entityId);
		}
		return _payload;
	};

	_q.onWXGetAlchemyState <- function( _data = null )
	{
		local entityId = (typeof _data == "array" && _data.len() > 0) ? _data[0] : _data;
		local payload = ::Wuxia.UI.buildAlchemyModalPayload();
		return this.WX_wrapAlchemyResponse(payload, entityId, false);
	};

	_q.onWXAlchemySweep <- function( _data = null )
	{
		local incTrophies = (typeof _data == "array" && _data.len() >= 1) ? (_data[0] ? true : false) : false;
		local entityId    = (typeof _data == "array" && _data.len() >= 2) ? _data[1] : null;
		if (!("World" in getroottable()) || ::World == null || ::World.Assets == null)
			return { ok = false, reason = "当前无法访问战团仓库。" };

		local stash = ::World.Assets.getStash();
		local moved = ::Wuxia.Alchemy.Cabinet.storeFromStash(stash, true, incTrophies);
		local payload = ::Wuxia.UI.buildAlchemyModalPayload();
		this.WX_wrapAlchemyResponse(payload, entityId, moved.slotsCleared > 0);

		if (moved.slotsCleared <= 0)
		{
			payload.actionMessage <- incTrophies
				? "当前战团仓库中暂无可收入百草药柜的奇草、内丹或异兽奇材。"
				: "当前战团仓库中暂无可收纳的奇草或山海内丹（如需连同异兽皮骨一并入柜，可点击「连同异兽奇材全部入柜」）。";
		}
		else
		{
			local parts = [];
			if (moved.herbsMoved > 0)    parts.push(moved.herbsMoved + " 株奇草");
			if (moved.coresMoved > 0)    parts.push(moved.coresMoved + " 枚内丹");
			if (moved.trophiesMoved > 0) parts.push(moved.trophiesMoved + " 份异兽奇材");
			payload.actionMessage <- "收纳完毕！已将 " + ::Wuxia.UI.wxJoinStrings(parts, "、") + " 归入【百草药柜】，腾出 " + moved.slotsCleared + " 格仓库空间！";
		}
		return payload;
	};

	_q.onWXAlchemyWithdraw <- function( _data )
	{
		local key      = _data[0];
		local qty      = (_data.len() >= 2 && _data[1] != null) ? _data[1] : 1;
		local entityId = (_data.len() >= 3) ? _data[2] : null;
		if (!("World" in getroottable()) || ::World == null || ::World.Assets == null)
			return { ok = false, reason = "当前无法访问战团仓库。" };

		local stash = ::World.Assets.getStash();
		local res = ::Wuxia.Alchemy.Cabinet.withdrawToStash(stash, key, qty);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		local payload = ::Wuxia.UI.buildAlchemyModalPayload();
		this.WX_wrapAlchemyResponse(payload, entityId, true);
		payload.actionMessage <- "已从百草药柜取出「" + res.Name + "」×" + res.Count + " 至战团仓库（可用于市集出售、应急生服或百工铸甲）。";
		return payload;
	};

	_q.onWXAlchemyToggleAuto <- function( _data )
	{
		local mode     = _data[0];
		local enabled  = _data[1] ? true : false;
		local entityId = (_data.len() >= 3) ? _data[2] : null;

		local swept = { slotsCleared = 0 };
		if (mode == "autotrophy")
		{
			::Wuxia.Alchemy.Cabinet.setAutoTrophyEnabled(enabled);
			if (enabled && ("World" in getroottable()) && ::World != null && ::World.Assets != null)
				swept = ::Wuxia.Alchemy.Cabinet.storeFromStash(::World.Assets.getStash(), false, true);
		}
		else
		{
			::Wuxia.Alchemy.Cabinet.setAutoStoreEnabled(enabled);
			if (enabled && ("World" in getroottable()) && ::World != null && ::World.Assets != null)
				swept = ::Wuxia.Alchemy.Cabinet.storeFromStash(::World.Assets.getStash(), false, ::Wuxia.Alchemy.Cabinet.isAutoTrophyEnabled());
		}

		local payload = ::Wuxia.UI.buildAlchemyModalPayload();
		this.WX_wrapAlchemyResponse(payload, entityId, swept.slotsCleared > 0);
		payload.actionMessage <- (mode == "autotrophy")
			? (enabled ? "已开启「异兽奇材自动入柜」！" : "已关闭异兽奇材自动入柜（留存仓库便于城镇百工铸甲）。")
			: (enabled ? "已开启「奇草/大妖内丹自动入柜」！" : "已关闭奇草/内丹自动入柜。");
		return payload;
	};

	_q.onWXAlchemyPreview <- function( _data )
	{
		local formulaID = _data[0];
		local slots = [
			_data.len() >= 2 ? _data[1] : "",
			_data.len() >= 3 ? _data[2] : "",
			_data.len() >= 4 ? _data[3] : ""
		];
		return ::Wuxia.Alchemy.previewBrew(formulaID, slots);
	};

	_q.onWXAlchemyBrew <- function( _data )
	{
		local formulaID = _data[0];
		local slots = [
			_data.len() >= 2 ? _data[1] : "",
			_data.len() >= 3 ? _data[2] : "",
			_data.len() >= 4 ? _data[3] : ""
		];
		local entityId = (_data.len() >= 5) ? _data[4] : null;

		local res = ::Wuxia.Alchemy.executeBrew(formulaID, slots);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		local payload = ::Wuxia.UI.buildAlchemyModalPayload();
		this.WX_wrapAlchemyResponse(payload, entityId, true);
		payload.brewResult    <- res;
		payload.actionMessage <- res.Message;
		return payload;
	};

	_q.onWXForgeReforge <- function( _data )
	{
		local uid      = _data[0];
		local entityId = (_data.len() >= 2) ? _data[1] : null;
		if (!("Forge" in ::Wuxia))
			return { ok = false, reason = "百工重锻系统尚未就绪。" };

		local res = ::Wuxia.Forge.executeReforge(uid);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		local payload = ::Wuxia.UI.buildAlchemyModalPayload();
		this.WX_wrapAlchemyResponse(payload, entityId, true);
		payload.reforgeResult <- res;
		payload.actionMessage <- res.Message;
		return payload;
	};
};

// 5. Hook World Topbar, Character Screen, Town Shop & Post-Battle Loot
::Wuxia.HooksMod.hook("scripts/ui/screens/world/modules/topbar/world_screen_topbar_options_module", function( q )
{
	::Wuxia.UI.attachAlchemyRPCs(q);
});

::Wuxia.HooksMod.hook("scripts/ui/screens/world/modules/world_town_screen/town_taxidermist_dialog_module", function( q )
{
	::Wuxia.UI.attachAlchemyRPCs(q);
});

::Wuxia.HooksMod.hook("scripts/ui/screens/character/character_screen", function( q )
{
	::Wuxia.UI.attachAlchemyRPCs(q);

	if ("show" in q)
	{
		q.show = @(__original) function()
		{
			if (!this.isInGroundMode() && ::Wuxia.Alchemy.Cabinet.isAutoStoreEnabled()
				&& ("World" in getroottable()) && ::World != null && ::World.Assets != null)
			{
				local stash = ::World.Assets.getStash();
				if (stash != null)
				{
					local moved = ::Wuxia.Alchemy.Cabinet.storeFromStash(stash, false, ::Wuxia.Alchemy.Cabinet.isAutoTrophyEnabled());
					if (moved.slotsCleared > 0 && ("WX_PendingAutoStoreNotice" in this.m))
					{
						local extra = "另有 " + moved.slotsCleared + " 份奇草/内丹归入【百草药柜】。";
						this.m.WX_PendingAutoStoreNotice = (this.m.WX_PendingAutoStoreNotice != "")
							? (this.m.WX_PendingAutoStoreNotice + " " + extra)
							: ("已自动将行囊新获奇草与内丹（共 " + moved.slotsCleared + " 份）归入【百草药柜】，不占仓库格。");
					}
				}
			}
			__original();
		};
	}

	if ("onWXGetState" in q)
	{
		q.onWXGetState = @(__original) function( _data )
		{
			local res = __original(_data);
			if (res != null && typeof res == "table")
			{
				local wp = ::Wuxia.Alchemy.getWashPillCounts();
				res.washPills        <- wp;
				res.washPillCount     = wp.totalMainWash;
				res.protectPillCount  = wp.totalProtect;
				res.alchemySummary   <- ::Wuxia.Alchemy.getCabinetSummaryCounts();
				if (("brother" in res) && res.brother != null)
				{
					local entityId = (typeof _data == "array" && _data.len() > 0) ? _data[0] : _data;
					local bro = this.WX_findBrotherById(entityId);
					res.brother.hasWangchenGrace <- (bro != null && bro.getSkills() != null && bro.getSkills().hasSkill("effects.wx_wangchen_grace"));
				}
			}
			return res;
		};
	}

	// Support infusing Cabinet-stored ShanHai Cores & Spirit Herbs (`stashIndex <= -1000`) directly into martial slots!
	if ("onWXInfusePill" in q)
	{
		q.onWXInfusePill = @(__original) function( _data )
		{
			local stashIndex = (typeof _data == "array" && _data.len() >= 2) ? _data[1] : 0;
			if (stashIndex > -1000)
				return __original(_data);

			local entityId  = _data[0];
			local slotIndex = _data[2];
			local bro = this.WX_findBrotherById(entityId);
			if (bro == null)
				return { ok = false, reason = "未找到该名侠客。" };

			local cabIdx = -(stashIndex + 1000);
			local cabItems = ::Wuxia.Alchemy.getCabinetInfusableItems();
			if (cabIdx < 0 || cabIdx >= cabItems.len())
				return { ok = false, reason = "百草药柜中该份仙株/内丹已耗尽。" };

			local entry = cabItems[cabIdx];
			local expAmt = entry.ExpAmount;
			local resonanceNote = "";

			if (entry.Kind == "core")
			{
				local c = bro.getSkills().getSkillByID("special.wx_martial_container");
				if (c != null && slotIndex >= 0 && slotIndex < c.m.Slots.len() && c.m.Slots[slotIndex].ManualID != null)
				{
					local mdef = ::Wuxia.Slots.getManualDef(c.m.Slots[slotIndex].ManualID);
					if ("ShanHai" in ::Wuxia && "getCoreInfuseExp" in ::Wuxia.ShanHai)
					{
						expAmt = ::Wuxia.ShanHai.getCoreInfuseExp(entry.SubID, mdef);
						if (expAmt >= entry.ExpAmount + 180) resonanceNote = "（山海孤本大共鸣！）";
						else if (expAmt > entry.ExpAmount) resonanceNote = "（内丹气脉共鸣！）";
					}
					else if (c.m.Slots[slotIndex].ManualID.find("wx_manual_shanhai_") == 0)
					{
						expAmt = 500;
						resonanceNote = "（山海孤本共鸣！）";
					}
				}
			}

			local res = ::Wuxia.Mastery.infuseWithPill(bro, slotIndex, expAmt);
			if (!res.Ok)
				return { ok = false, reason = res.Reason };

			::Wuxia.Alchemy.Cabinet.addCount(entry.CabKey, -1);

			local msg = "自【百草药柜】取「" + entry.Name + "」炼化，向《" + res.ManualName + "》注入 " + expAmt + " 点火候！" + resonanceNote;
			if (res.Advanced)
				msg += " 功法突破至" + ::Wuxia.Text.TierNames[res.NewTier] + "！";
			else if (res.BlockedByReq)
				msg += " 火候已满，但尚未满足三重大成属性门槛。";

			local state = this.onWXGetState(entityId);
			this.WX_attachVanillaSync(state, bro, true, false);
			state.actionMessage <- msg;
			return state;
		};
	}

	q.onWXGetWashPreviewEx <- function( _data )
	{
		local bro        = this.WX_findBrotherById(_data[0]);
		local washPillID = (_data.len() >= 5 && _data[4] != null && _data[4] != "") ? _data[4] : "wx_pill_xisui";
		return ::Wuxia.Alchemy.getWashPreviewEx(bro, _data[1], _data[2], _data[3], washPillID);
	};

	q.onWXExecuteWashEx <- function( _data )
	{
		local entityId         = _data[0];
		local targetAttrIdx    = _data[1];
		local replaceAttrIdx   = _data[2];
		local useProtectPill   = _data[3];
		local usePendingChance = _data[4];
		local washPillID       = (_data.len() >= 6 && _data[5] != null && _data[5] != "") ? _data[5] : "wx_pill_xisui";

		local bro   = this.WX_findBrotherById(entityId);
		local stash = ::World.Assets.getStash();
		if (bro == null || stash == null)
			return { ok = false, reason = "未找到侠客或战团仓库。" };

		local washIdx = -1;
		if (!usePendingChance)
		{
			washIdx = ::Wuxia.Alchemy.findPillIndexByID(stash, washPillID);
			if (washIdx < 0)
			{
				foreach (alt in ["wx_pill_zijin_xisui", "wx_pill_yijin_wan", "wx_pill_xisui"])
				{
					washIdx = ::Wuxia.Alchemy.findPillIndexByID(stash, alt);
					if (washIdx >= 0) { washPillID = alt; break; }
				}
			}
			if (washIdx < 0)
				return { ok = false, reason = "战团仓库中缺少可用的洗髓丹药。" };
		}

		local protectIdx = -1;
		if (useProtectPill)
		{
			// Prefer 山海造化护脉金丹 (`wx_pill_zaohua`) if owned, matching MarrowWash.resolveBestProtectPillDef!
			protectIdx = ::Wuxia.Alchemy.findPillIndexByID(stash, "wx_pill_zaohua");
			if (protectIdx < 0)
				protectIdx = this.WX_findFirstPillIndex(stash, "wash_protect");
			if (protectIdx < 0)
				return { ok = false, reason = "战团仓库中缺少护脉丹或造化护脉金丹。" };
		}

		local res = ::Wuxia.Alchemy.executeWashEx(bro, targetAttrIdx, replaceAttrIdx, useProtectPill, usePendingChance, washPillID);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		if (washIdx >= 0 && protectIdx >= 0)
		{
			if (washIdx > protectIdx)
			{
				stash.removeByIndex(washIdx);
				stash.removeByIndex(protectIdx);
			}
			else
			{
				stash.removeByIndex(protectIdx);
				stash.removeByIndex(washIdx);
			}
		}
		else if (washIdx >= 0)
			stash.removeByIndex(washIdx);
		else if (protectIdx >= 0)
			stash.removeByIndex(protectIdx);

		local state = this.onWXGetState(entityId);
		this.WX_attachVanillaSync(state, bro, true, true);
		state.washResult    <- res;
		state.actionMessage <- res.Message;
		return state;
	};
});

::Wuxia.HooksMod.hook("scripts/ui/screens/world/modules/world_town_screen/town_shop_dialog_module", function( q )
{
	if ("onLeaveButtonPressed" in q)
	{
		q.onLeaveButtonPressed = @(__original) function()
		{
			if (::Wuxia.Alchemy.Cabinet.isAutoStoreEnabled() && ("World" in getroottable()) && ::World != null && ::World.Assets != null)
			{
				local stash = ::World.Assets.getStash();
				if (stash != null)
					::Wuxia.Alchemy.Cabinet.storeFromStash(stash, false, ::Wuxia.Alchemy.Cabinet.isAutoTrophyEnabled());
			}
			__original();
		};
	}
});

::Wuxia.HooksMod.hook("scripts/ui/screens/tactical/tactical_combat_result_screen", function( q )
{
	if ("onLootAllItemsButtonPressed" in q)
	{
		q.onLootAllItemsButtonPressed = @(__original) function()
		{
			local cabMoved = 0;
			if (::Wuxia.Alchemy.Cabinet.isAutoStoreEnabled())
			{
				local incTr = ::Wuxia.Alchemy.Cabinet.isAutoTrophyEnabled();
				if ("Tactical" in getroottable() && ::Tactical != null && ("CombatResultLoot" in ::Tactical) && ::Tactical.CombatResultLoot != null)
				{
					local r1 = ::Wuxia.Alchemy.Cabinet.storeFromStash(::Tactical.CombatResultLoot, true, incTr);
					cabMoved += r1.slotsCleared;
				}
				if ("World" in getroottable() && ::World != null && ::World.Assets != null && ::World.Assets.getStash() != null)
				{
					local r2 = ::Wuxia.Alchemy.Cabinet.storeFromStash(::World.Assets.getStash(), false, incTr);
					cabMoved += r2.slotsCleared;
				}
			}
			local ret = __original();
			if (typeof ret == "table" && cabMoved > 0)
			{
				local note = "缴获的 " + cabMoved + " 份奇草/大妖内丹已自动归入【百草药柜】（零仓库占格）！";
				ret.wxSweepMessage <- ("wxSweepMessage" in ret && ret.wxSweepMessage != "")
					? (ret.wxSweepMessage + " " + note)
					: note;
			}
			return ret;
		};
	}
});

// High-tier Alchemy Elixirs (`忘尘归元散 / 玄冰辟火丸 / 疯魔燃血丸 / 易筋洗髓丸` etc.) are strictly crafted
// in the Eight-Trigrams Furnace (`八卦丹炉`) using Boss Neidan Cores & Spirit Herbs — never sold in ordinary town shops!

// 6. Unlock Town 百工丹坊 Blueprints even when the required Core / Exotic Herb was auto-swept directly into 百草药柜!
::Wuxia.HooksMod.hook("scripts/crafting/blueprint", function( q )
{
	if ("isQualified" in q)
	{
		q.isQualified = @(__original) function()
		{
			if (__original()) return true;
			local bpID = (::Wuxia.hasMember(this.m, "ID") && this.m.ID != null) ? this.m.ID : "";
			if (bpID.find("blueprint.wx_") != 0 || this.m.PreviewCraftable == null) return false;
			local comps = (::Wuxia.hasMember(this.m, "PreviewComponents")) ? this.m.PreviewComponents : ((::Wuxia.hasMember(this.m, "Ingredients")) ? this.m.Ingredients : null);
			if (comps == null) return false;
			foreach (ing in comps)
			{
				if (ing == null || !("Instance" in ing) || ing.Instance == null) continue;
				local meta = ::Wuxia.Alchemy.classifyItem(ing.Instance);
				if (meta != null && ::Wuxia.Alchemy.Cabinet.getCount(meta.Key) > 0)
					return true;
			}
			return false;
		};
	}
});
