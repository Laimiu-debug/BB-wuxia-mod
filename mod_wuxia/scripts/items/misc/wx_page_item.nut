// Generic Martial Page / Fragment Item (stackable; craft into full manual or risky fragment-learn)

this.wx_page_item <- this.inherit("scripts/items/item", {
	m = {
		ManualID  = "wx_manual_songtao",
		PageCount = 1
	},

	function create()
	{
		this.item.create();
		this.m.ID = "misc.wx_page_item";
		this.m.Name = "武学残页";
		this.m.Description = "散落的武学残页。集齐所需张数可在「武学修为」页拼合为完整秘籍，或冒险拖拽进行残本强修（限一重且有走火入魔风险）。";
		this.m.Icon = "misc/inventory_anatomists_book_02.png";
		this.m.SlotType = this.Const.ItemSlot.None;
		this.m.ItemType = this.Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsUsable = false;
		this.m.Value = 250;
	}

	function initPages( _manualID, _count = 1 )
	{
		this.m.ManualID = _manualID;
		this.m.PageCount = ::Math.max(1, _count);
		this.refreshFromConfig();
	}

	function getManualID()
	{
		return this.m.ManualID;
	}

	function getPageCount()
	{
		return this.m.PageCount;
	}

	function addPageCount( _delta )
	{
		this.m.PageCount = ::Math.max(0, this.m.PageCount + _delta);
		this.refreshFromConfig();
	}

	function refreshFromConfig()
	{
		local def = ::Wuxia.Slots.getManualDef(this.m.ManualID);
		if (def == null) return;
		local req = ::Math.max(1, def.FragmentsNeeded);
		this.m.Name = "《" + def.Name + "》残页 (" + this.m.PageCount + "/" + req + ")";
		this.m.Value = ::Math.max(100, ::Math.floor(def.BasePrice / req) * this.m.PageCount);
	}

	function onSerialize( _out )
	{
		this.item.onSerialize(_out);
		_out.writeString(this.m.ManualID);
		_out.writeU16(this.m.PageCount);
	}

	function onDeserialize( _in )
	{
		this.item.onDeserialize(_in);
		this.m.ManualID = _in.readString();
		this.m.PageCount = _in.readU16();
		this.refreshFromConfig();
	}
});
