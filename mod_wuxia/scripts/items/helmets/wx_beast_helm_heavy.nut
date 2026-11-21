this.wx_beast_helm_heavy <- this.inherit("scripts/items/helmets/kettle_hat", {
	m = {},

	function create()
	{
		this.kettle_hat.create();
		::Wuxia.BeastCraft.applyBeastArmorOrHelmet(this, "wx_beast_helm_heavy", false);
	}

	function onDeserialize( _in )
	{
		this.kettle_hat.onDeserialize(_in);
		::Wuxia.BeastCraft.applyBeastArmorOrHelmet(this, "wx_beast_helm_heavy", true);
	}
});
