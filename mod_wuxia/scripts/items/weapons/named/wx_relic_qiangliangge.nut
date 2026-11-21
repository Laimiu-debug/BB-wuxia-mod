// Shan Hai Divine Red Weapon: 传世·北山强良虎首衔蛇戈 (Polearm)
this.wx_relic_qiangliangge <- this.inherit("scripts/items/weapons/named/named_billhook", {
	m = {},
	function create()
	{
		this.named_billhook.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_qiangliangge");
	}
	function onDeserialize( _in )
	{
		this.named_billhook.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_qiangliangge");
	}
});
