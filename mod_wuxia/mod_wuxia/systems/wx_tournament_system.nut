// Wuxia Martial Arts Tournament & Silver Betting System (`天下武林大会 64 强 / 州府群英演武擂 16 强`)
// Features:
// - 5-Hero Player Registration OR Pure Spectating & Single / 6-Leg Parlay Silver Betting (`外围红盘连环银票`)
// - 44 Authentic Wuxia Sect Representative Squads (casting real 7-slot Wuxia skills!) + ShanHai / Tomb Guest Entries
// - Non-lethal combat (`监擂长老飞身救护 · 点到为止`), 1x/4x/12x Live Spectating, & Champion Purse Rewards!

::Wuxia.Tournament <- {
	MemberWorldContext = {
		m = { IsExitingToMenu = false },
		isScenarioMode = function() { return false; },
		isFleeing = function() { return false; },
		getStrategicProperties = function() { return { IsArenaMode = false }; }
	},
	AppearanceLayers = [
		"head", "hair", "beard", "beard_top", "body", "tattoo_body",
		"tattoo_head", "surcoat", "legs_back", "legs_front", "head_frenzy"
	]
};

local T = ::Wuxia.Tournament;
local G = ::Wuxia.Gambling;

// -----------------------------------------------------------------------------
// 1. Safe World-Roster Context & Deep Actor / Wuxia Manual Cloning
// -----------------------------------------------------------------------------
T.withMemberContext <- function( _fn )
{
	local existed = ("Tactical" in getroottable()) && ("State" in ::Tactical);
	local previous = existed ? ::Tactical.State : null;
	local installed = (previous == null) && ("Tactical" in getroottable());
	if (installed) ::Tactical.rawset("State", this.MemberWorldContext);
	local res = null;
	try
	{
		res = _fn();
	}
	catch (err)
	{
		if (installed && ("State" in ::Tactical) && ::Tactical.State == this.MemberWorldContext)
		{
			if (existed) ::Tactical.State = previous;
			else ::Tactical.rawdelete("State");
		}
		throw err;
	}
	if (installed && ("State" in ::Tactical) && ::Tactical.State == this.MemberWorldContext)
	{
		if (existed) ::Tactical.State = previous;
		else ::Tactical.rawdelete("State");
	}
	return res;
};

T.dataCopy <- function( _val, _depth = 0 )
{
	local kind = typeof _val;
	if (_val == null || kind == "string" || kind == "integer" || kind == "float" || kind == "bool")
		return _val;
	if (_depth > 12) throw "Tournament data nesting exceeds limit";
	if (kind == "array")
	{
		local out = [];
		foreach (v in _val) out.push(this.dataCopy(v, _depth + 1));
		return out;
	}
	if (kind == "table")
	{
		local out = {};
		foreach (k, v in _val)
		{
			if (typeof v != "function")
				out.rawset(k, this.dataCopy(v, _depth + 1));
		}
		return out;
	}
	return null;
};

T.copyItemValues <- function( _item, _copy )
{
	local seen = {};
	for (local fields = _item.m; fields != null; fields = fields.getdelegate())
	{
		foreach (k, v in fields)
		{
			if (k in seen) continue;
			seen.rawset(k, true);
			local kind = typeof v;
			if (v == null || kind == "string" || kind == "integer" || kind == "float" || kind == "bool")
			{
				if (k != "Container" && k != "CurrentSlotType" && k != "Tile")
					_copy.m.rawset(k, v);
			}
		}
	}
};

T.cloneSingleItem <- function( _item )
{
	local copy = ::new(::IO.scriptFilenameByHash(_item.ClassNameHash));
	this.copyItemValues(_item, copy);
	if ("Upgrade" in _item.m && _item.m.Upgrade != null)
		copy.setUpgrade(this.cloneSingleItem(_item.m.Upgrade));
	copy.setCurrentSlotType(::Const.ItemSlot.None);
	copy.setContainer(null);
	return copy;
};

T.copyActorGear <- function( _src, _dst )
{
	_dst.getItems().clear();
	foreach (item in _src.getItems().getAllItems())
	{
		if (item == null) continue;
		local copy = this.cloneSingleItem(item);
		if (item.getCurrentSlotType() == ::Const.ItemSlot.Bag)
			_dst.getItems().addToBag(copy);
		else
			_dst.getItems().equip(copy);
		this.copyItemValues(item, copy);
		copy.updateAppearance();
	}
	if ("Armory" in ::Wuxia && "syncActorHandheldAndArmor" in ::Wuxia.Armory)
		::Wuxia.Armory.syncActorHandheldAndArmor(_dst);
};

T.rememberAppearance <- function( _actor )
{
	local saved = { fields = {}, layers = [] };
	local empty = [];
	foreach (k in ["Size", "Head", "WX_SchoolRole", "WX_LoadoutKey"])
	{
		if (k in _actor.m && _actor.m[k] != null)
			saved.fields.rawset(k, _actor.m[k]);
	}
	foreach (lname in this.AppearanceLayers)
	{
		if (_actor.hasSprite(lname))
		{
			local sp = _actor.getSprite(lname);
			saved.layers.push({
				name       = lname,
				brush      = sp.HasBrush ? sp.getBrush().Name : "",
				scale      = sp.Scale,
				saturation = sp.Saturation
			});
			if (!sp.HasBrush) empty.push(lname);
		}
	}
	_actor.getFlags().set("WX_ArenaAppearance", G.encode(saved));
	_actor.getFlags().set("WX_ArenaEmptyLayers", G.encode(empty));
};

T.restoreEmptyLayers <- function( _actor )
{
	if (_actor == null) return;
	local flags = _actor.getFlags();
	if (flags.has("WX_ArenaAppearance"))
	{
		try
		{
			local saved = G.decode(flags.get("WX_ArenaAppearance"));
			foreach (k, v in saved.fields) _actor.m.rawset(k, v);
			if ("Size" in saved.fields && ::Wuxia.hasMember(_actor, "setSize")) _actor.setSize(saved.fields.Size);
			foreach (layer in saved.layers)
			{
				if (_actor.hasSprite(layer.name))
				{
					local sp = _actor.getSprite(layer.name);
					if (layer.brush.len() > 0) sp.setBrush(layer.brush);
					else sp.resetBrush();
					sp.Scale = layer.scale;
					sp.Saturation = layer.saturation;
				}
			}
		}
		catch (_e) {}
	}
	if (flags.has("WX_ArenaEmptyLayers"))
	{
		try
		{
			foreach (lname in G.decode(flags.get("WX_ArenaEmptyLayers")))
			{
				if (_actor.hasSprite(lname)) _actor.getSprite(lname).resetBrush();
			}
		}
		catch (_e) {}
	}
};

T.copyActorToTournament <- function( _src, _dst )
{
	if (_src.getFlags().has("WX_ArenaPackSize"))
		_dst.getFlags().set("WX_ArenaPackSize", _src.getFlags().getAsInt("WX_ArenaPackSize"));

	_dst.getItems().clear();
	foreach (sk in clone _dst.getSkills().m.Skills)
		_dst.getSkills().remove(sk);

	_dst.m.BaseProperties = _src.getBaseProperties().getClone();

	local srcMartial = _src.getSkills().getSkillByID("special.wx_martial_container");
	local grantedIds = (srcMartial != null && "GrantedSkills" in srcMartial.m) ? srcMartial.m.GrantedSkills : {};

	foreach (sk in _src.getSkills().m.Skills)
	{
		if (sk == null || sk.isGarbage() || sk.m.Item != null || sk.getID() == "special.stats_collector")
			continue;
		local sid = sk.getID();
		// Skip skills dynamically managed by wx_martial_container (they will be cleanly rebuilt by syncGrantedSkills!)
		if (sid != "special.wx_martial_container" && (sid in grantedIds))
			continue;
		if (sid == "special.wx_martial_container")
		{
			local cCopy = ::new("scripts/skills/special/wx_martial_container");
			cCopy.m.SchemaVersion      = sk.m.SchemaVersion;
			cCopy.m.Slots              = this.dataCopy(sk.m.Slots);
			cCopy.m.LearnedManuals     = this.dataCopy(sk.m.LearnedManuals);
			cCopy.m.PendingWashChances = sk.m.PendingWashChances;
			cCopy.m.UsedUniqueEffects  = this.dataCopy(sk.m.UsedUniqueEffects);
			cCopy.m.MarrowWashCount    = sk.m.MarrowWashCount;
			cCopy.m.FaceIdx            = sk.m.FaceIdx;
			cCopy.m.HairIdx            = sk.m.HairIdx;
			cCopy.m.HairToneIdx        = sk.m.HairToneIdx;
			cCopy.m.BeardIdx           = sk.m.BeardIdx;
			cCopy.m.ScarIdx            = sk.m.ScarIdx;
			cCopy.m.BackIdx            = sk.m.BackIdx;
			cCopy.m.GrantedSkills      = {};
			cCopy.m.CachedAggFlags     = null;
			_dst.getSkills().add(cCopy);
			continue;
		}
		local skPath = ::IO.scriptFilenameByHash(sk.ClassNameHash);
		if (skPath == null || skPath == "") continue;
		local cp = ::new(skPath);
		foreach (k, v in sk.m)
		{
			if (k != "Container" && k != "Item")
				cp.m.rawset(k, this.dataCopy(v));
		}
		_dst.getSkills().add(cp);
	}

	_dst.getItems().setUnlockedBagSlots(_src.getItems().getUnlockedBagSlots());
	this.copyActorGear(_src, _dst);

	foreach (k in [
		"Name", "Title", "Level", "XP", "Body", "Ethnicity", "Gender", "VoiceSet", "Surcoat",
		"Mood", "Fatigue", "MoraleState", "PerkPoints", "PerkPointsSpent", "LevelUps",
		"HireTime", "LastDrinkTime", "IsTryoutDone", "PlaceInFormation",
		"Talents", "Attributes", "MoodChanges", "Size", "Head"
	])
	{
		if (::Wuxia.hasMember(_src.m, k) && ::Wuxia.hasMember(_dst.m, k))
			_dst.m[k] = this.dataCopy(_src.m[k]);
	}
	if (::isKindOf(_dst, "player"))
	{
		if (::Wuxia.hasMember(_dst.m, "Talents") && _dst.m.Talents.len() < ::Const.Attributes.COUNT)
		{
			local tArr = [];
			tArr.resize(::Const.Attributes.COUNT, 0);
			_dst.m.Talents = tArr;
		}
		if (::Wuxia.hasMember(_dst.m, "Attributes") && _dst.m.Attributes.len() < ::Const.Attributes.COUNT)
		{
			local aArr = [];
			for (local ai = 0; ai < ::Const.Attributes.COUNT; ai = ++ai)
				aArr.push([2, 2, 2, 2, 2, 2, 2, 2, 2, 2]);
			_dst.m.Attributes = aArr;
		}
	}
	foreach (wxKey in ["WX_SchoolRole", "WX_LoadoutKey"])
	{
		if (wxKey in _src.m)
			_dst.m.rawset(wxKey, _src.m[wxKey]);
	}

	_dst.setName(_src.getNameOnly());
	_dst.m.rawset("Title", _src.m.Title);

	if ("Background" in _dst.m)
	{
		local bgs = _dst.getSkills().query(::Const.SkillType.Background);
		_dst.m.Background = bgs.len() > 0 ? bgs[0] : null;
	}
	_dst.m.WorldTroop = null;
	_dst.getFlags().set("WX_ArenaCopy", true);
	_dst.getFlags().set("WX_ArenaOriginal", _src.getID());

	if ("Size" in _src.m && ::Wuxia.hasMember(_dst, "setSize"))
		_dst.setSize(_src.m.Size);

	foreach (lname in this.AppearanceLayers)
	{
		if (!_src.hasSprite(lname) || !_dst.hasSprite(lname)) continue;
		local sa = _src.getSprite(lname);
		local sb = _dst.getSprite(lname);
		if (sa.HasBrush) sb.setBrush(sa.getBrush().Name);
		else sb.resetBrush();
		sb.Color = sa.Color;
		sb.Saturation = sa.Saturation;
		sb.Scale = sa.Scale;
	}

	local dstMartial = _dst.getSkills().getSkillByID("special.wx_martial_container");
	if (dstMartial != null)
		dstMartial.syncGrantedSkills();

	this.rememberAppearance(_dst);
	_dst.getSkills().update();
	_dst.setHitpoints(_dst.getHitpointsMax());
	_dst.setFatigue(0);
	return _dst;
};

// -----------------------------------------------------------------------------
// 2. Host Discovery, Bracket Lifecycle & Wuxia Team Generation
// -----------------------------------------------------------------------------
T.arenaBook <- function()
{
	if (!G.ensure() || G.State == null)
		return { next = 1, events = [] };
	if (!("arena" in G.State) || G.State.arena == null)
		G.State.rawset("arena", { next = 1, events = [] });
	return G.State.arena;
};

T.findEvent <- function( _id )
{
	foreach (ev in this.arenaBook().events)
	{
		if (ev.id == _id) return ev;
	}
	return null;
};

T.findMatch <- function( _ev, _matchId )
{
	if (_ev == null || !G.whole(_matchId, 1, _ev.matches.len())) return null;
	return _ev.matches[_matchId - 1];
};

T.findTeam <- function( _ev, _teamId )
{
	if (_ev == null || !G.whole(_teamId, 1, _ev.teams.len())) return null;
	return _ev.teams[_teamId - 1];
};

T.isLiveTown <- function( _town )
{
	return _town != null && !("isNull" in _town && _town.isNull()) && _town.isAlive();
};

T.isStandardHostTown <- function( _town )
{
	return this.isLiveTown(_town) && (_town.hasBuilding("building.arena") || (::Wuxia.hasMember(_town, "getSize") && _town.getSize() >= 3));
};

T.findFallbackHost <- function( _settlements )
{
	local best = null;
	local bestSize = -1;
	foreach (town in _settlements)
	{
		if (!this.isLiveTown(town)) continue;
		if (this.isStandardHostTown(town)) return null;
		local size = ::Wuxia.hasMember(town, "getSize") ? town.getSize() : 0;
		if (best == null || size > bestSize)
		{
			best = town;
			bestSize = size;
		}
	}
	return best;
};

T.isHostTown <- function( _town )
{
	if (this.isStandardHostTown(_town)) return true;
	if (!this.isLiveTown(_town) || !::Wuxia.hasWorldField("EntityManager")) return false;
	local fallback = this.findFallbackHost(::World.EntityManager.getSettlements());
	return fallback != null && fallback.getID() == _town.getID();
};

T.currentVenue <- function()
{
	if (("Tactical" in getroottable()) && ("isActive" in ::Tactical) && ::Tactical.isActive()) return null;
	if (!("World" in getroottable()) || ::World == null || !("State" in ::World) || ::World.State == null) return null;
	local town = ::World.State.getCurrentTown();
	return this.isHostTown(town) ? town : null;
};

T.atEventVenue <- function( _ev )
{
	local town = this.currentVenue();
	return _ev != null && town != null && town.getID() == _ev.town;
};

T.addNotice <- function( _ev, _text )
{
	_ev.notices.push({ day = G.day(), text = _text });
	while (_ev.notices.len() > 12) _ev.notices.remove(0);
};

T.rosterID <- function( _ev, _team ) { return 17000000 + _ev.id * 100 + _team.id; };
T.getTeamRoster <- function( _team ) { return ::World.getRoster(_team.roster); };

T.cleanupEventRosters <- function( _ev )
{
	if (_ev == null || !("teams" in _ev)) return;
	foreach (team in _ev.teams)
	{
		if ("roster" in team && team.roster > 0)
		{
			try { ::World.deleteRoster(team.roster); } catch (_e) {}
		}
	}
};

T.isSeasonOver <- function( _ev )
{
	local cooldown = (_ev.size == 64) ? 45 : 28;
	return _ev.phase == "finished" && G.day() >= _ev.finishedDay + cooldown;
};

T.hasUnclaimedPayout <- function( _ev )
{
	foreach (ticket in _ev.tickets)
	{
		if (!ticket.paid && this.ticketValue(_ev, ticket).amount > 0)
			return true;
	}
	return false;
};

T.createEvent <- function( _town, _size )
{
	if ((_size != 16 && _size != 64) || !this.isHostTown(_town)) return null;
	local book = this.arenaBook();
	local edition = 1;
	local current = null;
	local pruned = false;

	for (local i = book.events.len() - 1; i >= 0; i = --i)
	{
		local old = book.events[i];
		if (old.town != _town.getID() || old.size != _size) continue;
		edition = G.max(edition, old.edition + 1);
		if (!this.isSeasonOver(old))
		{
			if (current == null) current = old;
		}
		else if (!this.hasUnclaimedPayout(old))
		{
			this.cleanupEventRosters(old);
			book.events.remove(i);
			pruned = true;
		}
	}

	if (current != null)
	{
		if (pruned) G.touch();
		return current;
	}

	local title = (_size == 64) ? "天下武林大会" : (_town.getName() + "群英演武擂");
	local ev = {
		id            = book.next++,
		town          = _town.getID(),
		townName      = _town.getName(),
		size          = _size,
		title         = title,
		edition       = edition,
		phase         = "registration",
		openedDay     = G.day(),
		finishedDay   = -1,
		round         = 0,
		player        = 0,
		purseAwarded  = false,
		selected      = [],
		teams         = [],
		matches       = [],
		tickets       = [],
		nextTicket    = 1,
		champion      = 0,
		notices       = []
	};
	book.events.push(ev);
	this.addNotice(ev, "【英雄帖昭告天下】" + ev.townName + "演武总坛现为第 " + edition + " 届《" + ev.title
		+ "》广发英雄帖，共设 " + _size + " 席！九州名门正派、奇门邪宗与山海驯兽异人皆可登台较技。监擂长老坐镇护持，点到为止不伤性命。欲买外围红盘银票或递交五人英雄帖者，请亲赴" + ev.townName + "演武柜台！");
	G.touch();
	return ev;
};

T.discoverEvents <- function()
{
	if (!G.ensure()) return;
	if (!::Wuxia.hasWorldField("EntityManager")) return;
	local settlements = ::World.EntityManager.getSettlements();
	local fallback = this.findFallbackHost(settlements);
	if (fallback != null)
	{
		this.createEvent(fallback, 16);
		return;
	}

	foreach (town in settlements)
	{
		if (this.isStandardHostTown(town))
		{
			this.createEvent(town, 16);
			this.createEvent(town, 64);
		}
	}
};

T.roundName <- function( _ev, _round )
{
	local teams = _ev.size;
	for (local r = 0; r < _round; r = ++r) teams /= 2;
	if (teams == 2) return _ev.size == 64 ? "武林盟主总决赛" : "魁首总决赛";
	if (teams == 4) return "四强半决赛";
	if (teams == 8) return "八强论剑";
	if (teams == 16) return "十六强争锋";
	if (teams == 32) return "三十二强会武";
	return "六十四强初赛";
};

T.shuffleArray <- function( _arr )
{
	for (local i = _arr.len() - 1; i > 0; i = --i)
	{
		local j = G.rand(0, i);
		local tmp = _arr[i];
		_arr[i] = _arr[j];
		_arr[j] = tmp;
	}
	return _arr;
};

T.pickWuxiaFighterName <- function( _roleName, _sectId, _roster, _index )
{
	local poolKey = "jianghu";
	if (_sectId == "shaolin" || _roleName.find("僧") != null) poolKey = "monk";
	else if (_sectId == "taihe" || _sectId == "qingfeng" || _sectId == "xuanbing" || _roleName.find("剑") != null) poolKey = "master";
	else if (_roleName.find("女") != null) poolKey = "dancer";
	else if (_sectId == "pishan" || _roleName.find("辽东") != null || _roleName.find("漠北") != null) poolKey = "northern";
	else if (_sectId == "shenji" || _roleName.find("西域") != null) poolKey = "western";

	local pool = ("NamePools" in ::Wuxia.Config && poolKey in ::Wuxia.Config.NamePools)
		? ::Wuxia.Config.NamePools[poolKey]
		: ::Const.Strings.CharacterNames;

	local used = {};
	foreach (other in _roster.getAll())
		used.rawset(other.getNameOnly(), true);

	local startIdx = G.rand(0, pool.len() - 1);
	local chosen = pool[startIdx];
	for (local i = 0; i < pool.len(); i = ++i)
	{
		local cand = pool[(startIdx + i + _index * 3) % pool.len()];
		if (!(cand in used)) { chosen = cand; break; }
	}
	return chosen + "（" + _roleName + "）";
};

T.nameExoticGuest <- function( _actor, _team, _index, _roster )
{
	if (_team.human)
	{
		local poolKey = (_team.entry == "desert_blades") ? "western" : "jianghu";
		local pool = ::Wuxia.Config.NamePools[poolKey];
		local nm = pool[(G.rand(0, pool.len() - 1) + _index) % pool.len()];
		_actor.setName(nm);
		return;
	}
	local prefixes = ["裂齿", "赤瞳", "断耳", "苍脊", "铁鳞", "凶牙", "玄爪", "碎甲", "铁颚", "摧岳", "霜鬃", "血吻"];
	local off = (_team.roster + _index) % prefixes.len();
	local species = _actor.getNameOnly();
	if (_team.entry == "titan_zhuyan") species = "白首朱厌";
	else if (_team.entry == "titan_mountain") species = "裂岳巨猿";
	else if (_team.entry == "titan_bog") species = "瘴骨凶猿";
	else if (_team.entry == "yaoren_overlord") species = "炼体魔尊";
	_actor.setName(prefixes[off] + " · " + species);
};

T.buildSectCandidatePool <- function()
{
	local out = [];
	local cfg = ::Wuxia.Config.Gambling;
	local sectIds = [];
	foreach (sid, _ in ::Wuxia.Config.Sects) sectIds.push(sid);
	this.shuffleArray(sectIds);

	foreach (sid in sectIds)
	{
		local sdef = ::Wuxia.Config.Sects[sid];
		local spec = (sid in cfg.SectSquadMap)
			? cfg.SectSquadMap[sid]
			: ((sdef.Region in cfg.RegionSquadFallbacks) ? cfg.RegionSquadFallbacks[sdef.Region] : cfg.RegionSquadFallbacks.plains);

		local alignLabel = (sdef.Alignment == "righteous") ? "名门正派" : (sdef.Alignment == "outlaw" ? "绿林邪宗" : "江湖世家");
		out.push({
			sectId  = sid,
			player  = false,
			name    = sdef.Name + " · " + spec.Suffix,
			banner  = spec.Banner,
			faction = alignLabel,
			unit    = "人",
			count   = 5,
			solo    = false,
			human   = true,
			wxRoles = clone spec.Roster,
			power   = 1.0,
			story   = "【" + sdef.Name + "】遣五名精锐门人持帖登台。" + sdef.Description + "（五人联袂出阵）"
		});
	}

	// Supplement Imperial / Official / Jianghu elite delegations so even 64-team brackets have plenty of human martial teams!
	local extras = [
		{ sectId = "imperial_guard", name = "六扇门 · 朱衣神捕队", banner = "banner_55", faction = "朝廷官差", wxRoles = ["liushan_bailiff", "liushan_bailiff", "escort", "escort", "shenji_musketeer"], story = "六扇门紫衣神捕亲率铁索快捕奉旨观礼顺带下场演武，铁尺锁链专拿狂徒。" },
		{ sectId = "dongchang",      name = "东厂 · 绣春缇骑卫",   banner = "banner_61", faction = "朝廷内卫", wxRoles = ["dongchang_agent", "dongchang_agent", "shadow_dagger", "shenji_musketeer", "dartist"], story = "身披飞鱼服、腰悬绣春刀的厂卫高手冷面入席，刀法狠辣迅疾，看客无不侧目。" },
		{ sectId = "fanzhen_halberd",name = "河朔藩镇 · 玄甲戟卫", banner = "banner_51", faction = "地方藩镇", wxRoles = ["garrison_general", "hammer_adept", "axe_vanguard", "escort", "shenji_musketeer"], story = "地方节度使帐下披甲亲卫，重戟破阵、火铳压阵，尽显边军铁血杀伐气象。" },
		{ sectId = "emei_delegation",name = "峨眉金顶 · 玄衣剑侍", banner = "banner_52", faction = "名门剑宗", wxRoles = ["emei_sword", "emei_sword", "emei_sword", "disciple", "disciple"], story = "巴蜀金顶女剑客结剑阵登台，剑走轻灵专封穴道，身法飘逸若惊鸿。" },
		{ sectId = "mobei_wolves",   name = "漠北王庭 · 苍狼刀卫", banner = "banner_62", faction = "塞外王庭", wxRoles = ["mobei_centurion", "mobei_centurion", "axe_vanguard", "dartist", "escort"], story = "塞北草原百夫长携弯刀勇士南下论武，咆哮冲阵凶猛绝伦。" },
		{ sectId = "mingzun_flame",  name = "西域光明顶 · 圣火使", banner = "banner_56", faction = "西域奇宗", wxRoles = ["mingzun_fawang", "monk_fighter", "whip_stalker", "shadow_dagger", "dartist"], story = "西域拜火法王携护教武士东来赴会，掌风炽烈诡奇，招路迥异中原。" }
	];
	this.shuffleArray(extras);
	foreach (ex in extras)
	{
		out.push({
			sectId  = ex.sectId,
			player  = false,
			name    = ex.name,
			banner  = ex.banner,
			faction = ex.faction,
			unit    = "人",
			count   = 5,
			solo    = false,
			human   = true,
			wxRoles = clone ex.wxRoles,
			power   = 1.0,
			story   = ex.story
		});
	}
	return out;
};

T.buildGuestEntries <- function( _count, _usedNames, _size )
{
	local cfg = ::Wuxia.Config.Gambling;
	local deck = [];
	local entries = [];
	local soloCnt = 0;
	local soloCap = _size / 8;
	local prefixes = this.shuffleArray(clone cfg.GuestPrefixes);

	while (entries.len() < _count)
	{
		if (deck.len() == 0)
		{
			foreach (gt in cfg.ExoticGuests)
			{
				if (!gt.solo || soloCnt < soloCap) deck.push(gt);
			}
			this.shuffleArray(deck);
		}
		local gt = deck.pop();
		if (gt.solo && soloCnt >= soloCap) continue;

		local fullName = "";
		for (local i = 0; i < prefixes.len(); i = ++i)
		{
			local cand = prefixes[(i + entries.len()) % prefixes.len()] + " · " + gt.title;
			if (!(cand in _usedNames)) { fullName = cand; break; }
		}
		if (fullName == "") continue;

		_usedNames.rawset(fullName, true);
		if (gt.solo) soloCnt += 1;
		entries.push({
			sectId  = "",
			player  = false,
			name    = fullName,
			entry   = gt.id,
			banner  = "",
			faction = gt.faction,
			unit    = gt.unit,
			count   = gt.troops.len(),
			solo    = gt.solo,
			story   = gt.story,
			human   = gt.human,
			troops  = clone gt.troops,
			power   = 1.0
		});
	}
	return entries;
};

T.computeTeamPower <- function( _team )
{
	local total = 0.0;
	foreach (actor in this.getTeamRoster(_team).getAll())
	{
		local p = actor.getCurrentProperties();
		local martialMult = 1.0;
		local c = actor.getSkills().getSkillByID("special.wx_martial_container");
		if (c != null)
		{
			foreach (s in c.m.Slots)
			{
				if (s.ManualID != null && s.Tier > 0)
					martialMult += (0.04 * s.Tier);
			}
			martialMult += (0.10 * c.getPermanentAPBonus());
		}
		local unitPwr = G.max(1, (p.Hitpoints + p.Armor[0] * 0.25 + p.Armor[1] * 0.25)
			* (G.max(p.MeleeSkill, p.RangedSkill) + p.MeleeDefense + 30)
			* (p.DamageRegularMin + p.DamageRegularMax + 30)) * martialMult;
		total += unitPwr;
	}
	_team.power = total;
};

T.buildBracketTree <- function( _ev )
{
	if (_ev.phase != "registration" || _ev.teams.len() != _ev.size) return false;
	local previous = [];
	local count = _ev.size / 2;
	local round = 0;
	while (count > 0)
	{
		local current = [];
		for (local n = 0; n < count; n = ++n)
		{
			local m = {
				id        = _ev.matches.len() + 1,
				round     = round,
				index     = n,
				left      = (round == 0) ? (n * 2 + 1) : 0,
				right     = (round == 0) ? (n * 2 + 2) : 0,
				fromLeft  = (round == 0) ? 0 : previous[n * 2],
				fromRight = (round == 0) ? 0 : previous[n * 2 + 1],
				status    = (round == 0) ? "open" : "waiting",
				winner    = 0,
				oddsLeft  = 0,
				oddsRight = 0
			};
			_ev.matches.push(m);
			current.push(m.id);
		}
		previous = current;
		count /= 2;
		round += 1;
	}
	_ev.phase = "open";
	_ev.round = 0;
	this.addNotice(_ev, "《" + _ev.title + "》抽签已定，" + _ev.size + " 路人马尽数挂牌！【" + this.roundName(_ev, 0) + "】外围红盘现已开盘收银！");
	G.touch();
	return true;
};

T.lockMatchOdds <- function( _ev, _m )
{
	if (_m.oddsLeft > 0 || _m.oddsRight > 0 || _m.left == 0 || _m.right == 0) return;
	foreach (ticket in _ev.tickets)
	{
		foreach (leg in ticket.legs)
		{
			if (leg.match == _m.id) return;
		}
	}
	local pa = this.findTeam(_ev, _m.left).power;
	local pb = this.findTeam(_ev, _m.right).power;
	local prob = G.clamp(pa / (pa + pb + 0.0001), 0.15, 0.85);
	_m.oddsLeft = G.floor(92.0 / prob);
	_m.oddsRight = G.floor(92.0 / (1.0 - prob));
};

T.getEntryFee <- function( _size )
{
	return (_size == 64) ? 800 : 300;
};

T.registerSquad <- function( _ev, _broIds )
{
	if (!this.atEventVenue(_ev) || _ev.phase != "registration")
		return G.result(false, "英雄帖已封册，或你尚未亲临主办州府。");
	local hasAssets = ("World" in getroottable() && ::World != null && ("Assets" in ::World) && ::World.Assets != null);
	local bizRep = (hasAssets && ::Wuxia.hasMember(::World.Assets, "getBusinessReputation"))
		? ::World.Assets.getBusinessReputation()
		: 0;
	if (_ev.size == 64 && hasAssets && ::Wuxia.hasMember(::World.Assets, "getBusinessReputation") && bizRep < 750)
		return G.result(false, "天下武林大会（64强）须江湖威名达 750 以上方可递交英雄帖（当前：" + bizRep + "）。");
	local entryFee = this.getEntryFee(_ev.size);
	if (G.wallet() < entryFee)
		return G.result(false, "递帖登台需备齐投名彩礼 " + entryFee + " 两纹银（封签开赛时划扣）。");
	if (typeof _broIds != "array" || _broIds.len() != 5)
		return G.result(false, "请从麾下名册中点选整整 5 位登台侠客。");

	local found = [];
	local seen = {};
	foreach (id in _broIds)
	{
		if (!G.whole(id, 1, 2147483000) || (id.tostring() in seen))
			return G.result(false, "登台五人名录不可重复。");
		foreach (bro in ::World.getPlayerRoster().getAll())
		{
			if (bro != null && bro.getID() == id && bro.isAlive()) found.push(id);
		}
		seen.rawset(id.tostring(), true);
	}
	if (found.len() != 5)
		return G.result(false, "所选侠客中有人已不在队内，请重新点将。");

	_ev.selected = found;
	G.touch();
	return G.result(true, "知客执事郑重录下五位侠客名号！封签开赛时将划扣投名彩礼 " + entryFee + " 两纹银并拓印五人当下功法与兵甲入册；演武点到为止，绝不伤及场外真身与甲胄耐久。");
};

T.sealBracket <- function( _ev )
{
	if (!this.atEventVenue(_ev) || _ev.phase != "registration")
		return G.result(false, "本届签表已定，或你不在主办城池。");

	local chosenBros = [];
	local pendingFee = 0;
	if (_ev.selected.len() > 0)
	{
		local entryFee = this.getEntryFee(_ev.size);
		if (G.wallet() < entryFee)
			return G.result(false, "行囊现银不足以缴付本届登台投名彩礼（需 " + entryFee + " 两纹银）。");
		foreach (id in _ev.selected)
		{
			foreach (bro in ::World.getPlayerRoster().getAll())
			{
				if (bro != null && bro.getID() == id && bro.isAlive())
					chosenBros.push(bro);
			}
		}
		if (chosenBros.len() != 5)
			return G.result(false, "已报名的五位同袍人数有变，请重递五人名册或撤回报名后再封签。");
		pendingFee = entryFee;
	}

	local teams = [];
	local usedNames = {};

	if (chosenBros.len() == 5)
	{
		local compName = ::World.Assets.getName();
		usedNames.rawset(compName, true);
		teams.push({
			sectId  = "",
			player  = true,
			name    = compName,
			banner  = "banner_" + ::World.Assets.getBannerID(),
			faction = "本方义社",
			unit    = "人",
			count   = 5,
			solo    = false,
			human   = true,
			power   = 1.0,
			story   = "你亲点麾下五名得力同袍披挂本命兵甲、运起护体真气联袂登台，誓夺本届武林桂冠！"
		});
	}

	local sectPool = this.buildSectCandidatePool();
	local sectTarget = G.min(sectPool.len(), _ev.size - teams.len() - (_ev.size / 4));
	for (local i = 0; i < sectTarget; i = ++i)
	{
		local sc = sectPool[i];
		usedNames.rawset(sc.name, true);
		teams.push(sc);
	}

	local guestNeeded = _ev.size - teams.len();
	if (guestNeeded > 0)
		teams.extend(this.buildGuestEntries(guestNeeded, usedNames, _ev.size));

	this.shuffleArray(teams);
	foreach (idx, team in teams)
	{
		team.rawset("id", idx + 1);
		team.rawset("roster", this.rosterID(_ev, team));
	}

	local allocated = [];
	local self = this;
	try
	{
		foreach (team in teams)
		{
			::World.createRoster(team.roster);
			allocated.push(team.roster);
			local roster = this.getTeamRoster(team);

			this.withMemberContext(function()
			{
				if (team.player)
				{
					foreach (srcBro in chosenBros)
					{
						local cp = roster.create(::IO.scriptFilenameByHash(srcBro.ClassNameHash));
						self.copyActorToTournament(srcBro, cp);
					}
				}
				else if ("wxRoles" in team)
				{
					foreach (rIdx, roleKey in team.wxRoles)
					{
						local actor = roster.create("scripts/entity/tactical/enemies/wx_" + roleKey);
						actor.getFlags().set("WX_ArenaPackSize", team.count);
						actor.assignRandomEquipment();
						actor.getSkills().update();
						local baseTitle = (roleKey in ::Wuxia.Config.Fighters) ? ::Wuxia.Config.Fighters[roleKey].Name : actor.getNameOnly();
						actor.setName(self.pickWuxiaFighterName(baseTitle, team.sectId, roster, rIdx));
						actor.getFlags().set("WX_ArenaCopy", true);
						self.rememberAppearance(actor);
					}
				}
				else
				{
					foreach (gIdx, sp in team.troops)
					{
						local actor = roster.create("scripts/entity/tactical/" + sp);
						actor.getFlags().set("WX_ArenaPackSize", team.count);
						actor.assignRandomEquipment();
						actor.getSkills().update();
						self.nameExoticGuest(actor, team, gIdx, roster);
						actor.getFlags().set("WX_ArenaCopy", true);
						self.rememberAppearance(actor);
					}
				}
			});

			this.computeTeamPower(team);
		}
	}
	catch (err)
	{
		foreach (rid in allocated)
		{
			try { ::World.deleteRoster(rid); } catch (_e) {}
		}
		::logWarning("[mod_wuxia] Tournament roster build aborted (fee preserved): " + err);
		throw err;
	}

	_ev.teams = teams;
	_ev.player = 0;
	foreach (team in teams)
	{
		if (team.player) _ev.player = team.id;
	}
	this.buildBracketTree(_ev);
	foreach (m in _ev.matches)
	{
		if (m.round == 0) this.lockMatchOdds(_ev, m);
	}
	if (pendingFee > 0)
		G.money(-pendingFee);
	G.playSound("ledger");
	G.touch();
	return G.result(true, "演武金锣一响，英雄签表已高悬门楼！可逐场审阅双方武学兵甲、购买单场或连环银票，随时入场观战！");
};

// -----------------------------------------------------------------------------
// 3. Silver Betting Tickets (`外围红盘单注 & 六场连环串票`) & Match Reports
// -----------------------------------------------------------------------------
T.placeTicket <- function( _ev, _picks, _stake )
{
	if (!this.atEventVenue(_ev))
		return G.result(false, "须亲临本届大会主办州府的演武柜台，大庄家方肯收银开票。");
	if (_ev.phase != "open" || typeof _picks != "array" || _picks.len() < 1 || _picks.len() > 6
		|| !G.whole(_stake, 10, 5000) || _ev.tickets.len() >= 200)
	{
		return G.result(false, "每张红盘银票限押 10 ~ 5,000 两纹银，同轮最多串押 6 场对阵。");
	}

	local seen = {};
	local legs = [];
	local multiplier = 1.0;

	foreach (pick in _picks)
	{
		if (typeof pick != "array" || pick.len() != 2)
			return G.result(false, "银票所填场次有误，请重选。");
		local m = this.findMatch(_ev, pick[0]);
		if (m == null || m.status != "open" || m.round != _ev.round
			|| (pick[1] != m.left && pick[1] != m.right) || (m.id.tostring() in seen))
		{
			return G.result(false, "所选场次已封盘或重复串入，请核对签表。");
		}
		if ((m.left == _ev.player || m.right == _ev.player) && pick[1] != _ev.player)
			return G.result(false, "庄家按住银箱正色道：「自家义社登台比武，只准买自家得胜，断不收买败假拳之注！」");

		this.lockMatchOdds(_ev, m);
		if (!G.whole(m.oddsLeft, 100, 1000000) || !G.whole(m.oddsRight, 100, 1000000))
			return G.result(false, "该场红盘赔率尚未落定，暂缓收注。");

		local odds = (pick[1] == m.left) ? m.oddsLeft : m.oddsRight;
		multiplier *= (odds / 100.0);
		legs.push({ match = m.id, team = pick[1], odds = odds });
		seen.rawset(m.id.tostring(), true);
	}

	if (multiplier * _stake > 1000000)
		return G.result(false, "此张连环银票赔付总额逾百万两，庄家银库接不下，请略减本金或少串一场。");
	if (G.wallet() < _stake)
		return G.result(false, "行囊现银不足以买下此张银票。");

	local stake = _stake.tointeger();
	local ticket = {
		id      = _ev.nextTicket++,
		round   = _ev.round,
		stake   = stake,
		legs    = legs,
		paid    = false,
		receipt = 0
	};
	_ev.tickets.push(ticket);
	G.money(-stake);
	G.State.metrics.tourneyBet += stake;
	G.playSound("stake");
	G.touch();
	return G.result(true, "外围大庄家收下 " + stake + " 两纹银，朱笔签发第 " + ticket.id + " 号盖印红盘银票（票面赔率已封锁，兑付含本金）！");
};

T.ticketValue <- function( _ev, _ticket )
{
	local multiplier = 1.0;
	local waiting = false;
	local lost = false;
	local valid = 0;
	foreach (leg in _ticket.legs)
	{
		local m = this.findMatch(_ev, leg.match);
		if (m == null || m.status == "void") continue;
		if (m.status != "done") { waiting = true; continue; }
		valid += 1;
		if (m.winner != leg.team) lost = true;
		multiplier *= (leg.odds / 100.0);
	}
	if (lost) return { status = "lost", amount = 0 };
	if (waiting) return { status = "waiting", amount = 0 };
	return {
		status = (valid == 0 ? "void" : "won"),
		amount = (valid == 0 ? _ticket.stake : G.floor(_ticket.stake * multiplier))
	};
};

T.claimTicket <- function( _ev, _ticketId )
{
	if (!this.atEventVenue(_ev))
		return G.result(false, "兑付红盘银票须亲赴主办州府演武柜台。");
	foreach (ticket in _ev.tickets)
	{
		if (ticket.id == _ticketId)
		{
			if (ticket.paid)
				return G.result(false, "此张银票早已朱笔勾销兑清。");
			local val = this.ticketValue(_ev, ticket);
			if (val.status == "waiting")
				return G.result(false, "银票所押场次尚未比完，请待胜负落定再来兑银。");
			ticket.paid = true;
			ticket.receipt = val.amount;
			G.money(val.amount);
			if (val.amount > 0)
			{
				G.State.metrics.tourneyWon += val.amount;
				G.playSound("win");
			}
			else
			{
				G.playSound("ledger");
			}
			G.touch();
			local cMsg = val.amount > 0
				? ("大庄家核验红印无误，当场点出 " + val.amount + " 两足色纹银（含本金）奉还！")
				: "此票未能押中胜方，庄家在票角划下墨叉留档。";
			local outRes = G.result(true, cMsg);
			if (val.amount > 0)
			{
				outRes.wxShowcase <- {
					kind     = "tourney_payout",
					outcome  = val.amount >= 1000 ? "crit" : "great",
					title    = "朱印验票 · 银两落袋",
					subtitle = _ev.title + " · 演武红盘兑付",
					amount   = val.amount,
					message  = cMsg
				};
			}
			return outRes;
		}
	}
	return G.result(false, "账册上未查得该号银票。");
};

T.matchInterest <- function( _ev, _matchId )
{
	local tickets = 0;
	local coins = 0;
	foreach (ticket in _ev.tickets)
	{
		foreach (i, leg in ticket.legs)
		{
			if (leg.match == _matchId)
			{
				tickets += 1;
				coins += (ticket.stake / ticket.legs.len()) + (i < (ticket.stake % ticket.legs.len()) ? 1 : 0);
				break;
			}
		}
	}
	local heat = (tickets >= 6 && coins >= 1500) ? 2 : ((tickets >= 2 || coins >= 500) ? 1 : 0);
	return { tickets = tickets, coins = coins, heat = heat };
};

T.newTrace <- function( _left, _right )
{
	return {
		initialLeft  = _left,
		initialRight = _right,
		left         = _left,
		right        = _right,
		rounds       = 0,
		worstLeft    = { own = _left, enemy = _right },
		worstRight   = { own = _right, enemy = _left },
		armed        = false
	};
};

T.traceCounts <- function( _trace, _left, _right, _round )
{
	_trace.left = _left;
	_trace.right = _right;
	_trace.rounds = G.max(_trace.rounds, _round);
	local pairs = [
		{ key = "worstLeft",  own = _left,  enemy = _right, initial = _trace.initialLeft,  other = _trace.initialRight },
		{ key = "worstRight", own = _right, enemy = _left,  initial = _trace.initialRight, other = _trace.initialLeft }
	];
	foreach (v in pairs)
	{
		local prev = _trace[v.key];
		if (v.own > 0 && v.enemy > 0 && ((v.own.tofloat() / v.initial) - (v.enemy.tofloat() / v.other))
			< ((prev.own.tofloat() / v.initial) - (prev.enemy.tofloat() / v.other)))
		{
			_trace[v.key] = { own = v.own, enemy = v.enemy };
		}
	}
};

T.trackCombat <- function()
{
	local ctx = this.arenaContext();
	if (ctx == null || !("trace" in ctx)) return;
	local leftCnt = ::Tactical.Entities.getInstancesOfFaction(::Const.Faction.Player).len();
	local rightCnt = ::Tactical.Entities.getHostilesNum();
	if (leftCnt > ctx.trace.initialLeft || rightCnt > ctx.trace.initialRight) return;
	if (!ctx.trace.armed)
	{
		if (leftCnt != ctx.trace.initialLeft || rightCnt != ctx.trace.initialRight) return;
		ctx.trace.armed = true;
	}
	this.traceCounts(ctx.trace, leftCnt, rightCnt, ::Time.getRound());
};

T.buildMatchReport <- function( _ev, _m, _winner, _evidence = null )
{
	local win = this.findTeam(_ev, _winner);
	local lose = this.findTeam(_ev, _winner == _m.left ? _m.right : _m.left);
	local interest = this.matchInterest(_ev, _m.id);
	local winOdds = (_winner == _m.left) ? _m.oddsLeft : _m.oddsRight;
	local loseOdds = (_winner == _m.left) ? _m.oddsRight : _m.oddsLeft;
	local upset = (winOdds >= 240 && winOdds >= loseOdds * 1.45);
	local comeback = false;
	local huge = false;
	local deficit = null;

	if (_evidence != null)
	{
		local isLeft = (_winner == ("leftTeam" in _evidence ? _evidence.leftTeam : _m.left));
		local own = isLeft ? _evidence.initialLeft : _evidence.initialRight;
		local other = isLeft ? _evidence.initialRight : _evidence.initialLeft;
		deficit = isLeft ? _evidence.worstLeft : _evidence.worstRight;
		comeback = (own >= 3 && deficit.own > 0 && (deficit.own.tofloat() / own) <= 0.4 && (deficit.enemy.tofloat() / other) >= 0.6);
		huge = (comeback && deficit.own == 1 && deficit.enemy >= 3);
	}

	local isFinal = (_m.id == _ev.matches.len());
	local title = huge ? "孤身逆天翻盘" : (comeback ? "绝境反败为胜" : (upset ? "黑马爆冷破局" : "金锣报捷"));
	local text = "《" + _ev.title + "》" + this.roundName(_ev, _m.round) + "：【" + win.name + "】力挫【" + lose.name + "】"
		+ (isFinal ? "，荣耀登顶夺得桂冠！" : "，昂首晋级下一轮！");
	if (interest.tickets > 0)
		text += " 外围银庄共有 " + interest.tickets + " 张银票押在此局（涉资 " + interest.coins + " 两纹银）。";
	if (upset)
		text += " 赛前红盘原本看低【" + win.name + "】，谁料台上奇招迭出爆出大冷门，押冷门者赚得盆满钵满！";
	if (comeback)
	{
		text += " 【" + win.name + "】一度仅剩 " + deficit.own + " 人苦撑敌方 " + deficit.enemy + " 人围攻，"
			+ (huge ? "竟凭绝世武学以一敌众逆转乾坤，满场豪客拍烂栏杆喝彩！" : "终凭深厚内息稳住阵脚反败为胜！");
	}
	if (_evidence != null)
		text += " 双方激斗 " + _evidence.rounds + " 合，监擂长老鸣锣收兵，两家皆未伤及性命。";

	return {
		title    = title,
		text     = text,
		upset    = upset,
		comeback = comeback,
		huge     = huge,
		interest = interest,
		rounds   = _evidence == null ? null : _evidence.rounds
	};
};

T.finishMatch <- function( _ev, _m, _winner, _evidence = null )
{
	if (_m == null || _m.status != "running" || (_winner != _m.left && _winner != _m.right))
		return false;
	_m.winner = _winner;
	_m.status = "done";
	local isFinal = (_m.id == _ev.matches.len());
	local report = this.buildMatchReport(_ev, _m, _winner, _evidence);
	_m.rawset("report", report);
	_m.rawset("reportDay", G.day());
	this.addNotice(_ev, report.text);

	if (isFinal)
	{
		_ev.phase = "finished";
		_ev.champion = _winner;
		_ev.finishedDay = G.day();

		// Award Championship Purse if the player's own registered 5-hero squad won the tournament!
		local winTeam = this.findTeam(_ev, _winner);
		if (winTeam != null && winTeam.player && !("purseAwarded" in _ev && _ev.purseAwarded))
		{
			_ev.purseAwarded = true;
			local prizeSilver = (_ev.size == 64) ? 3600 : 1200;
			local repGain = (_ev.size == 64) ? 180 : 60;
			G.money(prizeSilver);
			if (::World.Assets != null) ::World.Assets.addBusinessReputation(repGain);
			if (_ev.size == 64 && "SectRelations" in ::Wuxia)
			{
				local champCnt = (::World.Flags != null && ::World.Flags.has("wx_grand_champ_count")) ? ::World.Flags.getAsInt("wx_grand_champ_count") : 0;
				local sectGain = (champCnt < 2) ? 8 : 2;
				if (::World.Flags != null) ::World.Flags.set("wx_grand_champ_count", champCnt + 1);
				foreach (sid, sdef in ::Wuxia.Config.Sects)
				{
					if (sdef.Alignment == "righteous")
						::Wuxia.SectRelations.addRelation(sid, sectGain);
				}
			}
			local prizeNote = "【义社夺魁彩头】恭喜麾下五虎荣膺第 " + _ev.edition + " 届《" + _ev.title + "》总魁首！大会盟主当场奉上彩头纹银 " + prizeSilver + " 两，江湖威名 +" + repGain + (_ev.size == 64 ? "，正道诸派钦佩交情齐升！" : "！");
			this.addNotice(_ev, prizeNote);
			_ev.rawset("championBannerMsg", prizeNote);
		}
	}
	else
	{
		local roundComplete = true;
		foreach (other in _ev.matches)
		{
			if (other.round == _ev.round && other.status != "done")
				roundComplete = false;
		}
		if (roundComplete)
		{
			_ev.round += 1;
			foreach (nxt in _ev.matches)
			{
				if (nxt.round == _ev.round)
				{
					nxt.left = this.findMatch(_ev, nxt.fromLeft).winner;
					nxt.right = this.findMatch(_ev, nxt.fromRight).winner;
					nxt.status = "open";
					this.lockMatchOdds(_ev, nxt);
				}
			}
			this.addNotice(_ev, "《" + _ev.title + "》【" + this.roundName(_ev, _ev.round) + "】晋级签牌已高悬，新一轮外围红盘开盘收注！");
		}
	}
	G.touch();
	return true;
};

// -----------------------------------------------------------------------------
// 4. Non-Lethal Tactical Execution, Arena AI & Spectating Speed Controls
// -----------------------------------------------------------------------------
T.arenaContext <- function() { return G.Runtime.arenaCombat; };
T.arenaActive <- function() { return this.arenaContext() != null && ("Tactical" in getroottable()) && ("isActive" in ::Tactical) && ::Tactical.isActive(); };

T.arenaKnockout <- function( _actor, _killer, _skill )
{
	if (!_actor.m.IsAlive || _actor.getFlags().get("WX_ArenaOut")) return;
	_actor.getFlags().set("WX_ArenaOut", true);
	_actor.m.IsTurnDone = true;
	_actor.m.IsAlive = false;
	_actor.m.IsDying = true;
	::Tactical.EventLog.logEx(_actor.getName() + " 气力不支败下阵来，监擂长老飞身掠入场中将其扶出擂台（点到为止）。");
	if (_killer != null && _killer.isAlive())
		_killer.getSkills().onTargetKilled(_actor, _skill);
	_actor.removeFromMap();
	this.trackCombat();
	local leftAlive = ::Tactical.Entities.getInstancesOfFaction(::Const.Faction.Player).len();
	::Tactical.Entities.setLastCombatResult(leftAlive == 0
		? ::Const.Tactical.CombatResult.PlayerDestroyed
		: ::Const.Tactical.CombatResult.EnemyDestroyed);
};

// --- Tactical Competitor AI (Left-Side Player-Faction AI + Ranged Coroutine Guard) ---
T.aiEnabled <- function( _actor )
{
	local ctx = this.arenaContext();
	return ctx != null && !ctx.ended && _actor != null && _actor.getFlags().has("WX_ArenaCopy") && !_actor.isPlayerControlled();
};

T.aiLiving <- function( _actor )
{
	if (_actor != null && ("isNull" in _actor) && _actor.isNull()) return false;
	return _actor != null && _actor.isAlive() && !_actor.isDying() && _actor.isPlacedOnMap();
};

T.aiClearRangedTargets <- function( _behavior )
{
	_behavior.m.ValidTargets = [];
	_behavior.m.PotentialDanger = [];
	_behavior.m.CurrentDanger = 0.0;
	_behavior.m.TargetTile = null;
	_behavior.m.TargetScore = 0.0;
};

T.aiRangedCacheValid <- function( _behavior, _actor )
{
	if (!this.aiLiving(_actor)) return false;
	foreach (t in _behavior.m.ValidTargets) if (!this.aiLiving(t.Actor)) return false;
	foreach (d in _behavior.m.PotentialDanger) if (!this.aiLiving(d)) return false;
	return true;
};

T.aiRangedCompileTargets <- function( _entity, _targets, _maxRange )
{
	// Generator coroutine guarding knocked-out competitors removed mid-frame
	this.m.ValidTargets = [];
	this.m.PotentialDanger = [];
	this.m.CurrentDanger = 0.0;
	if (!::Wuxia.Tournament.aiLiving(_entity)) return false;
	local myTile = _entity.getTile();
	local startTime = this.Time.getExactTime();

	foreach (target in _targets)
	{
		if (!::Wuxia.Tournament.aiLiving(target.Actor)) continue;
		if (this.isAllottedTimeReached(startTime))
		{
			yield null;
			startTime = this.Time.getExactTime();
			if (!::Wuxia.Tournament.aiLiving(_entity))
			{
				::Wuxia.Tournament.aiClearRangedTargets(this);
				return false;
			}
			if (!::Wuxia.Tournament.aiLiving(target.Actor)) continue;
		}

		local targetTile = target.Actor.getTile();
		local realDist = myTile.getDistanceTo(targetTile);

		if (realDist <= this.Const.AI.Behavior.RangedEngageMaxDangerDist
			&& target.Actor.getMoraleState() != this.Const.MoraleState.Fleeing
			&& !this.isRangedUnit(target.Actor)
			&& !target.Actor.isNonCombatant()
			&& (target.Actor.getHitpoints() / target.Actor.getHitpointsMax()) >= this.Const.AI.Behavior.RangedEngageMinDangerHitpointsPct
			&& targetTile.getZoneOfControlCountOtherThan(target.Actor.getAlliedFactions()) < this.Const.AI.Behavior.RangedEngageIgnoreDangerMinZones)
		{
			this.m.PotentialDanger.push(target.Actor);
			this.m.CurrentDanger += this.getDangerFromActor(target.Actor, myTile, _entity);
		}

		local alliesAdjacent = 0;
		local opponentsAdjacent = 0;
		local score = this.queryTargetValue(_entity, target.Actor, null);

		for (local i = 0; i < this.Const.Direction.COUNT; i = ++i)
		{
			if (!targetTile.hasNextTile(i)) continue;
			local adjTile = targetTile.getNextTile(i);
			if (!adjTile.IsEmpty && adjTile.IsOccupiedByActor)
			{
				if (adjTile.getEntity().isAlliedWith(_entity))
				{
					if (this.getProperties().TargetPriorityHittingAlliesMult < 1.0)
						score -= (1.0 / 6.0) * (1.0 - this.getProperties().TargetPriorityHittingAlliesMult) * adjTile.getEntity().getCurrentProperties().TargetAttractionMult;
					alliesAdjacent = ++alliesAdjacent;
				}
				else
				{
					score += (1.0 / 6.0) * this.queryTargetValue(_entity, adjTile.getEntity(), null) * this.Const.AI.Behavior.AttackRangedHitBystandersMult;
					opponentsAdjacent = ++opponentsAdjacent;
				}
			}
		}

		if (targetTile.getZoneOfControlCount(_entity.getFaction()) < this.Const.AI.Behavior.RangedEngageIgnoreDangerMinZones)
		{
			score *= (1.0 + (1.0 - this.Math.minf(1.0, this.queryActorTurnsNearTarget(target.Actor, myTile, _entity).Turns)) * this.Const.AI.Behavior.AttackDangerMult);
		}

		this.m.ValidTargets.push({
			Actor             = target.Actor,
			Tile              = targetTile,
			Distance          = realDist,
			IsRangedUnit      = this.isRangedUnit(target.Actor),
			Score             = this.Math.maxf(0.01, score),
			OpponentsAdjacent = opponentsAdjacent,
			AlliesAdjacent    = alliesAdjacent
		});
	}
	return true;
};

T.aiRangedSelect <- function( _origFn, _entity, _maxRange, _considerLoF, _visibleNeeded )
{
	local gen = null;
	while (true)
	{
		if (!::Wuxia.Tournament.aiRangedCacheValid(this, _entity))
		{
			::Wuxia.Tournament.aiClearRangedTargets(this);
			return false;
		}
		if (gen == null) gen = _origFn.bindenv(this)(_entity, _maxRange, _considerLoF, _visibleNeeded);
		local val = resume gen;
		if (!::Wuxia.Tournament.aiRangedCacheValid(this, _entity))
		{
			::Wuxia.Tournament.aiClearRangedTargets(this);
			return false;
		}
		if (gen.getstatus() == "dead") return val;
		yield val;
	}
};

T.installRangedAI <- function( _actor )
{
	if (!_actor.getFlags().has("WX_ArenaCopy") || _actor.isPlayerControlled()) return;
	local behavior = _actor.getAIAgent().getBehavior(::Const.AI.Behavior.ID.EngageRanged);
	if (behavior == null) return;
	local origCompile = behavior.compileTargets;
	local origSelect = behavior.selectBestTargetTile;
	behavior.compileTargets = function( _ent, _targets, _maxR )
	{
		return ::Wuxia.Tournament.aiEnabled(_ent)
			? ::Wuxia.Tournament.aiRangedCompileTargets.bindenv(this)(_ent, _targets, _maxR)
			: origCompile.bindenv(this)(_ent, _targets, _maxR);
	};
	behavior.selectBestTargetTile = function( _ent, _maxR, _lof, _vis )
	{
		return ::Wuxia.Tournament.aiEnabled(_ent)
			? ::Wuxia.Tournament.aiRangedSelect.bindenv(this)(origSelect, _ent, _maxR, _lof, _vis)
			: origSelect.bindenv(this)(_ent, _maxR, _lof, _vis);
	};
};

T.aiRole <- function( _actor )
{
	local w = _actor.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
	if (w != null && w.isItemType(::Const.Items.ItemType.Weapon))
	{
		if (w.isItemType(::Const.Items.ItemType.RangedWeapon)) return "ranged";
		if (w.getRangeIdeal() > 1) return "reach";
	}
	return _actor.isArmedWithShield() ? "shield" : "melee";
};

T.aiAllies <- function( _actor, _factions )
{
	local allies = [];
	foreach (fac in _factions)
	{
		foreach (other in fac)
		{
			if (this.aiLiving(other) && _actor.isAlliedWith(other))
				allies.push(other);
		}
	}
	return allies;
};

T.aiGuard <- function( _actor, _allies, _opponents )
{
	if (!_actor.isArmedWithShield() || _actor.getHitpoints() <= _actor.getHitpointsMax() * 0.5) return false;
	foreach (vip in _allies)
	{
		if (!this.aiLiving(vip) || vip.getID() == _actor.getID() || this.aiRole(vip) != "ranged"
			|| vip.getCurrentProperties().TargetAttractionMult <= 1.0
			|| vip.getAIAgent().getBehavior(::Const.AI.Behavior.ID.Protect) != null) continue;
		local dist = _actor.getTile().getDistanceTo(vip.getTile());
		if (dist > 2) continue;
		local threatened = false;
		foreach (opp in _opponents)
		{
			if (this.aiLiving(opp.Actor) && opp.Actor.getTile().getDistanceTo(vip.getTile()) <= 5)
			{
				threatened = true;
				break;
			}
		}
		if (!threatened) continue;
		local best = _actor;
		local bestD = dist;
		foreach (other in _allies)
		{
			if (!this.aiLiving(other) || !other.isArmedWithShield() || other.getHitpoints() <= other.getHitpointsMax() * 0.5
				|| other.getAIAgent().getBehavior(::Const.AI.Behavior.ID.Protect) == null) continue;
			local d = other.getTile().getDistanceTo(vip.getTile());
			if (d < bestD || (d == bestD && other.getID() < best.getID())) { best = other; bestD = d; }
		}
		if (best.getID() == _actor.getID()) return true;
	}
	return false;
};

T.aiFocus <- function( _actor, _target, _allies )
{
	if (!this.aiLiving(_target) || _actor.isAlliedWith(_target)) return 1.0;
	local engaged = 0;
	local rescue = false;
	foreach (ally in _allies)
	{
		if (!this.aiLiving(ally) || ally.getID() == _actor.getID() || ally.getTile().getDistanceTo(_target.getTile()) != 1)
			continue;
		if (ally.getMoraleState() != ::Const.MoraleState.Fleeing && !ally.getCurrentProperties().IsStunned)
			engaged += 1;
		if (ally.getHitpoints() <= ally.getHitpointsMax() * 0.4 || this.aiRole(ally) == "ranged")
			rescue = true;
	}
	return 1.0 + G.min(2, engaged) * 0.08 + (rescue ? 0.12 : 0.0);
};

T.aiUpdate <- function( _agent )
{
	local actor = _agent.getActor();
	if (!this.aiEnabled(actor) || !::isKindOf(actor, "human")) return;
	local p = _agent.getProperties();
	local role = this.aiRole(actor);
	local ids = ::Const.AI.Behavior.ID;
	local wounded = (actor.getHitpoints() <= actor.getHitpointsMax() * 0.4);
	p.TargetPriorityFinishTreshhold = 1.0;
	p.TargetPriorityHittingAlliesMult = 0.0;
	p.TargetPriorityCounterSkillsMult = 0.35;
	p.EngageTargetAlreadyBeingEngagedMult = (role == "reach") ? 0.1 : 0.25;
	p.OverallFormationMult = (role == "reach") ? 1.65 : 1.25;
	local w = actor.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
	local areaWeapon = (w != null && w.isItemType(::Const.Items.ItemType.Weapon) && w.isAoE());
	p.EngageTargetMultipleOpponentsMult = (wounded || role == "reach" || role == "ranged") ? 1.8 : (areaWeapon ? 0.85 : 1.35);
	if (_agent.getBehavior(ids.Protect) != null)
	{
		local guard = this.aiGuard(actor, _agent.getKnownAllies(), _agent.getKnownOpponents());
		p.BehaviorMult[ids.Protect] = guard ? 1.0 : 0.0;
		p.ProtectFarAway = false;
		if (guard) p.BehaviorMult[ids.SwitchToRanged] = 0.0;
	}
};

T.installArenaAI <- function( _actor )
{
	if (!_actor.getFlags().has("WX_ArenaCopy") || _actor.isPlayerControlled()) return;
	local agent = _actor.getAIAgent();
	if ("WX_ArenaTactics" in agent.m) return;
	agent.m.rawset("WX_ArenaTactics", true);
	agent.m.rawset("WX_ArenaRangedSwitch", agent.getProperties().BehaviorMult[::Const.AI.Behavior.ID.SwitchToRanged]);
	this.installRangedAI(_actor);

	local origCompile = agent.compileKnownAllies;
	local origEval = agent.evaluate;
	local origUpdate = agent.onUpdate;

	agent.compileKnownAllies = function()
	{
		if (!::Wuxia.Tournament.aiEnabled(this.getActor()) || this.getActor().getFaction() != ::Const.Faction.Player)
			return origCompile.bindenv(this)();
		this.m.KnownAllies = ::Wuxia.Tournament.aiAllies(this.getActor(), ::Tactical.Entities.getAllInstances());
	};
	agent.evaluate = function( _ent )
	{
		if (::Wuxia.Tournament.aiEnabled(_ent) && _ent.getFaction() == ::Const.Faction.Player && this.m.NextBehaviorToEvaluate == -2)
		{
			if (this.m.StrategyGenerator == null) this.m.StrategyGenerator = this.getStrategy().update();
			if (!(resume this.m.StrategyGenerator)) return;
			this.m.StrategyGenerator = null;
		}
		return origEval.bindenv(this)(_ent);
	};
	agent.onUpdate = function()
	{
		if (::Wuxia.Tournament.aiEnabled(this.getActor()) && ::isKindOf(this.getActor(), "human"))
			this.getProperties().BehaviorMult[::Const.AI.Behavior.ID.SwitchToRanged] = this.m.WX_ArenaRangedSwitch;
		origUpdate.bindenv(this)();
		::Wuxia.Tournament.aiUpdate(this);
	};
	if (::isKindOf(_actor, "human"))
	{
		foreach (bhv in agent.m.Behaviors)
		{
			local origQuery = bhv.queryTargetValue;
			bhv.queryTargetValue = function( _ent, _tgt, _sk = null )
			{
				local sc = origQuery.bindenv(this)(_ent, _tgt, _sk);
				return ::Wuxia.Tournament.aiEnabled(_ent)
					? (sc * ::Wuxia.Tournament.aiFocus(_ent, _tgt, this.getAgent().getKnownAllies()))
					: sc;
			};
		}
	}
};

T.combatClone <- function( _src, _roster, _isPlayerTeam, _faction, _pos )
{
	local sp = _isPlayerTeam ? "scripts/entity/tactical/wx_tournament_player" : ::IO.scriptFilenameByHash(_src.ClassNameHash);
	local cp = _roster.create(sp);
	this.copyActorToTournament(_src, cp);
	cp.setFaction(_faction);
	if (_isPlayerTeam)
	{
		cp.setPlaceInFormation(_pos);
	}
	else
	{
		cp.getFlags().set("WX_ArenaPosition", _pos);
		cp.getPlaceInFormation <- function() { return this.getFlags().getAsInt("WX_ArenaPosition"); };
		cp.onCombatStart <- function() { ::Wuxia.Tournament.combatBegin(this); };
	}
	cp.getAIAgent().getProperties().BehaviorMult[::Const.AI.Behavior.ID.Retreat] = 0.0;
	return cp;
};

T.combatBegin <- function( _actor )
{
	_actor.getSkills().onCombatStarted();
	_actor.getItems().onCombatStarted();
	_actor.getSkills().update();
	_actor.getAIAgent().getProperties().BehaviorMult[::Const.AI.Behavior.ID.Retreat] = 0.0;
	this.installArenaAI(_actor);
};

T.startMatch <- function( _ev, _matchId, _mode = "watch" )
{
	if (!this.atEventVenue(_ev) || this.arenaContext() != null)
		return G.result(false, "请先回到主办州府演武台，待前一场散场。");
	local m = this.findMatch(_ev, _matchId);
	if (m == null || m.round != _ev.round || (m.status != "open" && m.status != "interrupted"))
		return G.result(false, "该场尚未排定对阵，或已分出高下。");
	if ((_mode != "watch" && _mode != "fast" && _mode != "report") || (_mode != "watch" && (m.left == _ev.player || m.right == _ev.player)))
		return G.result(false, "自家义社登台之战，须由掌门亲自临阵指挥！");

	local arenaFac = ::World.FactionManager.getFactionOfType(::Const.FactionType.Arena);
	if (arenaFac == null) arenaFac = ::World.FactionManager.getFactionOfType(::Const.FactionType.Bandits);
	if (arenaFac == null)
		return G.result(false, "监擂执事尚未就位，暂无法鸣锣开赛。");

	local left = (m.right == _ev.player) ? m.right : m.left;
	local right = (left == m.left) ? m.right : m.left;
	local rosterId = 16999999;
	local allocated = false;
	local self = this;

	try
	{
		try { ::World.deleteRoster(rosterId); } catch (_e) {}
		::World.createRoster(rosterId);
		allocated = true;
		local roster = ::World.getRoster(rosterId);
		local teamA = this.findTeam(_ev, left);
		local teamB = this.findTeam(_ev, right);
		local players = [];

		this.withMemberContext(function()
		{
			local listA = self.getTeamRoster(teamA).getAll();
			foreach (i, src in listA)
			{
				local pos = i + (9 - listA.len()) / 2;
				players.push(self.combatClone(src, roster, teamA.player, ::Const.Faction.Player, pos));
			}
		});

		local venueTown = this.currentVenue();
		local p = ::Const.Tactical.CombatInfo.getClone();
		p.Tile = (venueTown != null && venueTown.getTile() != null)
			? venueTown.getTile()
			: ((::World.State != null && ::World.State.getPlayer() != null) ? ::World.State.getPlayer().getTile() : null);
		p.CombatID = "WuxiaTournament";
		p.LocationTemplate = clone ::Const.Tactical.LocationTemplate;
		p.LocationTemplate.Template = ["tactical.arena_floor"];
		p.TerrainTemplate = "tactical.arena";
		p.Music = ::Const.Music.ArenaTracks;
		p.Ambience[0] = ::Const.SoundAmbience.ArenaBack;
		p.Ambience[1] = ::Const.SoundAmbience.ArenaFront;
		p.AmbienceMinDelay[0] = 0;
		p.PlayerDeploymentType = ::Const.Tactical.DeploymentType.Arena;
		p.EnemyDeploymentType = ::Const.Tactical.DeploymentType.Arena;
		p.IsUsingSetPlayers = true;
		p.Players = players;
		p.IsFleeingProhibited = true;
		p.IsLootingProhibited = true;
		p.IsWithoutAmbience = true;
		p.IsFogOfWarVisible = false;
		p.IsArenaMode = true;
		p.IsAutoAssigningBases = false;
		p.Entities = [];
		p.Parties = [];
		p.TemporaryEnemies = [];

		foreach (src in this.getTeamRoster(teamB).getAll())
		{
			local troop = clone ::Const.World.Spawn.Troops.Mercenary;
			troop.Script = ::IO.scriptFilenameByHash(src.ClassNameHash);
			troop.Faction <- arenaFac.getID();
			troop.rawset("WX_ArenaActor", src.getID());
			troop.rawset("WX_ArenaRoster", teamB.roster);
			p.Entities.push(troop);
		}

		local ctx = {
			event            = _ev.id,
			match            = m.id,
			left             = left,
			right            = right,
			roster           = rosterId,
			ended            = false,
			stats            = this.dataCopy(::World.Statistics.getFlags().m),
			clock            = G.clock(),
			speed            = ::World.State.m.LastWorldSpeedMult,
			watchMode        = _mode,
			playerControlled = teamA.player,
			trace            = this.newTrace(players.len(), p.Entities.len())
		};
		ctx.trace.rawset("leftTeam", left);
		G.Runtime.arenaCombat = ctx;

		if (!("seed" in m)) m.rawset("seed", ::Math.rand());
		::World.State.m.CombatSeed = m.seed;
		m.status = "running";
		G.touch();

		if (::World.State.m.WorldTownScreen != null && ::World.State.m.WorldTownScreen.getMainDialogModule() != null
			&& ::World.State.m.WorldTownScreen.getMainDialogModule().m.JSHandle != null)
		{
			::World.State.m.WorldTownScreen.getMainDialogModule().m.JSHandle.asyncCall("wxTournamentClose", null);
		}
		if (::World.State.m.WorldTownScreen != null)
			::World.State.m.WorldTownScreen.hide();

		::World.State.startScriptedCombat(p, false, false, false);
		return G.result(true, "演武金锣震响！监擂长老立于高台，此战点到为止！");
	}
	catch (err)
	{
		G.Runtime.arenaCombat = null;
		if (allocated) { try { ::World.deleteRoster(rosterId); } catch (_e) {} }
		if (m.status == "running") { m.status = "interrupted"; G.touch(); }
		::logError("[mod_wuxia] Tournament start error: " + err);
		throw err;
	}
};

T.applyOpponentOnSetup <- function( _actor, _troop )
{
	if (!("WX_ArenaActor" in _troop)) return;
	foreach (src in ::World.getRoster(_troop.WX_ArenaRoster).getAll())
	{
		if (src.getID() == _troop.WX_ArenaActor)
		{
			this.copyActorToTournament(src, _actor);
			this.combatBegin(_actor);
			return;
		}
	}
	throw "Tournament opponent missing from registered roster";
};

T.endCombat <- function( _tacticalState )
{
	local ctx = this.arenaContext();
	if (ctx == null || ctx.ended) return;
	local cntA = ::Tactical.Entities.getInstancesOfFaction(::Const.Faction.Player).len();
	local cntB = ::Tactical.Entities.getHostilesNum();
	if (cntA > 0 && cntB > 0) return;

	ctx.ended = true;
	ctx.rawset("winner", cntA > 0 ? ctx.left : (cntB > 0 ? ctx.right : 0));
	this.trackCombat();
	::Time.setVirtualSpeed(1.0);
	_tacticalState.m.IsBattleEnded = true;
	_tacticalState.m.IsAIPaused = true;
	::Tactical.EventLog.logEx("金锣再鸣，胜负已分！监擂长老登台清点两家人数。");
	::Time.scheduleEvent(::TimeUnit.Real, 1800, function( _tag ) { ::Tactical.State.exitTactical(); }, null);
};

T.returnToTown <- function( _worldState )
{
	local ctx = this.arenaContext();
	local ev = this.findEvent(ctx.event);
	local m = this.findMatch(ev, ctx.match);

	::Time.setVirtualTime(ctx.clock);
	_worldState.m.CombatStartTime = 0;
	_worldState.m.CombatSeed = 0;
	::World.Statistics.getFlags().m = ctx.stats;
	try { ::World.deleteRoster(ctx.roster); } catch (_e) {}
	G.Runtime.arenaCombat = null;

	if (ctx.ended && ("winner" in ctx) && ctx.winner != 0)
		this.finishMatch(ev, m, ctx.winner, ctx.trace);
	else if (m != null && m.status == "running")
	{
		m.status = "interrupted";
		G.touch();
	}

	::Stash.setLocked(false);
	::Sound.stopAmbience();
	_worldState.setWorldmapMusic(true);
	_worldState.m.LastWorldSpeedMult = ctx.speed;
	::World.setSpeedMult(ctx.speed);
	_worldState.updateTopbarAssets();
	_worldState.show();
	_worldState.setPause(true);

	G.Runtime.arenaReopen = ev != null ? ev.id : 0;
	G.Runtime.arenaReopenMatch = m != null ? m.id : 0;
};

// --- Spectating Speed Bar (`1x 慢品拆招 / 4x 疾风快进 / 12x 幕后听锣`) ---
T.watchSpeed <- function( _mode ) { return _mode == "fast" ? 4.0 : (_mode == "report" ? 12.0 : 1.0); };

T.watchRequest <- function( _mode )
{
	local ctx = this.arenaContext();
	if (ctx == null || ctx.ended || ctx.playerControlled || (_mode != "watch" && _mode != "fast" && _mode != "report"))
		return G.result(false, "当前无法切换看台观战步调。");
	ctx.watchMode = _mode;
	ctx.rawset("watchNextUI", 0.0);
	if (!::Tactical.State.isPaused())
		::Time.setVirtualSpeed(this.watchSpeed(_mode));
	return G.result(true, "");
};

T.watchTick <- function( _tacticalState )
{
	local ctx = this.arenaContext();
	if (ctx == null || ctx.ended || _tacticalState.isInLoadingScreen()) return;
	this.trackCombat();
	if (ctx.playerControlled) return;
	if (!_tacticalState.isPaused() && ctx.watchMode != "watch")
		::Time.setVirtualSpeed(this.watchSpeed(ctx.watchMode));
	if (_tacticalState.m.TacticalScreen == null || _tacticalState.m.TacticalScreen.m.JSHandle == null) return;

	local now = ::Time.getRealTimeF();
	if ("watchNextUI" in ctx && now < ctx.watchNextUI) return;
	ctx.rawset("watchNextUI", now + 0.45);

	local ev = this.findEvent(ctx.event);
	if (ev == null) return;
	_tacticalState.m.TacticalScreen.m.JSHandle.asyncCall("wxTournamentWatchUpdate", {
		mode       = ctx.watchMode,
		title      = ev.title,
		left       = this.findTeam(ev, ctx.left).name,
		right      = this.findTeam(ev, ctx.right).name,
		round      = ::Time.getRound(),
		leftCount  = ctx.trace.left,
		rightCount = ctx.trace.right
	});
};

T.closeWatchUI <- function()
{
	if (("Tactical" in getroottable()) && ("State" in ::Tactical) && ::Tactical.State != null && ::Tactical.State.m.TacticalScreen != null && ::Tactical.State.m.TacticalScreen.m.JSHandle != null)
		::Tactical.State.m.TacticalScreen.m.JSHandle.asyncCall("wxTournamentWatchClose", null);
	::Time.setVirtualSpeed(1.0);
};

// -----------------------------------------------------------------------------
// 5. UI Dossier & Tournament Request Bridge (`fighterDossierView`, `buildView`, `handleRequest`)
// -----------------------------------------------------------------------------
T.fighterDossierView <- function( _actor )
{
	local gear = [];
	foreach (slot in [::Const.ItemSlot.Mainhand, ::Const.ItemSlot.Offhand, ::Const.ItemSlot.Head, ::Const.ItemSlot.Body])
	{
		local item = _actor.getItems().getItemAtSlot(slot);
		if (item != null && item.getIcon() != "")
			gear.push({ name = item.getName(), icon = item.getIcon(), slot = slot });
	}

	local manuals = [];
	local mc = _actor.getSkills().getSkillByID("special.wx_martial_container");
	if (mc != null)
	{
		local tierWords = ["", "一重", "二重", "三重"];
		foreach (s in mc.m.Slots)
		{
			if (s.ManualID != null && s.Tier > 0)
			{
				local mdef = ::Wuxia.Slots.getManualDef(s.ManualID);
				if (mdef != null)
					manuals.push("《" + mdef.Name + "》" + tierWords[G.clamp(s.Tier, 1, 3)]);
			}
		}
	}

	_actor.getSkills().update();
	local p = _actor.getCurrentProperties();
	return {
		id      = _actor.getID(),
		name    = _actor.getName(),
		image   = _actor.getImagePath(),
		gear    = gear,
		manuals = manuals,
		basics  = {
			hp           = _actor.getHitpoints(),
			hpMax        = _actor.getHitpointsMax(),
			ap           = _actor.getActionPointsMax(),
			head         = _actor.getArmor(::Const.BodyPart.Head),
			body         = _actor.getArmor(::Const.BodyPart.Body),
			melee        = p.getMeleeSkill(),
			ranged       = p.getRangedSkill(),
			meleeDefense = p.getMeleeDefense(),
			rangedDefense= p.getRangedDefense()
		}
	};
};

T.publicityGazette <- function()
{
	this.discoverEvents();
	local rows = [];
	foreach (ev in this.arenaBook().events)
	{
		if (ev.phase == "finished" && G.day() > ev.finishedDay + 7) continue;
		local topNotice = ev.notices.len() > 0 ? ev.notices.top() : { day = ev.openedDay, text = ev.townName + "正在筹办《" + ev.title + "》。" };
		rows.push({
			id      = ev.id,
			title   = ev.title,
			town    = ev.townName,
			size    = ev.size,
			edition = ev.edition,
			phase   = ev.phase,
			day     = topNotice.day,
			text    = topNotice.text
		});
		local reported = 0;
		for (local i = ev.matches.len() - 1; i >= 0 && reported < 2; i = --i)
		{
			if ("report" in ev.matches[i] && ev.matches[i].report != null)
			{
				local rep = ev.matches[i].report;
				rows.push({
					id      = ev.id,
					title   = ev.title + " · " + rep.title,
					town    = ev.townName,
					size    = ev.size,
					edition = ev.edition,
					phase   = ev.phase,
					day     = ("reportDay" in ev.matches[i]) ? ev.matches[i].reportDay : ev.openedDay,
					text    = rep.text
				});
				reported += 1;
			}
		}
	}
	return rows;
};

T.buildTournamentView <- function( _town, _ev = null, _matchId = 0 )
{
	this.discoverEvents();
	local isHost = this.isHostTown(_town);
	local hasNativeArena = (_town != null && _town.hasBuilding("building.arena"));
	local events = [];
	local inspection = null;
	local candidates = [];
	local self = this;

	if (_ev != null && (!isHost || _ev.town != _town.getID() || this.findEvent(_ev.id) == null))
	{
		_ev = null;
		_matchId = 0;
	}

	if (isHost && _town != null)
	{
		local preferred = null;
		foreach (item in this.arenaBook().events)
		{
			if (item.town == _town.getID())
			{
				events.push({
					id      = item.id,
					title   = item.title,
					edition = item.edition,
					phase   = item.phase,
					size    = item.size,
					awaitingPayout = this.isSeasonOver(item)
				});
				if (preferred == null || this.isSeasonOver(preferred)) preferred = item;
			}
		}
		if (_ev == null) _ev = preferred;
	}

	if (_ev != null && _ev.phase == "registration")
	{
		this.withMemberContext(function()
		{
			foreach (bro in ::World.getPlayerRoster().getAll())
			{
				if (bro != null && bro.isAlive())
					candidates.push(self.fighterDossierView(bro));
			}
		});
	}

	local m = this.findMatch(_ev, _matchId);
	if (m != null && m.left > 0 && m.right > 0)
	{
		inspection = { match = m.id, left = [], right = [] };
		this.withMemberContext(function()
		{
			foreach (side in ["left", "right"])
			{
				local tm = self.findTeam(_ev, m[side]);
				if (tm != null)
				{
					foreach (actor in self.getTeamRoster(tm).getAll())
						inspection[side].push(self.fighterDossierView(actor));
				}
			}
		});
	}

	local view = (_ev == null) ? null : (clone _ev);
	if (view != null)
	{
		view.matches = [];
		foreach (mt in _ev.matches)
		{
			local cp = clone mt;
			cp.rawset("interest", this.matchInterest(_ev, mt.id));
			view.matches.push(cp);
		}
		view.teams = [];
		this.withMemberContext(function()
		{
			foreach (tm in _ev.teams)
			{
				local actors = self.getTeamRoster(tm).getAll();
				view.teams.push({
					id      = tm.id,
					name    = tm.name,
					player  = tm.player,
					count   = actors.len(),
					faction = ("faction" in tm) ? tm.faction : "江湖门派",
					unit    = ("unit" in tm) ? tm.unit : "人",
					solo    = ("solo" in tm) && tm.solo,
					story   = ("story" in tm) ? tm.story : "奉英雄帖登台演武。",
					banner  = ("banner" in tm) ? tm.banner : "",
					image   = actors.len() > 0 ? actors[0].getImagePath() : ""
				});
			}
		});
		view.tickets = [];
		foreach (tk in _ev.tickets)
		{
			local tc = clone tk;
			tc.rawset("value", this.ticketValue(_ev, tk));
			view.tickets.push(tc);
		}
	}

	return {
		town           = _town != null ? _town.getName() : "九州江湖",
		isHostTown     = isHost,
		hasNativeArena = hasNativeArena,
		events         = events,
		event          = view,
		candidates     = candidates,
		inspection     = inspection,
		gazette        = this.publicityGazette(),
		regions64      = ::Wuxia.Config.Gambling.Regions64,
		limits         = { minimum = 10, maximum = 5000, payout = 1000000 },
		money          = G.wallet(),
		revision       = G.State.revision
	};
};

T.handleTournamentAction <- function( _parentTownScreen, _data )
{
	if (!G.ensure()) return null;
	local town = (("State" in ::World) && ::World.State != null) ? ::World.State.getCurrentTown() : null;
	if (town == null || (("Tactical" in getroottable()) && ("isActive" in ::Tactical) && ::Tactical.isActive()))
		return { closed = true, ok = false, message = "你已离开州府演武柜台，银两分毫未动。" };
	if (typeof _data != "array" || _data.len() != 5 || typeof _data[0] != "string")
		return null;

	this.discoverEvents();
	local action = _data[0];

	// Gazette view works in ANY town (including small villages, showing where host cities are!)
	if (action == "gazette" || !this.isHostTown(town))
	{
		local gRes = G.result(true, this.isHostTown(town) ? "" : ("【" + town.getName() + "】地处偏隅未设演武高台；请按下方《演武英雄榜》前往各大州府重镇或西域演武城登台参战与下注！"));
		gRes.rawset("arena", this.buildTournamentView(town, null, 0));
		if (_parentTownScreen != null && ::Wuxia.hasMember(_parentTownScreen, "queryAssetsInformation"))
			gRes.rawset("Assets", _parentTownScreen.queryAssetsInformation());
		return gRes;
	}

	local ev = this.findEvent(_data[1]);
	if (ev != null && ev.town != town.getID())
		ev = null;

	local res = G.result(true, "");
	local matchId = 0;

	if (action != "view" && action != "inspect" && action != "native" && _data[4] != G.State.revision)
	{
		res = G.result(false, "签表或银箱账目刚有更新，请核对后再落锤。");
	}
	else if (action == "view")
	{
		if (ev != null && ("championBannerMsg" in ev) && ev.championBannerMsg != "")
		{
			res = G.result(true, ev.championBannerMsg);
			ev.championBannerMsg = "";
		}
	}
	else if (action == "inspect")
	{
		matchId = _data[2];
	}
	else if (action == "register" && ev != null)
	{
		res = this.registerSquad(ev, _data[2]);
	}
	else if (action == "withdraw" && ev != null && ev.phase == "registration")
	{
		ev.selected = [];
		G.touch();
		res = G.result(true, "知客执事划去了义社五人名帖，分文未取。");
	}
	else if (action == "seal" && ev != null)
	{
		res = this.sealBracket(ev);
	}
	else if (action == "bet" && ev != null)
	{
		res = this.placeTicket(ev, _data[2], _data[3]);
	}
	else if (action == "claim" && ev != null)
	{
		res = this.claimTicket(ev, _data[2]);
	}
	else if ((action == "start" || action == "fast" || action == "report") && ev != null)
	{
		local mode = (action == "start") ? "watch" : action;
		res = this.startMatch(ev, _data[2], mode);
		if (res.ok)
			return { closed = true, ok = true, message = res.message };
	}
	else if (action == "native")
	{
		local bldg = town.getBuilding("building.arena");
		local contract = ::World.Contracts.getActiveContract();
		if (bldg == null)
			res = G.result(false, "本城仅有武林大会校场，未设西域红绸生死死斗场。");
		else if (!::World.getTime().IsDaytime)
			res = G.result(false, "夜色已深，红绸生死擂坊主明早方才开门接生死状。");
		else if (bldg.isClosed())
			res = G.result(false, "今日红绸生死死斗已散场，请明日再来。");
		else if (contract != null && contract.getType() != "contract.arena" && contract.getType() != "contract.arena_tournament")
			res = G.result(false, "坊主瞥了眼你怀中榜文：「先把身上的江湖委托了结，再来签生死状！」");
		else if (contract == null && ::World.FactionManager.getFactionOfType(::Const.FactionType.Arena) != null
			&& ::World.FactionManager.getFactionOfType(::Const.FactionType.Arena).getContracts().len() == 0
			&& ::World.Assets.getStash().getNumberOfEmptySlots() < 3)
		{
			res = G.result(false, "坊主请你先在行囊中腾出 3 格空位，以便发放登台号牌项圈。");
		}
		else if (_parentTownScreen != null && "WX_NativeArenaClick" in bldg)
		{
			bldg.WX_NativeArenaClick(_parentTownScreen);
			return { closed = true, ok = true, message = "" };
		}
	}
	else
	{
		res = G.result(false, "知客执事未听清场次，请点选签表上的对阵。");
	}

	res.rawset("arena", this.buildTournamentView(town, ev, matchId));
	if (_parentTownScreen != null && ::Wuxia.hasMember(_parentTownScreen, "queryAssetsInformation"))
		res.rawset("Assets", _parentTownScreen.queryAssetsInformation());
	if (("State" in ::World) && ::World.State != null)
		::World.State.updateTopbarAssets();
	return res;
};
