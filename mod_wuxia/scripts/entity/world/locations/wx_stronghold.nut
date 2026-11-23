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
			local bID = ("getBossIDForSite" in ::Wuxia.ShanHai) ? ::Wuxia.ShanHai.getBossIDForSite(this.m.WX_Site) : null;
			local bTier = (bID != null && "getBossTier" in ::Wuxia.ShanHai) ? ::Wuxia.ShanHai.getBossTier(bID) : 2;
			local sovChance = (bTier >= 3) ? 85 : ((bTier == 2) ? 45 : 25);
			if (::Math.rand(1, 100) <= sovChance)
			{
				local sovCore = ::Wuxia.ShanHai.createRandomSovereignCore();
				if (sovCore != null) this.m.Loot.add(sovCore);
			}
		}
		else if (::Math.rand(1, 100) <= 30)
		{
			local relic = ::Wuxia.Relics.createRandomRelic();
			if (relic != null) this.m.Loot.add(relic);
		}
		this.getFlags().set("wx_garrison_ready", true);
	}

	function getTooltip()
	{
		local ret = this.location.getTooltip();
		if (ret != null && typeof ret == "array" && this.m.WX_Site != null && ("ShanHai" in ::Wuxia) && ("getBossIDForSite" in ::Wuxia.ShanHai))
		{
			local bossID = ::Wuxia.ShanHai.getBossIDForSite(this.m.WX_Site);
			if (bossID != null && (bossID in ::Wuxia.Config.ShanHaiBosses))
			{
				local cfg = ::Wuxia.Config.ShanHaiBosses[bossID];
				local tier = ::Wuxia.ShanHai.getBossTier(bossID);
				local tInfo = ::Wuxia.ShanHai.getBossTierInfo(tier);
				local hint = ::Wuxia.ShanHai.getBossCounterHint(bossID);
				local tCol = ("TooltipColor" in tInfo) ? tInfo.TooltipColor : tInfo.Color;
				ret.push({
					id   = 50,
					type = "text",
					icon = "ui/icons/special.png",
					text = "险地品阶：[color=" + tCol + "]【" + tInfo.Label + "】[/color]（" + tInfo.Advice + "）"
				});
				ret.push({
					id   = 51,
					type = "text",
					icon = "ui/icons/melee_skill.png",
					text = "凶兽神通：[color=#5e2c00]" + cfg.TraitName + "[/color] — " + cfg.TraitDesc
				});
				if (hint != "")
				{
					ret.push({
						id   = 52,
						type = "text",
						icon = "ui/icons/vision.png",
						text = "战前备策：[color=#0a4213]" + hint + "[/color]"
					});
				}
			}
		}
		return ret;
	}

	function onCombatLost()
	{
		::World.Flags.set("wx_camp_" + this.m.WX_Site + "_defeated", true);
		return this.location.onCombatLost();
	}
});
