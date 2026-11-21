this.wx_beast_fist <- this.inherit("scripts/items/weapons/wx_fist_base", {
	m = {},

	function create()
	{
		this.wx_fist_base.create();
		this.wxInitPlaceholderVisual("bludgeon");
		::Wuxia.BeastCraft.applyBeastWeapon(this, "wx_beast_fist", false);
	}

	function onDeserialize( _in )
	{
		this.wx_fist_base.onDeserialize(_in);
		::Wuxia.BeastCraft.applyBeastWeapon(this, "wx_beast_fist", true);
	}
});
