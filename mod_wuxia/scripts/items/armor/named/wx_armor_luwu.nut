// Shan Hai Mythical Named Armor: 山海·昆仑陆吾九部虎贲甲
this.wx_armor_luwu <- this.inherit("scripts/items/armor/named/named_plated_fur_armor", {
	m = {},
	function create()
	{
		this.named_plated_fur_armor.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_luwu", false);
	}
	function onDeserialize( _in )
	{
		this.named_plated_fur_armor.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_luwu", true);
	}
});
