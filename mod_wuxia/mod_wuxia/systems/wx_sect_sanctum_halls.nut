// Four Exclusive Wuxia Sect Sanctuary Halls (`山门专属四大堂口` — only available at Independent Mountain Gates `location.wx_sect_sanctum`):
//   1. 【演武校场】闯护山大阵 (Real Tactical Formation Trial) & 生死踢馆 (Full Sect Raid)
//   2. 【求贤堂】延请本门真传弟子下山入队 (Authentic Sect Disciple Recruitment)
//   3. 【传功堂 & 疗伤禅房】长老灌顶注入火候 & 运功拔除经脉内伤/散功虚弱
//   4. 【知客堂 & 本门药庐】接领/缴还宗门法帖试炼 & 采买本门道地《山海本草》灵药

::Wuxia.SectRelations.getSectRegionalHerbs <- function( _sectID )
{
	local sDef = (_sectID in ::Wuxia.Config.Sects) ? ::Wuxia.Config.Sects[_sectID] : null;
	local reg = (sDef != null && "Region" in sDef) ? sDef.Region : "mountains";

	if (_sectID == "shaolin" || _sectID == "taihe")
		return ["wx_herb_zizhi", "wx_herb_dixiu", "wx_herb_zhichu", "wx_herb_sutiao", "wx_herb_danmu", "wx_herb_pincao", "wx_herb_wuzhi", "wx_marrow_herb"];
	if (_sectID == "xuanbing" || reg == "snow")
		return ["wx_herb_xuelian", "wx_herb_bingpocao", "wx_herb_heshouwu", "wx_herb_xuanji", "wx_herb_hanshui", "wx_herb_yushu", "wx_herb_zhusang", "wx_herb_huangguan", "wx_herb_jiancao", "wx_herb_yuegui"];
	if (_sectID == "wudu" || _sectID == "tangmen" || reg == "forest")
		return ["wx_herb_jiarong", "wx_herb_guicao", "wx_herb_duheng", "wx_herb_xuncao", "wx_herb_gouwen", "wx_herb_guimu", "wx_herb_mangcao", "wx_herb_zhenyu", "wx_herb_xiangliuxue", "wx_herb_busicao"];
	if (_sectID == "shenji" || _sectID == "yinsha" || reg == "desert")
		return ["wx_herb_longxuejie", "wx_herb_huolingzhi", "wx_herb_zhuyu", "wx_herb_zhugu", "wx_herb_ruomu", "wx_herb_youduhua", "wx_herb_gurong", "wx_herb_wutiao", "wx_herb_fusang"];
	if (_sectID == "gaibang" || _sectID == "jiujie" || reg == "swamp")
		return ["wx_herb_shatang", "wx_herb_migu", "wx_herb_bili", "wx_herb_longchu", "wx_herb_panmu", "wx_herb_xunmu", "wx_herb_yinglu", "wx_herb_tiaocao", "wx_herb_jianmu"];
	if (reg == "mountains")
		return ["wx_herb_dixiu", "wx_herb_zhichu", "wx_herb_zizhi", "wx_herb_yaocao", "wx_herb_baiman", "wx_herb_langgan", "wx_herb_sutiao", "wx_marrow_herb"];
	return ["wx_herb_heshouwu", "wx_herb_zhuyu", "wx_herb_xuncao", "wx_herb_pincao", "wx_herb_gurong", "wx_herb_yaocao", "wx_marrow_herb"];
};

::Wuxia.SectRelations.getSectFormationRoster <- function( _sectID, _isRaid )
{
	local day = ("World" in getroottable() && ::World != null && ::World.getTime() != null) ? ::World.getTime().Days : 1;
	local late = (day >= 30);
	local sDef = (_sectID in ::Wuxia.Config.Sects) ? ::Wuxia.Config.Sects[_sectID] : null;
	local reg = (sDef != null && "Region" in sDef) ? sDef.Region : "mountains";
	local align = (sDef != null && "Alignment" in sDef) ? sDef.Alignment : "neutral";

	if (_sectID == "shaolin")
	{
		return _isRaid
			? ["monk_fighter", "monk_fighter", "monk_fighter", "staff_guard", "staff_guard", "shaolin_bronze", "shaolin_bronze"]
			: (late ? ["monk_fighter", "monk_fighter", "staff_guard", "shaolin_bronze", "shaolin_bronze"] : ["monk_fighter", "monk_fighter", "staff_guard", "shaolin_bronze"]);
	}
	if (_sectID == "taihe" || _sectID == "qingfeng")
	{
		return _isRaid
			? ["disciple", "disciple", "disciple", "emei_sword", "emei_sword", "taihe_elder", "renegade"]
			: (late ? ["disciple", "disciple", "emei_sword", "emei_sword", "taihe_elder"] : ["disciple", "disciple", "emei_sword", "taihe_elder"]);
	}
	if (_sectID == "xuanbing")
	{
		return _isRaid
			? ["emei_sword", "emei_sword", "emei_sword", "emei_sword", "taihe_elder", "renegade"]
			: ["emei_sword", "emei_sword", "disciple", "taihe_elder"];
	}
	if (_sectID == "tangmen" || _sectID == "yinsha")
	{
		return _isRaid
			? ["shadow_dagger", "shadow_dagger", "shadow_dagger", "dartist", "tangmen_killer", "tangmen_killer", "dongchang_agent"]
			: ["shadow_dagger", "shadow_dagger", "dartist", "tangmen_killer", "tangmen_killer"];
	}
	if (_sectID == "gaibang" || _sectID == "weiyuan")
	{
		local boss = (_sectID == "gaibang") ? "gaibang_elder" : "weiyuan_captain";
		return _isRaid
			? ["staff_guard", "staff_guard", "escort", "escort", "axe_vanguard", boss, "weiyuan_captain"]
			: ["staff_guard", "staff_guard", "escort", boss];
	}
	if (_sectID == "wudu")
	{
		return _isRaid
			? ["wudu_blowgun", "wudu_blowgun", "whip_stalker", "whip_stalker", "wudu_gushaman", "wanxian_patriarch"]
			: ["wudu_blowgun", "wudu_blowgun", "whip_stalker", "wudu_gushaman"];
	}
	if (_sectID == "shenji")
	{
		return _isRaid
			? ["escort", "escort", "shenji_musketeer", "shenji_musketeer", "shenji_musketeer", "garrison_general", "mingzun_fawang"]
			: ["escort", "escort", "shenji_musketeer", "shenji_musketeer", "garrison_general"];
	}
	if (align == "outlaw" || _sectID == "heifeng")
	{
		return _isRaid
			? ["axe_vanguard", "hammer_adept", "whip_stalker", "dartist", "shadow_dagger", "blood_chief", "liaodong_boss"]
			: ["axe_vanguard", "hammer_adept", "dartist", "blood_chief"];
	}
	if (reg == "desert")
	{
		return _isRaid
			? ["escort", "dartist", "shenji_musketeer", "mobei_centurion", "mingzun_fawang", "garrison_general"]
			: ["escort", "dartist", "mobei_centurion", "mingzun_fawang"];
	}
	if (reg == "swamp")
	{
		return _isRaid
			? ["whip_stalker", "whip_stalker", "escort", "staff_guard", "dongting_pirate", "liushan_bailiff"]
			: ["whip_stalker", "escort", "staff_guard", "dongting_pirate"];
	}
	if (reg == "snow")
	{
		return _isRaid
			? ["axe_vanguard", "axe_vanguard", "hammer_adept", "emei_sword", "liaodong_boss", "heishui_berserker"]
			: ["axe_vanguard", "hammer_adept", "emei_sword", "liaodong_boss"];
	}
	return _isRaid
		? ["disciple", "disciple", "escort", "hammer_adept", "emei_sword", "taihe_elder", "garrison_general"]
		: ["disciple", "disciple", "escort", "taihe_elder"];
};

// -----------------------------------------------------------------------------
// 1. 【演武校场】闯护山大阵 (`trial`) & 生死踢馆 (`raid`)
// -----------------------------------------------------------------------------
::Wuxia.SectRelations.sanctumStartBattle <- function( _sectID, _mode )
{
	if (!(_sectID in ::Wuxia.Config.Sects))
		return { ok = false, reason = "未找到该江湖宗门。" };

	local sanctum = ::Wuxia.SectRelations.getCurrentSanctum();
	if (sanctum == null)
		return { ok = false, reason = "须亲临该派大地图【独立山门】方能登坛闯阵或踢馆。" };
	local ssid = ("getSectID" in sanctum) ? sanctum.getSectID() : sanctum.getFlags().get("wx_sect_id");
	if (ssid != _sectID)
		return { ok = false, reason = "当前并不在该派山门之中。" };

	local sect = ::Wuxia.Config.Sects[_sectID];
	local sealDays = ::Wuxia.SectRelations.getSanctumSealLeft(_sectID);
	if (sealDays > 0)
		return { ok = false, reason = "【" + sect.Name + "】山门前番已被攻破重创，尚余 " + sealDays + " 日封山整顿，暂无大阵可闯。" };

	local isRaid = (_mode == "raid");
	if (!isRaid)
	{
		local rel = ::Wuxia.SectRelations.getRelation(_sectID);
		local minRel = (sect.Alignment == "outlaw") ? 0 : 10;
		if (rel < minRel)
			return { ok = false, reason = "与【" + sect.Name + "】交情未至（需 ≥" + minRel + "，当前 " + rel + "），护法长老不允外客入护山大阵切磋（若执意强闯可点『生死踢馆』）。" };

		local cd = ::Wuxia.SectRelations.getTeaCooldownLeft("trial", _sectID, 8);
		if (cd > 0)
			return { ok = false, reason = "本门护山大阵近日刚与贵社印证过，尚需隔 " + cd + " 日重布阵势。" };
	}
	else
	{
		if (::World.Assets != null && ::World.Assets.getOrigin() != null && ::World.Assets.getOrigin().getID() == "scenario.wx_origin_shaolin_monks" && ("Alignment" in sect) && sect.Alignment == "righteous")
			return { ok = false, reason = "少室门规森严：严禁对天下【名门正派】山门发起生死踢馆！请走切磋印证之正道。" };
		local rcd = ::Wuxia.SectRelations.getTeaCooldownLeft("raid", _sectID, 15);
		if (rcd > 0)
			return { ok = false, reason = "该派山门余威未复，尚需隔 " + rcd + " 日方可再行踢馆。" };
	}

	local banditFac = ::World.FactionManager.getFactionOfType(::Const.FactionType.Bandits);
	if (banditFac == null)
		return { ok = false, reason = "无法初始化山门护阵敌方编制。" };

	// Arm `wx_sect_sanctum` for real tactical combat via native `World.State.enterLocation`
	sanctum.clearTroops();
	if ("Loot" in sanctum.m && sanctum.m.Loot != null)
		sanctum.m.Loot.clear();

	local roster = ::Wuxia.SectRelations.getSectFormationRoster(_sectID, isRaid);
	::Wuxia.Encounters.addTroops(sanctum, roster);

	// Populate authentic Sect Formation / Raid Vault Loot
	local manualIDs = [];
	local bestManualID = "";
	local bestMinRel = -999;
	foreach (sm in sect.ShopManuals)
	{
		if (sm.ManualID in ::Wuxia.Config.Manuals)
		{
			manualIDs.push(sm.ManualID);
			if (sm.MinRel > bestMinRel)
			{
				bestMinRel = sm.MinRel;
				bestManualID = sm.ManualID;
			}
		}
	}

	local vaultLooted = isRaid && ::World.Flags != null && ::World.Flags.get("wx_raid_vault_looted_" + _sectID);
	if (manualIDs.len() > 0 && "Loot" in sanctum.m && sanctum.m.Loot != null)
	{
		if (isRaid && bestManualID != "" && !vaultLooted)
		{
			local fullBook = ::new("scripts/items/misc/wx_manual_item");
			fullBook.initManual(bestManualID);
			sanctum.m.Loot.add(fullBook);
		}
		local pageMid = manualIDs[::Math.rand(0, manualIDs.len() - 1)];
		local pages = ::new("scripts/items/misc/wx_page_item");
		pages.initPages(pageMid, isRaid ? (vaultLooted ? 1 : 3) : 2);
		sanctum.m.Loot.add(pages);
	}

	local herbPool = ::Wuxia.SectRelations.getSectRegionalHerbs(_sectID);
	if (herbPool.len() > 0 && "Loot" in sanctum.m && sanctum.m.Loot != null)
	{
		local herbCnt = isRaid ? (vaultLooted ? 1 : 2) : 1;
		for (local hi = 0; hi < herbCnt; hi = ++hi)
		{
			local hId = herbPool[::Math.rand(0, herbPool.len() - 1)];
			try { sanctum.m.Loot.add(::new("scripts/items/misc/" + hId)); } catch (_e) {}
		}
	}

	if ("Loot" in sanctum.m && sanctum.m.Loot != null)
	{
		try
		{
			local silver = ::new("scripts/items/supplies/money_item");
			silver.setAmount(isRaid ? (vaultLooted ? 600 : 1400) : 500);
			sanctum.m.Loot.add(silver);
		}
		catch (_e) {}
	}

	sanctum.setFaction(banditFac.getID());
	sanctum.m.LocationType = ::Const.World.LocationType.Lair | ::Const.World.LocationType.Unique;
	sanctum.m.IsShowingDefenders = true;
	sanctum.m.CombatLocation.Template = isRaid ? ["tactical.human_camp"] : [null, null];
	sanctum.m.CombatLocation.Fortification = isRaid ? ::Const.Tactical.FortificationType.Palisade : ::Const.Tactical.FortificationType.None;
	sanctum.m.CombatLocation.ForceLineBattle = !isRaid;
	sanctum.m.WX_BattleMode = isRaid ? "raid" : "trial";
	sanctum.m.WX_AllowCombatEnter = true;
	sanctum.WX_RefreshSanctumVisuals();

	if (!::World.State.enterLocation(sanctum))
	{
		sanctum.WX_ResetPeacefulState();
		return { ok = false, reason = "当前无法进入山门战斗，请稍后再试。" };
	}
	::World.Flags.set("wx_active_sanctum_sect", "");

	return {
		ok         = true,
		closeModal = true,
		message    = isRaid ? ("拔刃踢馆：已向【" + sect.Name + "】山门发起强攻！") : ("登坛闯阵：已踏入【" + sect.Name + "】护山大阵！")
	};
};

::Wuxia.HooksMod.hook("scripts/states/world_state", function( q )
{
	q.combat_dialog_module_onCancelPressed = @(__original) function()
	{
		local site = this.m.LastEnteredLocation;
		if (site != null && !site.isNull() && ::Wuxia.hasMember(site, "WX_GetBattleMode") && site.WX_GetBattleMode() != "")
			site.WX_ResetPeacefulState();
		return __original();
	};

	q.onCombatFinished = @(__original) function()
	{
		local sitesWithDefenders = [];
		foreach (site in this.m.PartiesInCombat)
		{
			if (::Wuxia.hasMember(site, "WX_GetBattleMode") && site.WX_GetBattleMode() != "" && site.isAlive() && site.getTroops().len() > 0)
				sitesWithDefenders.push(site);
		}
		// Vanilla must see the surviving defenders before the gate is reset.
		local res = __original();
		foreach (site in sitesWithDefenders)
		{
			if (::Wuxia.hasMember(site, "WX_GetBattleMode") && site.isAlive())
				site.WX_ResetPeacefulState();
		}
		return res;
	};
});

// -----------------------------------------------------------------------------
// 2. 【求贤堂】延请真传弟子下山入队 (`sanctumRecruitDisciple`)
// -----------------------------------------------------------------------------
::Wuxia.SectRelations.getSanctumRecruitCost <- function( _sectID )
{
	if (!(_sectID in ::Wuxia.Config.Sects)) return 2600;
	local sect = ::Wuxia.Config.Sects[_sectID];
	local reg = ("Region" in sect) ? sect.Region : "mountains";
	local align = ("Alignment" in sect) ? sect.Alignment : "neutral";
	if (_sectID == "taihe" || _sectID == "qingfeng") return 4200; // swordmaster_background + 2 sect manuals
	if (_sectID == "shaolin" || _sectID == "gaibang" || _sectID == "weiyuan" || _sectID == "zhenyue" || align == "outlaw") return 1750;
	if (_sectID == "tangmen" || _sectID == "yinsha" || _sectID == "wudu" || _sectID == "pishan" || reg == "snow") return 2250;
	return 2800; // sellsword_background + 2 sect manuals
};

::Wuxia.SectRelations.sanctumRecruitDisciple <- function( _sectID )
{
	if (!(_sectID in ::Wuxia.Config.Sects))
		return { ok = false, reason = "未找到该江湖宗门。" };

	local meet = ::Wuxia.SectRelations.resolveActiveMeeting(_sectID);
	if (!meet.Ok || !meet.AtSanctum)
		return { ok = false, reason = ("Sealed" in meet && meet.Sealed) ? meet.Reason : "唯有亲临宗门山门【求贤堂】，方能延请真传弟子下山。" };

	local sect = ::Wuxia.Config.Sects[_sectID];
	local rel = ::Wuxia.SectRelations.getRelation(_sectID);
	if (rel < 45)
		return { ok = false, reason = "延请本门入室弟子随行须交情 ≥45（当前：" + rel + "）。" };

	local cd = ::Wuxia.SectRelations.getTeaCooldownLeft("recruit", _sectID, 12);
	if (cd > 0)
		return { ok = false, reason = "本门求贤堂近日已有弟子奉命下山随行，请隔 " + cd + " 日再行延请。" };

	local pRoster = ::World.getPlayerRoster();
	local maxBros = ::World.Assets.getBrothersMax();
	if (pRoster == null || pRoster.getSize() >= maxBros)
		return { ok = false, reason = "义社麾下编制已满（" + (pRoster != null ? pRoster.getSize() : 0) + " / " + maxBros + " 人），请先腾出空位。" };

	local cost = ::Wuxia.SectRelations.getSanctumRecruitCost(_sectID);
	if (::World.Assets.getMoney() < cost)
		return { ok = false, reason = "奉上求贤安家礼银需 " + cost + " 两纹银。" };

	local reg = ("Region" in sect) ? sect.Region : "mountains";
	local align = ("Alignment" in sect) ? sect.Alignment : "neutral";

	local bgScript = "sellsword_background";
	local namePool = "jianghu";
	local wpnScript = "weapons/arming_sword";
	local discTitle = sect.Name + "真传";
	local forceFemale = false;

	if (_sectID == "shaolin")
	{
		bgScript = "monk_background";
		namePool = "monk";
		wpnScript = (::Math.rand(1, 100) <= 65) ? "weapons/wx_fist_iron" : "weapons/bludgeon";
		discTitle = "少室护法行者";
	}
	else if (_sectID == "taihe" || _sectID == "qingfeng")
	{
		bgScript = "swordmaster_background";
		wpnScript = "weapons/arming_sword";
		discTitle = (_sectID == "taihe") ? "太和入室剑客" : "清风试剑传人";
	}
	else if (_sectID == "xuanbing")
	{
		bgScript = "sellsword_background";
		wpnScript = "weapons/arming_sword";
		discTitle = "昆仑寒霜剑侍";
		forceFemale = true;
	}
	else if (_sectID == "tangmen" || _sectID == "yinsha")
	{
		bgScript = "hunter_background";
		wpnScript = (_sectID == "tangmen") ? "weapons/crossbow" : "weapons/rondel_dagger";
		discTitle = (_sectID == "tangmen") ? "唐门机括暗手" : "幽冥执匕影卫";
	}
	else if (_sectID == "gaibang" || _sectID == "weiyuan")
	{
		bgScript = "caravan_hand_background";
		wpnScript = (_sectID == "gaibang") ? "weapons/wooden_stick" : "weapons/fighting_spear";
		discTitle = (_sectID == "gaibang") ? "丐帮六袋弟子" : "威远八方镖师";
	}
	else if (_sectID == "wudu")
	{
		bgScript = "hunter_background";
		wpnScript = "weapons/rondel_dagger";
		discTitle = "五毒驭蛊门人";
	}
	else if (_sectID == "pishan" || reg == "snow")
	{
		bgScript = "raider_background";
		wpnScript = "weapons/fighting_axe";
		discTitle = sect.Name + "锐士";
	}
	else if (_sectID == "zhenyue" || align == "outlaw")
	{
		bgScript = "brawler_background";
		wpnScript = (_sectID == "zhenyue") ? "weapons/warhammer" : "weapons/scimitar";
		discTitle = sect.Name + "悍徒";
	}

	// Find first open formation slot (0..26)
	local occupiedSlots = {};
	local usedNames = {};
	foreach (existing in pRoster.getAll())
	{
		if (existing != null)
		{
			occupiedSlots[existing.getPlaceInFormation()] <- true;
			usedNames[existing.getNameOnly()] <- true;
		}
	}
	local freePlace = 0;
	for (local fp = 0; fp < 27; fp = ++fp)
	{
		if (!(fp in occupiedSlots)) { freePlace = fp; break; }
	}

	local bro = null;
	local equippedBookNames = [];
	::Wuxia.Backgrounds.SuppressAutoAssign = true;
	try
	{
		bro = pRoster.create("scripts/entity/tactical/player");
		bro.setStartValuesEx([bgScript]);
		if (forceFemale)
		{
			local st = ::Wuxia.Appearance.getOrInitState(bro);
			if (st != null)
			{
				st.FaceIdx = ::Math.rand(33, 48);
				st.HairIdx = 9 + ::Math.rand(0, 3);
				st.BeardIdx = 0;
			}
			local femPool = ::Wuxia.Config.Appearance.FemaleHeroineNames;
			if (femPool.len() > 0)
				bro.setName(femPool[::Math.rand(0, femPool.len() - 1)]);
		}
		else if ("rollUniqueActorName" in ::Wuxia.Backgrounds)
		{
			::Wuxia.Backgrounds.rollUniqueActorName(bro, usedNames, namePool);
		}
		bro.setTitle(discTitle);
		bro.setPlaceInFormation(freePlace);
		bro.m.HireTime = ::Time.getVirtualTimeF();
		bro.m.Level = 2;
		bro.m.XP = ::Const.LevelXP[1];
		bro.m.LevelUps = 1;
		bro.m.PerkPoints = 0;
		bro.m.Hitpoints = bro.getHitpointsMax();

		local items = bro.getItems();
		if (items.getItemAtSlot(::Const.ItemSlot.Mainhand) != null)
			items.unequip(items.getItemAtSlot(::Const.ItemSlot.Mainhand));
		if (items.getItemAtSlot(::Const.ItemSlot.Offhand) != null)
			items.unequip(items.getItemAtSlot(::Const.ItemSlot.Offhand));
		local mainWpn = ::new("scripts/items/" + wpnScript);
		items.equip(mainWpn);
		if (wpnScript == "weapons/crossbow")
		{
			if (items.getItemAtSlot(::Const.ItemSlot.Ammo) != null)
				items.unequip(items.getItemAtSlot(::Const.ItemSlot.Ammo));
			items.equip(::new("scripts/items/ammo/quiver_of_bolts"));
		}

		// Equip 1 Neigong + 1 matching Sect Manual (preferring manuals from `sect.ShopManuals`)
		local sectNei = null;
		local sectWai = null;
		local sectExtra = null;
		foreach (sm in sect.ShopManuals)
		{
			local md = ::Wuxia.Slots.getManualDef(sm.ManualID);
			if (md == null) continue;
			if (md.Category == "neigong" && sectNei == null)
				sectNei = md.ID;
			else if (md.Category == "waigong" && sectWai == null && ::Wuxia.CombatRules.matchesWeapon(mainWpn, md.WeaponTypes))
				sectWai = md.ID;
			else if (sectExtra == null)
				sectExtra = md.ID;
		}
		if (sectNei == null)
			sectNei = ::Wuxia.Backgrounds.pickCatalogManual("neigong", "sect", null, {}, "wx_manual_guiyuan");
		if (sectWai == null)
			sectWai = ::Wuxia.Backgrounds.pickCatalogManual("waigong", "common", mainWpn, {}, "wx_manual_qingfeng");

		::Wuxia.Slots.equipManual(bro, 0, sectNei, false);
		::Wuxia.Slots.equipManual(bro, 1, sectWai, false);
		equippedBookNames.push(::Wuxia.Slots.getManualDef(sectNei).Name);
		equippedBookNames.push(::Wuxia.Slots.getManualDef(sectWai).Name);
		if (sectExtra != null && sectExtra != sectNei && sectExtra != sectWai)
			::Wuxia.Slots.learnManual(bro, sectExtra, false);

		if (bro.getBackground() != null && ::Wuxia.hasMember(bro.getBackground(), "WX_RefreshStarterNote"))
			bro.getBackground().WX_RefreshStarterNote(equippedBookNames);

		::Wuxia.Appearance.refreshActorSprites(bro);
		::Wuxia.Armory.syncActorHandheldAndArmor(bro);
		bro.getSkills().update();
	}
	catch (_err)
	{
		::Wuxia.Backgrounds.SuppressAutoAssign = false;
		return { ok = false, reason = "招募弟子异常：" + _err };
	}
	::Wuxia.Backgrounds.SuppressAutoAssign = false;

	::World.Assets.addMoney(-cost);
	::World.Flags.set("wx_tea_recruit_" + _sectID, ::World.getTime().Days);

	return {
		ok      = true,
		message = "求贤得士：奉上安家银 " + cost + " 两，【" + bro.getName() + "】（2 级 · 兼修《" + equippedBookNames[0] + "》《" + equippedBookNames[1] + "》）已拜别师门加入义社！"
	};
};

// -----------------------------------------------------------------------------
// 3. 【传功堂 & 疗伤禅房】长老灌顶指点 (`sanctumElderEmpower`) & 运功疗内伤 (`sanctumHealInternal`)
// -----------------------------------------------------------------------------
::Wuxia.SectRelations.sanctumElderEmpower <- function( _sectID )
{
	if (!(_sectID in ::Wuxia.Config.Sects))
		return { ok = false, reason = "未找到该江湖宗门。" };

	local meet = ::Wuxia.SectRelations.resolveActiveMeeting(_sectID);
	if (!meet.Ok || !meet.AtSanctum)
		return { ok = false, reason = ("Sealed" in meet && meet.Sealed) ? meet.Reason : "唯有亲登宗门山门【传功堂】，方能请传功长老指点迷津。" };

	local sect = ::Wuxia.Config.Sects[_sectID];
	local rel = ::Wuxia.SectRelations.getRelation(_sectID);
	if (rel < 30)
		return { ok = false, reason = "需与本门交情达 30 以上，传功长老方肯开堂指点火候（当前：" + rel + "）。" };

	local cd = ::Wuxia.SectRelations.getTeaCooldownLeft("emp", _sectID, 5);
	if (cd > 0)
		return { ok = false, reason = "传功长老近日真气损耗未复，请隔 " + cd + " 日再来求教。" };

	local cost = 450;
	if (::World.Assets.getMoney() < cost)
		return { ok = false, reason = "奉上传功堂香火束脩需纹银 " + cost + " 两。" };

	local sectManualSet = {};
	foreach (sm in sect.ShopManuals)
		sectManualSet[sm.ManualID] <- true;

	local bestBro = null;
	local bestSlot = -1;
	local bestScore = -1;
	local bestMName = "";

	local bros = (::World.getPlayerRoster() != null) ? ::World.getPlayerRoster().getAll() : [];
	foreach (b in bros)
	{
		if (b == null || !b.isAlive()) continue;
		local c = ::Wuxia.Slots.getContainer(b);
		if (c == null) continue;
		for (local si = 0; si < c.m.Slots.len(); si = ++si)
		{
			local check = ::Wuxia.Mastery.checkInfusionSlot(b, c, si);
			if (!check.Ok) continue;
			local s = c.m.Slots[si];
			local score = (s.ManualID in sectManualSet) ? 100 : (si == 0 ? 50 : 25);
			score += s.Tier * 10;
			if (score > bestScore)
			{
				bestScore = score;
				bestBro = b;
				bestSlot = si;
				bestMName = check.Def.Name;
			}
		}
	}

	if (bestBro == null || bestSlot < 0)
		return { ok = false, reason = "麾下侠客当前没有可继续灌注火候的已装功法。" };

	local res = ::Wuxia.Mastery.addExpToSlot(bestBro, bestSlot, 160);
	if (!("ExpGained" in res) || res.ExpGained <= 0)
		return { ok = false, reason = "此功法当前无法再获得火候。" };
	::World.Assets.addMoney(-cost);
	::World.Flags.set("wx_tea_emp_" + _sectID, ::World.getTime().Days);
	bestBro.getSkills().update();

	local breakNote = res.Advanced ? ("，当场贯通关窍突破至【第 " + res.NewTier + " 重】") : "";
	return {
		ok      = true,
		message = "传功灌顶：奉银 " + cost + " 两，【" + sect.Name + "】长老掌抵百会助【" + bestBro.getName() + "】参透《" + bestMName + "》（火候 +" + res.ExpGained + breakNote + "）！"
	};
};

::Wuxia.SectRelations.sanctumHealInternal <- function( _sectID )
{
	if (!(_sectID in ::Wuxia.Config.Sects))
		return { ok = false, reason = "未找到该江湖宗门。" };

	local meet = ::Wuxia.SectRelations.resolveActiveMeeting(_sectID);
	if (!meet.Ok || !meet.AtSanctum)
		return { ok = false, reason = ("Sealed" in meet && meet.Sealed) ? meet.Reason : "须亲临宗门山门方能求请高人运功拔除经脉内伤。" };

	local sect = ::Wuxia.Config.Sects[_sectID];
	local rel = ::Wuxia.SectRelations.getRelation(_sectID);
	if (rel < 15)
		return { ok = false, reason = "需与本门交情达 15 以上，禅房高人方肯耗损真元为你疗伤（当前：" + rel + "）。" };

	local cd = ::Wuxia.SectRelations.getTeaCooldownLeft("heal", _sectID, 3);
	if (cd > 0)
		return { ok = false, reason = "本门药师真元调息中，请隔 " + cd + " 日再来求医。" };

	local cost = 380;
	if (::World.Assets.getMoney() < cost)
		return { ok = false, reason = "奉上汤药香火需纹银 " + cost + " 两。" };

	local healedCnt = 0;
	local bros = (::World.getPlayerRoster() != null) ? ::World.getPlayerRoster().getAll() : [];
	foreach (b in bros)
	{
		if (b == null || !b.isAlive() || b.getSkills() == null) continue;
		local sk = b.getSkills();
		local touched = false;

		if (sk.hasSkill("effects.wx_scatter_weakness"))
		{
			sk.removeByID("effects.wx_scatter_weakness");
			touched = true;
		}
		local intInj = sk.getSkillByID("effects.wx_internal_injury");
		if (intInj != null && (intInj.m.Severity > 0 || intInj.m.DaysRemaining > 0))
		{
			intInj.cureTemporary();
			touched = true;
		}
		local tempWounds = sk.getAllSkillsOfType(::Const.SkillType.TemporaryInjury);
		if (tempWounds != null && tempWounds.len() > 0)
		{
			foreach (tw in tempWounds)
			{
				if (tw != null) sk.remove(tw);
			}
			touched = true;
		}
		if (b.getHitpoints() < b.getHitpointsMax())
		{
			b.setHitpoints(b.getHitpointsMax());
			touched = true;
		}
		if (touched)
		{
			sk.update();
			healedCnt += 1;
		}
	}

	if (healedCnt <= 0)
		return { ok = false, reason = "麾下全体侠客当前经脉畅通、内外无伤，无需运功施治。" };

	::World.Assets.addMoney(-cost);
	::World.Flags.set("wx_tea_heal_" + _sectID, ::World.getTime().Days);

	return {
		ok      = true,
		message = "真元涤脉：奉银 " + cost + " 两，【" + sect.Name + "】前辈以深厚内力为队中 " + healedCnt + " 名伤患尽数拔除经脉内伤、散功虚弱与外创，气血尽复！"
	};
};

// -----------------------------------------------------------------------------
// 4. 【知客堂 · 宗门法帖试炼 & 本门药庐】(`sanctumHandleQuest` & `sanctumBuyHerbs`)
// -----------------------------------------------------------------------------
::Wuxia.SectRelations.getSanctumQuestInfo <- function( _sectID )
{
	if (!("World" in getroottable()) || ::World == null || ::World.Flags == null)
		return { active = false, canComplete = false, cd = 0, label = "接领宗门法帖差事", detail = "" };

	local qType = ::World.Flags.has("wx_sq_type_" + _sectID) ? ::World.Flags.getAsInt("wx_sq_type_" + _sectID) : 0;
	local cd = ::Wuxia.SectRelations.getTeaCooldownLeft("quest", _sectID, 3);

	if (qType <= 0)
	{
		return {
			active      = false,
			canComplete = false,
			cd          = cd,
			label       = cd > 0 ? ("宗门法帖(隔" + cd + "日)") : "接领宗门法帖(交情+22)",
			detail      = "可于知客堂领受本门法帖差事（荡寇除恶 / 奉山采药 / 校勘残卷），功成回山大涨交情与威名并获赐残页。"
		};
	}

	if (qType == 1)
	{
		local curSlain = ::World.Flags.has("wx_sq_enemies_slain") ? ::World.Flags.getAsInt("wx_sq_enemies_slain") : 0;
		local targetSlain = ::World.Flags.getAsInt("wx_sq_target_" + _sectID);
		local need = 6;
		local done = ::Math.max(0, ::Math.min(need, need - (targetSlain - curSlain)));
		local ready = (curSlain >= targetSlain);
		return {
			active      = true,
			canComplete = ready,
			cd          = 0,
			label       = ready ? "缴令领赏 · 荡寇法帖(已完成!)" : ("荡寇法帖(" + done + "/" + need + "敌)"),
			detail      = "当前法帖：下山诛除任意绿林匪寇或邪派凶徒（进度 " + done + " / " + need + "）"
		};
	}
	if (qType == 2)
	{
		local herbId = ::World.Flags.get("wx_sq_item_" + _sectID);
		if (herbId == null || typeof herbId != "string" || herbId == "") herbId = "wx_marrow_herb";
		local cnt = ::Wuxia.Alchemy.Cabinet.getCount("herb:" + herbId);
		local hName = "山海灵草";
		try { hName = ::new("scripts/items/misc/" + herbId).getName(); } catch (_e) {}
		local ready = (cnt >= 1);
		return {
			active      = true,
			canComplete = ready,
			cd          = 0,
			label       = ready ? ("奉药缴令 · " + hName + "(可交付!)") : ("采药法帖 · 需" + hName),
			detail      = "当前法帖：为本门丹房寻回 1 株【" + hName + "】（百草药柜现存：" + cnt + " 株）"
		};
	}

	// qType == 3: Contribute any 2 spare manual pages from 藏经阁
	local maps = ::Wuxia.Library.getOwnedMaps();
	local totalPages = 0;
	foreach (_m, pCnt in maps.Pages)
		totalPages += pCnt;
	local readyP = (totalPages >= 2);
	return {
		active      = true,
		canComplete = readyP,
		cd          = 0,
		label       = readyP ? "奉卷缴令 · 校勘残页(可交付!)" : ("校勘法帖(藏经阁残页" + totalPages + "/2)"),
		detail      = "当前法帖：自藏经阁奉交任意 2 张武学残页供本门长老校勘武库（现存：" + totalPages + " 张）"
	};
};

::Wuxia.SectRelations.sanctumHandleQuest <- function( _sectID )
{
	if (!(_sectID in ::Wuxia.Config.Sects))
		return { ok = false, reason = "未找到该江湖宗门。" };

	local meet = ::Wuxia.SectRelations.resolveActiveMeeting(_sectID);
	if (!meet.Ok || !meet.AtSanctum)
		return { ok = false, reason = ("Sealed" in meet && meet.Sealed) ? meet.Reason : "须亲临宗门山门【知客堂】方能接领或缴还宗门法帖。" };

	local sect = ::Wuxia.Config.Sects[_sectID];
	local rel = ::Wuxia.SectRelations.getRelation(_sectID);
	if (rel < -15)
		return { ok = false, reason = "当前与【" + sect.Name + "】敌意深重（交情 " + rel + "），知客僧道拒发法帖（可先赴城镇易容阁敛息缓和）。" };

	local qType = ::World.Flags.has("wx_sq_type_" + _sectID) ? ::World.Flags.getAsInt("wx_sq_type_" + _sectID) : 0;
	if (qType <= 0)
	{
		local cd = ::Wuxia.SectRelations.getTeaCooldownLeft("quest", _sectID, 3);
		if (cd > 0)
			return { ok = false, reason = "本门知客堂近日暂无新法帖派发，请隔 " + cd + " 日再来。" };

		local roll = (::World.getTime().Days + ::Wuxia.WorldVisuals.hashString(_sectID)) % 3 + 1;
		::World.Flags.set("wx_sq_type_" + _sectID, roll);
		if (roll == 1)
		{
			local curSlain = ::World.Flags.has("wx_sq_enemies_slain") ? ::World.Flags.getAsInt("wx_sq_enemies_slain") : 0;
			::World.Flags.set("wx_sq_target_" + _sectID, curSlain + 6);
			return {
				ok      = true,
				message = "接领法帖：【" + sect.Name + "】知客长老授下靖乱法帖——下山诛灭 6 名绿林匪寇或邪派凶徒后即可回山领赏！"
			};
		}
		if (roll == 2)
		{
			local herbs = ::Wuxia.SectRelations.getSectRegionalHerbs(_sectID);
			local pickH = herbs[::Math.rand(0, herbs.len() - 1)];
			::World.Flags.set("wx_sq_item_" + _sectID, pickH);
			local hNm = "山海灵草";
			try { hNm = ::new("scripts/items/misc/" + pickH).getName(); } catch (_e) {}
			return {
				ok      = true,
				message = "接领法帖：【" + sect.Name + "】丹房急需 1 株【" + hNm + "】（存入百草药柜即可回山奉交领赏）！"
			};
		}
		return {
			ok      = true,
			message = "接领法帖：【" + sect.Name + "】藏经阁征集任意 2 张闲置武学残页校勘古谱，备齐于藏经阁即可交付！"
		};
	}

	// Turn in active quest if complete!
	local qInfo = ::Wuxia.SectRelations.getSanctumQuestInfo(_sectID);
	if (!qInfo.canComplete)
		return { ok = false, reason = "法帖差事尚未达成：" + qInfo.detail };

	if (qType == 2)
	{
		local herbId = ::World.Flags.get("wx_sq_item_" + _sectID);
		if (herbId == null || typeof herbId != "string" || herbId == "") herbId = "wx_marrow_herb";
		::Wuxia.Alchemy.Cabinet.addCount("herb:" + herbId, -1);
	}
	else if (qType == 3)
	{
		local maps = ::Wuxia.Library.getOwnedMaps();
		local remNeed = 2;
		local pKeys = [];
		foreach (mid, cnt in maps.Pages)
		{
			if (cnt > 0) pKeys.push(mid);
		}
		pKeys.sort();
		foreach (mid in pKeys)
		{
			if (remNeed <= 0) break;
			local curP = ::Wuxia.Library.getPageCount(mid);
			local take = ::Math.min(remNeed, curP);
			if (take > 0)
			{
				::Wuxia.Library.setPageCount(mid, curP - take);
				remNeed -= take;
			}
		}
	}

	::World.Flags.set("wx_sq_type_" + _sectID, 0);
	::World.Flags.set("wx_tea_quest_" + _sectID, ::World.getTime().Days);

	local activeCrisis = (::World.Flags != null && ::World.Flags.has("wx_active_crisis")) ? ::World.Flags.get("wx_active_crisis") : "";
	local inCrisis = (typeof activeCrisis == "string" && activeCrisis != "");
	local relReward = inCrisis ? 27 : 22;
	local silverReward = inCrisis ? 550 : 420;
	local renownReward = inCrisis ? 60 : 45;

	local newRel = ::Wuxia.SectRelations.addRelation(_sectID, relReward);
	::World.Assets.addMoney(silverReward);
	::World.Assets.addBusinessReputation(renownReward);

	local pageNote = "";
	if (sect.ShopManuals.len() > 0)
	{
		local rewardMid = sect.ShopManuals[::Math.rand(0, sect.ShopManuals.len() - 1)].ManualID;
		if (rewardMid in ::Wuxia.Config.Manuals)
		{
			local curPg = ::Wuxia.Library.getPageCount(rewardMid);
			::Wuxia.Library.setPageCount(rewardMid, curPg + 1);
			pageNote = "，并获赐《" + ::Wuxia.Config.Manuals[rewardMid].Name + "》残页 ×1（已入藏经阁）";
		}
	}

	local crisisTag = inCrisis ? "（大劫军需战时加赏）" : "";
	return {
		ok      = true,
		message = "法帖缴令" + crisisTag + "：【" + sect.Name + "】盛赞贵社信义果决！赏纹银 " + silverReward + " 两、江湖威名 +" + renownReward + "、宗门交情 +" + relReward + "（→ " + newRel + "）" + pageNote + "！"
	};
};

::Wuxia.SectRelations.sanctumBuyHerbs <- function( _sectID )
{
	if (!(_sectID in ::Wuxia.Config.Sects))
		return { ok = false, reason = "未找到该江湖宗门。" };

	local meet = ::Wuxia.SectRelations.resolveActiveMeeting(_sectID);
	if (!meet.Ok || !meet.AtSanctum)
		return { ok = false, reason = ("Sealed" in meet && meet.Sealed) ? meet.Reason : "唯有亲临宗门山门【本门药庐】，方能采买秘植道地灵草。" };

	local sect = ::Wuxia.Config.Sects[_sectID];
	local rel = ::Wuxia.SectRelations.getRelation(_sectID);
	if (rel < 20)
		return { ok = false, reason = "需与本门交情达 20 以上，药庐执事方肯匀售山门灵草（当前：" + rel + "）。" };

	local cd = ::Wuxia.SectRelations.getTeaCooldownLeft("herb", _sectID, 4);
	if (cd > 0)
		return { ok = false, reason = "本门药圃灵草尚在采摘晾晒，请隔 " + cd + " 日再来选购。" };

	local cost = 360;
	if (::World.Assets.getMoney() < cost)
		return { ok = false, reason = "采买本门道地灵草需纹银 " + cost + " 两。" };

	local pool = ::Wuxia.SectRelations.getSectRegionalHerbs(_sectID);
	if (pool.len() == 0)
		return { ok = false, reason = "本门药庐暂无灵草存货。" };

	::World.Assets.addMoney(-cost);
	::World.Flags.set("wx_tea_herb_" + _sectID, ::World.getTime().Days);

	local gotNames = [];
	for (local i = 0; i < 2; i = ++i)
	{
		local hid = pool[::Math.rand(0, pool.len() - 1)];
		local sc = "scripts/items/misc/" + hid;
		::Wuxia.Alchemy.Cabinet.addCount("herb:" + hid, 1, sc, hid);
		try { gotNames.push(::new(sc).getName()); } catch (_e) { gotNames.push(hid); }
	}

	return {
		ok      = true,
		message = "药庐采买：耗银 " + cost + " 两购得本门道地灵草【" + gotNames[0] + "】【" + gotNames[1] + "】，已直接归入【百草药柜】（可用于盲炉试丹）！"
	};
};
