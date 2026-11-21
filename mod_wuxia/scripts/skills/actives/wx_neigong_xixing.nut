// Active Skill: 北冥噬气诀 (Evil/Harmony Qi Siphon Touch, 4 AP, 12 Qi, 2-turn cooldown)
this.wx_neigong_xixing <- this.inherit("scripts/skills/skill", {
	m = { Cooldown = 0, WX_VfxBrush = "wx_vfx_19", WX_AnimID = "wx_anim_24", WX_AnimMode = "black_hole" },
	function create()
	{
		this.m.ID = "actives.wx_neigong_xixing";
		this.m.Name = "北冥噬气诀";
		this.m.Description = "奇门导气秘术：消耗 4 AP 与 12 内息，掌心吐纳气璇强行抽散近身活人目标 18 点内息并导引 14 点归入自身丹田（冷却 2 回合）。";
		this.m.Icon = "skills/wx_neigong_xixing.png";
		this.m.IconDisabled = "skills/wx_neigong_xixing_sw.png";
		this.m.Overlay = "wx_ov_wx_neigong_xixing";
		this.m.WX_AnimID <- "wx_anim_24";
		this.m.WX_AnimMode <- "black_hole";
		this.m.WX_ChoreoID <- "wx_neigong_xixing";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.OffensiveTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 12;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
	}
	function getTooltip() { return this.getDefaultUtilityTooltip(); }
	function isUsable() { return this.m.Cooldown <= 0 && this.skill.isUsable(); }
	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!this.skill.onVerifyTarget(_originTile, _targetTile)) return false;
		local t = _targetTile.getEntity();
		return t != null && !this.getContainer().getActor().isAlliedWith(t) && !::Wuxia.CombatRules.isUndeadOrConstruct(t);
	}
	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.Cooldown = 0; }
	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		if (target == null) return false;
		this.m.Cooldown = 2;
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		target.setFatigue(::Math.min(target.getFatigueMax(), target.getFatigue() + 18));
		::Wuxia.CombatRules.restoreQi(_user, 14);
		return true;
	}
});
