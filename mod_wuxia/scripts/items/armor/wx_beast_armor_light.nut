this.wx_beast_armor_light <- this.inherit("scripts/items/armor/mail_shirt", {
	m = {},

	function create()
	{
		this.mail_shirt.create();
		::Wuxia.BeastCraft.applyBeastArmorOrHelmet(this, "wx_beast_armor_light", false);
	}

	function onDeserialize( _in )
	{
		this.mail_shirt.onDeserialize(_in);
		::Wuxia.BeastCraft.applyBeastArmorOrHelmet(this, "wx_beast_armor_light", true);
	}
});
