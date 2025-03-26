// LoaderUtilities.as

#include "DummyCommon.as";

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	//I FUCKING HATE KAG

	Vec2f pos = map.getTileWorldPosition(offset);
	bool was_solid = map.isTileSolid(pos);
	u16 type = map.getTile(offset).type;

	if (!was_solid) return true;
	
	CBlob@ tileblob = server_CreateBlob("tileentity", -3, pos+Vec2f(1, 2)*map.tilesize/2);
	if (tileblob is null) return true;

	//if the tile-to-collapse was wooden and was on fire we just kill it
	if (map.isTileWood(type) && map.isInFire(pos))
	{	
		tileblob.set_s32("tile_frame", 400);
		tileblob.getShape().SetGravityScale(0);
		tileblob.server_SetTimeToDie(4.0f/30);

		CBitStream params;
		params.write_Vec2f(pos);
		getRules().SendCommand(getRules().getCommandID("create wood gibs"), params);

		return true;
	}

	tileblob.getShape().SetGravityScale(0.4f);
	tileblob.Tag("no_rotations");
	tileblob.Tag("collapsing_tile");
	
	tileblob.set_s32("tile_frame", type);
	tileblob.set_u32("tile_flags", map.getTileFlags(offset));
	
	return true;
}

/*
TileType server_onTileHit(CMap@ this, f32 damage, u32 index, TileType oldTileType)
{
}
*/

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	if(isDummyTile(tile_new))
	{
		map.SetTileSupport(index, 10);

		switch(tile_new)
		{
			case Dummy::SOLID:
			case Dummy::OBSTRUCTOR:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			case Dummy::BACKGROUND:
			case Dummy::OBSTRUCTOR_BACKGROUND:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				break;
			case Dummy::LADDER:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LADDER | Tile::WATER_PASSES);
				break;
			case Dummy::PLATFORM:
				map.AddTileFlag(index, Tile::PLATFORM);
				break;
		}
	}
}