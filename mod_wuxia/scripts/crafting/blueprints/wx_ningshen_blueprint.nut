// Alchemy Blueprint: 2x 凝神丸 crafted from 食腐山魈脑髓 + 五毒岩蛛韧丝

this.wx_ningshen_blueprint <- this.inherit("scripts/crafting/blueprint", {
	function makePreview()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_ningshen");
		return pill;
	}

	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_ningshen_batch";
		this.m.PreviewCraftable = this.makePreview();
		this.m.Cost = 280;
		this.init([
			{ Script = "scripts/items/misc/ghoul_brain_item", Num = 1 },
			{ Script = "scripts/items/misc/spider_silk_item", Num = 1 }
		]);
	}

	function onCraft( _stash )
	{
		for (local i = 0; i < 2; i = ++i)
		{
			local pill = ::new("scripts/items/misc/wx_pill_item");
			pill.initPill("wx_pill_ningshen");
			_stash.add(pill);
		}
	}
});
