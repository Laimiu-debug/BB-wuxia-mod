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
		WX_ChoreoID         = null
	},

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
		this.m.IsDoingForwardMove = true;
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

	function isHidden()
	{
		return this.skill.isHidden() || !this.wxHasRequiredWeapon();
	}

	function isUsable()
	{
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
					local rg = ::new("scripts/skills/actives/reload_handgonne");
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

	function getFatigueCost()
	{
		local cost = this.skill.getFatigueCost();
		local container = this.getContainer();
		local actor = container == null ? null : container.getActor();
		local c = actor == null ? null : ::Wuxia.Slots.getContainer(actor);
		if (c != null && c.m.CachedAggFlags != null && c.m.CachedAggFlags.WeaponQiDiscount > 0.0)
		{
			cost = ::Math.max(1, ::Math.floor(cost * (1.0 - c.m.CachedAggFlags.WeaponQiDiscount)));
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

		// 5. Unique 72-Skill Martial Choreography Signature
		local choreoLbl = ("VFX" in ::Wuxia && "getSkillChoreoLabel" in ::Wuxia.VFX) ? ::Wuxia.VFX.getSkillChoreoLabel(this) : "";
		if (choreoLbl != "")
		{
			ret.push({
				id = 18,
				type = "text",
				icon = "ui/icons/special.png",
				text = "演武意境：[color=#5e2c00]" + choreoLbl + "[/color]"
			});
		}

		return ret;
	}
});
