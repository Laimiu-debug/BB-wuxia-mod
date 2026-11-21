this.wx_marrow_herb <- this.inherit("scripts/items/misc/wx_herb_base", {
	function create()
	{
		this.wx_herb_base.create();
		this.initHerb("wx_marrow_herb");
		this.m.ID = "misc.wx_marrow_herb";
		this.m.Name = "洗髓血芝";
	}
});
