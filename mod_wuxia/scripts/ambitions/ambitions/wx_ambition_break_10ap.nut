// Wuxia Ambition: Raise Any Brother's Permanent AP to >= 10
this.wx_ambition_break_10ap <- this.inherit("scripts/ambitions/ambition", {
	m = {},
	function create()
	{
		this.ambition.create();
		this.m.ID = "ambition.wx_break_10ap";
		this.m.Duration = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.ButtonText = "破境化臻，令侠客突破 10 点常驻行动力";
		this.m.UIText = "令 1 名侠客借江湖孤本三重大成将常驻行动力升至 10 AP 以上";
		this.m.SuccessText = "[img]gfx/ui/events/wx_ev_25.png[/img]一念动而身先至，招未尽而势已圆！麾下高手已借江湖孤本三重大成打破凡胎桎梏，常驻行动力跨入 10 AP 宗师之境，举手投足皆令天下群雄望尘莫及！";
		this.m.SuccessButtonText = "好！壮哉我辈江湖儿女！";
		if ("ButtonTooltip" in this.m)
			this.m.ButtonTooltip = "寻获附带『常驻行动点 +1』词条的江湖孤本（如绝世内功或神行轻功），装入槽位并修至三重大成，令麾下至少 1 名侠客常驻行动力达到 10 AP 以上。";
		if ("TooltipText" in this.m)
			this.m.TooltipText = "将带『常驻行动点 +1』的江湖孤本修至三重大成并装配，令至少 1 名侠客常驻行动力达 10 AP 以上。";
	}

	function hasBroken10AP()
	{
		if (this.World.getPlayerRoster() == null) return false;
		foreach (bro in this.World.getPlayerRoster().getAll())
		{
			if (bro == null || !bro.isAlive()) continue;
			local c = ::Wuxia.Slots.getContainer(bro);
			if (c != null && c.getPermanentAPBonus() >= 1)
				return true;
		}
		return false;
	}

	function onUpdateScore()
	{
		if (this.m.IsDone) return;
		if (this.hasBroken10AP()) return;
		if (this.World.getTime().Days < 25) return;
		this.m.Score = 2 + this.Math.rand(0, 5);
	}

	function onCheckSuccess()
	{
		return this.hasBroken10AP();
	}

	function onReward()
	{
		this.World.Assets.addMoney(1000);
		this.World.Assets.addBusinessReputation(200);
		this.m.SuccessList.push({
			id = 10,
			icon = "ui/icons/asset_money.png",
			text = "宗师破境名震武林，获赠纹银 1,000 两，额外江湖威名 +200"
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
