// Combat Status: 回锋反击架势 (Auto-counterattacks missed melee attacks; spends 4 Qi per counter)

this.wx_status_counter_stance <- this.inherit("scripts/skills/skill", {
	m = {
		IsCountering = false,
		QiCostPerCounter = 4
	},

	function create()
	{
		this.m.ID = "effects.wx_status_counter_stance";
		this.m.Name = "回锋架势";
		this.m.Description = "凝剑守势：直至下回合开始前，敌方近战攻势落空时自动回锋反击（每次反击耗 4 内息）。";
		this.m.Icon = "skills/wx_status_counter_stance.png";
		this.m.IconMini = "status_effect_33_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (!this.m.IsCountering || _skill == null || _skill.isRanged()) return;
		local c = this.getContainer().getSkillByID("special.wx_martial_container");
		if (c != null && c.m.CachedAggFlags != null) _properties.MeleeSkill += c.m.CachedAggFlags.CounterBonus;
	}

	function onUpdate( _properties )
	{
		_properties.MeleeDefense += 5;
	}

	function onMissed( _attacker, _skill )
	{
		if (_attacker == null || !_attacker.isAlive() || _skill == null || _skill.isRanged() || _skill.isIgnoringRiposte())
			return;

		local actor = this.getContainer().getActor();
		if (actor == null || !actor.isAlive() || this.m.IsCountering) return;
		local c = this.getContainer().getSkillByID("special.wx_martial_container");
		if (c == null || c.m.CachedAggFlags == null || c.m.CachedAggFlags.CounterBonus <= 0) return;
		local active = this.Tactical.TurnSequenceBar.getActiveEntity();
		if (active == null || active.getID() != _attacker.getID() || actor.isAlliedWith(_attacker)) return;
		if (actor.getTile().getDistanceTo(_attacker.getTile()) > 1) return;

		local availQi = actor.getFatigueMax() - actor.getFatigue();
		if (availQi < this.m.QiCostPerCounter)
		{
			this.removeSelf();
			return;
		}

		local counterSkill = actor.getSkills().getAttackOfOpportunity();
		if (counterSkill != null)
		{
			::Wuxia.CombatRules.spendQi(actor, this.m.QiCostPerCounter);
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(actor, "wx_vfx_01", "wx_fx_bagua", 0, 140, 1.08);
			this.m.IsCountering = true;
			try { counterSkill.useForFree(_attacker.getTile()); }
			catch (error) { this.m.IsCountering = false; throw error; }
			this.m.IsCountering = false;
		}
	}

	function onTurnStart()
	{
		this.removeSelf();
	}
});
