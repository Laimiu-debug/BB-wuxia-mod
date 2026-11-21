// Shan Hai Mythical Named Armor: 山海·流波夔牛紫电革铠
this.wx_armor_kui <- this.inherit("scripts/items/armor/named/lindwurm_armor", {
	m = {},
	function create()
	{
		this.lindwurm_armor.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_kui", false);
	}
	function onDeserialize( _in )
	{
		this.lindwurm_armor.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_kui", true);
	}
});
