// Sequential Jianghu Event Chain 1 (Stage 1/3): 残卷血案 · 孤驿托孤
this.wx_event_chain_scroll_1 <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_chain_scroll_1";
		this.m.Title = "残卷血案（一）· 孤驿血封";
		this.m.Cooldown = 999.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "「放心去吧，这封血卷我们替你护住，决不落入宵小之手！」",
					function getResult( _ev ) { return "AcceptHonor"; }
				},
				{
					Text = "「死人带不走秘籍——收下血卷，火化名帖，此事莫对旁人声张。」",
					function getResult( _ev ) { return "KeepSecret"; }
				},
				{
					Text = "「无妄血祸莫要沾身，入土为安便罢。」",
					function getResult( _ev ) { return "Decline"; }
				}
			],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.Bro;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "守夜弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]暮雨潇潇，你们刚在荒野破驿燃起篝火，一名胸口插着三支透骨黑羽箭的青衣信使便踉跄扑倒在门廊下。他气若游丝，死死攥住 " + bName + " 的衣襟，从怀里掏出一卷以蜡油和血印封口的明黄素绢。\n\n『幽冥楼……追杀三百里……此卷关乎名门秘传图谱……求诸位大侠莫让恶贼得逞……』话音未落，信使便咽了气，唯余那卷透着奇异药香与剑意暗纹的血封残卷静静躺在掌心。";
			}
		});

		this.m.Screens.push({
			ID = "AcceptHonor",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "妥善收好血封残卷，明日加紧戒备。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::World.Flags.set("wx_chain_scroll", 1);
				::World.Flags.set("wx_chain_scroll_day", ::World.getTime().Days);
				::Wuxia.Events.givePage("sect", 1, this.List);
				::Wuxia.Events.addReputation(20, 12, this.List);
				::Wuxia.Events.addCompanyMood(0.5, "侠肝义胆受托护卷", this.List);
				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]你们替青衣信使掩埋尸骨、立下无名木碑，郑重收起那封尚带余温的血印残卷。虽知前路必有暗杀追兵闻风而来，众弟兄反倒添了几分仗剑行侠的豪气。";
			}
		});

		this.m.Screens.push({
			ID = "KeepSecret",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "抹去痕迹，连夜拔营。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::World.Flags.set("wx_chain_scroll", 2);
				::World.Flags.set("wx_chain_scroll_day", ::World.getTime().Days);
				::Wuxia.Events.givePage("sect", 1, this.List);
				::Wuxia.Events.addMoney(150, this.List);
				::Wuxia.Events.addReputation(0, -8, this.List);
				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]你们将信使腰间散碎盘缠与血封残卷一并收入囊中，顺手将门派腰牌丢进篝火烧作灰烬。只是风声既已走漏，盯上这卷残谱的黑道高手迟早会顺着踪迹寻来。";
			}
		});

		this.m.Screens.push({
			ID = "Decline",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "多一事不如少一事，继续赶路。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::World.Flags.set("wx_chain_scroll", 9);
				::Wuxia.Events.addReputation(0, 6, this.List);
				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]你们将血卷随信使一并深埋古驿后院，拂袖而去。江湖风波诡谲，明哲保身有时亦是上策。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Bro = null;
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::World.getTime().Days < 8) return;
		if (::World.Flags.getAsInt("wx_chain_scroll") != 0) return;

		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;
		this.m.Bro = bro;
		this.m.Score = 24;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear() { this.m.Bro = null; }
});
