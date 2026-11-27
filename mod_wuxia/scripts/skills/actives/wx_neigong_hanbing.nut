// Active Skill: 玄阴寒冰气
this.wx_neigong_hanbing <- this.inherit("scripts/skills/skill", {
	m = { ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_21", WX_AnimID = "wx_anim_145", WX_AnimMode = "stance_hanbing" },
	function create()
	{
		this.m.ID = "actives.wx_neigong_hanbing";
		this.m.Name = "玄阴寒冰气";
		this.m.Description = "极寒阴柔护体真气：消耗 3 AP 与 16 内息，周身凝结六角玄冰霜甲，本回合受创气血减免 25% 且令近身攻击者内息凝滞 +10（冷却 2 回合）。";
		this.m.Icon = "skills/wx_neigong_hanbing.png";
		this.m.IconDisabled = "skills/wx_neigong_hanbing_sw.png";
		this.m.Overlay = "wx_ov_wx_neigong_hanbing";
		this.m.WX_AnimID <- "wx_anim_145";
		this.m.WX_AnimMode <- "stance_hanbing";
		this.m.WX_ChoreoID <- "wx_neigong_hanbing";
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
			_properties.DamageReceivedRegularMult = ::Math.maxf(0.40, _properties.DamageReceivedRegularMult * 0.75); _properties.MeleeDefense += 8;
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
		local myT = _user.getTile();
		if ("TileField" in ::Wuxia && myT != null)
			::Wuxia.TileField.setField(myT, "abyss_frost", 2, _user);
		for (local d = 0; d < ::Const.Direction.COUNT; d = ++d) { if (!myT.hasNextTile(d)) continue; local nt = myT.getNextTile(d); if (nt.IsOccupiedByActor && !_user.isAlliedWith(nt.getEntity()) && !::Wuxia.CombatRules.isUndeadOrConstruct(nt.getEntity())) { nt.getEntity().setFatigue(::Math.min(nt.getEntity().getFatigueMax(), nt.getEntity().getFatigue() + 10)); if ("TileField" in ::Wuxia) ::Wuxia.TileField.setField(nt, "abyss_frost", 2, _user); } }
		this.getContainer().update();
		return true;
	}
});
