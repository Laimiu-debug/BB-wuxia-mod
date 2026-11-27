// Four Exclusive Wuxia Sect Sanctuary Halls (`山门专属四大堂口` — only available at Independent Mountain Gates `location.wx_sect_sanctum`):
//   1. 【演武校场】闯护山大阵 (Non-Lethal Tactical Formation Trial — 点到为止绝不死人) & 生死踢馆 (Full Lethal Sect Raid)
//   2. 【求贤堂】延请本门真传弟子下山入队 (Authentic Sect Disciple Recruitment)
//   3. 【传功堂 & 疗伤禅房】长老灌顶注入火候 & 运功拔除经脉内伤/散功虚弱
//   4. 【知客堂 & 本门药庐】接领/缴还宗门法帖试炼 & 分阶限供本门道地《山海本草》灵药

// Active non-lethal Mountain Gate Trial combat state (protects players from death, permanent injuries & Game Over)
::Wuxia.SectRelations.ActiveTrial <- null;

// Curated Apothecary Herb Catalog per Sect/Region:
//   - Strictly forbids Potency 5 Mythic Immortal Herbs (`紫芝/扶桑/不死草/建木/月桂`) and `洗髓血芝` (`wx_marrow_herb`) from purchase!
//   - `common` (交情 >= 20, 420两 / 2株, 4日冷却): Regional Potency 2~3 herbs only
//   - `rare`   (交情 >= 50, 980两 / 1株, 7日冷却): Sect-curated Potency 4 herbs only (never P5 / marrow herb!)
::Wuxia.SectRelations.ForbiddenShopHerbs <- {
	wx_marrow_herb = true,
	wx_herb_zizhi  = true,
	wx_herb_fusang = true,
	wx_herb_busicao = true,
	wx_herb_jianmu = true,
	wx_herb_yuegui = true
};

::Wuxia.SectRelations.getSectApothecaryCatalog <- function( _sectID )
{
	local sDef = (_sectID in ::Wuxia.Config.Sects) ? ::Wuxia.Config.Sects[_sectID] : null;
	local reg = (sDef != null && "Region" in sDef) ? sDef.Region : "mountains";

	local common = null;
	local rare   = null;
	if (_sectID == "shaolin" || _sectID == "taihe")
	{
		common = ["wx_herb_dixiu", "wx_herb_zhichu", "wx_herb_pincao", "wx_herb_sutiao"];
		rare   = ["wx_herb_danmu", "wx_herb_wuzhi"];
	}
	else if (_sectID == "xuanbing" || reg == "snow")
	{
		common = ["wx_herb_huangguan", "wx_herb_jiancao", "wx_herb_xuanji", "wx_herb_hanshui"];
		rare   = ["wx_herb_xuelian", "wx_herb_bingpocao"];
	}
	else if (_sectID == "wudu" || _sectID == "tangmen" || reg == "forest")
	{
		common = ["wx_herb_mangcao", "wx_herb_gouwen", "wx_herb_guimu", "wx_herb_jiarong", "wx_herb_duheng"];
		rare   = ["wx_herb_guicao", "wx_herb_zhenyu"];
	}
	else if (_sectID == "shenji" || _sectID == "yinsha" || reg == "desert")
	{
		common = ["wx_herb_wutiao", "wx_herb_gurong", "wx_herb_zhuyu", "wx_herb_zhugu"];
		rare   = ["wx_herb_longxuejie", "wx_herb_huolingzhi"];
	}
	else if (_sectID == "gaibang" || _sectID == "jiujie" || reg == "swamp")
	{
		common = ["wx_herb_tiaocao", "wx_herb_migu", "wx_herb_bili", "wx_herb_longchu"];
		rare   = ["wx_herb_panmu", "wx_herb_xunmu"];
	}
	else if (reg == "mountains")
	{
		common = ["wx_herb_dixiu", "wx_herb_zhichu", "wx_herb_baiman", "wx_herb_yaocao"];
		rare   = ["wx_herb_langgan", "wx_herb_danmu"];
	}
	else
	{
		common = ["wx_herb_pincao", "wx_herb_gurong", "wx_herb_zhuyu", "wx_herb_xuncao", "wx_herb_yaocao"];
		rare   = ["wx_herb_heshouwu", "wx_herb_yinglu"];
	}

	return {
		common      = common,
		commonCost  = 420,
		commonQty   = 2,
		commonRel   = 20,
		commonCdMax = 4,
		rare        = rare,
		rareCost    = 980,
		rareQty     = 1,
		rareRel     = 50,
		rareCdMax   = 7
	};
};

::Wuxia.SectRelations.describeHerbIds <- function( _ids )
{
	local out = [];
	if (_ids == null) return out;
	foreach (hid in _ids)
	{
		local nm = hid;
		local natName = "";
		local pot = 2;
		if ("Alchemy" in ::Wuxia.Config && "HerbNatures" in ::Wuxia.Config.Alchemy && (hid in ::Wuxia.Config.Alchemy.HerbNatures))
		{
			local hn = ::Wuxia.Config.Alchemy.HerbNatures[hid];
			pot = hn.Potency;
			if (hn.Nature in ::Wuxia.Config.Alchemy.Natures)
				natName = ::Wuxia.Config.Alchemy.Natures[hn.Nature].Short;
		}
		if ("Herbs" in ::Wuxia.Config && (hid in ::Wuxia.Config.Herbs))
		{
			nm = ::Wuxia.Config.Herbs[hid].Name;
		}
		else
		{
			try { nm = ::new("scripts/items/misc/" + hid).getName(); } catch (_e) {}
		}
		out.push({ id = hid, name = nm, natureShort = natName, potency = pot });
	}
	return out;
};

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
	local loot = sanctum.getLoot();
	loot.clear();

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
	if (manualIDs.len() > 0)
	{
		if (isRaid && bestManualID != "" && !vaultLooted)
		{
			local fullBook = ::new("scripts/items/misc/wx_manual_item");
			fullBook.initManual(bestManualID);
			loot.add(fullBook);
		}
		local pageMid = manualIDs[::Math.rand(0, manualIDs.len() - 1)];
		local pages = ::new("scripts/items/misc/wx_page_item");
		pages.initPages(pageMid, isRaid ? (vaultLooted ? 1 : 3) : 2);
		loot.add(pages);
	}

	local herbPool = isRaid
		? ::Wuxia.SectRelations.getSectRegionalHerbs(_sectID)
		: ::Wuxia.SectRelations.getSectApothecaryCatalog(_sectID).common;
	if (herbPool.len() > 0)
	{
		local herbCnt = isRaid ? (vaultLooted ? 1 : 2) : 1;
		for (local hi = 0; hi < herbCnt; hi = ++hi)
		{
			local hId = herbPool[::Math.rand(0, herbPool.len() - 1)];
			loot.add(::new("scripts/items/misc/" + hId));
		}
	}

	local silver = ::new("scripts/items/supplies/money_item");
	silver.setAmount(isRaid ? (vaultLooted ? 600 : 1400) : 500);
	loot.add(silver);

	sanctum.setFaction(banditFac.getID());
	sanctum.m.LocationType = ::Const.World.LocationType.Lair | ::Const.World.LocationType.Unique;
	sanctum.m.IsShowingDefenders = true;
	sanctum.m.CombatLocation.Template = isRaid ? ["tactical.human_camp"] : [null, null];
	sanctum.m.CombatLocation.Fortification = isRaid ? ::Const.Tactical.FortificationType.Palisade : ::Const.Tactical.FortificationType.None;
	sanctum.m.CombatLocation.ForceLineBattle = !isRaid;
	sanctum.m.WX_BattleMode = isRaid ? "raid" : "trial";
	sanctum.m.WX_AllowCombatEnter = true;
	sanctum.WX_RefreshSanctumVisuals();

	if (!isRaid)
		::Wuxia.SectRelations.beginActiveTrial(_sectID, sanctum);
	else
		::Wuxia.SectRelations.ActiveTrial = null;

	if (!::World.State.enterLocation(sanctum))
	{
		::Wuxia.SectRelations.ActiveTrial = null;
		sanctum.WX_ResetPeacefulState();
		return { ok = false, reason = "当前无法进入山门战斗，请稍后再试。" };
	}
	::World.Flags.set("wx_active_sanctum_sect", "");

	return {
		ok         = true,
		closeModal = true,
		message    = isRaid ? ("拔刃踢馆：已向【" + sect.Name + "】山门发起强攻！") : ("登坛闯阵：已踏入【" + sect.Name + "】护山大阵（点到为止，绝不死人）！")
	};
};

// Non-lethal Mountain Gate Trial protection (`闯护山大阵` — zero death, zero permanent injury, no Game Over on defeat)
::Wuxia.SectRelations.beginActiveTrial <- function( _sectID, _sanctum )
{
	local snapInj = {};
	local snapHP  = {};
	local snapInt = {};
	if (::Wuxia.hasWorldField("getPlayerRoster") && ::World.getPlayerRoster() != null)
	{
		foreach (b in ::World.getPlayerRoster().getAll())
		{
			if (b == null || !b.isAlive()) continue;
			local bid = b.getID();
			if (b.getFlags() != null) b.getFlags().set("WX_TrialOut", false);
			snapHP[bid] <- b.getHitpoints();
			local injMap = {};
			local sk = b.getSkills();
			if (sk != null)
			{
				foreach (tType in [::Const.SkillType.TemporaryInjury, ::Const.SkillType.PermanentInjury])
				{
					local list = sk.getAllSkillsOfType(tType);
					if (list != null)
					{
						foreach (inSk in list)
							if (inSk != null) injMap[inSk.getID()] <- true;
					}
				}
				local intSk = sk.getSkillByID("effects.wx_internal_injury");
				if (intSk != null)
					snapInt[bid] <- { severity = intSk.m.Severity, days = intSk.m.DaysRemaining,
						scars = intSk.m.PermanentScars, explicitDuration = intSk.m.WX_HasExplicitDuration };
			}
			snapInj[bid] <- injMap;
		}
	}
	::Wuxia.SectRelations.ActiveTrial = {
		sectID      = _sectID,
		sanctum     = _sanctum,
		knockedOut  = {},
		preInjuries = snapInj,
		preHP       = snapHP,
		preInternal = snapInt
	};
};

::Wuxia.SectRelations.isTrialCombatActive <- function()
{
	local ctx = ::Wuxia.SectRelations.ActiveTrial;
	if (ctx == null || !("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive())
		return false;
	local props = ::Tactical.State.getStrategicProperties();
	if (props != null && !props.IsArenaMode)
	{
		foreach (p in props.Parties)
		{
			if (::Wuxia.hasMember(p, "WX_GetBattleMode") && p.WX_GetBattleMode() == "trial" && p.getID() == ctx.sanctum.getID())
				return true;
		}
	}
	return false;
};

::Wuxia.SectRelations.trialPlayerKnockout <- function( _actor, _killer, _skill )
{
	if (_actor == null) return;
	if (_actor.getFlags() != null && _actor.getFlags().get("WX_TrialOut")) return;
	if (_actor.getFlags() != null) _actor.getFlags().set("WX_TrialOut", true);

	if (::Wuxia.SectRelations.ActiveTrial != null && ::Wuxia.hasMember(_actor, "getID"))
		::Wuxia.SectRelations.ActiveTrial.knockedOut[_actor.getID()] <- true;

	_actor.m.IsAlive = true;
	_actor.m.IsDying = false;
	_actor.m.IsTurnDone = true;
	local hp = ::Math.max(1, ::Math.round(_actor.getHitpointsMax() * 0.20).tointeger());
	local ctx = ::Wuxia.SectRelations.ActiveTrial;
	if (ctx != null && _actor.getID() in ctx.preHP) hp = ::Math.min(hp, ctx.preHP[_actor.getID()]);
	_actor.m.Hitpoints = hp;

	local sk = _actor.getSkills();
	if (sk != null)
	{
		foreach (dotId in ["effects.bleeding", "effects.goblin_poison", "effects.spider_poison", "effects.acid", "effects.wx_venom", "effects.wx_burn"])
		{
			if (sk.hasSkill(dotId))
				sk.removeByID(dotId);
		}
	}

	if ("EventLog" in ::Tactical && ::Tactical.EventLog != null)
		::Tactical.EventLog.logEx(_actor.getName() + " 气力不支认负退场，护阵长老及时收招点到为止（绝不伤性命）！");
	if ("UI" in ::Wuxia && "playShowcaseSound" in ::Wuxia.UI)
		::Wuxia.UI.playShowcaseSound("cultivate_infuse");

	if (_killer != null && _killer.isAlive() && _killer.getSkills() != null)
		_killer.getSkills().onTargetKilled(_actor, _skill);

	if (::Wuxia.hasMember(_actor, "retreat"))
	{
		try { _actor.retreat(); } catch (_eRet) {}
	}
	if (::Wuxia.hasMember(_actor, "isPlacedOnMap") && _actor.isPlacedOnMap())
	{
		try { _actor.removeFromMap(); } catch (_eRem) {}
	}

	local leftAlive = ::Tactical.Entities.getInstancesOfFaction(::Const.Faction.Player).len();
	if (leftAlive <= 0)
	{
		::Tactical.Entities.setLastCombatResult(::Const.Tactical.CombatResult.PlayerRetreated);
		if (::Wuxia.hasMember(::Tactical.Entities, "checkCombatFinished"))
			::Tactical.Entities.checkCombatFinished();
	}
};

::Wuxia.SectRelations.trialDefenderYield <- function( _actor, _killer, _skill )
{
	if (_actor == null) return;
	if (!_actor.m.IsAlive || (_actor.getFlags() != null && _actor.getFlags().get("WX_TrialOut"))) return;
	if (_actor.getFlags() != null) _actor.getFlags().set("WX_TrialOut", true);

	_actor.m.IsTurnDone = true;
	_actor.m.IsAlive = false;
	_actor.m.IsDying = true;

	if ("EventLog" in ::Tactical && ::Tactical.EventLog != null)
		::Tactical.EventLog.logEx(_actor.getName() + " 拱手认负退下演武场（点到为止）。");

	// Share friendly sparring XP across player roster without gory corpses or looting personal monk robes
	local xpVal = ::Wuxia.hasMember(_actor, "getXPValue") ? _actor.getXPValue() : 120;
	if (xpVal > 0 && ::Wuxia.hasWorldField("getPlayerRoster") && ::World.getPlayerRoster() != null)
	{
		local bros = ::World.getPlayerRoster().getAll();
		local aliveCnt = 0;
		foreach (b in bros) if (b != null && b.isAlive()) aliveCnt += 1;
		if (aliveCnt > 0)
		{
			local share = ::Math.max(12, ::Math.floor(xpVal / aliveCnt));
			foreach (b2 in bros)
			{
				if (b2 != null && b2.isAlive() && ::Wuxia.hasMember(b2, "addXP"))
					b2.addXP(share);
			}
		}
	}

	if (_killer != null && _killer.isAlive() && _killer.getSkills() != null)
		_killer.getSkills().onTargetKilled(_actor, _skill);

	// Vanilla decides whether a location lost by counting its remaining world troops.
	local troop = _actor.m.WorldTroop;
	troop.Party.removeTroop(troop);
	::Tactical.Entities.setLastCombatResult(::Const.Tactical.CombatResult.EnemyDestroyed);
	_actor.removeFromMap();

	if (::Tactical.Entities.getHostilesNum() <= 0)
	{
		if (::Wuxia.hasMember(::Tactical.Entities, "checkCombatFinished"))
			::Tactical.Entities.checkCombatFinished();
	}
};

::Wuxia.SectRelations.finishActiveTrial <- function()
{
	local ctx = ::Wuxia.SectRelations.ActiveTrial;
	::Wuxia.SectRelations.ActiveTrial = null;
	if (ctx == null) return;
	if (!::Wuxia.hasWorldField("getPlayerRoster") || ::World.getPlayerRoster() == null) return;

	foreach (b in ::World.getPlayerRoster().getAll())
	{
		if (b == null) continue;
		local bid = b.getID();
		if (!(bid in ctx.preHP)) continue;
		if (b.getFlags() != null) b.getFlags().set("WX_TrialOut", false);
		b.m.IsAlive = true;
		b.m.IsDying = false;

		local minFloor = ::Math.max(1, ::Math.round(b.getHitpointsMax() * 0.25).tointeger());
		if (bid in ctx.preHP && ctx.preHP[bid] < minFloor)
			minFloor = ::Math.max(1, ctx.preHP[bid]);
		if (b.getHitpoints() < minFloor)
			b.setHitpoints(minFloor);

		local sk = b.getSkills();
		if (sk != null)
		{
			local preSet = (bid in ctx.preInjuries) ? ctx.preInjuries[bid] : {};
			foreach (tType in [::Const.SkillType.TemporaryInjury, ::Const.SkillType.PermanentInjury])
			{
				local curList = sk.getAllSkillsOfType(tType);
				if (curList != null)
				{
					local toRem = [];
					foreach (inSk in curList)
					{
						if (inSk != null && !(inSk.getID() in preSet))
							toRem.push(inSk);
					}
					foreach (rem in toRem)
						sk.remove(rem);
				}
			}
			local intSk = sk.getSkillByID("effects.wx_internal_injury");
			if (intSk != null && !(bid in ctx.preInternal))
				sk.remove(intSk);
			else if (intSk != null)
			{
				local old = ctx.preInternal[bid];
				intSk.m.Severity = old.severity;
				intSk.m.DaysRemaining = old.days;
				intSk.m.PermanentScars = old.scars;
				intSk.m.WX_HasExplicitDuration = old.explicitDuration;
				intSk.updateLabel();
			}
			sk.update();
		}
	}
};

::Wuxia.HooksMod.hook("scripts/entity/tactical/actor", function( q )
{
	if (::Wuxia.qHas(q, "kill"))
	{
		q.kill = @(__original) function( _killer = null, _skill = null, _fatality = 0, _silent = false )
		{
			if (::Wuxia.SectRelations.isTrialCombatActive())
			{
				local ctx = ::Wuxia.SectRelations.ActiveTrial;
				if (this.getID() in ctx.preHP)
				{
					::Wuxia.SectRelations.trialPlayerKnockout(this, _killer, _skill);
					return;
				}
				local troop = this.m.WorldTroop;
				if (troop != null && ("Party" in troop) && troop.Party != null && !troop.Party.isNull() && troop.Party.getID() == ctx.sanctum.getID())
				{
					::Wuxia.SectRelations.trialDefenderYield(this, _killer, _skill);
					return;
				}
			}
			return __original(_killer, _skill, _fatality, _silent);
		};
	}
});

::Wuxia.HooksMod.hook("scripts/states/tactical_state", function( q )
{
	q.gatherLoot = @(__original) function()
	{
		local result = __original();
		if (!::Wuxia.SectRelations.isTrialCombatActive()) return result;
		local gate = ::Wuxia.SectRelations.ActiveTrial.sanctum;
		local outcome = ::Tactical.Entities.getCombatResult();
		// A victory by surrender has no kills to trigger the native location loot drop.
		if ((outcome == ::Const.Tactical.CombatResult.EnemyDestroyed || outcome == ::Const.Tactical.CombatResult.EnemyRetreated)
			&& gate.getTroops().len() == 0 && !gate.getLoot().isEmpty())
		{
			local rewards = [];
			gate.onDropLootForPlayer(rewards);
			foreach (item in rewards) this.m.CombatResultLoot.add(item);
			this.m.CombatResultLoot.sort();
		}
		return result;
	};
});

::Wuxia.HooksMod.hook("scripts/states/world_state", function( q )
{
	q.combat_dialog_module_onCancelPressed = @(__original) function()
	{
		local site = this.m.LastEnteredLocation;
		if (site != null && !site.isNull() && ::Wuxia.hasMember(site, "WX_GetBattleMode") && site.WX_GetBattleMode() != "")
			site.WX_ResetPeacefulState();
		::Wuxia.SectRelations.ActiveTrial = null;
		return __original();
	};

	q.onCombatFinished = @(__original) function()
	{
		local sitesWithDefenders = [];
		local ctx = ::Wuxia.SectRelations.ActiveTrial;
		local hadTrial = false;
		foreach (site in this.m.PartiesInCombat)
		{
			if (::Wuxia.hasMember(site, "WX_GetBattleMode") && site.WX_GetBattleMode() != "" && site.isAlive())
			{
				if (ctx != null && site.WX_GetBattleMode() == "trial" && site.getID() == ctx.sanctum.getID()) hadTrial = true;
				if (site.getTroops().len() > 0)
					sitesWithDefenders.push(site);
			}
		}
		// Restore non-lethal trial state before vanilla renders the post-battle summary screen
		if (hadTrial)
			::Wuxia.SectRelations.finishActiveTrial();
		else
			::Wuxia.SectRelations.ActiveTrial = null;
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

	local recCards = [];
	local cBro = ::Wuxia.Slots.getContainer(bro);
	if (cBro != null)
	{
		for (local si = 0; si < 2 && si < cBro.m.Slots.len(); si = ++si)
		{
			if (cBro.m.Slots[si].ManualID != null)
				recCards.push(::Wuxia.UI.buildManualShowcaseCard(cBro.m.Slots[si].ManualID, si == 0 ? "自带内功" : "自带外功"));
		}
	}
	local rMsg = "求贤得士：奉上安家银 " + cost + " 两，【" + bro.getName() + "】（2 级 · 兼修《" + equippedBookNames[0] + "》《" + equippedBookNames[1] + "》）已拜别师门加入义社！";
	return {
		ok       = true,
		message  = rMsg,
		showcase = {
			kind      = "recruit",
			outcome   = "crit",
			title     = "求贤得士 · 真传入社",
			subtitle  = sect.Name + "真传【" + bro.getName() + "】（2 级）携兵甲武学加入义社",
			bannerImg = ::Wuxia.SectRelations.getSanctumBannerUIPath(_sectID),
			items     = recCards,
			message   = rMsg
		}
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
	local bestManualID = null;

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
				bestManualID = s.ManualID;
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
	local eMsg = "传功灌顶：奉银 " + cost + " 两，【" + sect.Name + "】长老掌抵百会助【" + bestBro.getName() + "】参透《" + bestMName + "》（火候 +" + res.ExpGained + breakNote + "）！";
	local eTierName = (res.NewTier in ::Wuxia.Text.TierNames) ? ::Wuxia.Text.TierNames[res.NewTier] : ("第" + res.NewTier + "重");
	local eCard = bestManualID != null ? ::Wuxia.UI.buildManualShowcaseCard(bestManualID, res.Advanced ? ("突破至 " + eTierName) : ("火候 +" + res.ExpGained)) : null;
	return {
		ok       = true,
		message  = eMsg,
		showcase = {
			kind        = res.Advanced ? "breakthrough" : "empower",
			outcome     = res.Advanced ? "crit" : "great",
			title       = res.Advanced ? ("长老灌顶 · 突破" + eTierName + "！") : "传功长老 · 灌顶指点",
			subtitle    = sect.Name + "宿老真气贯通【" + bestBro.getName() + "】经脉（火候 +" + res.ExpGained + "）",
			broName     = bestBro.getName(),
			expAmount   = res.ExpGained,
			newTier     = res.NewTier,
			newTierName = eTierName,
			items       = eCard != null ? [eCard] : [],
			message     = eMsg
		}
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
	local healedList = [];
	local bros = (::World.getPlayerRoster() != null) ? ::World.getPlayerRoster().getAll() : [];
	foreach (b in bros)
	{
		if (b == null || !b.isAlive() || b.getSkills() == null) continue;
		local sk = b.getSkills();
		local touched = false;
		local curedTags = [];

		if (sk.hasSkill("effects.wx_scatter_weakness"))
		{
			sk.removeByID("effects.wx_scatter_weakness");
			touched = true;
			curedTags.push("散功已清");
		}
		local intInj = sk.getSkillByID("effects.wx_internal_injury");
		if (intInj != null && (intInj.m.Severity > 0 || intInj.m.DaysRemaining > 0))
		{
			intInj.cureTemporary();
			touched = true;
			curedTags.push("内伤尽除");
		}
		local tempWounds = sk.getAllSkillsOfType(::Const.SkillType.TemporaryInjury);
		if (tempWounds != null && tempWounds.len() > 0)
		{
			foreach (tw in tempWounds)
			{
				if (tw != null) sk.remove(tw);
			}
			touched = true;
			curedTags.push("外创尽愈");
		}
		if (b.getHitpoints() < b.getHitpointsMax())
		{
			b.setHitpoints(b.getHitpointsMax());
			touched = true;
			curedTags.push("气血回满");
		}
		if (touched)
		{
			sk.update();
			healedCnt += 1;
			local tagStr = "";
			for (local ti = 0; ti < curedTags.len(); ti = ++ti)
			{
				if (ti > 0) tagStr += " · ";
				tagStr += curedTags[ti];
			}
			healedList.push({ name = b.getName(), tags = tagStr });
		}
	}

	if (healedCnt <= 0)
		return { ok = false, reason = "麾下全体侠客当前经脉畅通、内外无伤，无需运功施治。" };

	::World.Assets.addMoney(-cost);
	::World.Flags.set("wx_tea_heal_" + _sectID, ::World.getTime().Days);

	local healMsg = "真元涤脉：奉银 " + cost + " 两，【" + sect.Name + "】前辈以深厚内力为队中 " + healedCnt + " 名伤患尽数拔除经脉内伤、散功虚弱与外创，气血尽复！";
	return {
		ok       = true,
		message  = healMsg,
		showcase = {
			kind       = "sect_heal",
			outcome    = "warded",
			title      = "真元涤脉 · 妙手回春",
			subtitle   = sect.Name + "前辈运功施治 · 共治愈 " + healedCnt + " 名侠客（耗银 " + cost + " 两）",
			healedList = healedList,
			message    = healMsg
		}
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
		local stashCnt = 0;
		if (::Wuxia.hasWorldField("Assets") && ::World.Assets.getStash() != null)
		{
			foreach (it in ::World.Assets.getStash().getItems())
			{
				if (it != null && it.getID() == ("misc." + herbId))
					stashCnt += 1;
			}
		}
		local totalCnt = cnt + stashCnt;
		local hName = "山海灵草";
		try { hName = ::new("scripts/items/misc/" + herbId).getName(); } catch (_e) {}
		local ready = (totalCnt >= 1);
		return {
			active      = true,
			canComplete = ready,
			cd          = 0,
			label       = ready ? ("奉药缴令 · " + hName + "(可交付!)") : ("采药法帖 · 需" + hName + "(0/1)"),
			detail      = "当前法帖：为本门丹房寻回 1 株【" + hName + "】（药柜/行囊现存：" + totalCnt + " 株）"
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

// Build live tracker payload for all active Sect Sanctum quests (`宗门法帖`) so WorldScreen HUD displays them!
::Wuxia.SectRelations.getAllActiveSanctumQuests <- function()
{
	local out = [];
	if (!("World" in getroottable()) || ::World == null || !("Flags" in ::World) || ::World.Flags == null)
		return out;
	if (!("Config" in ::Wuxia) || !("Sects" in ::Wuxia.Config))
		return out;

	local sectKeys = [];
	foreach (sid, _s in ::Wuxia.Config.Sects)
		sectKeys.push(sid);
	sectKeys.sort();

	local playerTile = (::Wuxia.hasWorldField("State") && ::World.State.getPlayer() != null) ? ::World.State.getPlayer().getTile() : null;
	local sanctumLocBySect = {};
	try
	{
		if (::Wuxia.hasWorldField("EntityManager") && ("getLocations" in ::World.EntityManager))
		{
			foreach (loc in ::World.EntityManager.getLocations())
			{
				if (loc != null && ("m" in loc) && ("WX_SectID" in loc.m) && loc.m.WX_SectID != null && loc.m.WX_SectID != "")
					sanctumLocBySect[loc.m.WX_SectID] <- loc;
			}
		}
	}
	catch (_eLoc) {}

	local dirNames = ["正北", "东北", "东南", "正南", "西南", "西北", "正东", "正西"];
	foreach (sid in sectKeys)
	{
		local qType = ::World.Flags.has("wx_sq_type_" + sid) ? ::World.Flags.getAsInt("wx_sq_type_" + sid) : 0;
		if (qType <= 0) continue;
		local qInfo = ::Wuxia.SectRelations.getSanctumQuestInfo(sid);
		if (qInfo == null || !qInfo.active) continue;

		local sect = ::Wuxia.Config.Sects[sid];
		local locHint = ("HomeRegion" in sect && sect.HomeRegion != null) ? sect.HomeRegion : "独立山门";
		if (sid in sanctumLocBySect)
		{
			local sLoc = sanctumLocBySect[sid];
			local sName = ::Wuxia.hasMember(sLoc, "getName") ? sLoc.getName() : (sect.Name + "山门");
			if (playerTile != null && ::Wuxia.hasMember(sLoc, "getTile") && sLoc.getTile() != null)
			{
				local sTile = sLoc.getTile();
				local dHex = playerTile.getDistanceTo(sTile);
				local dirIdx = playerTile.getDirection8To(sTile);
				local dStr = (dirIdx >= 0 && dirIdx < dirNames.len()) ? dirNames[dirIdx] : "";
				locHint = sName + (dStr != "" ? ("（" + dStr + " " + dHex + " 里）") : "");
			}
			else
			{
				locHint = sName;
			}
		}

		out.push({
			sectID      = sid,
			sectName    = sect.Name,
			qType       = qType,
			canComplete = qInfo.canComplete ? true : false,
			label       = qInfo.label,
			detail      = qInfo.detail,
			locHint     = locHint
		});
	}
	return out;
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
			local herbs = ::Wuxia.SectRelations.getSectApothecaryCatalog(_sectID).common;
			local pickH = herbs[::Math.rand(0, herbs.len() - 1)];
			::World.Flags.set("wx_sq_item_" + _sectID, pickH);
			local hNm = "山海灵草";
			try { hNm = ::new("scripts/items/misc/" + pickH).getName(); } catch (_e) {}
			return {
				ok      = true,
				message = "接领法帖：【" + sect.Name + "】丹房急需 1 株本门道地灵草【" + hNm + "】（存入百草药柜即可回山奉交领赏）！"
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
		if (::Wuxia.Alchemy.Cabinet.getCount("herb:" + herbId) >= 1)
		{
			::Wuxia.Alchemy.Cabinet.addCount("herb:" + herbId, -1);
		}
		else if (::Wuxia.hasWorldField("Assets") && ::World.Assets.getStash() != null)
		{
			::World.Assets.getStash().removeByID("misc." + herbId);
		}
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
	local oldRel = ::Wuxia.SectRelations.getRelation(_sectID);
	local silverReward = inCrisis ? 550 : 420;
	local renownReward = inCrisis ? 60 : 45;

	local newRel = ::Wuxia.SectRelations.addRelation(_sectID, inCrisis ? 27 : 22);
	local relReward = newRel - oldRel;
	::World.Assets.addMoney(silverReward);
	::World.Assets.addBusinessReputation(renownReward);

	local pageNote = "";
	local rewardItems = [];
	if (sect.ShopManuals.len() > 0)
	{
		local rewardMid = sect.ShopManuals[::Math.rand(0, sect.ShopManuals.len() - 1)].ManualID;
		if (rewardMid in ::Wuxia.Config.Manuals)
		{
			local curPg = ::Wuxia.Library.getPageCount(rewardMid);
			::Wuxia.Library.setPageCount(rewardMid, curPg + 1);
			pageNote = "，并获赐《" + ::Wuxia.Config.Manuals[rewardMid].Name + "》残页 ×1（已入藏经阁）";
			rewardItems.push(::Wuxia.UI.buildManualShowcaseCard(rewardMid, "法帖赏赐残页 ×1（已入藏经阁）"));
		}
	}

	local crisisTag = inCrisis ? "（大劫军需战时加赏）" : "";
	local qMsg = "法帖缴令" + crisisTag + "：【" + sect.Name + "】盛赞贵社信义果决！赏纹银 " + silverReward + " 两、江湖威名 +" + renownReward + "、宗门交情 +" + relReward + "（→ " + newRel + "）" + pageNote + "！";
	return {
		ok       = true,
		message  = qMsg,
		showcase = {
			kind      = "quest_reward",
			outcome   = inCrisis ? "crit" : "great",
			title     = "法帖功成 · 宗门封赏" + crisisTag,
			subtitle  = sect.Name + "知客堂验令毕，特赐盘缠威名与本门残卷",
			bannerImg = ::Wuxia.SectRelations.getSanctumBannerUIPath(_sectID),
			rewards   = { silver = silverReward, renown = renownReward, rel = relReward, newRel = newRel },
			items     = rewardItems,
			message   = qMsg
		}
	};
};

::Wuxia.SectRelations.sanctumBuyHerbs <- function( _sectID, _tier = "common" )
{
	if (!(_sectID in ::Wuxia.Config.Sects))
		return { ok = false, reason = "未找到该江湖宗门。" };

	local meet = ::Wuxia.SectRelations.resolveActiveMeeting(_sectID);
	if (!meet.Ok || !meet.AtSanctum)
		return { ok = false, reason = ("Sealed" in meet && meet.Sealed) ? meet.Reason : "唯有亲临宗门山门【本门药庐】，方能采买秘植道地灵草。" };

	local sect = ::Wuxia.Config.Sects[_sectID];
	local cat = ::Wuxia.SectRelations.getSectApothecaryCatalog(_sectID);
	local isRare = (_tier == "rare");
	local minRel = isRare ? cat.rareRel : cat.commonRel;
	local cdDays = isRare ? cat.rareCdMax : cat.commonCdMax;
	local cdKey  = isRare ? "herb_rare" : "herb";
	local cost   = isRare ? cat.rareCost : cat.commonCost;
	local qty    = isRare ? cat.rareQty : cat.commonQty;
	local rawPool = isRare ? cat.rare : cat.common;

	local rel = ::Wuxia.SectRelations.getRelation(_sectID);
	if (rel < minRel)
		return { ok = false, reason = "需与本门交情达 " + minRel + " 以上，药庐执事方肯匀售" + (isRare ? "镇庐珍株" : "常备道地灵草") + "（当前：" + rel + "）。" };

	local cd = ::Wuxia.SectRelations.getTeaCooldownLeft(cdKey, _sectID, cdDays);
	if (cd > 0)
		return { ok = false, reason = (isRare ? "本门镇庐珍株尚在育苗采撷，请隔 " : "本门药圃常备灵草尚在采摘晾晒，请隔 ") + cd + " 日再来选购。" };

	if (::World.Assets.getMoney() < cost)
		return { ok = false, reason = "采买" + (isRare ? "镇庐珍株" : "本门道地灵草") + "需纹银 " + cost + " 两。" };

	// Strictly filter out forbidden mythic P5 / marrow herbs as a hard safety invariant
	local pool = [];
	foreach (hCand in rawPool)
	{
		if (hCand in ::Wuxia.SectRelations.ForbiddenShopHerbs) continue;
		pool.push(hCand);
	}
	if (pool.len() == 0)
		return { ok = false, reason = "本门药庐暂无可对外匀售之灵草存货。" };

	::World.Assets.addMoney(-cost);
	::World.Flags.set("wx_tea_" + cdKey + "_" + _sectID, ::World.getTime().Days);

	// Pick distinct herbs when qty > 1 and pool has enough variety
	local avail = clone pool;
	local gotNames = [];
	local herbCards = [];
	for (local i = 0; i < qty; i = ++i)
	{
		if (avail.len() == 0) avail = clone pool;
		local pickIdx = ::Math.rand(0, avail.len() - 1);
		local hid = avail[pickIdx];
		avail.remove(pickIdx);
		local sc = "scripts/items/misc/" + hid;
		::Wuxia.Alchemy.Cabinet.addCount("herb:" + hid, 1, sc, hid);
		try
		{
			local hObj = ::new(sc);
			local hName = hObj.getName();
			local hIco = hObj.getIcon();
			if (hIco != null && hIco != "" && hIco.find("ui/") != 0) hIco = "ui/items/" + hIco;
			local hDesc = hObj.getDescription();
			gotNames.push(hName);
			herbCards.push({
				isPill      = true,
				name        = hName,
				icon        = hIco,
				grade       = isRare ? 3 : 2,
				gradeTitle  = isRare ? "镇庐珍株" : "道地灵草",
				gradeColor  = isRare ? "#b58ae6" : "#5ec47a",
				description = hDesc
			});
		}
		catch (_e)
		{
			gotNames.push(hid);
		}
	}

	local joined = "";
	for (local g = 0; g < gotNames.len(); g = ++g)
		joined += "【" + gotNames[g] + "】";
	local hMsg = (isRare ? "药庐求珍：耗银 " : "药庐采买：耗银 ") + cost + " 两购得本门限供" + (isRare ? "镇庐奇草" : "道地灵草") + joined + "，已直接归入【百草药柜】！";
	return {
		ok       = true,
		message  = hMsg,
		showcase = {
			kind     = "herbs_gain",
			outcome  = isRare ? "great" : "success",
			title    = isRare ? "山门药庐 · 获匀镇庐珍株" : "山门药庐 · 采得道地灵草",
			subtitle = sect.Name + "药圃限供 · 已直接清点归入【百草药柜】",
			items    = herbCards,
			message  = hMsg
		}
	};
};
