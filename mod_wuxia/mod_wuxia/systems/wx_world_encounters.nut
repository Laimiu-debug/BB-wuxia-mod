// World flags persist hunt cooldowns and unique victories across campaigns' save/load cycles.
::Wuxia.Encounters <- {
	function addTroops( _party, _roster )
	{
		foreach (id in _roster)
		{
			if ("ShanHaiBosses" in ::Wuxia.Config && (id in ::Wuxia.Config.ShanHaiBosses))
			{
				local boss = ::Wuxia.Config.ShanHaiBosses[id];
				local bTroop = clone ::Const.World.Spawn.Troops[boss.BaseTroop];
				if (boss.EntityType in ::Const.EntityType) bTroop.ID = ::Const.EntityType[boss.EntityType];
				bTroop.Script = boss.Script;
				bTroop.Strength = boss.Strength;
				::Const.World.Common.addTroop(_party, { Type = bTroop }, true, 0);
				_party.getTroops().top().Name = boss.Name;
				continue;
			}
			local fighter = id in ::Wuxia.Config.Fighters ? ::Wuxia.Config.Fighters[id] : null;
			local troop = clone ::Const.World.Spawn.Troops[fighter == null ? id : fighter.BaseTroop];
			if (fighter != null) troop.Script = "scripts/entity/tactical/enemies/wx_" + id;
			::Const.World.Common.addTroop(_party, { Type = troop }, true, 0);
			if (fighter != null) _party.getTroops().top().Name = fighter.Name;
		}
	}

	function findTile( _road, _nearPlayer = false )
	{
		local playerTile = ::World.State.getPlayer().getTile(), size = ::World.getMapSize();
		local nav = ::World.getNavigator().createSettings();
		nav.ActionPointCosts = ::Const.World.TerrainTypeNavCost_Flat;
		local towns = ::World.EntityManager.getSettlements(), sites = ::World.EntityManager.getLocations();
		local terrain = ::Const.World.TerrainType;
		local useLocalBox = _road || _nearPlayer;
		local boxR = _road ? 12 : 20;
		local x0 = useLocalBox ? ::Math.max(2, playerTile.SquareCoords.X - boxR) : 2;
		local y0 = useLocalBox ? ::Math.max(2, playerTile.SquareCoords.Y - boxR) : 2;
		local width = (useLocalBox ? ::Math.min(size.X - 2, playerTile.SquareCoords.X + boxR + 1) : size.X - 2) - x0;
		local height = (useLocalBox ? ::Math.min(size.Y - 2, playerTile.SquareCoords.Y + boxR + 1) : size.Y - 2) - y0;
		if (width <= 0 || height <= 0) return null;
		local count = width * height, offset = ::Math.rand(0, count - 1);
		local samples = ::Math.min(768, count), paths = 0;
		for (local i = 0; i < samples && paths < 14; ++i)
		{
			local idx = (offset + i * count / samples) % count;
			local tile = ::World.getTileSquare(x0 + idx % width, y0 + idx / width);
			if (tile == null || tile.IsOccupied || tile.HasRoad != _road || tile.Type == terrain.Ocean || tile.Type == terrain.Shore
				|| tile.Type == terrain.Mountains || tile.Type == terrain.Impassable || tile.Type == terrain.Urban) continue;
			local anchorTile = playerTile;
			if (_road)
			{
				local dist = playerTile.getDistanceTo(tile);
				if (dist < 5 || dist > 12) continue;
			}
			else
			{
				if (_nearPlayer)
				{
					local pDist = playerTile.getDistanceTo(tile);
					if (pDist < 6 || pDist > 18) continue;
				}
				local nearest = 10000;
				local nearestTown = null;
				foreach (town in towns)
				{
					if (town == null || town.isIsolatedFromRoads()) continue;
					local d = tile.getDistanceTo(town.getTile());
					if (d < nearest)
					{
						nearest = d;
						nearestTown = town;
					}
				}
				if (nearest < 5 || nearest > 16) continue;
				if (nearestTown != null) anchorTile = nearestTown.getTile();
				local crowded = false;
				foreach (site in sites) if (site.isAlive() && tile.getDistanceTo(site.getTile()) < 4) { crowded = true; break; }
				if (crowded) continue;
			}
			++paths;
			if (!::World.getNavigator().findPath(anchorTile, tile, nav, 0).isEmpty()) return tile;
		}
		return null;
	}

	function ensureStronghold( _id, _faction, _nearPlayer = false )
	{
		local key = "wx_camp_" + _id;
		local defeated = ::World.Flags.get(key + "_defeated");
		foreach (site in ::World.EntityManager.getLocations())
		{
			if (!site.isAlive() || site.getTypeID() != "location.wx_" + _id) continue;
			if (defeated && !site.isInCombat()) site.fadeOutAndDie();
			return site;
		}
		if (defeated) return null;
		local tile = _nearPlayer ? this.findTile(false, true) : null;
		if (tile == null) tile = this.findTile(false, false);
		if (tile == null) return null;
		local site = ::World.spawnLocation("scripts/entity/world/locations/wx_" + _id, tile.Coords);
		if (site == null) return null;
		site.setFaction(_faction.getID());
		site.onSpawned();
		return site;
	}

	function findRoadTileNearTown( _town )
	{
		if (_town == null || _town.getTile() == null) return null;
		local center = _town.getTile();
		local size = ::World.getMapSize();
		local terrain = ::Const.World.TerrainType;
		local candidates = [];
		for (local dx = -6; dx <= 6; ++dx)
		{
			for (local dy = -6; dy <= 6; ++dy)
			{
				local tx = center.SquareCoords.X + dx;
				local ty = center.SquareCoords.Y + dy;
				if (tx < 2 || ty < 2 || tx >= size.X - 2 || ty >= size.Y - 2) continue;
				local t = ::World.getTileSquare(tx, ty);
				if (t == null || t.IsOccupied || t.Type == terrain.Ocean || t.Type == terrain.Shore || t.Type == terrain.Mountains || t.Type == terrain.Impassable || t.Type == terrain.Urban)
					continue;
				local dist = center.getDistanceTo(t);
				if (dist >= 2 && dist <= 6 && t.HasRoad)
					candidates.push(t);
			}
		}
		if (candidates.len() > 0)
			return candidates[::Math.rand(0, candidates.len() - 1)];
		return this.findTile(true);
	}

	// Maintain 6 visible Jianghu Sect Patrols & Raiders marching across the World Map (zero new Faction IDs!)
	function updateRoamingSectPatrols( _day, _banditFaction )
	{
		local player = ::World.State.getPlayer();
		if (player == null || _banditFaction == null || !("SectRelations" in ::Wuxia)) return;
		::Wuxia.SectRelations.ensureWorldSectAnchors();

		local patrolDefs = [
			{ SectID = "shaolin",  Title = "少室禅院 · 行脚护法僧", Desc = "奉方丈法旨下山巡游、扶危济困的少室武僧与护寺行者。", Fig = "wx_fig_sect_monk",    Banner = "banner_53", Outlaw = false,
			  Early = ["monk_fighter", "monk_fighter", "staff_guard"], Late = ["monk_fighter", "monk_fighter", "staff_guard", "shaolin_bronze"] },
			{ SectID = "taihe",    Title = "太和玄门 · 云游剑客",   Desc = "背负长剑下山历练、斩妖除盗的太和玄门道门弟子。",   Fig = "wx_fig_sect_sword",   Banner = "banner_54", Outlaw = false,
			  Early = ["disciple", "disciple", "escort"], Late = ["disciple", "disciple", "emei_sword", "taihe_elder"] },
			{ SectID = "gaibang",  Title = "天下丐帮 · 巡方弟子",   Desc = "执齐眉熟铜棍游走南北官道、传递江湖风声的丐帮弟子。", Fig = "wx_fig_sect_gaibang", Banner = "banner_60", Outlaw = false,
			  Early = ["staff_guard", "staff_guard", "monk_fighter"], Late = ["staff_guard", "staff_guard", "monk_fighter", "gaibang_elder"] },
			{ SectID = "weiyuan",  Title = "威远总镖局 · 走镖护卫", Desc = "高竖镖旗押送重货往来州府的威远镖师与趟子手。",     Fig = "wx_cart_escort_01",   Banner = "banner_51", Outlaw = false,
			  Early = ["escort", "escort", "axe_vanguard"], Late = ["escort", "escort", "axe_vanguard", "weiyuan_captain"] },
			{ SectID = "tangmen",  Title = "蜀中唐家堡 · 游方暗器手", Desc = "携机括劲弩与淬毒暗器行走巴蜀山林的唐门外堂子弟。", Fig = "wx_fig_sect_tangmen", Banner = "banner_59", Outlaw = false,
			  Early = ["dartist", "dartist", "disciple"], Late = ["dartist", "dartist", "tangmen_killer"] },
			{ SectID = "qingfeng", Title = "清风剑派 · 试剑门人",   Desc = "结伴下山访友试剑的清风剑派年轻剑客。",             Fig = "wx_fig_sect_sword",   Banner = "banner_52", Outlaw = false,
			  Early = ["disciple", "disciple", "escort"], Late = ["disciple", "disciple", "emei_sword"] }
		];

		local outlawDefs = [
			{ SectID = "heifeng", Title = "黑风血煞宗 · 巡山狂刀队", Desc = "黑风血煞宗派下山劫掠商旅、搜罗血食的凶悍刀客。", Fig = "wx_fig_sect_xuesha", Banner = "wx_fbanner_outlaw_01", Outlaw = true,
			  Early = ["axe_vanguard", "hammer_adept", "dartist"], Late = ["axe_vanguard", "hammer_adept", "dartist", "blood_chief"] },
			{ SectID = "wudu",    Title = "南疆五毒奇门 · 采蛊伏兵", Desc = "深入林泽搜集奇虫毒草、伏击路人的五毒奇门弟子。", Fig = "wx_fig_wudu",        Banner = "wx_fbanner_outlaw_01", Outlaw = true,
			  Early = ["wudu_blowgun", "wudu_blowgun", "whip_stalker"], Late = ["wudu_blowgun", "wudu_blowgun", "whip_stalker", "wudu_gushaman"] },
			{ SectID = "yinsha",  Title = "幽冥隐杀楼 · 索命死士",   Desc = "受鬼市暗花雇佣、昼伏夜出的幽冥隐杀楼执匕刺客。", Fig = "wx_fig_sect_tangmen", Banner = "banner_61",           Outlaw = true,
			  Early = ["shadow_dagger", "shadow_dagger", "dartist"], Late = ["shadow_dagger", "shadow_dagger", "dartist", "tangmen_killer"] }
		];

		for (local slot = 1; slot <= 6; slot = ++slot)
		{
			local fKey = "wx_sect_patrol_" + slot;
			local prevID = ::World.Flags.getAsInt(fKey + "_id");
			local prevDay = ::World.Flags.getAsInt(fKey + "_day");
			local party = (prevID == 0) ? null : ::World.getEntityByID(prevID);

			if (party != null && party.isAlive() && party.getFlags().get("wx_sect_patrol_slot") == slot)
			{
				if (!party.isInCombat() && (_day - prevDay >= 12))
					party.fadeOutAndDie();
				else
					continue;
			}

			local isOutlawSlot = (slot >= 5);
			local def = isOutlawSlot
				? outlawDefs[(slot + _day) % outlawDefs.len()]
				: patrolDefs[(slot - 1 + (_day / 6)) % patrolDefs.len()];

			local anchor = ::Wuxia.SectRelations.getSectAnchorInfo(def.SectID);
			local homeTown = anchor.townObj;
			local spawnFac = _banditFaction;
			local spawnTile = null;

			if (!isOutlawSlot)
			{
				if (homeTown != null && "FactionManager" in ::World && ::World.FactionManager != null && ::Wuxia.hasMember(homeTown, "getFactions"))
				{
					foreach (fid in homeTown.getFactions())
					{
						local candF = ::World.FactionManager.getFaction(fid);
						if (candF != null) { spawnFac = candF; break; }
					}
				}
				spawnTile = this.findRoadTileNearTown(homeTown);
				if (spawnTile == null) spawnTile = this.findTile(true);
			}
			else
			{
				spawnTile = this.findTile(false, slot == 5);
			}
			if (spawnTile == null || spawnFac == null) continue;

			party = spawnFac.spawnEntity(spawnTile, def.Title, false, ::Const.World.Spawn.BanditRaiders, 45, 0);
			if (party == null) continue;

			party.clearTroops();
			local roster = (_day >= 20) ? def.Late : def.Early;
			this.addTroops(party, roster);
			party.setDescription(def.Desc);
			party.getFlags().set("wx_sect_patrol", def.SectID);
			party.getFlags().set("wx_sect_patrol_slot", slot);
			party.getFlags().set("wx_sect_patrol_fig", def.Fig);
			party.getFlags().set("wx_sect_patrol_banner", def.Banner);

			if ("WX_RefreshPartyVisuals" in party)
			{
				party.m.WX_LastBodyBrush <- "";
				party.m.WX_LastBannerBrush <- "";
				party.WX_RefreshPartyVisuals();
			}

			local ro = ::new("scripts/ai/world/orders/roam_order");
			if ("setPivot" in ro) ro.setPivot((homeTown != null && !isOutlawSlot && homeTown.getTile() != null) ? homeTown.getTile() : spawnTile);
			if ("setMinRange" in ro) ro.setMinRange(2);
			if ("setMaxRange" in ro) ro.setMaxRange(14);
			if ("setAllTerrainAvailable" in ro) ro.setAllTerrainAvailable();
			if ("setTime" in ro) ro.setTime(720.0);
			party.getController().addOrder(ro);

			::World.Flags.set(fKey + "_id", party.getID());
			::World.Flags.set(fKey + "_day", _day);
		}
	}

	function updateRoamingShanHaiBeasts( _day )
	{
		local beastFaction = ::World.FactionManager.getFactionOfType(::Const.FactionType.Beasts);
		local player = ::World.State.getPlayer();
		if (beastFaction == null || player == null) return;
		local pTile = player.getTile();

		local templates = [
			{
				Name = "山海荒兽 · 天狗妖群",
				Desc = "自《山海经》阴山窜出的白首天狗妖群，疾行如风，专袭荒野行旅。",
				Fig  = "wx_fig_beast_tiangou",
				Troops = (_day >= 18) ? ["Direwolf", "Direwolf", "Direwolf", "Direwolf", "Direwolf"] : ["Direwolf", "Direwolf", "Direwolf", "Direwolf"]
			},
			{
				Name = "山海毒虫 · 赤蛛蛊群",
				Desc = "栖息幽林古木间的山海赤蛛毒虫群，吐丝结网、奇毒蚀骨。",
				Fig  = "wx_fig_beast_chizhu",
				Troops = (_day >= 18) ? ["Spider", "Spider", "Spider", "Spider", "Spider", "Spider"] : ["Spider", "Spider", "Spider", "Spider", "Spider"]
			},
			{
				Name = "山海凶兽 · 蛊雕文豹群",
				Desc = "状如雕而戴角、声若婴儿啼哭的大漠蛊雕与文豹恶兽。",
				Fig  = "wx_fig_beast_gudiao",
				Troops = (_day >= 18) ? ["Hyena", "Hyena", "Hyena", "Hyena", "Hyena"] : ["Hyena", "Hyena", "Hyena", "Hyena"]
			}
		];
		if (_day >= 10)
		{
			templates.push({
				Name = "山海饕妖 · 咆哮长舌群",
				Desc = "盘踞古战场荒冢的食人咆哮与长舌凶妖，嗜食血肉以壮妖躯。",
				Fig  = "wx_fig_beast_taotie",
				Troops = ["Ghoul", "Ghoul", "Ghoul", "Ghoul", "Ghoul"]
			});
			templates.push({
				Name = "山海泽妖 · 巴蛇毒虺群",
				Desc = "潜行大泽泥淖的巴蛇裔种与肥遗毒虺，绞杀吞噬过往生灵。",
				Fig  = "wx_fig_beast_bashe",
				Troops = ["Serpent", "Serpent", "Serpent", "Serpent"]
			});
		}
		if (_day >= 26)
		{
			templates.push({
				Name = "山海巨兽 · 朱厌山魈",
				Desc = "白首赤足、力拔千钧的山海凶猿朱厌，见则大兵起于四野。",
				Fig  = "wx_fig_beast_zhuyan",
				Troops = ["Unhold", "Unhold", "Direwolf"]
			});
			templates.push({
				Name = "山海古精 · 建木树妖",
				Desc = "感天地灵煞化形而行的千年建木枯荣树精，木甲坚逾精铁。",
				Fig  = "wx_fig_beast_jianmu",
				Troops = ["Schrat", "Schrat"]
			});
		}

		for (local slot = 1; slot <= 5; slot = ++slot)
		{
			local flagKey = "wx_roam_beast_" + slot;
			local prevID = ::World.Flags.getAsInt(flagKey + "_id");
			local prevDay = ::World.Flags.getAsInt(flagKey + "_day");
			local pack = (prevID == 0) ? null : ::World.getEntityByID(prevID);

			if (pack != null && pack.isAlive() && pack.getFlags().get("wx_shanhai_roam") == slot)
			{
				// Recycle packs that wandered far off-screen (> 32 tiles) after 10+ days so players actually meet them!
				if (!pack.isInCombat() && (_day - prevDay >= 10) && pack.getTile() != null && pTile.getDistanceTo(pack.getTile()) > 32)
				{
					pack.fadeOutAndDie();
				}
				else
				{
					continue;
				}
			}

			local tile = (slot <= 3) ? this.findTile(false, true) : null;
			if (tile == null) tile = this.findTile(false, false);
			if (tile == null) continue;

			local tpl = templates[::Math.rand(0, templates.len() - 1)];
			pack = beastFaction.spawnEntity(tile, tpl.Name, false, ::Const.World.Spawn.Direwolves, 45, 0);
			if (pack == null) continue;

			pack.clearTroops();
			this.addTroops(pack, tpl.Troops);
			pack.setDescription(tpl.Desc);
			pack.getFlags().set("wx_shanhai_roam", slot);
			if (pack.hasSprite("body") && ::Wuxia.Appearance.brushExists(tpl.Fig))
			{
				pack.getSprite("body").setBrush(tpl.Fig);
				pack.m.WX_LastBodyBrush <- tpl.Fig;
			}
			if (pack.hasSprite("banner"))
				pack.getSprite("banner").Visible = false;

			local ro = ::new("scripts/ai/world/orders/roam_order");
			if ("setPivot" in ro) ro.setPivot(tile);
			if ("setMinRange" in ro) ro.setMinRange(2);
			if ("setMaxRange" in ro) ro.setMaxRange(12);
			if ("setAllTerrainAvailable" in ro) ro.setAllTerrainAvailable();
			if ("setTime" in ro) ro.setTime(600.0);
			pack.getController().addOrder(ro);

			::World.Flags.set(flagKey + "_id", pack.getID());
			::World.Flags.set(flagKey + "_day", _day);
		}
	}

	function updateVendetta( _sect, _faction, _day )
	{
		local key = "wx_hunt_" + _sect.ID;
		local previous = ::World.Flags.getAsInt(key + "_id");
		local squad = previous == 0 ? null : ::World.getEntityByID(previous);
		local hostile = ::Wuxia.SectRelations.isVendettaActive(_sect.ID);
		local last = ::World.Flags.getAsInt(key + "_day");
		if (squad != null && squad.isAlive() && squad.getFlags().get("wx_vendetta") == _sect.ID)
		{
			if ((!hostile || _day - last >= 7) && !squad.isInCombat()) squad.fadeOutAndDie();
			return;
		}
		if (!hostile || _day < 14 || (last > 0 && _day - last < 14) || ::World.Flags.getAsInt("wx_last_hunt") == _day) return;
		local tile = this.findTile(true);
		if (tile == null) return;
		local spec = ::Wuxia.Config.Vendettas[_sect.VendettaParty];
		squad = _faction.spawnEntity(tile, spec.Name, false, ::Const.World.Spawn.BanditRaiders, 40, 0);
		if (squad == null) return;
		squad.clearTroops();
		this.addTroops(squad, spec.Troops);
		squad.setDescription(_sect.Name + "派出的寻仇人马，正沿路追查你的行踪。");
		squad.getFlags().set("wx_vendetta", _sect.ID);
		if ("WX_RefreshPartyVisuals" in squad)
		{
			squad.m.WX_LastBodyBrush <- "";
			squad.WX_RefreshPartyVisuals();
		}
		squad.setAlwaysAttackPlayer(true);
		local order = ::new("scripts/ai/world/orders/intercept_order");
		order.setTarget(::World.State.getPlayer());
		squad.getController().addOrder(order);
		squad.getController().addOrder(::new("scripts/ai/world/orders/despawn_order"));
		::World.Flags.set(key + "_id", squad.getID());
		::World.Flags.set(key + "_day", _day);
		::World.Flags.set("wx_last_hunt", _day);
	}

	function resolveStrongholdFaction( _config, _fallback )
	{
		if ("FactionType" in _config && _config.FactionType in ::Const.FactionType)
		{
			local f = ::World.FactionManager.getFactionOfType(::Const.FactionType[_config.FactionType]);
			if (f != null) return f;
		}
		return _fallback;
	}

	function syncCrisisFlags()
	{
		local fm = ::World.FactionManager;
		local activeKey = "";
		if (::Wuxia.hasMember(fm, "isGreenskinInvasion") && fm.isGreenskinInvasion()) activeKey = "greenskins";
		else if (::Wuxia.hasMember(fm, "isUndeadScourge") && fm.isUndeadScourge())    activeKey = "undead";
		else if (::Wuxia.hasMember(fm, "isCivilWar") && fm.isCivilWar())              activeKey = "civilwar";
		else if (::Wuxia.hasMember(fm, "isHolyWar") && fm.isHolyWar())                activeKey = "holywar";

		local prev = ::World.Flags.get("wx_active_crisis");
		if (activeKey != "" && prev != activeKey && (activeKey in ::Wuxia.Config.CrisisLore))
		{
			::World.Flags.set("wx_active_crisis", activeKey);
			local lore = ::Wuxia.Config.CrisisLore[activeKey];
			::logInfo("[mod_wuxia] " + lore.Title + " -> " + lore.Summary);
		}
		else if (activeKey == "" && prev != null && prev != "")
		{
			::World.Flags.set("wx_active_crisis", "");
		}
	}

	function update( _state )
	{
		if (_state.getPlayer() == null || ::World.Flags == null || ::World.FactionManager == null) return;
		local day = ::World.getTime().Days;
		if (_state.m.WX_EncounterDay == day) return;
		local banditFaction = ::World.FactionManager.getFactionOfType(::Const.FactionType.Bandits);
		if (banditFaction == null) return;
		_state.m.WX_EncounterDay = day;
		this.syncCrisisFlags();
		local shanhaiPending = [];
		local activeShanHai = 0;
		foreach (id, config in ::Wuxia.Config.Strongholds)
		{
			if (!("IsShanHai" in config) || !config.IsShanHai)
			{
				this.ensureStronghold(id, this.resolveStrongholdFaction(config, banditFaction));
				continue;
			}
			local defeated = ::World.Flags.get("wx_camp_" + id + "_defeated");
			local aliveOnMap = false;
			foreach (site in ::World.EntityManager.getLocations())
			{
				if (!site.isAlive() || site.getTypeID() != "location.wx_" + id) continue;
				if (defeated && !site.isInCombat()) site.fadeOutAndDie();
				else aliveOnMap = true;
				break;
			}
			if (aliveOnMap) activeShanHai += 1;
			else if (!defeated) shanhaiPending.push(id);
		}
		// Maintain up to 12 active undefeated Shan Hai Lairs hidden in the world fog of war
		local maxSpawnToday = (activeShanHai < 4) ? 8 : 3;
		local spawnedToday = 0;
		while (activeShanHai < 12 && spawnedToday < maxSpawnToday && shanhaiPending.len() > 0)
		{
			local pickIdx = ::Math.rand(0, shanhaiPending.len() - 1);
			local pickID = shanhaiPending[pickIdx];
			shanhaiPending.remove(pickIdx);
			local cfg = ::Wuxia.Config.Strongholds[pickID];
			local spawned = this.ensureStronghold(pickID, this.resolveStrongholdFaction(cfg, banditFaction), spawnedToday < 2);
			if (spawned != null)
				activeShanHai += 1;
			spawnedToday += 1;
		}
		this.updateRoamingShanHaiBeasts(day);
		this.updateRoamingSectPatrols(day, banditFaction);
		if ("WorldVisuals" in ::Wuxia && "refreshAllSettlementSectLabels" in ::Wuxia.WorldVisuals)
			::Wuxia.WorldVisuals.refreshAllSettlementSectLabels();
		foreach (id, sect in ::Wuxia.Config.Sects) this.updateVendetta(sect, banditFaction, day);
	}
};

::Wuxia.HooksMod.hook("scripts/states/world_state", function( q )
{
	q.startNewCampaign = @(__original) function()
	{
		this.m.WX_EncounterDay <- null;
		__original();
		this.m.WX_EncounterDay = -1;
		::Wuxia.Encounters.update(this);
	};
	q.loadCampaign = @(__original) function( _file )
	{
		this.m.WX_EncounterDay <- null;
		__original(_file);
		this.m.WX_EncounterDay = -1;
		::Wuxia.Encounters.update(this);
	};
	q.updateDayTime = @(__original) function()
	{
		__original();
		if ("WX_EncounterDay" in this.m && this.m.WX_EncounterDay != null) ::Wuxia.Encounters.update(this);
	};
});
