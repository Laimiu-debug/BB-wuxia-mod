// Shan Hai Mythical Named Gear: 山海·朱厌白首狂血铠

this.wx_armor_zhuyan <- this.inherit("scripts/items/armor/named/named_plated_fur_armor", {
	m = {},

	function create()
	{
		this.named_plated_fur_armor.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_zhuyan", false);
	}

	function onDeserialize( _in )
	{
		this.named_plated_fur_armor.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_zhuyan", true);
	}
});
