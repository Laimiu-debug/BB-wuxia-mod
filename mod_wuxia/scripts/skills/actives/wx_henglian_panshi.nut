// Active Skill: 磐石镇岳架
this.wx_henglian_panshi <- this.inherit("scripts/skills/skill", {
	m = { ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_05", WX_AnimID = "wx_anim_163", WX_AnimMode = "stance_panshi" },
	function create()
	{
		this.m.ID = "actives.wx_henglian_panshi";
		this.m.Name = "磐石镇岳架";
		this.m.Description = "北岳沉肩守阵硬功：消耗 3 AP 与 18 内息，双足生根如泰山磐石，本回合近防 +10、护甲减伤 25% 且完全免疫击退抓取与合围惩罚（冷却 2 回合）。";
		this.m.Icon = "skills/wx_henglian_panshi.png";
		this.m.IconDisabled = "skills/wx_henglian_panshi_sw.png";
		this.m.Overlay = "wx_ov_wx_henglian_panshi";
		this.m.WX_AnimID <- "wx_anim_163";
		this.m.WX_AnimMode <- "stance_panshi";
		this.m.WX_ChoreoID <- "wx_henglian_panshi";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 3;
		this.m.FatigueCost = 18;
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
			_properties.MeleeDefense += 10; _properties.DamageReceivedArmorMult *= 0.75; _properties.IsImmuneToKnockBackAndGrab = true; _properties.IsImmuneToSurrounding = true;
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
		
		this.getContainer().update();
		return true;
	}
});
