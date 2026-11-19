// Combat Status: 回锋反击架势 (Auto-counterattacks missed melee attacks; spends 4 Qi per counter)

this.wx_status_counter_stance <- this.inherit("scripts/skills/skill", {
	m = {
		CounterHitBonus = 10,
		QiCostPerCounter = 4
	},

	function create()
	{
		this.m.ID = "effects.wx_status_counter_stance";
		this.m.Name = "回锋架势";
		this.m.Description = "凝剑守势：直至下回合开始前，敌方近战攻势落空时自动回锋反击（每次反击耗 4 内息）。";
		this.m.Icon = "skills/status_effect_33.png";
		this.m.IconMini = "status_effect_33_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
	}

	function setCounterBonus( _bonus )
	{
		this.m.CounterHitBonus = _bonus;
	}

	function onUpdate( _properties )
	{
		_properties.MeleeDefense += 5;
	}

	function onMissed( _attacker, _skill )
	{
		if (_attacker == null || !_attacker.isAlive() || _skill == null || _skill.isRanged())
			return;

		local actor = this.getContainer().getActor();
		if (actor == null || !actor.isAlive()) return;
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
			counterSkill.useForFree(_attacker.getTile());
		}
	}

	function onTurnStart()
	{
		this.removeSelf();
	}
});
