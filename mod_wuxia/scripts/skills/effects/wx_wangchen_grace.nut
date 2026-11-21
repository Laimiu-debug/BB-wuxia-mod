// Status Effect: 归元护脉 (Granted by 忘尘归元散 when no active 散功虚弱; waives the next manual switch/unequip scatter penalty)

this.wx_wangchen_grace <- this.inherit("scripts/skills/skill", {
	function create()
	{
		this.m.ID = "effects.wx_wangchen_grace";
		this.m.Name = "归元护脉";
		this.m.Description = "丹田已凝结一层清纯归元药力：下一次换装或卸下任意品阶武学插槽时，散功调息天数直接归零（无损换功一次后自然消散）。";
		this.m.Icon = "skills/wx_status_poise_charge.png";
		this.m.IconMini = "status_effect_74_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.Perk;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsSerialized = true;
		this.m.IsRemovedAfterBattle = false;
	}

	function getTooltip()
	{
		return [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description", text = this.getDescription() },
			{ id = 10, type = "text", icon = "ui/icons/special.png", text = "下次换槽或卸功：[color=" + ::Const.UI.Color.PositiveValue + "]0 日散功调息[/color]（免除虚弱与换功内伤）" }
		];
	}
});
