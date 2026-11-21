// Town Alchemy Blueprint: 黑玉断续膏 (Cures 1 vanilla Permanent Injury)

this.wx_bp_pill_duanxu <- this.inherit("scripts/crafting/blueprint", {
	function makePill()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_duanxu");
		return pill;
	}

	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_duanxu";
		this.m.PreviewCraftable = this.makePill();
		this.m.Cost = 1300;
		this.init([
			{ Script = "scripts/items/misc/lindwurm_blood_item", Num = 1 },
			{ Script = "scripts/items/misc/unhold_bones_item", Num = 1 },
			{ Script = "scripts/items/misc/poison_gland_item", Num = 1 }
		]);
	}

	function onCraft( _stash )
	{
		_stash.add(this.makePill());
	}
});
