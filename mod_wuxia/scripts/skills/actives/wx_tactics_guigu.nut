// Active Skill: 鬼谷纵横策
this.wx_tactics_guigu <- this.inherit("scripts/skills/skill", {
	m = { ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_24", WX_AnimID = "wx_anim_165", WX_AnimMode = "aoe_guigu" },
	function create()
	{
		this.m.ID = "actives.wx_tactics_guigu";
		this.m.Name = "鬼谷纵横策";
		this.m.Description = "兵家孤本统帅奇谋：消耗 4 AP 与 24 内息，运筹帷幄号令周身 4 格全体同袍稳固战意、回复 8 点内息，并令 3 格内敌军暴露破绽（冷却 3 回合）。";
		this.m.Icon = "skills/wx_tactics_guigu.png";
		this.m.IconDisabled = "skills/wx_tactics_guigu_sw.png";
		this.m.Overlay = "wx_ov_wx_tactics_guigu";
		this.m.WX_AnimID <- "wx_anim_165";
		this.m.WX_AnimMode <- "aoe_guigu";
		this.m.WX_ChoreoID <- "wx_tactics_guigu";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 24;
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
		local actors = ::Tactical.Entities.getAllInstances(); local myT = _user.getTile(); foreach (team in actors) { foreach (a in team) { if (a == null || !a.isAlive() || !a.isPlacedOnMap()) continue; local dist = myT.getDistanceTo(a.getTile()); if (_user.isAlliedWith(a) && dist <= 4) { a.checkMorale(1, 20); a.setFatigue(::Math.max(0, a.getFatigue() - 8)); } else if (!_user.isAlliedWith(a) && dist <= 3) { local ask = a.getSkills(); if (ask != null && !ask.hasSkill("effects.wx_status_opening")) ask.add(::new("scripts/skills/effects/wx_status_opening")); if ("Streams" in ::Wuxia) ::Wuxia.Streams.interruptEnemyCharge(_user, a, 2); } } }
		this.getContainer().update();
		return true;
	}
});
