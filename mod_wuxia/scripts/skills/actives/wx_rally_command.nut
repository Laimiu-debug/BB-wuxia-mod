// Unbinds Rally the Troops from the 2H Battle Standard weapon so any high-Resolve commander can steady morale.

this.wx_rally_command <- this.inherit("scripts/skills/actives/rally_the_troops", {
	m = {},

	function create()
	{
		this.rally_the_troops.create();
		this.m.ID = "actives.wx_rally_command";
		this.m.Name = "聚义号令";
		this.m.Description = "振臂高呼稳固军心：无需手持双手战旗，消耗 5 AP 与 25 内息，令 4 格内动摇、崩溃或溃逃的同伴重整战意（每回合限用一次）。";
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 25;
	}

	function getFatigueCost()
	{
		return this.skill.getFatigueCost();
	}

	function onUse( _user, _targetTile )
	{
		local c = _user.getSkills().getSkillByID("special.wx_martial_container");
		local bonus = (c != null && c.m.CachedAggFlags != null) ? c.m.CachedAggFlags.RallyBonus : 0;
		if (bonus <= 0)
			return this.rally_the_troops.onUse(_user, _targetTile);

		// Vanilla rally_the_troops scales difficulty by floor(Bravery * 0.4); +2.5 Bravery per +1 bonus gives exact +10/+20 roll.
		local extraBravery = ::Math.floor(bonus * 2.5);
		_user.m.CurrentProperties.Bravery += extraBravery;
		local ok = false;
		try
		{
			ok = this.rally_the_troops.onUse(_user, _targetTile);
		}
		catch (err)
		{
			_user.m.CurrentProperties.Bravery -= extraBravery;
			throw err;
		}
		_user.m.CurrentProperties.Bravery -= extraBravery;
		return ok;
	}
});
