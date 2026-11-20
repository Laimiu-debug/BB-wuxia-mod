this.wx_marrow_herb <- this.inherit("scripts/items/item", {
	function create()
	{
		this.item.create();
		this.m.ID = "misc.wx_marrow_herb";
		this.m.Name = "洗髓血芝";
		this.m.Description = "血煞总寨珍藏的药引。在剥制师处配上巨魔之心与林德虫骨，可炼出一枚洗髓丹。";
		this.m.Icon = "misc/inventory_unhold_01.png";
		this.m.SlotType = this.Const.ItemSlot.None;
		this.m.ItemType = this.Const.Items.ItemType.Misc | this.Const.Items.ItemType.Crafting;
		this.m.IsDroppedAsLoot = true;
		this.m.Value = 1400;
	}
});
