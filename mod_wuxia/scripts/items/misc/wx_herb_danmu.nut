this.wx_herb_danmu <- this.inherit("scripts/items/misc/wx_herb_base", {
	function create()
	{
		this.wx_herb_base.create();
		this.initHerb("wx_herb_danmu");
	}
});
