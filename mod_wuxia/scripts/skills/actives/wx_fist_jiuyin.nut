// Active Move: 九阴摧心爪
this.wx_fist_jiuyin <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_jiuyin";
		this.m.Name = "九阴摧心爪";
		this.m.Description = "阴狠诡奇五指利爪：消耗 4 AP 与 20 内息，五指如钩直扣天灵与心口（击头率 +20%，伤血致深创流血）。";
		this.m.Icon = "skills/wx_fist_jiuyin.png";
		this.m.IconDisabled = "skills/wx_fist_jiuyin_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_jiuyin";
		this.m.WX_VfxBrush <- "wx_vfx_13";
		this.m.WX_AnimID <- "wx_anim_08";
		this.m.WX_AnimMode <- "ghost_claw";
		this.m.WX_ChoreoID <- "wx_fist_jiuyin";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.40;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8; _properties.HitChance[::Const.BodyPart.Head] += 20; _properties.DamageTotalMult *= 1.12;
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
