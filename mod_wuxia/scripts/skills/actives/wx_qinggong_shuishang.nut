// Active Qinggong Skill: 踏浪水上漂
this.wx_qinggong_shuishang <- this.inherit("scripts/skills/skill", {
	m = { Cooldown = 0, WX_VfxBrush = "wx_vfx_21", WX_AnimID = "wx_anim_153", WX_AnimMode = "step_shuishang" },
	function create()
	{
		this.m.ID = "actives.wx_qinggong_shuishang";
		this.m.Name = "踏浪水上漂";
		this.m.Description = "江河水战绝顶提气术：消耗 3 AP 与 18 内息，足点清波飞掠 2 格内平地或水域空地，无视截击并解脱失衡（冷却 2 回合）。";
		this.m.Icon = "skills/wx_qinggong_shuishang.png";
		this.m.IconDisabled = "skills/wx_qinggong_shuishang_sw.png";
		this.m.Overlay = "wx_ov_wx_qinggong_shuishang";
		this.m.WX_AnimID <- "wx_anim_153";
		this.m.WX_AnimMode <- "step_shuishang";
		this.m.WX_ChoreoID <- "wx_qinggong_shuishang";
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
		local usk = _user.getSkills(); if (usk != null) usk.removeByID("effects.wx_status_offbalance");
		if ("Streams" in ::Wuxia)
		{
			local st = ::Wuxia.Streams.getOrCreateState(_user);
			if (st != null) st.addWindSteps(2);
		}
		if (_targetTile != null && ("TileField" in ::Wuxia) && ::Wuxia.TileField.hasField(_targetTile, "bitter_mire"))
		{
			::Wuxia.TileField.removeField(_targetTile);
			::Wuxia.CombatRules.restoreQi(_user, 6);
		}
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		return true;
	}
});
