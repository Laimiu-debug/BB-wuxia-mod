// Shan Hai Mythical Named Armor: 山海·共工相柳九首毒鳞甲
this.wx_armor_xiangliu <- this.inherit("scripts/items/armor/named/lindwurm_armor", {
	m = {},
	function create()
	{
		this.lindwurm_armor.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_xiangliu", false);
	}
	function onDeserialize( _in )
	{
		this.lindwurm_armor.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_xiangliu", true);
	}
});
