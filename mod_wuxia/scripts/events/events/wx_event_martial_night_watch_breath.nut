// Batch E3-35: 寒夜吐纳（星夜值哨借凛冽寒风炼气、磨砺身法或教习全营暖身呼吸）

this.wx_event_martial_night_watch_breath <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function wxPickBreathManualName( _bro )
	{
		local n = ::Wuxia.Events.pickManualName(_bro, "neigong");
		if (n != "随身武艺") return n;
		local q = ::Wuxia.Events.pickManualName(_bro, "qinggong");
		if (q != "随身武艺") return q;
		return ::Wuxia.Events.pickManualName(_bro);
	}

	function wxPrefersInitiative( _bro )
	{
		if (!::Wuxia.Events.isAlive(_bro)) return false;
		local c = ::Wuxia.Slots.getContainer(_bro);
		if (c == null) return false;
		local hasNei = false;
		local hasQing = false;
		foreach (s in c.m.Slots)
		{
			if (s.ManualID == null || s.Tier <= 0 || s.IsFragment) continue;
			local def = ::Wuxia.Slots.getManualDef(s.ManualID);
			if (def == null) continue;
			if (def.Category == "neigong") hasNei = true;
			else if (def.Category == "qinggong") hasQing = true;
		}
		if (hasQing && !hasNei) return true;
		if (hasNei && !hasQing) return false;
		return ::Math.rand(0, 1) == 0;
	}

	function create()
	{
		this.m.ID = "event.wx_martial_night_watch_breath";
		this.m.Title = "寒夜吐纳";
		this.m.Cooldown = 16.0 * this.World.getTime().SecondsPerDay;

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
				local manName = _event.wxPickBreathManualName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_09.png[/img]子夜寒星密如霜钉，割面般的北风扫过枯苇荡，惊得拴在木桩旁的马匹焦躁刨蹄。轮到值哨的" + bName + "并未蜷在炭火堆边烤手，反而横刀膝上，稳稳坐在一截老树虬根之上。\n\n每当刺骨冷风直扑咽喉，他竟不再缩颈硬扛，而是循着" + manName + "的节拍将这口冰寒野气徐徐纳入丹田，再如拉风箱般细长吐出——刹那间脏腑暖意骤生，周身竟然不再发抖，连暗夜里的风吹草动都听得格外真切。";

				this.Options.push({
					Text = "难得心风合一，任他独自借寒夜罡风深磨自身修为。",
					function getResult( _ev ) { return "DeepenSelf"; }
				});

				this.Options.push({
					Text = "唤来冻得上下牙打架的换岗弟兄，把这手借寒暖身的吐纳节奏教给全营！",
					function getResult( _ev ) { return "TeachCamp"; }
				});

				this.Options.push({
					Text = "夜黑风高最易招来劫营匪徒，嘱他睁大眼睛只管巡哨。",
					function getResult( _ev ) { return "AlertWatch"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "DeepenSelf",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "苦寒磨筋骨，不虚此夜。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);

				local isInit = _event.wxPrefersInitiative(bro);
				if (isInit)
				{
					this.Text = "[img]gfx/ui/events/wx_ev_09.png[/img]" + bName + "在寒风里枯坐足足两个时辰，耳听枯叶翻滚、风向转折，脚下借着换气吐纳暗暗练习无声挪移。待鸡鸣破晓收刀起身时，他眉梢虽挂着白霜，步履却轻捷得宛如贴地滑行的夜枭，身法反应比往日又快了一线。";
					::Wuxia.Events.addMastery(bro, 65, this.List);
					::Wuxia.Events.addStat(bro, "Initiative", 1, "身法", "ui/icons/initiative.png", this.List);
				}
				else
				{
					this.Text = "[img]gfx/ui/events/wx_ev_09.png[/img]" + bName + "在冰风中纹丝不动，借寒气逼迫丹田自生阳火，一次次将肺腑之气沉至极深再缓缓回提。待黎明灰白漫过荒原，他肩头霜雪竟被体表隐隐热气化成了水珠，内息运转比昨日愈发悠长雄浑。";
					::Wuxia.Events.addMastery(bro, 65, this.List);
					::Wuxia.Events.addStat(bro, "Stamina", 1, "内息上限", "ui/icons/fatigue.png", this.List);
				}
			}
		});

		this.m.Screens.push({
			ID = "TeachCamp",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "有了这口热气，霜重也不怕了！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_09.png[/img]" + bName + "把冷得直跺脚的弟兄们聚到背风土坡下，教大家按三吸一顿二缓吐的法门运息生暖。不过两刻钟，众人指尖脚趾便渐渐回温，连平日最不善内功的粗汉也尝到了气血流通的甜头。\n\n满营笑骂着称赞这法子比灌烈酒还管用，整夜霜寒竟成了全队打磨吐纳的好光景。";

				::Wuxia.Events.addCompanyMastery(30, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "寒夜习得暖身吐纳，驱散彻骨霜气", this.List);
			}
		});

		this.m.Screens.push({
			ID = "AlertWatch",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "平安无事便是大吉。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_09.png[/img]" + bName + "收起闭目吐纳的心思，提刀沿着营地外围仔细巡察。整夜只惊走两只偷摸干粮袋的野狐狸，全营安安稳稳睡到了天亮。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (!::Wuxia.Events.isNight()) return;

		local bro = null;
		if (::Math.rand(0, 1) == 0)
		{
			bro = ::Wuxia.Events.findBroWithManual("neigong");
			if (bro == null) bro = ::Wuxia.Events.findBroWithManual("qinggong");
		}
		else
		{
			bro = ::Wuxia.Events.findBroWithManual("qinggong");
			if (bro == null) bro = ::Wuxia.Events.findBroWithManual("neigong");
		}
		if (bro == null) return;

		this.m.Bro = bro;
		this.m.Score = 16;
	}

	function onClear()
	{
		this.m.Bro = null;
	}
});
