// Batch E4 Event 46: 豪商谢宴（城郊盐茶豪商联同正道门派设宴）

this.wx_event_sect_escort_banquet <- this.inherit("scripts/events/event", {
	m = {
		SectID = null,
		Bro    = null
	},

	function create()
	{
		this.m.ID = "event.wx_sect_escort_banquet";
		this.m.Title = "灯火华筵 · 豪商谢宴";
		this.m.Cooldown = 35.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "欣然赴席，与豪商及门派执事把酒言欢。",
					function getResult( _event ) { return "Feast"; }
				},
				{
					Text = "婉辞入宴，主动率众在宅院外围轮值巡哨护场。",
					function getResult( _event ) { return "Sentry"; }
				},
				{
					Text = "行色匆匆不便叨扰，拱手谢绝后赶路。",
					function getResult( _event ) { return 0; }
				}
			],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local regionLabel = ::Wuxia.Events.getRegionLabel();
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_06.png[/img]" + regionLabel + "城外盐茶大行今夜灯笼高挂、丝竹隐隐。一名穿貂绒坎肩的胖掌柜正陪着【" + sect.Name + "】的执事站在朱漆大门前迎客——他们刚平平安安运回一整船春茶与细盐，正大摆谢宴酬谢沿路保驾的江湖朋友。\n\n听家丁通报你们的名号，胖掌柜满面油光地递上洒金请柬：『久仰诸位走南闯北的名头！炉上烤鸭刚出油，坛里陈年花雕也开了封，【" + sect.Name + "】的诸位前辈都在厅里候着，快请入席！』不过" + ::Wuxia.Events.fmtName(bro) + "扫了一眼，顺带瞧见宅后矮墙连着黑漆漆的桑林，外头仅有两个打瞌睡的家院看门。";
			}
		});

		this.m.Screens.push({
			ID = "Feast",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "醉饱而归，江湖路宽。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addCompanyMood(1.0, "豪商灯火华筵款待，醉饱尽兴", this.List);
				::Wuxia.Events.giveFood("scripts/items/supplies/wine_item", "陈年花雕美酒", this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, 15, this.List);
				::Wuxia.Events.addMoney(220, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_06.png[/img]热气腾腾的酱肘、肥鸭与温烫花雕流水般端上长桌，半数弟兄总算暂且忘却了靴底烂泥与风霜旧伤。酒过三巡，【" + sect.Name + "】的执事拉着" + ::Wuxia.Events.fmtName(bro) + "畅谈一路侠闻，宾主尽欢。\n\n临别送至石阶下，盐茶豪商笑眯眯往你袖中塞了二百二十两程仪，又命伙计抱来两坛泥封未开的好酒装上骡车。";
			}
		});

		this.m.Screens.push({
			ID = "Sentry",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "不负所托，辞行上路。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addReputation(40, 0, this.List);
				::Wuxia.Events.addSupplies(12, 0, 0, this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, 10, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_06.png[/img]你们婉辞美酒，只讨了两壶浓茶提神，便悄然散开在桑林矮墙与马厩暗角轮流放哨。果然刚过二更，两个拎着迷烟筒的摸墙蟊贼摸到后院窗下，还没来得及吹烟便被" + ::Wuxia.Events.fmtName(bro) + "用刀鞘连拍带踹拿了个正着，连厅里的酒兴都没惊动半分。\n\n天明席散，豪商与【" + sect.Name + "】执事得知昨夜暗惊，无不对你们滴酒不沾、军纪森严赞不绝口，当即赠出一箱上等修甲铁件，更把你们的名号吹遍了全城商行。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (!::Wuxia.Events.isNearTown(4)) return;
		if (::World.getTime().Days < 12) return;
		if (::Wuxia.Events.getAliveBros().len() == 0) return;
		this.m.SectID = ::Wuxia.Events.pickLocalSect("righteous");
		this.m.Bro = ::Wuxia.Events.findRandomBro();
		this.m.Score = 15;
	}

	function onPrepare()
	{
		if (this.m.SectID == null || !(this.m.SectID in ::Wuxia.Config.Sects))
			this.m.SectID = ::Wuxia.Events.pickLocalSect("righteous");
		if (!::Wuxia.Events.isAlive(this.m.Bro))
			this.m.Bro = ::Wuxia.Events.findRandomBro();
	}

	function onPrepareVariables( _vars ) {}

	function onClear()
	{
		this.m.SectID = null;
		this.m.Bro = null;
	}
});
