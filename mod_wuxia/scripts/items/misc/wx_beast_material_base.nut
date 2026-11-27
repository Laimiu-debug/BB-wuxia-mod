// Base Item for Shan Hai & Wild Beast Forging Materials (`misc.wx_mat_*`)

this.wx_beast_material_base <- this.inherit("scripts/items/item", {
	m = {
		MatID = "wx_mat_shagu"
	},

	function create()
	{
		this.item.create();
		local ref = ::new("scripts/items/misc/unhold_bones_item");
		this.m.Icon = ref.m.Icon;
		this.m.SlotType = this.Const.ItemSlot.None;
		this.m.ItemType = this.Const.Items.ItemType.Misc | this.Const.Items.ItemType.Crafting;
		this.m.IsDroppedAsLoot = true;
		this.m.Value = 450;
	}

	function initMaterial( _matID )
	{
		this.m.MatID = _matID;
		this.m.ID = "misc." + _matID;
		if ("BeastMaterials" in ::Wuxia.Config && (_matID in ::Wuxia.Config.BeastMaterials))
		{
			local cfg = ::Wuxia.Config.BeastMaterials[_matID];
			this.m.Name = cfg.Name;
			this.m.Description = cfg.Description;
			this.m.Value = cfg.Value;
			this.m.Icon = cfg.Icon;
		}
	}

	function getTooltip()
	{
		local ret = this.item.getTooltip();
		local natStr = "";
		local fullId = "misc." + this.m.MatID;
		if ("Alchemy" in ::Wuxia.Config && "KnownMaterials" in ::Wuxia.Config.Alchemy && (fullId in ::Wuxia.Config.Alchemy.KnownMaterials))
		{
			local km = ::Wuxia.Config.Alchemy.KnownMaterials[fullId];
			local nName = ("Natures" in ::Wuxia.Config.Alchemy && km.Nature in ::Wuxia.Config.Alchemy.Natures)
				? ::Wuxia.Config.Alchemy.Natures[km.Nature].Name
				: km.Nature;
			local nCol = ("UI" in ::Wuxia && "getNatureTooltipColor" in ::Wuxia.UI) ? ::Wuxia.UI.getNatureTooltipColor(km.Nature) : "#094039";
			natStr = " · 炼丹药性：[color=" + nCol + "][b]" + nName + "（药力 " + km.Potency + "）[/b][/color]";
		}
		ret.push({
			id = 15,
			type = "text",
			icon = "ui/icons/asset_supplies.png",
			text = "[color=#094039][b]【百工奇材 · 重锻辅料】[/b][/color]可用于城镇「百工丹坊」锻造百工奇物、镶缀甲片或「神兵重锻」免内丹淬洗词条" + natStr
		});
		return ret;
	}
});
