// Batch E4 Event 41: 丐帮暗记消息（天下丐帮耳目线报）

this.wx_event_sect_gaibang_tip <- this.inherit("scripts/events/event", {
	m = {
		SectID = "gaibang",
		Bro    = null
	},

	function create()
	{
		this.m.ID = "event.wx_sect_gaibang_tip";
		this.m.Title = "灰墙暗记 · 丐帮长老递风";
		this.m.Cooldown = 28.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "付 140 银两买下这桩山匪藏赃暗窖的消息",
					function getResult( _event )
					{
						if (::World.Assets.getMoney() < 140) return "NoMoney";
						return "BuyTip";
					}
				},
				{
					Text = "花 60 银两拎一坛烧酒与他共饮，托他在城中美言几句",
					function getResult( _event )
					{
						if (::World.Assets.getMoney() < 60) return "NoMoney";
						return "BuyWine";
					}
				},
				{
					Text = "道听途说不足信，拱手离去。",
					function getResult( _event ) { return 0; }
				}
			],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local regionLabel = ::Wuxia.Events.getRegionLabel();
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]行过" + regionLabel + "一处塌了半边的土地庙白墙，三道斜粉笔画出的葫芦暗记还沾着新灰。檐下蹲着个缺了两根手指的老叫花，背上五个灰布口袋补丁摞补丁，正往缺口粗瓷碗里剥炒花生。\n\n你们还没停稳脚步，这位【" + sect.Name + "】的五袋长老头也不抬，竟一口叫出你们三日前投宿的客栈字号，嘿嘿笑道：『别紧张，老叫花只卖消息不卖命。前夜一伙流匪分赃火并，把最值钱的油布包袱塞进了乱岗枯柳洞里。一百四十两茶钱，地方归你们刨；若嫌沾贼气，花六十两请我喝坛老烧刀子也成，明儿城里茶肆酒楼我保准替诸位吹上十句好风声。』";
			}
		});

		this.m.Screens.push({
			ID = "BuyTip",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "收妥财物，暗赞丐帮耳目果然灵通。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMoney(-140, this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, 12, this.List);
				::Wuxia.Events.addMoney(180, this.List);

				local bookLine = "";
				if (::Math.rand(1, 100) <= 50)
				{
					::Wuxia.Events.giveManual("common", this.List, _event.m.SectID);
					bookLine = "银袋底下还压着一册油渍斑斑却字迹完整的江湖抄本！";
				}
				else
				{
					::Wuxia.Events.givePage("sect", 1, this.List, _event.m.SectID);
					bookLine = "银袋夹层里竟还裹着一叶珍贵的门派秘录残页！";
				}

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]老叫花咬了口碎银验过成色，顺手抓起一把花生壳在地上摆出山坳与溪汊走向。依着【" + sect.Name + "】的暗桩指点，你们摸到乱岗尽头那棵雷劈枯柳前，果然从腐叶和树洞深处刨出只沉甸甸的桐油包袱。\n\n抖开一看，除了散碎纹银一百八十两，" + bookLine;
			}
		});

		this.m.Screens.push({
			ID = "BuyWine",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "酒尽人散，各自珍重。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMoney(-60, this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, 15, this.List);
				::Wuxia.Events.addReputation(30, 0, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "与丐帮长老把酒言欢，美名传遍市井", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]六十两银子换来两坛辛辣地瓜烧和一包五香花生。老叫花拍开泥封仰脖痛饮，拉着" + ::Wuxia.Events.fmtName(bro) + "讲了半宿南北码头的奇闻轶事，临别将酒坛往砖台上一墩：『痛快！往后你们走到哪州哪府，只要墙角还有【" + sect.Name + "】的粉笔道，没人敢在暗地里编排诸位的不是！』";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "讪讪告辞。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]摸摸腰包竟连这点茶酒钱都凑不齐。老叫花眨眨眼，反手从碗里抓了把炒花生塞给你们：『穷家富路，拿去垫垫肚子，买卖改日再做！』";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::Wuxia.Events.getAliveBros().len() == 0) return;
		this.m.SectID = "gaibang";
		this.m.Bro = ::Wuxia.Events.findRandomBro();
		this.m.Score = 16;
	}

	function onPrepare()
	{
		this.m.SectID = "gaibang";
		if (!::Wuxia.Events.isAlive(this.m.Bro))
			this.m.Bro = ::Wuxia.Events.findRandomBro();
	}

	function onPrepareVariables( _vars ) {}

	function onClear()
	{
		this.m.SectID = null;
		this.m.Bro = null;
	}
});
