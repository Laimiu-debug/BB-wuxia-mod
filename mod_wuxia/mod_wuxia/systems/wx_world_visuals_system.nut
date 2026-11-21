// Runtime System & Non-Destructive Modern Hooks for Row 4:
//   1. Chinese Prefectures, Garrisons, Villages, Oasis Cities & Sect Mountain Gates (`wx_settlement_0.brush` + `gfx/ui/settlements/`)
//   2. 32 World Map Marching Chess Pieces & Caravans (`wx_world_entity_0.brush`)
//   3. 16 Chinese Vertical Long War Standards (`gfx/ui/banners/` + `wx_world_entity_0.brush` + `wx_banners_0.brush`)

::Wuxia.WorldVisuals <- {
	RegisteredBanners = 0,
	MappedTerrainCount = 0
};

::Wuxia.WorldVisuals.isAsciiName <- function( _s )
{
	if (_s == null || typeof _s != "string" || _s.len() == 0) return false;
	for (local i = 0; i < _s.len(); i = ++i)
	{
		local c = _s[i];
		if (c < 0 || c >= 128) return false;
	}
	return true;
};

::Wuxia.WorldVisuals.initGlobals <- function()
{
	local cfg = ::Wuxia.Config.WorldVisuals;

	// 1. Prepend 12 Wuxia vertical war banners (`banner_51..62`) to `::Const.PlayerBanners`
	//    so New Campaign opens directly on Wuxia standards while preserving `banner_01..34` for old saves.
	if ("PlayerBanners" in ::Const && ::Const.PlayerBanners != null)
	{
		local merged = [];
		local seen = {};
		foreach (b in cfg.PlayerBanners)
		{
			merged.push(b);
			seen[b] <- true;
		}
		foreach (b in ::Const.PlayerBanners)
		{
			if (!(b in seen))
			{
				merged.push(b);
				seen[b] <- true;
			}
		}
		::Const.PlayerBanners = merged;
		::Wuxia.WorldVisuals.RegisteredBanners = cfg.PlayerBanners.len();
	}

	// 2. Remap `::Const.World.TerrainSettlementImages` backgrounds onto our 8 Song/Ming landscapes (`wx_bg_*`)
	if ("World" in ::Const && "TerrainSettlementImages" in ::Const.World)
	{
		local arr = ::Const.World.TerrainSettlementImages;
		local mapped = 0;
		foreach (idx, bgPath in cfg.TerrainBackdropMap)
		{
			if (idx >= 0 && idx < arr.len() && arr[idx] != null && ("Background" in arr[idx]))
			{
				arr[idx].Background = bgPath;
				mapped += 1;
			}
		}
		::Wuxia.WorldVisuals.MappedTerrainCount = mapped;
	}

	// 3. Chinese Mercenary Company Names
	if ("Strings" in ::Const && ::Const.Strings != null && "MercenaryCompanyNames" in ::Const.Strings)
	{
		::Const.Strings.MercenaryCompanyNames = clone cfg.MercenaryCompanyNames;
	}
};

::Wuxia.WorldVisuals.normalizePlayerBannerID <- function( _variant )
{
	if (_variant >= 51 && _variant <= 62) return _variant;
	local v = _variant <= 0 ? 1 : _variant;
	return 51 + ((v - 1) % 12);
};

::Wuxia.WorldVisuals.mapPartyBodyBrush <- function( _brushName, _party = null )
{
	if (_brushName == null || _brushName == "") return null;
	if (_brushName.find("wx_") == 0) return _brushName;

	local cfg = ::Wuxia.Config.WorldVisuals;
	if (_brushName in cfg.PartyExactMap)
		return cfg.PartyExactMap[_brushName];

	foreach (pair in cfg.PartyPrefixMap)
	{
		if (_brushName.find(pair[0]) == 0)
			return pair[1];
	}
	return null;
};

::Wuxia.WorldVisuals.parseTrailingDigits <- function( _str, _prefixLen )
{
	if (_str == null || _str.len() <= _prefixLen) return -1;
	local sub = _str.slice(_prefixLen);
	local val = 0;
	local found = false;
	for (local i = 0; i < sub.len(); i = ++i)
	{
		local ch = sub[i];
		if (ch >= '0' && ch <= '9')
		{
			val = val * 10 + (ch - '0');
			found = true;
		}
		else if (found)
		{
			break;
		}
	}
	return found ? val : -1;
};

::Wuxia.WorldVisuals.mapWorldBannerBrush <- function( _bannerName )
{
	if (_bannerName == null || _bannerName == "") return null;
	if (_bannerName.find("wx_") == 0) return _bannerName;
	if (_bannerName.find("banner_") == 0 && _bannerName.len() == 9)
	{
		local numStr = _bannerName.slice(7);
		local firstCh = numStr[0];
		if (firstCh >= '0' && firstCh <= '9')
		{
			local id = numStr.tointeger();
			if (id >= 51 && id <= 62) return _bannerName;
			return "banner_" + ::Wuxia.WorldVisuals.normalizePlayerBannerID(id);
		}
	}
	if (_bannerName.find("banner_noble_") == 0)
	{
		local n = ::Wuxia.WorldVisuals.parseTrailingDigits(_bannerName, 13);
		if (n >= 1 && n <= 10)
			return "wx_fbanner_noble_" + ::Wuxia.Appearance.pad2(n);
		if (n == 11)
			return "wx_fbanner_civ_01";
		if (n >= 12 && n <= 14)
			return "wx_fbanner_south_0" + (((n - 12) % 3) + 1);
		if (n > 14)
			return "wx_fbanner_noble_" + ::Wuxia.Appearance.pad2(((n - 1) % 10) + 1);
		return "wx_fbanner_noble_01";
	}
	if (_bannerName.find("banner_southern") == 0 || _bannerName.find("banner_citystate") == 0 || _bannerName.find("banner_nomads_") == 0)
	{
		local sn = ::Wuxia.WorldVisuals.parseTrailingDigits(_bannerName, 7);
		local sIdx = (sn >= 1) ? (((sn - 1) % 3) + 1) : 1;
		return "wx_fbanner_south_0" + sIdx;
	}
	if (_bannerName.find("banner_bandits_") == 0 || _bannerName.find("banner_goblins_") == 0 || _bannerName.find("banner_orcs_") == 0 || _bannerName.find("banner_wildmen_") == 0 || _bannerName == "banner_deserters")
		return "wx_fbanner_outlaw_01";
	return null;
};

::Wuxia.WorldVisuals.pickUniqueSettlementName <- function( _poolKey, _seed, _self )
{
	local pools = ::Wuxia.Config.WorldVisuals.SettlementNames;
	local pool = (_poolKey in pools) ? pools[_poolKey] : pools.town;
	local settlements = ("EntityManager" in ::World && ::World.EntityManager != null) ? ::World.EntityManager.getSettlements() : [];
	local used = {};
	foreach (s in settlements)
	{
		if (s != null && s != _self && (::Wuxia.hasMember(s, "getName")))
			used[s.getName()] <- true;
	}
	local n = pool.len();
	for (local i = 0; i < n; i = ++i)
	{
		local cand = pool[(_seed + i) % n];
		if (!(cand in used)) return cand;
	}
	return pool[_seed % n];
};

// Sync the world-map player marching pawn (`player_party`) directly to the player's #1 operated character's actual Wuxia outfit, face, hair, beard & hat!
::Wuxia.WorldVisuals.syncPlayerLeadAppearance <- function( _party = null )
{
	local p = _party;
	if (p == null && ("World" in getroottable()) && ::World != null && ("State" in ::World) && ::World.State != null)
		p = ::World.State.getPlayer();
	if (p == null || !p.hasSprite("body")) return;

	local wmSubLayers = ["wx_wm_hat_back", "wx_wm_head", "wx_wm_beard", "wx_wm_hair", "wx_wm_hat_front"];
	foreach (sn in wmSubLayers)
	{
		if (!p.hasSprite(sn))
		{
			local added = p.addSprite(sn);
			if (added != null) added.Visible = false;
		}
	}

	local bodySpr = p.getSprite("body");
	local curBodyName = bodySpr.HasBrush ? bodySpr.getBrush().Name : "";
	local isSailing = (::Wuxia.hasMember(p.m, "IsSailing") && p.m.IsSailing) || curBodyName == "figure_player_ship" || curBodyName == "wx_ship_junk_01";
	if (isSailing)
	{
		if (curBodyName != "wx_ship_junk_01" && ::Wuxia.Appearance.brushExists("wx_ship_junk_01"))
			bodySpr.setBrush("wx_ship_junk_01");
		foreach (sn in wmSubLayers)
			p.getSprite(sn).Visible = false;
		p.m.WX_LastBodyBrush <- "wx_ship_junk_01";
		return;
	}

	local roster = ("World" in getroottable() && ::World != null) ? ::World.getPlayerRoster() : null;
	local bros = (roster != null) ? roster.getAll() : [];
	local lead = (bros != null && bros.len() > 0) ? bros[0] : null;
	if (lead == null || !("Appearance" in ::Wuxia))
	{
		if (curBodyName.find("wx_") != 0 && curBodyName.find("wm_") != 0)
			bodySpr.setBrush("wx_fig_player_01");
		foreach (sn in wmSubLayers)
			p.getSprite(sn).Visible = false;
		return;
	}

	local st = ::Wuxia.Appearance.getOrInitState(lead);
	local items = (::Wuxia.hasMember(lead, "getItems")) ? lead.getItems() : null;
	local bodyItem = (items != null) ? items.getItemAtSlot(::Const.ItemSlot.Body) : null;
	local headItem = (items != null) ? items.getItemAtSlot(::Const.ItemSlot.Head) : null;
	if (bodyItem != null && ("Armory" in ::Wuxia) && ("ensureArmorMapped" in ::Wuxia.Armory))
		::Wuxia.Armory.ensureArmorMapped(bodyItem);
	if (headItem != null && ("Armory" in ::Wuxia) && ("ensureHelmetMapped" in ::Wuxia.Armory))
		::Wuxia.Armory.ensureHelmetMapped(headItem);

	local bodyCond = (bodyItem != null) ? ((::Wuxia.hasMember(bodyItem, "getCondition")) ? bodyItem.getCondition() : bodyItem.m.Condition) : 0;
	local baseBody = (bodyItem != null && ("WX_BodyBrush" in bodyItem.m) && bodyItem.m.WX_BodyBrush != null && bodyCond > 0)
		? bodyItem.m.WX_BodyBrush
		: ::Wuxia.Appearance.resolveUnarmoredBodyBrush(lead);
	local wmBody = "wm_" + baseBody;
	if (!::Wuxia.Appearance.brushExists(wmBody))
		wmBody = "wx_fig_player_01";

	bodySpr.setBrush(wmBody);
	if (p.hasSprite("base"))
		p.getSprite("base").Visible = true;
	p.m.WX_LastBodyBrush <- wmBody;

	if (wmBody.find("wm_") != 0 || st == null)
	{
		foreach (sn in wmSubLayers)
			p.getSprite(sn).Visible = false;
		return;
	}

	local flip = bodySpr.isFlippedHorizontally();
	local setWM = function( _sprName, _baseBrush )
	{
		local sp = p.getSprite(_sprName);
		if (sp == null) return;
		local cand = (_baseBrush != null && _baseBrush != "") ? ("wm_" + _baseBrush) : null;
		if (cand != null && ::Wuxia.Appearance.brushExists(cand))
		{
			sp.setBrush(cand);
			sp.Visible = true;
			sp.setHorizontalFlipping(flip);
		}
		else
		{
			sp.Visible = false;
		}
	};

	local headCond = (headItem != null) ? ((::Wuxia.hasMember(headItem, "getCondition")) ? headItem.getCondition() : headItem.m.Condition) : 0;
	local hasHat = (headItem != null && ("WX_HatFrontBrush" in headItem.m) && headItem.m.WX_HatFrontBrush != null && headCond > 0);
	local hatID = (hasHat && ("WX_HatID" in headItem.m)) ? headItem.m.WX_HatID : null;
	local hatBack = hasHat
		? (("WX_HatBackBrush" in headItem.m && headItem.m.WX_HatBackBrush != null) ? headItem.m.WX_HatBackBrush : (hatID != null ? (hatID + "_back") : null))
		: null;
	local hatFront = hasHat ? headItem.m.WX_HatFrontBrush : null;

	local fi = ::Math.max(1, ::Math.min(48, st.FaceIdx));
	local ti = ("HairToneIdx" in st && st.HairToneIdx >= 0) ? ::Math.max(0, ::Math.min(3, st.HairToneIdx)) : 0;
	local toneSuffix = ::Wuxia.Appearance.HairTones[ti].Suffix;

	local hideBeard = (fi >= 33) || (st.BeardIdx <= 0 || st.BeardIdx > 24) || (hatID != null && (hatID in ::Wuxia.Appearance.HideBeardHats));
	local beardBrush = null;
	if (!hideBeard)
	{
		beardBrush = "wx_beard_" + ::Wuxia.Appearance.pad2(st.BeardIdx) + toneSuffix;
		if (!::Wuxia.Appearance.brushExists("wm_" + beardBrush))
			beardBrush = "wx_beard_" + ::Wuxia.Appearance.pad2(st.BeardIdx);
	}

	local hideHair = (st.HairIdx <= 0 || st.HairIdx > 24) || (hatID != null && (hatID in ::Wuxia.Appearance.HideHairHats));
	local hairBrush = null;
	if (!hideHair)
	{
		local useTucked = (hatID != null && !(hatID in ::Wuxia.Appearance.OpenCrownHats));
		local baseH = "wx_hair_" + ::Wuxia.Appearance.pad2(st.HairIdx) + (useTucked ? "_tucked" : "");
		hairBrush = baseH + toneSuffix;
		if (!::Wuxia.Appearance.brushExists("wm_" + hairBrush))
			hairBrush = baseH;
	}

	setWM("wx_wm_hat_back",  hatBack);
	setWM("wx_wm_head",      "wx_head_" + ::Wuxia.Appearance.pad2(fi));
	setWM("wx_wm_beard",     beardBrush);
	setWM("wx_wm_hair",      hairBrush);
	setWM("wx_wm_hat_front", hatFront);
};

// Initialize global Const tables immediately
::Wuxia.WorldVisuals.initGlobals();

// =============================================================================
// 1. Player Banner & Tactical Battlefield Bannerman Hooks
// =============================================================================
if ("HooksMod" in ::Wuxia && ::Wuxia.HooksMod != null)
{
	::Wuxia.HooksMod.hook("scripts/states/world/asset_manager", function( q )
	{
		q.updateLook = @(__original) function( _updateTo = -1 )
		{
			__original(_updateTo);
			::Wuxia.WorldVisuals.syncPlayerLeadAppearance();
		};

		q.onDeserialize = @(__original) function( _in )
		{
			__original(_in);
			// Seamlessly upgrade legacy European banner IDs (1..34) on old saves onto Wuxia vertical banners (51..62)
			if (this.m.BannerID < 51 || this.m.BannerID > 62)
			{
				this.m.BannerID = ::Wuxia.WorldVisuals.normalizePlayerBannerID(this.m.BannerID);
				this.m.Banner = "banner_" + this.m.BannerID;
			}
			local p = ::World.State.getPlayer();
			if (p != null)
			{
				if (p.hasSprite("banner"))
					p.getSprite("banner").setBrush(this.m.Banner);
				this.updateLook(-1);
			}
		};
	});

	::Wuxia.HooksMod.hook("scripts/items/tools/player_banner", function( q )
	{
		q.WX_ApplyBannerText <- function()
		{
			this.m.Name = "镇团聚义竖幅大纛";
			this.m.Description = "龙头横杆、红缨精钢矛尖高挑的丝绸竖幅战团大纛。大纛所至，四格内同袍皆受掌旗者定力感召而军心稳固。";
		};

		q.create = @(__original) function()
		{
			__original();
			this.WX_ApplyBannerText();
		};

		q.updateVariant = @(__original) function()
		{
			this.m.Variant = ::Wuxia.WorldVisuals.normalizePlayerBannerID(this.m.Variant);
			__original();
			this.WX_ApplyBannerText();
		};

		q.onEquip = @(__original) function()
		{
			this.m.Variant = ::Wuxia.WorldVisuals.normalizePlayerBannerID(this.m.Variant);
			this.updateVariant();
			__original();
		};

		q.onDeserialize = @(__original) function( _in )
		{
			__original(_in);
			this.m.Variant = ::Wuxia.WorldVisuals.normalizePlayerBannerID(this.m.Variant);
			this.updateVariant();
		};
	});

	::Wuxia.HooksMod.hook("scripts/items/tools/faction_banner", function( q )
	{
		q.create = @(__original) function()
		{
			__original();
			this.m.Name = "藩镇帅字牙旗";
		};

		q.updateAppearance = @(__original) function()
		{
			if (!this.isEquipped()) return;
			local actor = this.getContainer().getActor();
			if (actor == null) return;
			local vIdx = ((::Math.max(1, this.m.Variant) - 1) % 4) + 1;
			if (actor.hasSprite("background"))
				actor.getSprite("background").setBrush("wx_faction_banner_0" + vIdx);
			if (actor.hasSprite("shaft"))
				actor.getSprite("shaft").setBrush("wx_faction_banner_shaft");
			actor.setDirty(true);
		};
	});

	// =========================================================================
	// 2. World Settlements, Mountain Sect Gates, Houses & Town Interior Hooks
	// =========================================================================
	::Wuxia.HooksMod.hook("scripts/entity/world/settlement", function( q )
	{
		q.WX_ComputeArchProfile <- function()
		{
			local tile = this.getTile();
			local seed = (tile != null) ? ::Math.abs(tile.SquareCoords.X * 73 + tile.SquareCoords.Y * 37) : 7;
			local isMtnOrForest = false;
			local isSwamp = false;
			local isSnow = false;

			if (tile != null && ("TerrainType" in ::Const.World))
			{
				local tt = ::Const.World.TerrainType;
				for (local i = 0; i < 6; i = ++i)
				{
					if (!tile.hasNextTile(i)) continue;
					local nt = tile.getNextTile(i).Type;
					if (nt == tt.Mountains || nt == tt.Hills || nt == tt.Forest || nt == tt.LeaveForest)
						isMtnOrForest = true;
					if (nt == tt.Swamp)
						isSwamp = true;
					if (nt == tt.Snow || nt == tt.SnowyForest)
						isSnow = true;
				}
			}

			local sz = this.getSize();
			if (this.isSouthern())
			{
				return {
					WorldSprite  = "wx_set_oasis_city_01",
					HousesIdx    = 4,
					UICenter     = "ui/settlements/wx_ui_center_oasis",
					UIHousesBase = "ui/settlements/wx_ui_houses_04",
					NamePool     = "oasis_city",
					IsSnow       = false
				};
			}
			if (this.isMilitary())
			{
				if (sz <= 1)
					return { WorldSprite = "wx_set_outpost_01",  HousesIdx = 1, UICenter = "ui/settlements/wx_ui_center_outpost",  UIHousesBase = "ui/settlements/wx_ui_houses_fort", NamePool = "fort_small",  IsSnow = isSnow };
				if (sz == 2)
					return { WorldSprite = "wx_set_garrison_02", HousesIdx = 2, UICenter = "ui/settlements/wx_ui_center_garrison", UIHousesBase = "ui/settlements/wx_ui_houses_fort", NamePool = "fort_medium", IsSnow = isSnow };
				return     { WorldSprite = "wx_set_citadel_03",  HousesIdx = 3, UICenter = "ui/settlements/wx_ui_center_citadel",  UIHousesBase = "ui/settlements/wx_ui_houses_fort", NamePool = "fort_large",  IsSnow = isSnow };
			}
			// Mountain / Forest Sect Gate & Zen Monastery towns!
			if (!this.isCoastal() && isMtnOrForest && sz >= 2 && (seed % 3 != 2))
			{
				if (seed % 2 == 0)
					return { WorldSprite = "wx_set_sect_mountain",  HousesIdx = 2, UICenter = "ui/settlements/wx_ui_center_sect",      UIHousesBase = "ui/settlements/wx_ui_houses_sect", NamePool = "sect_town", IsSnow = isSnow };
				return     { WorldSprite = "wx_set_sect_monastery", HousesIdx = 2, UICenter = "ui/settlements/wx_ui_center_monastery", UIHousesBase = "ui/settlements/wx_ui_houses_sect", NamePool = "sect_town", IsSnow = isSnow };
			}
			// Coastal & Jianghuai Swamp Water-Market towns!
			if (this.isCoastal() || isSwamp)
			{
				if (sz <= 1)
					return { WorldSprite = "wx_set_water_market",  HousesIdx = 1, UICenter = "ui/settlements/wx_ui_center_village",    UIHousesBase = "ui/settlements/wx_ui_houses_water", NamePool = "water_town", IsSnow = isSnow };
				if (sz == 2)
					return { WorldSprite = "wx_set_water_market",  HousesIdx = 2, UICenter = "ui/settlements/wx_ui_center_town",       UIHousesBase = "ui/settlements/wx_ui_houses_water", NamePool = "water_town", IsSnow = isSnow };
				return     { WorldSprite = "wx_set_prefecture_03", HousesIdx = 3, UICenter = "ui/settlements/wx_ui_center_prefecture", UIHousesBase = "ui/settlements/wx_ui_houses_water", NamePool = "water_town", IsSnow = isSnow };
			}
			// Standard Central Plains / Steppe / Snow Villages, County Towns & Grand Prefectures
			if (sz <= 1)
				return { WorldSprite = "wx_set_village_01",    HousesIdx = 1, UICenter = "ui/settlements/wx_ui_center_village",    UIHousesBase = "ui/settlements/wx_ui_houses_01", NamePool = "village",    IsSnow = isSnow };
			if (sz == 2)
				return { WorldSprite = "wx_set_town_02",       HousesIdx = 2, UICenter = "ui/settlements/wx_ui_center_town",       UIHousesBase = "ui/settlements/wx_ui_houses_02", NamePool = "town",       IsSnow = isSnow };
			return     { WorldSprite = "wx_set_prefecture_03", HousesIdx = 3, UICenter = "ui/settlements/wx_ui_center_prefecture", UIHousesBase = "ui/settlements/wx_ui_houses_03", NamePool = "prefecture", IsSnow = isSnow };
		};

		q.WX_RebuildHouseTiles <- function( _prof, _onlyLighting = false )
		{
			if (this.m.HousesTiles == null || !("DetailType" in ::Const.World)) return;
			local isNight = ("getTime" in ::World && ::World.getTime() != null) ? !::World.getTime().IsDaytime : false;
			foreach (h in this.m.HousesTiles)
			{
				local hTile = ::World.getTileSquare(h.X, h.Y);
				if (hTile == null) continue;
				local v = (h.V == 2) ? 2 : 1;
				local baseBrush = "wx_houses_0" + _prof.HousesIdx + "_0" + v;
				if (!_onlyLighting)
				{
					hTile.clear(::Const.World.DetailType.Houses | ::Const.World.DetailType.Lighting);
					local d = hTile.spawnDetail(baseBrush + (this.m.IsActive ? "" : "_ruins"), ::Const.World.ZLevel.Object - 3, ::Const.World.DetailType.Houses);
					if (d != null) d.Scale = 0.85;
				}
				else
				{
					hTile.clear(::Const.World.DetailType.Lighting);
				}

				if (this.m.IsActive && isNight)
				{
					local dl = hTile.spawnDetail(baseBrush + "_light", ::Const.World.ZLevel.Object - 4, ::Const.World.DetailType.Lighting);
					if (dl != null)
					{
						dl.IgnoreAmbientColor = true;
						dl.Scale = 0.85;
					}
				}
			}
		};

		q.WX_ApplyArchVisuals <- function( _rebuildHouses = false )
		{
			local prof = this.WX_ComputeArchProfile();
			local snowSuf = prof.IsSnow ? "_snow" : "";

			// Preserve `_undead` state if Undead Crisis conquered this settlement
			local isUndeadTaken = (this.m.Sprite.find("_undead") != null);
			this.m.Sprite = prof.WorldSprite + (isUndeadTaken ? "_undead" : "");
			this.m.Lighting = prof.WorldSprite + (isUndeadTaken ? "_undead_lights" : "_light");
			this.m.UISprite = "ui/settlement_sprites/" + prof.WorldSprite + ".png";

			if (this.m.UIBackground == null || this.m.UIBackground.find("wx_bg_") == null)
			{
				if (this.isSouthern())
					this.m.UIBackground = "ui/settlements/wx_bg_desert";
				else if (this.m.IsCoastal)
					this.m.UIBackground = "ui/settlements/wx_bg_coast";
				else if (prof.IsSnow)
					this.m.UIBackground = "ui/settlements/wx_bg_snow";
				else if (prof.NamePool == "sect_town")
					this.m.UIBackground = "ui/settlements/wx_bg_mountains";
				else if (prof.NamePool == "water_town")
					this.m.UIBackground = "ui/settlements/wx_bg_swamp";
				else
					this.m.UIBackground = "ui/settlements/wx_bg_plains";
			}

			this.m.UIBackgroundCenter = prof.UICenter + snowSuf;
			local hasPortLeft = this.m.IsCoastal && this.m.Buildings.len() > 3 && this.m.Buildings[3] != null && this.m.Buildings[3].getID() == "building.port";
			this.m.UIBackgroundLeft = hasPortLeft ? "ui/settlements/water_01" : (prof.UIHousesBase + "_left" + snowSuf);
			this.m.UIBackgroundRight = prof.UIHousesBase + "_right" + snowSuf;
			this.m.UIRamp = this.isSouthern() ? "ui/settlements/ramp_07" : ("ui/settlements/ramp_01" + snowSuf);
			this.m.UIRampPathway = this.isSouthern() ? "ui/settlements/wx_ui_pathway_sand" : ("ui/settlements/wx_ui_pathway_stone" + snowSuf);
			this.m.UIForeground = null;

			// Authentic Chinese Wuxia settlement hover description
			if (this.isSouthern())
				this.m.Description = "扼守西域瀚海商道的绿洲雄城，胡汉商队、驼铃奇珍与沙海武人在此云集。";
			else if (this.isMilitary())
				this.m.Description = (this.getSize() >= 3)
					? "高墙瓮城、铁甲森严的藩镇节度使帅城，屯驻精锐边军以镇抚一方。"
					: "控扼山川要冲的官军卫所戍堡，旌旗猎猎、刁斗森严。";
			else if (prof.NamePool == "sect_town")
				this.m.Description = "依傍名山古刹而建的清幽山门市镇，常有各派游侠与采药道人往来落脚。";
			else if (prof.NamePool == "water_town")
				this.m.Description = "舟楫纵横、渔歌互答的水陆渡埠集镇，南北漕运商货在此昼夜吞吐。";
			else if (this.getSize() >= 3)
				this.m.Description = "街市繁华、百工齐备的中原大州重府，车马喧阗、三教九流汇聚一堂。";
			else if (this.getSize() == 2)
				this.m.Description = "城垣齐整、商肆林立的州县城池，是往来镖局与江湖行客休整补给的要地。";
			else
				this.m.Description = "炊烟袅袅、桑麻环绕的乡间村镇，民风淳朴却也时常饱受乱世匪患惊扰。";

			if (this.hasSprite("body"))
			{
				local bodyBrush = this.m.IsActive ? this.m.Sprite : (prof.WorldSprite + "_ruins");
				this.getSprite("body").setBrush(bodyBrush);
			}
			if (this.hasSprite("lighting"))
			{
				this.getSprite("lighting").setBrush(this.m.Lighting);
			}
			if (this.hasSprite("location_banner"))
			{
				local resolvedB = this.WX_ResolveSettlementBanner(prof);
				if (resolvedB != null && ::Wuxia.Appearance.brushExists(resolvedB))
					this.getSprite("location_banner").setBrush(resolvedB);
			}

			// Localize European or transliterated settlement names into authentic Chinese Wuxia town names
			if (!("Purify" in ::Wuxia && ::Wuxia.Purify.isWuxiaTownName(this.m.Name)))
			{
				local t = this.getTile();
				local nSeed = (t != null) ? ::Math.abs(t.SquareCoords.X * 53 + t.SquareCoords.Y * 97) : 1;
				this.m.Name = ::Wuxia.WorldVisuals.pickUniqueSettlementName(prof.NamePool, nSeed, this);
			}
			this.WX_RefreshMapSectLabel();

			if (_rebuildHouses)
				this.WX_RebuildHouseTiles(prof, false);
		};

		q.WX_RefreshMapSectLabel <- function()
		{
			if (!this.hasLabel("name")) return;
			local labelStr = this.m.Name;
			if (this.m.IsActive && ("SectRelations" in ::Wuxia) && ("getSettlementSects" in ::Wuxia.SectRelations))
			{
				local sects = ::Wuxia.SectRelations.getSettlementSects(this);
				if (sects.len() > 0 && (sects[0] in ::Wuxia.Config.Sects))
					labelStr = this.m.Name + " · " + ::Wuxia.Config.Sects[sects[0]].Name;
			}
			this.getLabel("name").Text = labelStr;
		};

		q.WX_GetUISubTitle <- function( _prof = null )
		{
			local prof = (_prof != null) ? _prof : this.WX_ComputeArchProfile();
			local sz = this.getSize();
			local base = "桑麻环绕 · 炊烟袅袅之淳朴乡间村镇";
			if (this.isSouthern())
				base = "瀚海商道枢纽 · 胡汉奇珍云集之绿洲雄城";
			else if (this.isMilitary())
			{
				if (sz >= 3) base = "铁甲森严 · 藩镇节度使驻节帅府重城";
				else if (sz == 2) base = "旌旗猎猎 · 控扼山川要冲之官军卫城";
				else base = "刁斗森严 · 戍守边关隘口之烽燧军堡";
			}
			else if (prof.NamePool == "sect_town")
				base = (prof.WorldSprite == "wx_set_sect_monastery")
					? "晨钟暮鼓 · 依傍古刹禅林之山门集镇"
					: "云深松风 · 依傍名山道观之山门市镇";
			else if (prof.NamePool == "water_town")
				base = "舟楫纵横 · 南北漕运吞吐之水陆古渡";
			else if (sz >= 3)
				base = "车马喧阗 · 百工商贾辐辏之大州重府";
			else if (sz == 2)
				base = "城垣齐整 · 镖局行客休整之州县城池";

			if ("SectRelations" in ::Wuxia && "getSettlementSects" in ::Wuxia.SectRelations)
			{
				local sects = ::Wuxia.SectRelations.getSettlementSects(this);
				if (sects.len() > 0 && (sects[0] in ::Wuxia.Config.Sects))
					return base + "（驻地宗门：" + ::Wuxia.Config.Sects[sects[0]].Name + "）";
			}
			return base;
		};

		q.WX_ResolveSettlementBanner <- function( _prof = null )
		{
			local prof = (_prof != null) ? _prof : this.WX_ComputeArchProfile();
			local tile = this.getTile();
			local seed = (tile != null) ? ::Math.abs(tile.SquareCoords.X * 41 + tile.SquareCoords.Y * 83) : 3;

			if (this.isSouthern())
			{
				local ownerS = (::Wuxia.hasMember(this, "getOwner")) ? this.getOwner() : null;
				if (ownerS != null && ::Wuxia.hasMember(ownerS, "getBannerSmall"))
				{
					local sb = ::Wuxia.WorldVisuals.mapWorldBannerBrush(ownerS.getBannerSmall());
					if (sb != null && sb.find("wx_fbanner_south_") == 0) return sb;
				}
				if ("FactionManager" in ::World && ::World.FactionManager != null && ::Wuxia.hasMember(this, "getFactions"))
				{
					foreach (fid in this.getFactions())
					{
						local fac = ::World.FactionManager.getFaction(fid);
						if (fac != null && ::Wuxia.hasMember(fac, "getBannerSmall"))
						{
							local fb = ::Wuxia.WorldVisuals.mapWorldBannerBrush(fac.getBannerSmall());
							if (fb != null && fb.find("wx_fbanner_south_") == 0) return fb;
						}
					}
				}
				return "wx_fbanner_south_0" + ((seed % 3) + 1);
			}

			local owner = (::Wuxia.hasMember(this, "getOwner")) ? this.getOwner() : null;
			if (owner != null && ::Wuxia.hasMember(owner, "getBannerSmall"))
			{
				local ob = owner.getBannerSmall();
				if (ob != null && ob != "banner_noble_11")
				{
					local mappedOwner = ::Wuxia.WorldVisuals.mapWorldBannerBrush(ob);
					if (mappedOwner != null) return mappedOwner;
				}
			}

			if (this.isMilitary())
			{
				if (this.hasSprite("location_banner") && this.getSprite("location_banner").HasBrush)
				{
					local curB = this.getSprite("location_banner").getBrush().Name;
					if (curB.find("wx_fbanner_noble_") == 0) return curB;
					local mb = ::Wuxia.WorldVisuals.mapWorldBannerBrush(curB);
					if (mb != null) return mb;
				}
				return "wx_fbanner_noble_" + ::Wuxia.Appearance.pad2((seed % 10) + 1);
			}

			// Independent civilian towns & regional settlements each fly distinct Song/Ming regional standards
			if (prof.WorldSprite == "wx_set_sect_mountain")
				return "wx_fbanner_civ_02";
			if (prof.WorldSprite == "wx_set_sect_monastery")
				return "wx_fbanner_civ_03";
			if (prof.NamePool == "water_town")
				return "wx_fbanner_civ_04";
			if (prof.IsSnow)
				return "wx_fbanner_civ_05";
			if (this.getSize() <= 1)
				return (seed % 2 == 0) ? "wx_fbanner_civ_06" : "wx_fbanner_civ_01";
			return (seed % 2 == 0) ? "wx_fbanner_civ_01" : "wx_fbanner_civ_06";
		};

		q.onInit = @(__original) function()
		{
			__original();
			this.WX_ApplyArchVisuals(false);
		};

		q.build = @(__original) function()
		{
			__original();
			this.WX_ApplyArchVisuals(true);
		};

		q.setOwner = @(__original) function( _o )
		{
			__original(_o);
			if (this.hasSprite("location_banner"))
			{
				local resolvedB = this.WX_ResolveSettlementBanner(null);
				if (resolvedB != null && ::Wuxia.Appearance.brushExists(resolvedB))
					this.getSprite("location_banner").setBrush(resolvedB);
			}
		};

		q.setActive = @(__original) function( _a, _burn = true )
		{
			__original(_a, _burn);
			this.WX_ApplyArchVisuals(true);
		};

		q.onDeserialize = @(__original) function( _in )
		{
			__original(_in);
			this.WX_ApplyArchVisuals(true);
		};

		q.getUIInformation = @(__original) function()
		{
			local prof = this.WX_ComputeArchProfile();
			this.WX_ApplyArchVisuals(false);
			local ret = __original();
			if (ret != null && typeof ret == "table")
			{
				ret.SubTitle <- this.WX_GetUISubTitle(prof);
				foreach (listKey in ["Slots", "Buildings"])
				{
					if ((listKey in ret) && typeof ret[listKey] == "array")
					{
						for (local i = 0; i < ret[listKey].len(); i = ++i)
						{
							local b = ret[listKey][i];
							if (b != null && typeof b == "table" && ("Image" in b) && b.Image != null && b.Image.find("barber") != null)
								ret[listKey][i] = null;
						}
					}
				}
			}
			return ret;
		};

		if ("getTooltip" in q)
		{
			q.getTooltip = @(__original) function()
			{
				local ret = __original();
				if (ret != null && typeof ret == "array" && this.m.IsActive && ("SectRelations" in ::Wuxia) && ("getSettlementSects" in ::Wuxia.SectRelations))
				{
					local sects = ::Wuxia.SectRelations.getSettlementSects(this);
					if (sects.len() > 0 && (sects[0] in ::Wuxia.Config.Sects))
					{
						local pSect = ::Wuxia.Config.Sects[sects[0]];
						local rel = ::Wuxia.SectRelations.getRelation(sects[0]);
						local relStr = (rel > 0 ? ("+" + rel) : ("" + rel));
						local extra = "";
						if (sects.len() > 1)
						{
							local subNames = [];
							for (local k = 1; k < sects.len(); ++k)
								if (sects[k] in ::Wuxia.Config.Sects) subNames.push(::Wuxia.Config.Sects[sects[k]].Name);
							if (subNames.len() > 0)
								extra = "；同城堂口：" + subNames[0] + (subNames.len() > 1 ? ("、" + subNames[1]) : "");
						}
						ret.push({
							id   = 77,
							type = "text",
							icon = "ui/wx_icons/wx_glyph_sect_token.png",
							text = "驻地宗门：[color=#dda21f]【" + pSect.Name + "】[/color]（交情 " + relStr + "）" + extra + "。入城点击「江湖茶肆」可设席论交或请教本门真传秘籍"
						});
					}
				}
				return ret;
			};
		}

		q.onUpdate = @(__original) function()
		{
			local prevAlpha = this.hasSprite("lighting") ? this.getSprite("lighting").Alpha : 0;
			__original();
			if (this.m.IsActive && this.hasSprite("lighting"))
			{
				local curAlpha = this.getSprite("lighting").Alpha;
				if (prevAlpha == 0 && curAlpha > 0)
				{
					this.WX_RebuildHouseTiles(this.WX_ComputeArchProfile(), true);
				}
			}
		};
	});

	::Wuxia.WorldVisuals.refreshAllSettlementSectLabels <- function()
	{
		if (!("World" in getroottable()) || ::World == null || ::World.EntityManager == null) return;
		foreach (s in ::World.EntityManager.getSettlements())
		{
			if (s != null && s.isAlive() && ("WX_RefreshMapSectLabel" in s))
				s.WX_RefreshMapSectLabel();
		}
	};

	// =========================================================================
	// 3. Town Shop Buildings & Attached Locations Hooks
	// =========================================================================
	::Wuxia.HooksMod.hook("scripts/entity/world/settlements/buildings/building", function( q )
	{
		q.WX_ApplyBuildingVisuals <- function()
		{
			if (this.m.ID in ::Wuxia.Config.WorldVisuals.BuildingMap)
			{
				local bCfg = ::Wuxia.Config.WorldVisuals.BuildingMap[this.m.ID];
				this.m.UIImage = bCfg[0];
				this.m.UIImageNight = (this.m.ID == "building.crowd") ? null : (bCfg[0] + "_night");
				this.m.Name = bCfg[1];
				this.m.Description = bCfg[2];
				if (::Wuxia.hasMember(this.m, "UIImageClosed") && this.m.ID == "building.arena")
					this.m.UIImageClosed = bCfg[0] + "_closed";
			}
		};

		q.getUIImage = @(__original) function()
		{
			this.WX_ApplyBuildingVisuals();
			return __original();
		};

		if ("isHidden" in q)
		{
			q.isHidden = @(__original) function()
			{
				if (this.m.ID == "building.barber") return true;
				return __original();
			};
		}

		q.onDeserialize = @(__original) function( _in )
		{
			__original(_in);
			this.WX_ApplyBuildingVisuals();
		};
	});

	::Wuxia.HooksMod.hookTree("scripts/entity/world/settlements/buildings/building", function( q )
	{
		q.create = @(__original) function()
		{
			__original();
			this.WX_ApplyBuildingVisuals();
		};
	});

	::Wuxia.HooksMod.hook("scripts/entity/world/settlements/buildings/crowd_building", function( q )
	{
		q.getUIImage = @(__original) function()
		{
			this.WX_ApplyBuildingVisuals();
			local res = __original();
			if (res == null) return null;
			return "ui/settlements/wx_bldg_crowd";
		};
	});

	::Wuxia.HooksMod.hook("scripts/entity/world/attached_location", function( q )
	{
		q.WX_ApplyAttachedVisuals <- function()
		{
			if (this.m.ID in ::Wuxia.Config.WorldVisuals.AttachedLocationMap)
			{
				local entry = ::Wuxia.Config.WorldVisuals.AttachedLocationMap[this.m.ID];
				this.m.Name = entry[1];
				if (entry.len() >= 3 && entry[2] != null)
					this.m.Description = entry[2];
				if (entry[0] != null)
				{
					this.m.Sprite = entry[0];
					this.m.SpriteDestroyed = entry[0] + "_ruins";
					if (::Wuxia.hasMember(this, "hasSprite") && this.hasSprite("body"))
						this.getSprite("body").setBrush(this.m.IsActive ? this.m.Sprite : this.m.SpriteDestroyed);
					if (::Wuxia.hasMember(this, "hasSprite") && this.hasSprite("lighting"))
						this.getSprite("lighting").setBrush(entry[0] + "_light");
				}
			}
		};

		q.onInit = @(__original) function()
		{
			__original();
			this.WX_ApplyAttachedVisuals();
		};

		q.setActive = @(__original) function( _a )
		{
			__original(_a);
			this.WX_ApplyAttachedVisuals();
		};

		q.onDeserialize = @(__original) function( _in )
		{
			__original(_in);
			this.WX_ApplyAttachedVisuals();
		};
	});

	::Wuxia.HooksMod.hookTree("scripts/entity/world/attached_location", function( q )
	{
		q.create = @(__original) function()
		{
			__original();
			this.WX_ApplyAttachedVisuals();
		};
	});

	// =========================================================================
	// 4. World Map Marching Chess Pieces, Caravans, Ships & Party Flags Hooks
	// =========================================================================
	::Wuxia.HooksMod.hook("scripts/entity/world/party", function( q )
	{
		q.WX_RefreshPartyVisuals <- function()
		{
			if (this.m.IsPlayer)
			{
				::Wuxia.WorldVisuals.syncPlayerLeadAppearance(this);
			}
			else if (this.hasSprite("body"))
			{
				local spr = this.getSprite("body");
				if (spr.HasBrush)
				{
					local curName = spr.getBrush().Name;
					local patrolSect = (this.m.Flags != null) ? this.m.Flags.get("wx_sect_patrol") : null;
					local patrolFig  = (this.m.Flags != null) ? this.m.Flags.get("wx_sect_patrol_fig") : null;
					local patrolBan  = (this.m.Flags != null) ? this.m.Flags.get("wx_sect_patrol_banner") : null;
					if (patrolSect != null && patrolSect != "" && patrolFig != null && patrolFig != "" && ::Wuxia.Appearance.brushExists(patrolFig))
					{
						if (curName != patrolFig)
							spr.setBrush(patrolFig);
						this.m.WX_LastBodyBrush <- patrolFig;
						if (this.hasSprite("banner") && patrolBan != null && patrolBan != "" && ::Wuxia.Appearance.brushExists(patrolBan))
						{
							this.getSprite("banner").setBrush(patrolBan);
							this.getSprite("banner").Visible = true;
							this.m.WX_LastBannerBrush <- patrolBan;
						}
					}
					else if (curName.find("wx_") != 0 && curName.find("wm_") != 0)
					{
						local targetBrush = null;
						local sectID = (this.m.Flags != null) ? this.m.Flags.get("wx_vendetta") : null;
						if (sectID != null && sectID != "" && (sectID in ::Wuxia.Config.Sects))
						{
							local vParty = ::Wuxia.Config.Sects[sectID].VendettaParty;
							if (vParty in ::Wuxia.Config.WorldVisuals.VendettaVisualMap)
							{
								local vSpec = ::Wuxia.Config.WorldVisuals.VendettaVisualMap[vParty];
								targetBrush = vSpec[0];
								if (this.hasSprite("banner"))
									this.getSprite("banner").setBrush(vSpec[1]);
							}
						}

						if (targetBrush == null)
							targetBrush = ::Wuxia.WorldVisuals.mapPartyBodyBrush(curName, this);

						if (targetBrush != null && targetBrush != curName)
						{
							spr.setBrush(targetBrush);
							curName = targetBrush;
						}
						this.m.WX_LastBodyBrush <- curName;
					}
				}
			}

			if (this.hasSprite("banner"))
			{
				local bSpr = this.getSprite("banner");
				local pBanCheck = (this.m.Flags != null) ? this.m.Flags.get("wx_sect_patrol_banner") : null;
				if (pBanCheck != null && pBanCheck != "" && ::Wuxia.Appearance.brushExists(pBanCheck))
				{
					bSpr.setBrush(pBanCheck);
					this.m.WX_LastBannerBrush <- pBanCheck;
				}
				else if (bSpr.HasBrush)
				{
					local curB = bSpr.getBrush().Name;
					if (!("WX_LastBannerBrush" in this.m) || this.m.WX_LastBannerBrush != curB)
					{
						local mappedB = null;
						local vFlag = (this.m.Flags != null) ? this.m.Flags.get("wx_vendetta") : null;
						if (!this.m.IsPlayer && (vFlag == null || vFlag == "") && ("FactionManager" in ::World) && ::World.FactionManager != null && ::Wuxia.hasMember(this, "getFaction"))
						{
							local fac = ::World.FactionManager.getFaction(this.getFaction());
							if (fac != null)
							{
								if (::Wuxia.hasMember(fac, "getSettlements"))
								{
									local fSets = fac.getSettlements();
									if (fSets != null && fSets.len() == 1 && fSets[0] != null && ("WX_ResolveSettlementBanner" in fSets[0]))
										mappedB = fSets[0].WX_ResolveSettlementBanner(null);
								}
								if (mappedB == null && ::Wuxia.hasMember(fac, "getBannerSmall"))
									mappedB = ::Wuxia.WorldVisuals.mapWorldBannerBrush(fac.getBannerSmall());
							}
						}
						if (mappedB == null)
							mappedB = ::Wuxia.WorldVisuals.mapWorldBannerBrush(curB);
						if (mappedB != null && mappedB != curB && ::Wuxia.Appearance.brushExists(mappedB))
						{
							bSpr.setBrush(mappedB);
							curB = mappedB;
						}
						this.m.WX_LastBannerBrush <- curB;
					}
				}
			}
		};

		if ("getTooltip" in q)
		{
			q.getTooltip = @(__original) function()
			{
				local ret = __original();
				if (ret != null && typeof ret == "array" && this.m.Flags != null && ("SectRelations" in ::Wuxia))
				{
					local psid = this.m.Flags.get("wx_sect_patrol");
					if (psid == null || psid == "") psid = this.m.Flags.get("wx_vendetta");
					if (psid != null && psid != "" && (psid in ::Wuxia.Config.Sects))
					{
						local pSect = ::Wuxia.Config.Sects[psid];
						local rel = ::Wuxia.SectRelations.getRelation(psid);
						local relStr = (rel > 0 ? ("+" + rel) : ("" + rel));
						local anchor = ::Wuxia.SectRelations.getSectAnchorInfo(psid);
						local homeNote = (anchor.townName != "") ? (" · 驻地：" + anchor.townName) : "";
						ret.push({
							id   = 78,
							type = "text",
							icon = "ui/wx_icons/wx_glyph_sect_token.png",
							text = "所属宗门：[color=#dda21f]【" + pSect.Name + "】[/color]（当前交情 " + relStr + homeNote + "）"
						});
					}
				}
				return ret;
			};
		}

		q.onAfterInit = @(__original) function()
		{
			__original();
			this.WX_RefreshPartyVisuals();
		};

		q.onDeserialize = @(__original) function( _in )
		{
			__original(_in);
			this.m.WX_LastBodyBrush <- "";
			this.m.WX_LastBannerBrush <- "";
			this.WX_RefreshPartyVisuals();
		};

		q.onUpdate = @(__original) function()
		{
			__original();
			if (this.m.IsPlayer && this.hasSprite("body"))
			{
				local bs = this.getSprite("body");
				local bName = bs.HasBrush ? bs.getBrush().Name : "";
				// Immediately re-sync if vanilla switched to/from ship or reset figure_player_*
				if (bName == "figure_player_ship" || bName.find("figure_player_") == 0)
					::Wuxia.WorldVisuals.syncPlayerLeadAppearance(this);
				local fl = bs.isFlippedHorizontally();
				foreach (sn in ["wx_wm_hat_back", "wx_wm_head", "wx_wm_beard", "wx_wm_hair", "wx_wm_hat_front"])
				{
					if (this.hasSprite(sn))
						this.getSprite(sn).setHorizontalFlipping(fl);
				}
			}
			local nowT = ("Time" in getroottable() && ::Time != null) ? ::Time.getVirtualTimeF() : 0.0;
			if ("WX_NextVisTime" in this.m && nowT < this.m.WX_NextVisTime)
				return;
			this.m.WX_NextVisTime <- nowT + 2.0;
			this.WX_RefreshPartyVisuals();
		};
	});

	// Localize Noble House Faction Names, Mottos & Descriptions unconditionally (even under transliterated l10n mods)
	::Wuxia.HooksMod.hook("scripts/factions/noble_faction", function( q )
	{
		q.WX_EnsureChineseHouseName <- function()
		{
			if ("Purify" in ::Wuxia && "NobleHouses" in ::Wuxia.Purify)
			{
				local list = ::Wuxia.Purify.NobleHouses;
				local entry = list[::Math.abs(this.getID()) % list.len()];
				this.m.Name = entry[0];
				if (::Wuxia.hasMember(this.m, "Motto")) this.m.Motto = entry[1];
				if (::Wuxia.hasMember(this.m, "Description")) this.m.Description = entry[2];
			}
			else if (::Wuxia.WorldVisuals.isAsciiName(this.m.Name))
			{
				local pool = ::Wuxia.Config.WorldVisuals.NobleHouseNames;
				this.m.Name = pool[::Math.abs(this.getID()) % pool.len()];
			}
		};

		q.onDeserialize = @(__original) function( _in )
		{
			__original(_in);
			this.WX_EnsureChineseHouseName();
		};

		q.getName = @(__original) function()
		{
			this.WX_EnsureChineseHouseName();
			return __original();
		};
	});
}
