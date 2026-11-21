this.wx_beast_armor_med <- this.inherit("scripts/items/armor/mail_hauberk", {
	m = {},

	function create()
	{
		this.mail_hauberk.create();
		::Wuxia.BeastCraft.applyBeastArmorOrHelmet(this, "wx_beast_armor_med", false);
	}

	function onDeserialize( _in )
	{
		this.mail_hauberk.onDeserialize(_in);
		::Wuxia.BeastCraft.applyBeastArmorOrHelmet(this, "wx_beast_armor_med", true);
	}
});
