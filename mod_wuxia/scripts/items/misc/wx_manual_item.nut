// Generic Martial Manual Item (Consumable: right-click in Stash to teach character, or store in 藏经阁)

this.wx_manual_item <- this.inherit("scripts/items/item", {
	m = {
		ManualID            = "wx_manual_tuna",
		WX_WithdrawnForSale = false
	},

	function create()
	{
		this.item.create();
		this.m.ID = "misc.wx_manual_item";
		this.m.Name = "武学秘籍";
		this.m.Description = "武林典籍消耗品。可在战团仓库右键直接给当前角色研读学习，或收入「藏经阁」不占格管理；角色习得后方可在「武学修为」页装入插槽。";
		this.m.Icon = "misc/wx_book_neigong_common.png";
		this.m.SlotType = this.Const.ItemSlot.None;
		this.m.ItemType = this.Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsUsable = true;
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

	function wxGetBookIconSuffix( _quality )
	{
		if (_quality == "secret") return "supreme";
		return _quality;
	}

	function refreshFromConfig()
	{
		local def = ::Wuxia.Slots.getManualDef(this.m.ManualID);
		if (def == null) return;

		local qName = (def.Quality in ::Wuxia.Text.Qualities) ? ::Wuxia.Text.Qualities[def.Quality] : def.Quality;
		local cName = (def.Category in ::Wuxia.Text.Categories) ? ::Wuxia.Text.Categories[def.Category] : def.Category;
		this.m.Name = "《" + def.Name + "》";
		this.m.Description = "【" + qName + " · " + cName + "】" + def.Description;
		this.m.Value = def.BasePrice;
		local qKey = this.wxGetBookIconSuffix(def.Quality);
		this.m.Icon = "misc/wx_book_" + def.Category + "_" + qKey + ".png";
		this.m.IsUsable = true;
	}

	function getTooltip()
	{
		local ret = this.item.getTooltip();
		local def = ::Wuxia.Slots.getManualDef(this.m.ManualID);
		if (def != null)
		{
			local own = ::Wuxia.Library.getOwnershipSummary(this.m.ManualID);
			local ownStatus = "";
			if (own.bookCount <= 0 && own.learnedCount <= 0)
			{
				ownStatus = "[color=#0b4a1e][b]【未收录新篇】[/b][/color]藏经阁暂无存书 · 队内尚无人领悟";
			}
			else
			{
				ownStatus = "[color=#5e2c00][b]藏经阁存书：" + own.bookCount + " 册[/b][/color]｜队内已领悟：[color=#0b4a1e][b]" + own.learnedCount + "[/b][/color] 人";
			}
			if (own.pageCount > 0 && own.fragmentsNeeded > 0)
			{
				ownStatus += "（另存残页 [color=#153e6e][b]" + own.pageCount + "/" + own.fragmentsNeeded + "[/b][/color] 张）";
			}
			ret.push({
				id = 17,
				type = "text",
				icon = "ui/icons/relations.png",
				text = ownStatus
			});

			if ("WeaponTypes" in def && def.WeaponTypes.len() > 0)
			{
				local wStr = "";
				for (local w = 0; w < def.WeaponTypes.len(); w = ++w)
				{
					if (w > 0) wStr += " / ";
					local wt = def.WeaponTypes[w];
					wStr += (("WeaponTypeNames" in ::Wuxia.Text && wt in ::Wuxia.Text.WeaponTypeNames) ? ::Wuxia.Text.WeaponTypeNames[wt] : wt);
				}
				ret.push({
					id = 18,
					type = "text",
					icon = "ui/icons/melee_skill.png",
					text = "[color=#3a3052][b]适配兵刃：[/b][/color][color=#6e3400][b]" + wStr + "[/b][/color]"
				});
			}
			local tierCols = ["#3a3052", "#0b4a1e", "#7c1414"];
			for (local i = 0; i < def.Levels.len(); i = ++i)
			{
				local tCol = (i < tierCols.len()) ? tierCols[i] : "#5e2c00";
				ret.push({
					id = 20 + i,
					type = "text",
					icon = "ui/icons/special.png",
					text = "[color=" + tCol + "][b]" + ::Wuxia.Text.TierNames[i + 1] + "：[/b][/color]" + def.Levels[i].Summary
				});
			}
			ret.push({
				id = 30,
				type = "text",
				icon = "ui/icons/xp_received.png",
				text = "[color=#094a44][b]用法：[/b][/color]右键直接消耗并让当前角色领悟此武学，在「武学修为」页选装入槽；亦可归入「藏经阁」不占仓库格存放。"
			});
		}
		return ret;
	}

	function onUse( _actor, _item = null )
	{
		local res = ::Wuxia.Slots.learnManual(_actor, this.m.ManualID, false);
		return res.Ok;
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
