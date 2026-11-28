// Deep Wuxia Martial Arts Stream & Four-Meridian Reaction Engine (`::Wuxia.Streams`)
// Powers:
//   1. Same-Slot Dynamic Combo Progression & Stance Shifting (strictly keeping bottom HUD within 6~9 active icons!)
//   2. Sword Sect (`剑宗/气宗`): Field Sword-Qi Nodes (`sword_node`) & Hex-Line `万剑归宗` Convergence Recall
//   3. Taiji / Douzhuan (`太和/姑苏`): True Melee Deflection onto Adjacent Enemies (`借力打力`) or Wall-Slam Toss
//   4. Dugu Nine Swords (`剑冢遗脉`): 6-Category Adaptive Enemy Weapon/Stance Breaker (`破盾/破枪/破刀剑/破箭/破鞭掌/破气`)
//   5. Shaolin / Beggar (`少室/丐帮`): True `隔山打牛` Rear-Hex Shockwave & `寸劲伏脉` 3-Stack Organ Rupture
//   6. Four-Meridian (`内·外·轻·横`) Non-Inflating Tactical Chemical Reactions

::Wuxia.Streams <- {};

::Wuxia.Streams.getOrCreateState <- function( _actor )
{
	if (_actor == null || !::Wuxia.hasMember(_actor, "getSkills") || _actor.getSkills() == null) return null;
	local sk = _actor.getSkills();
	local st = sk.getSkillByID("effects.wx_stream_combo_state");
	if (st == null)
	{
		st = ::new("scripts/skills/effects/wx_stream_combo_state");
		sk.add(st);
	}
	return st;
};

::Wuxia.Streams.getState <- function( _actor )
{
	if (_actor == null || !::Wuxia.hasMember(_actor, "getSkills") || _actor.getSkills() == null) return null;
	return _actor.getSkills().getSkillByID("effects.wx_stream_combo_state");
};

::Wuxia.Streams.getComboStage <- function( _actor, _skillID )
{
	local st = ::Wuxia.Streams.getState(_actor);
	return st != null ? st.getStage(_skillID) : 0;
};

::Wuxia.Streams.advanceComboStage <- function( _actor, _skillID, _maxForms, _persistTurn = false )
{
	if (_actor == null || _skillID == null || _maxForms <= 1) return 0;
	local st = ::Wuxia.Streams.getOrCreateState(_actor);
	if (st == null) return 0;
	local next = (st.getStage(_skillID) + 1) % _maxForms;
	st.setStage(_skillID, next, _persistTurn);
	return next;
};

::Wuxia.Streams.resetComboStage <- function( _actor, _skillID )
{
	local st = ::Wuxia.Streams.getState(_actor);
	if (st != null) st.setStage(_skillID, 0, false);
};

// ============================================================================
// Stream 1: Sword Sect (`剑宗/气宗`) — Field Sword-Qi & `万剑归宗` Recall
// ============================================================================

::Wuxia.Streams.spawnSwordNode <- function( _user, _nearTile )
{
	if (_user == null || _nearTile == null) return null;
	local chosen = _nearTile;
	if (::Wuxia.hasMember(_nearTile, "hasNextTile"))
	{
		for (local d = 0; d < 6; d = ++d)
		{
			if (!_nearTile.hasNextTile(d)) continue;
			local cand = _nearTile.getNextTile(d);
			if (cand != null && !::Wuxia.TileField.hasField(cand, "sword_node"))
			{
				chosen = cand;
				break;
			}
		}
	}
	::Wuxia.TileField.setField(chosen, "sword_node", 3, _user);
	return chosen;
};

// Recall all `sword_node` fields owned by `_user` along hex lines into `_targetTile`!
::Wuxia.Streams.recallSwordNodes <- function( _user, _targetTile )
{
	local result = { recalled = 0, bonusHits = 0, qiRestored = 0 };
	if (_user == null || _targetTile == null) return result;
	local uid = ::Wuxia.hasMember(_user, "getID") ? _user.getID() : -1;
	local nodes = ::Wuxia.TileField.getFieldsByKind("sword_node", uid);
	if (nodes.len() == 0) return result;

	local hitCountByActor = {};
	foreach (nd in nodes)
	{
		local nTile = nd.TileRef;
		::Wuxia.TileField.removeField(nTile);
		result.recalled += 1;
		if (nTile == null) continue;

		// Trace flight path from `nTile` -> `_targetTile`
		local pathTiles = [nTile];
		pathTiles.extend(::Wuxia.TileField.collectHexLine(nTile, _targetTile, 5));
		if (pathTiles[pathTiles.len() - 1] != _targetTile)
			pathTiles.push(_targetTile);

		foreach (pt in pathTiles)
		{
			if (pt == null) continue;
			if (::Wuxia.TileField.isLiveTactical() && "KineticVFX" in ::Wuxia)
				::Wuxia.KineticVFX.spawnShockwaveRing(pt, "wx_pt_ring_cyan", 25 * result.recalled, 0.22, 1.15, 0.26, -14.0, 200);
			if (!::Wuxia.isTileOccupiedByActor(pt)) continue;
			local ent = pt.getEntity();
			if (ent == null || !ent.isAlive() || _user.isAlliedWith(ent)) continue;

			local eid = ::Wuxia.hasMember(ent, "getID") ? ent.getID() : 0;
			local prevHits = (eid in hitCountByActor) ? hitCountByActor[eid] : 0;
			hitCountByActor[eid] <- prevHits + 1;

			local mult = prevHits == 0 ? 1.0 : 0.50;
			local hpCut = ::Math.max(5, ::Math.floor(14 * mult));
			local armCut = ::Math.max(6, ::Math.floor(16 * mult));
			if (ent.getItems() != null)
			{
				local bArm = ent.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (bArm != null && bArm.getArmor() > 0)
					bArm.setArmor(::Math.max(0, bArm.getArmor() - armCut));
			}
			if (ent.getHitpoints() > hpCut + 1) ent.setHitpoints(ent.getHitpoints() - hpCut);
			else ent.setHitpoints(1);
			result.bonusHits += 1;
		}
	}

	local qiBack = ::Math.min(16, result.recalled * 4);
	if (qiBack > 0)
	{
		::Wuxia.CombatRules.restoreQi(_user, qiBack);
		result.qiRestored = qiBack;
	}
	if (::Wuxia.TileField.isLiveTactical() && ::Tactical.EventLog != null)
		::Tactical.EventLog.log("[color=#127896]【万剑归宗】" + ::Const.UI.getColorizedEntityName(_user) + " 剑指一引，" + result.recalled + " 柄驻场气剑破空归位攒刺敌阵，回气 " + qiBack + " 点！[/color]");

	return result;
};

// ============================================================================
// Stream 2: Dugu Nine Swords (`剑冢独孤`) — 6-Category Adaptive Weapon Breaker
// ============================================================================

::Wuxia.Streams.inspectDuguTarget <- function( _target )
{
	local info = {
		FormKey      = "qi_beast",
		FormName     = "破气式",
		HitBonus     = 12,
		PenBonus     = 0.08,
		IgnoreShield = false,
		Summary      = "直透护体罡气/妖核：穿甲 +8%，震散 20 内息并追加双倍破招值"
	};
	if (_target == null) return info;

	local tsk = ::Wuxia.hasMember(_target, "getSkills") ? _target.getSkills() : null;
	local items = ::Wuxia.hasMember(_target, "getItems") ? _target.getItems() : null;
	local off = items != null ? items.getItemAtSlot(::Const.ItemSlot.Offhand) : null;
	local main = items != null ? items.getItemAtSlot(::Const.ItemSlot.Mainhand) : null;

	local hasShield = (off != null && ::Wuxia.hasMember(off, "isItemType") && off.isItemType(::Const.Items.ItemType.Shield))
		|| (tsk != null && tsk.hasSkill("effects.shieldwall"));
	if (hasShield)
	{
		return {
			FormKey      = "shield",
			FormName     = "破盾式",
			HitBonus     = 12,
			PenBonus     = 0.0,
			IgnoreShield = true,
			Summary      = "剑走偏锋越盾削腕：无视盾防加成，崩毁敌盾 35 点耐久、破盾墙并挂【失衡】"
		};
	}

	if (main != null)
	{
		if (::Wuxia.CombatRules.matchesWeapon(main, ["Spear", "Polearm", "Staff"]) || (tsk != null && tsk.hasSkill("effects.spearwall")))
		{
			return {
				FormKey      = "polearm",
				FormName     = "破枪式",
				HitBonus     = 14,
				PenBonus     = 0.04,
				IgnoreShield = false,
				Summary      = "顺杆欺身削指破阵：武艺 +14，破除拒马枪阵并挂【散劲虚弱】与【破绽】"
			};
		}
		if (::Wuxia.CombatRules.matchesWeapon(main, ["Bow", "Crossbow", "Firearm", "Throwing"]))
		{
			return {
				FormKey      = "ranged",
				FormName     = "破箭式",
				HitBonus     = 16,
				PenBonus     = 0.04,
				IgnoreShield = false,
				Summary      = "剑挑弓弦断机括：武艺 +16，卸除弩铳上膛弹药、震散 14 内息并挂【失衡】"
			};
		}
		if (::Wuxia.CombatRules.matchesWeapon(main, ["Flail", "Fist"]))
		{
			return {
				FormKey      = "whip_fist",
				FormName     = "破鞭掌式",
				HitBonus     = 14,
				PenBonus     = 0.05,
				IgnoreShield = true,
				Summary      = "截腕锁脉断奇兵：武艺 +14，削损 20 护甲并施加【点穴封气】"
			};
		}
		if (::Wuxia.CombatRules.matchesWeapon(main, ["Sword", "Saber", "Cleaver", "Axe", "Hammer", "Dagger"])
			|| (::Wuxia.hasMember(main, "isItemType") && main.isItemType(::Const.Items.ItemType.MeleeWeapon)))
		{
			return {
				FormKey      = "blade",
				FormName     = "破刀剑式",
				HitBonus     = 15,
				PenBonus     = 0.04,
				IgnoreShield = false,
				Summary      = "料敌机先卸刃势：武艺 +15，尽破格反回锋架势并挂【散劲虚弱】与【破绽】"
			};
		}
	}

	return info;
};

// ============================================================================
// Stream 3: Taiji / Douzhuan (`太和/姑苏`) — True Melee Deflection (`借力打力`)
// ============================================================================

::Wuxia.Streams.tryDeflectMeleeAttack <- function( _defender, _attacker, _isDouzhuan = false )
{
	local res = { mode = "none", redirectedTo = null, damageDealt = 0 };
	if (_defender == null || _attacker == null || !_defender.isAlive() || !_attacker.isAlive()) return res;
	if (!::Wuxia.hasMember(_attacker, "getTile") || _attacker.getTile() == null) return res;

	local aTile = _attacker.getTile();
	local secondEnemy = null;

	if (::Wuxia.hasMember(aTile, "hasNextTile"))
	{
		for (local d = 0; d < 6; d = ++d)
		{
			if (!aTile.hasNextTile(d)) continue;
			local nt = aTile.getNextTile(d);
			if (!::Wuxia.isTileOccupiedByActor(nt)) continue;
			local cand = nt.getEntity();
			if (cand == null || !cand.isAlive()) continue;
			if (::Wuxia.hasMember(cand, "getID") && ::Wuxia.hasMember(_attacker, "getID") && cand.getID() == _attacker.getID()) continue;
			if (!_defender.isAlliedWith(cand))
			{
				secondEnemy = cand;
				break;
			}
		}
	}

	// Compute base force from attacker's own properties so heavy hitters hurt their own allies hard!
	local aProps = ::Wuxia.hasMember(_attacker, "getCurrentProperties") ? _attacker.getCurrentProperties() : null;
	local rawAvg = 32;
	if (aProps != null && ("DamageRegularMin" in aProps) && ("DamageRegularMax" in aProps))
		rawAvg = ::Math.max(22, ::Math.floor((aProps.DamageRegularMin + aProps.DamageRegularMax) * 0.5));
	local mult = _isDouzhuan ? 1.00 : 0.85;

	// Case 1: Adjacent Second Enemy -> True `借力打力 / 斗转星移` Redirection!
	if (secondEnemy != null)
	{
		local redirHP = ::Math.max(12, ::Math.floor(rawAvg * mult * 0.55));
		local redirArm = ::Math.max(14, ::Math.floor(rawAvg * mult * 0.75));
		if (secondEnemy.getItems() != null)
		{
			local bArm = secondEnemy.getItems().getItemAtSlot(::Const.ItemSlot.Body);
			if (bArm != null && bArm.getArmor() > 0)
				bArm.setArmor(::Math.max(0, bArm.getArmor() - redirArm));
		}
		if (secondEnemy.getHitpoints() > redirHP + 1)
			secondEnemy.setHitpoints(secondEnemy.getHitpoints() - redirHP);
		else
			secondEnemy.setHitpoints(1);

		local ssk = secondEnemy.getSkills();
		if (ssk != null && !ssk.hasSkill("effects.wx_status_offbalance"))
			ssk.add(::new("scripts/skills/effects/wx_status_offbalance"));

		if (::Wuxia.TileField.isLiveTactical() && "KineticVFX" in ::Wuxia)
		{
			local ringB = _isDouzhuan ? "wx_pt_ring_violet" : "wx_pt_ring_jade";
			::Wuxia.KineticVFX.spawnShockwaveRing(_defender.getTile(), ringB, 0, 0.25, 1.55, 0.28, -12.0, 225);
			if (secondEnemy.getTile() != null)
				::Wuxia.KineticVFX.spawnShockwaveRing(secondEnemy.getTile(), ringB, 65, 0.25, 1.75, 0.32, -12.0, 235);
		}
		if (::Wuxia.TileField.isLiveTactical() && ::Tactical.EventLog != null)
		{
			local tagLbl = _isDouzhuan ? "【斗转星移】" : "【太极借力打力】";
			::Tactical.EventLog.log("[color=#127896]" + tagLbl + ::Const.UI.getColorizedEntityName(_defender) + " 圆转引化，将 " + ::Const.UI.getColorizedEntityName(_attacker) + " 的凶猛攻势原封偏转轰向 " + ::Const.UI.getColorizedEntityName(secondEnemy) + "！[/color]");
		}

		res.mode = "redirect_enemy";
		res.redirectedTo = secondEnemy;
		res.damageDealt = redirHP;
		return res;
	}

	// Case 2: Lone Attacker -> `四两拨千斤` Throw / Obstacle Collision!
	local dTile = ::Wuxia.hasMember(_defender, "getTile") ? _defender.getTile() : null;
	if (dTile != null && ::Wuxia.hasMember(dTile, "getDirectionTo") && ::Wuxia.hasMember(aTile, "hasNextTile"))
	{
		local pushDir = dTile.getDirectionTo(aTile);
		if (pushDir >= 0 && aTile.hasNextTile(pushDir))
		{
			local behind = aTile.getNextTile(pushDir);
			local canMove = behind != null && behind.IsEmpty && !behind.IsOccupiedByActor && ::Math.abs(behind.Level - aTile.Level) <= 1
				&& (aProps == null || (!aProps.IsImmuneToKnockBackAndGrab && !aProps.IsRooted));
			if (canMove && ::Wuxia.TileField.isLiveTactical())
			{
				::Tactical.getNavigator().teleport(_attacker, behind, null, null, true);
				res.mode = "flung_away";
			}
			else
			{
				// Slammed into wall/cliff/obstacle!
				local slamHP = 14;
				if (_attacker.getHitpoints() > slamHP + 1) _attacker.setHitpoints(_attacker.getHitpoints() - slamHP);
				else _attacker.setHitpoints(1);
				if (_attacker.getSkills() != null && !_attacker.getSkills().hasSkill("effects.wx_status_offbalance"))
					_attacker.getSkills().add(::new("scripts/skills/effects/wx_status_offbalance"));
				res.mode = "wall_slam";
				res.damageDealt = slamHP;
			}
			return res;
		}
	}

	return res;
};

// ============================================================================
// Stream 4: Shaolin / Beggar (`少室/丐帮`) — `隔山打牛` & `寸劲伏脉`
// ============================================================================

::Wuxia.Streams.applyHiddenForce <- function( _target, _stacks = 1, _instigator = null )
{
	if (_target == null || !_target.isAlive() || ::Wuxia.CombatRules.isUndeadOrConstruct(_target)) return 0;
	local sk = ::Wuxia.hasMember(_target, "getSkills") ? _target.getSkills() : null;
	if (sk == null) return 0;
	local hf = sk.getSkillByID("effects.wx_status_hidden_force");
	if (hf == null)
	{
		hf = ::new("scripts/skills/effects/wx_status_hidden_force");
		sk.add(hf);
		if (_stacks > 1) return hf.addStacks(_stacks - 1, _instigator);
		return 0;
	}
	return hf.addStacks(_stacks, _instigator);
};

// True `隔山打牛`: Palm force passes harmlessly/lightly through front shield-bearer and blasts rear 1~2 hexes!
::Wuxia.Streams.transmitThroughForce <- function( _user, _frontTarget, _frontTile )
{
	local res = { rearHits = 0, rearDamage = 0, rebound = false };
	if (_user == null || _frontTile == null) return res;
	local uTile = ::Wuxia.hasMember(_user, "getTile") ? _user.getTile() : null;
	if (uTile == null || !::Wuxia.hasMember(uTile, "getDirectionTo") || !::Wuxia.hasMember(_frontTile, "hasNextTile"))
		return res;

	local dir = uTile.getDirectionTo(_frontTile);
	local cur = _frontTile;
	for (local step = 1; step <= 2; step = ++step)
	{
		if (cur == null || dir < 0 || !cur.hasNextTile(dir)) break;
		cur = cur.getNextTile(dir);
		if (cur == null) break;
		if (::Wuxia.TileField.isLiveTactical() && "KineticVFX" in ::Wuxia)
			::Wuxia.KineticVFX.spawnShockwaveRing(cur, "wx_pt_ring_gold", step * 55, 0.25, 1.65, 0.30, -12.0, 230);

		if (::Wuxia.isTileOccupiedByActor(cur))
		{
			local rear = cur.getEntity();
			if (rear != null && rear.isAlive() && !_user.isAlliedWith(rear))
			{
				local shockHP = (step == 1) ? 26 : 18;
				if (rear.getHitpoints() > shockHP + 1) rear.setHitpoints(rear.getHitpoints() - shockHP);
				else rear.setHitpoints(1);
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(rear))
					::Wuxia.CombatRules.spendQi(rear, 10);
				if (rear.getSkills() != null && !rear.getSkills().hasSkill("effects.wx_status_offbalance"))
					rear.getSkills().add(::new("scripts/skills/effects/wx_status_offbalance"));
				::Wuxia.Streams.applyHiddenForce(rear, 1, _user);
				res.rearHits += 1;
				res.rearDamage += shockHP;
			}
		}
	}

	// If no rear enemy stood behind `_frontTarget`, internal wave rebounds inside `_frontTarget` (`寸劲回震`)!
	if (res.rearHits == 0 && _frontTarget != null && _frontTarget.isAlive())
	{
		res.rebound = true;
		::Wuxia.Streams.applyHiddenForce(_frontTarget, 2, _user);
	}
	else if (res.rearHits > 0 && ::Wuxia.TileField.isLiveTactical() && ::Tactical.EventLog != null)
	{
		::Tactical.EventLog.log("[color=#d9822b]【隔山打牛】" + ::Const.UI.getColorizedEntityName(_user) + " 浑厚内家掌力透体而出，隔着前排直震后阵 " + res.rearHits + " 名敌军脏腑！[/color]");
	}

	return res;
};

// ============================================================================
// Four-Meridian (`内 · 外 · 轻 · 横`) Chemical Reactions (Zero Stat Inflation!)
// ============================================================================

::Wuxia.Streams.triggerFourMeridianReaction <- function( _user, _target, _targetTile, _hit )
{
	if (_user == null || !_user.isAlive()) return "";
	local elem = ::Wuxia.TileField.getPrimaryNeigongElement(_user);
	local st = ::Wuxia.Streams.getState(_user);
	if (st != null && st.m.ReactionsUsed >= 2) return "";

	// 1. Yang Neigong × Strike: Melts frost, cauterizes mire, and chars +10 armor
	if (elem == "yang" && _targetTile != null)
	{
		if (::Wuxia.TileField.hasField(_targetTile, "abyss_frost"))
		{
			::Wuxia.TileField.removeField(_targetTile);
			::Wuxia.CombatRules.restoreQi(_user, 5);
			if (st != null) st.m.ReactionsUsed += 1;
			return "yang_melt_frost";
		}
		if (::Wuxia.TileField.hasField(_targetTile, "bitter_mire"))
		{
			::Wuxia.TileField.setField(_targetTile, "drought_scorch", 2, _user);
			if (st != null) st.m.ReactionsUsed += 1;
			return "yang_cauterize_mire";
		}
		if (_hit && _target != null && _target.isAlive() && ::Wuxia.hasMember(_target, "getItems") && _target.getItems() != null)
		{
			local bArm = _target.getItems().getItemAtSlot(::Const.ItemSlot.Body);
			if (bArm != null && bArm.getArmor() > 0)
			{
				bArm.setArmor(::Math.max(0, bArm.getArmor() - 10));
				if (st != null) st.m.ReactionsUsed += 1;
				return "yang_armor_sear";
			}
		}
	}
	// 2. Yin Neigong × Strike: Quenches scorch into cool mist (+6 Qi) & chills meridian (-6 Qi on target)
	else if (elem == "yin")
	{
		if (_targetTile != null && ::Wuxia.TileField.hasField(_targetTile, "drought_scorch"))
		{
			::Wuxia.TileField.removeField(_targetTile);
			::Wuxia.CombatRules.restoreQi(_user, 6);
			if (st != null) st.m.ReactionsUsed += 1;
			return "yin_quench_scorch";
		}
		if (_hit && _target != null && _target.isAlive() && !::Wuxia.CombatRules.isUndeadOrConstruct(_target))
		{
			::Wuxia.CombatRules.spendQi(_target, 6);
			if (st != null) st.m.ReactionsUsed += 1;
			return "yin_chill_qi";
		}
	}
	// 3. Evil / Eerie Neigong × Bleeding/Poisoned Target: Siphons 5 Qi
	else if (elem == "evil" && _hit && _target != null && _target.isAlive() && ::Wuxia.hasMember(_target, "getSkills") && _target.getSkills() != null)
	{
		local tsk = _target.getSkills();
		if (tsk.hasSkill("effects.bleeding") || tsk.hasSkill("effects.wx_status_poison_dart"))
		{
			::Wuxia.CombatRules.restoreQi(_user, 5);
			if (st != null) st.m.ReactionsUsed += 1;
			return "evil_siphon_qi";
		}
	}
	// 4. Harmony / Balanced Neigong: Restores 3 Qi steadiness on solid hit
	else if (elem == "harmony" && _hit)
	{
		::Wuxia.CombatRules.restoreQi(_user, 3);
		if (st != null) st.m.ReactionsUsed += 1;
		return "harmony_calm_qi";
	}
	return "";
};

// ============================================================================
// Global AGENTS.md Armor-Penetration Clamp Helper (`<= +25%` DirectDmgAdd!)
// ============================================================================
::Wuxia.Streams.addCappedPen <- function( _properties, _add )
{
	if (_properties == null || _add <= 0.0) return 0.0;
	local room = ::Math.maxf(0.0, 0.25 - _properties.DamageDirectAdd);
	local delta = ::Math.minf(room, _add);
	_properties.DamageDirectAdd += delta;
	return delta;
};

// ============================================================================
// Stream 5: Blade Sect (`居合藏锋·拔刀一闪` & `血刀门·血海刀煞`)
// ============================================================================
::Wuxia.Streams.triggerIaidoSheathe <- function( _user )
{
	local st = ::Wuxia.Streams.getOrCreateState(_user);
	if (st != null) st.m.IaidoSheathed = true;
};

::Wuxia.Streams.isIaidoReady <- function( _user )
{
	if (_user == null) return false;
	local st = ::Wuxia.Streams.getState(_user);
	if (st != null && st.m.IaidoSheathed) return true;
	local sk = ::Wuxia.hasMember(_user, "getSkills") ? _user.getSkills() : null;
	return sk != null && sk.hasSkill("effects.wx_status_poise_charge");
};

::Wuxia.Streams.applyIaidoPreHit <- function( _user, _properties )
{
	if (!::Wuxia.Streams.isIaidoReady(_user) || _properties == null) return false;
	::Wuxia.Streams.addCappedPen(_properties, 0.10);
	_properties.HitChance[::Const.BodyPart.Head] += 15;
	return true;
};

::Wuxia.Streams.consumeIaidoPostHit <- function( _user, _target, _killed = false )
{
	local st = ::Wuxia.Streams.getState(_user);
	local wasReady = ::Wuxia.Streams.isIaidoReady(_user);
	if (st != null) st.m.IaidoSheathed = false;
	if (!wasReady || _user == null || !_user.isAlive()) return false;

	local targetDead = _killed || (_target != null && ::Wuxia.hasMember(_target, "isAlive") && !_target.isAlive());
	if (targetDead && st != null && !st.m.IaidoRefreshedThisTurn)
	{
		st.m.IaidoRefreshedThisTurn = true;
		st.m.IaidoSheathed = true;
		local sk = ::Wuxia.hasMember(_user, "getSkills") ? _user.getSkills() : null;
		if (sk != null && !sk.hasSkill("effects.wx_status_poise_charge"))
			sk.add(::new("scripts/skills/effects/wx_status_poise_charge"));
		return true;
	}
	return false;
};

::Wuxia.Streams.triggerBloodBlade <- function( _user, _target )
{
	local res = { stacks = 0, burstDmg = 0, healed = 0 };
	if (_user == null || !_user.isAlive()) return res;
	local st = ::Wuxia.Streams.getOrCreateState(_user);
	if (st != null)
	{
		st.addBloodBlade(1);
		res.stacks = st.m.BloodBladeStacks;
	}
	if (_target != null && _target.isAlive() && !::Wuxia.CombatRules.isUndeadOrConstruct(_target))
	{
		local tsk = ::Wuxia.hasMember(_target, "getSkills") ? _target.getSkills() : null;
		if (tsk != null && tsk.hasSkill("effects.bleeding"))
		{
			local burst = 8 + res.stacks * 4;
			if (_target.getHitpoints() > burst + 1) _target.setHitpoints(_target.getHitpoints() - burst);
			else _target.setHitpoints(1);
			res.burstDmg = burst;
		}
		local heal = 6 + res.stacks * 2;
		_user.setHitpoints(::Math.min(_user.getHitpointsMax(), _user.getHitpoints() + heal));
		res.healed = heal;
	}
	return res;
};

// ============================================================================
// Stream 6: Spear / Polearm / Staff (`挑飞过肩换位 / 铁枪拒马 / 打狗断蓄力`)
// ============================================================================
::Wuxia.Streams.vaultFlipOverShoulder <- function( _user, _target )
{
	if (_user == null || _target == null || !_user.isAlive() || !_target.isAlive()) return false;
	if (!::Wuxia.isOnMap(_user) || !::Wuxia.isOnMap(_target)) return false;
	local uTile = _user.getTile();
	local tTile = _target.getTile();
	if (uTile == null || tTile == null || uTile.getDistanceTo(tTile) != 1) return false;

	local tProps = ::Wuxia.hasMember(_target, "getCurrentProperties") ? _target.getCurrentProperties() : null;
	if (tProps != null && (tProps.IsImmuneToKnockBackAndGrab || tProps.IsRooted)) return false;

	local backDir = ::Wuxia.hasMember(tTile, "getDirectionTo") ? tTile.getDirectionTo(uTile) : -1;
	if (backDir < 0 || !::Wuxia.hasMember(uTile, "hasNextTile") || !uTile.hasNextTile(backDir)) return false;
	local behindUser = uTile.getNextTile(backDir);
	if (behindUser == null || !behindUser.IsEmpty || behindUser.IsOccupiedByActor || ::Math.abs(behindUser.Level - uTile.Level) > 1)
		return false;

	if (::Wuxia.TileField.isLiveTactical())
	{
		::Tactical.getNavigator().teleport(_target, behindUser, null, null, true);
	}
	else
	{
		tTile.IsOccupiedByActor = false;
		if ("Occupant" in tTile) tTile.Occupant = null;
		behindUser.IsOccupiedByActor = true;
		if ("Occupant" in behindUser) behindUser.Occupant = _target;
		if ("Tile" in _target) _target.Tile = behindUser;
	}

	local tsk = ::Wuxia.hasMember(_target, "getSkills") ? _target.getSkills() : null;
	if (tsk != null && !tsk.hasSkill("effects.wx_status_offbalance"))
		tsk.add(::new("scripts/skills/effects/wx_status_offbalance"));
	return true;
};

::Wuxia.Streams.activateSpearWallStance <- function( _user, _charges = 2 )
{
	local st = ::Wuxia.Streams.getOrCreateState(_user);
	if (st != null && _charges > st.m.SpearWallCharges)
		st.m.SpearWallCharges = _charges;
};

::Wuxia.Streams.interruptEnemyCharge <- function( _user, _target, _breakPts = 2 )
{
	local broke = false;
	if (_target == null || !_target.isAlive()) return false;
	local tsk = ::Wuxia.hasMember(_target, "getSkills") ? _target.getSkills() : null;
	if (tsk != null)
	{
		if (tsk.hasSkill("effects.wx_status_poise_charge"))
		{
			tsk.removeByID("effects.wx_status_poise_charge");
			broke = true;
		}
		if (tsk.hasSkill("effects.wx_status_counter_stance"))
		{
			tsk.removeByID("effects.wx_status_counter_stance");
			broke = true;
		}
		if ("ShanHai" in ::Wuxia && "findBossTrait" in ::Wuxia.ShanHai)
		{
			local bt = ::Wuxia.ShanHai.findBossTrait(tsk);
			if (bt != null)
			{
				if ("IsChargingOmen" in bt.m && bt.m.IsChargingOmen)
				{
					bt.m.OmenBreakPts += _breakPts;
					if (bt.m.OmenBreakPts >= bt.m.OmenBreakNeeded)
					{
						bt.m.IsChargingOmen = false;
						bt.m.OmenBreakPts = 0;
						broke = true;
					}
				}
				if ("IsInhalingWind" in bt.m && bt.m.IsInhalingWind)
				{
					bt.m.IsInhalingWind = false;
					bt.m.WindCharged = false;
					broke = true;
				}
				if ("IsChargingApocalypse" in bt.m && bt.m.IsChargingApocalypse)
				{
					bt.m.IsChargingApocalypse = false;
					broke = true;
				}
			}
		}
	}
	if ("CraftBridge" in ::Wuxia && "applyBossCounterHit" in ::Wuxia.CraftBridge)
	{
		local cr = ::Wuxia.CraftBridge.applyBossCounterHit(_user, _target, { BreakPts = _breakPts });
		if (cr.BrokeCharge) broke = true;
	}
	return broke;
};

// ============================================================================
// Stream 7: Toad Force (`金蟾蓄劲`), Hidden-Force Detonation & Tangmen Caltrops (`子母收镖`)
// ============================================================================
::Wuxia.Streams.peekToadForce <- function( _user )
{
	local st = ::Wuxia.Streams.getState(_user);
	return st != null ? st.m.ToadForceStacks : 0;
};

::Wuxia.Streams.consumeToadForce <- function( _user )
{
	local st = ::Wuxia.Streams.getState(_user);
	if (st == null || st.m.ToadForceStacks <= 0) return 0;
	local cur = st.m.ToadForceStacks;
	st.m.ToadForceStacks = 0;
	return cur;
};

::Wuxia.Streams.detonateHiddenForceNow <- function( _user, _target )
{
	if (_target == null || !_target.isAlive()) return 0;
	local tsk = ::Wuxia.hasMember(_target, "getSkills") ? _target.getSkills() : null;
	if (tsk == null || !tsk.hasSkill("effects.wx_status_hidden_force")) return 0;
	return ::Wuxia.Streams.applyHiddenForce(_target, 3, _user);
};

::Wuxia.Streams.plantTangmenCaltrop <- function( _user, _nearTile )
{
	if (_user == null || _nearTile == null) return null;
	local chosen = _nearTile;
	if (::Wuxia.isTileOccupiedByActor(_nearTile) && ::Wuxia.hasMember(_nearTile, "hasNextTile"))
	{
		for (local d = 0; d < 6; d = ++d)
		{
			if (!_nearTile.hasNextTile(d)) continue;
			local cand = _nearTile.getNextTile(d);
			if (cand != null && !cand.IsOccupiedByActor && !::Wuxia.TileField.hasField(cand, "tangmen_trap"))
			{
				chosen = cand;
				break;
			}
		}
	}
	::Wuxia.TileField.setField(chosen, "tangmen_trap", 3, _user);
	return chosen;
};

::Wuxia.Streams.recallTangmenCaltrops <- function( _user, _targetTile )
{
	local res = { recalled = 0, bonusDmg = 0, ammoRestored = 0 };
	if (_user == null || _targetTile == null) return res;
	local uid = ::Wuxia.hasMember(_user, "getID") ? _user.getID() : -1;
	local traps = ::Wuxia.TileField.getFieldsByKind("tangmen_trap", uid);
	if (traps.len() == 0) return res;

	foreach (tr in traps)
	{
		::Wuxia.TileField.removeField(tr.TileRef);
		res.recalled += 1;
	}

	if (::Wuxia.isTileOccupiedByActor(_targetTile))
	{
		local foe = _targetTile.getEntity();
		if (foe != null && foe.isAlive() && !_user.isAlliedWith(foe))
		{
			local cutHP = ::Math.min(28, res.recalled * 10);
			if (foe.getHitpoints() > cutHP + 1) foe.setHitpoints(foe.getHitpoints() - cutHP);
			else foe.setHitpoints(1);
			res.bonusDmg = cutHP;
		}
	}

	if (::Wuxia.hasMember(_user, "getItems") && _user.getItems() != null)
	{
		local wpn = _user.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
		if (wpn != null && ::Wuxia.hasMember(wpn, "getAmmoMax") && wpn.getAmmoMax() > 0 && wpn.getAmmo() < wpn.getAmmoMax())
		{
			wpn.setAmmo(::Math.min(wpn.getAmmoMax(), wpn.getAmmo() + 1));
			res.ammoRestored = 1;
		}
	}
	::Wuxia.CombatRules.restoreQi(_user, ::Math.min(12, res.recalled * 4));
	return res;
};
