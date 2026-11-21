// Batch E4 Event 43: 古刹化缘与禅茶（少室禅院 / 峨眉金顶庵 / 太和玄门下院）

this.wx_event_sect_shaolin_alms <- this.inherit("scripts/events/event", {
	m = {
		SectID      = null,
		StrainedBro = null,
		Bro         = null
	},

	function wxGetHostTitle( _sectID )
	{
		if (_sectID == "emei_ci") return "值殿老尼";
		if (_sectID == "taihe") return "守观老道";
		return "老知客僧";
	}

	function create()
	{
		this.m.ID = "event.wx_sect_shaolin_alms";
		this.m.Title = "山寺檐雨 · 古刹化缘与禅茶";
		this.m.Cooldown = 30.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "捐出 200 银两香火钱，助下院修缮漏雨殿瓦",
					function getResult( _event )
					{
						if (::World.Assets.getMoney() < 200) return "NoMoney";
						return "Donate";
					}
				},
				{
					Text = "借宿偏殿一夜，随暮鼓晨钟打坐静心",
					function getResult( _event ) { return "Meditate"; }
				},
				{
					Text = "饮尽粗茶暖身，合十稽首辞行。",
					function getResult( _event ) { return 0; }
				}
			],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local host = _event.wxGetHostTitle(_event.m.SectID);
				local regionLabel = ::Wuxia.Events.getRegionLabel();
				local showBro = ::Wuxia.Events.isAlive(_event.m.StrainedBro) ? _event.m.StrainedBro : _event.m.Bro;
				if (::Wuxia.Events.isAlive(showBro)) this.Characters.push(showBro.getImagePath());

				local strainHint = ::Wuxia.Events.isAlive(_event.m.StrainedBro)
					? ("\n\n" + host + "替" + ::Wuxia.Events.fmtName(_event.m.StrainedBro) + "斟茶时，目光在其微颤的虎口停了一瞬，轻声道：『施主脉象浮躁，似有内伤或散功暗损，院中尚存几味温经草药。』")
					: "";

				this.Text = "[img]gfx/ui/events/wx_ev_15.png[/img]薄暮细雨浸冷了" + regionLabel + "的山径，松林深处传来几声沉缓幽远的铜磬。转过山坳，一处隶属【" + sect.Name + "】的清静下院隐在雾气中，南侧偏殿瓦檐因去秋山风塌了一角，正用几根新砍松木勉强支着。\n\n一名衣袍洗得发白的" + host + "引众人避雨，并不盘问你们刀鞘上干涸的血渍，只默默添上松果火炭，替每人斟了一碗苦中回甘的粗叶山茶。" + strainHint;
			}
		});

		this.m.Screens.push({
			ID = "Donate",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "心境澄明，辞别山门。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local host = _event.wxGetHostTitle(_event.m.SectID);

				::Wuxia.Events.addMoney(-200, this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, 20, this.List);
				::Wuxia.Events.addReputation(0, 6, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "古刹布施听钟，洗去一身杀伐戾气", this.List);

				local strained = ::Wuxia.Events.isAlive(_event.m.StrainedBro) ? _event.m.StrainedBro : ::Wuxia.Events.findBroWithInternalStrain();
				local cureLine = "";
				if (::Wuxia.Events.isAlive(strained))
				{
					this.Characters.push(strained.getImagePath());
					::Wuxia.Events.cureInternalStrain(strained, this.List);
					cureLine = "\n\n临行前，" + host + "特地在药炉上煎了一碗温经安脉汤，又以温和真气替" + ::Wuxia.Events.fmtName(strained) + "推宫过血，顷刻间便将郁结体内的散功虚弱与内伤化去大半！";
				}
				else if (::Wuxia.Events.isAlive(_event.m.Bro))
				{
					this.Characters.push(_event.m.Bro.getImagePath());
				}

				this.Text = "[img]gfx/ui/events/wx_ev_15.png[/img]你将二百两纹银放进斑驳功德箱，" + host + "郑重还礼，提笔在缘簿上记下你们的名号，言道待传书回【" + sect.Name + "】总坛时必如实禀明今日善缘。檐外雨滴敲打青石，弟兄们捧着热茶听了一夜清钟，连日厮杀积下的暴躁心火竟平复不少。" + cureLine;
			}
		});

		this.m.Screens.push({
			ID = "Meditate",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "神清气爽，整装启程。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local host = _event.wxGetHostTitle(_event.m.SectID);
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addCompanyMastery(35, this.List);
				::Wuxia.Events.addStat(bro, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, 8, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_15.png[/img]刀枪尽数靠在廊柱外，众人脱去沾泥鞋袜在偏殿草席上盘膝静坐。" + host + "并不讲深奥玄理，只在熄灯前轻敲三声木鱼，教众人将杂念收归鼻息。一夜寂静无梦，全队在吐纳间竟各自悟通了几处平日卡壳的运劲关窍。\n\n黎明推窗见松雾散尽，" + ::Wuxia.Events.fmtName(bro) + "眉宇间多了一分临危不乱的沉定。临别时，【" + sect.Name + "】下院还赠了两捆干柴与半罐粗茶。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "稽首告辞。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local host = _event.wxGetHostTitle(_event.m.SectID);
				this.Text = "[img]gfx/ui/events/wx_ev_15.png[/img]掏遍行囊却凑不齐二百两香火银。" + host + "淡然一笑：『佛道不嫌寒士，施主留步避过这阵急雨便是缘分。』";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::Wuxia.Events.getAliveBros().len() == 0) return;
		local pool = ["shaolin", "emei_ci", "taihe"];
		this.m.SectID = pool[::Math.rand(0, pool.len() - 1)];
		this.m.StrainedBro = ::Wuxia.Events.findBroWithInternalStrain();
		this.m.Bro = ::Wuxia.Events.findRandomBro();
		this.m.Score = 15;
	}

	function onPrepare()
	{
		if (this.m.SectID == null || !(this.m.SectID in ::Wuxia.Config.Sects))
		{
			local pool = ["shaolin", "emei_ci", "taihe"];
			this.m.SectID = pool[::Math.rand(0, pool.len() - 1)];
		}
		if (!::Wuxia.Events.isAlive(this.m.StrainedBro))
			this.m.StrainedBro = ::Wuxia.Events.findBroWithInternalStrain();
		if (!::Wuxia.Events.isAlive(this.m.Bro))
			this.m.Bro = ::Wuxia.Events.findRandomBro();
	}

	function onPrepareVariables( _vars ) {}

	function onClear()
	{
		this.m.SectID = null;
		this.m.StrainedBro = null;
		this.m.Bro = null;
	}
});
