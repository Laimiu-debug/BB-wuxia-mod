// Active Skill: 破阵杀伐气
this.wx_neigong_junwu <- this.inherit("scripts/skills/skill", {
	m = { ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_24", WX_AnimID = "wx_anim_151", WX_AnimMode = "stance_junwu" },
	function create()
	{
		this.m.ID = "actives.wx_neigong_junwu";
		this.m.Name = "破阵杀伐气";
		this.m.Description = "边塞军旅刚猛行气诀：消耗 2 AP 与 12 内息，鼓荡胸中杀伐烈气，本回合总伤害提升 +15%、定力 +20 且免疫恐惧动摇（冷却 3 回合）。";
		this.m.Icon = "skills/wx_neigong_junwu.png";
		this.m.IconDisabled = "skills/wx_neigong_junwu_sw.png";
		this.m.Overlay = "wx_ov_wx_neigong_junwu";
		this.m.WX_AnimID <- "wx_anim_151";
		this.m.WX_AnimMode <- "stance_junwu";
		this.m.WX_ChoreoID <- "wx_neigong_junwu";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 2;
		this.m.FatigueCost = 12;
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
			_properties.DamageTotalMult *= 1.15; _properties.Bravery += 20;
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
		_user.checkMorale(1, 15);
		this.getContainer().update();
		return true;
	}
});
