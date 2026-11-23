// Pure Wuxia Origin 5: 「边关残部 · 铁血老卒」
// 4 Battle-scarred frontier heavy infantry & Shenji firearm veteran start.

this.wx_origin_frontier_veterans <- this.inherit("scripts/scenarios/world/starting_scenario", {
	m = {},

	function create()
	{
		this.m.ID = "scenario.wx_origin_frontier_veterans";
		this.m.Name = "边关残部 · 铁血老卒";
		this.m.Description = "[p=c][img]gfx/ui/events/wx_ev_05.png[/img][/p][p]一场边关惨败后，四名从死人堆里爬出来的九边老卒聚拢残旗。你们不通花哨剑舞，唯凭军中硬功《铁布衫》、长戟大刀结阵与神机火铳轰鸣，在乱世硬生生杀出一条血路。[/p][p][color=#bcad8c]• 开局阵容：4 名九边老卒（刀盾/长戟/重锤/神机火铳齐备），备有《铁布衫》《聚义令》《神机火器谱》\n• 九边军纪：全队同袍每日饷银 -15%，随军修械速度 +25%，起始铁料火药充裕\n• 悍卒本色：不擅商贾周旋，市集售卖战利品回银 -8%[/color][/p]";
		this.m.Difficulty = 2;
		this.m.Order = 5;
	}

	function onInit()
	{
		if ("DailyWageMult" in this.World.Assets.m)
			this.World.Assets.m.DailyWageMult *= 0.85;
		if ("RepairSpeedMult" in this.World.Assets.m)
			this.World.Assets.m.RepairSpeedMult *= 1.25;
		if ("SellPriceMult" in this.World.Assets.m)
			this.World.Assets.m.SellPriceMult *= 0.92;
	}

	function onSpawnAssets()
	{
		local roster = this.World.getPlayerRoster();
		local vets = [
			{ Pool = "jianghu", Bg = "retired_soldier_background", Wpn = "weapons/military_cleaver",   Off = "shields/wooden_shield", WaiOverride = null,               Learn = "wx_manual_tiebushan" },
			{ Pool = "jianghu", Bg = "deserter_background",        Wpn = "weapons/billhook",           Off = null,                    WaiOverride = null,               Learn = "wx_manual_juyiling" },
			{ Pool = "folk",    Bg = "militia_background",         Wpn = "weapons/warhammer",          Off = "shields/wooden_shield", WaiOverride = null,               Learn = null },
			{ Pool = "jianghu", Bg = "hunter_background",          Wpn = "weapons/oriental/handgonne", Off = null,                    WaiOverride = "wx_manual_shenji", Learn = null }
		];

		local usedNames = {};
		local usedManuals = {};

		::Wuxia.Backgrounds.SuppressAutoAssign = true;
		try
		{
			for (local i = 0; i < vets.len(); i = ++i)
			{
				local vt = vets[i];
				local bro = roster.create("scripts/entity/tactical/player");
				bro.setStartValuesEx([vt.Bg]);
				::Wuxia.Backgrounds.rollUniqueActorName(bro, usedNames, vt.Pool);
				bro.setPlaceInFormation(i < 3 ? (i + 2) : 11);
				bro.m.HireTime = this.Time.getVirtualTimeF();
				bro.m.BaseProperties.Bravery += 8;
				bro.m.PerkPoints = 0;

				local items = bro.getItems();
				if (items.getItemAtSlot(this.Const.ItemSlot.Mainhand) != null)
					items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
				if (items.getItemAtSlot(this.Const.ItemSlot.Offhand) != null)
					items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));
				local mainWpn = ::new("scripts/items/" + vt.Wpn);
				items.equip(mainWpn);
				if (vt.Off != null)
					items.equip(::new("scripts/items/" + vt.Off));
				if (vt.Wpn.find("handgonne") != null && items.getItemAtSlot(this.Const.ItemSlot.Ammo) == null)
					items.equip(::new("scripts/items/ammo/powder_bag"));

				local neiID = ::Wuxia.Backgrounds.pickCatalogManual("neigong", "common", null, usedManuals, "wx_manual_tuna");
				local waiID = (vt.WaiOverride != null)
					? vt.WaiOverride
					: ::Wuxia.Backgrounds.pickCatalogManual("waigong", "common", mainWpn, usedManuals, "wx_manual_wuhudao");
				::Wuxia.Slots.equipManual(bro, 0, neiID, false);
				::Wuxia.Slots.equipManual(bro, 1, waiID, false);
				if (vt.Learn != null)
					::Wuxia.Slots.learnManual(bro, vt.Learn, false);
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

		local stash = this.World.Assets.getStash();
		this.World.Assets.m.Money = 2200;
		this.World.Assets.m.ArmorParts = 45;
		this.World.Assets.m.Ammo = 60;
		this.World.Assets.m.Medicine = 20;
		this.World.Assets.addBusinessReputation(150);

		local food = ::new("scripts/items/supplies/cured_rations_item");
		food.setAmount(25);
		stash.add(food);
		this.World.Assets.updateFood();
	}

	function onSpawnPlayer()
	{
		::Wuxia.spawnPlayerNearSettlement();
		this.World.Assets.updateLook(12);
	}
});
