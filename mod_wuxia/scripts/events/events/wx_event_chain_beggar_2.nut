// Sequential Jianghu Event Chain 2 (Stage 2/3): 无名老丐传艺 · 长街仗义
this.wx_event_chain_beggar_2 <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_chain_beggar_2";
		this.m.Title = "无名老丐（二）· 渡口护老";
		this.m.Cooldown = 999.0 * this.World.getTime().SecondsPerDay;

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
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "同袍";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Options.push({
					Text = "「光天化日欺凌老弱？" + ::Wuxia.Events.shortName(bro) + "，把这帮泼皮给我扔进河里！」",
					function getResult( _ev ) { return "DefendBeggar"; }
				});
				if (::World.Assets.getMoney() >= 120)
				{
					this.Options.push({
						Text = "「扔给地痞一百二十两酒钱息事宁人，护送老丐离开渡口。」",
						function getResult( _ev ) { return "PayOff"; }
					});
				}

				this.Text = "[img]gfx/ui/events/wx_ev_05.png[/img]渡口石阶上忽起喧哗——几名腰佩铁尺的漕帮恶少正围着那名曾与你们把酒言欢的九指老丐拳打脚踢，还一脚踢碎了他的破酒葫芦！老丐蜷身护头却始终未还半招，倒似在有意忍让。" + bName + " 一眼认出故人，眉峰倒竖，手已搭上兵刃！";
			}
		});

		this.m.Screens.push({
			ID = "DefendBeggar",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "替老人家买只新葫芦，后会有期！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::World.Flags.set("wx_chain_beggar", 2);
				::World.Flags.set("wx_chain_beggar_day", ::World.getTime().Days);
				::Wuxia.Events.addSectRel("gaibang", 15, this.List);
				::Wuxia.Events.addReputation(30, 12, this.List);
				::Wuxia.Events.addMastery(bro, 55, this.List);
				::Wuxia.Events.givePill("wx_pill_huoluo", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_05.png[/img]你们大步上前三拳两脚便将几个仗势欺人的恶少震得滚地求饶、抱头鼠窜！老丐拍拍衣襟起身，竟丝毫无损，只深深看了你们一眼，塞来一瓶家传活络丹：『好小子，两番相助皆是真性情！再过些时日，老叫花子定找一处清静松林，请诸位看一场真功夫！』";
			}
		});

		this.m.Screens.push({
			ID = "PayOff",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "平安脱身便好。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::World.Flags.set("wx_chain_beggar", 2);
				::World.Flags.set("wx_chain_beggar_day", ::World.getTime().Days);
				::Wuxia.Events.addMoney(-120, this.List);
				::Wuxia.Events.addSectRel("gaibang", 10, this.List);
				::Wuxia.Events.addReputation(15, 8, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_05.png[/img]你抛出一串银钱打发走贪财地痞，搀扶老丐避入茶巷。老丐摇摇头叹道：『既肯散财护人，又不喜滥杀生事，难得！日后月圆之夜，老叫花子必登门回礼！』";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Bro = null;
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::World.Flags.getAsInt("wx_chain_beggar") != 1) return;
		local lastDay = ::World.Flags.getAsInt("wx_chain_beggar_day");
		if (::World.getTime().Days < lastDay + 10) return;

		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;
		this.m.Bro = bro;
		this.m.Score = 30;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear() { this.m.Bro = null; }
});
