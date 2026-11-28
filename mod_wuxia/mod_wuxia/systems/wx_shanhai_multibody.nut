// Shan Hai Jing Multi-Tile Boss, Severable Appendage & Domain Totem Controller (`::Wuxia.ShanHaiMultiBody`)
// Supports 3 distinct spatial structures across 2~7 hexes:
//   - Mode A (`segments`): Coiled slithering dragon/serpent segments with independent scale armor & trail follow (`烛九阴` 3-tile)
//   - Mode B (`appendages`): Independent severable heads/limbs where slaying a part permanently/cyclically locks out its Boss skill (`相柳皇` 5-tile)
//   - Mode C (`totems`): Battlefield celestial/elemental totems projecting domain laws & counterplay (`女丑魂` 1+3 suns)

::Wuxia.ShanHaiMultiBody <- {
	Registry = {}
};

::Wuxia.ShanHaiMultiBody.clearAll <- function()
{
	::Wuxia.ShanHaiMultiBody.Registry = {};
};

::Wuxia.ShanHaiMultiBody.isLiveMap <- function( _actor )
{
	return _actor != null
		&& ("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive()
		&& ::Wuxia.hasMember(_actor, "isPlacedOnMap") && _actor.isPlacedOnMap()
		&& _actor.getTile() != null;
};

// Silence vanilla `lindwurm` auto-spawned single tail when our multi-tile controller takes over (`烛九阴` / `相柳皇`)
::Wuxia.ShanHaiMultiBody.silenceVanillaLindwurmTail <- function( _master )
{
	if (_master == null || !("m" in _master) || !("Tail" in _master.m)) return;
	local t = _master.m.Tail;
	if (t != null)
	{
		try
		{
			if (!("isNull" in t && t.isNull()) && ("isAlive" in t) && t.isAlive())
			{
				t.m.WX_IsBossSubEntity <- true;
				t.m.WX_DeathHandled <- true;
				t.killSilently();
			}
		}
		catch (_e) {}
		_master.m.Tail = null;
	}
};

::Wuxia.ShanHaiMultiBody.getOrCreateRecord <- function( _master, _mode = "segments" )
{
	if (_master == null || !::Wuxia.hasMember(_master, "getID")) return null;
	local id = _master.getID();
	if (!(id in ::Wuxia.ShanHaiMultiBody.Registry))
	{
		::Wuxia.ShanHaiMultiBody.Registry[id] <- {
			Master         = _master,
			Mode           = _mode,
			Segments       = [],
			Appendages     = {},
			Totems         = [],
			SeveredParts   = {},
			CauterizedParts = {},
			LockedSkills   = {},
			BrokenSegments = {},
			TrailTiles     = []
		};
	}
	return ::Wuxia.ShanHaiMultiBody.Registry[id];
};

::Wuxia.ShanHaiMultiBody.getRecord <- function( _master )
{
	if (_master == null || !::Wuxia.hasMember(_master, "getID")) return null;
	local id = _master.getID();
	return (id in ::Wuxia.ShanHaiMultiBody.Registry) ? ::Wuxia.ShanHaiMultiBody.Registry[id] : null;
};

::Wuxia.ShanHaiMultiBody.isSkillLocked <- function( _master, _skillID )
{
	local rec = ::Wuxia.ShanHaiMultiBody.getRecord(_master);
	if (rec == null || _skillID == null) return false;
	return (_skillID in rec.LockedSkills) && rec.LockedSkills[_skillID] == true;
};

::Wuxia.ShanHaiMultiBody.lockSkill <- function( _master, _skillID )
{
	if (_master == null || _skillID == null || _skillID == "") return false;
	local rec = ::Wuxia.ShanHaiMultiBody.getOrCreateRecord(_master, "mythic_law");
	if (rec == null) return false;
	rec.LockedSkills[_skillID] <- true;
	return true;
};

::Wuxia.ShanHaiMultiBody.isSegmentArmorBroken <- function( _master, _partKey )
{
	local rec = ::Wuxia.ShanHaiMultiBody.getRecord(_master);
	if (rec == null || _partKey == null) return false;
	return (_partKey in rec.BrokenSegments) && rec.BrokenSegments[_partKey] == true;
};

::Wuxia.ShanHaiMultiBody.getAliveAppendageCount <- function( _master )
{
	local rec = ::Wuxia.ShanHaiMultiBody.getRecord(_master);
	if (rec == null) return 0;
	local cnt = 0;
	foreach (_, app in rec.Appendages)
	{
		if (app != null && ::Wuxia.hasMember(app, "isAlive") && app.isAlive())
			cnt += 1;
	}
	return cnt;
};

::Wuxia.ShanHaiMultiBody.getAliveTotems <- function( _master )
{
	local out = [];
	local rec = ::Wuxia.ShanHaiMultiBody.getRecord(_master);
	if (rec == null) return out;
	foreach (tot in rec.Totems)
	{
		if (tot != null && ::Wuxia.hasMember(tot, "isAlive") && tot.isAlive())
			out.push(tot);
	}
	return out;
};

::Wuxia.ShanHaiMultiBody.findNearbyEmptyTiles <- function( _centerTile, _count, _minDist = 1, _maxDist = 2 )
{
	local out = [];
	if (_centerTile == null || !("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive())
		return out;
	local mapSize = ::Tactical.getMapSize();
	for (local r = _minDist; r <= _maxDist && out.len() < _count; r = ++r)
	{
		for (local x = 0; x < mapSize.X && out.len() < _count; x = ++x)
		{
			for (local y = 0; y < mapSize.Y && out.len() < _count; y = ++y)
			{
				local cand = ::Tactical.getTileSquare(x, y);
				if (cand == null || !cand.IsEmpty || cand.IsOccupiedByActor) continue;
				local d = _centerTile.getDistanceTo(cand);
				if (d == r && ::Math.abs(cand.Level - _centerTile.Level) <= 1)
					out.push(cand);
			}
		}
	}
	return out;
};

// Spawn Mode A Linked Segments (`烛九阴`: `赤鳞龙躯` + `盘山龙尾`)
::Wuxia.ShanHaiMultiBody.spawnCoiledSegments <- function( _master, _segSpecs )
{
	local rec = ::Wuxia.ShanHaiMultiBody.getOrCreateRecord(_master, "segments");
	if (rec == null || rec.Segments.len() > 0) return rec;
	::Wuxia.ShanHaiMultiBody.silenceVanillaLindwurmTail(_master);
	if (!::Wuxia.ShanHaiMultiBody.isLiveMap(_master)) return rec;

	local headTile = _master.getTile();
	rec.TrailTiles = [headTile];
	local anchor = headTile;

	foreach (spec in _segSpecs)
	{
		local cands = ::Wuxia.ShanHaiMultiBody.findNearbyEmptyTiles(anchor, 1, 1, 2);
		if (cands.len() == 0) break;
		local spawnTile = cands[0];
		local seg = ::Tactical.spawnEntity("scripts/entity/tactical/enemies/wx_boss_part_segment", spawnTile.Coords);
		if (seg != null)
		{
			seg.setFaction(_master.getFaction());
			seg.setupSegment(_master, spec);
			rec.Segments.push(seg);
			rec.TrailTiles.push(spawnTile);
			anchor = spawnTile;
		}
	}
	return rec;
};

// Spawn Mode B Severable Appendages (`相柳皇`: 4 independent functional heads)
::Wuxia.ShanHaiMultiBody.spawnSeverableAppendages <- function( _master, _appSpecs )
{
	local rec = ::Wuxia.ShanHaiMultiBody.getOrCreateRecord(_master, "appendages");
	if (rec == null || rec.Appendages.len() > 0) return rec;
	::Wuxia.ShanHaiMultiBody.silenceVanillaLindwurmTail(_master);
	if (!::Wuxia.ShanHaiMultiBody.isLiveMap(_master)) return rec;

	local center = _master.getTile();
	local emptyList = ::Wuxia.ShanHaiMultiBody.findNearbyEmptyTiles(center, _appSpecs.len(), 1, 2);
	for (local i = 0; i < _appSpecs.len() && i < emptyList.len(); i = ++i)
	{
		local spec = _appSpecs[i];
		local t = emptyList[i];
		local app = ::Tactical.spawnEntity("scripts/entity/tactical/enemies/wx_boss_part_appendage", t.Coords);
		if (app != null)
		{
			app.setFaction(_master.getFaction());
			app.setupAppendage(_master, spec);
			rec.Appendages[spec.Key] <- app;
		}
	}
	return rec;
};

// Spawn Mode C Domain Totems (`女丑魂`: 3~4 floating `汤谷炙魂日冕`)
::Wuxia.ShanHaiMultiBody.spawnDomainTotems <- function( _master, _totemSpecs, _minDist = 2, _maxDist = 4 )
{
	local rec = ::Wuxia.ShanHaiMultiBody.getOrCreateRecord(_master, "totems");
	if (rec == null || rec.Totems.len() > 0) return rec;
	if (!::Wuxia.ShanHaiMultiBody.isLiveMap(_master)) return rec;

	local center = _master.getTile();
	local emptyList = ::Wuxia.ShanHaiMultiBody.findNearbyEmptyTiles(center, _totemSpecs.len() * 2, _minDist, _maxDist);
	local step = emptyList.len() >= _totemSpecs.len() * 2 ? 2 : 1;
	local spawned = 0;
	for (local i = 0; i < emptyList.len() && spawned < _totemSpecs.len(); i += step)
	{
		local spec = _totemSpecs[spawned];
		local tot = ::Tactical.spawnEntity("scripts/entity/tactical/enemies/wx_boss_part_totem", emptyList[i].Coords);
		if (tot != null)
		{
			tot.setFaction(_master.getFaction());
			tot.setupTotem(_master, spec);
			rec.Totems.push(tot);
			spawned += 1;
		}
	}
	return rec;
};

// Register mock parts for deterministic `selftest.nut` unit tests (when `::Tactical` is offline)
::Wuxia.ShanHaiMultiBody.registerMockAppendage <- function( _master, _partKey, _lockedSkillID, _partObj )
{
	local rec = ::Wuxia.ShanHaiMultiBody.getOrCreateRecord(_master, "appendages");
	if (rec == null) return null;
	rec.Appendages[_partKey] <- _partObj;
	return rec;
};

// Slither trail update & appendage tethering when Master Boss moves to `_newTile`
::Wuxia.ShanHaiMultiBody.onMasterMoved <- function( _master, _prevTile, _newTile )
{
	local rec = ::Wuxia.ShanHaiMultiBody.getRecord(_master);
	if (rec == null || _newTile == null || _prevTile == null || _prevTile.ID == _newTile.ID) return;
	if (!::Wuxia.ShanHaiMultiBody.isLiveMap(_master)) return;

	if (rec.Mode == "segments" && rec.Segments.len() > 0)
	{
		local prevCursor = _prevTile;
		foreach (seg in rec.Segments)
		{
			if (seg == null || !seg.isAlive() || !seg.isPlacedOnMap()) continue;
			local segOld = seg.getTile();
			if (prevCursor != null && prevCursor.IsEmpty && !prevCursor.IsOccupiedByActor)
			{
				::Tactical.getNavigator().teleport(seg, prevCursor, null, null, false);
				prevCursor = segOld;
			}
		}
	}
	else if (rec.Mode == "appendages")
	{
		foreach (_, app in rec.Appendages)
		{
			if (app == null || !app.isAlive() || !app.isPlacedOnMap()) continue;
			if (app.getTile().getDistanceTo(_newTile) > 2)
			{
				local near = ::Wuxia.ShanHaiMultiBody.findNearbyEmptyTiles(_newTile, 1, 1, 2);
				if (near.len() > 0)
					::Tactical.getNavigator().teleport(app, near[0], null, null, false);
			}
		}
	}
};

// Check whether killing blow seared/cauterized a severed appendage (`阳刚真气 / 烈火刀法 / 火铳霹雳弹`)
::Wuxia.ShanHaiMultiBody.isFireOrYangAttack <- function( _killer, _skill )
{
	if (_skill != null && ::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null)
	{
		local sid = _skill.getID();
		if (sid == "actives.wx_saber_ranmu" || sid == "actives.wx_saber_huoyandao"
			|| sid == "actives.wx_throw_pilidan" || sid == "actives.wx_gun_huolong"
			|| sid == "actives.wx_gun_leihuo" || sid == "actives.wx_bow_luori"
			|| sid == "actives.wx_fist_xianglong")
			return true;
	}
	if (_killer != null && ::Wuxia.TileField.getPrimaryNeigongElement(_killer) == "yang")
		return true;
	return false;
};

// Callback when a Mode A segment's scale armor is broken for the first time
::Wuxia.ShanHaiMultiBody.onSegmentArmorBroken <- function( _master, _partKey, _partName )
{
	local rec = ::Wuxia.ShanHaiMultiBody.getRecord(_master);
	if (rec == null || (_partKey in rec.BrokenSegments)) return;
	rec.BrokenSegments[_partKey] <- true;
	if ("CraftBridge" in ::Wuxia && "markBossPartBroken" in ::Wuxia.CraftBridge)
	{
		::Wuxia.CraftBridge.markBossPartBroken(_master, _partKey == "tail_seg" ? "tail" : "shell");
		::Wuxia.CraftBridge.markBossPartBroken(_master, "head");
	}

	local sk = ::Wuxia.hasMember(_master, "getSkills") ? _master.getSkills() : null;
	if (sk != null)
	{
		if (!sk.hasSkill("effects.wx_status_opening"))
			sk.add(::new("scripts/skills/effects/wx_status_opening"));
		local tr = ("ShanHai" in ::Wuxia && "findBossTrait" in ::Wuxia.ShanHai)
			? ::Wuxia.ShanHai.findBossTrait(sk)
			: sk.getSkillByID("special.wx_shanhai_boss_trait");
		if (tr != null && ::Wuxia.hasMember(tr, "onSubPartBroken"))
			tr.onSubPartBroken(_partKey);
	}

	if (::Wuxia.TileField.isLiveTactical() && "EventLog" in ::Tactical && ::Tactical.EventLog != null)
		::Tactical.EventLog.log("[color=#166b2f]【破鳞断势】" + _partName + " 护体龙鳞崩裂，大妖真身露出七寸破绽！[/color]");
};

// Callback when a Mode B severable appendage (`相柳四首` etc.) is slain!
::Wuxia.ShanHaiMultiBody.onAppendageSevered <- function( _part, _killer, _skill, _tile )
{
	if (_part == null || !("m" in _part) || _part.m.WX_Master == null) return false;
	local master = _part.m.WX_Master;
	if (!::Wuxia.hasMember(master, "isAlive") || !master.isAlive()) return false;

	local rec = ::Wuxia.ShanHaiMultiBody.getOrCreateRecord(master, "appendages");
	local pKey = _part.m.WX_PartKey;
	local lockedSkill = _part.m.WX_LockedSkillID;
	local cauterized = ::Wuxia.ShanHaiMultiBody.isFireOrYangAttack(_killer, _skill);

	rec.SeveredParts[pKey] <- true;
	if (cauterized) rec.CauterizedParts[pKey] <- true;
	if ("CraftBridge" in ::Wuxia && "markBossPartBroken" in ::Wuxia.CraftBridge)
		::Wuxia.CraftBridge.markBossPartBroken(master, "head");
	if (lockedSkill != null && lockedSkill != "")
		rec.LockedSkills[lockedSkill] <- true;
	if (pKey in rec.Appendages)
		delete rec.Appendages[pKey];

	// Inflict sever backlash on Master Boss (8% MaxHP floor 35, never below 1 HP) + Opening & Offbalance!
	local backlash = ::Math.max(35, ::Math.floor(master.getHitpointsMax() * 0.08));
	if (master.getHitpoints() > backlash + 1) master.setHitpoints(master.getHitpoints() - backlash);
	else master.setHitpoints(1);

	local msk = ::Wuxia.hasMember(master, "getSkills") ? master.getSkills() : null;
	if (msk != null)
	{
		if (!msk.hasSkill("effects.wx_status_opening"))
			msk.add(::new("scripts/skills/effects/wx_status_opening"));
		if (!msk.hasSkill("effects.wx_status_offbalance"))
			msk.add(::new("scripts/skills/effects/wx_status_offbalance"));
		local tr = ("ShanHai" in ::Wuxia && "findBossTrait" in ::Wuxia.ShanHai)
			? ::Wuxia.ShanHai.findBossTrait(msk)
			: msk.getSkillByID("special.wx_shanhai_boss_trait");
		if (tr != null && ::Wuxia.hasMember(tr, "onAppendageSevered"))
			tr.onAppendageSevered(pKey, lockedSkill, cauterized, _tile);
	}

	if (::Wuxia.TileField.isLiveTactical() && "EventLog" in ::Tactical && ::Tactical.EventLog != null)
	{
		local note = cauterized ? "（断口已被阳炎灼封，无法再生！）" : "（腥血洒地化作苦毒腐泽！）";
		::Tactical.EventLog.log("[color=#166b2f]【斩首封招】" + _part.getName() + " 被一举斩落，对应凶招已遭封印！" + note + "[/color]");
	}
	return true;
};

// Callback when a Mode C domain totem (`汤谷炙魂日冕` etc.) is destroyed!
::Wuxia.ShanHaiMultiBody.onTotemDestroyed <- function( _totem, _killer, _skill, _tile )
{
	if (_totem == null || !("m" in _totem) || _totem.m.WX_Master == null) return false;
	local master = _totem.m.WX_Master;
	if (!::Wuxia.hasMember(master, "isAlive") || !master.isAlive()) return false;
	if ("CraftBridge" in ::Wuxia && "markBossPartBroken" in ::Wuxia.CraftBridge)
		::Wuxia.CraftBridge.markBossPartBroken(master, "core");

	local msk = ::Wuxia.hasMember(master, "getSkills") ? master.getSkills() : null;
	if (msk != null)
	{
		local tr = ("ShanHai" in ::Wuxia && "findBossTrait" in ::Wuxia.ShanHai)
			? ::Wuxia.ShanHai.findBossTrait(msk)
			: msk.getSkillByID("special.wx_shanhai_boss_trait");
		if (tr != null && ::Wuxia.hasMember(tr, "onTotemDestroyed"))
			tr.onTotemDestroyed(_totem.m.WX_PartKey, _killer, _tile);
	}
	return true;
};

// Regrow one uncauterized severed appendage for Xiangliu if `生肌血首` survives & `bitter_mire` exists
::Wuxia.ShanHaiMultiBody.tryRegrowAppendage <- function( _master, _spec )
{
	local rec = ::Wuxia.ShanHaiMultiBody.getRecord(_master);
	if (rec == null || _spec == null) return false;
	local pKey = _spec.Key;
	if (!(pKey in rec.SeveredParts) || (pKey in rec.CauterizedParts)) return false;

	delete rec.SeveredParts[pKey];
	if ("LockedSkillID" in _spec && _spec.LockedSkillID != null && (_spec.LockedSkillID in rec.LockedSkills))
		delete rec.LockedSkills[_spec.LockedSkillID];

	if (::Wuxia.ShanHaiMultiBody.isLiveMap(_master))
	{
		local emptyList = ::Wuxia.ShanHaiMultiBody.findNearbyEmptyTiles(_master.getTile(), 1, 1, 2);
		if (emptyList.len() > 0)
		{
			local app = ::Tactical.spawnEntity("scripts/entity/tactical/enemies/wx_boss_part_appendage", emptyList[0].Coords);
			if (app != null)
			{
				app.setFaction(_master.getFaction());
				app.setupAppendage(_master, _spec);
				rec.Appendages[pKey] <- app;
			}
		}
	}
	return true;
};

// Clean up all sub-entities immediately when Master Boss dies so battle ends cleanly!
::Wuxia.ShanHaiMultiBody.onMasterDeath <- function( _master )
{
	local rec = ::Wuxia.ShanHaiMultiBody.getRecord(_master);
	if (rec == null) return;

	foreach (seg in rec.Segments)
	{
		try
		{
			if (seg != null && ::Wuxia.hasMember(seg, "isAlive") && seg.isAlive())
			{
				seg.m.WX_Master = null;
				seg.m.WX_DeathHandled <- true;
				seg.killSilently();
			}
		}
		catch (_e1) {}
	}
	foreach (_, app in rec.Appendages)
	{
		try
		{
			if (app != null && ::Wuxia.hasMember(app, "isAlive") && app.isAlive())
			{
				app.m.WX_Master = null;
				app.m.WX_DeathHandled <- true;
				app.killSilently();
			}
		}
		catch (_e2) {}
	}
	foreach (tot in rec.Totems)
	{
		try
		{
			if (tot != null && ::Wuxia.hasMember(tot, "isAlive") && tot.isAlive())
			{
				tot.m.WX_Master = null;
				tot.m.WX_DeathHandled <- true;
				tot.killSilently();
			}
		}
		catch (_e3) {}
	}
	if (::Wuxia.hasMember(_master, "getID") && (_master.getID() in ::Wuxia.ShanHaiMultiBody.Registry))
		delete ::Wuxia.ShanHaiMultiBody.Registry[_master.getID()];
};
