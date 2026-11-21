// Batch E3-36: 客栈换残页（江湖残谱收书人现身客栈，高价售卖上乘/绝学残页或酒桌论武）

this.wx_event_martial_page_exchange <- this.inherit("scripts/events/event", {
	m = {},

	function create()
	{
		this.m.ID = "event.wx_martial_page_exchange";
		this.m.Title = "客栈换残页";
		this.m.Cooldown = 20.0 * this.World.getTime().SecondsPerDay;

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

				local curMoney = ::World.Assets.getMoney();

				this.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]官道老客栈的煤烟熏黑了大梁，墙角偏桌却清静得古怪。一名缺了半只左耳、披着泛碱旧毡袍的疤脸行客，正把一张油光锃亮的鹿皮铺在油腻桌面，拿四枚铜镇纸压住几页水渍斑驳的泛黄纸片。\n\n有的残页边缘焦黑卷曲，像是从大火烧塌的藏经阁里抢出来的；有的角落还沁着暗褐旧血印。那人指节敲了敲桌面，头也不抬地沙哑道：『庸人只认整册金装秘籍，殊不知乱世里真传早碎成了断章残页。凑得齐，便是安身立命的绝学——诸位手里若有现银，挑上一页，或是请我吃壶热酒盘盘江湖各派路数，也行。』";

				this.Options.push({
					Text = "花 420 银两买下一张「门派上乘」武学残页",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 420) return "NoMoney";
						return "BuySectPage";
					}
				});

				if (curMoney >= 920)
				{
					this.Options.push({
						Text = "豪掷 920 银两买下他压箱底的「镇派绝学」稀世残页！",
						function getResult( _ev )
						{
							if (::World.Assets.getMoney() < 920) return "NoMoney";
							return "BuySecretPage";
						}
					});
				}

				this.Options.push({
					Text = "花 160 银两叫两斤酱牛肉与烫老酒，同他彻夜盘道论武（全队 +45 火候）",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 160) return "NoMoney";
						return "WineLore";
					}
				});

				this.Options.push({
					Text = "旧纸残章水太深，拱手告辞回座。",
					function getResult( _ev ) { return "Decline"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "BuySectPage",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "仔细夹入油纸袋收好。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				this.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]你点出 420 银两推过去。独耳书客拿指腹摩挲过银锭边缘，干脆利落地抽出一页墨迹犹劲的门派真传残页，用油纸折妥递来：『货真价实，凑够残页便是整本上乘功夫，莫叫老鼠啃了。』";

				::Wuxia.Events.addMoney(-420, this.List);
				::Wuxia.Events.givePage("sect", 1, this.List);
			}
		});

		this.m.Screens.push({
			ID = "BuySecretPage",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "此页千金不换，速速离开客栈！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				this.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]见你毫不犹豫拍出 920 两沉甸甸的现银，独耳书客浑浊眼珠终于闪过一丝讶色。他解开贴身夹袄，从一只防潮竹筒里小心抽出一张金丝绢纸残页——墨痕如龙蛇盘走，仅瞥一眼便觉杀机扑面。\n\n银货两讫，对方收起鹿皮便头也不回地融进夜雨里。你们也压低斗笠，将这页稀世绝学残章藏进了最稳妥的暗袋。";

				::Wuxia.Events.addMoney(-920, this.List);
				::Wuxia.Events.givePage("secret", 1, this.List);
			}
		});

		this.m.Screens.push({
			ID = "WineLore",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "听君一席话，胜练半年功！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				this.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]两斤切得厚实的酱牛肉配三大壶滚烫黄酒端上桌，独耳书客的话匣子顿时打开。他年轻时走遍南北十三省收集残谱，虽自废武功不再动刀，嘴里吐出的全是各大门派的招式破绽、换气暗窍与借劲秘诀。\n\n满桌弟兄连筷子都顾不上动，听得屏息凝神，彼此对照着各自修习的功法频频点头，直到酒坛见底仍觉意犹未尽！";

				::Wuxia.Events.addMoney(-160, this.List);
				::Wuxia.Events.addCompanyMastery(45, this.List);
			}
		});

		this.m.Screens.push({
			ID = "Decline",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "各安天命，回房歇息。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]独耳书客不以为意地哼了一声，慢条斯理卷起油鹿皮，独自抿起了桌上那杯早已冷透的粗茶。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "改日备足现银再会。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]你摸了摸腰囊，现银尚差几分火候。独耳书客瞥了一眼，面无表情地把铜镇纸一收，将残页重新卷回油鹿皮里：『江湖残篇不讲赊欠，备齐银两再来吧。』";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::World.getTime().Days < 10) return;
		if (::World.Assets.getMoney() < 400) return;

		this.m.Score = 15;
	}

	function onClear()
	{
	}
});
