// World Event: 老猎妖师与《山海异兽图志》（花 150 银两探明一处尚未讨伐的【山海凶兽秘境】方位并点亮地图迷雾）

this.wx_event_shanhai_rumor <- this.inherit("scripts/events/event", {
	m = {
		TargetName = "",
		DirText    = "",
		DistTiles  = 0,
		TargetSite = null
	},

	function create()
	{
		this.m.ID = "event.wx_shanhai_rumor";
		this.m.Title = "荒村酒肆 · 老猎妖师的山海图志";
		this.m.Cooldown = 14.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/wx_ev_21.png[/img]道旁茅店檐下挂着几串异兽利齿，一名独臂老猎妖师正对着一卷残破泛黄的《山海异兽图志》独酌。见你们兵甲精良、气度不凡，他敲了敲旱烟杆压低声音道：『近来大荒地脉异动，《山海经》所载的上古凶兽现世作乱。老朽早年折了一条胳膊才摸清其中一处巢穴方位——给我一百五十两买酒钱，这处凶兽秘境便画在诸位舆图之上！』",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "奉上 150 银两请教山海凶兽秘境方位",
					function getResult( _event )
					{
						if (::World.Assets.getMoney() < 150) return "NoMoney";
						::World.Assets.addMoney(-150);
						return "Revealed";
					}
				},
				{
					Text = "凶兽凶险，暂不节外生枝。",
					function getResult( _event ) { return 0; }
				}
			],
			function start( _event ) {}
		});

		this.m.Screens.push({
			ID = "Revealed",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "收好舆图，磨砺兵刃备战！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				local site = _event.m.TargetSite;
				if (site == null || !site.isAlive()) site = ::Wuxia.ShanHai.pickUndefeatedLairSite();
				if (site != null)
				{
					local pTile = ::World.State.getPlayer().getTile();
					local sTile = site.getTile();
					local dir = ::Wuxia.ShanHai.getCompassDirection(pTile, sTile);
					local dist = pTile.getDistanceTo(sTile);
					if (::Wuxia.hasMember(site, "setDiscovered")) site.setDiscovered(true);
					site.getFlags().set("wx_charted", true);
					if ("uncoverFogOfWar" in ::World) ::World.uncoverFogOfWar(sTile.Pos, 500.0);
					local intelNote = "";
					local siteKey = ("WX_Site" in site.m) ? site.m.WX_Site : null;
					local bossID = (siteKey != null && "getBossIDForSite" in ::Wuxia.ShanHai) ? ::Wuxia.ShanHai.getBossIDForSite(siteKey) : null;
					if (bossID != null && (bossID in ::Wuxia.Config.ShanHaiBosses))
					{
						local bCfg = ::Wuxia.Config.ShanHaiBosses[bossID];
						local tInfo = ::Wuxia.ShanHai.getBossTierInfo(::Wuxia.ShanHai.getBossTier(bossID));
						local hint = ::Wuxia.ShanHai.getBossCounterHint(bossID);
						intelNote = "\n\n[color=" + tInfo.Color + "]【" + tInfo.Label + "】[/color] " + bCfg.TraitName + "：" + bCfg.TraitDesc + "\n[color=#8be9b5]老猎妖师叮嘱：" + hint + "。[/color]";
					}
					this.Text = "[img]gfx/ui/events/wx_ev_21.png[/img]老猎妖师蘸着烈酒在羊皮舆图上重重一点：\n\n『自此地往 [color=#ffd88a]" + dir + "[/color] 行约 [color=#ffd88a]" + dist + " 格[/color]路程，便是 [color=#ff8e80]" + site.getName() + "[/color]！大妖凶威非同小可，若能取其山海内丹带回城中百工丹坊，便可锻出刀枪难入的山海传世宝甲与神兵！』" + intelNote + "\n\n（该处【山海秘境】已在世界地图迷雾中点亮！）";
				}
				else
				{
					::World.Assets.addMoney(150);
					this.Text = "[img]gfx/ui/events/wx_ev_21.png[/img]老猎妖师翻遍图志，啧啧称奇道：『怪哉，这方圆千里的山海大妖竟已被高人扫荡一空！』说罢将银两推还于你。";
				}
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "[img]gfx/ui/events/wx_ev_21.png[/img]摸了摸钱袋竟凑不出一百五十两现银，老猎妖师摇了摇头自顾饮酒去了。",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "改日再访。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});
	}

	function onUpdateScore()
	{
		if (this.World.getTime().Days < 8) return;
		if (this.World.Assets.getMoney() < 150) return;
		local site = ::Wuxia.ShanHai.pickUndefeatedLairSite();
		if (site == null) return;
		this.m.TargetSite = site;
		this.m.Score = 14;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear() { this.m.TargetSite = null; }
});
