// Active Skill: 沧海潮生诀
this.wx_neigong_chaoxi <- this.inherit("scripts/skills/skill", {
	m = { ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_21", WX_AnimID = "wx_anim_150", WX_AnimMode = "stance_chaoxi" },
	function create()
	{
		this.m.ID = "actives.wx_neigong_chaoxi";
		this.m.Name = "沧海潮生诀";
		this.m.Description = "江海派叠浪生息内功：消耗 3 AP 与 0 内息，呼吸如海潮涨落，回复 18 点内息并使本回合身法提升 +18（冷却 2 回合）。";
		this.m.Icon = "skills/wx_neigong_chaoxi.png";
		this.m.IconDisabled = "skills/wx_neigong_chaoxi_sw.png";
		this.m.Overlay = "wx_ov_wx_neigong_chaoxi";
		this.m.WX_AnimID <- "wx_anim_150";
		this.m.WX_AnimMode <- "stance_chaoxi";
		this.m.WX_ChoreoID <- "wx_neigong_chaoxi";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 3;
		this.m.FatigueCost = 0;
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
			_properties.Initiative += 18; _properties.RangedDefense += 8;
		}
	}
	function onTurnStart() { this.m.ActiveBuff = false; if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.ActiveBuff = false; this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.ActiveBuff = false; this.m.Cooldown = 0; }
	function onUse( _user, _targetTile )
	{
		this.m.ActiveBuff = true;
		this.m.Cooldown = 2;
		::Wuxia.VFX.playSkillVfx(this, _user, _user.getTile(), this.m.WX_VfxBrush);
		_user.setFatigue(::Math.max(0, _user.getFatigue() - 18));
		this.getContainer().update();
		return true;
	}
});
