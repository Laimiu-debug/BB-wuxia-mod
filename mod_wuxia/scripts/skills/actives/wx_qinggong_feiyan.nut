// Active Qinggong Skill: 飞燕掠空纵
this.wx_qinggong_feiyan <- this.inherit("scripts/skills/skill", {
	m = { Cooldown = 0, WX_VfxBrush = "wx_vfx_26", WX_AnimID = "wx_anim_154", WX_AnimMode = "step_feiyan" },
	function create()
	{
		this.m.ID = "actives.wx_qinggong_feiyan";
		this.m.Name = "飞燕掠空纵";
		this.m.Description = "名门高纵轻功：消耗 4 AP 与 20 内息，拔地掠空跃入 2 格内任意高低差 3 层以内空地抢占险要（冷却 2 回合）。";
		this.m.Icon = "skills/wx_qinggong_feiyan.png";
		this.m.IconDisabled = "skills/wx_qinggong_feiyan_sw.png";
		this.m.Overlay = "wx_ov_wx_qinggong_feiyan";
		this.m.WX_AnimID <- "wx_anim_154";
		this.m.WX_AnimMode <- "step_feiyan";
		this.m.WX_ChoreoID <- "wx_qinggong_feiyan";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.UtilityTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = false;
		this.m.IsVisibleTileNeeded = true;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.MaxLevelDifference = 3;
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
		return _targetTile.IsEmpty && !_targetTile.IsOccupiedByActor && ::Math.abs(_originTile.Level - _targetTile.Level) <= 3;
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
