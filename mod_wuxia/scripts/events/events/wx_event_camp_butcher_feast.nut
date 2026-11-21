// Batch E1 Event 07: 庖丁解兽（屠户/猎户营外放倒肥硕黑山猪，现烤、熏腊或卖给过路盐商）

this.wx_event_camp_butcher_feast <- this.inherit("scripts/events/event", {
	m = {
		BroA = null
	},

	function create()
	{
		this.m.ID = "event.wx_camp_butcher_feast";
		this.m.Title = "庖丁解兽";
		this.m.Cooldown = 32.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]天擦黑时，荆棘沟里传出一声闷响，不多久 " + nameA + " 竟攥着后蹄拖出一头獠牙外翻的肥黑山猪，喉口一道干净利落的放血刀口还在暮寒里滋滋冒着热气。浓郁的血腥混着湿松针味漫过营盘，连趴在草垛边打盹的弟兄都直勾勾伸长了脖子。\n\n" + nameA + " 拿河滩湿石把厚背斩骨刀蹭得雪亮——唰、唰、唰——眼里透着行家见了好货的光亮：\n\n『少说一百六七十斤重，肋条上挂着两指厚的雪白肥膘！东家一句话：今夜架起柴火撒把野生花椒粗盐烤个痛快，让伤病号也喝两碗热骨汤；还是趁肉紧实全片成条，拿松柏青枝熏成能存半月的腊肉干粮？再不然，前头官道刚过去一支盐商驼队，割下最嫩的后腿里脊追上去换现银，保管他们抢着要。』";

				this.Options = [
					{
						Text = "难得碰上横财！架柴撒花椒盐，今夜全队吃顿热腾腾的烤肉宴！",
						function getResult( _event ) { return "Feast"; }
					},
					{
						Text = "行军口粮最要紧！抹粗盐架松柏枝，全熏成肉干腊肉带在路上。",
						function getResult( _event ) { return "SmokeMeat"; }
					},
					{
						Text = "割下上好里脊后腿，快步追上官道商队换现银，下水煮锅清汤便罢。",
						function getResult( _event ) { return "SellMeat"; }
					}
				];
			}
		});

		this.m.Screens.push({
			ID = "Feast",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "吃饱喝足，明日更有力气卖命。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addCompanyMood(1.25, "火堆旁大口吃肉大碗喝汤", this.List);
				local healedCount = 0;
				foreach (bro in ::Wuxia.Events.getAliveBros())
				{
					if (bro.getHitpointsPct() < 0.99)
					{
						::Wuxia.Events.healBro(bro, 0.18, healedCount < 3 ? this.List : null);
						healedCount += 1;
					}
				}

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]油脂滴在通红栎木炭上滋滋爆响，野花椒与烤肉焦香顺风飘出半里地。" + nameA + " 手起刀落分肉极均，众人撕扯着焦脆流油的排骨，满嘴油光发亮，连骨头缝里的髓汁都敲出来熬了一大锅浓白热汤。\n\n热汤下肚，连日行军落下的疲乏与皮肉淤伤竟也舒坦了大半，荒野冷夜里难得升起几分人间烟火气。";
			}
		});

		this.m.Screens.push({
			ID = "SmokeMeat",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "囊里有干肉，进深山也不慌。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.giveFood("scripts/items/supplies/cured_venison_item", "熏制野味肉干", this.List);
				::Wuxia.Events.giveFood("scripts/items/supplies/smoked_ham_item", "松烟腊山猪肉", this.List);
				::Wuxia.Events.addMood(_event.m.BroA, 0.75, "庖丁解兽露了一手绝活", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]" + nameA + " 刀走骨缝、竟未碰响一下硬骨，不到一炷香便将百余斤山猪拆解得条块分明。薄片裹上粗盐与碎花椒，架在湿松针和柏枝闷出的青烟上慢焙了一宿。\n\n次日启程时，辎重袋里沉甸甸多了两捆油润焦香的熏肉腊条，咸香耐放，足够弟兄们在荒山野岭顶上好些天。";
			}
		});

		this.m.Screens.push({
			ID = "SellMeat",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "好肉换真银，生意不亏。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addMoney(180, this.List);
				::Wuxia.Events.addCompanyMood(0.25, "喝了锅热乎猪蹄清汤", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]嚼了半个月硬面饼的商队大掌柜一见新鲜野猪里脊，眼睛直放绿光。" + nameA + " 用宽荷叶包着上好腿肉在石碑旁一番唇枪舌剑，硬是卖出了 180 两纹银的好价钱；余下的猪蹄与杂骨带回营中炖了一锅清汤，虽没大快朵颐，倒也算人财两得。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		this.m.BroA = null;

		local hunter = ::Wuxia.Events.findByBackgrounds([
			"background.butcher",
			"background.hunter",
			"background.poacher"
		]);
		if (hunter == null) return;

		this.m.BroA = hunter;
		this.m.Score = 17;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.BroA))
		{
			this.m.BroA = ::Wuxia.Events.findByBackgrounds([
				"background.butcher",
				"background.hunter",
				"background.poacher"
			]);
		}
	}

	function onPrepareVariables( _vars )
	{
		_vars.push(["butcher", ::Wuxia.Events.shortName(this.m.BroA)]);
	}

	function onClear()
	{
		this.m.BroA = null;
	}
});
