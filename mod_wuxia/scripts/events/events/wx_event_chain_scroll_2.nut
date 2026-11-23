// Sequential Jianghu Event Chain 1 (Stage 2/3): 残卷血案 · 截道暗刺
this.wx_event_chain_scroll_2 <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_chain_scroll_2";
		this.m.Title = "残卷血案（二）· 幽冥截道";
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
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "前锋好手";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Options.push({
					Text = "「藏头露尾的鼠辈！拔刀结阵，杀他们个片甲不留！」",
					function getResult( _ev ) { return "FightOff"; }
				});
				if (::World.Assets.getMoney() >= 250)
				{
					this.Options.push({
						Text = "「掏 250 两买路钱加一卷伪造抄本，先将这批杀手糊弄走！」",
						function getResult( _ev ) { return "BribeDecoy"; }
					});
				}

				this.Text = "[img]gfx/ui/events/wx_ev_09.png[/img]峡谷浓雾未散，两侧枯松之上骤然落下七八道玄黑身影，寒芒森森的柳叶飞刀封死了退路！为首的青铜面具杀手冷笑开口：\n\n『幽冥隐杀楼办事！数日前那名断气信使留下的血封残卷，交出来饶尔等全尸；否则今日便将你们全数葬在此谷！』" + bName + " 霍然按住刀柄，低声道：『看他们身法轻飘，必是先行探路的暗哨，打或骗须早作决断！』";
			}
		});

		this.m.Screens.push({
			ID = "FightOff",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "收缴残页与密信，速离是非之地！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::World.Flags.set("wx_chain_scroll", 3);
				::World.Flags.set("wx_chain_scroll_day", ::World.getTime().Days);
				::Wuxia.Events.applyLightHurt(bro, 0.14, this.List);
				::Wuxia.Events.addMoney(350, this.List);
				::Wuxia.Events.givePage("secret", 1, this.List);
				::Wuxia.Events.addCompanyMastery(60, this.List);
				::Wuxia.Events.addSectRel("yinsha", -10, this.List);
				::Wuxia.Events.addReputation(35, 8, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_09.png[/img]一声暴喝，众弟兄反客为主抢先突袭！暗哨杀手本以为你们只是寻常商旅，措手不及间连折三名好手，其余人见势不妙急忙掷出烟弹遁入密林。你们虽有轻伤，却从杀手怀中搜出了半张破译血卷经脉暗语的密匙与一袋赏银！";
			}
		});

		this.m.Screens.push({
			ID = "BribeDecoy",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "趁夜色疾行，尽快参透真卷！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::World.Flags.set("wx_chain_scroll", 3);
				::World.Flags.set("wx_chain_scroll_day", ::World.getTime().Days);
				::Wuxia.Events.addMoney(-250, this.List);
				::Wuxia.Events.addSectRel("yinsha", 5, this.List);
				::Wuxia.Events.givePage("sect", 1, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_09.png[/img]你不动声色捧出早已临摹半真的赝品残卷与二百五十两纹银，笑称愿与幽冥楼交个朋友。青铜面具杀手在雾色中草草验过蜡印便收银退走，还顺手留下一枚暗道记号——却不知真正的血封原卷仍稳稳藏在你们行囊夹层之中！";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Bro = null;
		if (!::Wuxia.Events.isWorldReady()) return;
		local st = ::World.Flags.getAsInt("wx_chain_scroll");
		if (st != 1 && st != 2) return;
		local lastDay = ::World.Flags.getAsInt("wx_chain_scroll_day");
		if (::World.getTime().Days < lastDay + 8) return;

		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;
		this.m.Bro = bro;
		this.m.Score = 30;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear() { this.m.Bro = null; }
});
