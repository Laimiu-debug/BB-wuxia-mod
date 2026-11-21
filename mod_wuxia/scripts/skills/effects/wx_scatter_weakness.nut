// Status Effect: 散功虚弱 (applied when overwriting a martial slot)

this.wx_scatter_weakness <- this.inherit("scripts/skills/skill", {
	m = {
		DaysRemaining = 2
	},

	function create()
	{
		this.m.ID = "effects.wx_scatter_weakness";
		this.m.Name = "散功虚弱";
		this.m.Description = "强行散去旧功重修所致的气血虚浮，需调养数日或服用护心丹化解。";
		this.m.Icon = "skills/wx_scatter_weakness.png";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.VeryLast;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsSerialized = true;
		this.m.IsRemovedAfterBattle = false;
	}

	function setDaysRemaining( _days )
	{
		this.m.DaysRemaining = ::Math.max(this.m.DaysRemaining, _days);
	}

	function getTooltip()
	{
		return [
			{ id = 1, type = "title", text = this.getName() + "（余 " + this.m.DaysRemaining + " 日）" },
			{ id = 2, type = "description", text = this.getDescription() },
			{ id = 10, type = "text", icon = "ui/icons/fatigue.png", text = "[color=" + ::Const.UI.Color.NegativeValue + "]-15%[/color] 内息上限" },
			{ id = 11, type = "text", icon = "ui/icons/melee_skill.png", text = "[color=" + ::Const.UI.Color.NegativeValue + "]-8[/color] 武艺、射艺与招架" }
		];
	}

	function onUpdate( _properties )
	{
		_properties.StaminaMult *= 0.85;
		_properties.MeleeSkill -= 8;
		_properties.RangedSkill -= 8;
		_properties.MeleeDefense -= 8;
	}

	function onNewDay()
	{
		this.m.DaysRemaining -= 1;
		if (this.m.DaysRemaining <= 0)
		{
			this.removeSelf();
		}
	}

	function onSerialize( _out )
	{
		this.skill.onSerialize(_out);
		_out.writeU8(this.m.DaysRemaining);
	}

	function onDeserialize( _in )
	{
		this.skill.onDeserialize(_in);
		this.m.DaysRemaining = _in.readU8();
	}
});
