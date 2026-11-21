this.wx_beast_bow <- this.inherit("scripts/items/weapons/short_bow", {
	m = {},

	function create()
	{
		this.short_bow.create();
		::Wuxia.BeastCraft.applyBeastWeapon(this, "wx_beast_bow", false);
	}

	function onDeserialize( _in )
	{
		this.short_bow.onDeserialize(_in);
		::Wuxia.BeastCraft.applyBeastWeapon(this, "wx_beast_bow", true);
	}
});
