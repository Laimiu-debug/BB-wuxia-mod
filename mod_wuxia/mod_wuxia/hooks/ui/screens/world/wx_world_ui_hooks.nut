// World, Town Shop, Relations, Post-Battle Loot & Attribute Tooltip Synchronization Hooks

::Wuxia.HooksMod.hook("scripts/ui/screens/world/modules/topbar/world_screen_topbar_options_module", function( q )
{
	::Wuxia.UI.attachSectTeaHouseRPCs(q, false, true);
});

::Wuxia.HooksMod.hook("scripts/ui/screens/world/world_screen", function( q )
{
	::Wuxia.UI.attachSectTeaHouseRPCs(q, false, true);
});

::Wuxia.HooksMod.hook("scripts/ui/screens/world/world_relations_screen", function( q )
{
	::Wuxia.UI.attachSectTeaHouseRPCs(q, false, false);
});

::Wuxia.HooksMod.hook("scripts/ui/screens/world/modules/world_town_screen/town_tavern_dialog_module", function( q )
{
	::Wuxia.UI.attachSectTeaHouseRPCs(q, true, false);
});

// Town Disguise & Appearance Pavilion (`铜镜江湖易容阁` — 1000-Faces Wuxia Customization + Rename + Jianghu Vendetta/Official Disguise)
::Wuxia.HooksMod.hook("scripts/ui/screens/world/modules/world_town_screen/town_barber_dialog_module", function( q )
{
	if (::Wuxia.qHas(q, "queryRosterInformation"))
	{
		q.queryRosterInformation = @(__original) function()
		{
			local ret = __original();
			if (ret != null && typeof ret == "table")
			{
				ret.Title    <- "铜镜江湖易容阁";
				ret.SubTitle <- "千面修容改换冠发名号 · 敛息潜踪消解江湖恩怨";
			}
			return ret;
		};
	}

	if (::Wuxia.qHas(q, "onEntrySelected"))
	{
		q.onEntrySelected = @(__original) function( _entityID )
		{
			local bro = this.WX_FindBro(_entityID);
			if (bro != null)
			{
				::Wuxia.Appearance.getOrInitState(bro);
				::Wuxia.Appearance.refreshActorSprites(bro);
				return bro.getImagePath();
			}
			return __original(_entityID);
		};
	}

	if (::Wuxia.qHas(q, "onChangeAppearance"))
	{
		q.onChangeAppearance = @(__original) function( _entityID )
		{
			local bro = this.WX_FindBro(_entityID);
			if (bro != null)
			{
				::Wuxia.Appearance.refreshActorSprites(bro);
			}
			if ("WorldVisuals" in ::Wuxia && "syncPlayerLeadAppearance" in ::Wuxia.WorldVisuals)
				::Wuxia.WorldVisuals.syncPlayerLeadAppearance();
			if (bro != null)
				return bro.getImagePath();
			return __original(_entityID);
		};
	}

	q.WX_FindBro <- function( _id )
	{
		if (!("World" in getroottable()) || ::World == null || ::World.getPlayerRoster() == null)
			return null;
		local roster = ::World.getPlayerRoster().getAll();
		if (roster == null || roster.len() == 0)
			return null;
		if (_id != null && _id != 0)
		{
			foreach (b in roster)
			{
				if (b != null && b.getID() == _id)
					return b;
			}
		}
		return roster[0];
	};

	q.WX_GetDisguiseCooldown <- function( _key, _cooldownDays )
	{
		if (!("World" in getroottable()) || ::World == null || !("Flags" in ::World) || ::World.Flags == null)
			return 0;
		if (!::World.Flags.has(_key))
			return 0;
		local lastDay = ::World.Flags.getAsInt(_key);
		local curDay  = ::World.getTime().Days;
		return ::Math.max(0, _cooldownDays - (curDay - lastDay));
	};

	q.WX_BuildDisguiseData <- function( _bro )
	{
		if (_bro == null)
			return { ok = false, reason = "未找到该名侠客。" };

		local st = ::Wuxia.Appearance.getOrInitState(_bro);
		::Wuxia.Appearance.refreshActorSprites(_bro);
		local labels = ::Wuxia.Appearance.getLabelsForState(st, _bro);

		local money = ("World" in getroottable() && ::World != null && ::World.Assets != null) ? ::World.Assets.getMoney() : 0;
		local curDay = ("World" in getroottable() && ::World != null && ::World.getTime() != null) ? ::World.getTime().Days : 1;
		local ignoreFeud = ("World" in getroottable() && ::World != null && ::World.Assets != null && ::World.Assets.getOrigin() != null && ::World.Assets.getOrigin().getID() == "scenario.wx_origin_blood_remnant");
		local hasBloodFeud     = false;
		local hostileSectCount = 0;
		local vendettaCount    = 0;
		local hostileNames     = [];

		if ("Sects" in ::Wuxia.Config && "SectRelations" in ::Wuxia)
		{
			foreach (sid, sdef in ::Wuxia.Config.Sects)
			{
				local rel = ::Wuxia.SectRelations.getRelation(sid);
				if (rel < 0)
				{
					hostileSectCount += 1;
					if (rel <= sdef.VendettaRel)
						vendettaCount += 1;
					if (!ignoreFeud && ("World" in getroottable()) && ::World != null && ("Flags" in ::World) && ::World.Flags != null)
					{
						local bfKey = "wx_blood_feud_" + sid;
						if (::World.Flags.has(bfKey) && (curDay - ::World.Flags.getAsInt(bfKey) < 30))
							hasBloodFeud = true;
					}
					if (hostileNames.len() < 3)
						hostileNames.push(sdef.Name + "(" + rel + ")");
				}
			}
		}

		local coldFactionCount = 0;
		local coldFactionName  = "";
		local lowestFacRel     = 999.0;
		if ("World" in getroottable() && ::World != null && "FactionManager" in ::World && ::World.FactionManager != null)
		{
			local facs = ::World.FactionManager.getFactions();
			if (facs != null)
			{
				foreach (f in facs)
				{
					if (f == null) continue;
					local ft = f.getType();
					if (ft != ::Const.FactionType.NobleHouse && ft != ::Const.FactionType.OrientalCityState)
						continue;
					local fRel = f.getPlayerRelation();
					if (fRel < 30.0)
					{
						coldFactionCount += 1;
						if (fRel < lowestFacRel)
						{
							lowestFacRel    = fRel;
							coldFactionName = f.getName();
						}
					}
				}
			}
		}

		return {
			ok               = true,
			broId            = _bro.getID(),
			name             = _bro.getNameOnly(),
			title            = _bro.getTitle(),
			fullName         = _bro.getName(),
			imagePath        = _bro.getImagePath(),
			labels           = labels,
			money            = money,
			hostileSectCount = hostileSectCount,
			vendettaCount    = vendettaCount,
			hostileSectNames = hostileNames,
			coldFactionCount = coldFactionCount,
			coldFactionName  = coldFactionName,
			vendettaCost     = hasBloodFeud ? 900 : 600,
			disguiseCd       = this.WX_GetDisguiseCooldown("wx_disguise_vendetta_day", 5),
			officialCd       = this.WX_GetDisguiseCooldown("wx_disguise_faction_day", 7)
		};
	};

	q.onWXBarberGetState <- function( _data )
	{
		local broID = (typeof _data == "array" && _data.len() > 0) ? _data[0] : _data;
		return this.WX_BuildDisguiseData(this.WX_FindBro(broID));
	};

	q.onWXBarberStepPart <- function( _data )
	{
		if (_data == null || typeof _data != "array" || _data.len() < 3)
			return { ok = false, reason = "参数缺失。" };
		local bro = this.WX_FindBro(_data[0]);
		if (bro == null)
			return { ok = false, reason = "未找到该名侠客。" };

		::Wuxia.Appearance.stepAppearance(bro, "" + _data[1], _data[2]);
		if ("WorldVisuals" in ::Wuxia && "syncPlayerLeadAppearance" in ::Wuxia.WorldVisuals)
			::Wuxia.WorldVisuals.syncPlayerLeadAppearance();

		return this.WX_BuildDisguiseData(bro);
	};

	q.onWXBarberRename <- function( _data )
	{
		if (_data == null || typeof _data != "array" || _data.len() < 3)
			return { ok = false, reason = "参数缺失。" };
		local bro = this.WX_FindBro(_data[0]);
		if (bro == null)
			return { ok = false, reason = "未找到该名侠客。" };

		local newName  = _data[1] != null ? strip("" + _data[1]) : "";
		local newTitle = _data[2] != null ? strip("" + _data[2]) : "";
		if (newName == "")
			return { ok = false, reason = "侠客本名不可为空。" };

		bro.setName(newName);
		bro.setTitle(newTitle);

		local res = this.WX_BuildDisguiseData(bro);
		res.actionMessage <- "铜镜易名：已将此侠改换名号为【" + bro.getName() + "】！";
		return res;
	};

	q.onWXBarberClearVendetta <- function( _data )
	{
		local broID = (typeof _data == "array" && _data.len() > 0) ? _data[0] : _data;
		local bro = this.WX_FindBro(broID);
		if (!("World" in getroottable()) || ::World == null || ::World.Assets == null)
			return { ok = false, reason = "当前无法访问义社盘缠。" };

		local cd = this.WX_GetDisguiseCooldown("wx_disguise_vendetta_day", 5);
		if (cd > 0)
			return { ok = false, reason = "风声未平：还需隔 " + cd + " 日方可再次施展秘术易容敛息。" };

		local curDay = ::World.getTime().Days;
		local ignoreFeud = (::World.Assets.getOrigin() != null && ::World.Assets.getOrigin().getID() == "scenario.wx_origin_blood_remnant");
		local cands = [];
		local hasBloodFeud = false;
		foreach (sid, sdef in ::Wuxia.Config.Sects)
		{
			local rel = ::Wuxia.SectRelations.getRelation(sid);
			if (rel < 0)
			{
				local bfKey = "wx_blood_feud_" + sid;
				local isFeud = !ignoreFeud && ::World.Flags.has(bfKey) && (curDay - ::World.Flags.getAsInt(bfKey) < 30);
				if (isFeud) hasBloodFeud = true;
				cands.push({ id = sid, name = sdef.Name, rel = rel, feud = isFeud });
			}
		}
		if (cands.len() == 0)
			return { ok = false, reason = "当前与九州各派并无恶交或寻仇追杀令，无需耗银敛息。" };

		local cost = hasBloodFeud ? 900 : 600;
		if (::World.Assets.getMoney() < cost)
			return { ok = false, reason = "纹银不足（" + (hasBloodFeud ? "血洗山门风声极紧，易容避祸需 " : "施展秘术易容敛息需 ") + cost + " 两纹银）。" };

		cands.sort(function( _a, _b ) {
			if (_a.rel != _b.rel) return _a.rel < _b.rel ? -1 : 1;
			return _a.id <=> _b.id;
		});

		::World.Assets.addMoney(-cost);
		::World.Flags.set("wx_disguise_vendetta_day", curDay);

		local easedNames = [];
		local despawnedHunt = 0;
		local feudCapped = false;
		local limit = ::Math.min(2, cands.len());
		for (local i = 0; i < limit; i = ++i)
		{
			local entry = cands[i];
			local maxEase = entry.feud ? 8 : 22;
			if (entry.feud) feudCapped = true;
			local gain = ::Math.min(maxEase, -entry.rel);
			local afterRel = ::Wuxia.SectRelations.addRelation(entry.id, gain, true);
			::Wuxia.SectRelations.discoverSect(entry.id);
			easedNames.push("【" + entry.name + "】(" + entry.rel + "→" + afterRel + (entry.feud ? "·血仇未平" : "") + ")");

			local huntFlag = "wx_hunt_" + entry.id + "_id";
			if (::World.Flags.has(huntFlag))
			{
				local hid = ::World.Flags.getAsInt(huntFlag);
				if (hid > 0)
				{
					local hParty = ::World.getEntityByID(hid);
					if (hParty != null && !hParty.isNull() && hParty.isAlive() && !hParty.isInCombat())
					{
						hParty.fadeOutAndDie();
						despawnedHunt += 1;
					}
				}
				::World.Flags.set(huntFlag, 0);
			}
		}

		local res = this.WX_BuildDisguiseData(bro);
		local feudNote = feudCapped ? "（踢馆血仇非一纸易容可尽消，仅暂缓少许风声）" : "";
		res.actionMessage <- "易容敛息：耗银 " + cost + " 两改换形貌暗记，已消解 " + easedNames[0] + (easedNames.len() > 1 ? ("、" + easedNames[1]) : "") + " 之追缉敌意" + (despawnedHunt > 0 ? "，并甩脱城外追杀执事队！" : "！") + feudNote;
		return res;
	};

	q.onWXBarberEaseFaction <- function( _data )
	{
		local broID = (typeof _data == "array" && _data.len() > 0) ? _data[0] : _data;
		local bro = this.WX_FindBro(broID);
		if (!("World" in getroottable()) || ::World == null || ::World.Assets == null)
			return { ok = false, reason = "当前无法访问义社盘缠。" };

		local cd = this.WX_GetDisguiseCooldown("wx_disguise_faction_day", 7);
		if (cd > 0)
			return { ok = false, reason = "驿路盘查尚严：还需隔 " + cd + " 日方可再次托暗桩打点官凭。" };

		local cost = 800;
		if (::World.Assets.getMoney() < cost)
			return { ok = false, reason = "纹银不足（伪造路引打点藩镇官凭需 " + cost + " 两纹银）。" };

		local bestFac = null;
		local lowestRel = 999.0;
		local facs = ::World.FactionManager.getFactions();
		if (facs != null)
		{
			foreach (f in facs)
			{
				if (f == null) continue;
				local ft = f.getType();
				if (ft != ::Const.FactionType.NobleHouse && ft != ::Const.FactionType.OrientalCityState)
					continue;
				local fRel = f.getPlayerRelation();
				if (fRel < 30.0 && fRel < lowestRel)
				{
					lowestRel = fRel;
					bestFac   = f;
				}
			}
		}
		if (bestFac == null)
			return { ok = false, reason = "当前与各大地方藩镇及西域都护府关系尚佳（皆 ≥30），无需打点官凭。" };

		::World.Assets.addMoney(-cost);
		::World.Flags.set("wx_disguise_faction_day", ::World.getTime().Days);
		bestFac.addPlayerRelation(12.0, "易容改换路引、托暗桩周旋");

		local res = this.WX_BuildDisguiseData(bro);
		res.actionMessage <- "伪造官凭：耗银 " + cost + " 两托驿馆暗桩换发路引，【" + bestFac.getName() + "】对义社之盘查敌意已显著缓和（关系 +12）！";
		return res;
	};

	if (::Wuxia.qHas(q, "onUpdateAppearance"))
	{
		q.onUpdateAppearance = @(__original) function( _data )
		{
			if (_data != null && typeof _data == "array" && _data.len() >= 3)
			{
				local bro = this.WX_FindBro(_data[0]);
				if (bro != null)
				{
					local layerId = "" + _data[1];
					local dir     = _data[2];
					local partMap = {
						head   = "face",
						hair   = "hair",
						color  = "tone",
						beard  = "beard",
						tattoo = "scar",
						body   = "random"
					};
					local wxPart = (layerId in partMap) ? partMap[layerId] : "face";
					::Wuxia.Appearance.stepAppearance(bro, wxPart, dir);
					if ("WorldVisuals" in ::Wuxia && "syncPlayerLeadAppearance" in ::Wuxia.WorldVisuals)
						::Wuxia.WorldVisuals.syncPlayerLeadAppearance();
					return bro.getImagePath();
				}
			}
			return __original(_data);
		};
	}
});

// Town Shop: 1-click sweep into 藏经阁 + auto-sweep newly purchased manuals/pages on leaving shop (respecting WithdrawnForSale)
::Wuxia.HooksMod.hook("scripts/ui/screens/world/modules/world_town_screen/town_shop_dialog_module", function( q )
{
	q.onWXSweepShopManuals <- function( _data = null )
	{
		if (!("World" in getroottable()) || ::World == null || ::World.Assets == null)
			return { ok = false, reason = "当前无法访问战团仓库。" };

		local stash = ::World.Assets.getStash();
		local moved = ::Wuxia.Library.storeAllFromStash(stash, true);
		local msg = "";
		if (moved.booksMoved > 0 || moved.pagesMoved > 0)
		{
			local parts = [];
			if (moved.booksMoved > 0) parts.push(moved.booksMoved + " 册秘籍");
			if (moved.pagesMoved > 0) parts.push(moved.pagesMoved + " 张残页");
			msg = "已将仓库内 " + parts[0] + (parts.len() > 1 ? ("、" + parts[1]) : "") + " 归入【藏经阁】，释放 " + moved.slotsCleared + " 格仓库空间！";
		}
		else
		{
			msg = "当前战团仓库中暂无可收纳的秘籍或残页。";
		}

		local stashUI = ::UIDataHelper.convertStashToUIData(false, this.m.InventoryFilter);
		return {
			ok             = true,
			movedCount     = moved.booksMoved + moved.pagesMoved,
			actionMessage  = msg,
			Stash          = stashUI,
			StashSpaceUsed = stash.getNumberOfFilledSlots(),
			StashSpaceMax  = stash.getCapacity()
		};
	};

	if (::Wuxia.qHas(q, "onLeaveButtonPressed"))
	{
		q.onLeaveButtonPressed = @(__original) function()
		{
			if (::Wuxia.Library.isAutoStoreEnabled() && ("World" in getroottable()) && ::World != null && ::World.Assets != null)
			{
				local stash = ::World.Assets.getStash();
				if (stash != null)
					::Wuxia.Library.storeAllFromStash(stash, false);
			}
			__original();
		};
	}
});

// Post-Battle Combat Result Screen: Protect dropped manuals/pages from full-Stash loss by sweeping directly into 藏经阁!
::Wuxia.HooksMod.hook("scripts/ui/screens/tactical/tactical_combat_result_screen", function( q )
{
	q.WX_sweepLootAndStashToLibrary <- function( _includeWithdrawn = false )
	{
		local booksMoved = 0;
		local pagesMoved = 0;

		if ("Tactical" in getroottable() && ::Tactical != null && ("CombatResultLoot" in ::Tactical) && ::Tactical.CombatResultLoot != null)
		{
			local lootSweep = ::Wuxia.Library.storeAllFromStash(::Tactical.CombatResultLoot, true);
			booksMoved += lootSweep.booksMoved;
			pagesMoved += lootSweep.pagesMoved;
		}
		if ("World" in getroottable() && ::World != null && ::World.Assets != null && ::World.Assets.getStash() != null)
		{
			local stashSweep = ::Wuxia.Library.storeAllFromStash(::World.Assets.getStash(), _includeWithdrawn);
			booksMoved += stashSweep.booksMoved;
			pagesMoved += stashSweep.pagesMoved;
		}
		return {
			booksMoved = booksMoved,
			pagesMoved = pagesMoved
		};
	};

	q.onWXSweepCombatLootManuals <- function( _data = null )
	{
		local swept = this.WX_sweepLootAndStashToLibrary(true);
		local msg = "";
		if (swept.booksMoved > 0 || swept.pagesMoved > 0)
		{
			local parts = [];
			if (swept.booksMoved > 0) parts.push(swept.booksMoved + " 册秘籍");
			if (swept.pagesMoved > 0) parts.push(swept.pagesMoved + " 张残页");
			msg = "已将战利品与仓库中 " + parts[0] + (parts.len() > 1 ? ("、" + parts[1]) : "") + " 直接归入【藏经阁】（不占仓库格）！";
		}
		else
		{
			msg = "战利品与仓库中暂无可收纳的武学秘籍或残页。";
		}

		local res = {
			ok             = true,
			movedCount     = swept.booksMoved + swept.pagesMoved,
			wxSweepMessage = msg
		};
		if (::Wuxia.hasMember(this, "onQueryStashList"))
			res.stash <- this.onQueryStashList();
		else if ("World" in getroottable() && ::World != null && ::World.Assets != null)
			res.stash <- ::UIDataHelper.convertStashToUIData(false);

		if (::Wuxia.hasMember(this, "onQueryFoundLootList"))
			res.foundLoot <- this.onQueryFoundLootList();
		else if ("Tactical" in getroottable() && ::Tactical != null && ("CombatResultLoot" in ::Tactical) && ::Tactical.CombatResultLoot != null)
			res.foundLoot <- ::UIDataHelper.convertItemsToUIData(::Tactical.CombatResultLoot.getItems(), false, "tactical-combat-result-screen.found-loot");
		return res;
	};

	if (::Wuxia.qHas(q, "onLootAllItemsButtonPressed"))
	{
		q.onLootAllItemsButtonPressed = @(__original) function()
		{
			local preSwept = { booksMoved = 0, pagesMoved = 0 };
			if (::Wuxia.Library.isAutoStoreEnabled())
			{
				preSwept = this.WX_sweepLootAndStashToLibrary(false);
			}
			local ret = __original();
			if (typeof ret == "table" && (preSwept.booksMoved > 0 || preSwept.pagesMoved > 0))
			{
				local parts = [];
				if (preSwept.booksMoved > 0) parts.push(preSwept.booksMoved + " 册秘籍");
				if (preSwept.pagesMoved > 0) parts.push(preSwept.pagesMoved + " 张残页");
				ret.wxSweepMessage <- "缴获的 " + parts[0] + (parts.len() > 1 ? ("、" + parts[1]) : "") + " 已自动归入【藏经阁】（不占仓库格）！";
			}
			return ret;
		};
	}
});

// Synchronize ALL UI Element Hover Tooltips (New Campaign, Character/Tactical Stats, Town Buildings, World Topbar) with Wuxia Lore & Mechanics!
::Wuxia.HooksMod.hook("scripts/ui/screens/tooltip/tooltip_events", function( q )
{
	local wxFullTooltips = {
		// 1. New Campaign Screen (`menu-screen.new-campaign.*`)
		["menu-screen.new-campaign.CompanyName"]              = ["义社名号", "立下你的江湖字号。此名号将书写于聚义竖幅大纛、官府文牒与九州茶肆评书之中。"],
		["menu-screen.new-campaign.StartingScenario"]         = ["江湖出身流派", "择定开山立社的出身来历——不同流派拥有截然不同的初始掌门侠客、独门功法、盘缠与江湖规矩。"],
		["menu-screen.new-campaign.Seed"]                     = ["山河气运种子", "决定九州山川城池、名山秘境与各路豪杰排布的舆图气运字符；输入相同种子即可重历同一片江湖。"],
		["menu-screen.new-campaign.EvilRandom"]               = ["天机莫测（随机大势）", "待义社威名渐盛之时，天下将随机掀起一场席卷九州的武林与朝堂大浩劫；平定首劫后，其余大势亦将陆续登场。"],
		["menu-screen.new-campaign.EvilWar"]                  = ["藩镇节度争霸", "各大地方藩镇节度使拥兵自重、撕破朝廷盟约，披甲长戟大军与神机火器营将在中原展开血腥攻城争霸。"],
		["menu-screen.new-campaign.EvilGreenskins"]           = ["南疆五毒与药人犯境", "南疆五毒奇门伏兵与关外邪派炼体药人合流北上，剧毒吹箭与狂暴巨刃大举席卷中原村镇。"],
		["menu-screen.new-campaign.EvilUndead"]               = ["前朝玄宫尸傀浩劫", "地脉阴煞暴涨，前朝古墓青铜机关兵俑与湘西控魂妖道驱使不惧生死的尸傀大军破土而出，祸乱苍生。"],
		["menu-screen.new-campaign.EvilCrusade"]              = ["西域都护与中原兵燹", "西域绿洲诸城邦与北方藩镇因圣物古迹与商路霸权兵戎相见，南北群豪皆被卷入万里烽烟。"],
		["menu-screen.new-campaign.EvilPermanentDestruction"] = ["兵燹焦土（城池可毁）", "乱世无情：在武林大势浩劫中被乱军、药人或尸傀攻破的村镇城池将化为永久断壁残垣，不再重建。"],
		["menu-screen.new-campaign.EasyDifficulty"]           = ["江湖凶险：初窥门径", "各路绿林匪类与邪派强敌人数较少、境界尚浅，适合初入武侠江湖熟悉七槽内功与外功连招。"],
		["menu-screen.new-campaign.NormalDifficulty"]         = ["江湖凶险：刀口舔血", "标准乱世险恶程度，强敌环伺、高手辈出，一步踏错便有折损同袍之虞。"],
		["menu-screen.new-campaign.HardDifficulty"]           = ["江湖凶险：九死一生", "匪寨重兵云集、成名高手与上古大妖层出不穷，唯有深谙轻重装武学搭配与阵法进退者方能立足。"],
		["menu-screen.new-campaign.EasyDifficultyEconomic"]   = ["行商生计：宽裕", "州府悬赏酬银丰厚，市集粮草与秘籍折价更优，易于养活麾下侠客。"],
		["menu-screen.new-campaign.NormalDifficultyEconomic"] = ["行商生计：常道", "乱世寻常物价与悬赏行情，需精打细算镖资、粮草与购置秘籍丹药之开销。"],
		["menu-screen.new-campaign.HardDifficultyEconomic"]   = ["行商生计：窘迫", "乱世米珠薪桂、委托酬银微薄，市集买卖差价严苛，每一两纹银皆需刀头换取。"],
		["menu-screen.new-campaign.EasyDifficultyBudget"]     = ["起家盘缠：丰厚", "初入江湖时行囊中备有充裕纹银、干粮与百工资材，可从容招揽好手。"],
		["menu-screen.new-campaign.NormalDifficultyBudget"]   = ["起家盘缠：寻常", "携适量盘缠与干粮踏入江湖，需尽早接取州县差事以充实库藏。"],
		["menu-screen.new-campaign.HardDifficultyBudget"]     = ["起家盘缠：囊中羞涩", "开局仅有微薄碎银与数日粗粮，全凭手中兵刃白手起家。"],
		["menu-screen.new-campaign.Ironman"]                  = ["生死无悔（铁人单档）", "江湖落子无悔：全程仅保留单一自动存档，不可手动回档重来，每一次生死抉择皆成定局。"],
		["menu-screen.new-campaign.Exploration"]              = ["迷雾山河（舆图未探）", "九州城池与道路初始隐没于云雾之中，需亲自策马探路寻访各州府重镇。"],

		// 2. Character & Tactical Attributes (`character-stats.*`)
		["character-stats.Hitpoints"]      = ["气血", "侠客肉身气血之本，归零即重伤倒地乃至殒命。轻装修《金蝉卸力》与真气护体可化劲减伤（总上限 60%）；重甲修《铁布衫》可获气血加持与铜头铁额免爆头重创。"],
		["character-stats.ActionPoints"]   = ["招式行动点 (AP)", "每回合走位腾挪与施展外功绝招可用的行动点。常人基准 9 AP，全局常驻硬封顶 11 AP（唯极少数孤本三重大成可破境）。"],
		["character-stats.Fatigue"]        = ["丹田内息", "施展外功招式、轻功身法及格挡受击皆会消耗内息。沉重甲胄与兵刃负重会折损可用内息上限（重甲硬功『披甲行气』可减免负重）；辅修第 2 门内功常驻内息与回气按 50% 折算。"],
		["character-stats.MaximumFatigue"] = ["内息上限", "丹田所能蓄纳的最大真气总量。沉重衣甲与兵刃会占用部分内息上限；主修内功心法决定回气路数（中正/阳刚/阴柔/邪功）与每轮调息回气效率。"],
		["character-stats.Bravery"]        = ["武道定力", "临阵不乱的心性与胆魄。定力不仅抵御战意动摇与邪祟惊魂，更直接提升『洗经伐髓』成功率、满足高阶秘籍突破门槛，并驱动《聚义令》四格稳军心光环。"],
		["character-stats.Initiative"]     = ["轻功身法", "决定每回合出手快慢先后；受当前已耗内息与衣甲负重影响。修习轻功后可将有效身法按比例（15%~20%）实时转化为近身招架与听风避暗。"],
		["character-stats.MeleeSkill"]     = ["近战武艺", "决定刀剑、拳掌、枪戟、锤斧等近身兵刃的命中机率（D100 线性检定，5%~95% 硬边界）。兼修多门外功时常驻武艺加成取最高值，主动招式池可合并。"],
		["character-stats.RangeSkill"]     = ["百步射艺", "决定良弓、强弩、甩手暗器与神机火铳的远距命中机率。配合弓术或唐门暗器谱可施展毒针封穴、流星追月等绝技。"],
		["character-stats.MeleeDefense"]   = ["近身招架", "拆解卸开敌方近身兵刃攻势之机率。由角色根骨、外功守势、手中藤牌铁盾与轻功身法转化共同构筑。"],
		["character-stats.RangeDefense"]   = ["听风避暗", "闪避拨落敌方箭矢、吹箭与飞镖暗器之机率。轻功身法与护身盾牌可大幅提升避暗造诣。"],
		["character-stats.Morale"]         = ["临阵战意", "侠客当下的斗志状态（自信昂扬 → 沉着 → 动摇 → 胆寒 → 溃逃）。战意高涨可获攻防精进，溃败则失魂落魄。"],
		["character-stats.ArmorHead"]      = ["头部护甲", "冠笠兜鍪可替天灵要穴承受兵刃劈刺；一旦护甲碎尽，头部受击将承受额外重创（修习『铜头铁额』可免疫爆头额外倍率）。"],
		["character-stats.ArmorBody"]      = ["身躯护甲", "战袍甲胄可吸收敌方实伤冲击；唯高穿甲内劲拳掌、透甲锥匕与重锤破甲劲力能隔甲伤及肺腑。"],
		["character-stats.RegularDamage"]  = ["兵刃气血伤害", "命中敌手时所造成的基础劈刺内劲伤害区间；若敌方有护甲，将按穿甲率直接透伤气血。"],
		["character-stats.CrushingDamage"] = ["破甲震击效能", "命中护甲时削损敌方甲胄耐久之倍率；锤锏大斧与阳刚重兵尤为擅长摧甲裂盾。"],
		["character-stats.ChanceToHitHead"]= ["取首命中率", "出招直击敌方天灵头部的机率；连枷软鞭与特定外功杀招更易越盾取首。"],
		["character-stats.SightDistance"]  = ["目力视野", "战场可洞察敌踪与施展远射的距离格数；黑夜、密林与覆面重盔会遮蔽目力。"],
		["character-stats.Talent"]         = ["武学根骨星级", "该项属性的天生经脉资质（1★~3★），升级加点时可获更高成长下限；亦可通过服用『洗髓丹』冲星或易筋换星（全身最多维持三项带星根骨）。"],

		// 3. Town Screen Buildings (`world-town-screen.main-dialog-module.*`)
		["world-town-screen.main-dialog-module.Crowd"]        = ["江湖招贤茶摊", "各路走镖趟子手、行脚武僧、退隐剑客与落魄武人在此歇脚寻东家；可查看身价、切磋看相并招揽入伙。"],
		["world-town-screen.main-dialog-module.Marketplace"]  = ["州县百货集市", "南北客商云集的繁华街市，可采买行军干粮、百工修甲资材、箭矢药材及寻常布衣兵刃，亦可售卖战利货物。"],
		["world-town-screen.main-dialog-module.Tavern"]       = ["迎风八方酒楼", "三教九流把酒高歌之地：一楼设『长乐赌桌』（马吊廿一点、四家叶子戏、红四牛骨骰、夜走黑风道等七门博戏）并可向酒保打探山门秘闻与武林大会邸报；二楼特设『江湖茶座』，可与云游各派门人设茗论交、拆招切磋。"],
		["world-town-screen.main-dialog-module.Temple"]       = ["古刹济世医馆", "名医高僧坐堂施诊，可耗费纹银为麾下侠客金针拔毒、正骨接筋，迅速治愈各类跌打刀伤与经脉内伤。"],
		["world-town-screen.main-dialog-module.Weaponsmith"]  = ["百炼神兵铁铺", "炉火纯青的刀剑名匠坐镇，专售百炼长剑、雁翎快刀、破甲重锤、成对拳掌护手及偶现人间的传世红武。"],
		["world-town-screen.main-dialog-module.Armorsmith"]   = ["精工玄甲坊", "裁缝劲装锦袍、锻造山文重甲、扎甲战笠与百炼铁盾的官督甲坊，偶有巧夺天工的名家宝甲压箱。"],
		["world-town-screen.main-dialog-module.Fletcher"]     = ["神机弓弩铺", "专制桑木角弓、踏张劲弩、诸葛连珠弩与满袋雕翎破甲箭矢的巧匠铺面。"],
		["world-town-screen.main-dialog-module.TrainingHall"] = ["讲武堂演武院", "前朝退隐教头开设的演武大院，可出资请名师指点麾下侠客拆招喂招，在数场实战中获得额外武学历练加成。"],
		["world-town-screen.main-dialog-module.Taxidermist"]  = ["百工丹坊", "内设青铜八卦丹炉、百炼铁砧与百草药柜总枢，唯有入此城镇百工坊方可开炉炼丹、重锻神兵、铸造山海护具及取放药柜奇材。"],
		["world-town-screen.main-dialog-module.Alchemist"]    = ["西域火器奇珍局", "售卖霹雳雷火弹、唐门五云烟弹、蚀甲化骨毒瓶、神机手铳火药及西域秘制灵散的奇巧商局。"],
		["world-town-screen.main-dialog-module.Arena"]        = ["红绸生死演武擂 · 武林大会总坛", "内分两道门楼：左门『红绸生死擂』可接三对三赏金死斗契约；右门『天下武林大会』可点选五人登台争魁（点到为止不伤性命），或审阅四十四派与山海奇兽签表、购买单场及六场连环外围红盘银票入席观战！"],
		["world-town-screen.main-dialog-module.Port"]         = ["漕运硬帆官渡口", "可支付船资雇请硬帆福船顺江海航道疾行千里，瞬息往返南北沿海港埠。"],
		["world-town-screen.main-dialog-module.Barber"]       = ["铜镜江湖易容阁", "精修麾下侠客四十八相男女面容、发髻鬓色、胡须战痕与江湖名号；并可耗银『易容敛息』消解宗门追杀令或周旋藩镇官凭。"],
		["world-town-screen.main-dialog-module.Kennel"]       = ["塞外猛獒驯犬坊", "售卖凶悍忠心的关外猛獒与护院猎犬，临阵放出可追剿残敌、牵制弓手。"],
		["world-town-screen.main-dialog-module.Contract"]     = ["官府与乡绅榜文委托", "点击接洽此项江湖差事，商议酬银并听取委托原委（骷髅数代表凶险品阶）。"],
		["world-town-screen.main-dialog-module.ContractNegotiated"] = ["已议定酬银之差事", "已与东家谈妥酬银条款，随时可拍板应承动身。"],
		["world-town-screen.main-dialog-module.ContractLocked"]     = ["威名未显 · 尚难接洽", "此乃地方藩镇或名门重托，需义社江湖威名更高或有茶楼折冲客引荐方肯委任。"],
		["world-town-screen.main-dialog-module.LeaveButton"]        = ["出城起行", "整顿人马离开此城，重返九州大地图。"],

		// 4. World Topbar Assets, Campfire Retinue & Character Screen Buttons
		["assets.Money"]              = ["纹银盘缠", "行囊现存纹银两数，用于发放同袍每日月俸、采买粮草兵甲、请教门派秘籍与炼丹竞拍。"],
		["assets.DailyMoney"]         = ["每日月俸开销", "麾下全体侠客每日所需的饷银合计；银钱断绝将致人心思变、愤然离队。"],
		["assets.Food"]               = ["行军干粮", "随军携行的米面熏肉果脯总量；断粮挨饿将令同袍内息衰弱、怨声载道。"],
		["assets.DailyFood"]          = ["每日口粮消耗", "全队人马每日行军所需的口粮份额。"],
		["assets.Ammo"]               = ["箭矢与火药储备", "战后自动为弓弩、投掷暗器囊与神机火铳补充弹药的随军储备。"],
		["assets.Supplies"]           = ["百工修甲资材", "精铁甲片、熟革麻绳与磨刀石，行军与扎营时自动修复受损兵刃与护甲。"],
		["assets.Medicine"]           = ["金疮灵药储备", "三七金疮散、夹板与汤药，每日自动救治同袍身上的内外创伤与疾病。"],
		["assets.Brothers"]           = ["麾下同袍人数", "义社当前在册侠客人数与上阵/替补编制上限。"],
		["assets.BusinessReputation"] = ["江湖威名", "义社在九州黑白两道闯出的赫赫威名；威名愈盛，可解锁更多随营江湖幕僚席位、接取地方藩镇重托，并赢取更高的差事酬银。"],
		["assets.MoralReputation"]    = ["侠义风评", "义社行事守信抑或心狠手辣的江湖风评，影响部分正邪奇遇走向。"],
		["assets.Ambition"]           = ["当前江湖志向", "义社当下立誓达成的威名志向；功成之日将名动一方、振奋全军斗志。"],
		["character-screen.right-panel-header-module.InventoryButton"] = ["兵甲行囊", "查阅并调配全队公用仓库中的兵刃、甲胄、丹药与山海奇材。"],
		["character-screen.right-panel-header-module.PerksButton"]     = ["武学修为（七槽经脉）", "进入该侠客的七大武学插槽、个人已习武库与洗经伐髓修行界面。"],
		["character-screen.left-panel-header-module.Dismiss"]          = ["遣散归乡", "赠予路费或令该名侠客解甲归田、重返江湖人海。"],
		["world-screen.topbar.options-module.ActiveContractButton"]    = ["当前江湖委托卷宗", "展开或收起正在履行的差事榜文要略。"],
		["world-screen.topbar.options-module.RelationsButton"]         = ["江湖录 · 朝堂与百草丹经", "查阅各大地方藩镇交情，并可在此翻阅随身只读卷宗『江湖宗门名刺』与『丹经手札·百草器谱』（结交宗门请赴酒肆茶座或山门；开炉炼丹与重锻请赴城镇百工坊）。"],
		["world-screen.topbar.options-module.CampButton"]              = ["安营扎寨调息", "就地驻马扎营，加快气血疗伤与兵甲修缮。"],
		["world-screen.topbar.options-module.ObituaryButton"]          = ["忠烈英魂录", "缅怀自开山立社以来血洒疆场、马革裹尸的逝去同袍。"],
		["world-screen.topbar.options-module.PerksButton"]             = ["行营篝火 · 江湖幕僚", "打开行营幕僚界面，延请丹鼎方士、百炼随匠、杏林医官等十八路江湖奇人随军襄助，并可扩建重装镖车。"],
		["world-campfire-screen.main-dialog-module.LeaveButton"]       = ["拔营返程", "离开行营篝火幕僚席，重返九州大地图。"],
		["world-campfire-screen.hire-dialog-module.HireFollowerButton"]= ["奉银延请幕僚", "奉上礼银延请此位江湖奇人入驻行营幕僚席，常驻襄助义社。"],
		["world-campfire-screen.hire-dialog-module.LeaveButton"]       = ["返回行营", "返回行营篝火主界面。"],

		// 5. Options Menu -> Gameplay: Wuxia Combat VFX & Actor Motion Toggles
		["menu-screen.options.WXSkillVfx"]    = ["显示武学招式特效动画", "开启后，施展武学招式、轻功与内功心法时将播放渐入渐出的气芒、残影与法相特效（战斗加载时一次性预载至显存，消除施法卡顿）；关闭后仅保留简洁打击反馈并进一步降低战斗显存占用。"],
		["menu-screen.options.WXActorMotion"] = ["启用侠客出招身法动作", "开启后，侠客出招与受击时将演出蓄力后撤、疾驰突进、腾空劈斩、旋风回旋、瞬步闪袭以及受击击退/侧身闪避身法；关闭后恢复原版静态摇晃表现。"]
	};

	if (!("UI" in ::Wuxia)) ::Wuxia.UI <- {};
	::Wuxia.UI.FullTooltips <- wxFullTooltips;

	::Wuxia.UI.harmonizeTooltipArray <- function( _arr )
	{
		if (_arr == null || typeof _arr != "array") return _arr;
		if (!("Purify" in ::Wuxia) || !("rewriteCurrencyAndSupplyTerms" in ::Wuxia.Purify)) return _arr;
		for (local i = 0; i < _arr.len(); i = ++i)
		{
			local row = _arr[i];
			if (row != null && typeof row == "table")
			{
				if (("text" in row) && typeof row.text == "string")
					row.text = ::Wuxia.Purify.rewriteCurrencyAndSupplyTerms(row.text);
				if (("label" in row) && typeof row.label == "string")
					row.label = ::Wuxia.Purify.rewriteCurrencyAndSupplyTerms(row.label);
				if (("children" in row) && typeof row.children == "array")
					::Wuxia.UI.harmonizeTooltipArray(row.children);
			}
		}
		return _arr;
	};

	::Wuxia.UI.applyElementTooltip <- function( _elementId, _ret )
	{
		if (_elementId != null && ("FullTooltips" in ::Wuxia.UI) && (_elementId in ::Wuxia.UI.FullTooltips))
		{
			local spec = ::Wuxia.UI.FullTooltips[_elementId];
			local descTxt = spec[1];
			if (_elementId == "assets.BusinessReputation" && ("World" in getroottable()) && ::World != null && ::World.Assets != null)
			{
				local repVal = ::World.Assets.getBusinessReputation();
				local repRank = ::World.Assets.getBusinessReputationAsText();
				descTxt = descTxt + "\n\n当前威名阶位：[color=#5e2c00]" + repRank + "[/color]（威名值 " + repVal + "）";
			}
			if (_ret == null || typeof _ret != "array" || _ret.len() == 0)
			{
				return [
					{ id = 1, type = "title", text = spec[0] },
					{ id = 2, type = "description", text = descTxt }
				];
			}
			local replacedTitle = false;
			local replacedDesc  = false;
			for (local i = 0; i < _ret.len(); i = ++i)
			{
				if (typeof _ret[i] == "table" && ("type" in _ret[i]))
				{
					if (_ret[i].type == "title" && !replacedTitle)
					{
						_ret[i].text = spec[0];
						replacedTitle = true;
					}
					else if (_ret[i].type == "description" && !replacedDesc)
					{
						_ret[i].text = descTxt;
						replacedDesc = true;
					}
				}
			}
			if (!replacedTitle)
				_ret.insert(0, { id = 1, type = "title", text = spec[0] });
			if (!replacedDesc)
				_ret.insert(1, { id = 2, type = "description", text = descTxt });
		}
		return ::Wuxia.UI.harmonizeTooltipArray(_ret);
	};

	// Bind directly onto instantiated `tooltip_events` in `AfterHooks` so Wuxia stat/UI tooltips
	// always win even if `mod_bbmod_zhcn` wraps `tooltip_events` via `mods_hookNewObject`!
	::Wuxia.UI.bindTooltipEventsInstance <- function( _obj )
	{
		if (_obj == null || typeof _obj != "table") return;
		if ("WX_TooltipInstanceBound" in _obj && _obj.WX_TooltipInstanceBound) return;
		_obj.WX_TooltipInstanceBound <- true;

		foreach (elFn in ["general_queryUIElementTooltipData", "strategic_queryUIElementTooltipData", "tactical_queryUIElementTooltipData"])
		{
			if (::Wuxia.hasMember(_obj, elFn) && typeof _obj[elFn] == "function")
			{
				local origFn = _obj[elFn];
				_obj[elFn] <- (function( _entityId, _elementId, _elementOwner )
				{
					local ret = origFn.call(this, _entityId, _elementId, _elementOwner);
					return ::Wuxia.UI.applyElementTooltip(_elementId, ret);
				}).bindenv(_obj);
			}
		}

		foreach (arrFn in [
			"general_querySkillTooltipData",
			"general_queryStatusEffectTooltipData",
			"tactical_queryUIItemTooltipData",
			"strategic_queryUIItemTooltipData",
			"tactical_queryTileTooltipData"
		])
		{
			if (::Wuxia.hasMember(_obj, arrFn) && typeof _obj[arrFn] == "function")
			{
				local origArrFn = _obj[arrFn];
				_obj[arrFn] <- (function( ... )
				{
					local args = [this];
					for (local a = 0; a < vargv.len(); a = ++a)
						args.push(vargv[a]);
					local ret = origArrFn.acall(args);
					return ::Wuxia.UI.harmonizeTooltipArray(ret);
				}).bindenv(_obj);
			}
		}
	};

	foreach (elFnName in ["general_queryUIElementTooltipData", "strategic_queryUIElementTooltipData", "tactical_queryUIElementTooltipData"])
	{
		if (::Wuxia.qHas(q, elFnName))
		{
			q[elFnName] = @(__original) function( _entityId, _elementId, _elementOwner )
			{
				local ret = __original(_entityId, _elementId, _elementOwner);
				return ::Wuxia.UI.applyElementTooltip(_elementId, ret);
			};
		}
	}
});

// Town Temple Clinic (`古刹济世医馆`): Allow healing temporary `effects.wx_internal_injury` & `effects.wx_scatter_weakness`!
::Wuxia.HooksMod.hook("scripts/ui/screens/world/modules/world_town_screen/town_temple_dialog_module", function( q )
{
	q.WX_GetWuxiaInjuryPrice <- function( _eff )
	{
		local mult = 1.0;
		try
		{
			if ("World" in getroottable() && ::World != null && ::World.State != null && ::World.State.getCurrentTown() != null)
				mult = ::World.State.getCurrentTown().getBuyPriceMult();
		}
		catch (_e) {}
		if (_eff.getID() == "effects.wx_internal_injury")
		{
			local sev = ("Severity" in _eff.m) ? _eff.m.Severity : 1;
			local baseP = (sev >= 2) ? 340 : 200;
			return ::Math.max(120, ::Math.round(baseP * mult).tointeger());
		}
		return ::Math.max(110, ::Math.round(180 * mult).tointeger());
	};

	q.WX_CollectWuxiaInjuries <- function( _bro )
	{
		local out = [];
		if (_bro == null || _bro.getSkills() == null) return out;
		local sk = _bro.getSkills();
		local inj = sk.getSkillByID("effects.wx_internal_injury");
		if (inj != null && ("Severity" in inj.m) && inj.m.Severity > 0)
		{
			out.push({
				id    = "effects.wx_internal_injury",
				icon  = "skills/wx_internal_injury.png",
				name  = "内伤调理 · " + inj.getName() + "（余 " + inj.m.DaysRemaining + " 日）",
				price = this.WX_GetWuxiaInjuryPrice(inj)
			});
		}
		local scat = sk.getSkillByID("effects.wx_scatter_weakness");
		if (scat != null && ("DaysRemaining" in scat.m) && scat.m.DaysRemaining > 0)
		{
			out.push({
				id    = "effects.wx_scatter_weakness",
				icon  = "skills/wx_scatter_weakness.png",
				name  = "归元稳脉 · 散功虚弱（余 " + scat.m.DaysRemaining + " 日）",
				price = this.WX_GetWuxiaInjuryPrice(scat)
			});
		}
		return out;
	};

	q.WX_BuildBroTempleEntry <- function( _bro, _existingEntry )
	{
		local entry = _existingEntry;
		if (entry == null)
		{
			local bg = _bro.getBackground();
			entry = {
				ID                  = _bro.getID(),
				Name                = _bro.getName(),
				ImagePath           = _bro.getImagePath(),
				ImageOffsetX        = _bro.getImageOffsetX(),
				ImageOffsetY        = _bro.getImageOffsetY(),
				BackgroundImagePath = (bg != null) ? bg.getIconColored() : "",
				Injuries            = []
			};
		}
		local wxList = this.WX_CollectWuxiaInjuries(_bro);
		foreach (w in wxList)
		{
			local exists = false;
			foreach (cur in entry.Injuries)
				if (cur.id == w.id) { exists = true; break; }
			if (!exists) entry.Injuries.push(w);
		}
		return entry;
	};

	if (::Wuxia.qHas(q, "queryRosterInformation"))
	{
		q.queryRosterInformation = @(__original) function()
		{
			local ret = __original();
			if (ret == null || typeof ret != "table" || !("Roster" in ret) || typeof ret.Roster != "array")
				return ret;
			if (!("World" in getroottable()) || ::World == null || ::World.getPlayerRoster() == null)
				return ret;

			local byID = {};
			foreach (row in ret.Roster)
			{
				if (row != null && ("ID" in row)) byID[row.ID] <- row;
			}
			foreach (bro in ::World.getPlayerRoster().getAll())
			{
				if (bro == null || !bro.isAlive()) continue;
				local wxList = this.WX_CollectWuxiaInjuries(bro);
				if (wxList.len() == 0) continue;
				if (bro.getID() in byID)
				{
					this.WX_BuildBroTempleEntry(bro, byID[bro.getID()]);
				}
				else
				{
					ret.Roster.push(this.WX_BuildBroTempleEntry(bro, null));
				}
			}
			return ret;
		};
	}

	if (::Wuxia.qHas(q, "onTreatInjury"))
	{
		q.onTreatInjury = @(__original) function( _data )
		{
			if (_data != null && typeof _data == "array" && _data.len() >= 2 && (_data[1] == "effects.wx_internal_injury" || _data[1] == "effects.wx_scatter_weakness"))
			{
				local entityID = _data[0];
				local injID = _data[1];
				local bro = null;
				foreach (b in ::World.getPlayerRoster().getAll())
				{
					if (b != null && b.getID() == entityID) { bro = b; break; }
				}
				if (bro != null && bro.getSkills() != null)
				{
					local eff = bro.getSkills().getSkillByID(injID);
					if (eff != null)
					{
						local price = this.WX_GetWuxiaInjuryPrice(eff);
						if (::World.Assets.getMoney() >= price)
						{
							::World.Assets.addMoney(-price);
							if (injID == "effects.wx_internal_injury" && ("cureTemporary" in eff))
								eff.cureTemporary();
							else
								eff.removeSelf();
							bro.getSkills().update();
							try { ::Sound.play("sounds/combat/first_aid_01.wav", ::Const.Sound.Volume.Inventory); } catch (_e) {}
						}
					}
					// Rebuild updated entry (including any remaining vanilla + Wuxia injuries)
					local refreshed = this.queryRosterInformation();
					local updatedEntity = null;
					if (refreshed != null && ("Roster" in refreshed))
					{
						foreach (r in refreshed.Roster)
							if (r.ID == entityID) { updatedEntity = r; break; }
					}
					if (updatedEntity == null)
						updatedEntity = this.WX_BuildBroTempleEntry(bro, null);
					return {
						Assets = (this.m.Parent != null && ::Wuxia.hasMember(this.m.Parent, "queryAssetsInformation"))
							? this.m.Parent.queryAssetsInformation()
							: ::UIDataHelper.convertAssetsInformationToUIData(),
						Entity = updatedEntity
					};
				}
			}
			return __original(_data);
		};
	}
});

// Town Training Hall (`讲武演武木人馆`): Highlight +45% martial mastery XP bonus on training options!
::Wuxia.HooksMod.hook("scripts/ui/screens/world/modules/world_town_screen/town_training_dialog_module", function( q )
{
	if (::Wuxia.qHas(q, "queryRosterInformation"))
	{
		q.queryRosterInformation = @(__original) function()
		{
			local ret = __original();
			if (ret != null && typeof ret == "table")
			{
				ret.Title    <- "讲武演武木人馆";
				ret.SubTitle <- "闭关演武不仅加速境界经验，更令战后武学功法火候获取额外 +45%！";
			}
			return ret;
		};
	}
});

// Town Hire Dialog (`江湖牙人` Recruiter Synergy + Tryout Starter-Manual Preview)
::Wuxia.HooksMod.hook("scripts/ui/screens/world/modules/world_town_screen/town_hire_dialog_module", function( q )
{
	if (::Wuxia.qHas(q, "convertEntityHireInformationToUIDataAltered"))
	{
		q.convertEntityHireInformationToUIDataAltered = @(__original) function( _entity )
		{
			local ret = __original(_entity);
			if (ret == null || typeof ret != "table" || _entity == null) return ret;
			local hasRecruiter = ("World" in getroottable() && ::World != null && ("Retinue" in ::World) && ::World.Retinue != null && ::World.Retinue.hasFollower("follower.recruiter"));
			local tried = (::Wuxia.hasMember(_entity, "isTryoutDone") && _entity.isTryoutDone());
			if (hasRecruiter || tried)
			{
				local c = ::Wuxia.Slots.getContainer(_entity);
				if (c != null && ("Slots" in c.m))
				{
					local names = [];
					foreach (sl in c.m.Slots)
					{
						if (sl.ManualID != null && sl.Tier > 0)
						{
							local md = ::Wuxia.Slots.getManualDef(sl.ManualID);
							if (md != null) names.push("《" + md.Name + "》");
						}
					}
					local note = names.len() > 0
						? ("\n\n[color=#d8b467]【自带武学底子】[/color]" + (hasRecruiter && !tried ? "（江湖牙人相面识破）" : "") + "入队即身怀 " + names[0] + (names.len() > 1 ? ("、" + names[1]) : "") + "。")
						: ("\n\n[color=#9c927d]【自带武学底子】[/color]草莽白身，尚未习得成套武功。");
					if ("BackgroundText" in ret && typeof ret.BackgroundText == "string" && ret.BackgroundText.find("【自带武学底子】") == null)
						ret.BackgroundText += note;
				}
			}
			return ret;
		};
	}
});
