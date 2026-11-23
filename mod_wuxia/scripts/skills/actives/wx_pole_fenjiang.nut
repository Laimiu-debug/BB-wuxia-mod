// Active Move: 分江夜叉刺
this.wx_pole_fenjiang <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_pole_fenjiang";
		this.m.Name = "分江夜叉刺";
		this.m.Description = "洞庭水战倒刺钢叉绝技：消耗 5 AP 与 19 内息，三股钢叉贯刺两格之敌并放血（命中 +8，致敌流血与失衡）。";
		this.m.Icon = "skills/wx_pole_fenjiang.png";
		this.m.IconDisabled = "skills/wx_pole_fenjiang_sw.png";
		this.m.Overlay = "wx_ov_wx_pole_fenjiang";
		this.m.WX_VfxBrush <- "wx_vfx_21";
		this.m.WX_AnimID <- "wx_anim_116";
		this.m.WX_AnimMode <- "pierce_fenjiang";
		this.m.WX_ChoreoID <- "wx_pole_fenjiang";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 19;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Polearm", "Spear"];
		this.m.DirectDamageMult = 0.30;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8; _properties.DamageTotalMult *= 1.12;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) this.wxApplyStatusToTarget(target, "effects.bleeding", "scripts/skills/effects/bleeding_effect"); this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		return hit;
	}
});
