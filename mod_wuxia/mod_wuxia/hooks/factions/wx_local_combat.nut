::Wuxia.HooksMod.hook("scripts/states/world_state", function( q )
{
	q.getLocalCombatProperties = @(__original) function( _pos, _ignoreNoEnemies = false )
	{
		// The native battle-music counter has 32 slots even on larger world maps.
		local factions = this.World.FactionManager.getFactions();
		if (factions.len() <= 32) return __original(_pos, _ignoreNoEnemies);

		local radius = this.Const.World.CombatSettings.CombatPlayerDistance;
		local nearby = this.World.getAllEntitiesAtPos(_pos, radius);
		local eligible = @(p) p.isAlive() && !p.isPlayerControlled() && p.isAttackable()
			&& p.getFaction() != 0 && p.getVisibilityMult() != 0.0;
		local isUnique = @(p) p.isLocation() && p.isLocationType(::Const.World.LocationType.Unique);
		local uniqueOnly = false;
		foreach (party in nearby)
		{
			if (!eligible(party)) continue;
			if (isUnique(party)) { uniqueOnly = true; break; }
			if (party.isInCombat())
			{
				nearby = this.World.getAllEntitiesAtPos(_pos, radius * 2.0);
				break;
			}
		}

		local parties = [], needsLargerCounter = false;
		foreach (party in nearby)
		{
			if (!eligible(party) || (uniqueOnly && !isUnique(party))) continue;
			if (!_ignoreNoEnemies)
			{
				local hasOpponent = false;
				foreach (other in nearby)
					if (other.isAlive() && !party.isAlliedWith(other)) { hasOpponent = true; break; }
				if (!hasOpponent) continue;
			}
			parties.push(party);
			if (party.getFaction() >= 32 && !this.World.FactionManager.isAlliedWithPlayer(party.getFaction()))
				needsLargerCounter = true;
		}
		if (!needsLargerCounter) return __original(_pos, _ignoreNoEnemies);

		local props = this.Const.Tactical.CombatInfo.getClone();
		props.Tile = this.World.getTile(this.World.worldToTile(_pos));
		props.TerrainTemplate = this.Const.World.TerrainTacticalTemplate[props.Tile.TacticalType];
		props.InCombatAlready = false;
		props.IsAttackingLocation = false;
		local counts = array(factions.len(), 0);
		foreach (party in parties)
		{
			if (party.isInCombat()) props.InCombatAlready = true;
			if (party.isLocation())
			{
				props.IsAttackingLocation = true;
				props.CombatID = "LocationBattle";
				props.LocationTemplate = party.getCombatLocation();
				props.LocationTemplate.OwnedByFaction = party.getFaction();
			}

			this.World.Combat.abortCombatWithParty(party);
			party.onBeforeCombatStarted();
			local troops = party.getTroops();
			local id = party.getFaction();
			foreach (troop in troops)
			{
				if (troop.Script == "") continue;
				troop.Faction <- id;
				troop.Party <- this.WeakTableRef(party);
				props.Entities.push(troop);
				if (!this.World.FactionManager.isAlliedWithPlayer(id)) ++counts[id];
			}
			if (troops.len() == 0) continue;
			party.onCombatStarted();
			props.Parties.push(party);
			this.m.PartiesInCombat.push(party);
			local banners = party.isAlliedWithPlayer() ? props.AllyBanners : props.EnemyBanners;
			banners.push(party.getBanner());
		}

		local most = 0;
		foreach (id, count in counts)
			if (count > counts[most]) most = id;
		local mainFaction = this.World.FactionManager.getFaction(most);
		if (mainFaction != null) props.Music = mainFaction.getCombatMusic();
		return props;
	};
});
