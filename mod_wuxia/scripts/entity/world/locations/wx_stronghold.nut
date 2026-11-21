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
		local b = ::Wuxia.Config.Strongholds[this.m.WX_Site].Brush;
		if ("doesBrushExist" in getroottable() && !::doesBrushExist(b))
		{
			local pool = [
				"wx_lair_kaiming", "wx_lair_jinwu", "wx_lair_zouyu", "wx_lair_gonggong",
				"wx_lair_wuluo", "wx_lair_siwang", "wx_lair_jiufeng", "wx_lair_mingshe",
				"wx_lair_huashe", "wx_lair_fuzhu", "wx_lair_chenghuang", "wx_lair_dangkang",
				"wx_lair_boshi", "wx_lair_jiao", "wx_lair_bingyi", "wx_lair_qiangliang"
			];
			local h = 0;
			local k = (this.m.WX_Site != null) ? ("" + this.m.WX_Site) : "x";
			for (local i = 0; i < k.len(); i = ++i) h = (h * 31 + k[i]) & 0x3FFFFFFF;
			b = pool[h % pool.len()];
		}
		this.addSprite("body").setBrush(b);
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
		local isSH = ("IsShanHai" in def) && def.IsShanHai;
		if (def.GivesHerb && (isSH || ::Math.rand(1, 100) <= 40))
			this.m.Loot.add(::new("scripts/items/misc/wx_marrow_herb"));
		if (isSH)
		{
			local shHerb = ::Wuxia.ShanHai.createRandomHerb(true);
			if (shHerb != null) this.m.Loot.add(shHerb);
			local shRelic = (::Math.rand(1, 100) <= 68) ? ::Wuxia.Relics.createRandomShanHaiRelic() : ::Wuxia.Relics.createRandomRelic();
			if (shRelic != null) this.m.Loot.add(shRelic);
		}
		else if (::Math.rand(1, 100) <= 30)
		{
			local relic = ::Wuxia.Relics.createRandomRelic();
			if (relic != null) this.m.Loot.add(relic);
		}
		this.getFlags().set("wx_garrison_ready", true);
	}

	function onCombatLost()
	{
		::World.Flags.set("wx_camp_" + this.m.WX_Site + "_defeated", true);
		return this.location.onCombatLost();
	}
});
