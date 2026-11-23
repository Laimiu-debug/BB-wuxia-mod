// Active Move: 瀚海弯月斩
this.wx_saber_xinyue <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_xinyue";
		this.m.Name = "瀚海弯月斩";
		this.m.Description = "大漠弯刀诡弧快斩：消耗 4 AP 与 16 内息，新月弧光斜掠颈动脉（命中 +9，伤血必致流血）。";
		this.m.Icon = "skills/wx_saber_xinyue.png";
		this.m.IconDisabled = "skills/wx_saber_xinyue_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_xinyue";
		this.m.WX_VfxBrush <- "wx_vfx_02";
		this.m.WX_AnimID <- "wx_anim_89";
		this.m.WX_AnimMode <- "flurry_xinyue";
		this.m.WX_ChoreoID <- "wx_saber_xinyue";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Saber", "Sword"];
		this.m.DirectDamageMult = 0.28;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 9; _properties.HitChance[::Const.BodyPart.Head] += 10;
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
