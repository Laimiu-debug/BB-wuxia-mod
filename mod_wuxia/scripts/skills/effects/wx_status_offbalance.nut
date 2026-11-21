// Combat Status: 失衡 (MeleeDefense -10, Initiative -15, 1 turn)

this.wx_status_offbalance <- this.inherit("scripts/skills/skill", {
	m = {
		TurnsLeft = 1
	},

	function create()
	{
		this.m.ID = "effects.wx_status_offbalance";
		this.m.Name = "失衡";
		this.m.Description = "脚下重心被扰动，招架 -10，身法 -15。";
		this.m.Icon = "skills/wx_status_offbalance.png";
		this.m.IconMini = "status_effect_87_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
	}

	function resetDuration( _turns = 1 )
	{
		this.m.TurnsLeft = ::Math.max(this.m.TurnsLeft, _turns);
	}

	function onUpdate( _properties )
	{
		_properties.MeleeDefense -= 10;
		_properties.Initiative -= 15;
	}

	function onTurnEnd()
	{
		this.m.TurnsLeft -= 1;
		if (this.m.TurnsLeft <= 0) this.removeSelf();
	}
});
