// Active Skill: 夔牛震天吼
this.wx_tactics_kuiniu <- this.inherit("scripts/skills/skill", {
	m = { ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_23", WX_AnimID = "wx_anim_166", WX_AnimMode = "aoe_kuiniu" },
	function create()
	{
		this.m.ID = "actives.wx_tactics_kuiniu";
		this.m.Name = "夔牛震天吼";
		this.m.Description = "山海雷音横练孤本：消耗 5 AP 与 26 内息，吐气如东海夔牛雷鼓轰鸣，震得周身 2 格全体敌军陷入失衡与散劲并重挫军心（冷却 3 回合）。";
		this.m.Icon = "skills/wx_tactics_kuiniu.png";
		this.m.IconDisabled = "skills/wx_tactics_kuiniu_sw.png";
		this.m.Overlay = "wx_ov_wx_tactics_kuiniu";
		this.m.WX_AnimID <- "wx_anim_166";
		this.m.WX_AnimMode <- "aoe_kuiniu";
		this.m.WX_ChoreoID <- "wx_tactics_kuiniu";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 26;
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
		if (_user.getTile() != null && ("TileField" in ::Wuxia))
			::Wuxia.TileField.dispelFieldsInRadius(_user.getTile(), 3, ["mirage_mist"]);
		local actors = ::Tactical.Entities.getAllInstances(); local myT = _user.getTile(); foreach (team in actors) { foreach (a in team) { if (a == null || !a.isAlive() || !a.isPlacedOnMap() || _user.isAlliedWith(a)) continue; if (myT.getDistanceTo(a.getTile()) <= 2) { local ask = a.getSkills(); if (ask != null) { if (!ask.hasSkill("effects.wx_status_offbalance")) ask.add(::new("scripts/skills/effects/wx_status_offbalance")); if (!ask.hasSkill("effects.wx_scatter_weakness")) ask.add(::new("scripts/skills/effects/wx_scatter_weakness")); }
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(a)) a.checkMorale(-1, -15); } } }
		this.getContainer().update();
		return true;
	}
});
