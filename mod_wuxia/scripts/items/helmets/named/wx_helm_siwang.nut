// Shan Hai Mythical Named Helmet: 山海·苍梧青兕独角重兜
this.wx_helm_siwang <- this.inherit("scripts/items/helmets/named/named_metal_bull_helmet", {
	m = {},
	function create()
	{
		this.named_metal_bull_helmet.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_helm_siwang", false);
	}
	function onDeserialize( _in )
	{
		this.named_metal_bull_helmet.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_helm_siwang", true);
	}
});
