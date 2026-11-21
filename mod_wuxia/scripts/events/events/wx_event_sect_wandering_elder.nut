// Batch E4 Event 48: 荒野遇名宿（残驿炉火巧遇门派隐世前辈）

this.wx_event_sect_wandering_elder <- this.inherit("scripts/events/event", {
	m = {
		SectID = null,
		Bro    = null
	},

	function create()
	{
		this.m.ID = "event.wx_sect_wandering_elder";
		this.m.Title = "残驿炉火 · 荒野遇名宿";
		this.m.Cooldown = 36.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "出 80 银两置办热茶干肉，恭敬相邀老前辈共饮暖身",
					function getResult( _event )
					{
						if (::World.Assets.getMoney() < 80) return "NoMoney";
						return "ShareTea";
					}
				},
				{
					Text = "抱拳寒暄，虚心向老前辈打听此方地界近况",
					function getResult( _event ) { return "AskNews"; }
				},
				{
					Text = "道声叨扰，自去残驿另一角铺草和衣歇息。",
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

				this.Text = "[img]gfx/ui/events/wx_ev_32.png[/img]寒风顺着" + regionLabel + "一座塌了半面夯土墙的旧官驿破窗灌进来。火塘边却早已坐着位穿补丁葛布袍的白发老者，正拿一根青柳枝串着两枚干瘪蔓菁在柴火上慢烤。\n\n老者瞧着与寻常山野老农无异，唯独寒夜吐纳竟不带半缕白雾，腰间粗麻绳上还坠着块盘得温润如玉的旧木牌——隐约刻着【" + sect.Name + "】前辈长老才配有的古篆字样。听见你们沉重的靴声，老者抬眼淡淡一扫，抬手朝火塘背风那半边指了指。";
			}
		});

		this.m.Screens.push({
			ID = "ShareTea",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "拜谢前辈指点，获益匪浅！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMoney(-80, this.List);
				::Wuxia.Events.addMastery(bro, 80, this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, 18, this.List);

				local pageLine = "";
				if (::Math.rand(1, 100) <= 45)
				{
					::Wuxia.Events.givePage("sect", 1, this.List, _event.m.SectID);
					pageLine = "\n\n次日天蒙蒙亮时，老者早已不见踪影，只剩火堆旁一块鹅卵石压着一叶写满批注的【" + sect.Name + "】武学残页，墨痕还泛着松烟气！";
				}

				this.Text = "[img]gfx/ui/events/wx_ev_32.png[/img]你们取出上好砖茶和腌腊肉干烤得滋滋冒油，恭敬奉上一碗滚茶。老者吃得眉眼舒展，抹去唇边油星后忽地伸出枯瘦手指，电光火石间扣住" + ::Wuxia.Events.fmtName(bro) + "右腕试了试筋骨与呼吸气口。\n\n『底子不赖，就是换劲时肩井太僵，白白糟蹋了三成力道。』老者顺手折下烤蔓菁的青柳枝，连点三处僵滞关窍，逼得" + ::Wuxia.Events.fmtName(bro) + "在火光下演了半夜招式，直练到浑身大汗淋漓、旧滞尽通。" + pageLine;
			}
		});

		this.m.Screens.push({
			ID = "AskNews",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "多谢前辈提点，天明启程。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local regionLabel = ::Wuxia.Events.getRegionLabel();
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addSectRel(_event.m.SectID, 10, this.List);
				::Wuxia.Events.addCompanyMood(0.5, "荒野残驿听名宿谈古论今，胸怀顿畅", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_32.png[/img]围着噼啪柴火，老者慢悠悠讲起" + regionLabel + "近年的水旱荒年、哪几处山坳出了新贼巢，又随口点了几句武林旧事。见你们进退有礼、不打探门中隐秘，老者甚是受用，临睡前笑言他日回【" + sect.Name + "】见了晚辈，定会顺口夸赞几句。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "自行烤火歇息。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_32.png[/img]摸摸腰囊连置办好茶好肉的八十两碎银也拿不出手。你们只得惭愧作罢，默不作声地靠着残墙烤火熬到天明。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::Wuxia.Events.getAliveBros().len() == 0) return;
		this.m.SectID = ::Wuxia.Events.pickLocalSect();
		this.m.Bro = ::Wuxia.Events.findRandomBro();
		this.m.Score = 14;
	}

	function onPrepare()
	{
		if (this.m.SectID == null || !(this.m.SectID in ::Wuxia.Config.Sects))
			this.m.SectID = ::Wuxia.Events.pickLocalSect();
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
