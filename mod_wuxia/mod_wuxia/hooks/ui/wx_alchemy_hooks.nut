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
	if (!::Wuxia.qHas(q, "applyHeavyShock"))
	{
		q.applyHeavyShock <- function()
		{
			this.applySeverity(2, ::Wuxia.Config.MarrowWash.ShockDurationDays);
		};
	}
	if (!::Wuxia.qHas(q, "applyPermanentDamage"))
	{
		q.applyPermanentDamage <- function()
		{
			this.addPermanentMeridianScar();
		};
	}
});

// -----------------------------------------------------------------------------
// 2. Hook `wx_pill_battle_buff`: Add 4 ShanHai Counter Elixirs + 19 Build-Synergy Mechanism Elixirs + 2-Pill Dan-Toxin Cap
//    (Preserves 1/2/3/5/9-byte varint save compatibility AND keeps legacy direct `addPillBuff` selftest intact!)
// -----------------------------------------------------------------------------
::Wuxia.HooksMod.hook("scripts/skills/effects/wx_pill_battle_buff", function( q )
{
	q.m.HasBihuo          <- false; // 玄冰辟火丸: ShanHai fire/miasma aura immunity, -15% ranged dmg, +2 Qi rec
	q.m.HasYuji           <- false; // 玉肌止血散: Bleeding immunity, +25% injury threshold, +5 HP regen/turn
	q.m.HasLonghu         <- false; // 龙虎提纵散: +15 Initiative, +5 RangedDef, Knockback/Grab immunity
	q.m.HasFengmo         <- false; // 疯魔燃血丸: +15% Headshot, +15% ArmorDmg, +10% ArmorPen (capped at 25%), 2d post-battle light injury
	q.m.HasJuling         <- false; // 巨灵披甲行气丸: Refund 22% armor stamina penalty (max +18), -10% armor dmg taken
	q.m.HasTiee           <- false; // 铜皮铁额护顶膏: Steel Brow head crit immunity, -20% head armor dmg taken
	q.m.HasJiugong        <- false; // 九宫磐石守阵丸: +5 SurroundedDefense (non-stacking with Underdog), +10 ZoC hit
	q.m.HasJingji         <- false; // 玄甲反震刺猬散: Melee thorns 8 armor + 4 Qi scatter
	q.m.HasZuixian        <- false; // 醉仙望月狂酒: +15 Bravery, +6 MeleeDef, +10% Melee dmg, -10 RangedSkill, -1 Vision
	q.m.HasXiantian       <- false; // 先天真气护体丹: 25% True Qi Shield (1 Qi : 2 HP, capped at 60% total mitigation)
	q.m.HasLingfeng       <- false; // 踏雪凌风轻身露: -50% movement fatigue, 0 AP elevation cost, +15 Round-1 Init
	q.m.HasGufeng         <- false; // 孤锋破玉淬劲散: +12% Empty-offhand/Fist ArmorPen (capped at 25%), +15% unbroken armor dmg
	q.m.HasKongque        <- false; // 南疆孔雀胆淬毒膏: 55% poison dart on hit (HP>=4), +6 hit vs poisoned
	q.m.HasFugu           <- false; // 五仙腐骨蚀甲散: +10 body armor corrosion on hit, +6 shield corrosion
	q.m.HasSuoxue         <- false; // 透骨寻隙封脉散: 35% Opening on hit, 30% Acupoint on Head/Opening hit
	q.m.HasShixue         <- false; // 血煞饮血狂战丸: +12% dmg vs <50% HP, +10 HP & +5 Qi on kill (2/turn)
	q.m.HasYingyan        <- false; // 千里破雾鹰眼露: +1 Vision, NightOwl, +6 long-range shot, ignore 25% dodge
	q.m.HasPili           <- false; // 神机震雷火药引: 40% Off-balance on ranged/heavy hit, +8 shield break
	q.m.HasChunyang       <- false; // 龙虎纯阳破邪丹: +18% dmg & +8 armor burn vs Undead/Construct, +15 anti-fear
	q.m.HasHufu           <- false; // 聚义虎符壮胆丸: Start battle Confident, +4 MDef/RDef & +8 Bravery when >=2 adjacent allies
	q.m.HasBaoming        <- false; // 天王吊命保心丹: Temporary Nine Lives lethal save + cleanse + 12 HP & 10 Qi
	q.m.HasZhenmo         <- false; // 太清镇魔定脉丹: Suppress Neigong conflict & Fragment backlash, +6 hit per miss
	q.m.HasTihu           <- false; // 紫芝醍醐悟道丹: +35% XP gain & +50% post-battle martial slot mastery exp
	q.m.HasLiangyi        <- false; // 两仪逆命混元丹: Harmonize dual-Neigong clash + Dan-Wu Yang/Yin resonance
	q.m.HasZhuyin         <- false; // 烛阴昼夜轮转丹: Odd-round 瞑夜双防回气 / Even-round 赤昼增伤灼甲
	q.m.HasKurong         <- false; // 枯荣生死涅槃丸: +4 MDef/RDef & +4 Qi rec while bleed/poison + 1x <35% HP Nirvana heal
	q.m.HasShenmo         <- false; // 神魔一念辟邪丹: Suppress evil/fragment clash, +8 hit vs wavering/charmed, +6 Qi on kill
	q.m.HasBaize          <- false; // 白泽通玄勘破丹: First AoO/counter +12 hit & opening, +25% post-battle martial mastery
	q.m.HasJianmu         <- false; // 建木枯木逢春丹: +6 HP & +6 body armor/turn (+10 armor with Henglian manual)
	q.m.HasTaotie         <- false; // 饕餮吞元化气丸: Heavy melee hit devours 5 Qi from living foe (2/turn)
	q.m.HasYinglong       <- false; // 应龙行云御雷丹: -35% move fatigue, +3 Qi refund on step_through / pierce_line (2/turn)
	q.m.HasChiyou         <- false; // 蚩尤兵主百战丹: +15% ArmorDmg, +10 shield break, +5 Qi & adj morale check on kill
	q.m.HasJinwu          <- false; // 金乌十日纯阳丹: Cleanse chill, +10 melee armor burn, +16% dmg vs undead/construct
	q.m.HasXiangliu       <- false; // 相柳九首万蛊丹: Poison immune, 55% poison on hit & spread to adj enemy
	q.m.HasXuangui        <- false; // 玄龟镇海不坏丹: -18% ranged dmg, stun/kb immune, 1x/turn -12% heavy HP dmg (capped >=0.40)
	q.m.HasDijiang        <- false; // 帝江幻空缩地丹: +16 Init, 1x/turn 22% phase shift vs ranged/heavy hit (capped >=0.40)
	q.m.HasJiuwei         <- false; // 九尾青丘摄魂丹: +14 Bravery, charm/sleep cleanse, -10 morale check on hit
	q.m.HasXingtian       <- false; // 刑天常羊战魂丹: Stun immune, <60% HP +14% dmg & +4 Qi rec
	q.m.CoreImprintID     <- "";    // 本命妖丹丹韵 ID (`wx_core_*`, covering all 64 Boss Cores + 32 Wild/Sovereign Cores!)
	q.m.HasDanToxin       <- false; // 丹毒郁结: Triggered when consuming a 3rd non-Danxia battle pill (-15 Stamina, -3 Qi rec, 3d post-battle light injury)
	q.m.FengmoNoInjury    <- false; // 丹霞极品疯魔燃血丸免除战后 2 日内伤反噬
	q.m.PotencyScalePct   <- 100;   // 成丹/灵纹/丹霞药效倍率 (92..155)
	q.m.AuxMask           <- 0;     // 药引丹韵位掩码: 1=生机, 2=赤阳, 4=玄阴, 8=镇魂, 16=奇毒, 32=造化
	q.m.PillKillsThisTurn <- 0;
	q.m.PillAdaptStacks   <- 0;
	q.m.KurongNirvanaUsed <- false;
	q.m.BaizeUsedTurn     <- false;
	q.m.TaotieQiTurn      <- 0;
	q.m.YinglongQiTurn    <- 0;
	q.m.DuhengStanceTurn  <- false;
	q.m.PhasePillUsedTurn <- false;
	q.m.AuxAdaptReady     <- false;
	q.m.CoreQiTurn        <- 0;
	q.m.PrevLevelAPCost   <- -1;
	q.m.WX_BattleStarted  <- false;

	local extBuffSpecs = [
		{ Bit = 0,  Field = "HasJuling",   Kind = "buff_juling",   Short = "巨灵", Summary = "巨灵行气(减甲重)" },
		{ Bit = 1,  Field = "HasTiee",     Kind = "buff_tiee",     Short = "铁额", Summary = "铜皮铁额(免爆头)" },
		{ Bit = 2,  Field = "HasJiugong",  Kind = "buff_jiugong",  Short = "九宫", Summary = "九宫磐石(抗围拦击)" },
		{ Bit = 3,  Field = "HasJingji",   Kind = "buff_jingji",   Short = "刺猬", Summary = "玄甲反震(震甲散气)" },
		{ Bit = 4,  Field = "HasZuixian",  Kind = "buff_zuixian",  Short = "醉仙", Summary = "醉仙狂酒(+15定+6防)" },
		{ Bit = 5,  Field = "HasXiantian", Kind = "buff_xiantian", Short = "先天", Summary = "先天护体(真气化伤)" },
		{ Bit = 6,  Field = "HasLingfeng", Kind = "buff_lingfeng", Short = "凌风", Summary = "踏雪凌风(越障抢先)" },
		{ Bit = 7,  Field = "HasGufeng",   Kind = "buff_gufeng",   Short = "孤锋", Summary = "孤锋淬劲(+12%空副穿甲)" },
		{ Bit = 8,  Field = "HasKongque",  Kind = "buff_kongque",  Short = "孔雀", Summary = "孔雀淬毒(55%奇毒)" },
		{ Bit = 9,  Field = "HasFugu",     Kind = "buff_fugu",     Short = "腐骨", Summary = "五仙腐骨(蚀甲蚀盾)" },
		{ Bit = 10, Field = "HasSuoxue",   Kind = "buff_suoxue",   Short = "封脉", Summary = "透骨封脉(破绽点穴)" },
		{ Bit = 11, Field = "HasShixue",   Kind = "buff_shixue",   Short = "饮血", Summary = "血煞饮血(斩敌回血气)" },
		{ Bit = 12, Field = "HasYingyan",  Kind = "buff_yingyan",  Short = "鹰眼", Summary = "破雾鹰眼(+1视+6远射)" },
		{ Bit = 13, Field = "HasPili",     Kind = "buff_pili",     Short = "震雷", Summary = "神机震雷(40%失衡)" },
		{ Bit = 14, Field = "HasChunyang", Kind = "buff_chunyang", Short = "纯阳", Summary = "龙虎纯阳(诛邪+18%)" },
		{ Bit = 15, Field = "HasHufu",     Kind = "buff_hufu",     Short = "虎符", Summary = "聚义虎符(昂扬结阵)" },
		{ Bit = 16, Field = "HasBaoming",  Kind = "buff_baoming",  Short = "吊命", Summary = "天王吊命(九命锁血)" },
		{ Bit = 17, Field = "HasZhenmo",   Kind = "buff_zhenmo",   Short = "镇魔", Summary = "太清镇魔(镇逆冲叠命中)" },
		{ Bit = 18, Field = "HasTihu",     Kind = "buff_tihu",     Short = "醍醐", Summary = "紫芝醍醐(+35%历练+50%火候)" },
		{ Bit = 19, Field = "HasLiangyi",  Kind = "buff_liangyi",  Short = "两仪", Summary = "两仪逆命(丹武混元调频)" },
		{ Bit = 20, Field = "HasZhuyin",   Kind = "buff_zhuyin",   Short = "轮转", Summary = "烛阴轮转(昼夜催功)" },
		{ Bit = 21, Field = "HasKurong",   Kind = "buff_kurong",   Short = "枯荣", Summary = "枯荣涅槃(带创提气回生)" },
		{ Bit = 22, Field = "HasShenmo",   Kind = "buff_shenmo",   Short = "辟邪", Summary = "神魔辟邪(镇邪斩回气)" },
		{ Bit = 23, Field = "HasBaize",    Kind = "buff_baize",    Short = "勘破", Summary = "白泽勘破(反击破绽悟功)" },
		{ Bit = 24, Field = "HasJianmu",   Kind = "buff_jianmu",   Short = "逢春", Summary = "建木逢春(横练回血修甲)" },
		{ Bit = 25, Field = "HasTaotie",   Kind = "buff_taotie",   Short = "吞元", Summary = "饕餮吞元(重击鲸吞敌气)" },
		{ Bit = 26, Field = "HasYinglong", Kind = "buff_yinglong", Short = "行云", Summary = "应龙行云(轻功穿刺返气)" },
		{ Bit = 27, Field = "HasChiyou",   Kind = "buff_chiyou",   Short = "兵主", Summary = "蚩尤兵主(破甲斩慑)" },
		{ Bit = 28, Field = "HasJinwu",    Kind = "buff_jinwu",    Short = "十日", Summary = "金乌纯阳(焚甲诛邪)" },
		{ Bit = 29, Field = "HasXiangliu", Kind = "buff_xiangliu", Short = "万蛊", Summary = "相柳万蛊(免毒传蛊)" }
	];
	local extBuffSpecs2 = [
		{ Bit = 0, Field = "HasXuangui",  Kind = "buff_xuangui",  Short = "镇海", Summary = "玄龟不坏(抗远卸伤)" },
		{ Bit = 1, Field = "HasDijiang",  Kind = "buff_dijiang",  Short = "缩地", Summary = "帝江缩地(幻空折跃)" },
		{ Bit = 2, Field = "HasJiuwei",   Kind = "buff_jiuwei",   Short = "摄魂", Summary = "九尾摄魂(免惑摇魄)" },
		{ Bit = 3, Field = "HasXingtian", Kind = "buff_xingtian", Short = "战魂", Summary = "刑天战魂(残血狂战)" }
	];

	q.wxGetCoreImprintSpec <- function()
	{
		if (this.m.CoreImprintID != "" && "Alchemy" in ::Wuxia && "getCoreImprintPreview" in ::Wuxia.Alchemy)
			return ::Wuxia.Alchemy.getCoreImprintPreview(this.m.CoreImprintID, "buff_");
		return null;
	};

	q.wxCurrentRound <- function()
	{
		if (("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive()
			&& ("TurnSequenceBar" in ::Tactical) && ::Tactical.TurnSequenceBar != null)
		{
			return ::Tactical.TurnSequenceBar.getCurrentRound();
		}
		return 1;
	};

	q.syncBaomingNineLives <- function()
	{
		if (!this.m.HasBaoming) return;
		local cont = this.getContainer();
		if (cont == null || cont.hasSkill("perk.nine_lives")) return;
		local nl = ::new("scripts/skills/perks/wx_manual_nine_lives");
		nl.m.IsSerialized = false;
		nl.m.WX_FromBaomingPill <- true;
		cont.add(nl);
	};

	q.applyPillPotencyAndAux <- function( _potencyPct, _auxNature = "", _waiveFengmoInjury = false, _firstBattleEffect = false, _coreImprint = "" )
	{
		if (_potencyPct != null && (_firstBattleEffect || _potencyPct > this.m.PotencyScalePct))
			this.m.PotencyScalePct = ::Math.max(80, ::Math.min(160, _potencyPct));
		if (_waiveFengmoInjury)
			this.m.FengmoNoInjury = true;
		if (_auxNature != null && _auxNature != "" && ("Alchemy" in ::Wuxia.Config) && ("AuxInfusions" in ::Wuxia.Config.Alchemy) && (_auxNature in ::Wuxia.Config.Alchemy.AuxInfusions))
		{
			this.m.AuxMask = this.m.AuxMask | ::Wuxia.Config.Alchemy.AuxInfusions[_auxNature].Bit;
		}
		if (_coreImprint != null && _coreImprint != "")
			this.m.CoreImprintID = _coreImprint;
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
		foreach (sp in extBuffSpecs)
		{
			if (this.m[sp.Field]) n += 1;
		}
		foreach (sp2 in extBuffSpecs2)
		{
			if (this.m[sp2.Field]) n += 1;
		}
		return n;
	};

	q.canAcceptBattlePill <- function( _kind, _actorName = "侠客" )
	{
		if (this.hasBuffKind(_kind))
			return { Ok = false, Reason = _actorName + " 体内已有同类备战药力，无需重复服食。" };
		local cur = this.countActiveBuffs();
		if (cur >= 3)
			return { Ok = false, Reason = _actorName + " 体内已有 3 道备战药力，无法再服用备战丹药或奇草。" };
		local cont = this.getContainer();
		local hasBaidu = (cont != null && cont.hasSkill("trait.wx_baidu"));
		return {
			Ok               = true,
			WillTriggerToxin = (cur >= 2 && !hasBaidu)
		};
	};

	q.applyDanToxinOverload <- function()
	{
		this.m.HasDanToxin = true;
		this.updateLabel();
		return "（混服第 3 道备战药力引发【丹毒郁结】，本战内息上限 -15、回气 -3，战后染轻内伤。）";
	};

	q.addPillBuff = @(__original) function( _kind, _herbCalmBravery = 6 )
	{
		if (_kind == "buff_bihuo")       this.m.HasBihuo  = true;
		else if (_kind == "buff_yuji")   this.m.HasYuji   = true;
		else if (_kind == "buff_longhu") this.m.HasLonghu = true;
		else if (_kind == "buff_fengmo") this.m.HasFengmo = true;
		else
		{
			foreach (sp in extBuffSpecs)
			{
				if (_kind == sp.Kind) { this.m[sp.Field] = true; break; }
			}
			foreach (sp2 in extBuffSpecs2)
			{
				if (_kind == sp2.Kind) { this.m[sp2.Field] = true; break; }
			}
		}
		__original(_kind, _herbCalmBravery);
		if (this.m.HasBaoming)
			this.syncBaomingNineLives();
	};

	q.hasBuffKind = @(__original) function( _kind )
	{
		if (_kind == "buff_bihuo")  return this.m.HasBihuo;
		if (_kind == "buff_yuji")   return this.m.HasYuji;
		if (_kind == "buff_longhu") return this.m.HasLonghu;
		if (_kind == "buff_fengmo") return this.m.HasFengmo;
		foreach (sp in extBuffSpecs)
		{
			if (_kind == sp.Kind) return this.m[sp.Field];
		}
		foreach (sp2 in extBuffSpecs2)
		{
			if (_kind == sp2.Kind) return this.m[sp2.Field];
		}
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
		foreach (sp in extBuffSpecs)
		{
			if (this.m[sp.Field]) extra.push(sp.Short);
		}
		foreach (sp2 in extBuffSpecs2)
		{
			if (this.m[sp2.Field]) extra.push(sp2.Short);
		}
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
		foreach (sp in extBuffSpecs)
		{
			if (this.m[sp.Field]) list.push(sp.Summary);
		}
		foreach (sp2 in extBuffSpecs2)
		{
			if (this.m[sp2.Field]) list.push(sp2.Summary);
		}
		local cImpS = this.wxGetCoreImprintSpec();
		if (cImpS != null) list.push(cImpS.Title);
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
		if (this.m.HasJuling)
			ret.push({ id = 33, type = "text", icon = "ui/icons/fatigue.png", text = "【巨灵披甲行气丸】按甲胄总负重返还 [color=" + pos + "]" + ::Math.min(30, ::Math.round(22 * sc)) + "%[/color] 内息上限（至多 +18），承受破甲损耗 [color=" + pos + "]-10%[/color]" });
		if (this.m.HasTiee)
			ret.push({ id = 34, type = "text", icon = "ui/icons/armor_head.png", text = "【铜皮铁额护顶膏】免疫命中头部额外暴击倍率（铜头铁额），头盔耐久损耗 [color=" + pos + "]-20%[/color]" });
		if (this.m.HasJiugong)
			ret.push({ id = 35, type = "text", icon = "ui/icons/melee_defense.png", text = "【九宫磐石守阵丸】抗围近防补正 [color=" + pos + "]+5[/color]，控制区借机拦击命中 [color=" + pos + "]+" + ::Math.round(10 * sc) + "[/color]" });
		if (this.m.HasJingji)
			ret.push({ id = 36, type = "text", icon = "ui/icons/armor_damage.png", text = "【玄甲反震刺猬散】受近战攻击反削来敌 [color=" + pos + "]" + ::Math.round(8 * sc) + "[/color] 点身甲并震散 [color=" + pos + "]" + ::Math.round(4 * sc) + "[/color] 点内息" });
		if (this.m.HasZuixian)
			ret.push({ id = 37, type = "text", icon = "ui/icons/bravery.png", text = "【醉仙望月狂酒】定力 [color=" + pos + "]+" + ::Math.round(15 * sc) + "[/color]、招架 [color=" + pos + "]+" + ::Math.min(8, ::Math.round(6 * sc)) + "[/color]、近战总伤 [color=" + pos + "]+" + ::Math.round(10 * sc) + "%[/color]；[color=" + neg + "]射艺 -10、视野 -1[/color]" });
		if (this.m.HasXiantian)
			ret.push({ id = 38, type = "text", icon = "ui/icons/special.png", text = "【先天真气护体丹】以 1:2 内息化消至多 [color=" + pos + "]" + ::Math.min(32, ::Math.round(25 * sc)) + "%[/color] 气血实伤（合算减伤封顶 60%）" });
		if (this.m.HasLingfeng)
			ret.push({ id = 39, type = "text", icon = "ui/icons/initiative.png", text = "【踏雪凌风轻身露】移动内息消耗 [color=" + pos + "]-50%[/color]、越障免额外 AP，首轮先手身法 [color=" + pos + "]+" + ::Math.round(15 * sc) + "[/color]" });
		if (this.m.HasGufeng)
			ret.push({ id = 40, type = "text", icon = "ui/icons/direct_damage.png", text = "【孤锋破玉淬劲散】单手空副手/成对拳套穿甲 [color=" + pos + "]+12%[/color]（封顶 25%），对完好重甲破甲 [color=" + pos + "]+" + ::Math.round(15 * sc) + "%[/color]" });
		if (this.m.HasKongque)
			ret.push({ id = 41, type = "text", icon = "ui/icons/special.png", text = "【南疆孔雀胆淬毒膏】伤血 ≥4 时 [color=" + pos + "]" + ::Math.min(75, ::Math.round(55 * sc)) + "%[/color] 注入奇毒，对中毒目标命中 [color=" + pos + "]+" + ::Math.round(6 * sc) + "[/color]" });
		if (this.m.HasFugu)
			ret.push({ id = 42, type = "text", icon = "ui/icons/armor_damage.png", text = "【五仙腐骨蚀甲散】攻击命中腐蚀敌方 [color=" + pos + "]" + ::Math.round(10 * sc) + "[/color] 身甲（持盾再蚀 [color=" + pos + "]" + ::Math.round(6 * sc) + "[/color] 盾耐久）" });
		if (this.m.HasSuoxue)
			ret.push({ id = 43, type = "text", icon = "ui/icons/special.png", text = "【透骨寻隙封脉散】攻击 [color=" + pos + "]" + ::Math.min(55, ::Math.round(35 * sc)) + "%[/color] 震露【破绽】，击头/乘隙 [color=" + pos + "]" + ::Math.min(45, ::Math.round(30 * sc)) + "%[/color] 点穴封气" });
		if (this.m.HasShixue)
			ret.push({ id = 44, type = "text", icon = "ui/icons/health.png", text = "【血煞饮血狂战丸】对半血残敌总伤 [color=" + pos + "]+" + ::Math.round(12 * sc) + "%[/color]，斩杀活物回 [color=" + pos + "]+" + ::Math.round(10 * sc) + "[/color] 血 [color=" + pos + "]+" + ::Math.round(5 * sc) + "[/color] 气" });
		if (this.m.HasYingyan)
			ret.push({ id = 45, type = "text", icon = "ui/icons/vision.png", text = "【千里破雾鹰眼露】视野 [color=" + pos + "]+1[/color]、免夜盲，≥4 格远射命中 [color=" + pos + "]+" + ::Math.round(6 * sc) + "[/color] 且无视 25% 轻功避暗" });
		if (this.m.HasPili)
			ret.push({ id = 46, type = "text", icon = "ui/icons/shield_damage.png", text = "【神机震雷火药引】火器强弩或重击 [color=" + pos + "]" + ::Math.min(60, ::Math.round(40 * sc)) + "%[/color] 震敌【失衡】，碎盾 [color=" + pos + "]+" + ::Math.round(8 * sc) + "[/color]" });
		if (this.m.HasChunyang)
			ret.push({ id = 47, type = "text", icon = "ui/icons/bravery.png", text = "【龙虎纯阳破邪丹】对古墓机关与湘西尸傀总伤 [color=" + pos + "]+" + ::Math.round(18 * sc) + "%[/color]、焚甲 [color=" + pos + "]+" + ::Math.round(8 * sc) + "[/color]，抗惊骇 [color=" + pos + "]+" + ::Math.round(15 * sc) + "[/color]" });
		if (this.m.HasHufu)
			ret.push({ id = 48, type = "text", icon = "ui/icons/bravery.png", text = "【聚义虎符壮胆丸】开场必【战意高昂】，邻接 ≥2 同袍时双防 [color=" + pos + "]+4[/color]、定力 [color=" + pos + "]+" + ::Math.round(8 * sc) + "[/color]" });
		if (this.m.HasBaoming)
			ret.push({ id = 49, type = "text", icon = "ui/icons/health.png", text = "【天王吊命保心丹】单场 1 次致命一击锁血 1 点不死，触发立清流血奇毒并回 [color=" + pos + "]+" + ::Math.round(12 * sc) + "[/color] 血 [color=" + pos + "]+" + ::Math.round(10 * sc) + "[/color] 气" });
		if (this.m.HasZhenmo)
			ret.push({ id = 50, type = "text", icon = "ui/icons/melee_skill.png", text = "【太清镇魔定脉丹】镇压内功相克与残本散气反噬，落空叠下次命中 [color=" + pos + "]+" + ::Math.round(6 * sc) + "[/color]" + (this.m.PillAdaptStacks > 0 ? ("（当前 +" + (this.m.PillAdaptStacks * ::Math.round(6 * sc)) + "）") : "") });
		if (this.m.HasTihu)
			ret.push({ id = 51, type = "text", icon = "ui/icons/xp_received.png", text = "【紫芝醍醐悟道丹】人物历练经验 [color=" + pos + "]+35%[/color]，战后武学参战火候 [color=" + pos + "]+" + ::Math.round(50 * sc) + "%[/color]" });
		if (this.m.HasLiangyi)
			ret.push({ id = 52, type = "text", icon = "ui/icons/special.png", text = "【两仪逆命混元丹】镇压双内功逆冲并化混元破甲 [color=" + pos + "]+" + ::Math.round(12 * sc) + "%[/color]、回气 [color=" + pos + "]+3[/color]，且催化阳刚灼甲/阴柔凝霜共振！" });
		if (this.m.HasZhuyin)
			ret.push({ id = 53, type = "text", icon = "ui/icons/special.png", text = "【烛阴昼夜轮转丹】奇数轮【瞑夜】双防 [color=" + pos + "]+5[/color]、回气 [color=" + pos + "]+4[/color]；偶数轮【赤昼】总伤 [color=" + pos + "]+10%[/color]、近战灼甲 [color=" + pos + "]+10[/color]！" });
		if (this.m.HasKurong)
			ret.push({ id = 54, type = "text", icon = "ui/icons/health.png", text = "【枯荣生死涅槃丸】身负流血或中毒时双防 [color=" + pos + "]+4[/color]、回气 [color=" + pos + "]+4[/color]，首次残血触发枯荣涅槃涤毒回血 [color=" + pos + "]+" + ::Math.round(22 * sc) + "[/color]！" });
		if (this.m.HasShenmo)
			ret.push({ id = 55, type = "text", icon = "ui/icons/bravery.png", text = "【神魔一念辟邪丹】镇压邪功与残本反噬，对动摇/崩溃敌命中 [color=" + pos + "]+8[/color]，斩敌额外回气 [color=" + pos + "]+6[/color]（每轮2次）！" });
		if (this.m.HasBaize)
			ret.push({ id = 56, type = "text", icon = "ui/icons/melee_skill.png", text = "【白泽通玄勘破丹】每轮首次借机拦击或反击命中 [color=" + pos + "]+12[/color] 且必露【破绽】，战后武学参战火候 [color=" + pos + "]+25%[/color]！" });
		if (this.m.HasJianmu)
			ret.push({ id = 57, type = "text", icon = "ui/icons/armor_body.png", text = "【建木枯木逢春丹】每回合初自愈 [color=" + pos + "]+" + ::Math.round(6 * sc) + "[/color] 气血并修复 [color=" + pos + "]+6~10[/color] 点身甲（横练武学共振翻倍增益）！" });
		if (this.m.HasTaotie)
			ret.push({ id = 58, type = "text", icon = "ui/icons/fatigue.png", text = "【饕餮吞元化气丸】近战重创活物（伤血≥12）时鲸吞敌方 [color=" + pos + "]5[/color] 点内息化归丹田（每轮限2次）！" });
		if (this.m.HasYinglong)
			ret.push({ id = 59, type = "text", icon = "ui/icons/initiative.png", text = "【应龙行云御雷丹】移动行气消耗 [color=" + pos + "]-35%[/color]，施展【穿步/贯线刺】命中返还 [color=" + pos + "]+3[/color] 内息（每轮限2次）！" });
		if (this.m.HasChiyou)
			ret.push({ id = 60, type = "text", icon = "ui/icons/armor_damage.png", text = "【蚩尤兵主百战丹】破甲效能 [color=" + pos + "]+15%[/color]、碎盾 [color=" + pos + "]+10[/color]，斩敌立回 [color=" + pos + "]+5[/color] 内息并震慑邻敌检定 [color=" + pos + "]-8[/color] 定力！" });
		if (this.m.HasJinwu)
			ret.push({ id = 61, type = "text", icon = "ui/icons/armor_damage.png", text = "【金乌十日纯阳丹】每轮自涤寒霜迟缓，近战灼毁 [color=" + pos + "]10[/color] 身甲，迎战尸傀机关总伤 [color=" + pos + "]+16%[/color]！" });
		if (this.m.HasXiangliu)
			ret.push({ id = 62, type = "text", icon = "ui/icons/special.png", text = "【相柳九首万蛊丹】百毒不侵，攻击 [color=" + pos + "]55%[/color] 注入奇毒且击中已中毒目标时毒雾传染相邻敌军！" });
		if (this.m.HasXuangui)
			ret.push({ id = 63, type = "text", icon = "ui/icons/armor_body.png", text = "【玄龟镇海不坏丹】远伤 [color=" + pos + "]-18%[/color]、免晕免退，每轮首次受重击额外减免 [color=" + pos + "]12%[/color] 实伤（严守60%上限）！" });
		if (this.m.HasDijiang)
			ret.push({ id = 64, type = "text", icon = "ui/icons/initiative.png", text = "【帝江幻空缩地丹】身法 [color=" + pos + "]+16[/color]，每轮首次受远程或重击触发幻空折跃偏折 [color=" + pos + "]22%[/color] 实伤（严守60%上限）！" });
		if (this.m.HasJiuwei)
			ret.push({ id = 65, type = "text", icon = "ui/icons/bravery.png", text = "【九尾青丘摄魂丹】定力 [color=" + pos + "]+14[/color]、免魅惑梦魇，攻击伤血迫使敌手执行 [color=" + pos + "]-10[/color] 定力检定！" });
		if (this.m.HasXingtian)
			ret.push({ id = 66, type = "text", icon = "ui/icons/health.png", text = "【刑天常羊战魂丹】免疫击晕，气血低于 60% 时战魂沸腾令总伤 [color=" + pos + "]+14%[/color]、每轮回气 [color=" + pos + "]+4[/color]！" });
		if ((this.m.AuxMask & 1) != 0)
			ret.push({ id = 26, type = "text", icon = "ui/icons/health.png", text = "【生机丹韵】每轮初自愈 [color=" + pos + "]+3[/color] 气血（装配横练功法额外修甲 [color=" + pos + "]+4[/color]）" });
		if ((this.m.AuxMask & 2) != 0)
			ret.push({ id = 27, type = "text", icon = "ui/icons/armor_damage.png", text = "【赤阳丹韵】攻击破甲效能 [color=" + pos + "]+8%[/color]（主修阳刚内功近战额外灼损 [color=" + pos + "]5[/color] 身甲）" });
		if ((this.m.AuxMask & 4) != 0)
			ret.push({ id = 28, type = "text", icon = "ui/icons/fatigue.png", text = "【玄阴丹韵】每轮额外回气 [color=" + pos + "]+2[/color]（主修阴柔内功受近战反散来敌 [color=" + pos + "]4[/color] 内息）" });
		if ((this.m.AuxMask & 8) != 0)
			ret.push({ id = 30, type = "text", icon = "ui/icons/bravery.png", text = "【镇魂丹韵】定力 [color=" + pos + "]+6[/color]、抗惊骇 [color=" + pos + "]+8[/color]，攻击落空自动补下次命中 [color=" + pos + "]+5[/color]" });
		if ((this.m.AuxMask & 16) != 0)
			ret.push({ id = 31, type = "text", icon = "ui/icons/special.png", text = "【奇毒丹韵】伤血 ≥5 时 [color=" + pos + "]25%[/color] 附【暗器奇毒】，攻击中毒敌破甲 [color=" + pos + "]+10%[/color]" });
		if ((this.m.AuxMask & 32) != 0)
			ret.push({ id = 32, type = "text", icon = "ui/icons/health.png", text = "【造化丹韵】临时气血 [color=" + pos + "]+8[/color]、内息 [color=" + pos + "]+6[/color]，战后武学参战火候 [color=" + pos + "]+15%[/color]" });
		local cImpTT = this.wxGetCoreImprintSpec();
		if (cImpTT != null)
			ret.push({ id = 67, type = "text", icon = "ui/icons/special.png", text = "【本命丹韵 · " + cImpTT.Title + "】" + cImpTT.Desc });
		if (this.m.HasDanToxin)
			ret.push({ id = 29, type = "text", icon = "ui/icons/warning.png", text = "[color=" + neg + "]【丹毒郁结】超量混服第 3 枚备战丹：内息上限 -15、回气 -3，战后必染 3 日内伤！[/color]" });
		return ret;
	};

	q.onAdded <- function()
	{
		if (this.m.HasBaoming)
			this.syncBaomingNineLives();
	};

	q.onCombatStarted <- function()
	{
		this.m.PillKillsThisTurn = 0;
		this.m.PillAdaptStacks   = 0;
		this.m.KurongNirvanaUsed = false;
		this.m.BaizeUsedTurn     = false;
		this.m.TaotieQiTurn      = 0;
		this.m.YinglongQiTurn    = 0;
		this.m.DuhengStanceTurn  = false;
		this.m.PhasePillUsedTurn = false;
		this.m.AuxAdaptReady     = false;
		this.m.CoreQiTurn        = 0;
		if (this.m.HasBaoming)
			this.syncBaomingNineLives();

		local container = this.getContainer();
		local actor = container != null ? container.getActor() : null;
		if (actor == null || !actor.isAlive()) return;
		this.m.WX_BattleStarted = true;

		if (this.m.HasLingfeng)
		{
			if (this.m.PrevLevelAPCost < 0)
				this.m.PrevLevelAPCost = actor.m.LevelActionPointCost;
			actor.m.LevelActionPointCost = 0;
		}
		if (this.m.HasHufu && (::Wuxia.hasMember(actor, "getMoraleState")) && actor.getMoraleState() != ::Const.MoraleState.Ignore && actor.getMoraleState() < ::Const.MoraleState.Confident)
		{
			actor.setMoraleState(::Const.MoraleState.Confident);
		}
		local cImpStart = this.wxGetCoreImprintSpec();
		local hasOracleImp = (cImpStart != null && cImpStart.Mode == "oracle_sight");
		if (this.m.HasTihu || this.m.HasBaize || (this.m.AuxMask & 32) != 0 || hasOracleImp)
		{
			local tihuAdd   = this.m.HasTihu ? (0.50 * (this.m.PotencyScalePct / 100.0)) : 0.0;
			local baizeAdd  = this.m.HasBaize ? 0.25 : 0.0;
			local auxOrig   = ((this.m.AuxMask & 32) != 0) ? 0.15 : 0.0;
			local coreOrig  = hasOracleImp ? 0.15 : 0.0;
			local curMult   = ("WX_TihuMasteryMult" in actor.m) ? actor.m.WX_TihuMasteryMult : 1.0;
			actor.m.WX_TihuMasteryMult <- ::Math.maxf(curMult, 1.0 + tihuAdd + baizeAdd + auxOrig + coreOrig);
		}
	};

	q.onTurnStart <- function()
	{
		this.m.PillKillsThisTurn = 0;
		this.m.BaizeUsedTurn     = false;
		this.m.TaotieQiTurn      = 0;
		this.m.YinglongQiTurn    = 0;
		this.m.DuhengStanceTurn  = false;
		this.m.PhasePillUsedTurn = false;
		this.m.CoreQiTurn        = 0;
		local container = this.getContainer();
		local actor = container != null ? container.getActor() : null;
		if (actor == null || !actor.isAlive()) return;
		local sc = this.m.PotencyScalePct / 100.0;
		local mp = ("CraftBridge" in ::Wuxia) ? ::Wuxia.CraftBridge.getActorMartialProfile(actor) : null;
		local cImp = this.wxGetCoreImprintSpec();

		if (this.m.HasQingxin && ("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.isActorInMiasmaOrSwamp(actor))
		{
			::Wuxia.CombatRules.restoreQi(actor, 3);
		}
		if (this.m.HasGuiyuan && mp != null && mp.SubElement != "none")
		{
			if (actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + 4));
			::Wuxia.CombatRules.restoreQi(actor, 2);
		}
		if (this.m.HasJinwu && container != null)
		{
			if (container.hasSkill("effects.wx_status_frost_chill")) container.removeByID("effects.wx_status_frost_chill");
			if (container.hasSkill("effects.chilled")) container.removeByID("effects.chilled");
		}
		if (this.m.HasJiuwei && container != null)
		{
			if (container.hasSkill("effects.charmed")) container.removeByID("effects.charmed");
			if (container.hasSkill("effects.sleeping")) container.removeByID("effects.sleeping");
		}
		if ((this.m.AuxMask & 1) != 0 && mp != null && mp.HasHenglian && ::Wuxia.hasMember(actor, "getItems") && actor.getItems() != null)
		{
			local auxB = actor.getItems().getItemAtSlot(::Const.ItemSlot.Body);
			if (auxB != null && ::Wuxia.hasMember(auxB, "getArmor") && auxB.getArmor() < auxB.getArmorMax())
				auxB.setArmor(::Math.min(auxB.getArmorMax(), auxB.getArmor() + 4));
		}
		if (cImp != null && cImp.Mode == "sacred_wood")
		{
			if (actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + 3));
			if (::Wuxia.hasMember(actor, "getItems") && actor.getItems() != null)
			{
				local swB = actor.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (swB != null && ::Wuxia.hasMember(swB, "getArmor") && swB.getArmor() < swB.getArmorMax())
					swB.setArmor(::Math.min(swB.getArmorMax(), swB.getArmor() + 4));
			}
		}

		if (this.m.HasYuji)
		{
			if (container.hasSkill("effects.bleeding"))
				container.removeByID("effects.bleeding");
			if (actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + ::Math.round(5 * sc)));
		}
		if (this.m.HasJianmu)
		{
			if (actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + ::Math.round(6 * sc)));
			if (::Wuxia.hasMember(actor, "getItems") && actor.getItems() != null)
			{
				local jmBody = actor.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (jmBody != null && ::Wuxia.hasMember(jmBody, "getArmor") && jmBody.getArmor() < jmBody.getArmorMax())
				{
					local mcJ = container.getSkillByID("special.wx_martial_container");
					local hasHenglian = false;
					if (mcJ != null && "Slots" in mcJ.m)
					{
						foreach (sl in mcJ.m.Slots)
						{
							if (sl.ManualID != null && sl.Tier > 0)
							{
								local mdef = ::Wuxia.Slots.getManualDef(sl.ManualID);
								if (mdef != null && mdef.Category == "henglian") { hasHenglian = true; break; }
							}
						}
					}
					local armRep = hasHenglian ? 10 : 6;
					jmBody.setArmor(::Math.min(jmBody.getArmorMax(), jmBody.getArmor() + armRep));
				}
			}
		}
		if (this.m.HasKurong)
		{
			local hasAff = container.hasSkill("effects.bleeding") || container.hasSkill("effects.wx_status_poison_dart") || container.hasSkill("effects.spider_poison") || container.hasSkill("effects.goblin_poison");
			if (hasAff)
				::Wuxia.CombatRules.restoreQi(actor, 4);
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

	q.onBeforeDamageReceived <- function( _attacker, _skill, _hitInfo, _properties )
	{
		local container = this.getContainer();
		local actor = container != null ? container.getActor() : null;
		local sc = this.m.PotencyScalePct / 100.0;

		if (this.m.HasKurong && !this.m.KurongNirvanaUsed && actor != null && container != null && actor.getHitpointsMax() > 0)
		{
			local estDmg = (_hitInfo != null && ("DamageRegular" in _hitInfo)) ? _hitInfo.DamageRegular : 0;
			if ((actor.getHitpoints() - estDmg).tofloat() / actor.getHitpointsMax().tofloat() < 0.35)
			{
				this.m.KurongNirvanaUsed = true;
				foreach (clID in ["effects.bleeding", "effects.wx_status_poison_dart", "effects.spider_poison", "effects.goblin_poison"])
				{
					if (container.hasSkill(clID)) container.removeByID(clID);
				}
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + ::Math.round(22 * sc)));
			}
		}

		if (this.m.HasTiee && _hitInfo != null && ("BodyPart" in _hitInfo) && _hitInfo.BodyPart == ::Const.BodyPart.Head)
		{
			if (("BodyDamageMult" in _hitInfo) && _hitInfo.BodyDamageMult > 1.0)
				_hitInfo.BodyDamageMult = 1.0;
			_properties.DamageReceivedArmorMult *= 0.80;
		}

		if (this.m.HasJingji && _attacker != null && actor != null && _attacker.getID() != actor.getID() && _attacker.isAlive() && _skill != null && !_skill.isRanged())
		{
			if ((::Wuxia.hasMember(_attacker, "getItems")) && _attacker.getItems() != null)
			{
				local atkBody = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (atkBody != null && (::Wuxia.hasMember(atkBody, "getArmor")) && atkBody.getArmor() > 0)
					atkBody.setArmor(::Math.max(0, atkBody.getArmor() - ::Math.round(8 * sc)));
			}
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(_attacker) && (::Wuxia.hasMember(_attacker, "getFatigue")))
			{
				_attacker.setFatigue(::Math.min(_attacker.getFatigueMax(), _attacker.getFatigue() + ::Math.round(4 * sc)));
			}
		}

		local mpDef = ("CraftBridge" in ::Wuxia) ? ::Wuxia.CraftBridge.getActorMartialProfile(actor) : null;
		local cImpDef = this.wxGetCoreImprintSpec();

		if ((this.m.HasXuangui || this.m.HasDijiang) && !this.m.PhasePillUsedTurn && _hitInfo != null && ("CraftBridge" in ::Wuxia))
		{
			local isRangedP = (_skill != null && _skill.isRanged());
			local isHeavyP  = (("DamageRegular" in _hitInfo) && _hitInfo.DamageRegular >= 20);
			if (this.m.HasDijiang && (isRangedP || isHeavyP))
			{
				this.m.PhasePillUsedTurn = true;
				::Wuxia.CraftBridge.multCappedRegularDamageReceived(_properties, 0.78);
			}
			else if (this.m.HasXuangui && isHeavyP)
			{
				this.m.PhasePillUsedTurn = true;
				::Wuxia.CraftBridge.multCappedRegularDamageReceived(_properties, 0.88);
			}
		}

		if (this.m.HasQingxin && actor != null && _skill != null && _skill.getID().find("poison") != null)
		{
			::Wuxia.CombatRules.restoreQi(actor, 3);
		}

		if (_attacker != null && actor != null && _attacker.getID() != actor.getID() && _attacker.isAlive() && _skill != null && !_skill.isRanged())
		{
			if (this.m.HasBingxin && mpDef != null && (mpDef.MainElement == "yin" || mpDef.SubElement == "yin"))
			{
				if (_attacker.getSkills() != null && !_attacker.getSkills().hasSkill("effects.wx_status_frost_chill"))
					_attacker.getSkills().add(::new("scripts/skills/effects/wx_status_frost_chill"));
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(_attacker) && ::Wuxia.hasMember(_attacker, "getFatigue"))
					_attacker.setFatigue(::Math.min(_attacker.getFatigueMax(), _attacker.getFatigue() + 3));
			}
			if (this.m.HasBaishe && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_attacker)
				&& _attacker.getSkills() != null && ::Math.rand(1, 100) <= 30)
			{
				if (!_attacker.getSkills().hasSkill("effects.wx_status_poison_dart"))
					_attacker.getSkills().add(::new("scripts/skills/effects/wx_status_poison_dart"));
			}
			if (this.m.HasJinzun && mpDef != null && mpDef.HasHenglian && ::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
			{
				local jzB = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (jzB != null && jzB.getArmor() > 0)
					jzB.setArmor(::Math.max(0, jzB.getArmor() - 6));
			}
			if ((this.m.AuxMask & 4) != 0 && mpDef != null && (mpDef.MainElement == "yin" || mpDef.SubElement == "yin")
				&& !::Wuxia.CombatRules.isUndeadOrConstruct(_attacker) && ::Wuxia.hasMember(_attacker, "getFatigue"))
			{
				_attacker.setFatigue(::Math.min(_attacker.getFatigueMax(), _attacker.getFatigue() + 4));
			}
			if (cImpDef != null && cImpDef.Mode == "abyssal_frost" && _attacker.getSkills() != null)
			{
				if (!_attacker.getSkills().hasSkill("effects.wx_status_frost_chill"))
					_attacker.getSkills().add(::new("scripts/skills/effects/wx_status_frost_chill"));
			}
		}

		if (this.m.HasLiangyi && _attacker != null && actor != null && _attacker.getID() != actor.getID() && _attacker.isAlive() && _skill != null && !_skill.isRanged() && ("CraftBridge" in ::Wuxia))
		{
			local ngp = ::Wuxia.CraftBridge.getActorNeigongProfile(actor);
			if ((ngp.MainElement == "yin" || ngp.SubElement == "yin") && !::Wuxia.CombatRules.isUndeadOrConstruct(_attacker) && ::Wuxia.hasMember(_attacker, "getFatigue"))
			{
				_attacker.setFatigue(::Math.min(_attacker.getFatigueMax(), _attacker.getFatigue() + 5));
			}
		}

		// 先天真气护体丹: strictly enforces Math.max with manual QiShieldPct & global <= 60% HP mitigation ceiling (DamageReceivedRegularMult >= 0.40)
		if (this.m.HasXiantian && actor != null && _hitInfo != null && ("DamageRegular" in _hitInfo) && _hitInfo.DamageRegular > 0)
		{
			local mc = container != null ? container.getSkillByID("special.wx_martial_container") : null;
			local manualQiPct = (mc != null && mc.m.CachedAggFlags != null) ? mc.m.CachedAggFlags.QiShieldPct : 0.0;
			local targetQiPct = ::Math.minf(0.32, 0.25 * sc);
			local extraQiPct  = ::Math.maxf(0.0, targetQiPct - manualQiPct);
			local curRegMult  = _properties.DamageReceivedRegularMult;
			if (extraQiPct > 0.0 && curRegMult > 0.40)
			{
				local availQi = ::Math.max(0, actor.getFatigueMax() - actor.getFatigue());
				if (availQi > 0)
				{
					local minAllowedRatio = 0.40 / curRegMult;
					local maxShieldPct = ::Math.minf(extraQiPct, 1.0 - minAllowedRatio);
					local maxMitigate = ::Math.floor(_hitInfo.DamageRegular * maxShieldPct);
					local qiSpent = ::Math.min(availQi, ::Math.ceil(maxMitigate / 2.0));
					if (qiSpent > 0)
					{
						local actualMit = ::Math.min(maxMitigate, qiSpent * 2);
						local ratio = ::Math.maxf(minAllowedRatio, 1.0 - (actualMit.tofloat() / _hitInfo.DamageRegular.tofloat()));
						_properties.DamageReceivedRegularMult *= ratio;
						::Wuxia.CombatRules.spendQi(actor, qiSpent);
					}
				}
			}
		}
	};

	q.onAnySkillUsed <- function( _skill, _targetEntity, _properties )
	{
		if (_skill == null || !_skill.isAttack()) return;
		local container = this.getContainer();
		local actor = container != null ? container.getActor() : null;
		local sc = this.m.PotencyScalePct / 100.0;

		local mpAtk = ("CraftBridge" in ::Wuxia) ? ::Wuxia.CraftBridge.getActorMartialProfile(actor) : null;
		local cImpAtk = this.wxGetCoreImprintSpec();

		if (this.m.HasDingshen && ("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.isShadowOrSmokeEnv(actor, _targetEntity))
		{
			if (_skill.isRanged()) _properties.RangedSkill += 6;
			else _properties.MeleeSkill += 6;
		}
		if (cImpAtk != null && cImpAtk.Mode == "oracle_sight" && ("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.isShadowOrSmokeEnv(actor, _targetEntity))
		{
			if (_skill.isRanged()) _properties.RangedSkill += 5;
			else _properties.MeleeSkill += 5;
		}
		if (this.m.HasZhuyu && actor != null && ::Wuxia.hasMember(actor, "getFatigue") && ::Wuxia.hasMember(actor, "getFatigueMax")
			&& actor.getFatigueMax() > 0 && actor.getFatigue() * 2 >= actor.getFatigueMax())
		{
			if ("FatigueEffectMult" in _properties) _properties.FatigueEffectMult *= 0.90;
		}
		if ((this.m.AuxMask & 8) != 0 && this.m.AuxAdaptReady)
		{
			if (_skill.isRanged()) _properties.RangedSkill += 5;
			else _properties.MeleeSkill += 5;
		}
		if (_targetEntity != null)
		{
			local tskA = (::Wuxia.hasMember(_targetEntity, "getSkills")) ? _targetEntity.getSkills() : null;
			local targetPoisoned = tskA != null && (tskA.hasSkill("effects.wx_status_poison_dart") || tskA.hasSkill("effects.spider_poison") || tskA.hasSkill("effects.goblin_poison"));
			if ((this.m.AuxMask & 16) != 0 && targetPoisoned)
				_properties.DamageArmorMult += 0.10;
			if (cImpAtk != null && cImpAtk.Mode == "bitter_venom" && targetPoisoned)
			{
				if (_skill.isRanged()) _properties.RangedSkill += 4;
				else _properties.MeleeSkill += 4;
			}
			if (this.m.HasJinwu && ::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
				_properties.DamageTotalMult *= 1.16;
			else if (cImpAtk != null && cImpAtk.Mode == "solar_scorch" && ::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
				_properties.DamageTotalMult *= 1.08;
		}

		if (this.m.HasJiugong && !_skill.isRanged() && actor != null && ::Wuxia.hasMember(actor, "m") && actor.m != null && ("WX_IsIntercepting" in actor.m) && actor.m.WX_IsIntercepting)
		{
			_properties.MeleeSkill += ::Math.round(10 * sc);
		}
		if (this.m.HasBaize && !this.m.BaizeUsedTurn && !_skill.isRanged() && actor != null
			&& ((::Wuxia.hasMember(actor, "m") && actor.m != null && ("WX_IsIntercepting" in actor.m) && actor.m.WX_IsIntercepting)
				|| (container != null && container.hasSkill("effects.wx_status_counter_stance"))))
		{
			_properties.MeleeSkill += 12;
		}
		if (this.m.HasShenmo && _targetEntity != null && ::Wuxia.hasMember(_targetEntity, "getMoraleState") && _targetEntity.getMoraleState() <= ::Const.MoraleState.Wavering)
		{
			if (_skill.isRanged()) _properties.RangedSkill += 8;
			else _properties.MeleeSkill += 8;
		}
		if (this.m.HasZuixian && !_skill.isRanged())
		{
			_properties.DamageTotalMult *= (1.0 + 0.10 * sc);
		}
		if (this.m.HasZhenmo && this.m.PillAdaptStacks > 0)
		{
			local mc = container != null ? container.getSkillByID("special.wx_martial_container") : null;
			local manualAdapt = (mc != null && mc.m.CachedAggFlags != null && mc.m.FastAdaptStacks > 0)
				? (mc.m.FastAdaptStacks * mc.m.CachedAggFlags.FastAdaptBonus)
				: 0;
			local pillAdapt = this.m.PillAdaptStacks * ::Math.round(6 * sc);
			local addAdapt = ::Math.max(0, pillAdapt - manualAdapt);
			if (addAdapt > 0)
			{
				if (_skill.isRanged()) _properties.RangedSkill += addAdapt;
				else _properties.MeleeSkill += addAdapt;
			}
		}

		if (_targetEntity != null)
		{
			if (this.m.HasGufeng && (::Wuxia.hasMember(_targetEntity, "getArmor")) && (::Wuxia.hasMember(_targetEntity, "getArmorMax")))
			{
				local curA = _targetEntity.getArmor(::Const.BodyPart.Body) + _targetEntity.getArmor(::Const.BodyPart.Head);
				local maxA = _targetEntity.getArmorMax(::Const.BodyPart.Body) + _targetEntity.getArmorMax(::Const.BodyPart.Head);
				if (maxA >= 80 && curA * 2 >= maxA)
					_properties.DamageArmorMult *= (1.0 + 0.15 * sc);
			}
			if (this.m.HasKongque && (::Wuxia.hasMember(_targetEntity, "getSkills")) && _targetEntity.getSkills() != null)
			{
				local tsk = _targetEntity.getSkills();
				if (tsk.hasSkill("effects.wx_status_poison_dart") || tsk.hasSkill("effects.spider_poison") || tsk.hasSkill("effects.goblin_poison"))
				{
					local hitB = ::Math.round(6 * sc);
					if (_skill.isRanged()) _properties.RangedSkill += hitB;
					else _properties.MeleeSkill += hitB;
				}
			}
			if (this.m.HasShixue && (::Wuxia.hasMember(_targetEntity, "getHitpoints")) && (::Wuxia.hasMember(_targetEntity, "getHitpointsMax")) && _targetEntity.getHitpointsMax() > 0)
			{
				if ((_targetEntity.getHitpoints().tofloat() / _targetEntity.getHitpointsMax().tofloat()) < 0.50)
					_properties.DamageTotalMult *= (1.0 + 0.12 * sc);
			}
			if (this.m.HasChunyang && ::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
			{
				_properties.DamageTotalMult *= (1.0 + 0.18 * sc);
			}
			if (this.m.HasYingyan && _skill.isRanged() && actor != null && (::Wuxia.hasMember(actor, "isPlacedOnMap")) && actor.isPlacedOnMap() && (::Wuxia.hasMember(_targetEntity, "isPlacedOnMap")) && _targetEntity.isPlacedOnMap())
			{
				if (actor.getTile().getDistanceTo(_targetEntity.getTile()) >= 4)
					_properties.RangedSkill += ::Math.round(6 * sc);

				local mc2 = container != null ? container.getSkillByID("special.wx_martial_container") : null;
				local hasManualIgnore = (mc2 != null && mc2.m.CachedAggFlags != null && mc2.m.CachedAggFlags.IgnoreDodgeHalf);
				if (!hasManualIgnore && (::Wuxia.hasMember(_targetEntity, "getSkills")) && _targetEntity.getSkills() != null)
				{
					local tsk2 = _targetEntity.getSkills();
					local tInit = ::Math.max(0, _targetEntity.getInitiative());
					local dodge = tsk2.hasSkill("effects.dodge") ? ::Math.floor(tInit * 0.15) : 0;
					local tCont = tsk2.getSkillByID("special.wx_martial_container");
					if (tCont != null && tCont.m.CachedAggFlags != null)
						dodge += ::Math.floor(tInit * tCont.m.CachedAggFlags.InitToDefRatio);
					_properties.RangedSkill += ::Math.floor(dodge * 0.25);
				}
			}
		}
	};

	q.onTargetMissed <- function( _skill, _targetEntity )
	{
		if (_skill == null || !_skill.isAttack()) return;
		if (this.m.HasZhenmo)
			this.m.PillAdaptStacks = ::Math.min(5, this.m.PillAdaptStacks + 1);
		if ((this.m.AuxMask & 8) != 0)
			this.m.AuxAdaptReady = true;
	};

	q.onTargetHit <- function( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		if (_skill == null || !_skill.isAttack()) return;
		this.m.PillAdaptStacks = 0;
		this.m.AuxAdaptReady   = false;

		local container = this.getContainer();
		local actor = container != null ? container.getActor() : null;
		if (actor == null || _targetEntity == null || !_targetEntity.isAlive() || actor.isAlliedWith(_targetEntity))
			return;

		local sc = this.m.PotencyScalePct / 100.0;
		local tsk = (::Wuxia.hasMember(_targetEntity, "getSkills")) ? _targetEntity.getSkills() : null;
		local tItems = (::Wuxia.hasMember(_targetEntity, "getItems")) ? _targetEntity.getItems() : null;
		local poisonImmune = ::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity);

		local mpHit = ("CraftBridge" in ::Wuxia) ? ::Wuxia.CraftBridge.getActorMartialProfile(actor) : null;
		local cImpHit = this.wxGetCoreImprintSpec();

		// Legacy Pre-Battle Pills + 6 AuxInfusions + 7 New Boss Signature Pills + 64-Boss CoreImprints on-hit catalysts!
		if (this.m.HasHugu && !_skill.isRanged() && tItems != null)
		{
			local isYangOrHeavy = (mpHit != null && (mpHit.MainElement == "yang" || mpHit.SubElement == "yang"))
				|| (("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "concuss_armor"));
			if (isYangOrHeavy)
			{
				local hgB = tItems.getItemAtSlot(::Const.ItemSlot.Body);
				if (hgB != null && hgB.getArmor() > 0) hgB.setArmor(::Math.max(0, hgB.getArmor() - 6));
			}
		}
		if (this.m.HasDuheng && mpHit != null && mpHit.HasQinggong && ("CraftBridge" in ::Wuxia)
			&& (::Wuxia.CraftBridge.hasSkillMechanic(_skill, "step_through") || ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "push_advance")))
		{
			this.m.DuhengStanceTurn = true;
		}
		if ((this.m.AuxMask & 2) != 0 && !_skill.isRanged() && tItems != null && mpHit != null && (mpHit.MainElement == "yang" || mpHit.SubElement == "yang"))
		{
			local ayB = tItems.getItemAtSlot(::Const.ItemSlot.Body);
			if (ayB != null && ayB.getArmor() > 0) ayB.setArmor(::Math.max(0, ayB.getArmor() - 5));
		}
		if (this.m.HasChiyou && !_skill.isRanged() && tItems != null && ::Wuxia.hasMember(_targetEntity, "isArmedWithShield") && _targetEntity.isArmedWithShield())
		{
			local cySh = tItems.getItemAtSlot(::Const.ItemSlot.Offhand);
			if (cySh != null && ::Wuxia.hasMember(cySh, "applyShieldDamage")) cySh.applyShieldDamage(10);
		}
		if (this.m.HasJinwu && !_skill.isRanged() && tItems != null)
		{
			local jwB = tItems.getItemAtSlot(::Const.ItemSlot.Body);
			if (jwB != null && jwB.getArmor() > 0) jwB.setArmor(::Math.max(0, jwB.getArmor() - 10));
		}
		if (this.m.HasXiangliu && tsk != null && !poisonImmune)
		{
			local alreadyP = tsk.hasSkill("effects.wx_status_poison_dart") || tsk.hasSkill("effects.spider_poison") || tsk.hasSkill("effects.goblin_poison");
			if (::Math.rand(1, 100) <= 55 && !tsk.hasSkill("effects.wx_status_poison_dart"))
				tsk.add(::new("scripts/skills/effects/wx_status_poison_dart"));
			if (alreadyP && ::Wuxia.hasMember(_targetEntity, "isPlacedOnMap") && _targetEntity.isPlacedOnMap() && _targetEntity.getTile() != null)
			{
				local xlT = _targetEntity.getTile();
				for (local dx = 0; dx < 6; dx = ++dx)
				{
					if (!xlT.hasNextTile(dx)) continue;
					local nxt = xlT.getNextTile(dx);
					if (nxt.IsOccupiedByActor && nxt.getEntity() != null && nxt.getEntity().isAlive() && !actor.isAlliedWith(nxt.getEntity()) && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(nxt.getEntity()))
					{
						if (nxt.getEntity().getSkills() != null && !nxt.getEntity().getSkills().hasSkill("effects.wx_status_poison_dart"))
							nxt.getEntity().getSkills().add(::new("scripts/skills/effects/wx_status_poison_dart"));
						break;
					}
				}
			}
		}
		if (this.m.HasJiuwei && _damageInflictedHitpoints >= 4 && !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ::Wuxia.hasMember(_targetEntity, "checkMorale"))
		{
			_targetEntity.checkMorale(-1, -10);
		}
		if (cImpHit != null)
		{
			if ((cImpHit.Mode == "feral_might" || cImpHit.Mode == "solar_scorch") && !_skill.isRanged() && tItems != null)
			{
				local ciB = tItems.getItemAtSlot(::Const.ItemSlot.Body);
				if (ciB != null && ciB.getArmor() > 0) ciB.setArmor(::Math.max(0, ciB.getArmor() - 6));
				if (cImpHit.Mode == "feral_might" && (_damageInflictedHitpoints >= 12 || _damageInflictedArmor >= 20) && ("CraftBridge" in ::Wuxia))
					::Wuxia.CraftBridge.applyBossCounterHit(actor, _targetEntity, { BreakPts = 1 });
			}
			else if (cImpHit.Mode == "bitter_venom" && _damageInflictedHitpoints >= 4 && !poisonImmune && tsk != null && ::Math.rand(1, 100) <= 30)
			{
				if (!tsk.hasSkill("effects.wx_status_poison_dart"))
					tsk.add(::new("scripts/skills/effects/wx_status_poison_dart"));
			}
			else if (cImpHit.Mode == "thunder_shock" && !_skill.isRanged() && (_damageInflictedHitpoints >= 10 || _damageInflictedArmor >= 18)
				&& !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ::Wuxia.hasMember(_targetEntity, "getFatigue"))
			{
				_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + 5));
			}
			else if (cImpHit.Mode == "devour_qi" && !_skill.isRanged() && _damageInflictedHitpoints >= 12 && this.m.CoreQiTurn < 2 && !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
			{
				this.m.CoreQiTurn += 1;
				::Wuxia.CombatRules.restoreQi(actor, 3);
			}
			else if (cImpHit.Mode == "sonic_rattle" && _damageInflictedHitpoints >= 8 && !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
			{
				if (::Wuxia.hasMember(_targetEntity, "checkMorale")) _targetEntity.checkMorale(-1, -6);
				if (::Wuxia.hasMember(_targetEntity, "getFatigue"))
					_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + 3));
			}
		}

		if (((this.m.AuxMask & 16) != 0 && _damageInflictedHitpoints >= 5 && !poisonImmune && ::Math.rand(1, 100) <= 25)
			|| (this.m.HasKongque && _damageInflictedHitpoints >= 4 && !poisonImmune && ::Math.rand(1, 100) <= ::Math.min(75, ::Math.round(55 * sc))))
		{
			if (tsk != null)
			{
				local ex = tsk.getSkillByID("effects.wx_status_poison_dart");
				if (ex == null) tsk.add(::new("scripts/skills/effects/wx_status_poison_dart"));
				else if (::Wuxia.hasMember(ex, "resetDuration")) ex.resetDuration();
			}
		}

		if (this.m.HasFugu && tItems != null)
		{
			local tBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
			if (tBody != null && (::Wuxia.hasMember(tBody, "getArmor")) && tBody.getArmor() > 0)
				tBody.setArmor(::Math.max(0, tBody.getArmor() - ::Math.round(10 * sc)));
			if ((::Wuxia.hasMember(_targetEntity, "isArmedWithShield")) && _targetEntity.isArmedWithShield())
			{
				local sh = tItems.getItemAtSlot(::Const.ItemSlot.Offhand);
				if (sh != null && ::Wuxia.hasMember(sh, "applyShieldDamage"))
					sh.applyShieldDamage(::Math.round(6 * sc));
			}
		}

		if (this.m.HasChunyang && tItems != null && ::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
		{
			local uBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
			if (uBody != null && (::Wuxia.hasMember(uBody, "getArmor")) && uBody.getArmor() > 0)
				uBody.setArmor(::Math.max(0, uBody.getArmor() - ::Math.round(8 * sc)));
		}

		if (this.m.HasLiangyi && !_skill.isRanged() && tItems != null && ("CraftBridge" in ::Wuxia))
		{
			local ngAtk = ::Wuxia.CraftBridge.getActorNeigongProfile(actor);
			if (ngAtk.MainElement == "yang" || ngAtk.SubElement == "yang" || ngAtk.HasConflict)
			{
				local lyBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
				if (lyBody != null && lyBody.getArmor() > 0)
					lyBody.setArmor(::Math.max(0, lyBody.getArmor() - 6));
			}
		}

		if (this.m.HasZhuyin && !_skill.isRanged() && tItems != null && (this.wxCurrentRound() % 2) == 0)
		{
			local zyBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
			if (zyBody != null && zyBody.getArmor() > 0)
				zyBody.setArmor(::Math.max(0, zyBody.getArmor() - 10));
		}

		if (this.m.HasBaize && !this.m.BaizeUsedTurn && !_skill.isRanged() && tsk != null
			&& ((::Wuxia.hasMember(actor, "m") && actor.m != null && ("WX_IsIntercepting" in actor.m) && actor.m.WX_IsIntercepting)
				|| (container != null && container.hasSkill("effects.wx_status_counter_stance"))))
		{
			this.m.BaizeUsedTurn = true;
			if (!tsk.hasSkill("effects.wx_status_opening"))
				tsk.add(::new("scripts/skills/effects/wx_status_opening"));
		}

		if (this.m.HasTaotie && !_skill.isRanged() && this.m.TaotieQiTurn < 2 && _damageInflictedHitpoints >= 12
			&& !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
		{
			this.m.TaotieQiTurn += 1;
			if (::Wuxia.hasMember(_targetEntity, "getFatigue"))
				_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + 5));
			::Wuxia.CombatRules.restoreQi(actor, 5);
		}

		if (this.m.HasYinglong && this.m.YinglongQiTurn < 2 && ("CraftBridge" in ::Wuxia)
			&& (::Wuxia.CraftBridge.hasSkillMechanic(_skill, "step_through") || ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "pierce_line")))
		{
			this.m.YinglongQiTurn += 1;
			::Wuxia.CombatRules.restoreQi(actor, 3);
		}

		if (this.m.HasSuoxue && tsk != null)
		{
			if (::Math.rand(1, 100) <= ::Math.min(55, ::Math.round(35 * sc)))
			{
				local op = tsk.getSkillByID("effects.wx_status_opening");
				if (op == null) tsk.add(::new("scripts/skills/effects/wx_status_opening"));
				else if (::Wuxia.hasMember(op, "resetDuration")) op.resetDuration();
			}
			if (!poisonImmune && (_bodyPart == ::Const.BodyPart.Head || tsk.hasSkill("effects.wx_status_opening"))
				&& ::Math.rand(1, 100) <= ::Math.min(45, ::Math.round(30 * sc)))
			{
				local ac = tsk.getSkillByID("effects.wx_status_acupoint");
				if (ac == null) tsk.add(::new("scripts/skills/effects/wx_status_acupoint"));
				else if (::Wuxia.hasMember(ac, "resetDuration")) ac.resetDuration();
			}
		}

		if (this.m.HasPili)
		{
			if (tsk != null && (_skill.isRanged() || _damageInflictedHitpoints >= 12 || _damageInflictedArmor >= 22)
				&& ::Math.rand(1, 100) <= ::Math.min(60, ::Math.round(40 * sc)))
			{
				local ob = tsk.getSkillByID("effects.wx_status_offbalance");
				if (ob == null) tsk.add(::new("scripts/skills/effects/wx_status_offbalance"));
				else if (::Wuxia.hasMember(ob, "resetDuration")) ob.resetDuration();
			}
			if (tItems != null && (::Wuxia.hasMember(_targetEntity, "isArmedWithShield")) && _targetEntity.isArmedWithShield())
			{
				local sh2 = tItems.getItemAtSlot(::Const.ItemSlot.Offhand);
				if (sh2 != null && ::Wuxia.hasMember(sh2, "applyShieldDamage"))
					sh2.applyShieldDamage(::Math.round(8 * sc));
			}
		}
	};

	q.onTargetKilled <- function( _targetEntity, _skill )
	{
		local container = this.getContainer();
		local actor = container != null ? container.getActor() : null;
		if (::Wuxia.CombatRules.isSelfOrDyingKill(actor, _targetEntity)) return;

		local cImpKill = this.wxGetCoreImprintSpec();
		if (cImpKill != null && cImpKill.Mode == "devour_qi" && this.m.CoreQiTurn < 2 && (_targetEntity == null || !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity)))
		{
			this.m.CoreQiTurn += 1;
			::Wuxia.CombatRules.restoreQi(actor, 3);
		}
		if (this.m.HasChiyou)
		{
			::Wuxia.CombatRules.restoreQi(actor, 5);
			if (_targetEntity != null && ::Wuxia.hasMember(_targetEntity, "isPlacedOnMap") && _targetEntity.isPlacedOnMap() && _targetEntity.getTile() != null)
			{
				local cyT = _targetEntity.getTile();
				for (local dk = 0; dk < 6; dk = ++dk)
				{
					if (!cyT.hasNextTile(dk)) continue;
					local nk = cyT.getNextTile(dk);
					if (nk.IsOccupiedByActor && nk.getEntity() != null && nk.getEntity().isAlive() && !actor.isAlliedWith(nk.getEntity())
						&& !::Wuxia.CombatRules.isUndeadOrConstruct(nk.getEntity()) && ::Wuxia.hasMember(nk.getEntity(), "checkMorale"))
					{
						nk.getEntity().checkMorale(-1, -8);
						break;
					}
				}
			}
		}

		if (this.m.HasShenmo && this.m.PillKillsThisTurn < 2)
		{
			::Wuxia.CombatRules.restoreQi(actor, 6);
		}

		if (!this.m.HasShixue || this.m.PillKillsThisTurn >= 2)
		{
			if (this.m.HasShenmo && this.m.PillKillsThisTurn < 2)
				this.m.PillKillsThisTurn += 1;
			return;
		}
		if (_targetEntity != null && ::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity)) return;

		this.m.PillKillsThisTurn += 1;
		local sc = this.m.PotencyScalePct / 100.0;
		if (actor.getHitpoints() < actor.getHitpointsMax())
			actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + ::Math.round(10 * sc)));
		::Wuxia.CombatRules.restoreQi(actor, ::Math.round(5 * sc));
	};

	q.onUpdate = @(__original) function( _properties )
	{
		local container = this.getContainer();
		local actor = container != null ? container.getActor() : null;
		local prevStam = _properties.Stamina;
		local prevBrav = _properties.Bravery;
		local prevHP   = _properties.Hitpoints;
		local prevInit = _properties.Initiative;
		local prevMDef = _properties.MeleeDefense;
		local prevRDef = _properties.RangedDefense;
		local prevRec  = _properties.FatigueRecoveryRate;
		__original(_properties);

		local sc = this.m.PotencyScalePct / 100.0;
		if (this.m.PotencyScalePct != 100)
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
		if (this.m.HasJuling)
		{
			_properties.DamageReceivedArmorMult *= 0.90;
			if (actor != null)
			{
				local armPen = ::Wuxia.CombatRules.getArmorStaminaPenalty(actor);
				if (armPen > 0)
				{
					local hasBrawny = (container != null && container.hasSkill("perk.brawny"));
					local ratio = (hasBrawny ? 0.11 : 0.22) * sc;
					local cap   = hasBrawny ? 10 : 18;
					local refund = ::Math.min(cap, ::Math.round(armPen * ratio).tointeger());
					if (refund > 0) _properties.Stamina += refund;
				}
			}
		}
		if (this.m.HasJiugong)
		{
			local mcJ = container != null ? container.getSkillByID("special.wx_martial_container") : null;
			local alreadyUnderdog = (container != null && container.hasSkill("perk.underdog"))
				|| (mcJ != null && mcJ.m.CachedAggFlags != null && (mcJ.m.CachedAggFlags.StaffGuard || mcJ.m.CachedAggFlags.UnderdogGuard));
			if (!alreadyUnderdog && ("SurroundedDefense" in _properties))
				_properties.SurroundedDefense += 5;
		}
		if (this.m.HasZuixian)
		{
			local wantBrv = ::Math.round(15 * sc);
			local curBrvGain = _properties.Bravery - prevBrav;
			if (curBrvGain < wantBrv)
				_properties.Bravery += (wantBrv - curBrvGain);
			local wantMD = ::Math.min(8, ::Math.round(6 * sc));
			local curMDGain = _properties.MeleeDefense - prevMDef;
			if (curMDGain < wantMD)
				_properties.MeleeDefense += (wantMD - curMDGain);
			_properties.RangedSkill -= 10;
			_properties.Vision -= 1;
		}
		if (this.m.HasLingfeng)
		{
			if ("MovementFatigueCostMult" in _properties)
				_properties.MovementFatigueCostMult *= 0.50;
			if (this.wxCurrentRound() <= 1)
				_properties.Initiative += ::Math.round(15 * sc);
			if (actor != null && ("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive())
			{
				if (this.m.PrevLevelAPCost < 0)
					this.m.PrevLevelAPCost = actor.m.LevelActionPointCost;
				actor.m.LevelActionPointCost = 0;
			}
		}
		if (this.m.HasGufeng && actor != null)
		{
			local mainWpn = (::Wuxia.hasMember(actor, "getItems") && actor.getItems() != null)
				? actor.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand)
				: null;
			local isDuelOrFist = ::Wuxia.CombatRules.hasSingleHandEmptyOffhand(actor)
				|| (mainWpn != null && ::Wuxia.CombatRules.matchesWeapon(mainWpn, ["Fist"]));
			if (isDuelOrFist)
			{
				local curAdd2 = _properties.DamageDirectAdd;
				local room2 = (0.25 > curAdd2) ? (0.25 - curAdd2) : 0.0;
				local addPen2 = (0.12 < room2) ? 0.12 : room2;
				if (addPen2 > 0.0)
					_properties.DamageDirectAdd += addPen2;
			}
		}
		if (this.m.HasYingyan)
		{
			_properties.Vision += 1;
			_properties.IsAffectedByNight = false;
		}
		if (this.m.HasChunyang && ("MoraleCheckBravery" in _properties) && typeof _properties.MoraleCheckBravery == "array" && _properties.MoraleCheckBravery.len() > 0)
		{
			_properties.MoraleCheckBravery[0] += ::Math.round(15 * sc);
		}
		if (this.m.HasTihu)
		{
			if ("XPGainMult" in _properties)
				_properties.XPGainMult *= 1.35;
			if (actor != null && ::Wuxia.hasMember(actor, "m") && actor.m != null)
				actor.m.WX_TihuMasteryMult <- (1.0 + 0.50 * sc);
		}
		if (this.m.HasLiangyi)
		{
			_properties.DamageArmorMult += (0.12 * sc);
			_properties.FatigueRecoveryRate += 3;
			if (actor != null && ::Wuxia.hasMember(actor, "m") && actor.m != null)
				actor.m.WX_SuppressNeigongConflict <- true;
		}
		if (this.m.HasZhuyin)
		{
			if ((this.wxCurrentRound() % 2) == 1)
			{
				_properties.MeleeDefense += 5;
				_properties.RangedDefense += 5;
				_properties.FatigueRecoveryRate += 4;
			}
			else
			{
				_properties.DamageTotalMult *= 1.10;
			}
		}
		if (this.m.HasKurong && container != null)
		{
			local hasAffK = container.hasSkill("effects.bleeding") || container.hasSkill("effects.wx_status_poison_dart") || container.hasSkill("effects.spider_poison") || container.hasSkill("effects.goblin_poison");
			if (hasAffK)
			{
				_properties.MeleeDefense += 4;
				_properties.RangedDefense += 4;
				_properties.FatigueRecoveryRate += 4;
			}
		}
		if (this.m.HasShenmo && actor != null && ::Wuxia.hasMember(actor, "m") && actor.m != null)
		{
			actor.m.WX_SuppressNeigongConflict <- true;
		}
		if (this.m.HasYinglong && ("MovementFatigueCostMult" in _properties))
		{
			_properties.MovementFatigueCostMult *= 0.65;
		}
		local mpUp = ("CraftBridge" in ::Wuxia) ? ::Wuxia.CraftBridge.getActorMartialProfile(actor) : null;
		if (this.m.HasDuheng && this.m.DuhengStanceTurn)
		{
			_properties.MeleeDefense += 3;
			_properties.RangedDefense += 3;
		}
		if (this.m.HasDixiu && mpUp != null && mpUp.HasHenglian)
		{
			_properties.DamageReceivedArmorMult *= 0.88;
		}
		if (this.m.HasChiyou)
		{
			_properties.DamageArmorMult += (0.15 * sc);
		}
		if (this.m.HasXiangliu)
		{
			_properties.IsImmuneToPoison = true;
		}
		if (this.m.HasXuangui)
		{
			_properties.DamageReceivedRangedMult *= 0.82;
			_properties.IsImmuneToKnockBackAndGrab = true;
			_properties.IsImmuneToStun = true;
		}
		if (this.m.HasDijiang)
		{
			_properties.Initiative += ::Math.round(16 * sc);
		}
		if (this.m.HasJiuwei)
		{
			_properties.Bravery += ::Math.round(14 * sc);
		}
		if (this.m.HasXingtian)
		{
			_properties.IsImmuneToStun = true;
			if (actor != null && ::Wuxia.hasMember(actor, "getHitpointsMax") && actor.getHitpointsMax() > 0
				&& (actor.getHitpoints().tofloat() / actor.getHitpointsMax().tofloat()) < 0.60)
			{
				_properties.DamageTotalMult *= 1.14;
				_properties.FatigueRecoveryRate += 4;
			}
		}

		// Apply 64-Boss Inner-Core Imprint (`本命妖丹丹韵`) passive updates
		local cImpUp = this.wxGetCoreImprintSpec();
		if (cImpUp != null)
		{
			if (cImpUp.Mode == "abyssal_frost")
				_properties.FatigueRecoveryRate += 2;
			else if (cImpUp.Mode == "gale_stride")
			{
				_properties.Initiative += 8;
				if (this.wxCurrentRound() <= 1) _properties.Initiative += 6;
			}
			else if (cImpUp.Mode == "bastion_shell")
			{
				_properties.DamageReceivedArmorMult *= 0.90;
				_properties.Bravery += 6;
			}
			else if (cImpUp.Mode == "war_spirit" && actor != null && ::Wuxia.hasMember(actor, "getHitpointsMax") && actor.getHitpointsMax() > 0
				&& (actor.getHitpoints().tofloat() / actor.getHitpointsMax().tofloat()) < 0.60)
			{
				_properties.DamageTotalMult *= 1.08;
				_properties.Bravery += 8;
			}
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

	q.onAfterUpdate <- function( _properties )
	{
		if (!this.m.HasHufu) return;
		local container = this.getContainer();
		local actor = container != null ? container.getActor() : null;
		if (actor == null || !("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive() || !actor.isPlacedOnMap())
			return;

		local myTile = actor.getTile();
		local adjAllies = 0;
		local allies = ::Tactical.Entities.getInstancesOfFaction(actor.getFaction());
		foreach (ally in allies)
		{
			if (ally == null || ally.getID() == actor.getID() || !ally.isAlive() || !ally.isPlacedOnMap()) continue;
			if (ally.getMoraleState() == ::Const.MoraleState.Fleeing) continue;
			if (myTile.getDistanceTo(ally.getTile()) == 1)
				adjAllies += 1;
		}
		if (adjAllies >= 2)
		{
			local sc = this.m.PotencyScalePct / 100.0;
			_properties.MeleeDefense += 4;
			_properties.RangedDefense += 4;
			_properties.Bravery += ::Math.round(8 * sc);
		}
	};

	q.onCombatFinished = @(__original) function()
	{
		if (!this.m.WX_BattleStarted) return;
		this.m.WX_BattleStarted = false;
		local container = this.getContainer();
		local actor = container != null ? container.getActor() : null;
		if (this.m.PrevLevelAPCost >= 0 && actor != null)
		{
			actor.m.LevelActionPointCost = this.m.PrevLevelAPCost;
			this.m.PrevLevelAPCost = -1;
		}
		if (container != null)
		{
			local nl = container.getSkillByID("perk.nine_lives");
			if (nl != null && ("WX_FromBaomingPill" in nl.m) && nl.m.WX_FromBaomingPill)
			{
				nl.removeSelf();
				local mc = container.getSkillByID("special.wx_martial_container");
				if (mc != null) mc.syncGrantedSkills();
			}
		}

		local needFengmoInj = (this.m.HasFengmo && !this.m.FengmoNoInjury);
		if (container != null && (needFengmoInj || this.m.HasDanToxin))
		{
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

	// Clean 1/2/3/5/9-byte varint save stream (100% lossless backward compatibility with all existing 1/2/3/5-byte saves!)
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

		// Older save streams leave bit 4 clear, which keeps the default +6 herb bonus.
		local mask3 = (this.m.HasLonghu ? 1 : 0)
			| (this.m.HasFengmo ? 2 : 0)
			| (this.m.HasDanToxin ? 4 : 0)
			| (this.m.FengmoNoInjury ? 8 : 0)
			| (this.m.HasHerbCalm && this.m.HerbCalmBravery == 8 ? 16 : 0);

		local extPillMask = 0;
		foreach (sp in extBuffSpecs)
		{
			if (this.m[sp.Field])
				extPillMask = extPillMask | (1 << sp.Bit);
		}
		local extPillMask2 = 0;
		foreach (sp2 in extBuffSpecs2)
		{
			if (this.m[sp2.Field])
				extPillMask2 = extPillMask2 | (1 << sp2.Bit);
		}
		local hasExt2 = (extPillMask2 != 0 || this.m.CoreImprintID != "");
		if (hasExt2)
			extPillMask = extPillMask | (1 << 30);

		local hasExt = (this.m.AuxMask != 0 || this.m.PotencyScalePct != 100 || extPillMask != 0);

		if (hasExt)
		{
			_out.writeU8(mask1 | 128);
			_out.writeU8(mask2 | 128);
			_out.writeU8(mask3 | 128);
			_out.writeU8((this.m.AuxMask & 63) | (extPillMask != 0 ? 128 : 0));
			_out.writeU8(::Math.max(80, ::Math.min(200, this.m.PotencyScalePct)));
			if (extPillMask != 0)
				_out.writeU32(extPillMask);
			if (hasExt2)
			{
				_out.writeU32(extPillMask2);
				_out.writeString(this.m.CoreImprintID);
			}
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
		this.m.HerbCalmBravery = (mask3 & 16) != 0 ? 8 : 6;

		local extPillMask = 0;
		local extPillMask2 = 0;
		this.m.CoreImprintID = "";
		if (hasExt)
		{
			local rawAux           = _in.readU8();
			this.m.AuxMask         = rawAux & 63;
			this.m.PotencyScalePct = _in.readU8();
			if ((rawAux & 128) != 0)
			{
				extPillMask = _in.readU32();
				if ((extPillMask & (1 << 30)) != 0)
				{
					extPillMask2 = _in.readU32();
					this.m.CoreImprintID = _in.readString();
				}
			}
		}
		else
		{
			this.m.AuxMask         = 0;
			this.m.PotencyScalePct = 100;
		}
		foreach (sp in extBuffSpecs)
		{
			this.m[sp.Field] = (extPillMask & (1 << sp.Bit)) != 0;
		}
		foreach (sp2 in extBuffSpecs2)
		{
			this.m[sp2.Field] = (extPillMask2 & (1 << sp2.Bit)) != 0;
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

		local isBingxin = (def.Kind == "heal_internal_plus");
		if (def.Kind != null && (def.Kind.find("buff_") == 0 || isBingxin))
		{
			local buff = skills.getSkillByID("effects.wx_pill_battle_buff");
			local isThirdEffect = false;
			local isDanxiaPure = ((::Wuxia.hasMember(this, "getPillGrade")) && this.getPillGrade() >= 3);
			local kind = isBingxin ? "buff_bingxin" : def.Kind;
			if (buff != null && !(isBingxin && buff.hasBuffKind(kind)))
			{
				local chk = buff.canAcceptBattlePill(kind, _actor.getName());
				if (!chk.Ok) return chk;
				isThirdEffect = chk.WillTriggerToxin;
			}
			local res = __original(_actor);
			if (res.Ok && isThirdEffect)
			{
				if (isDanxiaPure)
				{
					res.Message += "（【丹霞无瑕】药性纯净圆融，兼容第 3 道备战药力。）";
				}
				else
				{
					res.Message += buff.applyDanToxinOverload();
					skills.update();
				}
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

		// Note: Items deposited in Town `百工丹坊`'s `百草药柜` stay stored at the workshop vault;
		// only finished pills & items physically carried in `兵甲行囊` (Stash) are usable in the field.
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

::Wuxia.UI.buildAlchemyModalPayload <- function( _inWorkshop = false )
{
	local hasAssets = ::Wuxia.hasWorldField("Assets");
	local stash = hasAssets ? ::World.Assets.getStash() : null;
	local money = hasAssets ? ::World.Assets.getMoney() : 0;

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
	local preViews = ::Wuxia.Alchemy.buildAutoPickSortedViews(ingList);
	local uiFormulas = [];
	local uiFreeRules = [];
	local totalFormulaCount = ::Wuxia.Config.Alchemy.Formulas.len();

	for (local fi = 0; fi < totalFormulaCount; fi = ++fi)
	{
		local f = ::Wuxia.Config.Alchemy.Formulas[fi];
		if (!(f.PillID in ::Wuxia.Config.Pills)) continue;
		local isDisc = ::Wuxia.Alchemy.isFormulaDiscovered(f.ID);
		local ruleCost = ::Math.max(50, ::Math.floor(f.SilverCost * mastery.CostMult));
		uiFreeRules.push({
			id                  = f.ID,
			discovered          = isDisc,
			junNatures          = f.JunNatures,
			minJunPotency       = f.MinJunPotency,
			requireRareJun      = f.RequireRareJun,
			requiredCoreKey     = ("RequiredCoreKey" in f) ? f.RequiredCoreKey : "",
			isHiddenMutation    = ("IsHiddenMutation" in f) && f.IsHiddenMutation,
			minAuxCount         = f.MinAuxCount,
			targetPotency       = f.TargetPotency,
			preferredAuxNatures = ("PreferredAuxNatures" in f) ? f.PreferredAuxNatures : [],
			silverCost          = ruleCost
		});
		// Hide undiscovered formulas completely in the handbook list so players discover & record recipes organically!
		if (!isDisc) continue;

		local pdef = ::Wuxia.Config.Pills[f.PillID];
		local qLabel = ("Quality" in pdef && pdef.Quality in ::Wuxia.Text.Qualities) ? ::Wuxia.Text.Qualities[pdef.Quality] : "灵丹";

		local natShorts = [];
		for (local ni = 0; ni < f.JunNatures.len(); ni = ++ni)
		{
			local nk = f.JunNatures[ni];
			if (nk in ::Wuxia.Config.Alchemy.Natures)
				natShorts.push(::Wuxia.Config.Alchemy.Natures[nk].Short);
		}

		local autoPick = ::Wuxia.Alchemy.autoPickIngredients(f.ID, ingList, preViews);
		local autoPv = ::Wuxia.Alchemy.previewBrew(f.ID, autoPick, ingMap, mastery, money);

		uiFormulas.push({
			id               = f.ID,
			category         = f.Category,
			pillID           = f.PillID,
			pillKind         = pdef.Kind,
			name             = pdef.Name,
			subLabel         = ("SubLabel" in pdef) ? pdef.SubLabel : "江湖灵丹",
			quality          = pdef.Quality,
			qualityLabel     = qLabel,
			icon             = "ui/items/" + pdef.Icon,
			description      = pdef.Description,
			formulaNote      = f.FormulaNote,
			baseYield        = f.BaseYield,
			junNatures       = f.JunNatures,
			junNatureText    = ::Wuxia.UI.wxJoinStrings(natShorts, "/"),
			minJunPotency    = f.MinJunPotency,
			requireRareJun   = f.RequireRareJun,
			requiredCoreKey  = ("RequiredCoreKey" in f) ? f.RequiredCoreKey : "",
			isHiddenMutation = ("IsHiddenMutation" in f) && f.IsHiddenMutation,
			minAuxCount      = f.MinAuxCount,
			targetPotency    = f.TargetPotency,
			silverCost       = ::Math.max(50, ::Math.floor(f.SilverCost * mastery.CostMult)),
			ownedCount       = (f.PillID in ownedPills) ? ownedPills[f.PillID] : 0,
			hasAutoIngredients = ("IngredientsReady" in autoPv) && autoPv.IngredientsReady,
			canAutoBrew      = autoPv.Ok,
			autoPick         = autoPick,
			autoPreview      = autoPv
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
		local uiQuenches = [];
		if ("QuenchCatalysts" in ::Wuxia.Forge)
		{
			foreach (qk in ["none", "frost", "flame", "thunder", "blood"])
			{
				if (!(qk in ::Wuxia.Forge.QuenchCatalysts)) continue;
				local qc = ::Wuxia.Forge.QuenchCatalysts[qk];
				local qf = ::Wuxia.Forge.findQuenchIngredient(qk, stash);
				uiQuenches.push({
					id         = qc.ID,
					name       = qc.Name,
					short      = qc.Short,
					color      = qc.Color,
					affixTitle = qc.AffixTitle,
					affixDesc  = qc.AffixDesc,
					available  = qf.Found,
					matName    = qf.Name
				});
			}
		}
		forgePayload = {
			smithLabel      = sm.SmithLabel,
			bonusHighPct    = sm.BonusHighPct,
			hasDiscount     = (sm.CostMult < 0.99),
			chances         = sm.Chances,
			pity            = ::Wuxia.Forge.getPity(),
			catalystFound   = cat.Found,
			catalystName    = cat.Name,
			catalystTotal   = ::Wuxia.Forge.countTotalBeastMats(stash),
			quenchCatalysts = uiQuenches,
			items           = ::Wuxia.Forge.collectReforgeableList(stash, sm)
		};
	}

	local uiFireModes = [];
	if ("FireModes" in ::Wuxia.Config.Alchemy)
	{
		foreach (fmk in ["gentle", "balanced", "fierce"])
		{
			if (!(fmk in ::Wuxia.Config.Alchemy.FireModes)) continue;
			local fm = ::Wuxia.Config.Alchemy.FireModes[fmk];
			uiFireModes.push({
				id          = fm.ID,
				title       = fm.Title,
				short       = fm.Short,
				color       = fm.Color,
				costMult    = fm.CostMult,
				grade2Bonus = fm.Grade2Bonus,
				grade3Bonus = fm.Grade3Bonus,
				doubleBonus = fm.DoubleBonus,
				desc        = fm.Desc
			});
		}
	}

	local uiHerbCodex = [];
	if ("Herbs" in ::Wuxia.Config)
	{
		foreach (hid, hdef in ::Wuxia.Config.Herbs)
		{
			local hn = ("HerbNatures" in ::Wuxia.Config.Alchemy && (hid in ::Wuxia.Config.Alchemy.HerbNatures))
				? ::Wuxia.Config.Alchemy.HerbNatures[hid]
				: { Nature = "vital", Potency = 3 };
			local natDef = (hn.Nature in ::Wuxia.Config.Alchemy.Natures)
				? ::Wuxia.Config.Alchemy.Natures[hn.Nature]
				: ::Wuxia.Config.Alchemy.Natures.vital;
			local cabKey = "herb:" + hid;
			local cabCnt = ::Wuxia.Alchemy.Cabinet.getCount(cabKey);
			local stCnt = (cabKey in ingMap) ? ingMap[cabKey].StashCount : 0;
			local qKey = ("Quality" in hdef) ? hdef.Quality : "sect";
			local qLabel = (("Text" in ::Wuxia) && ("Qualities" in ::Wuxia.Text) && (qKey in ::Wuxia.Text.Qualities)) ? ::Wuxia.Text.Qualities[qKey] : "奇珍";
			uiHerbCodex.push({
				key          = cabKey,
				id           = hid,
				name         = hdef.Name,
				chapter      = ("Chapter" in hdef) ? hdef.Chapter : "山海本草",
				subLabel     = ("SubLabel" in hdef) ? hdef.SubLabel : "奇草",
				quality      = qKey,
				qualityLabel = qLabel,
				nature       = hn.Nature,
				natureName   = natDef.Name,
				natureShort  = natDef.Short,
				natureColor  = natDef.Color,
				potency      = hn.Potency,
				cabinetCount = cabCnt,
				stashCount   = stCnt,
				totalCount   = cabCnt + stCnt,
				icon         = "ui/items/" + hdef.Icon,
				value        = hdef.Value,
				description  = hdef.Description
			});
		}
		uiHerbCodex.sort(function( _a, _b ) {
			local aHas = _a.totalCount > 0 ? 1 : 0;
			local bHas = _b.totalCount > 0 ? 1 : 0;
			if (aHas != bHas) return bHas - aHas;
			if (_a.potency != _b.potency) return _b.potency - _a.potency;
			if (_a.id < _b.id) return -1;
			if (_a.id > _b.id) return 1;
			return 0;
		});
	}

	local uiCoreImprints = {};
	if ("CoreImprints" in ::Wuxia.Config.Alchemy && "CoreImprintModes" in ::Wuxia.Config.Alchemy)
	{
		foreach (cidI, cimpI in ::Wuxia.Config.Alchemy.CoreImprints)
		{
			local msI = (cimpI.Mode in ::Wuxia.Config.Alchemy.CoreImprintModes)
				? ::Wuxia.Config.Alchemy.CoreImprintModes[cimpI.Mode]
				: { Color = "#f0bc42", PrepDesc = "" };
			uiCoreImprints[cidI] <- {
				title    = cimpI.Title,
				mode     = cimpI.Mode,
				color    = msI.Color,
				prepDesc = msI.PrepDesc
			};
		}
	}

	return {
		ok             = true,
		inWorkshop     = (_inWorkshop ? true : false),
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
		summary        = ::Wuxia.Alchemy.getCabinetSummaryCounts(stash, ingList),
		fireModes      = uiFireModes,
		natures        = uiNatures,
		auxInfusions   = uiAuxInfusions,
		coreImprints   = uiCoreImprints,
		ingredients            = uiIngredients,
		herbCodex              = uiHerbCodex,
		formulas               = uiFormulas,
		freeRules              = uiFreeRules,
		discoveredFormulaCount = uiFormulas.len(),
		totalFormulaCount      = totalFormulaCount,
		costMult               = mastery.CostMult,
		forge                  = forgePayload
	};
};

::Wuxia.UI.buildWashShowcase <- function( _bro, _res )
{
	if (_res == null) return null;
	local statIcons = [
		"ui/wx_icons/wx_icon_health.png",
		"ui/wx_icons/wx_icon_qi.png",
		"ui/wx_icons/wx_icon_bravery.png",
		"ui/wx_icons/wx_icon_initiative.png",
		"ui/wx_icons/wx_icon_melee_skill.png",
		"ui/wx_icons/wx_icon_ranged_skill.png",
		"ui/wx_icons/wx_icon_melee_def.png",
		"ui/wx_icons/wx_icon_ranged_def.png"
	];
	local pillIcons = {
		pending             = "ui/wx_icons/wx_icon_ap.png",
		wx_pill_zijin_xisui = "ui/items/consumables/wx_pill_zijin_xisui.png",
		wx_pill_xisui       = "ui/items/consumables/wx_pill_xisui.png",
		wx_pill_yijin_wan   = "ui/items/consumables/wx_pill_yijin_wan.png"
	};
	local pid = ("WashPillID" in _res && _res.WashPillID != null) ? _res.WashPillID : "wx_pill_xisui";
	local pIco = (pid in pillIcons) ? pillIcons[pid] : "ui/items/consumables/wx_pill_xisui.png";
	local aIdx = ("TargetAttrIdx" in _res && _res.TargetAttrIdx != null) ? _res.TargetAttrIdx : 0;
	local aIco = (aIdx >= 0 && aIdx < statIcons.len()) ? statIcons[aIdx] : statIcons[0];
	local okRoll = ("Succeeded" in _res) && _res.Succeeded;
	local avoidAll = ("AvoidAllShock" in _res) && _res.AvoidAllShock;
	local gotPerm = ("GotPermanentInjury" in _res) && _res.GotPermanentInjury;
	local outcome = okRoll ? "success" : (avoidAll ? "warded" : "fail");
	local title = okRoll
		? "洗经伐髓 · 脱胎换骨"
		: (avoidAll ? "造化护脉 · 经脉无恙" : (gotPerm ? "真气逆冲 · 经脉暗疾" : "洗髓冲关未成"));

	return {
		kind            = "wash",
		outcome         = outcome,
		title           = title,
		subtitle        = (_bro != null ? _bro.getName() : "侠客") + " · 服用「" + (("WashPillName" in _res) ? _res.WashPillName : "洗髓丹") + "」",
		broName         = _bro != null ? _bro.getName() : "",
		pillName        = ("WashPillName" in _res) ? _res.WashPillName : "洗髓丹",
		pillIcon        = pIco,
		targetAttrName  = ("TargetAttrName" in _res) ? _res.TargetAttrName : "根骨",
		targetAttrIcon  = aIco,
		oldStars        = ("OldStars" in _res) ? _res.OldStars : 0,
		newStars        = ("NextStar" in _res) ? _res.NextStar : 1,
		isReplaceMode   = ("IsReplaceMode" in _res) ? _res.IsReplaceMode : false,
		replaceAttrName = ("ReplaceAttrName" in _res) ? _res.ReplaceAttrName : "",
		gotPerm         = gotPerm,
		avoidedAll      = avoidAll,
		message         = ("Message" in _res) ? _res.Message : ""
	};
};

::Wuxia.UI.attachAlchemyRPCs <- function( _q, _isWorkshop = false )
{
	if (!::Wuxia.qHas(_q, "onWXShowcaseSound"))
	{
		_q.onWXShowcaseSound <- function( _cue )
		{
			local key = (typeof _cue == "array" && _cue.len() > 0) ? _cue[0] : _cue;
			::Wuxia.UI.playShowcaseSound(key);
			return { ok = true };
		};
	}
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
		local payload = ::Wuxia.UI.buildAlchemyModalPayload(_isWorkshop);
		return this.WX_wrapAlchemyResponse(payload, entityId, false);
	};

	_q.onWXAlchemySweep <- function( _data = null )
	{
		if (!_isWorkshop)
			return { ok = false, reason = "随身仅可查阅《丹经手札》与药柜账册——如需整理取放奇材、开炉炼丹或重锻神兵，请亲赴城镇【百工丹坊】操作！" };
		local incTrophies = (typeof _data == "array" && _data.len() >= 1) ? (_data[0] ? true : false) : false;
		local entityId    = (typeof _data == "array" && _data.len() >= 2) ? _data[1] : null;
		if (!::Wuxia.hasWorldField("Assets"))
			return { ok = false, reason = "当前无法访问战团仓库。" };

		local stash = ::World.Assets.getStash();
		local moved = ::Wuxia.Alchemy.Cabinet.storeFromStash(stash, true, incTrophies);
		local payload = ::Wuxia.UI.buildAlchemyModalPayload(true);
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
			local shortParts = [];
			if (moved.herbsMoved > 0)    { parts.push(moved.herbsMoved + " 株奇草"); shortParts.push("奇草×" + moved.herbsMoved); }
			if (moved.coresMoved > 0)    { parts.push(moved.coresMoved + " 枚内丹"); shortParts.push("内丹×" + moved.coresMoved); }
			if (moved.trophiesMoved > 0) { parts.push(moved.trophiesMoved + " 份异兽奇材"); shortParts.push("奇材×" + moved.trophiesMoved); }
			payload.actionMessage <- "收纳完毕！已将 " + ::Wuxia.UI.wxJoinStrings(parts, "、") + " 归入【百草药柜】，腾出 " + moved.slotsCleared + " 格仓库空间！";
			payload.sweepSummary  <- ::Wuxia.UI.wxJoinStrings(shortParts, " · ") + " 归入药柜";
		}
		return payload;
	};

	_q.onWXAlchemyWithdraw <- function( _data )
	{
		if (!_isWorkshop)
			return { ok = false, reason = "随身仅可查阅《丹经手札》与药柜账册——如需从百草药柜取出奇材，请亲赴城镇【百工丹坊】操作！" };
		local key      = _data[0];
		local qty      = (_data.len() >= 2 && _data[1] != null) ? _data[1] : 1;
		local entityId = (_data.len() >= 3) ? _data[2] : null;
		if (!::Wuxia.hasWorldField("Assets"))
			return { ok = false, reason = "当前无法访问战团仓库。" };

		local stash = ::World.Assets.getStash();
		local res = ::Wuxia.Alchemy.Cabinet.withdrawToStash(stash, key, qty);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		local payload = ::Wuxia.UI.buildAlchemyModalPayload(true);
		this.WX_wrapAlchemyResponse(payload, entityId, true);
		payload.actionMessage <- "已从百草药柜取出「" + res.Name + "」×" + res.Count + " 至战团仓库（可用于市集出售、应急生服或百工铸甲）。";
		return payload;
	};

	_q.onWXAlchemyToggleAuto <- function( _data )
	{
		if (!_isWorkshop)
			return { ok = false, reason = "随身仅可查阅《丹经手札》与药柜账册——如需调整百草药柜规制，请亲赴城镇【百工丹坊】操作！" };
		local mode     = _data[0];
		local enabled  = _data[1] ? true : false;
		local entityId = (_data.len() >= 3) ? _data[2] : null;

		local swept = { slotsCleared = 0 };
		if (mode == "autotrophy")
		{
			::Wuxia.Alchemy.Cabinet.setAutoTrophyEnabled(enabled);
			if (enabled && ::Wuxia.hasWorldField("Assets"))
				swept = ::Wuxia.Alchemy.Cabinet.storeFromStash(::World.Assets.getStash(), false, true);
		}
		else
		{
			::Wuxia.Alchemy.Cabinet.setAutoStoreEnabled(enabled);
			if (enabled && ::Wuxia.hasWorldField("Assets"))
				swept = ::Wuxia.Alchemy.Cabinet.storeFromStash(::World.Assets.getStash(), false, ::Wuxia.Alchemy.Cabinet.isAutoTrophyEnabled());
		}

		local payload = ::Wuxia.UI.buildAlchemyModalPayload(true);
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
		local fireMode = (_data.len() >= 5 && _data[4] != null && _data[4] != "") ? _data[4] : "balanced";
		return ::Wuxia.Alchemy.previewBrew(formulaID, slots, null, null, -1, fireMode);
	};

	_q.onWXAlchemyBrew <- function( _data )
	{
		if (!_isWorkshop)
			return { ok = false, reason = "行军途中无地火丹鼎——此处仅可查阅信息，欲开炉炼丹请亲赴州县城池【百工丹坊】操作！" };
		local formulaID = _data[0];
		local slots = [
			_data.len() >= 2 ? _data[1] : "",
			_data.len() >= 3 ? _data[2] : "",
			_data.len() >= 4 ? _data[3] : ""
		];
		local entityId = (_data.len() >= 5) ? _data[4] : null;
		local fireMode = (_data.len() >= 6 && _data[5] != null && _data[5] != "") ? _data[5] : "balanced";

		local res = null;
		if (formulaID == null || formulaID == "" || formulaID == "free")
		{
			res = ::Wuxia.Alchemy.executeFreeBrew(slots, fireMode);
		}
		else
		{
			if (!::Wuxia.Alchemy.isFormulaDiscovered(formulaID))
				return { ok = false, reason = "尚未参悟收录该道古丹方，请先通过「自由试丹」开炉参悟。" };
			res = ::Wuxia.Alchemy.executeBrew(formulaID, slots, fireMode);
		}
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		local payload = ::Wuxia.UI.buildAlchemyModalPayload(true);
		this.WX_wrapAlchemyResponse(payload, entityId, true);
		payload.brewResult    <- res;
		payload.actionMessage <- res.Message;

		local isTrial = ("IsTrialFallback" in res) && res.IsTrialFallback;
		local isCrit  = ("IsCrit" in res) && res.IsCrit;
		local discNm  = ("DiscoveredFormulaName" in res && res.DiscoveredFormulaName != null) ? res.DiscoveredFormulaName : "";
		local items   = ("Items" in res && res.Items != null) ? res.Items : [];
		local maxG    = 1;
		foreach (itc in items)
		{
			if (itc != null && ("grade" in itc) && itc.grade > maxG) maxG = itc.grade;
		}
		local outc = isTrial ? "trial" : ((isCrit || discNm != "" || maxG >= 3) ? "crit" : (maxG >= 2 ? "great" : "success"));
		local title = isTrial
			? "试炉未成古方 · 凝得药散"
			: (discNm != ""
				? "炉生瑞霭 · 新悟古丹方！"
				: (isCrit
					? "紫气东来 · 丹韵双成！"
					: (maxG >= 3 ? "丹霞天成 · 极品灵丹" : "八卦丹炉 · 开炉成丹")));
		local subtitle = isTrial
			? ("配伍尚未契合未录古方，炉中余药仍化作常备药散入囊（耗银 " + (("SilverCost" in res) ? res.SilverCost : 0) + " 两）")
			: ("耗纹银 " + (("SilverCost" in res) ? res.SilverCost : 0) + " 两，新成灵丹已收入战团行囊");

		payload.wxShowcase <- {
			kind                  = "alchemy",
			outcome               = outc,
			title                 = title,
			subtitle              = subtitle,
			inputs                = ("Inputs" in res && res.Inputs != null) ? res.Inputs : [],
			items                 = items,
			insight               = ("Insight" in res && res.Insight != null) ? res.Insight : "",
			discoveredFormulaName = discNm,
			isCrit                = isCrit,
			isTrial               = isTrial,
			message               = res.Message
		};
		return payload;
	};

	_q.onWXForgeReforge <- function( _data )
	{
		if (!_isWorkshop)
			return { ok = false, reason = "行军途中无百炼铁砧与地火炉膛——此处仅可查阅词条，欲重锻神兵请亲赴城镇【百工丹坊】操作！" };
		local uid      = _data[0];
		local entityId = (_data.len() >= 2) ? _data[1] : null;
		local quenchID = (_data.len() >= 3 && _data[2] != null) ? _data[2] : "none";
		local lockSlot = (_data.len() >= 4 && _data[3] != null) ? _data[3] : "";
		if (!("Forge" in ::Wuxia))
			return { ok = false, reason = "百工重锻系统尚未就绪。" };

		local res = ::Wuxia.Forge.executeReforge(uid, quenchID, lockSlot);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		local payload = ::Wuxia.UI.buildAlchemyModalPayload(true);
		this.WX_wrapAlchemyResponse(payload, entityId, true);
		payload.reforgeResult <- res;
		payload.actionMessage <- res.Message;

		local g = ("Grade" in res) ? res.Grade : 1;
		local outc = (g >= 3) ? "crit" : (g >= 2 ? "great" : "success");
		local title = (g >= 3)
			? "神工天成 · 炉吐金霞！"
			: (g >= 2 ? "百炼锋成 · 重淬大进" : "重锤淬火 · 词条重塑");
		local sub = ("UsedPity" in res && res.UsedPity)
			? ("【五锤炉温保底激发】耗「" + res.SpentMatName + "」与 " + res.SilverCost + " 两重铸并修满耐久")
			: ("耗「" + (("SpentMatName" in res) ? res.SpentMatName : "奇材") + "」与 " + (("SilverCost" in res) ? res.SilverCost : 0) + " 两重铸并修满耐久");
		payload.wxShowcase <- {
			kind             = "reforge",
			outcome          = outc,
			title            = title,
			subtitle         = sub,
			items            = ("ItemCard" in res && res.ItemCard != null) ? [res.ItemCard] : [],
			oldGradeTitle    = ("OldGradeTitle" in res) ? res.OldGradeTitle : "良工",
			oldGradeColor    = ("OldGradeColor" in res) ? res.OldGradeColor : "#5ec47a",
			oldPerfectionPct = ("OldPerfectionPct" in res) ? res.OldPerfectionPct : ::Wuxia.Forge.BasePerfectionPct,
			newGradeTitle    = ("GradeTitle" in res) ? res.GradeTitle : "良工",
			newGradeColor    = ("GradeColor" in res) ? res.GradeColor : "#5ec47a",
			newPerfectionPct = ("PerfectionPct" in res) ? res.PerfectionPct : ::Wuxia.Forge.BasePerfectionPct,
			usedPity         = ("UsedPity" in res) && res.UsedPity,
			message          = res.Message
		};
		return payload;
	};
};

// 5. Hook World Relations Ledger (Read-Only), Character Screen (Read-Only), & Town Workshop `百工丹坊` (Full Interactive)
::Wuxia.HooksMod.hook("scripts/ui/screens/world/modules/topbar/world_screen_topbar_options_module", function( q )
{
	::Wuxia.UI.attachAlchemyRPCs(q, false);
});

::Wuxia.HooksMod.hook("scripts/ui/screens/world/world_relations_screen", function( q )
{
	::Wuxia.UI.attachAlchemyRPCs(q, false);
});

::Wuxia.HooksMod.hook("scripts/ui/screens/world/modules/world_town_screen/town_taxidermist_dialog_module", function( q )
{
	::Wuxia.UI.attachAlchemyRPCs(q, true);

	if (::Wuxia.qHas(q, "queryBlueprints"))
	{
		q.queryBlueprints = @(__original) function()
		{
			local autoBanner = "";
			local stash = ::Wuxia.hasWorldField("Assets") ? ::World.Assets.getStash() : null;
			local skipSweep = ("BeastCraft" in ::Wuxia) && ::Wuxia.BeastCraft.SkipAutoStoreInQuery;
			if (!skipSweep && stash != null && ::Wuxia.Alchemy.Cabinet.isAutoStoreEnabled())
			{
				local moved = ::Wuxia.Alchemy.Cabinet.storeFromStash(stash, false, ::Wuxia.Alchemy.Cabinet.isAutoTrophyEnabled());
				if (moved.slotsCleared > 0)
					autoBanner = "百工掌柜已将行囊新获的 " + moved.slotsCleared + " 份奇草/内丹清点归入【百草药柜】（零仓库占格）！";
			}
			// Build one O(stash) itemID->count hash map for the entire 170-blueprint queryBlueprints pass!
			local hasBC = ("BeastCraft" in ::Wuxia) && ("buildStashCountMap" in ::Wuxia.BeastCraft);
			local prevCounts = hasBC ? ::Wuxia.BeastCraft.QueryStashCounts : null;
			if (hasBC && stash != null)
				::Wuxia.BeastCraft.QueryStashCounts = ::Wuxia.BeastCraft.buildStashCountMap(stash.getItems());
			local ret = null;
			try
			{
				ret = __original();
			}
			catch (_qErr)
			{
				if (hasBC) ::Wuxia.BeastCraft.QueryStashCounts = prevCounts;
				throw _qErr;
			}
			if (hasBC) ::Wuxia.BeastCraft.QueryStashCounts = prevCounts;

			if (autoBanner != "" && ret != null && typeof ret == "table")
			{
				ret.wxCraftBanner <- ("wxCraftBanner" in ret && ret.wxCraftBanner != "")
					? (ret.wxCraftBanner + " " + autoBanner)
					: autoBanner;
			}
			return ret;
		};
	}
});

::Wuxia.HooksMod.hook("scripts/ui/screens/character/character_screen", function( q )
{
	::Wuxia.UI.attachAlchemyRPCs(q, false);

	if (::Wuxia.qHas(q, "onWXInfusePill"))
	{
		q.onWXInfusePill = @(__original) function( _data )
		{
			local stashIndex = (typeof _data == "array" && _data.len() >= 2) ? _data[1] : 0;
			if (stashIndex <= -1000)
				return { ok = false, reason = "百草药柜奇材寄存于城镇【百工丹坊】，如需直接炼化请先赴百工丹坊取出至随军行囊！" };
			return __original(_data);
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
		local hasSelectedPill  = _data.len() >= 6 && _data[5] != null && _data[5] != "";
		local washPillID       = hasSelectedPill ? _data[5] : "wx_pill_xisui";

		local bro   = this.WX_findBrotherById(entityId);
		local stash = ::World.Assets.getStash();
		if (bro == null || stash == null)
			return { ok = false, reason = "未找到侠客或战团仓库。" };

		local washIdx = -1;
		if (!usePendingChance)
		{
			washIdx = ::Wuxia.Alchemy.findPillIndexByID(stash, washPillID);
			if (washIdx < 0 && !hasSelectedPill)
			{
				foreach (alt in ["wx_pill_zijin_xisui", "wx_pill_yijin_wan", "wx_pill_xisui"])
				{
					washIdx = ::Wuxia.Alchemy.findPillIndexByID(stash, alt);
					if (washIdx >= 0) { washPillID = alt; break; }
				}
			}
			if (washIdx < 0)
				return { ok = false, reason = hasSelectedPill ? "所选洗髓丹药已用尽，请重新选择。" : "战团仓库中缺少可用的洗髓丹药。" };
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
		state.wxShowcase    <- ::Wuxia.UI.buildWashShowcase(bro, res);
		return state;
	};
});

// High-tier Alchemy Elixirs (`忘尘归元散 / 玄冰辟火丸 / 疯魔燃血丸 / 易筋洗髓丸` etc.) are strictly crafted
// in the Eight-Trigrams Furnace (`八卦丹炉`) using Boss Neidan Cores & Spirit Herbs — never sold in ordinary town shops!
// (Cabinet-backed `scripts/crafting/blueprint.isQualified` is handled directly in `wx_beast_craft_system.nut` with O(1) caching.)
