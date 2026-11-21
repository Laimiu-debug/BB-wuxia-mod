// Shan Hai Divine Red Weapon: 传世·应龙斩魔蓄水剑 (Sword)
this.wx_relic_yinglongjian <- this.inherit("scripts/items/weapons/named/named_sword", {
	m = {},
	function create()
	{
		this.named_sword.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_yinglongjian");
	}
	function onDeserialize( _in )
	{
		this.named_sword.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_yinglongjian");
	}
});
