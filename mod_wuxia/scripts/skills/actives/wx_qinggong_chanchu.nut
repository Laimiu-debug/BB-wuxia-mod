// Active Qinggong Skill: 金蟾折跃步
this.wx_qinggong_chanchu <- this.inherit("scripts/skills/skill", {
	m = { Cooldown = 0, WX_VfxBrush = "wx_vfx_28", WX_AnimID = "wx_anim_158", WX_AnimMode = "step_chanchu" },
	function create()
	{
		this.m.ID = "actives.wx_qinggong_chanchu";
		this.m.Name = "金蟾折跃步";
		this.m.Description = "奇门伏地弹射身法：消耗 3 AP 与 18 内息，伏身蓄劲猛然折跃至 2 格内空地，落地激起劲风震得邻敌失衡（冷却 2 回合）。";
		this.m.Icon = "skills/wx_qinggong_chanchu.png";
		this.m.IconDisabled = "skills/wx_qinggong_chanchu_sw.png";
		this.m.Overlay = "wx_ov_wx_qinggong_chanchu";
		this.m.WX_AnimID <- "wx_anim_158";
		this.m.WX_AnimMode <- "step_chanchu";
		this.m.WX_ChoreoID <- "wx_qinggong_chanchu";
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
		local myT = _user.getTile(); for (local d = 0; d < ::Const.Direction.COUNT; d = ++d) { if (!myT.hasNextTile(d)) continue; local nt = myT.getNextTile(d); if (nt.IsOccupiedByActor && !_user.isAlliedWith(nt.getEntity())) { local tsk = nt.getEntity().getSkills(); if (tsk != null && !tsk.hasSkill("effects.wx_status_offbalance")) tsk.add(::new("scripts/skills/effects/wx_status_offbalance")); } }
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		return true;
	}
});
