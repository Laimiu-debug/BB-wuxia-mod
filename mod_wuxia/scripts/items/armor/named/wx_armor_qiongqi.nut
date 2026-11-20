// Shan Hai Mythical Named Gear: 山海·穷奇逐风翼皮甲

this.wx_armor_qiongqi <- this.inherit("scripts/items/armor/named/leopard_armor", {
	m = {},

	function create()
	{
		this.leopard_armor.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_qiongqi", false);
	}

	function onDeserialize( _in )
	{
		this.leopard_armor.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_qiongqi", true);
	}
});
