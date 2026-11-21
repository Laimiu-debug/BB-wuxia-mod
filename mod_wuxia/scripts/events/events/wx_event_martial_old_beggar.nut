// Batch E3-30: 破庙怪乞传艺（冷雨山神庙施舍酒肉，偶遇隐世老丐点拨）

this.wx_event_martial_old_beggar <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_martial_old_beggar";
		this.m.Title = "破庙怪乞传艺";
		this.m.Cooldown = 26.0 * this.World.getTime().SecondsPerDay;

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

				this.Text = "[img]gfx/ui/events/wx_ev_15.png[/img]牛毛冷雨斜打在残破山神庙的缺瓦上，神龛里泥胎早已塌了半边肩。廊檐下蜷着个满头乱草般白发、掉光了门牙的老叫花子，腰间挂只磨得发黑的破酒葫芦，正抱紧膝盖冻得上下牙关直打架。\n\n听见你们的马蹄与铁甲声，老人抬起浑浊泪眼，颤巍巍伸出枯爪似的手：『各位好汉爷行行好……老朽三天没沾一星半点荤腥，冻得快断气啦。若肯舍一壶烫烧刀、半斤卤熟肉，老叫花子也不白吃你们的……』";

				this.Options.push({
					Text = "花 120 银两去前头镇店拎一壶烫老酒、切一包热卤肉请他吃顿饱！",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 120) return "NoMoney";
						return "FeastBeggar";
					}
				});

				this.Options.push({
					Text = "顺手丢给他半块冷干粮与囊底几口残酒。",
					function getResult( _ev ) { return "TossScraps"; }
				});

				this.Options.push({
					Text = "荒郊破庙莫沾来历不明的老鬼，喝退他继续赶路。",
					function getResult( _ev ) { return "DriveAway"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "FeastBeggar",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "荒庙藏真龙，江湖果然深不可测！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);

				local giveFullCommon = (::Math.rand(0, 1) == 0);
				local giftDesc = giveFullCommon
					? "一册被油布裹得严严实实的旧抄秘籍"
					: "一页用腊油封边、字迹奇古的门派残篇";

				this.Text = "[img]gfx/ui/events/wx_ev_15.png[/img]老乞丐接过滚烫卤肉与烧酒，全无半分客气，两口扯下一大块肥膘，仰脖灌干了半壶烈酒。酒足饭饱后，他拿破袖口抹净油嘴，浑身哆嗦竟莫名其妙止住了，随手抓起一根油腻竹筷屈指一弹——咄的一声闷响，竹筷竟直挺挺钉进三丈外的青石庙柱两寸深，尾端嗡嗡颤鸣不绝！\n\n满庙众人骇然变色。老乞丐却似醉非醉，斜睨着站得最近的" + bName + "胡乱哼了几句扭腰抖腕的顺口溜，转身晃进雨幕里，只往供桌角丢下" + giftDesc + "。待" + bName + "回过神来细品那几句戏言，竟觉句句直指发力精髓！";

				::Wuxia.Events.addMoney(-120, this.List);
				::Wuxia.Events.addMastery(bro, 60, this.List);
				if (giveFullCommon)
				{
					::Wuxia.Events.giveManual("common", this.List);
				}
				else
				{
					::Wuxia.Events.givePage("sect", 1, this.List);
				}
				::Wuxia.Events.addReputation(0, 5, this.List);
			}
		});

		this.m.Screens.push({
			ID = "TossScraps",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "举手之劳，各走各路。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_15.png[/img]" + bName + "解下干粮袋掰出半块硬麦饼，又倒了半皮囊残酒递过去。老乞丐默默接过细嚼慢咽，抬眼打量" + bName + "那一瞬，眼底陡然闪过一抹老鹰般的锐光。\n\n『雨天拔刀，先听风声再看脚泥。别怕死，越怕死手越抖。』他沙哑地撂下这一句，便重新蜷回干草堆里不再言语。短短几字，却让" + bName + "心里沉甸甸地踏实了不少。";

				::Wuxia.Events.addMood(bro, 0.5, "破庙施舍怪乞反得一言点醒", this.List);
				::Wuxia.Events.addStat(bro, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);
			}
		});

		this.m.Screens.push({
			ID = "DriveAway",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "紧了紧蓑衣，迎雨前行。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_15.png[/img]你冷声喝斥他让开道口。老乞丐也不恼，喉间发出几声像干葫芦摇石子般的怪笑，慢吞吞缩回塌了半边的神案底下，目送你们消失在泥泞雨幕中。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "自身尚难顾全，叹息离去。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_15.png[/img]你掏了掏钱袋，现银连买酒切肉的 120 两都凑不齐。老乞丐摆了摆枯手，喃喃道了声『无缘』，自行缩回破草席里闭上了眼。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;

		this.m.Bro = bro;
		this.m.Score = 13;
	}

	function onClear()
	{
		this.m.Bro = null;
	}
});
