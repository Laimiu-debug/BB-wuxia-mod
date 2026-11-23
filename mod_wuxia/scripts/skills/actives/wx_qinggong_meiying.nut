// Active Qinggong Skill: 魅影迷踪步
this.wx_qinggong_meiying <- this.inherit("scripts/skills/skill", {
	m = { Cooldown = 0, WX_VfxBrush = "wx_vfx_25", WX_AnimID = "wx_anim_155", WX_AnimMode = "step_meiying" },
	function create()
	{
		this.m.ID = "actives.wx_qinggong_meiying";
		this.m.Name = "魅影迷踪步";
		this.m.Description = "奇门鬼魅幻影身法：消耗 3 AP 与 18 内息，原地留下一道青烟残影滑入 2 格内空地，无视截击（冷却 2 回合）。";
		this.m.Icon = "skills/wx_qinggong_meiying.png";
		this.m.IconDisabled = "skills/wx_qinggong_meiying_sw.png";
		this.m.Overlay = "wx_ov_wx_qinggong_meiying";
		this.m.WX_AnimID <- "wx_anim_155";
		this.m.WX_AnimMode <- "step_meiying";
		this.m.WX_ChoreoID <- "wx_qinggong_meiying";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.UtilityTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = false;
		this.m.IsVisibleTileNeeded = true;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 3;
		this.m.FatigueCost = 18;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.MaxLevelDifference = 2;
	}
	function getTooltip() { return this.getDefaultUtilityTooltip(); }
	function isUsable()
	{
		if (this.m.Cooldown > 0 || !this.skill.isUsable()) return false;
		local a = this.getContainer().getActor();
		return a != null && !a.getCurrentProperties().IsRooted;
	}
	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!this.skill.onVerifyTarget(_originTile, _targetTile)) return false;
		return _targetTile.IsEmpty && !_targetTile.IsOccupiedByActor && ::Math.abs(_originTile.Level - _targetTile.Level) <= 2;
	}
	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.Cooldown = 0; }
	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 2;
		::Wuxia.VFX.playSkillVfx(this, _user, _user.getTile(), this.m.WX_VfxBrush);
		::Tactical.getNavigator().teleport(_user, _targetTile, null, null, false);
		
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		return true;
	}
});
