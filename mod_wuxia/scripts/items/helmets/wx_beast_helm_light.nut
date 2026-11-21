this.wx_beast_helm_light <- this.inherit("scripts/items/helmets/hunters_hat", {
	m = {},

	function create()
	{
		this.hunters_hat.create();
		::Wuxia.BeastCraft.applyBeastArmorOrHelmet(this, "wx_beast_helm_light", false);
	}

	function onDeserialize( _in )
	{
		this.hunters_hat.onDeserialize(_in);
		::Wuxia.BeastCraft.applyBeastArmorOrHelmet(this, "wx_beast_helm_light", true);
	}
});
