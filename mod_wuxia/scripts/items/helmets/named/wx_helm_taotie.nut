// Shan Hai Mythical Named Gear: 山海·饕餮吞天兽面胄

this.wx_helm_taotie <- this.inherit("scripts/items/helmets/named/named_metal_bull_helmet", {
	m = {},

	function create()
	{
		this.named_metal_bull_helmet.create();
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_helm_taotie", false);
	}

	function onDeserialize( _in )
	{
		this.named_metal_bull_helmet.onDeserialize(_in);
		::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "wx_helm_taotie", true);
	}
});
