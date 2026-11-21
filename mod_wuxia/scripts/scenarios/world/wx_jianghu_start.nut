// M3 Formal Starting Origin: 「初走江湖」
// 5 varied-background martial companions, no bound main character (anyone can die, anyone can become the star).

this.wx_jianghu_start <- this.inherit("scripts/scenarios/world/starting_scenario", {
	m = {},

	function create()
	{
		this.m.ID = "scenario.wx_jianghu_start";
		this.m.Name = "初走江湖 · 威远散镖队";
		this.m.Description = "[p=c][img]gfx/ui/events/wx_ev_06.png[/img][/p][p]五名出身各异的江湖散客结伴同行，凭一纸护镖红契踏入风云激荡的九州武林。队中并无铁律绑定的不死主角——谁觅得秘籍机缘、熬过刀光剑影，谁便是名震天下的当家大哥；亦人人皆可马革裹尸。[/p][p][color=#bcad8c]• 开局阵容：5 名江湖散客（刀枪剑拳弓齐备，各带基础大路货武学）\n• 起始资财：2,500 两纹银，附金疮散、护心丹与健步功各一\n• 义社规模：12 人上阵 / 20 人花名册，无领队阵亡强制败局[/color][/p]";
		this.m.Difficulty = 2;
		this.m.Order = 1;
	}

	function onSpawnAssets()
	{
		local roster = this.World.getPlayerRoster();

		local starters = [
			{ Pool = "jianghu", Bg = "caravan_hand_background", Wpns = [["weapons/boar_spear", "shields/wooden_shield"], ["weapons/hooked_blade", null]], Ammo = null, Place = 2 },
			{ Pool = "jianghu", Bg = "squire_background",       Wpns = [["weapons/shortsword", null], ["weapons/arming_sword", null]],                        Ammo = null, Place = 3 },
			{ Pool = "jianghu", Bg = "brawler_background",      Wpns = [["weapons/falchion", "shields/buckler_shield"], ["weapons/hand_axe", "shields/wooden_shield"]], Ammo = null, Place = 4 },
			{ Pool = "folk",    Bg = "militia_background",      Wpns = [["weapons/wx_fist_wraps", null], ["weapons/wooden_stick", null]],                      Ammo = null, Place = 5 },
			{ Pool = "jianghu", Bg = "poacher_background",      Wpns = [["weapons/short_bow", null], ["weapons/light_crossbow", null]],                        Ammo = "auto", Place = 11 }
		];

		local usedNames = {};
		local usedManuals = {};

		::Wuxia.Backgrounds.SuppressAutoAssign = true;
		try
		{
			for (local i = 0; i < starters.len(); i = ++i)
			{
				local st = starters[i];
				local bro = roster.create("scripts/entity/tactical/player");
				bro.setStartValuesEx([st.Bg]);
				::Wuxia.Backgrounds.rollUniqueActorName(bro, usedNames, st.Pool);
				bro.setPlaceInFormation(st.Place);
				bro.m.HireTime = this.Time.getVirtualTimeF();
				bro.m.PerkPoints = 0;

				local loadout = st.Wpns[::Math.rand(0, st.Wpns.len() - 1)];
				local items = bro.getItems();
				if (items.getItemAtSlot(this.Const.ItemSlot.Mainhand) != null)
					items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
				if (items.getItemAtSlot(this.Const.ItemSlot.Offhand) != null)
					items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));
				local mainWpn = ::new("scripts/items/" + loadout[0]);
				items.equip(mainWpn);
				if (loadout[1] != null)
					items.equip(::new("scripts/items/" + loadout[1]));
				if (st.Ammo == "auto")
				{
					if (items.getItemAtSlot(this.Const.ItemSlot.Ammo) != null)
						items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Ammo));
					local ammoScript = (loadout[0].find("crossbow") != null) ? "ammo/quiver_of_bolts" : "ammo/quiver_of_arrows";
					items.equip(::new("scripts/items/" + ammoScript));
				}

				local neiID = ::Wuxia.Backgrounds.pickCatalogManual("neigong", "common", null, usedManuals, "wx_manual_tuna");
				local waiID = ::Wuxia.Backgrounds.pickCatalogManual("waigong", "common", mainWpn, usedManuals, "wx_manual_jichujian");
				local grantedNames = [];
				if (neiID != null)
				{
					::Wuxia.Slots.equipManual(bro, 0, neiID, false);
					grantedNames.push(::Wuxia.Slots.getManualDef(neiID).Name);
				}
				if (waiID != null)
				{
					::Wuxia.Slots.equipManual(bro, 1, waiID, false);
					grantedNames.push(::Wuxia.Slots.getManualDef(waiID).Name);
				}
				if (bro.getBackground() != null && ("WX_RefreshStarterNote" in bro.getBackground()))
					bro.getBackground().WX_RefreshStarterNote(grantedNames);
				bro.getSkills().update();
			}
		}
		catch (err)
		{
			::Wuxia.Backgrounds.SuppressAutoAssign = false;
			throw err;
		}
		::Wuxia.Backgrounds.SuppressAutoAssign = false;

		// Starter medical pills + 1 randomized spare common Qinggong/Henglian manual
		local stash = this.World.Assets.getStash();
		local p1 = ::new("scripts/items/misc/wx_pill_item");
		p1.initPill("wx_pill_jinchuang");
		stash.add(p1);

		local p2 = ::new("scripts/items/misc/wx_pill_item");
		p2.initPill("wx_pill_huxin");
		stash.add(p2);

		local spareCat = (::Math.rand(1, 100) <= 65) ? "qinggong" : "henglian";
		local spareID = ::Wuxia.Backgrounds.pickCatalogManual(spareCat, "common", null, usedManuals, "wx_manual_jianbu");
		local spareManual = ::new("scripts/items/misc/wx_manual_item");
		spareManual.initManual(spareID);
		stash.add(spareManual);

		this.World.Assets.m.Money = 2500;
		this.World.Assets.addBusinessReputation(100);

		local food = ::new("scripts/items/supplies/ground_grains_item");
		food.setAmount(25);
		stash.add(food);
		this.World.Assets.updateFood();
	}

	function onSpawnPlayer()
	{
		::Wuxia.spawnPlayerNearSettlement();
	}
});
