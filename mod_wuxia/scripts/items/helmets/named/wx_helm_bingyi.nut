// Shan Hai Mythical Named Helmet: 山海·从极冰夷御龙寒玉冠
this.wx_helm_bingyi <- this.inherit("scripts/items/helmets/named/lindwurm_helmet", {
	m = {},
	function create()
	{
		this.lindwurm_helmet.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_helm_bingyi", false);
	}
	function onDeserialize( _in )
	{
		this.lindwurm_helmet.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_helm_bingyi", true);
	}
});
