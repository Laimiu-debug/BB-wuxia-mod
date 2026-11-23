// Ephemeral non-lethal player clone for Wuxia Martial Arts Tournament (`武林大会 / 群英演武擂`).
// Knockouts on the tournament stage never award campaign XP, kill stats, or permanent casualties.

this.wx_tournament_player <- this.inherit("scripts/entity/tactical/player", {
	m = {},

	function onActorKilled( _actor, _tile, _skill )
	{
		this.actor.onActorKilled(_actor, _tile, _skill);
	}

	function addXP( _xp, _scale = true )
	{
	}

	function onBeforeCombatResult()
	{
	}

	function updateAchievement( _id, _progress, _maximum )
	{
	}

	function onSerialize( _out )
	{
		if (::Wuxia.hasMember(this.m, "Talents") && this.m.Talents.len() < ::Const.Attributes.COUNT)
		{
			local tArr = [];
			tArr.resize(::Const.Attributes.COUNT, 0);
			this.m.Talents = tArr;
		}
		if (::Wuxia.hasMember(this.m, "Attributes") && this.m.Attributes.len() < ::Const.Attributes.COUNT)
		{
			local aArr = [];
			for (local ai = 0; ai < ::Const.Attributes.COUNT; ai = ++ai)
				aArr.push([2, 2, 2, 2, 2, 2, 2, 2, 2, 2]);
			this.m.Attributes = aArr;
		}
		this.player.onSerialize(_out);
	}
});
