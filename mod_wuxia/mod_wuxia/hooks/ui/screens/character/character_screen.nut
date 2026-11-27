// Hook scripts/ui/screens/character/character_screen:
// Supports 7-Slot Learned Manual Selection (武学修为), Company Manual Vault (藏经阁), Consumable Right-Click Learning & Live Vanilla UI Sync.

::Wuxia.HooksMod.hook("scripts/ui/screens/character/character_screen", function( q )
{
	q.m.WX_PendingAutoStoreNotice <- "";

	// Auto-sweep newly looted/bought manuals & pages into 藏经阁 before CharacterScreen populates Stash UI!
	q.show = @(__original) function()
	{
		this.m.WX_PendingAutoStoreNotice = "";
		if ("VFX" in ::Wuxia && "clearAllActiveMotions" in ::Wuxia.VFX
			&& (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()))
		{
			::Wuxia.VFX.clearAllActiveMotions(true);
		}
		if (!this.isInGroundMode() && ::Wuxia.Library.isAutoStoreEnabled()
			&& ("World" in getroottable()) && ::World != null && ::World.Assets != null)
		{
			local stash = ::World.Assets.getStash();
			if (stash != null)
			{
				local moved = ::Wuxia.Library.storeAllFromStash(stash, false);
				if (moved.booksMoved > 0 || moved.pagesMoved > 0)
				{
					local parts = [];
					if (moved.booksMoved > 0) parts.push(moved.booksMoved + " 册秘籍");
					if (moved.pagesMoved > 0) parts.push(moved.pagesMoved + " 张残页");
					this.m.WX_PendingAutoStoreNotice = "已自动将行囊新获典籍（" + parts[0] + (parts.len() > 1 ? ("、" + parts[1]) : "") + "）归入【藏经阁】，释放 " + moved.slotsCleared + " 格仓库空间。";
				}
			}
		}
		__original();
	};

	if (::Wuxia.qHas(q, "hide"))
	{
		q.hide = @(__original) function()
		{
			__original();
			if ("WorldVisuals" in ::Wuxia && "syncPlayerLeadAppearance" in ::Wuxia.WorldVisuals)
				::Wuxia.WorldVisuals.syncPlayerLeadAppearance();
		};
	}

	// Intercept right-click consumable use in vanilla Stash to provide clear feedback when consuming wx_manual_item or wx_wmod_*
	q.onEquipInventoryItem = @(__original) function( _data )
	{
		local manualMeta = null;
		local wmodMeta = null;
		if (typeof _data == "array" && _data.len() >= 2 && ("World" in getroottable()) && ::World != null && ::World.Assets != null)
		{
			local bro = this.WX_findBrotherById(_data[0]);
			local stash = ::World.Assets.getStash();
			local itemId = _data[1];
			if (bro != null && stash != null && itemId != null)
			{
				local slotItem = stash.getItemByInstanceID(itemId);
				local itemObj = (slotItem != null && ("item" in slotItem)) ? slotItem.item : slotItem;
				if (itemObj != null && (::Wuxia.hasMember(itemObj, "getID")) && itemObj.getID() == "misc.wx_manual_item")
				{
					local mid = itemObj.getManualID();
					local def = ::Wuxia.Slots.getManualDef(mid);
					local c = ::Wuxia.Slots.getContainer(bro);
					c.ensureSlotsRegisteredInLearned();
					local prev = c.getLearnedEntry(mid);
					manualMeta = {
						broName     = bro.getName(),
						manualID    = mid,
						manualName  = def != null ? def.Name : mid,
						wasFull     = (prev != null && !prev.IsFragment),
						wasFragment = (prev != null && prev.IsFragment)
					};
				}
				else if (itemObj != null && (::Wuxia.hasMember(itemObj, "getID")) && itemObj.getID().find("misc.wx_wmod_") == 0)
				{
					local mcfg = ::Wuxia.hasMember(itemObj, "getModCfg") ? itemObj.getModCfg() : null;
					local mainWpn = (bro.getItems() != null) ? bro.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand) : null;
					wmodMeta = {
						broName     = bro.getName(),
						instanceID  = itemId,
						modName     = itemObj.getName(),
						familyLabel = mcfg != null ? mcfg.FamilyLabel : "适配兵刃",
						wpnName     = mainWpn != null ? mainWpn.getName() : ""
					};
				}
			}
		}

		local ret = __original(_data);

		if (wmodMeta != null && typeof ret == "table")
		{
			local stashAfter = (("World" in getroottable()) && ::World != null && ::World.Assets != null) ? ::World.Assets.getStash() : null;
			local stillInStash = (stashAfter != null && stashAfter.getItemByInstanceID(wmodMeta.instanceID) != null);
			if (stillInStash)
			{
				ret.wxManualNotice <- {
					ok      = false,
					message = wmodMeta.broName + " 主手未装备匹配的【" + wmodMeta.familyLabel + "】，无法镶缀「" + wmodMeta.modName + "」！"
				};
			}
			else
			{
				ret.wxManualNotice <- {
					ok      = true,
					message = wmodMeta.broName + " 已将「" + wmodMeta.modName + "」成功镶缀于主手兵刃" + (wmodMeta.wpnName != "" ? ("「" + wmodMeta.wpnName + "」") : "") + "！"
				};
			}
		}

		if (manualMeta != null && typeof ret == "table")
		{
			if (manualMeta.wasFull)
			{
				ret.wxManualNotice <- {
					ok      = false,
					message = manualMeta.broName + " 已习得《" + manualMeta.manualName + "》，无需重复消耗秘籍（可在其他角色页右键传授或收入藏经阁）。"
				};
			}
			else
			{
				local learnedCard = ::Wuxia.UI.buildManualShowcaseCard(manualMeta.manualID, manualMeta.wasFragment ? "补全残篇" : "领悟入录");
				ret.wxManualNotice <- {
					ok         = true,
					message    = manualMeta.broName + (manualMeta.wasFragment ? " 补全并领悟完整秘籍" : " 成功研习领悟") + "《" + manualMeta.manualName + "》！请切至【武学修为】页选装入槽。",
					wxShowcase = {
						kind     = "learn_manual",
						outcome  = "success",
						title    = manualMeta.wasFragment ? "补全残卷 · 领悟全篇" : "展卷研习 · 领悟新功",
						subtitle = manualMeta.broName + " · 请切至【武学修为】页装入穴位运功",
						items    = [learnedCard],
						message  = manualMeta.broName + (manualMeta.wasFragment ? " 补全并领悟完整秘籍" : " 成功研习领悟") + "《" + manualMeta.manualName + "》！"
					}
				};
			}
		}
		return ret;
	};

	q.WX_findBrotherById <- function( _entityId )
	{
		if (!("World" in getroottable()) || ::World == null || ::World.getPlayerRoster() == null)
			return null;
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
		if (_pillKind == "wash_protect")
		{
			local zIdx = ("Alchemy" in ::Wuxia && "findPillIndexByID" in ::Wuxia.Alchemy) ? ::Wuxia.Alchemy.findPillIndexByID(_stash, "wx_pill_zaohua") : -1;
			if (zIdx >= 0) return zIdx;
		}
		local bestIdx = -1;
		local bestScore = -1;
		for (local i = 0; i < items.len(); i = ++i)
		{
			local it = items[i];
			if (it != null && it.getID() == "misc.wx_pill_item")
			{
				local pid = it.getPillID();
				if (pid in ::Wuxia.Config.Pills && ::Wuxia.Config.Pills[pid].Kind == _pillKind)
				{
					local sc = ((::Wuxia.hasMember(it, "getPillGrade")) ? it.getPillGrade() : 1) * 1000 + ((::Wuxia.hasMember(it, "getPotencyPct")) ? it.getPotencyPct() : 100);
					if (sc > bestScore) { bestScore = sc; bestIdx = i; }
				}
			}
		}
		return bestIdx;
	};

	// Build vanilla UI sync payload so Left Panel stats/skills & Stash tab stay 100% live
	q.WX_attachVanillaSync <- function( _state, _bro, _syncBrother = false, _syncStash = false )
	{
		if (_syncBrother && _bro != null && ("UIDataHelper" in getroottable()) && ::UIDataHelper != null)
		{
			try
			{
				_state.uiBrother <- ::UIDataHelper.convertEntityToUIData(_bro, null);
			}
			catch (_err) {}
		}
		if (_syncStash && ("World" in getroottable()) && ::World != null && ::World.Assets != null)
		{
			local stash = ::World.Assets.getStash();
			if (stash != null)
			{
				_state.stashSpaceUsed <- stash.getNumberOfFilledSlots();
				_state.stashSpaceMax  <- stash.getCapacity();
				try
				{
					if (::Wuxia.hasMember(this, "onQueryStashList"))
					{
						_state.uiStash <- this.onQueryStashList();
					}
					else if ("UIDataHelper" in getroottable() && "convertStashToUIData" in ::UIDataHelper)
					{
						local flt = (::Wuxia.hasMember(this.m, "InventoryFilter")) ? this.m.InventoryFilter : ::Const.Items.ItemFilter.All;
						_state.uiStash <- ::UIDataHelper.convertStashToUIData(false, flt);
					}
				}
				catch (_err2) {}
			}
		}
		return _state;
	};

	// Return full Wuxia state (Selected Brother Slots + LearnedManuals + Company 藏经阁 + Stash Pills)
	q.onWXGetState <- function( _data )
	{
		local entityId = (typeof _data == "array" && _data.len() > 0) ? _data[0] : _data;
		local bro = this.WX_findBrotherById(entityId);
		local pillData = ::Wuxia.UI.buildStashPillsData();
		local wash = ::Wuxia.Alchemy.getWashPillCounts();
		local libData  = ::Wuxia.UI.buildLibraryUIData(bro);
		local notice   = this.m.WX_PendingAutoStoreNotice;
		this.m.WX_PendingAutoStoreNotice = "";

		local res = {
			ok               = (bro != null),
			brother          = ::Wuxia.UI.buildBrotherMartialData(bro),
			library          = libData,
			stashItems       = pillData.pills,
			washPills        = wash,
			washPillCount    = wash.totalMainWash,
			protectPillCount = wash.totalProtect,
			alchemySummary   = ::Wuxia.Alchemy.getCabinetSummaryCounts()
		};
		if (res.brother != null)
			res.brother.hasWangchenGrace <- bro.getSkills().hasSkill("effects.wx_wangchen_grace");
		if (notice != "")
			res.autoStoreNotice <- notice;
		return res;
	};

	::Wuxia.UI.attachSectTeaHouseRPCs(q);

	// Equip a manual from the character's OWN LearnedManuals pool into one of the 7 slots
	// _data = [entityId, slotIndex, manualID, confirmed]
	q.onWXEquipLearned <- function( _data )
	{
		local entityId  = _data[0];
		local slotIndex = _data[1];
		local manualID  = _data[2];
		local confirmed = _data.len() >= 4 ? _data[3] : false;

		local bro = this.WX_findBrotherById(entityId);
		if (bro == null)
			return { ok = false, reason = "未找到该名侠客。" };

		local check = ::Wuxia.Slots.canEquipLearnedManual(bro, slotIndex, manualID);
		if (!check.Ok)
			return { ok = false, reason = check.Reason };
		if (confirmed && _data.len() >= 5 && _data[4] != check.OldManualID)
			return { ok = false, reason = "该穴位功法已变更，请重新确认。" };

		if (check.IsOverwrite && !confirmed)
		{
			return {
				ok            = false,
				needsConfirm  = true,
				confirmKind   = "switch_slot",
				isOverwrite   = true,
				oldManualID   = check.OldManualID,
				oldManualName = check.OldManualName,
				newManualName = check.NewManualName,
				penaltyDays   = check.PenaltyDays,
				isFragment    = check.IsFragment
			};
		}

		local res = ::Wuxia.Slots.equipLearnedManual(bro, slotIndex, manualID);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		local state = this.onWXGetState(entityId);
		this.WX_attachVanillaSync(state, bro, true, false);
		state.actionMessage <- res.IsOverwrite
			? ("已换装《" + res.NewManualName + "》！（《" + res.OldManualName + "》重数与火候已完整保留于已习武学，附带 " + res.PenaltyDays + " 天短暂散功调息）")
			: ("《" + res.NewManualName + "》已装入插槽生效！");
		local eqCard = ::Wuxia.UI.buildManualShowcaseCard(manualID, "");
		state.wxShowcase <- {
			kind        = "slot_change",
			slotIndex   = slotIndex,
			manualName  = res.NewManualName,
			icon        = eqCard.overlayIcon != "" ? eqCard.overlayIcon : eqCard.icon,
			isOverwrite = res.IsOverwrite,
			message     = state.actionMessage
		};
		return state;
	};

	// Unequip an occupied slot back into LearnedManuals (preserves Tier & Exp)
	// _data = [entityId, slotIndex, confirmed, expectedManualID]
	q.onWXUnequipSlot <- function( _data )
	{
		local entityId  = _data[0];
		local slotIndex = _data[1];
		local confirmed = _data.len() >= 3 ? _data[2] : false;
		local expectedManualID = _data.len() >= 4 ? _data[3] : null;

		local bro = this.WX_findBrotherById(entityId);
		if (bro == null)
			return { ok = false, reason = "未找到该名侠客。" };

		local check = ::Wuxia.Slots.canUnequipSlot(bro, slotIndex);
		if (!check.Ok)
			return { ok = false, reason = check.Reason };

		if (!confirmed)
		{
			return {
				ok            = false,
				needsConfirm  = true,
				confirmKind   = "unequip_slot",
				oldManualID   = check.OldManualID,
				oldManualName = check.OldManualName,
				penaltyDays   = check.PenaltyDays
			};
		}

		if (expectedManualID != check.OldManualID)
			return { ok = false, reason = "该穴位功法已变更，请重新确认。" };

		local res = ::Wuxia.Slots.unequipSlot(bro, slotIndex);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		local state = this.onWXGetState(entityId);
		this.WX_attachVanillaSync(state, bro, true, false);
		state.actionMessage <- "已卸下《" + res.OldManualName + "》（重数与火候完整保留于已习武学，角色进入 " + res.PenaltyDays + " 天散功调息）。";
		state.wxShowcase <- {
			kind        = "slot_unequip",
			slotIndex   = slotIndex,
			manualName  = res.OldManualName,
			penaltyDays = res.PenaltyDays,
			message     = state.actionMessage
		};
		return state;
	};

	// Consume 1 manual (or 1 fragment page) from 藏经阁 to teach the selected brother permanently
	// _data = [entityId, manualID, isFragment, confirmed]
	q.onWXLearnFromLibrary <- function( _data )
	{
		local entityId   = _data[0];
		local manualID   = _data[1];
		local isFragment = _data.len() >= 3 ? _data[2] : false;
		local confirmed  = _data.len() >= 4 ? _data[3] : false;

		local bro = this.WX_findBrotherById(entityId);
		if (bro == null)
			return { ok = false, reason = "未选择要传授武学的侠客。" };

		local def = ::Wuxia.Slots.getManualDef(manualID);
		if (def == null)
			return { ok = false, reason = "未知武学秘籍。" };

		if (isFragment && !confirmed)
		{
			return {
				ok            = false,
				needsConfirm  = true,
				confirmKind   = "fragment_learn",
				newManualName = def.Name
			};
		}

		local res = ::Wuxia.Library.learnFromLibrary(bro, manualID, isFragment);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		local state = this.onWXGetState(entityId);
		this.WX_attachVanillaSync(state, bro, true, false);
		if (res.UpgradedFragment)
			state.actionMessage <- bro.getName() + " 研读完整《" + res.ManualName + "》，已补全先前残本隐患，可突破二、三重境界！";
		else if (isFragment)
			state.actionMessage <- bro.getName() + " 已强行记下《" + res.ManualName + "》残篇（限一重），可切至【武学修为】页装入插槽。";
		else
			state.actionMessage <- bro.getName() + " 成功领悟《" + res.ManualName + "》！请切至【武学修为】页选装入槽。";
		local lCard = ::Wuxia.UI.buildManualShowcaseCard(manualID, res.UpgradedFragment ? "补全残本" : (isFragment ? "强记残篇" : "完整领悟"));
		state.wxShowcase <- {
			kind     = "learn_manual",
			outcome  = res.UpgradedFragment ? "crit" : "success",
			title    = res.UpgradedFragment ? "残卷补全 · 贯通全篇" : (isFragment ? "强记残篇 · 初窥门径" : "藏经研习 · 领悟新功"),
			subtitle = bro.getName() + " · 已录于【已习武学】",
			items    = [lCard],
			message  = state.actionMessage
		};
		return state;
	};

	// _data = [entityId, slotIndex, manualID, isFragment, confirmed, previousManualID]
	q.onWXLearnAndEquip <- function( _data )
	{
		if (typeof _data != "array" || _data.len() < 3) return { ok = false, reason = "缺少研习或装配信息。" };
		local bro = this.WX_findBrotherById(_data[0]);
		local isFrag = (_data.len() > 3 && _data[3]);
		local result = ::Wuxia.Library.learnAndEquip(bro, _data[1], _data[2], isFrag,
			_data.len() > 4 && _data[4], _data.len() > 5, _data.len() > 5 ? _data[5] : null);
		if (!result.ok) return result;
		local state = this.onWXGetState(_data[0]);
		this.WX_attachVanillaSync(state, bro, true, false);
		state.actionMessage <- result.actionMessage;
		local leCard = ::Wuxia.UI.buildManualShowcaseCard(_data[2], isFrag ? "残篇入槽" : "研习入槽");
		state.wxShowcase <- {
			kind      = "learn_manual",
			outcome   = "success",
			title     = isFrag ? "残篇强习 · 装入穴位" : "领悟新功 · 运转周天",
			subtitle  = (bro != null ? bro.getName() : "侠客") + " · 已直接装入武学穴位生效",
			slotIndex = _data[1],
			items     = [leCard],
			message   = result.actionMessage
		};
		return state;
	};

	// Sweep all manuals & pages from Stash into 藏经阁
	// _data = [entityId]
	q.onWXLibraryStoreAll <- function( _data )
	{
		local entityId = (typeof _data == "array" && _data.len() > 0) ? _data[0] : _data;
		local bro = this.WX_findBrotherById(entityId);
		local stash = ::World.Assets.getStash();
		if (stash == null)
			return { ok = false, reason = "无法访问战团仓库。" };

		local moved = ::Wuxia.Library.storeAllFromStash(stash, true);
		local state = this.onWXGetState(entityId);
		this.WX_attachVanillaSync(state, bro, false, true);

		if (moved.booksMoved == 0 && moved.pagesMoved == 0)
			state.actionMessage <- "战团仓库中当前没有武学秘籍或残页需要收纳。";
		else
		{
			state.actionMessage <- "收纳完成！共将 " + moved.booksMoved + " 册秘籍、" + moved.pagesMoved + " 张残页归入藏经阁，腾出 " + moved.slotsCleared + " 格仓库空间。";
			local sParts = [];
			if (moved.booksMoved > 0) sParts.push("秘籍×" + moved.booksMoved);
			if (moved.pagesMoved > 0) sParts.push("残页×" + moved.pagesMoved);
			state.wxShowcase <- {
				kind      = "sweep_vault",
				floatText = (sParts.len() == 2 ? (sParts[0] + " · " + sParts[1]) : sParts[0]) + " 归入藏经阁",
				message   = state.actionMessage
			};
		}
		return state;
	};

	// Withdraw 1 manual or 1 stack of pages from 藏经阁 to Stash (for selling in town)
	// _data = [entityId, manualID, isPage]
	q.onWXLibraryWithdraw <- function( _data )
	{
		local entityId = _data[0];
		local manualID = _data[1];
		local isPage   = _data.len() >= 3 ? _data[2] : false;
		local bro      = this.WX_findBrotherById(entityId);
		local stash    = ::World.Assets.getStash();

		local res = isPage
			? ::Wuxia.Library.withdrawPagesToStash(stash, manualID)
			: ::Wuxia.Library.withdrawManualToStash(stash, manualID);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		local state = this.onWXGetState(entityId);
		this.WX_attachVanillaSync(state, bro, false, true);
		state.actionMessage <- isPage
			? ("已取出《" + res.ManualName + "》残页 ×" + res.Count + " 至战团仓库（可在城镇市集出售）。")
			: ("已取出《" + res.ManualName + "》至战团仓库（可在市集出售或直接右键给角色研习）。");
		return state;
	};

	// Toggle Auto-Store setting in 藏经阁
	// _data = [entityId, enabled]
	q.onWXLibrarySetAutoStore <- function( _data )
	{
		local entityId = _data[0];
		local enabled  = _data[1] ? true : false;
		local bro      = this.WX_findBrotherById(entityId);
		::Wuxia.Library.setAutoStoreEnabled(enabled);

		local swept = { booksMoved = 0, pagesMoved = 0, slotsCleared = 0 };
		if (enabled && ::World != null && ::World.Assets != null && ::World.Assets.getStash() != null)
		{
			swept = ::Wuxia.Library.storeAllFromStash(::World.Assets.getStash(), false);
		}

		local state = this.onWXGetState(entityId);
		if (swept.slotsCleared > 0)
			this.WX_attachVanillaSync(state, bro, false, true);
		state.actionMessage <- enabled
			? ("已开启「秘籍/残页自动入阁」" + (swept.slotsCleared > 0 ? ("，并自动收纳释放了 " + swept.slotsCleared + " 格仓库空间。") : "。"))
			: "已关闭自动入阁，新获秘籍与残页将暂留战团仓库，可手动点击「一键收纳」入阁。";
		return state;
	};

	// Craft 1 manual inside 藏经阁 from exact pages or 2:1 wildcard pages
	// _data = [entityId, manualID, allowWildcard, confirmed]
	q.onWXLibraryCraft <- function( _data )
	{
		local entityId      = _data[0];
		local manualID      = _data[1];
		local allowWildcard = (_data.len() >= 3) ? _data[2] : false;
		local confirmed     = (_data.len() >= 4) ? _data[3] : false;

		if (allowWildcard && !confirmed)
		{
			local preview = ::Wuxia.Library.previewWildcardCraft(manualID);
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

		local res = ::Wuxia.Library.craftManual(manualID, allowWildcard);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		local state = this.onWXGetState(entityId);
		state.actionMessage <- res.UsedWildcard
			? ("融会补缺成功！额外折算 " + res.SacrificedCount + " 张同品阶闲置残页，在藏经阁合成完整秘籍《" + res.ManualName + "》！")
			: ("残页装帧成册！在藏经阁合成完整秘籍《" + res.ManualName + "》！");
		state.wxShowcase <- {
			kind     = "craft_manual",
			outcome  = res.UsedWildcard ? "great" : "success",
			title    = res.UsedWildcard ? "融会补缺 · 装帧成册" : "残页拼合 · 装帧成册",
			subtitle = "新成秘籍已典藏入【藏经阁】",
			items    = [::Wuxia.UI.buildManualShowcaseCard(manualID, res.UsedWildcard ? "融会补缺成册" : "完整装帧")],
			message  = state.actionMessage
		};
		return state;
	};

	// One-click craft ALL exact-complete page stacks inside 藏经阁
	// _data = [entityId]
	q.onWXLibraryCraftAll <- function( _data )
	{
		local entityId = (typeof _data == "array" && _data.len() > 0) ? _data[0] : _data;
		local res = ::Wuxia.Library.craftAllExact();
		if (res.booksCrafted <= 0)
			return { ok = false, reason = "藏经阁中暂无凑齐张数的残页可供批量拼合。" };

		local state = this.onWXGetState(entityId);
		local previewNames = "";
		for (local i = 0; i < res.names.len() && i < 4; i = ++i)
		{
			if (i > 0) previewNames += "、";
			previewNames += res.names[i];
		}
		if (res.names.len() > 4) previewNames += " 等";
		state.actionMessage <- "批量装帧完成！消耗 " + res.pagesSpent + " 张残页，合成 " + res.booksCrafted + " 册完整秘籍：" + previewNames + "。";

		local craftedCards = [];
		if ("crafted" in res && res.crafted != null)
		{
			for (local ci = 0; ci < res.crafted.len() && ci < 6; ci = ++ci)
			{
				local ce = res.crafted[ci];
				craftedCards.push(::Wuxia.UI.buildManualShowcaseCard(ce.id, ce.count > 1 ? ("×" + ce.count + " 册") : "1 册"));
			}
		}
		state.wxShowcase <- {
			kind     = "craft_manual",
			outcome  = res.booksCrafted >= 2 ? "crit" : "success",
			title    = "批量装帧 · 秘籍成册",
			subtitle = "共消耗 " + res.pagesSpent + " 张残页，合成 " + res.booksCrafted + " 册完整秘籍归入藏经阁",
			items    = craftedCards,
			message  = state.actionMessage
		};
		return state;
	};

	// Infuse mastery exp into an equipped slot from Stash Pill/Neidan OR 藏经阁 Page
	// Stash Pill: _data = [entityId, stashIndex, slotIndex]
	q.onWXInfusePill <- function( _data )
	{
		local entityId   = _data[0];
		local stashIndex = _data[1];
		local slotIndex  = _data[2];

		local bro = this.WX_findBrotherById(entityId);
		local stash = ::World.Assets.getStash();
		if (bro == null || stash == null)
			return { ok = false, reason = "未找到侠客或战团仓库。" };

		local items = stash.getItems();
		if (stashIndex < 0 || stashIndex >= items.len() || items[stashIndex] == null)
			return { ok = false, reason = "丹药已不在仓库中。" };

		local it = items[stashIndex];
		local expAmt = 0;
		local curesScatter = false;
		local curesInternal = false;
		local healHP = 0;
		local resonanceNote = "";
		if (it.getID() == "misc.wx_pill_item")
		{
			local pid = it.getPillID();
			if (!(pid in ::Wuxia.Config.Pills) || ::Wuxia.Config.Pills[pid].Kind != "infuse_exp")
				return { ok = false, reason = "此丹药不可用于灌注火候。" };
			local pdef = ::Wuxia.Config.Pills[pid];
			if (::Wuxia.hasMember(it, "getInfuseExpForSlot"))
			{
				local infInfo = it.getInfuseExpForSlot(bro, slotIndex);
				expAmt = infInfo.ExpAmount;
				resonanceNote = infInfo.Note;
			}
			else
			{
				expAmt = pdef.ExpAmount;
			}
			curesScatter = ("CuresScatter" in pdef) && pdef.CuresScatter;
			curesInternal = ("CuresInternal" in pdef) && pdef.CuresInternal;
			healHP = ("HealHP" in pdef) ? ::Math.round(pdef.HealHP * ((::Wuxia.hasMember(it, "getPotencyPct")) ? it.getPotencyPct() : 100) / 100.0).tointeger() : 0;
		}
		else if (::Wuxia.hasMember(it.m, "HerbID") && ("Herbs" in ::Wuxia.Config) && (it.m.HerbID in ::Wuxia.Config.Herbs))
		{
			local hdef = ::Wuxia.Config.Herbs[it.m.HerbID];
			if (hdef.Kind != "herb_infuse")
				return { ok = false, reason = "此奇草请直接点击服用或携往百工炼丹房入炉。" };
			expAmt = hdef.ExpAmount;
		}
		else if (::Wuxia.hasMember(it.m, "CoreID") && (it.m.CoreID in ::Wuxia.Config.ShanHaiCores))
		{
			local baseExp = ::Wuxia.Config.ShanHaiCores[it.m.CoreID].ExpAmount;
			expAmt = baseExp;
			local c = bro.getSkills().getSkillByID("special.wx_martial_container");
			if (c != null && slotIndex >= 0 && slotIndex < c.m.Slots.len() && c.m.Slots[slotIndex].ManualID != null)
			{
				local mdef = ::Wuxia.Slots.getManualDef(c.m.Slots[slotIndex].ManualID);
				expAmt = ::Wuxia.ShanHai.getCoreInfuseExp(it.m.CoreID, mdef);
				if (expAmt >= baseExp + 180) resonanceNote = "（山海孤本大共鸣！）";
				else if (expAmt > baseExp) resonanceNote = "（内丹气脉共鸣！）";
			}
		}
		else
		{
			return { ok = false, reason = "所选物品不是修为丹药、仙株或山海内丹。" };
		}

		local res = ::Wuxia.Mastery.infuseWithPill(bro, slotIndex, expAmt);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		local clearedScatter = false;
		if (curesScatter && bro.getSkills().hasSkill("effects.wx_scatter_weakness"))
		{
			bro.getSkills().removeByID("effects.wx_scatter_weakness");
			bro.getSkills().update();
			clearedScatter = true;
		}
		if (curesInternal)
		{
			local inj = bro.getSkills().getSkillByID("effects.wx_internal_injury");
			if (inj != null && inj.m.Severity > 0)
			{
				inj.cureTemporary();
				bro.getSkills().update();
			}
		}
		if (healHP > 0 && bro.getHitpoints() < bro.getHitpointsMax())
		{
			bro.setHitpoints(::Math.min(bro.getHitpointsMax(), bro.getHitpoints() + healHP));
		}

		local srcName = it.getName();
		local srcIcon = it.getIcon();
		if (srcIcon != null && srcIcon != "" && srcIcon.find("ui/") != 0)
			srcIcon = "ui/items/" + srcIcon;
		local slotManualID = null;
		local cBefore = bro.getSkills().getSkillByID("special.wx_martial_container");
		if (cBefore != null && slotIndex >= 0 && slotIndex < cBefore.m.Slots.len())
			slotManualID = cBefore.m.Slots[slotIndex].ManualID;

		stash.removeByIndex(stashIndex);

		local msg = "向《" + res.ManualName + "》灌注 " + res.ExpAmount + " 点火候！" + resonanceNote;
		if (clearedScatter)
			msg += " 九转药力同时化解了散功虚弱！";
		if (res.Advanced)
			msg += " 功法突破至" + ::Wuxia.Text.TierNames[res.NewTier] + "！";
		else if (res.BlockedByReq)
			msg += " 火候已满，但尚未满足三重大成属性门槛。";

		local state = this.onWXGetState(entityId);
		this.WX_attachVanillaSync(state, bro, true, true);
		state.actionMessage <- msg;

		local tierName = (res.NewTier in ::Wuxia.Text.TierNames) ? ::Wuxia.Text.TierNames[res.NewTier] : ("第" + res.NewTier + "重");
		if (res.Advanced)
		{
			local mCard = slotManualID != null ? ::Wuxia.UI.buildManualShowcaseCard(slotManualID, "破境登阶 · " + tierName) : null;
			state.wxShowcase <- {
				kind        = "breakthrough",
				outcome     = res.NewTier >= 3 ? "crit" : "great",
				title       = res.NewTier >= 3 ? "三重大成 · 功行圆满！" : ("功法破境 · " + tierName),
				subtitle    = bro.getName() + " 炼化「" + srcName + "」，贯通关窍（火候 +" + res.ExpAmount + "）",
				slotIndex   = slotIndex,
				broName     = bro.getName(),
				sourceName  = srcName,
				sourceIcon  = srcIcon,
				expAmount   = res.ExpAmount,
				newTier     = res.NewTier,
				newTierName = tierName,
				items       = mCard != null ? [mCard] : [],
				message     = msg
			};
		}
		else
		{
			state.wxShowcase <- {
				kind         = "infuse",
				slotIndex    = slotIndex,
				manualName   = res.ManualName,
				sourceName   = srcName,
				sourceIcon   = srcIcon,
				expAmount    = res.ExpAmount,
				blockedByReq = res.BlockedByReq,
				resonance    = resonanceNote,
				message      = msg
			};
		}
		return state;
	};

	// Infuse 1 page from 藏经阁 into an equipped non-fragment slot (参悟化功)
	// _data = [entityId, pageManualID, slotIndex]
	q.onWXInfuseLibraryPage <- function( _data )
	{
		local entityId     = _data[0];
		local pageManualID = _data[1];
		local slotIndex    = _data[2];

		local bro = this.WX_findBrotherById(entityId);
		if (bro == null)
			return { ok = false, reason = "未找到该名侠客。" };

		local slotManualID = null;
		local cBefore = bro.getSkills().getSkillByID("special.wx_martial_container");
		if (cBefore != null && slotIndex >= 0 && slotIndex < cBefore.m.Slots.len())
			slotManualID = cBefore.m.Slots[slotIndex].ManualID;

		local res = ::Wuxia.Library.infuseSlotWithPage(bro, slotIndex, pageManualID);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		local resonanceNote = (res.Resonance != "") ? ("（" + res.Resonance + "）") : "";
		local msg = "参悟《" + res.PageManualName + "》残页" + resonanceNote + "，向《" + res.ManualName + "》注入 " + res.ExpAmount + " 点火候！";
		if (res.Advanced)
			msg += " 功法突破至" + ::Wuxia.Text.TierNames[res.NewTier] + "！";
		else if (res.BlockedByReq)
			msg += " 火候已满，但尚未满足三重大成门槛。";

		local state = this.onWXGetState(entityId);
		this.WX_attachVanillaSync(state, bro, true, false);
		state.actionMessage <- msg;

		local pgCard = ::Wuxia.UI.buildManualShowcaseCard(pageManualID, "残页参悟");
		local tierName = (res.NewTier in ::Wuxia.Text.TierNames) ? ::Wuxia.Text.TierNames[res.NewTier] : ("第" + res.NewTier + "重");
		if (res.Advanced)
		{
			local mCard = slotManualID != null ? ::Wuxia.UI.buildManualShowcaseCard(slotManualID, "破境登阶 · " + tierName) : null;
			state.wxShowcase <- {
				kind        = "breakthrough",
				outcome     = res.NewTier >= 3 ? "crit" : "great",
				title       = res.NewTier >= 3 ? "三重大成 · 功行圆满！" : ("参悟破境 · " + tierName),
				subtitle    = bro.getName() + " 参悟《" + res.PageManualName + "》残页，贯通关窍（火候 +" + res.ExpAmount + "）",
				slotIndex   = slotIndex,
				broName     = bro.getName(),
				sourceName  = "《" + res.PageManualName + "》残页",
				sourceIcon  = pgCard.icon,
				expAmount   = res.ExpAmount,
				newTier     = res.NewTier,
				newTierName = tierName,
				items       = mCard != null ? [mCard] : [],
				message     = msg
			};
		}
		else
		{
			state.wxShowcase <- {
				kind         = "infuse",
				slotIndex    = slotIndex,
				manualName   = res.ManualName,
				sourceName   = "《" + res.PageManualName + "》残页",
				sourceIcon   = pgCard.icon,
				expAmount    = res.ExpAmount,
				blockedByReq = res.BlockedByReq,
				resonance    = resonanceNote,
				message      = msg
			};
		}
		return state;
	};

	// Directly consume healing / detox / battle-prep pill for the selected brother
	// _data = [entityId, stashIndex]
	q.onWXUsePill <- function( _data )
	{
		local entityId   = _data[0];
		local stashIndex = _data[1];

		local bro = this.WX_findBrotherById(entityId);
		local stash = ::World.Assets.getStash();
		if (bro == null || stash == null)
			return { ok = false, reason = "未找到侠客或战团仓库。" };

		local items = stash.getItems();
		if (stashIndex < 0 || stashIndex >= items.len() || items[stashIndex] == null)
			return { ok = false, reason = "所选丹药已不在仓库中。" };

		local it = items[stashIndex];
		if (!("applyToActorWithMessage" in it))
			return { ok = false, reason = "所选物品不是可直接服食的灵丹或奇草。" };

		local pName = it.getName();
		local pIcon = it.getIcon();
		if (pIcon != null && pIcon != "" && pIcon.find("ui/") != 0)
			pIcon = "ui/items/" + pIcon;

		local pSub = "";
		if (it.getID() == "misc.wx_pill_item" && ::Wuxia.hasMember(it, "getPillID"))
		{
			local pid = it.getPillID();
			if (pid in ::Wuxia.Config.Pills && ("SubLabel" in ::Wuxia.Config.Pills[pid]))
				pSub = ::Wuxia.Config.Pills[pid].SubLabel;
		}

		local res = it.applyToActorWithMessage(bro);
		if (!res.Ok)
			return { ok = false, reason = res.Reason };

		stash.removeByIndex(stashIndex);
		local state = this.onWXGetState(entityId);
		this.WX_attachVanillaSync(state, bro, true, true);
		state.actionMessage <- res.Message;
		state.wxShowcase <- {
			kind        = "consume_pill",
			broName     = bro.getName(),
			pillName    = pName,
			pillIcon    = pIcon,
			effectLabel = pSub,
			message     = res.Message
		};
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
			return { ok = false, reason = "未找到侠客或战团仓库。" };

		local washIdx = -1;
		if (!usePendingChance)
		{
			washIdx = this.WX_findFirstPillIndex(stash, "marrow_wash");
			if (washIdx < 0)
				return { ok = false, reason = "战团仓库中缺少洗髓丹。" };
		}

		local protectIdx = -1;
		if (useProtectPill)
		{
			protectIdx = this.WX_findFirstPillIndex(stash, "wash_protect");
			if (protectIdx < 0)
				return { ok = false, reason = "战团仓库中缺少护脉丹。" };
		}

		local res = ::Wuxia.MarrowWash.execute(bro, targetAttrIdx, replaceAttrIdx, useProtectPill, usePendingChance);
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
		{
			stash.removeByIndex(washIdx);
		}
		else if (protectIdx >= 0)
		{
			stash.removeByIndex(protectIdx);
		}

		local state = this.onWXGetState(entityId);
		this.WX_attachVanillaSync(state, bro, true, true);
		state.washResult <- res;
		state.actionMessage <- res.Message;
		if ("buildWashShowcase" in ::Wuxia.UI)
			state.wxShowcase <- ::Wuxia.UI.buildWashShowcase(bro, res);
		return state;
	};

	// Step 1000-Faces Modular Appearance (`face`, `hair`, `tone`, `beard`, `scar`, `back`, `random`, `random_fem`, `reset_bg`)
	// _data = [entityId, part, dir]
	q.onWXStepAppearance <- function( _data )
	{
		local entityId = _data[0];
		local part     = _data[1];
		local dir      = _data.len() >= 3 ? _data[2] : 1;

		local bro = this.WX_findBrotherById(entityId);
		if (bro == null)
			return { ok = false, reason = "未找到该名侠客。" };

		::Wuxia.Appearance.stepAppearance(bro, part, dir);
		::Wuxia.Armory.syncActorHandheldAndArmor(bro);

		local state = this.onWXGetState(entityId);
		this.WX_attachVanillaSync(state, bro, true, false);
		state.brotherImagePath <- bro.getImagePath();
		return state;
	};

	// Save current 7-slot martial loadout into Preset 0..2 (`_data = [entityId, presetIdx, customLabel]`)
	q.onWXSavePreset <- function( _data )
	{
		if (_data == null || typeof _data != "array" || _data.len() < 2)
			return { ok = false, reason = "参数缺失。" };
		local entityId = _data[0];
		local presetIdx = _data[1];
		local customLbl = _data.len() >= 3 && _data[2] != null ? ("" + _data[2]) : "";
		local bro = this.WX_findBrotherById(entityId);
		if (bro == null)
			return { ok = false, reason = "未找到该名侠客。" };

		local op = ::Wuxia.Slots.saveLoadoutPreset(bro, presetIdx, customLbl);
		if (!op.Ok)
			return { ok = false, reason = op.Reason };

		local state = this.onWXGetState(entityId);
		state.actionMessage <- "已将 " + bro.getName() + " 当前 " + op.SavedCount + " 处穴位功法存入【方案 · " + op.PresetLabel + "】！";
		return state;
	};

	// Apply saved 7-slot martial loadout Preset 0..2 (`_data = [entityId, presetIdx, confirmed]`)
	q.onWXApplyPreset <- function( _data )
	{
		if (_data == null || typeof _data != "array" || _data.len() < 2)
			return { ok = false, reason = "参数缺失。" };
		local entityId  = _data[0];
		local presetIdx = _data[1];
		local confirmed = _data.len() >= 3 ? (_data[2] ? true : false) : false;
		local bro = this.WX_findBrotherById(entityId);
		if (bro == null)
			return { ok = false, reason = "未找到该名侠客。" };

		local res = ::Wuxia.Slots.applyLoadoutPreset(bro, presetIdx, confirmed);
		if (!res.Ok)
		{
			if (("NeedsConfirm" in res) && res.NeedsConfirm)
			{
				return {
					ok           = false,
					needsConfirm = true,
					presetIndex  = res.PresetIndex,
					presetLabel  = res.PresetLabel,
					changedCount = res.ChangedCount,
					penaltyDays  = res.PenaltyDays
				};
			}
			return { ok = false, reason = res.Reason };
		}

		local state = this.onWXGetState(entityId);
		this.WX_attachVanillaSync(state, bro, true, false);
		local scatterNote = res.UsedWangchen
			? "（【归元护脉】生效，本次整套换功零散功虚弱！）"
			: (res.PenaltyDays > 0 ? ("（所有卸下功法重数已完整保留，附带 " + res.PenaltyDays + " 天短暂散功调息）") : "");
		state.actionMessage <- bro.getName() + " 已切换至【方案 · " + res.PresetLabel + "】（调整 " + res.ChangedCount + " 处穴位）！" + scatterNote;
		return state;
	};
});
