// M4.2 Endgame Event: 天下武林大会（终极演武总擂，考验成型侠客梯队，赢取孤本秘籍与洗髓奇药）

this.wx_event_grand_tournament <- this.inherit("scripts/events/event", {
	m = {
		ChampName  = "",
		SquadScore = 0
	},

	function create()
	{
		this.m.ID = "event.wx_grand_tournament";
		this.m.Title = "天下武林大会英雄帖";
		this.m.Cooldown = 45.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "遣队内头号高手登台连战群雄，角逐武林盟主彩头！",
					function getResult( _event )
					{
						if (::Math.rand(1, 100) <= _event.m.SquadScore)
							return "Champion";
						return "SemiFinal";
					}
				},
				{
					Text = "率众在台下观摩各派宗师拆招，印证武学火候。",
					function getResult( _event ) { return "Observe"; }
				},
				{
					Text = "江湖是非多，婉拒英雄帖悄然离去。",
					function getResult( _event ) { return 0; }
				}
			],
			function start( _event )
			{
				local roster = ::World.getPlayerRoster().getAll();
				local bestBro = roster[0];
				local bestPower = -1;
				local tier3Count = 0;

				foreach (bro in roster)
				{
					if (bro == null || !bro.isAlive()) continue;
					local b = bro.getCurrentProperties();
					local pwr = ::Math.max(b.MeleeSkill, b.RangedSkill) + b.MeleeDefense + ::Math.floor(b.Bravery * 0.5) + bro.getLevel() * 4;
					local c = ::Wuxia.Slots.getContainer(bro);
					if (c != null)
					{
						foreach (s in c.m.Slots)
							if (s.ManualID != null && s.Tier >= 3) { pwr += 8; tier3Count += 1; }
					}
					if (pwr > bestPower)
					{
						bestPower = pwr;
						bestBro = bro;
					}
				}

				_event.m.ChampName = bestBro.getName();
				// Benchmark: a Lv9-11 master with Tier-3 manuals reaches ~190-230 power -> ~55%-85% win rate
				_event.m.SquadScore = ::Math.min(88, ::Math.max(20, ::Math.floor((bestPower - 125) * 0.75) + tier3Count * 3));

				this.Characters.push(bestBro.getImagePath());
				this.Text = "[img]gfx/ui/events/wx_ev_05.png[/img]旌旗蔽日，钟鼓齐鸣！各州名门大派、边塞奇人与世家供奉齐聚演武总擂，召开数年一度的「天下武林大会」。盟主高台之上，锦盒内赫然陈列着失传已久的江湖孤本与稀世洗髓灵丹。\n\n队中以 [color=#bcad8c]" + _event.m.ChampName + "[/color] 武功最为精纯（夺魁把握约 [color=#8f6b29]" + _event.m.SquadScore + "%[/color]）。是否登台一战？";
			}
		});

		this.m.Screens.push({
			ID = "Champion",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "名震天下，满载而归！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				::World.Assets.addMoney(4500);
				::World.Assets.addBusinessReputation(250);
				foreach (sid, sdef in ::Wuxia.Config.Sects)
				{
					if ("Alignment" in sdef && sdef.Alignment == "righteous")
						::Wuxia.SectRelations.addRelation(sid, 12);
				}

				local stash = ::World.Assets.getStash();
				local uniques = ::Wuxia.Loot.getManualIDsByQuality("unique");
				local mid = uniques[::Math.rand(0, uniques.len() - 1)];
				local def = ::Wuxia.Slots.getManualDef(mid);

				local rewardText = "赏银 4,500 两，正道诸派交情大涨";
				if (stash.hasEmptySlot())
				{
					local book = ::new("scripts/items/misc/wx_manual_item");
					book.initManual(mid);
					stash.add(book);
					rewardText += "，获赐江湖孤本《" + def.Name + "》";
				}
				if (stash.hasEmptySlot())
				{
					local pill = ::new("scripts/items/misc/wx_pill_item");
					pill.initPill("wx_pill_xisui");
					stash.add(pill);
					rewardText += "、【洗髓丹】一枚";
				}
				if (stash.hasEmptySlot())
				{
					local relic = ::Wuxia.Relics.createRandomRelic();
					if (relic != null)
					{
						stash.add(relic);
						rewardText += "与传世神兵【" + relic.getName() + "】";
					}
				}

				this.Text = "[img]gfx/ui/events/wx_ev_05.png[/img]" + _event.m.ChampName + " 连破三关，于总擂之上拆解少室金刚掌、破去唐门暴雨针，终以一记绝招震退压轴宿老！满场喝彩如雷，大会盟主亲手奉上彩头（" + rewardText + "）！";
			}
		});

		this.m.Screens.push({
			ID = "SemiFinal",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "收下彩头，来日再战。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				::World.Assets.addMoney(1500);
				::World.Assets.addBusinessReputation(80);
				local stash = ::World.Assets.getStash();
				for (local i = 0; i < 2; i = ++i)
				{
					if (stash.hasEmptySlot())
					{
						local p = ::new("scripts/items/misc/wx_pill_item");
						p.initPill("wx_pill_ningshen");
						stash.add(p);
					}
				}
				this.Text = "[img]gfx/ui/events/wx_ev_05.png[/img]" + _event.m.ChampName + " 一路鏖战闯入前四，奈何半决赛遭遇隐世绝顶名宿，苦斗百余合后棋差半着抱拳认输。虽未夺魁，豪勇风采仍赢得满堂敬重，获颁彩头银 1,500 两与两枚【凝神丸】。";
			}
		});

		this.m.Screens.push({
			ID = "Observe",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "大有所获。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				foreach (bro in ::World.getPlayerRoster().getAll())
				{
					if (bro != null && bro.isAlive())
						::Wuxia.Mastery.addExpToEquipped(bro, 60);
				}
				this.Text = "[img]gfx/ui/events/wx_ev_05.png[/img]众弟兄立于演武台下凝神观摩各路名家换气拆招，彼此印证平日苦修滞涩之处，全队已修习武学火候齐涨 60 点！";
			}
		});
	}

	function onUpdateScore()
	{
		if (this.World.getTime().Days < 45) return;
		if (!::Wuxia.Loot.isNearMarketTown()) return;

		local highLevelCount = 0;
		foreach (bro in ::World.getPlayerRoster().getAll())
		{
			if (bro != null && bro.isAlive() && bro.getLevel() >= 7)
				highLevelCount += 1;
		}
		if (highLevelCount < 3) return;
		this.m.Score = 15;
	}
});
