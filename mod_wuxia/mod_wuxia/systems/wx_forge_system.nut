// Wuxia Equipment Forging Range, Quality Tiers & Masterwork Reforge System (百工铸造品相 · 随机属性范围 · 神兵重锻台)
// Strictly adheres to AGENTS.md D100 anti-inflation rules & 100% 0-byte backward-compatible save serialization!
// - 4 Forging Tiers: 凡锻 (0..34%) -> 良工 (35..69%) -> 百炼 (70..91%) -> 神工 (92..100%)
// - Blueprint Previews in 百工丹坊 display exact [最低 ~ 最高] stat ranges & smithing probabilities
// - Non-Named items (`wx_beast_*`, `wx_up_*`, `wx_acc_*`) persist exact rolled stats via U8-safe `Variant` (100..255)
// - Named items (`wx_relic_*`, `wx_armor_*`, `wx_helm_*`, `wx_shd_*`) persist rolled stats natively + `Variant` grade
// - 5-Hammer Furnace Pity (`wx_forge_pity` in `::World.Flags`): every 5 reforges without 百炼/神工 guarantees 百炼/神工!

::Wuxia.Forge <- {
	FallbackPity     = 0,
	LastCraftBanner  = "",
	RelicCleanCache  = {},
	Grades = [
		{ Grade = 0, Title = "凡锻", Color = "#a8a296", TooltipColor = "#3f362a", MinPct = 0,  MaxPct = 34,  ValueMult = 0.92, Span = 36, BaseSeed = 100 },
		{ Grade = 1, Title = "良工", Color = "#5ec47a", TooltipColor = "#0a4213", MinPct = 35, MaxPct = 69,  ValueMult = 1.00, Span = 40, BaseSeed = 136 },
		{ Grade = 2, Title = "百炼", Color = "#b58ae6", TooltipColor = "#4b1c76", MinPct = 70, MaxPct = 91,  ValueMult = 1.18, Span = 40, BaseSeed = 176 },
		{ Grade = 3, Title = "神工", Color = "#f0bc42", TooltipColor = "#5e2c00", MinPct = 92, MaxPct = 100, ValueMult = 1.42, Span = 40, BaseSeed = 216 }
	]
};

::Wuxia.Forge.lerpInt <- function( _minVal, _maxVal, _t )
{
	local f = _t < 0.0 ? 0.0 : (_t > 1.0 ? 1.0 : _t);
	return ::Math.round(_minVal + (_maxVal - _minVal) * f).tointeger();
};

::Wuxia.Forge.lerpStep <- function( _minVal, _maxVal, _t, _step = 0.01 )
{
	local f = _t < 0.0 ? 0.0 : (_t > 1.0 ? 1.0 : _t);
	local raw = _minVal + (_maxVal - _minVal) * f;
	return ::Math.round(raw / _step) * _step;
};

::Wuxia.Forge.stripGradePrefix <- function( _name )
{
	if (_name == null || _name == "") return "";
	foreach (g in ::Wuxia.Forge.Grades)
	{
		local pfx = "【" + g.Title + "】";
		if (_name.find(pfx) == 0)
			return _name.slice(pfx.len());
	}
	return _name;
};

::Wuxia.Forge.formatGradedName <- function( _baseName, _grade )
{
	local clean = ::Wuxia.Forge.stripGradePrefix(_baseName);
	if (_grade == null || _grade < 0 || _grade >= ::Wuxia.Forge.Grades.len())
		return clean;
	return "【" + ::Wuxia.Forge.Grades[_grade].Title + "】" + clean;
};

// -----------------------------------------------------------------------------
// 1. Smithing Mastery (Retinue 百炼随匠 + Roster Smith/Warrior Backgrounds) & 5-Hammer Pity
// -----------------------------------------------------------------------------
::Wuxia.Forge.getSmithMastery <- function()
{
	local bonusHighPct = 0;
	local costMult     = 1.0;
	local smithLabel   = "随营炉火";

	if ("World" in getroottable() && ::World != null && ("Retinue" in ::World) && ::World.Retinue != null)
	{
		try
		{
			if ("hasFollower" in ::World.Retinue && ::World.Retinue.hasFollower("follower.blacksmith"))
			{
				bonusHighPct += 14;
				costMult = 0.80;
				smithLabel = "百炼随匠主锤";
			}
		}
		catch (_e) {}
	}

	if ("World" in getroottable() && ::World != null && ("getPlayerRoster" in ::World) && ::World.getPlayerRoster() != null)
	{
		local bestBonus = 0;
		local bestName  = "";
		foreach (bro in ::World.getPlayerRoster().getAll())
		{
			if (bro == null || !bro.isAlive()) continue;
			local bg = bro.getBackground();
			local bgId = bg != null ? bg.getID() : "";
			local b = 0;
			if (bgId == "background.swordmaster" || bgId == "background.hedge_knight" || bgId == "background.mason" || bgId == "background.bowyer")
				b = 10;
			else if (bgId == "background.miner" || bgId == "background.lumberjack" || bgId == "background.brawler" || bgId == "background.beast_slayer")
				b = 6;

			if (b > bestBonus)
			{
				bestBonus = b;
				bestName = bro.getName();
			}
		}
		if (bestBonus > 0)
		{
			bonusHighPct += bestBonus;
			if (smithLabel == "随营炉火")
				smithLabel = bestName + " 掌锤";
			else
				smithLabel += " · " + bestName + " 协锻";
		}
	}

	bonusHighPct = ::Math.min(24, bonusHighPct);
	// Base distribution: 凡锻 22% / 良工 45% / 百炼 24% / 神工 9%
	local g3 = ::Math.min(20, 9 + ::Math.floor(bonusHighPct * 0.42));
	local g2 = ::Math.min(38, 24 + (bonusHighPct - (g3 - 9)));
	local g0 = ::Math.max(6, 22 - ::Math.floor(bonusHighPct * 0.65));
	local g1 = ::Math.max(20, 100 - g0 - g2 - g3);

	return {
		BonusHighPct = bonusHighPct,
		CostMult     = costMult,
		SmithLabel   = smithLabel,
		Chances      = [g0, g1, g2, g3]
	};
};

::Wuxia.Forge.getPity <- function()
{
	if (("World" in getroottable()) && ::World != null && ("Flags" in ::World) && ::World.Flags != null)
	{
		if (!::World.Flags.has("wx_forge_pity")) return 0;
		return ::Math.max(0, ::Math.min(5, ::World.Flags.getAsInt("wx_forge_pity")));
	}
	return ::Math.max(0, ::Math.min(5, ::Wuxia.Forge.FallbackPity));
};

::Wuxia.Forge.setPity <- function( _val )
{
	local v = ::Math.max(0, ::Math.min(5, _val));
	if (("World" in getroottable()) && ::World != null && ("Flags" in ::World) && ::World.Flags != null)
		::World.Flags.set("wx_forge_pity", v);
	else
		::Wuxia.Forge.FallbackPity = v;
	return v;
};

::Wuxia.Forge.consumeLastCraftBanner <- function()
{
	local msg = ::Wuxia.Forge.LastCraftBanner;
	::Wuxia.Forge.LastCraftBanner = "";
	return msg;
};

// -----------------------------------------------------------------------------
// 2. Deterministic U8-Safe Seed Codec (`Variant` in 100..255 -> 0 Extra Save Bytes!)
// -----------------------------------------------------------------------------
::Wuxia.Forge.encodeVariantSeed <- function( _grade, _subIdx )
{
	local g = ::Math.max(0, ::Math.min(3, _grade));
	local spec = ::Wuxia.Forge.Grades[g];
	local idx = ((_subIdx % spec.Span) + spec.Span) % spec.Span;
	return spec.BaseSeed + idx;
};

::Wuxia.Forge.decodeVariantSeed <- function( _variant )
{
	if (_variant == null || _variant < 100 || _variant > 255)
		return null;

	local gIdx = 0;
	if (_variant >= 216) gIdx = 3;
	else if (_variant >= 176) gIdx = 2;
	else if (_variant >= 136) gIdx = 1;
	else gIdx = 0;

	local spec = ::Wuxia.Forge.Grades[gIdx];
	local sub = _variant - spec.BaseSeed;
	local denom = (spec.Span - 1).tofloat();
	local lo = spec.MinPct / 100.0;
	local hi = spec.MaxPct / 100.0;

	local u1 = sub.tofloat() / denom;
	local u2 = ((sub * 7 + 5) % spec.Span).tofloat() / denom;
	local u3 = ((sub * 13 + 11) % spec.Span).tofloat() / denom;

	local f1 = lo + (hi - lo) * u1;
	local f2 = lo + (hi - lo) * u2;
	local f3 = lo + (hi - lo) * u3;

	if (gIdx == 3)
	{
		// Masterwork (`神工`) guarantees peak rolls on primary stats!
		if (f1 < 0.95) f1 = 0.95 + u1 * 0.05;
		if (f2 < 0.93) f2 = 0.93 + u2 * 0.07;
	}

	local perf = ::Math.round(((f1 + f2 + f3) / 3.0) * 100.0).tointeger();
	perf = ::Math.max(spec.MinPct, ::Math.min(spec.MaxPct, perf));

	return {
		Seed          = _variant,
		Grade         = gIdx,
		GradeTitle    = spec.Title,
		GradeColor    = spec.Color,
		ValueMult     = spec.ValueMult,
		F1            = f1,
		F2            = f2,
		F3            = f3,
		PerfectionPct = perf
	};
};

::Wuxia.Forge.rollNewSeed <- function( _usePity = false, _minGrade = 0 )
{
	local mst = ::Wuxia.Forge.getSmithMastery();
	local pity = ::Wuxia.Forge.getPity();
	local usedPity = false;
	local grade = 1;

	if (_usePity && pity >= 5)
	{
		usedPity = true;
		grade = (::Math.rand(1, 100) <= 38) ? 3 : 2;
		::Wuxia.Forge.setPity(0);
	}
	else
	{
		local ch = mst.Chances;
		local r = ::Math.rand(1, 100);
		if (r <= ch[0]) grade = 0;
		else if (r <= ch[0] + ch[1]) grade = 1;
		else if (r <= ch[0] + ch[1] + ch[2]) grade = 2;
		else grade = 3;

		if (grade < _minGrade) grade = _minGrade;

		if (_usePity)
		{
			if (grade >= 2) ::Wuxia.Forge.setPity(0);
			else ::Wuxia.Forge.setPity(pity + 1);
		}
	}

	local span = ::Wuxia.Forge.Grades[grade].Span;
	local sub = ::Math.rand(0, span - 1);
	local seed = ::Wuxia.Forge.encodeVariantSeed(grade, sub);
	local decoded = ::Wuxia.Forge.decodeVariantSeed(seed);
	decoded.UsedPity <- usedPity;
	return decoded;
};

// -----------------------------------------------------------------------------
// 3. Clean Base Stat Lookup & Range Calculation Across All 68+ Forgeable Items
// -----------------------------------------------------------------------------
::Wuxia.Forge.BaseNamedCleanCache <- {};

::Wuxia.Forge.getCleanRelicBase <- function( _relicID )
{
	if (_relicID in ::Wuxia.Forge.RelicCleanCache)
		return ::Wuxia.Forge.RelicCleanCache[_relicID];
	if (!("RelicWeapons" in ::Wuxia.Config) || !(_relicID in ::Wuxia.Config.RelicWeapons))
		return null;
	local rcfg = ::Wuxia.Config.RelicWeapons[_relicID];
	local bScript = ("BaseNamedScript" in rcfg && rcfg.BaseNamedScript != null) ? rcfg.BaseNamedScript : rcfg.Script;
	if (bScript in ::Wuxia.Forge.BaseNamedCleanCache)
	{
		local cached = clone ::Wuxia.Forge.BaseNamedCleanCache[bScript];
		::Wuxia.Forge.RelicCleanCache[_relicID] <- cached;
		return cached;
	}

	local p0 = ::new(bScript);
	local fb = {
		ConditionMax       = p0.m.ConditionMax,
		RegularDamage      = p0.m.RegularDamage,
		RegularDamageMax   = p0.m.RegularDamageMax,
		ArmorDamageMult    = p0.m.ArmorDamageMult,
		DirectDamageMult   = p0.m.DirectDamageMult,
		StaminaModifier    = p0.m.StaminaModifier,
		FatigueOnSkillUse  = p0.m.FatigueOnSkillUse,
		ChanceToHitHead    = p0.m.ChanceToHitHead,
		ShieldDamage       = p0.m.ShieldDamage,
		AdditionalAccuracy = p0.m.AdditionalAccuracy
	};
	for (local k = 0; k < 5; k = ++k)
	{
		local pk = ::new(bScript);
		if (pk.m.ConditionMax < fb.ConditionMax) fb.ConditionMax = pk.m.ConditionMax;
		if (pk.m.RegularDamage < fb.RegularDamage) fb.RegularDamage = pk.m.RegularDamage;
		if (pk.m.RegularDamageMax < fb.RegularDamageMax) fb.RegularDamageMax = pk.m.RegularDamageMax;
		if (pk.m.ArmorDamageMult < fb.ArmorDamageMult) fb.ArmorDamageMult = pk.m.ArmorDamageMult;
		if (pk.m.DirectDamageMult < fb.DirectDamageMult) fb.DirectDamageMult = pk.m.DirectDamageMult;
		if (pk.m.StaminaModifier < fb.StaminaModifier) fb.StaminaModifier = pk.m.StaminaModifier;
		if (pk.m.FatigueOnSkillUse > fb.FatigueOnSkillUse) fb.FatigueOnSkillUse = pk.m.FatigueOnSkillUse;
		if (pk.m.ChanceToHitHead < fb.ChanceToHitHead) fb.ChanceToHitHead = pk.m.ChanceToHitHead;
		if (pk.m.ShieldDamage < fb.ShieldDamage) fb.ShieldDamage = pk.m.ShieldDamage;
		if (pk.m.AdditionalAccuracy < fb.AdditionalAccuracy) fb.AdditionalAccuracy = pk.m.AdditionalAccuracy;
	}
	::Wuxia.Forge.BaseNamedCleanCache[bScript] <- clone fb;
	::Wuxia.Forge.RelicCleanCache[_relicID] <- fb;
	return fb;
};

::Wuxia.Forge.classifyForgeableItem <- function( _item )
{
	if (_item == null || !("m" in _item)) return null;
	if (("WX_BeastGearID" in _item.m) && _item.m.WX_BeastGearID != null && ("BeastGear" in ::Wuxia.Config) && (_item.m.WX_BeastGearID in ::Wuxia.Config.BeastGear))
	{
		local cfg = ::Wuxia.Config.BeastGear[_item.m.WX_BeastGearID];
		return { Domain = "beast", SubKind = cfg.Kind, Key = _item.m.WX_BeastGearID, Cfg = cfg, BaseName = cfg.Name };
	}
	if (("WX_UpgCfgID" in _item.m) && _item.m.WX_UpgCfgID != null && ("BeastGear" in ::Wuxia.Config) && (_item.m.WX_UpgCfgID in ::Wuxia.Config.BeastGear))
	{
		local ucfg = ::Wuxia.Config.BeastGear[_item.m.WX_UpgCfgID];
		return { Domain = "beast", SubKind = "upgrade", Key = _item.m.WX_UpgCfgID, Cfg = ucfg, BaseName = ucfg.Name };
	}
	if ((::Wuxia.hasMember(_item.m, "GearID")) && _item.m.GearID != "" && ("ShanHaiGear" in ::Wuxia.Config) && (_item.m.GearID in ::Wuxia.Config.ShanHaiGear))
	{
		local scfg = ::Wuxia.Config.ShanHaiGear[_item.m.GearID];
		return { Domain = "shanhai", SubKind = scfg.Kind, Key = _item.m.GearID, Cfg = scfg, BaseName = scfg.Name };
	}
	if (("WX_ShanHaiGearID" in _item.m) && _item.m.WX_ShanHaiGearID != null && ("ShanHaiGear" in ::Wuxia.Config) && (_item.m.WX_ShanHaiGearID in ::Wuxia.Config.ShanHaiGear))
	{
		local sg = ::Wuxia.Config.ShanHaiGear[_item.m.WX_ShanHaiGearID];
		return { Domain = "shanhai", SubKind = sg.Kind, Key = _item.m.WX_ShanHaiGearID, Cfg = sg, BaseName = sg.Name };
	}
	if (("WX_RelicID" in _item.m) && _item.m.WX_RelicID != null && ("RelicWeapons" in ::Wuxia.Config) && (_item.m.WX_RelicID in ::Wuxia.Config.RelicWeapons))
	{
		local rcfg = ::Wuxia.Config.RelicWeapons[_item.m.WX_RelicID];
		return { Domain = "relic", SubKind = "weapon", Key = _item.m.WX_RelicID, Cfg = rcfg, BaseName = "传世·" + rcfg.Name };
	}
	return null;
};

::Wuxia.Forge.computeArmorBounds <- function( _cfg, _isBeast )
{
	if (_isBeast)
	{
		local baseC = _cfg.Condition.tointeger();
		local minC  = ::Math.max(40, ::Math.round(baseC * 0.93).tointeger());
		local maxC  = ::Math.round(baseC * 1.15).tointeger();
		local baseS = _cfg.StaminaModifier;
		local minS  = baseS - 1;
		local maxS  = ::Math.min(-2, baseS + (baseC >= 200 ? 4 : 2));
		return { MinCond = minC, MaxCond = maxC, WorstStam = minS, BestStam = maxS };
	}

	local minC2 = _cfg.MinCondition;
	local maxC2 = (("MaxCondition" in _cfg) && _cfg.MaxCondition > _cfg.MinCondition)
		? (_cfg.MaxCondition + 8)
		: (minC2 + (minC2 >= 260 ? 48 : 24));
	local worstS = _cfg.MaxStamPen - 1;
	local bestS  = (("MinStamPen" in _cfg) && _cfg.MinStamPen < 0)
		? _cfg.MinStamPen
		: ::Math.min(-4, _cfg.MaxStamPen + (minC2 >= 260 ? 5 : 2));
	return { MinCond = minC2, MaxCond = maxC2, WorstStam = worstS, BestStam = bestS };
};

::Wuxia.Forge.computeAccessoryBonusBounds <- function( _statKey, _baseVal )
{
	if (_statKey == "MeleeDefense" || _statKey == "RangedDefense")
	{
		local lo = ::Math.max(2, _baseVal - 1);
		local hi = ::Math.min(5, _baseVal + 1); // Strictly capped <= +5 per AGENTS.md!
		return [lo, hi];
	}
	if (_statKey == "Hitpoints")
	{
		local loH = ::Math.max(6, _baseVal - 3);
		local hiH = ::Math.min(20, _baseVal + 4); // Strictly capped <= +20 per AGENTS.md!
		return [loH, hiH];
	}
	if (_statKey == "FatigueRecoveryRate")
		return [::Math.max(1, _baseVal - 1), _baseVal + 1];
	if (_statKey == "Vision")
		return [_baseVal, _baseVal];
	if (_statKey == "XPGainMult")
		return [1.12, 1.22];
	if (_statKey == "RangedReceivedMult")
		return [0.92, 0.85];
	// Stamina, Bravery, Initiative, AntiFearBravery
	return [::Math.max(4, ::Math.round(_baseVal * 0.82).tointeger()), ::Math.round(_baseVal * 1.32).tointeger()];
};

::Wuxia.Forge.buildAccessoryTooltipRows <- function( _bonuses )
{
	local rows = [];
	local pos = "#0a4213";
	if (("MeleeDefense" in _bonuses) || ("RangedDefense" in _bonuses))
	{
		local parts = [];
		if ("MeleeDefense" in _bonuses) parts.push("近防 [color=" + pos + "]+" + _bonuses.MeleeDefense + "[/color]");
		if ("RangedDefense" in _bonuses) parts.push("远防 [color=" + pos + "]+" + _bonuses.RangedDefense + "[/color]");
		rows.push({ Icon = "ui/icons/melee_defense.png", Text = "护身守御：" + (parts.len() == 2 ? (parts[0] + "、" + parts[1]) : parts[0]) });
	}
	if ("Hitpoints" in _bonuses)
		rows.push({ Icon = "ui/icons/health.png", Text = "生机培元：气血上限 [color=" + pos + "]+" + _bonuses.Hitpoints + "[/color]" });
	if (("Stamina" in _bonuses) || ("FatigueRecoveryRate" in _bonuses))
	{
		local sp = [];
		if ("Stamina" in _bonuses) sp.push("内息上限 [color=" + pos + "]+" + _bonuses.Stamina + "[/color]");
		if ("FatigueRecoveryRate" in _bonuses) sp.push("每回合回气 [color=" + pos + "]+" + _bonuses.FatigueRecoveryRate + "[/color]");
		rows.push({ Icon = "ui/icons/fatigue.png", Text = "周天行气：" + (sp.len() == 2 ? (sp[0] + "、" + sp[1]) : sp[0]) });
	}
	if (("Bravery" in _bonuses) || ("AntiFearBravery" in _bonuses))
	{
		local bp = [];
		if ("Bravery" in _bonuses) bp.push("定力 [color=" + pos + "]+" + _bonuses.Bravery + "[/color]");
		if ("AntiFearBravery" in _bonuses) bp.push("抗惊骇检定额外 [color=" + pos + "]+" + _bonuses.AntiFearBravery + "[/color]");
		rows.push({ Icon = "ui/icons/bravery.png", Text = "镇心辟邪：" + (bp.len() == 2 ? (bp[0] + "，" + bp[1]) : bp[0]) });
	}
	if ("Initiative" in _bonuses)
		rows.push({ Icon = "ui/icons/initiative.png", Text = "御风提纵：身法 [color=" + pos + "]+" + _bonuses.Initiative + "[/color]" });
	if ("Vision" in _bonuses)
		rows.push({ Icon = "ui/icons/vision.png", Text = "慧目远眺：视野 [color=" + pos + "]+" + _bonuses.Vision + "[/color]" });
	if ("XPGainMult" in _bonuses)
		rows.push({ Icon = "ui/icons/xp_received.png", Text = "通晓往事：实战历练经验获取 [color=" + pos + "]+" + ::Math.round((_bonuses.XPGainMult - 1.0) * 100) + "%[/color]" });
	if ("RangedReceivedMult" in _bonuses)
		rows.push({ Icon = "ui/icons/ranged_defense.png", Text = "衔石卸矢：承受远程伤害减免 [color=" + pos + "]" + ::Math.round((1.0 - _bonuses.RangedReceivedMult) * 100) + "%[/color]" });
	if (("NightOwl" in _bonuses) && _bonuses.NightOwl)
		rows.push({ Icon = "ui/icons/vision.png", Text = "夜战心明如昼（免除夜间视野与射艺惩罚）" });
	if (("ImmuneStun" in _bonuses) && _bonuses.ImmuneStun)
		rows.push({ Icon = "ui/icons/special.png", Text = "七窍俱泯：彻底免疫棒槌震晕（Stun）" });
	if (("ImmuneKnockback" in _bonuses) && _bonuses.ImmuneKnockback)
		rows.push({ Icon = "ui/icons/special.png", Text = "镇海生根：彻底免疫击退与钩拉位移" });
	if (("PoisonImmune" in _bonuses) && _bonuses.PoisonImmune)
		rows.push({ Icon = "ui/icons/special.png", Text = "百毒不侵（免疫蛛毒、五毒瘴气与暗器奇毒）" });
	return rows;
};

// Apply a decoded seed deterministically onto ANY Forgeable Item!
::Wuxia.Forge.applySeedToItem <- function( _item, _dec, _preserveConditionPct = false )
{
	local info = ::Wuxia.Forge.classifyForgeableItem(_item);
	if (info == null || _dec == null) return false;

	local condRatio = 1.0;
	if (_preserveConditionPct && _item.getConditionMax() > 0)
		condRatio = _item.getCondition().tofloat() / _item.getConditionMax().tofloat();

	_item.m.Variant           = _dec.Seed;
	_item.m.WX_ForgeSeed     <- _dec.Seed;
	_item.m.WX_ForgeGrade    <- _dec.Grade;
	_item.m.WX_ForgeGradeTitle <- _dec.GradeTitle;
	_item.m.WX_ForgeColor    <- _dec.GradeColor;
	_item.m.WX_PerfectionPct <- _dec.PerfectionPct;
	_item.m.Name              = ::Wuxia.Forge.formatGradedName(info.BaseName, _dec.Grade);

	local cfg = info.Cfg;

	if (info.Domain == "beast" && info.SubKind == "weapon")
	{
		local minDLo = ::Math.round(cfg.RegularDamage * 0.92).tointeger();
		local minDHi = ::Math.round(cfg.RegularDamage * 1.16).tointeger();
		local maxDLo = ::Math.round(cfg.RegularDamageMax * 0.92).tointeger();
		local maxDHi = ::Math.round(cfg.RegularDamageMax * 1.16).tointeger();
		_item.m.RegularDamage     = ::Wuxia.Forge.lerpInt(minDLo, minDHi, _dec.F1);
		_item.m.RegularDamageMax  = ::Math.max(_item.m.RegularDamage + 4, ::Wuxia.Forge.lerpInt(maxDLo, maxDHi, _dec.F1));
		_item.m.ArmorDamageMult   = ::Wuxia.Forge.lerpStep(::Math.maxf(0.50, cfg.ArmorDamageMult - 0.10), cfg.ArmorDamageMult + 0.20, _dec.F2, 0.01);
		_item.m.DirectDamageMult  = ::Wuxia.Forge.lerpStep(::Math.maxf(0.15, cfg.DirectDamageMult - 0.03), ::Math.minf(0.56, cfg.DirectDamageMult + 0.06), _dec.F3, 0.01);
		_item.m.StaminaModifier   = ::Math.min(-3, ::Wuxia.Forge.lerpInt(cfg.StaminaModifier - 1, cfg.StaminaModifier + 3, _dec.F3));
		_item.m.FatigueOnSkillUse = (_dec.Grade >= 3) ? -2 : ((_dec.Grade == 2 && _dec.F2 >= 0.80) ? -1 : 0);
		_item.m.Value             = ::Math.round(cfg.Value * _dec.ValueMult).tointeger();
	}
	else if (info.Domain == "relic" && info.SubKind == "weapon")
	{
		local clean = ::Wuxia.Forge.getCleanRelicBase(info.Key);
		if (clean != null)
		{
			local rMinLo = ::Math.round(clean.RegularDamage * 1.03).tointeger();
			local rMinHi = ::Math.round(clean.RegularDamage * 1.28).tointeger();
			local rMaxLo = ::Math.round(clean.RegularDamageMax * 1.03).tointeger();
			local rMaxHi = ::Math.round(clean.RegularDamageMax * 1.28).tointeger();
			_item.m.RegularDamage     = ::Wuxia.Forge.lerpInt(rMinLo, rMinHi, _dec.F1);
			_item.m.RegularDamageMax  = ::Math.max(_item.m.RegularDamage + 5, ::Wuxia.Forge.lerpInt(rMaxLo, rMaxHi, _dec.F1));
			_item.m.ArmorDamageMult   = ::Wuxia.Forge.lerpStep(clean.ArmorDamageMult + 0.04, clean.ArmorDamageMult + 0.28, _dec.F2, 0.01);
			_item.m.DirectDamageMult  = ::Wuxia.Forge.lerpStep(clean.DirectDamageMult, ::Math.minf(0.62, clean.DirectDamageMult + 0.14), _dec.F3, 0.01);
			_item.m.StaminaModifier   = ::Math.min(0, ::Wuxia.Forge.lerpInt(clean.StaminaModifier, clean.StaminaModifier + 4, _dec.F2));
			_item.m.FatigueOnSkillUse = clean.FatigueOnSkillUse + ((_dec.Grade >= 3) ? -2 : ((_dec.Grade == 2) ? -1 : 0));
			_item.m.ConditionMax      = ::Wuxia.Forge.lerpInt(clean.ConditionMax.tointeger(), ::Math.round(clean.ConditionMax * 1.22).tointeger(), _dec.F3).tofloat();
			_item.m.Condition         = _preserveConditionPct ? ::Math.maxf(1.0, ::Math.round(_item.m.ConditionMax * condRatio).tofloat()) : _item.m.ConditionMax;
		}
		_item.m.Value = ::Math.round(cfg.MinValue * _dec.ValueMult).tointeger();
	}
	else if (info.SubKind == "shield")
	{
		if (info.Domain == "beast")
		{
			_item.m.ConditionMax    = ::Wuxia.Forge.lerpInt(cfg.Condition - 4, cfg.Condition + 18, _dec.F3);
			_item.m.MeleeDefense    = ::Wuxia.Forge.lerpInt(cfg.MeleeDefense - 1, cfg.MeleeDefense + 5, _dec.F1);
			_item.m.RangedDefense   = ::Wuxia.Forge.lerpInt(cfg.RangedDefense - 1, cfg.RangedDefense + 5, _dec.F2);
			_item.m.StaminaModifier = ::Math.min(-4, ::Wuxia.Forge.lerpInt(cfg.StaminaModifier - 1, cfg.StaminaModifier + 3, _dec.F3));
		}
		else
		{
			local bMD = ("BaseMDef" in cfg) ? cfg.BaseMDef : 20;
			local bRD = ("BaseRDef" in cfg) ? cfg.BaseRDef : 24;
			_item.m.ConditionMax    = ::Wuxia.Forge.lerpInt(cfg.MinCondition, cfg.MinCondition + 24, _dec.F3);
			_item.m.MeleeDefense    = ::Wuxia.Forge.lerpInt(bMD, bMD + 6, _dec.F1);
			_item.m.RangedDefense   = ::Wuxia.Forge.lerpInt(bRD, bRD + 6, _dec.F2);
			_item.m.StaminaModifier = ::Math.min(-4, ::Wuxia.Forge.lerpInt(cfg.MaxStamPen, cfg.MaxStamPen + 3, _dec.F3));
		}
		if (!_preserveConditionPct) _item.m.Condition = _item.m.ConditionMax;
		else _item.m.Condition = ::Math.min(_item.m.ConditionMax, ::Math.max(1, ::Math.round(_item.m.ConditionMax * condRatio)));
		_item.m.Value = ::Math.round(cfg.Value * _dec.ValueMult).tointeger();
	}
	else if (info.SubKind == "armor" || info.SubKind == "helmet")
	{
		local bnd = ::Wuxia.Forge.computeArmorBounds(cfg, info.Domain == "beast");
		_item.m.ConditionMax    = ::Wuxia.Forge.lerpInt(bnd.MinCond, bnd.MaxCond, _dec.F1);
		_item.m.StaminaModifier = ::Wuxia.Forge.lerpInt(bnd.WorstStam, bnd.BestStam, _dec.F2);
		if (!_preserveConditionPct) _item.m.Condition = _item.m.ConditionMax;
		else _item.m.Condition = ::Math.min(_item.m.ConditionMax, ::Math.max(1, ::Math.round(_item.m.ConditionMax * condRatio)));
		_item.m.Value = ::Math.round(cfg.Value * _dec.ValueMult).tointeger();
	}
	else if (info.SubKind == "upgrade")
	{
		local minArm = ::Math.max(12, ::Math.round(cfg.ArmorBonus * 0.88).tointeger());
		local maxArm = ::Math.round(cfg.ArmorBonus * 1.28).tointeger();
		_item.m.ConditionModifier = ::Wuxia.Forge.lerpInt(minArm, maxArm, _dec.F1);
		local stamU = cfg.StaminaModifier;
		if (stamU < 0)
			stamU = ::Math.min(-1, ::Wuxia.Forge.lerpInt(cfg.StaminaModifier - 1, cfg.StaminaModifier + 1, _dec.F3));
		_item.m.StaminaModifier = stamU;

		local initB = cfg.InitiativeBonus > 0 ? ::Wuxia.Forge.lerpInt(::Math.max(4, cfg.InitiativeBonus - 2), cfg.InitiativeBonus + 4, _dec.F2) : 0;
		local bravB = cfg.BraveryBonus > 0 ? ::Wuxia.Forge.lerpInt(::Math.max(5, cfg.BraveryBonus - 2), cfg.BraveryBonus + 4, _dec.F2) : 0;
		local rngM  = cfg.RangedMult < 1.0 ? ::Wuxia.Forge.lerpStep(0.88, 0.80, _dec.F2, 0.01) : 1.0;
		local armM  = cfg.ArmorDmgMult < 1.0 ? ::Wuxia.Forge.lerpStep(0.88, 0.80, _dec.F2, 0.01) : 1.0;

		_item.m.RolledInitBonus    <- initB;
		_item.m.RolledBraveryBonus <- bravB;
		_item.m.RolledRangedMult   <- rngM;
		_item.m.RolledArmorDmgMult <- armM;

		local bParts = ["护甲耐久 [color=#0a4213]+" + _item.m.ConditionModifier + "[/color]" + (stamU < 0 ? ("（负重 " + stamU + "）") : "（零负重）")];
		if (initB > 0) bParts.push("提纵身法 [color=#0a4213]+" + initB + "[/color]");
		if (bravB > 0) bParts.push("定力 [color=#0a4213]+" + bravB + "[/color]");
		if (rngM < 1.0) bParts.push("承受远程伤害 [color=#0a4213]-" + ::Math.round((1.0 - rngM) * 100) + "%[/color]");
		if (armM < 1.0) bParts.push("承受破甲损耗 [color=#0a4213]-" + ::Math.round((1.0 - armM) * 100) + "%[/color]");
		if (cfg.PoisonImmune) bParts.push("百毒不侵");

		local joined = "";
		for (local bi = 0; bi < bParts.len(); bi = ++bi)
		{
			if (bi > 0) joined += "，";
			joined += bParts[bi];
		}
		_item.m.RolledBonusText <- joined;
		_item.m.Value = ::Math.round(cfg.Value * _dec.ValueMult).tointeger();
	}
	else if (info.SubKind == "accessory")
	{
		local rolled = {};
		if ("Bonuses" in cfg && cfg.Bonuses != null)
		{
			local slotIdx = 0;
			local fs = [_dec.F1, _dec.F2, _dec.F3];
			foreach (bk, bv in cfg.Bonuses)
			{
				if (typeof bv == "bool")
				{
					rolled[bk] <- bv;
				}
				else
				{
					local fUse = fs[slotIdx % 3];
					slotIdx += 1;
					local bounds = ::Wuxia.Forge.computeAccessoryBonusBounds(bk, bv);
					if (typeof bv == "float" && (bk == "XPGainMult" || bk == "RangedReceivedMult"))
						rolled[bk] <- ::Wuxia.Forge.lerpStep(bounds[0], bounds[1], fUse, 0.01);
					else
						rolled[bk] <- ::Wuxia.Forge.lerpInt(bounds[0], bounds[1], fUse);
				}
			}
		}
		_item.m.RolledBonuses     <- rolled;
		_item.m.RolledTooltipRows <- ::Wuxia.Forge.buildAccessoryTooltipRows(rolled);
		_item.m.Value              = ::Math.round(cfg.Value * _dec.ValueMult).tointeger();
	}

	// Sync Fist weapon active skill DirectDamageMult if currently equipped!
	if (info.SubKind == "weapon" && _item.m.SkillPtrs != null)
	{
		foreach (sk in _item.m.SkillPtrs)
		{
			if (sk != null && (sk.getID() == "actives.wx_fist_jab" || sk.getID() == "actives.wx_fist_shock"))
				sk.m.DirectDamageMult = _item.m.DirectDamageMult;
		}
	}

	return true;
};

// Restore non-Named item stats deterministically from `Variant` (`100..255`) on save load
::Wuxia.Forge.restoreFromVariant <- function( _item )
{
	if (_item == null) return;
	local dec = ::Wuxia.Forge.decodeVariantSeed(_item.getVariant());
	if (dec == null) return;
	::Wuxia.Forge.applySeedToItem(_item, dec, true);
};

// Sync Forging Grade metadata onto deserialized Named items (`wx_relic_*`, `wx_armor_*`, `wx_helm_*`, `wx_shd_*`)
::Wuxia.Forge.syncDeserializedNamed <- function( _item )
{
	if (_item == null) return;
	local dec = ::Wuxia.Forge.decodeVariantSeed(_item.getVariant());
	if (dec != null)
	{
		_item.m.WX_ForgeSeed       <- dec.Seed;
		_item.m.WX_ForgeGrade      <- dec.Grade;
		_item.m.WX_ForgeGradeTitle <- dec.GradeTitle;
		_item.m.WX_ForgeColor      <- dec.GradeColor;
		_item.m.WX_PerfectionPct   <- dec.PerfectionPct;
		local info = ::Wuxia.Forge.classifyForgeableItem(_item);
		if (info != null && _item.m.Name.find("【") != 0)
			_item.m.Name = ::Wuxia.Forge.formatGradedName(info.BaseName, dec.Grade);
	}
};

::Wuxia.Forge.syncDeserializedShield <- function( _item )
{
	::Wuxia.Forge.syncDeserializedNamed(_item);
};

// Roll newly crafted gear in 百工丹坊
::Wuxia.Forge.rollCraftedGear <- function( _item )
{
	local info = ::Wuxia.Forge.classifyForgeableItem(_item);
	if (info == null) return null;
	local dec = ::Wuxia.Forge.rollNewSeed(false, 0);
	::Wuxia.Forge.applySeedToItem(_item, dec, false);
	return dec;
};

// -----------------------------------------------------------------------------
// 4. Range Introspection & Blueprint / Instance Tooltip Injection
// -----------------------------------------------------------------------------
::Wuxia.Forge.describeGearRanges <- function( _item )
{
	local info = ::Wuxia.Forge.classifyForgeableItem(_item);
	if (info == null) return null;
	local cfg = info.Cfg;
	local rows = [];
	local summaryParts = [];

	if (info.Domain == "beast" && info.SubKind == "weapon")
	{
		local minDLo = ::Math.round(cfg.RegularDamage * 0.92).tointeger();
		local minDHi = ::Math.round(cfg.RegularDamage * 1.16).tointeger();
		local maxDLo = ::Math.round(cfg.RegularDamageMax * 0.92).tointeger();
		local maxDHi = ::Math.round(cfg.RegularDamageMax * 1.16).tointeger();
		local armLo  = ::Math.round(::Math.maxf(0.50, cfg.ArmorDamageMult - 0.10) * 100).tointeger();
		local armHi  = ::Math.round((cfg.ArmorDamageMult + 0.20) * 100).tointeger();
		local penLo  = ::Math.round(::Math.maxf(0.15, cfg.DirectDamageMult - 0.03) * 100).tointeger();
		local penHi  = ::Math.round(::Math.minf(0.56, cfg.DirectDamageMult + 0.06) * 100).tointeger();
		local stLo   = cfg.StaminaModifier - 1;
		local stHi   = ::Math.min(-3, cfg.StaminaModifier + 3);

		summaryParts.push("伤害 [" + minDLo + "-" + maxDLo + "]~[" + minDHi + "-" + maxDHi + "]");
		summaryParts.push("破甲 " + armLo + "%~" + armHi + "%");
		summaryParts.push("穿甲 " + penLo + "%~" + penHi + "%");
		summaryParts.push("负重 " + stLo + "~" + stHi);

		rows.push({ label = "兵刃伤害", cur = _item.m.RegularDamage + " - " + _item.m.RegularDamageMax, range = "[" + minDLo + "-" + maxDLo + "] ~ [" + minDHi + "-" + maxDHi + "]" });
		rows.push({ label = "破甲效能", cur = ::Math.round(_item.m.ArmorDamageMult * 100) + "%", range = armLo + "% ~ " + armHi + "%" });
		rows.push({ label = "透甲内劲", cur = ::Math.round(_item.m.DirectDamageMult * 100) + "%", range = penLo + "% ~ " + penHi + "%" });
		rows.push({ label = "佩持负重", cur = "" + _item.m.StaminaModifier, range = stLo + " ~ " + stHi });
		rows.push({ label = "出招省气", cur = "" + _item.m.FatigueOnSkillUse, range = "0 ~ -2（神工专属）" });
	}
	else if (info.Domain == "relic" && info.SubKind == "weapon")
	{
		local clean = ::Wuxia.Forge.getCleanRelicBase(info.Key);
		if (clean != null)
		{
			local rMinLo = ::Math.round(clean.RegularDamage * 1.03).tointeger();
			local rMinHi = ::Math.round(clean.RegularDamage * 1.28).tointeger();
			local rMaxLo = ::Math.round(clean.RegularDamageMax * 1.03).tointeger();
			local rMaxHi = ::Math.round(clean.RegularDamageMax * 1.28).tointeger();
			local rArmLo = ::Math.round((clean.ArmorDamageMult + 0.04) * 100).tointeger();
			local rArmHi = ::Math.round((clean.ArmorDamageMult + 0.28) * 100).tointeger();
			local rPenLo = ::Math.round(clean.DirectDamageMult * 100).tointeger();
			local rPenHi = ::Math.round(::Math.minf(0.62, clean.DirectDamageMult + 0.14) * 100).tointeger();
			local rStLo  = clean.StaminaModifier;
			local rStHi  = ::Math.min(0, clean.StaminaModifier + 4);

			summaryParts.push("伤害 [" + rMinLo + "-" + rMaxLo + "]~[" + rMinHi + "-" + rMaxHi + "]");
			summaryParts.push("破甲 " + rArmLo + "%~" + rArmHi + "%");
			summaryParts.push("穿甲 " + rPenLo + "%~" + rPenHi + "%");
			summaryParts.push("负重 " + rStLo + "~" + rStHi);

			rows.push({ label = "神兵伤害", cur = _item.m.RegularDamage + " - " + _item.m.RegularDamageMax, range = "[" + rMinLo + "-" + rMaxLo + "] ~ [" + rMinHi + "-" + rMaxHi + "]" });
			rows.push({ label = "破甲震击", cur = ::Math.round(_item.m.ArmorDamageMult * 100) + "%", range = rArmLo + "% ~ " + rArmHi + "%" });
			rows.push({ label = "穿甲锋芒", cur = ::Math.round(_item.m.DirectDamageMult * 100) + "%", range = rPenLo + "% ~ " + rPenHi + "%" });
			rows.push({ label = "内息负重", cur = "" + _item.m.StaminaModifier, range = rStLo + " ~ " + rStHi });
			rows.push({ label = "招式省气", cur = "" + _item.m.FatigueOnSkillUse, range = clean.FatigueOnSkillUse + " ~ " + (clean.FatigueOnSkillUse - 2) });
		}
	}
	else if (info.SubKind == "shield")
	{
		local cLo  = (info.Domain == "beast") ? (cfg.Condition - 4) : cfg.MinCondition;
		local cHi  = (info.Domain == "beast") ? (cfg.Condition + 18) : (cfg.MinCondition + 24);
		local mdLo = (info.Domain == "beast") ? (cfg.MeleeDefense - 1) : (("BaseMDef" in cfg) ? cfg.BaseMDef : 20);
		local mdHi = (info.Domain == "beast") ? (cfg.MeleeDefense + 5) : (mdLo + 6);
		local rdLo = (info.Domain == "beast") ? (cfg.RangedDefense - 1) : (("BaseRDef" in cfg) ? cfg.BaseRDef : 24);
		local rdHi = (info.Domain == "beast") ? (cfg.RangedDefense + 5) : (rdLo + 6);
		local stLo = (info.Domain == "beast") ? (cfg.StaminaModifier - 1) : cfg.MaxStamPen;
		local stHi = ::Math.min(-4, ((info.Domain == "beast") ? cfg.StaminaModifier : cfg.MaxStamPen) + 3);

		summaryParts.push("近防 +" + mdLo + "~+" + mdHi);
		summaryParts.push("远防 +" + rdLo + "~+" + rdHi);
		summaryParts.push("耐久 " + cLo + "~" + cHi);
		summaryParts.push("负重 " + stLo + "~" + stHi);

		rows.push({ label = "近身招架", cur = "+" + _item.m.MeleeDefense, range = "+" + mdLo + " ~ +" + mdHi });
		rows.push({ label = "听风避暗", cur = "+" + _item.m.RangedDefense, range = "+" + rdLo + " ~ +" + rdHi });
		rows.push({ label = "盾体耐久", cur = "" + _item.m.ConditionMax, range = cLo + " ~ " + cHi });
		rows.push({ label = "持盾负重", cur = "" + _item.m.StaminaModifier, range = stLo + " ~ " + stHi });
	}
	else if (info.SubKind == "armor" || info.SubKind == "helmet")
	{
		local bnd = ::Wuxia.Forge.computeArmorBounds(cfg, info.Domain == "beast");
		summaryParts.push("护甲耐久 " + bnd.MinCond + "~" + bnd.MaxCond);
		summaryParts.push("内息负重 " + bnd.WorstStam + "~" + bnd.BestStam);

		rows.push({ label = "护甲耐久", cur = "" + ::Math.round(_item.m.ConditionMax), range = bnd.MinCond + " ~ " + bnd.MaxCond });
		rows.push({ label = "披甲负重", cur = "" + _item.m.StaminaModifier, range = bnd.WorstStam + " ~ " + bnd.BestStam });
	}
	else if (info.SubKind == "upgrade")
	{
		local minArm = ::Math.max(12, ::Math.round(cfg.ArmorBonus * 0.88).tointeger());
		local maxArm = ::Math.round(cfg.ArmorBonus * 1.28).tointeger();
		summaryParts.push("附加护甲 +" + minArm + "~+" + maxArm);
		rows.push({ label = "镶缀护甲", cur = "+" + _item.m.ConditionModifier, range = "+" + minArm + " ~ +" + maxArm });
		if (cfg.InitiativeBonus > 0)
		{
			local curI = (::Wuxia.hasMember(_item.m, "RolledInitBonus") && _item.m.RolledInitBonus != null) ? _item.m.RolledInitBonus : cfg.InitiativeBonus;
			local loI = ::Math.max(4, cfg.InitiativeBonus - 2), hiI = cfg.InitiativeBonus + 4;
			summaryParts.push("身法 +" + loI + "~+" + hiI);
			rows.push({ label = "提纵身法", cur = "+" + curI, range = "+" + loI + " ~ +" + hiI });
		}
		if (cfg.BraveryBonus > 0)
		{
			local curB = (::Wuxia.hasMember(_item.m, "RolledBraveryBonus") && _item.m.RolledBraveryBonus != null) ? _item.m.RolledBraveryBonus : cfg.BraveryBonus;
			local loB = ::Math.max(5, cfg.BraveryBonus - 2), hiB = cfg.BraveryBonus + 4;
			summaryParts.push("定力 +" + loB + "~+" + hiB);
			rows.push({ label = "镇魂定力", cur = "+" + curB, range = "+" + loB + " ~ +" + hiB });
		}
		if (cfg.RangedMult < 1.0)
		{
			local curR = (::Wuxia.hasMember(_item.m, "RolledRangedMult") && _item.m.RolledRangedMult != null) ? _item.m.RolledRangedMult : cfg.RangedMult;
			summaryParts.push("远伤减免 12%~20%");
			rows.push({ label = "远伤减免", cur = "-" + ::Math.round((1.0 - curR) * 100) + "%", range = "-12% ~ -20%" });
		}
		if (cfg.ArmorDmgMult < 1.0)
		{
			local curA = (::Wuxia.hasMember(_item.m, "RolledArmorDmgMult") && _item.m.RolledArmorDmgMult != null) ? _item.m.RolledArmorDmgMult : cfg.ArmorDmgMult;
			summaryParts.push("损甲减免 12%~20%");
			rows.push({ label = "损甲减免", cur = "-" + ::Math.round((1.0 - curA) * 100) + "%", range = "-12% ~ -20%" });
		}
	}
	else if (info.SubKind == "accessory")
	{
		local labelMap = {
			Hitpoints = "气血上限", Stamina = "内息上限", FatigueRecoveryRate = "每轮回气",
			Bravery = "武道定力", Initiative = "轻功身法", MeleeDefense = "近身招架",
			RangedDefense = "听风避暗", AntiFearBravery = "抗惊骇检定", XPGainMult = "历练经验", RangedReceivedMult = "远伤减免"
		};
		local curB = (::Wuxia.hasMember(_item.m, "RolledBonuses") && _item.m.RolledBonuses != null)
			? _item.m.RolledBonuses
			: (("Bonuses" in cfg) ? cfg.Bonuses : {});
		if ("Bonuses" in cfg && cfg.Bonuses != null)
		{
			foreach (bk, bv in cfg.Bonuses)
			{
				if (typeof bv == "bool" || bk == "Vision") continue;
				local bndA = ::Wuxia.Forge.computeAccessoryBonusBounds(bk, bv);
				local lbl = (bk in labelMap) ? labelMap[bk] : bk;
				local curV = (curB != null && (bk in curB)) ? curB[bk] : bv;
				if (bk == "XPGainMult")
				{
					summaryParts.push(lbl + " +12%~+22%");
					rows.push({ label = lbl, cur = "+" + ::Math.round((curV - 1.0) * 100) + "%", range = "+12% ~ +22%" });
				}
				else if (bk == "RangedReceivedMult")
				{
					summaryParts.push(lbl + " 8%~15%");
					rows.push({ label = lbl, cur = "-" + ::Math.round((1.0 - curV) * 100) + "%", range = "-8% ~ -15%" });
				}
				else
				{
					summaryParts.push(lbl + " +" + bndA[0] + "~+" + bndA[1]);
					rows.push({ label = lbl, cur = "+" + curV, range = "+" + bndA[0] + " ~ +" + bndA[1] });
				}
			}
		}
	}

	local summaryStr = "";
	for (local s = 0; s < summaryParts.len(); s = ++s)
	{
		if (s > 0) summaryStr += "  |  ";
		summaryStr += summaryParts[s];
	}

	return {
		Info       = info,
		SummaryStr = summaryStr,
		Rows       = rows
	};
};

::Wuxia.Forge.injectForgeTooltip <- function( _item, _ret )
{
	if (_ret == null || typeof _ret != "array" || _item == null || !("m" in _item))
		return _ret;
	foreach (row in _ret)
	{
		if (row != null && typeof row == "table" && ("id" in row) && (row.id == 969 || row.id == 970))
			return _ret;
	}

	local isPreview = ("WX_IsBlueprintPreview" in _item.m) && _item.m.WX_IsBlueprintPreview;
	local rng = ::Wuxia.Forge.describeGearRanges(_item);
	if (rng == null) return _ret;

	if (isPreview)
	{
		local mst = ::Wuxia.Forge.getSmithMastery();
		local ch = mst.Chances;
		_ret.push({
			id = 969,
			type = "text",
			icon = "ui/icons/asset_supplies.png",
			text = "[color=#533200]【百工铸造品相】[/color]凡锻 " + ch[0] + "% · [color=#0a4213]良工 " + ch[1] + "%[/color] · [color=#4b1c76]百炼 " + ch[2] + "%[/color] · [color=#5e2c00]神工 " + ch[3] + "%[/color]（" + mst.SmithLabel + "）"
		});
		if (rng.SummaryStr != "")
		{
			_ret.push({
				id = 970,
				type = "text",
				icon = "ui/icons/special.png",
				text = "[color=#0a4213]【锻造属性范围】[/color]" + rng.SummaryStr + "（出炉后支持「神兵重锻」免内丹重淬！）"
			});
		}
		return _ret;
	}

	if (("WX_ForgeGrade" in _item.m) && _item.m.WX_ForgeGrade != null)
	{
		local gIdx = _item.m.WX_ForgeGrade;
		local col = (gIdx >= 0 && gIdx < ::Wuxia.Forge.Grades.len() && ("TooltipColor" in ::Wuxia.Forge.Grades[gIdx]))
			? ::Wuxia.Forge.Grades[gIdx].TooltipColor
			: "#0a4213";
		local gTitle = ("WX_ForgeGradeTitle" in _item.m) ? _item.m.WX_ForgeGradeTitle : "良工";
		local perf = ("WX_PerfectionPct" in _item.m) ? _item.m.WX_PerfectionPct : 50;
		local tail = (_item.m.WX_ForgeGrade >= 3)
			? "（炉火至臻 · 已达最高品相！）"
			: "（可在「百草丹炉 → 神兵重锻」耗百工奇材免内丹重洗词条）";
		_ret.push({
			id = 969,
			type = "text",
			icon = "ui/icons/asset_supplies.png",
			text = "[color=" + col + "]【锻造品相 · " + gTitle + "（完美度 " + perf + "%）】[/color]" + tail
		});
		if (rng.SummaryStr != "" && _item.m.WX_ForgeGrade < 3)
		{
			_ret.push({
				id = 970,
				type = "text",
				icon = "ui/icons/special.png",
				text = "[color=#43392c]【满值参考区间】" + rng.SummaryStr + "[/color]"
			});
		}
	}
	return _ret;
};

// -----------------------------------------------------------------------------
// 5. Masterwork Reforge Workbench Engine (`神兵重锻` — 0 Boss Cores Required!)
// -----------------------------------------------------------------------------
::Wuxia.Forge.findReforgeCatalyst <- function( _stash = null )
{
	// Priority 1: `wx_mat_*` in Zero-Slot Cabinet
	if ("Alchemy" in ::Wuxia && "Cabinet" in ::Wuxia.Alchemy && "BeastMaterials" in ::Wuxia.Config)
	{
		local mkeys = ["wx_mat_renjin", "wx_mat_chiling", "wx_mat_xiongjiao", "wx_mat_gujing", "wx_mat_xuanlin", "wx_mat_shagu"];
		for (local i = 0; i < mkeys.len(); i = ++i)
		{
			local ck = "trophy:" + mkeys[i];
			local cnt = ::Wuxia.Alchemy.Cabinet.getCount(ck);
			if (cnt > 0)
			{
				local mcfg = ::Wuxia.Config.BeastMaterials[mkeys[i]];
				return { Found = true, Source = "cabinet", Key = ck, Name = mcfg.Name, Available = cnt };
			}
		}
	}
	// Priority 2: `misc.wx_mat_*` in Stash
	local stashRef = _stash;
	if (stashRef == null && ::Wuxia.hasWorldField("Assets"))
		stashRef = ::World.Assets.getStash();
	if (stashRef != null)
	{
		local items = stashRef.getItems();
		for (local j = 0; j < items.len(); j = ++j)
		{
			local it = items[j];
			if (it != null && it.getID().find("misc.wx_mat_") == 0)
				return { Found = true, Source = "stash", StashIdx = j, Name = it.getName(), Available = 1 };
		}
	}
	return { Found = false, Source = "", Name = "任意异兽百工奇材（赤炎翎/真龙逆鳞/太古凶角/战神煞骨/天妖蛟筋/蚀骨毒晶）", Available = 0 };
};

::Wuxia.Forge.countTotalBeastMats <- function( _stash = null )
{
	local total = 0;
	if ("Alchemy" in ::Wuxia && "Cabinet" in ::Wuxia.Alchemy && "BeastMaterials" in ::Wuxia.Config)
	{
		foreach (mk, _mv in ::Wuxia.Config.BeastMaterials)
			total += ::Wuxia.Alchemy.Cabinet.getCount("trophy:" + mk);
	}
	local stashRef = _stash;
	if (stashRef == null && ::Wuxia.hasWorldField("Assets"))
		stashRef = ::World.Assets.getStash();
	if (stashRef != null)
	{
		foreach (it in stashRef.getItems())
		{
			if (it != null && it.getID().find("misc.wx_mat_") == 0)
				total += 1;
		}
	}
	return total;
};

::Wuxia.Forge.consumeOneCatalyst <- function( _stash )
{
	local cat = ::Wuxia.Forge.findReforgeCatalyst(_stash);
	if (!cat.Found) return null;
	if (cat.Source == "cabinet")
	{
		::Wuxia.Alchemy.Cabinet.addCount(cat.Key, -1);
		return cat.Name;
	}
	if (cat.Source == "stash" && _stash != null)
	{
		_stash.removeByIndex(cat.StashIdx);
		return cat.Name;
	}
	return null;
};

::Wuxia.Forge.buildReforgeEntry <- function( _item, _uid, _ownerLabel, _isEquipped )
{
	local rng = ::Wuxia.Forge.describeGearRanges(_item);
	if (rng == null) return null;
	local mst = ::Wuxia.Forge.getSmithMastery();
	local baseSilver = (rng.Info.Domain == "beast") ? 350 : 850;
	local silverCost = ::Math.max(100, ::Math.floor(baseSilver * mst.CostMult));

	local grade = ("WX_ForgeGrade" in _item.m && _item.m.WX_ForgeGrade != null) ? _item.m.WX_ForgeGrade : 1;
	local gSpec = ::Wuxia.Forge.Grades[::Math.max(0, ::Math.min(3, grade))];
	local perf  = ("WX_PerfectionPct" in _item.m && _item.m.WX_PerfectionPct != null) ? _item.m.WX_PerfectionPct : 52;

	return {
		uid           = _uid,
		name          = _item.getName(),
		baseName      = rng.Info.BaseName,
		domain        = rng.Info.Domain,
		subKind       = rng.Info.SubKind,
		icon          = "ui/items/" + _item.getIcon(),
		ownerLabel    = _ownerLabel,
		isEquipped    = _isEquipped,
		grade         = grade,
		gradeTitle    = gSpec.Title,
		gradeColor    = gSpec.Color,
		perfectionPct = perf,
		silverCost    = silverCost,
		summaryStr    = rng.SummaryStr,
		statRows      = rng.Rows,
		description   = _item.getDescription()
	};
};

::Wuxia.Forge.collectReforgeableList <- function( _stash = null )
{
	local out = [];
	if (("World" in getroottable()) && ::World != null && ("getPlayerRoster" in ::World) && ::World.getPlayerRoster() != null)
	{
		local slotsCheck = [
			[::Const.ItemSlot.Mainhand,  "主手"],
			[::Const.ItemSlot.Offhand,   "副手"],
			[::Const.ItemSlot.Body,      "身甲"],
			[::Const.ItemSlot.Head,      "冠胄"],
			[::Const.ItemSlot.Accessory, "佩饰"]
		];
		foreach (bro in ::World.getPlayerRoster().getAll())
		{
			if (bro == null || !bro.isAlive() || bro.getItems() == null) continue;
			local items = bro.getItems();
			for (local s = 0; s < slotsCheck.len(); s = ++s)
			{
				local sl = slotsCheck[s][0];
				local slName = slotsCheck[s][1];
				local eq = items.getItemAtSlot(sl);
				if (eq == null) continue;
				local uid = "eq:" + bro.getID() + ":" + sl;
				local entry = ::Wuxia.Forge.buildReforgeEntry(eq, uid, bro.getName() + " · " + slName, true);
				if (entry != null) out.push(entry);
			}
		}
	}

	local stashRef = _stash;
	if (stashRef == null && ::Wuxia.hasWorldField("Assets"))
		stashRef = ::World.Assets.getStash();
	if (stashRef != null)
	{
		local sItems = stashRef.getItems();
		for (local i = 0; i < sItems.len(); i = ++i)
		{
			local it = sItems[i];
			if (it == null) continue;
			local entry2 = ::Wuxia.Forge.buildReforgeEntry(it, "st:" + i, "战团行囊", false);
			if (entry2 != null) out.push(entry2);
		}
	}
	return out;
};

::Wuxia.Forge.resolveTargetByUid <- function( _uid, _stash )
{
	if (_uid == null || typeof _uid != "string" || _uid == "") return null;
	if (_uid.find("st:") == 0 && _stash != null)
	{
		local idx = _uid.slice(3).tointeger();
		local sItems = _stash.getItems();
		if (idx >= 0 && idx < sItems.len() && sItems[idx] != null)
			return { Item = sItems[idx], Bro = null };
		return null;
	}
	if (_uid.find("eq:") == 0 && ("World" in getroottable()) && ::World != null && ::World.getPlayerRoster() != null)
	{
		local parts = split(_uid, ":");
		if (parts.len() >= 3)
		{
			local broID = parts[1].tointeger();
			local slotID = parts[2].tointeger();
			foreach (bro in ::World.getPlayerRoster().getAll())
			{
				if (bro != null && bro.isAlive() && bro.getID() == broID && bro.getItems() != null)
				{
					local eq = bro.getItems().getItemAtSlot(slotID);
					if (eq != null) return { Item = eq, Bro = bro };
				}
			}
		}
	}
	return null;
};

::Wuxia.Forge.executeReforge <- function( _uid )
{
	if (!::Wuxia.hasWorldField("Assets"))
		return { Ok = false, Reason = "当前无法启用百工重锻炉。" };

	local stash = ::World.Assets.getStash();
	local resolved = ::Wuxia.Forge.resolveTargetByUid(_uid, stash);
	if (resolved == null || resolved.Item == null)
		return { Ok = false, Reason = "未找到目标兵甲器物（可能已被移动或售出）。" };

	local item = resolved.Item;
	local info = ::Wuxia.Forge.classifyForgeableItem(item);
	if (info == null)
		return { Ok = false, Reason = "该件装备不支持百工炉火重锻。" };

	local mst = ::Wuxia.Forge.getSmithMastery();
	local baseSilver = (info.Domain == "beast") ? 350 : 850;
	local silverCost = ::Math.max(100, ::Math.floor(baseSilver * mst.CostMult));
	local money = ::World.Assets.getMoney();
	if (money < silverCost)
		return { Ok = false, Reason = "纹银不足（本次重锻需 " + silverCost + " 两，现存 " + money + " 两）。" };

	local catCheck = ::Wuxia.Forge.findReforgeCatalyst(stash);
	if (!catCheck.Found)
		return { Ok = false, Reason = "缺少百工奇材辅料（讨伐野外山泽异兽或秘境大妖可获赤炎翎、真龙逆鳞、太古凶角、战神煞骨、天妖蛟筋或蚀骨毒晶）。" };

	local oldPerf = ("WX_PerfectionPct" in item.m && item.m.WX_PerfectionPct != null) ? item.m.WX_PerfectionPct : 50;
	local oldTitle = ("WX_ForgeGradeTitle" in item.m && item.m.WX_ForgeGradeTitle != null) ? item.m.WX_ForgeGradeTitle : "良工";

	::World.Assets.addMoney(-silverCost);
	local spentMatName = ::Wuxia.Forge.consumeOneCatalyst(stash);

	local dec = ::Wuxia.Forge.rollNewSeed(true, 0);
	::Wuxia.Forge.applySeedToItem(item, dec, false); // Repairs to full durability on reforge!

	if (resolved.Bro != null)
	{
		if (resolved.Bro.getSkills() != null)
			resolved.Bro.getSkills().update();
		if ("Armory" in ::Wuxia && "syncActorHandheldAndArmor" in ::Wuxia.Armory)
			::Wuxia.Armory.syncActorHandheldAndArmor(resolved.Bro);
	}

	local pityNote = dec.UsedPity ? "【五锤炉温保底激发！】" : "";
	local mwNote   = (dec.Grade >= 3) ? " 炉吐金霞、神工天成！" : "";
	local msg = pityNote + "耗「" + spentMatName + "」×1 与纹银 " + silverCost + " 两重铸「" + item.getName() + "」：" +
		oldTitle + "(" + oldPerf + "%) → 【" + dec.GradeTitle + " · 完美度 " + dec.PerfectionPct + "%】！" + mwNote;

	return {
		Ok            = true,
		Grade         = dec.Grade,
		GradeTitle    = dec.GradeTitle,
		PerfectionPct = dec.PerfectionPct,
		Message       = msg
	};
};

// -----------------------------------------------------------------------------
// 6. Blueprint previews, product quality and town crafting
// -----------------------------------------------------------------------------
::Wuxia.Forge.rollTownProducts <- function( _products )
{
	local craftedMsgs = [];
	foreach (afterIt in _products)
	{
		if (afterIt.getID() == "misc.wx_pill_item")
		{
			if ("Alchemy" in ::Wuxia && "rollTownCraftedPill" in ::Wuxia.Alchemy)
			{
				local pRoll = ::Wuxia.Alchemy.rollTownCraftedPill(afterIt);
				if (pRoll != null)
					craftedMsgs.push("「" + afterIt.getName() + "」（药效 " + pRoll.PotencyPct + "%）");
			}
		}
		else
		{
			local gRoll = ::Wuxia.Forge.rollCraftedGear(afterIt);
			if (gRoll != null)
				craftedMsgs.push("「" + afterIt.getName() + "」（完美度 " + gRoll.PerfectionPct + "%）");
		}
	}

	if (craftedMsgs.len() > 0)
	{
		local joined = "";
		for (local m = 0; m < craftedMsgs.len(); m = ++m)
		{
			if (m > 0) joined += "、";
			joined += craftedMsgs[m];
		}
		::Wuxia.Forge.LastCraftBanner = "开炉功成！出炉：" + joined + "！";
	}
};

if ("HooksMod" in ::Wuxia && ::Wuxia.HooksMod != null)
{
	::Wuxia.HooksMod.hook("scripts/crafting/blueprint", function( q )
	{
		q.init = @(__original) function( _comps )
		{
			__original(_comps);
			if (this.getID().find("blueprint.wx_") == 0 && this.m.PreviewCraftable != null)
				this.m.PreviewCraftable.m.WX_IsBlueprintPreview <- true;
		};
	});

	::Wuxia.HooksMod.hook("scripts/ui/screens/world/modules/world_town_screen/town_taxidermist_dialog_module", function( q )
	{
		q.onCraft = @(__original) function( _blueprintID )
		{
			local bp = typeof _blueprintID == "string" ? ::World.Crafting.getBlueprint(_blueprintID) : null;
			local reason = null, plan = null;
			if (bp == null) reason = "找不到所选配方。";
			else if (::World.Assets.getMoney() < bp.getCost()) reason = "纹银不足。";
			else if (!bp.isCraftable()) reason = "制作材料不足，请重新选择丹方。";
			else if (bp.getID().find("blueprint.wx_") == 0)
			{
				plan = ::Wuxia.BeastCraft.prepareCraft(bp, ::World.Assets.getStash());
				reason = plan.Reason;
			}
			if (reason != null)
			{
				local data = this.queryBlueprints();
				data.wxCraftBanner <- reason;
				return data;
			}

			if (plan == null) return __original(_blueprintID);
			bp.m.WX_CraftPlan <- plan;
			local data;
			try { data = __original(_blueprintID); }
			catch (err) { delete bp.m.WX_CraftPlan; throw err; }
			delete bp.m.WX_CraftPlan;
			local banner = ::Wuxia.Forge.consumeLastCraftBanner();
			if (banner != "" && data != null) data.wxCraftBanner <- banner;
			return data;
		};
	});
}
