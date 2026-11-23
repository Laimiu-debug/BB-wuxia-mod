// Active Skill: 太和归元劲
this.wx_neigong_guiyuan <- this.inherit("scripts/skills/skill", {
	m = { ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_18", WX_AnimID = "wx_anim_148", WX_AnimMode = "stance_guiyuan" },
	function create()
	{
		this.m.ID = "actives.wx_neigong_guiyuan";
		this.m.Name = "太和归元劲";
		this.m.Description = "道门纯阳抱元吐纳：消耗 4 AP 与 0 内息，三花聚顶导引先天清气，立即回复 26 点内息并解除失衡与封穴（冷却 3 回合）。";
		this.m.Icon = "skills/wx_neigong_guiyuan.png";
		this.m.IconDisabled = "skills/wx_neigong_guiyuan_sw.png";
		this.m.Overlay = "wx_ov_wx_neigong_guiyuan";
		this.m.WX_AnimID <- "wx_anim_148";
		this.m.WX_AnimMode <- "stance_guiyuan";
		this.m.WX_ChoreoID <- "wx_neigong_guiyuan";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 4;
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
			_properties.FatigueRecoveryRate += 6; _properties.Bravery += 10;
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
		local usk = _user.getSkills(); if (usk != null) { usk.removeByID("effects.wx_status_offbalance"); usk.removeByID("effects.wx_status_acupoint"); }
			_user.setFatigue(::Math.max(0, _user.getFatigue() - 26));
		this.getContainer().update();
		return true;
	}
});
