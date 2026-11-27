//《山海经》64 尊大妖逐只原典法则与专属几何凶招执行引擎 ("一妖一法相 · 一战一考题")
// Zero generic template permutations! Every single one of the 64 Bosses has bespoke scripture-derived combat logic.

if (!("ShanHaiBossSpecs" in ::Wuxia)) ::Wuxia.ShanHaiBossSpecs <- {};
if (!("ShanHaiBossMoves" in ::Wuxia)) ::Wuxia.ShanHaiBossMoves <- {};

::Wuxia.ShanHaiBossLaws <- {};

// ----------------------------------------------------------------------------
// Weapon & Element Counterplay Classifiers
// ----------------------------------------------------------------------------
::Wuxia.ShanHaiBossLaws.isOrificeChiselStrike <- function( _attacker, _skill )
{
	if (_skill != null && ::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null)
	{
		local sid = _skill.getID();
		if (sid.find("acupoint") != null || sid.find("yiyang") != null || sid.find("canhe") != null
			|| sid.find("nianhua") != null || sid.find("dagger") != null || sid.find("pierce") != null
			|| sid.find("cuixin") != null || sid.find("duoming") != null || sid.find("qinggang") != null
			|| sid.find("dugu") != null || sid.find("faqiu") != null || sid.find("jinzhen") != null)
			return true;
	}
	if (_attacker != null && ::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
	{
		local w = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
		if (w != null && ::Wuxia.CombatRules.matchesWeapon(w, ["Dagger", "Spear"]))
			return true;
	}
	return false;
};

::Wuxia.ShanHaiBossLaws.isShellCrackerStrike <- function( _attacker, _skill )
{
	if (_skill != null && ::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null)
	{
		local sid = _skill.getID();
		if (sid.find("hammer_") != null || sid == "actives.wx_sword_zhongjian" || sid == "actives.wx_fist_shock"
			|| sid == "actives.wx_fist_xianglong" || sid == "actives.wx_fist_jingang" || sid == "actives.wx_staff_weituo")
			return true;
		if ("CraftBridge" in ::Wuxia && ::Wuxia.CraftBridge.hasSkillMechanic(_skill, "concuss_armor"))
			return true;
	}
	if (_attacker != null && ::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
	{
		local w = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
		if (w != null && ::Wuxia.CombatRules.matchesWeapon(w, ["Hammer", "Mace", "Staff"]))
			return true;
	}
	return false;
};

::Wuxia.ShanHaiBossLaws.isAxeWoodCutter <- function( _attacker, _skill )
{
	if (_skill != null && ::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null)
	{
		local sid = _skill.getID();
		if (sid.find("wx_axe_") != null || sid == "actives.split_shield" || sid == "actives.wx_saber_chiyou")
			return true;
	}
	if (_attacker != null && ::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
	{
		local w = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
		if (w != null && ::Wuxia.CombatRules.matchesWeapon(w, ["Axe"]))
			return true;
	}
	return false;
};

::Wuxia.ShanHaiBossLaws.isBladeSeverStrike <- function( _attacker, _skill )
{
	if (_skill != null && ::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null)
	{
		local sid = _skill.getID();
		if (sid.find("wx_sword_") != null || sid.find("wx_saber_") != null || sid.find("wx_axe_") != null || sid.find("wx_pole_") != null)
			return true;
	}
	if (_attacker != null && ::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
	{
		local w = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
		if (w != null && ::Wuxia.CombatRules.matchesWeapon(w, ["Sword", "Saber", "Cleaver", "Axe", "Polearm"]))
			return true;
	}
	return false;
};

::Wuxia.ShanHaiBossLaws.isRangedOrPinpointStrike <- function( _attacker, _skill )
{
	if (_skill != null)
	{
		if (::Wuxia.hasMember(_skill, "isRanged") && _skill.isRanged()) return true;
		if (::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null)
		{
			local sid = _skill.getID();
			if (sid.find("wx_bow_") != null || sid.find("wx_crossbow_") != null || sid.find("wx_throw_") != null
				|| sid.find("wx_gun_") != null || sid.find("yiyang") != null || sid.find("canhe") != null
				|| sid.find("acupoint") != null || sid.find("jinzhen") != null)
				return true;
		}
	}
	return false;
};

::Wuxia.ShanHaiBossLaws.isYinOrFrostStrike <- function( _attacker, _skill )
{
	if (_skill != null && ::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null)
	{
		local sid = _skill.getID();
		if (sid.find("hanbing") != null || sid.find("xuanming") != null || sid.find("xuanbing") != null
			|| sid.find("xuelong") != null || sid.find("xuelian") != null)
			return true;
	}
	return _attacker != null && ::Wuxia.TileField.getPrimaryNeigongElement(_attacker) == "yin";
};

::Wuxia.ShanHaiBossLaws.isQiDispelStrike <- function( _skill )
{
	if (_skill == null || !::Wuxia.hasMember(_skill, "getID") || _skill.getID() == null) return false;
	local sid = _skill.getID();
	return sid == "actives.wx_sword_dugu" || sid == "actives.wx_fist_yiyang" || sid.find("xixing") != null
		|| sid.find("acupoint") != null || sid.find("guigu") != null || sid.find("bamen") != null;
};

::Wuxia.ShanHaiBossLaws.countAdjacentEnemies <- function( _actor )
{
	if (!::Wuxia.isOnMap(_actor)) return 0;
	local mt = _actor.getTile();
	local cnt = 0;
	for (local d = 0; d < 6; d = ++d)
	{
		if (!mt.hasNextTile(d)) continue;
		local nt = mt.getNextTile(d);
		if (nt != null && nt.IsOccupiedByActor && nt.getEntity() != null && nt.getEntity().isAlive() && !_actor.isAlliedWith(nt.getEntity()))
			cnt += 1;
	}
	return cnt;
};

::Wuxia.ShanHaiBossLaws.isFrontalArc <- function( _boss, _other )
{
	if (!::Wuxia.isOnMap(_boss) || !::Wuxia.isOnMap(_other)) return true;
	local dir = _boss.getTile().getDirectionTo(_other.getTile());
	return (dir == 0 || dir == 1 || dir == 5);
};

// Check & advance 1-Hex Boss internal organ/shield/horn counter-break (`InternalBreakMode`)
::Wuxia.ShanHaiBossLaws.checkInternalCounterBreak <- function( _trait, _actor, _spec, _attacker, _skill )
{
	if (_trait.m.InternalBroken || _trait.m.InternalBreakMax <= 0 || !("InternalBreakMode" in _spec)) return false;
	local mode = _spec.InternalBreakMode;
	local matched = false;
	local pts = 1;
	local sid = (_skill != null && ::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null) ? _skill.getID() : "";

	if (mode == "axe")
	{
		matched = ::Wuxia.ShanHaiBossLaws.isAxeWoodCutter(_attacker, _skill);
		if (sid == "actives.split_shield" || sid == "actives.wx_axe_kaitian") pts = 2;
	}
	else if (mode == "blunt")
	{
		matched = ::Wuxia.ShanHaiBossLaws.isShellCrackerStrike(_attacker, _skill);
		if (sid.find("hammer_") != null || sid == "actives.wx_sword_zhongjian") pts = 2;
	}
	else if (mode == "blunt_or_axe")
	{
		matched = ::Wuxia.ShanHaiBossLaws.isShellCrackerStrike(_attacker, _skill) || ::Wuxia.ShanHaiBossLaws.isAxeWoodCutter(_attacker, _skill);
	}
	else if (mode == "ranged_or_acupoint")
	{
		matched = ::Wuxia.ShanHaiBossLaws.isRangedOrPinpointStrike(_attacker, _skill) || ::Wuxia.ShanHaiBossLaws.isOrificeChiselStrike(_attacker, _skill);
	}
	else if (mode == "blade")
	{
		matched = ::Wuxia.ShanHaiBossLaws.isBladeSeverStrike(_attacker, _skill);
	}
	else if (mode == "blade_or_ranged")
	{
		matched = ::Wuxia.ShanHaiBossLaws.isBladeSeverStrike(_attacker, _skill) || ::Wuxia.ShanHaiBossLaws.isRangedOrPinpointStrike(_attacker, _skill);
	}

	if (matched)
	{
		_trait.m.InternalBreakPts += pts;
		if (_trait.m.InternalBreakPts >= _trait.m.InternalBreakMax)
		{
			_trait.markInternalPartBroken(_actor);
			return true;
		}
	}
	return false;
};

// ============================================================================
// 1. Turn-Start Mythic Laws (`onBossTurnStart`)
// ============================================================================
::Wuxia.ShanHaiBossLaws.onBossTurnStart <- function( _trait, _actor, _spec )
{
	local key = _trait.m.BossKey;
	local sk = _actor.getSkills();
	local regenSealed = (sk != null && sk.hasSkill("effects.wx_status_regen_seal"));

	// Conditional Mythic Regeneration (each regenerating Boss has a strict canon condition!)
	if (!regenSealed && ("RegenHP" in _spec) && _spec.RegenHP > 0 && _actor.getHitpoints() < _actor.getHitpointsMax())
	{
		local amt = _spec.RegenHP;
		local canRegen = true;
		if (key == "jumang")
		{
			local roots = _trait.countAliveTotems(_actor);
			canRegen = (roots > 0);
			amt = roots * 8;
		}
		else if (key == "shebishi")
		{
			local snakes = (!_trait.isPartBroken("snake_l") ? 1 : 0) + (!_trait.isPartBroken("snake_r") ? 1 : 0);
			canRegen = (snakes > 0);
			amt = snakes * 13;
		}
		else if (key == "zhujian")
		{
			canRegen = (!_trait.m.MovedLastTurn && !_trait.m.InternalBroken);
		}
		else if (key == "zhuyan")
		{
			canRegen = (::Wuxia.isOnMap(_actor) && ::Wuxia.TileField.hasField(_actor.getTile(), "blood_pool"));
		}
		else if (key == "chenghuang")
		{
			canRegen = (!_trait.m.InternalBroken);
		}
		if (canRegen && amt > 0)
		{
			if (sk != null && (sk.hasSkill("effects.wx_status_poison_dart") || sk.hasSkill("effects.spider_poison")))
				amt = ::Math.max(4, amt / 3);
			_actor.setHitpoints(::Math.min(_actor.getHitpointsMax(), _actor.getHitpoints() + amt));
		}
	}

	// 1. Xingxing《知人名》: Calls out highest-MeleeSkill living fighter!
	if (key == "xingxing" && ::Wuxia.TileField.isLiveTactical())
	{
		local bestID = -1;
		local bestMS = -999;
		foreach (u in ::Tactical.Entities.getAllInstancesAsArray())
		{
			if (u == null || !u.isAlive() || _actor.isAlliedWith(u)) continue;
			if (::Wuxia.hasMember(u, "getCurrentProperties"))
			{
				local ms = u.getCurrentProperties().MeleeSkill;
				if (ms > bestMS) { bestMS = ms; bestID = u.getID(); }
			}
		}
		_trait.m.NamedPreyID = bestID;
	}
	// 2. Jiuying《水火九首》: Odd round frost mist, Even round drought scorch -> overlap triggers steam shock!
	else if (key == "jiuying" && ::Wuxia.isOnMap(_actor))
	{
		local mt = _actor.getTile();
		local odd = (_trait.m.RoundCount % 2 == 1);
		if (odd && !_trait.isPartBroken("water_head"))
			::Wuxia.TileField.setField(mt, "abyss_frost", 2, _actor);
		else if (!odd && !_trait.isPartBroken("fire_head"))
			::Wuxia.TileField.setField(mt, "drought_scorch", 2, _actor);
	}
	// 3. Luwu《司天九部·春夏秋冬四时轮转》
	else if (key == "luwu")
	{
		_trait.m.SeasonIdx = (_trait.m.RoundCount - 1) % 4;
		if (_trait.m.SeasonIdx == 0 && !regenSealed && _actor.getHitpoints() < _actor.getHitpointsMax())
			_actor.setHitpoints(::Math.min(_actor.getHitpointsMax(), _actor.getHitpoints() + 24));
	}
	// 4. Feiyi《太华天下大旱》: Heatwave drains Qi scaling with active drought_scorch tiles!
	else if (key == "feiyi" && !_trait.isPartBroken("six_leg_body") && ::Wuxia.TileField.isLiveTactical() && ::Wuxia.isOnMap(_actor))
	{
		local scorchCnt = ::Wuxia.TileField.getFieldsByKind("drought_scorch").len();
		local qDrain = ::Math.min(10, 2 + scorchCnt * 2);
		foreach (u in ::Tactical.Entities.getAllInstancesAsArray())
		{
			if (u == null || !u.isAlive() || _actor.isAlliedWith(u) || !::Wuxia.isOnMap(u)) continue;
			if (_actor.getTile().getDistanceTo(u.getTile()) <= 2 && !::Wuxia.CombatRules.isUndeadOrConstruct(u))
				u.setFatigue(::Math.min(u.getFatigueMax(), u.getFatigue() + qDrain));
		}
	}
	// 5. Kuafu《逐日大渴》: Peach staffs evaporate enemy Qi; if both chopped down, Kuafu suffers thirst exhaustion!
	else if (key == "kuafu" && ::Wuxia.TileField.isLiveTactical() && ::Wuxia.isOnMap(_actor))
	{
		if (_trait.countAliveTotems(_actor) > 0)
		{
			foreach (u in ::Tactical.Entities.getAllInstancesAsArray())
			{
				if (u == null || !u.isAlive() || _actor.isAlliedWith(u) || !::Wuxia.isOnMap(u)) continue;
				if (_actor.getTile().getDistanceTo(u.getTile()) <= 3 && !::Wuxia.CombatRules.isUndeadOrConstruct(u))
					u.setFatigue(::Math.min(u.getFatigueMax(), u.getFatigue() + 6));
			}
		}
	}
	// 6. Jinwu《十日浴扶桑》: Living Fusang Suns charge solar stacks (`LawStacks` 0..3)
	else if (key == "jinwu")
	{
		if (_trait.countAliveTotems(_actor) > 0)
			_trait.m.LawStacks = ::Math.min(3, _trait.m.LawStacks + 1);
		else
			_trait.m.LawStacks = 0;
	}
	// 7. Bo《音如战鼓·御兵修甲》: Restores +20 Body Armor each round while spiral horn is intact!
	else if (key == "bo" && !_trait.m.InternalBroken && ::Wuxia.hasMember(_actor, "m") && ("BaseProperties" in _actor.m))
	{
		local curA = _actor.getArmor(::Const.BodyPart.Body);
		local maxA = _actor.m.BaseProperties.ArmorMax[0];
		if (curA < maxA && ("Armor" in _actor.m.BaseProperties))
			_actor.m.BaseProperties.Armor[0] = ::Math.min(maxA, curA + 20);
	}
	// 8. Fei《行水则竭·行草则死》: Wither aura saps 6 Qi & strips regeneration within 3 hexes!
	else if (key == "fei" && ::Wuxia.TileField.isLiveTactical() && ::Wuxia.isOnMap(_actor))
	{
		foreach (u in ::Tactical.Entities.getAllInstancesAsArray())
		{
			if (u == null || !u.isAlive() || _actor.isAlliedWith(u) || !::Wuxia.isOnMap(u)) continue;
			if (_actor.getTile().getDistanceTo(u.getTile()) <= 3 && !::Wuxia.CombatRules.isUndeadOrConstruct(u))
				u.setFatigue(::Math.min(u.getFatigueMax(), u.getFatigue() + 6));
		}
	}
	// 9. Chenghuang《乘之寿二千岁》: Siphons 8 Qi from adjacent foes into amber longevity ward!
	else if (key == "chenghuang" && ::Wuxia.isOnMap(_actor))
	{
		local adj = ::Wuxia.ShanHaiBossLaws.countAdjacentEnemies(_actor);
		if (adj > 0 && !_trait.m.InternalBroken)
		{
			_trait.m.LawStacks = ::Math.min(3, adj);
			if (::Wuxia.TileField.isLiveTactical())
			{
				for (local d = 0; d < 6; d = ++d)
				{
					if (!_actor.getTile().hasNextTile(d)) continue;
					local nt = _actor.getTile().getNextTile(d);
					if (nt != null && nt.IsOccupiedByActor && nt.getEntity() != null && !_actor.isAlliedWith(nt.getEntity()))
					{
						local e = nt.getEntity();
						if (!::Wuxia.CombatRules.isUndeadOrConstruct(e))
							e.setFatigue(::Math.min(e.getFatigueMax(), e.getFatigue() + 8));
					}
				}
			}
		}
		else
		{
			_trait.m.LawStacks = 0;
		}
	}
	// 10. Huodou《食火吞炭》: Standing on `drought_scorch` heals Huodou +18 HP!
	else if (key == "huodou" && !regenSealed && ::Wuxia.isOnMap(_actor) && ::Wuxia.TileField.hasField(_actor.getTile(), "drought_scorch"))
	{
		_actor.setHitpoints(::Math.min(_actor.getHitpointsMax(), _actor.getHitpoints() + 18));
	}
};

// ============================================================================
// 2. Dynamic Stat & Stance Laws (`onBossUpdate`)
// ============================================================================
::Wuxia.ShanHaiBossLaws.onBossUpdate <- function( _trait, _actor, _spec, _properties )
{
	local key = _trait.m.BossKey;

	// Group III (10 Totem Lords): Domain ward scales with surviving totems
	if (_spec.StructureMode == "totems" && ("TotemShieldPerUnit" in _spec) && _spec.TotemShieldPerUnit > 0.0 && _actor != null)
	{
		local aliveT = _trait.countAliveTotems(_actor);
		if (aliveT > 0)
		{
			local mult = ::Math.maxf(0.38, 1.0 - ::Math.minf(0.60, aliveT * _spec.TotemShieldPerUnit));
			_properties.DamageReceivedRegularMult *= mult;
		}
	}

	// Bespoke per-Boss Passive/Stance Updates:
	if (key == "bifang" && _actor != null)
	{
		local onScorch = ::Wuxia.isOnMap(_actor) && ::Wuxia.TileField.hasField(_actor.getTile(), "drought_scorch");
		if (onScorch && !_properties.IsRooted) { _properties.MeleeDefense += 18; _properties.RangedDefense += 24; }
		else if (_properties.IsRooted || !onScorch) { _properties.MeleeDefense -= 14; }
	}
	else if (key == "zhujian")
	{
		if (!_trait.m.InternalBroken)
		{
			if (_trait.m.MovedLastTurn) { _properties.MeleeSkill += 14; _properties.DamageTotalMult *= 1.20; }
			else { _properties.DamageReceivedRegularMult *= 0.72; _properties.MeleeDefense += 10; }
		}
		else { _properties.MeleeDefense -= 10; }
	}
	else if (key == "boshi" && _actor != null)
	{
		if (!_trait.m.InternalBroken)
		{
			local sur = ::Wuxia.ShanHaiBossLaws.countAdjacentEnemies(_actor);
			_properties.MeleeDefense += 12 + sur * 5;
			_properties.MeleeSkill += sur * 5;
		}
		else { _properties.MeleeDefense -= 16; }
	}
	else if (key == "xuangui")
	{
		if (_trait.m.InternalBroken) _properties.MeleeDefense -= 18;
		else _properties.MeleeDefense += 10;
	}
	else if (key == "zhuyan")
	{
		if (_trait.m.LawStacks > 0)
		{
			_properties.MeleeSkill += _trait.m.LawStacks * 3;
			_properties.DamageTotalMult *= (1.0 + 0.04 * _trait.m.LawStacks);
		}
	}
	else if (key == "yingzhao" && _actor != null)
	{
		local blockers = ::Wuxia.ShanHaiBossLaws.countAdjacentEnemies(_actor);
		if (blockers >= 2) { _properties.MeleeDefense -= 14; _properties.DamageReceivedRegularMult *= 1.20; }
		else { _properties.MeleeSkill += 14; _properties.DamageTotalMult *= 1.18; }
	}
	else if (key == "luwu")
	{
		local s = _trait.m.SeasonIdx % 4;
		if (s == 1) _properties.DamageArmorMult *= 1.25;
		else if (s == 2) { _properties.MeleeSkill += 16; _properties.DamageTotalMult *= 1.18; }
		else if (s == 3) { _properties.DamageReceivedRegularMult *= 0.72; _properties.MeleeDefense += 12; }
	}
	else if (key == "qinyuan" && _actor != null)
	{
		if (!_trait.m.InternalBroken && !_properties.IsRooted)
		{
			_properties.MeleeDefense += 18;
			_properties.DamageReceivedMeleeMult *= 0.75;
		}
		else { _properties.MeleeDefense -= 14; _properties.ActionPoints = 8; }
	}
	else if (key == "hundun" && _trait.m.OrificeRuptured)
	{
		_properties.MeleeDefense -= 16;
	}
	else if (key == "jiao" && _trait.m.LawStacks > 0)
	{
		_properties.MeleeSkill += _trait.m.LawStacks * 4;
		_properties.MeleeDefense += _trait.m.LawStacks * 4;
	}
	else if (key == "paoxiaowang")
	{
		if (!_trait.m.InternalBroken && !_trait.m.BellyExposed) _properties.MeleeDefense += 14;
		else if (_trait.m.InternalBroken) _properties.MeleeDefense -= 14;
	}
	else if (key == "changyou")
	{
		if (_trait.m.DeafenedTurns <= 0) _properties.RangedDefense += 26;
		else { _properties.RangedDefense -= 12; _properties.MeleeDefense -= 10; }
	}
	else if (key == "mengji" && _actor != null)
	{
		local inMist = ::Wuxia.isOnMap(_actor) && ::Wuxia.TileField.hasField(_actor.getTile(), "mirage_mist");
		if (inMist) { _properties.MeleeDefense += 18; _properties.RangedDefense += 22; }
		else { _properties.MeleeDefense -= 10; }
	}
	else if (key == "yinglong" && _actor != null)
	{
		local onRiver = ::Wuxia.isOnMap(_actor) && ::Wuxia.TileField.hasField(_actor.getTile(), "abyss_frost");
		if (onRiver) { _properties.MeleeDefense += 14; _properties.DamageTotalMult *= 1.18; }
		else if (::Wuxia.isOnMap(_actor) && ::Wuxia.TileField.hasField(_actor.getTile(), "drought_scorch")) _properties.MeleeDefense -= 12;
	}
	else if (key == "taowu" && _actor != null && ::Wuxia.hasMember(_actor, "getHitpointsPct"))
	{
		local lostSteps = ::Math.floor((1.0 - _actor.getHitpointsPct()) / 0.18);
		if (lostSteps > 0)
		{
			_properties.MeleeSkill += lostSteps * 5;
			_properties.DamageTotalMult *= (1.0 + 0.08 * lostSteps);
		}
	}
	else if (key == "dangkang" && _actor != null)
	{
		if (!_trait.m.InternalBroken && _actor.getArmor(::Const.BodyPart.Body) > 80)
			_properties.DamageReceivedRegularMult *= 0.65;
		else if (_trait.m.InternalBroken)
			_properties.MeleeDefense -= 12;
	}
	else if (key == "wuzhiqi" && _actor != null && ::Wuxia.hasMember(_actor, "getHitpointsPct"))
	{
		local sk = _actor.getSkills();
		local suppressed = _properties.IsRooted || (sk != null && sk.hasSkill("effects.wx_status_acupoint"));
		if (suppressed) { _properties.MeleeDefense -= 15; _properties.ActionPoints = 7; }
		else if (_actor.getHitpointsPct() <= 0.55) { _properties.ActionPoints = 11; _properties.MeleeSkill += 15; _properties.DamageTotalMult *= 1.24; }
	}
	else if (key == "feilian" && _actor != null)
	{
		local onGale = ::Wuxia.isOnMap(_actor) && ::Wuxia.TileField.hasField(_actor.getTile(), "gale_sand");
		if (onGale && !_properties.IsRooted) { _properties.RangedDefense += 28; _properties.MeleeDefense += 12; }
	}
	else if (key == "shanhui" && _actor != null)
	{
		if (::Wuxia.ShanHaiBossLaws.countAdjacentEnemies(_actor) > 0) _properties.MeleeDefense -= 14;
		else _properties.RangedDefense += 20;
	}
	else if (key == "huashe" && _actor != null)
	{
		if (!_trait.isPartBroken("frost_wing_body") && ::Wuxia.isOnMap(_actor) && ::Wuxia.TileField.hasField(_actor.getTile(), "abyss_frost"))
			_properties.MeleeDefense += 15;
		else if (_trait.isPartBroken("frost_wing_body"))
			_properties.MeleeDefense -= 14;
	}
	else if (key == "kuafu" && _actor != null)
	{
		if (_trait.countAliveTotems(_actor) <= 0) { _properties.MeleeSkill -= 15; _properties.MeleeDefense -= 12; }
	}
	else if (key == "chiyou" && _actor != null)
	{
		if (_trait.isTotemKeyAlive(_actor, "armory_ge"))  _properties.MeleeDefense += 12;
		if (_trait.isTotemKeyAlive(_actor, "armory_yue")) _properties.DamageArmorMult *= 1.25;
		if (_trait.isTotemKeyAlive(_actor, "armory_nu"))  { _properties.MeleeSkill += 12; _properties.RangedDefense += 14; }
	}
	else if (key == "zaochi")
	{
		if (!_trait.m.InternalBroken) { _properties.MeleeDefense += 14; _properties.RangedDefense += 28; }
		else { _properties.MeleeDefense -= 12; _properties.RangedDefense -= 15; }
	}
	else if (key == "erfu" && _actor != null)
	{
		if (_trait.m.NirvanaUsed || _trait.m.InternalBroken)
		{
			_properties.ActionPoints = 10;
			_properties.MeleeSkill += 16;
			_properties.DamageTotalMult *= 1.22;
		}
		else
		{
			_properties.DamageReceivedRegularMult *= 0.72;
		}
	}
	else if (key == "kaiming" && _actor != null)
	{
		local heads = ::Wuxia.ShanHaiMultiBody.getAliveAppendageCount(_actor);
		_properties.MeleeDefense += heads * 7;
	}
	else if (key == "jinwu" && _trait.m.LawStacks > 0)
	{
		_properties.DamageTotalMult *= (1.0 + 0.10 * _trait.m.LawStacks);
	}
	else if (key == "chenghuang" && _trait.m.LawStacks > 0 && !_trait.m.InternalBroken)
	{
		_properties.DamageReceivedRegularMult *= 0.65;
	}
};

// ============================================================================
// 3. Target-Specific Offensive Laws (`onBossSkillUsed`)
// ============================================================================
::Wuxia.ShanHaiBossLaws.onBossSkillUsed <- function( _trait, _actor, _spec, _skill, _target, _properties )
{
	if (_target == null || !_target.isAlive()) return;
	local key = _trait.m.BossKey;
	local tsk = ::Wuxia.hasMember(_target, "getSkills") ? _target.getSkills() : null;

	// Qiongqi《毁信恶忠·惩善助恶》: Crushes high-Resolve righteous heroes, spares low-Resolve rogues!
	if (key == "qiongqi" && ::Wuxia.hasMember(_target, "getCurrentProperties"))
	{
		local brv = _target.getCurrentProperties().Bravery;
		if (brv >= 65) { _properties.MeleeSkill += 15; _properties.DamageTotalMult *= 1.25; }
		else if (brv < 50) { _properties.MeleeSkill -= 10; _properties.DamageTotalMult *= 0.82; }
	}
	// Gudiaowang《泽更婴啼·乘怯噬魂》: Executes wavering or low-Resolve prey!
	else if (key == "gudiaowang" && ::Wuxia.hasMember(_target, "getCurrentProperties"))
	{
		local lowBrv = _target.getCurrentProperties().Bravery < 55;
		local wavering = ::Wuxia.hasMember(_target, "getMoraleState") && _target.getMoraleState() <= ::Const.MoraleState.Wavering;
		if (lowBrv || wavering)
		{
			_properties.MeleeSkill += 16;
			_properties.DamageTotalMult *= 1.26;
			_properties.DamageDirectAdd = ::Math.minf(0.25, _properties.DamageDirectAdd + 0.10);
		}
	}
	// Tiangouwang《天狗食月·噬孤星》: +32% execution dmg vs isolated heroes (0 adjacent allies)!
	else if (key == "tiangouwang")
	{
		local hasBuddy = false;
		if (::Wuxia.isOnMap(_target))
		{
			local tt = _target.getTile();
			for (local d = 0; d < 6; d = ++d)
			{
				if (!tt.hasNextTile(d)) continue;
				local nt = tt.getNextTile(d);
				if (nt != null && nt.IsOccupiedByActor && nt.getEntity() != null && nt.getEntity().isAlive() && _target.isAlliedWith(nt.getEntity()))
				{
					hasBuddy = true;
					break;
				}
			}
		}
		if (!hasBuddy) { _properties.MeleeSkill += 16; _properties.DamageTotalMult *= 1.32; }
		else { _properties.DamageTotalMult *= 0.84; }
	}
	// Mengji《石者善伏》: +28% ambush crit vs Opening or Offbalance
	else if (key == "mengji" && tsk != null)
	{
		if (tsk.hasSkill("effects.wx_status_opening") || tsk.hasSkill("effects.wx_status_offbalance"))
			_properties.DamageTotalMult *= 1.28;
	}
	// Bashe《三岁吐骨箭》: Consumes digested elephant-bone stacks (`LawStacks`)!
	else if (key == "bashe" && _trait.m.LawStacks > 0 && ::Wuxia.hasMember(_skill, "getID") && _skill.getID() == "actives.wx_boss_bashe_bone_spit")
	{
		_properties.DamageTotalMult *= (1.0 + 0.22 * _trait.m.LawStacks);
		_properties.DamageArmorMult *= (1.0 + 0.15 * _trait.m.LawStacks);
	}
	// Hujiao《毒涧缠绞》: +25% dmg vs poisoned targets
	else if (key == "hujiao" && tsk != null && (tsk.hasSkill("effects.wx_status_poison_dart") || tsk.hasSkill("effects.spider_poison")))
	{
		_properties.DamageTotalMult *= 1.25;
	}
	// Zhuhuai《鸣雁嗜血》: +22% dmg vs bleeding prey
	else if (key == "zhuhuai" && tsk != null && tsk.hasSkill("effects.bleeding"))
	{
		_properties.MeleeSkill += 14;
		_properties.DamageTotalMult *= 1.22;
	}
	// Gonggong《天倾西北·水潦归低》: Crushes low-elevation or frost-soaked targets; high ground resists!
	else if (key == "gonggong" && ::Wuxia.isOnMap(_actor) && ::Wuxia.isOnMap(_target))
	{
		local myLv = _actor.getTile().Level;
		local tLv  = _target.getTile().Level;
		if (tLv > myLv) _properties.DamageTotalMult *= 0.75;
		else if (tLv < myLv || ::Wuxia.TileField.hasField(_target.getTile(), "abyss_frost")) _properties.DamageTotalMult *= 1.25;
	}
	// Zouyu《林氏仁虎·不杀降卒》: Spares wavering units, punishes confident champions!
	else if (key == "zouyu")
	{
		local wav = ::Wuxia.hasMember(_target, "getMoraleState") && _target.getMoraleState() <= ::Const.MoraleState.Wavering;
		if (wav) _properties.DamageTotalMult *= 0.65;
		else if (::Wuxia.hasMember(_target, "getCurrentProperties") && _target.getCurrentProperties().MeleeSkill >= 75)
			_properties.MeleeSkill += 14;
	}
	// Wuluo《穿耳鸣玉·乱息绝脉》: Scales direct damage with target's current Fatigue!
	else if (key == "wuluo" && !_trait.m.InternalBroken && ::Wuxia.hasMember(_target, "getFatigue"))
	{
		local fat = _target.getFatigue();
		if (fat >= 40) _properties.DamageTotalMult *= 1.24;
	}
};

// ============================================================================
// 4. Defensive & Counterplay Puzzle Laws (`onBossBeforeDamage`)
// ============================================================================
::Wuxia.ShanHaiBossLaws.onBossBeforeDamage <- function( _trait, _actor, _spec, _attacker, _skill, _hitInfo, _properties )
{
	local key = _trait.m.BossKey;
	local sid = (_skill != null && ::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null) ? _skill.getID() : "";
	local isRng = (_skill != null && ::Wuxia.hasMember(_skill, "isRanged") && _skill.isRanged());

	// Advance 1-Hex Boss Internal Organ/Shield/Horn Counter-Break if applicable!
	::Wuxia.ShanHaiBossLaws.checkInternalCounterBreak(_trait, _actor, _spec, _attacker, _skill);

	// 1. Hundun《日凿一窍，七日浑沌死》
	if (key == "hundun" && !_trait.m.OrificeRuptured)
	{
		if (::Wuxia.ShanHaiBossLaws.isOrificeChiselStrike(_attacker, _skill))
		{
			_trait.m.OrificeStacks += 1;
			if (_trait.m.OrificeStacks >= 7)
			{
				_trait.m.OrificeRuptured = true;
				local rupDmg = ::Math.max(60, ::Math.floor(_actor.getHitpointsMax() * 0.30));
				if (_actor.getHitpoints() > rupDmg + 1) _actor.setHitpoints(_actor.getHitpoints() - rupDmg);
				else _actor.setHitpoints(1);
				local ask = _actor.getSkills();
				if (ask != null)
				{
					if (!ask.hasSkill("effects.wx_status_offbalance")) ask.add(::new("scripts/skills/effects/wx_status_offbalance"));
					if (!ask.hasSkill("effects.wx_status_opening")) ask.add(::new("scripts/skills/effects/wx_status_opening"));
				}
				if ("CraftBridge" in ::Wuxia) ::Wuxia.CraftBridge.markBossPartBroken(_actor, "core");
				if (::Wuxia.TileField.isLiveTactical() && ::Tactical.EventLog != null)
					::Tactical.EventLog.log("[color=#166b2f]【七窍齐开·浑沌死】七记点穴穿刺凿穿无面黄囊，浑沌元胎轰然崩裂！[/color]");
			}
		}
		else
		{
			_properties.DamageReceivedRegularMult *= 0.58;
		}
	}
	// 2. Baize《通万物情·识破复读旧招》
	else if (key == "baize" && sid != "" && _attacker != null)
	{
		if (_trait.m.LastEnemySkills.find(sid) != null)
		{
			_properties.DamageReceivedRegularMult *= 0.45;
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(_attacker) && ::Wuxia.hasMember(_attacker, "getFatigue"))
				_attacker.setFatigue(::Math.min(_attacker.getFatigueMax(), _attacker.getFatigue() + 10));
			if (::Wuxia.hasMember(_attacker, "getSkills") && _attacker.getSkills() != null && !_attacker.getSkills().hasSkill("effects.wx_status_opening"))
				_attacker.getSkills().add(::new("scripts/skills/effects/wx_status_opening"));
		}
		else
		{
			_trait.m.LastEnemySkills.push(sid);
			if (_trait.m.LastEnemySkills.len() > 2)
				_trait.m.LastEnemySkills.remove(0);
		}
	}
	// 3. Xingxing《知人名》: Named main fighter deals 0.60x unless hidden in smoke/mirage!
	else if (key == "xingxing" && _attacker != null && ::Wuxia.hasMember(_attacker, "getID") && _attacker.getID() == _trait.m.NamedPreyID)
	{
		local inSmoke = ("CraftBridge" in ::Wuxia) && ::Wuxia.CraftBridge.isShadowOrSmokeEnv(_attacker, null);
		if (!inSmoke)
			_properties.DamageReceivedRegularMult *= 0.60;
	}
	// 4. Xuangui (Unbroken Shell) & Fangfeng (Chariot Giant Bones): Blunt/concussive 1.32x, blades/arrows 0.55x!
	else if ((key == "xuangui" && !_trait.m.InternalBroken) || key == "fangfeng")
	{
		if (::Wuxia.ShanHaiBossLaws.isShellCrackerStrike(_attacker, _skill))
			_properties.DamageReceivedRegularMult *= 1.32;
		else
			_properties.DamageReceivedRegularMult *= 0.55;
	}
	// 5. Bo《可以御兵》: Resists edged blades/spears (0.62x), vulnerable to Blunt/Fist concussive (1.28x)!
	else if (key == "bo")
	{
		if (::Wuxia.ShanHaiBossLaws.isShellCrackerStrike(_attacker, _skill))
			_properties.DamageReceivedRegularMult *= 1.28;
		else if (::Wuxia.ShanHaiBossLaws.isBladeSeverStrike(_attacker, _skill))
			_properties.DamageReceivedRegularMult *= 0.62;
	}
	// 6. Jumang《通天建木》: Axe cleaves 1.32x; non-axe melee suffers 10 armor thorns!
	else if (key == "jumang" && _skill != null)
	{
		if (::Wuxia.ShanHaiBossLaws.isAxeWoodCutter(_attacker, _skill))
			_properties.DamageReceivedRegularMult *= 1.32;
		else if (!isRng && _attacker != null && ::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
		{
			local bArm = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Body);
			if (bArm != null && bArm.getArmor() > 0) bArm.setArmor(::Math.max(0, bArm.getArmor() - 10));
		}
	}
	// 7. Huodou《厌火食炭·吞火自愈唯冰克》: Fire/Yang heals Huodou, Yin/Frost deals 1.40x!
	else if (key == "huodou")
	{
		if (::Wuxia.ShanHaiMultiBody.isFireOrYangAttack(_attacker, _skill))
		{
			_properties.DamageReceivedRegularMult *= 0.15;
			_actor.setHitpoints(::Math.min(_actor.getHitpointsMax(), _actor.getHitpoints() + 20));
		}
		else if (::Wuxia.ShanHaiBossLaws.isYinOrFrostStrike(_attacker, _skill))
		{
			_properties.DamageReceivedRegularMult *= 1.40;
		}
		else if (!isRng && _attacker != null && ::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
		{
			local hArm = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Body);
			if (hArm != null && hArm.getArmor() > 0) hArm.setArmor(::Math.max(0, hArm.getArmor() - 10));
		}
	}
	// 8. Xingtian《常羊巨干 & 舞戚露脐》: Frontal shield blocks 35% until Axe breaks it; post-whirl navel weakspot takes 1.40x!
	else if (key == "xingtian")
	{
		if (_trait.m.BellyExposed && (::Wuxia.ShanHaiBossLaws.isOrificeChiselStrike(_attacker, _skill) || sid == "actives.wx_fist_shock"))
			_properties.DamageReceivedRegularMult *= 1.40;
		else if (!_trait.m.InternalBroken && _attacker != null && ::Wuxia.ShanHaiBossLaws.isFrontalArc(_actor, _attacker))
			_properties.DamageReceivedRegularMult *= 0.65;
	}
	// 9. Zaochi《持戈盾抗羿》: Shield blocks 70% ranged until Axe breaks it; once broken, Ranged deals 1.50x (`后羿射杀凿齿`)!
	else if (key == "zaochi")
	{
		if (!_trait.m.InternalBroken && isRng)
			_properties.DamageReceivedRegularMult *= 0.30;
		else if (_trait.m.InternalBroken && isRng)
			_properties.DamageReceivedRegularMult *= 1.50;
	}
	// 10. Siwang《苍梧铁兕·正甲背隙》: Frontal arc reduces regular & armor dmg by 45%; rear flank takes 1.25x!
	else if (key == "siwang" && _attacker != null)
	{
		if (::Wuxia.ShanHaiBossLaws.isFrontalArc(_actor, _attacker))
		{
			_properties.DamageReceivedRegularMult *= 0.55;
			_properties.DamageReceivedArmorMult *= 0.55;
		}
		else
		{
			_properties.DamageReceivedRegularMult *= 1.25;
		}
	}
	// 11. Paoxiaowang《双腋露目》: Post-claw window takes 1.40x from Pierce/Ranged/Acupoint & instantly blinds armpit eyes!
	else if (key == "paoxiaowang" && _trait.m.BellyExposed)
	{
		if (::Wuxia.ShanHaiBossLaws.isRangedOrPinpointStrike(_attacker, _skill) || ::Wuxia.ShanHaiBossLaws.isOrificeChiselStrike(_attacker, _skill))
		{
			_properties.DamageReceivedRegularMult *= 1.40;
			_trait.markInternalPartBroken(_actor);
		}
	}
	// 12. Zheng《音如击石》& Mingshe《其音如磬》: 3rd non-blunt hit discharges sonic/drought shock!
	else if ((key == "zheng" && !_trait.m.InternalBroken) || (key == "mingshe" && !_trait.isPartBroken("gold_wing_body")))
	{
		if (!::Wuxia.ShanHaiBossLaws.isShellCrackerStrike(_attacker, _skill))
		{
			_trait.m.StoneChimeStacks += 1;
			if (_trait.m.StoneChimeStacks >= 3)
			{
				_trait.m.StoneChimeStacks = 0;
				if (_attacker != null && ::Wuxia.hasMember(_attacker, "getSkills") && _attacker.getSkills() != null && !_attacker.getSkills().hasSkill("effects.wx_status_offbalance"))
					_attacker.getSkills().add(::new("scripts/skills/effects/wx_status_offbalance"));
			}
		}
	}
	// 13. Luwu《逆时破令》: Opposite element breaks current seasonal law for 1.25x dmg!
	else if (key == "luwu")
	{
		local s = _trait.m.SeasonIdx % 4;
		if ((s == 1 && ::Wuxia.ShanHaiBossLaws.isYinOrFrostStrike(_attacker, _skill))
			|| (s == 3 && ::Wuxia.ShanHaiMultiBody.isFireOrYangAttack(_attacker, _skill)))
			_properties.DamageReceivedRegularMult *= 1.28;
	}
	// 14. Changyou《四耳听风》: Sonic skills (`shihou`/`kuiniu`) or Firearms deafen its 4 ears!
	else if (key == "changyou")
	{
		if (sid.find("shihou") != null || sid.find("kuiniu") != null || sid.find("wx_gun_") != null)
			_trait.m.DeafenedTurns = 2;
		else if (isRng && _trait.m.DeafenedTurns <= 0)
			_properties.DamageReceivedRegularMult *= 0.45;
	}
	// 15. Feilian《回风折矢》: Deflects arrows in `gale_sand` back at archers!
	else if (key == "feilian" && isRng && ::Wuxia.isOnMap(_actor) && ::Wuxia.TileField.hasField(_actor.getTile(), "gale_sand"))
	{
		_properties.DamageReceivedRegularMult *= 0.45;
		if (_attacker != null && _attacker.getHitpoints() > 12)
			_attacker.setHitpoints(_attacker.getHitpoints() - 10);
	}
	// 16. Fuzhu《伤鹿引洪》: Heavy brute hits (>=35 HP) flood attacker's tile with `abyss_frost` & drain 10 Qi!
	else if (key == "fuzhu" && _hitInfo != null && _hitInfo.DamageRegular >= 35 && _attacker != null)
	{
		if (::Wuxia.isOnMap(_attacker))
			::Wuxia.TileField.setField(_attacker.getTile(), "abyss_frost", 3, _actor);
		if (!::Wuxia.CombatRules.isUndeadOrConstruct(_attacker) && ::Wuxia.hasMember(_attacker, "getFatigue"))
			_attacker.setFatigue(::Math.min(_attacker.getFatigueMax(), _attacker.getFatigue() + 10));
	}
	// 17. Fei《烈火焚疫》: Pure Yang / Fire strikes ignite plague swamp for 1.28x dmg!
	else if (key == "fei" && ::Wuxia.ShanHaiMultiBody.isFireOrYangAttack(_attacker, _skill))
	{
		_properties.DamageReceivedRegularMult *= 1.28;
		if (::Wuxia.isOnMap(_actor)) ::Wuxia.TileField.removeField(_actor.getTile());
	}
	// 18. Yayu《弱水沉兵》: Melee attackers sink in Ruoshui cold, spending +6 extra Fatigue!
	else if (key == "yayu" && !isRng && _attacker != null && !::Wuxia.CombatRules.isUndeadOrConstruct(_attacker) && ::Wuxia.hasMember(_attacker, "getFatigue"))
	{
		_attacker.setFatigue(::Math.min(_attacker.getFatigueMax(), _attacker.getFatigue() + 6));
	}
	// 19. Qiongqi《猬毛反刺》: High-Resolve melee attackers take 10 armor/quill damage while quill_ridge intact!
	else if (key == "qiongqi" && !_trait.m.InternalBroken && !isRng && _attacker != null && ::Wuxia.hasMember(_attacker, "getCurrentProperties"))
	{
		if (_attacker.getCurrentProperties().Bravery >= 65 && ::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
		{
			local qArm = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Body);
			if (qArm != null && qArm.getArmor() > 0) qArm.setArmor(::Math.max(0, qArm.getArmor() - 12));
		}
	}
	// 20. Jiao & Chenghuang《破气夺瑞》: Qi-dispel strike shatters stored Qi back to attacker!
	else if ((key == "jiao" || key == "chenghuang") && _trait.m.LawStacks > 0 && ::Wuxia.ShanHaiBossLaws.isQiDispelStrike(_skill))
	{
		_trait.m.LawStacks = 0;
		if (_attacker != null && ::Wuxia.hasMember(_attacker, "getFatigue"))
			::Wuxia.CombatRules.restoreQi(_attacker, 15);
	}
	// 21. Qiangliang《操蛇反噬》: Whips ranged attackers within 2 hexes with red vipers unless serpent severed!
	else if (key == "qiangliang" && !_trait.m.InternalBroken && isRng && _attacker != null && ::Wuxia.isOnMap(_actor) && ::Wuxia.isOnMap(_attacker))
	{
		if (_actor.getTile().getDistanceTo(_attacker.getTile()) <= 2 && _attacker.getSkills() != null && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_attacker))
		{
			if (!_attacker.getSkills().hasSkill("effects.wx_status_poison_dart"))
				_attacker.getSkills().add(::new("scripts/skills/effects/wx_status_poison_dart"));
		}
	}
	// 22. Jiuwei & Dijiang: Auto-swap with a living Totem once per turn when hit hard in melee!
	else if ((key == "jiuwei" || key == "dijiang") && !_trait.m.SwapUsedThisTurn && !isRng && _trait.countAliveTotems(_actor) > 0 && ::Wuxia.TileField.isLiveTactical() && ::Wuxia.isOnMap(_actor))
	{
		local recSw = ::Wuxia.ShanHaiMultiBody.getRecord(_actor);
		if (recSw != null && recSw.Totems.len() > 0)
		{
			foreach (tot in recSw.Totems)
			{
				if (tot != null && tot.isAlive() && ::Wuxia.isOnMap(tot))
				{
					_trait.m.SwapUsedThisTurn = true;
					local uTile = _actor.getTile();
					local tPos = tot.getTile();
					::Tactical.getNavigator().teleport(tot, null, null, null, false);
					::Tactical.getNavigator().teleport(_actor, tPos, null, null, false);
					::Tactical.addEntityToMap(tot, uTile.Coords.X, uTile.Coords.Y);
					break;
				}
			}
		}
	}
	// 23. Jingwei《灵体度化》: Pure Yang neigong pierces her drowned spirit veil!
	else if (key == "jingwei" && _attacker != null && ::Wuxia.TileField.getPrimaryNeigongElement(_attacker) == "yang")
	{
		_properties.DamageReceivedRegularMult *= 1.35;
	}

	// Telegraphed Mythic Omen Counterplay Window!
	if (_trait.m.IsChargingOmen && _hitInfo != null && (_hitInfo.DamageRegular + _hitInfo.DamageArmor) > 0)
	{
		local pts = (::Wuxia.ShanHaiBossLaws.isOrificeChiselStrike(_attacker, _skill) || ::Wuxia.ShanHaiBossLaws.isShellCrackerStrike(_attacker, _skill)) ? 2 : 1;
		_trait.m.OmenBreakPts += pts;
		if (_trait.m.OmenBreakPts >= _trait.m.OmenBreakNeeded)
		{
			_trait.m.IsChargingOmen = false;
			_trait.m.OmenBreakPts = 0;
			if (_actor.getHitpoints() > 41) _actor.setHitpoints(_actor.getHitpoints() - 40);
			local bsk = _actor.getSkills();
			if (bsk != null && !bsk.hasSkill("effects.wx_status_offbalance"))
				bsk.add(::new("scripts/skills/effects/wx_status_offbalance"));
		}
	}

	// Conditional Nirvana / Undying Revival (`九尾狐灯替身` / `鹓鶵旱火烬羽` / `猰貐不死药` / `贰负断枷怨起`)
	if (!_trait.m.NirvanaUsed && _hitInfo != null && _hitInfo.DamageRegular >= _actor.getHitpoints())
	{
		local bsk2 = _actor.getSkills();
		local sealed = (bsk2 != null && bsk2.hasSkill("effects.wx_status_regen_seal"));
		if (!sealed)
		{
			if (key == "jiuwei" && _trait.countAliveTotems(_actor) > 0)
			{
				_trait.m.NirvanaUsed = true;
				_hitInfo.DamageRegular = 0;
				_actor.setHitpoints(::Math.max(95, ::Math.floor(_actor.getHitpointsMax() * 0.40)));
				local rec = ::Wuxia.ShanHaiMultiBody.getRecord(_actor);
				if (rec != null && rec.Totems.len() > 0)
				{
					local sac = rec.Totems.pop();
					if (sac != null && ::Wuxia.hasMember(sac, "isAlive") && sac.isAlive())
					{
						sac.m.WX_DeathHandled <- true;
						sac.killSilently();
					}
				}
			}
			else if (key == "yuanchu" && (!::Wuxia.isOnMap(_actor) || ::Wuxia.TileField.hasField(_actor.getTile(), "drought_scorch")))
			{
				_trait.m.NirvanaUsed = true;
				_hitInfo.DamageRegular = 0;
				_actor.setHitpoints(::Math.max(90, ::Math.floor(_actor.getHitpointsMax() * 0.42)));
				if (::Wuxia.isOnMap(_actor)) ::Wuxia.TileField.removeField(_actor.getTile());
			}
			else if ((key == "yayu" || key == "erfu") && !::Wuxia.ShanHaiMultiBody.isFireOrYangAttack(_attacker, _skill))
			{
				_trait.m.NirvanaUsed = true;
				_hitInfo.DamageRegular = 0;
				_actor.setHitpoints(135);
			}
		}
	}
};

// ============================================================================
// 5. Post-Hit Boss Laws (`onBossTargetHit`)
// ============================================================================
::Wuxia.ShanHaiBossLaws.onBossTargetHit <- function( _trait, _actor, _spec, _skill, _target, _dmgHP, _dmgArm )
{
	if (_target == null || !_target.isAlive()) return;
	local key = _trait.m.BossKey;
	local sid = (_skill != null && ::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null) ? _skill.getID() : "";

	// Xingtian whirl & Paoxiaowang heavy claw expose 1-turn weakspot (`乳目脐口 / 双腋邪瞳`)!
	if (key == "xingtian" && sid == "actives.wx_boss_xingtian_ganqi_whirl")
		_trait.m.BellyExposed = true;
	else if (key == "paoxiaowang" && sid == "actives.wx_boss_paoxiaowang_tiger_fang")
		_trait.m.BellyExposed = true;

	// Zhuyan《见则大兵》: Splashes blood_pool & builds war-frenzy stacks!
	if (key == "zhuyan" && _dmgHP > 0)
	{
		_trait.m.LawStacks = ::Math.min(5, _trait.m.LawStacks + 1);
		if (::Wuxia.isOnMap(_target)) ::Wuxia.TileField.setField(_target.getTile(), "blood_pool", 3, _actor);
	}
	// Bashe《吞象蓄骨》: Devour builds bone stacks; Bone Spit expends them!
	else if (key == "bashe")
	{
		if (sid == "actives.wx_boss_bashe_swallow_coil") _trait.m.LawStacks = ::Math.min(3, _trait.m.LawStacks + 1);
		else if (sid == "actives.wx_boss_bashe_bone_spit") _trait.m.LawStacks = 0;
	}
	// Taotie《食人未咽，害及其身》: Over-gorging to 4 stacks ruptures Taotie's own belly!
	else if (key == "taotie")
	{
		_trait.m.LawStacks += 1;
		if (_trait.m.LawStacks >= 4)
		{
			_trait.m.LawStacks = 0;
			if (_actor.getHitpoints() > 46) _actor.setHitpoints(_actor.getHitpoints() - 45);
			local ask = _actor.getSkills();
			if (ask != null)
			{
				if (!ask.hasSkill("effects.wx_internal_injury")) ask.add(::new("scripts/skills/effects/wx_internal_injury"));
				if (!ask.hasSkill("effects.wx_status_opening")) ask.add(::new("scripts/skills/effects/wx_status_opening"));
			}
			if (::Wuxia.TileField.isLiveTactical() && ::Tactical.EventLog != null)
				::Tactical.EventLog.log("[color=#166b2f]【食人未咽·害及其身】饕餮贪吞过度撑裂咽喉，当场内伤反噬！[/color]");
		}
	}
	// Jiao《玉山夺穰》: Builds harvest Qi stacks; heals 35 HP at 3 stacks!
	else if (key == "jiao")
	{
		_trait.m.LawStacks += 1;
		if (_trait.m.LawStacks >= 3)
		{
			_trait.m.LawStacks = 0;
			_actor.setHitpoints(::Math.min(_actor.getHitpointsMax(), _actor.getHitpoints() + 35));
		}
	}
	// Gudiaowang《乘怯追爪》: Hitting a wavering target refunds +2 AP once per turn!
	else if (key == "gudiaowang" && !_trait.m.FollowUpUsedThisTurn && ::Wuxia.hasMember(_target, "getMoraleState") && _target.getMoraleState() <= ::Const.MoraleState.Wavering)
	{
		_trait.m.FollowUpUsedThisTurn = true;
		_actor.setActionPoints(::Math.min(11, _actor.getActionPoints() + 2));
	}
	// Qinyuan《蜇木则枯·蜇石则烂》: Corrodes target's equipped shield or weapon condition!
	else if (key == "qinyuan" && !_trait.m.InternalBroken && ::Wuxia.hasMember(_target, "getItems") && _target.getItems() != null)
	{
		local off = _target.getItems().getItemAtSlot(::Const.ItemSlot.Offhand);
		if (off != null && ::Wuxia.hasMember(off, "getCondition") && off.getCondition() > 0)
			off.setCondition(::Math.max(0, off.getCondition() - 18));
	}
	// Kui《流波导电》: Arcs +14 lightning shock to enemies adjacent to primary target!
	else if (key == "kui" && ::Wuxia.isOnMap(_target))
	{
		local tt = _target.getTile();
		for (local d = 0; d < 6; d = ++d)
		{
			if (!tt.hasNextTile(d)) continue;
			local nt = tt.getNextTile(d);
			if (nt != null && nt.IsOccupiedByActor && nt.getEntity() != null && nt.getEntity().isAlive() && !_actor.isAlliedWith(nt.getEntity()))
			{
				local arcE = nt.getEntity();
				if (arcE.getHitpoints() > 15) arcE.setHitpoints(arcE.getHitpoints() - 14);
			}
		}
	}
	// Bingyi《寒极封脉》: High-fatigue targets (>=55) get acupoint-frozen!
	else if (key == "bingyi" && ::Wuxia.hasMember(_target, "getFatigue") && _target.getFatigue() >= 55 && _target.getSkills() != null && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_target))
	{
		if (!_target.getSkills().hasSkill("effects.wx_status_acupoint"))
			_target.getSkills().add(::new("scripts/skills/effects/wx_status_acupoint"));
	}
	// Shanhui《裂颅投石·怪笑退步》: Shreds helmet armor & steps back 1 hex if possible!
	else if (key == "shanhui" && sid == "actives.wx_boss_shanhui_boulder_hurl")
	{
		if (::Wuxia.hasMember(_target, "getItems") && _target.getItems() != null)
		{
			local helm = _target.getItems().getItemAtSlot(::Const.ItemSlot.Head);
			if (helm != null && ::Wuxia.hasMember(helm, "getArmor") && helm.getArmor() > 0)
				helm.setArmor(::Math.max(0, helm.getArmor() - 18));
		}
	}
};

// ============================================================================
// 6. Hex-Grid Geometric Active Move Executors
// ============================================================================
::Wuxia.ShanHaiBossLaws.executeBossMove <- function( _move, _user, _uTile, _targetTile )
{
	local g = _move.m.GeoKind;
	local anyHit = false;

	// 1. Cone 3-hex sweep (`cone_3` / `tail_sweep_arc`)
	if (g == "cone_3" || g == "tail_sweep_arc")
	{
		if (_targetTile == null) return false;
		local tiles = [_targetTile];
		if (_uTile != null && ::Wuxia.hasMember(_uTile, "getDirectionTo") && ::Wuxia.hasMember(_uTile, "hasNextTile"))
		{
			local dir = _uTile.getDirectionTo(_targetTile);
			if (dir >= 0)
			{
				local dL = (dir + 5) % 6;
				local dR = (dir + 1) % 6;
				if (_uTile.hasNextTile(dL)) tiles.push(_uTile.getNextTile(dL));
				if (_uTile.hasNextTile(dR)) tiles.push(_uTile.getNextTile(dR));
			}
		}
		foreach (t in tiles)
		{
			if (t == null) continue;
			if (_move.m.FieldKind != "") ::Wuxia.TileField.setField(t, _move.m.FieldKind, _move.m.FieldTurns, _user);
			if (("IsOccupiedByActor" in t) && t.IsOccupiedByActor && t.getEntity() != null && t.getEntity().isAlive() && !_user.isAlliedWith(t.getEntity()))
			{
				local ent = t.getEntity();
				if (_move.attackEntity(_user, ent))
				{
					anyHit = true;
					_move.wxInflictPostEffects(_user, ent, t);
					if (g == "tail_sweep_arc" && ent.isAlive() && ::Wuxia.TileField.isLiveTactical() && ::Wuxia.isOnMap(ent) && _uTile != null)
					{
						local kd = _uTile.getDirectionTo(t);
						if (kd >= 0 && t.hasNextTile(kd))
						{
							local kt = t.getNextTile(kd);
							if (kt != null && kt.IsEmpty && !kt.IsOccupiedByActor && !ent.getCurrentProperties().IsImmuneToKnockBackAndGrab)
								::Tactical.getNavigator().teleport(ent, kt, null, null, true);
						}
					}
				}
			}
		}
		return anyHit;
	}

	// 2. Line 3-hex pierce / charge (`line_pierce_3` / `line_charge_3`)
	if (g == "line_pierce_3" || g == "line_charge_3")
	{
		if (_targetTile == null) return false;
		local lineTiles = [_targetTile];
		local dir = (_uTile != null && ::Wuxia.hasMember(_uTile, "getDirectionTo")) ? _uTile.getDirectionTo(_targetTile) : -1;
		local cur = _targetTile;
		for (local s = 1; s < 3; s = ++s)
		{
			if (cur == null || dir < 0 || !::Wuxia.hasMember(cur, "hasNextTile") || !cur.hasNextTile(dir)) break;
			cur = cur.getNextTile(dir);
			if (cur != null) lineTiles.push(cur);
		}
		local lastEmpty = null;
		foreach (lt in lineTiles)
		{
			if (_move.m.FieldKind != "") ::Wuxia.TileField.setField(lt, _move.m.FieldKind, _move.m.FieldTurns, _user);
			if (("IsOccupiedByActor" in lt) && lt.IsOccupiedByActor && lt.getEntity() != null && lt.getEntity().isAlive() && !_user.isAlliedWith(lt.getEntity()))
			{
				local le = lt.getEntity();
				if (_move.attackEntity(_user, le))
				{
					anyHit = true;
					_move.wxInflictPostEffects(_user, le, lt);
				}
			}
			else if (("IsEmpty" in lt) && lt.IsEmpty && !lt.IsOccupiedByActor)
			{
				lastEmpty = lt;
			}
		}
		if (g == "line_charge_3" && lastEmpty != null && ::Wuxia.TileField.isLiveTactical() && ::Wuxia.isOnMap(_user))
		{
			local prevT = _user.getTile();
			::Tactical.getNavigator().teleport(_user, lastEmpty, null, null, false);
			::Wuxia.ShanHaiMultiBody.onMasterMoved(_user, prevT, lastEmpty);
		}
		return anyHit;
	}

	// 3. Ring 6-hex quake / aura roar (`ring_quake_6` / `sonic_roar`)
	if (g == "ring_quake_6" || g == "sonic_roar")
	{
		if (_uTile == null) return true;
		if (_move.m.FieldKind != "") ::Wuxia.TileField.setField(_uTile, _move.m.FieldKind, _move.m.FieldTurns, _user);
		for (local d = 0; d < 6; d = ++d)
		{
			if (!::Wuxia.hasMember(_uTile, "hasNextTile") || !_uTile.hasNextTile(d)) continue;
			local nt = _uTile.getNextTile(d);
			if (nt == null) continue;
			if (_move.m.FieldKind != "") ::Wuxia.TileField.setField(nt, _move.m.FieldKind, _move.m.FieldTurns, _user);
			if (("IsOccupiedByActor" in nt) && nt.IsOccupiedByActor && nt.getEntity() != null && nt.getEntity().isAlive() && !_user.isAlliedWith(nt.getEntity()))
			{
				local ne = nt.getEntity();
				if (g == "ring_quake_6")
				{
					if (_move.attackEntity(_user, ne)) anyHit = true;
				}
				else
				{
					anyHit = true;
				}
				_move.wxInflictPostEffects(_user, ne, nt);
			}
		}
		return true;
	}

	// 4. Leap slam 2~3 hexes (`leap_slam_3`)
	if (g == "leap_slam_3")
	{
		if (_targetTile == null) return false;
		local tEnt = _targetTile.getEntity();
		if (::Wuxia.TileField.isLiveTactical() && ::Wuxia.isOnMap(_user))
		{
			local prevT2 = _user.getTile();
			if (_uTile != null && _move.m.FieldKind != "")
				::Wuxia.TileField.setField(_uTile, _move.m.FieldKind, _move.m.FieldTurns, _user);
			for (local d2 = 0; d2 < 6; d2 = ++d2)
			{
				if (!_targetTile.hasNextTile(d2)) continue;
				local land = _targetTile.getNextTile(d2);
				if (land != null && land.IsEmpty && !land.IsOccupiedByActor && ::Math.abs(land.Level - _targetTile.Level) <= 2)
				{
					::Tactical.getNavigator().teleport(_user, land, null, null, false);
					::Wuxia.ShanHaiMultiBody.onMasterMoved(_user, prevT2, land);
					break;
				}
			}
		}
		if (tEnt != null && tEnt.isAlive() && _move.attackEntity(_user, tEnt))
		{
			anyHit = true;
			_move.wxInflictPostEffects(_user, tEnt, _targetTile);
		}
		return anyHit;
	}

	// 5. Pull & Devour (`pull_devour`)
	if (g == "pull_devour")
	{
		if (_targetTile == null) return false;
		local pEnt = _targetTile.getEntity();
		if (pEnt == null || !pEnt.isAlive()) return false;
		if (::Wuxia.TileField.isLiveTactical() && _uTile != null && _uTile.getDistanceTo(_targetTile) > 1 && !pEnt.getCurrentProperties().IsImmuneToKnockBackAndGrab)
		{
			local pd = _uTile.getDirectionTo(_targetTile);
			if (pd >= 0 && _uTile.hasNextTile(pd))
			{
				local pullT = _uTile.getNextTile(pd);
				if (pullT != null && pullT.IsEmpty && !pullT.IsOccupiedByActor)
					::Tactical.getNavigator().teleport(pEnt, pullT, null, null, true);
			}
		}
		if (_move.attackEntity(_user, pEnt))
		{
			anyHit = true;
			_move.wxInflictPostEffects(_user, pEnt, pEnt.getTile() != null ? pEnt.getTile() : _targetTile);
		}
		return anyHit;
	}

	// 6. Multi-Head Bite (`multi_bite`)
	if (g == "multi_bite")
	{
		if (_targetTile == null || _targetTile.getEntity() == null) return false;
		local mEnt = _targetTile.getEntity();
		local swings = 1 + ::Math.min(2, ::Wuxia.ShanHaiMultiBody.getAliveAppendageCount(_user));
		for (local k = 0; k < swings; k = ++k)
		{
			if (!mEnt.isAlive()) break;
			if (_move.attackEntity(_user, mEnt))
			{
				anyHit = true;
				_move.wxInflictPostEffects(_user, mEnt, _targetTile);
			}
		}
		return anyHit;
	}

	// 7. Totem Cross-Ray (`totem_ray`)
	if (g == "totem_ray")
	{
		local rec = ::Wuxia.ShanHaiMultiBody.getRecord(_user);
		if (rec != null && rec.Totems.len() > 0 && _targetTile != null)
		{
			foreach (tot in rec.Totems)
			{
				if (tot == null || !::Wuxia.hasMember(tot, "isAlive") || !tot.isAlive() || !::Wuxia.isOnMap(tot)) continue;
				local rayTiles = ::Wuxia.TileField.collectHexLine(tot.getTile(), _targetTile, 6);
				foreach (rt in rayTiles)
				{
					if (_move.m.FieldKind != "") ::Wuxia.TileField.setField(rt, _move.m.FieldKind, 2, _user);
					if (("IsOccupiedByActor" in rt) && rt.IsOccupiedByActor && rt.getEntity() != null && rt.getEntity().isAlive() && !_user.isAlliedWith(rt.getEntity()))
					{
						local re = rt.getEntity();
						if (re.getHitpoints() > 19) re.setHitpoints(re.getHitpoints() - 18);
						_move.wxInflictPostEffects(_user, re, rt);
						anyHit = true;
					}
				}
			}
		}
		if (_targetTile != null && _targetTile.getEntity() != null && _targetTile.getEntity().isAlive())
		{
			if (_move.attackEntity(_user, _targetTile.getEntity())) anyHit = true;
			_move.wxInflictPostEffects(_user, _targetTile.getEntity(), _targetTile);
		}
		return anyHit;
	}

	// 8. Totem Position Swap (`totem_swap`)
	if (g == "totem_swap")
	{
		local recS = ::Wuxia.ShanHaiMultiBody.getRecord(_user);
		if (recS != null && recS.Totems.len() > 0 && ::Wuxia.TileField.isLiveTactical() && _uTile != null)
		{
			foreach (tot2 in recS.Totems)
			{
				if (tot2 != null && tot2.isAlive() && ::Wuxia.isOnMap(tot2))
				{
					local tPos = tot2.getTile();
					::Tactical.getNavigator().teleport(tot2, null, null, null, false);
					::Tactical.getNavigator().teleport(_user, tPos, null, null, false);
					::Tactical.addEntityToMap(tot2, _uTile.Coords.X, _uTile.Coords.Y);
					if (_move.m.FieldKind != "") ::Wuxia.TileField.setField(_uTile, _move.m.FieldKind, 3, _user);
					return true;
				}
			}
		}
		if (_uTile != null && _move.m.FieldKind != "")
			::Wuxia.TileField.setField(_uTile, _move.m.FieldKind, 3, _user);
		return true;
	}

	// 9. Field-Wide Detonation (`field_detonate`)
	if (g == "field_detonate")
	{
		local wantKind = ::Wuxia.TileField.normalizeKind(_move.m.FieldKind != "" ? _move.m.FieldKind : "drought_scorch");
		local erupted = 0;
		foreach (_, f in ::Wuxia.TileField.Fields)
		{
			if (f == null || f.Kind != wantKind || f.TileRef == null) continue;
			local ft = f.TileRef;
			erupted += 1;
			if (("IsOccupiedByActor" in ft) && ft.IsOccupiedByActor && ft.getEntity() != null && ft.getEntity().isAlive() && !_user.isAlliedWith(ft.getEntity()))
			{
				local fe = ft.getEntity();
				if (fe.getHitpoints() > 23) fe.setHitpoints(fe.getHitpoints() - 22);
				else fe.setHitpoints(1);
				_move.wxInflictPostEffects(_user, fe, ft);
			}
		}
		return erupted > 0;
	}

	// 10. Telegraphed Mythic Omen (`telegraph_omen`)
	if (g == "telegraph_omen")
	{
		local usk = _user.getSkills();
		local tr = ("ShanHai" in ::Wuxia) ? ::Wuxia.ShanHai.findBossTrait(usk) : null;
		if (tr != null && ("m" in tr))
		{
			if (!tr.m.IsChargingOmen)
			{
				tr.m.IsChargingOmen = true;
				tr.m.OmenBreakPts = 0;
				return true;
			}
			else
			{
				tr.m.IsChargingOmen = false;
				tr.m.OmenBreakPts = 0;
				if (::Wuxia.TileField.isLiveTactical() && _uTile != null)
				{
					foreach (u in ::Tactical.Entities.getAllInstancesAsArray())
					{
						if (u == null || !u.isAlive() || _user.isAlliedWith(u) || !::Wuxia.isOnMap(u)) continue;
						if (_uTile.getDistanceTo(u.getTile()) <= 3)
						{
							if (u.getHitpoints() > 29) u.setHitpoints(u.getHitpoints() - 28);
							_move.wxInflictPostEffects(_user, u, u.getTile());
						}
					}
				}
				return true;
			}
		}
		return true;
	}

	// 11. Hex Curse (`hex_curse`)
	if (g == "hex_curse")
	{
		if (_targetTile == null || _targetTile.getEntity() == null) return false;
		_move.wxInflictPostEffects(_user, _targetTile.getEntity(), _targetTile);
		return true;
	}

	// 12. Single / Ranged Barrage (`single` / `ranged_barrage`)
	if (_targetTile != null && _targetTile.getEntity() != null && _targetTile.getEntity().isAlive())
	{
		local sEnt = _targetTile.getEntity();
		if (_move.attackEntity(_user, sEnt))
		{
			anyHit = true;
			_move.wxInflictPostEffects(_user, sEnt, _targetTile);
		}
	}
	return anyHit;
};

// Populate `::Wuxia.KineticVFX.BossProfiles` for all 64 Shan Hai Boss moves (keeping `Profiles` strictly 171 player moves!)
::Wuxia.ShanHaiBossLaws.registerAllBossKineticProfiles <- function()
{
	if (!("KineticVFX" in ::Wuxia) || !("BossProfiles" in ::Wuxia.KineticVFX)) return;
	foreach (mid, ms in ::Wuxia.ShanHaiBossMoves)
	{
		if (mid in ::Wuxia.KineticVFX.BossProfiles) continue;
		local fld = ("Field" in ms) ? ms.Field : "";
		local g   = ("Geo" in ms) ? ms.Geo : "single";

		local theme = "gold";
		local tint  = [255, 228, 145];
		local ground = "scorch";
		local react = "kin_hit_launch";
		local seq   = "wx_kin_earth_shatter";
		local seq2  = "wx_kin_giant_axe";
		local seal  = "荒神";
		local arch  = "earth_shatter";

		if (fld == "abyss_frost")
		{
			theme = "frost"; tint = [195, 244, 255]; ground = "frost"; react = "kin_hit_frost";
			seq = "wx_kin_frost_burst"; seq2 = "wx_kin_snow_step"; seal = "玄冥"; arch = "frost_burst";
		}
		else if (fld == "drought_scorch")
		{
			theme = "fire"; tint = [255, 185, 110]; ground = "scorch"; react = "kin_hit_launch";
			seq = "wx_kin_flame_pillar"; seq2 = "wx_kin_cannon_blast"; seal = "焚天"; arch = "cannon_blast";
		}
		else if (fld == "bitter_mire")
		{
			theme = "venom"; tint = [165, 255, 135]; ground = "venom"; react = "kin_hit_venom";
			seq = "wx_kin_venom_mire"; seq2 = "wx_kin_claw_rend"; seal = "苦瘴"; arch = "venom_mire";
		}
		else if (fld == "thunder_pool")
		{
			theme = "violet"; tint = [225, 195, 255]; ground = "scorch"; react = "kin_hit_electro";
			seq = "wx_kin_thunder_bolt"; seq2 = "wx_kin_sonic_wave"; seal = "天雷"; arch = "thunder_slam";
		}
		else if (fld == "mirage_mist")
		{
			theme = "violet"; tint = [215, 165, 255]; ground = ""; react = "kin_hit_venom";
			seq = "wx_kin_smoke_cloud"; seq2 = "wx_kin_warp_seal"; seal = "迷障"; arch = "smoke_cloud";
		}
		else if (fld == "gale_sand")
		{
			theme = "jade"; tint = [180, 255, 220]; ground = ""; react = "kin_hit_launch";
			seq = "wx_kin_whirl_cyclone"; seq2 = "wx_kin_qinggong_gust"; seal = "狂飙"; arch = "whirl_cyclone";
		}
		else if (fld == "blood_pool")
		{
			theme = "crimson"; tint = [255, 120, 135]; ground = "scorch"; react = "kin_hit_heavy";
			seq = "wx_kin_blood_arc"; seq2 = "wx_kin_claw_rend"; seal = "凶煞"; arch = "blood_cleave";
		}

		local motion = "kin_heavy_chop";
		local kind   = "melee";
		local isAoe  = false;
		if (g == "ring_quake_6")
		{
			motion = "kin_roar_pulse"; kind = "stance"; isAoe = true;
			if (fld == "") { seq = "wx_kin_giant_axe"; seq2 = "wx_kin_earth_shatter"; arch = "giant_axe"; seal = "崩岳"; }
		}
		else if (g == "sonic_roar")
		{
			motion = "kin_roar_pulse"; kind = "stance"; isAoe = true;
			if (fld == "") { seq = "wx_kin_sonic_wave"; seq2 = "wx_kin_whirl_cyclone"; arch = "sonic_wave"; theme = "violet"; tint = [225, 195, 255]; ground = ""; seal = "凶啸"; }
		}
		else if (g == "field_detonate" || g == "telegraph_omen")
		{
			motion = "kin_roar_pulse"; kind = "stance"; isAoe = true;
			if (fld == "") { seq = "wx_kin_cannon_blast"; seq2 = "wx_kin_prism_burst"; arch = "cannon_blast"; theme = "fire"; tint = [255, 195, 125]; seal = "天灾"; }
		}
		else if (g == "totem_swap")
		{
			motion = "kin_qg_vault"; kind = "util"; isAoe = false; ground = "";
			seq = "wx_kin_warp_seal"; seq2 = "wx_kin_qinggong_gust"; arch = "warp_seal"; theme = "violet"; tint = [220, 185, 255]; seal = "移形";
		}
		else if (g == "totem_ray")
		{
			motion = "kin_celestial_beam"; kind = "ranged"; isAoe = true;
			if (fld == "") { seq = "wx_kin_celestial_beam"; seq2 = "wx_kin_flame_pillar"; arch = "celestial_beam"; theme = "celestial"; tint = [255, 238, 165]; seal = "贯虹"; }
		}
		else if (g == "ranged_barrage")
		{
			motion = "kin_throw_fan"; kind = "ranged"; isAoe = false;
			if (fld == "") { seq = "wx_kin_peacock_fan"; seq2 = "wx_kin_flying_knives"; arch = "peacock_fan"; theme = "gold"; tint = [255, 228, 160]; ground = ""; seal = "飞刺"; }
		}
		else if (g == "hex_curse")
		{
			motion = "kin_celestial_beam"; kind = "ranged"; isAoe = false;
			if (fld == "") { seq = "wx_kin_soul_vortex"; seq2 = "wx_kin_smoke_cloud"; arch = "soul_vortex"; theme = "violet"; tint = [218, 175, 255]; ground = ""; seal = "摄魄"; }
		}
		else if (g == "leap_slam_3")
		{
			motion = "kin_flame_leap"; kind = "melee"; isAoe = false;
			if (fld == "") { seq = "wx_kin_phoenix_spear"; seq2 = "wx_kin_claw_rend"; arch = "flame_leap"; theme = "gold"; tint = [255, 224, 155]; seal = "扑杀"; }
		}
		else if (g == "tail_sweep_arc")
		{
			motion = "kin_whirl_spin"; kind = "melee"; isAoe = true;
			if (fld == "") { seq = "wx_kin_bamboo_bind"; seq2 = "wx_kin_whirl_cyclone"; arch = "bamboo_bind"; theme = "jade"; tint = [180, 255, 210]; ground = ""; seal = "摆尾"; }
		}
		else if (g == "cone_3")
		{
			motion = "kin_whirl_spin"; kind = "melee"; isAoe = true;
			if (fld == "") { seq = "wx_kin_flame_cleave"; seq2 = "wx_kin_claw_rend"; arch = "heavy_cleave"; theme = "fire"; tint = [255, 198, 138]; seal = "横扫"; }
		}
		else if (g == "line_charge_3" || g == "line_pierce_3")
		{
			motion = "kin_spear_drill"; kind = "melee"; isAoe = true;
			if (fld == "") { seq = "wx_kin_dragon_surge"; seq2 = "wx_kin_spear_drill"; arch = "dragon_surge"; theme = "gold"; tint = [255, 232, 170]; seal = "贯阵"; }
		}
		else if (g == "pull_devour")
		{
			motion = "kin_whip_snap"; kind = "melee"; isAoe = false;
			if (fld == "") { seq = "wx_kin_whip_lash"; seq2 = "wx_kin_soul_vortex"; arch = "whip_lash"; theme = "crimson"; tint = [255, 165, 180]; ground = ""; seal = "吞噬"; }
		}
		else
		{
			if (fld == "") { seq = "wx_kin_claw_rend"; seq2 = "wx_kin_blood_arc"; arch = "claw_rend"; theme = "crimson"; tint = [255, 175, 175]; seal = "裂爪"; }
		}

		::Wuxia.KineticVFX.BossProfiles[mid] <- {
			title      = ms.Name,
			subtitle   = "山海凶威·大荒异象",
			seal       = seal,
			arch       = arch,
			seq        = seq,
			seq2       = seq2,
			motionKind = motion,
			react      = react,
			theme      = theme,
			tint       = tint,
			kind       = kind,
			isFootwork = false,
			isAoe      = isAoe,
			ground     = ground,
			impactMs   = 375,
			releaseMs  = 520,
			totalMs    = 930,
			hits       = [375],
			shakePow   = isAoe ? 8 : 6
		};
	}

	::Wuxia.KineticVFX.BossProfiles["wx_item_bag_gadget"] <- {
		title = "墨家腰包奇械", subtitle = "千机巧括·应手破阵", seal = "奇械", arch = "flying_knives",
		seq = "wx_kin_flying_knives", seq2 = "wx_kin_bamboo_bind", motionKind = "kin_throw_fan", react = "kin_hit_heavy",
		theme = "cyan", tint = [185, 245, 255], kind = "ranged", isFootwork = false, isAoe = true, ground = "",
		impactMs = 310, releaseMs = 445, totalMs = 820, hits = [310], shakePow = 5
	};
	::Wuxia.KineticVFX.BossProfiles["wx_item_tactical_powder"] <- {
		title = "百草奇散秘膏", subtitle = "临阵淬刃·辟秽改脉", seal = "灵散", arch = "prism_burst",
		seq = "wx_kin_prism_burst", seq2 = "wx_kin_gold_needles", motionKind = "kin_stance_channel", react = "kin_hit_heavy",
		theme = "jade", tint = [185, 255, 220], kind = "util", isFootwork = false, isAoe = true, ground = "",
		impactMs = 280, releaseMs = 415, totalMs = 780, hits = [280], shakePow = 4
	};
};
