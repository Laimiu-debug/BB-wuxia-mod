this.wx_beast_spear <- this.inherit("scripts/items/weapons/fighting_spear", {
	m = {},

	function create()
	{
		this.fighting_spear.create();
		::Wuxia.BeastCraft.applyBeastWeapon(this, "wx_beast_spear", false);
	}

	function onDeserialize( _in )
	{
		this.fighting_spear.onDeserialize(_in);
		::Wuxia.BeastCraft.applyBeastWeapon(this, "wx_beast_spear", true);
	}
});
