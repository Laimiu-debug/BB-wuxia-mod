// Shan Hai Mythical Named Gear: 山海·苍梧巴蛇碧鳞冠

this.wx_helm_bashe <- this.inherit("scripts/items/helmets/named/lindwurm_helmet", {
	m = {},

	function create()
	{
		this.lindwurm_helmet.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_helm_bashe", false);
	}

	function onDeserialize( _in )
	{
		this.lindwurm_helmet.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_helm_bashe", true);
	}
});
