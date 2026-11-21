// Active Skill: 不动明王盾架 (Shield Wall + Knockback Immunity, 4 AP, 18 Qi)
this.wx_shield_tiebi <- this.inherit("scripts/skills/skill", {
	m = { ActiveGuard = false, UsedThisTurn = false, WX_VfxBrush = "wx_vfx_17", WX_AnimID = "wx_anim_31", WX_AnimMode = "hex_fortress" },
	function create()
	{
		this.m.ID = "actives.wx_shield_tiebi";
		this.m.Name = "不动明王盾";
		this.m.Description = "前排刀盾护卫守线绝技：消耗 4 AP 与 18 内息（需副手持藤牌或铁盾），沉肩立盾使近防 +15、远防 +15 且免疫击退抓取，持续至下回合开始。";
		this.m.Icon = "skills/wx_shield_tiebi.png";
		this.m.IconDisabled = "skills/wx_shield_tiebi_sw.png";
		this.m.Overlay = "wx_ov_wx_shield_tiebi";
		this.m.WX_AnimID <- "wx_anim_31";
		this.m.WX_AnimMode <- "hex_fortress";
		this.m.WX_ChoreoID <- "wx_shield_tiebi";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
	}
	function getTooltip() { return this.getDefaultUtilityTooltip(); }
	function hasShield()
	{
		local a = this.getContainer() == null ? null : this.getContainer().getActor();
		if (a == null || a.getItems() == null) return false;
		local off = a.getItems().getItemAtSlot(::Const.ItemSlot.Offhand);
		return off != null && off.isItemType(::Const.Items.ItemType.Shield);
	}
	function isHidden() { return this.skill.isHidden() || !this.hasShield(); }
	function isUsable() { return !this.m.UsedThisTurn && this.skill.isUsable() && this.hasShield(); }
	function onUpdate( _properties )
	{
		if (this.m.ActiveGuard)
		{
			_properties.MeleeDefense += 15;
			_properties.RangedDefense += 15;
			_properties.IsImmuneToKnockBackAndGrab = true;
		}
	}
	function onTurnStart() { this.m.ActiveGuard = false; this.m.UsedThisTurn = false; }
	function onCombatStarted() { this.m.ActiveGuard = false; this.m.UsedThisTurn = false; }
	function onCombatFinished() { this.m.ActiveGuard = false; this.m.UsedThisTurn = false; }
	function onUse( _user, _targetTile )
	{
		this.m.ActiveGuard = true;
		this.m.UsedThisTurn = true;
		::Wuxia.VFX.playSkillVfx(this, _user, _user.getTile(), this.m.WX_VfxBrush);
		this.getContainer().update();
		return true;
	}
});
