
/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */

namespace CMap
{
	enum CustomTiles
	{
		//pick tile indices from here - indices > 256 are advised.
		tile_tough_castle = 300
	};
};

const SColor color_tough_castle(255, 142, 42, 9);

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	//change this in your mod
	Vec2f pos = map.getTileWorldPosition(offset);

	//tiles
	if (pixel == color_tough_castle) {
		map.server_SetTile(pos, CMap::tile_tough_castle);
	}
}