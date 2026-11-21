// Lightweight Sect Relations & Regional Jianghu Discovery stored in World.Flags (Zero Faction ID cost)

::Wuxia.SectRelations.getExchangeSects <- function()
{
	local ids = [];
	foreach (id, sect in ::Wuxia.Config.Sects)
		if (sect.ShopManuals.len() > 0) ids.push(id);
	ids.sort();
	return ids;
};

::Wuxia.SectRelations.getRegionLabel <- function( _region )
{
	if (_region != null && (_region in ::Wuxia.Config.SectRegions))
		return ::Wuxia.Config.SectRegions[_region];
	return "四方江湖";
};

// Detect the geographic Jianghu region around the player's current position / nearest settlement
::Wuxia.SectRelations.getLocalRegion <- function()
{
	if (!("World" in getroottable()) || ::World == null || !("State" in ::World) || ::World.State == null || ::World.State.getPlayer() == null)
		return "plains";

	local tile = ::World.State.getPlayer().getTile();
	if (tile == null) return "plains";

	local t = tile.Type;
	local tt = ::Const.World.TerrainType;
	if (("Snow" in tt && t == tt.Snow) || ("Tundra" in tt && t == tt.Tundra))
		return "snow";
	if (("Desert" in tt && t == tt.Desert) || ("Oasis" in tt && t == tt.Oasis))
		return "desert";
	if (("Mountains" in tt && t == tt.Mountains) || ("Hills" in tt && t == tt.Hills))
		return "mountains";
	if (("Swamp" in tt && t == tt.Swamp))
		return "swamp";
	if (("Forest" in tt && t == tt.Forest) || ("LeaveForest" in tt && t == tt.LeaveForest) || ("AutumnForest" in tt && t == tt.AutumnForest))
		return "forest";
	return "plains";
};

// Return up to 3 distinct sect IDs for a town tea-house: 2 local-region sects + 1 roaming/global sect
::Wuxia.SectRelations.pickRegionalTrio <- function( _region )
{
	local localPool = [];
	local otherPool = [];

	foreach (id, sect in ::Wuxia.Config.Sects)
	{
		if (sect.ShopManuals.len() == 0) continue;
		if (("Region" in sect) && sect.Region == _region)
			localPool.push(id);
		else
			otherPool.push(id);
	}

	local chosen = [];
	local pickUniqueFrom = function( _arr )
	{
		if (_arr.len() == 0) return null;
		local idx = ::Math.rand(0, _arr.len() - 1);
		local val = _arr[idx];
		_arr.remove(idx);
		return val;
	};

	while (chosen.len() < 2 && localPool.len() > 0)
	{
		chosen.push(pickUniqueFrom(localPool));
	}
	while (chosen.len() < 3 && otherPool.len() > 0)
	{
		chosen.push(pickUniqueFrom(otherPool));
	}
	while (chosen.len() < 3 && localPool.len() > 0)
	{
		chosen.push(pickUniqueFrom(localPool));
	}
	return chosen;
};

::Wuxia.SectRelations.getFlagKey <- function( _sectID )
{
	return "wx_sect_rel_" + _sectID;
};

::Wuxia.SectRelations.getRelation <- function( _sectID )
{
	if (!(_sectID in ::Wuxia.Config.Sects)) return 0;
	local def = ::Wuxia.Config.Sects[_sectID];
	if (!("World" in getroottable()) || ::World == null || !("Flags" in ::World) || ::World.Flags == null)
		return def.DefaultRel;

	local key = ::Wuxia.SectRelations.getFlagKey(_sectID);
	if (!::World.Flags.has(key))
	{
		::World.Flags.set(key, def.DefaultRel);
	}
	return ::World.Flags.getAsInt(key);
};

::Wuxia.SectRelations.addRelation <- function( _sectID, _delta )
{
	if (!(_sectID in ::Wuxia.Config.Sects)) return 0;
	local cur = ::Wuxia.SectRelations.getRelation(_sectID);
	local next = ::Math.max(-100, ::Math.min(100, cur + _delta));
	if ("World" in getroottable() && ::World != null && ("Flags" in ::World) && ::World.Flags != null)
	{
		::World.Flags.set(::Wuxia.SectRelations.getFlagKey(_sectID), next);
	}
	return next;
};

::Wuxia.SectRelations.isVendettaActive <- function( _sectID )
{
	if (!(_sectID in ::Wuxia.Config.Sects)) return false;
	return ::Wuxia.SectRelations.getRelation(_sectID) <= ::Wuxia.Config.Sects[_sectID].VendettaRel;
};

::Wuxia.SectRelations.MajorSectPriority <- [
	"shaolin", "taihe", "qingfeng", "tangmen", "gaibang", "weiyuan", "xuanbing",
	"pishan", "zhenyue", "jiujie", "shenji", "wudu", "heifeng", "yinsha"
];

::Wuxia.SectRelations.AnchorCache <- {
	MapKey        = "",
	TownToSects   = {},
	SectToTownID  = {}
};

::Wuxia.SectRelations.getSettlementRegion <- function( _s )
{
	if (_s == null) return "plains";
	if (::Wuxia.hasMember(_s, "isSouthern") && _s.isSouthern()) return "desert";

	local tile = (::Wuxia.hasMember(_s, "getTile")) ? _s.getTile() : null;
	if (tile != null && ("TerrainType" in ::Const.World))
	{
		local tt = ::Const.World.TerrainType;
		local hasMtn = false;
		local hasForest = false;
		local hasSwamp = false;
		local hasSnow = false;

		if (tile.Type == tt.Snow || ("Tundra" in tt && tile.Type == tt.Tundra)) hasSnow = true;
		if (tile.Type == tt.Swamp) hasSwamp = true;
		if (tile.Type == tt.Mountains || tile.Type == tt.Hills) hasMtn = true;
		if (tile.Type == tt.Forest || tile.Type == tt.LeaveForest || ("AutumnForest" in tt && tile.Type == tt.AutumnForest)) hasForest = true;

		for (local d = 0; d < 6; d = ++d)
		{
			if (!tile.hasNextTile(d)) continue;
			local nt = tile.getNextTile(d).Type;
			if (nt == tt.Snow || ("SnowyForest" in tt && nt == tt.SnowyForest)) hasSnow = true;
			if (nt == tt.Mountains || nt == tt.Hills) hasMtn = true;
			if (nt == tt.Forest || nt == tt.LeaveForest || ("AutumnForest" in tt && nt == tt.AutumnForest)) hasForest = true;
			if (nt == tt.Swamp) hasSwamp = true;
		}

		if (hasSnow) return "snow";
		if (hasMtn) return "mountains";
		if (hasForest) return "forest";
		if (hasSwamp || (::Wuxia.hasMember(_s, "isCoastal") && _s.isCoastal())) return "swamp";
	}
	return "plains";
};

// Deterministically bind all 44 Jianghu Sects onto actual World-Map Settlements so every town hosts a Sect & every Sect has a map home!
::Wuxia.SectRelations.ensureWorldSectAnchors <- function()
{
	if (!("World" in getroottable()) || ::World == null || !("EntityManager" in ::World) || ::World.EntityManager == null)
		return;

	local rawTowns = ::World.EntityManager.getSettlements();
	if (rawTowns == null || rawTowns.len() == 0) return;

	local activeTowns = [];
	foreach (t in rawTowns)
	{
		if (t != null && (!::Wuxia.hasMember(t, "isAlive") || t.isAlive()))
			activeTowns.push(t);
	}
	if (activeTowns.len() == 0) return;

	local firstT = activeTowns[0].getTile();
	local key = activeTowns.len() + ":" + activeTowns[0].getID() + ":" + (firstT != null ? (firstT.SquareCoords.X + "_" + firstT.SquareCoords.Y) : "0");
	if (::Wuxia.SectRelations.AnchorCache.MapKey == key) return;

	activeTowns.sort(function( _a, _b ) {
		if (_a.getID() < _b.getID()) return -1;
		if (_a.getID() > _b.getID()) return 1;
		return 0;
	});

	local townToSects = {};
	local sectToTownID = {};
	local townMeta = [];

	foreach (tw in activeTowns)
	{
		local tid = tw.getID();
		townToSects[tid] <- [];
		local prof = ("WX_ComputeArchProfile" in tw) ? tw.WX_ComputeArchProfile() : null;
		townMeta.push({
			Town      = tw,
			ID        = tid,
			Region    = ::Wuxia.SectRelations.getSettlementRegion(tw),
			IsSectGate= (prof != null && prof.NamePool == "sect_town"),
			IsMonastery = (prof != null && prof.WorldSprite == "wx_set_sect_monastery"),
			IsMilitary= (::Wuxia.hasMember(tw, "isMilitary") && tw.isMilitary()),
			Size      = (::Wuxia.hasMember(tw, "getSize")) ? tw.getSize() : 1
		});
	}

	// Build ordered Sect list: 14 Major Sects first, then remaining alphabetical
	local orderedSects = [];
	local seenS = {};
	foreach (ms in ::Wuxia.SectRelations.MajorSectPriority)
	{
		if (ms in ::Wuxia.Config.Sects)
		{
			orderedSects.push(ms);
			seenS[ms] <- true;
		}
	}
	local rest = [];
	foreach (sid, _ in ::Wuxia.Config.Sects)
	{
		if (!(sid in seenS)) rest.push(sid);
	}
	rest.sort();
	foreach (rs in rest) orderedSects.push(rs);

	// Assign each Sect to the least-crowded matching Settlement (prioritizing Sect Mountain Gates for Monastery/Taoist/Sword sects!)
	foreach (sid in orderedSects)
	{
		local sDef = ::Wuxia.Config.Sects[sid];
		local sReg = ("Region" in sDef) ? sDef.Region : "plains";
		local bestMeta = null;
		local bestScore = -999999;

		foreach (tm in townMeta)
		{
			local curLoad = townToSects[tm.ID].len();
			local score = -curLoad * 100;
			if (tm.Region == sReg) score += 260;
			if (tm.IsSectGate && sReg == "mountains") score += 90;
			if (tm.IsMonastery && (sid == "shaolin" || sid.find("si") != null || sid.find("chan") != null)) score += 140;
			if (!tm.IsMonastery && tm.IsSectGate && (sid == "taihe" || sid == "qingfeng" || sid.find("jian") != null)) score += 95;
			if (!tm.IsMilitary && sDef.Alignment != "outlaw") score += 20;
			if (tm.Size >= 2 && (sid in seenS)) score += 25;

			if (score > bestScore)
			{
				bestScore = score;
				bestMeta = tm;
			}
		}

		if (bestMeta != null)
		{
			townToSects[bestMeta.ID].push(sid);
			sectToTownID[sid] <- bestMeta.ID;
		}
	}

	// Ensure every single settlement has at least 1 Primary Resident Sect (borrow a regional match if towns > 44)
	foreach (tm in townMeta)
	{
		if (townToSects[tm.ID].len() == 0)
		{
			local fallbackPool = [];
			foreach (sid, sDef in ::Wuxia.Config.Sects)
			{
				if ((("Region" in sDef) ? sDef.Region : "plains") == tm.Region)
					fallbackPool.push(sid);
			}
			if (fallbackPool.len() == 0) fallbackPool = orderedSects;
			fallbackPool.sort();
			townToSects[tm.ID].push(fallbackPool[tm.ID % fallbackPool.len()]);
		}
	}

	::Wuxia.SectRelations.AnchorCache.MapKey = key;
	::Wuxia.SectRelations.AnchorCache.TownToSects = townToSects;
	::Wuxia.SectRelations.AnchorCache.SectToTownID = sectToTownID;
};

::Wuxia.SectRelations.getSettlementSects <- function( _settlement )
{
	if (_settlement == null) return [];
	::Wuxia.SectRelations.ensureWorldSectAnchors();
	local tid = _settlement.getID();
	if (tid in ::Wuxia.SectRelations.AnchorCache.TownToSects)
		return ::Wuxia.SectRelations.AnchorCache.TownToSects[tid];
	return [];
};

::Wuxia.SectRelations.getSectAnchorInfo <- function( _sectID )
{
	local empty = { townName = "", dir = "", dist = -1, townObj = null };
	if (!(_sectID in ::Wuxia.Config.Sects) || !("World" in getroottable()) || ::World == null || ::World.EntityManager == null)
		return empty;

	::Wuxia.SectRelations.ensureWorldSectAnchors();
	if (!(_sectID in ::Wuxia.SectRelations.AnchorCache.SectToTownID))
		return empty;

	local tid = ::Wuxia.SectRelations.AnchorCache.SectToTownID[_sectID];
	local town = ::World.getEntityByID(tid);
	if (town == null || (::Wuxia.hasMember(town, "isAlive") && !town.isAlive()))
		return empty;

	local p = (::World.State != null) ? ::World.State.getPlayer() : null;
	local pTile = (p != null) ? p.getTile() : null;
	local tTile = town.getTile();
	local dir = (pTile != null && tTile != null && ("ShanHai" in ::Wuxia)) ? ::Wuxia.ShanHai.getCompassDirection(pTile, tTile) : "";
	local dist = (pTile != null && tTile != null) ? pTile.getDistanceTo(tTile) : -1;

	return {
		townName = town.getName(),
		dir      = dir,
		dist     = dist,
		townObj  = town
	};
};

// Detect the town the player is currently inside (or standing directly on)
::Wuxia.SectRelations.getCurrentTown <- function()
{
	if (!("World" in getroottable()) || ::World == null || ::World.State == null)
		return null;
	local ws = ::World.State;
	if (::Wuxia.hasMember(ws, "getCurrentTown"))
	{
		local ct = ws.getCurrentTown();
		if (ct != null && (!::Wuxia.hasMember(ct, "isAlive") || ct.isAlive()))
			return ct;
	}
	if ("m" in ws && ("CurrentTown" in ws.m) && ws.m.CurrentTown != null)
		return ws.m.CurrentTown;

	local p = ws.getPlayer();
	if (p == null || p.getTile() == null || ::World.EntityManager == null)
		return null;
	local pTile = p.getTile();
	foreach (s in ::World.EntityManager.getSettlements())
	{
		if (s != null && s.isAlive() && s.getTile() != null && pTile.getDistanceTo(s.getTile()) == 0)
			return s;
	}
	return null;
};

// Resolve all Sects seated in `_town`'s Tea House (`江湖茶肆`):
//   1. `_town`'s Resident Sects (`本城驻地`)
//   2. 1 Weekly-rotating Regional Visiting Sect (`地界行客`)
//   3. All Friendly/Origin Sects with Relation >= 25 (`同道传书` — e.g. Shaolin Monk Origin +35!)
::Wuxia.SectRelations.getTownTeaHouseSeats <- function( _town )
{
	local result = {}; // sectID -> badgeLabel
	if (_town == null) return result;

	local residents = ::Wuxia.SectRelations.getSettlementSects(_town);
	for (local i = 0; i < residents.len(); i = ++i)
	{
		local rsid = residents[i];
		result[rsid] <- (i == 0) ? "本城驻地" : "同城堂口";
	}

	local reg = ::Wuxia.SectRelations.getSettlementRegion(_town);
	local regPool = [];
	foreach (sid, sDef in ::Wuxia.Config.Sects)
	{
		if (sDef.ShopManuals.len() == 0) continue;
		if (!(sid in result) && (("Region" in sDef) ? sDef.Region : "plains") == reg)
			regPool.push(sid);
	}
	regPool.sort();
	if (regPool.len() > 0)
	{
		local week = ("getTime" in ::World && ::World.getTime() != null) ? (::World.getTime().Days / 5) : 0;
		local vIdx = ::Math.abs(_town.getID() * 17 + week * 11) % regPool.len();
		result[regPool[vIdx]] <- "地界行客";
	}

	foreach (sid, sDef in ::Wuxia.Config.Sects)
	{
		if (sDef.ShopManuals.len() == 0 || (sid in result)) continue;
		if (::Wuxia.SectRelations.getRelation(sid) >= 25)
			result[sid] <- "同道传书";
	}

	return result;
};

::Wuxia.SectRelations.getTeaCooldownLeft <- function( _kind, _sectID, _cooldownDays )
{
	if (!("World" in getroottable()) || ::World == null || ::World.Flags == null || ::World.getTime() == null)
		return 0;
	local flag = "wx_tea_" + _kind + "_" + _sectID;
	if (!::World.Flags.has(flag)) return 0;
	local lastDay = ::World.Flags.getAsInt(flag);
	local curDay = ::World.getTime().Days;
	local rem = _cooldownDays - (curDay - lastDay);
	return rem > 0 ? rem : 0;
};

::Wuxia.SectRelations.teaHouseBuyManual <- function( _sectID, _manualID )
{
	local town = ::Wuxia.SectRelations.getCurrentTown();
	if (town == null)
		return { ok = false, reason = "须先进入城池内的【江湖茶肆】方能当面请教秘籍。" };
	if (!(_sectID in ::Wuxia.Config.Sects))
		return { ok = false, reason = "未找到该江湖宗门。" };

	local seats = ::Wuxia.SectRelations.getTownTeaHouseSeats(town);
	if (!(_sectID in seats))
		return { ok = false, reason = "该宗门传人当前未在【" + town.getName() + "】茶肆落座，请前往其驻地城池寻访。" };

	local sect = ::Wuxia.Config.Sects[_sectID];
	local offer = null;
	foreach (sm in sect.ShopManuals)
	{
		if (sm.ManualID == _manualID) { offer = sm; break; }
	}
	if (offer == null)
		return { ok = false, reason = "该宗门未传授此部秘籍。" };

	local rel = ::Wuxia.SectRelations.getRelation(_sectID);
	if (rel < offer.MinRel)
		return { ok = false, reason = "与【" + sect.Name + "】交情不足（需 ≥" + offer.MinRel + "，当前 " + rel + "），可先设席论交或切磋印证。" };

	if (::World.Assets.getMoney() < offer.Price)
		return { ok = false, reason = "行囊纹银不足（需 " + offer.Price + " 两）。" };

	local mdef = ::Wuxia.Slots.getManualDef(offer.ManualID);
	if (mdef == null)
		return { ok = false, reason = "秘籍数据异常。" };

	local mItem = ::new("scripts/items/misc/wx_manual_item");
	mItem.initManual(offer.ManualID);
	local payRes = ::Wuxia.Loot.purchaseEventItem(mItem, offer.Price, "OK");
	if (payRes == "NoMoney")
		return { ok = false, reason = "行囊纹银不足。" };
	if (payRes == "NoRoom")
		return { ok = false, reason = "行囊空间已满，请先整理仓库或开启藏经阁自动收纳。" };

	local newRel = ::Wuxia.SectRelations.addRelation(_sectID, 2);
	local destNote = ::Wuxia.Library.isAutoStoreEnabled() ? "已直接收录入【藏经阁】" : "已放入战团行囊";
	return {
		ok      = true,
		message = "奉上束脩 " + offer.Price + " 两，自【" + sect.Name + "】传人处请得《" + mdef.Name + "》（" + destNote + "，交情 +2 → " + newRel + "）！"
	};
};

::Wuxia.SectRelations.teaHouseBanquet <- function( _sectID )
{
	local town = ::Wuxia.SectRelations.getCurrentTown();
	if (town == null)
		return { ok = false, reason = "须在城池【江湖茶肆】中方能设席款待各派传人。" };
	if (!(_sectID in ::Wuxia.Config.Sects))
		return { ok = false, reason = "未找到该江湖宗门。" };

	local seats = ::Wuxia.SectRelations.getTownTeaHouseSeats(town);
	if (!(_sectID in seats))
		return { ok = false, reason = "该宗门传人未在此城茶肆落座。" };

	local cd = ::Wuxia.SectRelations.getTeaCooldownLeft("banq", _sectID, 3);
	if (cd > 0)
		return { ok = false, reason = "近日已宴请过该派传人，尚需相隔 " + cd + " 日再行设席。" };

	local cost = 350;
	if (::World.Assets.getMoney() < cost)
		return { ok = false, reason = "设茗酒雅席需纹银 " + cost + " 两，当前盘缠不足。" };

	::World.Assets.addMoney(-cost);
	::World.Flags.set("wx_tea_banq_" + _sectID, ::World.getTime().Days);
	local sect = ::Wuxia.Config.Sects[_sectID];
	local newRel = ::Wuxia.SectRelations.addRelation(_sectID, 15);
	return {
		ok      = true,
		message = "于【" + town.getName() + "】茶肆设上等茗酒款待【" + sect.Name + "】传人，把盏畅叙武林掌故，宗门交情 +15（当前：" + newRel + "）！"
	};
};

::Wuxia.SectRelations.teaHouseSpar <- function( _sectID, _mode )
{
	local town = ::Wuxia.SectRelations.getCurrentTown();
	if (town == null)
		return { ok = false, reason = "须在城池【江湖茶肆】中方能当面切磋或递帖。" };
	if (!(_sectID in ::Wuxia.Config.Sects))
		return { ok = false, reason = "未找到该江湖宗门。" };

	local seats = ::Wuxia.SectRelations.getTownTeaHouseSeats(town);
	if (!(_sectID in seats))
		return { ok = false, reason = "该宗门传人未在此城茶肆落座。" };

	local sect = ::Wuxia.Config.Sects[_sectID];
	if (_mode == "offend")
	{
		local nextRel = ::Wuxia.SectRelations.addRelation(_sectID, -35);
		local vWarn = ::Wuxia.SectRelations.isVendettaActive(_sectID) ? "该派已传下江湖追杀令，小心道上寻仇高手！" : "双方梁子已结！";
		return {
			ok      = true,
			message = "当众拂袖撕碎【" + sect.Name + "】门帖，宗门交情 -35（当前：" + nextRel + "）！" + vWarn
		};
	}

	local cd = ::Wuxia.SectRelations.getTeaCooldownLeft("spar", _sectID, 5);
	if (cd > 0)
		return { ok = false, reason = "近日已与该派传人切磋印证，需潜心体悟 " + cd + " 日后再行拆招。" };

	local bros = (::World.getPlayerRoster() != null) ? ::World.getPlayerRoster().getAll() : [];
	local bestBro = null;
	local bestScore = -1;
	foreach (b in bros)
	{
		if (b == null || !b.isAlive()) continue;
		local cp = b.getCurrentProperties();
		local sc = cp.getMeleeSkill() + ::Math.floor(cp.getBravery() * 0.5);
		if (sc > bestScore) { bestScore = sc; bestBro = b; }
	}
	if (bestBro == null)
		return { ok = false, reason = "麾下暂无可登台拆招之侠客。" };

	::World.Flags.set("wx_tea_spar_" + _sectID, ::World.getTime().Days);
	local strongWin = (bestScore + ::Math.rand(1, 20) >= 92);
	local relGain = strongWin ? 12 : 7;
	local expGain = strongWin ? 65 : 40;
	local newRel = ::Wuxia.SectRelations.addRelation(_sectID, relGain);

	if ("Mastery" in ::Wuxia && "grantFlatExpToEquipped" in ::Wuxia.Mastery)
	{
		::Wuxia.Mastery.grantFlatExpToEquipped(bestBro, expGain);
	}
	else
	{
		local cont = ::Wuxia.Slots.getContainer(bestBro);
		if (cont != null)
		{
			for (local si = 0; si < cont.m.Slots.len(); si = ++si)
			{
				if (cont.m.Slots[si].ManualID != null && cont.m.Slots[si].Tier > 0)
					::Wuxia.Mastery.addSlotExp(bestBro, si, expGain);
			}
		}
	}

	return {
		ok      = true,
		message = bestBro.getName() + " 登茶楼演武坪与【" + sect.Name + "】传人拆招印证，" + (strongWin ? "招式精妙引满堂喝彩" : "点到为止互有启发") + "！【" + sect.Name + "】交情 +" + relGain + "（当前：" + newRel + "），全身已装功法历练 +" + expGain + "！"
	};
};

// Award or deduct local Sect Relations organically when slaying Outlaw Bosses or attacking Sect Patrols
::Wuxia.SectRelations.onCombatActorSlain <- function( _victim, _isBoss )
{
	if (_victim == null || !("World" in getroottable()) || ::World == null || ::World.State == null) return;

	// If this victim belonged to a friendly/righteous Sect Patrol (`WX_PatrolSectID`), penalize relation!
	if ("WX_PatrolSectID" in _victim.m && _victim.m.WX_PatrolSectID != null)
	{
		local psid = _victim.m.WX_PatrolSectID;
		if (psid in ::Wuxia.Config.Sects)
		{
			local pSect = ::Wuxia.Config.Sects[psid];
			if (pSect.Alignment != "outlaw")
			{
				::Wuxia.SectRelations.addRelation(psid, -12);
				return;
			}
			else
			{
				::Wuxia.SectRelations.addRelation(psid, -6);
			}
		}
	}

	if (!_isBoss) return;

	// Slaying any Bandit/Nomad/Barbarian/Goblin/Orc/Undead Boss boosts standing (+4) with the nearest town's Resident Righteous/Neutral Sect!
	local p = ::World.State.getPlayer();
	if (p == null || p.getTile() == null || ::World.EntityManager == null) return;
	local pTile = p.getTile();
	local nearestTown = null;
	local minD = 9999;
	foreach (tw in ::World.EntityManager.getSettlements())
	{
		if (tw == null || !tw.isAlive() || tw.getTile() == null) continue;
		local d = pTile.getDistanceTo(tw.getTile());
		if (d < minD) { minD = d; nearestTown = tw; }
	}
	if (nearestTown == null) return;

	local townSects = ::Wuxia.SectRelations.getSettlementSects(nearestTown);
	foreach (tsid in townSects)
	{
		if (tsid in ::Wuxia.Config.Sects && ::Wuxia.Config.Sects[tsid].Alignment != "outlaw")
		{
			local afterR = ::Wuxia.SectRelations.addRelation(tsid, 4);
			if ("Tactical" in getroottable() && ::Tactical != null && ("EventLog" in ::Tactical) && ::Tactical.EventLog != null)
			{
				::Tactical.EventLog.logEx("斩除一方凶顽，【" + ::Wuxia.Config.Sects[tsid].Name + "】闻讯嘉许（宗门交情 +4 → " + afterR + "）");
			}
			break;
		}
	}
};
