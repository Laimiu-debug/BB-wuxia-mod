// Shan Hai Mythical Named Helmet: 山海·蚩尤铜头铁额魔鍪
this.wx_helm_chiyou <- this.inherit("scripts/items/helmets/named/named_metal_bull_helmet", {
	m = {},
	function create()
	{
		this.named_metal_bull_helmet.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_helm_chiyou", false);
	}
	function onDeserialize( _in )
	{
		this.named_metal_bull_helmet.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_helm_chiyou", true);
	}
});
