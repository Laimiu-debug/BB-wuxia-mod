// Active Move: 北岳擂鼓震
this.wx_hammer_polu <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_hammer_polu";
		this.m.Name = "北岳擂鼓震";
		this.m.Description = "边军双锤对擂音爆：消耗 5 AP 与 22 内息，双锤轰鸣震溃敌胆（破甲 +32%，附加散劲虚弱并触发定力动摇检定）。";
		this.m.Icon = "skills/wx_hammer_polu.png";
		this.m.IconDisabled = "skills/wx_hammer_polu_sw.png";
		this.m.Overlay = "wx_ov_wx_hammer_polu";
		this.m.WX_VfxBrush <- "wx_vfx_23";
		this.m.WX_AnimID <- "wx_anim_125";
		this.m.WX_AnimMode <- "aoe_polu";
		this.m.WX_ChoreoID <- "wx_hammer_polu";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 22;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Hammer"];
		this.m.DirectDamageMult = 0.38;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 6; _properties.DamageArmorMult *= 1.32;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness"); if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) target.checkMorale(-1, -12);
		}
		return hit;
	}
});
