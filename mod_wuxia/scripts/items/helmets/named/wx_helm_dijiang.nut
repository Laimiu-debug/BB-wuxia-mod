// Shan Hai Mythical Named Helmet: 山海·天山帝江幻空丹面
this.wx_helm_dijiang <- this.inherit("scripts/items/helmets/named/lindwurm_helmet", {
	m = {},
	function create()
	{
		this.lindwurm_helmet.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_helm_dijiang", false);
	}
	function onDeserialize( _in )
	{
		this.lindwurm_helmet.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_helm_dijiang", true);
	}
});
