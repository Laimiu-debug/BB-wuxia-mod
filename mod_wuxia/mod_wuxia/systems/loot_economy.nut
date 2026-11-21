// M3 System: Enemy Wuxia Loadouts, Identical "What You See Is What You Drop" Loot & Town Shop Stocking

::Wuxia.Loot.EnemyLoadouts <- {
	// Tier 1: Bandits / Outcasts (大路货 — strictly low drop rates on trash mobs)
	bandit_thug = { Script = "scripts/entity/tactical/enemies/bandit_thug", DropChance = 6, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_tuna",      Tier = 1, Weight = 40 },
		{ ManualID = "wx_manual_wuhudao",   Tier = 1, Weight = 35 },
		{ ManualID = "wx_manual_jichujian", Tier = 1, Weight = 25 }
	] },
	bandit_raider = { Script = "scripts/entity/tactical/enemies/bandit_raider", DropChance = 9, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_xingqi",    Tier = 1, Weight = 30 },
		{ ManualID = "wx_manual_wuhudao",   Tier = 2, Weight = 30 },
		{ ManualID = "wx_manual_heifeng",   Tier = 1, Weight = 25 },
		{ ManualID = "wx_manual_yingpi",    Tier = 1, Weight = 15 }
	] },
	bandit_marksman = { Script = "scripts/entity/tactical/enemies/bandit_marksman", DropChance = 9, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_xiushou",   Tier = 2, Weight = 45 },
		{ ManualID = "wx_manual_jianbu",    Tier = 1, Weight = 30 },
		{ ManualID = "wx_manual_baoyu",     Tier = 1, Weight = 25 },
		{ ManualID = "wx_manual_yanxing",   Tier = 2, Weight = 30 }
	] },
	// Tier 2: Elites / Sect Swordsmen / Mercenaries (门派上乘残页)
	mercenary = { Script = "scripts/entity/tactical/humans/mercenary", DropChance = 18, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_songtao",   Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_weiyuan",   Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_qingfeng",  Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_tiebushan", Tier = 2, Weight = 25 }
	] },
	// Tier 3: Leaders / Bosses (上乘/绝学残页为主)
	bandit_leader = { Script = "scripts/entity/tactical/enemies/bandit_leader", DropChance = 38, IsBoss = true, CustomBust = "wx_enemy_bandit_lord", Manuals = [
		{ ManualID = "wx_manual_xuesha",    Tier = 2, Weight = 30 },
		{ ManualID = "wx_manual_duanyue",   Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_tiebushan", Tier = 2, Weight = 20 },
		{ ManualID = "wx_manual_heifeng",   Tier = 3, Weight = 15 }
	] },
	swordmaster = { Script = "scripts/entity/tactical/humans/swordmaster", DropChance = 52, IsBoss = true, IsGrandmaster = true, CustomBust = "wx_enemy_sword_saint", Manuals = [
		{ ManualID = "wx_manual_guiyuan",   Tier = 3, Weight = 25 },
		{ ManualID = "wx_manual_huifeng",   Tier = 3, Weight = 30 },
		{ ManualID = "wx_manual_taxue",     Tier = 3, Weight = 20 },
		{ ManualID = "wx_manual_jinchan",   Tier = 3, Weight = 15 },
		{ ManualID = "wx_manual_tianwai",   Tier = 2, Weight = 10 }
	] },

	// M4.2 Ecology Expansion: 塞外马贼 (Nomads)
	nomad_outlaw = { Troop = "NomadOutlaw", DropChance = 10, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_hanhai_wandao_ru", Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_liusha_bu",        Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_liesha_tuna",      Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_chanzi",           Tier = 2, Weight = 25 }
	] },
	nomad_leader = { Troop = "NomadLeader", DropChance = 38, IsBoss = true, CustomBust = "wx_enemy_nomad_khan", Manuals = [
		{ ManualID = "wx_manual_hanhai_xinyue",    Tier = 3, Weight = 30 },
		{ ManualID = "wx_manual_mingzun_huo",      Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_hanhai_guke",      Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_hanhai_shishen",   Tier = 2, Weight = 20 }
	] },
	southern_assassin = { Troop = "Assassin", DropChance = 50, IsBoss = true, IsGrandmaster = true, CustomBust = "wx_enemy_blade_dancer", Manuals = [
		{ ManualID = "wx_manual_youming_bi",       Tier = 3, Weight = 30 },
		{ ManualID = "wx_manual_youming_guibu",    Tier = 3, Weight = 25 },
		{ ManualID = "wx_manual_yinsha_guixi",     Tier = 3, Weight = 25 },
		{ ManualID = "wx_manual_mingzun_shenghuoling", Tier = 3, Weight = 20 }
	] },

	// M4.2 Ecology Expansion: 地方藩镇与军镇高手 (Noble Military & City-State Elites)
	sergeant = { Troop = "Sergeant", DropChance = 18, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_juyiling",         Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_baima_zhenshu",    Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_luoyang_changfeng", Tier = 2, Weight = 30 }
	] },
	knight = { Troop = "Knight", DropChance = 42, IsBoss = true, CustomBust = "wx_enemy_garrison_capt", Manuals = [
		{ ManualID = "wx_manual_hengshan_tiebi",   Tier = 3, Weight = 30 },
		{ ManualID = "wx_manual_yanmen_zhenjun",   Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_cuijia_liuhua",    Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_shaolin_jinzhong", Tier = 2, Weight = 20 }
	] },
	officer = { Troop = "Officer", DropChance = 38, IsBoss = true, CustomBust = "wx_enemy_shenji_officer", Manuals = [
		{ ManualID = "wx_manual_huaiyang_jindao",  Tier = 3, Weight = 30 },
		{ ManualID = "wx_manual_shazhou_leihuo_chong", Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_wuwei_shuaiqi",    Tier = 2, Weight = 20 },
		{ ManualID = "wx_manual_gufeng",           Tier = 2, Weight = 25 }
	] },
	gladiator = { Troop = "Gladiator", DropChance = 20, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_qianjiang_nuchao_zhang", Tier = 2, Weight = 30 },
		{ ManualID = "wx_manual_shuofang_jingua",  Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_lingnan_tengdun",  Tier = 2, Weight = 25 },
		{ ManualID = "wx_manual_jinchan",          Tier = 2, Weight = 20 }
	] },

	// M4.2 Ecology Expansion: 关外铁骑战帮 (Barbarians)
	barbarian_marauder = { Troop = "BarbarianMarauder", DropChance = 10, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_heishui_xue",      Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_heishui_kuangfu",  Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_xueyuan_zong",     Tier = 2, Weight = 30 }
	] },
	barbarian_chosen = { Troop = "BarbarianChampion", DropChance = 42, IsBoss = true, CustomBust = "wx_enemy_barb_chosen", Manuals = [
		{ ManualID = "wx_manual_heishui_xueming_fu", Tier = 3, Weight = 35 },
		{ ManualID = "wx_manual_pishan_kaitian",   Tier = 2, Weight = 30 },
		{ ManualID = "wx_manual_zhenyue_qianjun",  Tier = 2, Weight = 35 }
	] },

	// M4.2 Ecology Expansion: 五毒奇门伏兵 (Goblins)
	goblin_ambusher = { Troop = "GoblinAmbusher", DropChance = 10, IsBoss = false, CustomBust = "wx_enemy_wudu_blowgun", Manuals = [
		{ ManualID = "wx_manual_wudu_chuijian",    Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_wudu_shehang",     Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_wudu",             Tier = 2, Weight = 30 }
	] },
	goblin_overseer = { Troop = "GoblinOverseer", DropChance = 40, IsBoss = true, CustomBust = "wx_enemy_wudu_overseer", Manuals = [
		{ ManualID = "wx_manual_wudu_wanxian",     Tier = 3, Weight = 35 },
		{ ManualID = "wx_manual_tangmen_guanyin_lei", Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_wudu_jinshe_bian", Tier = 2, Weight = 30 }
	] },

	// M4.2 Ecology Expansion: 邪派炼体药人 (Orcs)
	orc_berserker = { Troop = "OrcBerserker", DropChance = 14, IsBoss = false, CustomBust = "wx_enemy_bronze_yaoren", Manuals = [
		{ ManualID = "wx_manual_xuesha",    Tier = 2, Weight = 50 },
		{ ManualID = "wx_manual_duanyue",   Tier = 2, Weight = 50 }
	] },
	orc_warrior = { Troop = "OrcWarrior", DropChance = 16, IsBoss = false, Manuals = [
		{ ManualID = "wx_manual_tiebushan", Tier = 3, Weight = 60 },
		{ ManualID = "wx_manual_jinzhong",  Tier = 2, Weight = 40 }
	] },
	orc_warlord = { Troop = "OrcWarlord", DropChance = 52, IsBoss = true, IsGrandmaster = true, CustomBust = "wx_enemy_yaoren_lord", Manuals = [
		{ ManualID = "wx_manual_jinzhong",  Tier = 3, Weight = 45 },
		{ ManualID = "wx_manual_xuesha",    Tier = 3, Weight = 30 },
		{ ManualID = "wx_manual_duanyue",   Tier = 3, Weight = 25 }
	] },

	// M4.2 Ecology Expansion: 前朝古墓与湘西尸傀邪宗 (Undead & Ancient Dead Elites)
	skeleton_heavy = { Troop = "SkeletonHeavy", DropChance = 15, IsBoss = false, CustomBust = "wx_enemy_tomb_automaton", Manuals = [
		{ ManualID = "wx_manual_tiebushan", Tier = 3, Weight = 55 },
		{ ManualID = "wx_manual_weiyuan",   Tier = 3, Weight = 45 }
	] },
	necromancer = { Troop = "Necromancer", DropChance = 42, IsBoss = true, CustomBust = "wx_enemy_corpse_taoist", Manuals = [
		{ ManualID = "wx_manual_zhenhun",   Tier = 2, Weight = 35 },
		{ ManualID = "wx_manual_xuesha",    Tier = 2, Weight = 40 },
		{ ManualID = "wx_manual_wudu",      Tier = 3, Weight = 25 }
	] },
	vampire = { Troop = "Vampire", DropChance = 38, IsBoss = true, CustomBust = "wx_enemy_blood_vampire", Manuals = [
		{ ManualID = "wx_manual_suodi",     Tier = 3, Weight = 40 },
		{ ManualID = "wx_manual_heifeng",   Tier = 3, Weight = 35 },
		{ ManualID = "wx_manual_zhenhun",   Tier = 2, Weight = 25 }
	] }
};

::Wuxia.Loot.resolveEnemyScript <- function( _profile )
{
	if ("Script" in _profile && _profile.Script != null && _profile.Script != "")
		return _profile.Script;
	if ("Troop" in _profile && (_profile.Troop in ::Const.World.Spawn.Troops))
		return ::Const.World.Spawn.Troops[_profile.Troop].Script;
	return null;
};

::Wuxia.Loot.applyLoadoutToEnemy <- function( _actor, _archetypeKey )
{
	if (_actor == null) return;
	local profiles = _archetypeKey in ::Wuxia.Config.Fighters ? ::Wuxia.Config.Fighters : ::Wuxia.Loot.EnemyLoadouts;
	if (!(_archetypeKey in profiles)) return;
	local loadout = profiles[_archetypeKey].Manuals;
	local c = ::Wuxia.Slots.getContainer(_actor);
	if (c == null) return;

	_actor.m.WX_LoadoutKey <- _archetypeKey;

	// Enemy tiers are fixed by archetype. Keep the same category rules as player slots.
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

::Wuxia.Loot.getEquippedDropPool <- function( _actor, _profile )
{
	local pool = [];
	local c = _actor.getSkills().getSkillByID("special.wx_martial_container");
	if (c == null) return pool;
	local equipped = {};
	foreach (slot in c.m.Slots)
		if (slot.ManualID != null && slot.Tier > 0) equipped[slot.ManualID] <- true;
	foreach (entry in _profile.Manuals)
		if (entry.ManualID in equipped) pool.push(entry);
	return pool;
};

::Wuxia.Loot.onEnemyKilledDrop <- function( _tile, _profile, _pool )
{
	local isBoss = _profile.IsBoss;
	local isGrandmaster = ("IsGrandmaster" in _profile) && _profile.IsGrandmaster;

	// Strictly gated drop rates: common street manuals or single torn pages (`wx_page_item`)
	if (_pool.len() > 0 && ::Math.rand(1, 100) <= _profile.DropChance)
	{
		local manualID = ::Wuxia.Loot.pickWeightedManual(_pool);
		local def = ::Wuxia.Slots.getManualDef(manualID);
		if (def != null)
		{
			if (def.Quality == "common" || (isGrandmaster && ::Math.rand(1, 100) <= 8))
			{
				local mItem = ::new("scripts/items/misc/wx_manual_item");
				mItem.initManual(manualID);
				mItem.drop(_tile);
			}
			else if (def.FragmentsNeeded > 0)
			{
				local pageItem = ::new("scripts/items/misc/wx_page_item");
				pageItem.initPages(manualID, 1);
				pageItem.drop(_tile);
			}
		}
	}

	// Boss bonus drop: basic healing/qi pills only (`洗髓丹` is strictly reserved for Boss-herb Alchemy!)
	if (isBoss && ::Math.rand(1, 100) <= (isGrandmaster ? 24 : 15))
	{
		local pillRoll = ::Math.rand(1, 100);
		local pid = "wx_pill_jinchuang";
		if (isGrandmaster && pillRoll <= 20) pid = "wx_pill_humai";
		else if (pillRoll <= 55)             pid = "wx_pill_ningshen";
		else if (pillRoll <= 85)             pid = "wx_pill_huxin";

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

// Random events are scored on the moving world map, including the approach to a town.
::Wuxia.Loot.isNearMarketTown <- function()
{
	local player = ::World.State.getPlayer();
	if (player == null) return false;
	local tile = player.getTile();
	foreach (town in ::World.EntityManager.getSettlements())
		if (town.isAlliedWithPlayer() && town.getTile().getDistanceTo(tile) <= 2) return true;
	return false;
};

::Wuxia.Loot.purchaseEventItem <- function( _item, _price, _successScreen )
{
	if (::World.Assets.getMoney() < _price) return "NoMoney";
	if (_item != null && ::Wuxia.Library.isAutoStoreEnabled())
	{
		local id = _item.getID();
		if (id == "misc.wx_manual_item")
		{
			::Wuxia.Library.addManual(_item.getManualID(), 1);
			::World.Assets.addMoney(-_price);
			return _successScreen;
		}
		else if (id == "misc.wx_page_item")
		{
			::Wuxia.Library.addPages(_item.getManualID(), _item.getPageCount());
			::World.Assets.addMoney(-_price);
			return _successScreen;
		}
	}
	if (::World.Assets.getStash().add(_item) == null) return "NoRoom";
	::World.Assets.addMoney(-_price);
	return _successScreen;
};

::Wuxia.Loot.makeNoRoomScreen <- function()
{
	return {
		ID = "NoRoom", Text = "行囊已满，放不下这件货物。你收起银两，辞别了对方。",
		Image = "", List = [], Characters = [],
		Options = [{ Text = "改日再来。", function getResult( _event ) { return 0; } }],
		function start( _event ) {}
	};
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

	// Stock up to 2 random common manuals (大路货) from the street/folk manual pool
	local commons = ::Wuxia.Loot.getManualIDsByQuality("common");
	if (commons.len() > 0)
	{
		for (local i = existingManuals; i < 2; i = ++i)
		{
			local mid = commons[::Math.rand(0, commons.len() - 1)];
			local mItem = ::new("scripts/items/misc/wx_manual_item");
			mItem.initManual(mid);
			_stash.add(mItem);
		}
	}

	// Stock starter paired cloth wraps (麻布缠手) in marketplace if none present
	local hasWraps = false;
	foreach (it in _stash.getItems())
	{
		if (it != null && it.getID() == "weapon.wx_fist_wraps") { hasWraps = true; break; }
	}
	if (!hasWraps)
	{
		_stash.add(::new("scripts/items/weapons/wx_fist_wraps"));
	}

	// Strictly stock ONLY basic medical & common battle-prep powders in town markets!
	// Rare elixirs, wash pills, Neidan cores & Spirit Herbs are NEVER sold in ordinary town shops.
	local shopPills = ["wx_pill_jinchuang", "wx_pill_huxin"];
	if (::Math.rand(1, 100) <= 35)
		shopPills.push("wx_pill_ningshen");
	if (::Math.rand(1, 100) <= 45)
	{
		local basicPrepPool = ["wx_pill_huoluo", "wx_pill_qingxin", "wx_pill_hugu", "wx_pill_dingshen"];
		shopPills.push(basicPrepPool[::Math.rand(0, basicPrepPool.len() - 1)]);
	}
	foreach (pid in shopPills)
	{
		local p = ::new("scripts/items/misc/wx_pill_item");
		p.initPill(pid);
		_stash.add(p);
	}
};

::Wuxia.Loot.injectWeaponsmithStock <- function( _stash )
{
	if (_stash == null) return;
	local existingFist = 0;
	foreach (it in _stash.getItems())
	{
		if (it != null && (it.getID() == "weapon.wx_fist_iron" || it.getID() == "weapon.wx_fist_heavy"))
			existingFist += 1;
	}
	if (existingFist >= 1) return;

	_stash.add(::new("scripts/items/weapons/wx_fist_iron"));
	if (::Math.rand(1, 100) <= 35)
	{
		_stash.add(::new("scripts/items/weapons/wx_fist_heavy"));
	}
	// Famous Red Relics (`传世神兵`) are strictly earned via Stronghold/Boss conquests & Ghost Market auctions, never sold in town smithies!
};
