// Active Skill: 金针渡穴诀 (Medical Acupressure Stop-Bleed/Detox/Heal, 5 AP, 22 Qi, 2-turn cooldown)
this.wx_tactics_jinzhen <- this.inherit("scripts/skills/skill", {
	m = { Cooldown = 0, WX_VfxBrush = "wx_vfx_22", WX_AnimID = "wx_anim_72", WX_AnimMode = "heal_needles" },
	function create()
	{
		this.m.ID = "actives.wx_tactics_jinzhen";
		this.m.Name = "金针渡穴诀";
		this.m.Description = "杏林医家济世奇术：消耗 5 AP 与 22 内息，为自身或相邻同袍施针止血、拔除奇毒封穴，并稳固 14 点气血（冷却 2 回合）。";
		this.m.Icon = "skills/wx_tactics_jinzhen.png";
		this.m.IconDisabled = "skills/wx_tactics_jinzhen_sw.png";
		this.m.Overlay = "wx_ov_wx_tactics_jinzhen";
		this.m.WX_AnimID <- "wx_anim_72";
		this.m.WX_AnimMode <- "heal_needles";
		this.m.WX_ChoreoID <- "wx_tactics_jinzhen";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.UtilityTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 22;
		this.m.MinRange = 0;
		this.m.MaxRange = 1;
	}
	function getTooltip() { return this.getDefaultUtilityTooltip(); }
	function isUsable() { return this.m.Cooldown <= 0 && this.skill.isUsable(); }
	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!this.skill.onVerifyTarget(_originTile, _targetTile)) return false;
		local t = _targetTile.getEntity();
		return t != null && this.getContainer().getActor().isAlliedWith(t) && !::Wuxia.CombatRules.isUndeadOrConstruct(t);
	}
	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.Cooldown = 0; }
	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		if (target == null) return false;
		this.m.Cooldown = 2;
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local sk = target.getSkills();
		if (sk != null)
		{
			sk.removeByID("effects.bleeding");
			sk.removeByID("effects.spider_poison");
			sk.removeByID("effects.goblin_poison");
			sk.removeByID("effects.wx_status_poison_dart");
			sk.removeByID("effects.wx_status_acupoint");
			local injury = sk.getSkillByID("effects.wx_internal_injury");
			if (injury != null) injury.cureTemporary();
		}
		target.setHitpoints(::Math.min(target.getHitpointsMax(), target.getHitpoints() + 14));
		return true;
	}
});
