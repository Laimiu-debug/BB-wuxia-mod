// Batch E3-32: 山野炼丹炉（松林野道开炉售丹，稳购良药或赌一枚无签试炉丹）

this.wx_event_martial_herbalist_cauldron <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_martial_herbalist_cauldron";
		this.m.Title = "山野炼丹炉";
		this.m.Cooldown = 18.0 * this.World.getTime().SecondsPerDay;

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

				this.Text = "[img]gfx/ui/events/wx_ev_12.png[/img]松林洼地里飘出一缕辛辣青烟，混着浓烈的苦当归、焦硫磺与陈米酒味。转过乱石一看，一名眉毛被火燎焦了半截的灰袍野道，正拿蒲扇拼命扇着一只打满铁铆钉补丁的破铜丹炉。\n\n听见脚步声，道士抬手在鼻梁上抹出两道黑炭印子，嘿嘿笑着摇响手里几只蜡封小瓷瓶：『无量天尊！贫道今儿运气不错，残火竟没炸炉，还多出几粒成丹。正缺银两买炭买米，几位走江湖的施主可要挑上一颗防身？』";

				this.Options.push({
					Text = "花 280 银两买下「护心丹」（立解内伤与散功虚弱）",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 280) return "NoMoney";
						return "BuyHuxin";
					}
				});

				this.Options.push({
					Text = "花 420 银两买下「凝神丸」（直接灌注 +150 武学火候）",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 420) return "NoMoney";
						return "BuyNingshen";
					}
				});

				this.Options.push({
					Text = "花 140 银两图便宜，赌一把他袖口那枚没贴签的「试炉野丹」！",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 140) return "NoMoney";
						return ::Math.rand(1, 100) <= 70 ? "GambleWin" : "GambleStomach";
					}
				});

				this.Options.push({
					Text = "野道炉丹鬼知道掺了什么草灰，拱手别过。",
					function getResult( _ev ) { return "MoveOn"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "BuyHuxin",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "妥善收进药囊。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_12.png[/img]你点清 280 两现银交过去。野道喜滋滋咬了口碎银验成色，郑重递上一粒温润清香的「护心丹」：『保准是正经朱砂川芎炼的，受了内家暗伤服下一粒，立马舒坦！』";

				::Wuxia.Events.addMoney(-280, this.List);
				::Wuxia.Events.givePill("wx_pill_huxin", this.List);
			}
		});

		this.m.Screens.push({
			ID = "BuyNingshen",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "好丹难求，多谢道长。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_12.png[/img]野道接过 420 银两，心疼地摸了摸小瓷瓶才交到你掌心。打开蜡封一闻，清冽松柏药香直透天灵，确实是难得的「凝神丸」成丹。";

				::Wuxia.Events.addMoney(-420, this.List);
				::Wuxia.Events.givePill("wx_pill_ningshen", this.List);
			}
		});

		this.m.Screens.push({
			ID = "GambleWin",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "白捡个大便宜，赶紧走人！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local pool = ["wx_pill_hugu", "wx_pill_huoluo", "wx_pill_qingxin"];
				local pickedID = pool[::Math.rand(0, pool.len() - 1)];
				local pName = (pickedID in ::Wuxia.Config.Pills) ? ::Wuxia.Config.Pills[pickedID].Name : "上等灵丹";

				this.Text = "[img]gfx/ui/events/wx_ev_12.png[/img]银货刚交割，你拿指腹蹭去瓷瓶底积着的一层炉灰，露出一枚暗红篆字暗印。野道凑过来眯眼一瞧，顿时拍着大腿哎哟直叫：『坏了坏了！贫道老眼昏花，竟把前日压箱底炼成的「" + pName + "」当成试炉废丹便宜卖给你们了！』\n\n你笑眯眯把瓶塞按死揣入怀中，冲着直跳脚的老道抱了抱拳，领着弟兄扬长而去。";

				::Wuxia.Events.addMoney(-140, this.List);
				::Wuxia.Events.givePill(pickedID, this.List);
			}
		});

		this.m.Screens.push({
			ID = "GambleStomach",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "下回再贪便宜，先拿这老道试药！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_12.png[/img]刚掏完 140 银两，" + bName + "好奇心起，抠了一丁点黑漆漆的丹渣放嘴里辨味。没过三息，他肚子里便轰隆隆滚起连串雷鸣，脸瞬间憋成了猪肝色，捂着肚子惨叫一声一头扎进了松树丛里！\n\n野道一看出了洋相，臊得满脸通红，连声念着罪过，慌忙塞过一包「金疮散」赔礼道歉，抱起破蒲扇一溜烟逃往山坳深处去了。";

				::Wuxia.Events.addMoney(-140, this.List);
				::Wuxia.Events.addMood(bro, -0.8, "误尝野道试炉黑丹，腹痛如绞", this.List);
				::Wuxia.Events.givePill("wx_pill_jinchuang", this.List);
			}
		});

		this.m.Screens.push({
			ID = "MoveOn",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "离那座快炸的铜炉远点。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_12.png[/img]你们绕开呛鼻的硫磺青烟继续赶路。刚走出半里地，身后松林里忽然闷响一声，一团乌黑浓烟直冲树冠，夹杂着野道撕心裂肺的哀嚎——还好没买他的丹。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "囊中羞涩，改日再说。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_12.png[/img]清点了一番银袋，眼下现银不够数。野道摇摇头把蜡封药瓶全数塞回破道袍里，继续低头专心扇他的破铜炉去了。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;

		this.m.Bro = bro;
		this.m.Score = 15;
	}

	function onClear()
	{
		this.m.Bro = null;
	}
});
