// Batch E4 Event 40: 官道劫镖残局（威远总镖局 / 洛阳长风镖局）

this.wx_event_sect_escort_wreck <- this.inherit("scripts/events/event", {
	m = {
		SectID = null,
		Bro    = null
	},

	function create()
	{
		this.m.ID = "event.wx_sect_escort_wreck";
		this.m.Title = "残焰断旌 · 官道劫镖残局";
		this.m.Cooldown = 32.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "救出幸存趟子手，护送人箱前往下个驿站。",
					function getResult( _event ) { return "Escort"; }
				},
				{
					Text = "四下无人，趁乱搜刮铁箱银两与散落镖货。",
					function getResult( _event ) { return "Loot"; }
				},
				{
					Text = "放镖徒自行离去，留下替遇难镖师掘土掩埋。",
					function getResult( _event ) { return "Bury"; }
				},
				{
					Text = "血腥味引狼，莫沾是非，催马径直通过。",
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

				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]焦臭黑烟顺着" + regionLabel + "的官道拐弯处笔直冒上灰天。两辆重木镖车断轴侧翻，一面烧焦半边的三角镖旗斜插在泥里，隐约还能辨出【" + sect.Name + "】的字号。四名趟子手横尸道旁，肋间还戳着折断的弩箭，几只老鸦正大胆地蹦上车辕啄食撒出的粟米。\n\n倾覆的车厢底下忽然传出轻响——一个满脸灰黑的年轻镖徒死死抱着口包铁钱箱，手里横着半截弯枪杆，双目发红地盯着走近的你们，浑然不知你们是救兵还是回马杀到的响马。";
			}
		});

		this.m.Screens.push({
			ID = "Escort",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "侠道相扶，后会有期。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addSectRel(_event.m.SectID, 22, this.List);
				::Wuxia.Events.addReputation(0, 6, this.List);
				::Wuxia.Events.addMoney(240, this.List);
				::Wuxia.Events.givePill("wx_pill_jinchuang", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]你们收刃卸下敌意，将吓得腿软的小镖徒从车底拉出来，连同那口沉甸甸的包铁红货一并绑上骡背，护送出二十余里直抵【" + sect.Name + "】在驿镇的落脚分号。\n\n留守的老镖头验明封条完好，当场红了眼眶，二话不说按规矩奉上二百四十两谢银与一瓶金疮散，并郑重将你们的名号记上了镖局恩客薄。";
			}
		});

		this.m.Screens.push({
			ID = "Loot",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "满载而去，莫留踪迹。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				::Wuxia.Events.addMoney(440, this.List);
				::Wuxia.Events.addSupplies(12, 0, 0, this.List);
				::Wuxia.Events.giveFood("scripts/items/supplies/cured_rations_item", "镖车腌肉干粮", this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, -25, this.List);
				::Wuxia.Events.addReputation(0, -10, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]小镖徒一眼瞧出你们目光只落在铁箱上，尖叫一声扔下断枪，连滚带爬钻进路边乱林不见了踪影。你们干脆利落地用刀背砸开铜锁，卷走箱中纹银、未损的修甲铁具和几大包油纸裹好的腌肉干粮。\n\n只是那小子保住了性命，不出五日，【" + sect.Name + "】和半个道上都会知道是谁趁火打劫吃了这趟绝户镖。";
			}
		});

		this.m.Screens.push({
			ID = "Bury",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "愿死者安息，继续行路。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addReputation(0, 5, this.List);
				::Wuxia.Events.addStat(bro, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]小镖徒见你们无恶意，谢过几声便背着铁箱踉跄投奔官驿去了。你们没有急着走，而是寻来半截破木板在老槐树下掘开浅坑，把【" + sect.Name + "】四位殉职的镖师一一收敛入土，又洒下半碗粗酒祭奠。\n\n刀口舔血的日子过久了，谁都说不准哪天横尸荒野的就是自己。" + ::Wuxia.Events.fmtName(bro) + "望着新坟默立许久，再抬头时眼神愈发沉稳冷硬。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::Wuxia.Events.getAliveBros().len() == 0) return;
		local pool = ["weiyuan", "luoyang_biao"];
		this.m.SectID = pool[::Math.rand(0, pool.len() - 1)];
		this.m.Bro = ::Wuxia.Events.findRandomBro();
		this.m.Score = 15;
	}

	function onPrepare()
	{
		if (this.m.SectID == null || !(this.m.SectID in ::Wuxia.Config.Sects))
		{
			local pool = ["weiyuan", "luoyang_biao"];
			this.m.SectID = pool[::Math.rand(0, pool.len() - 1)];
		}
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
