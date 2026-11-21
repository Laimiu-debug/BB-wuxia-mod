// Shan Hai Mythical Named Helmet: 山海·汤谷金乌大日火羽冠
this.wx_helm_jinwu <- this.inherit("scripts/items/helmets/named/lindwurm_helmet", {
	m = {},
	function create()
	{
		this.lindwurm_helmet.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_helm_jinwu", false);
	}
	function onDeserialize( _in )
	{
		this.lindwurm_helmet.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_helm_jinwu", true);
	}
});
