// Active Skill: 铁布横练功
this.wx_henglian_tiebushan <- this.inherit("scripts/skills/skill", {
	m = { ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_17", WX_AnimID = "wx_anim_160", WX_AnimMode = "stance_tiebushan" },
	function create()
	{
		this.m.ID = "actives.wx_henglian_tiebushan";
		this.m.Name = "铁布横练功";
		this.m.Description = "重甲硬功招牌架势：消耗 3 AP 与 18 内息，鼓足横练气墙，本回合护甲受创减免 35%、气血受创减免 25% 且免疫爆头暴击与震晕（冷却 2 回合）。";
		this.m.Icon = "skills/wx_henglian_tiebushan.png";
		this.m.IconDisabled = "skills/wx_henglian_tiebushan_sw.png";
		this.m.Overlay = "wx_ov_wx_henglian_tiebushan";
		this.m.WX_AnimID <- "wx_anim_160";
		this.m.WX_AnimMode <- "stance_tiebushan";
		this.m.WX_ChoreoID <- "wx_henglian_tiebushan";
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
			_properties.DamageReceivedArmorMult *= 0.65; _properties.DamageReceivedRegularMult = ::Math.maxf(0.40, _properties.DamageReceivedRegularMult * 0.75); _properties.IsImmuneToCriticals = true; _properties.IsImmuneToStun = true;
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
