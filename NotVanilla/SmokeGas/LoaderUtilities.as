// LoaderUtilities.as

#include "DummyCommon.as";

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	//I FUCKING HATE KAG

	Vec2f pos = map.getTileWorldPosition(offset);
	bool was_solid = map.isTileSolid(pos);
	u16 type = map.getTile(offset).type;

	if (!was_solid) return true;
	
	CBlob@ tileblob = server_CreateBlob("tileentity", -3, pos);
	if (tileblob is null) return true;

	tileblob.getShape().SetGravityScale(1.0f);
	tileblob.Tag("no_rotations");
	tileblob.setPosition(pos+Vec2f(XORRandom(80)-40, 0)*0.03f);
	
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