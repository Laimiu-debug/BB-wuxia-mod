// Batch E1 Event 04: 暗针衬甲（巧手裁缝以马尾鬃与桐油绢连夜修补加固全队甲衬）

this.wx_event_camp_tailor_lining <- this.inherit("scripts/events/event", {
	m = {
		BroA = null
	},

	function create()
	{
		this.m.ID = "event.wx_camp_tailor_lining";
		this.m.Title = "暗针衬甲";
		this.m.Cooldown = 36.0 * this.World.getTime().SecondsPerDay;

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

				this.Text = "[img]gfx/ui/events/wx_ev_30.png[/img]一连赶了几日湿路，铁片皮甲里的旧麻衬早被汗水沤出了霉味，磨得弟兄们锁骨与腋下血肉模糊。入夜后，" + nameA + " 盘腿坐在豆大油灯旁，拇指套着一枚发黄的骨顶针，翻检着一件豁了口的护肩直摇头：\n\n『诸位身上的甲叶是好铁，可这里衬缝得跟叫花子破袄一样！真挨上一记重棍，铁片没裂，震劲先叫人吐血。白天路过道口货郎担，我瞧见两捆上好的黑马尾鬃与生桐油双层绢——东家若是肯出 120 两银子置办下来，我连夜拿三股麻筋给全队把甲衬、护肘与皮带扣全密缝加固一遍，顺带还能省出一大包修甲零料。』\n\n说完，他揉了揉微红的眼眶，静候你的决断。";

				this.Options = [
					{
						Text = "拨 120 银两买齐马尾鬃与油绢，请师傅连夜替全队衬甲！",
						function getResult( _event )
						{
							if (::World.Assets.getMoney() < 120) return "NoMoney";
							return "Reinforce";
						}
					},
					{
						Text = "银钱紧巴，不必买新料——拿营里旧布把破披风与衣裆补补就成。",
						function getResult( _event ) { return "MendFree"; }
					},
					{
						Text = "黑灯瞎火别熬瞎了招子，收起针线早些歇着吧。",
						function getResult( _event ) { return "RestEyes"; }
					}
				];
			}
		});

		this.m.Screens.push({
			ID = "Reinforce",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "穿得服帖，杀敌才更利落。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addMoney(-120, this.List);
				::Wuxia.Events.addSupplies(18, 0, 0, this.List);
				::Wuxia.Events.addCompanyMood(1.0, "甲胄暗衬服帖轻便", this.List);
				::Wuxia.Events.addStat(_event.m.BroA, "Initiative", 1, "身法", "ui/icons/initiative.png", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_30.png[/img]钢针穿油绢的沙沙声响了一整夜。天边泛起鱼肚白时，一排排洗去锈泥、内垫厚实马尾鬃与防潮桐油绢的甲胄整齐码在车辕旁，原本勒肉的皮扣全换成了顺滑熟牛筋，裁剩下的铆钉与厚革角料也整整齐齐收进了器械箱。\n\n众弟兄试穿起身，只觉沉重铁甲竟凭空轻快了三分，肩肘转折再不卡顿。" + nameA + " 吹熄油灯伸了个懒腰，这一夜穿针引线，倒把十指灵巧劲又练出几分火候。";
			}
		});

		this.m.Screens.push({
			ID = "MendFree",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "出门在外，一件不透风的旧袄便抵半条命。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addCompanyMood(0.75, "破衣烂袄缝补得严严实实", this.List);
				::Wuxia.Events.addMood(_event.m.BroA, 0.5, "针线手艺派上了用场", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_30.png[/img]" + nameA + " 啧了一声，也不嫌寒酸，抱起众人扔在角落的撕裂披风、绽线裤裆与磨穿脚跟的粗布袜，就着火堆细细缝补起来。\n\n虽没添置新甲衬，可清晨迎着山风起行时，大伙再也不用缩着脖子挨冷风往脊梁骨里钻，个个嘴上都念着裁缝的好。";
			}
		});

		this.m.Screens.push({
			ID = "RestEyes",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "留得双眼在，日后再细做。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addMood(_event.m.BroA, 0.75, "得东家体恤早早歇息", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_30.png[/img]" + nameA + " 闻言松了口气，利索将钢针插回破布包，骨顶针揣入怀里，吹灭冒黑烟的菜油灯：『东家体谅，熬坏了招子明日可真看不清箭往哪儿飞。』说罢拉过毡毯安生歇去了。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "另想他法。", function getResult( _event ) { return "A"; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_30.png[/img]你摸了摸干瘪的钱袋，竟凑不齐 120 两现银置办马尾鬃与油绢，只好再作权衡。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		this.m.BroA = null;

		local tailor = ::Wuxia.Events.findByBackgrounds(["background.tailor"]);
		if (tailor == null) return;

		this.m.BroA = tailor;
		this.m.Score = 16;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.BroA))
			this.m.BroA = ::Wuxia.Events.findByBackgrounds(["background.tailor"]);
	}

	function onPrepareVariables( _vars )
	{
		_vars.push(["tailor", ::Wuxia.Events.shortName(this.m.BroA)]);
	}

	function onClear()
	{
		this.m.BroA = null;
	}
});
