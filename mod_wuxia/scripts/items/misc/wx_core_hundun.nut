this.wx_core_hundun <- this.inherit("scripts/items/misc/wx_shanhai_core_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_core_base.create();
		this.initCore("wx_core_hundun");
	}
});
