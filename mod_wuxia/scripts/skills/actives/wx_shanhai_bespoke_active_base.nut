// Base Class for Bespoke《山海经》Boss Geometric Active Skills (Zero Generic `wx_boss_cataclysm`!)
// Supports 14 distinct hex-grid geometries, multi-part severing lockouts (`ShanHaiMultiBody.isSkillLocked`),
// dynamic `TileField` terrain alchemy, poison-bait stomach backlash (`毒饵反噬`), and totem ray convergence!

this.wx_shanhai_bespoke_active_base <- this.inherit("scripts/skills/skill", {
	m = {
		BossKey       = "",
		MoveKey       = "",
		GeoKind       = "single",
		FieldKind     = "",
		FieldTurns    = 3,
		HitBonus      = 8,
		DmgMult       = 1.10,
		ArmorMult     = 1.15,
		PenAdd        = 0.05,
		ArmorBurn     = 0,
		DrainQi       = 0,
		DrainHP       = 0,
		InflictStatus = "",
		Cooldown      = 0,
		MaxCooldown   = 2,
		WX_VfxBrush   = "wx_vfx_30",
		WX_AnimID     = "wx_anim_71",
		WX_AnimMode   = "shanhai_omen",
		WX_ChoreoID   = ""
	},

	function initBespokeBossMove( _bossKey, _moveKey )
	{
		this.m.BossKey = _bossKey;
		this.m.MoveKey = _moveKey;
		this.m.ID = "actives." + _moveKey;
		this.m.WX_ChoreoID = _moveKey;
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.OffensiveTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsStacking = false;
		this.m.IsWeaponSkill = false;
		this.m.IsIgnoredAsAOO = true;
		this.m.IsDoingForwardMove = false;
		this.m.DirectDamageMult = 0.30;
		this.m.SoundOnUse = ["sounds/wx_combat/wx_thunder_quake_01.wav"];
		this.m.SoundOnHit = ["sounds/wx_combat/wx_palm_inch_01.wav"];

		local mSpec = ("ShanHaiBossMoves" in ::Wuxia && (_moveKey in ::Wuxia.ShanHaiBossMoves))
			? ::Wuxia.ShanHaiBossMoves[_moveKey]
			: null;
		if (mSpec != null)
		{
			this.m.Name          = mSpec.Name;
			this.m.Description   = mSpec.Desc;
			this.m.Icon          = ("Icon" in mSpec) ? mSpec.Icon : "skills/wx_boss_cataclysm.png";
			this.m.IconDisabled  = this.m.Icon.slice(0, this.m.Icon.len() - 4) + "_sw.png";
			this.m.Overlay       = "wx_ov_wx_boss_cataclysm";
			this.m.GeoKind       = mSpec.Geo;
			this.m.ActionPointCost = mSpec.AP;
			this.m.FatigueCost   = mSpec.Qi;
			this.m.MaxCooldown   = ("CD" in mSpec) ? mSpec.CD : 2;
			this.m.FieldKind     = ("Field" in mSpec) ? mSpec.Field : "";
			this.m.HitBonus      = ("Hit" in mSpec) ? mSpec.Hit : 8;
			this.m.DmgMult       = ("Dmg" in mSpec) ? mSpec.Dmg : 1.10;
			this.m.ArmorMult     = ("Arm" in mSpec) ? mSpec.Arm : 1.15;
			this.m.PenAdd        = ("Pen" in mSpec) ? mSpec.Pen : 0.05;
			this.m.ArmorBurn     = ("BurnArm" in mSpec) ? mSpec.BurnArm : 0;
			this.m.DrainQi       = ("DrainQi" in mSpec) ? mSpec.DrainQi : 0;
			this.m.DrainHP       = ("DrainHP" in mSpec) ? mSpec.DrainHP : 0;
			this.m.InflictStatus = ("Status" in mSpec) ? mSpec.Status : "";
			if ("Vfx" in mSpec) this.m.WX_VfxBrush = mSpec.Vfx;

			local g = this.m.GeoKind;
			if (g == "ring_quake_6" || g == "field_detonate" || g == "totem_swap" || g == "telegraph_omen" || g == "sonic_roar")
			{
				this.m.IsTargeted = false;
				this.m.IsAttack = (g == "ring_quake_6" || g == "field_detonate");
				this.m.IsAOE = true;
				this.m.MinRange = 0;
				this.m.MaxRange = 0;
				this.m.Order = this.Const.SkillOrder.NonTargeted;
			}
			else if (g == "ranged_barrage" || g == "totem_ray" || g == "hex_curse")
			{
				this.m.IsTargeted = true;
				this.m.IsRanged = true;
				this.m.IsAttack = true;
				this.m.IsAOE = (g == "totem_ray");
				this.m.MinRange = 1;
				this.m.MaxRange = ("Range" in mSpec) ? mSpec.Range : 4;
				this.m.MaxLevelDifference = 4;
			}
			else if (g == "leap_slam_3" || g == "pull_devour" || g == "line_charge_3" || g == "line_pierce_3")
			{
				this.m.IsTargeted = true;
				this.m.IsRanged = false;
				this.m.IsAttack = true;
				this.m.IsAOE = (g == "line_pierce_3" || g == "line_charge_3");
				this.m.MinRange = 1;
				this.m.MaxRange = ("Range" in mSpec) ? mSpec.Range : (g == "line_pierce_3" ? 2 : 3);
				this.m.MaxLevelDifference = 3;
			}
			else
			{
				this.m.IsTargeted = true;
				this.m.IsRanged = false;
				this.m.IsAttack = true;
				this.m.IsAOE = (g == "cone_3" || g == "tail_sweep_arc");
				this.m.MinRange = 1;
				this.m.MaxRange = ("Range" in mSpec) ? mSpec.Range : 1;
				this.m.MaxLevelDifference = 2;
			}
		}
	}

	function onCombatStarted() { this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.Cooldown = 0; }
	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }

	function isUsable()
	{
		if (this.m.Cooldown > 0 || !this.skill.isUsable()) return false;
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		if (actor != null && ("ShanHaiMultiBody" in ::Wuxia) && ::Wuxia.ShanHaiMultiBody.isSkillLocked(actor, this.m.ID))
			return false;
		return true;
	}

	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!this.m.IsTargeted) return true;
		if (_originTile == null || _targetTile == null) return false;
		local d = _originTile.getDistanceTo(_targetTile);
		if (d < this.m.MinRange || d > this.m.MaxRange) return false;
		if (!::Wuxia.isTileOccupiedByActor(_targetTile)) return false;
		local ent = _targetTile.getEntity();
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (ent == null || !ent.isAlive()) return false;
		if (actor != null && actor.isAlliedWith(ent)) return false;
		return true;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill != this) return;
		if (this.m.IsRanged) _properties.RangedSkill += this.m.HitBonus;
		else _properties.MeleeSkill += this.m.HitBonus;
		_properties.DamageTotalMult *= this.m.DmgMult;
		_properties.DamageArmorMult *= this.m.ArmorMult;
		local room = ::Math.maxf(0.0, 0.25 - _properties.DamageDirectAdd);
		if (this.m.PenAdd > 0.0)
			_properties.DamageDirectAdd += ::Math.minf(room, this.m.PenAdd);

		// Ensure monster/unarmed Boss entities always have a solid mythic base damage floor
		if (_properties.DamageRegularMax < 55)
		{
			_properties.DamageRegularMin = ::Math.max(_properties.DamageRegularMin, 42);
			_properties.DamageRegularMax = ::Math.max(_properties.DamageRegularMax, 68);
		}
	}

	function wxInflictPostEffects( _user, _target, _tile )
	{
		if (_tile != null && this.m.FieldKind != "" && ("TileField" in ::Wuxia))
			::Wuxia.TileField.setField(_tile, this.m.FieldKind, this.m.FieldTurns, _user);
		if (_target == null || !_target.isAlive()) return;

		if (this.m.ArmorBurn > 0 && ::Wuxia.hasMember(_target, "getItems") && _target.getItems() != null)
		{
			local bArm = _target.getItems().getItemAtSlot(::Const.ItemSlot.Body);
			if (bArm != null && bArm.getArmor() > 0)
				bArm.setArmor(::Math.max(0, bArm.getArmor() - this.m.ArmorBurn));
		}
		if (this.m.DrainQi > 0 && !::Wuxia.CombatRules.isUndeadOrConstruct(_target) && ::Wuxia.hasMember(_target, "getFatigue"))
			_target.setFatigue(::Math.min(_target.getFatigueMax(), _target.getFatigue() + this.m.DrainQi));

		if (this.m.DrainHP > 0 && _user != null && _user.isAlive())
		{
			local tsk0 = ::Wuxia.hasMember(_target, "getSkills") ? _target.getSkills() : null;
			// Poison-bait counterplay (`毒饵反噬` for Taotie / Bashe / Yayu / Jiufeng): devouring a poisoned target ruptures Boss!
			if (tsk0 != null && (tsk0.hasSkill("effects.wx_status_poison_dart") || tsk0.hasSkill("effects.spider_poison")))
			{
				if (_user.getHitpoints() > 36) _user.setHitpoints(_user.getHitpoints() - 35);
				local usk = _user.getSkills();
				if (usk != null && !usk.hasSkill("effects.wx_internal_injury"))
					usk.add(::new("scripts/skills/effects/wx_internal_injury"));
			}
			else if ( _user.getSkills() == null || !_user.getSkills().hasSkill("effects.wx_status_regen_seal") )
			{
				_user.setHitpoints(::Math.min(_user.getHitpointsMax(), _user.getHitpoints() + this.m.DrainHP));
			}
		}

		local st = this.m.InflictStatus;
		local tsk = ::Wuxia.hasMember(_target, "getSkills") ? _target.getSkills() : null;
		if (st == "" || tsk == null) return;
		if (st == "opening" && !tsk.hasSkill("effects.wx_status_opening"))
			tsk.add(::new("scripts/skills/effects/wx_status_opening"));
		else if (st == "offbalance" && !tsk.hasSkill("effects.wx_status_offbalance"))
			tsk.add(::new("scripts/skills/effects/wx_status_offbalance"));
		else if (st == "acupoint" && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_target) && !tsk.hasSkill("effects.wx_status_acupoint"))
			tsk.add(::new("scripts/skills/effects/wx_status_acupoint"));
		else if (st == "poison" && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_target) && !tsk.hasSkill("effects.wx_status_poison_dart"))
			tsk.add(::new("scripts/skills/effects/wx_status_poison_dart"));
		else if (st == "injury" && !::Wuxia.CombatRules.isUndeadOrConstruct(_target) && !tsk.hasSkill("effects.wx_internal_injury"))
			tsk.add(::new("scripts/skills/effects/wx_internal_injury"));
		else if (st == "scatter" && !::Wuxia.CombatRules.isUndeadOrConstruct(_target) && !tsk.hasSkill("effects.wx_scatter_weakness"))
			tsk.add(::new("scripts/skills/effects/wx_scatter_weakness"));
		else if (st == "bleed" && !::Wuxia.CombatRules.isImmuneToBleeding(_target))
		{
			local bl = ::new("scripts/skills/effects/bleeding_effect");
			bl.setDamage(10);
			tsk.add(bl);
		}
		else if (st == "shaken" && !::Wuxia.CombatRules.isUndeadOrConstruct(_target) && ::Wuxia.hasMember(_target, "checkMorale"))
			_target.checkMorale(-1, -15);
	}

	function onUse( _user, _targetTile )
	{
		if (_user == null || !_user.isAlive()) return false;
		this.m.Cooldown = this.m.MaxCooldown;
		local uTile = ::Wuxia.hasMember(_user, "getTile") ? _user.getTile() : null;
		local vfxTile = _targetTile != null ? _targetTile : uTile;
		if ("VFX" in ::Wuxia && vfxTile != null)
			::Wuxia.VFX.playSkillVfx(this, _user, vfxTile, this.m.WX_VfxBrush);

		if ("ShanHaiBossLaws" in ::Wuxia && "executeBossMove" in ::Wuxia.ShanHaiBossLaws)
			return ::Wuxia.ShanHaiBossLaws.executeBossMove(this, _user, uTile, _targetTile);
		return false;
	}

	function getTooltip()
	{
		return [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description", text = this.getDescription() }
		];
	}
});
