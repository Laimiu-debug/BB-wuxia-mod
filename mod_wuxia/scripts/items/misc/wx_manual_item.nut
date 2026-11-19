// Generic Martial Manual Item (data-driven from ::Wuxia.Config.Manuals)

this.wx_manual_item <- this.inherit("scripts/items/item", {
	m = {
		ManualID = "wx_manual_tuna"
	},

	function create()
	{
		this.item.create();
		this.m.ID = "misc.wx_manual_item";
		this.m.Name = "武学秘籍";
		this.m.Description = "可在角色界面「武学修为」页直接拖拽至对应插槽修习（消耗品）。";
		this.m.Icon = "misc/inventory_scroll_01.png";
		this.m.SlotType = this.Const.ItemSlot.None;
		this.m.ItemType = this.Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsUsable = false; // Equipped via drag-and-drop in Wuxia tab
		this.m.Value = 300;
	}

	function initManual( _manualID )
	{
		this.m.ManualID = _manualID;
		this.refreshFromConfig();
	}

	function getManualID()
	{
		return this.m.ManualID;
	}

	function refreshFromConfig()
	{
		local def = ::Wuxia.Slots.getManualDef(this.m.ManualID);
		if (def == null) return;

		local qName = (def.Quality in ::Wuxia.Text.Qualities) ? ::Wuxia.Text.Qualities[def.Quality] : def.Quality;
		local cName = (def.Category in ::Wuxia.Text.Categories) ? ::Wuxia.Text.Categories[def.Category] : def.Category;
		this.m.Name = "《" + def.Name + "》";
		this.m.Description = "【" + qName + " · " + cName + "】" + def.Description + "（在「武学修为」页拖拽装入插槽，装入后消耗）。";
		this.m.Value = def.BasePrice;
	}

	function getTooltip()
	{
		local ret = this.item.getTooltip();
		local def = ::Wuxia.Slots.getManualDef(this.m.ManualID);
		if (def != null)
		{
			for (local i = 0; i < def.Levels.len(); i = ++i)
			{
				ret.push({
					id = 20 + i,
					type = "text",
					text = ::Wuxia.Text.TierNames[i + 1] + "：" + def.Levels[i].Summary
				});
			}
		}
		return ret;
	}

	function onSerialize( _out )
	{
		this.item.onSerialize(_out);
		_out.writeString(this.m.ManualID);
	}

	function onDeserialize( _in )
	{
		this.item.onDeserialize(_in);
		this.m.ManualID = _in.readString();
		this.refreshFromConfig();
	}
});
