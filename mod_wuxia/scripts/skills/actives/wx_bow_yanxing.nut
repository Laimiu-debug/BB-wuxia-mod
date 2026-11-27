// Active Move: 苍狼追魂箭
this.wx_bow_yanxing <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_bow_yanxing";
		this.m.Name = "苍狼追魂箭";
		this.m.Description = "塞外游骑追风冷箭：消耗 4 AP 与 16 内息，顺风疾射压制敌阵（射程 2~7 格，射艺 +10，致敌流血或失衡）。";
		this.m.Icon = "skills/wx_bow_yanxing.png";
		this.m.IconDisabled = "skills/wx_bow_yanxing_sw.png";
		this.m.Overlay = "wx_ov_wx_bow_yanxing";
		this.m.WX_VfxBrush <- "wx_vfx_26";
		this.m.WX_AnimID <- "wx_anim_139";
		this.m.WX_AnimMode <- "pierce_yanxing";
		this.m.WX_ChoreoID <- "wx_bow_yanxing";
		this.m.IsRanged = true;
		this.m.IsIgnoredAsAOO = true;
		this.m.IsShowingProjectile = true;
		this.m.ProjectileType = ::Const.ProjectileType.WX_Diaolingjian;
		this.m.IsProjectileRotated = true;
		this.m.ProjectileTimeScale = 1.25;
		this.m.SoundOnUse = ["sounds/combat/quick_shot_01.wav", "sounds/combat/quick_shot_02.wav", "sounds/combat/quick_shot_03.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 2;
		this.m.MaxRange = 7;
		this.m.MaxLevelDifference = 4;
		this.m.RequiredWeaponTypes = ["Bow", "Crossbow"];
		this.m.DirectDamageMult = 0.36;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.RangedSkill += 10;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.wxShootBowAt(_user, target);
		if (hit && target != null && target.isAlive())
		{
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) this.wxApplyStatusToTarget(target, "effects.bleeding", "scripts/skills/effects/bleeding_effect"); this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		return hit;
	}
});
