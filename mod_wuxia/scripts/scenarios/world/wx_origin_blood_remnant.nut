// Pure Wuxia Origin 6: 「血煞残徒 · 魔宗遗脉」
// Outlaw / Evil Sect campaign start: starts favored by outlaw sects, hostile to righteous sects,
// excels at looting manuals in bloody combat & bypassing blood-feud disguise penalties.

this.wx_origin_blood_remnant <- this.inherit("scripts/scenarios/world/starting_scenario", {
	m = {},

	function create()
	{
		this.m.ID = "scenario.wx_origin_blood_remnant";
		this.m.Name = "血煞残徒 · 魔宗遗脉";
		this.m.Description = "[p=c][img]gfx/ui/events/wx_ev_10.png[/img][/p][p]黑风血煞宗分坛遭正道围剿那夜，三名悍不畏死的魔宗残徒浴血杀出重围。既然名门正派容不得你们，那便以战养战、夺谱掠经，在九州黑道重新杀出一片血色江山！[/p][p][color=#bcad8c]• 开局阵容：3 名魔宗悍徒（弯刀、铁爪拳套、透骨匕首齐备），起始 1,900 两纹银\n• 魔道渊源：黑风血煞宗/幽冥隐杀楼/五毒奇门交情 +35；少室禅院/太和玄门初始交情 -25\n• 血战掠法：斩杀人类江湖武人时秘籍与残页掉落率 +25%，千面易容阁免受 30 日血仇加价与缓和上限限制\n• 正道忌惮：州府坊市对魔门余孽处处设防，全城池买价上浮 12%[/color][/p]";
		this.m.Difficulty = 3;
		this.m.Order = 6;
	}

	function onInit()
	{
		if ("BuyPriceMult" in this.World.Assets.m)
			this.World.Assets.m.BuyPriceMult *= 1.12;
		if ("MoralReputation" in this.World.Assets.m && this.World.Assets.m.MoralReputation > 20.0)
			this.World.Assets.m.MoralReputation = 20.0;
	}

	function onSpawnAssets()
	{
		local roster = this.World.getPlayerRoster();
		local outlaws = [
			{ Pool = "outlaw", Bg = "raider_background",   Wpn = "weapons/scimitar",       Place = 3, NeiFallback = "wx_manual_xuesha",  WaiFallback = "wx_manual_xuedao" },
			{ Pool = "outlaw", Bg = "brawler_background",  Wpn = "weapons/wx_fist_iron",   Place = 4, NeiFallback = "wx_manual_xingqi",  WaiFallback = "wx_manual_luohan" },
			{ Pool = "outlaw", Bg = "assassin_background", Wpn = "weapons/rondel_dagger",  Place = 5, NeiFallback = "wx_manual_xingqi",  WaiFallback = "wx_manual_fenshui" }
		];

		local usedNames = {};
		local usedManuals = {};

		::Wuxia.Backgrounds.SuppressAutoAssign = true;
		try
		{
			for (local i = 0; i < outlaws.len(); i = ++i)
			{
				local st = outlaws[i];
				local bro = roster.create("scripts/entity/tactical/player");
				bro.setStartValuesEx([st.Bg]);
				::Wuxia.Backgrounds.rollUniqueActorName(bro, usedNames, st.Pool);
				bro.setPlaceInFormation(st.Place);
				bro.m.HireTime = this.Time.getVirtualTimeF();
				bro.m.BaseProperties.MeleeSkill += 5;
				bro.m.BaseProperties.Initiative += 5;
				bro.m.PerkPoints = 0;

				local items = bro.getItems();
				if (items.getItemAtSlot(this.Const.ItemSlot.Mainhand) != null)
					items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
				if (items.getItemAtSlot(this.Const.ItemSlot.Offhand) != null)
					items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));
				local mainWpn = ::new("scripts/items/" + st.Wpn);
				items.equip(mainWpn);

				local neiID = (st.NeiFallback in ::Wuxia.Config.Manuals)
					? st.NeiFallback
					: ::Wuxia.Backgrounds.pickCatalogManual("neigong", "common", null, usedManuals, "wx_manual_xingqi");
				local waiID = (st.WaiFallback in ::Wuxia.Config.Manuals)
					? st.WaiFallback
					: ::Wuxia.Backgrounds.pickCatalogManual("waigong", "common", mainWpn, usedManuals, "wx_manual_wuhudao");
				::Wuxia.Slots.equipManual(bro, 0, neiID, false);
				::Wuxia.Slots.equipManual(bro, 1, waiID, false);
				if (bro.getBackground() != null && ::Wuxia.hasMember(bro.getBackground(), "WX_RefreshStarterNote"))
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
		{
			::Wuxia.SectRelations.addRelation("heifeng", 35, true);
			::Wuxia.SectRelations.addRelation("yinsha", 35, true);
			::Wuxia.SectRelations.addRelation("wudu", 35, true);
			::Wuxia.SectRelations.addRelation("shaolin", -25, true);
			::Wuxia.SectRelations.addRelation("taihe", -25, true);
		}

		local stash = this.World.Assets.getStash();
		foreach (pid in ["wx_pill_jinchuang", "wx_pill_huxin", "wx_pill_longhu"])
		{
			if (pid in ::Wuxia.Config.Pills)
			{
				local pill = ::new("scripts/items/misc/wx_pill_item");
				pill.initPill(pid);
				stash.add(pill);
			}
		}

		this.World.Assets.m.Money = 1900;
		this.World.Assets.addBusinessReputation(120);

		local food = ::new("scripts/items/supplies/dried_lamb_item");
		food.setAmount(25);
		stash.add(food);
		this.World.Assets.updateFood();
	}

	function onSpawnPlayer()
	{
		::Wuxia.spawnPlayerNearSettlement();
		this.World.Assets.updateLook(15);
	}
});
