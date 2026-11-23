// Active Move: 鱼肠弑王刺
this.wx_dagger_zhuanzhu <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_dagger_zhuanzhu";
		this.m.Name = "鱼肠弑王刺";
		this.m.Description = "吴越勇绝破甲短剑术：消耗 4 AP 与 19 内息，无视重铠缝隙直透胸腹（穿甲 +22%，命中 +10，附加内伤）。";
		this.m.Icon = "skills/wx_dagger_zhuanzhu.png";
		this.m.IconDisabled = "skills/wx_dagger_zhuanzhu_sw.png";
		this.m.Overlay = "wx_ov_wx_dagger_zhuanzhu";
		this.m.WX_VfxBrush <- "wx_vfx_03";
		this.m.WX_AnimID <- "wx_anim_131";
		this.m.WX_AnimMode <- "pierce_zhuanzhu";
		this.m.WX_ChoreoID <- "wx_dagger_zhuanzhu";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 19;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Dagger"];
		this.m.DirectDamageMult = 0.42;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 10; _properties.DamageDirectAdd += 0.22;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_internal_injury", "scripts/skills/effects/wx_internal_injury");
		}
		return hit;
	}
});
