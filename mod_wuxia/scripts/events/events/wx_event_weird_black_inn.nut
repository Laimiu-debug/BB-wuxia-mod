// Batch E5 Event 49: 荒郊黑店 · 蒙汗药酒

this.wx_event_weird_black_inn <- this.inherit("scripts/events/event", {
	m = {
		Spotter = null,
		Victim  = null
	},

	function create()
	{
		this.m.ID = "event.wx_weird_black_inn";
		this.m.Title = "荒郊黑店 · 蒙汗药酒";
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
				this.Options = [];

				local spotter = _event.m.Spotter;
				local victim = _event.m.Victim;
				if (::Wuxia.Events.isAlive(spotter)) this.Characters.push(spotter.getImagePath());
				else if (::Wuxia.Events.isAlive(victim)) this.Characters.push(victim.getImagePath());

				local regionLabel = ::Wuxia.Events.getRegionLabel();
				local spotHint = "";
				if (::Wuxia.Events.isAlive(spotter))
				{
					spotHint = "\n\n" + ::Wuxia.Events.fmtName(spotter) + " 趁倒酒的工夫拿指甲悄悄刮过粗瓷碗沿，凑到鼻尖一嗅，冲你微不可察地挑了挑眉——那碗温热浑酒底沉着一层极细的灰白药沫，分明是掺了曼陀罗根粉的蒙汗药！";
				}

				this.Text = "[img]gfx/ui/events/wx_ev_20.png[/img]瓢泼冷雨灌透了" + regionLabel + "的荒岭官道，一盏破油纸灯笼在狂风里撞得木檐砰砰作响，灯面上歪斜写着半个『客』字。推开这间前不着村的土坯野店，一个油光满面的矮胖掌柜正把剔骨尖刀往油腻围裙上猛擦，咧嘴笑道：『几位爷赶巧了！后灶刚出笼的热肉包，配三碗温好的老黄酒，暖暖身子再歇脚！』\n\n茅草屋顶漏着黑水，灶房小伙计端盘的手直哆嗦，眼珠子死活不敢往你们脸上瞧。案上那笼包子皮白馅足，掰开却飘出一股过分甜腻的八角腥香，柜台草席角下隐约露出一只磨得发亮的铁地窖拉环。" + spotHint;

				if (::Wuxia.Events.isAlive(spotter))
				{
					this.Options.push({
						Text = "让 " + ::Wuxia.Events.shortName(spotter) + " 暗中传信，将计就计反端这间黑店！",
						function getResult( _ev ) { return "TurnTables"; }
					});
				}

				this.Options.push({
					Text = "一口不沾店中酒肉，只喝自带水囊，和衣抱刀轮班守夜。",
					function getResult( _ev ) { return "StayArmed"; }
				});

				this.Options.push({
					Text = "冒雨走了半日早已饿极，大碗喝酒大口吃肉，先填饱肚子再说！",
					function getResult( _ev ) { return "Drugged"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "TurnTables",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "挑走真货，趁雨停前上路。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local spotter = _event.m.Spotter;
				local sName = ::Wuxia.Events.isAlive(spotter) ? ::Wuxia.Events.fmtName(spotter) : "精明的弟兄";
				if (::Wuxia.Events.isAlive(spotter)) this.Characters.push(spotter.getImagePath());

				::Wuxia.Events.addMoney(360, this.List);
				::Wuxia.Events.givePill("wx_pill_qingxin", this.List);
				try
				{
					::Wuxia.Events.giveFood("scripts/items/supplies/smoked_ham_item", "黑店熏制猪火腿", this.List);
				}
				catch (_e)
				{
					::Wuxia.Events.addMoney(80, this.List);
				}
				::Wuxia.Events.addCompanyMood(1.0, "反端荒郊黑店大快人心", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_20.png[/img]" + sName + " 佯装豪饮，手腕一沉便把毒酒全泼进了桌脚砖缝，几只受惊爬出的灶马喝了一口当场翻肚抽搐。众人会意，不一会儿便东倒西歪伏在长凳上扯起响亮呼噜。\n\n三更梆子未响，草席地窖门吱呀掀开，矮胖掌柜带着两个满脸横肉的厨汉拎着麻绳与剥皮刀摸到大堂，刚伸手去摸你们腰间钱袋，寒光骤起！几记刀背拍得三人骨断筋折，满堂求饶声混着雨点翻天。你们从地窖搜出三百六十两沾血脏银、一瓶掌柜自备的清心解毒丹，还有几条梁上风干的熏火腿——弟兄们挨个拿刀拨开皮茬仔细验过硬猪鬃，这才放心装进粮袋。";
			}
		});

		this.m.Screens.push({
			ID = "StayArmed",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "天明雨歇，各自整装出庄。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				::Wuxia.Events.addCompanyMood(0.25, "识破荒店凶险安然避祸", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_20.png[/img]你敲敲桌面，冷声让掌柜把热酒肉包全撤下去，只付了半贯柴火钱，命全队背靠砖墙围炉而坐，嚼着自家冷干粮、灌着凉水囊，兵刃横在膝头，两人一班死盯后厨布帘。\n\n后半夜油灯灭了又挑，帘后至少探出两回鬼祟脑袋，每次都撞上几双亮得像狼似的眼睛。掌柜干笑两声缩回灶间，直熬到天边泛起鱼肚白，谁也没敢动一根手指。虽然一夜没睡踏实，好歹人钱两全。";
			}
		});

		this.m.Screens.push({
			ID = "Drugged",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "晦气！日后再见野店绝不多沾半口。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local victim = _event.m.Victim;
				if (!::Wuxia.Events.isAlive(victim)) victim = ::Wuxia.Events.findRandomBro();
				local vName = ::Wuxia.Events.isAlive(victim) ? ::Wuxia.Events.fmtName(victim) : "一名弟兄";
				if (::Wuxia.Events.isAlive(victim)) this.Characters.push(victim.getImagePath());

				::Wuxia.Events.addMoney(-240, this.List);
				::Wuxia.Events.applyLightHurt(victim, 0.14, this.List);
				::Wuxia.Events.addCompanyMood(-1.25, "中了黑店蒙汗药破财受辱", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_20.png[/img]三碗辣喉热酒下肚，不过半柱香工夫，眼前油灯便晕出三层绿圈，四肢软得像浸了水的棉絮。" + vName + " 察觉不对强撑着拔刀，刚起身就被暗影里抡出的一记擀面杖闷棍砸在额角，眼前一黑栽进长凳底。\n\n再被冷风冻醒时已是辰时，泥泞院子里空无一人，灶冷锅翻，行囊里的散碎银两被翻走二百四十两——想来是黑店见你们兵甲厚重、人多手杂，没敢下死手杀人越货，卷了现钱便连夜跑路。满营弟兄捂着剧痛的脑门破口大骂，恨不得把这破土屋一把火点了。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Spotter = null;
		this.m.Victim = null;
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::Wuxia.Events.getAliveBros().len() < 2) return;

		this.m.Spotter = ::Wuxia.Events.findByBackgrounds([
			"background.anatomist",
			"background.thief",
			"background.gambler",
			"background.raider",
			"background.manhunter"
		]);
		this.m.Victim = ::Wuxia.Events.findRandomBro(this.m.Spotter);
		if (this.m.Victim == null) this.m.Victim = ::Wuxia.Events.findRandomBro();
		this.m.Score = 16;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.Spotter))
		{
			this.m.Spotter = ::Wuxia.Events.findByBackgrounds([
				"background.anatomist",
				"background.thief",
				"background.gambler",
				"background.raider",
				"background.manhunter"
			]);
		}
		if (!::Wuxia.Events.isAlive(this.m.Victim))
			this.m.Victim = ::Wuxia.Events.findRandomBro(this.m.Spotter);
		if (!::Wuxia.Events.isAlive(this.m.Victim))
			this.m.Victim = ::Wuxia.Events.findRandomBro();
	}

	function onPrepareVariables( _vars ) {}

	function onClear()
	{
		this.m.Spotter = null;
		this.m.Victim = null;
	}
});
