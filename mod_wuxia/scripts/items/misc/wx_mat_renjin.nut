this.wx_mat_renjin <- this.inherit("scripts/items/misc/wx_beast_material_base", {
	m = {},
	function create()
	{
		this.wx_beast_material_base.create();
		this.initMaterial("wx_mat_renjin");
	}
});
