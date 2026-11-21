this.wx_beast_shield <- this.inherit("scripts/items/shields/heater_shield", {
	m = {},

	function create()
	{
		this.heater_shield.create();
		::Wuxia.BeastCraft.applyBeastShield(this, "wx_beast_shield", false);
	}

	function onDeserialize( _in )
	{
		this.heater_shield.onDeserialize(_in);
		::Wuxia.BeastCraft.applyBeastShield(this, "wx_beast_shield", true);
	}
});
