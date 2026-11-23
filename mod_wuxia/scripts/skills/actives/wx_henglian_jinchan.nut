// Active Skill: 金蝉卸甲劲
this.wx_henglian_jinchan <- this.inherit("scripts/skills/skill", {
	m = { ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_15", WX_AnimID = "wx_anim_161", WX_AnimMode = "stance_jinchan" },
	function create()
	{
		this.m.ID = "actives.wx_henglian_jinchan";
		this.m.Name = "金蝉卸甲劲";
		this.m.Description = "轻装内家卸力奇功：消耗 3 AP 与 16 内息，借金蝉脱壳巧劲卸开锋芒，清除自身流血/失衡并获本回合近远双防 +12（冷却 2 回合）。";
		this.m.Icon = "skills/wx_henglian_jinchan.png";
		this.m.IconDisabled = "skills/wx_henglian_jinchan_sw.png";
		this.m.Overlay = "wx_ov_wx_henglian_jinchan";
		this.m.WX_AnimID <- "wx_anim_161";
		this.m.WX_AnimMode <- "stance_jinchan";
		this.m.WX_ChoreoID <- "wx_henglian_jinchan";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 3;
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
			_properties.MeleeDefense += 12; _properties.RangedDefense += 12;
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
		local usk = _user.getSkills(); if (usk != null) { usk.removeByID("effects.bleeding"); usk.removeByID("effects.wx_status_offbalance"); }
		this.getContainer().update();
		return true;
	}
});
