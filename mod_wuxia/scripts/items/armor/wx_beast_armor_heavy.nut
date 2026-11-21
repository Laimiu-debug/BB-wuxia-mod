this.wx_beast_armor_heavy <- this.inherit("scripts/items/armor/mail_hauberk", {
	m = {},

	function create()
	{
		this.mail_hauberk.create();
		::Wuxia.BeastCraft.applyBeastArmorOrHelmet(this, "wx_beast_armor_heavy", false);
	}

	function onDeserialize( _in )
	{
		this.mail_hauberk.onDeserialize(_in);
		::Wuxia.BeastCraft.applyBeastArmorOrHelmet(this, "wx_beast_armor_heavy", true);
	}
});
