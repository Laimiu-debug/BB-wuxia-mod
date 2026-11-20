// Shan Hai Mythical Named Gear: 山海·句芒建木生机甲

this.wx_armor_jumang <- this.inherit("scripts/items/armor/named/green_coat_of_plates_armor", {
	m = {},

	function create()
	{
		this.green_coat_of_plates_armor.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_jumang", false);
	}

	function onDeserialize( _in )
	{
		this.green_coat_of_plates_armor.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_jumang", true);
	}
});
