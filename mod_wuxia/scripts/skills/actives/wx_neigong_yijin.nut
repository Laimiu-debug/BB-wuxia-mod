// Active Skill: 易筋洗髓功
this.wx_neigong_yijin <- this.inherit("scripts/skills/skill", {
	m = { ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_22", WX_AnimID = "wx_anim_144", WX_AnimMode = "stance_yijin" },
	function create()
	{
		this.m.ID = "actives.wx_neigong_yijin";
		this.m.Name = "易筋洗髓功";
		this.m.Description = "禅宗至高护脉神功：消耗 4 AP 与 10 内息，真气流转涤荡内腑，立即清除流血/奇毒/内伤/散劲并恢复 16 点气血与 12 点内息（冷却 3 回合）。";
		this.m.Icon = "skills/wx_neigong_yijin.png";
		this.m.IconDisabled = "skills/wx_neigong_yijin_sw.png";
		this.m.Overlay = "wx_ov_wx_neigong_yijin";
		this.m.WX_AnimID <- "wx_anim_144";
		this.m.WX_AnimMode <- "stance_yijin";
		this.m.WX_ChoreoID <- "wx_neigong_yijin";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 10;
	}
	function getTooltip() { return this.getDefaultUtilityTooltip(); }
	function isUsable()
	{
		if (this.m.Cooldown > 0 || this.m.ActiveBuff || !this.skill.isUsable()) return false;
		return true;
	}
	function onUpdate( _properties )
	{
		if (this.m.ActiveBuff)
		{
			_properties.Bravery += 15; _properties.DamageReceivedRegularMult = ::Math.maxf(0.40, _properties.DamageReceivedRegularMult * 0.80);
		}
	}
	function onTurnStart() { this.m.ActiveBuff = false; if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.ActiveBuff = false; this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.ActiveBuff = false; this.m.Cooldown = 0; }
	function onUse( _user, _targetTile )
	{
		this.m.ActiveBuff = true;
		this.m.Cooldown = 3;
		::Wuxia.VFX.playSkillVfx(this, _user, _user.getTile(), this.m.WX_VfxBrush);
		local sk = _user.getSkills();
		sk.removeByID("effects.bleeding");
		sk.removeByID("effects.wx_status_poison_dart");
		sk.removeByID("effects.wx_scatter_weakness");
		local injury = sk.getSkillByID("effects.wx_internal_injury");
		if (injury != null) injury.cureTemporary();
		_user.setHitpoints(::Math.min(_user.getHitpointsMax(), _user.getHitpoints() + 16));
		_user.setFatigue(::Math.max(0, _user.getFatigue() - 12));
		this.getContainer().update();
		return true;
	}
});
