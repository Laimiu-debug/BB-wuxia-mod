this.wx_beast_sword <- this.inherit("scripts/items/weapons/arming_sword", {
	m = {},

	function create()
	{
		this.arming_sword.create();
		::Wuxia.BeastCraft.applyBeastWeapon(this, "wx_beast_sword", false);
	}

	function onDeserialize( _in )
	{
		this.arming_sword.onDeserialize(_in);
		::Wuxia.BeastCraft.applyBeastWeapon(this, "wx_beast_sword", true);
	}
});
