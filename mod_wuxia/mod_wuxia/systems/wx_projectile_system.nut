// Standalone Wuxia Flying Projectile System (`wx_projectiles_0.brush` — 16 Sprites)
// Non-destructively extends `::Const.ProjectileType`, `::Const.ProjectileSprite` & `::Const.ProjectileDecals`,
// and dynamically binds equipped Wuxia weapons, martial manuals, enemy archetypes & ranged skills
// to authentic flying projectiles (飞蝗石、柳叶飞刀、孔雀翎、神机火铳弹丸、袖箭、神臂弩矢、雕翎箭、五毒吹箭等).

::Wuxia.Projectiles <- {
	RegisteredCount = 0,
	SpriteOffset    = 0,
	IsArraySlot     = false,
	TypeByID        = {},
	DefByType       = {},
	VanillaTypes    = {}
};

::Wuxia.Projectiles.hasMember <- function( _obj, _k )
{
	if (_obj == null) return false;
	if (_k in _obj) return true;
	try { local _ = _obj[_k]; return true; } catch (_e) { return false; }
};

::Wuxia.Projectiles.actorHasManual <- function( _actor, _manualID )
{
	if (_actor == null || !::Wuxia.Projectiles.hasMember(_actor, "getSkills")) return false;
	local c = ::Wuxia.Slots.getContainer(_actor);
	if (c == null || !::Wuxia.Projectiles.hasMember(c, "m") || !(::Wuxia.hasMember(c.m, "Slots"))) return false;
	foreach (sl in c.m.Slots)
	{
		if (sl != null && ("ManualID" in sl) && sl.ManualID == _manualID)
			return true;
	}
	return false;
};

::Wuxia.Projectiles.cloneSafeDecals <- function( _decalBase )
{
	if (!("ProjectileDecals" in ::Const) || typeof ::Const.ProjectileDecals != "array")
		return [];
	if (_decalBase == null || _decalBase == "None" || !(_decalBase in ::Wuxia.Projectiles.VanillaTypes))
		return [];
	local baseType = ::Wuxia.Projectiles.VanillaTypes[_decalBase];
	local idx = baseType - ::Wuxia.Projectiles.SpriteOffset;
	if (idx >= 0 && idx < ::Const.ProjectileDecals.len() && typeof ::Const.ProjectileDecals[idx] == "array")
		return clone ::Const.ProjectileDecals[idx];
	return [];
};

::Wuxia.Projectiles.registerAll <- function()
{
	if (!("Const" in getroottable()) || !("ProjectileType" in ::Const) || !("ProjectileSprite" in ::Const))
		return 0;

	// Snapshot vanilla ProjectileType constants before appending WX_* entries
	foreach (k, v in ::Const.ProjectileType)
	{
		if (k != "COUNT" && typeof v == "integer")
			::Wuxia.Projectiles.VanillaTypes[k] <- v;
	}

	local arrowType = ("Arrow" in ::Const.ProjectileType) ? ::Const.ProjectileType.Arrow : 1;
	local offset = 0;
	if (arrowType == 1 && ::Const.ProjectileSprite.len() > 0)
	{
		local s0 = ::Const.ProjectileSprite[0];
		if ((typeof s0 == "string" && s0 == "projectile_01") || (typeof s0 == "array" && s0.len() > 0 && s0[0] == "projectile_01"))
			offset = 1;
	}
	::Wuxia.Projectiles.SpriteOffset = offset;

	local sampleIdx = arrowType - offset;
	if (sampleIdx >= 0 && sampleIdx < ::Const.ProjectileSprite.len() && typeof ::Const.ProjectileSprite[sampleIdx] == "array")
		::Wuxia.Projectiles.IsArraySlot = true;

	local added = 0;
	foreach (pid in ::Wuxia.Config.ProjectileOrder)
	{
		local def = ::Wuxia.Config.Projectiles[pid];
		if (def.Key in ::Const.ProjectileType)
		{
			local existing = ::Const.ProjectileType[def.Key];
			::Wuxia.Projectiles.TypeByID[pid] <- existing;
			::Wuxia.Projectiles.DefByType[existing] <- def;
			continue;
		}

		local arrIdx = ::Const.ProjectileSprite.len();
		local typeVal = arrIdx + offset;
		local entry = ::Wuxia.Projectiles.IsArraySlot ? [def.Brush, def.Brush] : def.Brush;

		::Const.ProjectileSprite.push(entry);
		if ("ProjectileDecals" in ::Const && typeof ::Const.ProjectileDecals == "array")
		{
			while (::Const.ProjectileDecals.len() < arrIdx)
				::Const.ProjectileDecals.push([]);
			::Const.ProjectileDecals.push(::Wuxia.Projectiles.cloneSafeDecals(def.DecalBase));
		}

		::Const.ProjectileType[def.Key] <- typeVal;
		::Wuxia.Projectiles.TypeByID[pid] <- typeVal;
		::Wuxia.Projectiles.DefByType[typeVal] <- def;
		added += 1;
	}

	::Const.ProjectileType.COUNT = ::Const.ProjectileSprite.len() + offset;
	::Wuxia.Projectiles.RegisteredCount = ::Wuxia.Projectiles.TypeByID.len();
	return added;
};

::Wuxia.Projectiles.getRegisteredSprite <- function( _typeVal )
{
	local idx = _typeVal - ::Wuxia.Projectiles.SpriteOffset;
	if (idx < 0 || idx >= ::Const.ProjectileSprite.len()) return null;
	local v = ::Const.ProjectileSprite[idx];
	if (typeof v == "array") return v.len() > 0 ? v[0] : null;
	return v;
};

::Wuxia.Projectiles.resolveProjectileID <- function( _skill, _user = null )
{
	if (_skill == null || !::Wuxia.Projectiles.hasMember(_skill, "m")) return null;

	local actor = _user;
	if (actor == null && ::Wuxia.Projectiles.hasMember(_skill, "getContainer") && _skill.getContainer() != null)
		actor = _skill.getContainer().getActor();

	local skID = (::Wuxia.Projectiles.hasMember(_skill, "getID") && _skill.getID() != null)
		? _skill.getID()
		: (::Wuxia.Projectiles.hasMember(_skill.m, "ID") && _skill.m.ID != null ? _skill.m.ID : "");

	// 1. Bespoke Jianghu / Folkloric Enemy Archetypes
	if (actor != null && ::Wuxia.Projectiles.hasMember(actor, "m") && ("WX_CustomEnemyBust" in actor.m) && actor.m.WX_CustomEnemyBust != null)
	{
		local bust = actor.m.WX_CustomEnemyBust;
		if (skID == "actives.wx_throw_pilidan" || skID == "actives.wx_smoke_cast")
			return "pilileihuo";
		if (bust == "wx_enemy_tangmen_killer")
			return "kongqueling";
		if (bust == "wx_enemy_wudu_blowgun")
			return "chuijian";
		if (bust == "wx_enemy_mohist_puppet")
			return "xiujian";
		if ((bust == "wx_enemy_shenji_musketeer" || bust == "wx_enemy_shenji_officer") && skID == "actives.fire_handgonne")
			return "huochongdan";
	}

	// 2. Inspect equipped Mainhand weapon first for weapon-driven identity
	local mainItem = null;
	local wID = "";
	if (actor != null && ::Wuxia.Projectiles.hasMember(actor, "getItems") && actor.getItems() != null)
	{
		mainItem = actor.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
		if (mainItem != null)
		{
			if (::Wuxia.Projectiles.hasMember(mainItem, "getID") && mainItem.getID() != null)
				wID = mainItem.getID();
			else if (::Wuxia.Projectiles.hasMember(mainItem, "m") && ::Wuxia.Projectiles.hasMember(mainItem.m, "ID") && mainItem.m.ID != null)
				wID = mainItem.m.ID;
		}
	}

	// 3. Dedicated Wuxia Active Ranged / Hidden-Weapon Moves
	if (skID == "actives.wx_throwing_rain")
	{
		if (::Wuxia.Projectiles.actorHasManual(actor, "wx_manual_tangmen_guanyin_lei"))
			return "kongqueling";
		return "lihuazhen";
	}
	if (skID == "actives.wx_throw_fan")
	{
		if (::Wuxia.Projectiles.actorHasManual(actor, "wx_manual_tangmen_guanyin_lei") && wID != "weapon.wx_relic_feidaonang")
			return "kongqueling";
		return "liuyefeidao";
	}
	if (skID == "actives.wx_throw_duzhen")  return "sangmending";
	if (skID == "actives.wx_throw_pilidan" || skID == "actives.wx_smoke_cast") return "pilileihuo";
	if (skID == "actives.wx_bow_snipe" || skID == "actives.wx_bow_liuxing")     return "liuxingjian";
	if (skID == "actives.wx_crossbow_shenji") return "shenjishi";

	// 4. Weapon-to-Projectile Map + Martial Manual Upgrades on Basic Attacks
	if (wID != "" && (wID in ::Wuxia.Config.WeaponProjectileMap))
	{
		local mapped = ::Wuxia.Config.WeaponProjectileMap[wID];

		// Tangmen / Sleeve-Dart / Coin-Dart manual upgrades when throwing standard darts
		if (mapped == "liuyefeidao" && wID != "weapon.wx_relic_feidaonang")
		{
			if (::Wuxia.Projectiles.actorHasManual(actor, "wx_manual_tangmen_guanyin_lei"))
				return "kongqueling";
			if (::Wuxia.Projectiles.actorHasManual(actor, "wx_manual_xiushou"))
				return "xiujian";
			if (::Wuxia.Projectiles.actorHasManual(actor, "wx_manual_jianghu_feibiao"))
				return "jinqianbiao";
		}
		else if (mapped == "diaolingjian")
		{
			if (::Wuxia.Projectiles.actorHasManual(actor, "wx_manual_dahuang_luori") || ::Wuxia.Projectiles.actorHasManual(actor, "wx_manual_baima_luori_jian"))
				return "liuxingjian";
		}
		else if (mapped == "shenjishi" && wID != "weapon.wx_relic_shenbinu")
		{
			if (::Wuxia.Projectiles.actorHasManual(actor, "wx_manual_tangmen_liannu"))
				return "xiujian";
		}
		return mapped;
	}

	// 5. Explicit Vanilla Skill Map (`sling_stone`, `throw_fire_bomb`, etc.) & Sling/Handgonne substring match
	if (skID in ::Wuxia.Config.SkillProjectileMap)
		return ::Wuxia.Config.SkillProjectileMap[skID];
	if (wID.find("sling") != null || skID.find("sling") != null)
		return "feihuangshi";
	if (wID.find("handgonne") != null || skID.find("handgonne") != null)
		return "huochongdan";

	// 6. Fallback for any remaining vanilla `ProjectileType` (e.g. procedural named bows/axes/javelins/slings)
	if (::Wuxia.Projectiles.hasMember(_skill.m, "ProjectileType"))
	{
		local pt = _skill.m.ProjectileType;
		local vt = ::Wuxia.Projectiles.VanillaTypes;
		if (("Stone" in vt && pt == vt.Stone) || ("Rock" in vt && pt == vt.Rock))
			return "feihuangshi";
		if ("Javelin" in vt && pt == vt.Javelin) return "liuyefeidao";
		if ("Axe" in vt && pt == vt.Axe)         return "xuanfengbiao";
		if ("Bola" in vt && pt == vt.Bola)       return "feishisuo";
		if ("Arrow" in vt && pt == vt.Arrow)
		{
			if (skID.find("bolt") != null) return "shenjishi";
			return "diaolingjian";
		}
		if (("Bomb1" in vt && pt == vt.Bomb1) || ("Bomb2" in vt && pt == vt.Bomb2))
			return "pilileihuo";
	}

	return null;
};

::Wuxia.Projectiles.applyToSkill <- function( _skill, _user = null )
{
	local pid = ::Wuxia.Projectiles.resolveProjectileID(_skill, _user);
	if (pid == null || !(pid in ::Wuxia.Projectiles.TypeByID)) return false;

	local def = ::Wuxia.Config.Projectiles[pid];
	_skill.m.ProjectileType = ::Wuxia.Projectiles.TypeByID[pid];
	_skill.m.IsProjectileRotated = def.IsRotated;
	_skill.m.ProjectileTimeScale = def.TimeScale;
	return true;
};

::Wuxia.Projectiles.getVfxVolleySpec <- function( _skill, _user, _fallbackBrush )
{
	local pid = ::Wuxia.Projectiles.resolveProjectileID(_skill, _user);
	if (pid != null && (pid in ::Wuxia.Config.Projectiles))
	{
		local def = ::Wuxia.Config.Projectiles[pid];
		return { Brush = def.Brush, IsRotated = def.IsRotated };
	}
	return { Brush = _fallbackBrush, IsRotated = true };
};

::Wuxia.Projectiles.spawnHandgonneVolley <- function( _skill, _user, _targetTile )
{
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
	if (!("spawnProjectileEffect" in ::Tactical)) return;
	if (_user == null || !_user.isPlacedOnMap() || _targetTile == null) return;

	local originTile = _user.getTile();
	if (originTile == null || originTile.ID == _targetTile.ID) return;

	try
	{
		local brush = ::Wuxia.Config.Projectiles.huochongdan.Brush;
		if (originTile.IsVisibleForPlayer || _targetTile.IsVisibleForPlayer)
		{
			::Tactical.spawnProjectileEffect(brush, originTile, _targetTile, 1.65, 0.95, true, false);
		}
		if (_skill != null && (::Wuxia.hasMember(_skill, "getAffectedTiles")))
		{
			local tiles = _skill.getAffectedTiles(_targetTile);
			local extra = 0;
			if (typeof tiles == "array")
			{
				foreach (t in tiles)
				{
					if (t == null || t.ID == _targetTile.ID || t.ID == originTile.ID) continue;
					if (!t.IsOccupiedByActor && extra >= 1) continue;
					if (originTile.IsVisibleForPlayer || t.IsVisibleForPlayer)
						::Tactical.spawnProjectileEffect(brush, originTile, t, 1.50 + extra * 0.15, 0.85, true, false);
					extra += 1;
					if (extra >= 3) break;
				}
			}
		}
	}
	catch (_err) {}
};

// Register all 16 Wuxia projectile constants & sprite slots immediately on load
::Wuxia.Projectiles.registerAll();

// Non-destructive hook on base `skill` so both `onUse` (slings/bombs) and `attackEntity` (bows/crossbows/throwing) use Wuxia projectiles!
::Wuxia.HooksMod.hook("scripts/skills/skill", function( q )
{
	q.onUse = @(__original) function( _user, _targetTile )
	{
		if (this.m.IsRanged || this.m.IsShowingProjectile || (this.m.ID in ::Wuxia.Config.SkillProjectileMap))
			::Wuxia.Projectiles.applyToSkill(this, _user);
		return __original(_user, _targetTile);
	};

	q.attackEntity = @(__original) function( _user, _targetEntity, _allowDiversion = true )
	{
		if (this.m.IsRanged || this.m.IsShowingProjectile)
			::Wuxia.Projectiles.applyToSkill(this, _user);
		return __original(_user, _targetEntity, _allowDiversion);
	};
});

// Dedicated non-destructive hook on Shenji Handgonne (`fire_handgonne_skill`) to launch blazing lead-shot trajectories!
try
{
	::Wuxia.HooksMod.hook("scripts/skills/actives/fire_handgonne_skill", function( q )
	{
		q.onUse = @(__original) function( _user, _targetTile )
		{
			::Wuxia.Projectiles.spawnHandgonneVolley(this, _user, _targetTile);
			return __original(_user, _targetTile);
		};
	});
}
catch (_e) {}
