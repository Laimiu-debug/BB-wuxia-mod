// M3 World Event: 江湖名医调理内伤（双线伤养闭环：根治临时内伤/经脉震荡/散功虚弱）

this.wx_event_famous_physician <- this.inherit("scripts/events/event", {
	m = {},

	function create()
	{
		this.m.ID = "event.wx_famous_physician";
		this.m.Title = "江湖名医坐堂";
		this.m.Cooldown = 10.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_18.png[/img]进镇打听之下，恰逢一位擅治内家震伤与走火入魔的游方名医在药铺坐堂。听闻你们队中有弟兄真气紊乱、身负内伤或散功虚弱，老医官捻须道：『内伤非金疮散可愈，若肯出 350 银两，老夫可施针行药替全队一并梳理经脉。』",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "花 350 银两请名医施针（立即化解全队散功虚弱、内伤与经脉震荡）",
					function getResult( _event )
					{
						if (this.World.Assets.getMoney() < 350) return "NoMoney";
						this.World.Assets.addMoney(-350);
						foreach (bro in this.World.getPlayerRoster().getAll())
						{
							local sk = bro.getSkills();
							sk.removeByID("effects.wx_scatter_weakness");
							local inj = sk.getSkillByID("effects.wx_internal_injury");
							if (inj != null && inj.m.Severity > 0)
							{
								inj.cureTemporary();
							}
							sk.update();
						}
						return "Cured";
					}
				},
				{
					Text = "花 450 银两顺手买一颗「护心丹」备用",
					function getResult( _event )
					{
						if (this.World.Assets.getMoney() < 450) return "NoMoney";
						this.World.Assets.addMoney(-450);
						local p = ::new("scripts/items/misc/wx_pill_item");
						p.initPill("wx_pill_huxin");
						this.World.Assets.getStash().add(p);
						return "BoughtPill";
					}
				},
				{
					Text = "自行运功调息便罢。",
					function getResult( _event ) { return 0; }
				}
			],
			function start( _event ) {}
		});

		this.m.Screens.push({
			ID = "Cured",
			Text = "[img]gfx/ui/events/event_18.png[/img]几帖温经汤药下肚，再配银针渡气，队内众人的内伤与散功虚弱立时消散，周身气息重归顺畅！",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "多谢神医！", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});

		this.m.Screens.push({
			ID = "BoughtPill",
			Text = "[img]gfx/ui/events/event_18.png[/img]你将「护心丹」收入行囊，日后散功或内伤皆可应急。",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "告辞。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "[img]gfx/ui/events/event_18.png[/img]银两不足，只得作罢。",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "离开。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});
	}

	function onUpdateScore()
	{
		if (!this.World.State.isInTown()) return;
		local hasInternalNeed = false;
		foreach (bro in this.World.getPlayerRoster().getAll())
		{
			local sk = bro.getSkills();
			if (sk.hasSkill("effects.wx_scatter_weakness")) hasInternalNeed = true;
			local inj = sk.getSkillByID("effects.wx_internal_injury");
			if (inj != null && inj.m.Severity > 0) hasInternalNeed = true;
		}
		if (hasInternalNeed)
		{
			this.m.Score = 40;
		}
	}
});
