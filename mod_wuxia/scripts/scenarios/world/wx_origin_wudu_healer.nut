// Pure Wuxia Origin 4: 「百草毒医 · 南疆采药行」
// 4 Southern herbalists & hidden-weapon specialists with rich pill reserves & Shan Hai beast-hunting focus.

this.wx_origin_wudu_healer <- this.inherit("scripts/scenarios/world/starting_scenario", {
	m = {},

	function create()
	{
		this.m.ID = "scenario.wx_origin_wudu_healer";
		this.m.Name = "百草毒医 · 南疆采药行";
		this.m.Description = "[p=c][img]gfx/ui/events/wx_ev_21.png[/img][/p][p]你们是常年深入十万大山与云梦瘴泽寻觅灵药异兽的药师行帮。既通悬壶济世之丹术，亦擅见血封喉的吹箭奇毒与漫天暗器，专克世间凶兽皮甲。[/p][p][color=#bcad8c]• 开局阵容：4 名南疆采药人与奇门暗器手（自带《五毒吹影功》《暴雨暗器谱》《分水透骨刺》）\n• 丹囊充盈：开局随带金疮散、护心丹、凝神丸与护脉丹共 8 枚灵药\n• 宗门渊源：五毒奇门初始交情 +30，擅猎山海异兽炼丹铸宝[/color][/p]";
		this.m.Difficulty = 2;
		this.m.Order = 4;
	}

	function onSpawnAssets()
	{
		local roster = this.World.getPlayerRoster();
		local party = [
			{ Pool = "jianghu", Bg = "anatomist_background",   Wpn = "weapons/javelin",       Place = 11, WaiQual = "sect",   Learn = null },
			{ Pool = "jianghu", Bg = "poacher_background",     Wpn = "weapons/throwing_axe",  Place = 12, WaiQual = "sect",   Learn = null },
			{ Pool = "folk",    Bg = "houndmaster_background", Wpn = "weapons/rondel_dagger", Place = 3,  WaiQual = "common", Learn = null },
			{ Pool = "jianghu", Bg = "monk_background",        Wpn = "weapons/javelin",       Place = 4,  WaiQual = "common", Learn = "wx_manual_xiushou" }
		];

		local usedNames = {};
		local usedManuals = {};

		::Wuxia.Backgrounds.SuppressAutoAssign = true;
		try
		{
			for (local i = 0; i < party.len(); i = ++i)
			{
				local st = party[i];
				local bro = roster.create("scripts/entity/tactical/player");
				bro.setStartValuesEx([st.Bg]);
				::Wuxia.Backgrounds.rollUniqueActorName(bro, usedNames, st.Pool);
				bro.setPlaceInFormation(st.Place);
				bro.m.HireTime = this.Time.getVirtualTimeF();
				bro.m.BaseProperties.RangedSkill += 6;
				bro.m.BaseProperties.Initiative += 6;
				bro.m.PerkPoints = 0;

				local items = bro.getItems();
				if (items.getItemAtSlot(this.Const.ItemSlot.Mainhand) != null)
					items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
				if (items.getItemAtSlot(this.Const.ItemSlot.Offhand) != null)
					items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));
				local mainWpn = ::new("scripts/items/" + st.Wpn);
				items.equip(mainWpn);

				local neiID = ::Wuxia.Backgrounds.pickCatalogManual("neigong", "common", null, usedManuals, "wx_manual_xingqi");
				local waiID = ::Wuxia.Backgrounds.pickCatalogManual("waigong", st.WaiQual, mainWpn, usedManuals, "wx_manual_wudu");
				::Wuxia.Slots.equipManual(bro, 0, neiID, false);
				::Wuxia.Slots.equipManual(bro, 1, waiID, false);
				if (st.Learn != null)
					::Wuxia.Slots.learnManual(bro, st.Learn, false);
				if (bro.getBackground() != null && ("WX_RefreshStarterNote" in bro.getBackground()))
					bro.getBackground().WX_RefreshStarterNote([::Wuxia.Slots.getManualDef(neiID).Name, ::Wuxia.Slots.getManualDef(waiID).Name]);
				bro.getSkills().update();
			}
		}
		catch (err)
		{
			::Wuxia.Backgrounds.SuppressAutoAssign = false;
			throw err;
		}
		::Wuxia.Backgrounds.SuppressAutoAssign = false;

		if ("SectRelations" in ::Wuxia && "addRelation" in ::Wuxia.SectRelations)
			::Wuxia.SectRelations.addRelation("wudu", 30);

		local stash = this.World.Assets.getStash();
		stash.add(::new("scripts/items/weapons/throwing_axe"));
		stash.add(::new("scripts/items/weapons/javelin"));
		stash.add(::new("scripts/items/tools/throwing_net"));

		foreach (pid in [
			"wx_pill_jinchuang", "wx_pill_jinchuang", "wx_pill_jinchuang",
			"wx_pill_huxin", "wx_pill_huxin",
			"wx_pill_ningshen", "wx_pill_ningshen",
			"wx_pill_humai"
		])
		{
			local pill = ::new("scripts/items/misc/wx_pill_item");
			pill.initPill(pid);
			stash.add(pill);
		}

		this.World.Assets.m.Money = 2200;
		this.World.Assets.addBusinessReputation(100);

		local food = ::new("scripts/items/supplies/dried_fruits_item");
		food.setAmount(25);
		stash.add(food);
		this.World.Assets.updateFood();
	}

	function onSpawnPlayer()
	{
		::Wuxia.spawnPlayerNearSettlement();
		this.World.Assets.updateLook(20);
	}
});
