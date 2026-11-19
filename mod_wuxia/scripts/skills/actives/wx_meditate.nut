// Active Skill: 调息 (Small Meditate - 4 AP, restores 25% spent Qi)

this.wx_meditate <- this.inherit("scripts/skills/skill", {
	m = {},

	function create()
	{
		this.m.ID = "actives.wx_meditate";
		this.m.Name = "调息吐纳";
		this.m.Description = "沉心吐纳、引气归元：消耗 4 点行动点，立即恢复已损耗内息的 25%（至少 12 点）。";
		this.m.Icon = "skills/active_103.png";
		this.m.IconDisabled = "skills/active_103_sw.png";
		this.m.Overlay = "active_103";
		this.m.SoundOnUse = [
			"sounds/combat/recover_01.wav"
		];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsStacking = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 0;
		this.m.MinRange = 0;
		this.m.MaxRange = 0;
	}

	function getTooltip()
	{
		return [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description", text = this.getDescription() },
			{ id = 3, type = "text", text = this.getCostString() }
		];
	}

	function isUsable()
	{
		return this.skill.isUsable() && this.getContainer().getActor().getFatigue() > 0;
	}

	function onUse( _user, _targetTile )
	{
		local spent = _user.getFatigue();
		local recover = ::Math.max(12, ::Math.floor(spent * 0.25));
		::Wuxia.CombatRules.restoreQi(_user, recover);
		this.Tactical.EventLog.log(::Const.UI.getColorizedEntityName(_user) + " 调息吐纳，恢复了 " + recover + " 点内息。");
		return true;
	}
});
