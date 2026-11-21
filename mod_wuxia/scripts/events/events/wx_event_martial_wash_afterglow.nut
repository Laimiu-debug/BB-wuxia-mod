// Batch E3-28: 洗髓脱胎（服用洗髓丹数周后的筋骨蜕变余韵）

this.wx_event_martial_wash_afterglow <- this.inherit("scripts/events/event", {
	m = {
		Bro = null,
		Rookie = null
	},

	function create()
	{
		this.m.ID = "event.wx_martial_wash_afterglow";
		this.m.Title = "洗髓脱胎";
		this.m.Cooldown = 45.0 * this.World.getTime().SecondsPerDay;

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
				local rookie = _event.m.Rookie;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				if (::Wuxia.Events.isAlive(rookie)) this.Characters.push(rookie.getImagePath());

				local bName = ::Wuxia.Events.fmtName(bro);
				local manName = ::Wuxia.Events.pickManualName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_07.png[/img]五更霜重，帐篷绳索上挂满白露。营地外忽然响起一连串炒豆子般的脆响，清越得像干竹节在炭炉里爆开。你撩帘望去，只见" + bName + "赤足立在湿草里沉腰扎桩，随着一呼一吸运转" + manName + "，肩背毛孔竟渗出一层带着淡淡松脂与铁锈腥气的灰黑油汗。\n\n昔日洗经伐髓留下的药力，时隔数周终于彻底化开，将滞留在骨缝里的陈年浊垢逼了出来——筋骨齐鸣、气血翻涌，正是脱胎换骨的绝佳火候！";

				this.Options.push({
					Text = "趁药力余韵澎湃，令其守神导引、尽数炼入自身经脉！",
					function getResult( _ev ) { return "ChannelSurge"; }
				});

				if (::Wuxia.Events.isAlive(rookie))
				{
					local rName = ::Wuxia.Events.shortName(rookie);
					this.Options.push({
						Text = "唤来 " + rName + " 在旁观摩换气节奏，趁热传些行功心得。",
						function getResult( _ev ) { return "ShareRookie"; }
					});
				}

				this.Options.push({
					Text = "过犹不及，嘱其从容收功，保住一颗平常心。",
					function getResult( _ev ) { return "CalmHeart"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "ChannelSurge",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "脱胎换骨，真是造化！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);

				local gainStam = (::Math.rand(0, 1) == 0);
				if (gainStam)
				{
					this.Text = "[img]gfx/ui/events/wx_ev_07.png[/img]" + bName + "闻言闭目沉肩，顺着筋骨酥麻的暖流徐徐吐纳。每一口白雾呼出皆如长枪贯空，足足延绵三尺不散；待日头跃出山脊，周身浊汗已被朝风吹干，原本紧滞的肺腑宽阔了不止一分，连提气回息都比往日绵长许多。\n\n满营早起的弟兄亲眼见识这等武道奇景，个个看得热血沸腾，纷纷摸起兵器照着方才的桩架比划起来。";
					::Wuxia.Events.addMastery(bro, 90, this.List);
					::Wuxia.Events.addStat(bro, "Stamina", 1, "内息上限", "ui/icons/fatigue.png", this.List);
				}
				else
				{
					this.Text = "[img]gfx/ui/events/wx_ev_07.png[/img]" + bName + "闻言沉膝坐胯，任由那股滚烫余韵冲刷四肢百骸。脊柱如大龙般节节伸展，发出一声浑厚低鸣；待收功站直，整个人虽未增胖半分，肌理却紧实如老藤盘石，气血丰沛得连手背青筋都隐隐透着温热。\n\n满营弟兄亲眼目睹同袍洗髓脱胎，人人振奋不已，趁着晨风操演起各自招式，竟皆有所得。";
					::Wuxia.Events.addMastery(bro, 90, this.List);
					::Wuxia.Events.addStat(bro, "Hitpoints", 1, "气血上限", "ui/icons/health.png", this.List);
				}

				::Wuxia.Events.addCompanyMood(0.75, "目睹同袍洗髓脱胎，全队精神大振", this.List);
				::Wuxia.Events.addCompanyMastery(25, this.List);
			}
		});

		this.m.Screens.push({
			ID = "ShareRookie",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "同袍相携，方能在江湖站稳脚跟。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				local rookie = _event.m.Rookie;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				if (::Wuxia.Events.isAlive(rookie)) this.Characters.push(rookie.getImagePath());

				local bName = ::Wuxia.Events.fmtName(bro);
				local rName = ::Wuxia.Events.fmtName(rookie);

				this.Text = "[img]gfx/ui/events/wx_ev_07.png[/img]" + bName + "没有独自藏私，招手让" + rName + "站到上风口，一边借着体表蒸腾的药韵演示吐纳换气，一边把筋骨发力、丹田落气的秘窍逐字讲透。\n\n" + rName + "听得两眼放光，当场照葫芦画瓢蹲下马步，竟也模模糊糊摸到了一缕气感；而" + bName + "在倾囊相授间反将自身所学梳理得更加通透，二人皆是大有收获。";

				::Wuxia.Events.addMastery(bro, 55, this.List);
				::Wuxia.Events.addMastery(rookie, 55, this.List);
				::Wuxia.Events.addMood(bro, 0.75, "指点后辈行功，心怀宽畅", this.List);
				::Wuxia.Events.addMood(rookie, 0.9, "蒙同袍趁洗髓余韵传授吐纳门道", this.List);
			}
		});

		this.m.Screens.push({
			ID = "CalmHeart",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "不贪不躁，才是长久之道。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_07.png[/img]" + bName + "听从你的告诫，并未强催药力，只缓缓收回双掌，拿凉水洗去肩头油垢，安安稳稳端起一碗热米粥。虽未借机激进破关，可胸中那股浮躁之气尽消，眉宇间多了一分洗尽铅华的从容。";

				::Wuxia.Events.addMood(bro, 0.5, "守正持静，心境澄明", this.List);
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		local bro = ::Wuxia.Events.findBroWithMarrowWash();
		if (bro == null) return;

		this.m.Bro = bro;
		local rookie = ::Wuxia.Events.findRookieBro(4, bro);
		if (rookie == null) rookie = ::Wuxia.Events.findRandomBro(bro);
		this.m.Rookie = rookie;
		this.m.Score = 28;
	}

	function onClear()
	{
		this.m.Bro = null;
		this.m.Rookie = null;
	}
});
