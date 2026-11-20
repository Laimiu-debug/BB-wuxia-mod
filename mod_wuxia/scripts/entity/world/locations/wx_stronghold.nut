this.wx_stronghold <- this.inherit("scripts/entity/world/location", {
	m = { WX_Site = null },

	function create()
	{
		this.location.create();
		local def = ::Wuxia.Config.Strongholds[this.m.WX_Site];
		this.m.TypeID = "location.wx_" + this.m.WX_Site;
		this.m.Name = def.Name;
		this.m.Description = def.Description;
		this.m.LocationType = this.Const.World.LocationType.Lair | this.Const.World.LocationType.Unique;
		this.m.IsSpawningDefenders = false;
		this.m.IsDespawningDefenders = false;
		this.m.IsScalingDefenders = false;
		this.m.IsAttackableByAI = false;
		this.m.IsShowingDefenders = true;
		this.m.Resources = 180;
		this.m.CombatLocation.Template = def.Fortified ? ["tactical.human_camp"] : [null, null];
		this.m.CombatLocation.Fortification = def.Fortified ? this.Const.Tactical.FortificationType.Palisade : this.Const.Tactical.FortificationType.None;
		this.m.CombatLocation.ForceLineBattle = !def.Fortified;
	}

	function getDescription() { return this.m.Description; }

	function onInit()
	{
		this.location.onInit();
		this.addSprite("body").setBrush(::Wuxia.Config.Strongholds[this.m.WX_Site].Brush);
	}

	function onSpawned()
	{
		if (this.getFlags().get("wx_garrison_ready")) return;
		this.location.onSpawned();
		local def = ::Wuxia.Config.Strongholds[this.m.WX_Site];
		::Wuxia.Encounters.addTroops(this, def.Troops);
		local pages = ::new("scripts/items/misc/wx_page_item");
		pages.initPages(def.RewardManual, 2);
		this.m.Loot.add(pages);
		if ("ExtraManual" in def && def.ExtraManual != null)
		{
			local extra = ::new("scripts/items/misc/wx_page_item");
			extra.initPages(def.ExtraManual, 1);
			this.m.Loot.add(extra);
		}
		if (def.GivesHerb) this.m.Loot.add(::new("scripts/items/misc/wx_marrow_herb"));
		this.getFlags().set("wx_garrison_ready", true);
	}

	function onCombatLost()
	{
		::World.Flags.set("wx_camp_" + this.m.WX_Site + "_defeated", true);
		return this.location.onCombatLost();
	}
});
