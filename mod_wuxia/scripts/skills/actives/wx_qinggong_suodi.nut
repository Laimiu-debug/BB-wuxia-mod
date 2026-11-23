// Active Qinggong Skill: 缩地成寸步
this.wx_qinggong_suodi <- this.inherit("scripts/skills/skill", {
	m = { Cooldown = 0, WX_VfxBrush = "wx_vfx_26", WX_AnimID = "wx_anim_159", WX_AnimMode = "step_suodi" },
	function create()
	{
		this.m.ID = "actives.wx_qinggong_suodi";
		this.m.Name = "缩地成寸步";
		this.m.Description = "玄门空间奇步秘传：消耗 3 AP 与 20 内息，一步跨出瞬移至 3 格内任意可见空地，出神入化（冷却 3 回合）。";
		this.m.Icon = "skills/wx_qinggong_suodi.png";
		this.m.IconDisabled = "skills/wx_qinggong_suodi_sw.png";
		this.m.Overlay = "wx_ov_wx_qinggong_suodi";
		this.m.WX_AnimID <- "wx_anim_159";
		this.m.WX_AnimMode <- "step_suodi";
		this.m.WX_ChoreoID <- "wx_qinggong_suodi";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.UtilityTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = false;
		this.m.IsVisibleTileNeeded = true;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 3;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 3;
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
		this.m.Cooldown = 3;
		::Wuxia.VFX.playSkillVfx(this, _user, _user.getTile(), this.m.WX_VfxBrush);
		::Tactical.getNavigator().teleport(_user, _targetTile, null, null, false);
		
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		return true;
	}
});
