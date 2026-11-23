// Active Skill: 万蛊噬元瘴
this.wx_neigong_wudu <- this.inherit("scripts/skills/skill", {
	m = { ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_28", WX_AnimID = "wx_anim_147", WX_AnimMode = "aoe_wuduzhang" },
	function create()
	{
		this.m.ID = "actives.wx_neigong_wudu";
		this.m.Name = "万蛊噬元瘴";
		this.m.Description = "南疆五毒护身毒功：消耗 4 AP 与 16 内息，催谷体内百蛊散出护身碧瘴，清除自身中毒并令周身 1 格活人敌军感染奇毒蚀脉（冷却 2 回合）。";
		this.m.Icon = "skills/wx_neigong_wudu.png";
		this.m.IconDisabled = "skills/wx_neigong_wudu_sw.png";
		this.m.Overlay = "wx_ov_wx_neigong_wudu";
		this.m.WX_AnimID <- "wx_anim_147";
		this.m.WX_AnimMode <- "aoe_wuduzhang";
		this.m.WX_ChoreoID <- "wx_neigong_wudu";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
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
			_properties.IsImmuneToPoison = true; _properties.RangedDefense += 10;
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
		local usk = _user.getSkills(); if (usk != null) usk.removeByID("effects.wx_status_poison_dart"); local myT = _user.getTile(); for (local d = 0; d < ::Const.Direction.COUNT; d = ++d) { if (!myT.hasNextTile(d)) continue; local nt = myT.getNextTile(d); if (nt.IsOccupiedByActor && !_user.isAlliedWith(nt.getEntity()) && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(nt.getEntity())) { local tsk = nt.getEntity().getSkills(); if (tsk != null && !tsk.hasSkill("effects.wx_status_poison_dart")) tsk.add(::new("scripts/skills/effects/wx_status_poison_dart")); } }
		this.getContainer().update();
		return true;
	}
});
