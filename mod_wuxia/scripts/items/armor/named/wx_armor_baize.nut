// Shan Hai Mythical Named Armor: 山海·东望白泽通玄雪裘甲
this.wx_armor_baize <- this.inherit("scripts/items/armor/named/leopard_armor", {
	m = {},
	function create()
	{
		this.leopard_armor.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_baize", false);
	}
	function onDeserialize( _in )
	{
		this.leopard_armor.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_baize", true);
	}
});
