// Combat Status: 烟幕蔽目 (Reduces vision and ranged accuracy, 2 turns)

this.wx_status_smoke_screen <- this.inherit("scripts/skills/skill", {
	m = {
		TurnsLeft = 2
	},

	function create()
	{
		this.m.ID = "effects.wx_status_smoke_screen";
		this.m.Name = "烟幕蔽目";
		this.m.Description = "毒烟遮蔽视线：视野 -2，远射与暗器准头 -25%，近身准头 -10%。";
		this.m.Icon = "skills/wx_status_smoke_screen.png";
		this.m.IconMini = "status_effect_90_mini";
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
		_properties.Vision -= 2;
		_properties.RangedSkill -= 25;
		_properties.MeleeSkill -= 10;
	}

	function onTurnEnd()
	{
		this.m.TurnsLeft -= 1;
		if (this.m.TurnsLeft <= 0) this.removeSelf();
	}
});
