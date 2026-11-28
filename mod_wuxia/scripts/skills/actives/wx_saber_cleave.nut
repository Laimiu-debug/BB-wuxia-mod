// Active Move: 劈空重斩 (Saber/Cleaver, 5 AP, 18 Qi, +25% armor dmg + bleeding)

this.wx_saber_cleave <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_cleave";
		this.m.WX_VfxBrush <- "wx_vfx_02";
		this.m.WX_AnimID <- "wx_anim_43";
		this.m.WX_AnimMode <- "crescent";
		this.m.WX_ChoreoID <- "wx_saber_cleave";
		this.m.Name = "劈空重斩";
		this.m.Description = "黑风刀法狠辣重劈：破甲伤害 +25%，击穿气血时令对手严重流血。";
		this.m.Icon = "skills/wx_saber_cleave.png";
		this.m.IconDisabled = "skills/wx_saber_cleave_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_cleave";
		this.m.SoundOnUse = [
			"sounds/combat/cleave_01.wav",
			"sounds/combat/cleave_02.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/cleave_hit_hitpoints_01.wav"
		];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 18;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Saber"];
		this.m.DirectDamageMult = 0.25;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.DamageArmorMult *= 1.25;
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		local hpBefore = (target != null) ? target.getHitpoints() : 0;
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive() && (hpBefore - target.getHitpoints()) >= 6
			&& !::Wuxia.CombatRules.isImmuneToBleeding(target))
		{
			local bleed = ::new("scripts/skills/effects/bleeding_effect");
			bleed.setDamage(8);
			target.getSkills().add(bleed);
		}
		return hit;
	}
});
