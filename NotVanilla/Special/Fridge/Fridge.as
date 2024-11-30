// Fridge.as
// literally Concrete Donkey from Worms: Armaggedon :D
#include "Hitters.as"

void onInit(CBlob@ this)
{
	this.Tag("special");
	this.Tag("heavy weight");

	// shape
	Vec2f pos_off(0, 0);
	{
		Vec2f[] shape = { Vec2f(106.0f,  100.0f) - pos_off,
		                  Vec2f(108.0f,  126.0f) - pos_off,
		                  Vec2f(-14.0f,  126.0f) - pos_off,
		                  Vec2f(-5.0f,  85.0f) - pos_off
		                };
		this.getShape().AddShape(shape);
	}
}

void MakeHugeHole(CBlob@ this)
{
	CMap@ map = getMap();
	Vec2f hit_pos = this.getPosition();
	Vec2f map_dims = Vec2f(map.tilemapwidth, map.tilemapheight);
	Vec2f tilespace_pos = map.getTileSpacePosition(hit_pos);

	int depth = (map_dims.y);
	int width = 18;

	for (int x_idx = -width/2; x_idx < width/2; ++x_idx)
	{
		for (int y_idx = 0; y_idx < depth; ++y_idx)
		{
			Vec2f final_pos = Vec2f(hit_pos.x, 0) + Vec2f(x_idx, y_idx)*map.tilesize;
			map.server_DestroyTile(final_pos, 24);
			for (int idx = 0; idx < 24; idx++)
			{
				if (!map.isTileSolid(final_pos))
					break;
				map.server_DestroyTile(final_pos, 1);
			}
		}
	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	if (solid && this.getOldVelocity().Length() > 5) {
		MakeHugeHole(this);
	}

	if (blob is null) return;

	if (this.getOldVelocity().Length()<2) return;

	if (blob.hasTag("player") && blob.getPosition().y < this.getPosition().y && this.getVelocity().y>=0) return;

	this.server_Hit(blob, point1, this.getOldVelocity(), 50, Hitters::flying, true);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}