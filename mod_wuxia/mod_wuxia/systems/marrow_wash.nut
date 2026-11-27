// Marrow Wash (洗经伐髓): Talent Star upgrade (1->2: 30%, 2->3: 15%) & Star Replace (0->1: 45%)
// Strictly enforces vanilla max 3 attributes with stars; supports 护脉丹 (+5%) & 山海造化护脉金丹 (+9%, zero shock).

::Wuxia.MarrowWash.countStarredAttributes <- function( _actor )
{
	if (_actor == null || !::Wuxia.Appearance.hasMember(_actor, "m") || !::Wuxia.Appearance.hasMember(_actor.m, "Talents"))
		return 0;
	local cnt = 0;
	foreach (st in _actor.m.Talents)
	{
		if (st > 0) cnt = ++cnt;
	}
	return cnt;
};

::Wuxia.MarrowWash.refreshFutureRolls <- function( _actor, _attr )
{
	local values = _actor.m.Attributes[_attr];
	local pending = _actor.m.LevelUps;
	local end = ::Math.min(values.len(), pending + ::Math.max(0, ::Const.XP.MaxLevelWithPerkpoints - _actor.getLevel()));
	local stars = _actor.m.Talents[_attr];
	local range = ::Const.AttributesLevelUp[_attr];
	for (local i = pending; i < end; ++i)
		values[i] = ::Math.rand(range.Min + (stars == 3 ? 2 : stars), range.Max + (stars == 3 ? 1 : 0));
};

::Wuxia.MarrowWash.resolveBestProtectPillDef <- function()
{
	if ("World" in getroottable() && ::World != null && ::World.Assets != null && ::World.Assets.getStash() != null)
	{
		local items = ::World.Assets.getStash().getItems();
		local hasZaohua = false;
		foreach (it in items)
		{
			if (it != null && it.getID() == "misc.wx_pill_item" && it.getPillID() == "wx_pill_zaohua")
			{
				hasZaohua = true;
				break;
			}
		}
		if (hasZaohua && ("wx_pill_zaohua" in ::Wuxia.Config.Pills))
			return ::Wuxia.Config.Pills.wx_pill_zaohua;
	}
	return ("wx_pill_humai" in ::Wuxia.Config.Pills) ? ::Wuxia.Config.Pills.wx_pill_humai : null;
};

::Wuxia.MarrowWash.getPrepBonus <- function( _actor, _useProtectPill, _protectDef = null )
{
	local bonus = 0;
	local b = _actor.getBaseProperties();

	// Resolve contribution: up to +6%
	if (b != null && b.Bravery >= 50)
	{
		bonus += ::Math.min(6, ::Math.floor((b.Bravery - 40) / 10));
	}

	// Health condition: full HP gives +4%
	if (_actor.getHitpointsPct() >= 0.99)
	{
		bonus += 4;
	}

	// Main Neigong Tier contribution: +2% per tier (up to +6%)
	local c = ::Wuxia.Slots.getContainer(_actor);
	if (c != null && c.m.Slots[0].ManualID != null && c.m.Slots[0].Tier > 0)
	{
		bonus += c.m.Slots[0].Tier * 2;
	}

	// Protect Pill contribution: +5% (护脉丹) or +9% (山海造化护脉金丹)
	if (_useProtectPill)
	{
		local pDef = _protectDef != null ? _protectDef : ::Wuxia.MarrowWash.resolveBestProtectPillDef();
		local pBonus = (pDef != null && ("ProtectBonus" in pDef)) ? pDef.ProtectBonus : ::Wuxia.Config.MarrowWash.ProtectPillChanceBonus;
		bonus += pBonus;
	}

	local cappedPrep = ::Math.min(::Wuxia.Config.MarrowWash.MaxPrepBonus, bonus);
	if ("Traits" in ::Wuxia)
		cappedPrep += ::Wuxia.Traits.getWashPrepBonus(_actor);
	return cappedPrep;
};

::Wuxia.MarrowWash.getPreview <- function( _actor, _targetAttrIdx, _replaceAttrIdx = -1, _useProtectPill = false )
{
	if (_actor == null || !::Wuxia.Appearance.hasMember(_actor, "m") || !::Wuxia.Appearance.hasMember(_actor.m, "Talents"))
		return { Ok = false, Reason = "无法读取角色根骨信息。" };

	if (_targetAttrIdx < 0 || _targetAttrIdx >= 8)
		return { Ok = false, Reason = "请选择要洗髓的目标属性。" };

	local talents = _actor.m.Talents;
	local curStar = talents[_targetAttrIdx];
	if (curStar >= ::Wuxia.Config.Constants.MaxStarsPerAttribute)
		return { Ok = false, Reason = "该属性根骨已达 3★ 极境。" };

	local starredCount = ::Wuxia.MarrowWash.countStarredAttributes(_actor);
	local isReplaceMode = false;

	if (curStar == 0 && starredCount >= ::Wuxia.Config.Constants.MaxStarAttributes)
	{
		isReplaceMode = true;
		if (_replaceAttrIdx < 0 || _replaceAttrIdx >= 8 || _replaceAttrIdx == _targetAttrIdx || talents[_replaceAttrIdx] <= 0)
		{
			return {
				Ok = false,
				NeedsReplace = true,
				Reason = "角色已有 3 项带星根骨，须指定 1 项原有带星属性进行「易筋换星」。"
			};
		}
	}

	local pDef = _useProtectPill ? ::Wuxia.MarrowWash.resolveBestProtectPillDef() : null;
	local baseChance = ::Wuxia.Config.MarrowWash.BaseChance[curStar];
	local prepBonus = ::Wuxia.MarrowWash.getPrepBonus(_actor, _useProtectPill, pDef);
	local finalChance = ::Math.min(85, baseChance + prepBonus);
	local permRisk = (curStar >= 1 && !_useProtectPill) ? ::Wuxia.Config.MarrowWash.HighStarPermInjuryPct : 0;

	return {
		Ok = true,
		TargetAttrIdx = _targetAttrIdx,
		TargetAttrName = ::Wuxia.Text.Attributes[_targetAttrIdx],
		CurrentStar = curStar,
		NextStar = curStar + 1,
		IsReplaceMode = isReplaceMode,
		ReplaceAttrIdx = isReplaceMode ? _replaceAttrIdx : -1,
		ReplaceAttrName = isReplaceMode ? ::Wuxia.Text.Attributes[_replaceAttrIdx] : "",
		BaseChance = baseChance,
		PrepBonus = prepBonus,
		FinalChance = finalChance,
		PermInjuryRisk = permRisk,
		AvoidShock = (pDef != null && ("AvoidShock" in pDef) && pDef.AvoidShock)
	};
};

::Wuxia.MarrowWash.execute <- function( _actor, _targetAttrIdx, _replaceAttrIdx = -1, _useProtectPill = false, _usePendingChance = false )
{
	local preview = ::Wuxia.MarrowWash.getPreview(_actor, _targetAttrIdx, _replaceAttrIdx, _useProtectPill);
	if (!preview.Ok) return preview;

	local c = ::Wuxia.Slots.getContainer(_actor);
	if (_usePendingChance)
	{
		if (c == null || c.m.PendingWashChances <= 0)
			return { Ok = false, Reason = "当前无可用功成洗髓契机。" };
		c.m.PendingWashChances -= 1;
	}

	if (c != null)
		c.m.MarrowWashCount += 1;

	local roll = ::Math.rand(1, 100);
	local succeeded = (roll <= preview.FinalChance);

	if (succeeded)
	{
		if (preview.IsReplaceMode && preview.ReplaceAttrIdx >= 0)
		{
			_actor.m.Talents[preview.ReplaceAttrIdx] = 0;
			::Wuxia.MarrowWash.refreshFutureRolls(_actor, preview.ReplaceAttrIdx);
		}
		_actor.m.Talents[_targetAttrIdx] = preview.NextStar;
		::Wuxia.MarrowWash.refreshFutureRolls(_actor, _targetAttrIdx);
		if (::Wuxia.hasWorldField("Flags"))
			::World.Flags.set("wx_marrow_wash_success", true);

		return {
			Ok                 = true,
			Succeeded          = true,
			Roll               = roll,
			Chance             = preview.FinalChance,
			WashPillID         = _usePendingChance ? "pending" : "wx_pill_xisui",
			WashPillName       = _usePendingChance ? "功成契机" : "洗髓丹",
			TargetAttrIdx      = _targetAttrIdx,
			TargetAttrName     = preview.TargetAttrName,
			OldStars           = preview.CurrentStar,
			NextStar           = preview.NextStar,
			IsReplaceMode      = preview.IsReplaceMode,
			ReplaceAttrName    = ("ReplaceAttrName" in preview) ? preview.ReplaceAttrName : "",
			AvoidAllShock      = false,
			AvoidHeavyShock    = false,
			GotPermanentInjury = false,
			Message            = "洗经伐髓成功！「" + preview.TargetAttrName + "」根骨跃升至 " + preview.NextStar + "★！"
		};
	}

	if (("AvoidShock" in preview) && preview.AvoidShock)
	{
		return {
			Ok                 = true,
			Succeeded          = false,
			Roll               = roll,
			Chance             = preview.FinalChance,
			WashPillID         = _usePendingChance ? "pending" : "wx_pill_xisui",
			WashPillName       = _usePendingChance ? "功成契机" : "洗髓丹",
			TargetAttrIdx      = _targetAttrIdx,
			TargetAttrName     = preview.TargetAttrName,
			OldStars           = preview.CurrentStar,
			NextStar           = preview.NextStar,
			IsReplaceMode      = preview.IsReplaceMode,
			ReplaceAttrName    = ("ReplaceAttrName" in preview) ? preview.ReplaceAttrName : "",
			AvoidAllShock      = true,
			AvoidHeavyShock    = true,
			GotPermanentInjury = false,
			Message            = "洗髓药力未能冲开「" + preview.TargetAttrName + "」关窍，幸得【山海造化护脉金丹】护持心脉，全身经脉毫发无伤！"
		};
	}

	// Failure: Apply heavy internal shock + chance of permanent injury on high-star attempt without protection
	local skills = _actor.getSkills();
	local inj = skills.getSkillByID("effects.wx_internal_injury");
	if (inj == null)
	{
		inj = ::new("scripts/skills/effects/wx_internal_injury");
		skills.add(inj);
	}
	inj.applyHeavyShock();

	local gotPerm = false;
	if (preview.PermInjuryRisk > 0 && ::Math.rand(1, 100) <= preview.PermInjuryRisk)
	{
		inj.applyPermanentDamage();
		gotPerm = true;
	}
	skills.update();

	local failMsg = "洗髓药力冲关受阻，陷入「经脉震荡」" + (gotPerm ? "，更留下永久「经脉暗疾」！" : "（静养或服护心丹可愈）。");
	return {
		Ok                 = true,
		Succeeded          = false,
		Roll               = roll,
		Chance             = preview.FinalChance,
		WashPillID         = _usePendingChance ? "pending" : "wx_pill_xisui",
		WashPillName       = _usePendingChance ? "功成契机" : "洗髓丹",
		TargetAttrIdx      = _targetAttrIdx,
		TargetAttrName     = preview.TargetAttrName,
		OldStars           = preview.CurrentStar,
		NextStar           = preview.NextStar,
		IsReplaceMode      = preview.IsReplaceMode,
		ReplaceAttrName    = ("ReplaceAttrName" in preview) ? preview.ReplaceAttrName : "",
		AvoidAllShock      = false,
		AvoidHeavyShock    = false,
		GotPermanentInjury = gotPerm,
		Message            = failMsg
	};
};
