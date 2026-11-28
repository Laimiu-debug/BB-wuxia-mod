// Keep the native placement order, DLC gates, encounter scripts and canonical save names.
::Wuxia.LegendaryLocations <- {
	Sites = [
		["BuildBlackMonolith", "location.black_monolith", "Black Monolith"],
		["BuildGoblinCity", "location.goblin_city", "Rul'gazhix"],
		["BuildUnholdGraveyard", "location.unhold_graveyard", "Unhold Graveyard"],
		["BuildFountainOfYouth", "location.fountain_of_youth", "Grotesque Tree"],
		["BuildWitchHut", "location.witch_hut", "Witch Hut"],
		["BuildWaterWheel", "location.waterwheel", "Watermill"],
		["BuildKrakenCult", "location.kraken_cult", "Stone Pillars"],
		["BuildIcyCave", "location.icy_cave_location", "Icy Cave"],
		["BuildHuntingGround", "location.tundra_elk_location", "Hunting Ground"],
		["BuildAncientWatchTower", "location.ancient_watchtower", "Ancient Spire"],
		["BuildLandShip", "location.land_ship", "Curious Ship Wreck"],
		["BuildAncientStatue", "location.ancient_statue", "Ancient Statue"],
		["BuildAncientTemple", "location.ancient_temple", "Ancient Temple"],
		["BuildSunkenLibrary", "location.sunken_library", "Sunken Library"],
		["BuildHolySite1", "location.holy_site.meteorite", "The Fallen Star"],
		["BuildHolySite2", "location.holy_site.oracle", "The Oracle"],
		["BuildHolySite3", "location.holy_site.vulcano", "The Ancient City"],
		["BuildGolemLocation1", "location.abandoned_village", "Abandoned Village"],
		["BuildGolemLocation2", "location.artifact_reliquary", "Artifact Reliquary"]
	]
};

// Only the native legendary builder gets a second search in a more densely settled world.
// All vanilla terrain, roads, latitude, coast and reachability checks still run.
::Wuxia.HooksMod.hook("scripts/factions/actions/build_unique_locations_action", function( q )
{
	q.getTileToSpawnLocation = @(__original) function( _maxTries = 10, _notOnTerrain = [], _minDistToSettlements = 7, _maxDistToSettlements = 1000, _maxDistanceToAllies = 1000, _minDistToEnemyLocations = 7, _minDistToAlliedLocations = 7, _nearTile = null, _minY = 0.0, _maxY = 1.0 )
	{
		local tile = __original(_maxTries, _notOnTerrain, _minDistToSettlements, _maxDistToSettlements, _maxDistanceToAllies, _minDistToEnemyLocations, _minDistToAlliedLocations, _nearTile, _minY, _maxY);
		if (tile != null) return tile;
		return __original(_maxTries * 3, _notOnTerrain, ::Math.min(_minDistToSettlements, 18), _maxDistToSettlements, _maxDistanceToAllies, ::Math.min(_minDistToEnemyLocations, 7), ::Math.min(_minDistToAlliedLocations, 7), _nearTile, _minY, _maxY);
	};
});

::Wuxia.LegendaryLocations.reconcile <- function( _newCampaign )
{
	local flags = ::World.Flags;
	if (flags.get("wx_legendary_placement_v1")) return;
	local bandits = ::World.FactionManager.getFactionOfType(::Const.FactionType.Bandits);
	if (bandits == null || ::World.State.getPlayer() == null) return;

	local placer = ::new("scripts/factions/actions/build_unique_locations_action");
	placer.setFaction(bandits);
	placer.updateBuildings();
	local existing = {};
	foreach (site in ::World.EntityManager.getLocations())
		if (site.isLocationType(::Const.World.LocationType.Unique)) existing[site.getTypeID()] <- site;

	local lastPlaced = -1;
	local existingCount = 0;
	local undisposedDiscoveries = flags.getAsInt("LegendaryLocationsDiscovered");
	foreach (i, entry in this.Sites)
	{
		local id = entry[1];
		if (!(id in existing)) continue;
		lastPlaced = i;
		++existingCount;
		local site = existing[id];
		// The three southern holy sites do not increment the vanilla discovery counter.
		if (site.isDiscovered() && id.find("location.holy_site.") != 0) --undisposedDiscoveries;
		if (::Wuxia.WorldVisuals.isKnownWildCampName(site.getName()))
		{
			site.setName(entry[2]);
			if (site.hasLabel("name")) site.getLabel("name").Text = entry[2];
		}
	}

	local pending = [];
	foreach (i, entry in this.Sites)
	{
		local field = entry[0], key = "wx_legendary_" + field;
		if (!(field in placer.m)) continue;
		local missing = placer.m[field];
		placer.m[field] = false;
		if (!missing) continue;
		// An absent site before a surviving later one was already placed by vanilla.
		// Account for cleared sites at the end of the original sequence as well.
		if (!_newCampaign && !flags.get(key) && (i < lastPlaced || undisposedDiscoveries > 0))
		{
			if (entry[1].find("location.holy_site.") != 0) --undisposedDiscoveries;
			continue;
		}
		flags.set(key, true);
		pending.push(entry);
	}

	local restored = 0;
	foreach (entry in pending)
	{
		local field = entry[0];
		placer.m[field] = true;
		for (local attempt = 0; attempt < 6 && placer.m[field]; ++attempt)
		{
			placer.onExecute(bandits);
			placer.updateBuildings();
		}
		if (!placer.m[field])
		{
			++restored;
			flags.set("wx_legendary_" + field, false);
		}
		placer.m[field] = false;
	}
	if (restored == pending.len()) flags.set("wx_legendary_placement_v1", true);
	::logInfo("[mod_wuxia] Native legendary locations: found " + existingCount + ", placed " + restored + " of " + pending.len() + " missing sites.");
};

::Wuxia.HooksMod.hook("scripts/states/world_state", function( q )
{
	q.startNewCampaign = @(__original) function( ... )
	{
		vargv.insert(0, this);
		local result = __original.acall(vargv);
		::Wuxia.LegendaryLocations.reconcile(true);
		return result;
	};
	q.onDeserialize = @(__original) function( _in )
	{
		local result = __original(_in);
		::Wuxia.LegendaryLocations.reconcile(false);
		return result;
	};
});
