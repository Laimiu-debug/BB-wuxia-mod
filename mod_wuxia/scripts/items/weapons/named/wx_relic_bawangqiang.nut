// Historical Famous Rare Weapon: 传世·乌金霸王破阵枪 (Spear)

this.wx_relic_bawangqiang <- this.inherit("scripts/items/weapons/named/named_pike", {
	m = {},

	function create()
	{
		this.named_pike.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_bawangqiang");
	}

	function onDeserialize( _in )
	{
		this.named_pike.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_bawangqiang");
	}
});
