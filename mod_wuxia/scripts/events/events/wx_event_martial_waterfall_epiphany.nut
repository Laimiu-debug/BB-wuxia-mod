// Batch E3-31: 寒潭悟剑（行经绝壁飞瀑，观水流破石而悟武学真意）

this.wx_event_martial_waterfall_epiphany <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_martial_waterfall_epiphany";
		this.m.Title = "寒潭悟剑";
		this.m.Cooldown = 22.0 * this.World.getTime().SecondsPerDay;

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

				local bName = ::Wuxia.Events.fmtName(bro);
				local manName = ::Wuxia.Events.pickManualName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_10.png[/img]山径拐过一处峭壁，轰隆水声震得人耳膜生疼。一道白练般的雪水飞瀑自三丈高崖倾泻而下，狠狠砸入墨绿寒潭，溅起的冷雾湿透了马鞍。\n\n走到独木桥半途，" + bName + "却忽然钉在原地不肯挪步，连后头驮马拱着他后背也浑然未觉。顺着他呆滞的目光望去，只见潭心一块长满青苔的尖棱顽石迎着狂瀑而立，急流撞上石锋竟似锦帛遇刃般滑溜溜分向两侧，绕过石背又猛地绞合回卷！" + bName + "的右手不自觉抬起，对着湿冷水雾虚虚划出" + manName + "的起手弧线，神情竟已入定。";

				this.Options.push({
					Text = "难得遇此机缘！下令就地扎营半日，替他护法安心参悟水势。",
					function getResult( _ev ) { return "HaltComprehend"; }
				});

				this.Options.push({
					Text = "给一炷香工夫在潭畔演练几趟，切莫耽搁行程。",
					function getResult( _ev ) { return "BriefPractice"; }
				});

				this.Options.push({
					Text = "山峡雾寒、夜长梦多，拍醒他继续赶路。",
					function getResult( _ev ) { return "KeepMarching"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "HaltComprehend",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "这半日歇脚，抵得上苦练三个月！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);
				local manName = ::Wuxia.Events.pickManualName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_10.png[/img]你挥手示意队伍卸鞍生火，谁也不许高声喧哗。" + bName + "一袭单衣站在滑溜溜的苔石上，任凭冰冷潭雾打湿眉睫，从日头偏西一直演练到暮色沉渊。起初招式滞涩生硬，随着一遍遍顺应瀑水冲刷的劲路微调，" + manName + "的攻守衔接骤然圆融如水，一劈一收间竟隐隐带起细碎风啸！\n\n岸边围着火堆静观的弟兄们也各自若有所悟，有人拿树枝在泥地上画起回水漩涡，整支队伍的武学火候都随之往上蹿了一截。";

				::Wuxia.Events.addMastery(bro, 95, this.List);
				::Wuxia.Events.addCompanyMastery(25, this.List);
				::Wuxia.Events.addMood(bro, 1.0, "寒潭观瀑，豁然贯通招式流转之妙", this.List);
			}
		});

		this.m.Screens.push({
			ID = "BriefPractice",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "抓紧擦干湿衣，动身吧。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);
				local manName = ::Wuxia.Events.pickManualName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_10.png[/img]你只准歇马一炷香。" + bName + "赶忙抽出兵刃，对着轰鸣水声将" + manName + "紧赶慢赶走了三遍。虽没能参透那股水石相搏的全部奥妙，却也抓住了几分以柔借力、顺势化劲的灵光，收兵时满脸水珠却眼神发亮。";

				::Wuxia.Events.addMastery(bro, 45, this.List);
			}
		});

		this.m.Screens.push({
			ID = "KeepMarching",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "留得青山在，以后再看瀑布。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_10.png[/img]你上前重重拍了拍" + bName + "肩头。他恍然回神，依依不舍地回头又望了一眼白练般的寒潭飞瀑，长长呼出一口白雾，到底还是勒紧包裹跟上了队伍。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		local bro = ::Wuxia.Events.findBroWithManual(null);
		if (bro == null) return;

		this.m.Bro = bro;
		this.m.Score = 14;
	}

	function onClear()
	{
		this.m.Bro = null;
	}
});
