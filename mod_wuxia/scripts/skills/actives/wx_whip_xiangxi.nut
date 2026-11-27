// Active Move: 辰州摄魂鞭
this.wx_whip_xiangxi <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_whip_xiangxi";
		this.m.Name = "辰州摄魂鞭";
		this.m.Description = "湘西赶尸门阴森铜铃鞭：消耗 4 AP 与 18 内息，两格软鞭摇铃抽魂（绕盾命中 +8，震慑活人军心并对尸傀目标总伤 +25%）。";
		this.m.Icon = "skills/wx_whip_xiangxi.png";
		this.m.IconDisabled = "skills/wx_whip_xiangxi_sw.png";
		this.m.Overlay = "wx_ov_wx_whip_xiangxi";
		this.m.WX_VfxBrush <- "wx_vfx_30";
		this.m.WX_AnimID <- "wx_anim_171";
		this.m.WX_AnimMode <- "whip_xiangxi";
		this.m.WX_ChoreoID <- "wx_whip_xiangxi";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav", "sounds/combat/slash_hit_02.wav"];
		this.m.IsShieldRelevant = false;
		this.m.IsIgnoredAsAOO = true;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.MaxLevelDifference = 2;
		this.m.RequiredWeaponTypes = ["Flail"];
		this.m.DirectDamageMult = 0.30;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8;
			if (_targetEntity != null && ::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
				_properties.DamageTotalMult *= 1.25;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) target.checkMorale(-1, -14); this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness");
		}
		return hit;
	}
});
