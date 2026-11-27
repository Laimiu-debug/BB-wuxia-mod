// Base class for weapon-bound Wuxia active moves (with 4-Frame Choreography & Live-Computed Tactical Tooltips)

this.wx_move_base <- this.inherit("scripts/skills/skill", {
	m = {
		RequiredWeaponTypes = [],
		InflictStatusID     = null,
		InflictStatusScript = null,
		InflictChancePct    = 100,
		WX_VfxBrush         = null,
		WX_AnimID           = "wx_anim_01",
		WX_AnimMode         = "slash",
		WX_ChoreoID         = null,
		WX_TagMechanic      = "",
		WX_ComboForms       = null
	},

	function wxGetActiveComboForm()
	{
		if (!::Wuxia.hasMember(this.m, "WX_ComboForms") || this.m.WX_ComboForms == null || this.m.WX_ComboForms.len() == 0)
			return null;
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		local idx = (actor != null && ("Streams" in ::Wuxia)) ? ::Wuxia.Streams.getComboStage(actor, this.m.ID) : 0;
		if (idx < 0 || idx >= this.m.WX_ComboForms.len()) idx = 0;
		return this.m.WX_ComboForms[idx];
	}

	function getName()
	{
		local cf = this.wxGetActiveComboForm();
		if (cf != null && ("Name" in cf)) return cf.Name;
		return this.skill.getName();
	}

	function getDescription()
	{
		local cf = this.wxGetActiveComboForm();
		if (cf != null && ("Description" in cf)) return cf.Description;
		return this.skill.getDescription();
	}

	function getActionPointCost()
	{
		local cf = this.wxGetActiveComboForm();
		if (cf != null && ("AP" in cf)) return cf.AP;
		return this.skill.getActionPointCost();
	}

	function getFatigueCost()
	{
		local cf = this.wxGetActiveComboForm();
		local cost = this.skill.getFatigueCost();
		local cfFat = (cf != null && ("Fatigue" in cf)) ? cf.Fatigue : ((cf != null && ("Qi" in cf)) ? cf.Qi : -1);
		if (cfFat >= 0 && this.m.FatigueCost > 0)
		{
			cost = ::Math.max(0, ::Math.round(cost * (cfFat.tofloat() / this.m.FatigueCost.tofloat())));
		}
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		if (actor != null && ("Traits" in ::Wuxia) && ("getMoveQiSaveMult" in ::Wuxia.Traits))
		{
			local save = ::Wuxia.Traits.getMoveQiSaveMult(actor, this);
			if (save > 0.0)
				cost = ::Math.max(0, ::Math.floor(cost * (1.0 - save)));
		}
		return cost;
	}

	function create()
	{
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.OffensiveTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsStacking = false;
		this.m.IsAttack = true;
		this.m.IsWeaponSkill = true;
		this.m.IsDoingForwardMove = false;
		this.m.InjuriesOnBody = this.Const.Injury.CuttingBody;
		this.m.InjuriesOnHead = this.Const.Injury.CuttingHead;
		this.m.DirectDamageMult = 0.25;
	}

	function wxHasRequiredWeapon()
	{
		local container = this.getContainer();
		local actor = container == null ? null : container.getActor();
		local items = actor == null ? null : actor.getItems();
		local weapon = items == null ? null : items.getItemAtSlot(::Const.ItemSlot.Mainhand);
		return ::Wuxia.CombatRules.matchesWeapon(weapon, this.m.RequiredWeaponTypes);
	}

	function wxSyncAuthenticSounds()
	{
		if (!("VFX" in ::Wuxia) || !("resolveMoveSoundBank" in ::Wuxia.VFX)) return;
		if (!("WX_VanillaSoundBackup" in this.m))
		{
			this.m.WX_VanillaSoundBackup <- {
				use = (typeof this.m.SoundOnUse == "array") ? clone this.m.SoundOnUse : [],
				hit = (typeof this.m.SoundOnHit == "array") ? clone this.m.SoundOnHit : []
			};
		}
		if (!::Wuxia.VFX.isSfxEnabled())
		{
			this.m.SoundOnUse = clone this.m.WX_VanillaSoundBackup.use;
			this.m.SoundOnHit = clone this.m.WX_VanillaSoundBackup.hit;
			return;
		}
		local bank = ::Wuxia.VFX.resolveMoveSoundBank(this);
		if (bank != null)
		{
			this.m.SoundOnUse = clone bank.use;
			this.m.SoundOnHit = clone bank.hit;
		}
	}

	function onAdded()
	{
		this.wxSyncAuthenticSounds();
	}

	function isHidden()
	{
		return this.skill.isHidden() || !this.wxHasRequiredWeapon();
	}

	function isUsable()
	{
		this.wxSyncAuthenticSounds();
		if ((::Wuxia.hasMember(this.m, "Cooldown")) && this.m.Cooldown > 0) return false;
		if (!this.skill.isUsable() || !this.wxHasRequiredWeapon()) return false;
		if (this.m.RequiredWeaponTypes.find("Throwing") != null)
		{
			local item = this.getContainer().getActor().getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
			return item != null && (item.getAmmoMax() == 0 || item.getAmmo() > 0);
		}
		if (this.m.RequiredWeaponTypes.find("Firearm") != null || this.m.RequiredWeaponTypes.find("Crossbow") != null || this.m.RequiredWeaponTypes.find("Bow") != null)
		{
			local actor = this.getContainer().getActor();
			local items = actor.getItems();
			local weapon = items.getItemAtSlot(::Const.ItemSlot.Mainhand);
			if (::Wuxia.CombatRules.matchesWeapon(weapon, ["Firearm", "Crossbow"]))
				return !::Wuxia.hasMember(weapon, "isLoaded") || weapon.isLoaded();
			if (::Wuxia.CombatRules.matchesWeapon(weapon, ["Bow"]))
			{
				if (!actor.isPlayerControlled()) return true;
				local ammo = items.getItemAtSlot(::Const.ItemSlot.Ammo);
				return ammo != null && ammo.getAmmoType() == ::Const.Items.AmmoType.Arrows
					&& (ammo.getAmmoMax() == 0 || ammo.getAmmo() > 0);
			}
		}
		return true;
	}

	function wxThrowAt( _user, _target )
	{
		local item = _user.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
		local hit = this.attackEntity(_user, _target);
		if (item != null && item.getAmmoMax() > 0) item.consumeAmmo();
		return hit;
	}

	function wxShootBowAt( _user, _target )
	{
		local items = _user.getItems();
		local weapon = items.getItemAtSlot(::Const.ItemSlot.Mainhand);
		local hit = this.attackEntity(_user, _target);
		if (::Wuxia.CombatRules.matchesWeapon(weapon, ["Firearm"]))
		{
			if (::Wuxia.hasMember(weapon, "setLoaded")) weapon.setLoaded(false);
			if (!this.getContainer().hasSkill("actives.reload_handgonne"))
			{
				try
				{
					local rg = ::new("scripts/skills/actives/reload_handgonne_skill");
					rg.setItem(weapon);
					rg.setFatigueCost(::Math.max(0, rg.getFatigueCostRaw() + weapon.m.FatigueOnSkillUse));
					this.getContainer().add(rg);
				}
				catch (_e) {}
			}
		}
		else if (::Wuxia.CombatRules.matchesWeapon(weapon, ["Crossbow"]))
		{
			weapon.setLoaded(false);
			if (!this.getContainer().hasSkill("actives.reload_bolt"))
			{
				local reload = ::new("scripts/skills/actives/reload_bolt");
				reload.setItem(weapon);
				reload.setFatigueCost(::Math.max(0, reload.getFatigueCostRaw() + weapon.m.FatigueOnSkillUse));
				this.getContainer().add(reload);
			}
		}
		else if (_user.isPlayerControlled())
		{
			local ammo = items.getItemAtSlot(::Const.ItemSlot.Ammo);
			if (ammo != null && ammo.getAmmoMax() > 0) ammo.consumeAmmo();
		}
		return hit;
	}

	function findTileToKnockBackTo( _userTile, _targetTile )
	{
		if (_userTile == null || _targetTile == null) return null;
		local dir = _userTile.getDirectionTo(_targetTile);
		if (_targetTile.hasNextTile(dir))
		{
			local knockToTile = _targetTile.getNextTile(dir);
			if (knockToTile.IsEmpty && !knockToTile.IsOccupiedByActor && ::Math.abs(knockToTile.Level - _userTile.Level) <= 1 && ::Math.abs(knockToTile.Level - _targetTile.Level) <= 1)
				return knockToTile;
		}
		return null;
	}

	function wxTryKnockback( _user, _target )
	{
		if (_user == null || _target == null || !_target.isAlive() || !_user.isPlacedOnMap() || !_target.isPlacedOnMap())
			return false;
		local props = _target.getCurrentProperties();
		if (props.IsImmuneToKnockBackAndGrab || props.IsRooted) return false;
		local tTile = _target.getTile();
		local dir = _user.getTile().getDirectionTo(tTile);
		if (!tTile.hasNextTile(dir)) return false;
		local dest = tTile.getNextTile(dir);
		if (dest.IsOccupiedByActor || !dest.IsEmpty || ::Math.abs(dest.Level - tTile.Level) > 1)
			return false;
		::Tactical.getNavigator().teleport(_target, dest, null, null, true);
		return true;
	}

	function wxTryPullToAdjacent( _user, _target )
	{
		if (_user == null || _target == null || !_target.isAlive() || !_user.isPlacedOnMap() || !_target.isPlacedOnMap())
			return false;
		local uTile = _user.getTile();
		local tTile = _target.getTile();
		if (uTile.getDistanceTo(tTile) <= 1) return false;
		local props = _target.getCurrentProperties();
		if (props.IsImmuneToKnockBackAndGrab || props.IsRooted) return false;
		local dir = uTile.getDirectionTo(tTile);
		if (!uTile.hasNextTile(dir)) return false;
		local mid = uTile.getNextTile(dir);
		if (mid.IsOccupiedByActor || !mid.IsEmpty || ::Math.abs(mid.Level - tTile.Level) > 1)
			return false;
		::Tactical.getNavigator().teleport(_target, mid, null, null, true);
		return true;
	}

	// =========================================================================
	// 12 Distinctive Wuxia Martial Archetype Mechanics (Anti-Homogenization)
	// =========================================================================
	function wxResolveTagMechanic()
	{
		if (::Wuxia.hasMember(this.m, "WX_TagMechanic") && this.m.WX_TagMechanic != null && this.m.WX_TagMechanic != "")
			return this.m.WX_TagMechanic;
		local id = this.getID();
		if (id != null && ("CombatRules" in ::Wuxia) && ("SkillMechanics" in ::Wuxia.CombatRules) && (id in ::Wuxia.CombatRules.SkillMechanics))
		{
			this.m.WX_TagMechanic <- ::Wuxia.CombatRules.SkillMechanics[id];
			return this.m.WX_TagMechanic;
		}
		return "";
	}

	function wxApplyTagPreHitProps( _targetEntity, _properties )
	{
		local cont0 = this.getContainer();
		local user0 = cont0 != null ? cont0.getActor() : null;
		if (user0 != null && ("Streams" in ::Wuxia))
		{
			local stW = ::Wuxia.Streams.getState(user0);
			if (stW != null && stW.m.WindSteps > 0)
			{
				if (this.isRanged()) _properties.RangedSkill += stW.m.WindSteps * 3;
				else _properties.MeleeSkill += stW.m.WindSteps * 3;
			}
		}
		local tag = this.wxResolveTagMechanic();
		if (tag == "") return;
		local cont = this.getContainer();
		local user = cont != null ? cont.getActor() : null;

		if (tag == "detonate_opening" && _targetEntity != null && _targetEntity.isAlive() && _targetEntity.getSkills() != null)
		{
			if (_targetEntity.getSkills().hasSkill("effects.wx_status_opening"))
			{
				_properties.MeleeSkill += 12;
				local roomOp = ::Math.maxf(0.0, 0.25 - _properties.DamageDirectAdd);
				_properties.DamageDirectAdd += ::Math.minf(roomOp, 0.06);
			}
		}
		else if (tag == "surround_scale" && user != null && ::Wuxia.isOnMap(user))
		{
			local uTile = user.getTile();
			local adjFoes = 0;
			for (local d = 0; d < 6; d = ++d)
			{
				if (!uTile.hasNextTile(d)) continue;
				local nt = uTile.getNextTile(d);
				if (nt.IsOccupiedByActor && nt.getEntity() != null && nt.getEntity().isAlive() && !user.isAlliedWith(nt.getEntity()))
					adjFoes += 1;
			}
			if (adjFoes >= 2)
			{
				_properties.MeleeSkill += ::Math.min(12, (adjFoes - 1) * 4);
				_properties.DamageArmorMult *= (1.0 + ::Math.minf(0.24, (adjFoes - 1) * 0.08));
			}
		}
		else if (tag == "high_ground" && user != null && _targetEntity != null && ::Wuxia.isOnMap(user) && ::Wuxia.isOnMap(_targetEntity))
		{
			local diff = user.getTile().Level - _targetEntity.getTile().Level;
			if (diff > 0)
			{
				_properties.RangedSkill += diff * 6;
				_properties.MeleeSkill += diff * 6;
				_properties.DamageDirectAdd += ::Math.minf(0.12, diff * 0.06);
			}
		}
	}

	function wxGetMechanicTooltipText()
	{
		local tag = this.wxResolveTagMechanic();
		if (tag == "step_through")     return "【掠影过身】出招后若目标正后方为空地，借势穿过敌身落至其背后（无视截击）";
		if (tag == "backstep")         return "【燕返脱兔】出招后若身旁有敌军威胁，借反震之力向后方空位轻跃脱战 1 格";
		if (tag == "push_advance")     return "【摧锋踏进】震退目标 1 格破除架势，并自动前踏一步抢占目标原格撕裂阵线";
		if (tag == "detonate_opening") return "【破绽引爆】对带『破绽』目标无视盾防且命中+8；命中引爆破绽回气 8 点并追加 10 点透脉伤";
		if (tag == "detonate_bleed")   return "【血煞催创】命中『流血』目标时撕裂旧创，立即爆出 14 点直伤并为自身恢复 6 点气血";
		if (tag == "concuss_armor")    return "【隔甲寸劲】敌甲越厚反震越烈：按目标头身护甲直接震散最高 18 点内息，重甲者追加失衡/内伤";
		if (tag == "pierce_line")      return "【隔山贯阵】劲力穿透主目标，对其正后方紧邻一格的敌军追加一次 65% 威力的贯体杀伤";
		if (tag == "spread_venom")     return "【蛊毒蔓生】命中已中毒目标时催发毒雾爆散，将『奇毒』传染给相邻最多 2 名敌军并蚀甲 12 点";
		if (tag == "shatter_shield")   return "【断盾余威】重创敌盾 26 点耐久；若目标无盾或当击碎盾，余威直贯胸膛削甲 18 点并挂失衡";
		if (tag == "pull_closer")      return "【擒龙摄影】两格命中将远处敌军强拽至身前包围圈，贴身命中则卸散其 8 点内息";
		if (tag == "surround_scale")   return "【困兽破围】陷入合围时越战越勇：每多 1 名贴身敌军额外 +4 命中、+8% 破甲，命中回气 5 点";
		if (tag == "high_ground")      return "【天外凌空】居高临下出招每层高度差额外 +6 命中与 +6% 穿甲，命中高甲目标削其护甲";
		return "";
	}

	function wxTriggerTagPostMechanic( _user, _target, _targetTile, _hit )
	{
		if (_user != null && _user.isAlive() && ("Streams" in ::Wuxia))
		{
			local stW = ::Wuxia.Streams.getState(_user);
			if (stW != null && stW.m.WindSteps > 0) stW.consumeWindSteps();
			::Wuxia.Streams.triggerFourMeridianReaction(_user, _target, _targetTile, _hit);
		}
		local tag = this.wxResolveTagMechanic();
		if (tag == "" || _user == null || !_user.isAlive() || !::Wuxia.isOnMap(_user)) return;
		local uTile = _user.getTile();
		local uProps = _user.getCurrentProperties();

		if (tag == "step_through" && _targetTile != null && uTile.getDistanceTo(_targetTile) == 1 && !uProps.IsRooted)
		{
			local dir = uTile.getDirectionTo(_targetTile);
			if (_targetTile.hasNextTile(dir))
			{
				local behind = _targetTile.getNextTile(dir);
				if (behind != null && behind.IsEmpty && !behind.IsOccupiedByActor && ::Math.abs(behind.Level - uTile.Level) <= 1)
				{
					::Tactical.getNavigator().teleport(_user, behind, null, null, false);
				}
			}
			return;
		}

		if (tag == "backstep" && _targetTile != null && !uProps.IsRooted)
		{
			local hasAdjEnemy = false;
			for (local d0 = 0; d0 < 6; d0 = ++d0)
			{
				if (!uTile.hasNextTile(d0)) continue;
				local adj0 = uTile.getNextTile(d0);
				if (adj0.IsOccupiedByActor && adj0.getEntity() != null && adj0.getEntity().isAlive() && !_user.isAlliedWith(adj0.getEntity()))
				{
					hasAdjEnemy = true;
					break;
				}
			}
			if (hasAdjEnemy)
			{
				local bestRetreat = null;
				local bestDist = _targetTile.getDistanceTo(uTile);
				for (local d1 = 0; d1 < 6; d1 = ++d1)
				{
					if (!uTile.hasNextTile(d1)) continue;
					local cand = uTile.getNextTile(d1);
					if (cand == null || !cand.IsEmpty || cand.IsOccupiedByActor || ::Math.abs(cand.Level - uTile.Level) > 1) continue;
					local dToT = cand.getDistanceTo(_targetTile);
					if (dToT > bestDist)
					{
						bestDist = dToT;
						bestRetreat = cand;
					}
				}
				if (bestRetreat != null)
					::Tactical.getNavigator().teleport(_user, bestRetreat, null, null, false);
			}
			return;
		}

		if (!_hit) return;

		if (tag == "push_advance" && _targetTile != null)
		{
			if (_target != null && _target.isAlive() && ::Wuxia.isOnMap(_target) && _target.getTile().ID == _targetTile.ID)
			{
				local tsk = _target.getSkills();
				if (tsk != null) { tsk.removeByID("effects.shieldwall"); tsk.removeByID("effects.spearwall"); }
				this.wxTryKnockback(_user, _target);
			}
			if (!uProps.IsRooted && uTile.getDistanceTo(_targetTile) == 1 && _targetTile.IsEmpty && !_targetTile.IsOccupiedByActor && ::Math.abs(_targetTile.Level - uTile.Level) <= 1)
			{
				::Tactical.getNavigator().teleport(_user, _targetTile, null, null, false);
			}
		}
		else if (tag == "detonate_opening" && _target != null && _target.isAlive() && _target.getSkills() != null)
		{
			local tsk2 = _target.getSkills();
			if (tsk2.hasSkill("effects.wx_status_opening"))
			{
				tsk2.removeByID("effects.wx_status_opening");
				::Wuxia.CombatRules.restoreQi(_user, 8);
				if (_target.getHitpoints() > 11) _target.setHitpoints(_target.getHitpoints() - 10);
				if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_target, "wx_vfx_07", "wx_fx_sword_phantom", 0, 120, 1.12);
			}
		}
		else if (tag == "detonate_bleed" && _target != null && _target.isAlive() && _target.getSkills() != null)
		{
			if (_target.getSkills().hasSkill("effects.bleeding") && !::Wuxia.CombatRules.isUndeadOrConstruct(_target))
			{
				if (_target.getHitpoints() > 15) _target.setHitpoints(_target.getHitpoints() - 14);
				else _target.setHitpoints(1);
				if (_user.getHitpoints() < _user.getHitpointsMax())
					_user.setHitpoints(::Math.min(_user.getHitpointsMax(), _user.getHitpoints() + 6));
				if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_target, "wx_vfx_06", "wx_fx_blood_orb", 0, 0, 1.14);
			}
		}
		else if (tag == "concuss_armor" && _target != null && _target.isAlive())
		{
			local totalArm = _target.getArmor(::Const.BodyPart.Body) + _target.getArmor(::Const.BodyPart.Head);
			local qiShock = ::Math.min(18, ::Math.max(4, ::Math.floor(totalArm / 18)));
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(_target))
				::Wuxia.CombatRules.spendQi(_target, qiShock);
			if (totalArm >= 140)
				this.wxApplyStatusToTarget(_target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		else if (tag == "pierce_line" && _targetTile != null && !("WX_InLinePierce" in this.m && this.m.WX_InLinePierce))
		{
			local dirL = uTile.getDirectionTo(_targetTile);
			if (_targetTile.hasNextTile(dirL))
			{
				local backT = _targetTile.getNextTile(dirL);
				if (backT != null && backT.IsOccupiedByActor)
				{
					local rearEnt = backT.getEntity();
					if (rearEnt != null && rearEnt.isAlive() && !_user.isAlliedWith(rearEnt))
					{
						if ("VFX" in ::Wuxia) ::Wuxia.VFX.playAoESecondaryVfx(this, _user, backT, 45);
						local rArm = rearEnt.getItems() != null ? rearEnt.getItems().getItemAtSlot(::Const.ItemSlot.Body) : null;
						if (rArm != null && rArm.getArmor() > 0)
							rArm.setArmor(::Math.max(0, rArm.getArmor() - 16));
						if (rearEnt.getHitpoints() > 15) rearEnt.setHitpoints(rearEnt.getHitpoints() - 14);
						this.wxApplyStatusToTarget(rearEnt, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
					}
				}
			}
		}
		else if (tag == "spread_venom" && _targetTile != null && _target != null && _target.getSkills() != null)
		{
			local spreadCnt = 0;
			for (local dv = 0; dv < 6; dv = ++dv)
			{
				if (!_targetTile.hasNextTile(dv)) continue;
				local adjV = _targetTile.getNextTile(dv);
				if (!adjV.IsOccupiedByActor) continue;
				local vEnt = adjV.getEntity();
				if (vEnt != null && vEnt.isAlive() && !_user.isAlliedWith(vEnt) && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(vEnt))
				{
					this.wxApplyStatusToTarget(vEnt, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart");
					if (vEnt.getItems() != null)
					{
						local vb = vEnt.getItems().getItemAtSlot(::Const.ItemSlot.Body);
						if (vb != null && vb.getArmor() > 0) vb.setArmor(::Math.max(0, vb.getArmor() - 12));
					}
					spreadCnt += 1;
					if (spreadCnt >= 2) break;
				}
			}
		}
		else if (tag == "shatter_shield" && _target != null && _target.isAlive() && _target.getItems() != null)
		{
			local offS = _target.getItems().getItemAtSlot(::Const.ItemSlot.Offhand);
			local hadShield = (offS != null && ::Wuxia.hasMember(offS, "isItemType") && offS.isItemType(::Const.Items.ItemType.Shield));
			if (hadShield)
			{
				offS.applyShieldDamage(26);
				offS = _target.getItems().getItemAtSlot(::Const.ItemSlot.Offhand);
			}
			if (!hadShield || offS == null || offS.getCondition() <= 0)
			{
				local tb = _target.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (tb != null && tb.getArmor() > 0) tb.setArmor(::Math.max(0, tb.getArmor() - 18));
				this.wxApplyStatusToTarget(_target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
		}
		else if (tag == "pull_closer" && _target != null && _target.isAlive())
		{
			if (!this.wxTryPullToAdjacent(_user, _target) && !::Wuxia.CombatRules.isUndeadOrConstruct(_target))
				::Wuxia.CombatRules.spendQi(_target, 8);
		}
		else if (tag == "surround_scale")
		{
			::Wuxia.CombatRules.restoreQi(_user, 5);
		}
		else if (tag == "high_ground" && _target != null && _target.isAlive() && _target.getItems() != null)
		{
			local hb = _target.getItems().getItemAtSlot(::Const.ItemSlot.Body);
			if (hb != null && hb.getArmor() > 0) hb.setArmor(::Math.max(0, hb.getArmor() - 14));
		}
	}

	function getFatigueCost()
	{
		local cf = this.wxGetActiveComboForm();
		local cost = (cf != null && ("Fatigue" in cf)) ? cf.Fatigue : this.skill.getFatigueCost();
		local container = this.getContainer();
		local actor = container == null ? null : container.getActor();
		local c = actor == null ? null : ::Wuxia.Slots.getContainer(actor);
		local disc = (c != null && c.m.CachedAggFlags != null) ? c.m.CachedAggFlags.WeaponQiDiscount : 0.0;
		if (container != null && container.hasSkill("trait.wx_jiangu") && actor != null && ::Wuxia.hasMember(actor, "getItems") && actor.getItems() != null)
		{
			local mw = actor.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
			if (mw != null && ::Wuxia.CombatRules.matchesWeapon(mw, ["Sword", "Dagger"]))
				disc = ::Math.maxf(disc, 0.10);
		}
		if (disc > 0.0)
		{
			cost = ::Math.max(1, ::Math.floor(cost * (1.0 - disc)));
		}
		// Single-hand empty-offhand (`孤锋诀`) reduces follow-up combo step Qi cost by 2!
		if (cf != null && ("Stage" in cf) && cf.Stage > 0 && c != null && c.m.CachedAggFlags != null
			&& c.m.CachedAggFlags.EmptyOffhandPen > 0.0 && ::Wuxia.CombatRules.hasSingleHandEmptyOffhand(actor))
		{
			cost = ::Math.max(1, cost - 2);
		}
		return cost;
	}

	function wxApplyStatusToTarget( _target, _effectID, _effectScript, _chanceFlag = null )
	{
		if (_target == null || !_target.isAlive() || _effectID == null || _effectScript == null)
			return;
		if ((_effectID == "effects.wx_status_acupoint" || _effectID == "effects.wx_status_poison_dart") && ::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_target))
			return;
		if (_effectID == "effects.wx_internal_injury" && ::Wuxia.CombatRules.isUndeadOrConstruct(_target))
			return;
		if (_chanceFlag != null)
		{
			local c = this.getContainer().getSkillByID("special.wx_martial_container");
			local chance = c == null || c.m.CachedAggFlags == null ? null : c.m.CachedAggFlags[_chanceFlag];
			if (chance != null && ::Math.rand(1, 100) > chance) return;
		}
		local sk = _target.getSkills();
		if (sk == null) return;
		if (_effectID == "effects.bleeding")
		{
			if (::Wuxia.CombatRules.isUndeadOrConstruct(_target)) return;
			local tProps = ::Wuxia.hasMember(_target, "getCurrentProperties") ? _target.getCurrentProperties() : null;
			if (tProps != null && ("IsImmuneToBleeding" in tProps) && tProps.IsImmuneToBleeding) return;
			local bleed = ::new(_effectScript);
			if (::Wuxia.hasMember(bleed, "setDamage")) bleed.setDamage(6);
			sk.add(bleed);
			return;
		}
		local eff = sk.getSkillByID(_effectID);
		if (eff == null)
		{
			eff = ::new(_effectScript);
			sk.add(eff);
		}
		else if ("resetDuration" in eff)
		{
			eff.resetDuration();
		}
	}

	function wxFormatWeaponList()
	{
		local joined = "";
		for (local i = 0; i < this.m.RequiredWeaponTypes.len(); i = ++i)
		{
			if (i > 0) joined += " / ";
			local wt = this.m.RequiredWeaponTypes[i];
			joined += (("WeaponTypeNames" in ::Wuxia.Text && wt in ::Wuxia.Text.WeaponTypeNames) ? ::Wuxia.Text.WeaponTypeNames[wt] : wt);
		}
		return joined;
	}

	function getTooltip()
	{
		local ret = (this.getContainer() != null && this.getContainer().getActor() != null)
			? this.getDefaultTooltip()
			: [
				{ id = 1, type = "title", text = this.getName() },
				{ id = 2, type = "description", text = this.getDescription() }
			];

		// 1. Live-compute skill-specific accuracy, damage, armor-damage, and armor-pen modifiers!
		try
		{
			local baseP = ::Const.CharacterProperties.getClone();
			local probe = ::Const.CharacterProperties.getClone();
			this.onAnySkillUsed(this, null, probe);

			local dMelee = probe.MeleeSkill - baseP.MeleeSkill;
			local dRanged = probe.RangedSkill - baseP.RangedSkill;
			local dTotalPct = ::Math.round((probe.DamageTotalMult - 1.0) * 100);
			local dArmorPct = ::Math.round((probe.DamageArmorMult - 1.0) * 100);
			local dDirectPct = ::Math.round((probe.DamageDirectAdd - baseP.DamageDirectAdd) * 100);
			local dHead = probe.HitChance[::Const.BodyPart.Head] - baseP.HitChance[::Const.BodyPart.Head];

			if (dMelee != 0)
			{
				local sign = dMelee > 0 ? "+" : "";
				local col = dMelee > 0 ? ::Const.UI.Color.PositiveValue : ::Const.UI.Color.NegativeValue;
				ret.push({ id = 11, type = "text", icon = "ui/icons/hitchance.png", text = "招式武艺补正：[color=" + col + "]" + sign + dMelee + "[/color] 命中" });
			}
			if (dRanged != 0)
			{
				local signR = dRanged > 0 ? "+" : "";
				local colR = dRanged > 0 ? ::Const.UI.Color.PositiveValue : ::Const.UI.Color.NegativeValue;
				ret.push({ id = 11, type = "text", icon = "ui/icons/hitchance.png", text = "招式射艺补正：[color=" + colR + "]" + signR + dRanged + "[/color] 命中" });
			}
			if (dTotalPct != 0)
			{
				local signT = dTotalPct > 0 ? "+" : "";
				local colT = dTotalPct > 0 ? ::Const.UI.Color.PositiveValue : ::Const.UI.Color.NegativeValue;
				ret.push({ id = 12, type = "text", icon = "ui/icons/regular_damage.png", text = "招式威力修正：[color=" + colT + "]" + signT + dTotalPct + "%[/color] 总伤害" });
			}
			if (dDirectPct > 0)
			{
				ret.push({ id = 13, type = "text", icon = "ui/icons/direct_damage.png", text = "透甲内劲加成：[color=" + ::Const.UI.Color.PositiveValue + "]+" + dDirectPct + "%[/color] 护甲穿透率" });
			}
			if (dArmorPct > 0)
			{
				ret.push({ id = 14, type = "text", icon = "ui/icons/armor_damage.png", text = "碎甲重劲加成：[color=" + ::Const.UI.Color.PositiveValue + "]+" + dArmorPct + "%[/color] 破甲伤害" });
			}
			if (dHead > 0)
			{
				ret.push({ id = 14, type = "text", icon = "ui/icons/chance_to_hit_head.png", text = "寻隙击头修正：[color=" + ::Const.UI.Color.PositiveValue + "]+" + dHead + "%[/color] 命中头部概率" });
			}
			if (!this.m.IsShieldRelevant)
			{
				ret.push({ id = 14, type = "text", icon = "ui/icons/melee_defense.png", text = "绕盾奇袭：[color=" + ::Const.UI.Color.PositiveValue + "]无视目标盾牌近防加值[/color]" });
			}
		}
		catch (_e) {}

		// 2. Show Qi discount if martial passives reduce cost
		local rawFat = this.m.FatigueCost;
		local curFat = this.getFatigueCost();
		if (rawFat > 0 && curFat < rawFat)
		{
			ret.push({
				id = 15,
				type = "text",
				icon = "ui/icons/fatigue.png",
				text = "功法行气减耗：内息消耗已由 " + rawFat + " 降至 [color=" + ::Const.UI.Color.PositiveValue + "]" + curFat + "[/color]"
			});
		}

		// 3. Cooldown indicator if present
		if ((::Wuxia.hasMember(this.m, "Cooldown")) && this.m.Cooldown > 0)
		{
			ret.push({
				id = 16,
				type = "text",
				icon = "ui/icons/warning.png",
				text = "[color=" + ::Const.UI.Color.NegativeValue + "]招式调息中：尚需 " + this.m.Cooldown + " 回合方可再施展[/color]"
			});
		}

		// 4. Weapon Requirement + Live Equipped Check
		if (this.m.RequiredWeaponTypes.len() > 0)
		{
			local wOk = this.wxHasRequiredWeapon();
			local wCol = wOk ? ::Const.UI.Color.PositiveValue : ::Const.UI.Color.NegativeValue;
			ret.push({
				id = 17,
				type = "text",
				icon = "ui/icons/melee_skill.png",
				text = "适配兵刃：[color=" + wCol + "]" + this.wxFormatWeaponList() + (wOk ? "（已装备）" : "（未持对应兵刃）") + "[/color]"
			});
		}

		// 5. Distinctive Martial Mechanic Badge (`招式奇效`)
		local mechTxt = this.wxGetMechanicTooltipText();
		if (mechTxt != "")
		{
			ret.push({
				id = 18,
				type = "text",
				icon = "ui/icons/special.png",
				text = "[color=#0b4a1e]" + mechTxt + "[/color]"
			});
		}

		// 6. Unique Martial Choreography Signature
		local choreoLbl = ("VFX" in ::Wuxia && "getSkillChoreoLabel" in ::Wuxia.VFX) ? ::Wuxia.VFX.getSkillChoreoLabel(this) : "";
		if (choreoLbl != "")
		{
			ret.push({
				id = 19,
				type = "text",
				icon = "ui/icons/special.png",
				text = "演武意境：[color=#5e2c00]" + choreoLbl + "[/color]"
			});
		}

		return ret;
	}
});
