// Marrow Wash (洗经伐髓): Talent Star upgrade (1->2: 30%, 2->3: 15%) & Star Replace (0->1: 45%)
// Strictly enforces vanilla max 3 attributes with stars.

::Wuxia.MarrowWash.countStarredAttributes <- function( _actor )
{
	if (_actor == null || !("m" in _actor) || !("Talents" in _actor.m))
		return 0;
	local cnt = 0;
	foreach (st in _actor.m.Talents)
	{
		if (st > 0) cnt = ++cnt;
	}
	return cnt;
};

::Wuxia.MarrowWash.getPrepBonus <- function( _actor, _useProtectPill )
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

	// Protect Pill contribution: +5%
	if (_useProtectPill)
	{
		bonus += ::Wuxia.Config.MarrowWash.ProtectPillChanceBonus;
	}

	return ::Math.min(::Wuxia.Config.MarrowWash.MaxPrepBonus, bonus);
};

::Wuxia.MarrowWash.getPreview <- function( _actor, _targetAttrIdx, _replaceAttrIdx = -1, _useProtectPill = false )
{
	if (_actor == null || !("Talents" in _actor.m))
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

	local baseChance = ::Wuxia.Config.MarrowWash.BaseChance[curStar];
	local prepBonus = ::Wuxia.MarrowWash.getPrepBonus(_actor, _useProtectPill);
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
		PermInjuryRisk = permRisk
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
		}
		_actor.m.Talents[_targetAttrIdx] = preview.NextStar;

		// Refresh future attribute level up values if method exists on player
		if ("fillAttributeLevelUpValues" in _actor)
		{
			_actor.fillAttributeLevelUpValues(::Const.XP.MaxLevelWithPerkpoints - _actor.getLevel());
		}

		return {
			Ok = true,
			Succeeded = true,
			Roll = roll,
			Chance = preview.FinalChance,
			Message = "洗经伐髓成功！「" + preview.TargetAttrName + "」根骨跃升至 " + preview.NextStar + "★！"
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
	inj.applySeverity(2, ::Wuxia.Config.MarrowWash.ShockDurationDays);

	local gotPerm = false;
	if (preview.PermInjuryRisk > 0 && ::Math.rand(1, 100) <= preview.PermInjuryRisk)
	{
		gotPerm = true;
		// Apply a permanent internal defect using vanilla permanent injury or dedicated hidden penalty
		inj.addPermanentMeridianScar();
	}

	_actor.getSkills().update();

	return {
		Ok = true,
		Succeeded = false,
		Roll = roll,
		Chance = preview.FinalChance,
		GotPermanentInjury = gotPerm,
		Message = gotPerm
			? "洗经伐髓失败！真气逆冲引发「经脉震荡」，并留下永久经脉暗疾！"
			: "洗经伐髓失败！真气逆冲引发「经脉震荡」，需以护心丹或名医调养数日。"
	};
};
