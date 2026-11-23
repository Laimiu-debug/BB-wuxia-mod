// Wuxia Ambition: Succeed in Marrow Wash Star Breakthrough
this.wx_ambition_marrow_wash <- this.inherit("scripts/ambitions/ambition", {
	m = {},
	function create()
	{
		this.ambition.create();
		this.m.ID = "ambition.wx_marrow_wash";
		this.m.Duration = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.ButtonText = "洗经伐髓，助麾下侠客逆天改命冲星";
		this.m.UIText = "成功完成 1 次『洗经伐髓』根骨升星";
		this.m.SuccessText = "[img]gfx/ui/events/wx_ev_07.png[/img]药力如江河决堤冲开奇经八脉，伴随一声清越长啸，同袍周身浊气尽去、根骨星辉跃然升华！自此便是凡胎俗骨，亦有问鼎宗师之望！";
		this.m.SuccessButtonText = "好！壮哉我辈江湖儿女！";
		if ("ButtonTooltip" in this.m)
			this.m.ButtonTooltip = "借功法大成契机或服食洗髓灵丹，为任一名麾下侠客成功完成 1 次『洗经伐髓』根骨升星。";
		if ("TooltipText" in this.m)
			this.m.TooltipText = "为任一名麾下侠客成功完成 1 次『洗经伐髓』根骨升星。";
	}

	function onUpdateScore()
	{
		if (this.m.IsDone) return;
		if (this.World.Flags.get("wx_marrow_wash_success")) return;
		if (this.World.getTime().Days < 15) return;
		this.m.Score = 2 + this.Math.rand(0, 5);
	}

	function onCheckSuccess()
	{
		return this.World.Flags.get("wx_marrow_wash_success") == true;
	}

	function onReward()
	{
		this.World.Assets.addMoney(400);
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_humai");
		if (this.World.Assets.getStash().hasEmptySlot())
			this.World.Assets.getStash().add(pill);
		this.m.SuccessList.push({
			id = 10,
			icon = "ui/items/" + pill.getIcon(),
			text = "获赠纹银 400 两，并得【" + pill.getName() + "】×1 以护后途冲关"
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
