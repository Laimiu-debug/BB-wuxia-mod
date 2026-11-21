// Batch E2 Event 19: 天桥百戏（卖艺人/西域舞伎/说书人在城集坊市亮艺讨彩）

this.wx_event_bg_juggler_market <- this.inherit("scripts/events/event", {
	m = {
		Performer = null
	},

	function create()
	{
		this.m.ID = "event.wx_bg_juggler_market";
		this.m.Title = "天桥百戏";
		this.m.Cooldown = 32.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "「铜锣敲起来！把这帮城里闲汉荷包里的碎银全抖出来！」",
					function getResult( _event ) { return "Perform"; }
				},
				{
					Text = "「把咱们的旗号顺势亮出去，借着人气办场招贤扬名的场子。」",
					function getResult( _event ) { return "RecruitShow"; }
				},
				{
					Text = "「咱们是刀口讨饭的，别在官府眼皮底下招摇过市。」",
					function getResult( _event ) { return "LowProfile"; }
				}
			],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Performer;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "那名百戏好手";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_32.png[/img]逢上大集，城中鼓楼前蒸笼白雾混着牲口尘土，看热闹的贩夫走卒挤得水泄不通。前头耍猴的班子刚收摊，留下一圈白灰画的空场子。\n\n" + bName + " 一见那圈白灰，十根手指立时痒得按捺不住——顺手抛起三枚寒光闪闪的短柳叶刃，翻腕抖出丈许红绸彩练，眉飞色舞凑到你跟前：『头儿，瞧见没？今儿集上商客财主扎堆，荷包鼓得直往下坠！准我下场亮两手天桥百戏，今晚满营弟兄的烧酒卤肉钱我全包圆了！』";
			}
		});

		this.m.Screens.push({
			ID = "Perform",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "今夜加菜添酒，痛快！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Performer;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "百戏好手";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				local gain = ::Math.rand(220, 340);
				::Wuxia.Events.addMoney(gain, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "坊市卖艺博得满堂彩，晚间加肉添酒", this.List);

				if (::Math.rand(0, 1) == 0)
					::Wuxia.Events.addStat(bro, "Initiative", 1, "身法", "ui/icons/initiative.png", this.List);
				else
					::Wuxia.Events.addStat(bro, "RangedSkill", 1, "暗器准头", "ui/icons/ranged_skill.png", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_32.png[/img]弟兄们借来面破铜锣敲了三响，眨眼间便围了三层人墙。只见 " + bName + " 腾身翻跃、彩绸翻飞，末了凌空甩出三口飞刀，「咄咄咄」连响三声，竟把抛到半空的青梨稳稳钉进两丈外的木桩正中，汁水都没溅到半步外的看客衣襟！\n\n满场轰然叫好，碎银铜钱雨点般砸进反扣在地上的旧铁盔里。收摊一清点，整整攒了 " + gain + " 银两，弟兄们拎着大块酱肘子回营，一路笑声不断。";
			}
		});

		this.m.Screens.push({
			ID = "RecruitShow",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "名声打出去了，买卖自然找上门。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Performer;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "百戏好手";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addReputation(35, 0, this.List);
				::Wuxia.Events.addMoney(120, this.List);
				::Wuxia.Events.addMood(bro, 0.75, "扬名坊市，体面风光", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_32.png[/img]你叫弟兄们擦亮兵甲抱刀立在场边压阵，" + bName + " 心领神会，耍完一通漂亮把式后并不急着伸手讨赏，反倒抱拳唱喏，顺口把队伍近来走镖斩匪的几桩事迹编成顺口溜说得眉飞色舞。\n\n虽然落进铁盔里的赏钱少了些，茶楼二层几个商帮东家与江湖牙人却频频颔首打探你们的落脚客栈，这趟招牌算是稳稳立起来了。";
			}
		});

		this.m.Screens.push({
			ID = "LowProfile",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "办完采买便出城。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Performer;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "百戏好手";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMood(bro, -0.5, "手痒难耐却未准登台", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_32.png[/img]你一把拎住 " + bName + " 后领拉出人群——街口两个提水火棍的税吏正东张西望呢，真要闹出大动静，赏钱还没捂热就得先孝敬衙门。他恋恋不舍地把短刃插回袖袋，一路走一路叹气。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Performer = null;
		if (!::Wuxia.Events.isWorldReady()) return;
		if (!::Wuxia.Events.isNearTown(4)) return;

		local bro = ::Wuxia.Events.findByBackgrounds([
			"background.juggler",
			"background.belly_dancer",
			"background.minstrel"
		]);
		if (bro == null) return;

		this.m.Performer = bro;
		this.m.Score = 17;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.Performer = null;
	}
});
