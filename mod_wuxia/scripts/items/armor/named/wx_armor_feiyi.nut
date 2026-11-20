// Shan Hai Mythical Named Gear: 山海·太华肥遗逆鳞甲

this.wx_armor_feiyi <- this.inherit("scripts/items/armor/named/lindwurm_armor", {
	m = {},

	function create()
	{
		this.lindwurm_armor.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_feiyi", false);
	}

	function onDeserialize( _in )
	{
		this.lindwurm_armor.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_armor_feiyi", true);
	}
});
