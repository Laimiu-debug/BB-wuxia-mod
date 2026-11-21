// Shan Hai Mythical Named Helmet: 山海·昆仑开明九首虎冕
this.wx_helm_kaiming <- this.inherit("scripts/items/helmets/named/named_metal_bull_helmet", {
	m = {},
	function create()
	{
		this.named_metal_bull_helmet.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_helm_kaiming", false);
	}
	function onDeserialize( _in )
	{
		this.named_metal_bull_helmet.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_helm_kaiming", true);
	}
});
