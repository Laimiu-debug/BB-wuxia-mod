// Shan Hai Mythical Named Armor: 山海·凶黎蚩尤铜头战铠
this.wx_armor_chiyou <- this.inherit("scripts/items/armor/named/green_coat_of_plates_armor", {
	m = {},
	function create()
	{
		this.green_coat_of_plates_armor.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_chiyou", false);
	}
	function onDeserialize( _in )
	{
		this.green_coat_of_plates_armor.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_chiyou", true);
	}
});
