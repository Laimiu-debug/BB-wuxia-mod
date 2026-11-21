// Shan Hai Mythical Named Armor: 山海·杻阳玄龟镇海重铠
this.wx_armor_xuangui <- this.inherit("scripts/items/armor/named/green_coat_of_plates_armor", {
	m = {},
	function create()
	{
		this.green_coat_of_plates_armor.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_xuangui", false);
	}
	function onDeserialize( _in )
	{
		this.green_coat_of_plates_armor.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_xuangui", true);
	}
});
