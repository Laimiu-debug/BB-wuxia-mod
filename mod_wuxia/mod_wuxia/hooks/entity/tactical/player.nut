// Hook scripts/entity/tactical/player: ensure martial container exists & disable vanilla perk points

::Wuxia.HooksMod.hook("scripts/entity/tactical/player", function( q )
{
	q.setStartValuesEx = @(__original) function( _backgrounds, _addTraits = true )
	{
		__original(_backgrounds, _addTraits);
		// Adding a skill triggers an attribute update. Wait until the actor is initialized.
		::Wuxia.Slots.getContainer(this);
	};

	q.onDeserialize = @(__original) function( _in )
	{
		__original(_in);
		// The saved skill reads its data before the game binds it to the actor.
		::Wuxia.Slots.getContainer(this).syncGrantedSkills();
		this.m.PerkPoints = 0;
	};

	q.updateLevel = @(__original) function()
	{
		__original();
		// Perk tree is completely replaced by 1/3/5/7/9/11 martial slots
		this.m.PerkPoints = 0;
	};
});
