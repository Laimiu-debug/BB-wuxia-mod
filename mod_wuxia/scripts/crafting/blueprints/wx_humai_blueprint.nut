// Alchemy Blueprint: 护脉丹 + 护心丹 crafted from 雪山白猿厚皮 + 五毒异兽毒囊

this.wx_humai_blueprint <- this.inherit("scripts/crafting/blueprint", {
	function makePreview()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_humai");
		return pill;
	}

	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_humai_craft";
		this.m.PreviewCraftable = this.makePreview();
		this.m.Cost = 450;
		this.init([
			{ Script = "scripts/items/misc/unhold_hide_item", Num = 1 },
			{ Script = "scripts/items/misc/poison_gland_item", Num = 1 }
		]);
	}

	function onCraft( _stash )
	{
		local humai = ::new("scripts/items/misc/wx_pill_item");
		humai.initPill("wx_pill_humai");
		_stash.add(humai);

		local huxin = ::new("scripts/items/misc/wx_pill_item");
		huxin.initPill("wx_pill_huxin");
		_stash.add(huxin);
	}
});
