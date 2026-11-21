// Active Move: 狂风快刀斩
this.wx_saber_kuangfeng <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_kuangfeng";
		this.m.Name = "狂风快刀斩";
		this.m.Description = "大漠狂风骤雨刀路：消耗 4 AP 与 16 内息，顺风疾劈（命中 +6，伤血必令非尸傀目标割裂流血）。";
		this.m.Icon = "skills/wx_saber_kuangfeng.png";
		this.m.IconDisabled = "skills/wx_saber_kuangfeng_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_kuangfeng";
		this.m.WX_VfxBrush <- "wx_vfx_26";
		this.m.WX_AnimID <- "wx_anim_46";
		this.m.WX_AnimMode <- "omnislash6";
		this.m.WX_ChoreoID <- "wx_saber_kuangfeng";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Sword"];
		this.m.DirectDamageMult = 0.25;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 6;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) this.wxApplyStatusToTarget(target, "effects.bleeding", "scripts/skills/effects/bleeding_effect");
		}
		return hit;
	}
});
