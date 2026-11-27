// Wuxia Ambition: Visit a Sect Sanctum on the World Map
this.wx_ambition_visit_sanctum <- this.inherit("scripts/ambitions/ambition", {
	m = {},
	function create()
	{
		this.ambition.create();
		this.m.ID = "ambition.wx_visit_sanctum";
		this.m.Duration = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.ButtonText = "名山拜帖，亲赴一座江湖宗门山门";
		this.m.UIText = "在大地图踏入并拜访任意 1 座武林宗门山门";
		this.m.SuccessText = "[img]gfx/ui/events/wx_ev_04.png[/img]你们一路风尘仆仆踏上青石山道，终于亲身立于名山大派的朱漆山门之下。递上拜帖、与知客长老把茶论剑后，九州宗门的藏经秘阁与药庐试炼皆向你们敞开了大门！";
		this.m.SuccessButtonText = "好！壮哉我辈江湖儿女！";
		if ("ButtonTooltip" in this.m)
			this.m.ButtonTooltip = "循城中茶肆打听的方位，率队亲赴九州大地图上任意 1 座独立【武林宗门山门】并点击踏入拜访（可解锁宗门演武、药庐、求贤与镇派秘籍）。";
		if ("TooltipText" in this.m)
			this.m.TooltipText = "率队前往九州大地图上任意 1 座独立【武林宗门山门】并点击踏入拜访。";
	}

	function onUpdateScore()
	{
		if (this.m.IsDone) return;
		if (this.World.Flags.get("wx_visited_sanctum")) return;
		this.m.Score = 3 + this.Math.rand(0, 5);
	}

	function onCheckSuccess()
	{
		return this.World.Flags.get("wx_visited_sanctum") ? true : false;
	}

	function onReward()
	{
		this.World.Assets.addMoney(400);
		this.World.Assets.addBusinessReputation(100);
		this.m.SuccessList.push({
			id = 10,
			icon = "ui/icons/asset_money.png",
			text = "拜山结缘获赠程仪 400 两纹银，并额外提升江湖威名 +100"
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
