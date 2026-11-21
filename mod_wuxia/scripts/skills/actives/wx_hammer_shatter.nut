// Sect Hammer Move: 震岳碎甲击 (5 AP, 20 Qi, 1.35x armor dmg, guaranteed >=10 blunt shock HP damage + off-balance)

this.wx_hammer_shatter <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_hammer_shatter";
		this.m.WX_VfxBrush <- "wx_vfx_14";
		this.m.WX_AnimID <- "wx_anim_57";
		this.m.WX_AnimMode <- "armor_break";
		this.m.WX_ChoreoID <- "wx_hammer_shatter";
		this.m.Name = "震岳碎甲击";
		this.m.Description = "抡动重锤挟千钧之势砸落：破甲伤害额外提升 35%，隔甲震腑保底造成 10 点气血实伤并令目标陷入「失衡」。";
		this.m.KilledString = "一锤震碎胸甲";
		this.m.Icon = "skills/wx_hammer_shatter.png";
		this.m.IconDisabled = "skills/wx_hammer_shatter_sw.png";
		this.m.Overlay = "wx_ov_wx_hammer_shatter";
		this.m.SoundOnUse = [
			"sounds/combat/crush_armor_01.wav",
			"sounds/combat/crush_armor_02.wav",
			"sounds/combat/crush_armor_03.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/crush_armor_hit_01.wav",
			"sounds/combat/crush_armor_hit_02.wav",
			"sounds/combat/crush_armor_hit_03.wav"
		];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.InjuriesOnBody = this.Const.Injury.BluntBody;
		this.m.InjuriesOnHead = this.Const.Injury.BluntHead;
		this.m.RequiredWeaponTypes = ["Hammer"];
		this.m.DirectDamageMult = 0.50;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.DamageArmorMult *= 1.35;
			_properties.DamageMinimum += 10;
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		return hit;
	}
});
