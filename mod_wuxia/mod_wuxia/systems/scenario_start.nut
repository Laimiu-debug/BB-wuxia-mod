::Wuxia.spawnPlayerNearSettlement <- function()
{
	local townTile = ::World.EntityManager.getSettlements()[0].getTile();
	local spawnTile = townTile;
	for (local dir = 0; dir < ::Const.Direction.COUNT; ++dir)
	{
		if (!townTile.hasNextTile(dir)) continue;
		local tile = townTile.getNextTile(dir);
		if (tile.HasRoad && !tile.IsOccupied)
		{
			spawnTile = tile;
			break;
		}
	}

	local player = ::World.spawnEntity("scripts/entity/world/player_party", spawnTile.Coords.X, spawnTile.Coords.Y);
	::World.State.m.Player = player;
	::World.getCamera().setPos(player.getPos());
};
