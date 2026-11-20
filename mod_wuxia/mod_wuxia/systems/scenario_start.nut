::Wuxia.spawnPlayerNearSettlement <- function()
{
	local settlements = ::World.EntityManager.getSettlements();
	local randomVillage = settlements[0];
	foreach (s in settlements)
	{
		if (!s.isMilitary() && !s.isIsolatedFromRoads() && s.isAlliedWithPlayer())
		{
			randomVillage = s;
			break;
		}
	}

	local spawnTile = randomVillage.getTile();
	local navSettings = ::World.getNavigator().createSettings();
	navSettings.ActionPointCosts = ::Const.World.TerrainTypeNavCost_Flat;

	for (local tries = 0; tries < 200; tries = ++tries)
	{
		local x = ::Math.rand(::Math.max(2, spawnTile.SquareCoords.X - 4), ::Math.min(::Const.World.Settings.SizeX - 2, spawnTile.SquareCoords.X + 4));
		local y = ::Math.rand(::Math.max(2, spawnTile.SquareCoords.Y - 4), ::Math.min(::Const.World.Settings.SizeY - 2, spawnTile.SquareCoords.Y + 4));
		if (!::World.isValidTileSquare(x, y)) continue;
		local tile = ::World.getTileSquare(x, y);
		if (tile.Type == ::Const.World.TerrainType.Ocean || tile.Type == ::Const.World.TerrainType.Shore || tile.IsOccupied) continue;
		if (tile.getDistanceTo(spawnTile) <= 1) continue;
		local path = ::World.getNavigator().findPath(tile, spawnTile, navSettings, 0);
		if (!path.isEmpty())
		{
			spawnTile = tile;
			break;
		}
	}

	::World.State.m.Player = ::World.spawnEntity("scripts/entity/world/player_party", spawnTile.Coords.X, spawnTile.Coords.Y);
	::World.Assets.updateLook(1);
	::World.getCamera().setPos(::World.State.m.Player.getPos());
};
