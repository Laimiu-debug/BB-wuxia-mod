// 1000-Faces Modular Wuxia Character & Enemy Appearance System (`wx_busts_0.brush` + `wx_beasts_0.brush`)
// Renders 8-layer registered `104x142` (`ox=0, oy=35`) paperdoll busts:
//   1. `body`               -> `wx_body_*` / `wx_char_*` (robes, light/medium/heavy armors)
//   2. `surcoat`            -> `wx_back_01..16` (armor upgrade cloak/pelt OR personal back sword-box/gourd/banner)
//   3. `armor_upgrade_back` -> `wx_hat_*_back` / `wx_helm_*_back` (boolean-split rear brim/hood strictly behind `head`!)
//   4. `head`               -> `wx_head_01..48` (`01..32` male + `33..48` female heroines)
//   5. `tattoo_head`        -> `wx_scar_01..12` (scars, eyepatches, spectacles, cinnabar marks & permanent injuries)
//   6. `beard`              -> `wx_beard_01..24` + multi-tone (`""`, `"_brown"`, `"_grey"`, `"_white"`)
//   7. `hair`               -> `wx_hair_01..24` vs `wx_hair_01..24_tucked` + multi-tone
//   8. `helmet`             -> `wx_hat_*_front` / `wx_helm_*_front` (boolean-split front crown/brim)

local _appCfg = ::Wuxia.Config.Appearance;

::Wuxia.Appearance <- {
	FaceLabels      = _appCfg.FaceLabels,
	HairLabels      = _appCfg.HairLabels,
	HairTones       = _appCfg.HairTones,
	BeardLabels     = _appCfg.BeardLabels,
	ScarLabels      = _appCfg.ScarLabels,
	BackLabels      = _appCfg.BackLabels,
	OpenCrownHats   = _appCfg.OpenCrownHats,
	HideHairHats    = _appCfg.HideHairHats,
	HideBeardHats   = _appCfg.HideBeardHats,
	EntityTypeNames = null
};

::Wuxia.Appearance.pad2 <- function( _n )
{
	return _n < 10 ? ("0" + _n) : ("" + _n);
};

::Wuxia.Appearance.hasMember <- function( _obj, _k )
{
	if (_obj == null) return false;
	if (_k in _obj) return true;
	try { local _ = _obj[_k]; return true; } catch (_e) { return false; }
};

::Wuxia.Appearance.brushExists <- function( _brushName )
{
	if (_brushName == null || _brushName == "") return false;
	if ("doesBrushExist" in getroottable())
		return ::doesBrushExist(_brushName);
	return true;
};

::Wuxia.Appearance.resolveEntityTypeKey <- function( _actor )
{
	if (_actor == null || !::Wuxia.Appearance.hasMember(_actor, "m") || !::Wuxia.Appearance.hasMember(_actor.m, "Type")) return "";
	if (::Wuxia.Appearance.EntityTypeNames == null && ("Const" in getroottable()) && ("EntityType" in ::Const))
	{
		::Wuxia.Appearance.EntityTypeNames = {};
		foreach (k, v in ::Const.EntityType)
		{
			if (typeof v == "integer")
				::Wuxia.Appearance.EntityTypeNames[v] <- k;
		}
	}
	if (::Wuxia.Appearance.EntityTypeNames != null && (_actor.m.Type in ::Wuxia.Appearance.EntityTypeNames))
		return ::Wuxia.Appearance.EntityTypeNames[_actor.m.Type];
	return "";
};

::Wuxia.Appearance.computeActorSeed <- function( _actor )
{
	local h = ::Wuxia.Appearance.hasMember(_actor, "getID") ? (_actor.getID() * 1103515245 + 12345) : ::Math.rand(1, 999999);
	if (::Wuxia.Appearance.hasMember(_actor, "getNameOnly"))
	{
		local nm = _actor.getNameOnly();
		if (nm != null)
		{
			for (local i = 0; i < nm.len(); i = ++i)
				h = (h * 33 + nm[i]) & 0x3FFFFFFF;
		}
	}
	if (h < 0) h = -h;
	return h & 0x3FFFFFFF;
};

::Wuxia.Appearance.seedFromPreset <- function( _preset, _seed )
{
	local faces  = ("Faces" in _preset && _preset.Faces.len() > 0) ? _preset.Faces : [1];
	local hairs  = ("Hairs" in _preset && _preset.Hairs.len() > 0) ? _preset.Hairs : [1];
	local tones  = ("Tones" in _preset && _preset.Tones.len() > 0) ? _preset.Tones : [0];
	local beards = ("Beards" in _preset && _preset.Beards.len() > 0) ? _preset.Beards : [0];
	local scars  = ("Scars" in _preset && _preset.Scars.len() > 0) ? _preset.Scars : [0];
	local backs  = ("Backs" in _preset && _preset.Backs.len() > 0) ? _preset.Backs : [0];

	local faceIdx = faces[_seed % faces.len()];
	local isFem   = (faceIdx >= 33);
	local hairIdx = hairs[(_seed / 7) % hairs.len()];
	if (isFem && hairIdx == 0 && faceIdx != 40)
		hairIdx = 9 + ((_seed / 13) % 4); // Non-nun heroines keep hair
	local toneIdx  = tones[(_seed / 19) % tones.len()];
	local beardIdx = isFem ? 0 : beards[(_seed / 31) % beards.len()];
	local scarIdx  = scars[(_seed / 67) % scars.len()];
	local backIdx  = 0; // Jianghu back ornaments disabled on character busts

	return {
		FaceIdx     = faceIdx,
		HairIdx     = hairIdx,
		HairToneIdx = toneIdx,
		BeardIdx    = beardIdx,
		ScarIdx     = scarIdx,
		BackIdx     = backIdx
	};
};

::Wuxia.Appearance.seedValuesFromActor <- function( _actor )
{
	local seed = ::Wuxia.Appearance.computeActorSeed(_actor);
	local cfg  = ::Wuxia.Config.Appearance;

	local bgID = "";
	if (::Wuxia.Appearance.hasMember(_actor, "getBackground") && _actor.getBackground() != null)
		bgID = _actor.getBackground().getID();

	if (bgID != "" && (bgID in cfg.BackgroundPresets))
		return ::Wuxia.Appearance.seedFromPreset(cfg.BackgroundPresets[bgID], seed);

	local entityKey = ::Wuxia.Appearance.resolveEntityTypeKey(_actor);
	if (entityKey != "" && (entityKey in cfg.HumanEntityPresets))
		return ::Wuxia.Appearance.seedFromPreset(cfg.HumanEntityPresets[entityKey], seed);

	local faceIdx = 1;
	local hairIdx = 1;
	local toneIdx = 0;
	local beardIdx = 0;
	local scarIdx = 0;
	local backIdx = 0;

	local noFemBg = (bgID == "background.brawler" || bgID == "background.butcher" || bgID == "background.blacksmith"
		|| bgID == "background.lumberjack" || bgID == "background.miner" || bgID == "background.mason" || bgID == "background.eunuch");

	if (!noFemBg && (seed % 7 == 6))
	{
		local femHairs = [1, 9, 10, 11, 12, 17, 20, 23];
		faceIdx  = 33 + (seed % 16);
		hairIdx  = femHairs[(seed / 13) % femHairs.len()];
		toneIdx  = (faceIdx == 40) ? 2 : ((faceIdx == 47) ? 1 : 0);
		beardIdx = 0;
		scarIdx  = ((seed / 83) % 6 == 0) ? 8 : 0;
		backIdx  = 0;
	}
	else
	{
		faceIdx = 1 + (seed % 32);
		hairIdx = 1 + ((seed / 37) % 24);
		if (faceIdx == 4 || faceIdx == 8 || faceIdx == 9 || faceIdx == 16)
			toneIdx = ((seed / 43) % 2 == 0) ? 2 : 3;
		else if ((seed / 43) % 4 == 0)
			toneIdx = 1;

		local youngClean = (faceIdx == 1 || faceIdx == 5 || faceIdx == 17 || faceIdx == 22 || faceIdx == 24);
		if (youngClean && ((seed / 53) % 3 != 0))
			beardIdx = 0;
		else if ((seed / 53) % 5 == 0)
			beardIdx = 0;
		else
			beardIdx = 1 + ((seed / 61) % 24);

		if ((seed / 89) % 3 == 0)
			scarIdx = 1 + ((seed / 101) % 12);

		backIdx = 0;
	}

	return {
		FaceIdx     = faceIdx,
		HairIdx     = hairIdx,
		HairToneIdx = toneIdx,
		BeardIdx    = beardIdx,
		ScarIdx     = scarIdx,
		BackIdx     = backIdx
	};
};

::Wuxia.Appearance.getOrInitState <- function( _actor )
{
	if (_actor == null) return null;
	local skills = ::Wuxia.Appearance.hasMember(_actor, "getSkills") ? _actor.getSkills() : null;
	local c = (skills != null) ? skills.getSkillByID("special.wx_martial_container") : null;
	if (c != null)
	{
		if (!(::Wuxia.hasMember(c.m, "HairToneIdx"))) c.m.HairToneIdx <- -1;
		if (!(::Wuxia.hasMember(c.m, "BackIdx")))     c.m.BackIdx <- -1;

		if (c.m.FaceIdx <= 0 || c.m.FaceIdx > 48 || c.m.HairIdx < 0 || c.m.HairToneIdx < 0 || c.m.BeardIdx < 0 || c.m.ScarIdx < 0 || c.m.BackIdx < 0)
		{
			local seeded = ::Wuxia.Appearance.seedValuesFromActor(_actor);
			if (c.m.FaceIdx <= 0 || c.m.FaceIdx > 48)    c.m.FaceIdx     = seeded.FaceIdx;
			if (c.m.HairIdx < 0 || c.m.HairIdx > 24)     c.m.HairIdx     = seeded.HairIdx;
			if (c.m.HairToneIdx < 0 || c.m.HairToneIdx > 3) c.m.HairToneIdx = seeded.HairToneIdx;
			if (c.m.BeardIdx < 0 || c.m.BeardIdx > 24)   c.m.BeardIdx    = (c.m.FaceIdx >= 33) ? 0 : seeded.BeardIdx;
			if (c.m.ScarIdx < 0 || c.m.ScarIdx > 12)     c.m.ScarIdx     = seeded.ScarIdx;
			if (c.m.BackIdx < 0 || c.m.BackIdx > 16)     c.m.BackIdx     = seeded.BackIdx;
		}
		if (c.m.FaceIdx >= 33 && c.m.BeardIdx > 0)
			c.m.BeardIdx = 0;
		return c.m;
	}

	if (!::Wuxia.Appearance.hasMember(_actor, "m")) return null;
	if (!("WX_TempAppearance" in _actor.m) || _actor.m.WX_TempAppearance == null)
	{
		_actor.m.WX_TempAppearance <- ::Wuxia.Appearance.seedValuesFromActor(_actor);
	}
	return _actor.m.WX_TempAppearance;
};

// Synchronize newly generated female Jianghu heroine recruit names (`FaceIdx >= 33`) on first hire/spawn
::Wuxia.Appearance.syncHeroineNameIfNeeded <- function( _actor )
{
	if (_actor == null || !::Wuxia.Appearance.hasMember(_actor, "m")) return;
	if ("WX_HeroineNameChecked" in _actor.m && _actor.m.WX_HeroineNameChecked) return;
	_actor.m.WX_HeroineNameChecked <- true;

	local st = ::Wuxia.Appearance.getOrInitState(_actor);
	if (st == null || st.FaceIdx < 33) return;

	local bgID = (::Wuxia.Appearance.hasMember(_actor, "getBackground") && _actor.getBackground() != null)
		? _actor.getBackground().getID()
		: "";
	if (bgID == "background.belly_dancer") return; // Already uses curated `dancer` female names

	local pool = ::Wuxia.Config.Appearance.FemaleHeroineNames;
	if (pool.len() > 0 && ::Wuxia.Appearance.hasMember(_actor, "setName"))
	{
		local pick = pool[::Math.rand(0, pool.len() - 1)];
		_actor.setName(pick);
	}
};

::Wuxia.Appearance.resolveEffectiveScarIdx <- function( _actor, _st )
{
	if (_st != null && _st.ScarIdx > 0 && _st.ScarIdx <= 12)
		return _st.ScarIdx;
	if (_actor != null && ::Wuxia.Appearance.hasMember(_actor, "getSkills"))
	{
		local skills = _actor.getSkills();
		if (skills != null && ::Wuxia.Appearance.hasMember(skills, "hasSkill"))
		{
			foreach (pair in ::Wuxia.Config.Appearance.PermanentInjuryScarMap)
			{
				if (skills.hasSkill(pair[0]))
					return pair[1];
			}
		}
	}
	return 0;
};

::Wuxia.Appearance.resolveUnarmoredBodyBrush <- function( _actor )
{
	if (_actor != null)
	{
		local cfg = ::Wuxia.Config.Appearance;
		if (::Wuxia.Appearance.hasMember(_actor, "getBackground") && _actor.getBackground() != null)
		{
			local bgID = _actor.getBackground().getID();
			if ((bgID in cfg.BackgroundPresets) && ("UnarmoredBody" in cfg.BackgroundPresets[bgID]))
				return cfg.BackgroundPresets[bgID].UnarmoredBody;
		}
		local eKey = ::Wuxia.Appearance.resolveEntityTypeKey(_actor);
		if (eKey != "" && (eKey in cfg.HumanEntityPresets) && ("UnarmoredBody" in cfg.HumanEntityPresets[eKey]))
			return cfg.HumanEntityPresets[eKey].UnarmoredBody;
	}
	return "wx_char_cloth_short";
};

::Wuxia.Appearance.resolveEquippedUpgradeBack <- function( _actor )
{
	if (_actor == null || !::Wuxia.Appearance.hasMember(_actor, "getItems")) return null;
	local items = _actor.getItems();
	if (items == null) return null;
	local bodyItem = items.getItemAtSlot(::Const.ItemSlot.Body);
	if (bodyItem == null || !::Wuxia.Appearance.hasMember(bodyItem, "m")) return null;
	local bodyCond = ::Wuxia.Appearance.hasMember(bodyItem, "getCondition") ? bodyItem.getCondition() : (::Wuxia.Appearance.hasMember(bodyItem.m, "Condition") ? bodyItem.m.Condition : 0);
	if (bodyCond <= 0) return null;

	local upg = ::Wuxia.Appearance.hasMember(bodyItem.m, "Upgrade") ? bodyItem.m.Upgrade : null;
	if (upg != null && ("Armory" in ::Wuxia) && ("ensureUpgradeMapped" in ::Wuxia.Armory))
	{
		::Wuxia.Armory.ensureUpgradeMapped(upg);
		if (::Wuxia.Appearance.hasMember(upg, "m") && ("WX_BackBrush" in upg.m) && upg.m.WX_BackBrush != null)
		{
			return {
				Brush = upg.m.WX_BackBrush,
				Name  = ::Wuxia.Appearance.hasMember(upg, "getName") ? upg.getName() : (::Wuxia.Appearance.hasMember(upg.m, "Name") ? upg.m.Name : "")
			};
		}
	}
	return null;
};

::Wuxia.Appearance.getLabelsForState <- function( _st, _actor = null )
{
	local tones = ::Wuxia.Appearance.HairTones;
	if (_st == null)
	{
		return {
			faceIdx          = 1,
			faceLabel        = ::Wuxia.Appearance.FaceLabels[1],
			isFemale         = false,
			hairIdx          = 1,
			hairLabel        = ::Wuxia.Appearance.HairLabels[1],
			toneIdx          = 0,
			toneLabel        = tones[0].Name,
			beardIdx         = 0,
			beardLabel       = ::Wuxia.Appearance.BeardLabels[0],
			scarIdx          = 0,
			scarLabel        = ::Wuxia.Appearance.ScarLabels[0],
			backIdx          = 0,
			backLabel        = ::Wuxia.Appearance.BackLabels[0],
			upgradeBackLabel = ""
		};
	}
	local fi  = ::Math.max(1, ::Math.min(48, _st.FaceIdx));
	local hi  = ::Math.max(0, ::Math.min(24, _st.HairIdx));
	local ti  = ("HairToneIdx" in _st && _st.HairToneIdx >= 0) ? ::Math.max(0, ::Math.min(3, _st.HairToneIdx)) : 0;
	local bi  = (fi >= 33) ? 0 : ::Math.max(0, ::Math.min(24, _st.BeardIdx));
	local si  = ::Math.max(0, ::Math.min(12, _st.ScarIdx));
	local bki = ("BackIdx" in _st && _st.BackIdx >= 0) ? ::Math.max(0, ::Math.min(16, _st.BackIdx)) : 0;
	local upg = ::Wuxia.Appearance.resolveEquippedUpgradeBack(_actor);

	return {
		faceIdx          = fi,
		faceLabel        = ::Wuxia.Appearance.FaceLabels[fi],
		isFemale         = (fi >= 33),
		hairIdx          = hi,
		hairLabel        = ::Wuxia.Appearance.HairLabels[hi],
		toneIdx          = ti,
		toneLabel        = tones[ti].Name,
		beardIdx         = bi,
		beardLabel       = (fi >= 33) ? "女侠净面" : ::Wuxia.Appearance.BeardLabels[bi],
		scarIdx          = si,
		scarLabel        = ::Wuxia.Appearance.ScarLabels[si],
		backIdx          = bki,
		backLabel        = ::Wuxia.Appearance.BackLabels[bki],
		upgradeBackLabel = (upg != null ? upg.Name : "")
	};
};

::Wuxia.Appearance.saveOriginalVanillaBrushes <- function( _actor )
{
	if (_actor == null || !::Wuxia.Appearance.hasMember(_actor, "m") || !::Wuxia.Appearance.hasMember(_actor, "hasSprite")) return;
	if (!("WX_OrigBodyBrush" in _actor.m) && _actor.hasSprite("body"))
	{
		local sb = _actor.getSprite("body");
		if (sb != null && sb.HasBrush)
		{
			local bn = sb.getBrush().Name;
			if (bn.find("wx_") == null)
				_actor.m.WX_OrigBodyBrush <- bn;
		}
	}
	if (!("WX_OrigHeadBrush" in _actor.m) && _actor.hasSprite("head"))
	{
		local sh = _actor.getSprite("head");
		if (sh != null && sh.HasBrush)
		{
			local hn = sh.getBrush().Name;
			if (hn.find("wx_") == null)
				_actor.m.WX_OrigHeadBrush <- hn;
		}
	}
};

// Capture active `wx_*` visual layers before `onDeath` so fallen tactical corpses render authentic Wuxia robes, faces, hair & hats!
::Wuxia.Appearance.captureDeathLayers <- function( _actor )
{
	if (_actor == null || !::Wuxia.Appearance.hasMember(_actor, "hasSprite")) return null;
	local snap = {
		isFlipped    = false,
		isSingleBust = false,
		bodyDead     = null,
		backDead     = null,
		hatBackDead  = null,
		headDead     = null,
		scarDead     = null,
		beardDead    = null,
		hairDead     = null,
		hatFrontDead = null
	};

	local getDeadBrush = function( _sprName )
	{
		if (!_actor.hasSprite(_sprName)) return null;
		local sp = _actor.getSprite(_sprName);
		if (sp == null || !sp.Visible || !sp.HasBrush) return null;
		local bn = sp.getBrush().Name;
		if (bn == null || bn.find("wx_") != 0) return null;
		local cand = bn + "_dead";
		return ::Wuxia.Appearance.brushExists(cand) ? cand : null;
	};

	if (_actor.hasSprite("body"))
	{
		local sb = _actor.getSprite("body");
		if (sb != null)
		{
			snap.isFlipped = sb.isFlippedHorizontally();
			if (sb.HasBrush)
			{
				local bn = sb.getBrush().Name;
				if (bn.find("wx_enemy_") == 0 || bn.find("wx_char_enemy_") == 0 || bn.find("wx_beast_") == 0 || bn.find("wx_boss_") == 0)
					snap.isSingleBust = true;
			}
		}
	}

	snap.bodyDead = getDeadBrush("body");
	if (snap.bodyDead == null) return null;

	if (!snap.isSingleBust)
	{
		snap.backDead     = null;
		snap.hatBackDead  = getDeadBrush("armor_upgrade_back");
		snap.headDead     = getDeadBrush("head");
		snap.scarDead     = getDeadBrush("tattoo_head");
		snap.beardDead    = getDeadBrush("beard");
		snap.hairDead     = getDeadBrush("hair");
		snap.hatFrontDead = getDeadBrush("helmet");
	}
	return snap;
};

// Replace spawned vanilla European corpse decals on `_tile` with our registered `wx_*_dead` fallen Wuxia decals!
::Wuxia.Appearance.applyWuxiaCorpseDecals <- function( _actor, _tile, _fatalityType, _snap )
{
	if (_snap == null || _snap.bodyDead == null) return;
	local tile = _tile;
	if (tile == null && _actor != null && ::Wuxia.Appearance.hasMember(_actor, "m") && (::Wuxia.hasMember(_actor.m, "CorpseTile")))
		tile = _actor.m.CorpseTile;
	if (tile == null) return;

	local corpseFlag = ::Const.Tactical.DetailFlag.Corpse;
	local corpseOffset = ("Combat" in ::Const && "HumanCorpseOffset" in ::Const.Combat) ? ::Const.Combat.HumanCorpseOffset : 0;
	local flip = _snap.isFlipped;

	// Clear vanilla European body/armor/head/hair/helmet corpse decals while leaving blood pools (`Effects` / `0`) intact!
	tile.clear(corpseFlag);

	local spawnDead = function( _targetTile, _brushName )
	{
		if (_targetTile == null || _brushName == null) return;
		local d = _targetTile.spawnDetail(_brushName, corpseFlag, flip, false, corpseOffset);
		if (d != null)
		{
			d.Scale = 0.92;
		}
	};

	spawnDead(tile, _snap.bodyDead);
	if (_snap.isSingleBust)
		return;

	spawnDead(tile, _snap.backDead);

	local isSmashed = ("FatalityType" in ::Const) && (_fatalityType == ::Const.FatalityType.Smashed);
	local isDecap   = ("FatalityType" in ::Const) && (_fatalityType == ::Const.FatalityType.Decapitated);

	if (isSmashed)
		return;

	local headTile = tile;
	if (isDecap)
	{
		// If vanilla spawned a decapitated European head on an adjacent tile, clear its `Corpse` detail and place our Wuxia head there!
		for (local i = 0; i < 6; i = ++i)
		{
			if (tile.hasNextTile(i))
			{
				local nt = tile.getNextTile(i);
				if (nt != null && nt.IsEmpty && !nt.Properties.has("Corpse"))
				{
					nt.clear(corpseFlag);
					headTile = nt;
					break;
				}
			}
		}
	}

	spawnDead(headTile, _snap.hatBackDead);
	spawnDead(headTile, _snap.headDead);
	spawnDead(headTile, _snap.scarDead);
	spawnDead(headTile, _snap.beardDead);
	spawnDead(headTile, _snap.hairDead);
	spawnDead(headTile, _snap.hatFrontDead);
};

// Safely swap any `wx_*` brushes back to valid vanilla `*_dead`-compatible brushes right before `onDeath`!
::Wuxia.Appearance.restoreVanillaBrushesForDeath <- function( _actor )
{
	if (_actor == null || !::Wuxia.Appearance.hasMember(_actor, "hasSprite")) return;

	if (_actor.hasSprite("body"))
	{
		local sb = _actor.getSprite("body");
		if (sb != null && sb.HasBrush && sb.getBrush().Name.find("wx_") == 0)
		{
			local origB = (::Wuxia.Appearance.hasMember(_actor, "m") && "WX_OrigBodyBrush" in _actor.m && _actor.m.WX_OrigBodyBrush != null && _actor.m.WX_OrigBodyBrush.find("wx_") == null)
				? _actor.m.WX_OrigBodyBrush
				: "bust_naked_body_01";
			if (::Wuxia.Appearance.brushExists(origB))
				sb.setBrush(origB);
		}
	}

	if (_actor.hasSprite("head"))
	{
		local sh = _actor.getSprite("head");
		if (sh != null && sh.HasBrush && sh.getBrush().Name.find("wx_") == 0)
		{
			local origH = (::Wuxia.Appearance.hasMember(_actor, "m") && "WX_OrigHeadBrush" in _actor.m && _actor.m.WX_OrigHeadBrush != null && _actor.m.WX_OrigHeadBrush.find("wx_") == null)
				? _actor.m.WX_OrigHeadBrush
				: "bust_head_01";
			if (::Wuxia.Appearance.brushExists(origH))
				sh.setBrush(origH);
		}
	}

	foreach (sub in ["hair", "beard", "beard_top", "tattoo_head", "tattoo_body", "surcoat", "armor_upgrade_back", "armor_upgrade_front", "helmet", "helmet_damage"])
	{
		if (_actor.hasSprite(sub))
		{
			local sp = _actor.getSprite(sub);
			if (sp != null && sp.HasBrush && sp.getBrush().Name.find("wx_") == 0)
			{
				sp.resetBrush();
				sp.Visible = false;
			}
		}
	}
};

::Wuxia.Appearance.isEligibleHumanActor <- function( _actor )
{
	if (_actor == null || !::Wuxia.Appearance.hasMember(_actor, "hasSprite")) return false;
	if (::Wuxia.Appearance.hasMember(_actor, "isAlive") && !_actor.isAlive()) return false;
	if (::Wuxia.Appearance.hasMember(_actor, "m"))
	{
		if ("WX_CustomEnemyBust" in _actor.m && _actor.m.WX_CustomEnemyBust != null) return false;
		if ("WX_BossID" in _actor.m && _actor.m.WX_BossID != null) return false;
	}
	if (::Wuxia.CombatRules.isUndeadOrConstruct(_actor)) return false;
	if (!_actor.hasSprite("head") || !_actor.hasSprite("body") || !_actor.hasSprite("hair")) return false;

	local headSpr = _actor.getSprite("head");
	if (headSpr != null && headSpr.HasBrush)
	{
		local bName = headSpr.getBrush().Name;
		if (bName.find("orc") != null || bName.find("goblin") != null || bName.find("skeleton") != null || bName.find("zombie") != null || bName.find("vampire") != null || bName.find("ghoul") != null)
			return false;
	}
	return true;
};

::Wuxia.Appearance.refreshActorSprites <- function( _actor )
{
	if (!::Wuxia.Appearance.isEligibleHumanActor(_actor)) return;

	local st = ::Wuxia.Appearance.getOrInitState(_actor);
	if (st == null) return;

	::Wuxia.Appearance.saveOriginalVanillaBrushes(_actor);

	local white = ::createColor("#ffffff");
	local items = ::Wuxia.Appearance.hasMember(_actor, "getItems") ? _actor.getItems() : null;
	local bodyItem = (items != null) ? items.getItemAtSlot(::Const.ItemSlot.Body) : null;
	local headItem = (items != null) ? items.getItemAtSlot(::Const.ItemSlot.Head) : null;

	local bodyCond = (bodyItem != null) ? ((::Wuxia.hasMember(bodyItem, "getCondition")) ? bodyItem.getCondition() : bodyItem.m.Condition) : 0;
	local hasWuxiaBody = (bodyItem != null && ("WX_BodyBrush" in bodyItem.m) && bodyItem.m.WX_BodyBrush != null && bodyCond > 0);
	local bodyBrush = hasWuxiaBody ? bodyItem.m.WX_BodyBrush : ::Wuxia.Appearance.resolveUnarmoredBodyBrush(_actor);

	local headCond = (headItem != null) ? ((::Wuxia.hasMember(headItem, "getCondition")) ? headItem.getCondition() : headItem.m.Condition) : 0;
	local hasWuxiaHat = (headItem != null && ("WX_HatFrontBrush" in headItem.m) && headItem.m.WX_HatFrontBrush != null && headCond > 0);
	local hatID = hasWuxiaHat && ("WX_HatID" in headItem.m) ? headItem.m.WX_HatID : null;
	local hatBackBrush = hasWuxiaHat
		? (("WX_HatBackBrush" in headItem.m && headItem.m.WX_HatBackBrush != null) ? headItem.m.WX_HatBackBrush : (hatID != null ? (hatID + "_back") : null))
		: null;

	local ti = ("HairToneIdx" in st && st.HairToneIdx >= 0) ? ::Math.max(0, ::Math.min(3, st.HairToneIdx)) : 0;
	local toneSuffix = ::Wuxia.Appearance.HairTones[ti].Suffix;

	// 1. Registered Wuxia Torso / Robe / Armor (`104x142`, `oy=35` on `body`)
	local sprBody = _actor.getSprite("body");
	if (bodyItem == null || bodyCond <= 0 || hasWuxiaBody)
	{
		sprBody.setBrush(bodyBrush);
		sprBody.Color = white;
		sprBody.Visible = true;
		if (_actor.hasSprite("armor")) _actor.getSprite("armor").Visible = false;
		if (_actor.hasSprite("armor_upgrade_front")) _actor.getSprite("armor_upgrade_front").Visible = false;
	}
	if (_actor.hasSprite("injury_body")) _actor.getSprite("injury_body").Visible = false;
	if (_actor.hasSprite("dirt")) _actor.getSprite("dirt").Visible = false;

	// 2. Jianghu back ornaments (`wx_back_01..16`) suppressed on character busts so floating gourds/boxes/banners do not obscure sprites
	local upgBack = ::Wuxia.Appearance.resolveEquippedUpgradeBack(_actor);
	if (_actor.hasSprite("surcoat"))
		_actor.getSprite("surcoat").Visible = false;
	if (_actor.hasSprite("tattoo_body"))
		_actor.getSprite("tattoo_body").Visible = false;

	// 3. Boolean-Split Rear Hat Brim / Hood / Neck-Guard (`wx_hat_*_back` on `armor_upgrade_back`, `z > surcoat` & strictly `z < head`!)
	if (_actor.hasSprite("armor_upgrade_back"))
	{
		local sprHatBack = _actor.getSprite("armor_upgrade_back");
		if (hatBackBrush != null && ::Wuxia.Appearance.brushExists(hatBackBrush))
		{
			sprHatBack.setBrush(hatBackBrush);
			sprHatBack.Color = white;
			sprHatBack.Visible = true;
		}
		else if (bodyItem == null || bodyCond <= 0 || hasWuxiaBody || upgBack != null)
		{
			sprHatBack.Visible = false;
		}
	}

	// 4. Registered Wuxia Head (`wx_head_01..48`) & suppress misaligned vanilla European facial injury overlays
	local fi = ::Math.max(1, ::Math.min(48, st.FaceIdx));
	local sprHead = _actor.getSprite("head");
	sprHead.setBrush("wx_head_" + ::Wuxia.Appearance.pad2(fi));
	sprHead.Color = white;
	sprHead.Visible = true;
	foreach (vInj in ["injury", "permanent_injury_1", "permanent_injury_2", "permanent_injury_3", "permanent_injury_4"])
	{
		if (_actor.hasSprite(vInj)) _actor.getSprite(vInj).Visible = false;
	}

	// 5. Scar / Facial Mark / Permanent Injury Eyepatch (`wx_scar_01..12` on `tattoo_head`)
	local effScar = ::Wuxia.Appearance.resolveEffectiveScarIdx(_actor, st);
	if (_actor.hasSprite("tattoo_head"))
	{
		local sprScar = _actor.getSprite("tattoo_head");
		if (effScar > 0 && effScar <= 12)
		{
			sprScar.setBrush("wx_scar_" + ::Wuxia.Appearance.pad2(effScar));
			sprScar.Color = white;
			sprScar.Visible = true;
		}
		else
		{
			sprScar.Visible = false;
		}
	}

	// 6. Landmark-Fitted Beard + Multi-Tone (`wx_beard_01..24` on `beard`, hiding vanilla `beard_top`)
	if (_actor.hasSprite("beard_top")) _actor.getSprite("beard_top").Visible = false;
	if (_actor.hasSprite("beard"))
	{
		local sprBeard = _actor.getSprite("beard");
		local hideBeard = (fi >= 33) || (st.BeardIdx <= 0 || st.BeardIdx > 24) || (hatID != null && (hatID in ::Wuxia.Appearance.HideBeardHats));
		if (!hideBeard)
		{
			local bBrush = "wx_beard_" + ::Wuxia.Appearance.pad2(st.BeardIdx) + toneSuffix;
			if (!::Wuxia.Appearance.brushExists(bBrush))
				bBrush = "wx_beard_" + ::Wuxia.Appearance.pad2(st.BeardIdx);
			sprBeard.setBrush(bBrush);
			sprBeard.Color = white;
			sprBeard.Visible = true;
		}
		else
		{
			sprBeard.Visible = false;
		}
	}

	// 7. Boolean-Interlocked Hair + Multi-Tone (`wx_hair_01..24` vs `wx_hair_01_tucked..24_tucked` + toneSuffix)
	if (_actor.hasSprite("hair"))
	{
		local sprHair = _actor.getSprite("hair");
		local hideHair = (st.HairIdx <= 0 || st.HairIdx > 24) || (hatID != null && (hatID in ::Wuxia.Appearance.HideHairHats));
		if (!hideHair)
		{
			local useTucked = (hatID != null && !(hatID in ::Wuxia.Appearance.OpenCrownHats));
			local baseHair = "wx_hair_" + ::Wuxia.Appearance.pad2(st.HairIdx) + (useTucked ? "_tucked" : "");
			local hBrush = baseHair + toneSuffix;
			if (!::Wuxia.Appearance.brushExists(hBrush))
				hBrush = baseHair;
			sprHair.setBrush(hBrush);
			sprHair.Color = white;
			sprHair.Visible = true;
		}
		else
		{
			sprHair.Visible = false;
		}
	}

	// 8. Boolean-Split Wuxia Hat / Helmet Front (`wx_hat_01..32_front` / `wx_char_hat_*_front` / `wx_helm_*_front`)
	if (_actor.hasSprite("helmet"))
	{
		if (hasWuxiaHat)
		{
			local sprHelm = _actor.getSprite("helmet");
			sprHelm.setBrush(headItem.m.WX_HatFrontBrush);
			sprHelm.Color = white;
			sprHelm.Visible = true;
			if (_actor.hasSprite("helmet_damage")) _actor.getSprite("helmet_damage").Visible = false;
		}
		else if (headItem == null || headCond <= 0)
		{
			_actor.getSprite("helmet").Visible = false;
			if (_actor.hasSprite("helmet_damage")) _actor.getSprite("helmet_damage").Visible = false;
		}
	}

	// Sync tactical faction facing (`flip = !_actor.isAlliedWithPlayer()`) across all 8 paperdoll layers!
	if ("Tactical" in getroottable() && ::Tactical != null && ::Tactical.isActive() && ::Wuxia.Appearance.hasMember(_actor, "isAlliedWithPlayer"))
	{
		local flip = !_actor.isAlliedWithPlayer();
		foreach (lyr in ["body", "surcoat", "tattoo_body", "armor_upgrade_back", "head", "tattoo_head", "beard", "hair", "helmet"])
		{
			if (_actor.hasSprite(lyr))
				_actor.getSprite(lyr).setHorizontalFlipping(flip);
		}
	}

	if (::Wuxia.Appearance.hasMember(_actor, "setDirty")) _actor.setDirty(true);
};

::Wuxia.Appearance.applyCustomEnemyBust <- function( _actor, _enemyBrush )
{
	if (_actor == null || _enemyBrush == null || _enemyBrush == "" || !::Wuxia.Appearance.hasMember(_actor, "hasSprite")) return;
	if (!_actor.hasSprite("body") || !::Wuxia.Appearance.brushExists(_enemyBrush)) return;

	::Wuxia.Appearance.saveOriginalVanillaBrushes(_actor);
	_actor.m.WX_CustomEnemyBust <- _enemyBrush;

	local sprBody = _actor.getSprite("body");
	sprBody.setBrush(_enemyBrush);
	sprBody.Color = ::createColor("#ffffff");
	sprBody.Visible = true;

	if ("Tactical" in getroottable() && ::Tactical != null && ::Tactical.isActive() && ::Wuxia.Appearance.hasMember(_actor, "isAlliedWithPlayer"))
	{
		sprBody.setHorizontalFlipping(!_actor.isAlliedWithPlayer());
	}

	if (_enemyBrush.find("wx_beast_") == 0 && !("WX_BossID" in _actor.m) && ("Appearance" in ::Wuxia.Config) && ("BeastBustNames" in ::Wuxia.Config.Appearance) && (_enemyBrush in ::Wuxia.Config.Appearance.BeastBustNames))
	{
		if (::Wuxia.Appearance.hasMember(_actor, "setName"))
			_actor.setName(::Wuxia.Config.Appearance.BeastBustNames[_enemyBrush]);
	}

	// Hide all vanilla composite sub-layers so our bespoke hand-painted enemy/beast bust displays cleanly
	foreach (sub in [
		"quiver", "tattoo_body", "injury_body", "armor", "surcoat", "armor_upgrade_back", "armor_upgrade_front",
		"head", "head_frenzy", "closed_eyes", "eye_rings", "tattoo_head", "injury",
		"permanent_injury_1", "permanent_injury_2", "permanent_injury_3", "permanent_injury_4",
		"beard", "beard_top", "hair", "helmet", "helmet_damage", "body_blood", "dirt",
		"arms_icon", "shield_icon", "legs_back", "legs_front", "tail", "wings", "charm_body"
	])
	{
		if (_actor.hasSprite(sub)) _actor.getSprite(sub).Visible = false;
	}
	if (::Wuxia.Appearance.hasMember(_actor, "setDirty")) _actor.setDirty(true);
};

::Wuxia.Appearance.applyShanHaiEntityStrings <- function()
{
	if (!("Const" in getroottable()) || !("EntityType" in ::Const) || !("Strings" in ::Const) || ::Const.Strings == null) return;
	if (!("Appearance" in ::Wuxia.Config) || !("ShanHaiEntityStrings" in ::Wuxia.Config.Appearance)) return;

	local map = ::Wuxia.Config.Appearance.ShanHaiEntityStrings;
	local en = ("EntityName" in ::Const.Strings) ? ::Const.Strings.EntityName : null;
	local enp = ("EntityNamePlural" in ::Const.Strings) ? ::Const.Strings.EntityNamePlural : null;
	foreach (eKey, zhLabel in map)
	{
		if (!(eKey in ::Const.EntityType)) continue;
		local idx = ::Const.EntityType[eKey];
		if (en != null && idx >= 0 && idx < en.len())
			en[idx] = zhLabel;
		if (enp != null && idx >= 0 && idx < enp.len())
			enp[idx] = zhLabel;
	}
};
::Wuxia.Appearance.applyShanHaiEntityStrings();

// Resolve bespoke `wx_enemy_*` / `wx_char_enemy_*` bust for non-player enemy/boss entities if not already set
::Wuxia.Appearance.resolveAutoEnemyBust <- function( _actor )
{
	if (_actor == null || !::Wuxia.Appearance.hasMember(_actor, "m")) return null;
	if (::Wuxia.Appearance.hasMember(_actor, "isPlayerControlled") && _actor.isPlayerControlled()) return null;
	if ("WX_BossID" in _actor.m && _actor.m.WX_BossID != null) return null;
	if ("WX_CustomEnemyBust" in _actor.m && _actor.m.WX_CustomEnemyBust != null) return _actor.m.WX_CustomEnemyBust;

	// Never override civilian/gentry contract employers (`councilman`, `noble`, `envoy`, `vizier`) with combat general busts!
	local cls = ("ClassName" in _actor && typeof _actor.ClassName == "string") ? _actor.ClassName : "";
	if (cls == "councilman" || cls == "noble" || cls == "envoy" || cls == "vizier" || cls == "first_born" || (::Wuxia.hasMember(_actor.m, "IsGuest") && _actor.m.IsGuest))
		return null;

	local eKey = ::Wuxia.Appearance.resolveEntityTypeKey(_actor);
	if (eKey != "" && (eKey in ::Wuxia.Config.Appearance.EnemyEntityBustMap))
	{
		local pool = ::Wuxia.Config.Appearance.EnemyEntityBustMap[eKey];
		if (pool.len() > 0)
		{
			local seed = ::Wuxia.Appearance.computeActorSeed(_actor);
			return pool[seed % pool.len()];
		}
	}
	return null;
};

::Wuxia.Appearance.stepAppearance <- function( _actor, _part, _dir )
{
	local st = ::Wuxia.Appearance.getOrInitState(_actor);
	if (st == null) return null;

	if (!("HairToneIdx" in st) || st.HairToneIdx < 0) st.HairToneIdx <- 0;
	if (!("BackIdx" in st) || st.BackIdx < 0)         st.BackIdx <- 0;

	local stepWrap = function( _val, _minV, _maxV, _d )
	{
		local span = _maxV - _minV + 1;
		local rel = (_val - _minV + _d) % span;
		if (rel < 0) rel += span;
		return _minV + rel;
	};

	if (_part == "face")
	{
		st.FaceIdx = stepWrap(st.FaceIdx, 1, 48, _dir);
		if (st.FaceIdx >= 33 && st.BeardIdx > 0)
			st.BeardIdx = 0;
	}
	else if (_part == "hair")
	{
		st.HairIdx = stepWrap(st.HairIdx, 0, 24, _dir);
	}
	else if (_part == "tone")
	{
		st.HairToneIdx = stepWrap(st.HairToneIdx, 0, 3, _dir);
	}
	else if (_part == "beard")
	{
		st.BeardIdx = (st.FaceIdx >= 33) ? 0 : stepWrap(st.BeardIdx, 0, 24, _dir);
	}
	else if (_part == "scar")
	{
		st.ScarIdx = stepWrap(st.ScarIdx, 0, 12, _dir);
	}
	else if (_part == "back")
	{
		st.BackIdx = 0;
	}
	else if (_part == "random")
	{
		st.FaceIdx     = ::Math.rand(1, 32);
		st.HairIdx     = ::Math.rand(0, 24);
		st.HairToneIdx = (::Math.rand(1, 100) <= 65) ? 0 : ::Math.rand(1, 3);
		st.BeardIdx    = (::Math.rand(1, 100) <= 28) ? 0 : ::Math.rand(1, 24);
		st.ScarIdx     = (::Math.rand(1, 100) <= 32) ? ::Math.rand(1, 12) : 0;
		st.BackIdx     = 0;
	}
	else if (_part == "random_fem")
	{
		local femHairs = [1, 9, 10, 11, 12, 17, 20, 23];
		st.FaceIdx     = ::Math.rand(33, 48);
		st.HairIdx     = (st.FaceIdx == 40 && ::Math.rand(1, 100) <= 50) ? 0 : femHairs[::Math.rand(0, femHairs.len() - 1)];
		st.HairToneIdx = (st.FaceIdx == 40) ? ::Math.rand(2, 3) : ((::Math.rand(1, 100) <= 80) ? 0 : 1);
		st.BeardIdx    = 0;
		st.ScarIdx     = (::Math.rand(1, 100) <= 22) ? 8 : 0;
		st.BackIdx     = 0;
	}
	else if (_part == "reset_bg")
	{
		local seeded   = ::Wuxia.Appearance.seedValuesFromActor(_actor);
		st.FaceIdx     = seeded.FaceIdx;
		st.HairIdx     = seeded.HairIdx;
		st.HairToneIdx = seeded.HairToneIdx;
		st.BeardIdx    = seeded.BeardIdx;
		st.ScarIdx     = seeded.ScarIdx;
		st.BackIdx     = seeded.BackIdx;
	}

	::Wuxia.Appearance.refreshActorSprites(_actor);
	return ::Wuxia.Appearance.getLabelsForState(st, _actor);
};
