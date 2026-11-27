// Active Skill: 紫霞流云气
this.wx_neigong_zixia <- this.inherit("scripts/skills/skill", {
	m = { ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_04", WX_AnimID = "wx_anim_143", WX_AnimMode = "stance_zixia" },
	function create()
	{
		this.m.ID = "actives.wx_neigong_zixia";
		this.m.Name = "紫霞流云气";
		this.m.Description = "华山玄门绵长内功心诀：消耗 3 AP 与 0 内息，紫气东来盈满经脉，立即回复 20 点内息并在本回合提升 10 点近远双防（冷却 3 回合）。";
		this.m.Icon = "skills/wx_neigong_zixia.png";
		this.m.IconDisabled = "skills/wx_neigong_zixia_sw.png";
		this.m.Overlay = "wx_ov_wx_neigong_zixia";
		this.m.WX_AnimID <- "wx_anim_143";
		this.m.WX_AnimMode <- "stance_zixia";
		this.m.WX_ChoreoID <- "wx_neigong_zixia";
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
			_properties.MeleeDefense += 10; _properties.RangedDefense += 10;
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
		_user.setFatigue(::Math.max(0, _user.getFatigue() - 20));
		if ("Streams" in ::Wuxia && _user.getTile() != null)
			::Wuxia.Streams.spawnSwordNode(_user, _user.getTile());
		this.getContainer().update();
		return true;
	}
});
