// World flags persist hunt cooldowns and unique victories across campaigns' save/load cycles.
::Wuxia.Encounters <- {
	function addTroops( _party, _roster )
	{
		foreach (id in _roster)
		{
			local fighter = id in ::Wuxia.Config.Fighters ? ::Wuxia.Config.Fighters[id] : null;
			local troop = clone ::Const.World.Spawn.Troops[fighter == null ? id : fighter.BaseTroop];
			if (fighter != null) troop.Script = "scripts/entity/tactical/enemies/wx_" + id;
			::Const.World.Common.addTroop(_party, { Type = troop }, true, 0);
			if (fighter != null) _party.getTroops().top().Name = fighter.Name;
		}
	}

	function findTile( _road )
	{
		local playerTile = ::World.State.getPlayer().getTile(), size = ::World.getMapSize();
		local nav = ::World.getNavigator().createSettings();
		nav.ActionPointCosts = ::Const.World.TerrainTypeNavCost_Flat;
		local towns = ::World.EntityManager.getSettlements(), sites = ::World.EntityManager.getLocations();
		local terrain = ::Const.World.TerrainType;
		local x0 = _road ? ::Math.max(2, playerTile.SquareCoords.X - 12) : 2;
		local y0 = _road ? ::Math.max(2, playerTile.SquareCoords.Y - 12) : 2;
		local width = (_road ? ::Math.min(size.X - 2, playerTile.SquareCoords.X + 13) : size.X - 2) - x0;
		local height = (_road ? ::Math.min(size.Y - 2, playerTile.SquareCoords.Y + 13) : size.Y - 2) - y0;
		if (width <= 0 || height <= 0) return null;
		local count = width * height, offset = ::Math.rand(0, count - 1);
		local samples = ::Math.min(1536, count), paths = 0;
		for (local i = 0; i < samples && paths < 32; ++i)
		{
			local idx = (offset + i * count / samples) % count;
			local tile = ::World.getTileSquare(x0 + idx % width, y0 + idx / width);
			if (tile.IsOccupied || tile.HasRoad != _road || tile.Type == terrain.Ocean || tile.Type == terrain.Shore
				|| tile.Type == terrain.Mountains || tile.Type == terrain.Impassable || tile.Type == terrain.Urban) continue;
			if (_road)
			{
				local dist = playerTile.getDistanceTo(tile);
				if (dist < 5 || dist > 12) continue;
			}
			else
			{
				local nearest = 10000;
				foreach (town in towns) nearest = ::Math.min(nearest, tile.getDistanceTo(town.getTile()));
				if (nearest < 7 || nearest > 18) continue;
				local crowded = false;
				foreach (site in sites) if (site.isAlive() && tile.getDistanceTo(site.getTile()) < 4) { crowded = true; break; }
				if (crowded) continue;
			}
			++paths;
			if (!::World.getNavigator().findPath(playerTile, tile, nav, 0).isEmpty()) return tile;
		}
		return null;
	}

	function ensureStronghold( _id, _faction )
	{
		local key = "wx_camp_" + _id;
		local defeated = ::World.Flags.get(key + "_defeated");
		foreach (site in ::World.EntityManager.getLocations())
		{
			if (!site.isAlive() || site.getTypeID() != "location.wx_" + _id) continue;
			if (defeated && !site.isInCombat()) site.fadeOutAndDie();
			return;
		}
		if (defeated) return;
		local tile = this.findTile(false);
		if (tile == null) return;
		local site = ::World.spawnLocation("scripts/entity/world/locations/wx_" + _id, tile.Coords);
		if (site == null) return;
		site.setFaction(_faction.getID());
		site.onSpawned();
	}

	function updateVendetta( _sect, _faction, _day )
	{
		local key = "wx_hunt_" + _sect.ID;
		local previous = ::World.Flags.getAsInt(key + "_id");
		local squad = previous == 0 ? null : ::World.getEntityByID(previous);
		local hostile = ::Wuxia.SectRelations.isVendettaActive(_sect.ID);
		local last = ::World.Flags.getAsInt(key + "_day");
		if (squad != null && squad.isAlive() && squad.getFlags().get("wx_vendetta") == _sect.ID)
		{
			if ((!hostile || _day - last >= 7) && !squad.isInCombat()) squad.fadeOutAndDie();
			return;
		}
		if (!hostile || _day < 14 || (last > 0 && _day - last < 14) || ::World.Flags.getAsInt("wx_last_hunt") == _day) return;
		local tile = this.findTile(true);
		if (tile == null) return;
		local spec = ::Wuxia.Config.Vendettas[_sect.VendettaParty];
		squad = _faction.spawnEntity(tile, spec.Name, false, ::Const.World.Spawn.BanditRaiders, 40, 0);
		if (squad == null) return;
		squad.clearTroops();
		this.addTroops(squad, spec.Troops);
		squad.setDescription(_sect.Name + "派出的寻仇人马，正沿路追查你的行踪。");
		squad.getFlags().set("wx_vendetta", _sect.ID);
		squad.setAlwaysAttackPlayer(true);
		local order = ::new("scripts/ai/world/orders/intercept_order");
		order.setTarget(::World.State.getPlayer());
		squad.getController().addOrder(order);
		squad.getController().addOrder(::new("scripts/ai/world/orders/despawn_order"));
		::World.Flags.set(key + "_id", squad.getID());
		::World.Flags.set(key + "_day", _day);
		::World.Flags.set("wx_last_hunt", _day);
	}

	function update( _state )
	{
		if (_state.getPlayer() == null || ::World.Flags == null || ::World.FactionManager == null) return;
		local day = ::World.getTime().Days;
		if (_state.m.WX_EncounterDay == day) return;
		local faction = ::World.FactionManager.getFactionOfType(::Const.FactionType.Bandits);
		if (faction == null) return;
		_state.m.WX_EncounterDay = day;
		foreach (id, config in ::Wuxia.Config.Strongholds) this.ensureStronghold(id, faction);
		foreach (id, sect in ::Wuxia.Config.Sects) this.updateVendetta(sect, faction, day);
	}
};

::Wuxia.HooksMod.hook("scripts/states/world_state", function( q )
{
	q.startNewCampaign = @(__original) function()
	{
		this.m.WX_EncounterDay <- null;
		__original();
		this.m.WX_EncounterDay = -1;
		::Wuxia.Encounters.update(this);
	};
	q.loadCampaign = @(__original) function( _file )
	{
		this.m.WX_EncounterDay <- null;
		__original(_file);
		this.m.WX_EncounterDay = -1;
		::Wuxia.Encounters.update(this);
	};
	q.updateDayTime = @(__original) function()
	{
		__original();
		if ("WX_EncounterDay" in this.m && this.m.WX_EncounterDay != null) ::Wuxia.Encounters.update(this);
	};
});
