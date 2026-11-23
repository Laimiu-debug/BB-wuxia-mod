// Active Qinggong Skill: 燕子抄水步
this.wx_qinggong_yanxing <- this.inherit("scripts/skills/skill", {
	m = { Cooldown = 0, WX_VfxBrush = "wx_vfx_25", WX_AnimID = "wx_anim_152", WX_AnimMode = "step_yanxing" },
	function create()
	{
		this.m.ID = "actives.wx_qinggong_yanxing";
		this.m.Name = "燕子抄水步";
		this.m.Description = "灵巧江南轻身步法：消耗 3 AP 与 15 内息，如飞燕掠水轻滑入相邻空地，无视敌方控制区截击（冷却 2 回合）。";
		this.m.Icon = "skills/wx_qinggong_yanxing.png";
		this.m.IconDisabled = "skills/wx_qinggong_yanxing_sw.png";
		this.m.Overlay = "wx_ov_wx_qinggong_yanxing";
		this.m.WX_AnimID <- "wx_anim_152";
		this.m.WX_AnimMode <- "step_yanxing";
		this.m.WX_ChoreoID <- "wx_qinggong_yanxing";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.UtilityTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = false;
		this.m.IsVisibleTileNeeded = true;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 3;
		this.m.FatigueCost = 15;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.MaxLevelDifference = 1;
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
		return _targetTile.IsEmpty && !_targetTile.IsOccupiedByActor && ::Math.abs(_originTile.Level - _targetTile.Level) <= 1;
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
