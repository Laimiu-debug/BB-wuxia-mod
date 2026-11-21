this.wx_beast_saber <- this.inherit("scripts/items/weapons/military_cleaver", {
	m = {},

	function create()
	{
		this.military_cleaver.create();
		::Wuxia.BeastCraft.applyBeastWeapon(this, "wx_beast_saber", false);
	}

	function onDeserialize( _in )
	{
		this.military_cleaver.onDeserialize(_in);
		::Wuxia.BeastCraft.applyBeastWeapon(this, "wx_beast_saber", true);
	}
});
