// UI Data serialization helpers + data_helper hook for Character Screen & Tactical HUD

::Wuxia.UI <- {};

::Wuxia.UI.buildBrotherMartialData <- function( _actor )
{
	if (_actor == null) return null;
	local c = ::Wuxia.Slots.getContainer(_actor);
	local level = ::Wuxia.Slots.getActorLevel(_actor);

	local slotsData = [];
	for (local i = 0; i < ::Wuxia.Config.SlotLayout.len(); i = ++i)
	{
		local cfg = ::Wuxia.Config.SlotLayout[i];
		local s = c.m.Slots[i];
		local unlocked = (level >= cfg.UnlockLevel);
		local item = {
			slotIndex         = i,
			slotType          = cfg.SlotType,
			slotLabel         = cfg.Label,
			unlockLevel       = cfg.UnlockLevel,
			unlocked          = unlocked,
			allowedCategories = cfg.AllowedCategories,
			manualID          = null,
			name              = "",
			category          = "",
			categoryLabel     = "",
			quality           = "",
			qualityLabel      = "",
			element           = "",
			elementLabel      = "",
			icon              = "",
			tier              = 0,
			tierLabel         = "",
			exp               = 0,
			expNeeded         = 0,
			isFragment        = false,
			blockedByReq      = false,
			missingReqs       = [],
			description       = "",
			levelSummaries    = []
		};

		if (s.ManualID != null && s.Tier > 0)
		{
			local def = ::Wuxia.Slots.getManualDef(s.ManualID);
			if (def != null)
			{
				local nextNeed = ::Wuxia.Mastery.getNextTierExpNeeded(s);
				local reqCheck = { Met = true, Missing = [] };
				if (!s.IsFragment && s.Tier == 2 && nextNeed > 0 && s.Exp >= nextNeed)
				{
					reqCheck = ::Wuxia.Mastery.checkRequirements(_actor, def);
				}

				local summaries = [];
				for (local lv = 0; lv < def.Levels.len(); lv = ++lv)
				{
					summaries.push({
						tier = lv + 1,
						title = ::Wuxia.Text.TierNames[lv + 1],
						text = def.Levels[lv].Summary,
						expNeeded = def.Levels[lv].ExpNeeded
					});
				}

				item.manualID       = def.ID;
				item.name           = def.Name + (::Wuxia.Slots.getPracticedDef(c, s) == null ? "（超出兼修上限，已封存）" : "");
				item.category       = def.Category;
				item.categoryLabel  = (def.Category in ::Wuxia.Text.Categories) ? ::Wuxia.Text.Categories[def.Category] : def.Category;
				item.quality        = def.Quality;
				item.qualityLabel   = (def.Quality in ::Wuxia.Text.Qualities) ? ::Wuxia.Text.Qualities[def.Quality] : def.Quality;
				item.element        = def.Element != null ? def.Element : "";
				item.elementLabel   = (def.Element != null && def.Element in ::Wuxia.Text.Elements) ? ::Wuxia.Text.Elements[def.Element] : "";
				item.icon           = def.Icon;
				item.tier           = s.Tier;
				item.tierLabel      = ::Wuxia.Text.TierNames[::Math.min(s.Tier, 3)];
				item.exp            = s.Exp;
				item.expNeeded      = nextNeed;
				item.isFragment     = s.IsFragment;
				item.blockedByReq   = !reqCheck.Met;
				item.missingReqs    = reqCheck.Missing;
				item.description    = def.Description;
				item.levelSummaries = summaries;
			}
		}

		slotsData.push(item);
	}

	local mainElementLabel = "未修内功";
	if (c.m.Slots[0].ManualID != null)
	{
		local mdef = ::Wuxia.Slots.getManualDef(c.m.Slots[0].ManualID);
		if (mdef != null && mdef.Element != null && mdef.Element in ::Wuxia.Text.Elements)
			mainElementLabel = ::Wuxia.Text.Elements[mdef.Element];
	}

	local talents = [0, 0, 0, 0, 0, 0, 0, 0];
	if ("m" in _actor && "Talents" in _actor.m)
	{
		for (local t = 0; t < 8 && t < _actor.m.Talents.len(); t = ++t)
			talents[t] = _actor.m.Talents[t];
	}

	local b = _actor.getBaseProperties();
	local baseStats = [
		b.Hitpoints, b.Bravery, b.Stamina, b.Initiative,
		b.MeleeSkill, b.RangedSkill, b.MeleeDefense, b.RangedDefense
	];

	return {
		entityId           = _actor.getID(),
		name               = _actor.getName(),
		level              = level,
		actionPointsMax    = _actor.getActionPointsMax() - c.m.TemporaryAPOverflow,
		permanentAPBonus   = c.getPermanentAPBonus(),
		mainElementLabel   = mainElementLabel,
		hasConflict        = ::Wuxia.Slots.hasNeigongConflict(_actor),
		pendingWashChances = c.m.PendingWashChances,
		talents            = talents,
		baseStats          = baseStats,
		attrLabels         = ::Wuxia.Text.Attributes,
		slots              = slotsData
	};
};

::Wuxia.UI.buildStashWuxiaItems <- function()
{
	local result = [];
	local washPillCount = 0;
	local protectPillCount = 0;

	if (!("World" in getroottable()) || ::World == null || ::World.Assets == null)
		return { items = result, washPillCount = 0, protectPillCount = 0 };

	local stash = ::World.Assets.getStash();
	if (stash == null)
		return { items = result, washPillCount = 0, protectPillCount = 0 };

	local items = stash.getItems();

	// Count total pages per ManualID across all stacks for crafting check
	local pageTotals = {};
	for (local i = 0; i < items.len(); i = ++i)
	{
		local it = items[i];
		if (it != null && it.getID() == "misc.wx_page_item")
		{
			local mid = it.getManualID();
			if (!(mid in pageTotals)) pageTotals[mid] <- 0;
			pageTotals[mid] += it.getPageCount();
		}
	}

	for (local j = 0; j < items.len(); j = ++j)
	{
		local it = items[j];
		if (it == null) continue;
		local id = it.getID();

		if (id == "misc.wx_manual_item")
		{
			local def = ::Wuxia.Slots.getManualDef(it.getManualID());
			if (def == null) continue;
			result.push({
				stashIndex    = j,
				itemKind      = "manual",
				manualID      = def.ID,
				name          = def.Name,
				category      = def.Category,
				categoryLabel = ::Wuxia.Text.Categories[def.Category],
				quality       = def.Quality,
				qualityLabel  = ::Wuxia.Text.Qualities[def.Quality],
				icon          = def.Icon,
				description   = def.Description,
				tier1Summary  = def.Levels[0].Summary,
				tier3Summary  = def.Levels[def.Levels.len() - 1].Summary
			});
		}
		else if (id == "misc.wx_page_item")
		{
			local def = ::Wuxia.Slots.getManualDef(it.getManualID());
			if (def == null) continue;
			local total = (def.ID in pageTotals) ? pageTotals[def.ID] : it.getPageCount();
			result.push({
				stashIndex         = j,
				itemKind           = "page",
				manualID           = def.ID,
				name               = def.Name,
				category           = def.Category,
				categoryLabel      = ::Wuxia.Text.Categories[def.Category],
				quality            = def.Quality,
				qualityLabel       = ::Wuxia.Text.Qualities[def.Quality],
				icon               = def.Icon,
				pageCount          = it.getPageCount(),
				totalPages         = total,
				fragmentsNeeded    = def.FragmentsNeeded,
				canCraft           = (def.FragmentsNeeded > 0 && total >= def.FragmentsNeeded),
				allowFragmentLearn = def.AllowFragmentLearn,
				description        = def.Description
			});
		}
		else if (id == "misc.wx_pill_item")
		{
			local pid = it.getPillID();
			if (!(pid in ::Wuxia.Config.Pills)) continue;
			local pdef = ::Wuxia.Config.Pills[pid];

			if (pdef.Kind == "marrow_wash")  washPillCount += 1;
			if (pdef.Kind == "wash_protect") protectPillCount += 1;

			if (pdef.Kind == "infuse_exp")
			{
				result.push({
					stashIndex    = j,
					itemKind      = "pill_infuse",
					pillID        = pdef.ID,
					name          = pdef.Name,
					category      = "pill",
					categoryLabel = "丹药",
					quality       = "sect",
					qualityLabel  = "修为丹",
					icon          = "ui/items/" + pdef.Icon,
					expAmount     = pdef.ExpAmount,
					description   = pdef.Description
				});
			}
		}
	}

	return {
		items            = result,
		washPillCount    = washPillCount,
		protectPillCount = protectPillCount
	};
};

::Wuxia.HooksMod.hook("scripts/ui/global/data_helper", function( q )
{
	q.addCharacterToUIData = @(__original) function( _entity, _target )
	{
		__original(_entity, _target);
		if (_entity != null && _target != null)
		{
			_target.wxMartial <- ::Wuxia.UI.buildBrotherMartialData(_entity);
		}
	};
});

::Wuxia.HooksMod.hook("scripts/ui/screens/tactical/modules/turn_sequence_bar/turn_sequence_bar", function( q )
{
	q.convertEntityToUIData = @(__original) function( _entity, _isLastEntity = false )
	{
		local data = __original(_entity, _isLastEntity);
		local c = _entity.getSkills().getSkillByID("special.wx_martial_container");
		data.wxPermanentAP <- data.actionPointsMax - (c == null ? 0 : c.m.TemporaryAPOverflow);
		return data;
	};
});
