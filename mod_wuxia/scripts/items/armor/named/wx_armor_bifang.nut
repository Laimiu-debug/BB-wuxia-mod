// Shan Hai Mythical Named Armor: 山海·章莪毕方讹火赤翎衣
this.wx_armor_bifang <- this.inherit("scripts/items/armor/named/leopard_armor", {
	m = {},
	function create()
	{
		this.leopard_armor.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_bifang", false);
	}
	function onDeserialize( _in )
	{
		this.leopard_armor.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_bifang", true);
	}
});
