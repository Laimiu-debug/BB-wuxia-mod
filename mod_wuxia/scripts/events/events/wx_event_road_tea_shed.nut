// Road Encounter: 荒野茶棚 · 老镖头夜话（官道行军奇遇）

this.wx_event_road_tea_shed <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_road_tea_shed";
		this.m.Title = "荒野茶棚 · 老镖头指路";
		this.m.Cooldown = 14.0 * this.World.getTime().SecondsPerDay;

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
				this.Options = [];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]沿官道疾行半日，尘土满襟。转过一道黄土山梁，路旁老槐树下支着一座芦席茶棚，粗陶大碗里泡着消暑老粗茶。角落长凳上坐着一位满鬓霜白、左颊带刀疤的断指老镖头，正就着花生米独酌烧刀子。\n\n见你们一行兵刃齐整、步履沉稳，老镖头眯眼打量片刻，举起酒葫芦遥遥一敬：『都是刀口讨饭吃的同道中人，过来歇歇脚罢！』";

				this.Options.push({
					Text = "掏 45 两银子请老前辈满饮一壶，讨教这片地界的绿林暗桩与近路。",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 45) return "NoSilver";
						return "BuyWine";
					}
				});
				this.Options.push({
					Text = "与老镖头同席切磋走镖守夜的心得，全队歇脚饮茶。",
					function getResult( _ev ) { return "ShareTea"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "BuyWine",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "多谢老前辈提点，后会有期！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMoney(-45, this.List);
				::Wuxia.Events.giveFood("scripts/items/supplies/bread_item", "潼关千层焦香锅盔", this.List);
				::Wuxia.Events.addCompanyMastery(18, this.List);
				::Wuxia.Events.addCompanyMood(0.6, "得老镖头指点江湖路数", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]老镖头哈哈一笑，仰脖痛饮三大碗，用筷子蘸着茶水在木桌上画出附近几条山谷暗道与响马惯常设伏的隘口，又随手指点了 " + ::Wuxia.Events.fmtName(bro) + " 两手押车护肋的护身卸力巧劲。临别时，茶博士还往你们鞍袋里塞了一包刚出炉的热腾腾锅盔。";
			}
		});

		this.m.Screens.push({
			ID = "ShareTea",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "整顿鞍马，继续赶路。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro))
				{
					this.Characters.push(bro.getImagePath());
					::Wuxia.Events.addMastery(bro, 22, this.List);
				}
				::Wuxia.Events.addCompanyMood(0.5, "古槐茶棚歇脚畅饮", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]几碗苦冽粗茶下肚，暑气顿消。老镖头聊起年轻时三过黑风岭的旧事，" + ::Wuxia.Events.fmtName(bro) + " 听得频频颔首，对临阵守势颇有所悟。";
			}
		});

		this.m.Screens.push({
			ID = "NoSilver",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "老前辈爽快，请！", function getResult( _event ) { return "ShareTea"; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]你摸了摸空瘪的钱袋正觉尴尬，老镖头已摆手笑道：『出门在外哪有不囊中羞涩的时候？坐下喝碗粗茶不花钱！』";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (this.World.getTime().Days < 2) return;
		local p = this.World.State.getPlayer();
		if (p == null || p.getTile() == null || !p.getTile().HasRoad) return;
		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;
		this.m.Bro = bro;
		this.m.Score = 24;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear() { this.m.Bro = null; }
});
