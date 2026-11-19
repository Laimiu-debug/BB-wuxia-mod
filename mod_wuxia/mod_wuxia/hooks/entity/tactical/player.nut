// Hook scripts/entity/tactical/player: ensure martial container exists & disable vanilla perk points

::Wuxia.HooksMod.hook("scripts/entity/tactical/player", function( q )
{
	q.create = @(__original) function()
	{
		__original();
		::Wuxia.Slots.getContainer(this);
	};

	q.onDeserialize = @(__original) function( _in )
	{
		__original(_in);
		::Wuxia.Slots.getContainer(this);
		this.m.PerkPoints = 0;
	};

	q.updateLevel = @(__original) function()
	{
		__original();
		// Perk tree is completely replaced by 1/3/5/7/9/11 martial slots
		this.m.PerkPoints = 0;
	};
});
