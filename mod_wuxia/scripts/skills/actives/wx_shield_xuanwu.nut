// Active Skill: 玄武拒马盾
this.wx_shield_xuanwu <- this.inherit("scripts/skills/skill", {
	m = { ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_17", WX_AnimID = "wx_anim_164", WX_AnimMode = "stance_xuanwu" },
	function create()
	{
		this.m.ID = "actives.wx_shield_xuanwu";
		this.m.Name = "玄武拒马盾";
		this.m.Description = "镇派重盾铁壁阵法：消耗 4 AP 与 20 内息，副手持盾凝起玄武甲阵，本回合近远双防 +18、护甲减伤 25% 且免疫击退与震晕（冷却 2 回合）。";
		this.m.Icon = "skills/wx_shield_xuanwu.png";
		this.m.IconDisabled = "skills/wx_shield_xuanwu_sw.png";
		this.m.Overlay = "wx_ov_wx_shield_xuanwu";
		this.m.WX_AnimID <- "wx_anim_164";
		this.m.WX_AnimMode <- "stance_xuanwu";
		this.m.WX_ChoreoID <- "wx_shield_xuanwu";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 20;
	}
	function isHidden()
	{
		local a = this.getContainer() == null ? null : this.getContainer().getActor();
		local off = (a != null && a.getItems() != null) ? a.getItems().getItemAtSlot(::Const.ItemSlot.Offhand) : null;
		return this.skill.isHidden() || off == null || !off.isItemType(::Const.Items.ItemType.Shield);
	}
	function getTooltip() { return this.getDefaultUtilityTooltip(); }
	function isUsable()
	{
		if (this.m.Cooldown > 0 || this.m.ActiveBuff || !this.skill.isUsable()) return false;
		local a = this.getContainer().getActor();
		local off = (a != null && a.getItems() != null) ? a.getItems().getItemAtSlot(::Const.ItemSlot.Offhand) : null;
		if (off == null || !off.isItemType(::Const.Items.ItemType.Shield)) return false;
		return true;
	}
	function onUpdate( _properties )
	{
		if (this.m.ActiveBuff)
		{
			_properties.MeleeDefense += 18; _properties.RangedDefense += 18; _properties.DamageReceivedArmorMult *= 0.75; _properties.IsImmuneToKnockBackAndGrab = true; _properties.IsImmuneToStun = true;
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
