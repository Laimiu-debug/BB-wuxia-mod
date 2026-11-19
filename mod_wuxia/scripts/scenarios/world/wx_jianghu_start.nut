// M3 Formal Starting Origin: 「初走江湖」
// 5 varied-background martial companions, no bound main character (anyone can die, anyone can become the star).

this.wx_jianghu_start <- this.inherit("scripts/scenarios/world/starting_scenario", {
	m = {},

	function create()
	{
		this.m.ID = "scenario.wx_jianghu_start";
		this.m.Name = "初走江湖（威远散镖队）";
		this.m.Description = "[p=c][img]gfx/ui/events/event_80.png[/img][/p][p]五名出身各异的江湖散客结伴同行，凭一纸保镖契约踏入动荡武林。队中并无铁律绑定的主角——谁拿到秘籍机缘、熬过刀光剑影，谁便是名震天下的核心大哥；亦人人皆可战死沙场。[/p][p][color=#bcad8c]• 5 名初始同伴（各带基础大路货武学）\n• 12 人上场 / 20 人花名册，无领队死亡强制结束\n• 击败武林对手可爆对应残页与秘籍，拍卖/门派可求绝学与洗髓丹[/color][/p]";
		this.m.Difficulty = 2;
		this.m.Order = 199;
	}

	function onSpawnAssets()
	{
		local roster = this.World.getPlayerRoster();

		local starters = [
			{ Name = "赵老镖", Bg = "caravan_hand_background", Manuals = [[0, "wx_manual_tuna"], [1, "wx_manual_liuheqiang"]] },
			{ Name = "林疏影", Bg = "squire_background",       Manuals = [[1, "wx_manual_jichujian"]] },
			{ Name = "胡铁刀", Bg = "brawler_background",      Manuals = [[1, "wx_manual_wuhudao"]] },
			{ Name = "苏小雀", Bg = "poacher_background",      Manuals = [[0, "wx_manual_xingqi"]] },
			{ Name = "石大柱", Bg = "militia_background",      Manuals = [[0, "wx_manual_tuna"]] }
		];

		for (local i = 0; i < starters.len(); i = ++i)
		{
			local st = starters[i];
			local bro = roster.create("scripts/entity/tactical/player");
			bro.setStartValuesEx([st.Bg]);
			bro.setName(st.Name);
			bro.setPlaceInFormation(i + 2);
			bro.m.PerkPoints = 0;

			foreach (pair in st.Manuals)
			{
				::Wuxia.Slots.equipManual(bro, pair[0], pair[1], false);
			}
		}

		// Starter medical pills + 1 spare common manual
		local stash = this.World.Assets.getStash();
		local p1 = ::new("scripts/items/misc/wx_pill_item");
		p1.initPill("wx_pill_jinchuang");
		stash.add(p1);

		local p2 = ::new("scripts/items/misc/wx_pill_item");
		p2.initPill("wx_pill_huxin");
		stash.add(p2);

		local spareManual = ::new("scripts/items/misc/wx_manual_item");
		spareManual.initManual("wx_manual_jianbu");
		stash.add(spareManual);

		this.World.Assets.m.Money = 2500;
		this.World.Assets.addBusinessReputation(100);
	}

	function onSpawnPlayer()
	{
		::Wuxia.spawnPlayerNearSettlement();
	}
});
