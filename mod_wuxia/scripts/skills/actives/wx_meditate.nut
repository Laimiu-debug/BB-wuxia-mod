// Active Skill: 调息 (Small Meditate - 4 AP, restores 25% spent Qi)

this.wx_meditate <- this.inherit("scripts/skills/skill", {
	m = { GuardLowered = false, UsedThisTurn = false },

	function create()
	{
		this.m.ID = "actives.wx_meditate";
		this.m.Name = "调息吐纳";
		this.m.Description = "花 4 AP 恢复已耗内息的 25%（至少回 12 点，每回合限用一次）。放松守势使招架 -3，持续到下次行动。深调息可用 9 AP 恢复已耗内息的一半。";
		this.m.Icon = "ui/perks/perk_54_active.png";
		this.m.IconDisabled = "ui/perks/perk_54_active_sw.png";
		this.m.Overlay = "active_103";
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
		return !this.m.UsedThisTurn && this.skill.isUsable() && this.getContainer().getActor().getFatigue() > 0;
	}

	function onUpdate( _properties ) { if (this.m.GuardLowered) _properties.MeleeDefense -= 3; }
	function onTurnStart() { this.m.GuardLowered = false; this.m.UsedThisTurn = false; }
	function onCombatStarted() { this.m.GuardLowered = false; this.m.UsedThisTurn = false; }
	function onCombatFinished() { this.m.GuardLowered = false; this.m.UsedThisTurn = false; }

	function onUse( _user, _targetTile )
	{
		local spent = _user.getFatigue();
		local recover = ::Math.min(spent, ::Math.max(12, ::Math.floor(spent * 0.25)));
		this.m.GuardLowered = true;
		this.m.UsedThisTurn = true;
		::Wuxia.CombatRules.restoreQi(_user, recover);
		this.getContainer().update();
		this.Tactical.EventLog.log(::Const.UI.getColorizedEntityName(_user) + " 调息吐纳，恢复了 " + recover + " 点内息。");
		return true;
	}
});
