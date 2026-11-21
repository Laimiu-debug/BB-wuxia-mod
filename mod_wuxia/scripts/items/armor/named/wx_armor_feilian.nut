// Shan Hai Mythical Named Armor: 山海·鹿台飞廉御风羽衣
this.wx_armor_feilian <- this.inherit("scripts/items/armor/named/leopard_armor", {
	m = {},
	function create()
	{
		this.leopard_armor.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_feilian", false);
	}
	function onDeserialize( _in )
	{
		this.leopard_armor.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_feilian", true);
	}
});
