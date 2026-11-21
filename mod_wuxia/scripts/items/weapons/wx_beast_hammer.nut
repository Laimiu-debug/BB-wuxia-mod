this.wx_beast_hammer <- this.inherit("scripts/items/weapons/two_handed_hammer", {
	m = {},

	function create()
	{
		this.two_handed_hammer.create();
		::Wuxia.BeastCraft.applyBeastWeapon(this, "wx_beast_hammer", false);
	}

	function onDeserialize( _in )
	{
		this.two_handed_hammer.onDeserialize(_in);
		::Wuxia.BeastCraft.applyBeastWeapon(this, "wx_beast_hammer", true);
	}
});
