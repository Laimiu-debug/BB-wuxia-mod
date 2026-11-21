// Hook town settlement shop refresh to safely stock common Wuxia manuals & healing/exp pills
// NOTE: marketplace_building.onUpdateShopList() returns a list array; hooking settlement.updateShop() AFTER
// __original(_force) guarantees the marketplace Stash is already filled without altering onUpdateShopList's return value!

::Wuxia.HooksMod.hook("scripts/entity/world/settlement", function( q )
{
	q.updateShop = @(__original) function( _force = false )
	{
		__original(_force);

		if (::Wuxia.hasMember(this.m, "Buildings") && this.m.Buildings != null)
		{
			foreach (b in this.m.Buildings)
			{
				if (b == null || !(::Wuxia.hasMember(b.m, "Stash")) || b.m.Stash == null) continue;
				if (b.getID() == "building.marketplace")
				{
					::Wuxia.Loot.injectTownShopStock(b.m.Stash);
				}
				else if (b.getID() == "building.weaponsmith")
				{
					::Wuxia.Loot.injectWeaponsmithStock(b.m.Stash);
				}
			}
		}
	};
});
