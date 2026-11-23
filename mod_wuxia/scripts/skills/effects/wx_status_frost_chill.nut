// Combat Status: 寒凝封穴 (北溟寒渊套 3 件大成触发：行动点 -2，身法 -25，持续 1 回合)

this.wx_status_frost_chill <- this.inherit("scripts/skills/skill", {
	m = {
		TurnsLeft = 1
	},

	function create()
	{
		this.m.ID = "effects.wx_status_frost_chill";
		this.m.Name = "寒凝封穴";
		this.m.Description = "北溟寒渊弱水寒劲侵入奇经八脉，动作迟滞凝涩：行动点 -2，身法 -25。";
		this.m.Icon = "skills/wx_neigong_hanbing.png";
		this.m.IconMini = "status_effect_87_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsSerialized = false;
		this.m.IsRemovedAfterBattle = true;
	}

	function resetDuration( _turns = 1 )
	{
		this.m.TurnsLeft = ::Math.max(this.m.TurnsLeft, _turns);
	}

	function getTooltip()
	{
		return [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description", text = this.getDescription() },
			{ id = 10, type = "text", icon = "ui/icons/action_points.png", text = "[color=" + this.Const.UI.Color.NegativeValue + "]-2[/color] 行动点" },
			{ id = 11, type = "text", icon = "ui/icons/initiative.png", text = "[color=" + this.Const.UI.Color.NegativeValue + "]-25[/color] 身法" }
		];
	}

	function onUpdate( _properties )
	{
		_properties.ActionPoints = ::Math.max(2, _properties.ActionPoints - 2);
		_properties.Initiative -= 25;
	}

	function onTurnEnd()
	{
		this.m.TurnsLeft -= 1;
		if (this.m.TurnsLeft <= 0) this.removeSelf();
	}
});
