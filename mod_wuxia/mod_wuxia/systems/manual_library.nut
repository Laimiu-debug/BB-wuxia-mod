// Company Martial Manual & Page Vault (藏经阁): Zero-Stash-Slot Storage, Crafting, Teaching & Page Infusion
// Persisted in ::World.Flags so it costs 0 Stash slots, never overflows, and survives all save/load cycles.

if (!("Library" in ::Wuxia))
	::Wuxia.Library <- {};

::Wuxia.Library.Fallback <- {
	AutoStore = true,
	Books     = {},
	Pages     = {}
};

::Wuxia.Library._Cache <- {
	Hydrated = false,
	FlagsRef = null,
	Books    = {},
	Pages    = {},
	Summary  = null
};

::Wuxia.Library.invalidateCache <- function()
{
	::Wuxia.Library._Cache.Hydrated = false;
	::Wuxia.Library._Cache.FlagsRef = null;
	::Wuxia.Library._Cache.Books    = {};
	::Wuxia.Library._Cache.Pages    = {};
	::Wuxia.Library._Cache.Summary  = null;
};

::Wuxia.Library.resetFallback <- function()
{
	::Wuxia.Library.Fallback.AutoStore = true;
	::Wuxia.Library.Fallback.Books = {};
	::Wuxia.Library.Fallback.Pages = {};
	::Wuxia.Library.invalidateCache();
};

::Wuxia.Library.hasWorldFlags <- function()
{
	return ("World" in getroottable()) && ::World != null && ("Flags" in ::World) && ::World.Flags != null;
};

::Wuxia.Library._ensureCache <- function()
{
	if (!::Wuxia.Library.hasWorldFlags())
		return null;
	local curFlags = ::World.Flags;
	local cache = ::Wuxia.Library._Cache;
	if (cache.Hydrated && cache.FlagsRef == curFlags)
		return cache;

	local books = {};
	local pages = {};
	foreach (mid, _def in ::Wuxia.Config.Manuals)
	{
		local bk = "wx_lib_b_" + mid;
		if (curFlags.has(bk))
		{
			local bv = ::Math.max(0, curFlags.getAsInt(bk));
			if (bv > 0) books[mid] <- bv;
		}
		local pk = "wx_lib_p_" + mid;
		if (curFlags.has(pk))
		{
			local pv = ::Math.max(0, curFlags.getAsInt(pk));
			if (pv > 0) pages[mid] <- pv;
		}
	}
	cache.FlagsRef = curFlags;
	cache.Books    = books;
	cache.Pages    = pages;
	cache.Summary  = null;
	cache.Hydrated = true;
	return cache;
};

::Wuxia.Library.getOwnedMaps <- function()
{
	local cache = ::Wuxia.Library._ensureCache();
	if (cache != null)
		return { Books = cache.Books, Pages = cache.Pages };
	return { Books = ::Wuxia.Library.Fallback.Books, Pages = ::Wuxia.Library.Fallback.Pages };
};

::Wuxia.Library.bookKey <- function( _manualID )
{
	return "wx_lib_b_" + _manualID;
};

::Wuxia.Library.pageKey <- function( _manualID )
{
	return "wx_lib_p_" + _manualID;
};

::Wuxia.Library.isAutoStoreEnabled <- function()
{
	if (::Wuxia.Library.hasWorldFlags())
	{
		if (!::World.Flags.has("wx_lib_autostore"))
			return true;
		return ::World.Flags.get("wx_lib_autostore") ? true : false;
	}
	return ::Wuxia.Library.Fallback.AutoStore;
};

::Wuxia.Library.setAutoStoreEnabled <- function( _enabled )
{
	local v = _enabled ? true : false;
	if (::Wuxia.Library.hasWorldFlags())
	{
		::World.Flags.set("wx_lib_autostore", v);
	}
	else
	{
		::Wuxia.Library.Fallback.AutoStore = v;
	}
	return v;
};

::Wuxia.Library.getManualCount <- function( _manualID )
{
	if (_manualID == null || _manualID == "") return 0;
	local cache = ::Wuxia.Library._ensureCache();
	if (cache != null)
		return (_manualID in cache.Books) ? cache.Books[_manualID] : 0;
	if (_manualID in ::Wuxia.Library.Fallback.Books)
		return ::Math.max(0, ::Wuxia.Library.Fallback.Books[_manualID]);
	return 0;
};

::Wuxia.Library.setManualCount <- function( _manualID, _count )
{
	if (_manualID == null || _manualID == "") return 0;
	local next = ::Math.max(0, _count);
	local cache = ::Wuxia.Library._ensureCache();
	if (cache != null)
	{
		local k = ::Wuxia.Library.bookKey(_manualID);
		if (next > 0 || ::World.Flags.has(k))
			::World.Flags.set(k, next);
		if (next > 0) cache.Books[_manualID] <- next;
		else if (_manualID in cache.Books) delete cache.Books[_manualID];
		cache.Summary = null;
	}
	else
	{
		if (next > 0) ::Wuxia.Library.Fallback.Books[_manualID] <- next;
		else if (_manualID in ::Wuxia.Library.Fallback.Books) delete ::Wuxia.Library.Fallback.Books[_manualID];
		::Wuxia.Library._Cache.Summary = null;
	}
	return next;
};

::Wuxia.Library.addManual <- function( _manualID, _delta = 1 )
{
	if (_manualID == null || !(_manualID in ::Wuxia.Config.Manuals)) return 0;
	local cur = ::Wuxia.Library.getManualCount(_manualID);
	return ::Wuxia.Library.setManualCount(_manualID, cur + _delta);
};

::Wuxia.Library.getPageCount <- function( _manualID )
{
	if (_manualID == null || _manualID == "") return 0;
	local cache = ::Wuxia.Library._ensureCache();
	if (cache != null)
		return (_manualID in cache.Pages) ? cache.Pages[_manualID] : 0;
	if (_manualID in ::Wuxia.Library.Fallback.Pages)
		return ::Math.max(0, ::Wuxia.Library.Fallback.Pages[_manualID]);
	return 0;
};

::Wuxia.Library.setPageCount <- function( _manualID, _count )
{
	if (_manualID == null || _manualID == "") return 0;
	local next = ::Math.max(0, _count);
	local cache = ::Wuxia.Library._ensureCache();
	if (cache != null)
	{
		local k = ::Wuxia.Library.pageKey(_manualID);
		if (next > 0 || ::World.Flags.has(k))
			::World.Flags.set(k, next);
		if (next > 0) cache.Pages[_manualID] <- next;
		else if (_manualID in cache.Pages) delete cache.Pages[_manualID];
		cache.Summary = null;
	}
	else
	{
		if (next > 0) ::Wuxia.Library.Fallback.Pages[_manualID] <- next;
		else if (_manualID in ::Wuxia.Library.Fallback.Pages) delete ::Wuxia.Library.Fallback.Pages[_manualID];
		::Wuxia.Library._Cache.Summary = null;
	}
	return next;
};

::Wuxia.Library.addPages <- function( _manualID, _delta = 1 )
{
	if (_manualID == null || !(_manualID in ::Wuxia.Config.Manuals)) return 0;
	local cur = ::Wuxia.Library.getPageCount(_manualID);
	return ::Wuxia.Library.setPageCount(_manualID, cur + _delta);
};

::Wuxia.Library.getSummaryCounts <- function()
{
	local cache = ::Wuxia.Library._ensureCache();
	if (cache != null && cache.Summary != null)
		return cache.Summary;

	local maps = ::Wuxia.Library.getOwnedMaps();
	local distinctManuals = 0;
	local totalManuals    = 0;
	local distinctPages   = 0;
	local totalPages      = 0;
	local craftableCount  = 0;

	foreach (mid, b in maps.Books)
	{
		if (b > 0 && (mid in ::Wuxia.Config.Manuals))
		{
			distinctManuals += 1;
			totalManuals += b;
		}
	}
	foreach (pmid, p in maps.Pages)
	{
		if (p > 0 && (pmid in ::Wuxia.Config.Manuals))
		{
			local def = ::Wuxia.Config.Manuals[pmid];
			distinctPages += 1;
			totalPages += p;
			if (def.FragmentsNeeded > 0 && p >= def.FragmentsNeeded)
				craftableCount += ::Math.floor(p / def.FragmentsNeeded);
		}
	}

	local res = {
		distinctManuals = distinctManuals,
		totalManuals    = totalManuals,
		distinctPages   = distinctPages,
		totalPages      = totalPages,
		craftableCount  = craftableCount
	};
	if (cache != null) cache.Summary = res;
	return res;
};

// Live ownership & roster learning summary for shop badges, sect directory & item tooltips
::Wuxia.Library.getOwnershipSummary <- function( _manualID )
{
	local def = ::Wuxia.Slots.getManualDef(_manualID);
	local bookCount = ::Wuxia.Library.getManualCount(_manualID);
	local pageCount = ::Wuxia.Library.getPageCount(_manualID);
	local fragmentsNeeded = (def != null && "FragmentsNeeded" in def) ? def.FragmentsNeeded : 0;
	local learnedCount = 0;
	local fragmentCount = 0;

	if (_manualID != null && ("World" in getroottable()) && ::World != null && ("getPlayerRoster" in ::World) && ::World.getPlayerRoster() != null)
	{
		foreach (rb in ::World.getPlayerRoster().getAll())
		{
			if (rb == null || !rb.isAlive()) continue;
			local rc = ::Wuxia.Slots.getContainer(rb);
			if (rc == null) continue;
			rc.ensureSlotsRegisteredInLearned();
			local entry = rc.getLearnedEntry(_manualID);
			if (entry != null)
			{
				if (entry.IsFragment) fragmentCount += 1;
				else learnedCount += 1;
			}
		}
	}

	return {
		bookCount       = bookCount,
		pageCount       = pageCount,
		fragmentsNeeded = fragmentsNeeded,
		learnedCount    = learnedCount,
		fragmentCount   = fragmentCount
	};
};

::Wuxia.Library.countMovableInStash <- function( _stash, _includeWithdrawn = true )
{
	local books = 0;
	local pages = 0;
	local slots = 0;
	if (_stash == null) return { books = 0, pages = 0, slots = 0 };

	local items = _stash.getItems();
	for (local i = 0; i < items.len(); i = ++i)
	{
		local it = items[i];
		if (it == null) continue;
		if (!_includeWithdrawn && ("WX_WithdrawnForSale" in it.m) && it.m.WX_WithdrawnForSale)
			continue;

		local id = it.getID();
		if (id == "misc.wx_manual_item")
		{
			books += 1;
			slots += 1;
		}
		else if (id == "misc.wx_page_item")
		{
			pages += it.getPageCount();
			slots += 1;
		}
	}
	return { books = books, pages = pages, slots = slots };
};

// Sweep manuals & pages from Stash into Library (freeing Stash slots immediately)
::Wuxia.Library.storeAllFromStash <- function( _stash, _includeWithdrawn = true )
{
	local booksMoved   = 0;
	local pagesMoved   = 0;
	local slotsCleared = 0;
	if (_stash == null)
		return { booksMoved = 0, pagesMoved = 0, slotsCleared = 0 };

	local items = _stash.getItems();
	for (local i = items.len() - 1; i >= 0; i = --i)
	{
		local it = items[i];
		if (it == null) continue;
		if (!_includeWithdrawn && ("WX_WithdrawnForSale" in it.m) && it.m.WX_WithdrawnForSale)
			continue;

		local id = it.getID();
		if (id == "misc.wx_manual_item")
		{
			local mid = it.getManualID();
			if (mid in ::Wuxia.Config.Manuals)
			{
				::Wuxia.Library.addManual(mid, 1);
				_stash.removeByIndex(i);
				booksMoved += 1;
				slotsCleared += 1;
			}
		}
		else if (id == "misc.wx_page_item")
		{
			local midP = it.getManualID();
			local cnt = ::Math.max(1, it.getPageCount());
			if (midP in ::Wuxia.Config.Manuals)
			{
				::Wuxia.Library.addPages(midP, cnt);
				_stash.removeByIndex(i);
				pagesMoved += cnt;
				slotsCleared += 1;
			}
		}
	}

	return {
		booksMoved   = booksMoved,
		pagesMoved   = pagesMoved,
		slotsCleared = slotsCleared
	};
};

// Withdraw 1 manual from Library to Stash (marked WX_WithdrawnForSale so Auto-Store leaves it in Stash for town selling)
::Wuxia.Library.withdrawManualToStash <- function( _stash, _manualID )
{
	if (_stash == null)
		return { Ok = false, Reason = "无法访问战团仓库。" };
	local def = ::Wuxia.Slots.getManualDef(_manualID);
	if (def == null)
		return { Ok = false, Reason = "未知武学秘籍。" };
	if (::Wuxia.Library.getManualCount(_manualID) <= 0)
		return { Ok = false, Reason = "藏经阁中已无《" + def.Name + "》存本。" };

	local item = ::new("scripts/items/misc/wx_manual_item");
	item.initManual(_manualID);
	item.m.WX_WithdrawnForSale = true;

	if (_stash.add(item) == null)
		return { Ok = false, Reason = "战团仓库已满，请先腾出一格空位。" };

	::Wuxia.Library.addManual(_manualID, -1);
	return {
		Ok         = true,
		ManualName = def.Name
	};
};

// Withdraw 1 stack of pages (up to FragmentsNeeded) from Library to Stash for selling
::Wuxia.Library.withdrawPagesToStash <- function( _stash, _manualID )
{
	if (_stash == null)
		return { Ok = false, Reason = "无法访问战团仓库。" };
	local def = ::Wuxia.Slots.getManualDef(_manualID);
	if (def == null)
		return { Ok = false, Reason = "未知武学残页。" };
	local cur = ::Wuxia.Library.getPageCount(_manualID);
	if (cur <= 0)
		return { Ok = false, Reason = "藏经阁中已无《" + def.Name + "》残页。" };

	local batch = def.FragmentsNeeded > 0 ? ::Math.min(cur, def.FragmentsNeeded) : cur;
	local item = ::new("scripts/items/misc/wx_page_item");
	item.initPages(_manualID, batch);
	item.m.WX_WithdrawnForSale = true;

	if (_stash.add(item) == null)
		return { Ok = false, Reason = "战团仓库已满，请先腾出一格空位。" };

	::Wuxia.Library.addPages(_manualID, -batch);
	return {
		Ok         = true,
		ManualName = def.Name,
		Count      = batch
	};
};

// Collect candidate spare pages in Library of the same Quality (orphan incomplete stacks prioritized first!)
::Wuxia.Library.collectSparePages <- function( _targetManualID, _quality )
{
	local list = [];
	foreach (mid, odef in ::Wuxia.Config.Manuals)
	{
		if (mid == _targetManualID || odef.Quality != _quality) continue;
		local cnt = ::Wuxia.Library.getPageCount(mid);
		if (cnt <= 0) continue;
		local isCraftable = (odef.FragmentsNeeded > 0 && cnt >= odef.FragmentsNeeded);
		list.push({
			manualID    = mid,
			count       = cnt,
			name        = odef.Name,
			isCraftable = isCraftable
		});
	}
	list.sort(function( a, b ) {
		if (a.isCraftable != b.isCraftable) return a.isCraftable ? 1 : -1;
		if (a.count != b.count) return a.count < b.count ? -1 : 1;
		return a.name <=> b.name;
	});
	return list;
};

::Wuxia.Library.previewWildcardCraft <- function( _manualID )
{
	local def = ::Wuxia.Slots.getManualDef(_manualID);
	if (def == null || def.FragmentsNeeded <= 0)
		return { ok = false, reason = "此功法不可由残页拼合。" };

	local totalOwn = ::Wuxia.Library.getPageCount(_manualID);
	if (totalOwn <= 0)
		return { ok = false, reason = "至少需在藏经阁持有 1 张本篇残页方可融会补缺。" };
	if (totalOwn >= def.FragmentsNeeded)
		return { ok = true, needsWildcard = false, manualID = _manualID, manualName = def.Name };

	local missingOwn = def.FragmentsNeeded - totalOwn;
	local spareNeeded = missingOwn * 2;
	local spares = ::Wuxia.Library.collectSparePages(_manualID, def.Quality);
	local availSpare = 0;
	foreach (sp in spares) availSpare += sp.count;

	if (availSpare < spareNeeded)
	{
		return {
			ok     = false,
			reason = "藏经阁同品阶闲置残页不足（尚缺 " + missingOwn + " 张本篇残页，需 " + spareNeeded + " 张同阶残页按 2:1 补缺，当前仅有 " + availSpare + " 张）。"
		};
	}

	local rem = spareNeeded;
	local sacrificedList = [];
	foreach (sp in spares)
	{
		if (rem <= 0) break;
		local take = ::Math.min(rem, sp.count);
		sacrificedList.push("《" + sp.name + "》残页 ×" + take);
		rem -= take;
	}

	return {
		ok              = true,
		needsWildcard   = true,
		manualID        = _manualID,
		manualName      = def.Name,
		qualityLabel    = (def.Quality in ::Wuxia.Text.Qualities) ? ::Wuxia.Text.Qualities[def.Quality] : def.Quality,
		ownPages        = totalOwn,
		fragmentsNeeded = def.FragmentsNeeded,
		missingPages    = missingOwn,
		spareNeeded     = spareNeeded,
		sacrificedList  = sacrificedList
	};
};

// Craft 1 manual inside Library from exact pages or 2:1 wildcard pages (0 Stash slots needed!)
::Wuxia.Library.craftManual <- function( _manualID, _allowWildcard = false )
{
	local def = ::Wuxia.Slots.getManualDef(_manualID);
	if (def == null || def.FragmentsNeeded <= 0)
		return { Ok = false, Reason = "此功法不可由残页拼合。" };

	local totalOwn = ::Wuxia.Library.getPageCount(_manualID);
	if (totalOwn >= def.FragmentsNeeded)
	{
		::Wuxia.Library.addPages(_manualID, -def.FragmentsNeeded);
		::Wuxia.Library.addManual(_manualID, 1);
		return {
			Ok              = true,
			ManualName      = def.Name,
			UsedWildcard    = false,
			SacrificedCount = 0
		};
	}

	if (!_allowWildcard)
		return { Ok = false, Reason = "残页不足（当前 " + totalOwn + " / " + def.FragmentsNeeded + "）。" };
	if (totalOwn <= 0)
		return { Ok = false, Reason = "至少需持有 1 张本篇残页方可进行补缺拼合。" };

	local missingOwn = def.FragmentsNeeded - totalOwn;
	local spareNeeded = missingOwn * 2;
	local spares = ::Wuxia.Library.collectSparePages(_manualID, def.Quality);
	local availSpare = 0;
	foreach (sp in spares) availSpare += sp.count;
	if (availSpare < spareNeeded)
		return { Ok = false, Reason = "同品阶闲置残页不足（差 " + missingOwn + " 张本篇残页，需 " + spareNeeded + " 张同品阶残页补缺）。" };

	::Wuxia.Library.setPageCount(_manualID, 0);
	local rem = spareNeeded;
	foreach (sp in spares)
	{
		if (rem <= 0) break;
		local take = ::Math.min(rem, sp.count);
		::Wuxia.Library.addPages(sp.manualID, -take);
		rem -= take;
	}
	::Wuxia.Library.addManual(_manualID, 1);

	return {
		Ok              = true,
		ManualName      = def.Name,
		UsedWildcard    = true,
		SacrificedCount = spareNeeded
	};
};

// One-click craft ALL exact-complete page stacks in Library into whole manuals
::Wuxia.Library.craftAllExact <- function()
{
	local booksCrafted = 0;
	local pagesSpent   = 0;
	local names        = [];

	local pageSnap = clone ::Wuxia.Library.getOwnedMaps().Pages;
	foreach (mid, cur in pageSnap)
	{
		if (cur <= 0 || !(mid in ::Wuxia.Config.Manuals)) continue;
		local def = ::Wuxia.Config.Manuals[mid];
		if (def.FragmentsNeeded <= 0) continue;
		if (cur >= def.FragmentsNeeded)
		{
			local num = ::Math.floor(cur / def.FragmentsNeeded);
			local cost = num * def.FragmentsNeeded;
			::Wuxia.Library.addPages(mid, -cost);
			::Wuxia.Library.addManual(mid, num);
			booksCrafted += num;
			pagesSpent += cost;
			names.push("《" + def.Name + "》" + (num > 1 ? ("×" + num) : ""));
		}
	}

	return {
		booksCrafted = booksCrafted,
		pagesSpent   = pagesSpent,
		names        = names
	};
};

// Consume 1 manual (or 1 page for fragment learn) from Library to teach _actor permanently
::Wuxia.Library.learnFromLibrary <- function( _actor, _manualID, _isFragment = false )
{
	local def = ::Wuxia.Slots.getManualDef(_manualID);
	if (def == null)
		return { Ok = false, Reason = "未知武学秘籍。" };

	if (!_isFragment)
	{
		if (::Wuxia.Library.getManualCount(_manualID) <= 0)
			return { Ok = false, Reason = "藏经阁中暂无《" + def.Name + "》完整秘籍。" };
	}
	else
	{
		if (::Wuxia.Library.getPageCount(_manualID) <= 0)
			return { Ok = false, Reason = "藏经阁中暂无《" + def.Name + "》残页。" };
	}

	local res = ::Wuxia.Slots.learnManual(_actor, _manualID, _isFragment);
	if (!res.Ok) return res;

	if (!_isFragment)
		::Wuxia.Library.addManual(_manualID, -1);
	else
		::Wuxia.Library.addPages(_manualID, -1);

	return res;
};

// Infuse 1 page from Library into _actor's equipped slot (参悟化功)
::Wuxia.Library.infuseSlotWithPage <- function( _actor, _slotIndex, _pageManualID )
{
	local def = ::Wuxia.Slots.getManualDef(_pageManualID);
	if (def == null)
		return { Ok = false, Reason = "未知武学残页。" };
	if (::Wuxia.Library.getPageCount(_pageManualID) <= 0)
		return { Ok = false, Reason = "藏经阁中已无《" + def.Name + "》残页。" };

	local res = ::Wuxia.Mastery.infuseWithPage(_actor, _slotIndex, _pageManualID);
	if (!res.Ok) return res;

	::Wuxia.Library.addPages(_pageManualID, -1);
	return res;
};

if ("HooksMod" in ::Wuxia && ::Wuxia.HooksMod != null)
{
	::Wuxia.HooksMod.hook("scripts/states/world_state", function( q )
	{
		if ("startNewCampaign" in q)
		{
			q.startNewCampaign = @(__original) function()
			{
				::Wuxia.Library.invalidateCache();
				__original();
				::Wuxia.Library.invalidateCache();
			};
		}
		if ("loadCampaign" in q)
		{
			q.loadCampaign = @(__original) function( _file )
			{
				::Wuxia.Library.invalidateCache();
				__original(_file);
				::Wuxia.Library.invalidateCache();
			};
		}
	});
}
