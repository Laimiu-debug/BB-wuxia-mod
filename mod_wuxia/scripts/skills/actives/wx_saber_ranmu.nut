// Active Move: 燃木烈阳劈
this.wx_saber_ranmu <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_ranmu";
		this.m.Name = "燃木烈阳劈";
		this.m.Description = "禅门至阳刚猛刀罡：消耗 6 AP 与 26 内息，刀风炽烈如火焚木（破甲 +35%，命中震慑目标军心检定）。";
		this.m.Icon = "skills/wx_saber_ranmu.png";
		this.m.IconDisabled = "skills/wx_saber_ranmu_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_ranmu";
		this.m.WX_VfxBrush <- "wx_vfx_02";
		this.m.WX_AnimID <- "wx_anim_03";
		this.m.WX_AnimMode <- "fire_pillar";
		this.m.WX_ChoreoID <- "wx_saber_ranmu";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 26;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Sword"];
		this.m.DirectDamageMult = 0.28;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.DamageArmorMult *= 1.35; _properties.DamageTotalMult *= 1.15;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) target.checkMorale(-1, -10);
		}
		return hit;
	}
});
