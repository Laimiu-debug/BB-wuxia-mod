// Batch E4 Event 38: 两派狭路相逢（双门派博弈与斡旋）

this.wx_event_sect_rival_clash <- this.inherit("scripts/events/event", {
	m = {
		SectA       = null,
		SectB       = null,
		Mediator    = null,
		FallbackBro = null
	},

	function create()
	{
		this.m.ID = "event.wx_sect_rival_clash";
		this.m.Title = "断桥狭路 · 两派拔刃相向";
		this.m.Cooldown = 30.0 * this.World.getTime().SecondsPerDay;

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

				local sectA = ::Wuxia.Config.Sects[_event.m.SectA];
				local sectB = ::Wuxia.Config.Sects[_event.m.SectB];
				local regionLabel = ::Wuxia.Events.getRegionLabel();
				local showBro = ::Wuxia.Events.isAlive(_event.m.Mediator) ? _event.m.Mediator : _event.m.FallbackBro;
				if (::Wuxia.Events.isAlive(showBro)) this.Characters.push(showBro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_13.png[/img]" + regionLabel + "山涧暴涨，独剩一座长满青苔的单孔石桥可供通行。桥心窄处，两匹驮骡不知谁蹭了谁的货袋，先是骂了三句祖师爷，转眼便成了十来把寒铁出鞘半寸的僵局。\n\n桥西站着【" + sectA.Name + "】的门人，桥东则是【" + sectB.Name + "】的好手，双方脚下都是湿滑泥砖，谁也不肯先退半步，却又谁也不想在泥沟里白白丢下几具尸首。听见你们整齐沉重的脚步声踏上桥堤，两拨领头人的余光齐刷刷扫向你们腰间兵刃。";

				this.Options.push({
					Text = "迈步站到【" + sectA.Name + "】身后撑腰压阵",
					function getResult( _ev ) { return "BackA"; }
				});

				this.Options.push({
					Text = "横刀替【" + sectB.Name + "】助威逼退对方",
					function getResult( _ev ) { return "BackB"; }
				});

				if (::Wuxia.Events.isAlive(_event.m.Mediator))
				{
					this.Options.push({
						Text = "让" + ::Wuxia.Events.shortName(_event.m.Mediator) + "出面斡旋，替两家找个顾全颜面的台阶",
						function getResult( _ev ) { return "MediateBonus"; }
					});
				}
				else
				{
					this.Options.push({
						Text = "亲自踏上桥心抱拳圆场，劝两家各让一步",
						function getResult( _ev ) { return "MediateNormal"; }
					});
				}

				this.Options.push({
					Text = "两虎相争莫沾身，绕下游浅滩涉水过去。",
					function getResult( _ev ) { return 0; }
				});
			}
		});

		this.m.Screens.push({
			ID = "BackA",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "收刃过桥。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sectA = ::Wuxia.Config.Sects[_event.m.SectA];
				local sectB = ::Wuxia.Config.Sects[_event.m.SectB];

				::Wuxia.Events.addSectRel(_event.m.SectA, 20, this.List);
				::Wuxia.Events.addSectRel(_event.m.SectB, -20, this.List);

				local giftTxt = "";
				if (::Math.rand(1, 100) <= 50)
				{
					::Wuxia.Events.addMoney(180, this.List);
					giftTxt = "【" + sectA.Name + "】领头人朗声大笑，塞来一锭谢仪作茶水钱。";
				}
				else
				{
					::Wuxia.Events.givePill("wx_pill_jinchuang", this.List);
					giftTxt = "【" + sectA.Name + "】领头人抱拳称谢，随手赠了一瓶门中秘制跌打药散。";
				}

				this.Text = "[img]gfx/ui/events/wx_ev_13.png[/img]你们一言不发，只把刀柄往外一横，稳稳挡在【" + sectA.Name + "】身侧。人势顿时一边倒，【" + sectB.Name + "】领头人脸色铁青，往涧水里狠狠啐了一口，记下你们的衣甲样貌，领着同门骂骂咧咧倒退下桥。\n\n" + giftTxt;
			}
		});

		this.m.Screens.push({
			ID = "BackB",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "收刃过桥。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sectA = ::Wuxia.Config.Sects[_event.m.SectA];
				local sectB = ::Wuxia.Config.Sects[_event.m.SectB];

				::Wuxia.Events.addSectRel(_event.m.SectB, 20, this.List);
				::Wuxia.Events.addSectRel(_event.m.SectA, -20, this.List);

				local giftTxt = "";
				if (::Math.rand(1, 100) <= 50)
				{
					::Wuxia.Events.addMoney(180, this.List);
					giftTxt = "【" + sectB.Name + "】当家哈哈一笑，抛来一包散碎现银聊表谢意。";
				}
				else
				{
					::Wuxia.Events.givePill("wx_pill_jinchuang", this.List);
					giftTxt = "【" + sectB.Name + "】当家拍拍你们肩头，塞过一瓶贴身常备的外伤良药。";
				}

				this.Text = "[img]gfx/ui/events/wx_ev_13.png[/img]几名弟兄踩着桥栏斜跨一步，枪尖刀脊尽数指向桥西。【" + sectA.Name + "】弟子见硬拼必吃大亏，冷哼一声还刃归鞘，牵着驮骡阴沉退让，临走撂下一句『山水有相逢』。\n\n" + giftTxt;
			}
		});

		this.m.Screens.push({
			ID = "MediateBonus",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "相逢一笑，各自过桥。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sectA = ::Wuxia.Config.Sects[_event.m.SectA];
				local sectB = ::Wuxia.Config.Sects[_event.m.SectB];
				local med = _event.m.Mediator;
				if (::Wuxia.Events.isAlive(med)) this.Characters.push(med.getImagePath());

				::Wuxia.Events.addSectRel(_event.m.SectA, 10, this.List);
				::Wuxia.Events.addSectRel(_event.m.SectB, 10, this.List);
				::Wuxia.Events.addReputation(40, 0, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "桥头化干戈，两派皆敬三分", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_13.png[/img]" + ::Wuxia.Events.fmtName(med) + "空手踱到桥心，竟径直站在两排雪亮刃尖中间，不卑不亢地行了个江湖大礼。先赞【" + sectA.Name + "】气度，又抬【" + sectB.Name + "】名头，末了指着桥下浑浊溪水笑道：『两家都是有脸面的大字号，真为了两匹畜生磨破货袋在此见血，明儿岂不成了茶馆里说书人的笑料？不如卖我队一个薄面，各自收刃，先让骡子过桥。』\n\n话说到骨缝里，双方顺坡下驴，齐声喝彩还鞘。这桩体面做下来，两派竟都对你们刮目相看。";
			}
		});

		this.m.Screens.push({
			ID = "MediateNormal",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "继续前行。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sectA = ::Wuxia.Config.Sects[_event.m.SectA];
				local sectB = ::Wuxia.Config.Sects[_event.m.SectB];

				if (::Math.rand(1, 100) <= 65)
				{
					::Wuxia.Events.addSectRel(_event.m.SectA, 7, this.List);
					::Wuxia.Events.addSectRel(_event.m.SectB, 7, this.List);
					::Wuxia.Events.addReputation(25, 0, this.List);
					::Wuxia.Events.addCompanyMood(0.5, "桥头劝和，少见一场无妄血光", this.List);
					this.Text = "[img]gfx/ui/events/wx_ev_13.png[/img]你硬着头皮踏上石桥，两边各敬了一句好话，又示意弟兄们先替他们牵过受惊的驮骡。【" + sectA.Name + "】与【" + sectB.Name + "】本来就骑虎难下，如今有了外人圆场，彼此冷哼一声各自收兵，临走还不忘向你略一拱手。";
				}
				else
				{
					::Wuxia.Events.addReputation(10, 0, this.List);
					this.Text = "[img]gfx/ui/events/wx_ev_13.png[/img]你扯着嗓子劝了半晌，两家领头人谁也没搭理你的话茬，只拿眼角冷冷睨着你们。好在见你们人多势众、一时讨不着便宜，【" + sectA.Name + "】与【" + sectB.Name + "】僵持片刻后各自黑着脸撤下了石桥，总算没溅出一滴血来。";
				}
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::Wuxia.Events.getAliveBros().len() == 0) return;
		local pair = ::Wuxia.Events.pickSectPair();
		this.m.SectA = pair[0];
		this.m.SectB = pair[1];
		this.m.Mediator = ::Wuxia.Events.findByBackgrounds([
			"background.monk",
			"background.oathtaker",
			"background.paladin",
			"background.adventurous_noble"
		]);
		this.m.FallbackBro = ::Wuxia.Events.findRandomBro();
		this.m.Score = 16;
	}

	function onPrepare()
	{
		if (this.m.SectA == null || !(this.m.SectA in ::Wuxia.Config.Sects) || this.m.SectB == null || !(this.m.SectB in ::Wuxia.Config.Sects))
		{
			local pair = ::Wuxia.Events.pickSectPair();
			this.m.SectA = pair[0];
			this.m.SectB = pair[1];
		}
		if (!::Wuxia.Events.isAlive(this.m.Mediator))
		{
			this.m.Mediator = ::Wuxia.Events.findByBackgrounds([
				"background.monk",
				"background.oathtaker",
				"background.paladin",
				"background.adventurous_noble"
			]);
		}
		if (!::Wuxia.Events.isAlive(this.m.FallbackBro))
			this.m.FallbackBro = ::Wuxia.Events.findRandomBro();
	}

	function onPrepareVariables( _vars ) {}

	function onClear()
	{
		this.m.SectA = null;
		this.m.SectB = null;
		this.m.Mediator = null;
		this.m.FallbackBro = null;
	}
});
