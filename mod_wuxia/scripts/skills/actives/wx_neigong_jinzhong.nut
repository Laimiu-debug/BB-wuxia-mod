// Active Skill: 金钟护体罡 (Heavy HengLian / Yang Neigong Indomitable Bell, 4 AP, 24 Qi)
this.wx_neigong_jinzhong <- this.inherit("scripts/skills/skill", {
	m = { ActiveBell = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_17", WX_AnimID = "wx_anim_16", WX_AnimMode = "golden_bell" },
	function create()
	{
		this.m.ID = "actives.wx_neigong_jinzhong";
		this.m.Name = "金钟护体罡";
		this.m.Description = "阳刚横练沉岳绝技：消耗 4 AP 与 24 内息，周身鼓荡梵钟护体金罡，至下回合开始前所受气血与护甲伤害减免 35%，且免疫震晕与击退（冷却 2 回合）。";
		this.m.Icon = "skills/wx_neigong_jinzhong.png";
		this.m.IconDisabled = "skills/wx_neigong_jinzhong_sw.png";
		this.m.Overlay = "wx_ov_wx_neigong_jinzhong";
		this.m.WX_AnimID <- "wx_anim_16";
		this.m.WX_AnimMode <- "golden_bell";
		this.m.WX_ChoreoID <- "wx_neigong_jinzhong";
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
	function isUsable() { return this.m.Cooldown <= 0 && !this.m.ActiveBell && this.skill.isUsable(); }
	function onUpdate( _properties )
	{
		if (this.m.ActiveBell)
		{
			_properties.DamageReceivedRegularMult *= 0.65;
			_properties.DamageReceivedArmorMult *= 0.65;
			_properties.IsImmuneToStun = true;
			_properties.IsImmuneToKnockBackAndGrab = true;
		}
	}
	function onTurnStart() { this.m.ActiveBell = false; if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.ActiveBell = false; this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.ActiveBell = false; this.m.Cooldown = 0; }
	function onUse( _user, _targetTile )
	{
		this.m.ActiveBell = true;
		this.m.Cooldown = 2;
		::Wuxia.VFX.playSkillVfx(this, _user, _user.getTile(), this.m.WX_VfxBrush);
		this.getContainer().update();
		return true;
	}
});
