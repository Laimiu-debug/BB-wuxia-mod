// Secret Axe Move: 旋风断魂斧 (6 AP, 24 Qi: sweeps up to 3 adjacent front-arc enemies, +15% armor dmg + bleed)

this.wx_axe_whirl <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_axe_whirl";
		this.m.WX_VfxBrush <- "wx_vfx_06";
		this.m.WX_AnimID <- "wx_anim_59";
		this.m.WX_AnimMode <- "berserk_spin";
		this.m.WX_ChoreoID <- "wx_axe_whirl";
		this.m.Name = "旋风断魂斧";
		this.m.Description = "借腰马合一之劲抡斧狂旋横扫身前扇面最多 3 名敌军：破甲伤害 +15%，见血附加撕裂流血。";
		this.m.KilledString = "巨斧旋斩成两截";
		this.m.Icon = "skills/wx_axe_whirl.png";
		this.m.IconDisabled = "skills/wx_axe_whirl_sw.png";
		this.m.Overlay = "wx_ov_wx_axe_whirl";
		this.m.SoundOnUse = [
			"sounds/combat/round_swing_01.wav",
			"sounds/combat/round_swing_02.wav",
			"sounds/combat/round_swing_03.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/round_swing_hit_01.wav",
			"sounds/combat/round_swing_hit_02.wav",
			"sounds/combat/round_swing_hit_03.wav"
		];
		this.m.IsAOE = true;
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 24;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Axe"];
		this.m.DirectDamageMult = 0.30;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.DamageArmorMult *= 1.15;
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local targets = [];
		local mainTarget = _targetTile.getEntity();
		if (mainTarget != null) targets.push(mainTarget);

		local myTile = _user.getTile();
		for (local d = 0; d < this.Const.Direction.COUNT; ++d)
		{
			if (!_targetTile.hasNextTile(d)) continue;
			local adj = _targetTile.getNextTile(d);
			if (adj.getDistanceTo(myTile) != 1 || !adj.IsOccupiedByActor) continue;
			local ent = adj.getEntity();
			if (ent != null && ent.isAlive() && !_user.isAlliedWith(ent))
			{
				targets.push(ent);
				if (targets.len() >= 3) break;
			}
		};
			local anyHit = false;
		foreach (t in targets)
		{
			if (!t.isAlive()) continue;
			if (mainTarget == null || t.getID() != mainTarget.getID())
				::Wuxia.VFX.playAoESecondaryVfx(this, _user, t.getTile(), 55);
			local hpBefore = t.getHitpoints();
			local hit = this.attackEntity(_user, t);
			if (hit)
			{
				anyHit = true;
				if (t.isAlive() && (hpBefore - t.getHitpoints()) >= 6 && !::Wuxia.CombatRules.isImmuneToBleeding(t))
				{
					local bleed = ::new("scripts/skills/effects/bleeding_effect");
					bleed.setDamage(5);
					t.getSkills().add(bleed);
				}
			}
		}
		return anyHit;
	}
});
