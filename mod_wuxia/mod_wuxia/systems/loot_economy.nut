// M3 System: Enemy Wuxia Loadouts, Identical "What You See Is What You Drop" Loot & Town Shop Stocking

::Wuxia.Loot.EnemyLoadouts <- {
	// Tier 1: Bandits / Outcasts (大路货)
	bandit_thug = [
		{ ManualID = "wx_manual_tuna",      Tier = 1, Weight = 40 },
		{ ManualID = "wx_manual_wuhudao",   Tier = 1, Weight = 35 },
		{ ManualID = "wx_manual_jichujian", Tier = 1, Weight = 25 }
	],
	bandit_raider = [
		{ ManualID = "wx_manual_xingqi",    Tier = 1, Weight = 30 },
		{ ManualID = "wx_manual_wuhudao",   Tier = 2, Weight = 30 },
		{ ManualID = "wx_manual_heifeng",   Tier = 1, Weight = 25 },
		{ ManualID = "wx_manual_yingpi",    Tier = 1, Weight = 15 }
	],
	bandit_marksman = [
		{ ManualID = "wx_manual_xiushou",   Tier = 2, Weight = 45 },
		{ ManualID = "wx_manual_jianbu",    Tier = 1, Weight = 30 },
		{ ManualID = "wx_manual_baoyu",     Tier = 1, Weight = 25 }
	],
	// Tier 2: Elites / Sect Swordsmen / Mercenaries (门派上乘)
	mercenary = [
		{ ManualID = "wx_manual_songtao",   Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_weiyuan",   Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_qingfeng",  Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_tiebushan", Tier = 2, Weight = 25 }
	],
	// Tier 3: Leaders / Bosses (绝学 & 孤本残页 + 洗髓丹)
	bandit_leader = [
		{ ManualID = "wx_manual_xuesha",    Tier = 2, Weight = 30 },
		{ ManualID = "wx_manual_duanyue",   Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_tiebushan", Tier = 2, Weight = 20 },
		{ ManualID = "wx_manual_heifeng",   Tier = 3, Weight = 15 }
	],
	swordmaster = [
		{ ManualID = "wx_manual_guiyuan",   Tier = 3, Weight = 25 },
		{ ManualID = "wx_manual_huifeng",   Tier = 3, Weight = 30 },
		{ ManualID = "wx_manual_taxue",     Tier = 3, Weight = 20 },
		{ ManualID = "wx_manual_jinchan",   Tier = 3, Weight = 15 },
		{ ManualID = "wx_manual_tianwai",   Tier = 2, Weight = 10 }
	]
};

::Wuxia.Loot.applyLoadoutToEnemy <- function( _actor, _archetypeKey )
{
	if (_actor == null || !(_archetypeKey in ::Wuxia.Loot.EnemyLoadouts))
		return;

	local loadout = ::Wuxia.Loot.EnemyLoadouts[_archetypeKey];
	local c = ::Wuxia.Slots.getContainer(_actor);
	if (c == null) return;

	_actor.m.WX_LoadoutKey <- _archetypeKey;

	// Assign up to 4 manuals into matching slots directly without scatter penalty
	local usedSlots = {};
	foreach (entry in loadout)
	{
		local def = ::Wuxia.Slots.getManualDef(entry.ManualID);
		if (def == null) continue;

		for (local i = 0; i < ::Wuxia.Config.SlotLayout.len(); i = ++i)
		{
			if (i in usedSlots) continue;
			if (::Wuxia.Slots.isCategoryAllowedInSlot(i, def.Category))
			{
				c.m.Slots[i].ManualID   = entry.ManualID;
				c.m.Slots[i].Tier       = entry.Tier;
				c.m.Slots[i].Exp        = 0;
				c.m.Slots[i].IsFragment = false;
				usedSlots[i] <- true;
				break;
			}
		}
	}

	c.syncGrantedSkills();
	_actor.getSkills().update();
};

::Wuxia.Loot.pickWeightedManual <- function( _loadout )
{
	local totalW = 0;
	foreach (e in _loadout) totalW += e.Weight;
	if (totalW <= 0) return null;

	local roll = ::Math.rand(1, totalW);
	local acc = 0;
	foreach (e in _loadout)
	{
		acc += e.Weight;
		if (roll <= acc) return e.ManualID;
	}
	return _loadout[0].ManualID;
};

::Wuxia.Loot.onEnemyKilledDrop <- function( _actor, _tile )
{
	if (_actor == null || _tile == null) return;
	if (!("WX_LoadoutKey" in _actor.m) || !(_actor.m.WX_LoadoutKey in ::Wuxia.Loot.EnemyLoadouts))
		return;

	local key = _actor.m.WX_LoadoutKey;
	local loadout = ::Wuxia.Loot.EnemyLoadouts[key];
	local isBoss = (key == "bandit_leader" || key == "swordmaster");

	// Drop chance: 24% normal martial enemies, 75% elites/bosses
	local dropChance = isBoss ? 75 : (key == "mercenary" ? 40 : 24);
	if (::Math.rand(1, 100) <= dropChance)
	{
		local manualID = ::Wuxia.Loot.pickWeightedManual(loadout);
		local def = ::Wuxia.Slots.getManualDef(manualID);
		if (def != null)
		{
			if (def.Quality == "common" || (isBoss && ::Math.rand(1, 100) <= 20))
			{
				local mItem = ::new("scripts/items/misc/wx_manual_item");
				mItem.initManual(manualID);
				mItem.drop(_tile);
			}
			else if (def.FragmentsNeeded > 0)
			{
				local pageItem = ::new("scripts/items/misc/wx_page_item");
				pageItem.initPages(manualID, isBoss ? ::Math.rand(1, 2) : 1);
				pageItem.drop(_tile);
			}
		}
	}

	// Boss bonus drop: rare chance for 凝神丸 / 护脉丹 / 洗髓丹
	if (isBoss && ::Math.rand(1, 100) <= 35)
	{
		local pillRoll = ::Math.rand(1, 100);
		local pid = "wx_pill_ningshen";
		if (pillRoll <= 18)      pid = "wx_pill_xisui";
		else if (pillRoll <= 45) pid = "wx_pill_humai";
		else if (pillRoll <= 75) pid = "wx_pill_huxin";

		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill(pid);
		pill.drop(_tile);
	}
};

::Wuxia.Loot.getManualIDsByQuality <- function( _quality )
{
	local list = [];
	foreach (id, def in ::Wuxia.Config.Manuals)
	{
		if (def.Quality == _quality) list.push(id);
	}
	return list;
};

::Wuxia.Loot.injectTownShopStock <- function( _stash )
{
	if (_stash == null) return;

	// Avoid over-stuffing if shop already has Wuxia manuals
	local existingManuals = 0;
	foreach (it in _stash.getItems())
	{
		if (it != null && it.getID() == "misc.wx_manual_item")
			existingManuals += 1;
	}
	if (existingManuals >= 2) return;

	// Stock 2 random common manuals (大路货) for early 12-man slot filling
	local commons = ::Wuxia.Loot.getManualIDsByQuality("common");
	if (commons.len() > 0)
	{
		for (local i = 0; i < 2; i = ++i)
		{
			local mid = commons[::Math.rand(0, commons.len() - 1)];
			local mItem = ::new("scripts/items/misc/wx_manual_item");
			mItem.initManual(mid);
			_stash.add(mItem);
		}
	}

	// Stock core medical & training pills
	local shopPills = ["wx_pill_jinchuang", "wx_pill_huxin"];
	if (::Math.rand(1, 100) <= 50) shopPills.push("wx_pill_ningshen");
	foreach (pid in shopPills)
	{
		local p = ::new("scripts/items/misc/wx_pill_item");
		p.initPill(pid);
		_stash.add(p);
	}
};
