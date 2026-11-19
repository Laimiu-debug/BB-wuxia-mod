// Combat Status: 点穴封气 (Halves natural Qi recovery and raises skill Qi cost by 35%)

this.wx_status_acupoint <- this.inherit("scripts/skills/skill", {
	m = {
		TurnsLeft = 2
	},

	function create()
	{
		this.m.ID = "effects.wx_status_acupoint";
		this.m.Name = "点穴封气";
		this.m.Description = "经脉要穴受制，每回合自然回气 -8，运招内息消耗 +35%。";
		this.m.Icon = "skills/status_effect_83.png";
		this.m.IconMini = "status_effect_83_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
	}

	function resetDuration( _turns = 2 )
	{
		this.m.TurnsLeft = ::Math.max(this.m.TurnsLeft, _turns);
	}

	function onUpdate( _properties )
	{
		_properties.FatigueRecoveryRate -= 8;
		_properties.FatigueEffectMult *= 1.35;
	}

	function onTurnEnd()
	{
		this.m.TurnsLeft -= 1;
		if (this.m.TurnsLeft <= 0) this.removeSelf();
	}
});
