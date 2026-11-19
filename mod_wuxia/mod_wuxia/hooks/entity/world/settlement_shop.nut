// Hook town marketplace building to stock common Wuxia manuals & healing/exp pills on restock

::Wuxia.HooksMod.hook("scripts/entity/world/settlements/buildings/marketplace_building", function( q )
{
	q.onUpdateShopList = @(__original) function( _id = null )
	{
		if (_id != null)
			__original(_id);
		else
			__original();

		if ("m" in this && "Stash" in this.m && this.m.Stash != null)
		{
			::Wuxia.Loot.injectTownShopStock(this.m.Stash);
		}
	};
});
