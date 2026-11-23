// Active Skill: 饕餮吞天诀
this.wx_neigong_taotie <- this.inherit("scripts/skills/skill", {
	m = { ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_20", WX_AnimID = "wx_anim_149", WX_AnimMode = "aoe_taotie" },
	function create()
	{
		this.m.ID = "actives.wx_neigong_taotie";
		this.m.Name = "饕餮吞天诀";
		this.m.Description = "山海凶魔鲸吞秘功：消耗 3 AP 与 10 内息，张开饕餮血气漩涡，抽取周身每名活人敌军 6 点内息化为自身气血与内息（冷却 3 回合）。";
		this.m.Icon = "skills/wx_neigong_taotie.png";
		this.m.IconDisabled = "skills/wx_neigong_taotie_sw.png";
		this.m.Overlay = "wx_ov_wx_neigong_taotie";
		this.m.WX_AnimID <- "wx_anim_149";
		this.m.WX_AnimMode <- "aoe_taotie";
		this.m.WX_ChoreoID <- "wx_neigong_taotie";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 3;
		this.m.FatigueCost = 10;
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
			_properties.DamageTotalMult *= 1.12;
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
		::Wuxia.CombatRules.drainAdjacentQi(_user);
		this.getContainer().update();
		return true;
	}
});
