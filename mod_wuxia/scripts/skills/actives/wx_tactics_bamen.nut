// Active Skill: 八门金锁阵
this.wx_tactics_bamen <- this.inherit("scripts/skills/skill", {
	m = { ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_24", WX_AnimID = "wx_anim_167", WX_AnimMode = "aoe_bamen" },
	function create()
	{
		this.m.ID = "actives.wx_tactics_bamen";
		this.m.Name = "八门金锁阵";
		this.m.Description = "将门统军战阵号令：消耗 4 AP 与 22 内息，指挥周身 3 格全体同袍结成金锁严阵，稳固战意并清除同袍失衡状态（冷却 2 回合）。";
		this.m.Icon = "skills/wx_tactics_bamen.png";
		this.m.IconDisabled = "skills/wx_tactics_bamen_sw.png";
		this.m.Overlay = "wx_ov_wx_tactics_bamen";
		this.m.WX_AnimID <- "wx_anim_167";
		this.m.WX_AnimMode <- "aoe_bamen";
		this.m.WX_ChoreoID <- "wx_tactics_bamen";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 22;
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
			_properties.MeleeDefense += 8; _properties.RangedDefense += 8;
		}
	}
	function onTurnStart() { this.m.ActiveBuff = false; if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.ActiveBuff = false; this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.ActiveBuff = false; this.m.Cooldown = 0; }
	function onUse( _user, _targetTile )
	{
		this.m.ActiveBuff = true;
		this.m.Cooldown = 2;
		::Wuxia.VFX.playSkillVfx(this, _user, _user.getTile(), this.m.WX_VfxBrush);
		local myT = _user.getTile();
		if ("TileField" in ::Wuxia && myT != null)
			::Wuxia.TileField.dispelFieldsInRadius(myT, 3, ["mirage_mist", "gale_sand"]);
		local actors = ::Tactical.Entities.getAllInstances(); foreach (team in actors) { foreach (a in team) { if (a == null || !a.isAlive() || !a.isPlacedOnMap() || !_user.isAlliedWith(a)) continue; if (myT.getDistanceTo(a.getTile()) <= 3) { a.checkMorale(1, 15); local ask = a.getSkills(); if (ask != null) ask.removeByID("effects.wx_status_offbalance"); } } }
		this.getContainer().update();
		return true;
	}
});
