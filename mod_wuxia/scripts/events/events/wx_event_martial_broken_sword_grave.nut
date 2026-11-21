// Batch E3-34: 荒山剑冢（孤峰残剑冢前参悟石壁剑痕，或掘冢盗取前人遗物）

this.wx_event_martial_broken_sword_grave <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_martial_broken_sword_grave";
		this.m.Title = "荒山剑冢";
		this.m.Cooldown = 28.0 * this.World.getTime().SecondsPerDay;

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

				local bShort = ::Wuxia.Events.shortName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_10.png[/img]凛冽山风刮过荒秃岭脊，将枯黄茅草压得紧贴红土。岗顶赫然隆起一座无名荒冢，坟头斜插着三四十口早已锈蚀起皮的断剑、豁口厚背刀与折戟，冷风穿过残刃缺口，竟发出低沉如泣的细碎铁鸣。\n\n坟前歪斜半埋着一块裂成两截的青石碑，苔藓缝里仍能辨出九个力透石背的狂草大字：『生平求一败而不可得』。石碑后方那面黑岩陡壁上，密密麻麻刻满纵横交错的陈年剑沟，深达半寸，凌厉杀气历经数十年风雨犹未散尽。";

				this.Options.push({
					Text = "点三炷野香拜过前辈，令 " + bShort + " 贴近岩壁临摹观摩剑痕。",
					function getResult( _ev ) { return "StudyWall"; }
				});

				this.Options.push({
					Text = "死人留着剑冢作甚？撬开压碑青石，看看底下可埋着精铁与财帛。",
					function getResult( _ev ) { return "LootGrave"; }
				});

				this.Options.push({
					Text = "率众抱拳肃立片刻，不惊扰前朝剑客长眠。",
					function getResult( _ev ) { return "BowLeave"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "StudyWall",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "好狠的一手剑意，拜别前辈！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);
				local manName = ::Wuxia.Events.pickManualName(bro, "waigong");
				if (manName == "随身武艺") manName = ::Wuxia.Events.pickManualName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_10.png[/img]众人割草清去碑前浮土，插上三根枯艾权作心香。" + bName + "蹲在黑岩壁前，拿布满老茧的指腹顺着最深那道斜削剑痕一路摸索，忽地眼睛一亮——那道裂石沟壑并非蛮力硬劈，而是在锋刃入石三分后凭寸劲猛然抖腕震裂！\n\n他当即抽兵对照着" + manName + "虚劈数记，只觉昔日死板的发力关窍陡然打通，胸中更升起一股敢向天下强敌亮刃的豪气。其余弟兄围观这满壁遗痕，也都各自揣摩出几分进退章法。";

				::Wuxia.Events.addMastery(bro, 70, this.List);
				::Wuxia.Events.addStat(bro, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);
				::Wuxia.Events.addCompanyMastery(20, this.List);
			}
		});

		this.m.Screens.push({
			ID = "LootGrave",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "背上东西赶紧下山！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.Bro)) this.Characters.push(_event.m.Bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_10.png[/img]几名弟兄抡起长矛撬棍，费力掀翻了压在碑底的厚石板。潮湿墓穴里并没有什么黄金满箱，只躺着一具早已风化的枯骨，身畔散落着几锭发黑的旧银锞子，以及一堆当年拆自名剑宝刀、至今尚未锈烂的百炼铁件与修甲精料。\n\n刚把东西装入麻袋，岗顶一阵凄厉阴风骤起，坟头一柄锈剑竟咔嚓拦腰折断，发出似叹非啸的凄鸣。大伙儿脊背齐齐发凉，谁也没敢回头多看一眼，埋头匆匆下了荒山。";

				::Wuxia.Events.addMoney(180, this.List);
				::Wuxia.Events.addSupplies(12, 0, 0, this.List);
				::Wuxia.Events.addReputation(0, -5, this.List);
				::Wuxia.Events.addCompanyMood(-0.6, "掘开前辈荒山剑冢，阴风刺骨令众人心中发毛", this.List);
			}
		});

		this.m.Screens.push({
			ID = "BowLeave",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "江湖路远，后会有期。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_10.png[/img]你抬手示意队伍止步，对着那块断碑与满岗锈刃郑重抱了一拳。昔年纵横一世的剑客终归化作一抔荒土，你们沿着风声呼啸的山梁默然远去。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		local bro = ::Wuxia.Events.findBroWithManual("waigong");
		if (bro == null) bro = ::Wuxia.Events.findBroWithManual(null);
		if (bro == null) bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;

		this.m.Bro = bro;
		this.m.Score = 13;
	}

	function onClear()
	{
		this.m.Bro = null;
	}
});
