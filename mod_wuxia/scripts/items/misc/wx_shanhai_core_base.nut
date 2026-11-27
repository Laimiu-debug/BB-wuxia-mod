// Base Item for Shan Hai Jing Mythical Beast & Sovereign Neidan Cores (山海万妖与太古神魔内丹)

this.wx_shanhai_core_base <- this.inherit("scripts/items/item", {
	m = {
		CoreID = "wx_core_zhuyan"
	},

	function create()
	{
		this.item.create();
		local ref = ::new("scripts/items/misc/unhold_heart_item");
		this.m.Icon = ref.m.Icon;
		this.m.SlotType = this.Const.ItemSlot.None;
		this.m.ItemType = this.Const.Items.ItemType.Misc | this.Const.Items.ItemType.Crafting;
		this.m.IsDroppedAsLoot = true;
		this.m.Value = 1800;
	}

	function initCore( _coreID )
	{
		this.m.CoreID = _coreID;
		this.m.ID = "misc." + _coreID;
		if ("ShanHaiCores" in ::Wuxia.Config && (_coreID in ::Wuxia.Config.ShanHaiCores))
		{
			local cfg = ::Wuxia.Config.ShanHaiCores[_coreID];
			this.m.Name = cfg.Name;
			this.m.Description = cfg.Description;
			this.m.Value = cfg.Value;
			if (cfg.CustomIcon != null) this.m.Icon = cfg.CustomIcon;
		}
	}

	function getTooltip()
	{
		local ret = this.item.getTooltip();
		if ("ShanHaiCores" in ::Wuxia.Config && (this.m.CoreID in ::Wuxia.Config.ShanHaiCores))
		{
			local cfg = ::Wuxia.Config.ShanHaiCores[this.m.CoreID];
			local affMap = {
				waigong      = "外功兵道",
				neigong_yang = "阳刚内功",
				neigong_yin  = "阴柔/奇门内功",
				qinggong     = "轻功身法",
				henglian     = "横练硬功",
				tactics      = "统帅奇术"
			};
			local affKey = ("Affinity" in cfg) ? cfg.Affinity : "waigong";
			local affLabel = (affKey in affMap) ? affMap[affKey] : "诸般武学";
			local baseExp = cfg.ExpAmount;
			local resExp  = baseExp + 100;
			local shExp   = baseExp + 180;
			local cCol = (baseExp >= 340) ? "#7c1414" : ((baseExp >= 240) ? "#50187d" : "#0b4a1e");
			ret.push({
				id = 15,
				type = "text",
				icon = "ui/icons/special.png",
				text = "[color=#3a3052][b]内丹气脉：[/b][/color][color=" + cCol + "][b]【《" + cfg.Chapter + "》· 契合" + affLabel + "】[/b][/color]"
			});
			ret.push({
				id = 16,
				type = "text",
				icon = "ui/icons/xp_received.png",
				text = "[color=#5e2c00][b]炼化灌顶：[/b][/color]常规 [color=#0b4a1e][b]+" + baseExp + "[/b][/color] 火候｜" + affLabel + "共鸣 [color=#50187d][b]+" + resExp + "[/b][/color]｜山海孤本共鸣 [color=#7c1414][b]+" + shExp + "[/b][/color]"
			});
			ret.push({
				id = 17,
				type = "text",
				icon = "ui/icons/asset_supplies.png",
				text = "[color=#094a44][b]百工入炉：[/b][/color]可携往城镇「百工丹坊」锻造山海神兵宝甲或合炼仙品金丹"
			});
		}
		return ret;
	}
});
