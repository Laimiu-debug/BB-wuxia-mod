// Shan Hai Mythical Named Armor: 山海·钟山烛阴寒暑龙鳞袍
this.wx_armor_zhuyin <- this.inherit("scripts/items/armor/named/lindwurm_armor", {
	m = {},
	function create()
	{
		this.lindwurm_armor.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_zhuyin", false);
	}
	function onDeserialize( _in )
	{
		this.lindwurm_armor.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_zhuyin", true);
	}
});
