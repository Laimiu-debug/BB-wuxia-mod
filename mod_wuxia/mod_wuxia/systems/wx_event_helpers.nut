// Shared helper utilities for all mod_wuxia World/Camp/Sect/Strange-Tales events.
// Keeps every event crash-safe, stash-safe, save-safe, and aligned with AGENTS.md anti-inflation rules.

::Wuxia.Events <- {};

::Wuxia.Events.isWorldReady <- function()
{
	return ("World" in getroottable()) && ::World != null
		&& ::World.State != null
		&& ::World.State.getPlayer() != null
		&& ::World.getPlayerRoster() != null;
};

::Wuxia.Events.isAlive <- function( _bro )
{
	return _bro != null && (::Wuxia.hasMember(_bro, "isAlive")) && _bro.isAlive();
};

::Wuxia.Events.getAliveBros <- function()
{
	local out = [];
	if (!::Wuxia.Events.isWorldReady()) return out;
	foreach (bro in ::World.getPlayerRoster().getAll())
	{
		if (::Wuxia.Events.isAlive(bro)) out.push(bro);
	}
	return out;
};

::Wuxia.Events.isExcluded <- function( _bro, _exclude )
{
	if (_exclude == null) return false;
	if (typeof _exclude == "array")
	{
		foreach (ex in _exclude)
		{
			if (ex != null && ex.getID() == _bro.getID()) return true;
		}
		return false;
	}
	return _exclude.getID() == _bro.getID();
};

::Wuxia.Events.shortName <- function( _bro )
{
	if (_bro == null) return "弟兄";
	if (::Wuxia.hasMember(_bro, "getNameOnly"))
	{
		local n = _bro.getNameOnly();
		if (n != null && n != "") return n;
	}
	return _bro.getName();
};

::Wuxia.Events.fmtName <- function( _bro )
{
	return "[color=#bcad8c]" + ::Wuxia.Events.shortName(_bro) + "[/color]";
};

::Wuxia.Events.findByBackgrounds <- function( _bgIDs, _exclude = null )
{
	local cands = [];
	foreach (bro in ::Wuxia.Events.getAliveBros())
	{
		if (::Wuxia.Events.isExcluded(bro, _exclude)) continue;
		local bg = bro.getBackground();
		if (bg == null) continue;
		local id = bg.getID();
		foreach (wanted in _bgIDs)
		{
			if (id == wanted)
			{
				cands.push(bro);
				break;
			}
		}
	}
	if (cands.len() == 0) return null;
	return cands[::Math.rand(0, cands.len() - 1)];
};

::Wuxia.Events.findRandomBro <- function( _exclude = null )
{
	local cands = [];
	foreach (bro in ::Wuxia.Events.getAliveBros())
	{
		if (!::Wuxia.Events.isExcluded(bro, _exclude)) cands.push(bro);
	}
	if (cands.len() == 0) return null;
	return cands[::Math.rand(0, cands.len() - 1)];
};

::Wuxia.Events.findVeteranBro <- function( _minLevel = 4, _exclude = null )
{
	local cands = [];
	foreach (bro in ::Wuxia.Events.getAliveBros())
	{
		if (::Wuxia.Events.isExcluded(bro, _exclude)) continue;
		if (bro.getLevel() >= _minLevel) cands.push(bro);
	}
	if (cands.len() == 0) return null;
	return cands[::Math.rand(0, cands.len() - 1)];
};

::Wuxia.Events.findRookieBro <- function( _maxLevel = 3, _exclude = null )
{
	local cands = [];
	foreach (bro in ::Wuxia.Events.getAliveBros())
	{
		if (::Wuxia.Events.isExcluded(bro, _exclude)) continue;
		if (bro.getLevel() <= _maxLevel) cands.push(bro);
	}
	if (cands.len() == 0) return null;
	return cands[::Math.rand(0, cands.len() - 1)];
};

::Wuxia.Events.findBroWithManual <- function( _category = null, _exclude = null )
{
	local cands = [];
	foreach (bro in ::Wuxia.Events.getAliveBros())
	{
		if (::Wuxia.Events.isExcluded(bro, _exclude)) continue;
		local c = ::Wuxia.Slots.getContainer(bro);
		if (c == null) continue;
		foreach (s in c.m.Slots)
		{
			if (s.ManualID == null || s.Tier <= 0 || s.IsFragment) continue;
			local def = ::Wuxia.Slots.getManualDef(s.ManualID);
			if (def == null) continue;
			if (_category == null || def.Category == _category)
			{
				cands.push(bro);
				break;
			}
		}
	}
	if (cands.len() == 0) return null;
	return cands[::Math.rand(0, cands.len() - 1)];
};

::Wuxia.Events.findBroWithConflict <- function()
{
	local cands = [];
	foreach (bro in ::Wuxia.Events.getAliveBros())
	{
		if (::Wuxia.Slots.hasNeigongConflict(bro)) cands.push(bro);
	}
	if (cands.len() == 0) return null;
	return cands[::Math.rand(0, cands.len() - 1)];
};

::Wuxia.Events.findBroWithFragment <- function()
{
	local cands = [];
	foreach (bro in ::Wuxia.Events.getAliveBros())
	{
		local c = ::Wuxia.Slots.getContainer(bro);
		if (c == null) continue;
		foreach (s in c.m.Slots)
		{
			if (s.ManualID != null && s.IsFragment)
			{
				cands.push(bro);
				break;
			}
		}
	}
	if (cands.len() == 0) return null;
	return cands[::Math.rand(0, cands.len() - 1)];
};

::Wuxia.Events.findBroWithMarrowWash <- function()
{
	local cands = [];
	foreach (bro in ::Wuxia.Events.getAliveBros())
	{
		local c = ::Wuxia.Slots.getContainer(bro);
		if (c != null && c.m.MarrowWashCount > 0) cands.push(bro);
	}
	if (cands.len() == 0) return null;
	return cands[::Math.rand(0, cands.len() - 1)];
};

::Wuxia.Events.findBroWithInternalStrain <- function()
{
	local cands = [];
	foreach (bro in ::Wuxia.Events.getAliveBros())
	{
		local sk = bro.getSkills();
		if (sk == null) continue;
		if (sk.hasSkill("effects.wx_scatter_weakness"))
		{
			cands.push(bro);
			continue;
		}
		local inj = sk.getSkillByID("effects.wx_internal_injury");
		if (inj != null && inj.m.Severity > 0) cands.push(bro);
	}
	if (cands.len() == 0) return null;
	return cands[::Math.rand(0, cands.len() - 1)];
};

::Wuxia.Events.findBroWithElement <- function( _element, _exclude = null )
{
	local cands = [];
	foreach (bro in ::Wuxia.Events.getAliveBros())
	{
		if (::Wuxia.Events.isExcluded(bro, _exclude)) continue;
		local c = ::Wuxia.Slots.getContainer(bro);
		if (c == null) continue;
		foreach (s in c.m.Slots)
		{
			if (s.ManualID == null || s.Tier <= 0) continue;
			local def = ::Wuxia.Slots.getManualDef(s.ManualID);
			if (def != null && def.Category == "neigong" && def.Element == _element)
			{
				cands.push(bro);
				break;
			}
		}
	}
	if (cands.len() == 0) return null;
	return cands[::Math.rand(0, cands.len() - 1)];
};

::Wuxia.Events.findWoundedBro <- function()
{
	local cands = [];
	foreach (bro in ::Wuxia.Events.getAliveBros())
	{
		if (bro.getHitpointsPct() < 0.85 || bro.getSkills().getAllSkillsOfType(::Const.SkillType.TemporaryInjury).len() > 0)
			cands.push(bro);
	}
	if (cands.len() == 0) return null;
	return cands[::Math.rand(0, cands.len() - 1)];
};

::Wuxia.Events.pickManualName <- function( _bro, _category = null )
{
	if (!::Wuxia.Events.isAlive(_bro)) return "随身武艺";
	local c = ::Wuxia.Slots.getContainer(_bro);
	if (c == null) return "随身武艺";
	local names = [];
	foreach (s in c.m.Slots)
	{
		if (s.ManualID == null || s.Tier <= 0) continue;
		local def = ::Wuxia.Slots.getManualDef(s.ManualID);
		if (def == null) continue;
		if (_category == null || def.Category == _category) names.push("《" + def.Name + "》");
	}
	if (names.len() == 0) return "随身武艺";
	return names[::Math.rand(0, names.len() - 1)];
};

::Wuxia.Events.isNearTown <- function( _dist = 3 )
{
	if (!::Wuxia.Events.isWorldReady()) return false;
	local tile = ::World.State.getPlayer().getTile();
	foreach (town in ::World.EntityManager.getSettlements())
	{
		if (town.isAlliedWithPlayer() && town.getTile().getDistanceTo(tile) <= _dist)
			return true;
	}
	return false;
};

::Wuxia.Events.isNight <- function()
{
	if (!::Wuxia.Events.isWorldReady()) return false;
	return !::World.getTime().IsDaytime;
};

::Wuxia.Events.getRegion <- function()
{
	return ::Wuxia.SectRelations.getLocalRegion();
};

::Wuxia.Events.getRegionLabel <- function( _reg = null )
{
	local r = _reg != null ? _reg : ::Wuxia.Events.getRegion();
	return ::Wuxia.SectRelations.getRegionLabel(r);
};

::Wuxia.Events.getActiveCrisis <- function()
{
	if (!::Wuxia.Events.isWorldReady() || ::World.Flags == null) return "";
	local c = ::World.Flags.get("wx_active_crisis");
	return c != null ? c : "";
};

::Wuxia.Events.pickLocalSect <- function( _alignment = null )
{
	local reg = ::Wuxia.Events.getRegion();
	local localPool = [];
	local allPool = [];
	foreach (id, sect in ::Wuxia.Config.Sects)
	{
		if (_alignment != null && (!("Alignment" in sect) || sect.Alignment != _alignment)) continue;
		allPool.push(id);
		if (("Region" in sect) && sect.Region == reg) localPool.push(id);
	}
	if (localPool.len() > 0) return localPool[::Math.rand(0, localPool.len() - 1)];
	if (allPool.len() > 0) return allPool[::Math.rand(0, allPool.len() - 1)];
	return "weiyuan";
};

::Wuxia.Events.pickSectPair <- function()
{
	local reg = ::Wuxia.Events.getRegion();
	local righteous = [];
	local outlaw = [];
	local neutral = [];
	foreach (id, sect in ::Wuxia.Config.Sects)
	{
		local al = ("Alignment" in sect) ? sect.Alignment : "neutral";
		if (al == "righteous") righteous.push(id);
		else if (al == "outlaw") outlaw.push(id);
		else neutral.push(id);
	}
	local a = righteous.len() > 0 ? righteous[::Math.rand(0, righteous.len() - 1)] : "weiyuan";
	local b = outlaw.len() > 0 ? outlaw[::Math.rand(0, outlaw.len() - 1)] : "heifeng";
	if (a == b && neutral.len() > 0) b = neutral[0];
	return [a, b];
};

::Wuxia.Events.pickHostileSect <- function( _maxRel = -15 )
{
	local cands = [];
	foreach (id, sect in ::Wuxia.Config.Sects)
	{
		if (::Wuxia.SectRelations.getRelation(id) <= _maxRel) cands.push(id);
	}
	if (cands.len() == 0) return null;
	return cands[::Math.rand(0, cands.len() - 1)];
};

::Wuxia.Events.pushList <- function( _list, _icon, _text )
{
	if (_list == null) return;
	_list.push({ id = _list.len() + 1, icon = _icon, text = _text });
};

::Wuxia.Events.addMoney <- function( _delta, _list = null )
{
	if (_delta == 0) return;
	local cur = ::World.Assets.getMoney();
	local actual = _delta < 0 ? -::Math.min(cur, -_delta) : _delta;
	if (actual == 0) return;
	::World.Assets.addMoney(actual);
	if (_list != null)
	{
		local txt = actual > 0 ? ("获得 " + actual + " 银两") : ("支出 " + (-actual) + " 银两");
		::Wuxia.Events.pushList(_list, "ui/icons/asset_money.png", txt);
	}
};

::Wuxia.Events.addMood <- function( _bro, _delta, _reason, _list = null )
{
	if (!::Wuxia.Events.isAlive(_bro) || _delta == 0) return;
	if (_delta > 0 && ::Wuxia.hasMember(_bro, "improveMood"))
		_bro.improveMood(_delta, _reason);
	else if (_delta < 0 && ::Wuxia.hasMember(_bro, "worsenMood"))
		_bro.worsenMood(-_delta, _reason);
	if (_list != null)
	{
		local icon = (::Wuxia.hasMember(_bro, "getMoodStateIcon")) ? _bro.getMoodStateIcon() : "ui/icons/special.png";
		local verb = _delta > 0 ? "心情大好" : "心生郁结";
		::Wuxia.Events.pushList(_list, icon, ::Wuxia.Events.shortName(_bro) + " " + verb + "（" + _reason + "）");
	}
};

::Wuxia.Events.addCompanyMood <- function( _delta, _reason, _list = null )
{
	local bros = ::Wuxia.Events.getAliveBros();
	if (bros.len() == 0 || _delta == 0) return;
	foreach (b in bros)
	{
		if (_delta > 0 && ::Wuxia.hasMember(b, "improveMood")) b.improveMood(_delta, _reason);
		else if (_delta < 0 && ::Wuxia.hasMember(b, "worsenMood")) b.worsenMood(-_delta, _reason);
	}
	if (_list != null)
	{
		local icon = (::Wuxia.hasMember(bros[0], "getMoodStateIcon")) ? bros[0].getMoodStateIcon() : "ui/icons/special.png";
		local verb = _delta > 0 ? "全队士气振奋" : "全队士气低落";
		::Wuxia.Events.pushList(_list, icon, verb + "（" + _reason + "）");
	}
};

::Wuxia.Events.addMastery <- function( _bro, _amount, _list = null )
{
	if (!::Wuxia.Events.isAlive(_bro) || _amount <= 0) return;
	::Wuxia.Mastery.addExpToEquipped(_bro, _amount);
	if (_list != null)
		::Wuxia.Events.pushList(_list, "ui/icons/xp_received.png", ::Wuxia.Events.shortName(_bro) + " 已修习武学获得 +" + _amount + " 火候");
};

::Wuxia.Events.addCompanyMastery <- function( _amount, _list = null )
{
	if (_amount <= 0) return;
	foreach (bro in ::Wuxia.Events.getAliveBros())
		::Wuxia.Mastery.addExpToEquipped(bro, _amount);
	if (_list != null)
		::Wuxia.Events.pushList(_list, "ui/icons/xp_received.png", "全队已装配的未满重武学获得 +" + _amount + " 火候");
};

::Wuxia.Events.addStat <- function( _bro, _statKey, _delta, _label, _icon, _list = null )
{
	if (!::Wuxia.Events.isAlive(_bro) || _delta == 0) return;
	local b = _bro.getBaseProperties();
	if (b == null || !(_statKey in b)) return;
	b[_statKey] += _delta;
	_bro.getSkills().update();
	if (_list != null)
	{
		local sign = _delta > 0 ? "+" : "";
		::Wuxia.Events.pushList(_list, _icon, ::Wuxia.Events.shortName(_bro) + " " + _label + " " + sign + _delta);
	}
};

::Wuxia.Events.addSectRel <- function( _sectID, _delta, _list = null )
{
	if (_sectID == null || !(_sectID in ::Wuxia.Config.Sects) || _delta == 0) return;
	local next = ::Wuxia.SectRelations.addRelation(_sectID, _delta);
	local sname = ::Wuxia.Config.Sects[_sectID].Name;
	if (_list != null)
	{
		local sign = _delta > 0 ? "+" : "";
		::Wuxia.Events.pushList(_list, "ui/icons/relations.png", "【" + sname + "】门派交情 " + sign + _delta + "（当前：" + next + "）");
	}
};

::Wuxia.Events.addReputation <- function( _biz, _moral, _list = null )
{
	if (_biz != 0)
	{
		::World.Assets.addBusinessReputation(_biz);
		if (_list != null)
			::Wuxia.Events.pushList(_list, "ui/icons/special.png", "江湖名望 " + (_biz > 0 ? "+" : "") + _biz);
	}
	if (_moral != 0)
	{
		::World.Assets.addMoralReputation(_moral);
		if (_list != null)
			::Wuxia.Events.pushList(_list, "ui/icons/special.png", _moral > 0 ? "侠义声名上扬" : "江湖恶名传开");
	}
};

::Wuxia.Events.addSupplies <- function( _tools, _meds, _ammo, _list = null )
{
	if (_tools != 0)
	{
		local actualT = _tools < 0 ? -::Math.min(::World.Assets.getArmorParts(), -_tools) : _tools;
		if (actualT != 0)
		{
			::World.Assets.addArmorParts(actualT);
			if (_list != null)
				::Wuxia.Events.pushList(_list, "ui/icons/asset_supplies.png", (actualT > 0 ? "获得 " : "消耗 ") + ::Math.abs(actualT) + " 修甲器械");
		}
	}
	if (_meds != 0)
	{
		local actualM = _meds < 0 ? -::Math.min(::World.Assets.getMedicine(), -_meds) : _meds;
		if (actualM != 0)
		{
			::World.Assets.addMedicine(actualM);
			if (_list != null)
				::Wuxia.Events.pushList(_list, "ui/icons/asset_medicine.png", (actualM > 0 ? "获得 " : "消耗 ") + ::Math.abs(actualM) + " 伤药补给");
		}
	}
	if (_ammo != 0)
	{
		local actualA = _ammo < 0 ? -::Math.min(::World.Assets.getAmmo(), -_ammo) : _ammo;
		if (actualA != 0)
		{
			::World.Assets.addAmmo(actualA);
			if (_list != null)
				::Wuxia.Events.pushList(_list, "ui/icons/asset_ammo.png", (actualA > 0 ? "获得 " : "消耗 ") + ::Math.abs(actualA) + " 箭矢弹药");
		}
	}
};

::Wuxia.Events.giveFood <- function( _script, _label, _list = null )
{
	local item = null;
	try { item = ::new(_script); } catch (_e) { item = null; }
	if (item == null)
	{
		try { item = ::new("scripts/items/supplies/ground_grains_item"); } catch (_e2) { item = null; }
	}
	local stash = ::World.Assets.getStash();
	if (item != null && stash != null && stash.hasEmptySlot())
	{
		stash.add(item);
		::World.Assets.updateFood();
		if (_list != null)
			::Wuxia.Events.pushList(_list, "ui/items/" + item.getIcon(), "获得口粮：" + _label);
		return true;
	}
	::Wuxia.Events.addMoney(45, _list);
	return false;
};

::Wuxia.Events.givePill <- function( _pillID, _list = null )
{
	if (!(_pillID in ::Wuxia.Config.Pills)) return false;
	local pdef = ::Wuxia.Config.Pills[_pillID];
	local pill = ::new("scripts/items/misc/wx_pill_item");
	pill.initPill(_pillID);
	local stash = ::World.Assets.getStash();
	if (stash != null && stash.hasEmptySlot())
	{
		stash.add(pill);
		if (_list != null)
			::Wuxia.Events.pushList(_list, "ui/items/" + pill.getIcon(), "获得灵药【" + pdef.Name + "】");
		return true;
	}
	::Wuxia.Events.addMoney(::Math.floor(pdef.Value * 0.5), _list);
	return false;
};

::Wuxia.Events.pickManualIDForReward <- function( _quality, _sectID = null, _needFragments = false )
{
	local pool = [];
	if (_sectID != null && (_sectID in ::Wuxia.Config.Sects))
	{
		foreach (offer in ::Wuxia.Config.Sects[_sectID].ShopManuals)
		{
			local def = ::Wuxia.Slots.getManualDef(offer.ManualID);
			if (def == null) continue;
			if (_quality != null && def.Quality != _quality) continue;
			if (_needFragments && def.FragmentsNeeded <= 0) continue;
			pool.push(def.ID);
		}
	}
	if (pool.len() == 0)
	{
		foreach (id, def in ::Wuxia.Config.Manuals)
		{
			if (_quality != null && def.Quality != _quality) continue;
			if (_needFragments && def.FragmentsNeeded <= 0) continue;
			pool.push(id);
		}
	}
	if (pool.len() == 0) return "wx_manual_qingfeng";
	return pool[::Math.rand(0, pool.len() - 1)];
};

::Wuxia.Events.givePage <- function( _quality, _count, _list = null, _sectID = null )
{
	local mid = ::Wuxia.Events.pickManualIDForReward(_quality, _sectID, true);
	local def = ::Wuxia.Slots.getManualDef(mid);
	if (def == null) return false;
	local page = ::new("scripts/items/misc/wx_page_item");
	page.initPages(mid, _count);
	local stash = ::World.Assets.getStash();
	if (stash != null && stash.hasEmptySlot())
	{
		stash.add(page);
		if (_list != null)
			::Wuxia.Events.pushList(_list, "ui/items/" + page.getIcon(), "获得《" + def.Name + "》残页 ×" + _count);
		return true;
	}
	::Wuxia.Events.addMoney(220 * _count, _list);
	return false;
};

::Wuxia.Events.giveManual <- function( _quality, _list = null, _sectID = null )
{
	local mid = ::Wuxia.Events.pickManualIDForReward(_quality, _sectID, false);
	local def = ::Wuxia.Slots.getManualDef(mid);
	if (def == null) return false;
	local book = ::new("scripts/items/misc/wx_manual_item");
	book.initManual(mid);
	local stash = ::World.Assets.getStash();
	if (stash != null && stash.hasEmptySlot())
	{
		stash.add(book);
		if (_list != null)
			::Wuxia.Events.pushList(_list, "ui/items/" + book.getIcon(), "获得完整秘籍《" + def.Name + "》");
		return true;
	}
	::Wuxia.Events.addMoney(260, _list);
	return false;
};

::Wuxia.Events.giveItem <- function( _scriptPath, _list = null )
{
	local item = null;
	try { item = ::new(_scriptPath); } catch (_e) { item = null; }
	if (item == null)
	{
		::Wuxia.Events.addMoney(160, _list);
		return false;
	}
	local stash = ::World.Assets.getStash();
	if (stash != null && stash.hasEmptySlot())
	{
		stash.add(item);
		if (_list != null)
			::Wuxia.Events.pushList(_list, "ui/items/" + item.getIcon(), "获得物品：" + item.getName());
		return true;
	}
	::Wuxia.Events.addMoney(::Math.max(80, ::Math.floor(item.getValue() * 0.4)), _list);
	return false;
};

::Wuxia.Events.applyInternalStrain <- function( _bro, _days, _list = null )
{
	if (!::Wuxia.Events.isAlive(_bro)) return;
	local sk = _bro.getSkills();
	local inj = sk.getSkillByID("effects.wx_internal_injury");
	if (inj == null)
	{
		inj = ::new("scripts/skills/effects/wx_internal_injury");
		sk.add(inj);
	}
	inj.applySeverity(1, _days);
	sk.update();
	if (_list != null)
		::Wuxia.Events.pushList(_list, "ui/icons/fatigue.png", ::Wuxia.Events.shortName(_bro) + " 真气岔乱，染上轻度内伤（" + _days + " 日）");
};

::Wuxia.Events.cureInternalStrain <- function( _bro, _list = null )
{
	if (!::Wuxia.Events.isAlive(_bro)) return;
	local sk = _bro.getSkills();
	sk.removeByID("effects.wx_scatter_weakness");
	local inj = sk.getSkillByID("effects.wx_internal_injury");
	if (inj != null && inj.m.Severity > 0) inj.cureTemporary();
	sk.update();
	if (_list != null)
		::Wuxia.Events.pushList(_list, "ui/icons/health.png", ::Wuxia.Events.shortName(_bro) + " 体内散功虚弱与临时内伤尽数化去");
};

::Wuxia.Events.applyLightHurt <- function( _bro, _pctDmg, _list = null )
{
	if (!::Wuxia.Events.isAlive(_bro)) return;
	local dmg = ::Math.max(5, ::Math.floor(_bro.getHitpointsMax() * _pctDmg));
	local nextHp = ::Math.max(15, _bro.getHitpoints() - dmg);
	_bro.setHitpoints(nextHp);
	if (_list != null)
		::Wuxia.Events.pushList(_list, "ui/icons/health.png", ::Wuxia.Events.shortName(_bro) + " 负伤损血（当前气血 " + nextHp + "/" + _bro.getHitpointsMax() + "）");
};

::Wuxia.Events.healBro <- function( _bro, _pctHeal, _list = null )
{
	if (!::Wuxia.Events.isAlive(_bro)) return;
	local heal = ::Math.max(8, ::Math.floor(_bro.getHitpointsMax() * _pctHeal));
	local nextHp = ::Math.min(_bro.getHitpointsMax(), _bro.getHitpoints() + heal);
	_bro.setHitpoints(nextHp);
	if (_list != null)
		::Wuxia.Events.pushList(_list, "ui/icons/health.png", ::Wuxia.Events.shortName(_bro) + " 调养恢复气血（当前 " + nextHp + "/" + _bro.getHitpointsMax() + "）");
};
