// Active Qinggong Skill: 神行百变步
this.wx_qinggong_shenxing <- this.inherit("scripts/skills/skill", {
	m = { Cooldown = 0, WX_VfxBrush = "wx_vfx_25", WX_AnimID = "wx_anim_156", WX_AnimMode = "step_shenxing" },
	function create()
	{
		this.m.ID = "actives.wx_qinggong_shenxing";
		this.m.Name = "神行百变步";
		this.m.Description = "轻功孤本绝世滑步：消耗 2 AP 与 14 内息，泥鳅般自刀山剑林滑入相邻空地，解除失衡并回复 4 点内息（冷却 2 回合）。";
		this.m.Icon = "skills/wx_qinggong_shenxing.png";
		this.m.IconDisabled = "skills/wx_qinggong_shenxing_sw.png";
		this.m.Overlay = "wx_ov_wx_qinggong_shenxing";
		this.m.WX_AnimID <- "wx_anim_156";
		this.m.WX_AnimMode <- "step_shenxing";
		this.m.WX_ChoreoID <- "wx_qinggong_shenxing";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.UtilityTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = false;
		this.m.IsVisibleTileNeeded = true;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 2;
		this.m.FatigueCost = 14;
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
		local usk = _user.getSkills(); if (usk != null) usk.removeByID("effects.wx_status_offbalance"); _user.setFatigue(::Math.max(0, _user.getFatigue() - 4));
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		return true;
	}
});
