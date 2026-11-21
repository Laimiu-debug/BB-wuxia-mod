// Active Move: 灵蛇锁喉鞭
this.wx_whip_suohou <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_whip_suohou";
		this.m.Name = "灵蛇锁喉鞭";
		this.m.Description = "三格软鞭绕盾奇袭：消耗 5 AP 与 20 内息，鞭梢如毒蛇吐信绕过盾牌抽击咽喉（三格射程，击头率 +15%，附流血）。";
		this.m.Icon = "skills/wx_whip_suohou.png";
		this.m.IconDisabled = "skills/wx_whip_suohou_sw.png";
		this.m.Overlay = "wx_ov_wx_whip_suohou";
		this.m.WX_VfxBrush <- "wx_vfx_32";
		this.m.WX_AnimID <- "wx_anim_32";
		this.m.WX_AnimMode <- "viper_whip";
		this.m.WX_ChoreoID <- "wx_whip_suohou";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 3;
		this.m.RequiredWeaponTypes = ["Flail", "Cleaver"];
		this.m.DirectDamageMult = 0.30;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8; _properties.HitChance[::Const.BodyPart.Head] += 15;
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
