// Wuxia Tavern Gambling Table (`迎客酒肆 · 长乐赌桌`) & Segmented Campaign Persistence (`::Wuxia.Gambling`)
// Server-authoritative decks/dice/AI-tapes committed prior to silver deduction; zero stock-market bloat.

::Wuxia.Gambling <- {
	Schema  = 1,
	State   = null,
	Runtime = {
		loadedFlags    = null,
		recordCache    = null,
		saveDirty      = false,
		mediaLastSound = 0.0,
		arenaCombat    = null,
		arenaReopen    = 0,
		arenaReopenMatch = 0
	},
	Sounds = {
		cards  = "wx_cards",
		dice   = "wx_dice",
		stake  = "wx_stake",
		win    = "wx_win",
		lose   = "wx_lose",
		ledger = "wx_ledger"
	}
};

local G = ::Wuxia.Gambling;

G.rand <- function( _low, _high ) { return ::Math.rand(_low.tointeger(), _high.tointeger()); };
G.floor <- function( _n ) { return ::Math.floor(_n.tofloat()).tointeger(); };
G.ceil <- function( _n ) { return ::Math.ceil(_n.tofloat()).tointeger(); };
G.min <- function( _a, _b ) { return _a < _b ? _a : _b; };
G.max <- function( _a, _b ) { return _a > _b ? _a : _b; };
G.clamp <- function( _n, _low, _high ) { return this.min(_high, this.max(_low, _n)); };
G.result <- function( _ok, _msg ) { return { ok = _ok, message = _msg }; };

G.whole <- function( _q, _minimum = 0, _maximum = 1000000 )
{
	local t = typeof _q;
	return (t == "integer" || t == "float") && _q == _q && _q >= _minimum && _q <= _maximum && _q == this.floor(_q);
};

G.wallet <- function()
{
	if (!("World" in getroottable()) || ::World == null || !("Assets" in ::World) || ::World.Assets == null) return 0;
	return ::World.Assets.getMoney();
};

G.money <- function( _amount )
{
	if ("World" in getroottable() && ::World != null && ("Assets" in ::World) && ::World.Assets != null)
		::World.Assets.addMoney(_amount.tointeger());
};

G.day <- function()
{
	if (!("World" in getroottable()) || ::World == null || !("getTime" in ::World) || ::World.getTime() == null) return 1;
	return ::World.getTime().Days.tointeger();
};

G.clock <- function()
{
	if (!("Time" in getroottable()) || ::Time == null) return 0.0;
	return ::Time.getVirtualTimeF();
};

// -----------------------------------------------------------------------------
// 1. Length-Prefixed UTF-8 Safe Segmented Storage (`::World.Flags`)
// -----------------------------------------------------------------------------
G.encode <- function( _val )
{
	local t = typeof _val;
	if (_val == null) return "z";
	if (t == "bool") return _val ? "b1" : "b0";
	if (t == "integer") return "i" + _val + ";";
	if (t == "float") return "f" + format("%.9g", _val) + ";";
	if (t == "string") return "s" + _val.len() + ":" + _val;
	local out = (t == "array" ? "a" : "t") + _val.len() + ":";
	if (t == "array")
	{
		foreach (v in _val) out += this.encode(v);
	}
	else if (t == "table")
	{
		foreach (k, v in _val) out += this.encode(k.tostring()) + this.encode(v);
	}
	else
	{
		throw "Unsupported saved value type: " + t;
	}
	return out;
};

G.decode <- function( _text )
{
	if (typeof _text != "string" || _text.len() > 1000000) throw "Invalid save record";
	local pos = 0;
	local readVal = null;
	local token = function( _delim )
	{
		local endIdx = _text.find(_delim, pos);
		if (endIdx == null) throw "Truncated save record";
		local val = _text.slice(pos, endIdx);
		pos = endIdx + 1;
		return val;
	};
	readVal = function( _depth )
	{
		if (_depth > 24 || pos >= _text.len()) throw "Invalid save nesting";
		local kind = _text.slice(pos, pos + 1);
		pos += 1;
		if (kind == "z") return null;
		if (kind == "b")
		{
			if (pos >= _text.len()) throw "Truncated boolean";
			local bv = _text.slice(pos, pos + 1);
			pos += 1;
			if (bv != "0" && bv != "1") throw "Invalid boolean";
			return bv == "1";
		}
		if (kind == "i" || kind == "f")
		{
			local numStr = token(";");
			if (numStr.len() == 0) throw "Invalid number";
			return kind == "i" ? numStr.tointeger() : numStr.tofloat();
		}
		local sz = token(":").tointeger();
		if (sz < 0 || sz > 1000000) throw "Invalid save length";
		if (kind == "s")
		{
			if (pos + sz > _text.len()) throw "Truncated string";
			local sRes = _text.slice(pos, pos + sz);
			pos += sz;
			return sRes;
		}
		if (kind != "a" && kind != "t") throw "Unknown saved type";
		local res = (kind == "a") ? [] : {};
		for (local i = 0; i < sz; i = ++i)
		{
			if (kind == "a")
			{
				res.push(readVal(_depth + 1));
			}
			else
			{
				local k = readVal(_depth + 1);
				if (typeof k != "string") throw "Invalid saved key";
				res.rawset(k, readVal(_depth + 1));
			}
		}
		return res;
	};
	local decoded = readVal(0);
	if (pos != _text.len()) throw "Unexpected save suffix";
	return decoded;
};

G.sameSavedValue <- function( _val, _saved )
{
	local kind = typeof _val;
	if (kind != typeof _saved) return false;
	if (kind != "array" && kind != "table") return _val == _saved;
	if (_val.len() != _saved.len()) return false;
	foreach (k, item in _val)
	{
		if (!(k in _saved) || !this.sameSavedValue(item, _saved[k])) return false;
	}
	return true;
};

G.copySavedValue <- function( _val )
{
	local kind = typeof _val;
	if (kind != "array" && kind != "table") return _val;
	local res = (kind == "array") ? [] : {};
	foreach (k, item in _val)
	{
		local cp = this.copySavedValue(item);
		if (kind == "array") res.push(cp);
		else res.rawset(k, cp);
	}
	return res;
};

G.getRecordCache <- function()
{
	local cache = this.Runtime.recordCache;
	if (cache == null || cache.flags != ::World.Flags || cache.state != this.State)
	{
		cache = { flags = ::World.Flags, state = this.State, records = {} };
		this.Runtime.recordCache = cache;
	}
	return cache.records;
};

G.writeRecord <- function( _key, _val )
{
	local cache = this.getRecordCache();
	if (cache != null && (_key in cache) && this.sameSavedValue(_val, cache[_key]))
		return false;
	if (cache != null && (_key in cache))
		cache.rawdelete(_key);

	local text = this.encode(_val);
	local limit = 46000;
	if (text.len() <= limit)
	{
		::World.Flags.set(_key, text);
		::World.Flags.set(_key + "_parts", "0");
		if (cache != null) cache.rawset(_key, this.copySavedValue(_val));
		return true;
	}

	local startIdx = 0;
	local part = 0;
	while (startIdx < text.len())
	{
		local endIdx = this.min(startIdx + limit, text.len());
		while (endIdx < text.len() && (text[endIdx] & 0xC0) == 0x80)
			endIdx -= 1;
		::World.Flags.set(_key + "_" + part, text.slice(startIdx, endIdx));
		startIdx = endIdx;
		part += 1;
	}
	::World.Flags.set(_key, this.encode({ schema = -1, segmented = true }));
	::World.Flags.set(_key + "_parts", part.tostring());
	if (cache != null) cache.rawset(_key, this.copySavedValue(_val));
	return true;
};

G.readRecord <- function( _key )
{
	local count = ::World.Flags.has(_key + "_parts") ? ::World.Flags.get(_key + "_parts").tointeger() : 0;
	if (count < 0 || count > 32) throw "Invalid segmented save count";
	if (count == 0) return this.decode(::World.Flags.get(_key));
	local text = "";
	for (local part = 0; part < count; part = ++part)
	{
		local partKey = _key + "_" + part;
		if (!::World.Flags.has(partKey)) throw "Missing segmented save part";
		text += ::World.Flags.get(partKey);
		if (text.len() > 1000000) throw "Segmented save too large";
	}
	return this.decode(text);
};

G.freshState <- function( _day )
{
	return {
		schema        = this.Schema,
		nextId        = 1,
		revision      = 0,
		lastDay       = _day,
		game          = null,
		lastGamble    = null,
		holdemButton  = 0,
		talkSeen      = [],
		rumorHeard    = {},
		metrics       = {
			casinoNet   = 0,
			handsPlayed = 0,
			tourneyBet  = 0,
			tourneyWon  = 0
		},
		arena         = {
			next   = 1,
			events = []
		}
	};
};

G.save <- function()
{
	if (this.State == null || !("World" in getroottable()) || ::World == null || !("Flags" in ::World) || ::World.Flags == null)
		return;

	local meta = clone this.State;
	if ("arena" in meta && meta.arena != null)
	{
		local arenaMeta = clone meta.arena;
		local evIds = [];
		foreach (ev in meta.arena.events)
		{
			evIds.push(ev.id);
			this.writeRecord("wx_tourney_ev_" + ev.id, ev);
		}
		arenaMeta.events = [];
		arenaMeta.rawset("eventRecords", evIds);
		meta.arena = arenaMeta;
	}
	this.writeRecord("wx_gamble_meta", meta);
	this.Runtime.saveDirty = false;
};

G.load <- function()
{
	this.Runtime.recordCache = null;
	if (!("World" in getroottable()) || ::World == null || !("Flags" in ::World) || ::World.Flags == null)
		return false;

	if (!::World.Flags.has("wx_gamble_meta"))
	{
		this.State = this.freshState(this.day());
	}
	else
	{
		try
		{
			local loaded = this.readRecord("wx_gamble_meta");
			if (!("schema" in loaded) || loaded.schema > this.Schema)
				this.State = this.freshState(this.day());
			else
				this.State = loaded;
		}
		catch (_err)
		{
			::logError("[mod_wuxia] Failed to read wx_gamble_meta, resetting gambling state: " + _err);
			this.State = this.freshState(this.day());
		}
	}

	if ("arena" in this.State && this.State.arena != null && "eventRecords" in this.State.arena)
	{
		local evs = [];
		foreach (eid in this.State.arena.eventRecords)
		{
			try { evs.push(this.readRecord("wx_tourney_ev_" + eid)); } catch (_e) {}
		}
		this.State.arena.events = evs;
		this.State.arena.rawdelete("eventRecords");
	}

	if ("arena" in this.State && this.State.arena != null)
	{
		foreach (ev in this.State.arena.events)
		{
			foreach (m in ev.matches)
			{
				if (m.status == "running")
					m.status = "interrupted";
			}
		}
	}

	this.Runtime.loadedFlags = ::World.Flags;
	return true;
};

G.ensure <- function()
{
	if (!("World" in getroottable()) || ::World == null || !("Flags" in ::World) || ::World.Flags == null)
		return false;
	if (this.State == null || this.Runtime.loadedFlags != ::World.Flags)
		this.load();
	return this.State != null;
};

G.touch <- function()
{
	if (this.State == null) return;
	this.State.revision += 1;
	this.Runtime.saveDirty = true;
	if (this.Runtime.loadedFlags != null)
		this.save();
};

// -----------------------------------------------------------------------------
// 2. Sound Effects (`sounds/wx_gamble/wx_*.wav`)
// -----------------------------------------------------------------------------
G.playSound <- function( _key )
{
	if (typeof _key != "string" || !(_key in this.Sounds)) return false;
	if (("Tactical" in getroottable()) && ("isActive" in ::Tactical) && ::Tactical.isActive())
		return false;
	if (!("Sound" in getroottable()) || ::Sound == null)
		return false;
	local now = ("Time" in getroottable() && ::Time != null) ? ::Time.getRealTimeF() : 0.0;
	if (now > 0.0 && now - this.Runtime.mediaLastSound < 0.055)
		return false;
	this.Runtime.mediaLastSound = now;
	try
	{
		::Sound.play("sounds/wx_gamble/" + this.Sounds[_key] + ".wav", 0.50);
		return true;
	}
	catch (_e)
	{
		return false;
	}
};

// -----------------------------------------------------------------------------
// 3. Jianghu Table Banter (`牌桌江湖闲话`)
// -----------------------------------------------------------------------------
G.tableTalk <- function()
{
	if (this.State == null) return "";
	if (this.rand(1, 100) > 28) return "";

	// Prefer fresh 武林大会 match notices first!
	if ("arena" in this.State && this.State.arena != null && this.State.arena.events.len() > 0)
	{
		local pool = [];
		foreach (ev in this.State.arena.events)
		{
			for (local i = ev.matches.len() - 1; i >= 0; i = --i)
			{
				local m = ev.matches[i];
				if ("report" in m && m.report != null)
				{
					local tag = "m_" + ev.id + "_" + m.id;
					if (this.State.talkSeen.find(tag) == null)
						pool.push({ tag = tag, text = m.report.text });
				}
			}
		}
		if (pool.len() > 0)
		{
			local picked = pool[this.rand(0, pool.len() - 1)];
			this.State.talkSeen.push(picked.tag);
			while (this.State.talkSeen.len() > 40) this.State.talkSeen.remove(0);
			return "邻桌酒客拍案谈起近日演武战报：「" + picked.text + "」";
		}
	}

	// Fallback: colorful Jianghu sect gossip
	local gossips = [
		"旁边押镖老客抿了口烧刀子：「听说近日各大州府召开武林大会，外围银票盘口打得火热，押中一场黑马翻盘够吃半年酒肉！」",
		"独耳刀客擦着牛骨骰笑道：「前儿个有少室武僧登台比武，一双铁掌震飞了两柄大刀，外围买他赢的酒客笑得合不拢嘴。」",
		"角落行商低声道：「蜀中唐门的机括毒弩虽狠，到了演武擂上只分高下不伤性命，倒教看客瞧清了不少独门绝活。」",
		"说书老翁摇着折扇感叹：「这牛骨骰红四点乃是唐明皇赐绯的旧典，掷出豹子通杀，神仙难救喽！」"
	];
	return gossips[this.rand(0, gossips.len() - 1)];
};

// -----------------------------------------------------------------------------
// 4. Seven Wuxia Tavern Games — Core Rules & Pre-Committed Math
// -----------------------------------------------------------------------------
G.betLimits <- function()
{
	local w = this.max(0, this.floor(this.wallet()));
	local day = this.day();
	local rep = ("World" in getroottable() && ::World != null && ("Assets" in ::World) && ::World.Assets != null && ::Wuxia.hasMember(::World.Assets, "getBusinessReputation"))
		? ::World.Assets.getBusinessReputation()
		: 0;
	// Anti-bankroll-break guardrail: cap single-hand stakes smoothly by campaign day & company renown (300..1500 silver)
	local tableCap = this.min(1500, 300 + this.floor(day * 6) + this.floor(rep / 5));

	// Daily house profit cap (2,500 silver net winnings per day) so gambling stays lively without replacing contracts
	local dailyCapLeft = 2500;
	if (this.State != null)
	{
		if (!("dailyDay" in this.State) || this.State.dailyDay != day)
		{
			this.State.rawset("dailyDay", day);
			this.State.rawset("dailyCasinoNet", 0);
		}
		if (("dailyCasinoNet" in this.State) && this.State.dailyCasinoNet >= 2500)
			dailyCapLeft = 0;
		else if ("dailyCasinoNet" in this.State)
			dailyCapLeft = this.max(0, 2500 - this.State.dailyCasinoNet);
	}

	local maxStake = this.min(w, this.min(tableCap, dailyCapLeft));
	return {
		minimum      = 1,
		maximum      = maxStake,
		tableCap     = tableCap,
		dailyCapLeft = dailyCapLeft
	};
};

G.finishGamble <- function( _game, _payout, _message )
{
	this.money(_payout);
	local netDelta = _payout - _game.stake;
	this.State.metrics.casinoNet += netDelta;
	this.State.metrics.handsPlayed += 1;
	local curDay = this.day();
	if (!("dailyDay" in this.State) || this.State.dailyDay != curDay)
	{
		this.State.rawset("dailyDay", curDay);
		this.State.rawset("dailyCasinoNet", 0);
	}
	this.State.dailyCasinoNet += netDelta;
	this.State.game = null;

	local revealed = [];
	if ("dice" in _game)
	{
		local showCnt = (_game.kind == "raid") ? _game.stage : _game.dice.len();
		for (local i = 0; i < showCnt; i = ++i)
			revealed.push(_game.dice[i]);
	}

	local last = {
		id     = this.State.nextId++,
		kind   = _game.kind,
		stake  = _game.stake,
		pick   = _game.pick,
		dice   = revealed,
		stage  = _game.stage,
		payout = _payout,
		net    = _payout - _game.stake
	};

	if (_game.kind == "blackjack")
	{
		last.rawset("player", clone _game.player);
		last.rawset("dealer", clone _game.dealer);
		last.rawset("playerTotal", this.cardTotal(_game.player));
		last.rawset("dealerTotal", this.cardTotal(_game.dealer));
		last.rawset("doubled", _game.doubled);
	}
	else if (_game.kind == "hazard")
	{
		last.rawset("main", _game.main);
		last.rawset("chance", _game.chance);
	}
	else if (_game.kind == "riffa")
	{
		last.rawset("playerTotal", revealed[0] + revealed[1] + revealed[2]);
		last.rawset("dealerTotal", revealed[3] + revealed[4] + revealed[5]);
	}

	this.State.lastGamble = last;
	local talk = this.tableTalk();
	this.touch();

	local net = _payout - _game.stake;
	local receipt = _payout > 0
		? (" 你自案上拢回 " + _payout + " 两纹银（含退还赌本）。")
		: " 庄家笑眯眯收走了案上纹银。";
	receipt += net > 0
		? ("此局净赢 " + net + " 两纹银！")
		: (net < 0 ? ("此局折损 " + (-net) + " 两纹银。") : "此局平手退本，两不相欠。");

	return this.result(true, _message + receipt + (talk == "" ? "" : ("\n" + talk)));
};

// --- 4A. 马吊廿一点 (`blackjack`) ---
G.shuffledDeck <- function()
{
	local deck = [];
	for (local i = 0; i < 52; i = ++i) deck.push(i);
	for (local i = 51; i > 0; i = --i)
	{
		local j = this.rand(0, i);
		local tmp = deck[i];
		deck[i] = deck[j];
		deck[j] = tmp;
	}
	return deck;
};

G.cardTotal <- function( _cards )
{
	local total = 0;
	local aces = 0;
	foreach (card in _cards)
	{
		local rank = (card % 13) + 1;
		if (rank == 1)
		{
			total += 11;
			aces += 1;
		}
		else
		{
			total += this.min(10, rank);
		}
	}
	while (total > 21 && aces > 0)
	{
		total -= 10;
		aces -= 1;
	}
	return total;
};

G.drawCard <- function( _game, _side )
{
	_game[_side].push(_game.deck[_game.nextCard++]);
};

G.startBlackjack <- function( _stake )
{
	local game = {
		kind     = "blackjack",
		stake    = _stake,
		pick     = 0,
		stage    = 0,
		player   = [],
		dealer   = [],
		deck     = this.shuffledDeck(),
		nextCard = 0,
		doubled  = false
	};
	this.drawCard(game, "player");
	this.drawCard(game, "dealer");
	this.drawCard(game, "player");
	this.drawCard(game, "dealer");
	this.money(-_stake);
	this.State.game = game;

	local own = this.cardTotal(game.player);
	local dlr = this.cardTotal(game.dealer);
	if (own == 21 || dlr == 21)
	{
		local payout = (own == 21) ? (dlr == 21 ? _stake : this.floor(_stake * 2.5)) : 0;
		local msg = (own == 21)
			? (dlr == 21 ? "庄闲起手皆成廿一点天胡，原银退回！" : "起手两叶直成『天胡廿一点』，彩头按 2.5 倍奉还！")
			: "庄家起手两叶凑成廿一点天胡！";
		return this.finishGamble(game, payout, msg);
	}
	this.touch();
	return this.result(true, "马吊叶牌已发定，你手握 " + own + " 点。可『再摸一叶』、『封牌定输赢』，或再押同额纹银『孤注加倍（仅补一叶）』。");
};

G.standBlackjack <- function()
{
	local game = this.State.game;
	if (game == null || game.kind != "blackjack")
		return this.result(false, "案上并无未完的马吊廿一点牌局。");
	while (this.cardTotal(game.dealer) < 17)
		this.drawCard(game, "dealer");
	local own = this.cardTotal(game.player);
	local dlr = this.cardTotal(game.dealer);
	local payout = (dlr > 21 || own > dlr) ? (game.stake * 2) : (own == dlr ? game.stake : 0);
	local tail = (dlr > 21) ? "庄家贪补爆点！" : (own == dlr ? "点数相当，握手退本。" : (own > dlr ? "你的牌面压过庄家！" : "庄家牌面更胜一筹。"));
	return this.finishGamble(game, payout, "你手握 " + own + " 点，庄家摊牌 " + dlr + " 点——" + tail);
};

G.hitBlackjack <- function( _doubled = false )
{
	local game = this.State.game;
	if (game == null || game.kind != "blackjack")
		return this.result(false, "案上并无未完的马吊廿一点牌局。");
	if (_doubled)
	{
		if (game.player.len() != 2 || game.doubled)
			return this.result(false, "唯有起手两叶未补牌时方能孤注加倍。");
		if (this.wallet() < game.stake)
			return this.result(false, "孤注加倍需再押同额纹银（" + game.stake + " 两），行囊现银不足。");
		this.money(-game.stake);
		game.stake *= 2;
		game.doubled = true;
	}
	this.drawCard(game, "player");
	game.stage += 1;
	local total = this.cardTotal(game.player);
	if (total > 21)
		return this.finishGamble(game, 0, "补叶后合计 " + total + " 点，超过廿一点爆牌！");
	if (_doubled || total == 21)
		return this.standBlackjack();
	this.touch();
	return this.result(true, "当前手牌合计 " + total + " 点。可继续摸叶，或封牌交由庄家开暗叶。");
};

// --- 4B. 夜走黑风道 (`raid`), 牛骨骰大小 (`size`), 六合花旗盘 (`symbols`), 双鲤抢单骰 (`riffa`), 天门追点骰 (`hazard`) ---
G.raidPayout <- function( _game )
{
	if (_game.stage <= 0) return 0;
	local rates = [1.15, 1.38, 1.65, 1.98];
	return this.floor(_game.stake * rates[_game.stage - 1] + 0.00001);
};

G.continueRaid <- function()
{
	local game = this.State.game;
	if (game == null || game.kind != "raid")
		return this.result(false, "案上并无未完的『夜走黑风道』闯关局。");
	local stageNames = ["黑风山口", "迷雾苦竹林", "断魂一线天", "满载入州城"];
	local roll = game.dice[game.stage];
	local stageLabel = stageNames[game.stage];
	game.stage += 1;
	if (roll == 1)
		return this.finishGamble(game, 0, "行至第 " + game.stage + " 关【" + stageLabel + "】掷出红一，夜遇响马截镖埋伏！");
	if (game.stage == 4)
		return this.finishGamble(game, this.raidPayout(game), "镖旗连闯四道险关，平安抵达州城总号！");
	this.touch();
	return this.result(true, "骨骰掷出 " + roll + " 点，安然闯过第 " + game.stage + " 关【" + stageLabel + "】！此时收缰结账可拿回 " + this.raidPayout(game) + " 两纹银。");
};

G.stopRaid <- function()
{
	local game = this.State.game;
	if (game == null || game.kind != "raid")
		return this.result(false, "案上并无未完的『夜走黑风道』闯关局。");
	return this.finishGamble(game, this.raidPayout(game), "你勒马收缰见好就收，将镖旗挪回酒肆结账。");
};

G.hazardOpening <- function( _main, _sum )
{
	if (_sum == _main || (_sum == 12 && (_main == 6 || _main == 8)) || (_sum == 11 && _main == 7))
		return 1;
	if (_sum == 2 || _sum == 3 || _sum == 11 || _sum == 12)
		return -1;
	return 0;
};

G.startHazard <- function( _stake, _main )
{
	local first = [this.rand(1, 6), this.rand(1, 6)];
	local sum = first[0] + first[1];
	local opening = this.hazardOpening(_main, sum);
	local game = {
		kind   = "hazard",
		stake  = _stake,
		pick   = _main,
		stage  = 1,
		main   = _main,
		chance = (opening == 0 ? sum : 0),
		dice   = first,
		throws = [first]
	};
	if (opening == 0)
	{
		local resolved = false;
		for (local i = 0; i < 4096; i = ++i)
		{
			local pair = [this.rand(1, 6), this.rand(1, 6)];
			local tot = pair[0] + pair[1];
			game.throws.push(pair);
			if (tot == _main || tot == game.chance) { resolved = true; break; }
		}
		if (!resolved)
			return this.result(false, "庄家尚未摆稳紫铜骰盅，纹银仍在行囊中，请稍候再试。");
	}
	this.money(-_stake);
	if (opening != 0)
	{
		return this.finishGamble(game, opening > 0 ? (_stake * 2) : 0,
			"天门主点 " + _main + "，开盅首掷 " + sum + " 点——" + (opening > 0 ? "开门见彩直赢！" : "出师不利落败。"));
	}
	this.State.game = game;
	this.touch();
	return this.result(true, "天门主点 " + _main + "，首掷锁下机缘点【" + game.chance + "】！续摇双骰：先出机缘点【" + game.chance + "】即赢，先撞主点【" + _main + "】则败。");
};

G.continueHazard <- function()
{
	local game = this.State.game;
	if (game == null || game.kind != "hazard")
		return this.result(false, "案上并无未完的天门追点骰局。");
	local pair = game.throws[game.stage++];
	local sum = pair[0] + pair[1];
	game.dice = pair;
	if (sum == game.chance || sum == game.main)
	{
		return this.finishGamble(game, (sum == game.chance) ? (game.stake * 2) : 0,
			"双骰落碗 " + pair[0] + "、" + pair[1] + "（共 " + sum + " 点）——" + (sum == game.chance ? "机缘点先至，大获全胜！" : "先撞天门主点，惜败收场。"));
	}
	this.touch();
	return this.result(true, "掷出 " + sum + " 点，未分胜负！继续免注追掷机缘点【" + game.chance + "】（忌出主点 " + game.main + "）。");
};

G.playRiffa <- function( _stake )
{
	local own = this.rand(1, 6);
	local extra = this.rand(1, 6);
	local dlr = this.rand(1, 6);
	local last = this.rand(1, 6);
	local game = {
		kind  = "riffa",
		stake = _stake,
		pick  = 0,
		stage = 1,
		dice  = [own, own, extra, dlr, dlr, last]
	};
	local a = own * 2 + extra;
	local b = dlr * 2 + last;
	this.money(-_stake);
	local payout = (a > b) ? this.floor(_stake * 1.96 + 0.00001) : (a == b ? _stake : 0);
	local tail = (a > b) ? "点数压倒庄家获胜（赌坊抽四厘茶水钱）！" : (a == b ? "庄闲同点，原银退回。" : "庄家点子更硬，此把惜败。");
	return this.finishGamble(game, payout, "你的双鲤配单珠共 " + a + " 点，庄家共 " + b + " 点——" + tail);
};

// --- 4C. 四家叶子戏 (`holdem` — 4-Handed No-Limit Texas Hold'em) ---
G.holdemRank5 <- function( _cards )
{
	local counts = array(15, 0);
	local ranks = [];
	local isFlush = true;
	local suit = _cards[0] / 13;
	foreach (card in _cards)
	{
		local r = (card % 13) + 1;
		if (r == 1) r = 14;
		counts[r] += 1;
		if ((card / 13) != suit) isFlush = false;
	}
	for (local r = 14; r >= 2; r = --r)
	{
		if (counts[r] > 0) ranks.push(r);
	}
	local straight = 0;
	if (ranks.len() == 5)
	{
		if (ranks[0] - ranks[4] == 4) straight = ranks[0];
		else if (ranks[0] == 14 && ranks[1] == 5 && ranks[4] == 2) straight = 5;
	}
	local groups = [];
	for (local n = 4; n >= 1; n = --n)
	{
		for (local r = 14; r >= 2; r = --r)
		{
			if (counts[r] == n) groups.push(r);
		}
	}
	local cat = 0;
	local kickers = ranks;
	if (straight > 0 && isFlush) { cat = 8; kickers = [straight]; }
	else if (counts[groups[0]] == 4) { cat = 7; kickers = groups; }
	else if (counts[groups[0]] == 3 && counts[groups[1]] == 2) { cat = 6; kickers = groups; }
	else if (isFlush) { cat = 5; }
	else if (straight > 0) { cat = 4; kickers = [straight]; }
	else if (counts[groups[0]] == 3) { cat = 3; kickers = groups; }
	else if (counts[groups[0]] == 2 && counts[groups[1]] == 2) { cat = 2; kickers = groups; }
	else if (counts[groups[0]] == 2) { cat = 1; kickers = groups; }

	local score = cat;
	for (local i = 0; i < 5; i = ++i)
		score = score * 15 + (i < kickers.len() ? kickers[i] : 0);
	return score;
};

G.holdemRank <- function( _cards )
{
	local best = -1;
	local n = _cards.len();
	for (local a = 0; a < n - 4; a = ++a)
		for (local b = a + 1; b < n - 3; b = ++b)
			for (local c = b + 1; c < n - 2; c = ++c)
				for (local d = c + 1; d < n - 1; d = ++d)
					for (local e = d + 1; e < n; e = ++e)
						best = this.max(best, this.holdemRank5([_cards[a], _cards[b], _cards[c], _cards[d], _cards[e]]));
	return best;
};

G.holdemRankName <- function( _score )
{
	if (_score < 0) return "";
	local names = ["散叶(高牌)", "双星(一对)", "连双(两对)", "三绝(三条)", "五连珠(顺子)", "清一色(同花)", "满堂红(葫芦)", "四象轰雷(四条)", "天罡同花顺"];
	return names[_score / 759375];
};

G.holdemEvent <- function( _g, _text, _kind = "bet", _seat = -1, _amount = 0 )
{
	_g.events.push({
		seq        = _g.sequence++,
		text       = _text,
		type       = _kind,
		seat       = _seat,
		amount     = _amount,
		boardCount = _g.board.len(),
		street     = _g.street
	});
	while (_g.events.len() > 100) _g.events.remove(0);
};

G.holdemPay <- function( _g, _idx, _amount )
{
	local s = _g.seats[_idx];
	local paid = this.min(_amount, s.stack);
	s.stack -= paid;
	s.bet += paid;
	s.total += paid;
	return paid;
};

G.holdemCanRaise <- function( _g, _idx )
{
	local s = _g.seats[_idx];
	local hasOpponent = false;
	foreach (j, other in _g.seats)
	{
		if (j != _idx && !other.folded && other.stack > 0) hasOpponent = true;
	}
	return hasOpponent && (s.stack + s.bet > _g.currentBet)
		&& (!s.acted || s.actedAt == 0 || (_g.currentBet - s.actedAt) >= _g.minRaise);
};

G.holdemAct <- function( _g, _idx, _action, _target = 0 )
{
	local s = _g.seats[_idx];
	if (_g.done || _idx != _g.turn || s.folded || s.stack <= 0)
		return this.result(false, "尚未轮到该席位发话。");

	local owed = this.max(0, _g.currentBet - s.bet);
	local maximum = s.bet + s.stack;
	local act = _action;
	local tgt = _target;

	if (act == "allin")
	{
		tgt = maximum;
		act = (tgt > _g.currentBet) ? "raise" : "call";
	}
	if (act != "fold" && act != "call" && act != "raise")
		return this.result(false, "请择定扣牌弃局、跟注或加注。");

	if (act == "raise")
	{
		if (!this.whole(tgt, 1, maximum) || tgt <= _g.currentBet || !this.holdemCanRaise(_g, _idx))
			return this.result(false, "当前筹码或上轮加注幅度不合加注规矩。");
		if ((tgt - _g.currentBet) < _g.minRaise && tgt != maximum)
			return this.result(false, "至少须加注至 " + (_g.currentBet + _g.minRaise) + " 两纹银（银两不足可倾囊全押）。");
	}

	if (act == "fold")
	{
		s.folded = true;
		s.action = "扣牌不跟";
	}
	else if (act == "call")
	{
		local paid = this.holdemPay(_g, _idx, owed);
		s.action = (paid == 0) ? "观望过牌" : (s.stack == 0 ? ("全押 " + s.bet) : ("跟至 " + s.bet));
	}
	else
	{
		local inc = tgt - _g.currentBet;
		this.holdemPay(_g, _idx, tgt - s.bet);
		if (inc >= _g.minRaise) _g.minRaise = inc;
		_g.currentBet = tgt;
		_g.raises += 1;
		s.action = (s.stack == 0) ? ("全押至 " + tgt) : ("加注至 " + tgt);
	}

	s.acted = true;
	s.actedAt = _g.currentBet;
	this.holdemEvent(_g, s.name + "：" + s.action + "。", act, _idx, s.bet);
	_g.turn = (_idx + 1) % _g.seats.len();
	return this.result(true, "");
};

G.holdemPots <- function( _g )
{
	local levels = [];
	local pots = [];
	local prev = 0;
	foreach (s in _g.seats)
	{
		if (s.total > 0 && levels.find(s.total) == null)
			levels.push(s.total);
	}
	levels.sort();
	foreach (lv in levels)
	{
		local amount = 0;
		local eligible = [];
		local contributors = [];
		foreach (i, s in _g.seats)
		{
			if (s.total >= lv)
			{
				amount += (lv - prev);
				contributors.push(i);
				if (!s.folded) eligible.push(i);
			}
		}
		pots.push({ amount = amount, eligible = eligible, contributors = contributors });
		prev = lv;
	}
	return pots;
};

G.holdemSettle <- function( _g )
{
	if (_g.done) return;
	local alive = [];
	local ranks = [];
	foreach (i, s in _g.seats)
	{
		if (!s.folded) alive.push(i);
		local cards = clone s.cards;
		cards.extend(_g.board);
		ranks.push((!s.folded && _g.board.len() == 5) ? this.holdemRank(cards) : -1);
	}
	_g.showdown = (alive.len() > 1);
	_g.pots = this.holdemPots(_g);

	foreach (pot in _g.pots)
	{
		local winners = [];
		local best = -1;
		if (pot.contributors.len() == 1)
		{
			winners.push(pot.contributors[0]);
		}
		else if (alive.len() == 1)
		{
			winners.push(alive[0]);
		}
		else
		{
			foreach (i in pot.eligible)
			{
				if (ranks[i] > best) { best = ranks[i]; winners = [i]; }
				else if (ranks[i] == best) winners.push(i);
			}
		}
		local portion = pot.amount / winners.len();
		local odd = pot.amount % winners.len();
		foreach (i in winners) _g.seats[i].stack += portion;
		for (local step = 1; step <= _g.seats.len() && odd > 0; step = ++step)
		{
			local i = (_g.button + step) % _g.seats.len();
			if (winners.find(i) != null) { _g.seats[i].stack += 1; odd -= 1; }
		}
		pot.rawset("winners", winners);
	}

	foreach (i, s in _g.seats) s.rawset("rank", ranks[i]);
	_g.done = true;
	_g.turn = -1;
	_g.payout = _g.seats[0].stack;
	_g.net = _g.payout - _g.stake;
	this.holdemEvent(_g, "四家收拢银袋：你收回 " + _g.payout + " 两纹银（本手盈亏 " + (_g.net >= 0 ? ("+" + _g.net) : ("" + _g.net)) + " 两）。", "settle");
};

G.holdemNextStreet <- function( _g )
{
	_g.street += 1;
	_g.nextCard += 1; // burn card
	local n = (_g.street == 1) ? 3 : 1;
	for (local j = 0; j < n; j = ++j)
		_g.board.push(_g.deck[_g.nextCard++]);
	foreach (s in _g.seats)
	{
		s.bet = 0;
		s.acted = false;
		s.actedAt = 0;
		s.action = s.folded ? "已扣牌" : (s.stack == 0 ? "已全押" : "");
	}
	_g.currentBet = 0;
	_g.minRaise = _g.bigBlind;
	_g.raises = 0;
	_g.turn = (_g.button + 1) % _g.seats.len();
	local streetMsg = ["", "荷官翻开三叶公共明牌。", "第四叶转势明牌落案。", "第五叶定鼎明牌落案！"][_g.street];
	this.holdemEvent(_g, streetMsg, "deal");
};

G.holdemAi <- function( _g, _idx )
{
	local s = _g.seats[_idx];
	local cards = clone s.cards;
	cards.extend(_g.board);
	local a = (s.cards[0] % 13) + 1;
	local b = (s.cards[1] % 13) + 1;
	if (a == 1) a = 14;
	if (b == 1) b = 14;

	local quality = (a + b) / 28.0;
	if (a == b) quality = 0.68 + a / 50.0;
	if ((s.cards[0] / 13) == (s.cards[1] / 13)) quality += 0.08;
	if (_g.board.len() >= 3)
		quality = 0.22 + (this.holdemRank(cards) / 759375) * 0.17 + (a + b) / 140.0;
	quality = this.clamp(quality, 0.05, 0.98);

	local roll = _g.aiTape[_g.aiCursor++ % _g.aiTape.len()] / 10000.0;
	local owed = this.max(0, _g.currentBet - s.bet);
	local pot = 0;
	foreach (other in _g.seats) pot += other.total;
	local pressure = owed.tofloat() / this.max(1, pot + owed);

	if (owed > 0 && roll > (quality + 0.18 - pressure * 0.30))
		return this.holdemAct(_g, _idx, "fold");
	if (this.holdemCanRaise(_g, _idx) && roll < ((quality > 0.65 ? 0.24 : 0.06) / (1 + _g.raises)))
	{
		local tgt = this.min(s.bet + s.stack, _g.currentBet + this.max(_g.minRaise, this.floor(pot * 0.5)));
		return this.holdemAct(_g, _idx, "raise", tgt);
	}
	return this.holdemAct(_g, _idx, "call");
};

G.holdemAdvance <- function( _g )
{
	for (local guard = 0; guard < 256; guard = ++guard)
	{
		local alive = 0;
		local able = 0;
		local needing = [];
		foreach (i, s in _g.seats)
		{
			if (!s.folded)
			{
				alive += 1;
				if (s.stack > 0)
				{
					able += 1;
					if (!s.acted || s.bet < _g.currentBet) needing.push(i);
				}
			}
		}
		if (alive == 1) { this.holdemSettle(_g); return; }
		if (able == 1)
		{
			foreach (i, s in _g.seats)
			{
				if (!s.folded && s.stack > 0 && s.bet >= _g.currentBet) needing = [];
			}
		}
		if (needing.len() == 0)
		{
			if (_g.street == 3) { this.holdemSettle(_g); return; }
			this.holdemNextStreet(_g);
			continue;
		}
		for (local step = 0; step < _g.seats.len(); step = ++step)
		{
			local i = (_g.turn + step) % _g.seats.len();
			if (needing.find(i) != null) { _g.turn = i; break; }
		}
		if (_g.turn == 0) return;
		local aiRes = this.holdemAi(_g, _g.turn);
		if (!aiRes.ok) throw "Invalid Holdem AI action: " + aiRes.message;
	}
};

G.holdemView <- function( _g )
{
	local seats = [];
	local total = 0;
	foreach (i, s in _g.seats)
	{
		local reveal = (i == 0) || (_g.done && _g.showdown && !s.folded);
		seats.push({
			name     = s.name,
			stack    = s.stack,
			bet      = s.bet,
			total    = s.total,
			cards    = reveal ? (clone s.cards) : [],
			hidden   = !reveal,
			folded   = s.folded,
			action   = s.action,
			rankName = (reveal && "rank" in s) ? this.holdemRankName(s.rank) : ""
		});
		total += s.total;
	}
	local own = _g.seats[0];
	local res = {
		kind       = "holdem",
		stake      = _g.stake,
		stage      = _g.street,
		street     = _g.street,
		board      = clone _g.board,
		seats      = seats,
		button     = _g.button,
		smallBlind = _g.smallBlind,
		bigBlind   = _g.bigBlind,
		turn       = _g.turn,
		pot        = total,
		currentBet = _g.currentBet,
		done       = _g.done,
		events     = clone _g.events,
		toCall     = this.min(own.stack, this.max(0, _g.currentBet - own.bet)),
		minTo      = _g.currentBet + _g.minRaise,
		maxTo      = own.bet + own.stack,
		canRaise   = !_g.done && _g.turn == 0 && this.holdemCanRaise(_g, 0),
		payout     = _g.done ? _g.payout : 0,
		net        = _g.done ? _g.net : 0,
		pots       = []
	};
	foreach (p in (_g.done ? _g.pots : this.holdemPots(_g)))
	{
		res.pots.push({
			amount   = p.amount,
			eligible = clone p.eligible,
			winners  = _g.done ? (clone p.winners) : []
		});
	}
	return res;
};

G.holdemCommit <- function( _g )
{
	if (_g.done)
	{
		this.money(_g.payout);
		this.State.metrics.casinoNet += _g.net;
		this.State.metrics.handsPlayed += 1;
		local curDay = this.day();
		if (!("dailyDay" in this.State) || this.State.dailyDay != curDay)
		{
			this.State.rawset("dailyDay", curDay);
			this.State.rawset("dailyCasinoNet", 0);
		}
		this.State.dailyCasinoNet += _g.net;
		local shown = this.holdemView(_g);
		shown.rawset("id", this.State.nextId++);
		this.State.lastGamble = shown;
		this.State.game = null;
	}
	this.touch();
	local talk = _g.done ? this.tableTalk() : "";
	local msg = _g.done
		? ("牌局落定：你拢回 " + _g.payout + " 两纹银（本手净" + (_g.net >= 0 ? ("赢 " + _g.net) : ("输 " + (-_g.net))) + " 两）。" + (talk == "" ? "" : ("\n" + talk)))
		: "轮到你发话：可跟注、加注，或将暗叶扣下不跟。";
	return this.result(true, msg);
};

G.startHoldem <- function( _stake )
{
	local limits = this.betLimits();
	if (limits.dailyCapLeft <= 0)
		return this.result(false, "今日你手风太旺，长乐赌桌庄家已挂免战牌封顶（每日净赢上限 2,500 两），请明日再来小酌手谈。");
	if (!this.whole(_stake, limits.minimum, limits.maximum))
		return this.result(false, "带入桌上至少 1 两纹银，且不可超出本桌当前限红（" + limits.maximum + " 两，单局台面封顶 " + limits.tableCap + " 两）。");
	local stake = _stake.tointeger();
	local button = ("holdemButton" in this.State) ? ((this.State.holdemButton + 1) % 4) : 0;
	local small = this.max(1, this.floor(stake / 100.0));
	local big = small * 2;

	local g = {
		kind       = "holdem",
		stake      = stake,
		street     = 0,
		seats      = [],
		board      = [],
		button     = button,
		smallBlind = small,
		bigBlind   = big,
		currentBet = big,
		minRaise   = big,
		turn       = (button + 3) % 4,
		deck       = this.shuffledDeck(),
		nextCard   = 0,
		aiTape     = [],
		aiCursor   = 0,
		raises     = 0,
		done       = false,
		showdown   = false,
		events     = [],
		sequence   = 0,
		pots       = [],
		payout     = 0,
		net        = 0
	};
	for (local i = 0; i < 128; i = ++i)
		g.aiTape.push(this.rand(0, 9999));

	local names = ::Wuxia.Config.Gambling.HoldemSeats;
	local purses = [stake, this.max(big, this.floor(stake * 0.65)), stake, this.floor(stake * 1.35)];
	for (local i = 0; i < 4; i = ++i)
	{
		g.seats.push({
			name    = names[i],
			stack   = purses[i],
			cards   = [],
			bet     = 0,
			total   = 0,
			folded  = false,
			acted   = false,
			actedAt = 0,
			action  = ""
		});
	}
	for (local round = 0; round < 2; round = ++round)
	{
		for (local step = 1; step <= 4; step = ++step)
			g.seats[(button + step) % 4].cards.push(g.deck[g.nextCard++]);
	}
	this.holdemPay(g, (button + 1) % 4, small);
	this.holdemPay(g, (button + 2) % 4, big);
	g.seats[(button + 1) % 4].action = "小盲 " + small;
	g.seats[(button + 2) % 4].action = "大盲 " + big;
	this.holdemEvent(g, "四家入席，盲注底银 " + small + " / " + big + " 两，各发两张暗叶。", "deal");

	this.money(-stake);
	this.State.game = g;
	this.State.holdemButton = button;
	this.holdemAdvance(g);
	return this.holdemCommit(g);
};

G.playHoldem <- function( _action, _target = 0 )
{
	local g = this.State.game;
	if (g == null || g.kind != "holdem")
		return this.result(false, "案上并无未完的四家叶子戏。");
	local res = this.holdemAct(g, 0, _action, _target);
	if (!res.ok) return res;
	this.holdemAdvance(g);
	return this.holdemCommit(g);
};

// --- 4D. Unified Gamble Entry (`gamble`) ---
G.gamble <- function( _kind, _stake, _pick )
{
	if (this.State.game != null)
		return this.result(false, "上局纹银尚押在案上，请先将该局了结。");
	if (_kind == "holdem")
		return this.startHoldem(_stake);

	local limits = this.betLimits();
	if (limits.dailyCapLeft <= 0)
		return this.result(false, "今日你连战连捷，长乐赌桌庄家银柜告急已封盘（每日净赢上限 2,500 两），请明日再来。");
	if (!this.whole(_stake, limits.minimum, limits.maximum))
		return this.result(false, "至少押下 1 两整纹银，且不可超出当前限红（" + limits.maximum + " 两，单局台面封顶 " + limits.tableCap + " 两）。");

	local stake = _stake.tointeger();
	if (_kind != "size" && _kind != "raid" && _kind != "symbols" && _kind != "blackjack" && _kind != "hazard" && _kind != "riffa")
		return this.result(false, "赌客摇首笑道：「这门偏门赌法老夫却是不通。」");
	if (_kind == "size" && _pick != 0 && _pick != 1)
		return this.result(false, "买大还是买小？请先择定门路。");
	if (_kind == "symbols" && !this.whole(_pick, 1, 6))
		return this.result(false, "请先在六合花旗盘上挑定一门图腾。");
	if (_kind == "hazard" && !this.whole(_pick, 5, 9))
		return this.result(false, "天门主点须从 5 至 9 点中择定一数。");
	if (this.wallet() < stake)
		return this.result(false, "行囊现银不足以押下此注。");

	if (_kind == "blackjack") return this.startBlackjack(stake);
	if (_kind == "hazard")    return this.startHazard(stake, _pick.tointeger());
	if (_kind == "riffa")     return this.playRiffa(stake);

	local dice = [];
	local cnt = (_kind == "raid") ? 4 : 3;
	for (local n = 0; n < cnt; n = ++n) dice.push(this.rand(1, 6));
	local game = { kind = _kind, stake = stake, pick = _pick, dice = dice, stage = 0 };
	this.money(-stake);

	if (_kind == "raid")
	{
		this.State.game = game;
		return this.continueRaid();
	}
	if (_kind == "size")
	{
		local sum = dice[0] + dice[1] + dice[2];
		local triple = (dice[0] == dice[1] && dice[1] == dice[2]);
		local won = !triple && (_pick == 0 ? (sum <= 10) : (sum >= 11));
		return this.finishGamble(game, won ? (stake * 2) : 0,
			"紫铜盅揭开：牛骨骰 " + dice[0] + "、" + dice[1] + "、" + dice[2] + (triple ? "——三同『豹子』庄家通杀！" : ("，合计 " + sum + " 点（" + (sum <= 10 ? "小" : "大") + "）！")));
	}

	// `symbols` (`六合花旗盘`)
	local totemNames = ["", "名剑", "藤盾", "镖旗", "斗笠", "酒坛", "鬼首"];
	local hits = 0;
	foreach (d in dice) if (d == _pick) hits += 1;
	local payouts = [0, 2, 3, 12];
	return this.finishGamble(game, stake * payouts[hits],
		"花旗三骰落定：【" + totemNames[dice[0]] + " · " + totemNames[dice[1]] + " · " + totemNames[dice[2]] + "】，命中【" + totemNames[_pick] + "】" + hits + " 枚！");
};

G.pendingGameView <- function()
{
	local game = this.State.game;
	if (game == null) return null;
	if (game.kind == "holdem") return this.holdemView(game);
	if (game.kind == "blackjack")
	{
		return {
			kind         = game.kind,
			stake        = game.stake,
			stage        = game.stage,
			player       = clone game.player,
			dealer       = [game.dealer[0]],
			dealerHidden = true,
			playerTotal  = this.cardTotal(game.player),
			canDouble    = (game.player.len() == 2 && !game.doubled && this.wallet() >= game.stake)
		};
	}
	if (game.kind == "hazard")
	{
		return {
			kind   = game.kind,
			stake  = game.stake,
			stage  = game.stage,
			main   = game.main,
			chance = game.chance,
			dice   = clone game.dice
		};
	}
	local revealed = [];
	for (local i = 0; i < game.stage; i = ++i) revealed.push(game.dice[i]);
	return {
		kind   = game.kind,
		stake  = game.stake,
		stage  = game.stage,
		payout = this.raidPayout(game),
		dice   = revealed
	};
};

// -----------------------------------------------------------------------------
// 5. Frontend Bridge Payload & Action Dispatcher (`buildCasinoView`, `handleCasinoAction`)
// -----------------------------------------------------------------------------
G.buildCasinoView <- function( _town, _message = "", _ok = true )
{
	if (!this.ensure())
		return { ok = false, message = "当前尚未载入江湖存档。" };

	local patrons = ::Wuxia.Config.Gambling.Patrons;
	local townId = (_town != null) ? _town.getID() : 0;
	local townName = (_town != null) ? _town.getName() : "迎风酒肆";
	local pIdx = (townId + this.day()) % patrons.len();
	local isHost = ("Tournament" in ::Wuxia) && (_town != null) && ::Wuxia.Tournament.isHostTown(_town);

	return {
		ok         = _ok,
		message    = _message,
		revision   = this.State.revision,
		day        = this.day(),
		money      = this.wallet(),
		townName   = townName,
		isHostTown = isHost,
		patron     = patrons[pIdx],
		tables     = ::Wuxia.Config.Gambling.Tables,
		limits     = this.betLimits(),
		game       = this.pendingGameView(),
		lastGamble = this.State.lastGamble,
		metrics    = clone this.State.metrics
	};
};

G.handleCasinoAction <- function( _data, _town )
{
	if (!this.ensure())
		return { ok = false, message = "请先踏入江湖再行博戏。" };
	if (_town == null || !_town.isAlive() || (("Tactical" in getroottable()) && ("isActive" in ::Tactical) && ::Tactical.isActive())
		|| !("State" in ::World) || ::World.State == null || ::World.State.getCurrentTown() == null
		|| ::World.State.getCurrentTown().getID() != _town.getID())
	{
		return { ok = false, closed = true, message = "你已离开酒肆赌案，纹银分毫未动。" };
	}
	if (typeof _data != "array" || _data.len() < 5 || typeof _data[0] != "string")
		return this.buildCasinoView(_town, "庄家未听清你的意思，请再道一遍。", false);

	local action = _data[0];
	if (action != "refresh" && _data[4] != this.State.revision)
		return this.buildCasinoView(_town, "案上银账刚有变动，请核对现银后再出手。", false);

	local res = this.result(true, "");
	if (action == "refresh") {}
	else if (action == "gamble")       res = this.gamble(_data[1], _data[2], _data[3]);
	else if (action == "raid_next")    res = this.continueRaid();
	else if (action == "raid_stop")    res = this.stopRaid();
	else if (action == "bj_hit")       res = this.hitBlackjack(false);
	else if (action == "bj_stand")     res = this.standBlackjack();
	else if (action == "bj_double")    res = this.hitBlackjack(true);
	else if (action == "hazard_next")  res = this.continueHazard();
	else if (action == "holdem_fold")  res = this.playHoldem("fold");
	else if (action == "holdem_call")  res = this.playHoldem("call");
	else if (action == "holdem_raise") res = this.playHoldem("raise", _data[2]);
	else if (action == "holdem_allin") res = this.playHoldem("allin");
	else res = this.result(false, "庄家摆手道：「案上无此赌例。」");

	this.save();
	if (("State" in ::World) && ::World.State != null) ::World.State.updateTopbarAssets();
	return this.buildCasinoView(_town, res.message, res.ok);
};
