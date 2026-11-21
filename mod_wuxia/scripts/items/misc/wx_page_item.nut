// Generic Martial Page / Fragment Item (stackable; craft into full manual, infuse mastery, or risky fragment-learn)

this.wx_page_item <- this.inherit("scripts/items/item", {
	m = {
		ManualID            = "wx_manual_songtao",
		PageCount           = 1,
		WX_WithdrawnForSale = false
	},

	function create()
	{
		this.item.create();
		this.m.ID = "misc.wx_page_item";
		this.m.Name = "武学残页";
		this.m.Description = "散落的武学残页。自动或一键归入「藏经阁」（不占仓库格），可在阁内集齐拼合完整秘籍、以 2 张同阶闲置残页融会补缺，或用于「参悟化功」注入火候；取出至仓库可在市集出售。";
		this.m.Icon = "misc/wx_page_sect.png";
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
		local qKey = (def.Quality == "secret") ? "supreme" : def.Quality;
		this.m.Icon = "misc/wx_page_" + qKey + ".png";
		this.m.Name = "《" + def.Name + "》残页 (" + this.m.PageCount + "/" + req + ")";
		this.m.Value = ::Math.max(100, ::Math.floor(def.BasePrice / req) * this.m.PageCount);
	}

	function getTooltip()
	{
		local ret = this.item.getTooltip();
		local def = ::Wuxia.Slots.getManualDef(this.m.ManualID);
		if (def != null)
		{
			local qName = (def.Quality in ::Wuxia.Text.Qualities) ? ::Wuxia.Text.Qualities[def.Quality] : def.Quality;
			local cName = (def.Category in ::Wuxia.Text.Categories) ? ::Wuxia.Text.Categories[def.Category] : def.Category;
			local req = ::Math.max(1, def.FragmentsNeeded);
			local own = ::Wuxia.Library.getOwnershipSummary(this.m.ManualID);
			local combinedPages = own.pageCount + this.m.PageCount;
			ret.push({
				id = 15,
				type = "text",
				icon = "ui/icons/relations.png",
				text = "藏经阁现存：整本 " + own.bookCount + " 册 · 同名残页 " + own.pageCount + "/" + req + " 张（入阁后共 " + combinedPages + "/" + req + " 张）｜队内已习 " + own.learnedCount + " 人"
			});
			ret.push({
				id = 16,
				type = "text",
				icon = "ui/icons/special.png",
				text = "所属典籍：【" + qName + " · " + cName + "】《" + def.Name + "》（本叠 " + this.m.PageCount + " / 成书需 " + req + " 张）"
			});
			ret.push({
				id = 17,
				type = "text",
				icon = "ui/icons/xp_received.png",
				text = "参悟化功：拖入未满重插槽可注入 +" + ::Wuxia.Mastery.getPageBaseExp(def.Quality) + " 火候（同脉 +25%，同名 +50%）"
			});
			ret.push({
				id = 20,
				type = "text",
				icon = "ui/icons/regular_damage.png",
				text = "一重预览：" + def.Levels[0].Summary
			});
			ret.push({
				id = 21,
				type = "text",
				icon = "ui/icons/direct_damage.png",
				text = "大成预览：" + def.Levels[def.Levels.len() - 1].Summary
			});
		}
		return ret;
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
