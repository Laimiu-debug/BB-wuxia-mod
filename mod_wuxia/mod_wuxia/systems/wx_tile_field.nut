// Dynamic Battlefield Tile & Celestial Weather Engine (`::Wuxia.TileField`)
// Non-destructively manages 8 Shan Hai Jing mythic terrains + 3 Wuxia tactical constructs (`sword_node`, `tangmen_trap`, `bagua_gate`)
// without overwriting vanilla `tile.Properties.Effect` strings. Safe both in live Tactical combat and offline `selftest.nut` mocks.

::Wuxia.TileField <- {
	Fields = {},
	Weather = {
		Kind      = null,
		OwnerID   = -1,
		TurnsLeft = 0,
		WindDir   = 0,
		Intensity = 0
	},

	Catalog = {
		drought_scorch = {
			Name        = "赤旱焦土",
			DecalKind   = "scorch",
			Tint        = [255, 148, 72],
			DefaultTurn = 3,
			Desc        = "大旱炙烤之地：踏入或驻留每回合蒸干 8 点内息，护甲受热脆化（所受破甲伤 +20%）；遇玄冥寒潮引发寒暑蒸汽崩裂，遇玄阴招式化为护体寒雾。"
		},
		bitter_mire = {
			Name        = "苦毒腐泽",
			DecalKind   = "venom",
			Tint        = [136, 238, 112],
			DefaultTurn = 4,
			Desc        = "共工相柳腥血所化苦泽：驻留移动耗点 +1 AP，回合末蚀损 10 点身甲并染奇毒；水上轻功免阻滞，阳刚烈火或火器可焚干毒泽。"
		},
		abyss_frost = {
			Name        = "玄冥冻土",
			DecalKind   = "frost",
			Tint        = [168, 236, 255],
			DefaultTurn = 3,
			Desc        = "太古寒螟霜封之地：身法 -18，连续驻留触发寒霜封足失衡；主修阳刚内功者踏上自动融冰回气，遇钟山炎风引发寒暑蒸汽崩裂。"
		},
		thunder_pool = {
			Name        = "流波雷池",
			DecalKind   = "scorch",
			Tint        = [192, 142, 255],
			DefaultTurn = 3,
			Desc        = "东海夔牛紫电雷泽：头身甲负重 > 22 的重甲单位受击时导电溅射邻格 12 实伤与 10 内息；布衣轻装侠客（负重 <= 15）踏入可安全卸雷回气。"
		},
		mirage_mist = {
			Name        = "青丘迷障",
			DecalKind   = "venom",
			Tint        = [236, 168, 245],
			DefaultTurn = 3,
			Desc        = "狐妖幻雾笼罩：远程射艺 -15、视野受阻，定力不足者易露破绽；《佛门狮吼功》《夔牛雷音》或《聚义号令》可一吼吹散迷障。"
		},
		gale_sandstorm = {
			Name        = "裂风沙暴",
			DecalKind   = "scorch",
			Tint        = [232, 206, 148],
			DefaultTurn = 3,
			Desc        = "八风走石罡域：顺风抢攻迅捷，逆风步履维艰且飞矢受阻（远射 -12，远防 +12）。"
		},
		blood_pool = {
			Name        = "凶煞血池",
			DecalKind   = "scorch",
			Tint        = [220, 48, 64],
			DefaultTurn = 4,
			Desc        = "生灵精血汇聚之渊：山海凶兽汲取可暴回气血；我方侠客主动踏立血池格可『以身镇血』断绝妖物汲取，烈火亦可焚干。"
		},
		ancient_ward = {
			Name        = "太极两仪域",
			DecalKind   = "frost",
			Tint        = [182, 248, 232],
			DefaultTurn = 3,
			Desc        = "阴阳圆转阵纹：阵内友军近防 +6、借力反击内息减耗，敌军武艺 -6。"
		},
		sword_node = {
			Name        = "驻场气剑残影",
			DecalKind   = "frost",
			Tint        = [130, 242, 255],
			DefaultTurn = 3,
			Desc        = "剑宗凝气插地之无形剑影：施展《万剑归宗诀》或连剑终结式时，全场气剑沿六角格直线飞掠汇聚穿刺敌阵并回补内息！"
		},
		tangmen_trap = {
			Name        = "唐门暗器机簧",
			DecalKind   = "scorch",
			Tint        = [198, 214, 230],
			DefaultTurn = 4,
			Desc        = "预埋地表的毒蒺藜机括：敌军踏入瞬间崩损 18 护甲、染奇毒并陷入失衡。"
		},
		bagua_gate = {
			Name        = "奇门八阵门",
			DecalKind   = "frost",
			Tint        = [255, 224, 138],
			DefaultTurn = 3,
			Desc        = "奇门生克阵位：友军驻生门回气 +5、近防 +6；敌军陷死门近防 -8 并挂破绽。"
		}
	}
};

::Wuxia.TileField.clearAll <- function()
{
	::Wuxia.TileField.Fields = {};
	::Wuxia.TileField.Weather = {
		Kind      = null,
		OwnerID   = -1,
		TurnsLeft = 0,
		WindDir   = 0,
		Intensity = 0
	};
};

::Wuxia.TileField.getTileKey <- function( _tile )
{
	if (_tile == null) return null;
	if (typeof _tile == "integer" || typeof _tile == "string") return "" + _tile;
	if (::Wuxia.hasMember(_tile, "ID")) return "" + _tile.ID;
	return null;
};

// Follow the ray from the first neighbouring hex up to the target or range limit.
::Wuxia.TileField.collectHexLine <- function( _fromTile, _toTile, _maxSteps, _includeTarget = true )
{
	local tiles = [];
	if (_toTile == null || !::Wuxia.hasMember(_fromTile, "getDirectionTo")) return tiles;
	local current = _fromTile;
	for (local i = 0; i < _maxSteps && current.ID != _toTile.ID; ++i)
	{
		local dir = current.getDirectionTo(_toTile);
		if (dir < 0 || !current.hasNextTile(dir)) break;
		current = current.getNextTile(dir);
		if (_includeTarget || current.ID != _toTile.ID) tiles.push(current);
	}
	return tiles;
};

::Wuxia.TileField.getField <- function( _tile )
{
	local k = ::Wuxia.TileField.getTileKey(_tile);
	if (k == null || !(k in ::Wuxia.TileField.Fields)) return null;
	return ::Wuxia.TileField.Fields[k];
};

::Wuxia.TileField.normalizeKind <- function( _kind )
{
	if (_kind == "gale_sand") return "gale_sandstorm";
	if (_kind == "trap_caltrop") return "tangmen_trap";
	if (_kind == "taiji_domain") return "ancient_ward";
	return _kind;
};

::Wuxia.TileField.hasField <- function( _tile, _kind = null )
{
	local f = ::Wuxia.TileField.getField(_tile);
	if (f == null) return false;
	return _kind == null || f.Kind == ::Wuxia.TileField.normalizeKind(_kind);
};

::Wuxia.TileField.removeField <- function( _tile )
{
	local k = ::Wuxia.TileField.getTileKey(_tile);
	if (k != null && (k in ::Wuxia.TileField.Fields))
		delete ::Wuxia.TileField.Fields[k];
};

::Wuxia.TileField.setWeather <- function( _kind, _ownerID = -1, _turns = 2, _windDir = 0, _intensity = 1 )
{
	::Wuxia.TileField.Weather = {
		Kind      = _kind,
		OwnerID   = _ownerID,
		TurnsLeft = _turns,
		WindDir   = _windDir,
		Intensity = _intensity
	};
};

::Wuxia.TileField.getWeather <- function()
{
	return ::Wuxia.TileField.Weather;
};

::Wuxia.TileField.isLiveTactical <- function()
{
	return ("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive();
};

::Wuxia.TileField.renderFieldVisual <- function( _tile, _kind, _delayMs = 0 )
{
	if (_tile == null || !::Wuxia.TileField.isLiveTactical()) return;
	if (!(_kind in ::Wuxia.TileField.Catalog)) return;
	local cat = ::Wuxia.TileField.Catalog[_kind];
	if ("KineticVFX" in ::Wuxia && "spawnGroundDecal" in ::Wuxia.KineticVFX)
	{
		local t = cat.Tint;
		local sc = (_kind == "sword_node") ? 0.92 : 1.24;
		::Wuxia.KineticVFX.spawnGroundDecal(_tile, cat.DecalKind, _delayMs, sc, t[0], t[1], t[2]);
		if (_kind == "sword_node" && "spawnShockwaveRing" in ::Wuxia.KineticVFX)
			::Wuxia.KineticVFX.spawnShockwaveRing(_tile, "wx_pt_ring_cyan", _delayMs + 20, 0.25, 1.05, 0.32, -16.0, 210);
		else if (_kind == "thunder_pool" && "spawnShockwaveRing" in ::Wuxia.KineticVFX)
			::Wuxia.KineticVFX.spawnShockwaveRing(_tile, "wx_pt_ring_violet", _delayMs + 20, 0.30, 1.35, 0.34, -10.0, 215);
	}
};

// Trigger true elemental thermal shockwave (`寒暑崩裂蒸汽爆`) when extreme Frost & extreme Scorch collide!
::Wuxia.TileField.triggerSteamBurst <- function( _tile, _instigator = null )
{
	if (_tile == null) return 0;
	::Wuxia.TileField.removeField(_tile);

	if (::Wuxia.TileField.isLiveTactical())
	{
		if ("KineticVFX" in ::Wuxia)
		{
			::Wuxia.KineticVFX.spawnShockwaveRing(_tile, "wx_pt_ring_frost", 0, 0.30, 2.55, 0.36, -12.0, 240);
			::Wuxia.KineticVFX.spawnShockwaveRing(_tile, "wx_pt_ring_fire", 45, 0.24, 2.25, 0.34, -12.0, 230);
		}
	}

	local affected = 0;
	local hitTiles = [_tile];
	if (::Wuxia.hasMember(_tile, "hasNextTile"))
	{
		for (local d = 0; d < 6; d = ++d)
		{
			if (_tile.hasNextTile(d))
				hitTiles.push(_tile.getNextTile(d));
		}
	}

	foreach (ht in hitTiles)
	{
		if (ht == null || !::Wuxia.isTileOccupiedByActor(ht)) continue;
		local ent = ht.getEntity();
		if (ent == null || !ent.isAlive()) continue;
		if (_instigator != null && ::Wuxia.hasMember(_instigator, "getID") && ::Wuxia.hasMember(ent, "getID") && ent.getID() == _instigator.getID())
			continue;
		local dmg = (ht == _tile) ? 22 : 12;
		if (ent.getHitpoints() > dmg + 1) ent.setHitpoints(ent.getHitpoints() - dmg);
		else ent.setHitpoints(1);
		if (ent.getSkills() != null && !ent.getSkills().hasSkill("effects.wx_status_offbalance"))
			ent.getSkills().add(::new("scripts/skills/effects/wx_status_offbalance"));
		affected += 1;
	}

	if (::Wuxia.TileField.isLiveTactical() && "EventLog" in ::Tactical && ::Tactical.EventLog != null)
		::Tactical.EventLog.log("[color=#d94b2b]【寒暑崩裂】冰火异象猛烈对冲，炸开滚烫白汽震伤四野！[/color]");

	return affected;
};

// Place or react a dynamic field on `_tile`. Returns `{ outcome = "placed" | "steam_burst" | "cauterized" | "quenched", affected = int }`
::Wuxia.TileField.setField <- function( _tile, _kind, _turns = -1, _owner = null, _subKind = "", _power = 1 )
{
	_kind = ::Wuxia.TileField.normalizeKind(_kind);
	local res = { outcome = "none", affected = 0 };
	local k = ::Wuxia.TileField.getTileKey(_tile);
	if (k == null || !(_kind in ::Wuxia.TileField.Catalog)) return res;

	local ownerID = (_owner != null && ::Wuxia.hasMember(_owner, "getID")) ? _owner.getID() : -1;
	local faction = (_owner != null && ::Wuxia.hasMember(_owner, "getFaction")) ? _owner.getFaction() : -1;
	local isPlayerOwner = (_owner != null && ::Wuxia.hasMember(_owner, "isPlayerControlled") && _owner.isPlayerControlled());

	local existing = (k in ::Wuxia.TileField.Fields) ? ::Wuxia.TileField.Fields[k] : null;
	if (existing != null)
	{
		// Reaction 1: Scorch + Frost -> Steam Explosion (or Frost Mist if player Yin quenches scorch)
		if ((existing.Kind == "abyss_frost" && _kind == "drought_scorch") || (existing.Kind == "drought_scorch" && _kind == "abyss_frost"))
		{
			if (isPlayerOwner && _kind == "abyss_frost" && existing.Kind == "drought_scorch")
			{
				::Wuxia.TileField.removeField(_tile);
				if (_owner != null) ::Wuxia.CombatRules.restoreQi(_owner, 6);
				res.outcome = "quenched";
				return res;
			}
			res.affected = ::Wuxia.TileField.triggerSteamBurst(_tile, _owner);
			res.outcome = "steam_burst";
			return res;
		}
		// Reaction 2: Fire / Drought Scorch on Bitter Mire or Blood Pool -> Cauterize & Burn Clean!
		if ((existing.Kind == "bitter_mire" || existing.Kind == "blood_pool") && _kind == "drought_scorch")
		{
			::Wuxia.TileField.removeField(_tile);
			::Wuxia.TileField.renderFieldVisual(_tile, "drought_scorch", 0);
			if (::Wuxia.TileField.isLiveTactical() && "EventLog" in ::Tactical && ::Tactical.EventLog != null)
				::Tactical.EventLog.log("[color=#e07a2b]【烈火焚泽】阳炎烈火将苦毒血泽彻底焚干灼封！[/color]");
			res.outcome = "cauterized";
			return res;
		}
	}

	// Enforce max 5 active `sword_node` per owner (FIFO eviction)
	if (_kind == "sword_node" && ownerID != -1)
	{
		local ownedKeys = [];
		foreach (fk, fv in ::Wuxia.TileField.Fields)
		{
			if (fv.Kind == "sword_node" && fv.OwnerID == ownerID)
				ownedKeys.push(fk);
		}
		if (ownedKeys.len() >= 5)
		{
			ownedKeys.sort();
			delete ::Wuxia.TileField.Fields[ownedKeys[0]];
		}
	}

	local cat = ::Wuxia.TileField.Catalog[_kind];
	local dur = (_turns > 0) ? _turns : cat.DefaultTurn;
	::Wuxia.TileField.Fields[k] <- {
		TileKey   = k,
		TileRef   = _tile,
		Kind      = _kind,
		OwnerID   = ownerID,
		Faction   = faction,
		TurnsLeft = dur,
		SubKind   = _subKind,
		Power     = _power,
		StayCount = 0
	};

	::Wuxia.TileField.renderFieldVisual(_tile, _kind, 0);
	res.outcome = "placed";
	return res;
};

::Wuxia.TileField.getPrimaryNeigongElement <- function( _actor )
{
	if (_actor == null || !::Wuxia.hasMember(_actor, "getSkills") || _actor.getSkills() == null) return "";
	local c = _actor.getSkills().getSkillByID("special.wx_martial_container");
	if (c == null || !("Slots" in c.m) || c.m.Slots.len() == 0) return "";
	local s0 = c.m.Slots[0];
	if (s0.ManualID == null || s0.Tier <= 0) return "";
	local def = ::Wuxia.Slots.getManualDef(s0.ManualID);
	return (def != null && "Element" in def && def.Element != null) ? def.Element : "";
};

::Wuxia.TileField.hasWaterQinggong <- function( _actor )
{
	if (_actor == null || !::Wuxia.hasMember(_actor, "getSkills") || _actor.getSkills() == null) return false;
	local sk = _actor.getSkills();
	if (sk.hasSkill("actives.wx_qinggong_shuishang") || sk.hasSkill("actives.wx_qinggong_lingbo") || sk.hasSkill("perk.pathfinder"))
		return true;
	local c = sk.getSkillByID("special.wx_martial_container");
	return (c != null && c.m.CachedAggFlags != null && c.m.CachedAggFlags.TerrainCostHalved);
};

// Apply passive stat modifiers while an actor stands on a dynamic tile or under global Shan Hai weather
::Wuxia.TileField.applyActorUpdate <- function( _actor, _properties )
{
	if (_actor == null || _properties == null) return;

	// 1. Global Celestial Weather (`烛九阴·昼夜天象` / `十日酷暑` / `裂风沙暴`)
	local w = ::Wuxia.TileField.Weather;
	if (w.Kind != null && w.TurnsLeft > 0)
	{
		local isOwner = (::Wuxia.hasMember(_actor, "getID") && _actor.getID() == w.OwnerID);
		if (w.Kind == "zhuyin_night" && !isOwner)
		{
			if (!("IsAffectedByNight" in _properties && !_properties.IsAffectedByNight))
			{
				_properties.Vision -= 2;
				_properties.RangedSkill -= 12;
			}
		}
		else if (w.Kind == "zhuyin_day" && !isOwner)
		{
			_properties.Vision += 1;
		}
	}

	// 2. Standing Tile Field Effects
	if (!::Wuxia.hasMember(_actor, "isPlacedOnMap") || !_actor.isPlacedOnMap()) return;
	local tile = _actor.getTile();
	local f = ::Wuxia.TileField.getField(tile);
	if (f == null) return;

	local isAlly = f.Faction != -1 && _actor.isAlliedWith(f.Faction);

	if (f.Kind == "drought_scorch")
	{
		_properties.DamageReceivedArmorMult *= 1.20;
	}
	else if (f.Kind == "bitter_mire")
	{
		if (!isAlly && !::Wuxia.TileField.hasWaterQinggong(_actor))
			_properties.MovementAPCostAdditional += 1;
	}
	else if (f.Kind == "abyss_frost")
	{
		if (!isAlly && ::Wuxia.TileField.getPrimaryNeigongElement(_actor) != "yang")
			_properties.Initiative -= 18;
	}
	else if (f.Kind == "mirage_mist")
	{
		if (!isAlly)
		{
			_properties.RangedSkill -= 15;
			_properties.Vision -= 2;
		}
	}
	else if (f.Kind == "gale_sandstorm")
	{
		_properties.RangedDefense += 12;
		_properties.RangedSkill -= 12;
	}
	else if (f.Kind == "ancient_ward")
	{
		if (isAlly)
			_properties.MeleeDefense += 6;
		else
			_properties.MeleeSkill -= 6;
	}
	else if (f.Kind == "bagua_gate")
	{
		if (f.SubKind == "sheng" && isAlly)
			_properties.MeleeDefense += 6;
		else if (f.SubKind == "si" && !isAlly)
			_properties.MeleeDefense -= 8;
	}
};

// Triggered when an actor starts their turn or finishes stepping onto a tile
::Wuxia.TileField.onActorTileTick <- function( _actor, _tile, _isTurnStart = true )
{
	if (_actor == null || !_actor.isAlive() || _tile == null) return;
	local f = ::Wuxia.TileField.getField(_tile);
	if (f == null) return;

	local sk = ::Wuxia.hasMember(_actor, "getSkills") ? _actor.getSkills() : null;
	local isBossSub = ::Wuxia.hasMember(_actor, "m") && ("WX_IsBossSubEntity" in _actor.m) && _actor.m.WX_IsBossSubEntity;
	if (isBossSub) return;
	local isAlly = f.Faction != -1 && _actor.isAlliedWith(f.Faction);
	local ngElem = ::Wuxia.TileField.getPrimaryNeigongElement(_actor);

	if (f.Kind == "abyss_frost")
	{
		// Pure Yang Neigong melts frost automatically and restores 5 Qi!
		if (ngElem == "yang")
		{
			::Wuxia.TileField.removeField(_tile);
			::Wuxia.CombatRules.restoreQi(_actor, 5);
			if (::Wuxia.TileField.isLiveTactical() && "EventLog" in ::Tactical && ::Tactical.EventLog != null)
				::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(_actor) + " 体内纯阳真气运转，踏碎足下玄冥寒霜并回气 5 点！");
			return;
		}
		if (!isAlly && _isTurnStart)
		{
			f.StayCount += 1;
			if (f.StayCount >= 2 && sk != null && !sk.hasSkill("effects.wx_status_offbalance"))
				sk.add(::new("scripts/skills/effects/wx_status_offbalance"));
		}
	}
	else if (f.Kind == "drought_scorch")
	{
		if (!isAlly)
		{
			local pBuff = sk != null ? sk.getSkillByID("effects.wx_pill_battle_buff") : null;
			local hasIcePill = (pBuff != null && pBuff.m.HasBingxin);
			if (!hasIcePill && !::Wuxia.CombatRules.isUndeadOrConstruct(_actor))
				::Wuxia.CombatRules.spendQi(_actor, _isTurnStart ? 8 : 5);
		}
	}
	else if (f.Kind == "bitter_mire")
	{
		if (!isAlly && _isTurnStart)
		{
			if (!::Wuxia.TileField.hasWaterQinggong(_actor) && !::Wuxia.CombatRules.isUndeadOrConstruct(_actor))
				::Wuxia.CombatRules.spendQi(_actor, 6);
			if (::Wuxia.hasMember(_actor, "getItems") && _actor.getItems() != null)
			{
				local body = _actor.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (body != null && body.getArmor() > 0)
					body.setArmor(::Math.max(0, body.getArmor() - 10));
			}
			local props = _actor.getCurrentProperties();
			if (sk != null && !props.IsImmuneToPoison && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_actor) && !sk.hasSkill("effects.wx_status_poison_dart"))
				sk.add(::new("scripts/skills/effects/wx_status_poison_dart"));
		}
	}
	else if (f.Kind == "thunder_pool")
	{
		local pen = ::Wuxia.CombatRules.getArmorStaminaPenalty(_actor);
		// Light-armor heroes safely ground/absorb the lightning pool!
		if (!isAlly && pen <= 15 && ::Wuxia.hasMember(_actor, "isPlayerControlled") && _actor.isPlayerControlled())
		{
			::Wuxia.TileField.removeField(_tile);
			::Wuxia.CombatRules.restoreQi(_actor, 4);
		}
	}
	else if (f.Kind == "mirage_mist")
	{
		if (!isAlly && _isTurnStart && sk != null)
		{
			local brav = _actor.getCurrentProperties().Bravery;
			if (brav < 65 && !sk.hasSkill("effects.wx_status_opening"))
				sk.add(::new("scripts/skills/effects/wx_status_opening"));
		}
	}
	else if (f.Kind == "tangmen_trap")
	{
		if (!isAlly)
		{
			::Wuxia.TileField.removeField(_tile);
			if (::Wuxia.hasMember(_actor, "getItems") && _actor.getItems() != null)
			{
				local bArm = _actor.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (bArm != null && bArm.getArmor() > 0)
					bArm.setArmor(::Math.max(0, bArm.getArmor() - 18));
			}
			if (sk != null)
			{
				if (!sk.hasSkill("effects.wx_status_offbalance"))
					sk.add(::new("scripts/skills/effects/wx_status_offbalance"));
				if (!::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_actor) && !sk.hasSkill("effects.wx_status_poison_dart"))
					sk.add(::new("scripts/skills/effects/wx_status_poison_dart"));
			}
		}
	}
	else if (f.Kind == "bagua_gate" && _isTurnStart)
	{
		if (f.SubKind == "sheng" && isAlly)
			::Wuxia.CombatRules.restoreQi(_actor, 5);
		else if (f.SubKind == "si" && !isAlly && sk != null && !sk.hasSkill("effects.wx_status_opening"))
			sk.add(::new("scripts/skills/effects/wx_status_opening"));
	}
};

// Metal Conduction Law on `thunder_pool` when a heavy-armored unit (`penalty > 22`) takes damage!
::Wuxia.TileField.onActorDamagedOnTile <- function( _actor )
{
	if (_actor == null || !_actor.isAlive() || !::Wuxia.hasMember(_actor, "isPlacedOnMap") || !_actor.isPlacedOnMap()) return 0;
	local tile = _actor.getTile();
	if (!::Wuxia.TileField.hasField(tile, "thunder_pool")) return 0;
	local pen = ::Wuxia.CombatRules.getArmorStaminaPenalty(_actor);
	if (pen <= 22) return 0;

	local arcHits = 0;
	if (::Wuxia.hasMember(tile, "hasNextTile"))
	{
		for (local d = 0; d < 6; d = ++d)
		{
			if (!tile.hasNextTile(d)) continue;
			local nt = tile.getNextTile(d);
			if (!nt.IsOccupiedByActor) continue;
			local ent = nt.getEntity();
			if (ent == null || !ent.isAlive() || !_actor.isAlliedWith(ent)) continue;
			if (ent.getHitpoints() > 13) ent.setHitpoints(ent.getHitpoints() - 12);
			else ent.setHitpoints(1);
			::Wuxia.CombatRules.spendQi(ent, 10);
			arcHits += 1;
		}
	}
	return arcHits;
};

// Sonic / Rally skills dispel `mirage_mist` within `_radius`!
::Wuxia.TileField.dispelFieldsInRadius <- function( _centerTile, _radius, _kinds )
{
	if (_centerTile == null || _kinds == null || _kinds.len() == 0) return 0;
	local normKinds = [];
	foreach (kd in _kinds) normKinds.push(::Wuxia.TileField.normalizeKind(kd));
	local removed = 0;
	local toDelete = [];
	foreach (k, f in ::Wuxia.TileField.Fields)
	{
		if (normKinds.find(f.Kind) == null) continue;
		if (f.TileRef != null && ::Wuxia.hasMember(_centerTile, "getDistanceTo"))
		{
			if (_centerTile.getDistanceTo(f.TileRef) <= _radius)
				toDelete.push(k);
		}
	}
	foreach (dk in toDelete)
	{
		delete ::Wuxia.TileField.Fields[dk];
		removed += 1;
	}
	return removed;
};

// Count or collect active fields matching `_kind` (optionally filtered by `_ownerID`)
::Wuxia.TileField.getFieldsByKind <- function( _kind, _ownerID = null )
{
	_kind = ::Wuxia.TileField.normalizeKind(_kind);
	local out = [];
	foreach (_, f in ::Wuxia.TileField.Fields)
	{
		if (f.Kind != _kind) continue;
		if (_ownerID != null && f.OwnerID != _ownerID) continue;
		out.push(f);
	}
	return out;
};

// Round-end decay & visual refresh
::Wuxia.TileField.tickRound <- function()
{
	local expired = [];
	foreach (k, f in ::Wuxia.TileField.Fields)
	{
		f.TurnsLeft -= 1;
		if (f.TurnsLeft <= 0)
			expired.push(k);
		else
			::Wuxia.TileField.renderFieldVisual(f.TileRef, f.Kind, 0);
	}
	foreach (ek in expired)
		delete ::Wuxia.TileField.Fields[ek];

	if (::Wuxia.TileField.Weather.Kind != null && ::Wuxia.TileField.Weather.TurnsLeft > 0)
	{
		::Wuxia.TileField.Weather.TurnsLeft -= 1;
		if (::Wuxia.TileField.Weather.TurnsLeft <= 0)
			::Wuxia.TileField.Weather.Kind = null;
	}
};

::Wuxia.TileField.getActorStandingTooltip <- function( _actor )
{
	if (_actor == null || !::Wuxia.hasMember(_actor, "isPlacedOnMap") || !_actor.isPlacedOnMap()) return null;
	local f = ::Wuxia.TileField.getField(_actor.getTile());
	if (f == null || !(f.Kind in ::Wuxia.TileField.Catalog)) return null;
	local cat = ::Wuxia.TileField.Catalog[f.Kind];
	return "【脚下地脉：" + cat.Name + "（余 " + f.TurnsLeft + " 轮）】" + cat.Desc;
};

::Wuxia.HooksMod.hook("scripts/states/tactical_state", function( q )
{
	q.turnsequencebar_onNextRound = @(__original) function( _round )
	{
		if (_round > 1) ::Wuxia.TileField.tickRound();
		return __original(_round);
	};

	q.onFinish = @(__original) function()
	{
		::Wuxia.TileField.clearAll();
		::Wuxia.ShanHaiMultiBody.clearAll();
		return __original();
	};
});
