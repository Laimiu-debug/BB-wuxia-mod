this.wx_pmat_baize_tong <- this.inherit("scripts/items/misc/wx_beast_material_base", {
	m = {},
	function create()
	{
		this.wx_beast_material_base.create();
		this.initMaterial("wx_pmat_baize_tong");
	}
});
