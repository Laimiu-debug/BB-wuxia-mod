this.wx_core_feifei <- this.inherit("scripts/items/misc/wx_shanhai_core_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_core_base.create();
		this.initCore("wx_core_feifei");
	}
});
