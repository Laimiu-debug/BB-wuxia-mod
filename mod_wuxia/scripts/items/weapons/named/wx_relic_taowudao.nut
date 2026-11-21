// Shan Hai Divine Red Weapon: 传世·荒中檮杌傲狠断岳刀 (Cleaver)
this.wx_relic_taowudao <- this.inherit("scripts/items/weapons/named/named_crypt_cleaver", {
	m = {},
	function create()
	{
		this.named_crypt_cleaver.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_taowudao");
	}
	function onDeserialize( _in )
	{
		this.named_crypt_cleaver.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_taowudao");
	}
});
