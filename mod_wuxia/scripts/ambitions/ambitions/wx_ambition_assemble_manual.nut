// Wuxia Ambition: Assemble a Complete Manual from Pages in the Library
this.wx_ambition_assemble_manual <- this.inherit("scripts/ambitions/ambition", {
	m = {},
	function create()
	{
		this.ambition.create();
		this.m.ID = "ambition.wx_assemble_manual";
		this.m.Duration = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.ButtonText = "残页合璧，在藏经阁拼成一部完整秘籍";
		this.m.UIText = "在藏经阁以武学残页拼合成 1 部完整秘籍";
		this.m.SuccessText = "[img]gfx/ui/events/wx_ev_08.png[/img]灯花挑尽、宣纸铺开，散落四方的武学残页终于在你们手中一一对准经脉图谱，装订成一部首尾完备的传世秘籍！众弟兄摩拳擦掌，迫不及待欲窥其中奥妙。";
		this.m.SuccessButtonText = "好！壮哉我辈江湖儿女！";
		if ("ButtonTooltip" in this.m)
			this.m.ButtonTooltip = "在江湖厮杀、宗门试炼或茶肆历练中收集同篇残页，于【藏经阁】拼合成至少 1 部完整武学秘籍。";
		if ("TooltipText" in this.m)
			this.m.TooltipText = "于【藏经阁】以武学残页拼合成至少 1 部完整秘籍。";
	}

	function onUpdateScore()
	{
		if (this.m.IsDone) return;
		if (this.World.Flags.get("wx_crafted_page_manual")) return;
		if (this.World.getTime().Days < 8) return;
		this.m.Score = 2 + this.Math.rand(0, 5);
	}

	function onCheckSuccess()
	{
		return this.World.Flags.get("wx_crafted_page_manual") == true;
	}

	function onReward()
	{
		this.World.Assets.addMoney(300);
		local sectIds = ::Wuxia.Loot.getManualIDsByQuality("sect");
		local bonusTxt = "藏经阁整编得银 300 两";
		if (sectIds.len() > 0)
		{
			local pick = sectIds[this.Math.rand(0, sectIds.len() - 1)];
			::Wuxia.Library.addPages(pick, 1);
			local def = ::Wuxia.Slots.getManualDef(pick);
			local nm = def != null ? def.Name : pick;
			bonusTxt = "得银 300 两，并在古籍夹层中意外寻获《" + nm + "》残页 ×1";
		}
		this.m.SuccessList.push({
			id = 10,
			icon = "ui/items/misc/wx_book_waigong_sect.png",
			text = bonusTxt
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
