// Hook scripts/ui/screens/character/character_screen: SQ.call handlers for drag-and-drop Wuxia slots & Marrow Wash

::Wuxia.HooksMod.hook("scripts/ui/screens/character/character_screen", function( q )
{
	q.WX_findBrotherById <- function( _entityId )
	{
		local roster = ::World.getPlayerRoster().getAll();
		foreach (bro in roster)
		{
			if (bro != null && bro.getID() == _entityId)
				return bro;
		}
		return null;
	};

	q.WX_findFirstPillIndex <- function( _stash, _pillKind )
	{
		local items = _stash.getItems();
		for (local i = 0; i < items.len(); i = ++i)
		{
			local it = items[i];
			if (it != null && it.getID() == "misc.wx_pill_item")
			{
				local pid = it.getPillID();
				if (pid in ::Wuxia.Config.Pills && ::Wuxia.Config.Pills[pid].Kind == _pillKind)
					return i;
			}
		}
		return -1;
	};

	// Return full Wuxia tab state for the selected brother + stash manuals/pages/pills
	q.onWXGetState <- function( _data )
	{
		local entityId = (typeof _data == "array") ? _data[0] : _data;
		local bro = this.WX_findBrotherById(entityId);
		local stashData = ::Wuxia.UI.buildStashWuxiaItems(bro);
		return {
			ok               = (bro != null),
			brother          = ::Wuxia.UI.buildBrotherMartialData(bro),
			stashItems       = stashData.items,
			washPillCount    = stashData.washPillCount,
			protectPillCount = stashData.protectPillCount
		};
	};

	// Drag-and-drop manual or page into a martial slot
	// _data = [entityId, stashIndex, slotIndex, isFragment, confirmed]
	q.onWXEquipFromStash <- function( _data )
	{
		local entityId   = _data[0];
		local stashIndex = _data[1];
		local slotIndex  = _data[2];
		local isFragment = _data[3];
		local confirmed  = _data[4];

		local bro = this.WX_findBrotherById(entityId);
		local stash = ::World.Assets.getStash();
		if (bro == null || stash == null)
			return { ok = false, reason = "未找到侠客或行囊。" };

		local items = stash.getItems();
		if (stashIndex < 0 || stashIndex >= items.len() || items[stashIndex] == null)
			return { ok = false, reason = "所选秘籍已不在行囊中。" };

		local it = items[stashIndex];
		local manualID = null;

		if (!isFragment && it.getID() == "misc.wx_manual_item")
		{
			manualID = it.getManualID();
		}
		else if (isFragment && it.getID() == "misc.wx_page_item")
		{
			manualID = it.getManualID();
		}
		else
		{
			return { ok = false, reason = "所选物品不是有效的武学秘籍或残页。" };
		}

		local check = ::Wuxia.Slots.canEquipManual(bro, slotIndex, manualID, isFragment);
		if (!check.Ok)
		{
			return { ok = false, reason = check.Reason };
		}

		// Require explicit user confirmation for Overwrite (散功覆盖) or Fragment Learn (残本强修)
		if ((check.IsOverwrite || isFragment) && !confirmed)
		{
			return {
				ok                   = false,
				needsConfirm         = true,
				isOverwrite          = check.IsOverwrite,
				isFragment           = isFragment,
				oldManualName        = check.OldManualName,
				newManualName        = ::Wuxia.Slots.getManualDef(manualID).Name,
				penaltyDays          = check.PenaltyDays,
				causesInternalInjury = check.CausesInternalInjury
			};
		}

		local res = ::Wuxia.Slots.equipManual(bro, slotIndex, manualID, isFragment);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		// Consume manual or 1 stack of pages from stash
		if (!isFragment)
		{
			stash.removeByIndex(stashIndex);
		}
		else
		{
			it.addPageCount(-1);
			if (it.getPageCount() <= 0)
				stash.removeByIndex(stashIndex);
		}

		local state = this.onWXGetState(entityId);
		state.actionMessage <- isFragment
			? "已冒险强修残本（限一重，行气存在失控风险）。"
			: (res.IsOverwrite ? "散功重修完成！旧功已散，角色进入散功虚弱。" : "武学秘籍已成功装入插槽！");
		return state;
	};

	// Drag-and-drop 凝神丸 onto a martial slot to infuse mastery exp
	// _data = [entityId, stashIndex, slotIndex]
	q.onWXInfusePill <- function( _data )
	{
		local entityId   = _data[0];
		local stashIndex = _data[1];
		local slotIndex  = _data[2];

		local bro = this.WX_findBrotherById(entityId);
		local stash = ::World.Assets.getStash();
		if (bro == null || stash == null)
			return { ok = false, reason = "未找到侠客或行囊。" };

		local items = stash.getItems();
		if (stashIndex < 0 || stashIndex >= items.len() || items[stashIndex] == null)
			return { ok = false, reason = "丹药已不在行囊中。" };

		local it = items[stashIndex];
		if (it.getID() != "misc.wx_pill_item")
			return { ok = false, reason = "所选物品不是修为丹药。" };

		local pid = it.getPillID();
		if (!(pid in ::Wuxia.Config.Pills) || ::Wuxia.Config.Pills[pid].Kind != "infuse_exp")
			return { ok = false, reason = "此丹药不可用于灌注火候。" };

		local expAmt = ::Wuxia.Config.Pills[pid].ExpAmount;
		local res = ::Wuxia.Mastery.infuseWithPill(bro, slotIndex, expAmt);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		stash.removeByIndex(stashIndex);

		local msg = "向《" + res.ManualName + "》灌注 " + expAmt + " 点火候！";
		if (res.Advanced)
			msg += " 功法突破至" + ::Wuxia.Text.TierNames[res.NewTier] + "！";
		else if (res.BlockedByReq)
			msg += " 火候已满，但尚未满足三重大成门槛。";

		local state = this.onWXGetState(entityId);
		state.actionMessage <- msg;
		return state;
	};

	// Drag-and-drop 1 martial page onto an equipped non-fragment slot to infuse mastery exp (参悟化功)
	// _data = [entityId, stashIndex, slotIndex]
	q.onWXInfusePage <- function( _data )
	{
		local entityId   = _data[0];
		local stashIndex = _data[1];
		local slotIndex  = _data[2];

		local bro = this.WX_findBrotherById(entityId);
		local stash = ::World.Assets.getStash();
		if (bro == null || stash == null)
			return { ok = false, reason = "未找到侠客或行囊。" };

		local items = stash.getItems();
		if (stashIndex < 0 || stashIndex >= items.len() || items[stashIndex] == null)
			return { ok = false, reason = "所选残页已不在行囊中。" };

		local it = items[stashIndex];
		if (it.getID() != "misc.wx_page_item")
			return { ok = false, reason = "所选物品不是武学残页。" };

		local res = ::Wuxia.Mastery.infuseWithPage(bro, slotIndex, it.getManualID());
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		it.addPageCount(-1);
		if (it.getPageCount() <= 0)
			stash.removeByIndex(stashIndex);

		local resonanceNote = (res.Resonance != "") ? ("（" + res.Resonance + "）") : "";
		local msg = "参悟《" + res.PageManualName + "》残页" + resonanceNote + "，向《" + res.ManualName + "》注入 " + res.ExpAmount + " 点火候！";
		if (res.Advanced)
			msg += " 功法突破至" + ::Wuxia.Text.TierNames[res.NewTier] + "！";
		else if (res.BlockedByReq)
			msg += " 火候已满，但尚未满足三重大成门槛。";

		local state = this.onWXGetState(entityId);
		state.actionMessage <- msg;
		return state;
	};

	// Craft complete manual from 3/5 pages in stash (supports 2:1 same-quality wildcard completion)
	// _data = [entityId, manualID, allowWildcard, confirmed]
	q.onWXCraftPages <- function( _data )
	{
		local entityId      = _data[0];
		local manualID      = _data[1];
		local allowWildcard = (_data.len() >= 3) ? _data[2] : false;
		local confirmed     = (_data.len() >= 4) ? _data[3] : false;
		local stash         = ::World.Assets.getStash();

		if (allowWildcard && !confirmed)
		{
			local preview = ::Wuxia.Slots.previewWildcardCraft(stash, manualID);
			if (!preview.ok)
				return { ok = false, reason = preview.reason };
			if (preview.needsWildcard)
			{
				return {
					ok                   = false,
					needsWildcardConfirm = true,
					preview              = preview
				};
			}
		}

		local res = ::Wuxia.Slots.craftManualFromStash(stash, manualID, allowWildcard);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		local state = this.onWXGetState(entityId);
		if (res.UsedWildcard)
			state.actionMessage <- "融会补缺成功！额外折算 " + res.SacrificedCount + " 张同阶残页，合成完整秘籍《" + res.ManualName + "》。";
		else
			state.actionMessage <- "残页拼合成功！获得完整秘籍《" + res.ManualName + "》。";
		return state;
	};

	// Transparent Marrow Wash probability preview
	// _data = [entityId, targetAttrIdx, replaceAttrIdx, useProtectPill]
	q.onWXGetWashPreview <- function( _data )
	{
		local bro = this.WX_findBrotherById(_data[0]);
		return ::Wuxia.MarrowWash.getPreview(bro, _data[1], _data[2], _data[3]);
	};

	// Execute Marrow Wash (consumes 洗髓丹 or pending chance + optional 护脉丹)
	// _data = [entityId, targetAttrIdx, replaceAttrIdx, useProtectPill, usePendingChance]
	q.onWXExecuteWash <- function( _data )
	{
		local entityId         = _data[0];
		local targetAttrIdx    = _data[1];
		local replaceAttrIdx   = _data[2];
		local useProtectPill   = _data[3];
		local usePendingChance = _data[4];

		local bro = this.WX_findBrotherById(entityId);
		local stash = ::World.Assets.getStash();
		if (bro == null || stash == null)
			return { ok = false, reason = "未找到侠客或行囊。" };

		local washIdx = -1;
		if (!usePendingChance)
		{
			washIdx = this.WX_findFirstPillIndex(stash, "marrow_wash");
			if (washIdx < 0)
				return { ok = false, reason = "行囊中缺少洗髓丹。" };
		}

		local protectIdx = -1;
		if (useProtectPill)
		{
			protectIdx = this.WX_findFirstPillIndex(stash, "wash_protect");
			if (protectIdx < 0)
				return { ok = false, reason = "行囊中缺少护脉丹。" };
		}

		local res = ::Wuxia.MarrowWash.execute(bro, targetAttrIdx, replaceAttrIdx, useProtectPill, usePendingChance);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		// Consume pills cleanly (remove higher index first to avoid index shift!)
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
		{
			stash.removeByIndex(washIdx);
		}
		else if (protectIdx >= 0)
		{
			stash.removeByIndex(protectIdx);
		}

		local state = this.onWXGetState(entityId);
		state.washResult <- res;
		state.actionMessage <- res.Message;
		return state;
	};
});
