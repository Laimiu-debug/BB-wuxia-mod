// Wuxia Ambition: Brew a Grade 2+ (灵纹/丹霞) Pill in 百工丹坊 or 八卦丹炉
this.wx_ambition_brew_elixir <- this.inherit("scripts/ambitions/ambition", {
	m = {},
	function create()
	{
		this.ambition.create();
		this.m.ID = "ambition.wx_brew_elixir";
		this.m.Duration = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.ButtonText = "开炉凝丹，亲手炼出灵纹或丹霞上品丹药";
		this.m.UIText = "在百工丹坊或八卦丹炉炼出 1 枚『灵纹』或『丹霞』品相丹药";
		this.m.SuccessText = "[img]gfx/ui/events/wx_ev_03.png[/img]丹炉启盖之际清香扑鼻、霞光隐现，一枚丹纹细腻的上品灵丹稳稳落入玉瓶！行军打仗有了自给自足的丹道底蕴，纵逢强敌凶兽亦多了一分底气。";
		this.m.SuccessButtonText = "好！壮哉我辈江湖儿女！";
		if ("ButtonTooltip" in this.m)
			this.m.ButtonTooltip = "筹集奇草或异兽奇材，在城镇【百工丹坊】按图炼丹或【八卦丹炉】开炉，凝出至少 1 枚名称带『灵纹·』或『丹霞·』前缀的上品丹药（判定成丹丹纹品相，非丹方品质）。";
		if ("TooltipText" in this.m)
			this.m.TooltipText = "在城镇【百工丹坊】按图炼丹或【八卦丹炉】开炉，炼出 1 枚带『灵纹·』或『丹霞·』前缀的上品丹药（判定丹纹品相，非丹方品质）。";
	}

	function hasHighGradePillInStash()
	{
		if (!::Wuxia.hasWorldField("Assets") || this.World.Assets.getStash() == null)
			return false;
		foreach (it in this.World.Assets.getStash().getItems())
		{
			if (it != null && it.getID() == "misc.wx_pill_item"
				&& ::Wuxia.hasMember(it, "getPillGrade") && it.getPillGrade() >= 2)
				return true;
		}
		return false;
	}

	function onUpdateScore()
	{
		if (this.m.IsDone) return;
		if (this.World.Flags.get("wx_brewed_high_pill") || this.hasHighGradePillInStash()) return;
		if (this.World.getTime().Days < 4) return;
		this.m.Score = 2 + this.Math.rand(0, 5);
	}

	function onCheckSuccess()
	{
		if (this.World.Flags.get("wx_brewed_high_pill"))
			return true;
		if (this.hasHighGradePillInStash())
		{
			if (::Wuxia.hasWorldField("Flags"))
				this.World.Flags.set("wx_brewed_high_pill", true);
			return true;
		}
		return false;
	}

	function onReward()
	{
		this.World.Assets.addMoney(300);
		local herbs = [
			"scripts/items/misc/wx_herb_xuelian",
			"scripts/items/misc/wx_herb_huolingzhi",
			"scripts/items/misc/wx_herb_zizhi",
			"scripts/items/misc/wx_herb_heshouwu"
		];
		local herbScript = herbs[this.Math.rand(0, herbs.len() - 1)];
		local hItem = ::new(herbScript);
		if (this.World.Assets.getStash().hasEmptySlot())
			this.World.Assets.getStash().add(hItem);
		else if ("Alchemy" in ::Wuxia && "Cabinet" in ::Wuxia.Alchemy)
		{
			local meta = ::Wuxia.Alchemy.classifyItem(hItem);
			if (meta != null)
				::Wuxia.Alchemy.Cabinet.addCount(meta.Key, 1, meta.Script, meta.SubID);
		}
		this.m.SuccessList.push({
			id = 10,
			icon = "ui/items/" + hItem.getIcon(),
			text = "获赠纹银 300 两，并得奇草【" + hItem.getName() + "】×1"
		});
	}

	function onSerialize( _out )
	{
		this.ambition.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		this.ambition.onDeserialize(_in);
	}
});
